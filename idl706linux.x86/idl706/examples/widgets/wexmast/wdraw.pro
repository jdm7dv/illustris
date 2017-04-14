; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wdraw.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple DRAW widget.  It displays
; an image of a "DIST" and allows the user to erase the
; draw widget and to redraw the image.  If the mouse button
; is pressed while the cursor is moved over the displayed 
; image, the X and Y positions of the cursor are printed in
; the IDL window.

; Draw widgets are very similar to IDL graphics windows.
 
; For an example of a draw widget with scroll bars, 
; see the procedure WDR_SCRL.PRO.

PRO wdraw_event, event
; This is the event handler for a simple draw widget.

; The COMMON block is used because the event handler usually needs
; the window number and the size of the draw widget:

COMMON wdrawblock, win_num, orig_image, x_im_sz, y_im_sz

; When a widget is manipulated, put its User Value into the variable 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform actions based on the User Value of the event:
CASE eventval OF
   'DRAW_WIN_EVENT': BEGIN
			; The help statement is useful for
			; debugging the event handler.  Try uncommenting
			; it to see the full structure returned by a 
			; draw window event.  Note the 'PRESS' and
			; 'RELEASE' fields.
			; HELP, /STRUCT, event

			; Only deal with the 'press' event,
			; disregard the 'release' event
			IF event.press EQ 1 THEN BEGIN
				; Print the device coordinates of the cursor
				PRINT, 'X = ', event.x
				PRINT, 'Y = ', event.y
			ENDIF
		     END

   'ERASE': BEGIN
		swin = !D.WINDOW        ; Save previous window
		; Set the window number - important for multiple windows
		WSET, win_num                
                ERASE                   ; Erase the image
		WSET, swin              ; Restore previous window
             END

   'REDRAW': BEGIN
		swin = !D.WINDOW        ; Save previous window
		; Set the window number - important for multiple windows
		WSET, win_num
                ; Redraw the image
                TVSCL, REBIN(orig_image, x_im_sz, y_im_sz)
		WSET, swin              ; Restore previous window
             END

   'DONE': BEGIN
                WIDGET_CONTROL, event.top, /DESTROY
           END
ENDCASE

END



PRO wdraw, XSIZE=x_size, YSIZE=y_size, GROUP=GROUP

; This is the procedure that creates a draw widget.

; The COMMON block is used because the event handler usually needs
; the window number and the size of the draw widget.
; Names of common variables must be distinct from keyword variables.
COMMON wdrawblock, win_num, orig_image, x_im_sz, y_im_sz

swin = !D.WINDOW	; Remember the current window so it can be restored

; The size of the draw area is one of the more important parameters
; for a draw widget.  This example uses keywords to define the size
; of the draw area.  An alternative would be to use a fixed size draw area. 
if (NOT keyword_set(x_size)) THEN x_size = 400
if (NOT keyword_set(y_size)) THEN y_size = 500

; A top-level base widget with the title "Simple Draw Widget Example"
; will be created.  The size is left unspecified until the draw widget
; is created.

base = WIDGET_BASE(TITLE = 'Simple Draw Widget Example', $
	/COLUMN)

; Setting the managed attribute indicates our intention to put this application
; under the control of XMANAGER, and prevents our draw widgets from
; becoming candidates for becoming the default window on WSET, -1. XMANAGER
; sets this, but doing it here prevents our own WSETs at startup from
; having that problem.
WIDGET_CONTROL, /MANAGED, base

; The DONE button:
button1 = WIDGET_BUTTON(base, $
		UVALUE = 'DONE', $
		VALUE = 'DONE')

; A label containing some instructions:
wdrlabel = WIDGET_LABEL(base, $
	   VALUE = 'Press the left mouse button to see cursor coordinates.')

; A widget called 'draw' is created.
draw = WIDGET_DRAW(base, $
	/BUTTON_EVENTS, $	;generate events when buttons pressed
	/FRAME, $
	UVALUE = 'DRAW_WIN_EVENT', $
	RETAIN = 2, $		;make sure draw is redrawn when covered
	XSIZE = x_size, $
	YSIZE = y_size)

; Make a button which will erase the image.
button2 = WIDGET_BUTTON(base, $
		UVALUE = 'ERASE', $
		VALUE = 'ERASE')

; Make a button which will redisplay the image.
button3 = WIDGET_BUTTON(base, $
		UVALUE = 'REDRAW', $
		VALUE = 'REDRAW')


; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Get the window number from the draw widget.  This can only be done
; after the widget has been realized.
WIDGET_CONTROL, draw, GET_VALUE=win_num

; Use TVSCL to display an image in the draw widget.  Set the window for
; the TVSCL command since there may be other draw windows.
WSET, win_num
orig_image = DIST(50)
TVSCL, REBIN(orig_image, x_size, y_size)


WSET, swin			; Restore the original window

; Set the common values for the image size
x_im_sz = x_size
y_im_sz = y_size

; Hand off control of the widget to the XMANAGER:
XMANAGER, "wdraw", base, GROUP_LEADER=GROUP, /NO_BLOCK


END





















