;Plays a 1-Bit, 11kHz, Mono WAV-File over a connected earphone...
; (C) 1996 by Andreas Ess
;If you use the code, please give me an appropriate credit.
;Send a postcard saying thank you to:
; Andreas Ess
; Tufers 156
; A-6811 Goefis
; Austria/Europe
;
; Originally ZX Ported, now..over to the z88!
;
; djm 5/2/2000


        MODULE  wavplay


        org     62850

;
; Entry: a=sample number


.playsample
        add     a,a
        ld      l,a
        ld      h,0
        ld      de,table
        add     hl,de
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ex      de,hl
;..flow into playwav

.PlayWAV
        di                    ;greylib by robert taylor can't be used :(
        ld      a,($4B0)
        and     @10111111
        out     ($B0),a
        ex      af,af;        ;keep status safe in af'
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      b,128           ;b is used as a mask
.SoundLoop
        ld      c,19

.DLoop
        dec     c
        jr      nz,DLoop
        nop
        nop
        rrc     b
        jr      nc,Play
        inc     hl               ;next byte
        dec     de
        ld      a,d
        or      e
        jr      z,DonePlay
.Play
        ld      a,(hl)          ;get bit
        and     b
        jr      z,Play1
        ex      af,af'
        or      64
        out     ($B0),a
        xor     64
        ex      af,af'
        jr      SoundLoop
.Play1
        ex      af,af'
        out     ($B0),a
        ex      af,af'
        jr   SoundLoop
.DonePlay
        ex      af,af'
        out     ($B0),a
        ei
        ret

.table
        defw    sound0
        defw    sound1
        defw    sound2
        defw    sound3
        defw    sound4
        defw    sound5
        defw    sound6
        defw    sound7
        defw    sound8
        defw    sound9

