; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_people.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_people.pro
;
;  CALLING SEQUENCE: d_people
;
;  PURPOSE:
;       Demonstrates image warping and morphing.
;
;  MAJOR TOPICS: Data analysis and images
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       fun d_peopleLuminance        - Set the images luminance
;       pro d_peopleReadIndex        - Get the index of the image
;       fun d_peopleReadImage        - read the people image
;       pro d_peopleLoadMorph        - Start up the morphing application
;       pro d_peopleDisplayEveryone  - Display the image of everyone
;       pro d_peopleDisplay          - Display the original image
;       pro d_peopleCorners          - Set up corners points for warping
;       pro d_peopleEvent            - Event handler
;       pro d_peopleCleanup          - Cleanup
;       pro d_people                 - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro d_morph             - Morphing application
;       pro demo_gettips        - Read the tip file and create widgets
;       pro demo_puttips        - Change tips text
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:  Written by:  DS, RSI
;                         Modified by DS,RSI,  February 1997
;-
;--------------------------------------------------------------------
;
;  Purpose:  Convert an RBG (3,n,m) image to Black & White.
;
function d_peopleLuminance, $
    Im, $      ; IN: image
    Ct         ; IN: number of images

    ;   Two ways to do this.
    ;
    ; r = FIX(FINDGEN(256) * .3 + 0.5)
    ; g = FIX(FINDGEN(256) * .59 + 0.5)
    ; b = FIX(FINDGEN(256) * .11 + 0.5)
    ; RETURN, BYTSCL(REFORM(r(im(0,*,*)) + g(im(1,*,*)) + b(im(2,*,*))))

    ;  If already quantized. Set luminance value to 0.3, o.59, 0.11
    ;  for RGB respectively.
    ;
    if (N_ELEMENTS(ct) GT 1) then begin
        rr = ROUND(ct[*,0] * .30)
        gg = ROUND(ct[*,1] * .59)
        bb = ROUND(ct[*,2] * .11)
        RETURN, BYTSCL(rr[im] + gg[im] + bb[im])
    endif else $
        RETURN, REFORM(BYTSCL(.3 * im[0,*,*] + $
            0.59 * im[1,*,*] + .11 * im[2,*,*], $
            TOP=!D.N_COLORS-1 < 256))
end

;--------------------------------------------------------------------
;
;  Purpose: Read the people index file: people.idx.
;           Store the names and offsetsn the output parameters.
;
pro d_peopleReadIndex, $
    names,  $               ; IN: string array containing the names.
    offsets, $             ; IN: image ofset index.
    USE_CURRENT=use_current ; IN: indicate to use the current data file.

    filename = 'people.idx'

    if (KEYWORD_SET(use_current) EQ 0) then $
        ;filename = demopath(filename, SUBDIR=['examples','data'])
        filename = demo_filepath(filename, SUBDIR=['examples','data'])

    OPENR, lun, filename, /GET, ERROR=i

    if (i NE 0) then message,'people.idx file not found'

    np = 0L			;The number of people
    READF, lun, np
    names = STRARR(np)
    offsets = LONARR(np+2)
    for i=0, np+1 do begin
        a='' & off = 0L
        READF, lun, off, a
        a = STRTRIM(a,2)   ;Remove leading & trailing
        offsets[i] = off
        if (i LT np) then names[i] = a
    endfor

    CLOSE, lun
    FREE_LUN, lun
end

