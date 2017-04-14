; $Id: //depot/idl/IDL_70/idldir/examples/HP_TIFF/sonos_read.pro#2 $
;
; Copyright (c) 1999-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.


Pro UnPackBits, Dest, lun, INIT=init, BUFFER_SIZE=bufsiz
; .pro implementation of decode_packbits
; For now, the BUFFER_SIZE keyword is ignored.  It could/should be
; implemented to speed operation.

Common SonosPackBitsCom, buffer, buffp, cur, fsize, type_size

if keyword_set(init) or (n_elements(buffer) eq 0) then begin
    type_size = [0,1,2,4,4,8, $ ;Size of IDL Types: u, b, l, f, d
                 8,0,0,16,0, $  ;Cmplx, str, stru, dpCmplx, ptr
                 0, 2, 4, 8, 8] ;obj, ui, ul, l64, ul64
    bsize = n_elements(bufsiz) eq 0 ? 32768L : bufsiz
    if n_elements(buffer) ne bsize then buffer = bytarr(bsize, /NOZERO)
    readu, lun, buffer
    buffp = 0L
endif

nbytes = n_elements(dest) * type_size[size(dest, /TYPE)] ;# bytes to fill
destp = 0L

while destp lt nbytes do begin
    n = buffer[buffp]
    buffp = buffp + 1L
    if n ge 128b then begin     ;Replicate next byte -n+1 times
        n = n - 256             ;Neg count
        if n ne -128 then begin
            n = -n + 1
            dest[destp: destp + n - 1] = buffer[buffp]
            buffp = buffp + 1L
            destp = destp + n
        endif
    endif else begin            ;copy next n+1 bytes
        dest[destp] = buffer[buffp: buffp+n]
        buffp = buffp + n + 1L
        destp = destp + n + 1L
    endelse
endwhile
end


Pro UnPackBits1, Dest, lun, INIT=init, OFFSET=destp, COUNT=nbytes, $
                 BUFFER_SIZE=bufsiz
; Uses built-in DECODE_PACKBITS.
Common SonosPackBitsCom, buffer, buffp, cur, fsize, type_size

if keyword_set(init) or (n_elements(buffer) eq 0) then begin
    type_size = [0,1,2,4,4,8, $ ;Size of IDL Types: u, b, l, f, d
                 8,0,0,16,0, $  ;Cmplx, str, stru, dpCmplx, ptr
                 0, 2, 4, 8, 8] ;obj, ui, ul, l64, ul64
    bsize = n_elements(bufsiz) eq 0 ? 32768L : bufsiz
    if n_elements(buffer) ne bsize then buffer = bytarr(bsize, /NOZERO)
    readu, lun, buffer
    buffp = 0L
endif

if n_elements(nbytes) eq 0 then $ ;# bytes to fill
  nbytes = n_elements(dest) * type_size[size(dest, /TYPE)]
if n_elements(destp) eq 0 then destp = 0L

Decode_PackBits, 0, dest, POINTER=buffp, BUFFER=buffer, $
  OFFSET = destp, COUNT=nbytes
end

Pro Sonos_ReadRd, lun, var, COMPRESSION = compres, INIT=init, $
        START_ROW=srow, NROWS=nrows, BUFFER_SIZE=bufsiz
common Sonos_readrd, use_decode_packbits

; Determine if the built-in function DECODE_PACKBITS exists.  If so,
; use it, otherwise use a .pro implementation.
if n_elements(use_decode_packbits) eq 0 then begin
    dummy = routine_names(/S_PROC) ;Built-in decode packbits?
    use_decode_packbits = total(dummy eq 'DECODE_PACKBITS') gt 0
endif


s = size(var)
rowsize = s[1]
if n_elements(srow) eq 0 then srow = 0L ;Default = start
if n_elements(nrows) eq 0 then nrows = n_elements(var)/rowsize ;Default = entire

