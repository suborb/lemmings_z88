; INFLATE routines for Z80
; Code tables are arranged as 5 bytes per code, as follows:
;  bytes   0: code bit length
;  bytes 1-2: code (LSB first)
;  bytes 3-4: value (LSB first)

        ;define DEBUG                   ; debugging features
        if DEBUG
                ;define DBG_CLS         ; display codelengths
                define DBG_TABLES               ; display tables
                define DBG_INFLATE              ; display inflation
                ;define DBG_DISTINFO            ; display distance info
                ;define DBG_BUFINFO             ; display buffer info
        endif

        module  inflate

include "error.def"
include "data.def"

        xdef    inflate

        xref    getbufbyte,getabyte2,putbyte2,inf_err
        xref    getabyte3
if DEBUG
        xref    oz_gn_sop,oz_gn_pdn,oz_gn_nln
endif
        defvars workarea
        {
        bitlcnts        ds.b    17*4    ; bitlength nextcodes/counts
        clalpha ds.b    19*5+1  ; code length alphabet table
        llalpha ds.b    288*5+1 ; lit/length alphabet table
        dsalpha ds.b    32*5+1  ; distance alphabet table
        llstart ds.w    1       ; ptr to lit/length alphabet
        dsstart ds.w    1       ; ptr to distance alphabet
        }

.clorder        defb    16*5    ; order to read codelengths (as offsets
        defb    17*5    ; to a code table)
        defb    18*5
        defb    0*5
        defb    8*5
        defb    7*5
        defb    9*5
        defb    6*5
        defb    10*5
        defb    5*5
        defb    11*5
        defb    4*5
        defb    12*5
        defb    3*5
        defb    13*5
        defb    2*5
        defb    14*5
        defb    1*5
        defb    15*5

.lenextra       defb    0       ; Table of extra bits for length values - 257
        defw    3
        defb    0       ; 258
        defw    4
        defb    0       ; 259
        defw    5
        defb    0       ; 260
        defw    6
        defb    0       ; 261
        defw    7
        defb    0       ; 262
        defw    8
        defb    0       ; 263
        defw    9
        defb    0       ; 264
        defw    10
        defb    1       ; 265
        defw    11
        defb    1       ; 266
        defw    13
        defb    1       ; 267
        defw    15
        defb    1       ; 268
        defw    17
        defb    2       ; 269
        defw    19
        defb    2       ; 270
        defw    23
        defb    2       ; 271
        defw    27
        defb    2       ; 272
        defw    31
        defb    3       ; 273
        defw    35
        defb    3       ; 274
        defw    43
        defb    3       ; 275
        defw    51
        defb    3       ; 276
        defw    59
        defb    4       ; 277
        defw    67
        defb    4       ; 278
        defw    83
        defb    4       ; 279
        defw    99
        defb    4       ; 280
        defw    115
        defb    5       ; 281
        defw    131
        defb    5       ; 282
        defw    163
        defb    5       ; 283
        defw    195
        defb    5       ; 284
        defw    227
        defb    0       ; 285
        defw    258

.dstextra       defb    0       ; 0
        defw    1
        defb    0       ; 1
        defw    2
        defb    0       ; 2
        defw    3
        defb    0       ; 3
        defw    4
        defb    1       ; 4
        defw    5
        defb    1       ; 5
        defw    7
        defb    2       ; 6
        defw    9
        defb    2       ; 7
        defw    13
        defb    3       ; 8
        defw    17
        defb    3       ; 9
        defw    25
        defb    4       ; 10
        defw    33
        defb    4       ; 11
        defw    49
        defb    5       ; 12
        defw    65
        defb    5       ; 13
        defw    97
        defb    6       ; 14
        defw    129
        defb    6       ; 15
        defw    193
        defb    7       ; 16
        defw    257
        defb    7       ; 17
        defw    385
        defb    8       ; 18
        defw    513
        defb    8       ; 19
        defw    769
        defb    9       ; 20
        defw    1025
        defb    9       ; 21
        defw    1537
        defb    10      ; 22
        defw    2049
        defb    10      ; 23
        defw    3073
        defb    11      ; 24
        defw    4097
        defb    11      ; 25
        defw    6145
        defb    12      ; 26
        defw    8193
        defb    12      ; 27
        defw    12289
        defb    13      ; 28
        defw    16385
        defb    13      ; 29
        defw    24577

