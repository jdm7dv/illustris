; $Id: //depot/idl/IDL_70/idldir/lib/itools/ui_widgets/idlituifileexit.pro#2 $
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;   IDLitUIFileExit
;
; PURPOSE:
;   This function implements the user interface for file selection
;   for the IDL Tool. The Result is a success flag, either 0 or 1.
;
; CALLING SEQUENCE:
;   Result = IDLitUIFileExit(Requester [, UVALUE=uvalue])
;
; INPUTS:
;   Requester - Set this argument to the object reference for the caller.
;
; KEYWORD PARAMETERS:
;
;   UVALUE: User value data.
;
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, March 2002
;   Modified:
;
;-



;-------------------------------------------------------------------------
function IDLitUIFileExit, oUI, oRequester

    compile_opt idl2, hidden

    ; Retrieve widget ID of top-level base.
    oUI->GetProperty, GROUP_LEADER=id

    if (N_ELEMENTS(id) gt 0) then begin
        event = {WIDGET_KILL_REQUEST, ID: id, TOP: id, HANDLER: id}
        WIDGET_CONTROL, id, SEND_EVENT=event
    endif

    return, 1
end

