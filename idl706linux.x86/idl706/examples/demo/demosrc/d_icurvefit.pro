; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_icurvefit.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  NAME:
;       d_icurvefit
;
;  CALLING SEQUENCE:
;       d_icurvefit
;
;  PURPOSE:
;       Demonstration of fitting a curve to a plot
;
;  ARGUMENTS:
;       NONE
;
;  KEYWORDS:
;       _EXTRA - Needed to trap keywords being passed from the demo
;                system calling routine
;
;  MODIFICATION HISTORY:
;       SM, June 2003, Original
;       CT, Better example data.
;

;---------------------------------------------------------------------
PRO d_icurvefit, _EXTRA=_extra

    ; Generate a plot line
    n = 50
    x = (findgen(n) - 25)/2
    yerr = 0.1
    y = 2 + 0.1*x + 3*exp(-((x - 1)/2)^2) + yerr*randomn(1,n)
    yerror = replicate(yerr, n)

    IPLOT, x, y, $
        COLOR = [255,0,0], $
        ERRORBAR_COLOR = [255,0,0], $
        THICK = 2, $
        LINESTYLE = 6, $
        NAME = 'Gaussian+Linear', $
        SYM_INDEX = 4, $
        XTITLE = 'Angle  !9F!X (degrees)', $
        YTITLE = 'Area (m!u2!n)', $
        YERROR = yerror, $
        /NO_SAVEPROMPT

    idTool = ITGETCURRENT(TOOL=oTool)
    void = oTool->DoAction('Operations/Operations/Filter/Curve Fitting')
    oWin = oTool->GetCurrentWindow()
    oWin->ClearSelections
    void = oTool->DoAction('Operations/Insert/Legend')

end
