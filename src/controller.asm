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

; Controller1 to Top Bar Data Protocol
;
; 0
; HHDD|dddd
; ---------
; |||| ||||
; |||| ++++- Day Ones Digit
; ||++------ Day Tens Digit
; ++-------- Hour Tens Digit
; 
; 1
; YYYY|yyyy
; ---------
; |||| ||||
; |||| ++++- Year Hundreds Digit
; ++++------ Year Thousands Digit
;
; 2
; YYYY|yyyy
; ---------
; |||| ||||
; |||| ++++- Year Ones Digit
; ++++------ Year Tens Digit
;
; 3
; hhhh|MMMM
; ---------
; |||| ||||
; |||| ++++- Month Offset Minus 1
; ++++------ Hour Ones Digit
;
; 4
; NTTT|tttt
; ---------
; |||| ||||
; |||| ++++- Latitude Ones Place
; |+++------ Latitude Tens Place
; +--------- Longitude Hundreds Digit
;
; 5
; TTTT|tttt
; ---------
; |||| ||||
; |||| ++++- Latitude Hundredths Place
; ++++------ Latitude Tenths Place
;
; 6
; NNNN|nnnn
; ---------
; |||| ||||
; |||| ++++- Longitude Ones Place
; ++++------ Longitude Tens Place
;
; 7
; NNNN|nnnn
; ---------
; |||| ||||
; |||| ++++- Longitude Hundredths Place
; ++++------ Longitude Tenths Place

; 8
; TSSS|ssss
; ---------
; |||| ||||
; |||| ++++- Second Ones Digit
; |+++------ Second Tens Digit
; +--------- Latitude Hemisphere
;
; 9
; NMMM|mmmm
; ---------
; |||| ||||
; |||| ++++- Minute Ones Digit
; |+++------ Minute Tens Digit
; +--------- Longitude Hemisphere

SetDefaultDate:
  lda #$01
  sta controller1
  lda #$19
  sta (controller1 + 1)
  lda #$70
  sta (controller1 + 2)
  rts

PollControllerSync:
  lda #$00
  sta controllervalid
  jsr SetDefaultDate
  ldx #$06
  ldy #$08
PollControllerSyncLatch:
  lda #$01
  sta CONTROLLER1
  lda #$00
  sta CONTROLLER1
PollControllerSyncLoop:
  lda CONTROLLER1
  lsr A
  ror controllersync
  dey
  bne PollControllerSyncLoop
    lda controllersync
    cmp #$FF
    beq PollControllerSyncLoopIsFF
      cpx #$06
      beq PollControllerSyncContinue
        lda #$01
        sta controllervalid
        jmp PollControllerSyncContinue
PollControllerSyncLoopIsFF:
  ldy #$08
  dex
  bne PollControllerSyncLatch
PollControllerSyncContinue:
  lda controllervalid
  beq PollControllerSyncDone
    jsr PollController
PollControllerSyncDone:
  jsr PollControllerFinished
  rts

PollController:
  ldx #$00
  ldy #$08
PollControllerLatch:
  lda #$01
  sta CONTROLLER1
  lda #$00
  sta CONTROLLER1
PollController1Loop:
  lda CONTROLLER1
  lsr A
  rol controller1, x
  dey
  bne PollController1Loop
    ldy #$08
    inx
    cpx #$0A
    bne PollControllerLatch
      rts
PollControllerFinished:
  jsr GetDate
  jsr GetTime
  jsr GetLatitude
  jsr GetLongitude
  jsr DrawDate
  jsr DrawTime
  jsr DrawLatitude
  jsr DrawLongitude
  jsr LatitudeToTmp
  jsr LatitudeToYPosition
  jsr LongitudeToTmp
  jsr LongitudeToXScroll
  rts

GetHour:
  lda controller1
  and #%11000000
  asl
  rol
  rol
  sta hour
  lda (controller1 + 3)
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  sta (hour + 1)
  rts

GetMinute:
  lda (controller1 + 9)
  and #%01110000
  lsr
  lsr
  lsr
  lsr
  sta minute
  lda (controller1 + 9)
  and #%00001111
  sta (minute + 1)
  rts

GetSecond:
  lda (controller1 + 8)
  and #%01110000
  lsr
  lsr
  lsr
  lsr
  sta second
  lda (controller1 + 8)
  and #%00001111
  sta (second + 1)
  rts

GetDay:
  lda controller1
  and #%00110000
  lsr
  lsr
  lsr
  lsr
  sta day
  lda controller1
  and #%00001111
  sta (day + 1)
  rts

GetYear:
  lda (controller1 + 1)
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  sta year
  lda (controller1 + 1)
  and #%00001111
  sta (year + 1)
  lda (controller1 + 2)
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  sta (year + 2)
  lda (controller1 + 2)
  and #%00001111
  sta (year + 3)
  rts

GetMonth:
  lda (controller1 + 3)
  and #%00001111
  sta month
  asl
  clc
  adc month
  sta month
  rts

GetDate:
  jsr GetDay
  jsr GetYear
  jsr GetMonth
  rts

GetTime:
  jsr GetHour
  jsr GetMinute
  jsr GetSecond

GetLatitude:
  lda (controller1 + 4)
  and #%01110000
  lsr
  lsr
  lsr
  lsr
  sta lat
  lda (controller1 + 4)
  and #%00001111
  sta (lat + 1)
  lda (controller1 + 5)
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  sta (lat + 2)
  lda (controller1 + 5)
  and #%00001111
  sta (lat + 3)
  lda (controller1 + 8)
  and #%10000000
  asl
  rol
  sta northsouth
  rts


