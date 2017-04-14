;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example1_opresample__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example1_opresample
;
; PURPOSE:
;   Example custom iTool operation.
;   See "Creating Operations" in the iTool Developer's Guide
;   for a detailed explanation of this operation.
;
; CATEGORY:
;   iTools
;   
;-
;

FUNCTION example1_opResample::Init, _REF_EXTRA = _extra

   ; Call the superclass Init method, setting data types
   ; on which the operation will act.
   IF (~ self->IDLitDataOperation::Init(NAME='Resample', $
   TYPES=['IDLVECTOR','IDLARRAY2D','IDLARRAY3D'], $
   DESCRIPTION="Resampling", _EXTRA = _extra)) THEN $
      RETURN, 0

   ; Set the default values for resampling factors.
   self._x = 2
   self._y = 2
   self._z = 2

   ; Register properties
   self->RegisterProperty, 'X', /FLOAT, $
      DESCRIPTION='X resampling factor.'

   self->RegisterProperty, 'Y', /FLOAT, $
      DESCRIPTION='Y resampling factor.'

   self->RegisterProperty, 'Z', /FLOAT, $
      DESCRIPTION='Z resampling factor.'

   self->RegisterProperty, 'METHOD', $
      ENUMLIST=['Nearest neighbor', 'Linear', 'Cubic'], $
      NAME='Interpolation method', $
      DESCRIPTION='Interpolation method.'

   ; Unhide the SHOW_EXECUTION_UI property.
   self->SetPropertyAttribute, 'SHOW_EXECUTION_UI', HIDE=0

   ; Use the keyword inheritance mechanism to pass "extra"
   ; keyword parameters to the superclass SetProperty method.
   IF (N_ELEMENTS(_extra) GT 0) THEN $
      self->example1_opResample::SetProperty, _EXTRA = _extra

   ; Return success.
   RETURN, 1

END

; Execute method. This method does the work of the operation.
FUNCTION example1_opResample::Execute, data

   ; Get the dimensions of the selected data.
   dims = SIZE(data, /DIMENSIONS)

   ; Create an array of the size specified by the user.
   ; The new size is a multiple of the original size.
   CASE N_ELEMENTS(dims) OF
      1: newdims = dims*ABS([self._x]) > [1]
      2: newdims = dims*ABS([self._x, self._y]) > [1, 1]
      3: newdims = dims*ABS([self._x, self._y, self._z]) > [1, 1, 1]
      ELSE: RETURN, 0
   ENDCASE

   ; If there is no change in size, just return success.
   IF (ARRAY_EQUAL(newdims, dims)) THEN RETURN, 1

   ; Retrieve the resampling method from the operation's
   ; properties.
   interp = 0 & cubic = 0
   CASE (self._method) OF
      0: ; do nothing
      1: interp = 1
      2: cubic = 1
   ENDCASE

   ; Resample the data.
   CASE N_ELEMENTS(dims) OF
      1: data = CONGRID(data, newdims[0], $
            INTERP = interp, CUBIC = cubic)
      2: data = CONGRID(data, newdims[0], newdims[1], $
            INTERP = interp, CUBIC = cubic)
      ; CONGRID always uses linear interp with 3D
      3: data = CONGRID(data, newdims[0], newdims[1], newdims[2])
   ENDCASE

   ; Return success.
   RETURN, 1

END

; This method displays the operation's property sheet,
; allowing the user to specify values of operation properties
; to be used when the operation is executed.
FUNCTION example1_opResample::DoExecuteUI

   ; Get an object reference to the current iTool
   oTool = self->GetTool()
   IF (~oTool) THEN RETURN, 0

   ; Make sure we set up our data dimensions for the
   ; property sheet.
   pData = self->_RetrieveDataPointers(DIMENSIONS=dims)
   IF ~PTR_VALID(pData[0]) THEN RETURN, 0

   ; How many dimensions does our input data have?
   ndim = 1 + MAX(WHERE(dims gt 0))

   ; Desensitize properties for higher dimensions.
   CASE ndim OF
     1: self->SetPropertyAttribute, $
         ['Y', 'Z'], SENSITIVE=0
     2: self->SetPropertyAttribute, 'Z', SENSITIVE=0
     3: BEGIN
         self->SetPropertyAttribute, 'METHOD', SENSITIVE=0
         method = self._method
         self._method = 1 ; 3D always uses linear
        END
     ELSE:
   ENDCASE

   ; Call the Property Sheet UI service to display the
   ; property sheet.
   result = oTool->DoUIService('PropertySheet', self)

   ; Resensitize all properties.
   self->SetPropertyAttribute, ['Y', 'Z'], /SENSITIVE

   IF (ndim EQ 3) THEN BEGIN
     ; Restore the method
     self._method = method
     self->SetPropertyAttribute, 'METHOD', /SENSITIVE
   ENDIF

   ; Return the result of the call to the UI Service
   ; (1 or 0).
   RETURN, result

END

; The GetProperty method retrieves values of the operation's
; properties.
PRO example1_opResample::GetProperty, $
   X = x, $
   Y = y, $
   Z = z, $
   METHOD = method, $
   _REF_EXTRA = _extra

   ; Operation properties.
   IF ARG_PRESENT(x) THEN $
      x = self._x

   IF ARG_PRESENT(y) THEN $
      y = self._y

   IF ARG_PRESENT(z) THEN $
      z = self._z

   IF ARG_PRESENT(method) THEN $
      method = self._method

   ; Superclass properties.
   IF (N_ELEMENTS(_extra) gt 0) THEN $
      self->IDLitDataOperation::GetProperty, _EXTRA = _extra

END

; The GetProperty method sets values of the operation's
; properties.
PRO example1_opResample::SetProperty, $
   X = x, $
   Y = y, $
   Z = z, $
   METHOD = method, $
   _REF_EXTRA = _extra

   ; Operation properties.
   IF N_ELEMENTS(x) THEN $
      IF (x NE 0) THEN self._x = x

   IF N_ELEMENTS(y) THEN $
      IF (y NE 0) THEN self._y = y

   IF N_ELEMENTS(z) THEN $
      IF (z NE 0) THEN self._z = z

   IF N_ELEMENTS(method) THEN $
      self._method = method

   ; Superclass properties.
   IF (N_ELEMENTS(_extra) gt 0) THEN $
      self->IDLitDataOperation::SetProperty, _EXTRA = _extra

END


; Class structure definition.
PRO example1_opResample__define

   struc = {example1_opResample, $
      inherits IDLitDataOperation,   $
      _x: 0d, $
      _y: 0d, $
      _z: 0d, $
      _method: 0b $
      }

END