; Routine to set up a blank code table
; On entry, HL=start address, BC=number of codes
; and A=codelength to fill table with (usually 0)
; It also places code==value
; These values are preserved, but A,A',DE corrupted

.newtable       ld      de,0    ; initial code
        push    bc      ; save values
        push    hl
        ex      af,af'  ; A'=codelength
.blnknew        ex      af,af'
        ld      (hl),a  ; place code length
        inc     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d  ; place code==value
        inc     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d  ; place value
        inc     hl      ; hl=next entry
        inc     de      ; de=next value
        dec     bc      ; decrement # codes
        ex      af,af'  ; A'=codelength
        ld      a,b
        or      c
        jr      nz,blnknew      ; back for more
        pop     hl      ; restore values
        pop     bc
        ret             ; exit

; Routine to count the number of codes for each bit length
; On entry, HL points to the start of the code table,
; and BC holds the number of entries in the code table.
; At this stage, it is assumed that bytes 0 & 3-4 are correct
; for all entries in the table. The value of bytes 1-2 are
; not important. It is also assumed that the values are in
; ascending order.

.generate       push    hl      ; save registers
        push    bc
        ld      hl,bitlcnts
        ld      d,h
        ld      e,l
        inc     de
        ld      bc,67
        ld      (hl),0
        ldir            ; erase table of counts
        pop     bc
        pop     hl      ; restore registers
        push    hl      ; and re-save
        push    bc
        ld      d,0
.cntagain       ld      a,(hl)
        and     a
        jr      z,nozero        ; don't count zero code lengths
        add     a,a
        add     a,a
        ld      e,a     ; DE=bitlength*4
        push    hl      ; save tableadd
        ld      hl,bitlcnts+2
        add     hl,de   ; get to address of count to increment
        inc     (hl)    ; increment low byte
        jr      nc,lowinc       ; move on if no carry
        inc     hl
        inc     (hl)    ; otherwise, increment high byte
.lowinc pop     hl
.nozero ld      e,5
        add     hl,de   ; get to next table entry
        dec     bc
        ld      a,b
        or      c
        jr      nz,cntagain     ; loop back for more

; Routine to set up the "next_code" values for each bit length

.nxtcodes       ld      de,0    ; set code=0
        ld      hl,bitlcnts+2   ; start at count for bitlength 0
        ld      a,16    ; loop for 16 bits
.nextnc ld      c,(hl)
        inc     hl
        ld      b,(hl)
        inc     hl      ; bc=previous count, hl=add to place
        ex      de,hl
        add     hl,bc
        add     hl,hl
        ex      de,hl   ; code=(code+count(bits-1))*2
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl      ; store code
        dec     a
        jr      nz,nextnc       ; back for more

; Routine to assign numerical values to all codes. Codes with a
; bit length of zero will not be assigned a value.

        pop     bc      ; restore registers from
        pop     hl      ; previous routine
        push    hl      ; and re-save
        push    bc
.assignco       ld      a,(hl)  ; get bit length of code
        inc     hl
        push    hl      ; save address
        and     a
        jr      z,skipcode      ; don't assign value if bl=0
        add     a,a
        add     a,a
        ld      e,a
        ld      d,0     ; de=4*bitlength
        ld      hl,bitlcnts
        add     hl,de   ; hl=address of next code value
        ld      e,(hl)
        inc     hl
        ld      d,(hl)  ; get "next code"
        ex      (sp),hl
        ld      (hl),e
        inc     hl
        ld      (hl),d  ; place in code table
        dec     hl
        ex      (sp),hl
        inc     de
        ld      (hl),d
        dec     hl
        ld      (hl),e  ; store back increased code
.skipcode       pop     hl      ; restore table address
        ld      de,4
        add     hl,de   ; move to next entry
        dec     bc
        ld      a,b
        or      c
        jr      nz,assignco     ; loop back for more

; Routine to sort the code table into bit length order.
; On exit, IX points to the effective start of the ordered table
; (ignoring any initial zero bit length codes). A table terminator
; of zero is stored after the final entry.

