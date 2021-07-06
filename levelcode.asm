;
;       Entry Level Code Gubbins
;
;       Split off from main file 26/11/99



        MODULE  levelcode
        SECTION code

        INCLUDE "time.def"

        INCLUDE "game.inc"

        XREF    messag
        XREF    dmessag
        XREF    firemsg
        XREF    checkfire
        XREF    numpri
        XREF    ozread
        XREF    retascii
        XREF    startselect
        XREF    fadeattr
        XREF    windclr

        XDEF    getcode
        XDEF    inputcode

.getcode
.Lb2db  ld      hl,L46230
        ld      de,levelcode
        ld      bc,10
        ldir    
        ld      a,(level)
        ld      b,a
        ld      a,(L45786)      ;always 0?
        ld      c,a
        ld      a,(savedlemmings)
        ld      e,a
        ld      ix,levelcode
        ld      a,b
        and     1
        sla     a
        sla     a
        sla     a
        or      (ix+0)
        ld      (ix+0),a
        ld      a,c
        and     1
        sla     a
        or      (ix+0)
        ld      (ix+0),a
        ld      a,e
        and     1
        sla     a
        sla     a
        or      (ix+0)
        ld      (ix+0),a
        ld      a,b
        and     2
        sla     a
        or      (ix+1)
        ld      (ix+1),a
        ld      a,e
        and     2
        srl     a
        or      (ix+1)
        ld      (ix+1),a
        ld      a,b
        and     4
        or      (ix+2)
        ld      (ix+2),a
        ld      a,c
        and     2
        srl     a
        or      (ix+2)
        ld      (ix+2),a
        ld      a,e
        and     4
        srl     a
        or      (ix+2)
        ld      (ix+2),a
        ld      a,b
        and     8
        srl     a
        srl     a
        srl     a
        or      (ix+3)
        ld      (ix+3),a
        ld      a,e
        and     8
        srl     a
        srl     a
        or      (ix+3)
        ld      (ix+3),a
        ld      a,b
        and     16
        srl     a
        srl     a
        srl     a
        or      (ix+4)
        ld      (ix+4),a
        ld      a,c
        and     4
        srl     a
        srl     a
        or      (ix+4)
        ld      (ix+4),a
        ld      a,e
        and     16
        srl     a
        or      (ix+4)
        ld      (ix+4),a
        ld      a,b
        and     32
        srl     a
        srl     a
        srl     a
        srl     a
        srl     a
        or      (ix+5)
        ld      (ix+5),a
        ld      a,c
        and     8
        srl     a
        srl     a
        or      (ix+5)
        ld      (ix+5),a
        ld      a,e
        and     32
        srl     a
        srl     a
        srl     a
        or      (ix+5)
        ld      (ix+5),a
        ld      a,b
        and     192
        srl     a
        srl     a
        srl     a
        srl     a
        or      (ix+6)
        ld      (ix+6),a
        ld      a,e
        and     64
        srl     a
        srl     a
        srl     a
        srl     a
        srl     a
        srl     a
        or      (ix+6)
        ld      (ix+6),a
        ld      a,b
        and     15
        add     a,(ix+7)
        ld      (ix+7),a
        ld      a,b
        and     240
        srl     a
        srl     a
        srl     a
        srl     a
        add     a,(ix+8)
        ld      (ix+8),a
        xor     a
        add     a,(ix+0)
        add     a,(ix+1)
        add     a,(ix+2)
        add     a,(ix+3)
        add     a,(ix+4)
        add     a,(ix+5)
        add     a,(ix+6)
        add     a,(ix+7)
        add     a,(ix+8)
        and     15
        add     a,(ix+9)
        ld      (ix+9),a
        ld      a,b
        and     7
        ld      b,a
        ld      a,7
        sub     b
        ld      b,a
        inc     b

.Lb431  ld      c,(ix+6)
        ld      a,(ix+5)
        ld      (ix+6),a
        ld      a,(ix+4)
        ld      (ix+5),a
        ld      a,(ix+3)
        ld      (ix+4),a
        ld      a,(ix+2)
        ld      (ix+3),a
        ld      a,(ix+1)
        ld      (ix+2),a
        ld      a,(ix+0)
        ld      (ix+1),a
        ld      (ix+0),c
        djnz    Lb431                   ; (-44)
        ld      bc,$2521
        call    messag
        defm    "Code for level \x00"
        ld      a,(level)
        inc     a
        ld      (levelnew),a
        call    numpri
        call    messag
        defm    " is \x00"
        ld      d,10
        ld      hl,levelcode
        call    dmessag
        ret

