; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wback.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a widget that performs a timer task.
; Timer tasks are performed after the registered timer expires.
; For example, things like animations can run under timer control
; without forcing other widgets to be inactive.

; Here, a text window appears and the current system time is displayed 
; repeatedly each second.  Select the "Done" button to exit.




PRO wback_event, event
; This is the event handler for a background task widget.

; The COMMON block is used because the event handler and the timer
; both need the widget id of the text widget:

COMMON wbackblock, text1

IF TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_TIMER' THEN BEGIN
; This is the task that the widget performs when timer expires

temp_string = SYSTIME(0)
WIDGET_CONTROL, text1, SET_VALUE=temp_string, /APPEND

; Re-register the timer
WIDGET_CONTROL, event.top, /TIMER

RETURN
ENDIF

; If a widget has been selected, put its User Value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform actions based on the user value of the event:

CASE eventval OF

   'DONE' : WIDGET_CONTROL, event.top, /DESTROY

   'ERASE': WIDGET_CONTROL, text1, SET_VALUE = ''

ENDCASE

END



PRO wback, GROUP=GROUP

; This is the procedure that creates a widget with a timer

; The COMMON block is used because the event handler needs
; the widget id of the text widget:

COMMON wbackblock, text1

; A top-level base widget with the title "Timer Widget Example"
; is created:

base = WIDGET_BASE(TITLE = 'Timer Widget Example', $
	/COLUMN)

; Make the 'DONE' button:

button1 = WIDGET_BUTTON(base, $
		UVALUE = 'DONE', $
		VALUE = 'DONE')

; Make the text widget:

text1 = WIDGET_TEXT(base, $		; create a display only text widget
		XSIZE=30, $
		YSIZE=30, $
		/SCROLL)

; Make a button which will clear the text file.

button2 = WIDGET_BUTTON(base, $
		UVALUE = 'ERASE', $
		VALUE = 'ERASE')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Register the timer
WIDGET_CONTROL, base, /TIMER

; Hand off control of the widget to the XMANAGER
XMANAGER, "wback", base, GROUP_LEADER=GROUP, /NO_BLOCK

END