.shellsort      pop     bc      ; restore registers from
        pop     hl      ; previous routine
        push    hl
        add     hl,bc
        add     hl,bc
        add     hl,bc
        add     hl,bc
        add     hl,bc
        ld      (hl),0  ; store table end marker
        ex      (sp),hl
        pop     ix      ; IX=list end, HL=list start
.sortloop       srl     b       ; halve distance
        rr      c
        ld      a,b
        or      c
        jr      z,sorted        ; finished sorting
        push    hl      ; save list start
        push    bc      ; and distance
        ld      d,h
        ld      e,l     ; DE=list start
        add     hl,bc
        add     hl,bc
        add     hl,bc
        add     hl,bc
.sortloop2      add     hl,bc   ; HL=list middle
        ex      de,hl
        ld      (listptr),hl    ; save list pointers
        ld      (listptr+2),de
.moreswaps      ld      a,(de)
        cp      (hl)    ; compare items
        jr      nc,noswap
        ld      b,(hl)  ; swap items if re       if required
        ld      (hl),a
        ld      a,b
        ld      (de),a
        inc     de
        inc     hl
        ld      a,(de)  ; swap 2nd byte
        ld      b,(hl)
        ld      (hl),a
        ld      a,b
        ld      (de),a
        inc     de
        inc     hl
        ld      a,(de)  ; swap 3rd byte
        ld      b,(hl)
        ld      (hl),a
        ld      a,b
        ld      (de),a
        inc     de
        inc     hl
        ld      a,(de)  ; swap 4th byte
        ld      b,(hl)
        ld      (hl),a
        ld      a,b
        ld      (de),a
        inc     de
        inc     hl
        ld      a,(de)  ; swap 5th byte
        ld      b,(hl)
        ld      (hl),a
        ld      a,b
        ld      (de),a
        dec     hl
        dec     hl
        dec     hl
        dec     hl
        ld      d,h
        ld      e,l
        pop     bc      ; BC=distance
        and     a
        sbc     hl,bc
        sbc     hl,bc
        sbc     hl,bc
        sbc     hl,bc
        sbc     hl,bc
        ex      de,hl
        ex      (sp),hl
        push    hl
        dec     hl
        and     a
        sbc     hl,de
        pop     hl
        ex      (sp),hl
        push    bc
        ex      de,hl
        jr      c,moreswaps
.noswap ld      hl,(listptr)    ; restore listpointers
        ld      de,(listptr+2)
        ld      bc,5    ; move to next entries
        add     hl,bc
        ex      de,hl
        add     hl,bc
        push    ix
        pop     bc
        and     a
        sbc     hl,bc   ; test for table end
        jr      c,sortloop2     ; back if not
        pop     bc      ; restore registers
        pop     hl
        jp      sortloop        ; loop back
.sorted ld      bc,5
.nextone        ld      a,(hl)
        and     a
        jr      nz,gotone       ; exit when found true table start
        add     hl,bc   ; else move to next entry
        jr      nextone
.gotone push    hl
        pop     ix
        ret

; Routine to read the encoded Literal/Length & Distance code
; block for dynamic Huffman codes

.dynread        ld      hl,0
        ld      (lastclv),hl    ; zeroise repeat values
        ld      hl,clalpha
        ld      bc,19
        xor     a
        call    newtable        ; set up codelength code table
        ld      a,5
        call    getbits
        ld      b,e     ; B=# of literal/length codes-257
if DEBUG
        push    bc
        ld      hl,msg_litcodes
        call    oz_gn_sop
        pop     bc
        push    bc
        ld      hl,2
        ld      c,b
        ld      b,0
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        call    oz_gn_nln
        pop     bc
endif
        ld      a,5
        call    getbits
        ld      c,e     ; C=# of distance codes-1
        push    bc      ; save # length/lit & distance codes
if DEBUG
        ld      hl,msg_distcodes
        call    oz_gn_sop
        pop     bc
        push    bc
        ld      hl,2
        ld      b,0
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        call    oz_gn_nln
endif
        ld      a,4
        call    getbits
        ld      a,e
        add     a,4
        ld      b,a     ; B=# of codelength codes
        ld      ix,clorder      ; IX=cl order table start