; Default start data for the level code..
.L46230
        defm    "AJHLDHBBCJ"

;
; Routine To enter the access code to getto another level
;


.inputcode  
        call    windclr

.Lb4ab  ld      bc,$2127
        call    messag
        defm    "ENTER ACCESS CODE\x00"
        ld      bc,$222A
        call    messag
        defm    "----------\x00"
        ld      hl,levelcode
        ld      de,levelcode+1
        ld      bc,9
        ld      (hl),45
        ldir    
        ld      a,10
        ld      ix,levelcode

.Lb4e8  push    af
.inploop
        call    retascii
        push    af
        call    ozread
        pop     af
        and     a
        jr      z,inploop
        cp      227     ;DELETE
        jp      z,handle_delete
        ld      (ix+0),a
        inc     ix

        ld      bc,$222A
        ld      d,10
        ld      hl,levelcode
        call    dmessag

.Lb502  
        ld      bc,20
        call_oz(os_dly)
        pop     af
        dec     a
        jp      nz,Lb4e8

.Lb50a  ld      ix,levelcode
        xor     a
        add     a,(ix+0)
        add     a,(ix+1)
        add     a,(ix+2)
        add     a,(ix+3)
        add     a,(ix+4)
        add     a,(ix+5)
        add     a,(ix+6)
        add     a,(ix+7)
        add     a,(ix+8)
        and     15
        add     a,74
        cp      (ix+9)
        jp      nz,Lb61a
        ld      a,(ix+7)
        sub     66
        ld      (ix+7),a
        ld      a,(ix+8)
        sub     67
        sla     a
        sla     a
        sla     a
        sla     a
        or      (ix+7)
        ld      (ix+8),a
        and     7
        ld      b,a
        ld      a,7
        sub     b
        ld      b,a
        inc     b

.Lb557  ld      c,(ix+0)
        ld      a,(ix+1)
        ld      (ix+0),a
        ld      a,(ix+2)
        ld      (ix+1),a
        ld      a,(ix+3)
        ld      (ix+2),a
        ld      a,(ix+4)
        ld      (ix+3),a
        ld      a,(ix+5)
        ld      (ix+4),a
        ld      a,(ix+6)
        ld      (ix+5),a
        ld      (ix+6),c
        djnz    Lb557                   ; (-44)
        ld      (ix+7),0
        bit     3,(ix+0)
        jr      z,Lb591                 ; (4)
        set     0,(ix+7)

.Lb591  bit     2,(ix+1)
        jr      z,Lb59b                 ; (4)
        set     1,(ix+7)

.Lb59b  bit     2,(ix+2)
        jr      z,Lb5a5                 ; (4)
        set     2,(ix+7)

.Lb5a5  bit     0,(ix+3)
        jr      z,Lb5af                 ; (4)
        set     3,(ix+7)

.Lb5af  bit     1,(ix+4)
        jr      z,Lb5b9                 ; (4)
        set     4,(ix+7)

.Lb5b9  bit     0,(ix+5)
        jr      z,Lb5c3                 ; (4)
        set     5,(ix+7)

.Lb5c3  bit     2,(ix+6)
        jr      z,Lb5cd                 ; (4)
        set     6,(ix+7)

.Lb5cd  bit     3,(ix+6)
        jr      z,Lb5d7                 ; (4)
        set     7,(ix+7)

.Lb5d7  ld      a,(ix+7)
        cp      (ix+8)
        jr      nz,Lb61a                ; (59)
        cp      61
        jr      nc,Lb61a                ; (55)
        push    af
        ld      bc,$2425
        call    messag
        defm    "CODE FOR LEVEL \x00"
        pop     af
        inc     a
        ld      (level),a
        call    numpri
        ld      a,255
        ld      (reloadlevel),a

.Lb607  call    firemsg

.Lb60a  call    checkfire
        jr      nz,Lb60a                ; (-5)
        call    fadeattr
        ld      a,255
        ld      (attr),a
        jp      startselect

.Lb61a  ld      bc,$242A
        call    messag
        defm    "INCORRECT CODE\x00"
        jr      Lb607                   ; (-42)


.handle_delete
        pop     af
        cp      10
        jp      z,inploop
        inc     a
        push    af
        ld      (ix-1),45
        dec     ix
        ld      bc,$222A
        ld      d,10
        ld      hl,levelcode
        call    dmessag
        ld      bc,20
        call_oz(os_dly)
        pop     af
        jp      Lb4e8