if compres eq 32773U then begin
    type_size = [0,1,2,4,4,8, $ ;Size of IDL Types: u, b, l, f, d
                 8,0,0,16,0, $  ;Cmplx, str, stru, dpCmplx, ptr
                 0, 2, 4, 8, 8] ;obj, ui, ul, l64, ul64
    type = size(var, /TYPE)
    buffer = bytarr(rowsize * type_size[type], /NOZERO)
    if s[0] eq 3 then $         ;Make it 2D to read...
      var = reform(var, rowsize, n_elements(var)/rowsize, /OVERWRITE)
    for i= srow, srow+nrows-1 do begin ;Read each row
        if use_decode_packbits then UnPackBits1, buffer, lun, $
          INIT=init, BUFFER_SIZE=bufsiz $
        else UnPackBits, buffer, lun, INIT=init, BUFFER_SIZE=bufsiz
        init = 0
        if type eq 1 then var[0,i] = buffer $
        else if type eq 2 or type eq 12 then $
          var[0,i] = fix(buffer, 0, rowsize) $
        else message, 'Unanticipated type in Sonos_ReadRd'
    endfor
    if s[0] eq 3 then var = reform(var, s[1], s[2], s[3],/overwrite)
endif else begin
    readu, lun, var
endelse
end

function TIFF_Long,a,i,len=len	;return longword(s) from array a(i)
common TIFF_Com, order, ifd, count

on_error,2                      ;Return to caller if an error occurs

if n_elements(len) le 0 then len = 1
if len gt 1 then result = long(a,i,len) $
else result = long(a,i)
if order then byteorder, result, /lswap
return, result
end


function TIFF_Rational,a,i, len = len ; return rational from array a(i)
common TIFF_Com, order, ifd, count

on_error,2              ;Return to caller if an error occurs

if n_elements(len) le 0 then len = 1
tmp = TIFF_Long(a, i, len = 2 * len)	;1st, cvt to longwords
if len gt 1 then begin
	subs = lindgen(len)
	rslt = float(tmp[subs*2]) / tmp[subs*2+1]
endif else rslt = float(tmp[0]) / tmp[1]
return, rslt
end

function TIFF_Uint,a,i, len=len ;return unsigned long int from Sonos short int
common TIFF_Com, order, ifd, count

if n_elements(len) le 0 then len = 1
if len gt 1 then begin          ;Array?
    result = uint(a, i, len)
    if order then byteorder, result, /sswap
endif else begin                ;Scalar
    result = uint(a,i)
    if order then byteorder, result, /sswap
endelse
return, result
end

function TIFF_Byte, a,i,len=len	;return bytes from array a(i)
common TIFF_Com, order, ifd, count

on_error,2              ;Return to caller if an error occurs

   if n_elements(len) le 0 then len = 1
   if len gt 1 then result = a[i:i+len-1] $
   else result = a[i]
   return, result
end

function Sonos_read_field, index, tag, lun  ;Return contents of field index
; On output, tag = Sonos tag index.
;
common TIFF_Com, order, ifd, count


on_error,2                      ;Return to caller if an error occurs
TypeLen = [0, 1, 1, 2, 4, 8] ;lengths of Sonos types, 0 is null type for indexin

ent = ifd[index * 12: index * 12 + 11]  ;Extract the ifd
tag = TIFF_Uint(ent, 0)		;Sonos tag index
typ = TIFF_Uint(ent, 2)		;Sonos data type
cnt = TIFF_Long(ent, 4)		;# of elements
nbytes = cnt * TypeLen[typ]	;Size of tag field
IF (nbytes GT 4) THEN BEGIN 	;value size > 4 bytes ?
        offset = TIFF_Long(ent, 8)	;field has offset to value location
        Point_Lun, lun, offset
        val = BytArr(nbytes) 	;buffer will hold value(s)
        Readu, lun, val
        CASE typ OF		;Ignore bytes, as there is nothing to do
	   1: i = 0		;Dummy
           2: val = String(val)		;Sonos ascii type
           3: val = TIFF_Uint(val,0, len = cnt)
	   4: val = TIFF_Long(val,0, len = cnt)
           5: val = TIFF_Rational(val,0, len = cnt)
	ENDCASE
ENDIF ELSE BEGIN			;Scalar...
        CASE typ OF
	   1: val = ent[8 : 7 + cnt]
  	   2: val = string(ent[8:8+(cnt>1)-1])
	   3: val = TIFF_Uint(ent,8)
	   4: val = TIFF_Long(ent,8)
        ENDCASE
     ENDELSE
