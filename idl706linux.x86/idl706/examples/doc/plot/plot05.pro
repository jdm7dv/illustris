;  $Id: //depot/idl/IDL_70/idldir/examples/doc/plot/plot05.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This file defines two IDL procedures discussed in Chapter 10,
; "Plotting", of _Using IDL_.

; Define a procedure that draws a box, using POLYFILL, whose corners
; are (X0, Y0) and (X1, Y1).

PRO EX_BOX, X0, Y0, X1, Y1, color	

;Call POLYFILL.

POLYFILL, [X0, X0, X1, X1], [Y0, Y1, Y1, Y0], COL = color

END

; Define a procedure that draws a bar graph of the SAT data used
; in this chapter's examples.

PRO EX_BARGRAPH, minval

; Define variables.

@plot01

; Define constants used in this procedure. Note that the number of
; colors used in the bar graph is defined by the number of colors
; available on your system.

del = 1./5.
ncol=!d.n_colors/5
colors = ncol*INDGEN(4)+ncol

; Loop for each score.

FOR iscore = 0, 3 DO BEGIN

    ; The y value of annotation. Vertical separation is 20 data units.

    yannot = minval + 20 *(iscore+1)

    ; Label for each bar. 

    XYOUTS, 1984, yannot, names(iscore)

    ; Bar for annotation.

    EX_BOX, 1984, yannot - 6, 1988, yannot - 2, colors(iscore)
    
    ; The x offset of vertical bar for each score.

    xoff = iscore * del - 2 * del	

    ; Draw vertical box for each year's score.

    FOR iyr=0, N_ELEMENTS(year)-1 DO $	
        EX_BOX, year(iyr) + xoff, minval, year(iyr) + xoff + del, $
        allpts(iyr, iscore), colors(iscore)
    ENDFOR

END
