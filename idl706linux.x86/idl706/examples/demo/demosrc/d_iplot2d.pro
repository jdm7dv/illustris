; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_iplot2d.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  NAME:
;       d_iplot2d
;
;  CALLING SEQUENCE:
;       d_iplot2d
;
;  PURPOSE:
;       2D iPlot demo
;
;  ARGUMENTS:
;       NONE
;
;  KEYWORDS:
;       _EXTRA - Needed to trap keywords being passed from the demo
;                system calling routine
;
;  MODIFICATION HISTORY:
;       AY, June 2003, Original
;
;---------------------------------------------------------------------

PRO d_iplot2d, _EXTRA=_extra

    ; TOP LEFT
    ;overplot test, multiple plots for legend testing
    ;randomu(s, 30)*10
    ;sin(findgen(30)*!pi/30*4)
    iplot, sin(findgen(30)*!pi/30*4), $
        view_grid=[2,2], $
        thick=2, $
        color=[255,0,0], $
        sym_index=1, $
        sym_size=0.3, $
        sym_color=[0,255,0], $
        name = 'Sin', $
        /no_saveprompt

    iplot, randomu(s, 30)*5, $
        /overplot


    ;TOP RIGHT
    ; asymetric error bars: Y
    yerr=fltarr(2,10)
    yerr[0,*]=findgen(10)/10.
    yerr[1,*]=fltarr(10)+.5
    iplot, randomu(s,10)*10, $
        view_number=2, $
        yerror=yerr, $
        errorbar_color=[255,0,0]


    ;BOTTOM LEFT
;    LOADCT, 7 ; red/purple
    LOADCT, 3 ; red temp
    TVLCT, R, G, B, /GET
    rgbTable = BYTARR(256,3)
    rgbTable[*,0] = r
    rgbTable[*,1] = g
    rgbTable[*,2] = b
    iplot, sin(findgen(100)*!pi/100*4), $
        view_number=3, $
        rgb_table = rgbTable, $
        vert_colors = indgen(10)*25, $
        SYM_INDEX=2, $
        YRANGE=[-1.5,1.5], $
        /SCATTER

    ;BOTTOM RIGHT
    ;; polar test
    r=findgen(100)
    theta = findgen(100)/100*!pi*2
    ; TBD set axes appropriately for polar
    iplot, r, theta, $
        view_number=4, $
        XRANGE=[-100.,100.], $
        YRANGE=[-100.,100.], $
        /polar

END