;--------------------------------------------------------------------
;
;  Purpose  Read an image from the file and returns it.
;
function d_peopleReadImage, $
    index, $            ; IN: image index.
    lun, $              ; IN: file lun
    offsets, $         ; IN: image offset parameters.
    LABEL=lw, $         ; IN: (opt) Label or text widget to set to
                        ; "Reading JPEG" while reading
    REQUIRED_SIZE = reqs, $ ; IN: (opt) Set the image to this size.
    BW = bw, $          ; IN: (opt) if set, always return a black/white image
    QUANTIZE=quant


    ;  Handle the JPEG option (LABEL keyword).
    ;
    if (KEYWORD_SET(lw)) then begin
        WIDGET_CONTROL, lw, SET_VALUE='Decompressing JPEG image'
    endif

    point_lun, lun, offsets[index]

    ;  Read the JPEG image returned as jpegImage.
    ;
    if (KEYWORD_SET(quant) AND (!D.N_COLORS LE 256)) then begin
        read_jpeg, UNIT=lun, jpegImage, quant, COLORS=!D.N_COLORS-1, /TWO_PASS
    endif else if (KEYWORD_SET(bw)) then begin
        read_jpeg, unit = lun, jpegImage, /GRAYSCALE, COLORS=!D.TABLE_SIZE-1
    endif else begin
        read_jpeg, unit = lun, jpegImage
    endelse

    ;  Resize the image if needed.
    ;
    s = size(jpegImage)
    if (N_ELEMENTS(reqs) GT 0) then begin
        if (KEYWORD_SET(lw)) then WIDGET_CONTROL, lw, SET_VALUE='Resampling'

        if (s[0] EQ 3 AND s[2] NE reqs) then begin
            jpegImage = congrid(jpegImage, 3, reqs, reqs, /interp)
        endif

        if (s[0] EQ 2 AND s[1] NE reqs) then begin
            jpegImage = congrid(jpegImage, reqs, reqs)
        endif
    endif

    if (KEYWORD_SET(lw)) then WIDGET_CONTROL, lw, SET_VALUE=' '

    RETURN, jpegImage
end

;--------------------------------------------------------------------
;
;  Purpose Call the morphing routine.
;
pro d_peopleLoadMorph, $
    index, $  ; IN: image index
    top       ; IN: top base (parent) identifier

    ;  Construct the common variable bloc.
    ;
    common people_common, base, bases, window, draw, mode, names, np, $
	button, txt_wid, ncpnts, cpnts, dcolor, image, imagew, imagewq, $
	corners, x0, y0, x1, y1, siz, first, sx, $
	morph_flag, lun, offsets, plist, quintic, bw_loaded, face_loaded, ct, $
        sText, $   ;  tips structure
        controlbuttonID, $
	image_everyone, ct_everyone

    ;  Do morphing on the first image.
    ;
    if (morph_flag[0] EQ -1) then begin	;First image
	morph_flag = [index+1, 0]
        demo_putTips, 0, ['secon', 'lmbut'], [10,11], /LABEL, NOSTATE=sText
        demo_putTips, 0, '', 12, NOSTATE=sText
      
    ;  Do morphing on the second image.
    ;
    endif else if morph_flag[1] EQ 0 then begin
        demo_putTips, 0, ['selecto', 'mouse', 'show1'], [10,11,12], $
           /LABEL, NOSTATE=sText
        d_morph, GROUP=top, /FROM_PEOPLE, $
	    d_peopleReadImage(morph_flag[0]-1, lun, offsets, $
             REQ=256, /BW), $
            d_peopleReadImage(index, lun, offsets,  REQ=256, /BW)
	morph_flag = 0
    endif		;Morph_flag(1) EQ 0
end

;--------------------------------------------------------------------
;
;  Purpose  Display everyone images.
;
pro d_peopleDisplayEveryone
    common people_common

    if (N_ELEMENTS(ct_everyone) GT 1) then begin
        TVLCT, ct_everyone
        bw_loaded = 0
    endif else begin
        if (bw_loaded EQ 0) then LOADCT, 0, /silent
        bw_loaded = 1
    endelse

    if (size(image_everyone))[0] EQ 3 then tv, image_everyone, TRUE=1 $
    else tv, image_everyone
end
    
