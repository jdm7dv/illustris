;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example4tool__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example4tool__define
;
; PURPOSE:
;   Example custom iTool class definition, used to display
;   the example user interface panel described in "Creating
;   a User Interface Panel" in the iTool Developer's Guide.
;
; CATEGORY:
;   iTools
;   
;-
;
FUNCTION example4tool::Init, _REF_EXTRA = _extra

   ; Call our super class
   IF ( self->IDLitToolbase::Init(TYPE = 'EXAMPLE', $
      _EXTRA = _extra) EQ 0) THEN $
      RETURN, 0

   ; Return success.
   RETURN, 1


END

; Class definition routine. Here we inherit the standard iTool
; functionality defined in the IDLitToolbase class.

PRO example4tool__define

struct = { example4tool,              $
           INHERITS IDLitToolbase     $ ; Provides iTool interface
         }

END

