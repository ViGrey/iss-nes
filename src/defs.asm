; Copyright (C) 2020, Vi Grey
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
;
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
; SUCH DAMAGE.

CONTROLLER1             = $4016
CONTROLLER2             = $4017

BUTTON_A                = 1 << 7
BUTTON_B                = 1 << 6
BUTTON_SELECT           = 1 << 5
BUTTON_START            = 1 << 4
BUTTON_UP               = 1 << 3
BUTTON_DOWN             = 1 << 2
BUTTON_LEFT             = 1 << 1
BUTTON_RIGHT            = 1 << 0

PPU_CTRL                = $2000
PPU_MASK                = $2001
PPU_STATUS              = $2002
PPU_OAM_ADDR            = $2003
PPU_OAM_DATA            = $2004
PPU_SCROLL              = $2005
PPU_ADDR                = $2006
PPU_DATA                = $2007

OAM_DMA                 = $4014
APU_FRAME_COUNTER       = $4017

CALLBACK                = $FFFA