;--------------------------------------------------------------------
;
;  Purpose  Display the original image.
;
pro d_peopleDisplay, $
    Nmode, $  ; IN: = 1 to display original image with CP's
              ;     = 2 or warped image if available
              ;     = 3 for quintic warped
    ctable    ; IN: color table

    common people_common

    ;  Display  a color image.
    ;
    if (Nmode EQ 0) then begin
        s = size(image)
        image_true = s[0] EQ 3
        display_true = !D.N_COLORS GT 256

        if (N_ELEMENTS(ctable) GT 1) then begin
            TVLCT, ctable
            bw_loaded = 0
        endif else if (image_true EQ display_true) or (image_true EQ 0) then begin
            if bw_loaded EQ 0 then LOADCT,0, /SILENT ;Load bw
            bw_loaded = 1
        endif

        if (image_true AND display_true) then TV, image, TRUE=1 $
        else if (image_true EQ 0) then TV, image $
        else if (image_true) then begin   ;Load true color on indexed display
            tmp =  color_quan(image, 1, rr, gg, bb)
            erase
            TVLCT, rr, gg, bb
            TV, temporary(tmp)
            bw_loaded = 0
        endif
        RETURN
    endif

    ;  If we get here, we're displaying in monochrome.
    ;
    if (bw_loaded EQ 0) then LOADCT, 0, /SILENT ;Load bw table?
    bw_loaded = 1

    if (Nmode EQ mode) then RETURN
    mode = Nmode
    if (mode EQ 1) then begin
        TV, image
        DEVICE, SET_GRAPHICS=6	    ; XOR
        for i=0, ncpnts-1 do $      ; Redraw arrows
            ARROW, cpnts[0,i], cpnts[1,i], cpnts[2,i], cpnts[3,i], $
            COLOR=dcolor
        DEVICE, SET_GRAPHICS=3	    ; XOR
    endif else if ((mode EQ 2) AND (N_ELEMENTS(imagew) GT 2)) then $
        TV, imagew $
    else if ( (mode EQ 3) AND (N_ELEMENTS(imagewq) GT 2)) then $
        TV, imagewq

end

;--------------------------------------------------------------------
;
;  Purpose  Add corners if necessary. Returns the number
;           of corner points (n).
;
pro d_peopleCorners, $
    n     ;  OUT: number of corners.

    common people_common

    if ((corners) AND (ncpnts LT 96) ) then begin
        ix = (!d.x_size-1) * [0,1,1,0]
        iy = (!d.y_size-1) * [0,0,1,1]
        for i = 0, 3 do cpnts[0, i+ncpnts] = [ix[i], iy[i], ix[i], iy[i]]
        n = ncpnts + 3
    endif else n = ncpnts-1
end