.morecls        ld      a,3
        call    getbits ; get next code length codelength
        ld      a,e
        ld      e,(ix+0)        ; get offset to place in table
        ld      hl,clalpha
        add     hl,de
        ld      (hl),a  ; place code length codelength
        inc     ix      ; step to next offset
        djnz    morecls ; back for rest of cl codelengths
        ld      hl,clalpha
        ld      bc,19
        call    generate        ; generate the code table for cls
        pop     bc      ; B=#lit/length codes-257
        push    bc      ; resave counts
        ld      c,b
        ld      b,0
        ld      hl,257
        add     hl,bc
        ld      b,h
        ld      c,l     ; BC=#lit/length codes
if DEBUG
        ld      hl,msg_declitlen
        call    oz_gn_sop
endif
        ld      hl,llalpha      ; HL=start of lit/length table
if DBG_TABLES
        push    bc
        call    decalpha        ; decode the lit/length alphabet
        ld      (llstart),hl    ; save start of lit/length alphabet
        ld      hl,msg_tbllit
        call    oz_gn_sop
        pop     bc
        ld      hl,llalpha
        call    disptable
else
        call    decalpha
        ld      (llstart),hl
endif
        pop     bc      ; C=#distance codes-1
        inc     c
        ld      b,0     ; BC=#distance codes
if DEBUG
        ld      hl,msg_decdist
        call    oz_gn_sop
endif
        ld      hl,dsalpha      ; HL=start of distance alphabet
if DBG_TABLES
        push    bc
        call    decalpha        ; decode the distance alphabet
        ld      (dsstart),hl    ; save start of distance table
        pop     bc
        ld      hl,msg_tbldist
        call    oz_gn_sop
        ld      hl,dsalpha
        call    disptable
else
        call    decalpha
        ld      (dsstart),hl
endif
        ret             ; exit

; Routine to decode a lit/length or distance alphabet, using the code
; length alphabet
; On entry, IX=start of codelength table (preserved),
; HL=start of lit/length table (on exit=effective start)
; BC=number of codes

.decalpha       push    ix      ; save registers
        push    hl
        push    bc
        xor     a
        call    newtable        ; create blank table
        ld      de,(lastclv)    ; D=repeats left, E=last value
.decalph2       ld      a,d
        and     a       ; check if any repeats left
        jr      z,getnewval
.dorepeat       dec     d       ; decrement repeats
        ld      a,e     ; get value
        jr      gotaval
.getnewval      push    de
        push    bc
        push    hl
        push    ix
        pop     hl      ; get HL=table start
        push    hl
        call    decodev ; decode a value
        pop     ix
        pop     hl
        pop     bc
        ld      a,e
        and     15
        cp      e
        jr      nz,repvals      ; move on if 16-18 (=repeats)
        pop     de      ; discard old value
        ld      e,a     ; new "last" value
        ld      d,0     ; zeroise repeats
.gotaval        ld      (hl),a  ; store codelength
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        inc     hl      ; HL points to next entry
if DBG_CLS
        push    bc
        push    de
        push    hl
        push    af
        ld      hl,msg_codelength
        call    oz_gn_sop
        pop     af
        ld      hl,2
        ld      c,a
        ld      b,0
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        call    oz_gn_nln
        pop     hl
        pop     de
        pop     bc
endif
        dec     bc
        ld      a,b
        or      c
        jr      nz,decalph2     ; back for more codes
        ld      (lastclv),de    ; save repeat info
        pop     bc
        pop     hl
        call    generate        ; generate code table
        ex      (sp),ix ; IX=start of codelength table
        pop     hl      ; HL=start of generated table
        ret             ; exit
.repvals        push    af      ; save A
        add     a,2     ; A=2/3/4
        cp      4
        jr      nz,not18        ; skip if was code 18
        ld      a,7     ; else get 7 bits
.not18  call    getbits ; get additional bits
        pop     af
        and     a
        jr      nz,copy0s       ; move on if codes 17/18
        ld      a,e
        add     a,3     ; A=number of times to copy value
        pop     de      ; restore last code
        ld      d,a     ; D=# repeats
        jr      dorepeat
.copy0s cp      2       ; check if val 18 or 17
        ld      a,e     ; A=bits to add
        jr      z,was18
        add     a,3     ; times=3-10 for code 17
        jr      copy0s2
.was18  add     a,11    ; times=11-138 for code 18
.copy0s2        pop     de
        ld      d,a     ; D=# repeats
        ld      e,0     ; value=zero
        jp      dorepeat

