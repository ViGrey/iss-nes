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

DecompressAddr:
  lda PPU_STATUS
  ldy #$00
  lda (addr), Y
  sta PPU_ADDR
  sta ppuAddr
  jsr IncAddr
  lda (addr), Y
  sta PPU_ADDR
  sta (ppuAddr + 1)
  jsr IncAddr
DecompressAddrGetRowByteLoop:
  jsr CmpAddrAddrEnd
  bne DecompressAddrDone
    ; addr not addrEnd
    lda (addr), Y
    sta tmp
    jsr IncAddr
    lda tmp
    cmp #$01
    beq DecompressAddrGetRowByteLoopIs01
      cmp #$02
      beq DecompressAddr
        sta PPU_DATA
        jmp DecompressAddrGetRowByteLoop
DecompressAddrGetRowByteLoopIs01:
  lda PPU_STATUS
  jsr IncPPUAddrOneLineDecompress
  lda ppuAddr
  sta PPU_ADDR
  lda (ppuAddr + 1)
  sta PPU_ADDR
  jmp DecompressAddrGetRowByteLoop
DecompressAddrDone:
  rts

IncPPUAddrOneLineDecompress:
  lda (ppuAddr + 1)
  clc
  adc #$20
  sta (ppuAddr + 1)
  lda ppuAddr
  adc #$00
  sta ppuAddr
  rts

CmpAddrAddrEnd:
  lda (addr + 1)
  cmp (addrEnd + 1)
  bcc CmpAddrAddrEndLTUpper
    bne CmpAddrAddrEndPositive:
      lda addr
      cmp addrEnd
      bcs CmpAddrAddrEndPositive
CmpAddrAddrEndLTUpper:
    lda #$00
    rts
CmpAddrAddrEndPositive:
  lda #$01
  rts 

IncAddr:
  lda addr
  clc
  adc #$01
  sta addr
  lda (addr + 1)
  adc #$00
  sta (addr + 1)
  rts
