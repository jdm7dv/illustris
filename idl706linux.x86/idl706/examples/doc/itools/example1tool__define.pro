;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example1tool__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example1tool__define
;
; PURPOSE:
;   Example custom iTool class definition.
;   See "Creating an iTool" in the iTool Developer's Guide
;   for a detailed explanation of this iTool class.
;
; CATEGORY:
;   iTools
;
;-
;
FUNCTION example1tool::Init, _REF_EXTRA = _extra

   ; Call our super class
   IF ( self->IDLitToolbase::Init(_EXTRA = _extra) EQ 0) THEN $
      RETURN, 0

   ;*** Visualizations
   ; Here we register a custom visualization type described in
   ; the "Creating Visualizations" chapter of the iTool Developer's
   ; guide.

   self->RegisterVisualization, 'Image-Contour', 'example1_visImageContour', $
      ICON = 'image', /DEFAULT

   ;*** Operations menu
   ; Here we register a custom operation described in the "Creating
   ; Operations" chapter of the iTool Developer's guide.

   self->RegisterOperation, 'Example Resample', 'example1_opResample', $
      IDENTIFIER = 'Operations/Examples/Resample'

   ;*** Manipulators
   ; For an example of a custom manipulator, see the "Creating
   ; Manipulators" chapter of the iTool Developer's Guide.

   ;*** File Readers
   ; Here we register a custom file reader described in the "Creating
   ; File Readers" chapter of the iTool Developer's guide.

   self->RegisterFileReader, 'Example TIFF Reader', 'example1_readTIFF', $
        ICON='demo', /DEFAULT

   ;*** File Writers
   ; Here we unregister one of the standard file writers used by the
   ; iTools, replacing it with a custom file writer described in
   ; "Creating File Writers" in the iTool Developer's Guide.

   self->UnRegisterFileWriter, 'Tag Image File Format'

   self->RegisterFileWriter, 'Example TIFF Writer', 'example1_writetiff', $
      ICON='demo', /DEFAULT

   ; Return success.
   RETURN, 1

END

; Class definition routine. Here we inherit the standard iTool
; functionality defined in the IDLitToolbase class.

PRO example1tool__Define

struct = { example1tool,              $
           INHERITS IDLitToolbase     $ ; Provides iTool interface
         }

END

