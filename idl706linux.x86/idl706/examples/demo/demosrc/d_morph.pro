; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_morph.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_morph.pro
;
;  CALLING SEQUENCE: d_morph
;
;  PURPOSE:
;       Morph 2 images.
;
;  MAJOR TOPICS: Visualization and data analysis
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       fun d_morphBarycentric     -  Compute the barycentric matrix.
;       pro d_morphCompute         -  Compute the morphing images
;       pro d_morphEvent           -  Event handler
;       pro d_morphCleanup         -  Cleanup
;       pro d_morph                -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;
;       d_peopleReadImage
;       d_peopleReadIndex
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       morph_demo_common
;
;  MODifICATION HISTORY:
;       DS   - Written.
;-

forward_function d_peopleReadImage

;----------------------------------------------------------------------------
;
;  Purpose:  Compute and returns the barycentric matrix.
;
function d_morphBarycentric, $
    x, $
    y, $
    xt, $
    yt, $
    zt
    det = (xt[1]-xt[0]) * (yt[2]-yt[0]) - (xt[2]-xt[0]) * (yt[1]-yt[0])
    w0 = ((xt[1]-x) * (yt[2]-y) - (xt[2]-x) * (yt[1]-y)) / det
    w1 = ((xt[2]-x) * (yt[0]-y) - (xt[0]-x) * (yt[2]-y)) / det
    w2 = ((xt[0]-x) * (yt[1]-y) - (xt[1]-x) * (yt[0]-y)) / det
    PRINT, w0, w1, w2
    RETURN,w0 * zt[0] + w1 * zt[1] + w2 * zt[2]
end

;----------------------------------------------------------------------------
;
;  Purpose:  This procedure actually does the morphing.
;
pro d_morphCompute, $
    i0, $            ; IN: first image
    i1, $            ; IN: seconsd image
    x0, $            ; IN: x control point of first image
    y0, $            ; IN: y control point of first image
    x1, $            ; IN: x control point of second image
    y1, $            ; IN: y control point of second image
    nsteps, $        ; IN: number of transitions, including the 2 end images
    QUINTIC = quint  ; IN: (opt) indicates quintic interpolation.

    ncp = N_ELEMENTS(x0)
    if ( (ncp NE N_ELEMENTS(y0)) OR (ncp NE N_ELEMENTS(x1)) OR $
	(ncp NE N_ELEMENTS(y1)) ) then $
	MESSAGE, "Number of control points doesn't match"

    TRIANGULATE, x0, y0, tr, bounds
    TRIANGULATE, x1, y1, tr1, bounds1

    s = SIZE(i0)
    t = SIZE(i1)
    if (s[0] NE 2) OR (t[0] NE 2) OR (s[1] NE t[1]) OR (s[2] NE t[2]) then $
	MESSAGE,'Image dimensions inconsistent'
    nx = s[1]
    ny = s[2]

    gs = [1,1]
    b = [0,0,nx-1, ny-1]

    if (N_ELEMENTS(quint) EQ 0) then quint = 0

    ;  Call for the xinteranimate tool to display
    ;  the sequence of images.
    ;
    xinteranimate, set=[nx, ny, nsteps], /SHOWLOAD, /CYCLE

    for i=0, nsteps-1 do begin		;Each step
	t = FLOAT(i) / FLOAT(nsteps-1)  ;From 0.0 to 1.0
	xt = x0 + (x1-x0) * t		;From 1st to 2nd
	yt = y0 + (y1-y0) * t
	xt1 = x1 + t * (x0-x1)		;From 2nd to 1st
	yt1 = y1 + t * (y0-y1)
	im1 = INTERPOLATE(i1, $
	    TRIGRID(x0,y0,xt1,tr, gs, b, QUINT=quint), $
	    TRIGRID(x0,y0,yt1,tr, gs, b, QUINT=quint))
	im0 = INTERPOLATE(i0, $
	    TRIGRID(x1,y1,xt1,tr, gs, b, QUINT=quint), $
	    TRIGRID(x1,y1,yt1,tr, gs, b, QUINT=quint))
	im = BYTE(t * im1  + (1.0-T) * im0)
	xinteranimate, image=im, frame=i
    endfor
