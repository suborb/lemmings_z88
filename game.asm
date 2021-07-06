; Disassembly of the file "gamecode_36621_28403"
;
; Created with dZ80 v1.31
;
; on Saturday, 23 of October 1999 at 07:00 PM
;
; Lemmings Entry Point is 36621
;
; djm Started 23/10/99 done all messages
;
; Levels are 64x16=8192 bytes and start at 23613
;
;Global replace: cp 0 w/  and a
;                ld a,0   xor a
;
;62871-62871+2047 - needed for sommat!
;Variable space so far:
;
;       8405 = level data
;       4096 = back screen
;       2219 = varbase gunk
;        720 = @35901 for lemming data
;
;Total: 15440 ~=16384
;
;z88 memory map:

; 8192  =  backscreen
;12288  =  level data
;20693  =  data @ 35901
;21413  =  varbase
;23632  =  my oz variables


                MODULE  game

        defc sampleplay = 62850

        defc comp_game = 1
                INCLUDE "game.inc"
                INCLUDE "fileio.def"
                INCLUDE "director.def"
                INCLUDE "syspar.def"
                INCLUDE "stdio.def"
                INCLUDE "time.def"
                INCLUDE "error.def"

	SECTION code

        defc myzorg = 36750
                org     myzorg

;
;     Routines In Other Modules
;

                XREF    ozscrcpy
                XREF    oztitlecopy

                XREF    messag
                XREF    dmessag
                XREF    messag32
                XREF    prchar
                XREF    prchar1
                XREF    windclr
                XREF    doposn
        
; Keyboard
                XREF    keys
                XREF    ozread
                XREF    retascii
                XREF    kfind

; Misc

                XREF    doudgs
                XREF    getcode
                XREF    inputcode
                XREF    jimmyattr
                XREF    applname
;Values for jimmy syyt
                defc normal_attr = @01000001
                defc inv_attr = @01010001


;Lem table:
;               +0      = type
;               +3      = y
;               +4      = x


; 23403/4 23417/8 prob home and start things

                XDEF    cksound
                XDEF    entry
                XDEF    attr
                XDEF    fadeattr
                XDEF    startselect
                XDEF    firemsg
                XDEF    checkfire
                XDEF    numpri


                XDEF    copyright_text
                XDEF    ingame_text
                XDEF    preview_text
                XDEF    leveldone_text
                XDEF    startselect_text
        


.setup_mydata
        ld      hl,defaultdata
        ld      de,filename
        ld      bc,+(enddefault-defaultdata)
        ldir
        xor     a
        ld      (myflags),a
        ld      hl,varbase
        ld      de,varbase+1
        ld      bc,75
        ld      (hl),a
        ldir
        ret

.domusic
        call    cksound ;exits with hl=myflags
        bit     0,(hl)
        ret     nz
        bit     1,(hl)          ;music off
        ret     nz
        ld      hl,music_store
        ld      de,8377
        push    de
        ld      bc,1600
        ldir
        ret

.dotitlescreen
        ld      hl,titlescreen_store
        ld      de,screen
        ld      bc,1063
        ldir
        call    screen
        call    oztitlecopy
        ret
        

.entry
        ld      (spstor),sp
        call    setup_mydata
.entry1
        ld      sp,(spstor)
        ld      a,1
        ld      (level),a
        ld      hl,applname
        call_oz(dc_nam)
        call    dotitlescreen
        call    copyright

.startlevel  

.L8f54  
        call    startselect
        call    previewtitle
        call    Lc400
        call    ingame_text
        ld      a,255
        ld      (gameon),a
        jp      ploop

.ingame_text
        ld      a,3
        ld      (gamemode),a
        call    windclr
        call    doudgs
        ld      hl,level_name
        ld      bc,$2020
        call    messag32
        ld      bc,$2228
        call    messag
        defm    "OUT 00 IN 00  TIME 0:00\x00"
        ld      a,255
        ld      (timeprflag),a
        call    prtime
        call    prstatnum
        call    copymap
        call    prpointer
        jp      ozscrcpy




; Clear the back screen

.cls    ld      hl,8192
        ld      de,8193
        ld      bc,4095
        ld      (hl),l
        ldir    
        ret     

; Set the attributes to the colour held in a

; Pause for bc loops

.pausebc  
        dec     c
        jr      nz,pausebc
        dec     b
        ld      a,b
        or      c
        ret     z
        dec     c
        jr      pausebc


.fadeattr  
        ld      a,7
        ld      (attr),a

.L8fc5  ld      bc,$2710
;        call    pausebc
;Frazzle break up effect here maybe?
;        call    setattr
;        jr      nc,L8fc5                ; (-11)
        ret     


; Check To see if the fire button/space is pressed

.checkfire  
        call    ozread     ;handles menus and gubbins!
        cp      'M'
        jp      z,entry1
        cp      32
        ret

; The initial intro and music..

.copyright
        xor     a
        ld      (gamemode),a
        call    copyright_text
        call    domusic
        call_oz(os_pur)
.copy1
        call    ozread
        and     a
        jr      z,copy1
        ret


.copyright_text
        call    dotitlescreen
        call    windclr
        ld      bc,$2129
        call    messag
        defm    "Lemmings Z88\x00"
        ld      bc,$2225
        call    messag
        defm    "(c) 1991 Psygnosis Ltd\x00"
        ld      bc,$2320
        call    messag
        defm    "Conversion by D Morris Feb 2000\x00"
        ld      bc,$2523
        call    messag
        defm    "Press Any Key To Continue\x00"
        ret

; Text for startselect

.startselect_text
        ld      a,1
        ld      (gamemode),a
        call    dotitlescreen
        call    windclr
        ld      bc,$2129
        call    messag
        defm    "Current level\x00"
        ld      bc,$222C
        call    messag
        defm    "Level \x00"
        ld      a,(level)
        call    numpri
        ld      bc,$2325
        call    messag
        defm    "To access another level\x00"
        ld      bc,$242A
        call    messag
        defm    "Press Enter\x00"
        call    firemsg
        ret


; Print up the level select thing

.startselect  
        call    startselect_text

.start1
        call    ozread
        cp      'M'
        jp      z,entry1
        cp      13
        jp      z,inputcode
        cp      32
        jr      nz,start1

; ------ START OF LOADING GUBBINS ------
; FIX, FIX! Length=8405

.loadlevel
        call    windclr
        ld      bc,$2220
        call    messag
        defm    "Loading and unzipping Level: \x00"
        ld      a,(level)
        call    numpri
        ld      bc,$2427
        call    messag
        defm    "...please wait...\x00"
        ld      a,(level)
        call    reda2de
        ld      hl,$3030
        add     hl,de
        ld      a,l
        ld      l,h
        ld      h,a
        ld      (filenamech),hl
        ld      de,filename
        call    inflate
        jr      c,filerr
        ld      hl,filename
        call_oz (dc_nam)
        ld      a,(level)
        ld      hl,level_no
        cp      (hl)
        ret     

.filerr
        push    af
        call    windclr
        pop     af
.unziperr
        ld      bc,$2222
        call    messag
        defm    "An error has occurred whilst\x00"
        ld      bc,$2327
        call    messag
        defm    "loading level: \x00"
        ld      a,(level)
        call    numpri
        call    firemsg
.unzip1
        call    checkfire
        jr      nz,unzip1
        jp      startselect


;-------- END OF LOADING GUBBINS ---------


.previewtitle  
        call    preview_text
        jp      waitstartgame

.preview_text
        ld      a,2
        ld      (gamemode),a
        call    cls
        call    previewlevel
;Copy screen over to OZ...
        call    oztitlecopy     ;fixes types etc
        call    windclr
IF SILLY
        ld      bc,$202C
        call    messag
        defm    "Level \x00"
        ld      a,(level)
        call    numpri
ENDIF
        ld      hl,level_name
        ld      bc,$2020
        call    messag32
        ld      bc,$2128
        call    messag
        defm    "No. of Lemmings \x00"
        ld      a,(total_lemmings)
.L9201  call    numpri
        ld      a,(to_be_saved)
        ld      bc,$2228
        call    numpri
        inc     c
        inc     c
        call    messag
        defm    "to be saved\x00"
        ld      bc,$2328
        call    messag
        defm    "Release Rate \x00"
        ld      a,(release_rate)
        call    numpri
        ld      bc,$2428
        call    messag
        defm    "Time \x00"
        ld      a,(time_allowed)
        inc     a
        call    numpri
        call    messag
        defm    " minutes\x00"
        call    firemsg
        ld      bc,$2528
        call    messag
        defm    "Rating \x00"
        ld      a,(rating)
        cp      1
        jr      z,pr_fun                 ; (21)
.L926c  cp      2
        jr      z,pr_tricky                 ; (27)
        cp      3
        jr      z,pr_taxing                 ; (36)
        call    messag
        defm    "Mayhem\x00"
        ret

.pr_fun  
        call    messag
        defm    "Fun\x00"
        ret

.pr_tricky  
        call    messag
        defm    "Tricky\x00"
        ret

.pr_taxing  
        call    messag
        defm    "Taxing\x00"
        ret



.firemsg  
        ld      bc,$2625
        call    messag
        defm    "PRESS SPACE TO CONTINUE\x00"
        ret     


.leveldonescr 
        ld      a,(level)
        ld      (levelnew),a
        call    leveldone_text
        jr      nc,gamedone
        call    waitstartgame
        ld      a,(levelnew)
        ld      (level),a
        jp      startlevel
.gamedone
        call    ozread
        and     a
        jr      z,gamedone
        jp      entry1

.leveldone_text
        ld      a,4
        ld      (gamemode),a
        xor     a
.L92f4  ld      (reloadlevel),a
        call    cls
        call    dotitlescreen
        call    windclr
        ld      bc,$2023
        call    messag
        defm    "All Lemmings accounted for\x00"
        ld      bc,$2122
        call    messag
        defm    "You rescued \x00"
        ld      a,(savedlemmings)
        call    numpri
;        ld      bc,$2228
        call    messag
        defm    " You needed \x00"
        ld      a,(to_be_saved)
        call    numpri

        ld      a,(savedlemmings)
.L9356  and     a
        jp      z,L93de
        ld      hl,to_be_saved
        cp      (hl)
        jp      c,L9428
        ld      a,(level)
        cp      lastlevel
        jp      z,gamefinished
        ld      a,255
        ld      (reloadlevel),a
        ld      a,(savedlemmings)
        ld      hl,total_lemmings
        cp      (hl)
        jp      z,perfectfinish
        ld      hl,to_be_saved
        cp      (hl)
        jp      z,spoton
        ld      bc,$2320
        call    messag
        defm    "That level seemed no problem to\x00"
        ld      bc,$2420
        call    messag
        defm    "you on that attempt one the next\x00"
.L93d8  call    getcode
        call    firemsg
        scf
        ret

.L93de  ld      bc,$2322
        call    messag
        defm    "Rock Bottom! I Hope for your\x00"
        ld      bc,$2421
.L9408  call    messag
        defm    "sake that you nuked that level\x00"
        call    firemsg
        scf
        ret

.L9428  ld      bc,$2321
        call    messag
        defm    "Better rethink your strategy\x00"
        ld      bc,$2420
        call    messag
        defm    "before you try this level again!\x00"
        call    firemsg
        scf
        ret

.spoton ld      bc,$2320
        call    messag
        defm    "Spot on.you can't get much closer\x00"
        ld      bc,$2420
        call    messag
        defm    "than that. lets try the next....\x00"
        call    getcode
        call    firemsg
        scf
        ret

.perfectfinish  
        ld      bc,$2224
        call    messag
        defm    "Superb! You rescued every\x00"
        ld      bc,$2321
        call    messag
        defm    "Lemming on that level. Can you\x00"
        ld      bc,$2427
        call    messag
        defm    "do it again....?\x00"
        call    getcode
        call    firemsg
        scf
        ret

