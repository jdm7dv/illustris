; $Id: //depot/idl/IDL_70/idldir/lib/dicomex/dicomex_getstorscpdir.pro#2 $
; Copyright (c) 2004-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;   getDicomexStorScpDir
;
; PURPOSE:
;   Returns the directory StorScpDir used by the IDLffDicomExCfg object
;
; CALLING SEQUENCE:
;
;   PATH = GETDICOMEXSTORSCPDIR
;
; INPUTS:
;
;   NONE
;
; KEYWORD PARAMETERS:
;
;   NONE
;
; MODIFICATION HISTORY:
;   Written by:  LFG, RSI, October 2004
;   Modified by:
;
;-
function Dicomex_GetStorScpDir
  compile_opt idl2

  catch, errorStatus
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    return, path
  endif

  path = ''
  ocfg = obj_new('IDLffDicomExCfg', /system)
  path = ocfg->GetValue('StorScpDir')

  obj_destroy, ocfg
  return, path

end
