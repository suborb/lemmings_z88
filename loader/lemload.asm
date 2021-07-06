; Lemmings level load and decompressor

     module    lemload

include   "fileio.def"
include   "error.def"
include   "data.def"

     xdef getabyte2,getabyte3,getbufbyte
     xdef putbyte2,inf_err
     xdef decompress

     xref inflate

; Main routine. On entry, de=address of filename to open

     org  appl_org      ;not needed..appending to my file...

.decompress  
     ld   (header+2),sp
;     ld   sp,($1ffe)     ; choose safe stack
     ex   de,hl     ; HL=filename address
     ld   b,0
     ld   de,workarea
     ld   c,255
     ld   a,OP_IN
     call_oz(gn_opf)          ; attempt to open file
     jp   c,inf_err2     ; move on if error
     ld   (inhandle),ix
     call fillbuffer     ; fill the input buffer
     call getbufbyte
     ld   (header),a
     call getbufbyte
     ld   (header+1),a   ; store filelength
     call getbufbyte
     exx
     ld   c,a  ; fill bit-buffer
     ld   b,8
     ld   de,outbuffer   ; set up output buffer
     exx
     call inflate   ; inflate the file
     xor  a    ; no error
     jp   inf_err   ; finish

; Subroutine to get a byte from the input file in A
; All other registers preserved

.getbufbyte    exx
     ld   a,(hl)
     inc  l
     exx
     ret  nz   ; exit unless at 256-byte boundary
               ; if so, continue into GETABYTE2

; Subroutine to get next byte from the input buffer
; Use EXX; LD C,(HL); LD B,8; INC L; EXX; CALL Z,GETABYTE2
; Or if in alternate set, use:
;     LD C,(HL); LD B,8; INC L; CALL Z,GETABYTE3

.getabyte2     push af
     exx
     inc  h
     ld   a,h
     cp   0+(inbuffer+inbuflen)/$100    ; check if at end of input buffer
     exx
     jr   z,refillit
     pop  af
     ret
.getabyte3     push af
     inc  h
     ld   a,h
     cp   0+(inbuffer+inbuflen)/$100
     jr   z,refill2
     pop  af
     ret
.refill2  exx
     call fillbuffer
     exx
     pop  af
     ret
.refillit pop  af   ; restore regs and enter FILLBUFFER

; Subroutine to re-fill the input buffer

.fillbuffer    push af
     push bc
     push de
     push hl
     push ix
     ld   ix,(inhandle)
     ld   de,inbuffer
     ld   hl,0
     ld   bc,inbuflen
     exx
     push bc
     push de
     push hl
     exx
     call_oz(os_mv)      ; fill input buffer
     exx
     pop  hl
     pop  de
     pop  bc
     exx
     ld   hl,inbuffer
     ld   a,b
     or   c
     jr   z,allread ; move on if full buffer
     ld   hl,inbuflen
     and  a
     sbc  hl,bc     ; hl=#bytes actually read
     jp   z,inf_err ; if none, there's a problem
     ld   b,h
     ld   c,l  ; BC=#bytes read
     ld   de,inbuffer-1
     add  hl,de     ; HL=add of last byte read
     ld   de,inbuffer+inbuflen-1   ; DE=end of inbuffer
     lddr      ; move input to end of buffer
     ex   de,hl
     inc  hl   ; HL=start of input
.allread  push hl
     exx
     pop  hl   ; setup HL'
     exx
     pop  ix   ; restore registers
     pop  hl
     pop  de
     pop  bc
     pop  af
     ret

; Subroutine to output a byte (will be buffered)
; A contains byte (changed), all other registers preserved
; Use EXX; LD (DE),A; INC E; EXX; CALL Z,PUTBYTE2

.putbyte2 exx
     inc  d
     ld   a,d
     exx
     cp   0+(outbuffer+outbuflen)/$100
     ret  nz   ; exit if not at end of buffer 
     exx
     ld   a,e
     exx
     and  a
     ret  z    ; exit unless output past end
     ld   a,RC_Ovf  ; else continue into error routine

; Error handling

.inf_err  push af   ; save error code
     ld   ix,(inhandle)
     call_oz(gn_cl)      ; close file
     pop  af
.inf_err2 ld   sp,(header+2)  ; restore BASIC stack
     ld   hl,(header)    ; get HL'=filesize detected
     exx
     ld   l,a
     ld   h,0  ; HL=error
     ret       ; Exit to BASIC