.gamefinished  
        call    cls
        call    windclr
        ld      bc,$2129
        call    messag
        defm    "CONGRATULATIONS!!!\x00"
        ld      bc,$2221
        call    messag
        defm    "You have finished z88 Lemmings\x00"
        ld      bc,$2322
        call    messag
        defm    "You're now truly a Lemmings\x00"
        ld      bc,$2429
        defm    "GRAND MASTER!!\x00"
        ld      bc,$2520
        defm    "Hope you enjoyed playing.. - Dom\x00"
        and     a
        ret


.waitstartgame  
        call    checkfire
        jr      nz,waitstartgame                ; (-8)
        call    fadeattr
        ld      a,255
        ld      (attr),a
        jp      cls



; This looks like the main in game loop

.ploop  
        ld      a,(varbase+34)
        bit     0,a
        jp      nz,scrollleft
        bit     1,a
        jp      nz,scrollright

.mloop  call    copymap
        call    dokeyselectors
        call    L9910   ;lemming actions?
        call    La458   ;more actions?
        call    cklockon
        call    La20e   ;?
        call    L98c3   ;both this and above address datatab1
        ld      a,0
        ld      (gameon),a
        call    interrupt_routine
        ld      a,255
        ld      (gameon),a
        call    prtime
        call    prlemsout
        call    prlemsin
        call    La600
        ld      a,(attr)
        cp      255
        jp      nz,exitlevfin        ;finished level
        ld      a,(varbase+18)
        cp      0
        jp      nz,ploop
        ld      a,(attr)
        cp      255
        jp      nz,mloop

.mloop1 ld      a,5
        ld      (attr),a
        jp      mloop

        xor     a
        ld      (varbase+30),a
        jp      mloop

.exitlevfin  
        jp      leveldonescr    ;poss?

        call    setattr
        jp      c,leveldonescr
        jp      mloop

; Set the screen attribute - used in fade out

.setattr  
        ld      a,(attr)
        sub     1
        ret     c
        ld      (attr),a
        ld      bc,3000
        call    pausebc
        xor     a
        ret     


.scrollleft  
        xor     a
        ld      (varbase+34),a
        ld      a,(scrxpos)
        and     a
        jp      z,mloop
        dec     a
        ld      (scrxpos),a
        ld      hl,(varbase+12)
        ld      de,8
        and     a
        sbc     hl,de
        ld      (varbase+12),hl
        ld      a,(varbase+35)
        bit     0,a
        jp      z,L9790
        xor     a
        ld      (varbase+35),a
        ld      a,(scrxpos)
        cp      2
        jp      c,L9790
        dec     a
        dec     a
        ld      (scrxpos),a
        ld      hl,(varbase+12)
        ld      de,16
        and     a
        sbc     hl,de
        ld      (varbase+12),hl
        jp      L9790

.scrollright  
        xor     a
        ld      (varbase+34),a
        ld      a,(scrxpos)
        cp      32
        jp      nc,mloop
        inc     a
        ld      (scrxpos),a
        ld      hl,(varbase+12)
        ld      de,8
        add     hl,de
        ld      (varbase+12),hl
        ld      a,(varbase+35)
        bit     1,a
        jp      z,L9790
        xor     a
        ld      (varbase+35),a
        ld      a,(scrxpos)
        cp      30
        jp      nc,L9790
        inc     a
        inc     a
        ld      (scrxpos),a
        ld      hl,(varbase+12)
        ld      de,16
        add     hl,de
        ld      (varbase+12),hl

.L9790  ld      iy,(varbase+67)
        ld      a,(varbase+25)
        ld      b,a
        and     a
        jp      z,mloop

.L979d  push    bc
        ld      a,(iy+0)
        and     a
        jp      z,L97a9
        call    L9c94

.L97a9  pop     bc
        ld      de,20
        add     iy,de
        djnz    L979d                   ; (-20)
        jp      mloop



; Print the lemming numbers

.prstatnum  
        ld      bc,$2420
        ld      a,(release_rate)
        call    prstatusnum
        ld      a,(release_rate)
        inc     c
        call    prstatusnum
        ld      a,(num_climbers)
        ld      bc,$2426
        call    prstatusnum
.L97f3  ld      a,(num_floaters)
        ld      bc,$2428
        call    prstatusnum
.L9800  ld      a,(num_bombers)
        ld      bc,$242B
        call    prstatusnum
.L980d  ld      a,(num_blockers)
        ld      bc,$242E
        call    prstatusnum
.L981a  ld      a,(num_builders)
        ld      bc,$2430
        call    prstatusnum
.L9827  ld      a,(num_bashers)
        ld      bc,$2433
        call    prstatusnum
.L9834  ld      a,(num_miners)
        ld      bc,$2436
        call    prstatusnum
.L9841  ld      a,(num_diggers)
        ld      bc,$2439
        call    prstatusnum
        jp      mksel_icon

; Print a numbr in a...at bc

.prselect
        ld      hl,invon
        call_oz(gn_sop)
        call    prstatusnum
        ld      hl,invon
        call_oz(gn_sop)
        ret
.invon
        defb    1,'R',0

.prstatusnum  
        ld      hl,tinyon
        call_oz(gn_sop)
        call    numpri
        ld      hl,tinyon
        call_oz(gn_sop)
        ret     
.tinyon defb    1,'T',0


.numpri  
        push    af
        call    doposn
        pop     af
        call    reda2de
        push    bc
        push    de
        ld      a,d
        add     a,48
        call    prchar1
        pop     de
        pop     bc
        inc     c
        ld      a,e
        add     a,48
        call    prchar1
        ret     


; Get a number in a into a tens in d and units in e

.reda2de  
        cp      10
        jp      c,L98b0
        ld      d,0
.L98a2  push    af
        sub     10
        jp      c,L98ad
        inc     d
        pop     hl
        jp      L98a2
.L98ad  pop     af
        ld      e,a
        ret     
.L98b0  ld      e,a
        ld      d,0
        ret     


; Handles trapdoor?

.L98c3  ld      iy,datatab1
        ld      de,20
        add     iy,de
        add     iy,de
        call    L99ce
        ld      de,20
        add     iy,de
        call    L99ce
        ld      a,(varbase+58)
        and     a
        ret     z

        dec     a
        ld      (varbase+58),a
        cp      4
        ret     nc
        and     a
        ld      a,2             ;lets go sound
        call    z,sample

        ld      iy,datatab1
        ld      l,(iy+10)
        ld      h,(iy+11)
        ld      de,64
        add     hl,de
        ld      (iy+10),l
        ld      (iy+11),h
        ld      de,20
        add     iy,de
        ld      l,(iy+10)
        ld      h,(iy+11)
        ld      de,64
        add     hl,de
        ld      (iy+10),l
        ld      (iy+11),h
        ret     

; Does the Lemming Actions?

.L9910  ld      iy,datatab1+120
        ld      a,(varbase+25)
        ld      hl,varbase+69
        add     a,(hl)
        ld      b,a
        and     a
        jp      z,La170

.L9921  push    bc
        bit     5,(iy+0)
        jp      nz,La955

.L9929  ld      a,(iy+0)        ;lemming type
        and     31
        jp      z,L998d         ;cp 0
        cp      1
        jp      z,L99fd
        cp      2
        jp      z,L9af1
        cp      3
        jp      z,L9acd
        cp      7
        jp      z,L9cbb
        cp      10
        jp      z,Lad99
        cp      8
        jp      z,L9d83
        cp      12
        jp      z,La131
        cp      9
        jp      z,La31d
        cp      11
        jp      z,L9f36
        cp      4
        jp      z,L9cda
        cp      13
        jp      z,L9d6d
        cp      14
        jp      z,L9a62
        cp      5
        jp      z,Lab06
        cp      17
        jp      z,Lab43
        cp      15
        jp      z,L9c54
        cp      16
        jp      z,La9ee
        cp      19
        jp      z,Laa32
        cp      18
        jp      z,L9999

.L998d  pop     bc
        ld      de,20
        add     iy,de
        djnz    L9921                   ; (-116)
        jp      La170

.L9998  pop     af

.L9999  ld      a,(iy+12)
        inc     a
        cp      (iy+13)
        jp      nc,L99bb
        ld      (iy+12),a
        ld      l,(iy+10)
        ld      h,(iy+11)
        ld      d,0
        ld      e,(iy+15)
        add     hl,de
        ld      (iy+10),l
        ld      (iy+11),h
        jp      L998d

.L99bb  ld      (iy+12),1
        ld      l,(iy+8)
        ld      h,(iy+9)
        ld      (iy+10),l
        ld      (iy+11),h
        jp      L998d

.L99ce  ld      a,(iy+12)
        inc     a
        cp      (iy+13)
        jp      nc,L99ec
        ld      (iy+12),a
        ld      l,(iy+10)
        ld      h,(iy+11)
        ld      de,64
        add     hl,de
        ld      (iy+10),l
        ld      (iy+11),h
        ret     


.L99ec  ld      (iy+12),1
        ld      l,(iy+8)
        ld      h,(iy+9)
        ld      (iy+10),l
        ld      (iy+11),h
        ret     


.L99fd  ld      a,(iy+0)
        and     64
        jp      nz,L9a6d

.L9a05  ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        call    La13c
        push    af
        and     (hl)
        jp      nz,L9a3f
        pop     af
        ld      de,64
        add     hl,de
        and     (hl)
        jp      nz,L9a35
        ld      a,(iy+5)
        inc     a
        inc     a
        inc     (iy+19)
        inc     (iy+19)

.L9a2a  cp      128
        jp      nc,L9a9c
        ld      (iy+5),a
        jp      L9999

.L9a35  ld      a,(iy+5)
        inc     a
        inc     (iy+19)
        jp      L9a2a

.L9a3f  pop     af
        ld      a,(iy+19)
        cp      42
        jp      c,Lad03
        ld      a,(iy+0)
        and     224
        add     a,14
        ld      (iy+0),a
        ld      hl,58466
        ld      a,20
        ld      b,17
        ld      de,2058
        call    setlemgfx
        jp      L998d

.L9a62  ld      a,(iy+12)
        cp      16
        jp      nz,L9999
        jp      L9a9c

.L9a6d  ld      a,(iy+19)
        cp      20
        jp      c,L9a05
        bit     0,(iy+14)
        jp      z,L9a96
        ld      hl,58786

.L9a7f  ld      a,(iy+0)
        and     224
        add     a,5
        ld      (iy+0),a
        ld      b,9
        ld      a,32
        ld      de,2064
        call    setlemgfx
        jp      L998d

.L9a96  ld      hl,59042
        jp      L9a7f

.L9a9c  ld      a,255
        ld      (varbase+15),a
        ld      (iy+0),0
        ld      hl,varbase+16
        dec     (hl)
        ld      hl,varbase+18
        dec     (hl)
        ld      a,(varbase+30)
;        bit     0,a
;        jp      z,L998d
        rrca
        jp      nc,L998d
        push    iy
        pop     de
        ld      hl,(varbase+48)
        ex      de,hl
        xor     a
        sbc     hl,de
        jp      nz,L998d
        ld      (varbase+30),a  ;a=0
        jp      L998d

.L9acd  dec     (iy+5)
        ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        call    La13c
        push    af
        and     (hl)
        jp      z,Lad02
        pop     af
        dec     (iy+5)
        ld      de,64
        sbc     hl,de
        and     (hl)
        jp      z,Lad03
        jp      L998d

.L9af1  bit     0,(iy+14)
        jp      nz,L9b11
        ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        ld      (iy+3),l
        ld      (iy+4),h
        push    hl
        ld      de,10
        sbc     hl,de
        jr      nc,L9b2a                ; (29)
        pop     hl
        jp      L9be2

.L9b11  ld      l,(iy+3)
        ld      h,(iy+4)
        inc     hl
        ld      (iy+3),l
        ld      (iy+4),h
        push    hl
        ld      de,496
        sbc     hl,de
        jr      c,L9b2a                 ; (4)
        pop     hl
        jp      L9be2

