; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wexmaster.pro#2 $
;
; Copyright (c) 1991-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;	WEXMASTER.PRO
; PURPOSE:
;	This routine is the main menu for the "Simple Widget Examples".
;	Click on any of the buttons in the menu to see helpful examples
;	of Widgets programming.
;
;	The examples under "Simple Widget Examples:" demonstrate the creation
;	and management of just one or two kinds of widgets at one time.
;	For more complex examples, select the examples under "Example Widget
;	Applications".
;
;	Select "About the Simple Widget Examples" to see a more information on
;	the simple widget examples.  Select "Widget Programming Tips and Tech-
;	niques" to see helpful information on programming with the IDL/widgets,
;	and widgets documentation updates.
;
;	Hope this helps!
; CATEGORY:
;	Widgets
; CALLING SEQUENCE:
;	WEXMASTER
; KEYWORD PARAMETERS:
;	GROUP = The widget ID of the widget that calls WEXMASTER.  When this
;		ID is specified, a death of the caller results in a death of
;		WEXMASTER.
; SIDE EFFECTS:
;	Initiates the XManager if it is not already running.
; RESTRICTIONS: Only one copy may run at a time to avoid confusion.
; PROCEDURE:
;	Create and register the widget and then exit.
; MODIFICATION HISTORY:
;	WEXMASTER and associated examples by Keith R Crosley, August, 1991
;	Created from a template written by: Steve Richards,	January, 1991
;-





;------------------------------------------------------------------------------
PRO wexmaster_event, event

COMPILE_OPT hidden

ON_ERROR, 2  ; return to caller

WIDGET_CONTROL, event.id, GET_UVALUE = eventval
							;find the user value
							;of the widget where
							;the event occured
; Set the width of the XDISPLAYFILE windows:
X=90
WIDGET_CONTROL, event.top, GET_UVALUE=wexmaster_path

IF eventval EQ 'THEMENU' THEN BEGIN

CASE event.value OF

  "XLoadct": XLoadct, GROUP = event.top			;XLoadct is the library
							;routine that lets you
							;select and adjust the
							;color palette being
							;used.

  "XPalette": XPalette, GROUP = event.top		;XPalette is the
							;library routine that
							;lets you adjust
							;individual color
							;values in the palette.

  "XManagerTool": XMTool, GROUP = event.top		;XManTool is a library
							;routine that shows
							;which widget
							;applications are
							;currently registered
							;with the XManager as
							;well as which
							;background tasks.

  "About the Simple Widget Examples"	: $
			XDISPLAYFILE,FILEPATH('simpwidg.txt', $
			SUBDIR=wexmaster_path),$
		  	TITLE = 'About the Simple Widget Examples', $
			GROUP=event.top

  "Widget Programming Tips and Techniques" : $
			XDISPLAYFILE, FILEPATH('wtips.txt', $
			SUBDIR=wexmaster_path),$
		  	TITLE = 'Widget Programming Tips and Techniques', $
			GROUP=event.top

  "Done" : WIDGET_CONTROL, event.top, /DESTROY		;There is no need to
							;"unregister" a widget
							;application.  The
							;XManager will clean
							;the dead widget from
							;its list.

ENDCASE ; The Menu

ENDIF ELSE IF eventval EQ "SIMPLE" THEN BEGIN

CASE event.index OF

		0: BEGIN
		   XDISTFILE, 'mbar', wexmaster_path, $
			GROUP = event.top, WIDTH=X
		   MBAR, GROUP = event.top
		   ENDCASE

		1: BEGIN
		   XDISTFILE, 'wslider',wexmaster_path, $
			GROUP = event.top, WIDTH=X
		   WSLIDER, GROUP = event.top
		   ENDCASE

                2: BEGIN
                   XDISTFILE, 'wvertical', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WVERTICAL, GROUP = event.top
                   ENDCASE

		3: BEGIN
		   XDISTFILE, 'wbuttons', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
		   WBUTTONS, GROUP = event.top
		   ENDCASE

		4: BEGIN
		   XDISTFILE, 'wbitmap', wexmaster_path, $
			GROUP = event.top, WIDTH=X
		   WBITMAP, GROUP = event.top
		   ENDCASE

                5: BEGIN
                   XDISTFILE, 'wtoggle', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WTOGGLE, GROUP = event.top
                   ENDCASE

		6: BEGIN
                   XDISTFILE, 'wtext', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WTEXT, GROUP = event.top
                   ENDCASE

		7: BEGIN
		   XDISTFILE, 'wlabel', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WLABEL, GROUP = event.top
                   ENDCASE

                8: BEGIN
                   XDISTFILE, 'wlabtext', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WLABTEXT, GROUP = event.top
                   ENDCASE

                9: BEGIN
                   XDISTFILE, 'wlist', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WLIST, GROUP = event.top
                   ENDCASE

               10: BEGIN
                   XDISTFILE, 'wdroplist', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WDROPLIST, GROUP = event.top
                   ENDCASE


               11: BEGIN
                   XDISTFILE, 'wmtest', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WMTEST, GROUP = event.top
                   ENDCASE

               12: BEGIN
                   XDISTFILE, 'wpdmenu', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WPDMENU, GROUP = event.top
                   ENDCASE

               13: BEGIN
                   XDISTFILE, 'wexclus', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WEXCLUS, GROUP = event.top
                   ENDCASE

               14: BEGIN
                   XDISTFILE, 'w2menus', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   W2MENUS, GROUP = event.top
                   ENDCASE

               15: BEGIN
                   XDISTFILE, 'wpopup', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WPOPUP, GROUP = event.top
                   ENDCASE

               16: BEGIN
                   XDISTFILE, 'wdraw', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WDRAW, GROUP = event.top
                   ENDCASE

               17: BEGIN
                   XDISTFILE, 'wdr_scrl', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WDR_SCRL, GROUP = event.top
                   ENDCASE

               18: BEGIN
                   XDISTFILE, 'wmotion', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WMOTION, GROUP = event.top
                   ENDCASE

               19: BEGIN
                   XDISTFILE, 'wsens', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WSENS, GROUP = event.top
                   ENDCASE

               20: BEGIN
                   XDISTFILE, 'wback', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WBACK, GROUP = event.top
                   ENDCASE

               21: BEGIN
                   XDISTFILE, 'wxreg', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   WXREG, GROUP = event.top
                   ENDCASE

