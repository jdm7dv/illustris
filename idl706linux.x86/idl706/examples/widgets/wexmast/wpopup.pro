; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wpopup.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple "pop-up" widget.
; In this example, a new base with a button in it appears
; when a button in the original base, labeled "Create Popup",
; is pressed.



PRO wpopup_event, event
; This is the event handler for a "pop-up" widget.

; The COMMON block is used because both wpopup and wpopup_event must
; know about the group leader.
COMMON groupleader, base

; Use WIDGET_CONTROL to get the user value of any widget touched and put
; that value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform actions based on the user value of the button which was pressed.

CASE eventval OF
	'POPUP':     BEGIN
			popupbase = WIDGET_BASE()

			popupbutton = WIDGET_BUTTON(popupbase, $
                		UVALUE = 'GOBACK', $
				VALUE = 'Go Back', $
				XSIZE=200, YSIZE=60)

			; Desensitize the parent of popup
			WIDGET_CONTROL, base, SENSITIVE=0

			; Realize the popup:
			WIDGET_CONTROL, popupbase, /REALIZE

			; Hand off control of the widget to the XMANAGER:
			XMANAGER, "wpopup", popupbase, GROUP_LEADER=base, $
			          /NO_BLOCK
		      END

   'DONE': WIDGET_CONTROL, event.top, /DESTROY

   'GOBACK': BEGIN
                WIDGET_CONTROL, event.top, /DESTROY

                ; Re-sensitize the main base
                WIDGET_CONTROL, base, SENSITIVE=1
           END

ENDCASE
END



PRO wpopup, GROUP=GROUP
; This is the procedure that creates a widget application

; The COMMON block is used because both wpopup and wpopup_event must
; know the group leader.
COMMON groupleader, base

; A top-level base widget with the title "Pop-Up Widget Example" will
; hold the exclusive buttons:
base = WIDGET_BASE(TITLE = 'Pop-Up Widget Example', $
	/COLUMN, $
	XSIZE=200)

button1 = WIDGET_BUTTON(base, $
                UVALUE = 'DONE', $
                VALUE = 'DONE')

button2 = WIDGET_BUTTON(base, $
                UVALUE = 'POPUP', $
                VALUE = 'Create Popup')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off control of the widget to the XMANAGER:
XMANAGER, "wpopup", base, GROUP_LEADER=GROUP, /NO_BLOCK

END


