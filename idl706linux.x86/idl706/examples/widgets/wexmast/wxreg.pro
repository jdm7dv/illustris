; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wxreg.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This code sample creates a widget application that checks
; to make sure that only one copy of itself is running.





PRO wxreg_event, event
; This is the event handler for the "Multiple Copies" widget.

; Allow the event handler to set the value of the label:
COMMON wxreg, label1, button2

; Use WIDGET_CONTROL to get the user value of any widget touched and put
; that value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform actions based on the user value of the button that was pressed:

CASE eventval OF
   'ANOTHER':BEGIN
		; Attempt to start invoke another copy of this example
		wxreg, GROUP=event.top
             END

   'DONE': BEGIN
                WIDGET_CONTROL, event.top, /DESTROY
           END

ENDCASE
END



PRO wxreg, GROUP=GROUP
; This is the procedure that creates a widget application that checks
; to make sure that only one copy of itself is running.  Widgets that
; use COMMON blocks could become corrupted if there were 
; several copies running at the same time.  The check for multiple
; copies is usually expressed as follows:

; 	IF (XREGISTERED("procedure_name") NE 0 THEN RETURN

; This line is already in the widget template "XMNG_TMPL.PRO".


; Allow the event handler to set the value of the label:
COMMON wxreg, label1, button2

; Check to make sure that only one example may run at a time.
; Removing the following IF block will allow more than one
; invocation of the "wxreg" example to run concurrently:

IF(XREGISTERED("wxreg") GT 0) THEN BEGIN
	WIDGET_CONTROL, label1, $
		SET_VALUE='ONLY ONE INVOCATION OF "wxreg" IS ALLOWED'
	; Return here rather than actually starting another
	WIDGET_CONTROL, button2, SENSITIVE=0
	RETURN
ENDIF

; A top-level base widget with the title "X Registered Example" will
; hold the exclusive buttons:

base = WIDGET_BASE(TITLE = 'X Registered Example', $
	/COLUMN)

; Make the DONE button:

button1 = WIDGET_BUTTON(base, $
                UVALUE = 'DONE', $
                VALUE = 'DONE')

text1 = WIDGET_TEXT(base, $
		/FRAME, $
		VALUE = [ $
			'This example will show how the XREGISTERED routine', $
			'can be used to allow only one invocation of a', $
			'given procedure.  The button below can be used to', $
			'attempt to start another invocation of this example',$
			'widget.', $
			'', $
			'The main procedure uses XREGISTERED to determine', $
			'if the example is already running.  If it is, it', $
			'does not allow another to start.', $
			'', $
			'The example also starts the XMANAGERTOOL.  This', $
			'shows that the procedure "wxreg" is registered.', $
			'', $
			'Try modifying the main procedure so that it does', $
			'not check to see if the example is already running.',$
			'This should allow multiple invocations of the', $
			'example to co-exist.  These multiple invocations', $
			"should show up in the XMANAGERTOOL's list of", $
			'registered widgets.' $
			], $
		XSIZE=60, $
		YSIZE=20)

; The ANOTHER button:
button2 = WIDGET_BUTTON(base, $
                UVALUE = 'ANOTHER', $
                VALUE = 'Attempt to Invoke Another "X Registered Example"')

; A blank label is created. It holds the 'Only one copy...' message
; when an attempt to run another copy is made:
label1 = WIDGET_LABEL(base, $
		/FRAME, /DYNAMIC_RESIZE, $
		VALUE = ' ')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Use the xmanager to only register the widgets:
XMANAGER, "wxreg", base, GROUP_LEADER=GROUP, /JUST_REG, /NO_BLOCK

; Run the XMANAGER tool:
XMTool, GROUP = base

END