;--------------------------------------------------------------------
;
;  Purpose  Main event handler.
;
pro d_peopleEvent, $
    sEvent    ; IN: event structure

    common people_common

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WSET, window

    ;  Handle a mouse button or motion event.
    ;
    if (sEvent.id EQ draw) then begin  

        ;  Handle the click on person's face.
        ;
        if (mode EQ 0) then begin
            if ((first EQ 0) OR (sEvent.press EQ 0)) then RETURN
            i = (sEvent.x / sx) + (siz/sx) * ((siz-sEvent.y) / sx)

            ;  Returns if not legitimate.
            ;
            if (i GE np) then RETURN   
            first = 1

            ;  Sensitize the warping button, desensitize the
            ;  morphing button.
            ;
            morphsz = size(morph_flag)
            if (morphsz[0] EQ 0) then begin
                if (morph_flag NE -1) then begin
                    WIDGET_CONTROL, controlButtonID[0], SENSITIVE=1
                    WIDGET_CONTROL, controlButtonID[1], SENSITIVE=0
                endif
            endif else if (morphsz[0] EQ 1) then begin
                if (morph_flag[1] NE 0) then begin
                    WIDGET_CONTROL, controlButtonID[0], SENSITIVE=1
                    WIDGET_CONTROL, controlButtonID[1], SENSITIVE=0
                endif
            endif

            goto, load_face

        endif

        dcolor = 255

        ;  Handle button press.
        ;
        if ((sEvent.press AND 1) NE 0) then begin

            if (button EQ 1) then RETURN
            d_peopleDisplay, 1
            DEVICE, SET_GRAPHICS=6  ; Use XOR drawing mode

            x1 = (x0 = sEvent.x)          ; Get 1st point
            y1 = (y0 = sEvent.y)
            button = 1
            PLOTS, [x0, x1],[y0, y1], COLOR=dcolor, /DEVICE ;new spot

            RETURN
        endif

        ;  Handle button release.
        ;
        if ((sEvent.release and 1) NE 0) then begin
            imagew = 0 & imagewq = 0
            PLOTS, [x0, x1],[y0, y1], COLOR=dcolor, /DEVICE ;Erase old
            arrow, x0, y0, x1, y1, COLOR=dcolor
            DEVICE, SET_GRAPHICS=3  ; Restore graphics mode
            button = 0

            if (ncpnts GE 99) then begin
                 too_many: $
                     demo_putTips, 0, 'tooma', 12, /LABEL, NOSTATE=sText

                 RETURN
            endif
            cpnts[0:3, ncpnts] = [ x0, y0, x1, y1] ; Save it
            ncpnts = ncpnts + 1 ; One more
            RETURN
        endif

        ;  Handle button motion.
        ;
        if (button) then begin
            PLOTS, [x0, x1],[y0, y1], COLOR=dcolor, /DEVICE ;Erase old
            x1 = sEvent.x > 0 < (!d.x_size-1) ;In range
            y1 = sEvent.y > 0 < (!d.y_size-1)
            PLOTS, [x0, x1],[y0, y1], COLOR=dcolor, /DEVICE ;Draw new
            RETURN
        endif                       ;Motion

        RETURN			;Ignore plain motion events

    endif   ;  of  sEvent.id EQ draw


    WIDGET_CONTROL, sEvent.top, /HOURGLASS

    ;  Handle the event of a pressed button.
    ;  (People button).
    ;
    if (sEvent.id EQ plist) then begin
        i = sEvent.index
        if (mode NE 0) then begin
        Load_person:	mode = 0 & morph_flag = 0
            WIDGET_CONTROL, bases[1], MAP=0
            WIDGET_CONTROL, bases[0], MAP=1
            imagew = 0 & imagewq = 0
            ncpnts = 0

            ;  Desensitize the warping button, sensitize the
            ;  morphing button.
            ;
            WIDGET_CONTROL, controlButtonID[0], SENSITIVE=0
            WIDGET_CONTROL, controlButtonID[1], SENSITIVE=1
        endif

        ;  Handle the press of the 'group' button.
        ;
        if (i EQ (np-1)) then begin  
            text = names[i]
            demo_putTips, 0, ['selecto', 'mouse', 'show1'], [10,11,12], $
               /LABEL, NOSTATE=sText
        show_everyone:
            erase
            mode = 0
            first = 1
            face_loaded = -1
            d_peopleDisplayEveryone
            image = 0

            ;  Desensitize the warping button, sensitize the
            ;  morphing button.
            ;
            WIDGET_CONTROL, controlButtonID[0], SENSITIVE=0
            WIDGET_CONTROL, controlButtonID[1], SENSITIVE=1

            RETURN
        endif

        ;  Display a new person.
        ;
        LOAD_FACE:
        WIDGET_CONTROL, sEvent.top, /HOURGLASS
        if (morph_flag[0] NE 0) then begin
            d_peopleLoadMorph, i[0], sEvent.top
            RETURN
        endif

        ;  Here, the event was bgenerated by selecting the 
        ;  person from the widget list.
        ;
        first = 0 	
        face_loaded = i[0]
        WIDGET_CONTROL, plist, SET_LIST_SELECT=face_loaded
        ct = 1
        image = d_peopleReadImage(face_loaded, lun, $
            offsets, REQ=siz, QUANTIZE=ct)

        WSET, window
        d_peopleDisplay, 0, ct
        image = 0 & imagewq = 0 & imagew = 0 ;No more warped
        demo_putTips, 0, ['','',names[i]], [10,11,12], NOSTATE=sText

        ;  Sensitize the warping button, desensitize the
        ;  morphing button.
        ;
        WIDGET_CONTROL, controlButtonID[0], SENSITIVE=1
        WIDGET_CONTROL, controlButtonID[1], SENSITIVE=0

        RETURN
    endif                           ;People button


    WIDGET_CONTROL, sEvent.id, GET_UVALUE=b

    ;  Handle the event from a compound widget button group.
    ;
    if (b EQ 'CW') then b = sEvent.value  ;A cw_bgroup button

    button = 0		;Mouse buttons are up now

    ;  Branch to the corresponding widget button event.
    ;
    case b of			;It must be a widget button event

        ;  Everyone button.
        ;
        'Group' : begin
        load_everyone:
            i = np - 1
            goto, Load_person

            ;  Desensitize the warping button, sensitize the
            ;  morphing button.
            ;
            WIDGET_CONTROL, controlButtonID[0], SENSITIVE=0
            WIDGET_CONTROL, controlButtonID[1], SENSITIVE=1

        endcase

        ;  Launch the color table tool.
        ;
        'Colors':  begin
            xLOADCT, GROUP=sEvent.top
            bw_loaded = 0
        endcase

        ;  Quit the application.
        ;
        'Quit': begin  
            image = 0 & imagew = 0 & imagewq = 0
            WIDGET_CONTROL, base, /DESTROY
            FREE_LUN, lun
        endcase

        ;  Display the information (help) file.
        ;
        "Help" : begin

            ONLINE_HELP, 'd_people', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
        endcase

        ;  Load the warping options (new menu).
        ;
        'Warping': begin
            if (mode NE 0) or face_loaded LT 0 then return
            image =  d_peopleReadImage(face_loaded, lun, offsets, $
                          REQ=siz, /BW)
            mode = 1             ;Set warping mode
            WIDGET_CONTROL, bases[0], MAP=0
            WIDGET_CONTROL, bases[1], MAP=1
            demo_putTips, 0, '', 10, NOSTATE=sText
            demo_putTips, 0, ['mark3', 'lmbut'], [11,12], $
               /LABEL, NOSTATE=sText

            if (bw_loaded EQ 0) then begin
                LOADCT,0,/silent
                TV, image
                bw_loaded = 1
            endif
        endcase

        ;  Load the morphing menu.
        ;
        "Morphing": begin
            morph_flag = -1
            WIDGET_CONTROL, bases[1], MAP=0
            WIDGET_CONTROL, bases[0], MAP=1
            demo_putTips, 0, ['sele2', 'lmbut'], [10,11], /LABEL, NOSTATE=sText
            demo_putTips, 0, '', 12, NOSTATE=sText
            text = 'Select two people'
            goto, show_everyone

        endcase

        
        ;  Launch the color table tool.
        ;
        "COLORS": begin
            xLOADCT, GROUP=sEvent.top
            bw_loaded = 0
        endcase

        ; "Done Warping": goto, back_to_people
        ;
        "Everyone": begin

            ;  Desensitize the warping button, sensitize the
            ;  morphing button.
            ;
            WIDGET_CONTROL, controlButtonID[0], SENSITIVE=0
            WIDGET_CONTROL, controlButtonID[1], SENSITIVE=1
            goto, load_everyone
        endcase

        ; ..........  Handle the warping panel..........

        ; Remove most recent tie point.
        ;
        "Undo": begin
            d_peopleDisplay, 1
            imagew = 0 & imagewq = 0
            if (ncpnts EQ 0) then return ;Anything?
            i = (ncpnts = ncpnts-1)
            DEVICE, SET_GRAPHICS=6	;Redraw last CP to erase
            arrow, cpnts[0,i], cpnts[1,i], cpnts[2,i], cpnts[3,i], $
                color=dcolor
            DEVICE, SET_GRAPHICS=3
        endcase

        ;  Set the corner options.
        ;
        "On":   corners = 1
        "Off":  corners = 0

        ;  Reset (display) the unwarped image.
        ;
        "Reset": begin
            imagew = 0 & imagewq = 0
            ncpnts = 0
            mode = 1
            TV, image
        endcase

        ;  Display the original image.
        ;
        "Original": begin
            d_peopleDisplay, 1
        endcase

        ;  Plot the warping surface function.
        ;
        "Surface": begin
            if (ncpnts + (corners*2) LT 3) then RETURN
            !P.MULTI=[0,1,2]        ;Double up
            d_peopleCorners, n

            for i=0,1 do begin      ;X and Y
                z = cpnts[i+2,*]

                if (i EQ 1) then $
                    p0 = REPLICATE(1,51) # (FINDGEN(51) * (siz/50.)) $
                else p0 = (FINDGEN(51) * (siz/50.)) # replicate(1,51)

                TRIANGULATE, cpnts[0,0:n], cpnts[1, 0:n], tr
                p = TRIGRID(cpnts[0,0:n], cpnts[1, 0:n],z[0:n], tr, $
                    QUINT= N_ELEMENTS(imagewq) GT 2)
                SURFACE, p - p0, TITLE=(['X','Y'])[i] + ' Deformation'
            endfor

            !P.MULTI=0
            mode = 5
        endcase

        ;  Set the warping function to linear.
        ;
        "Warp Linear": begin
            quintic = 0
            goto, do_warp
        endcase

        ;  Set the warping function to linear.
        ;
        "Warp Smooth":  begin
            quintic = 1
            do_warp: if ncpnts  + (corners*2) LT 3 then return
            d_peopleCorners, n

            if quintic and KEYWORD_SET(imagewq) EQ 0 then $
              imagewq = WARP_TRI(cpnts[2,0:n], cpnts[3,0:n], $
                  cpnts[0,0:n], cpnts[1,0:n], image, /QUINT)
            if (quintic EQ 0) and (KEYWORD_SET(imagew) EQ 0) then $
              imagew = WARP_TRI(cpnts[2,0:n], cpnts[3,0:n], $
                  cpnts[0,0:n], cpnts[1,0:n], image)

            d_peopleDisplay, 2+quintic ;Show warped image
        endcase

        ;  Animate the warping sequence.
        ;
        "Animate":  begin
            if (ncpnts + (corners*2)  LT 3) then return
            d_peopleCorners, n
            nframes = 12
            xinteranimate, SET=[siz, siz, nframes], /SHOWLOAD, /CYCLE
            TV, image               ;First frame = original
            xinteranimate, window=!d.window, frame=0
            cpx = cpnts[0,0:n]  & cpy = cpnts[1,0:n]
            for i=1, nframes-1 do begin
                t = i / (nframes-1.)
                x = (cpnts[2,0:n] - cpx) * t + cpx
                y = (cpnts[3,0:n] - cpy) * t + cpy
                TV, WARP_TRI(x,y, cpx, cpy, image, QUINT=quintic)
                xinteranimate, window=!d.window, frame=i
            endfor
            xinteranimate, 20, GROUP=sEvent.top
        endcase

        else:  help, /structure, sEvent ;Dunno...
    endcase                         ;String value
    RETURN
