;
;     Lemmings Z88
;
;     djm 25/11/99


IF comp_game
        XDEF    screen
        XDEF    varbase
        XDEF    l_errlevel
        XDEF    l_erraddr
        XDEF    ozbank
        XDEF    ozaddr
        XDEF    pkeys
        XDEF    myflags
ENDIF


; Memory setup

        defc    level_len       = 8405
        defc    lastlevel       = 60

; Defns for OZ

        defc    screen          = 8192
        defc    levaddr         = 12288
        defc    levdata         = 12501
;Level ends at 20693
        defc    varbase         = 20700
        defc    datatab1        = varbase+72+2048       ;usage unknown
        defc    ozvars          = varbase+72+720+2048


        defc    inflate = 32768 ;1312
        defc    music_store     = 32768+1315 ;1580
        defc    titlescreen_store = 32768+1315+1590  ;1063

; So data would end at around 24000


; Stuff in data file..


        defc    lemmingslogo    = 60018
        defc    statusudg       = 59826
        defc    statnumbers     = 61538





;Structure definitions and other such gunk

DEFVARS     ozvars
{
filename    ds.b  9     ;
filenamech  ds.b  2
filenameend ds.b  1
pkeys       ds.b  8     ;player keys
myflags     ds.b  1
copy_spstor ds.w  1
copy_ixstor ds.w  1
copy_iystor ds.w  1
fbuffer     ds.b  10    ;reuse?
levelcode   ds.b  10
L45786      ds.b  1     ;used in code gubbins
table1st    ds.b  1     ;used in sprite routines
l_errlevel    ds.w  1
l_erraddr ds.b  1
ozaddr      ds.w  1
ozbank      ds.b  1
udg         ds.b  1
spstor          ds.w    1
gamemode    ds.b  1     ;mode of game (for redraw)
                        ;0=in copyright (music)
                        ;1=start select
                        ;2=preview screen
                        ;3=in game
                        ;4=post game analysis
levelnew        ds.b 1  ;next level to play (used for redraw)
}


 

; Structure of the level


DEFVARS levaddr
{
        level_no        ds.b    1       ;23400
        total_lemmings  ds.b    1       ;23401
        release_rate    ds.b    1       ;23402
        u1              ds.b    1       ;23403 - word with 23404
        u2              ds.b    1       ;23404
        u3              ds.b    1       ;23405
        time_allowed    ds.b    1       ;23406
; 23407 - 23414 - number of lemming types this level
        num_climbers    ds.b    1       ;23407
        num_floaters    ds.b    1       ;23408
        num_bombers     ds.b    1       ;23409
        num_blockers    ds.b    1       ;23410
        num_builders    ds.b    1       ;23411
        num_bashers     ds.b    1       ;23412
        num_miners      ds.b    1       ;23413
        num_diggers     ds.b    1       ;23414
        level_attr      ds.b    1       ;23415
        to_be_saved     ds.b    1       ;23416
        u4              ds.b    1       ;23417 - word with 23418
        u5              ds.b    1       ;23418
        u6              ds.b    1       ;23419
        rating          ds.b    1       ;23420
        level_name      ds.b    32      ;23421 - level name
}





; varbase+31 = locked on
; varbase+26 = pointer x
; varbase+27 = pointer y
; varbase+12/13 = address in level to display top left

DEFVARS varbase {
u10             ds.b    10
level           ds.b    1       
u11             ds.b    6
savedlemmings   ds.b    1
__u12           ds.b    1
timeprflag      ds.b    1
subsecs         ds.b    1
secunits        ds.b    1
sectens         ds.b    1
mins            ds.b    1
scrxpos         ds.b    1
__u13           ds.b    12
attr            ds.b    1
__u14           ds.b    14
plopcount       ds.b    1
plopaddr        ds.w    1
current_type    ds.b    1
__u15           ds.b    1
armagedset      ds.b    1
__u16           ds.b    2
kempston        ds.b    1
__u17           ds.b    3
reloadlevel     ds.b    1
gameon          ds.b    1
__u18           ds.b    3
model           ds.b    1
}

IF STATIC


.level           defb    0       ;62810 - holds level number
.savedlemmings  defb    0       ;62817 - no saved this game

.timeprflag     defb    0       ;62819 - 255 if print 0 if not
.subsecs        defb    0       ;62820
.secunits       defb    0       ;62821
.sectens        defb    0       ;62822
.mins           defb    0       ;62823
.scrxpos        defb    0       ;62824 - x posn of top left i think

.attr           defb    0       ;62837 - holds attr for screen colour


.plopcount      defb    0       ;62852 - some sort of counter for plop snd
.plopaddr       defw    0       ;62853 - address for plop snd posn

.current_type   defb    0       ;62855 - current highlit type

.armagedset     defb    0       ;62857 - armageddon set
.kempston       defb    0       ;62860 - if bit 0 set use kempston

.mode128        defb    0       ;62864 - bit 0 set if 128k
.reloadlevel    defb    0       ;62865 - 255 = reload level (128k)
.gameon         defb    0       ;62866 - 255 print screen/keys 0 dont
.model          defb    0       ;62870 - 0 = sincliar 255=amstrad/other


ENDIF
