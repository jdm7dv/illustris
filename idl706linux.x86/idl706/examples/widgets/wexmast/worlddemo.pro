; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/worlddemo.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

pro world_demo_color		;Load color table suitable for elev data.
COMPILE_OPT hidden

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

ON_ERROR, 2

; Define interpolation points:  (elevation in meters, r, g, b)
; be sure elevation of 1st element is -5000 (data value 0), and last is
; 5240 (data value 256).
c = fltarr(256, 3)
p = [	[ -5000, 64, 64, 64], $		;Dark Gray at 0
	[ -4900, 0, 0, 128], $		;Dim blue
	[ -1500, 0, 0, 255], $		;Bright blue
	[ -40, 192, 192, 255], $
	[ 0, 64, 192, 64], $		;Med green
	[ 250, 150, 150, 75], $		;Dim Yellow
	[ 1000, 200, 200, 100], $	;Brighter yellow
	[ 4000, 255, 255, 255], $	;White
	[ 5240, 255, 255, 255]]		;To white

n = n_elements(p)/4
for i=0,n-2 do begin		;Intervals
	s0 = (p[0,i]+5000) / 40	;Color index
	s1 = (p[0,i+1]+5000) / 40
	m = s1 - s0
	for j=0,2 do begin	;Each color
		s = float(p[j+1,i+1] - p[j+1,i]) / m
		c[s0, j] = findgen(m) * s + p[j+1,i]
		endfor
	endfor
r_orig = byte(c[*,0])
g_orig = byte(c[*,1])
b_orig = byte(c[*,2])
r_curr = r_orig
g_curr = g_orig
b_curr = b_orig
tvlct,r_orig, g_orig, b_orig
end

PRO WORLDDEMO_EVENT, EVENT
COMPILE_OPT hidden
;THIS IS THE WORLDROT EVENT HANDLER

;COMMON BLOCK
;

COMMON world_block,projection,minlon,maxlon,minlat,maxlat,viewlat,width,$
                   height,numframes,cna,dne,theproj,base,names,help,$
		   rotangle,message,adjust,$
		   drawcon,nocon,drawgrid, nogrid, im,$
		   bilinear,nointerp,con,grid,bilin, imsize

ON_ERROR, 2

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; This IF THEN ELSE handles clicking on the exclusive menu of projections.
; The variable 'projection' was set with the 'buttons' keyword when the
; exclusive menu of projections was created.
; The WHERE expression sets the value of 'projflag' to 1 if one of the
; exclusive buttons is clicked on.  The variable 'projselection' will also
; hold the index of the button touched.

IF eventval EQ 'THEMENU' THEN BEGIN

    projselection = WHERE(projection EQ event.value, i)

    IF i NE 0 THEN theproj = projselection[0]
    RETURN
ENDIF

;If something other than a exclusive button has been touched, manage the event
;with this CASE statement.

