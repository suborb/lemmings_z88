;
;       Lemmings Music Adapted To The Z88 And it Works!!!
;
;       djm 28/11/99
;
;       Notes: Tune kept at 33724, player code to be relocated
;       To low memory in RAM cos self modifying...dump code in
;       upper half of screen buffer?
;
;       Disables interrupts and locks OZ out!


        MODULE  music

        INCLUDE "interrpt.def"

        org     8377	;33721 (loaded 33721 in z88 memory)
        jp      start

.tune
        BINARY  "assets/tune.bin"

.start
        ld      a,94
        ld      (stor1+1),a
        ld      (stor2+1),a
        ld      a,23
        ld      (stor3+1),a
        srl     a
        ld      (stor4+1),a

.Lc017  xor     a
        in      a,($B2)
        cpl     
        and     127
        jr      nz,Lc017                ; (-8)
        call    oz_di
        ld      (spstor+1),sp
IF SLOWDO
        call    Lc39e
ELSE
        ld      hl,tune+85
ENDIF
        ld      a,(hl)
        inc     hl
        ld      (stor10+1),a
        ld      sp,hl
        pop     hl
        ld      (double1+1),hl
        pop     hl
        ld      (double2+1),hl
        pop     hl
        ld      (double10+1),hl
        ld      sp,(spstor+1)
        xor     a
        ld      (value1+1),a
        ld      (stor11+1),a
        ld      a,($4B0)
        and     63
        ld      (stor12+1),a    ;4b0
        ld      (stor14+1),a    ;4b0
        ld      (stor15+1),a    ;4b0
        ld      (stor16+1),a    ;4b0
        ld      (stor17+1),a    ;4b0
        ld      (blah1+1),a
        ld      (blah2+1),a
        or      64
        ld      (blah3+1),a
        call    Lc350
        call    Lc36a
        call    Lc384
        ld      c,1
        exx     
        ld      bc,257

.Lc064  call    Lc12f
        ld      hl,296

.Lc06a  push    hl
        ld      a,b
        and     a
        jr      nz,Lc0a6                ; (55)
        ld      (stor18+1),a

.Lc072  
.double11
        ld      hl,1

.Lc075  ld      a,(hl)
        or      a
        jp      m,Lc1c6
        ld      (stor19+1),a
.value1
        add     a,0
        call    Lc124
        ld      (stor1+1),a
        ld      d,a
        rra     
        rra     
        rra     
        and     31
        ld      (stor20+1),a
        xor     a
        ld      (stor21+1),a
        inc     a
        ld      (stor4+1),a
        ld      a,(stor16+1)
        xor     64
        ld      (stor16+1),a
        inc     hl

.Lc09f  ld      (double11+1),hl
.stor32
        ld      b,1
        jr      Lc0ab                   ; (5)

.Lc0a6  ld      a,3

.Lc0a8  dec     a
        jr      nz,Lc0a8                ; (-3)

.Lc0ab  dec     d
        jr      nz,Lc0c2                ; (20)
.stor1
        ld      d,94
.stor4
        ld      a,11

.Lc0b2  dec     a
        jr      nz,Lc0b2                ; (-3)
.stor16
        ld      a,0
        out     ($B0),a
.stor20
        ld      a,1

.Lc0bb  dec     a
        jr      nz,Lc0bb                ; (-3)
.stor12
        ld      a,0
        out     ($B0),a

.Lc0c2  ld      a,c
        and     a
        jr      nz,Lc0fc                ; (54)
        ld      (stor22+1),a

.Lc0c9  
.double14
        ld      hl,1

.Lc0cc  ld      a,(hl)
        or      a
        jp      m,Lc18d
        ld      (stor23+1),a
.stor11
        add     a,0
        call    Lc124
        ld      (stor2+1),a
        ld      e,a
        rra     
        rra     
        and     63
        ld      (stor3+1),a
        xor     a
        ld      (stor24+1),a
        inc     a
        ld      (stor25+1),a
        ld      a,(stor17+1)
        or      64
        ld      (stor17+1),a
        inc     hl

.Lc0f5  ld      (double14+1),hl
.stor31
        ld      c,1
        jr      Lc101                   ; (5)

.Lc0fc  ld      a,3

.Lc0fe  dec     a
        jr      nz,Lc0fe                ; (-3)

.Lc101  dec     e
        jr      nz,Lc118                ; (20)
.stor2
        ld      e,94
.stor25
        ld      a,1

.Lc108  dec     a
        jr      nz,Lc108                ; (-3)
.stor17
        ld      a,0
        out     ($B0),a
.stor3
        ld      a,23

.Lc111  dec     a
        jr      nz,Lc111                ; (-3)
