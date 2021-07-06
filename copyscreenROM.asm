;Copy a screen from 16384 to OZ Map
;Needs to be reworked for each game..
;Rewriting so can ROM it..
;
;Now fixed for Lemmings (redundant code also removed!)


    MODULE  screen
    SECTION code

    INCLUDE "interrpt.def"



    XREF    cksound
    XREF    myflags
    XREF    varbase
    XREF    ozbank
    XREF    ozaddr
    XREF    screen

    XDEF    ozscrcpy
    XDEF    ozscrcpy_noc
    XDEF    oztitlecopy

;Myflags
;bit 0 = sound on/off
;bit 1 = title music
;bit 2 = samples
;bit 3 = resoluion
;bit 4 = inverse


.oztitlecopy
    ld      a,(myflags)
    push    af
    ld      a,(varbase+27)
    push    af
    xor     a
    ld      (myflags),a
    ld      (varbase+27),a
    call    ozscrcpy_noc
    pop     af
    ld      (varbase+27),a
    pop     af
    ld      (myflags),a
    ret

          
.ozscrcpy
    call    cksound         ;might as well do it here!
.ozscrcpy_noc  
    ld      hl,$4D1
    ld      a,(hl)
    push    af
    ld      a,(varbase+27)
    ld      d,a
    ld      a,(myflags)
    ld      e,a
    ld      a,(ozbank)
    ld      (hl),a
    ld      bc,(ozaddr)
    push    bc
    out     ($D1),a
    ld      b,d     ;varbase
    ld      a,e     ;myflags
    ld      de,ozfullcpy
    bit     3,a              ;bit 3
    jr      z,ozskhalf
    ld      de,ozhalfcpy
.ozskhalf
    exx
    ld      c,0
    bit     4,a
    jr      z,ozskinv
    ld      c,255
.ozskinv
    pop     hl      ;screen address
    exx
    call    oz_di
    push    af
    call    ozcallch
    pop     af
    call    oz_ei
    pop     af
    ld      ($4D1),a
    out     ($D1),a
    ret

.ozcallch
    push    de
    ret

.ozfullcpy
    ld      a,b ;varbase+27
    rrca
    rrca
    rrca
    and     15
    cp      12
    jr      c,scrcpya
    ld      a,11
.scrcpya  
    sub     3
    jr      nc,scrcpy0
    xor     a
.scrcpy0
    ld      b,a
    ld      c,8
.scrcpy1  
    push    bc
    ld       a,b
    and     248
    add     a,+(screen/256)
    ld      d,a
    ld      a,b
    and     7
    rrca
    rrca
    rrca
    ld      e,a
    ;OZ screen is handled like characters..grrr!
    ld      c,32
.scrcpy2
    ld      b,8
    push    de
.scrcpy3  
    ld      a,(de)
    exx
    xor     c
    ld      (hl),a
    inc     hl
    exx
    inc     d
    djnz    scrcpy3
    pop     de
    inc     e
    dec     c
    jp      nz,scrcpy2
    pop     bc
    inc     b
.scrcpy36 
    ex      af,af
    dec     c
    jp      nz,scrcpy1
    ret


;Screen copy for half size

.ozhalfcpy
    ld      de,screen
.ozhalfcpy1
    ld      b,4
.ozhalfcpy2
    ld      a,(de)
    exx
    xor     c
    ld      (hl),a
    inc     hl
    exx
    inc     d
    inc     d
    djnz    ozhalfcpy2
    ld      a,d
    sub     8
    ld      d,a
    ld      a,e
    add     a,32
    ld      e,a
    ld      b,4
.ozhalfcpy3
    ld      a,(de)
    exx
    xor     c
    ld      (hl),a
    inc     hl
    exx
    inc     d
    inc     d
    djnz    ozhalfcpy3
    ld      a,d
    sub     8
    ld      d,a
    ld      a,e
    sub     31
    ld      e,a
    and     31
    jp      nz,ozhalfcpy1
    ld      a,e
    add     a,32
    ld      e,a
    and     a
    jp      nz,ozhalfcpy1
    ld      a,d
    add     a,8
    ld      d,a
    cp      32+16
    jp      c,ozhalfcpy1
    ret