CASE eventval OF
	"CREATE":BEGIN

		;If Xinteranimate is already going, DON'T DO THIS:
		IF (XREGISTERED("XInterAnimate") NE 0) THEN RETURN

		;If the Create New Animation Button is pressed,
		;read the values of all of the widgets from the tool.
		;Projection number is already in THEPROJ.

		;Read the Info about Image fields:
		lon1 = -180
                lon2 = 180
                lat1 = -90
                lat2 = 90

		;Read the Latitude to be Centered slider:
                WIDGET_CONTROL, viewlat, GET_VALUE   = vlat

		;The Rotation of North slider:
		WIDGET_CONTROL, rotangle,GET_VALUE   = rot

		;The size of the animation window:
                WIDGET_CONTROL, width, GET_VALUE     = wide
                WIDGET_CONTROL, height, GET_VALUE    = high

		;The number of frames to be generated:
                WIDGET_CONTROL, numframes, GET_VALUE = nframes

		;The Latitude and Longitude sampling parameters:
		lts = 30 < imsize[1]
		lns = 30 < imsize[0]

		;These numbers get returned as arrays. Turn them into scalars:
		nframes = nframes[0]
		high = high[0]
		wide = wide[0]
		lon1=lon1[0]
		lon2=lon2[0]
		lat1=lat1[0]
		lat2=lat2[0]
		vlat=vlat[0]
		rot=rot[0]


		;Make the Worldrot Widget insensitive.
		WIDGET_CONTROL, base, SENSITIVE=0

		;Convert THEPROJ to correct argument to proj keyword.
		;CONVECT maps the projection menu into correct proj keyvalue:
		convect = [15,  6, 8, 5, 4, 9, 10, 2, 14, 1]
		p = convect[theproj]

		;Make the title for XinterAnimate window:
		title = 'Rotating ' + names[theproj] + ' Projection'

		;Make Animation Frames:
        	XINTERANIMATE, SET = [wide, high, nframes], $
				     TITLE=title, GROUP = event.top, $
				     /SHOWLOAD

        	FOR i=0,nframes-1 DO BEGIN
		  ;Make the 'Frame n of x created.' message:
                  mess = 	'Frame '+ STRING(i+1, format='(I0)') + $
			' of ' + STRING(nframes, FORMAT='(I0)')+' created.'

		   ;Set up the map projection:
		   step = i * 360. / nframes
		   MAP_SET, vlat, step, rot, PROJ=p

			;Warp the image and show it
		   Tv, MAP_IMAGE(im, startx, starty, /WHOLE, $
			BILINEAR = bilin), startx, starty
		   xyouts, 0, 0, /device, strtrim(fix(step),2), siz=1.5

			;Draw the continents and gridlines:
		   IF (grid EQ 1) THEN BEGIN
			DEVICE, SET_GRAPHICS_FUNCTION=6 ;XOR
			MAP_GRID, COLOR = !d.n_colors-1, $
					latdel=15, londel = 15
			DEVICE, SET_GRAPHICS_FUNCTION=3 ;NORMAL
			ENDIF

		   IF con EQ 1 THEN MAP_CONTINENTS, COLOR = 255

			;Put the message in the message window:
		   WIDGET_CONTROL, message, SET_VALUE = mess

			;Put the new frame into the Xinteranimate tool:
                   XINTERANIMATE, FRAME = i, WINDOW = !D.WINDOW
        	ENDFOR


		;Call the Animation Tool & display new message
		WIDGET_CONTROL, message, $
			SET_VALUE=['Displaying Animation Tool']
		XINTERANIMATE, 20, GROUP = event.top

		;Resensitize the Worldrot Widget

		WIDGET_CONTROL, base, /SENSITIVE
		WIDGET_CONTROL, message, SET_VALUE = adjust

		END ;Create case

    "DRAWGRID": grid = 1	;Turn grid drawing ON.
      "NOGRID": grid = 0	;Turn grid drawing OFF.

     "DRAWCON": con = 1		;Turn continent drawing ON.
       "NOCON": con = 0		;Turn continent drawing OFF.

    "BILINEAR": bilin = 1	;Turn bilinear interpolation ON.
    "NOINTERP": bilin = 0	;Turn bilinear interpolation OFF.

  "LOAD_ELEV": BEGIN
		world_demo_color
		openr, unit, /GET_LUN, FILEPATH('worldelv.dat', $
                       sub=['examples','data'])
		im = bytarr(360,360, /NOZERO)
		readu, unit, im
		free_lun, unit
		im = shift(im, 180, 0)		;Align -180 w/ left edge.
		imsize = [360, 360]
		ENDCASE
	"HELP": BEGIN
		;If HELP is pressed, display the help file.
		XDISPLAYFILE, FILEPATH('wordemohelp.txt', $
				   SUBDIR=['examples', 'widgets', 'wexmast']), $
			GROUP = event.top, TITLE = 'World Rotation Demo Help'
		END ;Help case

	"FILE": BEGIN
		;If "Get a New Image" is pressed, use XGETDATA to retrieve the new image:
		oldim = im
		oldimsize = imsize
		XGETDATA, im, /TWO_DIM, OFILENAME = fname, $
			TITLE='Select an Image to Warp to the Map', $
			GROUP = event.top, DIMENSIONS = imsize
	;If the "Cancel" button on XGETDATA is pressed, keep the old image:
		s = SIZE(im)
		IF s[0] EQ 0 THEN BEGIN
			im = oldim
			imsize = oldimsize
		ENDIF ELSE BEGIN
		  if fname eq 'worldrot.dat' then im = shift(im, 180 ,0)
		ENDELSE
	ENDCASE

	"DONE": BEGIN
		WIDGET_CONTROL, event.top, /DESTROY	;If 'Done' is pressed,
							;destroy all widgets
							;and return to IDL.
		im = 0			;Free some memory
		ENDCASE
	  ELSE: donothing=0	;If nothing is pressed, don't do anything.

	ENDCASE

END



; !!! MAKE THE ACTUAL WIDGETS !!!

PRO worlddemo, GROUP = GROUP, im1


