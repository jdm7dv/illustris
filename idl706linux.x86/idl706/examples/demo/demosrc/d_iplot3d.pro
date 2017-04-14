; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_iplot3d.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  NAME:
;       d_iplot3d
;
;  CALLING SEQUENCE:
;       d_iplot3d
;
;  PURPOSE:
;       3D iPlot demo
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

PRO d_iplot3d, _EXTRA=_extra

   nVerts =30
    x = findgen(nVerts)/10
    y = (sin(x*2)+1)*25
    z = x
    zerr=fltarr(2,nVerts)
    zerr[0,*]=randomu(s, nVerts)
    zerr[1,*]=randomu(s, nVerts)
    yerr=zerr*5.

    ; create tool and view grid
    iplot, $
        view_grid=[2,2], $
        /no_saveprompt

    ;TOP RIGHT
    iplot, x, y, $
        view_number=2, $
        errorbar_color=[255,0,0], $
        yerror=yerr, $
        xtitle='X data', $
        ytitle='Y data'


    ;BOTTOM LEFT
    iplot, x, z, $
        view_number=3, $
        errorbar_color=[255,0,0], $
        yerror=zerr, $
        xtitle='X data', $
        ytitle='Z data'

    ;BOTTOM RIGHT
    iplot, y, z, $
        view_number=4, $
        errorbar_color=[255,0,0], $
        xerror=yerr, $
        yerror=zerr, $
        xtitle='Y data', $
        ytitle='Z data'

    ; TOP LEFT (do last so it is selected)
    iplot, x, y, z, color=[0,0,255], $
        view_number=1, $
        thick=2, $
        errorbar_color=[255,0,0], $
        yerror=yerr, $
;        y_errorbars=0, $ initially hidden
        zerror=zerr, $
        name='3d plot with error bars', $
        xtitle='X data', $
        ytitle='Y data', $
        ztitle='Z data'

END
