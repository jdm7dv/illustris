;  $Id: //depot/idl/IDL_70/idldir/examples/doc/dicom/dicomex_importimage_doc.pro#2 $

; Copyright (c) 1995-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   dicomex_importimage_doc
;
; PURPOSE:
;   Example of getting pixel and setting monochrome and RGB
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
PRO dicomex_importimage_doc
; Import in the pixel data of an image, and
; then set it as the pixel data for a new Image
; object.

; Determine the full path to the image file.
sFile = DIALOG_PICKFILE(/MUST_EXIST, $
   TITLE = 'Select an Image File', $
   FILTER = ['*.bmp', '*.jpg', '*.png', $
      '*.ppm', '*.srf', '*.tif'], $
      GET_PATH=path)

; If no file is selected, return to the previous
; level.
IF (sFile EQ '') THEN RETURN

; Query the image file.
vOpenStatus = QUERY_IMAGE(sFile, vQueryInfo)

; If the file cannot be openned with IDL, return
; to the previous level.
IF (vOpenStatus NE 1) THEN RETURN

; Initialize some the image parameters.
vNumSamples = vQueryInfo.channels
vCols = vQueryInfo.dimensions[0]
vRows = vQueryInfo.dimensions[1]
vImgSize = vQueryInfo.dimensions
vNumFrames = vQueryInfo.num_images
vPixelType = vQueryInfo.pixel_type

; Handle single channel images.
If vNumSamples EQ 1 THEN BEGIN
   CASE vPixelType of
      1: BEGIN
         ; Set properties for byte data.
         vBitsAlloc = 8
         vPixelRep = 0 ; accept the default.
         vPhotoInterp = 'MONOCHROME2'
      END

      2: BEGIN
         ; Set properties for signed integer.
         vBitsAlloc = 10
         vPixelRep = 1
         vPhotoInterp = 'MONOCHROME2'
      END

      12: BEGIN
         ; Set properties for unsigned integer.
         vBitsAlloc = 16
         vPixelRep = 0
         vPhotoInterp = 'MONOCHROME2'
      END
   ENDCASE

   ; If the file contains multiple images, access these
   ; images as multiple frames. If the file contains
   ; only one image, access just that image.
   IF (vNumFrames GT 1) THEN BEGIN
      vPixelData = MAKE_ARRAY(vCols, vRows, vNumFrames, $
         TYPE = vPixelType)
      FOR vIndex = 0L, (vNumFrames - 1) DO $
         vPixelData[*, *, vIndex] = READ_IMAGE(sFile, $
            IMAGE_INDEX = vIndex)
   ENDIF ELSE BEGIN
      vPixelData = READ_IMAGE(sFile)
   ENDELSE

   ; Create a new DICOM file and set properties.
   oImg = OBJ_NEW('IDLffDicomEx', $
      path+PATH_SEP()+'aNewMonoImg.dcm', $
      SOP_CLASS = 'STANDARD_MR', /NON_CONFORMING, /CREATE)

   ; Call set pixel data with only required properties.
   oImg -> SetPixelData, vPixelData, $
      BITS_ALLOCATED = vBitsAlloc, $
      COLUMNS = vCols, $
      NUMBER_OF_FRAMES = vNumFrames, $
      PHOTOMETRIC_INTERPRETATION = vPhotoInterp, $
      PIXEL_REPRESENTATION = vPixelRep, $
      ROWS = vRows, $
      SAMPLES_PER_PIXEL = vNumSamples, $
      /ORDER

   ; Commit the file.
   oImg -> Commit

   ; Display monochrome image (frames).
   WINDOW, XSIZE=vcols, YSIZE=vrows, $
      TITLE = 'New Monochrome DICOM Image'

   FOR i = 1, vNumFrames DO BEGIN
      TVSCL, vPixelData[*,*,i-1]
      WAIT, 1
   ENDFOR

ENDIF

; If it is an RGB image, determine interleaving.
IF (vNumSamples EQ 3) THEN BEGIN

   ; Determine the size of all the dimensions of the pixel
   ; data array.
   vDataSize = SIZE(vPixelData, /DIMENSIONS)
   ; Determine the planar configuration of the image.
   vInterleave = WHERE((vDataSize NE vCols) AND $
      (vDataSize NE vRows))

   ; Return if line interleaved (vCols,3,vRows)
   IF (vInterleave[0] EQ 1) THEN RETURN

   ; If pixel interleaved (3,vCols,vRows), set to 0.
   ; If planar interleaved (vCols,vRows,3), set to 1
   IF (vInterleave[0] EQ 0) THEN vPlanarConfig = 0 $
      ELSE vPlanarConfig = 1

   ; Set other properties for RGB images.
   vBitsAlloc = 8
   vPhotoInterp = 'RGB'
   vPixelRep = 0

   ; Use READ_IMAGE to access the image array.
   vPixelData = READ_IMAGE(sFile)

   ; Create a new DICOM file and set properties.
   oImg = OBJ_NEW('IDLffDicomEx', $
      path+PATH_SEP()+'aNewRBGImg.dcm', $
      SOP_CLASS = 'STANDARD_US', /NON_CONFORMING, /CREATE)

   ; Call set pixel data with required properties
   oImg -> SetPixelData, vPixelData, $
      BITS_ALLOCATED = vBitsAlloc, $
      COLUMNS = vCols, $
      NUMBER_OF_FRAMES = vNumFrames, $
      PHOTOMETRIC_INTERPRETATION = vPhotoInterp, $
      PIXEL_REPRESENTATION = vPixelRep, $
      PLANAR_CONFIGURATION = vPlanarConfig, $
      ROWS = vRows, $
      SAMPLES_PER_PIXEL = vNumSamples, $
      /ORDER
   oImg -> Commit

   ; Display RGB image.
   WINDOW, XSIZE=vcols, YSIZE=vrows, TITLE = 'New RGB DICOM Image'

   IF vPlanarConfig EQ 0 THEN vTrue = 1 ELSE vTrue = 3
   TV,  vPixelData, TRUE = vTrue

ENDIF

; Clean up the object references.
OBJ_DESTROY, [oImg]

; Note: the following lines allow you to run the program
; multiple times without having to manually delete files.
; You cannot duplicate an existing file when creating or cloning
; a DICOM file.
FILE_DELETE, path+PATH_SEP()+'aNewMonoImg.dcm', /ALLOW_NONEXISTENT
FILE_DELETE, path+PATH_SEP()+'aNewRBGImg.dcm', /ALLOW_NONEXISTENT

END