; Routine to generate Lit/length & distance code tables for fixed
; length Huffman codes

.fixgen ld      hl,llalpha
        ld      bc,288
        ld      a,8
        call    newtable        ; generate table with all 8bit cls
        ld      hl,llalpha+(144*5)      ; get to code 144 cl
        ld      de,5
        ld      a,112   ; fill 112 entries with 9bit cl
.fill9  ld      (hl),9
        add     hl,de
        dec     a
        jr      nz,fill9
        ld      a,24    ; fill 24 entries with 7bit cl
.fill7  ld      (hl),7
        add     hl,de
        dec     a
        jr      nz,fill7
        ld      hl,llalpha
        call    generate        ; generate lit/length code table
        ld      (llstart),ix
        ld      hl,dsalpha
        ld      bc,32
        ld      a,5
        call    newtable        ; generate distance code table
        call    generate
        ld      (dsstart),ix
        ret

; Main decompression routine

.inflate        ld      a,3
        call    getbits ; read block header
        ld      a,e     ; get A=header
        srl     a       ; shift "last block" flag to carry
        push    af      ; and save it
        and     a
        jp      z,block00       ; jump for block 00
        dec     a
        jr      z,block01       ; jump for block 01
        dec     a
        jp      nz,codeerr      ; error if not block 10
.block10        call    dynread ; read dynamic Huffman codes
        jr      loopdcmp
.block01        call    fixgen  ; generate fixed Huffman codes
.loopdcmp       ld      hl,(llstart)
if DBG_BUFINFO
        push    hl
        ld      hl,msg_bufinfo
        call    oz_gn_sop
        exx
        push    bc
        exx
        pop     bc
        push    bc
        ld      c,b
        ld      b,0     ; BC=#bits left
        ld      hl,2
        ld      de,dbg_buffer
        ld      a,4
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        pop     bc
        ld      b,0     ; BC=bit buffer
        ld      hl,2
        ld      de,dbg_buffer
        ld      a,4
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        exx
        push    hl
        exx
        ld      b,5
.dispbuf        pop     hl
        ld      c,(hl)
        inc     hl
        push    hl
        push    bc
        ld      b,0     ; BC=next buffer byte
        ld      hl,2
        ld      de,dbg_buffer
        ld      a,4
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        pop     bc
        djnz    dispbuf
        pop     hl
        call    oz_gn_nln
        pop     hl
endif
                        ; For speed, a copy of the DECODEV
                        ; routine is inserted here
.Ldecodev       ld      de,0    ; start with code=0
        ld      b,0     ; and codelength=0
.Ldecagain      ld      a,(hl)
        inc     hl
        ld      c,a     ; save new codelength
        sub     b
        jr      z,Lnomoreh      ; move on if no more bits needed
        jr      c,Lnomoreh      ; error if end of table
        exx             ; switch to alt (buffer) set
.Lmorehbit      rr      c       ; rotate bit in
        exx
        rl      e
        rl      d
        exx
        dec     b       ; decrement bits left
        jp      nz,Lsamebyte2
        ld      c,(hl)
        ld      b,8
        inc     l
        call    z,getabyte3     ; get another byte if required
.Lsamebyte2     dec     a
        jp      nz,Lmorehbit    ; back for more bits
        exx             ; switch back to normal set
.Lnomoreh       ld      b,(hl)  ; get code from table
        inc     hl
        ld      a,(hl)
        inc     hl
        cp      d
        jr      nz,Lnotdecoded
        ld      a,b
        cp      e
        jr      z,Ldecoded
.Lnotdecoded    inc     hl      ; skip value
        inc     hl
        ld      b,c     ; get codelength
        jp      Ldecagain       ; and loop back
.Ldecoded       ld      e,(hl)  ; de=decoded value
        inc     hl
        ld      d,(hl)
                        ; end of DECODEV copy
        ld      a,d
        and     a
        jr      nz,dolength     ; move on if 256+
        ld      a,e
        exx
        ld      (de),a  ; place literal in output stream
        inc     e
        exx
        call    z,putbyte2
if DBG_INFLATE
        push    af
        ld      hl,msg_literal
        call    oz_gn_sop
        pop     af
        ld      hl,2
        ld      c,a
        ld      b,0
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        call    oz_gn_nln
endif
        jp      loopdcmp        ; and loop back
