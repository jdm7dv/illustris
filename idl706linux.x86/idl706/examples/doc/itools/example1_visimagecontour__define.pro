;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example1_visimagecontour__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example1_visimagecontour
;
; PURPOSE:
;   Example custom iTool visualization type.
;   See "Creating Visualizations" in the iTool Developer's Guide
;   for a detailed explanation of this class.
;
; CATEGORY:
;   iTools
;   
;-
;

FUNCTION example1_visImageContour::Init, _REF_EXTRA = _extra

   ; Initialize the superclass
   IF (~self->IDLitVisualization::Init(NAME='example1_visImageContour', $
      ICON = 'image', _EXTRA = _extra)) THEN RETURN, 0

   ; Register the parameters we are using for data
   self->RegisterParameter, 'IMAGEPIXELS', $
      DESCRIPTION = 'Image Data', /INPUT, $
      TYPES = ['IDLIMAGE', 'IDLIMAGEPIXELS', 'IDLARRAY2D'], /OPTARGET
   self->RegisterParameter, 'PALETTE', $
      DESCRIPTION = 'Palette', /INPUT, /OPTIONAL, $
      TYPES = ['IDLPALETTE','IDLARRAY2D'], /OPTARGET

   ; Create objects and add to this Visualization
   self._oImage = OBJ_NEW('IDLitVisImage', /PRIVATE)
   self->Add, self._oImage, /AGGREGATE
   self._oContour = OBJ_NEW('IDLitVisContour', /PRIVATE)
   self->Add, self._oContour, /AGGREGATE

   ; Return success
   RETURN, 1

END

; The OnDataChangeUpdate method modifies the visualization when
; the data it was created from changes.
PRO example1_visImageContour::OnDataChangeUpdate, oSubject, parmName, $
   _REF_EXTRA = _extra

   ; Branch based on the value of the parmName string.
   CASE STRUPCASE(parmName) OF

      ; The method was called with a paramter set as the argument.
      '<PARAMETER SET>': BEGIN
      oParams = oSubject->Get(/ALL, COUNT = nParam, $
         NAME = paramNames)
         FOR i = 0, nParam-1 DO BEGIN
            IF (paramNames[i] EQ '') THEN CONTINUE
            oData = oSubject->GetByName(paramNames[i])
            IF (OBJ_VALID(oData)) THEN $
              self->OnDataChangeUpdate, oData, paramNames[i]
        ENDFOR
      END

      ; The method was called with an image array as the argument.
      'IMAGEPIXELS': BEGIN
      void = self._oImage->SetData(oSubject, $
         PARAMETER_NAME = 'IMAGEPIXELS')
      void = self._oContour->SetData(oSubject, $
         PARAMETER_NAME = 'Z')
      ; Make our contour appear at the top OF the surface.
      IF (oSubject->GetData(zdata)) THEN $
         self._oContour->SetProperty, ZVALUE = MAX(zdata)
      END

      ; The method was called with a palette as the argument.
      'PALETTE': BEGIN
      void = self._oImage->SetData(oSubject, $
         PARAMETER_NAME = 'PALETTE')
      void = self._oContour->SetData(oSubject, $
         PARAMETER_NAME = 'PALETTE')
      END

      ELSE: ; Do nothing

   ENDCASE

END

; The OnDataDisconnect method modifies the visualization when
; the data it was created from is "disconnected" from the
; visualization.
PRO example1_visImageContour::OnDataDisconnect, ParmName

CASE STRUPCASE(parmname) OF

   'IMAGEPIXELS': BEGIN
      self->SetProperty, DATA = 0
      self._oImage->SetProperty, /HIDE
      self._oContour->SetProperty, /HIDE
   END

   'PALETTE': BEGIN
      self._oImage->SetProperty, PALETTE = OBJ_NEW()
      self->SetPropertyAttribute, 'PALETTE', SENSITIVE = 0
   END

   ELSE: ; Do nothing
 ENDCASE

END

; Class definitin routine. We inherit from the IDLitVisualization
; class, which provides most of the infrastructure for a visualization
; type. We have two instance data fields to contain object references
; to the contour and image objects that make up our visualization
; type.
PRO example1_visImageContour__Define
   struct = { example1_visImageContour, $
      inherits IDLitVisualization, $
      _oContour: OBJ_NEW(), $
      _oImage: OBJ_NEW() $
   }
END