return, val
end




FUNCTION SONOS_READ, file, FRAME=findex, EIGHT_BIT_ONLY=only8, $
            TagKeys = TagKeys, TagValues=tagvalues

; Read an HP SONOS DSR Image File...
; Function result = image from file.  Will usually by an [nx, ny,
; 	nframes] array, of either bytes or unsigned shorts.
; Keywords:
;  FRAME = if specified, only read the frame in the file
;     corresponding to FRAME, from 0 to nFrames-1.
;  EIGHT_BIT_ONLY = if set, always return a byte image.  If the file
;     contains a 16 bit image, return only the low 8 bits.  This might
;     not always be valid, because the 16 bit images may contain
;     encodings of more than one variable.
;  TagKeys = if present, the numeric key value of the entries in the Sonos
;     header are returned as an array.  E.g. the directory entry 
;     ApplicationDescription has a key value of 33787.  These key
;     values are describled in the HP Sonos document.
;  TagValues = if present, the key values, corresponding to TagKeys,
;     are returned in a pointer array.  I.e. TagKey[i] contains the
;     key index, and *TagValue[i] contains the key value.

common TIFF_Com, order, ifd, count

on_error,2                      ;Return to caller if an error occurs

openr,lun,file, error = i, /GET_LUN, /BLOCK
if i lt 0 then begin ;OK?
	if keyword_set(lun) then free_lun,lun
	lun = -1
	message, 'Unable to open file: ' + file
	endif

hdr = bytarr(8)			;Read the header
readu, lun, hdr

typ = string(hdr[0:1])		;Either MM or II
if (typ ne 'MM') and (typ ne 'II') then begin
	message,'Sonos_READ: File is not a Sonos file: ' + string(file)
	return,0
	endif
order = typ eq 'MM'  		;1 if Motorola 0 if Intel (LSB first or vax)
endian = byte(1,0,2)		;What endian is this?
endian = endian[0] eq 0		;1 for big endian, 0 for little
order = order xor endian	;1 to swap...

; print,'Sonos File: byte order=',typ, ',  Version = ', TIFF_Uint(hdr,2)

offs = TIFF_Long(hdr, 4)	;Offset to IFD

point_lun, lun, offs		;Read it

a = bytarr(2)			;Entry count array
readu, lun, a
count = TIFF_Uint(a,0)		;count of entries
; print,count, ' directory entries'
ifd = bytarr(count * 12)	;Array for IFD's
readu, lun, ifd			;read it

;	Insert default values:
compression = 1
bits_sample = 1
ord = 1
SamplesPerPixel = 1L
pc = 1
photo = 1
rows_strip = 'fffffff'xl	;Essentially infinity
SampleFormat = 1
FramesInFile = 0
FieldsInFile = 1


for i=0,count-1 do begin	;Process each directory entry
    value = Sonos_read_field(i, tag, lun) ;Get each parameter
    case tag of                 ;Decode the tag fields we care about
        256:	width = value
        257:	length = value
        258:	bits_sample = value[0]
        259:	compression = value
        262:	Photo = value
        273:	StripOff = value
        274:	Ord = value
        277:	SamplesPerPixel = long(value)
        278:	Rows_strip = value
        279:	Strip_bytes = value
        284:	PC = value
        320:	ColorMap = value
        339:    SampleFormat = value
        33782:  FramesInFile = value ;HP unique tags follow
        33783:  FrameInfo = value
        33788:  FieldsInFile = value
        else:   dummy = 0       ;Ignore it
    endcase
    if arg_present(TagKeys) then begin ;Save directory keys and values?
        if i eq 0 then TagKeys = lonarr(count)
        TagKeys[i] = tag
    endif
    if arg_present(TagValues) then begin
        if i eq 0 then TagValues = ptrarr(count)
        TagValues[i] = ptr_new(value)
    endif
endfor                          ;Each tag

if n_elements(FrameInfo) eq 0 or $ ;Check for HP unique tags... must be there
  n_elements(FramesInFile) eq 0 or $
  n_elements(FieldsInFile) eq 0 then $
  message,'File is not an HP DSR file'

if n_elements(findex) eq 1 then begin
    fstart = findex
    nframes = 1
