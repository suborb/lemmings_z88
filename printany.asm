
;Plot to absolute address in display file..
;Plots a udg with no attributes....
;Pages to segment 3..
;Entry: a=character (udg!) (64-128)
;       b=y pos c=x pos
;Exit   a=udg character -64

;
; Assumptions:
;       sbrbank = $21
;       sbraddr = $7800 (+offset)

                MODULE absplot
        SECTION code

                defc SBRBANK = $21
                defc SBRADDR = $7800



                XDEF   plotabs
                XDEF   jimmyattr

.plotabs
        ex      af,af'
        ld      a,($4D1)
        push    af
        ld      a,SBRBANK
        ld      ($4D1),a
        out     ($D1),a
        ld      hl,SBRADDR
        ld      d,b     ;each row is 256 bytes
        ld      e,0
        add     hl,de
        ld      e,c
        ld      d,0
        add     hl,de
        add     hl,de   ;each char is two bytes..
;hl now points to address in display file of 
        ex      af,af
        sub     64
        cpl
        ld      (hl),a
        ex      af,af
        inc     hl
        ld      (hl),@10000001
        pop     af
        ld      ($4D1),a
        out     ($D1),a
        ex      af,af
        cpl
        ret

.jimmyattr
        ex      af,af'
        ld      a,($4D1)
        push    af
        ld      a,SBRBANK
        ld      ($4D1),a
        out     ($D1),a
        ld      hl,SBRADDR
        ld      d,b     ;each row is 256 bytes
        ld      e,0
        add     hl,de
        ld      e,c
        ld      d,0
        add     hl,de
        add     hl,de   ;each char is two bytes..
;hl now points to address in display file of 
        ex      af,af
        inc     hl
        ld      (hl),a
        pop     af
        ld      ($4D1),a
        out     ($D1),a
        ex      af,af
        cpl
        ret

;add 0 or 1 = tiny
;add 64 or 1 = gubbins