.L9b2a  pop     hl
        ld      a,(iy+5)
        push    hl
        push    af
        ld      b,a
        ld      a,l
        and     3
        jp      nz,L9b42
        ld      a,b
        sub     5
        call    Lac82
        and     a
        jp      nz,L9c2f

.L9b42  pop     af
        pop     hl
        call    La13c
        ld      de,64
        push    af
        and     (hl)
        jp      nz,L9b74
        add     hl,de
        pop     af
        push    af
        and     (hl)
        jp      nz,L9c11
        pop     af
        push    af
        add     hl,de
        and     (hl)
        jp      nz,L9c0e
        pop     af
        push    af
        add     hl,de
        and     (hl)
        jp      nz,L9c0b
        pop     af
        inc     (iy+5)
        inc     (iy+5)
        inc     (iy+5)
        inc     (iy+5)
        jp      Laada

.L9b74  xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,L9c14
        xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,L9c25
        xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,L9c22
        xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,Lab7e
        xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,Lab7e
        xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,Lab7e
        xor     a
        sbc     hl,de
        pop     af
        push    af
        and     (hl)
        jp      z,Lab7e
        pop     af
        bit     7,(iy+0)
        jp      z,L9be2
        bit     0,(iy+14)
        jp      z,L9bdc
        ld      hl,57698

.L9bc5  ld      a,(iy+0)
        and     224
        add     a,4
        ld      (iy+0),a
        ld      a,24
        ld      b,9
        ld      de,2060
        call    setlemgfx
        jp      L998d

.L9bdc  ld      hl,57890
        jp      L9bc5

.L9be2  ld      (iy+12),1
        bit     0,(iy+14)
        jp      nz,L9c01
        ld      (iy+14),255
        ld      hl,52890

.L9bf4  ld      b,9
        ld      a,20
        ld      de,2058
        call    setlemgfx
        jp      L998d

.L9c01  ld      (iy+14),0
        ld      hl,53070
        jp      L9bf4

.L9c0b  inc     (iy+5)

.L9c0e  inc     (iy+5)

.L9c11  inc     (iy+5)

.L9c14  pop     af
        bit     7,(iy+5)
        jp      nz,L9a9c
        call    L9c94
        jp      L9999

.L9c22  dec     (iy+5)

.L9c25  dec     (iy+5)
        pop     af
        call    L9c94
        jp      L9999

.L9c2f  cp      1
        jp      z,L9c3e
        cp      8
        jp      nz,L9b42
        pop     hl
        pop     af
        jp      L9be2

.L9c3e  pop     hl
        pop     af
        ld      hl,59298
        ld      (iy+0),15
        ld      de,2061
        ld      b,9
        ld      a,26
        call    setlemgfx
        jp      L998d

; We have a lemming home!

.L9c54  ld      a,(iy+12)
        cp      8
        jp      nz,L9999
        ld      a,255
        ld      (varbase+15),a
        ld      (varbase+56),a
        ld      (iy+0),0
        ld      hl,varbase+16
        dec     (hl)
        ld      hl,savedlemmings
        inc     (hl)
        ld      hl,varbase+18
        dec     (hl)
        ld      a,(varbase+30)
        bit     0,a
        jp      z,L998d
        push    iy
        pop     de
        ld      hl,(varbase+48)
        ex      de,hl
        xor     a
        sbc     hl,de
        jp      nz,L998d
        ld      (varbase+30),a  ;a-0
        jp      L998d

.L9c94  ld      l,(iy+3)
        ld      h,(iy+4)
        ld      de,(varbase+12)
        xor     a
        sbc     hl,de
        jp      c,L9cb6
        ld      a,h
        and     a
        jp      nz,L9cb6
        ld      (iy+2),l
        ld      (iy+1),255
        ret     


.L9cb6  ld      (iy+1),0
        ret     


.L9cbb  ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        call    La13c
        and     (hl)
        jp      nz,L9999
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        call    La9c0
        jp      Lad03

.L9cda  ld      a,(iy+12)
        dec     a
        bit     2,a
        jr      nz,L9d0b                ; (41)
        ld      a,(iy+5)
        dec     a
        cp      12
        jp      c,L9d52
        ld      (iy+5),a
        ld      l,(iy+3)
        ld      h,(iy+4)
        bit     0,(iy+14)
        jr      z,L9d07                 ; (13)
        dec     hl
        dec     hl

.L9cfc  sub     8
        call    La13c
        and     (hl)
        jr      nz,L9d52                ; (78)
        jp      L9999

.L9d07  inc     hl
        inc     hl
        jr      L9cfc                   ; (-15)

.L9d0b  ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        sub     7
        ld      b,(iy+12)
        dec     b
        sub     b
        call    La13c
        and     (hl)
        jp      nz,L9999
        ld      a,(iy+5)
        sub     (iy+12)
        add     a,3
        ld      (iy+5),a
        bit     0,(iy+14)
        jr      z,L9d4d                 ; (26)
        ld      hl,58082

.L9d36  ld      a,(iy+0)
        and     224
        add     a,13
        ld      (iy+0),a
        ld      b,9
        ld      a,24
        ld      de,2060
        call    setlemgfx
        jp      L998d

.L9d4d  ld      hl,58274
        jr      L9d36                   ; (-28)

.L9d52  inc     (iy+5)
        inc     (iy+5)
        bit     0,(iy+14)
        jp      nz,L9d66
        ld      (iy+14),255
        jp      Laada

.L9d66  ld      (iy+14),0
        jp      Laada

.L9d6d  ld      a,(iy+12)
        cp      8
        jp      z,Lad03
        cp      6
        jp      nc,L9999
        dec     (iy+5)
        dec     (iy+5)
        jp      L9999

.L9d83  ld      a,(iy+12)
        cp      15
        jp      z,L9d91
        jp      nc,L9e33
        jp      L9999

.L9d91  ld      a,(iy+5)
        dec     a
        ld      l,(iy+3)
        ld      h,(iy+4)
        bit     0,(iy+14)
        jp      z,L9deb
        dec     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        call    Lacce
        or      (hl)
        ld      (hl),a
        dec     (iy+16)
        ld      a,(iy+16)
        cp      3
        jp      nc,L9999
        call    setplop1
        jp      L9999

.L9deb  push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        or      (hl)
        ld      (hl),a
        pop     af
        pop     hl
        dec     hl
        call    Lacce
        or      (hl)
        ld      (hl),a
        dec     (iy+16)
        ld      a,(iy+16)
        cp      3
        jp      nc,L9999
        call    setplop1
        jp      L9999

.L9e33  ld      a,(iy+5)
        cp      10
        jp      c,L9ee2
        dec     (iy+5)
        bit     0,(iy+14)
        jp      z,L9ef8
        ld      l,(iy+3)
        ld      h,(iy+4)
        inc     hl
        inc     hl
        ld      (iy+4),h
        ld      (iy+3),l
        ld      de,495
        sbc     hl,de
        jp      nc,L9ed5
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        dec     a
        call    La13c
        and     (hl)
        jp      nz,L9ed5
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        inc     hl
        inc     hl
        sub     8
        call    La13c
        and     (hl)
        jp      nz,L9ed5
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        sub     10
        call    La13c
        and     (hl)
        jp      nz,L9ed5

.L9e92  ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,l
        and     3
        jp      nz,L9ebf
        ld      a,(iy+5)
        call    Lac82
        cp      8
        jr      nz,L9ebf                ; (23)
        bit     0,(iy+14)
        jr      z,L9ee5                 ; (55)
        ld      (iy+14),0
        ld      hl,55234
        ld      de,2061
        ld      a,26
        ld      b,17
        call    setlemgfx

.L9ebf  ld      a,(iy+5)
        cp      17
        jp      c,L9ee2
        call    L9c94
        ld      a,(iy+16)
        and     a
        jp      z,La107
        jp      L9999

.L9ed5  ld      a,(iy+0)
        and     224
        add     a,2
        ld      (iy+0),a
        jp      L9be2

.L9ee2  jp      Lad03

.L9ee5  ld      (iy+14),255
        ld      hl,54818
        ld      de,2061
        ld      a,26
        ld      b,17
        call    setlemgfx
        jr      L9ebf                   ; (-57)

.L9ef8  ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        dec     hl
        ld      (iy+4),h
        ld      (iy+3),l
        ld      de,10
        sbc     hl,de
        jp      c,L9ed5
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        dec     a
        call    La13c
        and     (hl)
        jp      nz,L9ed5
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        dec     hl
        dec     hl
        sub     8
        call    La13c
        and     (hl)
        jp      nz,L9ed5
        jp      L9e92

.L9f36  ld      a,(iy+12)
        cp      17
        jp      z,La016
        cp      16
        jp      z,L9f48
        cp      8
        jp      nz,L9999

.L9f48  bit     7,(iy+5)
        jp      nz,L9a9c
        ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        inc     (iy+5)
        bit     7,(iy+5)
        jp      nz,L9a9c
        ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        dec     hl
        push    hl
        push    af
        call    La13c
        and     (hl)
        jp      nz,La000
        pop     af
        pop     hl
        inc     hl
        inc     hl
        push    hl
        push    af
        call    La13c
        and     (hl)
        jp      nz,La000
        pop     af
        pop     hl
        inc     hl
        inc     hl
        push    hl
        push    af
        call    La13c
        and     (hl)
        jp      nz,La000
        pop     af
        pop     hl
        jp      Laada

.La000  pop     af
        pop     af
        ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        call    Lac82
        cp      7
        jp      z,Lad03
        jp      L9999

.La016  ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        inc     a
        ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        push    hl
        push    af
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        pop     af
        pop     hl
        inc     hl
        call    Lacce
        xor     255
        and     (hl)
        ld      (hl),a
        inc     (iy+5)
        inc     (iy+5)
        jp      L9999

.La107  inc     (iy+5)
        ld      a,(iy+0)
        and     224
        add     a,12
        ld      (iy+0),a
        ld      de,2058
        bit     0,(iy+14)
        jp      z,La12b
        ld      hl,55650

.La121  ld      a,20
        ld      b,9
        call    setlemgfx
        jp      L998d

.La12b  ld      hl,55810
        jp      La121

.La131  ld      a,(iy+12)
        cp      8
        jp      nz,L9999
        jp      Lad03

.La13c  ld      d,a
        ld      e,0
        srl     d
        rr      e
        srl     d
        rr      e
        ld      a,l
        and     7
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l
        add     hl,de
        ld      de,levdata
        add     hl,de
        ld      e,a
        ld      d,0
        ld      ix,L41320
        add     ix,de
        ld      a,(ix+0)
        ret     

.L41320
        defb    192,96,48,24,12,6,3,3


; Release a lemming


.La170  ld      a,(varbase+58)
        and     a
        ret     nz

        ld      a,(armagedset)
        cp      255
        ret     z

        ld      a,(varbase+25)
        ld      hl,total_lemmings
        cp      (hl)
        ret     z


.La184  ld      a,(varbase+36)
        cp      104
        ret     nz

        ld      a,255
        ld      (varbase+15),a
        ld      a,(varbase+59)
        ld      (varbase+36),a
        ld      hl,varbase+25
        inc     (hl)
        ld      hl,varbase+16
        inc     (hl)
        ld      hl,(varbase+32)
        push    hl
        pop     iy
        ld      (iy+0),1
        ld      (iy+19),0
        ld      hl,(levaddr+03)
        ld      de,(varbase+12)
        and     a
        sbc     hl,de
        jp      c,La207
        ld      a,h
        and     a
        jp      nz,La207
        ld      (iy+2),l
        ld      (iy+1),255

.La1d4  ld      (iy+14),255
        ld      a,(levaddr+03)
        ld      (iy+3),a
        ld      a,(levaddr+04)
        ld      (iy+4),a
        ld      a,(levaddr+05)
        ld      (iy+5),a
        ld      hl,53250
        ld      de,2058
        ld      b,5
        ld      a,20
        call    setlemgfx
        push    iy
        pop     hl
        ld      de,20
        add     hl,de
        ld      (varbase+32),hl
        ret     


.La207  ld      (iy+1),0
        jp      La1d4

