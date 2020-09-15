/*-
 * Copyright (C) 2020, Vi Grey
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

package main

import (
	"github.com/mikepb/go-serial"

	"bufio"
	"fmt"
	"io/ioutil"
	"net"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"
)

const (
	DIALHOST = "vigrey.com"
	DIALPORT = "56502"
)

var (
	ctrlC                        chan os.Signal
	msgQueue                     []byte
	usbSerialConnected           bool
	device                       *serial.Port
	issDataBuffer, issSecondData []byte
	start                        bool
	stop                         chan bool
)

/*
 * ------------------------------
 * CTRL+C HANDLER CODE  (START)
 * ------------------------------
 */

// Set Ctrl-C handling
func setupCloseHandler() {
	ctrlC = make(chan os.Signal)
	signal.Notify(ctrlC, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-ctrlC
		os.Exit(0)
	}()
}

/*
 * ------------------------------
 * CTRL+C HANDLER CODE  (END)
 * ------------------------------
 */

/*
 * ------------------------------
 * ISS DATA CODE (START)
 * ------------------------------
 */

// Grabs ISS position data from DIALHOST:DIALPORT and set it to the
// issDataBuffer
func tcpGet() {
	// Get ISS position data from DIALHOST:DIALPORT
	conn, err := net.Dial("tcp", DIALHOST+":"+DIALPORT)
	if err == nil {
		// Get ISS position data from the request
		issDataBufferTmp, err := ioutil.ReadAll(conn)
		if err == nil {
			if len(issDataBufferTmp) > 600 {
				// If DIALHOST:DIALPORT provides more than 60 seconds of
				// data, set buffer to the response
				issDataBuffer = issDataBufferTmp[:]
			}
		}
	}
}

// Timer set for 60 seconds continually to grab ISS position data from
// DIALHOST:DIALPORT
func getISSData() {
	for {
		// Wait 60 seconds before getting data from https://vigrey.com/iss
		<-time.After(60 * time.Second)
		go tcpGet()
	}
}

// Timer set for 1 second continually to set this second's 10 bytes of
// ISS tracking data from the buffer
func getISSSecondData() {
	for {
		// Wait 1 second before setting new framePosition
		<-time.After(1 * time.Second)
		go getISSSecondDataBytes()
	}
}

// Grabs this second's 10 bytes of ISS tracking data
func getISSSecondDataBytes() {
	if len(issDataBuffer) < 10 {
		// If the buffer length is less than 10, set framePosition to
		// default Epoch time values
		issSecondData = []byte{0x01, 0x19, 0x70, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00}
	} else {
		// Set issSecondData to the first 10 bytes of issDataBuffer
		// Remove first 10 bytes of buffer
		issSecondData = issDataBuffer[:10]
		issDataBuffer = issDataBuffer[10:]
	}
	if usbSerialConnected {
		// Set 2 FE pulse bytes at the beginning of issSecondData
		issSecondData = append([]byte{0xff, 0xff, 0xff}, issSecondData...)
		issSecondDataToMsgBuffer()
		go sendMsgQueueChunk()
	}
}

// Set 'A' character in front of each byte of issSecondData and add the
// data to msgQueue
func issSecondDataToMsgBuffer() {
	dataForMsgBuffer := []byte{}
	for _, b := range issSecondData {
		dataForMsgBuffer = append(dataForMsgBuffer, 'A')
		dataForMsgBuffer = append(dataForMsgBuffer, b)
	}
	msgQueue = append(msgQueue, dataForMsgBuffer...)
}

/*
 * ------------------------------
 * ISS DATA CODE (END)
 * ------------------------------
 */

/*
 * ------------------------------
 * USB SERIAL CODE (START)
 * ------------------------------
 */

// Try to connect to TAStm32 device, if failed to connect, waits 1
// second and tries connecting again
func connectSerial() {
	serialUSBPath := getTAStm32COMPath()
	if serialUSBPath != "" {
		connectToSerialUSB(serialUSBPath)
	}
}