.endblock       pop     af      ; restore last block flag
        jp      nc,inflate      ; loop back for more blocks
        ret             ; exit
.dolength       xor     1
        or      e       ; set Z if D=1 and E=0
        jr      z,endblock
.dodist ld      hl,lenextra-(3*257)
        add     hl,de
        add     hl,de
        add     hl,de   ; hl=address of extra bits etc
        ld      a,(hl)
        call    getbits ; get extra bits required
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a
        add     hl,de   ; hl=length (3-258)
        push    hl      ; save length
        ld      hl,(dsstart)
        call    decodev ; decode a distance
if DBG_DISTINFO
        push    de
endif
        ld      hl,dstextra
        add     hl,de
        add     hl,de
        add     hl,de   ; hl=address of extra bits etc
        ld      a,(hl)
        call    getbits ; get extra bits required
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a
if DBG_DISTINFO
        pop     bc
        push    de
        push    hl
        push    bc
endif
        add     hl,de   ; hl=distance (1-32768)
if DBG_INFLATE
        push    hl
if DBG_DISTINFO
        ld      hl,msg_distcode
        call    oz_gn_sop
        ld      hl,2
        pop     de
        pop     bc      ; bc=distance code
        push    de
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        ld      hl,msg_distval
        call    oz_gn_sop
        ld      hl,2
        pop     de
        pop     bc      ; bc=distance value
        push    de
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        ld      hl,msg_distextra
        call    oz_gn_sop
        ld      hl,2
        pop     de
        pop     bc      ; bc=distance extra bits
        push    de
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        ld      hl,msg_distance
        call    oz_gn_sop
else
        ld      hl,msg_distonly
        call    oz_gn_sop
endif
        pop     bc      ; bc=distance
        push    bc
        ld      hl,2
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        ld      hl,msg_length
        call    oz_gn_sop
        ld      hl,2
        pop     de
        pop     bc      ; bc=length
        push    bc
        push    de
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        call    oz_gn_nln
        pop     hl      ; restore distance
endif
        pop     bc      ; get length
        ex      de,hl   ; de=distance
        exx
        push    de
        exx
        pop     hl
        and     a
        sbc     hl,de   ; get to position in output stream
        ld      a,h
        cp      outbuffer/$100  ; check if wraps
        jr      c,doeswrap
        cp      0+(outbuffer+outbuflen)/$100
        jr      c,copyloop
.doeswrap       add     a,outbuflen/$100
        ld      h,a     ; now in correct position
.copyloop       ld      a,(hl)  ; get next byte from buffer
        exx
        ld      (de),a  ; output it
        inc     e
        exx
        call    z,putbyte2
        inc     l
        jp      nz,samepage
        inc     h
        ld      a,h
        cp      0+(outbuffer+outbuflen)/$100
        jp      nz,samepage
        ld      h,outbuffer/$100
.samepage       dec     bc
        ld      a,b
        or      c
        jp      nz,copyloop
        jp      loopdcmp        ; jump back
.block00        call    getbufbyte
        ld      e,a
        call    getbufbyte
        ld      d,a     ; DE=block length
        call    getbufbyte
        cpl
        cp      e
        jp      nz,codeerr      ; error if bad NLEN
        call    getbufbyte
        cpl
        cp      d
        jp      nz,codeerr      ; error if bad NLEN
.storeloop      exx
        ld      a,(hl)  ; get byte
        inc     l
        call    z,getabyte3
        ld      (de),a  ; put in output buffer
        inc     e
        exx
        call    z,putbyte2
        dec     de      ; decrement count
        ld      a,d
        or      e
        jp      nz,storeloop    ; back for more
        exx
        ld      c,(hl)  ; refill bit buffer
        ld      b,8
        inc     l
        exx
        call    z,getabyte2
        jp      endblock        ; back for more blocks


; Now the GETBITS subroutine
; This gets A bits into DE from the input stream

.getbits        ld      d,a
        ld      e,a
        and     a
        ret     z       ; exit with DE=0 if A=0
        ld      de,32768        ; flag bit 15
        exx             ; switch to alt (buffer) set
.morebits       rr      c       ; rotate bit in
        exx
        rr      d
        rr      e
        exx
        dec     b
        jp      nz,samebyte
        ld      c,(hl)
        ld      b,8
        inc     l
        call    z,getabyte3