.La20e  ld      iy,datatab1
        ld      a,(varbase+25)
        ld      hl,varbase+69
        add     a,(hl)
        add     a,6
        ld      b,a

.La21c  push    bc
        ld      a,(iy+0)
        and     a
        jp      z,La240
        cp      19
        jp      z,La2cb
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      e,(iy+6)
        ld      d,0
        sbc     hl,de
        ld      a,(iy+5)
        sub     (iy+7)
        call    La249

.La240  pop     bc
        ld      de,20
        add     iy,de
        djnz    La21c                   ; (-44)
        ret     


.La249  push    hl
        push    af
        ld      de,(varbase+12)
        sbc     hl,de
        jp      c,La273
        bit     0,h
        jr      nz,La270                ; (20)
        ld      b,l
        pop     af
        pop     hl
        ld      c,a
        ld      e,(iy+10)
        ld      d,(iy+11)
        ld      a,(iy+15)
        push    de
        pop     ix
        call    Lb80e
        ret     


.La270  pop     af
        pop     hl
        ret     


.La273  pop     af
        pop     hl
        push    hl
        push    af
        ld      de,8
        add     hl,de
        ld      de,(varbase+12)
        sbc     hl,de
        jp      c,La29f
        ld      a,l
        sub     8
        ld      b,a
        pop     af
        pop     hl
        ld      c,a
        ld      e,(iy+10)
        ld      d,(iy+11)
        ld      a,(iy+15)
        push    de
        pop     ix
        call    Lbab0
        ret     


.La29f  pop     af
        pop     hl
        push    hl
        push    af
        ld      de,16
        add     hl,de
        ld      de,(varbase+12)
        sbc     hl,de
        jp      c,La270
        ld      a,l
        sub     16
        ld      b,a
        pop     af
        pop     hl
        ld      c,a
        ld      e,(iy+10)
        ld      d,(iy+11)
        ld      a,(iy+15)
        push    de
        pop     ix
        call    Lba22
        ret     


.La2cb  ld      l,(iy+3)
        ld      h,(iy+4)
        ld      e,(iy+6)
        ld      d,0
        sbc     hl,de
        ld      de,16
        sbc     hl,de
        ld      a,(iy+5)
        sub     (iy+7)
        sub     16
        call    La301
        call    La301
        call    La301
        ld      de,48
        sbc     hl,de
        add     a,16
        call    La301
        call    La301
        call    La301
        jp      La240

.La301  push    hl
        push    af
        call    La249
        ld      l,(iy+10)
        ld      h,(iy+11)
        ld      de,32
        add     hl,de
        ld      (iy+10),l
        ld      (iy+11),h
        pop     af
        pop     hl
        ld      de,16
        add     hl,de
        ret     


.La31d  ld      a,(iy+12)
        dec     a
        and     15
        cp      10
        jp      nc,La3cd
        cp      4
        jp      nc,L9999
        push    af
        inc     a
        ex      af,af'
        ld      a,(iy+5)
        sub     (iy+7)
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      e,(iy+6)
        ld      d,0
        sbc     hl,de
        ld      b,9
        ex      af,af'
        push    iy
        bit     0,(iy+14)
        jr      z,La393                 ; (69)
        ld      iy,62400
        ld      de,18

.La355  add     iy,de
        dec     a
        jr      nz,La355                ; (-5)

.La35a  ex      af,af'
        inc     a
        call    Lbcfa
        pop     iy
        pop     af
        cp      3
        jp      nz,L9999
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        sub     6
        bit     0,(iy+14)
        jp      z,La3a6
        ld      de,8
        add     hl,de
        push    af
        push    hl
        call    La13c
        and     (hl)
        jp      nz,La3a1
        pop     hl
        pop     af
        inc     hl
        call    La13c
        and     (hl)
        jp      nz,L9999
        jp      Lad03

.La393  ld      iy,62472        ;Lf408
        ld      de,18

.La39a  add     iy,de
        dec     a
        jr      nz,La39a                ; (-5)
        jr      La35a                   ; (-71)

.La3a1  pop     hl
        pop     af
        jp      L9999

.La3a6  ld      de,8
        sbc     hl,de
        push    af
        push    hl
        call    La13c
        and     (hl)
        jp      nz,La3a1
        pop     hl
        pop     af
        dec     hl
        push    af
        push    hl
        call    La13c
        and     (hl)
        jp      nz,La3a1
        pop     hl
        pop     af
        dec     hl
        call    La13c
        and     (hl)
        jp      nz,L9999
        jp      Lad03

.La3cd  bit     0,(iy+14)
        jp      z,La431
        ld      l,(iy+3)
        ld      h,(iy+4)
        inc     hl
        ld      (iy+3),l
        ld      (iy+4),h
        push    hl
        call    L9c94
        pop     hl
        ld      de,496
        sbc     hl,de
        jp      c,La3fb
        ld      a,(iy+0)
        and     224
        add     a,2
        ld      (iy+0),a
        jp      L9be2

.La3fb  ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        ld      de,64
        push    af
        call    La13c
        and     (hl)
        jp      nz,L9998
        pop     af
        inc     (iy+5)
        add     hl,de
        push    af
        and     (hl)
        jp      nz,L9998
        pop     af
        inc     (iy+5)
        add     hl,de
        push    af
        and     (hl)
        jp      nz,L9998
        pop     af
        inc     (iy+5)
        add     hl,de
        push    af
        and     (hl)
        jp      nz,L9998
        pop     af
        jp      Laada

.La431  ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        ld      (iy+3),l
        ld      (iy+4),h
        push    hl
        call    L9c94
        pop     hl
        ld      de,10
        sbc     hl,de
        jp      nc,La3fb
        ld      a,(iy+0)
        and     224
        add     a,2
        ld      (iy+0),a
        jp      L9be2

.La458  ld      a,(varbase+30)
        bit     0,a
        jp      nz,La567
        ld      iy,(varbase+67)
        ld      a,(varbase+25)
        and     a
        ret     z

        ld      a,(varbase+29)
        bit     0,a
        ret     nz

        ld      a,(varbase+26)
        ld      b,a
        ld      a,(varbase+27)
        add     a,6
        ld      c,a
        exx     
        ld      a,(varbase+25)
        ld      b,a
        xor     a
        ld      (varbase+47),a
        ld      (varbase+46),a

.La486  push    bc
        ld      a,(iy+0)
        and     a
        jp      z,La4da
        bit     0,(iy+1)
        jp      z,La4da
        ld      a,(iy+2)
        sub     (iy+6)
        exx     
        ld      e,a
        sub     b
        jp      nc,La4d9
        ld      a,e
        add     a,8
        sub     b
        jp      c,La4d9
        ld      a,(iy+5)
        sub     (iy+7)
        ld      e,a
        sub     c
        jp      nc,La4d9
        ld      a,e
        add     a,12
        sub     c
        jp      c,La4d9
        exx     
        push    iy
        pop     hl
        ld      a,(iy+0)
        and     31
        cp      4
        jp      c,La53d
        ld      (varbase+40),hl
        ld      a,255
        ld      (varbase+46),a
        jp      La4da

.La4d9  exx     

.La4da  pop     bc
        ld      de,20
        add     iy,de
        djnz    La486                   ; (-92)
        ld      a,(varbase+46)
        bit     0,a
        jp      z,La505
        ld      a,(varbase+31)
        bit     0,a
        jp      nz,La4f7
        ld      a,1
        ld      (varbase+31),a

.La4f7  ld      hl,(varbase+40)
        push    hl
        pop     iy
        jp      prlemtype

.La505  ld      a,(varbase+47)
        bit     0,a
        jp      z,La54d
        ld      a,1
        ld      (varbase+31),a
        ld      hl,(varbase+38)
        push    hl
        pop     iy
        ld      a,(iy+0)
        and     192
        jp      nz,La688
        ld      bc,$2220      ;2,0
        ld      a,(iy+0)
        cp      1
        jp      z,fallermsg

.walkermsg  
        call    messag
        defm    "WALKER\x00"
        ret     


.La53d  ld      (varbase+38),hl
        ld      a,255
        ld      (varbase+47),a
        jp      La4da

.La54d  ld      a,(varbase+31)
        bit     0,a
        ret     z

        xor     a
        ld      (varbase+31),a
        ld      bc,$2220
        call    messag
        defm    "       \x00"
        ret     


.La567  ld      hl,(varbase+48)
        push    hl
        push    hl
        pop     iy
        call    prlemtype
        pop     iy
        ld      a,(iy+2)
        sub     (iy+6)

.La582  cp      240

.La584  jp      nc,La59d
        cp      10
        jp      c,La5a3
        inc     a
        inc     a
        inc     a
        inc     a
        ld      (varbase+26),a
        ld      a,(iy+5)
        sub     (iy+7)
        ld      (varbase+27),a
        ret     


.La59d  ld      a,2
        ld      (varbase+34),a
        ret     


.La5a3  ld      a,1
        ld      (varbase+34),a
        ret     


.cklockon  
        call    keys            ;KLUDGE
        bit     5,e
        ret     z

        ld      a,(varbase+30)
        bit     0,a
        ret     nz

        ld      a,(varbase+29)
        bit     0,a
        ret     nz

        ld      a,(varbase+31)
        bit     0,a
        ret     z

        ld      a,2
        ld      (plopcount),a
        ld      hl,varbase+02
        ld      (plopaddr),hl
        call    Lad2a   ;exits with hl=iy
;        push    iy
;        pop     hl
        ld      (varbase+48),hl
        ld      a,(iy+2)
        sub     (iy+6)
        add     a,4
        ld      (varbase+26),a
        ld      a,(iy+5)
        sub     (iy+7)
        ld      (varbase+27),a
        ld      a,255
        ld      (varbase+28),a
        ld      a,255
        ld      (varbase+30),a
        ret     

; Handlers selection?

.La600  
        ld      a,(varbase+29)
        bit     0,a
        ret     z

        xor     a
        ld      (varbase+29),a
        ld      a,(varbase+31)
        bit     0,a
        ret     z

        ld      a,(current_type)
        cp      4
        jp      z,La894
        cp      5
        jp      z,La80e
        cp      6
        jp      z,La925
        cp      9
        jp      z,La774
        cp      7
        jp      z,Labbc
        cp      8
        jp      z,La8bd
        cp      10
        jp      z,Laa40
        cp      11
        jp      z,La837
        ret     

; Print the type of lemming based on the contents of
; the table pointed to by iy (iy+0) = lem type

.prlemtype  
        ld      bc,$2220      ;2,0
        ld      a,(iy+0)
        and     192
        jp      nz,La688
        ld      a,(iy+0)
        and     31
        cp      1
        jp      z,fallermsg
        cp      2
        jp      z,walkermsg
        cp      3
        jp      z,walkermsg
        cp      7
        jp      z,blockermsg
        cp      9
        jp      z,bashermsg
        cp      11
        jp      z,diggermsg
        cp      8
        jp      z,climbermsg
        cp      12
        jp      z,buildermsg
        cp      15
        jp      z,walkermsg
        cp      16
        jp      z,walkermsg
        cp      19
        jp      z,bombermsg
        cp      14
        jp      z,fallermsg
        jp      minermsg

.La688  ld      bc,$2220
        cp      128
        jp      z,diggermsg
        cp      64
        jp      z,floatermsg
        call    messag
        defm    "ATHLETE\x00"
        ret     


.floatermsg  
        call    messag
        defm    "FLOATER\x00"
        ret     


.fallermsg  
        call    messag
        defm    "FALLER \x00"
        ret     


.blockermsg  
        call    messag
        defm    "BLOCKER\x00"
        ret     


.bashermsg  
        call    messag
        defm    "BASHER \x00"
        ret     


.diggermsg  
        call    messag
        defm    "DIGGER \x00"
        ret     


.climbermsg
        call    messag
        defm    "CLIMBER\x00"
        ret     

.buildermsg  
        call    messag
        defm    "BUILDER\x00"
        ret     