// Get the Serial Device location to connect to the TAStm32
func getTAStm32COMPath() string {
	infoList, err := serial.ListPorts()
	usbSerialPath := ""
	if err != nil {
		return usbSerialPath
	}
	for _, list := range infoList {
		vid, pid, _ := list.USBVIDPID()
		vidStr := strings.ToLower(strconv.FormatInt(int64(vid), 16))
		pidStr := strings.ToLower(strconv.FormatInt(int64(pid), 16))
		if pidStr == "7a5" && vidStr == "b07" {
			usbSerialPath = list.Name()
			break
		}
	}
	return usbSerialPath
}

// Connect to TAStm32 device
func connectToSerialUSB(usbSerialPath string) {
	usbSerialConnected = false
	options := serial.RawOptions
	options.Mode = serial.MODE_READ_WRITE
	options.BitRate = 115200
	var err error
	device, err = options.Open(usbSerialPath)
	if err != nil {
		printStatus("<!> Error Connecting to TAStm32 Device!")
		return
	}
	defer device.Close()
	_, err = device.WriteString("R")
	if err != nil {
		fmt.Println(err)
		return
	}
	buf := make([]byte, 2)
	_, err = device.Read(buf)
	if err != nil {
		fmt.Println(err)
		return
	}
	_, err = device.WriteString("SAN\x80\x00")
	if err != nil {
		fmt.Println(err)
		return
	}
	buf = make([]byte, 2)
	_, err = device.Read(buf)
	if err != nil {
		fmt.Println(err)
		return
	}
	_, err = device.WriteString("A\x00")
	if err != nil {
		fmt.Println(err)
		return
	}
	usbSerialConnected = true
	msgQueue = []byte{}
	start = true
	stop = make(chan bool)

	<-stop
}

// Prints status message to STDOUT along with a timestamp
func printStatus(msg string) {
	timestamp := time.Now().Format("Jan 02 15:04:05")
	fmt.Println(timestamp + " - " + msg)
}

// SendmsgQueue data from the TAStm32 device to the NES
func sendMsgQueueChunk() {
	if device != nil {
		if len(msgQueue) >= 2 {
			device.Write(msgQueue)
			msgQueue = []byte{}
		}
	}
}

/*
 * ------------------------------
 * USB SERIAL CODE (END)
 * ------------------------------
 */

/*
 * ------------------------------
 * COMMAND ENTER CODE (START)
 * ------------------------------
 */

func getCommand() {
	printHelp()
	for {
		fmt.Println()
		fmt.Print("ENTER COMMAND: ")
		r := bufio.NewReader(os.Stdin)
		cmdStr, _ := r.ReadString('\n')
		cmdStr = strings.ToLower(strings.TrimSuffix(cmdStr, "\n"))
		fmt.Println()
		if cmdStr == "start" {
			if start {
				fmt.Println("Cannot Start: TAStm32 Already Started")
			} else {
				fmt.Println("Starting TAStm32")
				go startTAStm32()
			}
		} else if cmdStr == "restart" {
			if start {
				fmt.Println("Stopping TAStm32")
				stopTAStm32()
			}
			fmt.Println("Starting TAStm32")
			go startTAStm32()
		} else if cmdStr == "stop" {
			if !start {
				fmt.Println("Cannot Stop: TAStm32 Not Started")
			} else {
				fmt.Println("Stopping TAStm32")
				stopTAStm32()
			}
		} else if cmdStr == "help" {
			printHelp()
		} else if cmdStr == "quit" {
			return
		} else {
			fmt.Println("Invalid Command")
		}
	}
}

func stopTAStm32() {
	start = false
	usbSerialConnected = false
	stop <- true
}

func startTAStm32() {
	connectSerial()
}

func printHelp() {
	fmt.Println("Available Commands: start, restart, stop, quit, help")
}

/*
 * ------------------------------
 * COMMAND ENTER CODE (END)
 * ------------------------------
 */

func main() {
	setupCloseHandler()
	tcpGet()
	go getISSData()
	go getISSSecondData()
	go getISSSecondDataBytes()
	getCommand()
}
