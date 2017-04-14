; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo_puttips.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
pro demo_putTips, $
    state, $        ; IN: tip structure is the sText field of this struct,
                    ; unless the NOSTATE keyword is set.
    textArray, $    ; IN: string array to change from current settings.
                    ; This can contain labels to match (use the LABEL keyword
                    ; or the actual strings to display.
    position, $     ; IN: 2-d index of each change expressed as a 2
                    ; digit number, column/row: e.g.
                    ; 12 = column1, row 2.  Offsets are 0
                    ; based, so the upper left field is 00.
    LABEL=label, $  ; IN (Opt): If set, the input string contains tag names
                    ; to look up.  Otherwise it contains the
                    ; actual text to display
    NOSTATE=sText   ; Specify the structure here if it is not contained in the
                    ; state parameter.  In this case, pass a dummy argument
                    ; of zero for the state param.

                    ; Dimensions of textArray and position are the same.

if not keyword_set(sText) then begin
   sText = state.sText
   resetState = 1
endif else resetState=0

wChange = bytarr(sText.ncols)   ;Changed text widget flags

for i=0, N_ELEMENTS(textArray)-1 do begin     ;Each changed field
    ix = position[i] / 10       ;Column index
    iy = position[i] mod 10     ;Row index
    if ix lt sText.ncols and iy lt sText.nrows then begin ;Existing slot?
        if keyword_set(label) then begin
            j = where(textArray[i] eq sText.tags, count)
            if count eq 0 then $
              message, 'Can not find tip tag <' + textArray[i] + '>'
            sText.contents[ix,iy] = Stext.text[j[0]]
        endif else begin
            sText.contents[ix,iy] = textArray[i]
        endelse
        wChange[ix] = 1         ;Show column has been changed
    endif                       ;ipos lt n
endfor

for ix = 0, sText.ncols-1 do $  ;Update only text widgets that are changed
   if wChange[ix] then $
      widget_control, sText.wTextId[ix], set_value=sText.contents[ix,*]

if resetState then state.sText = sText ;Store back in state

end                             ; of putTips