.minermsg  
        call    messag
        defm    "MINER  \x00"
        ret     


.bombermsg  
        call    messag
        defm    "BOMBER\x00"
        ret     

; Print the time remaining/


.prtime  
        ld      a,(timeprflag)
        rrca
        ret     nc
        xor     a
        ld      (timeprflag),a
        ld      bc,$223B      ;2,28
        call    doposn
        ld      a,(mins)
        add     a,48
        call    prchar1
        ld      a,':'
        call    prchar1
        ld      a,(sectens)
        add     a,47
        call    prchar1
        ld      a,(secunits)
        add     a,47
        call    prchar1
        ret     


.prlemsout  
        ld      a,(varbase+15)
        rrca
        ret     nc
        ld      bc,$222c      ;2,13
        ld      a,(varbase+16)
        call    numpri
        ret     


.prlemsin  
        ld      a,(varbase+56)
        rrca
        ret     nc
        ld      bc,$2232
        ld      a,(savedlemmings)
        call    numpri
        ret     


.La774  call    Lad2a
        ret     c

        ld      a,(iy+0)
        and     31
        cp      2
        jp      z,La794
        cp      12
        jp      z,La794
        cp      11
        jp      z,La794
        cp      10
        jp      z,La794
        cp      8
        ret     nz


.La794  ld      a,(num_bashers)
        and     a
        ret     z

        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        call    Lac82
        cp      7
        ret     z

        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        sub     6
        bit     0,(iy+14)
        jp      z,La7fd
        ld      de,8
        add     hl,de
        call    Lac82
        cp      7
        ret     z

        cp      5
        ret     z


.La7c8  ld      a,(iy+0)
        and     224
        add     a,9
        ld      (iy+0),a
        bit     0,(iy+14)
        jp      z,La7f7
        ld      hl,55970

.La7dc  ld      de,2058
        ld      a,20
        ld      b,33
        call    setlemgfx
        ld      a,(num_bashers)
        dec     a
        ld      (num_bashers),a
        ld      bc,$2433
        call    prselect
        call    setplop1
        ret     


.La7f7  ld      hl,56610
        jp      La7dc

.La7fd  ld      de,8
        sbc     hl,de
        call    Lac82
        cp      7
        ret     z

        cp      6
        ret     z

        jp      La7c8

.La80e  call    Lad2a
        ret     c

        ld      a,(iy+0)
        and     96
        ret     nz

        ld      a,(iy+0)
        and     31
        cp      7
        ret     z

        ld      a,(num_floaters)
        sub     1
        ret     c

        ld      (num_floaters),a
        set     6,(iy+0)
        ld      bc,$2428
        call    prselect
        call    setplop1
        ret     


.La837  call    Lad2a
        ret     c
        ld      a,(iy+0)
        and     31
        cp      2
        jp      z,La857
        cp      12
        jp      z,La857
        cp      10
        jp      z,La857
        cp      8
        jp      z,La857
        cp      9
        ret     nz
.La857  ld      a,(num_diggers)
        and     a
        ret     z
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        call    Lac82
        cp      7
        ret     z
        ld      a,(iy+0)
        and     224
        add     a,11
        ld      (iy+0),a
        ld      hl,57250
        ld      de,2060
        ld      a,28
        ld      b,17
        call    setlemgfx
        ld      a,(num_diggers)
        dec     a
        ld      (num_diggers),a
        ld      bc,$2439
        call    prselect
        call    setplop1
        ret     



.La894  
        call    Lad2a
        ret     c
        ld      a,(iy+0)
        and     160
        ret     nz
        ld      a,(iy+0)
        and     31
        cp      7
        ret     z
        ld      a,(num_climbers)
        sub     1
        ret     c
        ld      (num_climbers),a
        set     7,(iy+0)
        ld      bc,$2426
        call    prselect
        call    setplop1
        ret     


.La8bd  call    Lad2a
        ret     c
        ld      a,(iy+0)
        and     31
        cp      2
        jp      z,La8dd
        cp      12
        jp      z,La8dd
        cp      10
        jp      z,La8dd
        cp      11
        jp      z,La8dd
        cp      9
        ret     nz


.La8dd  ld      a,(num_builders)
        and     a
        ret     z

        ld      a,(iy+5)
        sub     (iy+7)
        cp      12
        ret     c

        ld      a,(iy+0)
        and     224
        add     a,8
        ld      (iy+0),a
        bit     0,(iy+14)
        jp      z,La91f
        ld      hl,54818

.La900  ld      (iy+16),12
        ld      de,2061
        ld      a,26
        ld      b,17
        call    setlemgfx
        ld      a,(num_builders)
        dec     a
        ld      (num_builders),a
        ld      bc,$2430
        call    prselect
        call    setplop1
        ret     


.La91f  ld      hl,55234
        jp      La900

.La925  call    Lad2a
        ret     c

        ld      a,(iy+0)
        and     31
        cp      16
        ret     z

        bit     5,(iy+0)
        ret     nz

        ld      a,(num_bombers)
        sub     1
        ret     c

        ld      (num_bombers),a
        set     5,(iy+0)
        ld      (iy+17),13
        ld      (iy+18),5
        ld      bc,$242B
        call    prselect
        call    setplop1
        ret     


.La955  dec     (iy+17)
        jp      nz,La965
        dec     (iy+18)
        jp      z,La992
        ld      (iy+17),13

.La965  bit     0,(iy+1)
        jp      z,L9929
        ld      b,(iy+2)
        ld      a,(iy+5)
        sub     (iy+7)
        sub     8
        jp      c,L9929
        ld      c,a
        ld      e,(iy+18)
        ld      d,0
        sla     e
        sla     e
        sla     e
        ld      ix,statnumbers
        add     ix,de
        call    sprite8x8
        jp      L9929

.La992  ld      a,(iy+0)
        cp      14
        jp      z,L9929
        and     31
        cp      1
        jp      z,La9f6
        cp      7
        call    z,La9c0
        ld      a,(iy+0)
        and     192
        add     a,16
        ld      (iy+0),a
        ld      hl,59506
        ld      de,2058
        ld      a,20
        ld      b,22
        call    setlemgfx
        ld      a,(armagedset)
        inc     a
        ld      a,4
        call    nz,sample
        jp      L9929

.La9c0  ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        push    hl
        push    af
        call    Lac82
        ld      a,0
        ld      (ix+0),a        ;,0
        pop     af
        pop     hl
        sub     4
        push    hl
        push    af
        call    Lac82
        ld      a,0
        ld      (ix+0),a
        pop     af
        pop     hl
        sub     4
        call    Lac82
        ld      a,0
        ld      (ix+0),a
        ret     


.La9ee  ld      a,(iy+12)
        cp      16
        jp      c,L9999

.La9f6  ld      (iy+0),19
        ld      hl,51930
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+12),1
        ld      (iy+15),192
        ld      (iy+13),6
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      e,(iy+6)
        ld      d,0
        sbc     hl,de
        ld      a,(iy+5)
        sub     (iy+7)
        push    iy
        ld      iy,62386
        ld      b,16
        call    Lbcfa
        pop     iy
        jp      L998d

.Laa32  ld      a,(iy+12)
        cp      5
        jp      z,L9a9c
        inc     (iy+12)
        jp      L998d

.Laa40  call    Lad2a
        ret     c

        ld      a,(iy+0)
        and     31
        cp      2
        jp      z,Laa60
        cp      12
        jp      z,Laa60
        cp      8
        jp      z,Laa60
        cp      11
        jp      z,Laa60
        cp      9
        ret     nz


.Laa60  ld      a,(num_miners)
        and     a
        ret     z

        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        call    Lac82
        cp      7
        ret     z

        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        sub     6
        bit     0,(iy+14)
        jp      z,Laac9
        ld      de,8
        add     hl,de
        call    Lac82
        cp      7
        ret     z

        cp      5
        ret     z


.Laa94  ld      a,(iy+0)
        and     224
        add     a,10
        ld      (iy+0),a
        bit     0,(iy+14)
        jp      z,Laac3
        ld      hl,53570

.Laaa8  ld      a,26
        ld      b,25
        ld      de,2061
        call    setlemgfx
        ld      a,(num_miners)
        dec     a
        ld      (num_miners),a
        ld      bc,$2436
        call    prselect
        call    setplop1
        ret     


.Laac3  ld      hl,54194
        jp      Laaa8

.Laac9  ld      de,8
        sbc     hl,de
        call    Lac82
        cp      7
        ret     z

        cp      6
        ret     z

        jp      Laa94

.Laada  ld      a,(iy+0)
        and     224
        add     a,1
        ld      (iy+0),a
        ld      a,(iy+14)
        and     a
        jp      z,Lab00
        ld      hl,53250

.Laaef  ld      (iy+19),4
        ld      de,2058
        ld      a,20
        ld      b,5
        call    setlemgfx
        jp      L998d

.Lab00  ld      hl,53330
        jp      Laaef

.Lab06  ld      a,(iy+0)
        and     224
        add     a,5
        ld      (iy+0),a
        inc     (iy+5)
        ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        call    La13c
        and     (hl)
        jp      nz,Lad03
        ld      a,(iy+5)
        cp      128
        jp      nc,L9a9c
        ld      a,(iy+12)
        cp      8
        jp      z,Lab36
        jp      L9999

.Lab36  ld      a,(iy+0)
        and     224
        add     a,17
        ld      (iy+0),a
        jp      Lab66

.Lab43  ld      a,(iy+12)
        cp      5
        jp      z,Lab06
        inc     (iy+5)
        ld      a,(iy+5)
        ld      l,(iy+3)
        ld      h,(iy+4)
        call    La13c
        and     (hl)
        jp      nz,Lad03
        ld      a,(iy+5)
        cp      128
        jp      nc,L9a9c

.Lab66  dec     (iy+12)
        ld      l,(iy+10)
        ld      h,(iy+11)
        xor     a
        ld      de,32
        sbc     hl,de
        ld      (iy+10),l
        ld      (iy+11),h
        jp      L998d

.Lab7e  pop     af
        ld      a,(iy+0)
        and     224
        add     a,3
        ld      (iy+0),a
        dec     (iy+5)
        dec     (iy+5)
        bit     0,(iy+14)
        jp      nz,Laba9
        ld      hl,53230
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+12),8
        call    L9c94
        jp      L998d

.Laba9  ld      hl,53050
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+12),8
        call    L9c94
        jp      L998d

.Labbc  call    Lad2a
        ret     c

        ld      a,(iy+0)
        and     31
        cp      2
        jp      z,Labe1
        cp      12
        jp      z,Labe1
        cp      10
        jp      z,Labe1
        cp      11
        jp      z,Labe1
        cp      9
        jp      z,Labe1
        cp      8
        ret     nz


.Labe1  ld      a,(num_blockers)
        and     a
        ret     z

        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        push    hl
        push    af
        call    Lac82
        cp      8
        jp      z,Lac7f
        cp      1
        jp      z,Lac7f
        pop     af
        pop     hl
        sub     4
        push    hl
        push    af
        call    Lac82
        cp      8
        jp      z,Lac7f
        cp      1
        jp      z,Lac7f
        pop     af
        pop     hl
        sub     4
        push    hl
        push    af
        call    Lac82
        cp      8
        jp      z,Lac7f
        cp      1
        jp      z,Lac7f
        pop     af
        pop     hl
        push    hl
        push    af
        call    Lac82
        ld      a,136
        and     (hl)
        or      (ix+0)
        ld      (ix+0),a
        pop     af
        pop     hl
        add     a,4
        push    hl
        push    af
        call    Lac82
        ld      a,136
        and     (hl)
        or      (ix+0)
        ld      (ix+0),a
        pop     af
        pop     hl
        add     a,4
        call    Lac82
        ld      a,136
        and     (hl)
        or      (ix+0)
        ld      (ix+0),a
        ld      a,(iy+0)
        and     224
        add     a,7
        ld      (iy+0),a
        ld      hl,53410
        ld      a,20
        ld      b,9
        ld      de,2058
        call    setlemgfx
        ld      a,(num_blockers)
        dec     a
        ld      (num_blockers),a
        ld      bc,$242E
        call    prselect
        call    setplop1
        ret     


