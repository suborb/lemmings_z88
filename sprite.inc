;
;       Lemmings Sprite Routines
;       Hived off from main block of code 26/11/99
;
;

; ----- START OF SPRITE ROUTINES -----


.Lb80e  sub     16
        ex      af,af'
        push    ix
        push    bc
        call    spr16x16_rig
        pop     bc
        pop     ix
        inc     ix
        ld      a,b
        cp      247
        jp      nc,Lb998
        add     a,8
        ld      b,a
        push    ix
        push    bc
        call    spr16x16_rig
        pop     bc
        pop     ix
        ld      de,15
        add     ix,de
        ld      a,c
        cp      120
        ret     nc

        add     a,8
        ld      c,a
        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        ld      a,b
        sub     8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        ld      a,b
        add     a,8
        ld      b,a
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        ret     


.Lb998  ld      de,15
        add     ix,de
        ld      a,c
        add     a,8
        ld      c,a
        bit     7,c
        ret     nz

        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z

        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        ret     


.Lba22  sub     16
        ex      af,af'
        inc     ix
        push    ix
        push    bc
        call    spr16x16_left
        pop     bc
        pop     ix
        ld      de,16
        add     ix,de
        ld      a,c
        add     a,8
        ld      c,a
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        ret     

; Print 16x16 sprite I guess, usual conditions it looks like


.Lbab0  
        push    ix
        dec     ix
        push    bc
        push    af
        call    Lba22
        pop     af
        pop     bc
        pop     ix
        sub     16
        ex      af,af'
        ld      a,b
        add     a,8
        ld      b,a
        inc     ix
        push    ix
        push    bc
        call    spr16x16_rig
        pop     bc
        pop     ix
        ld      de,16
        add     ix,de
        ld      a,c
        add     a,8
        ld      c,a
        bit     7,c
        ret     nz
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz

        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        ex      af,af'
        dec     a
        dec     a
        ret     z
        ex      af,af'
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        ret     

; Sprite routine, print left column of 16x16 sprite
; Presumably used for going off right of screen

.spr16x16_rig  
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        ret     

;Print 16x16 sprites but only print right most column on far left
;of screen

.spr16x16_left  
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        inc     ix
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline_left
        ret     

; Dump a 1 byte sprite line to the screen at 31805
; Shift byte for correct posn
; Entry: c = pixel row
;        b = pixel x (0-255)
;        (table1st) = x posn (chars)
;       ix = address to pick sprite line up from

.sprline  
        ld      hl,table1       ;speed up?
        ld      e,c
        ld      d,0
        sla     e
        add     hl,de
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ex      de,hl   ;hl holds line address for row in c
        ld      a,(table1st)
        ld      e,a
        ld      d,0
        add     hl,de   ;now pointing to correct
        ld      d,(ix+0)
        ld      e,0
        ld      a,b
        and     7
        jp      z,Lbc2c
.Lbc24  srl     d
        rr      e
        dec     a
        jp      nz,Lbc24
.Lbc2c  ld      a,d
        or      (hl)
        ld      (hl),a
        ld      a,b
        cp      249
        ret     nc
        inc     hl
        ld      a,e
        or      (hl)
        ld      (hl),a
        ret     

;Another sprite plot routine, only prints right-most char of sprite
;on left hand side of screen
;Entry:   c = pixel row
;         b = pixel x
;        ix = points to byte to pick up


.sprline_left  
        ld      hl,table1       ;speedup?
        ld      e,c
        ld      d,0
        sla     e
        add     hl,de
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ex      de,hl
        ld      d,(ix+0)
        ld      e,0
        ld      a,b
        and     7
        jp      z,Lbc58
.Lbc50  srl     d
        rr      e
        dec     a
        jp      nz,Lbc50
.Lbc58  ld      a,e
        or      (hl)
        ld      (hl),a
        ret     

; Print 8x8 sprite to 16384 screen, usual entry params

IF SPECTRUM

.spr8x8_16384  
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        inc     ix
        inc     c
        ld      a,c
        cp      192
        ret     nc
        call    sprline16384
        ret     
ENDIF


; Plot routine to 16384 screen - one pixel line again
; if varbase+51 == 0 then don't or, copy directly
; Entry:        c = pixel row
;               b = pixel x
;      (table1st) = char x
;              ix = byte to pick up

