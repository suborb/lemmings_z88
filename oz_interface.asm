;
;     Oz Interface for Games


    MODULE      ozinterface
    SECTION     code


    INCLUDE     "game.inc"
    INCLUDE     "stdio.def"
    INCLUDE     "director.def"
    INCLUDE     "memory.def"
    INCLUDE     "error.def"
    INCLUDE     "syspar.def"
    INCLUDE     "time.def"
    INCLUDE     "fileio.def"
    INCLUDE     "map.def"
    INCLUDE     "screen.def"



    XDEF        messag
    XDEF        messag32
    XDEF        dmessag
    XDEF        prchar1
    XDEF        windclr
    XDEF        doposn
    XDEF        app_entrypoint
    XREF        redrawscreen
    XREF        applname
    XREF        entry


    XREF    ingame_text
    XREF    copyright_text
    XREF    preview_text
    XREF    leveldone_text
    XREF    startselect_text

.app_entrypoint
    ld      a,(ix+2)
    cp      $20+32
    ld      hl,nomemory
    jr      c,init_error
    ;Now find out if we have an expanded machine or not...
    ld      ix,-1
    ld      a,FA_EOF
    call_oz(os_frm)
    jr      z,init_continue
    ld      hl,need_expanded_text
.init_error
    push    hl
    ;Now define windows...
    ld      hl,clrscr
    call_oz(gn_sop)
    ld      hl,windini
    call_oz(gn_sop)
    pop     hl
    call_oz(gn_sop)
    ld      bc,500
    call_oz(os_dly)
    xor     a
    call_oz(os_bye)

.init_continue
    ld      a,SC_DIS
    call_oz(Os_Esc)
    xor     a
    ld      b,a
    ld      hl,errhan
    call_oz(os_erh)
    ld      (l_errlevel),a
    ld      (l_erraddr),hl
    ld      hl,applname
    call_oz(dc_nam)
    call    windsetup
    jp      entry


.windsetup
    ld      hl,clrscr
    call_oz (gn_sop)
    ld      hl,windini
    call_oz(gn_sop)
    ld      a,'5'       ;window number - ignored!
    ld      bc,mp_gra
    ld      hl,255
    call_oz(os_map)          ; create map width of 256 pixels
    ld      b,0
    ld      hl,0                ; dummy address
    ld      a,sc_hr0
    call_oz(os_sci)          ; get base address of map area (hires0)
    push    bc
    push    hl
    call_oz(os_sci)          ; (and re-write original address)
    pop     hl
    pop     bc
    ld      a,b
    ld      (ozbank),a
    ld      a,h
    and     63                  ;mask to bank
    or      64                 ;mask to segment 3 (49152)
    ld      h,a
    ld      (ozaddr),hl
    ret


.redrawscreen
    call    windsetup
    ld      a,(gamemode)
    and     a
    jp      z,copyright_text
    dec     a
    jp      z,startselect_text
    dec     a
    jp      z,preview_text
    dec     a
    jp      z,ingame_text
    dec     a
    jp      z,leveldone_text
    ret




;
; Almost forgot this, an error handler..laughable again!
;

.errhan
    ret     z       ;fatal error - this may louse up allocated mem
    cp      RC_Draw         ;rc_susp        (Rc_susp for BASIC!)
    jr      nz,errhan2
    push    af
    call    redrawscreen
    pop     af
;This is to handle all errors
;Needs to be changed!
.errhan2
    cp      RC_Quit                 ;they don't like us!
    jr      nz,no_error
    xor     a
    call_oz(os_bye)
    ret

.no_error
    xor     a
    ret


; Print a message
; Entry: bc=position
; Text stored after call

.doposn
    ld      hl,doposnt
    call_oz(gn_sop)
    ld      a,c
    call_oz(os_out)
    ld      a,b
    call_oz(os_out)
    ret

.doposnt
    defb 1,'3','@',0



.messag
    call    doposn
    pop     hl
.messag1
    ld      a,(hl)
    inc     hl
    and     a
    jr      z,messag2
    call    prchar1
    jr      messag1
.messag2
    push    hl
    ret

; Print string of 32 characters
; Entry: bc=xy pos
;        hl=text

.messag32
    ld      d,32
.dmessag
    push    hl
    call    doposn
    pop     hl
    ld      e,b     ;kepp row safe
    ld      b,d         ;get back number of chars to print
.messag32_1
    ld      a,(hl)
    call_oz(os_out)
    inc     hl
    inc     c
    djnz    messag32_1
    ld      b,e
    ret

; Output a character in a
; Xypos in bc..

.prchar1
    call_oz(os_out)
    inc   c
    ret



.nomemory
    defb    1,'3','@',32,32,1,'2','J','C'
    defm    "Not enough memory allocated to run application"
    defb    13,10,13,10
    defm    "Sorry, please try again later!"
    defb    0

.need_expanded_text
    defb    1,'3','@',32,32,1,'2','J','C'
    defm    "Sorry, application needs an expanded machine"
    defb    13,10,13,10
    defm    "Try again when you have expanded your machine"
    defb    0



.windclr
    ld      hl,windclrt
    call_oz(gn_sop)
    ret

.windclrt
    defb 1
    defm "2C3\x012+B"
    defb  0


.clrscr
    defb    1,'7','#','3',32,32,32+94,32+8,128,1,'2','C','3',0
          
.windini
    defb   1,'7','#','3',32+7,32+0,32+34,32+8,131     ;dialogue box
    defb   1,'2','C','3',1,'4','+','T','U','R',1,'2','J','C'
    defb   1,'3','@',32,32  ;reset to (0,0)
    defm   "Lemmings z88"
    defb   1,'3','@',32,32 ,1,'2','A',32+34  ;keep settings for 10
    defb   1,'7','#','3',32+8,32+1,32+32,32+7,128     ;dialogue box
    defb   1,'2','C','3'
    defb   1,'3','@',32,32,1,'2','+','B'
    defb   0