.Lac7f  pop     hl
        pop     hl
        ret     

; Takes entry in a,l


.Lac82  ld      ix,varbase+71
        and     252     ;@11111100
        ld      e,a
        ld      d,0
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e       ;*16 - max=4032 bytes but...int @ 65021
        rl      d
        add     ix,de
        push    hl
        pop     de
        ld      a,l
        srl     d
        rr      e
        srl     d
        rr      e
        srl     d
        rr      e
        add     ix,de
        bit     2,a
        jr      nz,Lacc3                ; (17)
        ld      hl,L44236
        ld      a,(ix+0)
        and     240
        srl     a
        srl     a
        srl     a
        srl     a
        ret     


.Lacc3  ld      hl,L44236+1
        ld      a,(ix+0)
        and     15
        ret     
.L44236
        defb    240,15

;Huh?
;Entry: a=row? (char)
;       l=?
;       h=?


.Lacce  ld      d,a     ;x256
        ld      e,0
        srl     d       
        rr      e
        srl     d
        rr      e       ;x64
        ld      a,l
        and     7
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l       ;hl/8
        add     hl,de
        ld      de,levdata
        add     hl,de
        ld      e,a
        ld      d,0
        ld      ix,L44282
        add     ix,de
        ld      a,(ix+0)
        ret     

;44282
.L44282
        defb    128,64,32,16,8,4,2,1

.Lad02
        pop     af
.Lad03
        ld      a,(iy+0)
        and     224
        add     a,2
        ld      (iy+0),a
        bit     0,(iy+14)
        jp      z,Lad24
        ld      hl,52890

.Lad17  ld      de,2058
        ld      a,20
        ld      b,9
        call    setlemgfx
        jp      L998d

.Lad24  ld      hl,53070
        jp      Lad17

; Get current lemming?

.Lad2a  
        ld      a,(varbase+30)
        and     a
        jp      z,Lad40
        ld      hl,(varbase+48)
        push    hl
        pop     iy
        and     a       ;sub 0
        ret     


.Lad40  ld      a,(varbase+46)
        and     a
        jp      z,Lad56
        ld      hl,(varbase+40)
        push    hl
        pop     iy
        and     a       ;sub     0
        ret     


.Lad56  ld      a,(varbase+47)
        and     a
        scf     
        ret     z
        ld      hl,(varbase+38)
        push    hl
        pop     iy
        and     a       ;sub     0
        ret     


.setplop1  
        ld      a,2
        ld      (plopcount),a
        ld      hl,62794
        ld      (plopaddr),hl
        ret     

;Set the graphics for a lemming

.setlemgfx  
        ld      (iy+6),d
        ld      (iy+7),e
        ld      (iy+8),l
        ld      (iy+9),h
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+12),1
        ld      (iy+13),b
        ld      (iy+15),a
        ret     


.Lad99  ld      a,(iy+12)
        cp      24
        jp      z,Lae78
        cp      15
        jp      z,Ladf5
        cp      3
        jp      z,Lae85
        jp      nc,L9999
        ex      af,af'
        ld      a,(iy+5)
        sub     (iy+7)
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      e,(iy+6)
        ld      d,0
        sbc     hl,de
        ld      b,13
        ex      af,af'
        push    iy
        bit     0,(iy+14)
        jr      z,Lade4                 ; (23)
        ld      iy,62536
        ld      de,26

.Ladd4  add     iy,de
        dec     a
        jr      nz,Ladd4                ; (-5)
        inc     hl

.Ladda  ex      af,af'
        inc     a
        call    Lbcfa
        pop     iy
        jp      L9999

.Lade4  ld      iy,62588
        ld      de,26

.Ladeb  add     iy,de
        dec     a
        jr      nz,Ladeb                ; (-5)
        dec     hl
        dec     hl
        dec     hl
        jr      Ladda                   ; (-27)

.Ladf5  bit     0,(iy+14)
        jp      z,Lae28
        ld      l,(iy+3)
        ld      h,(iy+4)
        inc     hl
        inc     hl
        ld      (iy+3),l
        ld      (iy+4),h
        ld      de,496
        sbc     hl,de
        jp      nc,Lae92

.Lae12  call    L9c94
        ld      l,(iy+3)
        ld      h,(iy+4)
        ld      a,(iy+5)
        call    La13c
        and     (hl)
        jp      z,Laada
        jp      L9999

.Lae28  ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        dec     hl
        ld      (iy+3),l
        ld      (iy+4),h
        ld      de,10
        sbc     hl,de
        jp      c,Lae92
        jp      Lae12
        bit     0,(iy+14)
        jp      z,Lae60
        ld      l,(iy+3)
        ld      h,(iy+4)
        inc     hl
        ld      (iy+3),l
        ld      (iy+4),h
        ld      de,496
        sbc     hl,de
        jp      nc,Lae92
        jp      Lae12

.Lae60  ld      l,(iy+3)
        ld      h,(iy+4)
        dec     hl
        ld      (iy+3),l
        ld      (iy+4),h
        ld      de,10
        sbc     hl,de
        jp      c,Lae92
        jp      Lae12

.Lae78  inc     (iy+5)
        bit     7,(iy+5)
        jp      nz,L9a9c
        jp      L9999

.Lae85  inc     (iy+5)
        bit     7,(iy+5)
        jp      nz,L9a9c
        jp      Ladf5
  
.Lae92  ld      a,(iy+0)
        and     224
        add     a,2
        ld      (iy+0),a
        jp      L9be2

; Makes a plopping sound when a thang selected (48k mode)

.plop   
        ld      a,l
        srl     l
        srl     l
        cpl     
        and     3
        ld      c,a
        ld      b,0
        ld      ix,plopplace
        add     ix,bc
        ld      a,($4B0)
        and     63
.plopplace
        nop     
        nop     
        nop     
        inc     b
        inc     c
.Laebe  dec     c
        jr      nz,Laebe                ; (-3)
        ld      c,63
        dec     b
        jp      nz,Laebe
        xor     64
        out     ($B0),a
        ld      b,h
        ld      c,a
        bit     6,a
        jr      nz,Laed9                ; (8)
        ld      a,d
        or      e
        ret     z
        ld      a,c
        ld      c,l
        dec     de
        jp      (ix)
.Laed9  ld      c,l
        inc     c
        jp      (ix)


; Called instead of 128k music..

.driveplop  
        ld      a,(plopcount)
        and     a
        ret     z
        call    sndcheck
        ret     nz
        ld      iy,(plopaddr)
        ld      a,(iy+0)
        ld      h,(iy+1)
        ld      e,(iy+2)
        ld      d,(iy+3)
        cp      255
        jr      nz,driveplop1
        cp      h
        jr      nz,driveplop1
        jr      driveplop2

.driveplop1
        ld      l,a
        call    plop
.driveplop2
        inc     iy
        inc     iy
        inc     iy
        inc     iy
        ld      (plopaddr),iy
        ld      hl,plopcount
        dec     (hl)
        ret     


.dokeyselectors  
        ld      a,(armagedset)
        cp      255
        call    z,Lb137
        call    kfind
        ld      a,d
        ret     nz      ;multiple keys pressed
        inc     d
        ret     z       ;no key pressed
        cp      18     ; '1'
        jp      z,decreaserate
        cp      19     ; '2'
        jp      z,increaserate
        cp      20     ; '3'
        jp      z,sel_climber
        cp      21     ; '4'
        jp      z,sel_floater
        cp      22     ; '5'
        jp      z,sel_bomber
        cp      23      ; '6'
        jp      z,sel_blocker
        cp      55      ; '7'
        jp      z,sel_builder
        cp      63      ; '8'
        jp      z,sel_basher
        cp      60      ; '9'
        jp      z,sel_miner
        cp      58      ; '0'
        jp      z,sel_digger
        cp      41      ; '<' was L
        jp      z,set_lscroll
        cp      40      ; '>' was ENTER
        jp      z,set_rscroll
        cp      42
        jp      z,sel_down
        cp      43
        jp      z,sel_up
;pkeys:       0 = R,L,U,D,F, lock on, pause, armageddon

        call    keys
        bit     6,e
        jp      nz,pause
        bit     7,e
        jp      nz,armageddon
        ret     


; Scroll the screen left and right (well, set flags to!)

.set_lscroll  
        ld      hl,varbase+34
        set     0,(hl)
        ret     


.set_rscroll  
        ld      hl,varbase+34
        set     1,(hl)
        ret     


.sel_up  
        ld      a,(current_type)
        cp      4
        jp      z,sel_floater
        cp      5
        jp      z,sel_bomber
        cp      6
        jp      z,sel_blocker
        cp      7
        cp      8
        jp      z,sel_basher
        cp      9
        jp      z,sel_miner
        cp      10
        jp      z,sel_digger
        jp      sel_climber

.sel_down  
        ld      a,(current_type)
        cp      4
        jp      z,sel_digger
        cp      5
        jp      z,sel_climber
        cp      6
        jp      z,sel_floater
        cp      7
        jp      z,sel_bomber
        cp      8
        jp      z,sel_blocker
        cp      9
        jp      z,sel_builder
        cp      10
        jp      z,sel_basher
        jp      sel_miner

;Faffing around with decrementing the release rate

.decreaserate  
        ld      a,(varbase+59)
        dec     a
        dec     a
        ld      hl,release_rate
        cp      (hl)            ;check if lower, if so set to default
        jp      c,Lb03f
        cp      255
        jp      z,Lb03f
.Lb028  ld      (varbase+59),a
        ld      b,a
        ld      a,(varbase+36)
        sub     b
        jp      nc,Lb037
        ld      a,b
        ld      (varbase+36),a
.Lb037  ld      a,b
        ld      bc,$2420
        call    prstatusnum
        ret     

.Lb03f  ld      a,(hl)
        jp      Lb028

; Incrementing the release rate

.increaserate  
        ld      a,(varbase+59)
        inc     a
        inc     a
        cp      100
        jp      c,Lb028

;        jp      nc,Lb051
;        jp      Lb028
;        ret     

.Lb051  ld      a,99
        jp      Lb028


;Select climber

.sel_climber  
        call    mkunsel_icon
        ld      a,4
        ld      (current_type),a
        call    mksel_icon
        ret     

;Select floater

.sel_floater  
        call    mkunsel_icon
        ld      a,5
        ld      (current_type),a
        call    mksel_icon
        ret     

;Select bomber

.sel_bomber  
        call    mkunsel_icon
        ld      a,6
        ld      (current_type),a
        call    mksel_icon
        ret     


.sel_basher  
        call    mkunsel_icon
        ld      a,9
        ld      (current_type),a
        call    mksel_icon
        ret     


.sel_blocker  
        call    mkunsel_icon
        ld      a,7
        ld      (current_type),a
        call    mksel_icon
        ret     


.sel_builder  
        call    mkunsel_icon
        ld      a,8
        ld      (current_type),a
        call    mksel_icon
        ret     


.sel_miner  
        call    mkunsel_icon
        ld      a,10
        ld      (current_type),a
        call    mksel_icon
        ret     


.sel_digger  
        call    mkunsel_icon
        ld      a,11
        ld      (current_type),a
        call    mksel_icon
        ret     

;These two routine handle the attribute selection thing - i.e
;changing the colour to red/whatever..

;Unselected icon
.mkunsel_icon  
        call    getposn_r
        push    bc
        ld      a,normal_attr
        call    jimmyattr
        pop     bc
        inc     c
        ld      a,normal_attr
        jp      jimmyattr

;Selected icon
.mksel_icon  
        call    getposn_r
        push    bc
        ld      a,inv_attr
        call    jimmyattr
        pop     bc
        inc     c
        ld      a,inv_attr
        jp      jimmyattr

