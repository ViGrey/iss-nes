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

Palettes:
  .byte $0F, $11, $2A, $30
  .byte $0F, $11, $30, $30
  .byte $0F, $0F, $0F, $30
  .byte $0F, $0F, $0F, $30
  .byte $0F, $2D, $2C, $30
  .byte $0F, $0F, $0F, $0F
  .byte $0F, $0F, $0F, $0F
  .byte $0F, $0F, $0F, $0F

West:
  .incbin "graphics/west.nam"
  .incbin "graphics/west.atr"
East:
  .incbin "graphics/east.nam"
  .incbin "graphics/east.atr"

Months:
  .byte $F3, $EB, $F6
  .byte $F0, $EF, $EC
  .byte $F5, $EB, $F9
  .byte $EB, $F8, $F9
  .byte $F5, $EB, $FF
  .byte $F3, $FC, $F6
  .byte $F3, $FC, $F4
  .byte $EB, $FC, $F1
  .byte $FA, $EF, $F8
  .byte $F7, $ED, $FB
  .byte $F6, $F7, $FD
  .byte $EE, $EF, $ED

NorthSouth:
  .byte $F6, $FA

EastWest:
  .byte $EF, $FE

Latitudes:
  .byte $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $41, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $50, $51, $52, $53, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d, $5e, $5f, $60, $61, $62, $63, $64, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $89, $8a, $8b, $8c, $8d, $8e, $8f, $90, $91, $92, $93, $94, $95, $96, $97, $98, $9a, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ac, $ad, $ae, $af, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bd, $be, $bf, $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $cf, $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $db, $dc, $dd, $de, $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7

Longitudes:
  .byte $00, $01, $03, $04, $06, $07, $09, $0a, $0b, $0d, $0e, $10, $11, $12, $14, $15, $17, $18, $1a, $1b, $1c, $1e, $1f, $21, $22, $24, $25, $26, $28, $29, $2b, $2c, $2e, $2f, $30, $32, $33, $35, $36, $37, $39, $3a, $3c, $3d, $3f, $40, $41, $43, $44, $46, $47, $49, $4a, $4b, $4d, $4e, $50, $51, $52, $54, $55, $57, $58, $5a, $5b, $5c, $5e, $5f, $61, $62, $64, $65, $66, $68, $69, $6b, $6c, $6e, $6f, $70, $72, $73, $75, $76, $77, $79, $7a, $7c, $7d, $7f, $80, $81, $83, $84, $86, $87, $89, $8a, $8b, $8d, $8e, $90, $91, $92, $94, $95, $97, $98, $9a, $9b, $9c, $9e, $9f, $a1, $a2, $a4, $a5, $a6, $a8, $a9, $ab, $ac, $ae, $af, $b0, $b2, $b3, $b5, $b6, $b7, $b9, $ba, $bc, $bd, $bf, $c0, $c1, $c3, $c4, $c6, $c7, $c9, $ca, $cb, $cd, $ce, $d0, $d1, $d2, $d4, $d5, $d7, $d8, $da, $db, $dc, $de, $df, $e1, $e2, $e4, $e5, $e6, $e8, $e9, $eb, $ec, $ee, $ef, $f0, $f2, $f3, $f5, $f6, $f7, $f9, $fa, $fc, $fd, $ff, $ff