.sound0
.sound1
.sound2 
;Let's go!
 defw 1238
 defb $7F,$FF,$FF,$FF,$87,$FF,$FF,$F9,$FF,$FF,$FF,$FF,$FC,$FF,$FF,$C0
 defb $00,$7F,$FE,$00,$FE,$03,$FF,$80,$3E,$00,$FF,$FE,$00,$FE,$03,$FF
 defb $E0,$0F,$E0,$3F,$F8,$00,$FE,$07,$FF,$00,$3F,$81,$FF,$C0,$07,$E0
 defb $3F,$F8,$00,$FC,$0F,$FE,$00,$3F,$03,$FF,$80,$0F,$E0,$3F,$F0,$00
 defb $FE,$0F,$FE,$00,$1F,$C1,$FF,$C0,$03,$F8,$1F,$FC,$00,$7E,$01,$FF
 defb $80,$07,$E0,$3F,$F8,$00,$7E,$07,$FF,$00,$07,$E0,$7F,$F8,$00,$7E
 defb $03,$FF,$80,$07,$E0,$3F,$F8,$00,$7E,$03,$FF,$80,$07,$E0,$3F,$F8
 defb $00,$3F,$01,$FF,$C0,$03,$F8,$1F,$FC,$00,$1F,$81,$FF,$E0,$00,$FC
 defb $0F,$FE,$00,$0F,$C0,$7F,$F0,$00,$FE,$03,$FF,$80,$07,$E0,$3F,$F8
 defb $00,$7F,$03,$FF,$80,$03,$F0,$3F,$F8,$00,$3F,$03,$FF,$80,$07,$E0
 defb $3F,$F8,$00,$FE,$03,$FF,$00,$0F,$C0,$FF,$C0,$03,$F0,$3F,$F8,$01
 defb $FC,$07,$FE,$00,$7F,$03,$FF,$80,$3F,$81,$FF,$80,$1F,$81,$FF,$80
 defb $3F,$81,$FE,$00,$7E,$07,$FC,$03,$F8,$1F,$E0,$1F,$C3,$FC,$00,$F8
 defb $3F,$80,$3E,$0F,$E0,$0F,$C7,$F0,$07,$EF,$F8,$07,$EF,$F0,$1F,$0F
 defb $C0,$F0,$7E,$0F,$83,$FC,$1E,$0F,$F0,$E0,$7F,$C3,$83,$FE,$1C,$3F
 defb $E0,$E0,$FF,$1C,$1F,$E0,$E1,$FE,$38,$3F,$83,$03,$F0,$70,$7E,$0E
 defb $1F,$C3,$C3,$F8,$70,$FE,$1C,$1F,$87,$83,$F0,$E1,$F8,$78,$3F,$1E
 defb $1F,$83,$87,$C3,$F1,$E0,$F8,$FC,$7C,$3E,$0E,$1F,$87,$87,$81,$C3
 defb $E0,$F1,$F0,$F1,$F0,$38,$F8,$3E,$F8,$07,$FC,$01,$FE,$00,$3F,$FE
 defb $00,$7F,$80,$0F,$E1,$C0,$F0,$F0,$30,$7E,$1C,$1F,$8E,$07,$87,$87
 defb $83,$00,$C4,$03,$0F,$83,$83,$C0,$C0,$F8,$78,$38,$0C,$1F,$07,$0F
 defb $81,$C3,$C0,$E0,$F0,$7C,$3C,$0C,$0F,$03,$07,$C0,$C3,$E0,$61,$F8
 defb $00,$00,$00,$03,$00,$00,$00,$03,$00,$06,$00,$00,$00,$00,$00,$78
 defb $18,$0C,$00,$07,$C0,$03,$03,$00,$01,$E0,$00,$00,$0C,$00,$00,$00
 defb $00,$00,$00,$00,$70,$00,$00,$00,$00,$03,$C0,$03,$00,$01,$80,$19
 defb $A4,$73,$00,$00,$1C,$70,$00,$01,$9E,$00,$00,$0E,$3F,$03,$60,$00
 defb $37,$B8,$1E,$61,$03,$01,$FF,$3E,$F9,$E2,$00,$00,$78,$18,$FB,$0F
 defb $FE,$0F,$F7,$FC,$38,$00,$E0,$00,$00,$FF,$80,$7E,$F8,$01,$D0,$9F
 defb $C0,$8F,$07,$C1,$E7,$07,$00,$01,$60,$18,$60,$0F,$C2,$34,$FE,$20
 defb $ED,$E0,$00,$0F,$08,$F1,$C6,$18,$C0,$00,$00,$00,$30,$00,$00,$00
 defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 defb $00,$00,$00,$00,$00,$00,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00
 defb $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E6,$E7,$E7,$1E,$00,$3E
 defb $3C,$47,$78,$FE,$E0,$00,$B8,$7F,$80,$3F,$81,$FE,$01,$FC,$07,$F0
 defb $0F,$E0,$3F,$C0,$FE,$03,$FC,$03,$E0,$3F,$C0,$7C,$03,$F8,$1F,$80
 defb $7F,$83,$F0,$1F,$C0,$78,$0F,$F0,$3E,$03,$F8,$1F,$03,$FC,$0F,$03
 defb $FC,$1F,$83,$FC,$1F,$03,$F8,$1F,$07,$F8,$3E,$0F,$F0,$FC,$3F,$E1
 defb $F8,$3F,$83,$E0,$FF,$0F,$83,$F8,$3F,$07,$E0,$E0,$3F,$83,$81,$FE
 defb $0E,$07,$F8,$F0,$1F,$E3,$80,$7F,$9E,$01,$FE,$78,$07,$E0,$E0,$1F
 defb $E7,$80,$7F,$9E,$03,$FC,$7C,$07,$F0,$70,$1F,$C3,$C0,$3F,$C3,$C0
 defb $7F,$8F,$01,$FF,$9E,$01,$FE,$1C,$03,$FF,$3E,$03,$FE,$3E,$83,$FE
 defb $1F,$83,$FF,$3E,$C1,$FE,$0F,$C1,$FF,$07,$F0,$7F,$83,$F0,$3F,$C1
 defb $FC,$1F,$F0,$7F,$0F,$FC,$1F,$C3,$FF,$07,$E0,$FF,$81,$F8,$1F,$F0
 defb $3F,$07,$FE,$0F,$E0,$FF,$80,$FC,$3F,$F8,$3F,$83,$FF,$03,$F8,$7F
 defb $F0,$3F,$07,$FF,$03,$F0,$3F,$F0,$3F,$03,$FF,$03,$F8,$1F,$F8,$1F
 defb $C0,$FF,$C0,$FE,$07,$FE,$03,$F8,$1F,$F0,$0F,$E0,$FF,$E0,$7F,$01
 defb $FF,$81,$FC,$07,$FE,$07,$F8,$07,$FC,$07,$F0,$0F,$F8,$0F,$E0,$3F
 defb $F8,$1F,$E0,$7F,$F0,$1F,$C0,$3F,$F0,$3F,$C0,$3F,$F0,$3F,$C0,$3F
 defb $F0,$1F,$E0,$1F,$F8,$1F,$E0,$0F,$F8,$0F,$F0,$0F,$FC,$07,$F8,$07
 defb $FE,$01,$FC,$03,$FF,$00,$FE,$00,$FF,$C0,$3F,$C0,$7F,$E0,$1F,$E0
 defb $1F,$F8,$07,$F8,$07,$FF,$00,$FE,$01,$FF,$C0,$3F,$80,$3F,$F8,$1F
 defb $E0,$0F,$FE,$01,$FC,$03,$FF,$80,$3F,$80,$7F,$F0,$0F,$F0,$07,$FE
 defb $00,$FC,$01,$FF,$C0,$1F,$C0,$1F,$FC,$03,$FC,$03,$FF,$80,$3F,$80
 defb $3F,$F8,$03,$F8,$03,$FF,$80,$1F,$C0,$3F,$FC,$01,$FC,$03,$FF,$C0
 defb $0F,$C0,$1F,$FE,$00,$7E,$00,$FF,$F0,$03,$F8,$07,$FF,$80,$1F,$C0
 defb $1F,$FE,$00,$FF,$00,$FF,$F0,$03,$FC,$03,$FF,$C0,$0F,$F0,$07,$FF
 defb $00,$3F,$80,$1F,$FE,$00,$7F,$00,$7F,$FC,$00,$FE,$00,$FF,$F8,$01
 defb $FE,$01,$FF,$F0,$03,$FC,$01,$FF,$F0,$07,$F8,$03,$FF,$F0,$07,$FC
 defb $03,$FF,$E0,$07,$FC,$03,$FF,$F0,$03,$F8,$01,$FF,$F0,$03,$FC,$01
 defb $FF,$F8,$03,$FE,$00,$FF,$FC,$00,$FE,$00,$FF,$FC,$00,$FF,$00,$7F
 defb $FF,$00,$3F,$C0,$3F,$FF,$00,$1F,$E0,$0F,$FF,$C0,$0F,$F8,$07,$FF
 defb $FC,$01,$FE,$01,$FF,$FF,$00,$7F,$C0,$1F,$FF,$E0,$0F,$F8,$07,$FF
 defb $FC,$01,$FF,$00,$7F,$FF,$C0,$3F,$E0,$1F,$FF,$F8,$07,$FC,$01,$FF
 defb $FF,$00,$FF,$80,$7F,$BF,$F0,$0F,$F0,$07,$FF,$FF,$01,$FE,$00,$7C
 defb $FF,$C0,$3F,$C0,$3F,$CF,$FC,$03,$FC,$03,$F8,$FF,$80,$3F,$C0,$7E
 defb $0F,$F8,$01,$FE,$07,$C0,$FF,$C0,$07,$F0,$3F,$81,$FE,$00,$1F,$E0
 defb $1E,$0F,$F8,$01,$FE,$0F,$F0,$0F,$FC,$00,$7F,$80,$FF,$C0,$0F,$F0
 defb $3F,$00,$FC,$03,$F0,$7F,$C0,$30,$07,$FF,$80,$07,$F0,$3F,$C0,$3F
 defb $E0,$3F,$80,$1F,$F8,$3C,$00,$07,$F8,$0F,$FF,$80,$1F,$E0,$3F,$FF
 defb $00,$7F,$F0,$1F,$F0,$01,$E0,$FE,$0F,$F0,$00,$3F,$E0,$3F,$E0,$07
 defb $FF,$00,$3F,$E0,$0F,$F0,$1F,$E0,$1F,$00,$00,$3F,$80,$F8,$00,$01
 defb $FC,$06,$70,$03,$F8,$07,$C0,$03,$C0,$3F,$E0,$00,$0E,$00,$FF,$C0
 defb $00,$F0,$03,$BC,$01,$E0,$1E,$03,$C0,$0F,$00,$00,$70,$07,$C0,$00
 defb $C0,$03,$D8,$03,$80,$00,$00,$3E,$00,$06,$00,$00,$00,$00,$00,$00
 defb $37,$80,$00,$00,$00,$00

