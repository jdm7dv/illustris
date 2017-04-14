; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wlabel.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for an example label widget.
; This example shows two labels, one with a frame around
; it, and one without.  Since label widgets don't really
; do anything except serve as titles, prompts, and other
; kinds of labels, this widget doesn't do very much.



PRO wlabel_event, event

; This is the event handler for the example label widget.
; It doesn't actually do anything. More complex widgets would, 
; of course, need a CASE statement or something of that nature
; to tell IDL what to do when certain widgets were manipulated.
 
END

PRO wlabel, GROUP = GROUP
; This is the procedure that creates a simple label widget.

; Unlike some other types of widgets, label widgets generally
; do not have to be declared in a common block or even given 
; User Values.  Label widgets primarily for generating
; unchanging text fields.

base = WIDGET_BASE(TITLE = 'Example Label Widget', $
		   /COLUMN, $	;Organize subsequent widgets in columns.
		   XSIZE = 350)	;Make it wide enough that the 
                                ;base's title shows completely.


; The next commands create two label widgets. The VALUE of a label
; is the text that will appear in the label.

label1 = WIDGET_LABEL(base, $		;This widget belongs to 'base'.
		      VALUE = 'This is a label widget with a frame.', $
		      /FRAME)		;Put a frame around it.

label2 = WIDGET_LABEL(base, $		;This widget belongs to 'base'.
		      VALUE = 'This is another label without a frame.')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'wlabel', base, GROUP_LEADER = GROUP, /NO_BLOCK

END