; Get the position of the text for selecting
.getposn_r
        ld      a,(current_type)
        sub     4
        ld      l,a
        ld      h,0
        ld      de,getposn_t
        add     hl,de
        ld      c,(hl)  ;col
        ld      b,5     ;row
        ret


;Table to get the x position of counters...
; 18=start, we are given a number 4-13 (which we sub 4 from)
.getposn_t
        defb    24,26,29
        defb    32,34,37
        defb    40,43



;--- Pause loop ---


.pause
        call    keys            ;wait for let go of space
        bit     6,e
        jr      nz,pause
        ld      bc,$243B
        call    messag
        defb    1,'F',1,'R',32,32,1,'R',1,'F',0
.pause2
        call    ozread
        call    keys
        bit     6,e
        jr      z,pause2
        ld      bc,$243B
        call    messag
        defb    32,32,0
        ret


;--- END OF PAUSE ---


; --- ARMAGEDDON!!!!! -----

.armageddon  
        ld      a,(armagedset)
        cp      255
        ret     z
        ld      bc,$243D
        call    messag
        defb    1,'F',1,'T'
        defm    "!!!"
        defb    1,'F',1,'T',0
        ld      a,(varbase+16)
        ld      (varbase+18),a
        ld      a,255
        ld      (armagedset),a
        ld      ix,(varbase+67)
        ld      (varbase+61),ix
        ld      a,(varbase+25)
        ld      (varbase+63),a
        jp      setplop1

; --- END OF ARMAGEDDON ----


.Lb137  ld      a,(varbase+63)
        and     a
        ret     z

        dec     a
        ld      (varbase+63),a
        ld      hl,(varbase+61)
;        ld      a,(varbase+61)
;        ld      l,a
;        ld      a,(varbase+62)
;        ld      h,a
        push    hl
        pop     iy
        ld      a,(iy+0)
        and     31
        and     a
        jr      z,Lb16b                 ; (22)
        cp      16
        jr      z,Lb16b                 ; (18)
        bit     5,(iy+0)
        jr      nz,Lb16b                ; (12)
        set     5,(iy+0)
        ld      (iy+17),13
        ld      (iy+18),5

.Lb16b  ld      de,20
        add     iy,de
        push    iy
        pop     hl
        ld      (varbase+61),hl
;        ld      a,l
;        ld      (varbase+61),a
;        ld      a,h
;        ld      (varbase+62),a
        ret     


.previewlevel  
        ld      a,255
        ld      (varbase+51),a
;        xor     a
;        ld      hl,22528
;        ld      de,22529
;        ld      bc,127
;        ld      (hl),a
;        ldir    
        ld      bc,$6000        ;96,0
        ld      hl,levdata
        exx     
        ld      b,32

.Lb198  exx     
        ld      a,64

.Lb19b  ex      af,af'
        ld      a,(hl)
        and     a
        call    nz,Lb2b9
        inc     hl
        ex      af,af'
        inc     b
        dec     a
        jr      nz,Lb19b                ; (-13)
        ld      de,192
        add     hl,de
        ld      b,96
        inc     c
        exx     
        djnz    Lb198                   ; (-26)

;This bit of code prints the mini home and goal sprites

        ld      bc,$6000
        ld      a,(varbase+11)
        add     a,b
        ld      b,a
        ld      a,(levaddr+05)
        srl     a
        srl     a
        ld      c,a
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        ld      ix,unktable+1
        push    bc
        call    sprline16384
        pop     bc
        inc     c
        inc     ix
        call    sprline16384
        ld      bc,24576
        ld      a,(levaddr+17)
        ld      l,a
        ld      a,(levaddr+18)
        ld      h,a
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l
        ld      a,l
        add     a,b
        ld      b,a
        ld      a,(levaddr+19)
        srl     a
        srl     a
        inc     a
        inc     a
        inc     a
        inc     a
        ld      c,a
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        ld      ix,unktable+3
        push    bc
        call    sprline16384
        pop     bc
        inc     c
        inc     ix
        push    bc
        call    sprline16384
        pop     bc
        inc     c
        inc     ix
        push    bc
        call    sprline16384
        pop     bc
        inc     c
        inc     ix
        call    sprline16384
;Print the lemmings logos either side of the minimap
        ld      iy,lemmingslogo
        push    iy
        ld      bc,$0000
        exx     
        ld      b,8
        call    dumpudgrow
        pop     iy
        ld      bc,$0018
        exx     
        ld      b,8
        call    dumpudgrow
        ld      iy,lemmingslogo+256
        push    iy
        ld      bc,$0100
        exx     
        ld      b,8
        call    dumpudgrow
        pop     iy
        ld      bc,$0118
        exx     
        ld      b,8
        call    dumpudgrow
        ld      iy,lemmingslogo+512
        push    iy
        ld      bc,$0200
        exx     
        ld      b,8
        call    dumpudgrow
        pop     iy
        ld      bc,$0218
        exx     
        ld      b,8
        call    dumpudgrow
        ret


.Lb2b9  ex      af,af'
        push    af
        push    hl
        push    bc
        ld      a,b
        srl     a
        srl     a
        srl     a
        ld      (table1st),a
        ld      ix,unktable
        call    sprline16384
        pop     bc
        pop     hl
        pop     af
        ex      af,af'
        ret     

;45779
.unktable
        defb    128,112,136
        defb    136,112,80,112




; ----- START OF SPRITE ROUTINES -----

        INCLUDE "sprite.inc"    ; File is too large otherwise!

; ----- END OF SPRITE ROUTINES!! -------

; seems to copy the current map to a back screen @ 31805-35900
; so as to work on it?

.copymap  
        ld      d,0
        ld      a,(scrxpos)
        ld      e,a
        ld      hl,levdata
        add     hl,de
        ld      de,screen
        ld      b,8
.Lc36c  push    bc
        push    hl
        ld      a,8
        ld      b,0
.Lc372  push    hl
        ld      c,32
        ldir    
        pop     hl
        inc     h
        inc     h
        dec     a
        jr      nz,Lc372                ; (-11)
        pop     hl
        pop     bc
        push    de
        ld      de,64
        add     hl,de
        pop     de
        djnz    Lc36c                   ; (-27)

        ld      b,0
        ld      a,(scrxpos)
        ld      c,a
        ld      hl,levdata+4096
        add     hl,bc
        ld      b,8
.Lc395  push    bc
        push    hl
        ld      a,8
        ld      b,0
.Lc39b  push    hl
        ld      c,32
        ldir    
        pop     hl
        inc     h
        inc     h
        dec     a
        jr      nz,Lc39b                ; (-11)
        pop     hl
        pop     bc
        push    de
        ld      de,64
        add     hl,de
        pop     de
        djnz    Lc395                   ; (-27)
        ret     

; Copy the back screen to the front screen
; Goes up the bloody screen! Must be to avoid raster!


.scrcopy  
        ld      (copy_spstor),sp
        ld      (copy_ixstor),ix
        ld      (copy_iystor),iy
        ld      a,0

.Lc3bf  ld      sp,(copy_ixstor)
        exx     
        pop     hl
        pop     de
        pop     bc
        exx     
        pop     hl
        pop     de
        pop     bc
        pop     ix
        pop     iy
        ld      sp,(copy_iystor)
        push    iy
        push    ix
        push    bc
        push    de
        push    hl
        exx     
        push    bc
        push    de
        push    hl
        ld      hl,(copy_ixstor)
        ld      de,16
        sbc     hl,de
        ld      (copy_ixstor),hl
        ld      hl,(copy_iystor)
        sbc     hl,de
        ld      (copy_iystor),hl
        inc     a
        jp      nz,Lc3bf
        ld      sp,(copy_spstor)
        ret     


.Lc400  ld      hl,varbase+71
        ld      de,varbase+72
        ld      bc,2047
        ld      (hl),0
        ldir    
        ld      hl,datatab1
        ld      a,(total_lemmings)
        ld      (varbase+18),a
        ld      b,30
        ld      de,20
.Lc41b  ld      (hl),0
        add     hl,de
        djnz    Lc41b                   ; (-5)
        xor     a
        ld      (varbase+69),a
        ld      iy,datatab1+120
        ld      (varbase+67),iy
        ld      iy,levaddr+53
        ld      b,40

.Lc432  ld      a,(iy+0)
        and     a
        jr      z,setupleveldata                 ; (119)
        cp      4
        jr      z,Lc45e                 ; (33)
        push    af
        ld      l,(iy+1)
        ld      h,(iy+2)
        ld      a,(iy+3)
        call    Lac82
        pop     af
        and     (hl)
        or      (ix+0)
        ld      (ix+0),a

.Lc452  inc     iy
        inc     iy
        inc     iy
        inc     iy
        djnz    Lc432                   ; (-42)
        jr      setupleveldata                   ; (82)

.Lc45e  push    bc
        ld      ix,(varbase+67)
        ld      (ix+0),18
        ld      (ix+1),0
        ld      (ix+6),0
        ld      (ix+7),0
        ld      (ix+15),32
        ld      (ix+13),5
        ld      (ix+12),1
        ld      hl,62666
        ld      (ix+10),l
        ld      (ix+11),h
        ld      (ix+8),l
        ld      (ix+9),h
        ld      l,(iy+1)
        ld      h,(iy+2)
        ld      (ix+3),l
        ld      (ix+4),h
        ld      a,(iy+3)
        ld      (ix+5),a
        ld      de,20
        add     ix,de
        ld      (varbase+67),ix
        pop     bc
        ld      hl,varbase+69
        inc     (hl)
        jr      Lc452                   ; (-94)

.setupleveldata  
        ld      a,(levaddr+03)
        ld      l,a
        ld      a,(levaddr+04)
        ld      h,a
        srl     h
        rr      l
        srl     h
        rr      l
        srl     h
        rr      l
        ld      a,l
        ld      (varbase+11),a
        ld      a,(time_allowed)
        ld      (mins),a
        ld      a,10
        ld      (secunits),a
        ld      a,6
        ld      (sectens),a
        ld      a,14
        ld      (subsecs),a