.sprline16384  
IF SPECTRUM
        ld      hl,table1+256
ELSE
        ld      hl,table1
ENDIF
       
        ld      e,c
        ld      d,0
        add     hl,de
        add     hl,de
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ex      de,hl
        ld      a,(table1st)
        ld      e,a
        ld      d,0
        add     hl,de
        ld      d,(ix+0)
        ld      e,0
        ld      a,b
        and     7
        jp      z,Lbcd6
.Lbcce  srl     d
        rr      e
        dec     a
        jp      nz,Lbcce
.Lbcd6  ld      a,d
        ex      af,af'
        ld      a,(varbase+51)
        and     a
        jp      z,Lbce3
        ex      af,af'
        or      (hl)
        ex      af,af'
.Lbce3  ex      af,af'
        ld      (hl),a
        ld      a,b
        cp      249
        ret     nc
        inc     hl
        ld      a,e
        ex      af,af'
        ld      a,(varbase+51)
        and     a
        jp      z,Lbcf7
        ex      af,af'
        or      (hl)
        ex      af,af'
.Lbcf7  ex      af,af'
        ld      (hl),a
        ret     



.Lbcfa  push    bc
        push    iy
        push    hl
        push    af
        ex      af,af'
        ld      a,b
        ex      af,af'
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        jp      z,Lbe72
        ex      af,af'
        inc     a
        bit     7,a
        jp      nz,Lbe72

.Lbe72  pop     af
        pop     hl
        pop     iy
        pop     bc
        inc     iy
        ld      de,8
        add     hl,de
        bit     1,h
        ret     nz

        ex      af,af'
        ld      a,b
        ex      af,af'
        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        push    af
        push    hl
        call    Lbfb4
        pop     hl
        pop     af
        inc     iy
        inc     iy
        ex      af,af'
        dec     a
        ret     z

        ex      af,af'
        inc     a
        bit     7,a
        ret     nz

        ret     


.Lbfb4  push    hl
        ld      d,a
        ld      e,0
        srl     d
        rr      e
        srl     d
        rr      e
        ld      a,l
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l
        add     hl,de
        ld      de,levdata
        add     hl,de
        ld      d,(iy+0)
        ld      e,0
        and     7
        jp      z,Lbfe4

.Lbfdc  srl     d
        rr      e
        dec     a
        jp      nz,Lbfdc

; What the firg is going on here? - 49124

.Lbfe4  
        ld      a,d
        xor     255
        and     (hl)
        ld      (hl),a
        pop     ix
        ld      bc,504
        defb      237,221                ; Undocumented 8 T-State NOP
        ld      b,d
        ret     c

        inc     hl
        ld      a,e
        xor     255
        and     (hl)
        ld      (hl),a
        ret     

; Print a sprite routine
; Entry:        b = pixel row
;               c = pixel line
;              ix = sprite address


.sprite8x8  
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
.Lc003  call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    sprline
        ret     

; Another 8x8 sprite routine - this one does the mask
; Entry:        b = pixel row
;               c = pixel x
;              ix = sprite to print


.mask8x8  
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        inc     ix
        inc     c
        bit     7,c
        ret     nz
        call    maskline
        ret     


.maskline  
        ld      hl,table1
        ld      e,c
        ld      d,0
        sla     e
        add     hl,de
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ex      de,hl
        ld      a,(table1st)
        ld      e,a
        ld      d,0
        add     hl,de
        ld      d,(ix+0)
        ld      e,255
        ld      a,b
        and     7
        jp      z,Lc0bb
.Lc0b2
        scf
        rr      d
        rr      e
        dec     a
        jp      nz,Lc0b2
.Lc0bb  ld      a,d
        and     (hl)
        ld      (hl),a
        ld      a,b
        cp      249
        ret     nc
        inc     hl
        ld      a,e
        and     (hl)
        ld      (hl),a
        ret     


.table1
        BINARY  "assets/8192scr.tab"

IF SPECTRUM


;table at 49351...49991(-4?)
;first 256 bytes are for screen line table at 31805
;Bytes at 49607 are screen line table for 16384 - 192 lines

.table1
        BINARY  "table1"         
ENDIF

; ----- END OF SPRITE ROUTINES!! -------
