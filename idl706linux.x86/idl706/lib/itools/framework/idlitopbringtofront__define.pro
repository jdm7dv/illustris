; $Id: //depot/idl/IDL_70/idldir/lib/itools/framework/idlitopbringtofront__define.pro#2 $
;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;----------------------------------------------------------------------------
;;---------------------------------------------------------------------------
;; IDLitopBringToFront::DoAction
;;
;; Purpose:
;;
;; Parameters:
;; None.
;;
;-------------------------------------------------------------------------
function IDLitopBringToFront::DoAction, oTool

    compile_opt idl2, hidden

    return, self->IDLitopOrder::DoAction(oTool, 'Bring to Front')
end


;-------------------------------------------------------------------------
pro IDLitopBringToFront__define

    compile_opt idl2, hidden
    struc = {IDLitopBringToFront, $
        inherits IDLitopOrder}

end

