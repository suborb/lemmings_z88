;Miscellaneous OZ routines for applications
;
;
;28/11/99

    MODULE  miscoz
    SECTION code

    INCLUDE "stdio.def"
    INCLUDE "director.def"

    XDEF    ozread
    XREF    myflags
    XREF    redefine


.ozread
    ld      bc,0
    call_oz(os_tin)
    ret     c
    and     a
    ret     nz
    ld      bc,0
    call_oz(os_tin)
    and     a
    ret     z
    ;Deal with command a..for now, just ret
    ld      hl,myflags
    sub     $80
    jr      nz,oz_notq
    ;Quit
    xor     a
    call_oz(os_bye)
.oz_notq
    dec     a               ;$81 - display
    jr      nz,oz_notsize
    ld      a,(hl)
    xor     8
    ld      (hl),a
.oz_notsize
    dec     a               ;$82 - inverse
    jr      nz,oz_notinv
    ld      a,(hl)
    xor     16
    ld      (hl),a
    ret
.oz_notinv
    dec     a               ;$83 - title music
    jr      nz,nottitmusic
    ld      a,(hl)
    xor     2
    ld      (hl),a
    ret
.nottitmusic
    dec     a               ;$84 = samples on/off
    jr      nz,notsample
    ld      a,(hl)
    xor     4
    ld      (hl),a
    ret
.notsample
    dec     a               ;$85 - redefine
    ret     nz
    bit     1,(hl)
    ret     z
    bit     2,(hl)
    ret     nz
    ;        jp      redefine
    ret