ENDCASE ;SIMPLE case.

ENDIF ELSE IF eventval EQ "APPS" THEN BEGIN

CASE event.index OF

                0: BEGIN
                   XDISTFILE, 'worlddemo', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   OPENR, UNIT, /GET_LUN, FILEPATH('worldelv.dat', $
                          sub=['examples', 'data'])
                   im = BYTARR(360, 360, /NOZERO)
                   READU, unit, im
                   FREE_LUN, unit
                   im = SHIFT(im, 180, 0)
                   WORLDDEMO, BYTSCL(IM, TOP=!D.N_COLORS-1), GROUP = event.top
                   ENDCASE

                 1: BEGIN
                   XDISTFILE, 'slots', wexmaster_path, $
                        GROUP = event.top, WIDTH=X
                   SLOTS, GROUP = event.top
                   ENDCASE

                2: BEGIN
                   XDISTFILE, 'xmng_tmpl', ['lib'], $
                        GROUP = event.top, WIDTH=X
                   XMNG_TMPL, GROUP = event.top
                   ENDCASE

;                3: BEGIN
;                   XDISTFILE, 'xexample', ['lib','demo','xdemo'], $
;                        GROUP = event.top, WIDTH=X
;                   XEXAMPLE, GROUP = event.top
;                   ENDCASE

                3: BEGIN
                   XDISTFILE, 'xsurface', ['lib','utilities'], $
                        GROUP = event.top, WIDTH=X
                   XSURFACE, DIST(20), GROUP = event.top
                   ENDCASE

                4: BEGIN
                   XDISTFILE, 'xbm_edit', ['lib','utilities'], $
                        GROUP = event.top, WIDTH=X
                   XBM_EDIT, GROUP = event.top
                   ENDCASE
ENDCASE ;APPS case

ENDIF ELSE MESSAGE, "Event User Value Not Found"	;When an event occurs
							;in a widget that has
							;no user value in this
							;case statement, an
							;error message is shown

END ;============= end of WEXMASTER event handling routine task =============




;------------------------------------------------------------------------------
PRO wexmaster, GROUP = GROUP

ON_ERROR, 2  ; return to caller

IF(XRegistered("wexmaster") NE 0) THEN RETURN		;only one instance of
							;the Wexmaster widget
							;is allowed.  If it is
							;already managed, do
							;nothing and return

;The main base.
XMng_tmplbase = WIDGET_BASE(TITLE = "Simple Widget Examples", $
	/COLUMN,MBAR=mbar, UVALUE=['examples','widgets','wexmast'])

menu = CW_PdMenu(mbar, /RETURN_NAME, /MBAR, /HELP, $
                 ['1\File', $
                  '2\Done', $
                  '1\Tools', $
                  '0\XLoadct', $
                  '0\XPalette', $
                  '2\XManagerTool', $
                  '1\Help', $
                  '0\About the Simple Widget Examples', $
                  '2\Widget Programming Tips and Techniques'], $
                 UVALUE='THEMENU')

; Make a new sub-base:
base = WIDGET_BASE(xmng_tmplbase, /ROW)

lcol = WIDGET_BASE(base, /COLUMN)	;The left column.
rcol = WIDGET_BASE(base, /COLUMN)

llabel = WIDGET_LABEL(lcol, VALUE = 'Simple Widget Examples:')

;Define the top pulldown labels:

buttons = ['Menu Bar', $
        'Horizontal Slider', $
	'Vertical Slider', $
	'Action Buttons', $
	'Bitmap Button', $
	'Toggle Buttons', $
	'Text Widgets', $
	'Label Widgets', $
	'Combination Label/Text Widgets', $
	'List Widget', $
	'Droplist Widget', $
	'Non-Exclusive Menu', $
	'Pull-Down Menu', $
	'Exclusive Menu', $
	'Two Menus', $
	'Pop-Up Widget', $
	'Draw Widget', $
	'Scrolling Draw Widget', $
	'Motion Events Draw Widget', $
	'Sensitizing/Desensitizing', $
	'Timer Task Widget', $
	'Multiple Copies of a Widget']


list = WIDGET_LIST(lcol, VALUE=buttons, YSIZE = 10, $
		   /FRAME, UVALUE = 'SIMPLE')

buttons2 = ['World Rotation Tool', $
        'Slot Machine Demo', $
;        'Widgets Template', $
        'All Widget Types Example', $
        'XSURFACE Tool', $
        'Bitmap Editor']

; Right column has the super-cool example programs written by Keith:

mlabel = WIDGET_LABEL(rcol, VALUE = 'Example Widget Applications:')

list2 = WIDGET_LIST(rcol, VALUE=buttons2, YSIZE=10, $
                    /FRAME, UVALUE = 'APPS')




; Realize the widgets:
WIDGET_CONTROL, XMng_tmplbase, /REALIZE

XManager, "wexmaster", XMng_tmplbase, $			;register the widgets,
		GROUP_LEADER = GROUP, /NO_BLOCK  	;with the XManager
							;and pass through the
							;group leader if this
							;routine is to be
							;called from some group
							;leader.

END ;==================== end of WEXMASTER main routine =======================

