;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example1tool.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example1tool
;
; PURPOSE:
;   Example custom iTool launch routine
;   See "Creating an iTool" in the iTool Developer's Guide
;   for a detailed explanation of this procedure
;
; CATEGORY:
;   iTools
;   
;-
;
PRO example1tool, data, IDENTIFIER = identifier, _REF_EXTRA = _extra

; Build a parameter set from data passed in at the command line.
IF (N_PARAMS() gt 0) THEN BEGIN
   oParmSet = OBJ_NEW('IDLitParameterSet', $
      NAME = 'example 1 parameters', $
      ICON = 'image', $
      DESCRIPTION = 'Example tool parameters')

   IF (N_ELEMENTS(data) GT 0) THEN BEGIN
      oData = OBJ_NEW('IDLitDataIDLImagePixels')
      result = oData->SetData(data, _EXTRA = _extra)
      oParmSet->Add, oData, PARAMETER_NAME = 'ImagePixels'

      ; Create a default grayscale ramp.
      ramp = BINDGEN(256)
      oPalette = OBJ_NEW('IDLitDataIDLPalette', $
         TRANSPOSE([[ramp], [ramp], [ramp]]), $
         NAME = 'Palette')
      oParmSet->Add, oPalette, PARAMETER_NAME = 'PALETTE'

   ENDIF

ENDIF

   ; Register our iTool class with the iTool system.
   ITREGISTER, 'Example 1 Tool', 'example1tool'

   ; Create an instance of our iTool.
   identifier = IDLITSYS_CREATETOOL('Example 1 Tool',$
      VISUALIZATION_TYPE = ['Image-Contour'], $
      INITIAL_DATA = oParmSet, _EXTRA = _extra, $
      TITLE = 'First Example iTool')
END

