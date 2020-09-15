-- Copyright (C) 2020, Vi Grey
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
-- OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
-- SUCH DAMAGE.

local socket = require 'socket.core'

local HOST = "vigrey.com"
local PORT = 56502
local partial = ""
local second = 0
local tcpCheckLastTimestamp = 0

-- TCP request to HOST:PORT for ISS Data
function getISSData()
	local tcp = assert(socket.tcp())
	tcp:settimeout(5)
	tcp:connect(HOST, PORT)
	local s, status, partial = tcp:receive()
	tcp:close()
	return partial
end

-- Write all 0s to the 10 input memory bytes and then wait 5 seconds
function writeBlankFrame()
	for i = 10,1,-1
	do
		memory.writebyte(1280+i-1, 0)
	end
	socket.sleep(5)
  tcpCheckLastTimestamp = 0
  second = 0
end

-- Write minute worth of ISS tracking data to input memory bytes
function writeSecondData(partial)
	local timestamp = os.time(os.date("!*t"))
	local timestampLast = os.time(os.date("!*t"))
	for i = 10,1,-1
	do
		memory.writebyte(1280+i-1, string.byte(partial, (second-1)*10+i))
	end
	while timestamp == timestampLast do
		timestamp = os.time(os.date("!*t"))
		socket.sleep(0.1)
	end
	timestampLast = timestamp
end

-- Run at beginning of frame
function handleFrame()
	memory.writebyte(0, 1)
  second = second + 1
	local timestampNow = os.time(os.date("!*t"))
  if timestampNow - tcpCheckLastTimestamp > 59 then
    tcpCheckLastTimestamp = timestampNow
		partial = getISSData()
    second = 1
  end
	if string.len(partial) > 600 then
		writeSecondData(partial)
	else
		writeBlankFrame()
	end
end

-- Per frame data
while true do
	handleFrame()
	emu.frameadvance()
end