.stor14                                 ;4b0
        ld      a,0
        out     ($B0),a

.Lc118  pop     hl
        dec     l
        jp      nz,Lc06a
        dec     h
        jp      p,Lc06a
        jp      Lc064

.Lc124  push    hl
        add     a,$E3   ;227   ; 50147
        ld      l,a
        adc     a,32	;$83   ;195   ;49920
        sub     l
        ld      h,a
        ld      a,(hl)
        pop     hl
        ret     


.Lc12f  dec     c
        dec     b
        exx     
        dec     c
        call    z,Lc273
        push    bc
        call    Lc17d
.stor30
        ld      a,85
        rrca    
        ld      (stor30+1),a
        jr      c,Lc148                 ; (6)
        call    Lc2e9
        call    Lc317

.Lc148  pop     bc
        exx     
.stor21
        ld      a,0
        inc     a
        ld      (stor21+1),a
        push    hl
.stor34
        cp      2
        jr      c,Lc163                 ; (14)
        xor     a
        ld      (stor21+1),a
        ld      hl,stor20+1
        dec     (hl)
        jr      z,Lc162                 ; (3)
        ld      hl,stor4+1

.Lc162  inc     (hl)

.Lc163  
.stor24
        ld      a,0
        inc     a
        ld      (stor24+1),a
.stor33
        cp      4
        jr      c,Lc17b                 ; (14)
        xor     a
        ld      (stor24+1),a
        ld      hl,stor3+1
        dec     (hl)
        jr      z,Lc17a                 ; (3)
        ld      hl,stor25+1

.Lc17a  inc     (hl)

.Lc17b  pop     hl
        ret     


.Lc17d  xor     a
        in      a,($B2)
        cpl
        and     127
        ret     z


.Lc184  
.spstor
        ld      sp,1
        call    oz_ei
        ret     


.Lc18d  inc     hl
        cp      224
        jr      nc,Lc1b3                ; (33)
        push    hl
        and     127
        call    Lc344
        jp      Lc254
        jp      Lc21e
        jp      Lc20e
        jp      Lc0f5
        jp      Lc1fe
        jp      Lc184
        jp      Lc244
        jp      Lc24c
        jp      Lc3b4

.Lc1b3  push    bc
        sub     223
        ld      c,a
        ld      a,(stor10+1)
        ld      b,a
        xor     a

.Lc1bc  add     a,c
        djnz    Lc1bc                   ; (-3)
        ld      (stor31+1),a
        pop     bc
        jp      Lc0cc

.Lc1c6  inc     hl
        cp      224
        jr      nc,Lc1ec                ; (33)
        push    hl
        and     127
        call    Lc344
        jp      Lc25a
        jp      Lc229
        jp      Lc216
        jp      Lc09f
        jp      Lc206
        jp      Lc184
        jp      Lc234
        jp      Lc23c
        jp      Lc3ac

.Lc1ec  push    bc
        sub     223
        ld      c,a
.stor10
        ld      a,3
        ld      b,a
        xor     a

.Lc1f4  add     a,c
        djnz    Lc1f4                   ; (-3)
        ld      (stor32+1),a
        pop     bc
        jp      Lc075

.Lc1fe  ld      a,(hl)
        ld      (stor11+1),a
        inc     hl
        jp      Lc0cc

.Lc206  ld      a,(hl)
        ld      (value1+1),a
        inc     hl
        jp      Lc075

.Lc20e  ld      a,(hl)
        ld      (stor33+1),a
        inc     hl
        jp      Lc0cc

.Lc216  ld      a,(hl)
        ld      (stor34+1),a
        inc     hl
        jp      Lc075

.Lc21e  ld      a,(stor17+1)
        and     63
        ld      (stor17+1),a
        jp      Lc0f5

.Lc229  ld      a,(stor16+1)        ;stor16+1)
        and     63
        ld      (stor16+1),a
        jp      Lc09f

.Lc234  ld      a,255
        ld      (stor18+1),a
        jp      Lc075

.Lc23c  ld      a,1
        ld      (stor18+1),a
        jp      Lc075

.Lc244  ld      a,255
        ld      (stor22+1),a
        jp      Lc0cc

.Lc24c  ld      a,1
        ld      (stor22+1),a
        jp      Lc0cc

.Lc254  call    Lc36a
        jp      Lc0c9

.Lc25a  call    Lc350
        jp      Lc072

.Lc260  call    Lc384
        jr      Lc275                   ; (16)

.Lc265  sub     223
        ld      c,a
        ld      a,(stor10+1)
        ld      b,a
        xor     a

