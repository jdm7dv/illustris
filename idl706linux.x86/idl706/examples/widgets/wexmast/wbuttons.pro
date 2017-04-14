; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wbuttons.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple set of widget buttons that perform different
; actions when they are selected, hence the name 'action buttons'.

; A button's VALUE is equal to the label on the face of the button.
; In this example, the labels on the buttons are text strings, but
; buttons can have bitmapped images as labels instead.  For an example
; of creating a bitmapped button, see the file WBITMAP.PRO.


 
PRO wbuttons_event, event
; This procedure is the event handler for a simple set of 'action' buttons.

; When a widget is touched, put its User Value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; This CASE statement branches based upon the value of 'eventval:

CASE eventval OF
	'GREET'	: PRINT, 'Hello World!'			;The 'Print a Greeting' button
							;has been selected, so print
							;a message in the IDL window.

	'PRINT'	: PRINT, 'IDL Widgets are Cool.'	;The 'Print a Message' button
							;has been selected, so print
							;a message in the IDL window.

	'DONE'	: WIDGET_CONTROL, event.top, /DESTROY	;The 'Done' button has been
							;selected, so destroy the widget.
ENDCASE
END



PRO wbuttons, GROUP = GROUP
; This procedure creates a simple set of buttons.

; Create the top-level base widget:

base = WIDGET_BASE(TITLE = 'Action Buttons Example', XSIZE = 350, /COLUMN)


; Create three buttons: two 'Print' buttons, and a 'Done' button. 

greetbutton = WIDGET_BUTTON(base, $			;The button belongs to 'base'
			    VALUE = 'Print a Greeting',$;The button label.
			    UVALUE = 'GREET')		;The button's User Value.

printbutton = WIDGET_BUTTON(base, $                     ;The button belongs to 'base'
                            VALUE = 'Print a Message', $;The button label.
                            UVALUE = 'PRINT')           ;The button's User Value.

donebutton  = WIDGET_BUTTON(base, $                     ;The button belongs to 'base'
                            VALUE = 'Done', $		;The button label.
                            UVALUE = 'DONE')		;The button's User Value.


; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'wbuttons', base, GROUP_LEADER = GROUP, /NO_BLOCK

END