; Take posn of top left *8 and store in 62812
        ld      a,(varbase+14)
        ld      (scrxpos),a
        ld      e,a
        ld      d,0
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        ld      a,e
        ld      (varbase+12),a
        ld      a,d
        ld      (varbase+13),a
        ld      a,(release_rate)
        ld      (varbase+59),a
        ld      a,95
        ld      (varbase+36),a
        ld      a,128
        ld      (varbase+26),a
        srl     a
        ld      (varbase+27),a
        xor     a
        ld      (gameon),a
        ld      (varbase+56),a
        ld      (plopcount),a
        ld      (varbase+51),a
        ld      (varbase+28),a
        ld      (varbase+29),a
        ld      (varbase+30),a
        ld      (varbase+31),a
        ld      (varbase+34),a
        ld      (varbase+35),a
        ld      (varbase+16),a
        ld      (savedlemmings),a
        ld      (varbase+25),a
        ld      (varbase+44),a
        ld      (varbase+45),a
        ld      (varbase+42),a
        ld      (varbase+43),a
        ld      (varbase+15),a
        ld      (timeprflag),a
        ld      (varbase+49),a
        ld      (varbase+48),a
        ld      (armagedset),a
        ld      iy,(varbase+67)
        ld      (varbase+32),iy
        ld      a,255
        ld      (attr),a
        ld      a,14
        ld      (varbase+58),a
        ld      a,4
        ld      (current_type),a
        ld      iy,datatab1
        ld      (iy+0),18
        ld      (iy+6),0
        ld      (iy+7),0
        ld      (iy+1),0
        ld      hl,61618
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+15),32
        ld      hl,(levaddr+03)
        ld      de,16
        sbc     hl,de
        ld      (iy+3),l
        ld      (iy+4),h
        ld      a,(levaddr+05)
        sub     12
        ld      (iy+5),a
        ld      de,20
        add     iy,de
        ld      (iy+0),18
        ld      (iy+6),0
        ld      (iy+7),0
        ld      (iy+1),0
        ld      hl,61650
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+15),32
        ld      hl,(levaddr+03)
        ld      (iy+3),l
        ld      (iy+4),h
        ld      a,(levaddr+05)
        sub     12
        ld      (iy+5),a
        add     iy,de
        ld      (iy+0),18
        ld      (iy+6),0
        ld      (iy+7),0
        ld      (iy+1),0
        ld      hl,61938
        ld      (iy+8),l
        ld      (iy+9),h
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+15),32
        ld      (iy+13),7
        ld      (iy+12),1
        ld      hl,(levaddr+17)
        ld      (iy+3),l
        ld      (iy+4),h
        ld      a,(levaddr+19)
        ld      (iy+5),a
        add     iy,de
        ld      (iy+0),18
        ld      (iy+6),0
        ld      (iy+7),0
        ld      (iy+1),0
        ld      hl,61970
        ld      (iy+8),l
        ld      (iy+9),h
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+15),32
        ld      (iy+13),7
        ld      (iy+12),1
        ld      hl,(levaddr+17)
        ld      bc,16
        add     hl,bc
        ld      (iy+3),l
        ld      (iy+4),h
        ld      a,(levaddr+19)
        ld      (iy+5),a
        add     iy,de
        ld      (iy+0),18
        ld      (iy+6),0
        ld      (iy+7),0
        ld      (iy+1),0
        ld      hl,62322
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+15),32
        ld      (iy+12),1
        ld      hl,(levaddr+17)
        ld      (iy+3),l
        ld      (iy+4),h
        ld      a,(levaddr+19)
        add     a,16
        ld      (iy+5),a
        add     iy,de
        ld      (iy+0),18
        ld      (iy+6),0
        ld      (iy+7),0
        ld      (iy+1),0
        ld      hl,62354
        ld      (iy+10),l
        ld      (iy+11),h
        ld      (iy+15),32
        ld      (iy+12),1
        ld      hl,(levaddr+17)
        ld      bc,16
        add     hl,bc
        ld      (iy+3),l
        ld      (iy+4),h
        ld      a,(levaddr+19)
        add     a,16
        ld      (iy+5),a
        ld      hl,(levaddr+17)
        ld      a,(levaddr+19)
        ld      de,16
        add     hl,de
        add     a,26
        call    Lac82
        ld      a,17
        and     (hl)
        or      (ix+0)
        ld      (ix+0),a
        ret     

;Convert xy in b,c to screen address
;In:  b=line c=column
;Out: hl=screen address

.xypos  ld      a,b
        and     248
        add     a,32    ;CHANGED!
        ld      h,a
        ld      a,b
        and     7
        rrca    
        rrca    
        rrca    
        add     a,c
        ld      l,a
        ret     

; Print character to screen
; Entry:
; b=row, c=column
; iy points to UDG thing

.prudg  call    xypos
        ld      a,(iy+0)
        ld      (hl),a
        inc     h
        ld      a,(iy+1)
        ld      (hl),a
        inc     h
        ld      a,(iy+2)
        ld      (hl),a
        inc     h
        ld      a,(iy+3)
        ld      (hl),a
        inc     h
        ld      a,(iy+4)
        ld      (hl),a
        inc     h
        ld      a,(iy+5)
        ld      (hl),a
        inc     h
        ld      a,(iy+6)
        ld      (hl),a
        inc     h
        ld      a,(iy+7)
        ld      (hl),a
        ret     


; Print out b udgs at location bc' from address iy

.dumpudgrow  
        exx     
        call    prudg
        ld      de,8
        add     iy,de
        inc     c
        exx     
        djnz    dumpudgrow                   ; (-13)
        ret     

;Called on interrupt - fixing for zed

.dokeyboard  
        call    keys    ;returns in e
        bit     4,e     ;fire
        jr      z,Lc7c7
;Select pressed
.Lc7c2  ld      a,255
        ld      (varbase+29),a

.Lc7c7  ld      a,(varbase+30)
        bit     0,a
        jp      nz,Lc98c
        bit     3,e
        jr      z,Lc82b

.Lc7ea  ld      a,(varbase+42)
        bit     0,a
        jr      nz,Lc821                ; (48)
        ld      a,1
        ld      (varbase+42),a
        xor     a
        ld      (varbase+43),a

.Lc7fa  ld      a,(varbase+27)
        and     a
        jp      z,Lc891
        dec     a
        ld      (varbase+27),a
        ld      a,1
        ld      (varbase+28),a
        ld      a,(varbase+43)
        bit     2,a
        jp      z,Lc891
        ld      a,(varbase+27)
        cp      8
        jr      c,Lc891                 ; (119)
        sub     8
        ld      (varbase+27),a
        jr      Lc891                   ; (112)

.Lc821  ld      hl,varbase+43
        bit     2,(hl)
        jr      nz,Lc7fa                ; (-46)
        inc     (hl)
        jr      Lc7fa                   ; (-49)

.Lc82b  
        bit     2,e
        jr      z,Lc88d                 ; (82)

.Lc847  ld      a,(varbase+42)
        bit     1,a
        jp      nz,Lc881
        ld      a,2
        ld      (varbase+42),a
        xor     a
        ld      (varbase+43),a

.Lc858  ld      a,(varbase+27)
        cp      120
        jp      nc,Lc891
        inc     a
        ld      (varbase+27),a
        ld      a,1
        ld      (varbase+28),a
        ld      a,(varbase+43)
        bit     2,a
        jp      z,Lc891
        ld      a,(varbase+27)
        cp      113
        jp      nc,Lc891
        add     a,8
        ld      (varbase+27),a
        jp      Lc891

.Lc881  ld      hl,varbase+43
        bit     2,(hl)
        jp      nz,Lc858
        inc     (hl)
        jp      Lc858

.Lc88d  xor     a
        ld      (varbase+42),a

.Lc891  
        bit     0,e     ; L
        jr      z,Lc8ef                 ; (78)

.Lc8ad  ld      a,(varbase+44)
        bit     0,a
        jp      nz,Lc8e3
        ld      a,1
        ld      (varbase+44),a
        xor     a
        ld      (varbase+45),a

.Lc8be  ld      a,(varbase+26)
        cp      248
        jp      z,Lc960
        inc     a
        ld      (varbase+26),a
        ld      a,1
        ld      (varbase+28),a

.Lc8cf  ld      a,(varbase+45)
        bit     2,a
        ret     z

        ld      a,(varbase+26)
        cp      241
        jp      nc,Lc97d
        add     a,8
        ld      (varbase+26),a
        ret     


.Lc8e3  ld      hl,varbase+45
        bit     2,(hl)
        jp      nz,Lc8be
        inc     (hl)
        jp      Lc8be

.Lc8ef  
        bit     1,e     ;R
        jr      z,Lc94d                 ; (78)

.Lc90b  ld      a,(varbase+44)
        bit     1,a
        jp      nz,Lc941
        ld      a,2
        ld      (varbase+44),a
        xor     a
        ld      (varbase+45),a

.Lc91c  ld      a,(varbase+26)
        and     a
        jp      z,Lc952
        dec     a
        ld      (varbase+26),a
        ld      a,1
        ld      (varbase+28),a

.Lc92d  ld      a,(varbase+45)
        bit     2,a
        ret     z

        ld      a,(varbase+26)
        cp      9
        jp      c,Lc96e
        sub     8
        ld      (varbase+26),a
        ret     


.Lc941  ld      hl,varbase+45
        bit     2,(hl)
        jp      nz,Lc91c
        inc     (hl)
        jp      Lc91c

.Lc94d  xor     a
        ld      (varbase+44),a
        ret     


.Lc952  ld      a,(varbase+27)
        cp      125
        ret     nc

        ld      a,1
        ld      (varbase+34),a
        jp      Lc92d

.Lc960  ld      a,(varbase+27)
        cp      125
        ret     nc

        ld      a,2
        ld      (varbase+34),a
        jp      Lc8cf

.Lc96e  ld      a,(varbase+27)
        cp      125
        ret     nc

        ld      a,1
        ld      (varbase+34),a
        ld      (varbase+35),a
        ret     


.Lc97d  ld      a,(varbase+27)
        cp      125
        ret     nc

        ld      a,2
        ld      (varbase+34),a
        ld      (varbase+35),a
        ret     


.Lc98c  
        bit     0,e     ;R
        jr      nz,Lc9bf                ; (-31)
        bit     1,e     ;L
        jr      nz,Lc9ce                ; (-20)
        bit     2,e     ;D
        jr      nz,Lc9ae                ; (-56)
        bit     3,e     ;U
        ret     z


.Lc99d  xor     a
        ld      (varbase+30),a
        jp      dokeyboard


.Lc9ae  xor     a
        ld      (varbase+30),a
        jp      Lc82b


.Lc9bf  xor     a
        ld      (varbase+30),a
        jp      Lc891


.Lc9ce  xor     a
        ld      (varbase+30),a
        jp      Lc8ef

; Print the pointer on the screen with its mask

.prpointer  
        ld      a,(varbase+26)  ; gotta be x pos
        ld      b,a
        ld      a,(varbase+27)  ; gotta b y pos
        ld      c,a
        ld      hl,varbase+31   ; locked on?
        bit     0,(hl)
        jp      nz,Lca0c
        push    bc
        ld      ix,utable
        call    mask8x8
        pop     bc
        ld      ix,utable+8
        call    sprite8x8
        ret     


.Lca0c  push    bc
        ld      ix,utable+24
        call    mask8x8
        pop     bc
        ld      ix,utable+16
        call    sprite8x8
        ret     

; This is the mask and sprite for the pointer
; One set is locked on and other is floating
.utable
        defb    195,195,0,0,0,0,195,195
        defb    0,24,24,126,126,24,24,0
        defb    0,126,102,0,0,102,126,0
        defb    0,0,0,60,60,0,0,0

; Do the timer countdown we have 14 ticks per second?
; So we're only running at 14fps? We are called on int
; after all!

.dotimer  
        ld      a,(subsecs)
        dec     a
        jr      nz,Lca74                ; (49)
        ld      a,255
        ld      (timeprflag),a
        ld      a,10
        ld      (subsecs),a
        ld      a,(secunits)
        dec     a
        jr      nz,Lca70                ; (29)
        ld      a,10
        ld      (secunits),a
        ld      a,(sectens)
        dec     a
        jr      nz,Lca78                ; (26)
        ld      a,6
        ld      (sectens),a
        ld      a,(mins)
        and     a
        jp      z,Lca7c
        dec     a
        ld      (mins),a
        ret     
.Lca70  ld      (secunits),a
        ret     
.Lca74  ld      (subsecs),a
        ret     
.Lca78  ld      (sectens),a
        ret     

.Lca7c  ld      a,1
        ld      (secunits),a
        ld      (sectens),a
        ld      a,(attr)
        cp      255
        ret     nz
        ld      a,5
        ld      (attr),a
        ret     

; Interrupt Routine..

.interrupt_routine
        call    prpointer
        call    ozscrcpy
        call    dokeyboard
        call    ozread
        call    dotimer
        call    driveplop
        ld      hl,varbase+36
        ld      a,(hl)
        cp      104
        ret     z
        inc     (hl)
        ret


;Check to see if sound is working...


.cksound
     ld   de,fbuffer
     ld   bc,pa_snd
     ld   a,1
     call_oz(os_nq)
     ld   hl,myflags
     res  0,(hl)
     ld   a,(fbuffer)
     cp   'N'
     ret  nz
     set  0,(hl)
     ret

; Play a sample
;
; Entry: a = sample to play (2/4)

.sample
        call    sndcheck
        ret     nz
        bit     2,(hl)
        ret     nz      ;checksample
        jp      sampleplay

.sndcheck
        ld      hl,myflags
        bit     0,(hl)  ;check global sound
        ret





;Default data copied down to 23632

.defaultdata
            defm  "LEMLEVEL.xx\x00"
            defb  59,61,34,26,10,51,39,16
            ;     P,O,A,Q,[space],M,H,ESC

.enddefault





;pkeys
;       0 = R,L,U,D,F, lock on, pause, armageddon
