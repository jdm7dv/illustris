pro HPColorMap, iMap, TABLE=tbl, GET_RGB=rgb
; If GET_RGB is present, return the original HP color tables in the
; variable, and return without affecting the color tables.

COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

if iMap ge 100 and iMap le 125 then begin
    j = iMap-100
    invert = 1
endif else begin
    j = iMap
    invert = 0
endelse
if j le 25 then begin           ;Color Flow.
    fname = 's5500'+string(byte('a') + byte(j)) + '.map'
endif 

; print, fname, invert
fname = 'maps/'+fname
openr, lun, fname, /GET_LUN, ERROR = i ;Read it, assume dir lcn

if i lt 0 then begin            ;Can't read file, fake it
    print, "Warning: Can't find color map file: ", fname
    if arg_present(rgb) then bw_table, GET_RGB=rgb $
    else bw_table, TABLE=tbl
    return
endif

a=bytarr(3, 256)                ;Only for 8 bit maps
readu, lun, a
free_lun, lun

if arg_present(rgb) then begin
    rgb = a
    return
endif

nc = !d.table_size
if nc lt 90 then $
  message,'There are not enough available colors for DSR display.', /INFO

a = transpose(a)                ;a is now a (256, 3) array
tvlct, a[200:255, *], nc-56
ind = bytscl(indgen(nc-56), top=199) ;Scale ramp colors to # of colors avail
if invert then ind = 199-ind
tvlct, a[ind, *]

tvlct,r,g,b,/get                ;Read back the colors
r_orig = r & r_curr = r         ;And save them
g_orig = g & g_curr = g
b_orig = b & b_curr = b

tbl = bindgen(256)              ;Create transformation table
tbl[200] = tbl[200:*] + (nc-256)
tbl[0] = bytscl(tbl[0:199], top=nc-57)

end


pro bw_table, index, BLACK=black, GRAY=gray, WHITE=white, TABLE=tbl, GET_RGB=rgb

; Load HP SONOS B&W Color map with either a black (0) , gray (1), or
; white (2), background.  Default = black.
;
; If GET_RGB is present, return the original HP color tables in the
; variable, and return without affecting the color tables.

COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

if n_params() eq 0 then index = keyword_set(white) ? 2 : $
  (keyword_set(gray) ? 1 : 0)
i = index > 0 < 2

; Table is [5,n], where [0,i] = 1st index to load, [1,i] = 2nd index
; to load, [2,i],[3,i],[4,i] = R,G,B for the two indices.

if i eq 0 then begin
    t = [ 200,201,   34,34,34, $ ;Black screen background
      202,203,   255,100,65, $
      204,205,   255,100,65, $
      206,218,   20, 50,33, $
      207,219,   21,67,35, $
      208,220,   22,85,38, $
      209,221,   22,98,42, $
      210,222,   23,108,45, $
      211,223,   23,117,48, $
      212,224,   24,127,51, $
      213,225,   24,133,52, $
      214,226,   25,141,55, $
      215,227,   25,148,57, $
      216,228,   25,155,59, $
      217,229,   25,161,61, $
      230,231,   18,18,18]
    t = [t, 232,233,   180,180,180, $
      234,235,   45,60,86, $
      236,237,   255,255,255, $
      238,239,   128,128,128, $
      240,241,   18,18,18, $
      242,243,   90,255,255, $
      244,245,   208,208,208, $
      246,247,   200,200,200, $
      248,249,   18,18,18, $
      250,251,   18,18,18, $
      252,253,   18,18,18, $
      254,255,   18,18,18]

endif else if i eq 1 then begin
    t =[ 200,201,   34,34,34, $ ;Gray screen background
      202,203,   255,100,65, $
      204,205,   255,100,65, $
      206,218,   32,80,53, $
      207,219,   31,87,54, $
      208,220,   31,95,54, $
      209,221,   30,102,55, $
      210,222,   29,110,56, $
      211,223,   28,117,57, $
      212,224,   28,124,57, $
      213,225,   27,132,58, $
      214,226,   27,139,59, $
      215,227,   26,147,60, $
      216,228,   26,154,60, $
      217,229,   25,161,61, $
      230,231,   63,63,63]
    t = [t, 232,233,   180,180,180, $
      234,235,   45,60,86, $
      236,237,   255,255,255, $
      238,239,   140,140,140, $
      240,241,   18,18,18, $
      242,243,   90,255,255, $
      244,245,   255,255,255, $
      246,247,   140,140,140, $
      248,249,   63,63,63, $
      250,251,   63,63,63, $
      252,253,   63,63,63, $
      254,255,   63,63,63]

endif else begin
    t =[ $                      ;white screen background
      200,201,   34,34,34, $
      202,203,   255,100,65, $
      204,205,   255,100,65, $
      206,218,   162,200,172, $
      207,219,   139,200,155, $
      208,220,   118,200,140, $
      209,221,   102,200,128, $
      210,222,   89,200,118,$
      211,223,   78,200,110,$
      212,224,   66,200,102,$
      213,225,   57,200,95,$
      214,226,   49,200,89,$
      215,227,   39,200,82,$
      216,228,   31,200,77, $
      217,229,   23,200,70,$
      230,231,   200,200,200]
    t = [t, 232,233,   18,18,18, $
      234,235,   60,124,220,$
      236,237,   255,255,255, $
      238,239,   92,92,92,$
      240,241,   18,18,18,$
      242,243,   90,255,255, $
      244,245,   18,18,18,$
      246,247,   200,200,200,$
      248,249,   200,200,200,$
      250,251,   200,200,200,$
      252,253,   200,200,200,$
      254,255,   200,200,200]
endelse

tbl = bytarr(3,56)
t = reform(t, 5, n_elements(t)/5, /OVERWRITE)
for i=0, n_elements(t)/5-1 do begin
    tbl[0, t[0,i]-200] = t[2:4,i]
    tbl[0, t[1,i]-200] = t[2:4,i]
endfor

if arg_present(rgb) then begin
    rgb = bytarr(3,256)
    for i=0, 199 do rgb[*,i] = i*255./199. ;1st 200 elements = ramp
    rgb[0,200] = tbl
    rgb = transpose(rgb)
    return
endif

nc = !d.table_size
if nc lt 90 then $
  message,'There are not enough available colors for DSR display.', /INFO

tvlct, transpose(tbl), nc-56      ;Load reserved portion of 56 colors

r = bytscl(indgen(nc - 56))     ;BW Ramp
tvlct,r,r,r                     ;Load bw portion

tbl = bindgen(256)              ;Create transformation table
tbl[200] = tbl[200:*] + (nc-256)
tbl[0] = bytscl(tbl[0:199], top=nc-57)
tvlct,r,g,b,/get
r_orig = r & r_curr = r
g_orig = g & g_curr = g
b_orig = b & b_curr = b
end
