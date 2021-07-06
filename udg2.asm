;
;       Stuff to do the Status Bar UDGs
;
;       djm 2/2/2000
;


                MODULE udgs
        SECTION code

                INCLUDE "stdio.def"
                INCLUDE "game.inc"

                XREF plotabs
                XDEF doudgs




;
; Brief summary of what we've got..and what we've got to do.
;
; ZX: 16 rows of 192 pixels (ignoring last 8 cols cos it wont fit)
; OZ: 64 x 8 rows x 6 cols
;
; Thus we can afford to use 32 per row (good, our window is that wide!)

;             c3    c4      c5     c2     c3
; OZ:        012345 012345 012345 012345 012345
; ZX:        012345 670123 456701 234567 012345 ....
;            |        |        |         |         |
;
; We use the screen to write our string to...

.doudgs
        ld      ix,screen
        ld      hl,statusudg+256    ;Graphics are here
        ld      a,64
        ld      (udg),a
        call    dorow
        ld      hl,statusudg+512 ;2nd row
        call    dorow
        ld      (ix+0),0
        ld      hl,screen
        call_oz(gn_sop)
; Now print them out, use my quick printany routine
        ld      b,6             ;row
        ld      a,64               ;initial udg
        ld      d,2             ;2 rows
.doplot1
        ld      c,18            ;column
        ld      e,32            ;32 columns
.doplot2
        push    af
        push    de
        push    bc
        call    plotabs
        pop     bc
        pop     de
        pop     af
        inc     c               ;col++
        inc     a               ;udg++
        dec     e
        jr      nz,doplot2
        inc     b               ;row++
        dec     d
        jr      nz,doplot1
        ret

        


.dorow
        ld      e,8
.dorow_1
        push    de
        push    hl
        call    column3
        call    column4
        call    column5
        call    column2
        pop     hl
        ld      de,24
        add     hl,de
        pop     de
        dec     e
        jr      nz,dorow_1
        ret

;Set the udg string up

.setstring
        ld      (ix+0),1
        ld      (ix+1),138
        ld      (ix+2),'='
        ld      a,(udg)
        ld      (ix+3),a
        inc     a       ;char++
        ld      (udg),a
        inc     ix
        inc     ix
        inc     ix
        inc     ix
        ret

        


.column5
        call    setstring
        push    hl
        ld      b,8
.col_5
        push    bc
        ld      e,(hl)
        ld      bc,8
        add     hl,bc
        ld      d,(hl)
        ld      bc,-8
        add     hl,bc
        rl     d
        rl     e
        rl     d
        rl     e
        ld      a,e
        and     @00111111
        or      @10000000
        ld      (ix+0),a
        inc     ix
        inc     hl
        pop     bc
        djnz    col_5
        pop     hl
        ld      bc,8
        add     hl,bc
        
        ret
        



.column4
        call    setstring
        push    hl
        ld      b,8
.col_4
        push    bc
        ld      e,(hl)
        ld      bc,8
        add     hl,bc
        ld      d,(hl)
        ld      bc,-8
        add     hl,bc
        rr     e
        rr     d
        rr     e
        rr     d
        rr     e
        rr     d
        rr     e
        rr     d
        ld      a,d
        and     @00111111
        or      @10000000
        ld      (ix+0),a
        inc     hl
        inc     ix
        pop     bc
        djnz    col_4
        pop     hl
        ld      bc,8
        add     hl,bc
        ret




.column3
        call    setstring
        push    hl
        ld      b,8
.col_3
        ld      a,(hl)
        rra
        rra
        and     @00111111
        or      @10000000
        ld      (ix+0),a
        inc     ix
        inc     hl
        djnz    col_3
        pop     hl
        ret



.column2
        call    setstring
        push    hl
        ld      b,8
.col_2
        ld      a,(hl)
        and     @00111111
        or      @10000000
        ld      (ix+0),a
        inc     ix
        inc     hl
        djnz    col_2
        pop     hl
        ld      bc,8
        add     hl,bc
        ret




