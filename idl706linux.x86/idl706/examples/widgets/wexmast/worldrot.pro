; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/worldrot.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

PRO WORLDROT_EVENT, EVENT
;THIS IS THE WORLDROT EVENT HANDLER

;COMMON BLOCK
;
COMPILE_OPT hidden

common worldr_block,projection,minlon,maxlon,minlat,maxlat,viewlat,width,$
                   height,numframes,cna,dne,theproj,base,names,help,$
		   rotangle,message,adjust,display,concol,gridcol,$
		   drawcon,nocon,drawgrid,nogrid,wlevel,latsamp,lonsamp,$
		   bilinear,nointerp,grid,con,bilin

ON_ERROR, 2
; This IF THEN ELSE handles clicking on the exclusive menu of projections.
; The variable 'projection' was set with the 'buttons' keyword when the
; exclusive menu of projections was created.
; The WHERE expression sets the value of 'projflag' to 1 if one of the
; exclusive buttons is clicked on.  The variable 'projselection' will also
; hold the index of the button touched.

projselection = WHERE(projection EQ event.id, projflag)

IF (projflag NE 0) THEN BEGIN
  theproj = projselection[0]

ENDIF ELSE BEGIN

;If something other than a exclusive button has been touched, manage the event
;with this CASE statement.

