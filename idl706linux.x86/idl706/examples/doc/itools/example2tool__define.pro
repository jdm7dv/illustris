;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example2tool__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example2tool__define
;
; PURPOSE:
;   Example custom iTool class definition.
;   See "Creating a Custom iTool Widget Interface" in the
;   iTool Developer's Guide for a detailed explanation of
;   this iTool class.
;
; CATEGORY:
;   iTools
;   
;-
;
FUNCTION example2tool::Init, _REF_EXTRA = _extra

   ; Call our super class
   IF ( self->IDLitToolbase::Init(_EXTRA = _extra) EQ 0) THEN $
      RETURN, 0

   ; This tool removes several of the standard iTool operations
   ; and manipulators.
  
   ;*** Insert menu
   self->UnRegister, 'OPERATIONS/INSERT/VISUALIZATION'
   self->UnRegister, 'OPERATIONS/INSERT/VIEW'
   self->UnRegister, 'OPERATIONS/INSERT/DATA SPACE'
   self->UnRegister, 'OPERATIONS/INSERT/COLORBAR'

   ;*** Window menu
   self->Unregister, 'OPERATIONS/WINDOW/FITTOVIEW'
   self->Unregister, 'OPERATIONS/WINDOW/DATA MANAGER'

   ;*** Operations menu
   self->UnRegister, 'OPERATIONS/OPERATIONS/MAP PROJECTION'

   ;*** Toolbars
   self->UnRegister, 'MANIPULATORS/ROTATE'

   ; Return success.
   RETURN, 1


END

; Class definition routine. Here we inherit the standard iTool
; functionality defined in the IDLitToolbase class.

PRO example2tool__Define

struct = { example2tool,              $
           INHERITS IDLitToolbase     $ ; Provides iTool interface
         }

END