.Lc26d  add     a,c
        djnz    Lc26d                   ; (-3)
        ld      (stor36+1),a

.Lc273  
.stor36
        ld      c,1

.Lc275  
.double16
        ld      hl,1
        ld      a,(hl)
        inc     hl
        ld      (double16+1),hl
        cp      224
        jr      nc,Lc265                ; (-28)
        and     127
        push    hl
        call    Lc344
        jp      Lc260
        ret     

        nop     
        nop     
        jp      Lc2b4
        ret     

        nop     
        nop     
        jp      Lc29c
        jp      Lc29c
        jp      Lc2c6

.Lc29c  ld      hl,92

.Lc29f  ld      a,(hl)
        or      a
        ret     z

        rlca
        rlca
        and     64
.blah1
        or      0

;        and     24
;        or      0
        out     ($B0),a
        inc     hl
        nop     
        nop     
        nop     
        nop     
        nop     
        nop     
        nop     
        nop     
        nop     
        jr      Lc29f                   ; (-21)

.Lc2b4  ld      b,20
        ld      h,b

.Lc2b7  ld      a,(hl)
        rlca
        rlca
        and     64      ;was and 24 w/o rlca
.stor15
        or      0
        out     ($B0),a

.Lc2be  dec     a
        nop     
        jr      nz,Lc2be                ; (-4)
        dec     l
        djnz    Lc2b7                   ; (-14)
        ret     


.Lc2c6  ld      hl,(double16+1)
        ld      a,(hl)
        inc     hl
        ld      b,(hl)
        inc     hl
        ld      (double16+1),hl
        ld      l,a
        rrca    
        ld      h,a

.Lc2d3
.blah2
        ld      a,0
        out     ($B0),a
        dec     l
        ld      a,l

.Lc2d8  dec     a
        jr      nz,Lc2d8                ; (-3)
.blah3
        ld      a,0
        out     ($B0),a
        ld      a,4
        add     a,h
        ld      h,a

.Lc2e3  dec     a
        jr      nz,Lc2e3                ; (-3)
        djnz    Lc2d3                   ; (-21)
        ret     


.Lc2e9  
.stor18
        ld      a,0
        or      a
        ret     z
.stor19
        add     a,0
        ld      (stor19+1),a
        ld      d,a
        ld      a,(value1+1)
        add     a,d
        call    Lc124
        ld      (stor1+1),a
        ld      d,a
        rra     
        rra     
        rra     
        and     31
        ld      (stor20+1),a
        xor     a
        ld      (stor21+1),a
        inc     a
        ld      (stor4+1),a
        ld      a,(stor16+1)
        or      64
        ld      (stor16+1),a
        ret     


.Lc317  
.stor22
        ld      a,0
        or      a
        ret     z
.stor23
        add     a,0
        ld      (stor23+1),a
        ld      e,a
        ld      a,(stor11+1)
        add     a,e
        call    Lc124
        ld      (stor2+1),a
        ld      e,a
        rra     
        rra     
        and     63
        ld      (stor3+1),a
        xor     a
        ld      (stor24+1),a
        inc     a
        ld      (stor25+1),a
        ld      a,(stor17+1)
        or      64
        ld      (stor17+1),a
        ret     


.Lc344  ld      l,a
        add     a,a
        add     a,l
        pop     hl
        add     a,l
        ld      l,a
        jr      nc,Lc34d                ; (1)
        inc     h

.Lc34d  ex      (sp),hl
        ld      a,(hl)
        ret     


.Lc350  
.double1
        ld      hl,0
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      (double1+1),hl
        ld      (double11+1),de
        ld      a,e
        or      d
        ret     nz

        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      (double1+1),de
        jr      Lc350                   ; (-26)

.Lc36a  
.double2
        ld      hl,0
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      (double2+1),hl
        ld      (double14+1),de
        ld      a,d
        or      e
        ret     nz

        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      (double2+1),de
        jr      Lc36a                   ; (-26)

.Lc384  
.double10
        ld      hl,0
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      (double10+1),hl
        ld      (double16+1),de
        ld      a,d
        or      e
        ret     nz

        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      (double10+1),de
        jr      Lc384                   ; (-26)

IF SLOWDO
.Lc39e  
        ld      a,1
        dec     a
        add     a,a
        add     a,a
        add     a,a
        ld      hl,tune+85      ;L50193
        add     a,l
        ld      l,a
        ret     nc
        inc     h
        ret     
ENDIF


.Lc3ac  ld      a,(hl)
        ld      (stor10+1),a
        inc     hl
        jp      Lc075

.Lc3b4  ld      a,(hl)
        ld      (stor10+1),a
        inc     hl
        jp      Lc0cc


