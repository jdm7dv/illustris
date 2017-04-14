;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example2tool.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example2tool
;
; PURPOSE:
;   Example custom iTool launch routine
;   See "Creating a Custom iTool Widget Interface" in the
;   iTool Developer's Guide for a detailed explanation of
;   this procedure.

; CATEGORY:
;   iTools
;   
;-
;
PRO example2tool, IDENTIFIER = identifier, _REF_EXTRA = _extra

   ; Register our iTool class with the iTool system.
   ITREGISTER, 'Example 2 Tool', 'example2tool'
   ; Register our custom user interface definition.
   ITREGISTER, 'Example2_UI', 'example2_wdtool', /USER_INTERFACE

   ; Create an instance of an iTool that uses our custom interface.
   identifier = IDLITSYS_CREATETOOL('Example 2 Tool',$
      VISUALIZATION_TYPE = ['Plot'], $
      USER_INTERFACE='Example2_UI', $
      TITLE = 'Example iTool Interface', $
      _EXTRA = _extra)
END

