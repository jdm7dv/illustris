;  $Id: //depot/idl/IDL_70/idldir/examples/doc/plot/plot10.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This file compiles to simple routines that illustrate the use
; of the CURSOR procedure. The examples come from Chapter 10, 
; "Plotting", of _Using IDL_.

; The first routine draws lines on a window until the right
; mouse button is clicked.

PRO ex_draw

; Start with a blank screen.

ERASE	

; Get the initial point in normalized coordinates.

CURSOR, X, Y, /NORMAL, /DOWN	

; Repeat until the right button is pressed.

WHILE (!MOUSE.button NE 4) DO BEGIN	
    CURSOR, X1, Y1, /NORM, /DOWN	; Get the second point.
    PLOTS,[X,X1], [Y,Y1], /NORMAL	; Draw the line.
    X = X1 & Y = Y1	                ; Make the current second point
                                        ;be the new first.
ENDWHILE
END

; The second routine allows you to position a text label on
; an existing window.

PRO LABEL, TEXT 	

; Text is the string to be written on the screen.
; Ask the user to mark the position.

PRINT, 'Use the mouse to mark the text position:'

; Get the cursor position after press ing any button.

CURSOR, X, Y, /NORMAL, /DOWN	

; Write the text at the specified position. The NOCLIP keyword is 
; used to ensure that the text will appear even if it is outside
; the plotting region.

XYOUTS, X, Y, TEXT, /NORMAL, /NOCLIP	

END
