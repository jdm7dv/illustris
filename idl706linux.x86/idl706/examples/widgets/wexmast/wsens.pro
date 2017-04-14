; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wsens.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This simple widget example demonstates the use of the
; SENSITIVE keyword to the WIDGET_CONTROL routine.

; A widget is said to be sensitive when it can be manipulated.
; When a widget is desensitized, it is 'grayed-out' and cannot
; be manipulated.


PRO wsens_event, event
; This is the event handler for the WSENS widget.

; This COMMON block is used because both sens and sens_event must
; know the widget ID's of all the widgets that will be desensitized:

COMMON wsensblock, desens_list1, desens_list2, button4

; Use WIDGET_CONTROL to get the user value of any widget touched and put
; that value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform actions based on the User Value of the button which was pressed:

CASE eventval OF
	'DESENSITIZE': BEGIN
			; Desensitize those widgets in desens_list1:

			FOR i=0,(N_ELEMENTS(desens_list1) -1) DO BEGIN
				 WIDGET_CONTROL, desens_list1[i], SENSITIVE=0
			ENDFOR

			; Sensitize the button which brings those buttons back:
			WIDGET_CONTROL, button4, SENSITIVE=1

		       END

	'ALLOW'	     : BEGIN
			; Desensitize those widgets in desens_list2:

			FOR i=0,(N_ELEMENTS(desens_list2) -1) DO BEGIN
				 WIDGET_CONTROL, desens_list2[i], SENSITIVE=0
			ENDFOR

                        ; Sensitize the button which brings those buttons back
                        WIDGET_CONTROL, button4, SENSITIVE=1

		       END

   	'DONE'       : WIDGET_CONTROL, event.top, /DESTROY	;Destroy the widgets.

   'RESENSITIZE': BEGIN
                     ; Re-sensitize those widgets in desens_list1:

                     FOR i=0,(N_ELEMENTS(desens_list1) -1) DO BEGIN
                     	WIDGET_CONTROL, desens_list1[i], SENSITIVE=1
                     ENDFOR

                     ; DE-Sensitize button4
                     WIDGET_CONTROL, button4, SENSITIVE=0
                  END

ENDCASE
END



PRO wsens, GROUP=GROUP
; This is a procedure that creates the widgets for the widget
; sensitize/desensitize example.

; The COMMON block is used because both sens and sens_event must
; know the widget ID's of all widgets that will be desensitized:

COMMON wsensblock, desens_list1, desens_list2, button4

; A top -level base widget with the title "Exclusive Buttons Example" will
; hold the exclusive buttons:
base = WIDGET_BASE(TITLE = 'Sensitivity Example', $
	/COLUMN, $
	XSIZE=400)

button1 = WIDGET_BUTTON(base, $
                UVALUE = 'DONE', $
                VALUE = 'DONE')

button2 = WIDGET_BUTTON(base, $
                UVALUE = 'DESENSITIZE', $
                VALUE = 'Desensitize The Top Three Buttons')

button3 = WIDGET_BUTTON(base, $
                UVALUE = 'ALLOW', $
                VALUE = 'Desensitize Buttons Two and Three')

button4 = WIDGET_BUTTON(base, $
               	UVALUE = 'RESENSITIZE', $
		VALUE = 'Sensitize All Buttons Except This One')

; Make button4 initially insensitive:
WIDGET_CONTROL, button4, SENSITIVE=0		;notice that the button can
						;be desensitized before being
; Realize the widgets:				;realized.
WIDGET_CONTROL, base, /REALIZE

; Build the arrays of items to desensitize:

desens_list1 = [button1, button2, button3]
desens_list2 = [button2, button3]

; Hand off control of the widget to the XMANAGER:
XMANAGER, "wsens", base, GROUP_LEADER=GROUP, /NO_BLOCK

END