; COMMON BLOCK
COMMON world_block,projection,minlon,maxlon,minlat,maxlat,viewlat,width,$
                   height,numframes,cna,dne,theproj,base,names,help,$
		   rotangle,message,adjust,$
		   drawcon,nocon,drawgrid,nogrid,im, $
		   bilinear,nointerp,con,grid,bilin, imsize

ON_ERROR, 2
; Only one copy of WORLDROT can run at a time due to the COMMON block.
; Check for other copies and do nothing if WORLDROT is already running:

IF(XRegistered("worldrot") NE 0) THEN RETURN

base = WIDGET_BASE(TITLE='World Rotation Demo', /ROW) ;MAIN WIDGET BASE

if n_elements(im1) lt 10 then begin
	XGETDATA, im, /TWO_DIM, DIMENSIONS = imsize, OFILENAME = fname, $
		TITLE='Select an Image to Warp to the Map', GROUP = base
ENDIF ELSE BEGIN
	im = im1		;Copy to common
	fname = 'xx'
	imsize = size(im)
	if imsize[0] ne 2 then message,'WORLDDEMO: parameter not image'
	imsize = imsize[1:2]
ENDELSE

; If XGETDATA's cancel button was hit, don't continue.  Otherwise, do it to it:
s = SIZE(im)
IF s[0] GT 0 THEN BEGIN
  if fname eq 'worldelv.dat' then im = shift(im, 180, 0)  ;Warp -180 to left

;WORLD ROTATION TOOL HAS 3 MAIN COLUMNS
lcol = WIDGET_BASE(base, /FRAME, /COLUMN)	;Left column.
mcol = WIDGET_BASE(base, /FRAME, /COLUMN)	;Middle column.


;LEFT COLUMN IS THE EXCLUSIVE MENU OF PROJECTION TYPES, BUTTONS, AND OPTIONS
lpad = WIDGET_BASE(lcol, /FRAME, /ROW)

;The SPIN IT button:

