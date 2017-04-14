; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wtext.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code to create simple text widgets. Text widgets
; come in two varieties: editable and non-editable. The VALUE of
; a text widget is equal to the text string displayed in the
; text widget.

; For an example of text widgets in 'action' see
; the procedure WORLDROT.PRO available from the 'Simple Widget
; Examples' widget by selecting 'World Rotation Tool'.


PRO wtext_event, event

; This event handler for the example text widgets
; does not really do anything. It's just here to remind
; you that you generally need an event handler when
; you are programming widgets.

; For this example, we aren't doing anything with either
; of the text widgets.

; Text widgets can, however, have
; USER VALUES so you could use a CASE statement to execute some IDL
; commands if a text widget were manipulated. You could also use the
; GET_VALUE keyword to the WIDGET_CONTROL routine to return
; the text string currently present in a text widget.

END


PRO wtext, GROUP = GROUP

; This procedure creates 2 text widgets.
; One is editable and the other is not.

base = WIDGET_BASE(TITLE = 'Example Text Widgets', $	;The title for the base. 
		   XSIZE = 500, $			;Make the base really wide.
		   /COLUMN)				;Organize subsequent
							;widgets into columns.

; The next two commands create two text widgets.
; The first is editable, the second is not:

text1 = WIDGET_TEXT(base, $		;This widget belongs to 'base'.
	VALUE = 'This is an editable text widget. Go ahead and edit this text field.', $
	/EDITABLE, $	;Make it editable.
	YSIZE = 1, $ 
	/FRAME)		;Put a frame around it.

text2 = WIDGET_TEXT(base, $		;This widget belongs to 'base'.
	VALUE = 'This text widget cannot be edited.', $
	YSIZE = 1, $
	/FRAME)		;Put a frame around it.

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'wtext', base, GROUP_LEADER = GROUP, /NO_BLOCK

END
