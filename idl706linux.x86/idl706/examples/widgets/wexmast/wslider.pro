; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wslider.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple slider.  Moving the slider in this
; example causes the slider's new value to be printed in the IDL
; window.
;
; Sliders come in two varieties, horizontal (the default) and
; vertical.  For an example of a vertical slider, see the routine
; WVERTICAL.PRO.

; Sliders are used to select integer values from 
; a well-bounded range.  For example, a slider is a good widget
; to use for allowing users to select a color from an 8-bit palette.
; For an example of just such an application, see the routine
; WORLDROT.PRO available from the 'Simple Widget Examples' widget
; by selecting 'World Rotation Tool'.


PRO wslider_event, event
; This is the event handler for a basic slider.

; Use WIDGET_CONTROL to get the user value of any widget touched and put
; that value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; The movement of sliders is easily handled with a CASE statement.
; When the slider is moved, the value of 'eventval' becomes 'SLIDE':

CASE eventval OF
	'SLIDE':BEGIN
		
		; Get the current value of the slider and put it in the
		; variable 's':
		WIDGET_CONTROL, event.id, GET_VALUE = s
		
		; Print the slider value to the IDL window:
		PRINT, 'Horizontal Slider Value = ' + STRING(s)
		END
ENDCASE
END



PRO wslider, GROUP = GROUP
; This is the procedure that creates a single, horizontal  slider.

; A top-level base widget with the title "Slider Example" will
; hold the slider:

base = WIDGET_BASE(TITLE = 'Slider Example', /COLUMN)

; Often, a slider's minimum and maximum values are defined by an expression:

minvalue = 0
maxvalue = 100

; A widget called 'slider' is created. It has the title 'Slider Widget', 
; a frame around it, and a user value of 'SLIDE':

slider = WIDGET_SLIDER(base, $
			MINIMUM = minvalue, $
			MAXIMUM = maxvalue, $
		        TITLE = 'Slider Widget', $
			/FRAME, UVALUE = 'SLIDE',$
			XSIZE = 300) 

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off control of the widget to the XMANAGER:
XMANAGER, "wslider", base, GROUP_LEADER = GROUP, /NO_BLOCK

END


