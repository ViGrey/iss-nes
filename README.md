# **ISS Tracker for NES**

International Space Station Tracker for the NES

_**ISS Tracker for NES was created by Vi Grey (https://vigrey.com) <vi@vigrey.com> and is licensed under the BSD 2-Clause License.**_

### Description:

This is an NROM NES ROM that tracks the location of the International Space Station in Real-Time.

### Platforms:
- Linux
- Windows

------
## **RUNNING THE NES ROM ON AN EMULATOR**

This NES ROM has only been successfully tested on two NES emulators, Mesen and the Windows version of FCEUX for Windows.  **YOU WILL NEED TO RUN AN INCLUDED LUA SCRIPT TO MAKE THIS NES ROM WORK PROPERLY ON AN EMULATOR.**

### Running the NES ROM:
In the main directory of this project (the directory this README.md file exists in), you will find a `bin` directory.  Inside of this directory is a directory named `nes`, which contains a file named `iss-nes.nes`, which can be opened up in Mesen or the Windows version of FCEUX.  To make this NES ROM work for real-time tracking of the International Space Station, you will need to run an included lua script.

### Running an Included Lua Script on an Emulator:
In the main directory of this project (the directory this README.md file exists in), you will find a `bin` directory.  Inside of this directory is a directory named `lua`, which contains two files named `fceux.lua` and `mesen.lua`.  You can use `mesen.lua` in Mesen and `fceux.lua` in the Windows version of FCEUX.  These lua scripts request real-time ISS tracking data from `vigrey.com` on port `56502` every minute and displays the information in the NES game while it's running.

------
## **BUILDING THE NES ROM SOURCE CODE**

### NES ROM Build Dependencies:
- **asm6** (You'll probably have to build asm6 from source.  Make sure the asm6 binary is named **asm** and that the binary is executable and accessible in your PATH. The source code can be found at http://3dscapture.com/NES/asm6.zip)
- **gmake** (make)

### Build NES ROM on Linux:
From a terminal, go to the the main directory of this project (the directory this README.md file exists in).  You can then build the NES ROM with the following command.

```sh
make
```

The resulting NES ROM will be located at `bin/iss-nes.nes` from the main directory.

### Build NES ROM on Windows:
If you are using Windows, in the command prompt (make sure to have asm6 on your system as `asm.exe`), go to the the `src` directory of this project (the `src` directory this README.md file exists in).  You can then build the NES ROM with the following command.

```
asm.exe iss-nes.asm ..\bin\iss-nes.nes
```

Replace the `asm.exe` command with the path to your `asm6` executable.

The resulting NES ROM will be located at `bin\iss-nes.nes` from the main directory.

------
## **RUNNING THE NES ROM ON ACTUAL NES HARDWARE** _(Requires Linux and a Tool Assisted Speedrun Replay Device)_

### Making the NES ROM work on an NES Cartridge:
To run the ISS-NES ROM on actual hardware, you will need to be able to program it into a cartridge.  This ROM is compatible with NROM-256 boards and uses Vertical Mirroring.  If you cannot program an NROM-256 board with this ROM, you can alternatively use an Everdrive NES flash cartridge by Krikzz or similar device.

### Transferring ISS Tracking Data to the NES Console:
A device that is able to press buttons accurately multiple times a frame is required, as frames that get ISS Tracking data will need to be able to send at least 11 bytes of data to the NES console over the Controller 1 port.  Usually, when a game asks for what buttons a controller is pressing each frame, the controller will respond back with a single byte that frame.  The 11 bytes is for a single frame of data, although you only need to send data on frames where you have updated data.  With that said, it's still humanly impossible to send accurate button inputs that quickly, so you will need the help of a Tool Assisted Speedrun replay device  (If you are unfamiliar with Tool Assisted Speedruns or Tool Assisted Speedrun replay devices, you can check out TASBot online to see such devices in action, especially at Games Done Quick events).

A device called the TAStm32 can be used for this purpose, which can be purchased at https://store.tas.bot/owna/index.php/product/tastm32-a-tas-replay-device/.  You will also need to create a custom RJ45 Ethernet to NES Controller cable in order for the TAStm32 to connect to the NES console over the controller port.  Documentation on how how to create such a cable can be found at https://github.com/Ownasaurus/TAStm32/wiki/Hardware.

### Controlling the TAStm32 Board With the ISS Tracker NES ROM:
In the main directory of this project (the directory this README.md file exists in), you will find a `bin` directory.  Inside of this directory is a directory named `iss-nes-TAStm32`, which contains multiple files that start with `iss-nes-TAStm32-linux-`.  The last part of the file names is the architecture of the Linux computer you will be running the program on to control the TAStm32.  The available architectures in this directory are **amd64**, which is useful for most laptop and desktop Linux computers, **arm**, which is useful for the Raspberry Pi, and **arm64** for 64 bit arm Linux computers.

### Usage of iss-nes-TAStm32:
The following command will not include the `-linux-*` part of the program for the sake of simplicity, but do know that the precompiled iss-nes-TAStm32 program may have more to its name than just iss-nes-TAStm32.

```
./iss-nes-TAStm32
Available Commands: start, restart, stop, quit, help

ENTER COMMAND:
```

Upon starting iss-nes-TAStm32, a TCP connection will be made to `vigrey.com` at port `56502` every 60 seconds to get 70 seconds of ISS tracking data.  This program will not connect to the TAStm32 board until you type `start` in after running the command.  You may need to add the included `udev` rules in the `udev` directory inside of the `iss-nes-TAStm32` directory if you want to connect to the TAStm32 board without running iss-nes-TAStm32 as root.

------
## **BUILDING THE ISS-NES SPECIFIC TASTM32 CONTROLLER SOURCE CODE** _(Linux Only)_

### iss-nes-TAStm32 Build Dependencies:
- **go** (with cgo)

This program depends on mikepb's go-serial package in order to compile.  To get the go-serial package, run the following command.

```sh
go get github.com/mikepb/go-serial
```

Inside of the main directory of this project (the directory this README.md file exists in), you will find a directory named `iss-nes-TAStm32` which contains a file named `iss-nes-TAStm32.go`. You can compile the iss-nes-TAStm32 program with the following command.

```sh
go build iss-nes-TAStm32.go
```

The resulting file will be located at `iss-nes-TAStm32/iss-nes-TAStm32` from tha main directory.

------
## **ISS TRACKING DATA TO CONTROLLER PROTOCOL**
This game uses the Controller 1 port to retrieve ISS tracking data.  If you are using the controller port rather than the provided lua scripts to get ISS tracking data, you MUST send a "sync" pulse byte of $FF (11111111) before sending the first byte of ISS tracking data.  It is recommended that you send 2-4 sync pulse bytes before sending ISS tracking data.

All bytes MUST be sent over the D0 line of the controller 1 port to be valid.

The following is the protocol for the 10 data bytes (does not include the sync byte[s]) that are sent to the NES console over controller port 1.

```
Bit 76543210  First Byte ($0500)
    ||||++++- Day Ones Digit
    ||++----- Day Tens Digit
    ++------- Hour Tens Digit

Bit 76543210  Second Byte ($0501)
    ||||++++- Year Hundreds Digit
    ++++----- Year Thousands Digit

Bit 76543210  Third Byte ($0502)
    ||||++++- Year Ones Digit
    ++++----- Year Tens Digit

Bit 76543210  Fourth Byte ($0503)
    ||||++++- Month Offset Minus 1
    ++++----- Hour Ones Digit

Bit 76543210  Fifth Byte ($0504)
    ||||++++- Latitude Ones Digit
    |+++----- Latitude Tens Digit
    +-------- Longitude Hundreds Digit

Bit 76543210  Sixth Byte ($0505)
    ||||++++- Latitude Hundredths Place
    ++++----- Latitude Tenths Place

Bit 76543210  Seventh Byte ($0506)
    ||||++++- Longitude Ones Digit
    ++++----- Longitude Tens Digit

Bit 76543210  Eighth Byte ($0507)
    ||||++++- Longitude Hundredths Place
    ++++----- Longitude Tenths Place

Bit 76543210  Ninth Byte ($0508)
    ||||++++- Second Ones Digit
    |+++----- Second Tens Digit
    +-------- Latitude Hemisphere (0=North/1=South)

Bit 76543210  Tenth Byte ($0509)
    ||||++++- Minute Ones Digit
    |+++----- Minute Tens Digit
    +-------- Longitude Hemisphere (0=East/1=West)
```

------
## **LICENSE**
```
Copyright (C) 2020, Vi Grey
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS \`\`AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
```
