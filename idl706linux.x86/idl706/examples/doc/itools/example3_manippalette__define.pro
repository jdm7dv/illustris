;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example3_manippalette__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example3_manippalette
;
; PURPOSE:
;   Example custom iTool manipulator.
;   See "Creating a Manipulator" in the iTool Developer's Guide
;   for a detailed explanation of this manipulator.
;
; CATEGORY:
;   iTools
;
;-
;; ****************************************************************
; Create the color table manipulator class definition.
; Always use keyword inheritance (the _REF_EXTRA keyword)
; to pass keyword parameters through to called routines.
FUNCTION example3_manippalette::Init, $
    _REF_EXTRA=_extra

COMPILE_OPT idl2, HIDDEN

; Initialize the manipulator.
IF (~self->IDLitManipulator::Init( $
   NAME='Color Table', $
   TYPES=['IDLIMAGE'], $
   OPERATION_IDENTIFIER="SET_PROPERTY", $
   PARAMETER_IDENTIFIER="VISUALIZATION_PALETTE", $
   _EXTRA = _extra)) THEN $
      RETURN, 0

; Register the cursor of the manipulator.
self->example3_manippalette::DoRegisterCursor

; Initialize a working palette.
self.oPalette = OBJ_NEW('IDLgrPalette')

; Indicate success if all has succeeded.
RETURN, 1
END

; ****************************************************************
; Select single plane images from among the selected
; visualizations.
PRO example3_manippalette::SelectSinglePlaneImages, $
    N_IMAGES=nImages

; If nothing is selected, return.
IF (self.nSelectionList EQ 0) THEN $
   RETURN

; Cull out multi-channel (RGB and RGBA) images from selection list.
; Cycle through the public instance pointer, pSelectionList,
; accessing all images. Use the number of selected items, contained
; in nSelectionList, to access each object in pSelectionList.
nValid = 0
nImages = 0
FOR i=0, self.nSelectionList-1 DO BEGIN
   oImage = (*self.pSelectionList)[i]
   IF (OBJ_ISA(oImage,'IDLitVisImage')) THEN BEGIN

      ; Increment nImages counter.
      nImages++

      ; Determine if the image is single plane. If so, add the
      ; image to the array of valid images and increment the
      ; nValid counter.
      oImage->GetProperty, N_IMAGE_PLANES=nImgPlanes
      IF (nImgPlanes EQ 1) THEN BEGIN
         validImgs=(nValid gt 0) ? [validImgs, oImage] : [oImage]
         nValid++
      ENDIF
   ENDIF
ENDFOR

IF (nValid GT 0) THEN BEGIN
   ; Store valid images using pSelectionList and nSelectionList.
   *self.pSelectionList = validImgs
   self.nSelectionList = nValid
ENDIF ELSE BEGIN
   ; If one or more images had been selected, but none are
   ; single-plane, then issue message.
   IF (nImages GT 0) THEN BEGIN
      self->ErrorMessage, $
      'Palettes can only be changed for single-plane images.', $
         TITLE='Color Table Manipulator Message', $
         SEVERITY=2
   ENDIF

   ; No images to manipulate - reset pSelectionList and    nSelectionList.
   void = TEMPORARY(*self.pSelectionList)
   self.nSelectionList = 0
   self.oImage = OBJ_NEW()
ENDELSE
END

; ****************************************************************
; Configure the mouse down method. This is activated when
; the mouse button is clicked over the image.
PRO example3_manippalette::OnMouseDown, oWin, x, y, iButton, $
    KeyMods, nClicks

; Call our superclass.
self->IDLitManipulator::OnMouseDown, $
   oWin, x, y, iButton, KeyMods, nClicks

; Return if there is no selection. Otherwise validate selection.
IF (self.nSelectionList EQ 0) THEN $
   RETURN
self->SelectSinglePlaneImages, N_IMAGES=nImages

; If no visualization meets requirements, return.
IF ((self.nSelectionList EQ 0) && (nImages GT 0)) THEN BEGIN
; Revert to default manipulator.
   oTool = self->GetTool()
   oTool->ActivateManipulator, /DEFAULT
   RETURN
ENDIF

; Use the first image in the selection list as the
; color table selection target. Note that GRID_DIMENSIONS
; is a property of the undocumented IDLitVisImage class,
; of which self.oImage is an instance.
self.oImage = (*self.pSelectionList)[0]
self.oImage->GetProperty, GRID_DIMENSIONS=imgDims
self.imgDims = imgDims

; Record the current values for the selected images.
iStatus = self->RecordUndoValues()
END

; ****************************************************************
; Configure the mouse up method
PRO example3_manippalette::OnMouseUp, oWin, x, y, iButton

IF (OBJ_VALID(self.oImage)) THEN BEGIN
   ; Commit this transaction.
   iStatus = self->CommitUndoValues()
ENDIF

; Reset the structure fields.
self.oImage = OBJ_NEW()

; Call our superclass.
self->IDLitManipulator::OnMouseUp, oWin, x, y, iButton
END

; ****************************************************************
; Configure mouse motion method.
pro example3_manippalette::OnMouseMotion, oWin, x, y, KeyMods

; If there is not a valid image object, return.
IF (~OBJ_VALID(self.oImage)) THEN BEGIN

   ; Call our superclass.
   self->IDLitManipulator::OnMouseMotion, oWin, x, y, KeyMods
   RETURN
ENDIF

