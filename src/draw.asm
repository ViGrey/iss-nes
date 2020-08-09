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

ResetScroll:
  lda #$00
  sta PPU_SCROLL
  sta PPU_SCROLL
  jsr EnableNMI
  rts

Draw:
  lda #%00011110
  sta PPU_MASK
  rts

DisableNMI:
  lda #$00
  sta PPU_CTRL
  rts

EnableNMI:
  lda #%10000000
  ora patterns
  sta PPU_CTRL
  rts

Blank:
  lda #%00000110
  sta PPU_MASK
  jsr DisableNMI
  rts

ClearPPURAM:
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldy #$10
  ldx #$00
  txa
ClearPPURAMLoop:
  sta PPU_DATA
  dex
  bne ClearPPURAMLoop
    ldx #$00
    dey
    bne ClearPPURAMLoop
      rts

DrawPreviousFrame:
  ldy #$00
DrawPreviousFrameLoop:
  lda PPU_STATUS
  lda (drawBuffer), Y
  iny
  cmp #$8F
  beq DrawPreviousFrameDone
    cmp #$8E
    beq DrawPreviousFrameLoop
      sta PPU_ADDR
      lda (drawBuffer), Y
      iny
      sta PPU_ADDR
DrawPreviousFrameLoopContentLoop:
  lda (drawBuffer), Y
  iny
  cmp #$8E
  beq DrawPreviousFrameLoop
    ; Not #$8E
    cmp #$8F
    beq DrawPreviousFrameDone
      ; Not #$8F
      sta PPU_DATA
      jmp DrawPreviousFrameLoopContentLoop
DrawPreviousFrameDone:
  jsr InitializeDrawBuffer
  rts

InitializeDrawBuffer:
  ldy #$00
  sty drawBufferOffset
  lda #$8F
  sta (drawBuffer), Y
  rts

EndDrawBuffer:
  ldy drawBufferOffset
  lda #$8F
  sta (drawBuffer), Y
  iny
  sty drawBufferOffset
  rts

SetMapScreenPalettes:
  lda PPU_STATUS
  lda #$3F
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  lda #<(Palettes)
  sta addr
  lda #>(Palettes)
  sta (addr + 1)
  ldy #$00
SetMapScreenPalettesLoop:
  lda (addr), Y
  sta PPU_DATA
  iny
  cpy #$20
  bne SetMapScreenPalettesLoop
    rts

DrawMapScreen:
  lda PPU_STATUS
  lda #$20
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  lda #<(West)
  sta addr
  lda #>(West)
  sta (addr + 1)
  ldy #$00
  ldx #$04
DrawMapScreenWest:
  lda (addr), Y
  sta PPU_DATA
  iny
  bne DrawMapScreenWest
    inc (addr + 1)
    dex
    bne DrawMapScreenWest
      lda PPU_STATUS
      lda #$24
      sta PPU_ADDR
      lda #$00
      sta PPU_ADDR
      lda #<(East)
      sta addr
      lda #>(East)
      sta (addr + 1)
      ldx #$04
DrawMapScreenEast:
  lda (addr), Y
  sta PPU_DATA
  iny
  bne DrawMapScreenEast
    inc (addr + 1)
    dex
    bne DrawMapScreenEast
      rts

TopBarText:
  .byte $20, $42
  .byte $EE, $EB, $FB, $EF, $E0, $01
  .byte $FB, $F2, $F5, $EF, $E0, $04, $04, $04, $E0, $04, $04, $E0, $04, $04, $04, $FC, $FB, $ED, $01
  .byte $F4, $EB, $FB, $E0, $04, $04, $04, $04, $DF, $01
  .byte $F4, $F7, $F6, $E0, $04, $04, $04, $04, $DF
TopBarTextDone:

DrawSpriteZero:
  lda #$27
  sta $200
  lda #$01
  sta $201
  lda #$01
  sta #$202
  lda #00
  sta $203
  rts

DrawISSSprites:
  lda #$6F
  sta $204
  lda #$02
  sta $205
  lda #$00
  sta $206
  lda #$78
  sta $207
  lda #$6F
  sta $208
  lda #$03
  sta $209
  lda #$00
  sta $20A
  lda #$80
  sta $20B
  lda #$6F
  sta $20C
  lda #$04
  sta $20D
  lda #$00
  sta $20E
  lda #$88
  sta $20F
  lda #$77
  sta $210
  lda #$12
  sta $211
  lda #$00
  sta $212
  lda #$78
  sta $213
  lda #$77
  sta $214
  lda #$13
  sta $215
  lda #$00
  sta $216
  lda #$80
  sta $217
  lda #$77
  sta $218
  lda #$14
  sta $219
  lda #$00
  sta $21A
  lda #$88
  sta $21B
  rts

DrawTopBar:
  lda #<(TopBarTextDone)
  sta addrEnd
  lda #>(TopBarTextDone)
  sta (addrEnd + 1)
  lda #<(TopBarText)
  sta addr
  lda #>(TopBarText)
  sta (addr + 1)
  jsr DecompressAddr
  rts