spin = 	[				$
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 048B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 240B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 240B, 003B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 015B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 063B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 003B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 015B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 031B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 063B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 063B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 015B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 003B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 063B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 031B, 000B], $
	[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 007B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 240B, 001B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 112B, 000B, 000B], $
	[252B, 249B, 099B, 134B, 129B, 249B, 007B, 048B, 000B, 000B], $
	[252B, 249B, 103B, 142B, 129B, 249B, 007B, 000B, 000B, 000B], $
	[006B, 024B, 102B, 142B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[006B, 024B, 102B, 158B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[006B, 024B, 102B, 150B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[124B, 248B, 099B, 182B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[248B, 248B, 099B, 166B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[128B, 025B, 096B, 230B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[128B, 025B, 096B, 198B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[128B, 025B, 096B, 198B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[254B, 024B, 096B, 134B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[254B, 024B, 096B, 134B, 129B, 193B, 000B, 000B, 000B, 000B], $
	[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B] $
	]



dne = WIDGET_BUTTON(lpad, VALUE = 'Done', UVALUE = 'DONE')

; Make the cool bitmap SPIN IT button if Motif, if Open Look, don't bother:

VERSION	= WIDGET_INFO(/VERSION)
IF (VERSION.STYLE EQ 'OPEN LOOK') THEN $
cna = WIDGET_BUTTON(lpad, VALUE = 'Spin World', UVALUE = 'CREATE') $
ELSE $
cna = WIDGET_BUTTON(lpad, VALUE = spin, UVALUE = 'CREATE')
;file = WIDGET_BUTTON(lpad, VALUE = 'Get a New Image', UVALUE = 'FILE')
help = WIDGET_BUTTON(lpad, VALUE = 'Help', UVALUE = 'HELP')


;The text for the exclusive projection buttons:
names = ['Aitoff', 'Azimuthal Equidistant', 'Cylindrical', 'Gnomonic', $
	'Lambert''s Equal Area', $
        'Mercator', 'Mollweide', 'Orthographic', 'Sinusoidal', $
        'Stereographic']

;Make the exclusive projection list. Turn release events off:
title = WIDGET_BASE(lcol, /FRAME, /COLUMN)
label = WIDGET_LABEL(title, VALUE='Map Projection')
first_menu_id = CW_BGROUP(title, names, /EXCLUSIVE, /NO_RELEASE, $
                          IDS = projection, UVALUE = 'THEMENU', $
                          /COLUMN, /FRAME, /RETURN_ID)

drawlabel = WIDGET_LABEL(lcol, VALUE = 'Drawing Options:')

;This is the two-button 'toggle' switch for continent drawing:
conbase = WIDGET_BASE(lcol, /ROW, /FRAME, /EXCLUSIVE)
drawcon = WIDGET_BUTTON(conbase, VALUE='Draw Continents', UVALUE='DRAWCON',$
			/NO_RELEASE)
nocon = WIDGET_BUTTON(conbase, VALUE='No Continents', UVALUE='NOCON',$
		      /NO_RELEASE)

;This is the two-button 'toggle' switch for grid drawing:
gridbase = WIDGET_BASE(lcol, /ROW, /FRAME, /EXCLUSIVE)
drawgrid = WIDGET_BUTTON(gridbase, VALUE='Draw Grid', UVALUE='DRAWGRID',$
			 /NO_RELEASE)
nogrid = WIDGET_BUTTON(gridbase, VALUE='No Grid', UVALUE='NOGRID',$
		       /NO_RELEASE)

;This is the two-button 'toggle' switch for bilinear interpolation:
bilinbase = WIDGET_BASE(lcol, /ROW, /FRAME, /EXCLUSIVE)
bilinear = WIDGET_BUTTON(bilinbase, VALUE='Bilinear Interpolation', $
			 UVALUE='BILINEAR', /NO_RELEASE)
nointerp = WIDGET_BUTTON(bilinbase, VALUE='No Interpolation', $
			 UVALUE='NOINTERP', /NO_RELEASE)

junk = WIDGET_BUTTON(lcol, VALUE='Load Elevation Data', /NO_REL, $
	UVALUE="LOAD_ELEV")

;MIDDLE COLUMN HAS LOTS OF STUFF

viewlabel = WIDGET_LABEL(mcol, VALUE = 'Viewing Options:')

mcol2 = WIDGET_BASE(mcol, /FRAME, /COLUMN)

viewlat = WIDGET_SLIDER(mcol2, TITLE = 'Latitude to be Centered', $
                        MINIMUM = -90, MAXIMUM = 90, VALUE = 0, $
			UVALUE = 'latslider')

;The 'Rotation of North' slider:
rotangle = WIDGET_SLIDER(mcol2, TITLE = 'Rotation of North', $
			 MINIMUM = -180, MAXIMUM = 180, VALUE = 0, $
			 UVALUE = 'rotslider', XSIZE = 255)



;RIGHT COLUMN HAS SLIDER AND BUTTONS

;The 'Animation Window Size' fields:
winbase =  WIDGET_BASE(mcol, /COLUMN, /FRAME)
wintitle = WIDGET_LABEL(winbase, VALUE='Animation Window Size:')
w5 = WIDGET_BASE(winbase, /ROW)

w15 = WIDGET_LABEL(w5, VALUE = 'Width')
width = WIDGET_TEXT(w5, XSIZE=3, YSIZE=1, /EDITABLE, VALUE='400', $
                    UVALUE = 'setwidth')

w35 = WIDGET_LABEL(w5, VALUE = 'Height')
height = WIDGET_TEXT(w5, XSIZE=3, YSIZE=1, /EDITABLE, VALUE='400', $
                     UVALUE = 'setheight')

;The 'Number of Frames' slider:
numframes = WIDGET_SLIDER(mcol, TITLE = 'Number of Frames', $
                          MAXIMUM=36, MINIMUM=2,VALUE=16, /FRAME, $
		 	  UVALUE = 'frameslider')

;The 'Messages' window:
instruct = WIDGET_LABEL(mcol, VALUE='Messages:')
message = WIDGET_TEXT(mcol, XSIZE=28, YSIZE=2, UVALUE='createtext', FRAME=2)

;Create some default messages:
adjust=['Adjust parameters and/or','select the SPIN button.']

;REALIZE THE WIDGETS:
WIDGET_CONTROL, base, /REALIZE

;Set the default to be ORTHOGRAPHIC
theproj = 6
WIDGET_CONTROL, projection[theproj], /SET_BUTTON

;Put the 'Adjust values...' message in the message window:
WIDGET_CONTROL, message, SET_VALUE = adjust

;Set Grid drawing to ON:
WIDGET_CONTROL, drawgrid, /SET_BUTTON
grid = 1

;Set Continent drawing to ON:
WIDGET_CONTROL, drawcon, /SET_BUTTON
con = 1

;Set Interpolation to OFF:
WIDGET_CONTROL, nointerp, /SET_BUTTON
bilin = 0

;HAND THINGS OFF TO THE X MANAGER:
XMANAGER, 'worlddemo', base, GROUP_LEADER = GROUP, /NO_BLOCK

ENDIF ELSE BEGIN
    WIDGET_CONTROL, base, /DESTROY
ENDELSE

END
