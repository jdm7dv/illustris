; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wlabtext.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a labeled text field.

; This example shows a common combination of widgets where
; A label is right next to a text field.  In this example, 
; A label that says 'Name: ' is right next to an editable text
; widget.  When some text is entered in the name field, it
; is echoed to a 'Message: ' field. 



PRO wlabtext_event, event
; This is the event handler for a text widget with a label.

; Because the widget ID for the message field is needed in the CASE
; statement below, 'message' is put in a COMMON block:

COMMON wlabtextblock, message

; Get the widget ID of any widget touched and put it into 'eventval'.
; Pressing the RETURN key inside a text widget generates an event:

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; Perform different actions based upon 'eventval':

CASE eventval OF
	"NAME"	: BEGIN

		  ;A RETURN has been pressed in the Name field
		  ;so get the value of the Name field, and print
		  ;it in the Message field:

          	  WIDGET_CONTROL, event.id, GET_VALUE = newname
		  stuff = newname + ' was entered in the name field.'
		  WIDGET_CONTROL, message, SET_VALUE = stuff

		  END
ENDCASE

END



PRO wlabtext, GROUP = GROUP
; This is the procedure for a text widget with a label.

; The widget ID for the message field will be needed in the procedure
; above, so put 'message' in a COMMON block:

COMMON wlabtextblock, message

; This is the procedure that creates a simple label widget.

base = WIDGET_BASE(TITLE = 'Example Label/Text Widget', $
		   /COLUMN)	;Organize subsequent widgets in columns.


; Make a ROW base widget so the label and text field can be
; side by side:

row1 = WIDGET_BASE(base, /ROW, /FRAME)


; Put the name field label into the row base first:

namelabel = WIDGET_LABEL(row1, $		;This label belongs to row1.
		         VALUE = 'Name:')	;The value of the label.


; Then put the name field text widget into the row base:

name = WIDGET_TEXT(row1, $ 			;This widget belongs to row1.
		   /EDITABLE, $			;Make the text field editable.
		   XSIZE = 30, $
		   YSIZE = 1, $
		   UVALUE = 'NAME')		;The User Value for the widget.

; Make another ROW base to hold another label and text field:

row2 = WIDGET_BASE(base, /ROW, /FRAME)

; Put the message field label into the 2nd row base:

messlabel = WIDGET_LABEL(row2, $
		         VALUE = 'Message: ')

; Then put the message text widget into the 2nd row base.
; Note that this text widget is NOT editable:

message = WIDGET_TEXT(row2, $
		      VALUE = 'Enter a name in the space above and press RETURN.', $
		      XSIZE = 90, $
		      YSIZE = 1, $
		      UVALUE = 'MESSAGE')


; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'wlabtext', base, GROUP_LEADER = GROUP, /NO_BLOCK

END