GetLongitude:
  lda (controller1 + 4)
  and #%10000000
  asl
  rol
  sta lon
  lda (controller1 + 6)
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  sta (lon + 1)
  lda (controller1 + 6)
  and #%00001111
  sta (lon + 2)
  lda (controller1 + 7)
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  sta (lon + 3)
  lda (controller1 + 7)
  and #%00001111
  sta (lon + 4)
  lda (controller1 + 9)
  and #%10000000
  asl
  rol
  sta eastwest
  rts


DrawDate:
  ldy drawBufferOffset
  lda #$20
  sta (drawBuffer), Y
  iny
  lda #$48
  sta (drawBuffer), Y
  iny
  ldx month
  lda Months, X
  sta (drawBuffer), Y
  iny
  inx
  lda Months, X
  sta (drawBuffer), Y
  iny
  inx
  lda Months, X
  sta (drawBuffer), Y
  iny
  lda #$04
  sta (drawBuffer), Y
  iny
  lda day
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (day + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$04
  sta (drawBuffer), Y
  iny
  lda year
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (year + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (year + 2)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (year + 3)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$8E
  sta (drawBuffer), Y
  iny
  sty drawBufferOffset
  rts

DrawTime:
  ldy drawBufferOffset
  lda #$20
  sta (drawBuffer), Y
  iny
  lda #$68
  sta (drawBuffer), Y
  iny
  lda hour
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (hour + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$E0
  sta (drawBuffer), Y
  iny
  lda minute
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (minute + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$E0
  sta (drawBuffer), Y
  iny
  lda second
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (second + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$8E
  sta (drawBuffer), Y
  iny
  sty drawBufferOffset
  rts

DrawLatitude:
  ldy drawBufferOffset
  lda #$20
  sta (drawBuffer), Y
  iny
  lda #$88
  sta (drawBuffer), Y
  iny
  lda lat
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (lat + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$DF
  sta (drawBuffer), Y
  iny
  lda (lat + 2)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (lat + 3)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$04
  sta (drawBuffer), Y
  iny
  ldx northsouth
  lda NorthSouth, X
  sta (drawBuffer), Y
  iny
  lda #$8E
  sta (drawBuffer), Y
  iny
  sty drawBufferOffset
  rts

DrawLongitude:
  ldy drawBufferOffset
  lda #$20
  sta (drawBuffer), Y
  iny
  lda #$A7
  sta (drawBuffer), Y
  iny
  lda lon
  beq DrawLongitudeNotHundred
    clc
    adc #$E1
    jmp DrawLongitudeContinue
DrawLongitudeNotHundred:
  lda #$04
DrawLongitudeContinue:
  sta (drawBuffer), Y
  iny
  lda (lon + 1)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (lon + 2)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$DF
  sta (drawBuffer), Y
  iny
  lda (lon + 3)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda (lon + 4)
  clc
  adc #$E1
  sta (drawBuffer), Y
  iny
  lda #$04
  sta (drawBuffer), Y
  iny
  ldx eastwest
  lda EastWest, X
  sta (drawBuffer), Y
  iny
  lda #$8E
  sta (drawBuffer), Y
  iny
  sty drawBufferOffset
  rts

LatitudeToTmp:
  lda #$00
  ldx lat
LatitudeToTmpTensLoop:
  cpx #$00
  beq LatitudeToTmpTensLoopDone
    clc
    adc #$0A
    dex
    jmp LatitudeToTmpTensLoop
LatitudeToTmpTensLoopDone:
  clc
  adc (lat + 1)
  cmp #91
  bcc LatitudeToTmpDone
    lda #$00
LatitudeToTmpDone:
  sta tmp
  rts

LatitudeToYPosition:
  lda northsouth
  bne LatitudeToYPositionSouth
    lda #90
    sec
    sbc tmp
    jmp LatitudeToYPositionContinue
LatitudeToYPositionSouth:
  lda tmp
  clc
  adc #90
LatitudeToYPositionContinue:
  tay
  lda (Latitudes), Y
  sta $204
  sta $208
  sta $20C
  clc
  adc #$08
  sta $210
  sta $214
  sta $218
  rts

LongitudeToTmp:
  lda #$00
  ldx lon
LongitudeToTmpHundredsLoop:
  beq LongitudeToTmpHundredsLoopDone
    clc
    adc #100
LongitudeToTmpHundredsLoopDone:
  ldx (lon + 1)
LongitudeToTmpTensLoop:
  cpx #$00
  beq LongitudeToTmpTensLoopDone
    clc
    adc #$0A
    dex
    jmp LongitudeToTmpTensLoop
LongitudeToTmpTensLoopDone:
  clc
  adc (lon + 2)
  cmp #179
  bcc LongitudeToTmpDone
    lda #179
LongitudeToTmpDone:
  sta tmp
  rts

LongitudeToXScroll:
  lda eastwest
  beq LongitudeToXScrollEast
    lda #$00
    sta nametable
    lda #179
    sec
    sbc tmp
    jmp LongitudeToXScrollContinue
LongitudeToXScrollEast:
  lda #$01
  sta nametable
  lda tmp
LongitudeToXScrollContinue:
  tay
  lda (Longitudes), Y
  sec
  sbc #$80
  sta xscroll
  bcs LongitudeToXScrollDone
    lda nametable
    eor #%00000001
    sta nametable
LongitudeToXScrollDone:
  rts
