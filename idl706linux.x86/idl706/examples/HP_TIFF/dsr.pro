Function TIFFKey, index, keys, values
i = where(index eq keys, count)
if count le 0 then message, 'Key ' + strtrim(index,2) + $
  ' not found in TIFF header.'
return, *(values[i[0]])
end


pro Sonos_demo_clean, id
widget_control, id, GET_UVALUE=status
ptr_free, status.ptr
end

pro Sonos_demo_event, event
if (TAG_NAMES(event, /STRUCTURE_NAME) EQ $ ;Was application closed?
    'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, event.top, /DESTROY
    RETURN
endif

WIDGET_CONTROL, event.id, GET_UVALUE=eventval
WIDGET_CONTROL, event.top, GET_UVALUE=status

case eventval of

    'SLIDER': begin
        wset, status.win
        widget_control, status.slider, GET_VALUE=frame
        if frame ge 0 and frame lt status.nframes then begin
            table = status.table
            tv, table[(*status.ptr)[*,*,frame]], /ORDER
        endif
    endcase

    'Contrast': begin
        wset, status.win
        nc = !d.table_size      ;# of colors we have
        s = size(*status.ptr)
        frame = 0
        if status.slider ne 0 then $
          widget_control, status.slider, GET_VALUE=frame
        a = (*status.ptr)[*,*,frame < s[3]]
        if event.value eq 'Restore' then begin
            bw_table, TABLE=table ;Restore orig table
        endif else begin
            table = status.table
            v = where(a lt 200b, count)
            h = histogram(a[v]) ;Get the histogram...
            for i=1,n_elements(h)-1 do h[i] = h[i]+h[i-1] ;Cumulative
            nc = !d.table_size
            case event.value of
                'Histogram Equalize': table[0] = bytscl(h[0:199], top = nc-57)
                '2% Stretch': begin
                    thr = 0.02 * count & goto, do_stretch & endcase
                '5% Stretch': begin
                    thr = 0.05 * count
                    DO_STRETCH: low = 0L & high = 199L
                    while h[low] lt thr do low = low + 1
                    while h[high] ge (count-thr) do high = high - 1L
                    table[0] = bytscl(indgen(200), top=nc-57, MIN=low, MAX=high)
                endcase
            endcase
        endelse
        tv, table[a], /order
        status.table = table
    endcase

    'Colors': begin
        xloadct, NCOLORS = !d.table_size-57, GROUP = event.top
    endcase

    'ROI': begin
        s = size(*status.ptr)
        WIDGET_CONTROL, status.draw, /DRAW_MOTION, /DRAW_BUTTON
        r = CW_DEFROI(status.draw, IMAGE_SIZE=[s[1], s[2]], /ORDER)
        WIDGET_CONTROL, status.draw, DRAW_MOTION=0, DRAW_BUTTON=0
        y = fltarr(status.nframes)
        for i=0, status.nframes-1 do $ ;Get counts
            y[i] = total(((*status.ptr)[*,*,i])[r])
        IPLOT, y, xtitle="X", ytitle="Y", name="Intensity", /NO_SAVEPROMPT
        idtool=itgetcurrent(tool=otool)
        void=otool->DoAction('Operations/Insert/Legend')
    endcase

    'Animate' : begin
        s = size(*status.ptr)
        xinteranimate, set = [s[1], s[2], s[3]], /SHOWLOAD, GROUP=event.top
        tbl = status.table
        for i=0, s[3]-1 do begin
            tv, tbl[(*status.ptr)[*,*,i]], /ORDER
            xinteranimate, FRAME=i, WINDOW=!d.window
        endfor
        xinteranimate, 30, GROUP=event.top
        wset, status.win
    endcase

    'Save As TIFF' : begin
        outfile = dialog_pickfile(FILTER='*.tif', /WRITE)
        bw_table, GET_RGB=rgb
        catch, i
        if i ne 0 then begin
            junk = dialog_message('Could not create file: '+outfile, /ERROR)
            return
        endif

        Write_TIFF, outfile, (*status.ptr)[*,*,0], COMPRESSION=2, $
          RED=rgb[*,0], GREEN=rgb[*,1], BLUE=rgb[*,2]
        wset, status.win
        s = size(*status.ptr)
        tbl = status.table
        for i=1, s[3]-1 do begin
            tv, tbl[(*status.ptr)[*,*,i]], /ORDER
            if status.slider ne 0 then $
              WIDGET_CONTROL, status.slider, SET_VALUE=i
            Write_TIFF, outfile, (*status.ptr)[*,*,i], COMPRESSION=2, /APPEND
        endfor
    endcase

    'Exit' : begin
        widget_control, event.top, /destroy
        return
    endcase
else: print, eventval, " didn't match."
endcase


WIDGET_CONTROL, event.top, SET_UVALUE=status
end

pro dsr, Filename

if n_elements(filename) eq 0 then $
  filename = dialog_pickfile(FILTER='*.tif', /MUST_EXIST)

if strlen(filename) eq 0 then return ;Cancelled

catch, i
if i ne 0 then begin
    widget_control, junk, /DESTROY
    junk = dialog_message('Could not read file: '+filename + $
                          '. ' + strmessage(i), /ERROR)
    return
endif

junk = widget_base(/COLUMN)
junk1 = widget_label(junk, value='Reading: '+filename)
widget_control, junk,/realize
t = systime(1)

a = SONOS_read(filename, /EIGHT_BIT_ONLY, TAGKEYS=keys, TAGVALUES=tvalues)
ImageMapType = TIFFKey(33786, keys, tvalues) ;Extract color map value
ColorMapSettings = TIFFKey(33789, keys, tvalues)
ptr_free, tvalues               ;Done with tag values

s = size(a)
print, 'Dims = ', strtrim(s[1:3],1), 'Time: ', systime(1)-t
; print, 'ImageMapType = ', ImageMapType
; Print, 'ColorMapSettings = ', Colormapsettings

nframes = s[3]
catch, /CANCEL
widget_control, junk, /DESTROY

Base = WIDGET_BASE(TITLE=filename, $ ;Main base, not mapped yet
                   /TLB_KILL_REQUEST_EVENTS, $
                   TLB_FRAME_ATTR=1, $
                   MBAR=bar_base, /ROW)
left = widget_base(base, /COLUMN)
right = widget_base(base, /COLUMN)

junk = cw_pdmenu(left, /RETURN_NAME, UVALUE='Contrast', $
                 ['3\Contrast Enhancement', '0\Histogram Equalize', $
                  '0\2% Stretch', '0\5% Stretch', '2\Restore'])

MenuItems = ['Colors', 'Save As TIFF'] ;Items for any study
if nframes gt 1 then $          ;Add multi frame facilities
  MenuItems = [MenuItems, 'ROI', 'Animate']
MenuItems = [MenuItems, 'Exit'] ;And exit on the end.

for i=0, n_elements(MenuItems)-1 do $
  junk = WIDGET_BUTTON(left, VALUE=MenuItems[i], UVALUE=MenuItems[i])

draw = widget_draw(right, xsize=s[1], ysize=s[2], RETAIN=1)

if nframes gt 1 then begin
    junk = widget_base(right, /row)
    junk1 = widget_label(junk, VALUE='Frame: ')
    slider = widget_slider(junk, /DRAG, MAXIMUM=nframes-1, $
                         XSIZE=256, UVALUE='SLIDER')
endif else slider = 0L

widget_control, base, /realize
widget_control, draw, GET_VALUE=win

bw_table, TABLE=tbl             ;Default color map
; if ImageMapType eq 0 then begin ;Simple bw file?
;     HPColorMap, ColorMapSettings[0], TABLE=tbl
; endif

status = { filename: filename, $
           draw: draw, $
           win: win, $
           table: tbl, $        ;save lookup table
           slider : slider, $
           nframes : nframes, $
           ImageMapType : ImageMapType, $
           ColorMapSettings : ColorMapSettings, $
           ptr : ptr_new(a, /NO_COPY) }

wset, status.win
erase
tv, tbl[(*status.ptr)[*,*,0]], /ORDER
widget_control, base, SET_UVALUE=status

xmanager, 'SONOS_DEMO', base, /NO_BLOCK, CLEANUP='Sonos_demo_clean'
end