WIDGET_CONTROL, event.id, GET_UVALUE = eventval
CASE eventval OF
	"CREATE":BEGIN

		;If Xinteranimate is already going, DON'T DO THIS:
		IF (XREGISTERED("XInterAnimate") NE 0) THEN RETURN

		;If the Create New Animation Button is pressed,
		;read the values of all of the widgets from the tool.
		;Projection number is already in THEPROJ.

		;Read the Info about Image fields:
		WIDGET_CONTROL, minlon, GET_VALUE    = lon1
                WIDGET_CONTROL, maxlon, GET_VALUE    = lon2
                WIDGET_CONTROL, minlat, GET_VALUE    = lat1
                WIDGET_CONTROL, maxlat, GET_VALUE    = lat2

		;Read the Latitude to be Centered slider:
                WIDGET_CONTROL, viewlat, GET_VALUE   = vlat

		;The Rotation of North slider:
		WIDGET_CONTROL, rotangle,GET_VALUE   = rot

		;The size of the animation window:
                WIDGET_CONTROL, width, GET_VALUE     = wide
                WIDGET_CONTROL, height, GET_VALUE    = high

		;The number of frames to be generated:
                WIDGET_CONTROL, numframes, GET_VALUE = nframes

		;The grid and continent colors:
		WIDGET_CONTROL, concol, GET_VALUE    = concolor
		WIDGET_CONTROL, gridcol, GET_VALUE   = gridcolor

		;The Latitude and Longitude sampling parameters:
		WIDGET_CONTROL, latsamp, GET_VALUE   = lts
		WIDGET_CONTROL, lonsamp, GET_VALUE   = lns

		;These numbers get returned as arrays. Turn them into scalars:
		nframes = nframes[0]
		high = high[0]
		wide = wide[0]
		concolor = concolor[0]
		gridcolor = gridcolor[0]
		lon1=lon1[0]
		lon2=lon2[0]
		lat1=lat1[0]
		lat2=lat2[0]
		vlat=vlat[0]
		rot=rot[0]
		lts=lts[0]
		lns=lns[0]

		;Make the Worldrot Widget insensitive.
		WIDGET_CONTROL, base, SENSITIVE=0

		;Convert THEPROJ to correct argument to proj keyword.
		;CONVECT maps the projection menu into correct proj keyvalue:
		convect = [6,8,5,4,9,10,2,14,1]
		p = convect[theproj]

		;Make the title for XinterAnimate window:
		title = 'Rotating ' + names[theproj] + ' Projection'

		;Make Animation Frames:
        	XINTERANIMATE, SET = [wide, high, nframes], $
				     TITLE=title, GROUP = event.top, $
				     /SHOWLOAD
		step = 360./nframes

        	FOR i=0,nframes-1 DO BEGIN
			;Make the 'Frame n of x created.' message:
                	mess = 	'Frame '+ STRING(i+1, format='(I0)') + $
				' of ' + STRING(nframes, FORMAT='(I0)')+' created.'

			;Set up the map projection:
			MAP_SET, vlat, i*step-180, rot, PROJ=p


			;Warp the image and return it as 'img':
			img = MAP_IMAGE(ROUTINE_NAMES('IM', FETCH = wlevel), $
					startx, starty, LATSAMP=lts, $
					LONSAMP=lns, LONMIN=lon1, LONMAX=lon2,$
					LATMIN=lat1, LATMAX=lat2, $
					BILINEAR = bilin)

			;Display the image on the map:
			TV, img, startx, starty

			;Draw the continents and gridlines if we're supposed to:
			IF (grid EQ 1) THEN MAP_GRID, COLOR = gridcolor
			IF (con EQ 1)  THEN MAP_CONTINENTS, COLOR = concolor

			;Put the message in the message window:
			WIDGET_CONTROL, message, SET_VALUE = mess

			;Put the new frame into the Xinteranimate[B tool:
                	XINTERANIMATE, FRAME = i, WINDOW = !D.WINDOW

        		END


		;Call the Animation Tool & display new message
		WIDGET_CONTROL, message, SET_VALUE=display
		XINTERANIMATE, 80, GROUP = event.top

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

	"HELP": BEGIN
		;If HELP is pressed, display the help file.
		XDISPLAYFILE, FILEPATH('worldrthelp.txt', $
			        SUBDIR = ['examples', 'widgets', 'wexmast']), $
			GROUP=event.top, TITLE='World Rotation Tool Help'
		END ;Help case

	"DONE": WIDGET_CONTROL, event.top, /DESTROY	;If 'Done' is pressed,
							;destroy all widgets
							;and return to IDL.

	  ELSE: donothing=0	;If nothing is pressed, don't do anything.

	ENDCASE

ENDELSE ;(projflag NE 0)

END



; !!! MAKE THE ACTUAL WIDGETS !!!

PRO worldrot, im, GROUP = GROUP
; 'im' is the image that the user wants to warp.  It is assumed to be
;  already properly scaled for the display

; COMMON BLOCK
COMMON worldr_block,projection,minlon,maxlon,minlat,maxlat,viewlat,width,$
                   height,numframes,cna,dne,theproj,base,names,help,$
		   rotangle,message,adjust,display,concol,gridcol,$
		   drawcon,nocon,drawgrid,nogrid,wlevel,latsamp,lonsamp,$
		   bilinear,nointerp,con,grid,bilin

ON_ERROR, 2
; Only one copy of WORLDROT can run at a time due to the COMMON block.
; Check for other copies and do nothing if WORLDROT is already running:

IF(XRegistered("worldrot") NE 0) THEN RETURN

wlevel = ROUTINE_NAMES(/LEVEL)		;Current level

;Find the dimensions of the image:
imsize=SIZE(im)

;MAIN WIDGET BASE
base = WIDGET_BASE(TITLE='World Rotation Tool', /ROW)

;WORLD ROTATION TOOL HAS 3 MAIN COLUMNS
lcol = WIDGET_BASE(base, /FRAME, /COLUMN)	;Left column.
mcol = WIDGET_BASE(base, /FRAME, /COLUMN)	;Middle column.
rcol = WIDGET_BASE(base, /FRAME, /COLUMN)	;Right column.

;LEFT COLUMN IS THE EXCLUSIVE MENU OF PROJECTION TYPES, BUTTONS, AND OPTIONS
lpad = WIDGET_BASE(lcol, /FRAME, /ROW)
;The buttons:

spin = 		[				$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 048B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 240B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 240B, 003B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 015B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 063B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 003B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 015B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 031B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 063B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 063B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 015B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 003B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 255B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 063B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 031B, 000B],			$
		[153B, 057B, 207B, 231B, 231B, 207B, 127B, 254B, 007B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 240B, 001B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 112B, 000B, 000B],			$
		[252B, 249B, 099B, 134B, 129B, 249B, 007B, 048B, 000B, 000B],			$
		[252B, 249B, 103B, 142B, 129B, 249B, 007B, 000B, 000B, 000B],			$
		[006B, 024B, 102B, 142B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[006B, 024B, 102B, 158B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[006B, 024B, 102B, 150B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[124B, 248B, 099B, 182B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[248B, 248B, 099B, 166B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[128B, 025B, 096B, 230B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[128B, 025B, 096B, 198B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[128B, 025B, 096B, 198B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[254B, 024B, 096B, 134B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[254B, 024B, 096B, 134B, 129B, 193B, 000B, 000B, 000B, 000B],			$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B]			$
		]



dne = WIDGET_BUTTON(lpad, VALUE = 'Done', UVALUE = 'DONE')

; Make the cool bitmap SPIN IT button if Motif, if Open Look, don't bother:

VERSION	= WIDGET_INFO(/VERSION)
IF (VERSION.STYLE EQ 'OPEN LOOK') THEN $
cna = WIDGET_BUTTON(lpad, VALUE = 'Spin World', UVALUE = 'CREATE') $
ELSE $
cna = WIDGET_BUTTON(lpad, VALUE = spin, UVALUE = 'CREATE')

help = WIDGET_BUTTON(lpad, VALUE = 'Help', UVALUE = 'HELP')


;The text for the exclusive projection buttons:
names = ['Azimuthal', 'Cylindrical', 'Gnomonic', 'Lambert', $
        'Mercator', 'Mollweide', 'Orthographic', 'Sinusoidal', $
        'Stereographic']

;Make the exclusive projection list. Turn release events off:
XMENU, names, lcol, /EXCLUSIVE, /FRAME, $
        TITLE = 'Map Projection', BUTTONS = projection, /NO_RELEASE

;This is the two-button 'toggle' switch for continent drawing:
conbase = WIDGET_BASE(lcol, /COLUMN, /FRAME, /EXCLUSIVE)
drawcon = WIDGET_BUTTON(conbase, VALUE='Draw Continents', UVALUE='DRAWCON',$
			/NO_RELEASE)
nocon = WIDGET_BUTTON(conbase, VALUE='No Continents', UVALUE='NOCON',$
		      /NO_RELEASE)

;This is the two-button 'toggle' switch for grid drawing:
gridbase = WIDGET_BASE(lcol, /COLUMN, /FRAME, /EXCLUSIVE)
drawgrid = WIDGET_BUTTON(gridbase, VALUE='Draw Grid', UVALUE='DRAWGRID',$
			 /NO_RELEASE)
nogrid = WIDGET_BUTTON(gridbase, VALUE='No Grid', UVALUE='NOGRID',$
		       /NO_RELEASE)

;This is the two-button 'toggle' switch for bilinear interpolation:
bilinbase = WIDGET_BASE(lcol, /COLUMN, /FRAME, /EXCLUSIVE)
bilinear = WIDGET_BUTTON(bilinbase, VALUE='Bilinear Interpolation', $
			 UVALUE='BILINEAR', /NO_RELEASE)
nointerp = WIDGET_BUTTON(bilinbase, VALUE='No Interpolation', $
			 UVALUE='NOINTERP', /NO_RELEASE)


;MIDDLE COLUMN HAS LOTS OF STUFF

;The 'Info about Image' fields:
l1 = WIDGET_LABEL(mcol, VALUE='Information about Image:')
w1 = WIDGET_BASE(mcol, /ROW)
w2 = WIDGET_BASE(mcol, /ROW)
w3 = WIDGET_BASE(mcol, /ROW)
w4 = WIDGET_BASE(mcol, /ROW)

w11 = WIDGET_LABEL(w1, VALUE = 'Min Longitude')
minlon = WIDGET_TEXT(w1, XSIZE=6, YSIZE=1, /EDITABLE, VALUE='-180',$
		     UVALUE = 'minlong')

w21 = WIDGET_LABEL(w2, VALUE = 'Max Longitude')
maxlon = WIDGET_TEXT(w2, XSIZE=6, YSIZE=1, /EDITABLE, VALUE='180',$
		     UVALUE = 'maxlong')

w31 = WIDGET_LABEL(w3, VALUE = 'Min Latitude ')
minlat = WIDGET_TEXT(w3, XSIZE=6, YSIZE=1, /EDITABLE, VALUE='-90',$
		     UVALUE = 'minlatit')

w41 = WIDGET_LABEL(w4, VALUE = 'Max Latitude ')
maxlat = WIDGET_TEXT(w4, XSIZE=6, YSIZE=1, /EDITABLE, VALUE='90', $
		     UVALUE = 'maxlatit')

;The Longitude and Latitude Sampling sliders:
mcol2 = WIDGET_BASE(mcol, /FRAME, /COLUMN)
lonsamp = WIDGET_SLIDER(mcol2, TITLE = 'Longitude Sampling', MINIMUM=0, $
			MAXIMUM=imsize[1], VALUE = imsize[1]/5 < 32, $
			UVALUE='lonsamp', XSIZE = 192)

latsamp = WIDGET_SLIDER(mcol2, TITLE = 'Latitude Sampling', MINIMUM=0, $
			MAXIMUM=imsize[2], VALUE = IMSIZE[2]/5 < 32, $
			UVALUE='latsamp', XSIZE = 192)

;The 'Latitude to be Centered' slider:
viewlat = WIDGET_SLIDER(mcol2, TITLE = 'Latitude to be Centered', $
                        MINIMUM = -90, MAXIMUM = 90, VALUE = 0, $
			UVALUE = 'latslider', XSIZE = 192)

;The 'Rotation of North' slider:
rotangle = WIDGET_SLIDER(mcol2, TITLE = 'Rotation of North', $
			 MINIMUM = -90, MAXIMUM = 90, VALUE = 0, $
			 UVALUE = 'rotslider', XSIZE = 192)

;The Continent and Grid color sliders:
concol = WIDGET_SLIDER(mcol2, TITLE = 'Continent Color', $
                         MINIMUM = 0, MAXIMUM = !D.N_COLORS-1, $
			 VALUE = !D.N_COLORS-1, $
                         UVALUE = 'concolslider', XSIZE = 192)

gridcol = WIDGET_SLIDER(mcol2, TITLE = 'Grid Color', $
                         MINIMUM = 0, MAXIMUM = !D.N_COLORS-1, $
		 	 VALUE = !D.N_COLORS-1, $
                         UVALUE = 'gridcolslider', XSIZE = 192)


;RIGHT COLUMN HAS SLIDER AND BUTTONS

;The 'Animation Window Size' fields:
winbase =  WIDGET_BASE(rcol, /COLUMN, /FRAME)
wintitle = WIDGET_LABEL(winbase, VALUE='Animation Window Size:')
w5 = WIDGET_BASE(winbase, /ROW)

w15 = WIDGET_LABEL(w5, VALUE = 'Width')
width = WIDGET_TEXT(w5, XSIZE=3, YSIZE=1, /EDITABLE, VALUE='400', $
                    UVALUE = 'setwidth')

w35 = WIDGET_LABEL(w5, VALUE = 'Height')
height = WIDGET_TEXT(w5, XSIZE=3, YSIZE=1, /EDITABLE, VALUE='400', $
                     UVALUE = 'setheight')

;The 'Number of Frames' slider:
numframes = WIDGET_SLIDER(rcol, TITLE = 'Number of Frames', $
                          MAXIMUM=100, MINIMUM=2, VALUE=10, /FRAME, $
		 	  UVALUE = 'frameslider')

;The 'Messages' window:
instruct = WIDGET_LABEL(rcol, VALUE='Messages:')
message = WIDGET_TEXT(rcol, XSIZE=28, YSIZE=2, $
		      UVALUE='createtext', FRAME=2)

;Create some default messages:
adjust=['Adjust parameters and/or','select SPIN button.']
display=['Displaying Animation Tool']

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
XMANAGER, 'worldrot', base, GROUP_LEADER = GROUP, /NO_BLOCK

END
