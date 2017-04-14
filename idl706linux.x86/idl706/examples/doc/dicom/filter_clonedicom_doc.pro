;  $Id: //depot/idl/IDL_70/idldir/examples/doc/dicom/filter_clonedicom_doc.pro#2 $

; Copyright (c) 1995-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   filter_clonedicom_doc
;
; PURPOSE:
;   Example of getting pixel and setting monochrome
;   pixel data using the IDLffDicomEx object.
;   A special license key is required for this functionality.
;   See the Medical Imaging in IDL manual for IDLffDicomEx
;   object reference information.
;
; CATEGORY:
;   DICOM
;
;-
;
PRO filter_clonedicom_doc

; Select a DICOM file.
sFile = DIALOG_PICKFILE( $
    PATH=FILEPATH('',SUBDIRECTORY=['examples','data']), $
    TITLE='Select DICOM Patient File', FILTER='*.dcm', $
    GET_PATH=path)

; Create a clone (aImgClone.dcm) of the selected file (sfile).
 oImg = OBJ_NEW('IDLffDicomEx', path + 'aImgClone.dcm', $
    CLONE=sfile)

; Get image attributes.
oImg->GetProperty, BITS_ALLOCATED = vBA, ROWS=rows, $
   COLUMNS=cols, SAMPLES_PER_PIXEL=samples

; Allow user to select monochrome image.
IF samples gt 1 THEN BEGIN
   v= DIALOG_MESSAGE('This application requires ' + $
      'a monochrome image.', /ERROR)
sFile = DIALOG_PICKFILE( $
    PATH=FILEPATH('',SUBDIRECTORY=['examples','data']), $
    TITLE='Select DICOM Patient File', FILTER='*.dcm', $
    GET_PATH=path)
   ; Create a clone (aImgClone.dcm) of the selected file (sfile).
   oImg = OBJ_NEW('IDLffDicomEx', path + 'aImgClone.dcm', $
      CLONE=sfile)
ENDIF

; Check to see if the image has multiple frames.
; First check for the presence of the Number of Frames tag.
FrameTest = oImg->QueryValue('NUMBER_OF_FRAMES')

; If the tag exists and has a value, retrieve it. Pixel data
; FRAME index is zero-based so subtract 1 from the value.
; ORDER is set for IDL consistency.
IF FrameTest EQ 2 THEN BEGIN
   oImg->GetProperty, NUMBER_OF_FRAMES=frame
   FRAME = frame - 1
   ORDER=0
; Otherwise, set FRAME to 0 indicating is is a single frame
; image. ORDER is set for IDL consistency.
ENDIF ELSE BEGIN
   FRAME = 0
   ORDER =0
ENDELSE

; Return all of the frames of pixel data by
; not specifying a value for FRAME.
vPixels = oImg->GetPixelData(ORDER=order, COUNT=cnt)
PRINT, 'Returned pixel data for number of frames = ', cnt

; Initialize and array of the proper type for the
; filtered pixel data.
IF vBA GT 8 THEN BEGIN
    vFilterArr = INTARR([rows,cols,frame+1])
ENDIF ELSE BEGIN
    vFilterArr = BYTARR([rows,cols,frame+1])
ENDELSE

; Filter each frame of data or the single frame.
IF frame GT 0 THEN BEGIN
   FOR n = 1, frame+1 DO BEGIN
      vFilterPixels = ROBERTS(vPixels[*,*,n-1])
      vFilterArr[*,*,n-1] = vFilterPixels
   ENDFOR
ENDIF ELSE BEGIN
   vFilterArr = ROBERTS(vPixels)
ENDELSE

; Roberts function changes byte data to integer.
; SetPixelData requires array of original type.
; If original array was byte (as indicated by
; BITS_ALLOCATED = 8), change the array back to byte.
IF vBA EQ 8 THEN BEGIN
   vFilterArr = BYTE(vFilterArr)
End

; Set the pixel data of the frame(s) back to the image.
oImg->SetPixelData, vFilterarr, ORDER=order

; Write the pixel data changes to the file.
oImg-> Commit

; Sequentially display each frame of the original
; and filtered data.
WINDOW, XSIZE=cols*2, YSIZE=rows, $
   TITLE = 'Original and Filtered Frames'
FOR i = 1, frame+1 DO BEGIN
   TVSCL, vPixels[*,*,i-1], 0, ORDER = order
   TVSCL, vfilterarr[*,*,i-1], 1, ORDER = order
   WAIT, 1
ENDFOR

; Clean up references.
OBJ_DESTROY, oImg

; Note: the following line allows you to run the program
; multiple times without having to manually delete the file.
; You cannot duplicate an existing file when creating or cloning
; a DICOM file.
FILE_DELETE, path + 'aImgClone.dcm', /ALLOW_NONEXISTENT

END