endif else begin
    fstart = 0
    nframes = FramesInFile
endelse

only8 = keyword_set(only8)
if fstart ge FramesInFile or fstart lt 0 then $
  message, 'FRAME parameter must be between 0 and '+strtrim(FramesInFile,2)

type = only8 or (PC eq 1) ? 1 : 12 ;Uint for PC=2, otherwise byte

;	Do a cursory amount of checking:
if compression ne 1  and compression ne 32773U then $
  message,'Sonos_READ: Images must be un-compressed'

dims = long([width, length])
interlaced = 1                  ;Just assume everything's interlaced.
; interlaced = FieldsInFile gt FramesInFile

FrameInfo = long(REFORM(FrameInfo, 6, FramesInFile))
FieldOff = lonarr(2 * FramesInFile)
FieldSiz = FieldOff

for i=0, FramesInFile-1 do begin ;Field offsets
    FieldOff[i*2] = FrameInfo[2,i] + ishft(FrameInfo[3,i],16) ;Even Field
    FieldOff[i*2+1] = FrameInfo[4,i] + ishft(FrameInfo[5,i],16) ;Odd Field
endfor

flast = (fstat(lun)).size       ;Last byte in file
for i=FramesInFile*2L - 1L, 0, -1 do $
  if FieldOff[i] ne -1 then begin
    FieldSiz[i] = flast - FieldOff[i]
    flast = FieldOff[i]
endif

if (nframes gt 1)  then dims = [dims, nframes]
field0 = make_array(DIMENSION=[dims[0], dims[1]], /BYTE, /NOZERO)
field1 = make_array(DIMENSION=[dims[0], dims[1]], /BYTE, /NOZERO)

do16 = type eq 12               ;TRUE for 16 bit pixels
if do16 then begin
    ifield0 = field0
    ifield1 = field0
endif else begin
    ifield0 = 0
    ifield1 = 0
endelse

if interlaced then dims[1] = 2 * dims[1]
image = make_array(DIMENSION=dims, TYPE=type,  /NOZERO)

for iframe = fstart, fstart+nframes-1 do begin ;Read each frame...
    if FieldOff[iframe*2] ne -1 then begin ;Even field
        point_lun, lun, FieldOff[iframe*2] ;1st image data
        Inited = 1L
        Sonos_Readrd, lun, field0, COMPRESS=compression, INIT=Inited, $
          BUFFER_SIZE=FieldSiz[iframe*2]
        if do16 then begin      ;Read even color field
            Sonos_Readrd, lun, ifield0, COMPRESS=compression, INIT=0
        endif
    endif
        
    if FieldOff[iframe*2+1] ne -1 then begin ;Odd field
        point_lun, lun, FieldOff[iframe*2+1]
        Inited = 1L
        Sonos_Readrd, lun, field1, COMPRESS=compression, INIT=Inited, $
          BUFFER_SIZE=FieldSiz[iframe*2+1]
        if do16 then begin      ;Read odd color field
            Sonos_Readrd, lun, ifield1, COMPRESS=compression, INIT=0
        endif
    endif else begin            ;Just copy even field
        field1 = field0
        ifield1 = ifield0
    endelse
    
    if FieldOff[iframe*2] eq -1 then begin ;No even, Copy odd field
        field0 = field1
        ifield0 = ifield1
    endif
    
    islice = iframe - fstart
    if do16 then begin       ;Make uints?
        ufield0 = field0 + ishft(uint(ifield0), 8)
        ufield1 = field1 + ishft(uint(ifield1), 8)

        if interlaced then begin ;Combine fields
            for j=0, dims[1]-1 do begin ;Each row
                image[0, j, islice] = $
                  (j and 1) ? ufield1[*, j/2] : ufield0[*, j/2]
            endfor
        endif else begin
            image[0,0,islice] = ufield0
        endelse
    endif else begin            ;Bytes
        if interlaced then begin ;Combine fields
            for j=0, dims[1]-1 do begin ;Each row
                image[0, j, islice] = (j and 1) ? field1[*, j/2] : field0[*,j/2]
            endfor
        endif else begin
            image[0,0,islice] = field0
        endelse
    endelse
endfor                          ;Iframe


free_lun, lun
return, image
end
