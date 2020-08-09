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

RESET:
  sei
  cld
  ldx #$40
  stx APU_FRAME_COUNTER
  ldx #$FF
  txs
  inx
  lda #%00000110
  sta PPU_MASK
  lda #$00
  sta PPU_CTRL
  stx $4010
  ldy #$00

InitialVWait:
  lda PPU_STATUS
  bpl InitialVWait
InitialVWait2:
  lda PPU_STATUS
  bpl InitialVWait2

InitializeRAM:
  ldx #$00
InitializeRAMLoop:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x
  inx
  bne InitializeRAMLoop
    lda #%00001000
    sta patterns
    jsr ClearPPURAM
    jsr SetMapScreenPalettes
    jsr DrawMapScreen
    jsr DrawSpriteZero
    jsr DrawISSSprites
    jsr DrawTopBar
    jsr InitializeDrawBuffer
    jsr SetDefaultDate
    jsr ResetScroll

Forever:
  jmp Forever

NMI:
  lda #$00
  sta PPU_OAM_ADDR
  lda #$02
  sta OAM_DMA
  lda PPU_STATUS
  jsr Draw
  jsr DrawPreviousFrame
  jsr ResetScroll
Sprite0ClearWait:
  bit PPU_STATUS
  bvs Sprite0ClearWait
Sprite0HitWait:
  bit PPU_STATUS
  bvc Sprite0HitWait
    lda #%10000000
    ora nametable
    ora patterns
    sta PPU_CTRL
    lda xscroll
    sta PPU_SCROLL

NMIDone:
  jsr Update
  rti

Update:
  lda lua
  beq UpdateNotLua
    jsr PollControllerFinished
    jmp UpdateLuaContinue
UpdateNotLua:
  jsr PollControllerSync
UpdateLuaContinue:
  ldy drawBufferOffset
  lda #$8F
  sta (drawBuffer), Y
  iny
  sta drawBufferOffset
  rts

SetPalette:
  lda #<(Palettes)
  sta addr
  lda #>(Palettes)
  sta (addr + 1)
  lda PPU_STATUS
  lda #$3F
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldy #$00
SetPaletteLoop:
  lda (addr), Y
  sta PPU_DATA
  iny
  cpy #$20
  bne SetPaletteLoop
    rts

.include "decompress.asm"
.include "draw.asm"
.include "include.asm"
.include "controller.asm"
