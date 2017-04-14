;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example3tool.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example3tool
;
; PURPOSE:
;   Example custom iTool launch routine
;   See "Creating a Manipulator" in the iTool Developer's Guide
;   for a detailed explanation of this procedure
;
; CATEGORY:
;   iTools
;
;-
;
PRO example3tool, data, identifier = identifier, _REF_EXTRA = _extra

; Check for data entered by the user. Add input to a parameter set
; if it exists.
nparams = N_PARAMS()
IF (nparams GT 0) THEN BEGIN

   ; Create an IDLitParameterSet object to pass to the
   ; INITIAL_DATA keyword to IDLitSys_CreateTool.
   oparmset = OBJ_NEW('IDLitParameterSet')

   ; Verify data is present.
   IF (n_elements(data) GT 0) THEN BEGIN

      ; Create an IDLImagePixels type IDLitData object.
      odata = OBJ_NEW('IDLitDataIDLImagePixels')

      ; Copy the data to the data object
      result = odata->SetData(data, 'imagepixels', $
         _EXTRA = _extra)

      ; Add the IDLitData object to the parameter set.
      oparmset->Add, odata, PARAMETER_NAME = 'imagepixels'
   ENDIF

   ; Create a default palette for the image.
   ramp = BINDGEN(256)
   oPalette = OBJ_NEW('IDLitDataIDLPalette', $
      TRANSPOSE([[ramp], [ramp], [ramp]]), $
      NAME = 'Palette')
   oParmSet->Add, oPalette, PARAMETER_NAME = 'PALETTE'
ENDIF

; Register the new tool.
ITREGISTER, 'Color Table Tool', 'example3tool'

; Create an instance of the new tool.
identifier = IDLitSys_CreateTool('Color Table Tool', $
    NAME = 'Color Table Tool', $
    VISUALIZATION_TYPE = ['IMAGE'], $
    INITIAL_DATA = oparmset, _EXTRA = _extra, $
    TITLE = 'Example Color Table Tool')
END
