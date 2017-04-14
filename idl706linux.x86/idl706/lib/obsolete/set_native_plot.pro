; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/set_native_plot.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.

PRO SET_NATIVE_PLOT
    ver	= WIDGET_INFO(/version)
    CASE ver.style OF
    	'MS Windows':	SET_PLOT,'WIN'
    	ELSE: 		SET_PLOT,'X'
    ENDCASE
END