; Activate if mouse button is held down.
IF self.ButtonPress NE 0 THEN BEGIN

   ; Map window coordinates to image data coordinates.
   self.oImage->WindowToVis, x, y, 0, dataX, dataY, dataZ

   ; Map image data coordinates to pixel coordinates.
   ; Note that the GeometryToGrid method is inherited from
   ; a superclass of the undocumented IDLitVisImage class,
   ; of which self.oImage is an instance.
   self.oImage->GeometryToGrid, dataX[0], dataY[0], imgX, imgY

   ; If the x image dimension is greater than the number
   ; of colortables find the range of how many pixels per
   ; colortable specification.
   IF self.imgDims[0] LT 41 THEN BEGIN
      self.colortable = FIX(ABS(imgX))
   ENDIF ELSE BEGIN
      stepSize = FIX(self.imgDims[0]/41)
      self.colorTable = (FIX(imgX/stepSize) > 0) < 40
   ENDELSE

   ; Assign the color table to the palette.
   self.oPalette->LoadCT, self.colortable
   self.oPalette->GetProperty, BLUE_VALUES=blue, $
      GREEN_VALUES=green, RED_VALUES=red
   palette = TRANSPOSE([[red],[green],[blue]])

   ; Apply the palette to the image. This automatically
   ; notifies the observer (the window) to update itself.
   self.oImage->SetProperty, VISUALIZATION_PALETTE=palette


   ; Write the color table number to the status bar using the
   ;inherited IDLitIMessaging ProbeStatusMessage method.
   self-> ProbeStatusMessage,  'Color table number: ' $
      + STRTRIM(String(self.colortable),2)

ENDIF

; Call our superclass.
self->IDLitManipulator::OnMouseMotion, oWin, x, y, KeyMods
END

; ****************************************************************
; Configure Keyboard method to respond to right or left arrow keys.
pro example3_manippalette::OnKeyboard, oWin, $
    IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods

; If not a keyboard press event, return.
IF (~Press) THEN $
   RETURN

; Retrieve the list of currently selected visualizations.
oSelectList = oWin->GetSelectedItems(COUNT=nSelect)
self.nSelectionList = nSelect

IF (nSelect GT 0) THEN BEGIN
   ; Cull selection list to include only single plane images.
   *self.pSelectionList = oSelectList
   self->SelectSinglePlaneImages
ENDIF

; If there are no valid single-plane images selected, return.
IF (self.nSelectionList EQ 0) THEN $
   RETURN

; Use the first image in the selection list as the
; color table selection target. Note that GRID_DIMENSIONS
; is a property of the undocumented IDLitVisImage class,
; of which self.oImage is an instance.
self.oImage = (*self.pSelectionList)[0]
self.oImage->GetProperty, GRID_DIMENSIONS=imgDims
self.imgDims = imgDims

; Record the current values for the selected images.
iStatus = self->RecordUndoValues()

IF (~IsASCII) THEN BEGIN

   CASE KeyValue OF

      ; Left arrow key.
      5: IF self.colortable EQ 0 THEN self.colortable = 40 $
         ELSE IF self.colortable NE 0 THEN $
            self.colortable = self.colortable - 1

      ; Right arrow key.
      6: IF self.colortable EQ 40 THEN self.colortable = 0 $
         ELSE IF self.colortable NE 40 THEN $
            self.colortable = self.colortable + 1
   ENDCASE
ENDIF

; Assign the color table to the palette.
self.oPalette->LoadCT, self.colortable
self.oPalette->GetProperty, BLUE_VALUES=blue, $
   GREEN_VALUES=green, RED_VALUES=red
palette = TRANSPOSE([[red],[green],[blue]])

; Modify the palette of the image. This automatically
; notifies the observer (the window) to update itself.
self.oImage->SetProperty, VISUALIZATION_PALETTE=palette

; Commit this transaction.
iStatus = self->CommitUndoValues()

; Write the color table number to the status bar using the
; inherited IDLitIMessaging ProbeStatusMessage method.
self-> ProbeStatusMessage,  'Color table number: ' $
   + STRTRIM(String(self.colortable),2)

END

; ****************************************************************
; Configure the DoRegisterCursor method
; This method will create the cursor for the manipulator.
pro example3_manippalette::DoRegisterCursor

  compile_opt idl2, hidden

; Define the default cursor for this manipulation.
  strArray = [ $
      '                ', $
      '                ', $
      '                ', $
      '                ', $
      '                ', $
      '  .#.      .#.  ', $
      ' .#..........#. ', $
      '.##############.', $
      '###....$.....###', $
      '.##############.', $
      ' .#..........#. ', $
      '  .#.      .#.  ', $
      '                ', $
      '                ', $
      '                ', $
      '                ']

; Register the new cursor with the tool.
  self->RegisterCursor, strArray, 'LUT', /DEFAULT
END

; ****************************************************************
PRO example3_manippalette::Cleanup

; Call superclass Cleanup method
self->IDLitManipulator::Cleanup

OBJ_DESTROY, self.oPalette
END

; ****************************************************************
; Class Definition
pro example3_manippalette__define
  compile_opt idl2, hidden

; Define the doc_colortablemanip class structure which inherits
; the IDLitManipulator class and class instance data used by this
; manipulator.
void = {example3_manippalette,        $
      inherits IDLitManipulator,  $ ; Superclass
      oImage: OBJ_NEW(),          $ ; Target image.
      imgDims: DBLARR(2),         $ ; Image dimensions
      oPalette: OBJ_NEW(),        $ ; Working palette.
      colortable: 0               $ ; Color table value
   }
END