.sound3
.sound4 ;Oh no!
 defw 700

 defb $07,$3B,$B2,$62,$6C,$79,$C1,$8E,$39,$E3,$F9,$E1,$F8,$F3,$C7,$8E
 defb $3C,$F1,$E3,$9C,$1C,$79,$87,$8E,$71,$E1,$EE,$3C,$7D,$C7,$9F,$78
 defb $F1,$E7,$0E,$1E,$E0,$E3,$CE,$1E,$1D,$C7,$85,$D8,$F1,$3B,$9F,$27
 defb $31,$62,$6F,$1E,$6E,$C1,$E0,$FC,$7C,$4F,$C7,$C5,$F8,$F8,$5F,$C7
 defb $81,$F8,$F1,$BD,$83,$87,$FC,$78,$7F,$C7,$87,$FC,$3C,$7F,$83,$C7
 defb $FC,$3E,$3F,$C3,$E1,$F6,$17,$0F,$70,$78,$3D,$83,$81,$EE,$2E,$07
 defb $70,$70,$1D,$C1,$C0,$F7,$07,$03,$DC,$1C,$0F,$70,$F8,$1D,$E0,$E0
 defb $3B,$81,$C0,$77,$03,$C0,$EE,$07,$81,$FE,$0F,$81,$DC,$0F,$03,$FC
 defb $07,$03,$FC,$07,$03,$FC,$07,$03,$FE,$07,$81,$FE,$07,$81,$FF,$03
 defb $E0,$7F,$81,$F0,$7F,$81,$FC,$1F,$C0,$FE,$0F,$E0,$3E,$07,$F0,$1F
 defb $03,$FC,$0F,$81,$FE,$07,$C0,$FF,$00,$FC,$47,$E0,$1F,$E3,$F0,$07
 defb $F1,$F8,$03,$F9,$FC,$01,$FD,$7E,$00,$FE,$7F,$00,$7F,$BF,$80,$7F
 defb $FF,$C0,$3F,$FF,$C0,$3F,$FF,$C0,$3F,$FF,$C0,$0F,$FF,$C0,$0F,$FF
 defb $80,$0F,$FF,$00,$1F,$F8,$00,$FF,$E0,$03,$FF,$80,$1F,$FC,$00,$7F
 defb $E0,$03,$FE,$00,$3F,$F0,$03,$FF,$00,$3F,$F8,$0B,$FE,$06,$97,$C0
 defb $C3,$F0,$38,$7E,$18,$FF,$03,$FC,$1F,$0F,$F8,$5F,$87,$F0,$7F,$0F
 defb $F8,$7F,$0F,$F0,$7F,$03,$F8,$6F,$03,$F8,$3F,$C1,$FC,$1F,$C1,$FC
 defb $1F,$E0,$BE,$07,$E0,$DE,$07,$F0,$7F,$87,$F0,$3F,$83,$F8,$3F,$C1
 defb $FC,$1F,$C1,$FC,$0F,$E0,$FF,$0F,$E0,$7F,$07,$F0,$7F,$83,$F0,$1F
 defb $81,$F8,$0F,$C0,$FE,$07,$E0,$3F,$01,$F0,$0F,$C2,$7C,$13,$E1,$9F
 defb $84,$7C,$71,$F1,$8F,$86,$3E,$38,$7C,$63,$C1,$8F,$8E,$7E,$38,$F8
 defb $F3,$E3,$8F,$C7,$9F,$1F,$1F,$1E,$7F,$1E,$3E,$1E,$1F,$1E,$0F,$87
 defb $8F,$E3,$C3,$F0,$F0,$FC,$78,$7E,$1C,$1F,$8E,$1F,$C7,$1F,$87,$8F
 defb $C3,$1F,$C3,$1F,$82,$1F,$18,$7E,$31,$F8,$63,$E1,$8F,$C3,$1F,$06
 defb $7E,$18,$FC,$31,$F0,$71,$F0,$E1,$F0,$E3,$F0,$F1,$F8,$78,$FC,$3C
 defb $3F,$0F,$0F,$E1,$E1,$FC,$3C,$3F,$83,$C3,$F8,$FC,$7F,$0F,$87,$F0
 defb $F0,$7F,$0F,$87,$F0,$F8,$FF,$87,$87,$F8,$7C,$3F,$C3,$C1,$FE,$0E
 defb $07,$F8,$38,$1F,$C0,$E0,$7F,$03,$81,$FE,$0E,$07,$F8,$3C,$0F,$F0
 defb $78,$3F,$C1,$E0,$7F,$81,$C0,$FF,$03,$81,$FE,$07,$03,$FC,$0E,$07
 defb $F8,$1E,$03,$F8,$1C,$07,$F0,$3C,$07,$F0,$38,$0F,$F0,$3C,$0F,$F0
 defb $3C,$0F,$E0,$3C,$0F,$E0,$1C,$0F,$F0,$1E,$07,$F8,$0E,$07,$FC,$0F
 defb $03,$FE,$07,$80,$FF,$01,$E0,$3F,$C0,$FC,$1F,$E0,$1E,$07,$FC,$07
 defb $C0,$FF,$80,$F0,$3F,$F0,$3E,$01,$FE,$03,$E0,$3F,$E0,$3E,$03,$FF
 defb $01,$F0,$3F,$F0,$1F,$00,$FF,$80,$7E,$07,$FF,$01,$F0,$1F,$FC,$0F
 defb $E0,$3F,$F0,$1F,$80,$FF,$E0,$3F,$01,$FF,$80,$FE,$03,$FF,$80,$FC
 defb $07,$FF,$80,$FC,$03,$FF,$80,$FC,$07,$FF,$C0,$7C,$03,$FD,$E0,$1E
 defb $03,$FE,$70,$1F,$00,$FE,$3C,$03,$E0,$FF,$1F,$81,$FC,$1F,$8F,$E0
 defb $1F,$0F,$F3,$F8,$04,$71,$FF,$FE,$08,$03,$FF,$FF,$8F,$00,$19,$FF
 defb $EE,$7C,$00,$FF,$FE,$1F,$00,$07,$FF,$7F,$C0,$00,$3F,$C8,$7F,$E0
 defb $00,$7F,$FF,$F8,$00,$00,$7F,$FF,$C0,$00,$03,$FF,$F0,$C0,$00,$0F
 defb $E7,$F8,$40,$00,$1F,$FF,$80,$00,$01,$FF,$F8,$00,$00,$1F,$FF,$00
 defb $00,$03,$FF,$E4,$00,$00,$1F,$FF,$80,$00,$03,$FF,$F0,$00,$00,$9F
 defb $F0,$80,$00,$07,$FE,$80,$00,$05,$04,$C0,$28,$00,$80,$20,$20,$00
 defb $04,$22,$A3,$00,$04,$C4,$00,$80,$40,$00,$00,$80

.sound5 ;splat

.sound6
.sound7
.sound8
.sound9