end


;----------------------------------------------------------------------------
;
;  Purpose:  Main event handler.
;
pro d_morphEvent, $
    sEvent     ; IN: event Structure

    common morph_demo_common, cmd_button, frames_button, msg, lun, image_in, $
	draw, draw_size, im_size, dwin, sx, nx, state, iindex, imlt, imrt, $
	ncp, cpx, cpy, nimages, offsets, nframes

    ;  Set to the morphing window.
    ;
    WSET, dwin	

    ;  Brancjh accoridingly to the event.
    ;
    case sEvent.id of

        ;  Handle a mouse button event occuring in the viewing area.
        ;
        frames_button: nframes = ([3,8,16,32])[sEvent.index]

        draw: begin

            ;  Returns if it is not a button press event.
            ;
            if (sEvent.press NE 0) then RETURN 

            ;  Selecting an image
            ;
            if (state LE 1) then begin
                im = ((draw_size > !d.y_size) - sEvent.y) / $
                    sx * nx + sEvent.x / sx
	        iindex[state] = im
	        if (state EQ 0) then WIDGET_CONTROL, msg, $
                    SET_VALUE='Select other image' $
	        else begin
	            WIDGET_CONTROL, msg, SET_VALUE='Pick LEFT control point' 
	            erase
	            for i=0,1 do begin
	                imrt = d_peopleReadImage(iindex[i], lun, offsets, $
		       	    LABEL=msg, /BW, REQUIRED=im_size)
		        TV, CONGRID(imrt, draw_size, draw_size), i*draw_size, 0
		        if (i EQ 0) then imlt = imrt
		    endfor
                endelse
	        state = state + 1
	        ncp = 0

            ;  Must be marking a control point (CP).
            ;
            endif else begin	
 
                ;  Right image case.
                ;
	        rt = (sEvent.x GE draw_size)

                ;  Scale to pixels.
                ;
	        x = (sEvent.x MOD draw_size) * im_size / $
                    draw_size 
	        y = sEvent.y * im_size / draw_size

                ;  If not the proper image, toss it.
                ;
	        if (rt NE (ncp AND 1)) then RETURN 

                ;  Mark the control point.
                ;
                PLOTS, sEvent.x, sEvent.y, /DEVICE, $
;                    COLOR=!D.N_COLORS-1, PSYM=2
                    COLOR=!D.TABLE_SIZE-1, PSYM=2
	        empty

                ;  First control point, else it is the second.
                ;
	        if ncp EQ 0 then begin
	            cpx = x
	            cpy = y
	        endif else begin
	            cpx = [cpx, x]
	            cpy = [cpy, y]
	        endelse

	        ncp = ncp + 1

                ;  Refreash the message text.
                ;
	        WIDGET_CONTROL, msg, SET_VALUE= $
	            'Mark the ' + (['LEFT','RIGHT'])[ncp and 1] + ' image.'

	        if (!Version.Os_Family NE 'MacOS') then $
                    TVCRS, sEvent.x - (2*rt-1) * draw_size, sEvent.y, /DEVICE $
                else TVCRS, 1
            endelse

        endcase      ;   of  draw

        cmd_button: begin

            ;  Branch to the approriate command button event.
            ;
            case sEvent.value of

                ;  Quit this application.
                ;
                'Done': begin
	            if (image_in EQ 0) then FREE_LUN, lun
	            WIDGET_CONTROL, sEvent.top, /DESTROY
	        endcase   ;  of Done

                'Help': begin
                    ONLINE_HELP, 'd_people', $
                       book=demo_filepath("idldemo.adp", $
                               SUBDIR=['examples','demo','demohelp']), $
                               /FULL_PATH
	        endcase  ;  of  Help

                ;  Remove the previous control points.
                ;
                'Delete CP': begin

                    ;  Return under certain conditions.
                    ;
	            if (state LE 1) then RETURN
	            if (ncp LE 0) then RETURN

                    ;  Verify the validity of this event and handle it.
                    ;
	            ncp = (ncp + (ncp and 1)) - 2

                    ;  If valid, set the control points.
                    ;
	            if (ncp gt 0) then begin
	                cpx = cpx[0:ncp-1]
	                cpy = cpy[0:ncp-1]
                    endif

	            TV, CONGRID(imlt, draw_size, draw_size), 0, 0
	            TV, CONGRID(imrt, draw_size, draw_size), draw_size, 0

	            for i=0, ncp-1 do $
	                PLOTS, cpx[i] * draw_size / $
                            im_size + (i and 1) * draw_size, $
		        cpy[i] * draw_size / im_size, /DEVICE, $
