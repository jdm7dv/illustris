; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wbitmap.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple bitmapped button. When the
; button in this example is pressed, the word 'OUCH!' is 
; printed in the IDL window.

; Bitmap buttons can be used any place that regular buttons
; are used.  Use bitmap buttons to add variety and personality
; to your widget applications.

; The VALUE of a bitmapped button is the bitmap
; to be displayed.  Changing the VALUE of a bitmap button
; causes the new bitmap to be displayed.

; The procedure WORLDROT.PRO, available from the 'Simple Widget
; Examples' widget by selecting 'World Rotation Tool', uses bitmap
; buttons as "action" buttons.

; The procedure SLOTS.PRO, available from the 'Simple Widget 
; Examples' widget by selecting 'Slot Machine Demo', uses bitmap
; buttons to display little bitmap pictures that simulate the 
; wheels of a slot machine.  When selected, the buttons
; don't actually do anything.   


PRO wbitmap_event, event 
; This procedure is the event handler for the 'wbitmap' procedure.

; When a widget is 'touched', put its User Value into the variable 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; This CASE statement branches based on the value of 'eventval'.
; For a more elaborate example of managing buttons that perform an 
; action when pressed, see the WBUTTONS.PRO procedure.

CASE eventval OF
	"LOOK":print, 'OUCH!'	;Print OUCH! in the IDL window when the button
				;is pressed.
ENDCASE

END



PRO wbitmap, GROUP = GROUP
; This is the procedure that creates a bitmap button widget.

; Create the main, top-level base:

base = WIDGET_BASE(TITLE = 'Bitmap Button Example', /COLUMN, XSIZE = 300)

; Create a sub-base to hold the button widget.  The button could be put 
; directly into the top-level base, but we wanted to show that widget
; bases can be put inside other widget bases. Also, to make this demo
; work with both OPEN LOOK and MOTIF, we need to determine which version
; we are using and, for OPEN LOOK, make the base EXCLUSIVE to properly
; display the bitmapped button.  Unless you routinely work with BOTH 
; environments, you shouldn't have to the IF... THEN part the the next
; command.  Just use the code for OPEN LOOK or MOTIF, depending upon 
; which toolkit you use:


VERSION	= WIDGET_INFO(/VERSION)
IF (VERSION.STYLE EQ 'OPEN LOOK') THEN $
	holder = WIDGET_BASE(base, $
		             /FRAME, $
			     /EXCLUSIVE) $	;If running under OPEN LOOK,
						;make the base EXCLUSIVE.
ELSE $
	holder = WIDGET_BASE(base, /FRAME)	;If running under MOTIF, 
						;DON'T make the base EXCLUSIVE.

; The bitmap for the LOOK! button was created with the procedure XBM_EDIT.
; The bitmap was saved as an "IDL array definition file" and imported into
; this file with a text editor.
; Here is the definition of the LOOK! button:
	
looker = 	[				$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 030B, 060B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 033B, 066B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 032B, 065B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 032B, 065B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 032B, 065B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 039B, 079B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 039B, 079B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 039B, 079B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 039B, 079B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 039B, 079B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 032B, 065B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 032B, 065B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 016B, 033B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 015B, 030B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 000B, 032B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 000B, 032B, 000B, 000B, 000B, 000B],$
		[000B, 128B, 000B, 016B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 001B, 016B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 001B, 008B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 002B, 008B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 002B, 006B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 252B, 003B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 248B, 001B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 224B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[056B, 192B, 135B, 143B, 195B, 057B, 000B, 000B],$
		[056B, 224B, 207B, 159B, 195B, 057B, 000B, 000B],$
		[056B, 224B, 207B, 159B, 227B, 057B, 000B, 000B],$
		[056B, 224B, 206B, 157B, 243B, 056B, 000B, 000B],$
		[056B, 224B, 206B, 157B, 059B, 056B, 000B, 000B],$
		[056B, 224B, 206B, 157B, 031B, 056B, 000B, 000B],$
		[056B, 224B, 206B, 157B, 031B, 056B, 000B, 000B],$
		[056B, 224B, 206B, 157B, 027B, 056B, 000B, 000B],$
		[056B, 224B, 206B, 157B, 051B, 056B, 000B, 000B],$
		[056B, 224B, 207B, 157B, 227B, 000B, 000B, 000B],$
		[248B, 231B, 207B, 159B, 195B, 057B, 000B, 000B],$
		[248B, 231B, 207B, 159B, 195B, 057B, 000B, 000B],$
		[248B, 199B, 135B, 143B, 195B, 057B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B],$
		[000B, 000B, 000B, 000B, 000B, 000B, 000B, 000B]$
		]

; Making the button appear is rather easy:

look = WIDGET_BUTTON(holder, $		;The button belongs to the base 'holder'.
		     VALUE = looker, $	;The button's value is the bitmap 'looker'.
		     UVALUE = "LOOK")	;Give the button the User Value 'LOOK'.

; Realize the widgets:

WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:

XMANAGER, "wbitmap", base, GROUP_LEADER = GROUP, /NO_BLOCK

END




