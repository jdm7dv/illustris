; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wdr_scrl.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a DRAW widget with scroll bars.  It 
; displays a portion of an image of a "DIST" in the drawing
; window.  It also allows the user to erase the
; draw widget and to redraw the image.  If the mouse button
; is pressed while the cursor is moved over the displayed
; image, the X and Y positions of the cursor are printed in
; the IDL window.

; For an example of a draw widget without scroll bars, 
; see the procedure WDRAW.PRO.


PRO wdr_scrl_event, event
; This is the event handler for a draw widget with scroll bars.

; The COMMON block is used because the event handler usually needs
; the window number and size of the draw widget.

COMMON wdr_scrlblock, win_num, orig_image, x_im_sz, y_im_sz

; When a widget is manipulated, put its User Value into the variable 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform actions based on the user value of the event:

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
		; Set the window number - important if multiple windows
		WSET, win_num
                ERASE                   ; Erase the image
		WSET, swin              ; Restore previous window
             END


   'REDRAW': BEGIN
		swin = !D.WINDOW        ; Save previous window
		; Set the window number - important if multiple windows
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



PRO wdr_scrl, XSIZE=x_size, YSIZE=y_size, $
	X_SCROLL_SIZE=x_scroll, Y_SCROLL_SIZE=y_scroll, $
	GROUP=GROUP


; This is the procedure that creates a draw widget which scrolls.

; The COMMON block is used because the event handler usually needs
; the window number and size of the draw widget.
; Names of common variables must be distinct from keyword variables.

COMMON wdr_scrlblock, win_num, orig_image, x_im_sz, y_im_sz

; The size of the draw area is one of the more important parameters
; for a draw widget.  This example uses keywords to define the size
; of the draw area.  An alternative would be to use a fixed size draw area. 

if (NOT keyword_set(x_size)) THEN x_size = 600
if (NOT keyword_set(y_size)) THEN y_size = 600

; The size of actual area which will be displayed is determined by
; these keywords.

if (NOT keyword_set(x_scroll)) THEN x_scroll = 200
if (NOT keyword_set(y_scroll)) THEN y_scroll = 300

swin = !D.WINDOW	; Remember the current window so it can be restored

; A top -level base widget with the title "Scrolling Draw Widget Example"
; will be created.  The size is left unspecified until the draw widget
; is created:

base = WIDGET_BASE(TITLE = 'Scrolling Draw Widget Example', $
		   /COLUMN)

; Setting the managed attribute indicates our intention to put this application
; under the control of XMANAGER, and prevents our draw widgets from
; becoming candidates for becoming the default window on WSET, -1. XMANAGER
; sets this, but doing it here prevents our own WSETs at startup from
; having that problem.
WIDGET_CONTROL, /MANAGED, base

; Make the 'DONE' button:

button1 = WIDGET_BUTTON(base, $
		UVALUE = 'DONE', $
		VALUE = 'DONE')

; Make the DRAW widget:

draw = WIDGET_DRAW(base, $
	/BUTTON_EVENTS, $		;Generate events when button is pressed.
	/FRAME, $
	RETAIN = 2, $			;Make sure IDL provides backing store.
	UVALUE = 'DRAW_WIN_EVENT', $	;The User Value of the draw widget.
	X_SCROLL_SIZE = x_scroll, $	;The x size of the displayed area.
	Y_SCROLL_SIZE = y_scroll, $	;The y size of the displayed area.
	XSIZE = x_size, $
	YSIZE = y_size)

; Make the 'ERASE' button:

button2 = WIDGET_BUTTON(base, $
		UVALUE = 'ERASE', $
		VALUE = 'ERASE')

; Make the 'REDRAW' button:

button3 = WIDGET_BUTTON(base, $
		UVALUE = 'REDRAW', $
		VALUE = 'REDRAW')


; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; The VALUE of a draw widget is its "window number".
; Get the window number from the draw widget.
; This number can only be obtained after the widget has been realized.

WIDGET_CONTROL, draw, GET_VALUE=win_num

; Use to display an image in the draw widget.  Set the window for
; the TVSCL command to use since there may be other draw windows.
WSET, win_num

orig_image = COS(DIST(50))			;Make an image to display.
TVSCL, REBIN(orig_image, x_size, y_size)	;Display the image.

WSET, swin			; Restore the original window

; Set the common values for the image size:
x_im_sz = x_size
y_im_sz = y_size

; Hand off control of the widget to the XMANAGER:
XMANAGER, "wdr_scrl", base, GROUP_LEADER=GROUP, /NO_BLOCK


END


