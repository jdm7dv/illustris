;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example3tool__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example3tool__define
;
; PURPOSE:
;   Example custom iTool class definition.
;   See "Creating a Manipulator" in the iTool Developer's Guide
;   for a detailed explanation of this iTool class.
;
; CATEGORY:
;   iTools
;
;-
;; Tool Initialization
FUNCTION example3tool::Init, _REF_EXTRA = _extra

; Initialize the inherited iImage tool. If this fails, return.
IF (~(self->IDLitToolImage::Init(_EXTRA = _extra))) THEN $
   RETURN, 0

; Register the new color table manipulator. The Description
; appears in the status bar when the manipulator is activated.
; The ICON references example3_lut.bmp.
self->RegisterManipulator, 'Color Table', 'example3_manippalette', $
   DESCRIPTION='Click over image & drag right or left' $
   + ' to change color table', $
   ICON = FILEPATH('example3_lut.bmp', $
      SUBDIRECTORY=['examples', 'doc', 'itools'])

; Indicate success.
RETURN, 1

END

; ****************************************************************
; Tool Class Definition
PRO example3tool__define

; Define the structue of the tool.
structure = {example3tool, $
   INHERITS IDLitToolImage $ ; provides itool interface
   }
END
