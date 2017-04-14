; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wtoggle.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple set of toggle button widgets.
; A set of toggle buttons acts like an ON-OFF switch.
; In this example, when the ON button is selected, the 
; variable 'value' is set equal to 1.  When the OFF button is
; selected, the variable 'value' is set equal to 0.

; For an example of toggle buttons in action, see the routine
; WORLDROT.PRO where they are used to turn certain drawing
; and display features on or off.




PRO wtoggle_event, event
; This is the code for a simple 2-button toggle switch.

; Both procedures need to know about the variable 'value':

COMMON wtoggleblock, value

; Put the UVALUE of any widget touched into the variable 'eventval':
WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; A CASE statement is an easy way to handle toggle buttons:
CASE eventval OF
	"ON":	BEGIN			; The ON button has been pressed.
	     	value = 1
		PRINT, 'value = ', value
		END

	"OFF":	BEGIN			; The OFF button has been pressed.
		value = 0
		PRINT, 'value = ', value
		END
ENDCASE

END



PRO wtoggle, GROUP = GROUP

; Both procedures need to know about the variable 'on':

COMMON wtoggleblock, value

; Make the main base:
base = WIDGET_BASE(TITLE = 'Toggle Buttons Example', /COLUMN, XSIZE = 300)

; Make another base to hold the exclusive buttons.  The base is made
; capable of holding only exclusive buttons so that when the ON button
; is selected, the OFF button is automatically de-selected and vice
; versa:

togglebase = WIDGET_BASE(base, /COLUMN, /FRAME, /EXCLUSIVE)

; Make the ON button:
onbutton = WIDGET_BUTTON(togglebase, $	
			 VALUE='ON Button', $	;The label for the button.
			 UVALUE='ON', $		;The User Value for the button.
			 /NO_RELEASE)		;The /NO_RELEASE keyword keeps
						;the released button from
						;generating an event when a new
						;button is selected.

; Make the OFF button:
offbutton = WIDGET_BUTTON(togglebase, $
			  VALUE='OFF Button', $	;The label for the button.
			  UVALUE='OFF', $	;The User Value for the button.
			  /NO_RELEASE)		;The /NO_RELEASE keyword keeps
						;the released button from 
						;generating an event when a new
						;button is selected.


; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Initialize the ON button to be 'pushed in'. An associated variable, called
; 'on' is set to 1 when ON is selected and 0 when OFF is selected:	

WIDGET_CONTROL, onbutton, /SET_BUTTON
value = 1

; Hand off to the XManager:
XMANAGER, 'wtoggle', base, GROUP_LEADER = GROUP, /NO_BLOCK

END
