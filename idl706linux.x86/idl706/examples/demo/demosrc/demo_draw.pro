;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo_draw.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
pro demo_draw, oWindow, oView, debug=debug
;
;Procedure DEMO_DRAW: call oWindow->Draw, oView
;wrapping the call in !except=0 if not DEBUG.
;
;On some platforms, when IDLgrWindow::Draw is invoked, math errors
;(e.g. "% Program caused arithmetic error: Floating illegal
;operand") are printed.  DEMO_DRAW exists to supress the printing of
;these errors.
;
;Flush and print any accumulated math errors
;
void = check_math(/print)
;
;Silently accumulate any subsequent math errors, unless we are debugging.
;
orig_except = !except
!except = ([0, 2])[keyword_set(debug)]
;
;Draw.
;
oWindow->Draw, oView
;
;Silently (unless we are debugging) flush any accumulated math errors.
;
void = check_math(PRINT=keyword_set(debug))
;
;Restore original math error behavior.
;
!except = orig_except
end