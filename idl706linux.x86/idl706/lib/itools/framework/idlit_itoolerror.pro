; $Id: //depot/idl/IDL_70/idldir/lib/itools/framework/idlit_itoolerror.pro#1 $
;
; Purpose:
;   An include file that should be used at the top of every iTool.
;   Controls error handling and cleans up any parameter sets.
;
; Use:
;   To disable error handling, use /DEBUG from one of the iTools.
;
; First check for the DEBUG keyword.
if (N_Elements(debug)) then Defsysv, '!iTools_Debug', Keyword_Set(debug)
@idlit_on_error2.pro
@idlit_catch.pro
if (iErr ne 0) then begin
    Catch, /CANCEL
    if (N_Elements(oParmSet)) then Obj_Destroy, oParmSet
    ; Remove name in front of the error message.
    semi = Strpos(!Error_State.msg, ':')
    if (semi gt 0) then !Error_State.msg = Strmid(!Error_State.msg, semi+2)
    Message, !Error_State.msg
    Return
endif
; end idlit_itoolerror