;                        PSYM=2, COLOR=!D.N_COLORS-1
                        PSYM=2, COLOR=!D.TABLE_SIZE-1

	            WIDGET_CONTROL, msg, SET_VALUE= 'Mark the left image.'
	        endcase  ;  of Delete CP (control points)

                ;  Restart the whole process.
                ;
                'Restart': begin	
	            ERASE
	            ncp = 0      ; number o fcontrol points.

	            if (image_in) then begin
	                TV, CONGRID(imlt, draw_size, draw_size), 0, 0
	                TV, CONGRID(imrt, draw_size, draw_size), draw_size, 0
	            endif else begin
	                TV, d_peopleReadImage(nimages, lun, $
                               offsets, LABEL=msg, /BW)
	                state = 0
	            endelse
	        endcase    ;  of Restart

                ;  Start the animation sequence.
                ;
                'Go' :  begin

                    ;  Show the hourglass during the processing of the event.
                    ;
                    WIDGET_CONTROL, sEvent.top, /HOURGLASS

                    ;  Return if the number of control points is less
                    ;  than 2 or the xinteranimate tool is already running.
                    ;
	            if (ncp LT 2) then RETURN
	            if (XREGISTERED("XInterAnimate")) then RETURN

	            i2 = indgen(ncp/2) * 2		;Alternate CPs
	            i1 = im_size -1
	            x0 = [cpx[i2], 0, i1, i1, 0]		;Add corners to CPs
	            x1 = [cpx[i2+1], 0, i1, i1, 0]
	            y0 = [cpy[i2], 0, 0, i1, i1]
	            y1 = [cpy[i2+1], 0, 0, i1, i1]
	            d_morphCompute, imlt, imrt, x0, y0, x1, y1, nframes
	            xinteranimate, 40, group = sEvent.top
	        endcase   ;  of Go

            endcase  ;    of sEvent.value

        endcase    ;  of cmd_button

        else: i2=0      ;  Dummy statement.

    endcase   ;  of sEvent.id
end
;-----------------------------------------------------------------
;
;    PURPOSE : Cleanup procedure. Restore colortable.
;
pro d_morphCleanup, wTopBase

    WIDGET_CONTROL, wTopBase, GET_UVALUE=sState, /NO_COPY

    if (WIDGET_INFO(sState.group, /VALID_ID)) then begin
        WIDGET_CONTROL, sState.group, SENSITIVE=1
    endif

    ;  Restore the color table.
    ;
    TVLCT, sState.colorTable
    imlt = 0 & imrt = 0         ;Clean up images
end   ;  of d_morphCleanup

