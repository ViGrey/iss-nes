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
_**(Source Code Build Instructions are 1 section below)**_

This NES ROM has only been successfully tested on two NES emulators, FCEUX for Windows and Mesen for Linux (This will likely work for Mesen on Windows as well).  **YOU WILL NEED TO RUN AN INCLUDED LUA SCRIPT AND THE ACCOMPANYING SERVER TO MAKE THIS NES ROM WORK PROPERLY ON AN EMULATOR.**

### Running the NES ROM:
In the main directory of this project, you will find a `bin` directory.  Inside of this directory is a file named `iss-nes.nes`, which can be opened up in FCEUX on Windows or Mesen on Linux (and possibly Windows as well).  To make this NES ROM work for real-time tracking of the International Space Station, you will need to run an included lua script and the accompanying server program.

### Running the Accompanying Server:
In the main directory of this project, you will find a `bin` directory.  Inside of this directory are files named `server-linux-386`, `server-linux-amd64`, `server-linux-arm`, `server-linux-arm64`, `server-windows-386.exe`, and `server-windows-amd64.exe`.  Depending on whether you are running Linux or Windows, and what CPU architecture you are using, you will need to run the correct server program.  This server program will open up a **localhost** connection to port **56502** that the included Lua scripts are able to connect to in order to get the ISS real-time tracking location.

### Running an Included Lua Script on an Emulator:
In the main directory of this project, you will find a `lua` directory.  Inside of that directory is a file called `fceux.lua`, which is used for FCEUX on Windows, and a file called `mesen.lua`, which is used for Mesen.  These lua scripts request real-time ISS tracking data (10 bytes of data) from the accompanying server program every frame and displays the information in the NES game while it's running.

------
## **BUILDING THE SOURCE CODE**

### NES ROM Build Dependencies:
- **asm6** (You'll probably have to build asm6 from source.  Make sure the asm6 binary is named **asm** and that the binary is executable and accessible in your PATH. The source code can be found at http://3dscapture.com/NES/asm6.zip)
- **gmake** (make)

### Accompanying Server Build Dependencies:
- **go**

### Build NES ROM on Linux:
From a terminal, go to the the main directory of this project (the directory this README.md file exists in).  You can then build the NES ROM with the following command.

```sh
make
```
The resulting NES ROM will be located at `bin/iss-nes.nes` from the main directory.

### Build NES ROM on Windows:
If you are using Windows, in the command prompt (make sure to have asm6 on your system as `asm.exe`), go to the the `src` directory of this project (the `src` directory this README.md file exists in).  You can then build the NES ROM with the following command.

```
asm iss-nes.asm ..\bin\iss-nes.nes
```
Replace the `asm` command with the path to your `asm.exe` command.

The resulting NES ROM will be located at `bin\iss-nes.nes` from the main directory.

### Build Accompanying Server on Linux:

If you are using Linux, go to the `bin` directory of this project (the `bin` directory in the directory this README.md file exists in).  You can then build the server binary file with the following command.

```
go build ../server/server.go
```

The resulting server binary file will be located at `bin/server` from the main directory.

### Build Accompanying Server on Windows:

If you are using Windows, go to the `bin` directory of this project (the `bin` directory in the directory this README.md file exists in).  You can then build the server binary file with the following command (Assuming you have the `go` command added to your PATH).

```sh
go build ..\server\server.go
```

The resulting server binary file will be located at `bin\server.exe` from the main directory.

### Cleaning Build Environment (Linux Only):
If you used `make` to build the NES ROM, you can run the following command to clean up the build environment.

```sh
make clean
```

------

## **LICENSE**

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