end

;--------------------------------------------------------------------
;
;  Purpose  Cleanup procedure.
;
Pro d_peopleCleanup, $
    wTopBase    ;  IN: identifier

    ;  Get the color table saved in the window's user value.
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sState,/No_Copy
  
    ;  Restore the previous color table.
    ;
    TVLCT, sState.previouscolorTable

    common people_common

    image = 0 & imagew = 0 & imagewq = 0
    image_everyone = 0 & ct_everyone = 0

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sState.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sState.groupBase, /MAP

end

;--------------------------------------------------------------------
;
;  Purpose  Main people procedure. This application shows
;           The images (digital photography) of several employees.
;           Moreover, the user can use the morphing and
;           the warping tools.
;
pro d_people, $
    USE_CURRENT=use_current, $; IN: (opt) use file in current directory.
    GROUP=group, $            ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTlb           ; OUT: (opt) TLB of this application

    common people_common

    if n_elements(group) eq 0 then group = 0L

    ;   Have one instance of the application running.
    ;
    if (xregistered("people")) then RETURN

    ;  Get the current color table. It will be restored when exiting.
    ;
    TVLCT, savedR, savedG, savedB, /GET
    previousColorTable = [[savedR],[savedG],[savedB]]

    drawbase = demo_startmes(GROUP=group)    ;  Create the starting up message.

    ;  Initialize working variable and arrays.
    ;
    mode = 0	                    ; Not warp mode
    button = 0			    ; Button status
    ncpnts = 0			    ; # of control pnts
    morph_flag = 0
    cpnts = fltarr(4,100)	    ; Control point array
    dcolor = 'aa'x		    ; XOR Drawing color
    DEVICE, GET_SCREEN_SIZE=x

    if (x[0] LT 800) then begin
        result = $
        DIALOG_MESSAGE('This application is optimized for 800 x 640 resolution.')
    endif

    if (x[0] LE 640) then siz=384 else siz = 512
    siz = 512			;Drawable size
    quintic = 0
    first = 1
    bw_loaded = 1
    face_loaded = -1
    corners = 1

    ;  Read the data file that contain the image of every employees.
    ;
    d_peopleReadIndex, names, offsets, USE_CURRENT=use_current
    filename = 'people.jpg'

    if (KEYWORD_SET(use_current) EQ 0) then  $
        filename = demo_filepath(filename, SUBDIR=['examples','data'])

    OPENR, lun, filename, /STREAM, /GET ;For VMS...

    names = [names, 'Group']	;Add last image
    np = N_ELEMENTS(names)

    nx = CEIL(SQRT(np-1))		;# of images across
    sx = siz / nx			;Size of image

    ;  Set the text font accrding to the hardware platform.
    ;
    version = WIDGET_INFO(/version)
    if (STRPOS(version.style, 'Windows') NE -1) then begin
        helb24 = 'arial*bold*24'    ;Fonts we might find on DOS
        helb18 = 'arial*bold*18'
        helb14 = 'arial*bold*14'
        hel14 =  'arial*14'
    endif else begin
        helb24 = '*helvetica-bold-r*240*' ;Fonts we use
        helb18 = '*helvetica-bold-r*180*'
        helb14 = '*helvetica-bold-r*140*'
        hel14 =  '*helvetica-medium-r*140*'
    endelse


    myScroll = x[0] LT 750      ;  Determine if the scroll bar is needed.

    ;  Create the widgets starting with the top level base.
    ;
    if myScroll then begin
        base = WIDGET_BASE(TITLE='Warping and Morphing', $
                           /TLB_KILL_REQUEST_EVENTS, $
                           MAP=0, $
                           SCROLL=myScroll, $
                           X_SCROLL_SIZE=x[0]-75, Y_SCROLL_SIZE=x[1]-75, $
                           MBAR=barBase, $
                           GROUP_LEADER=group, /COLUMN)
    endif else begin
        base = WIDGET_BASE(TITLE='Warping and Morphing', $
                           /TLB_KILL_REQUEST_EVENTS, $
                           MAP=0, $
                           MBAR=barBase, $
                GROUP_LEADER=group, /COLUMN)
    endelse

        wFileButton = WIDGET_BUTTON(barBase, VALUE='File', $
            UVALUE='File', /MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                UVALUE='Quit')

        wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', $
            UVALUE='HELP', /MENU, /HELP)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Warping and Morphing Demo', $
                UVALUE='Help')


        ;  Create a sub base.
        ;  
        wSubTopBase = WIDGET_BASE(base, /ROW)

        ;  Create the left side controls.
        ;
        left = WIDGET_BASE(wSubTopBase, /COLUMN)

        wLeftSub0Base = WIDGET_BASE(left, /COLUMN)

        ctl_buttons = CW_BGROUP(wLeftSub0Base, COLUMN=1, $
                                /FRAME, /NO_REL, /RETURN_NAME, $
                                IDS=controlButtonID, $
                                UVALUE='CW', $
                                ['Warping', 'Morphing', 'Group'])

            wLeftSubBase = WIDGET_BASE(left )

                bases = LONARR(2)
                for i=0,1 do bases[i] = WIDGET_BASE(wLeftSubBase, $
                    /COLUMN)