;----------------------------------------------------------------------------
;
;  Purpose:  Main procedure. This application  aplies mophing of 2 images.
;
pro d_morph, $
    GROUP=Group, $              ; IN: (opt) group leader identifier
    im0, $                      ; IN: first image
    im1, $                      ; IN: second image
    USE_CURRENT=use_current, $  ; IN: (opt) use files in current directory
    FROM_PEOPLE=from_people     ; IN: (opt) indicate for use of people demo.

    ;+
    ; Demo for morphing.  If im0 and im1 are supplied, they are the two
    ; images to morph.  If not supplied, the people.dat file is read and
    ; the user selects two faces to morph.
    ;	USE_CURRENT = true to read from files in current directory.
    ;-

    common morph_demo_common

    nframes = 8
    if N_ELEMENTS(group) eq 0 then group = 0L

    if (group ne 0) then WIDGET_CONTROL, group, SENSITIVE=0 

    ;  Get the current color vectors to restore
    ;  when this application is exited.
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ;  Build color table from color vectors
    ;
    colorTable = [[savedR],[savedG],[savedB]]

    ;  Loads people demo , the people images, etc...
    ;
    if (N_ELEMENTS(im_size) EQ 0 and KEYWORD_SET(from_people) EQ 0) then begin
        if 0 then d_people      ;This makes sure we get .sav files right
       resolve_routine, 'd_people'
    endif

    ;  Have only one instance of morph_demo running.
    ;
    if (xregistered("d_morph")) then return
    im_size = 256
    image_in = N_ELEMENTS(im0) gt 2

    ;  Initilize the image size and the size of the drawing area.
    ;
    if (image_in) then im_size = (SIZE(im0))[1] ;We're passed images
    draw_size = 256 > im_size	;Size of drawable

    ;  Initialize other working variables and arrays.
    ;
    state = 0
    ncp = 0      ;  number of control points.
    iindex = INTARR(2)

    ;  Create the widgets, starting with the top level base.
    ;
    Base = WIDGET_BASE(Title='Morphing', /ROW)

        ;  Create the left base containing the control buttons
        ;  and the message text.
        ;
    left = WIDGET_BASE(base, /COLUMN)

    cmd_button = CW_BGROUP(left, /NO_REL, $
                           /RETURN_NAME, /COL, /FRAME, $
                           ['Done', 'Help', 'Restart', 'Delete CP', 'Go'])

    frames_button = WIDGET_DROPLIST(left, VALUE= ['3', '8', '16', '32'], $
                                    /FRAME, TITLE='Frames')
    WIDGET_CONTROL, frames_button, SET_DROPLIST_SELECT=1

            msg = WIDGET_TEXT(left, XSIZE=20, YSIZE=1, $
	        VALUE=(['Select two images', $
                         'Mark the left image.'])[image_in])

        siz = [draw_size*2, draw_size]
        DEVICE, get_screen=x

        if (NOT image_in) then siz = siz > ([384, 512])[x[0] gt 640]

        ;  Create the drawing area.
        ;
        draw = WIDGET_DRAW(base, xsize=siz[0], ysize=siz[1], /BUTTON_EVENTS)

    ;  Realize the widgets.
    ;
    WIDGET_CONTROL, base, /REALIZE

    WIDGET_CONTROL, draw, GET_VALUE=dwin
    WSET, dwin

    ;  Load the grey scale color table.
    ;
    loadct, 0

    ;  Display the initial images.
    ;
    if (image_in EQ 0) then begin  ;Initial display
        d_peopleReadIndex, names, offsets, USE_CURRENT=use_current
        nimages = N_ELEMENTS(names)
        nx = SQRT(nimages)      	;# of images across
        if (nx NE fix(nx)) then nx = nx + 1
        nx = fix(nx)
        sx = min(siz) / nx		;Size of image
        filename = 'people.jpg'
        if (KEYWORD_SET(use_current) EQ 0) then $
	    ;filename = demopath(filename, subdir='images')
            filename = demo_filepath(filename, SUBDIR=['examples','data'])

        OPENR, lun, /GET, filename, /STREAM

        TV, d_peopleReadImage(nimages, lun, offsets, $
            LABEL=msg, /BW, REQUIRED=min(siz))

    ;  Images passed in case.
    ;
    endif else begin			;Images passed in
        state=2
        imlt = im0
        imrt = im1
        TV, CONGRID(imlt, draw_size, draw_size), 0
        TV, CONGRID(imrt, draw_size, draw_size), 1
    endelse

    ;  Create the state structure.
    ;
    sState = { $
        ColorTable:colorTable, $
        Group: group $
    }

    WIDGET_CONTROL, Base, SET_UVALUE=sState, /NO_COPY

    Xmanager, 'd_morph', base, GROUP_LEADER=group, $ ;  , /NO_BLOCK
      EVENT_HANDLER='d_morphEvent', $
      CLEANUP='d_morphCleanup'
end
