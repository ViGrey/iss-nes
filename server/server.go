package main

import (
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"time"
)

const (
	HOST = "localhost"
	PORT = "56502"
)

var (
	positionBuffer []byte
	framePosition  []byte
)

func main() {
	httpGet()
	getFramePosition()
	go getISSData()
	go getFrameData()
	startServer()
}

func httpGet() {
	// Get iss position data from https://vigrey.com/iss
	resp, err := http.Get("https://vigrey.com/iss")
	if err == nil {
		// Get ISS position data from
		positionBufferTmp, err := ioutil.ReadAll(resp.Body)
		if err == nil {
			if len(positionBufferTmp) > 600 {
				// If https://vigrey.com/iss provides more than 60 seconds of
				// data, set buffer to the response
				positionBuffer = positionBufferTmp[:]
			}
		}
	}
}

func getISSData() {
	for {
		// Wait 60 seconds before getting data from https://vigrey.com/iss
		<-time.After(60 * time.Second)
		go httpGet()
	}
}

func getFrameData() {
	for {
		// Wait 1 seconds before setting new framePosition
		<-time.After(1 * time.Second)
		go getFramePosition()
	}
}

func getFramePosition() {
	if len(positionBuffer) < 10 {
		// If the buffer length is less than 10, set framePosition to
		// default Epoch time values
		framePosition = []byte{0x01, 0x19, 0x70, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00}
	} else {
		// Set framePosition to the first 10 bytes of buffer
		// Remove first 10 bytes of buffer
		framePosition = positionBuffer[:10]
		positionBuffer = positionBuffer[10:]
	}
}

func startServer() {
	// Start server at HOST:PORT
	l, err := net.Listen("tcp", HOST+":"+PORT)
	if err == nil {
		fmt.Println("Server started at " + HOST + ":" + PORT)
		defer l.Close()
		for {
			// Wait for client to connect to server at HOST:PORT
			conn, err := l.Accept()
			if err == nil {
				// Write framePosition (10 bytes) to client and close
				// connection
				conn.Write(framePosition)
				conn.Close()
			}
		}
	}
}
