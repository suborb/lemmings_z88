;Some more z88 gunk...
;Keyboard routines...hurrah!!!
;These work for games!


    MODULE  keyboard
    SECTION code

    INCLUDE "stdio.def"


    XREF    pkeys
    XDEF    keys
    XDEF    ktest1
    XDEF    kfind
    XDEF    retascii

;Return ascii value for a keystroke
;Entry: none
;Exit:  a = key (0=none/multiple)

.retascii
    call    kfind
    ld      a,0
    ret     nz      ;more than one key
    inc     d
    ret     z
    ld      e,d
    dec     e
    ld      d,0
    ld      hl,keytable
    add     hl,de
    ld      a,(hl)
    ret



IF MAPKEY

;Transforms a raw key into a printable quantity
;Entry: d=raw key
;Output: dumps keys to stdout

.mapkey
    ld      e,d
    ld      d,0
    ld      hl,keytable
    add     hl,de
    ld      a,(hl)
    and     a
    ret     z
    cp      127
    jr      c,mapkey1
    ld      d,a
    ld      a,1
    call_oz(os_out)
    ld      a,d
.mapkey1
    call_oz(os_out)
    ld      a,1
    and     a
    ret
ENDIF


;Find a key...used in define keys...hopefully!
;Exit:    d=key (255=no key)
;        nz=more than one key..

.kfind
    ld      de,$FF47       ;$FF2F
    ld      bc,$FEB2
.nxhalf
    in      a,(c)
    cpl
    and     a
    jr      z,npress
    ;Test for multiple keys..
    inc     d
    ret     nz
    ;Calc key value..
    ld      h,a
    ld      a,e
.kloop
    sub     8
    srl     h
    jr      nc,kloop
    ret     nz        ;a will have some value...
    ld      d,a
.npress
    dec     e
    rlc     b
    jr      c,nxhalf
    ;set zero flag
    cp      a
    ret  


;Read the keys!


.keys
    ld      hl,pkeys+7  
    ld      e,1  
.nxtkey   
    ld      a,(hl)  
    dec     hl  
    call    ktest1  
    ccf   
    rl      e  
    jp      nc,nxtkey  
    ret   

;Test a Z88 key
;Entry: a=key
;Exit:  c=no key
;      nc=key pressed
          
.ktest1   
    ld      c,a  
    and     7  
    inc     a  
    ld      b,a  
    srl     c  
    srl     c  
    srl     c  
    ld      a,8  
    sub     c  
    ld      c,a  
    ld      a,254  
.hifind   
    rrca  
    djnz    hifind  
    in      a,($B2)  
.nxkey
    rra   
    dec     c  
    jp      nz,nxkey  
    ret   


;Key table...


.keytable
;0-15
     defm      "",0,0,"[]-=\\",227,0,0,224,240,241,242,243,225
;16-31
     defm      "",0,0,"123456",0,0,"QWERTY"
;32-47
     defm      "",0,0,"ASDFGH.,ZXCVBN"
;48-64
     defm      "/;LMKJU7",163,34,"0P9OI8"