; Don't display the Group list item.  It's a matter of taste.  Hence
; the [0:np-2] and the (np-1) below.
                    plist = WIDGET_LIST(bases[0], $
                        VALUE=names[0:np-2], YSIZE=5 < (np-1))

                    ;  Create the control panel for warping.
                    ;
                    wWarp1BGroup = CW_BGROUP(bases[1],  $
                        /COLUMN, /NO_REL, /RETURN_NAME, $
                        UVALUE='CW', ['Undo', 'Reset'])

                    wWarp2BGroup = CW_BGROUP(bases[1], $
                        LABEL_TOP='View:', /FRAME, /RETURN_NAME, $
                        UVALUE='CW', /COLUMN, $
                        ['Warp Linear', 'Warp Smooth', $
                        'Animate', 'Original', $
                        'Surface', 'Reset'])

                    wWarp3BGroup = CW_BGROUP(bases[1], $
                        ['Off','On'], LABEL_TOP = 'Mark Corners', $
                        UVALUE='CW', /COLUMN, /RETURN_NAME, $
                        /NO_REL, /EXCLUSIVE, $
                        SET_VALUE=corners)

        ;  Create the drawable in the center.
        ;
        center = WIDGET_BASE(wSubTopBase, /COLUMN)

            ;  Create a sub base in the center, and frame it.
            ;
            wCenterSubBase = WIDGET_BASE(center, /FRAME)

                draw = widget_draw(wCenterSubBase, $
                    XSIZE=siz, YSIZE=siz, RETAIN=2, $
                    /BUTTON_EVENTS, /MOTION_EVENTS, COLORS=-5)

        ;  Create the status line label.
        ;
        wStatusBase = WIDGET_BASE(base, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, /REALIZE, base

    appTLB = base

    WIDGET_CONTROL, bases[1], MAP=0
    WIDGET_CONTROL, draw, GET_VALUE = window

    ERASE

    sText = demo_getTips(demo_filepath('people.tip', $ ;  Get the tips.
                                  SUBDIR=['examples','demo','demotext']), $
                         Base, wStatusBase)

    ;  Load the grey scale color table.
    ;
    LOADCT, 0, /SILENT

    ;  Display the image that contains all the employees.
    ;
    ct_everyone = 1
    image_everyone = d_peopleReadImage(np-1, lun, offsets, $
        REQUIRED_SIZE=siz, QUANTIZE=ct_everyone)
    d_peopleDisplayEveryone

    ;  Create the state structure and make it the user value
    ;  of the top level base.
    ;
    sState = { $
        previousColorTable: previousColorTable, $
        groupBase: group $      ; Base of Group Leader
    }
    WIDGET_CONTROL, base, SET_UVALUE=sState, /NO_COPY

    ;  Desensitize the warping button.
    ;
    WIDGET_CONTROL, controlButtonID[0], SENSITIVE=0

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, base, MAP=1


    ;  Register with xmamager.
    ;
    XManager, "d_people", base, EVENT_HANDLER = 'd_peopleEvent', $
	CLEANUP='d_peopleCleanup', /NO_BLOCK
end