.samebyte       dec     a
        jp      nz,morebits     ; back for more
        exx             ; switch back to normal set
.reshift        srl     d       ; shift value to bottom of DE
        rr      e
        jp      nc,reshift      ; until flag drops out
        ret

; The DECODEV subroutine
; Using table HL, this decodes a value from the input stream,
; returned in DE. No registers are preserved

.decodev        ld      de,0    ; start with code=0
        ld      b,0     ; and codelength=0
.decagain       ld      a,(hl)
        inc     hl
        ld      c,a     ; save new codelength
        sub     b
        jr      z,nomoreh       ; move on if no more bits needed
        jr      c,nomoreh       ; error if end of table
        exx             ; switch to alt (buffer) set
.morehbit       rr      c       ; rotate bit in
        exx
        rl      e
        rl      d
        exx
        dec     b       ; decrement bits left
        jp      nz,samebyte2
        ld      c,(hl)
        ld      b,8
        inc     l
        call    z,getabyte3     ; get another byte if required
.samebyte2      dec     a
        jp      nz,morehbit     ; back for more bits
        exx             ; switch back to normal set
.nomoreh        ld      b,(hl)  ; get code from table
        inc     hl
        ld      a,(hl)
        inc     hl
        cp      d
        jr      nz,notdecoded
        ld      a,b
        cp      e
        jr      z,decoded
.notdecoded     inc     hl      ; skip value
        inc     hl
        ld      b,c     ; get codelength
        jp      decagain        ; and loop back
.decoded        ld      e,(hl)  ; de=decoded value
        inc     hl
        ld      d,(hl)
        ret             ; done

; If an error in the ZIP file has been found

.codeerr        ld      a,RC_Ovf        ; use "Overflow" error
        jp      inf_err ; do it

if DEBUG
.msg_literal    defm    "Literal: "&0
.msg_length     defm    "  Length: "&0
.msg_distcode   defm    "Distance(code="&0
.msg_distval    defm    ",value="&0
.msg_distextra  defm    ",extra="&0
.msg_distance   defm    "): "&0
.msg_distonly   defm    "Distance: "&0
.msg_bufinfo    defm    "#B<5>: "&0
.msg_litcodes   defm    "Number of lit/length codes-257="&0
.msg_distcodes  defm    "Number of distance codes-1="&0
.msg_codelength defm    "Codelength from stream: "&0
.msg_declitlen  defm    "Decoding lit/length alphabet..."&13&10&0
.msg_decdist    defm    "Decoding distance alphabet..."&13&10&0
.msg_value      defm    "Value="&0
.msg_code       defm    "  Code="&0
.msg_bits       defm    "  Bits="&0
.msg_tbllit     defm    "Lit/length table..."&13&10&0
.msg_tbldist    defm    "Distance table..."&13&10&0
endif

if DBG_TABLES
.disptable      ld      a,b
        or      c
        ret     z
        ld      a,(hl)  ; get codelength
        inc     hl
        and     a
        jr      z,skipzeros
        push    bc      ; save count
        push    hl      ; save address
        push    af      ; save codelength
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        push    de      ; save code
        ld      c,(hl)
        inc     hl
        ld      b,(hl)  ; BC=value
        ld      hl,msg_value
        call    oz_gn_sop
        ld      hl,2
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        ld      hl,msg_code
        call    oz_gn_sop
        ld      hl,2
        pop     de      ; get back code
        pop     af      ; get #bits
        push    af
        ld      bc,0
.reverseit      rr      d
        rr      e
        rl      c
        rl      b
        dec     a
        jr      nz,reverseit
        ld      de,dbg_buffer
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        ld      hl,msg_bits
        call    oz_gn_sop
        ld      hl,2
        ld      de,dbg_buffer
        pop     af      ; get back bits
        ld      c,a
        ld      b,0
        xor     a
        call    oz_gn_pdn
        xor     a
        ld      (de),a
        ld      hl,dbg_buffer
        call    oz_gn_sop
        call    oz_gn_nln
        pop     hl
        pop     bc
.skipzeros      inc     hl
        inc     hl
        inc     hl
        inc     hl
        dec     bc
        jr      disptable
endif

