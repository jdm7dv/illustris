;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example1_writetiff__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example1_writetiff
;
; PURPOSE:
;   Example custom iTool file writer.
;   See "Creating File Writers" in the iTool Developer's Guide
;   for a detailed explanation of this class.
;
; CATEGORY:
;   iTools
;
;-
;
FUNCTION example1_writetiff::Init, _REF_EXTRA = _extra

   IF (self->IDLitWriter::Init('tiff', $
      TYPES=['IDLIMAGE', 'IDLIMAGEPIXELS', 'IDLARRAY2D'], $
      NAME='Tag Image File Format', $
      DESCRIPTION='Tag Image File Format (TIFF)', $
      _EXTRA = _extra) EQ 0) THEN $
      RETURN, 0

   RETURN, 1

END

; The SetData method retrieves the data from the item selected
; in the Export Wizard's tree view, then writes the data to
; a file.
FUNCTION example1_writetiff::SetData, oImageData

   ; We need a filename for the file we are about to write.
   strFilename = self->GetFilename()
   IF (strFilename EQ '') THEN $
      RETURN, 0 ; failure

   ; Make sure that the object passed to this method is valid.
   IF (~ OBJ_VALID(oImageData)) THEN BEGIN
      MESSAGE, 'Invalid image data object.', /CONTINUE
      RETURN, 0 ; failure
   ENDIF

   ; First, we look for some image data.
   oData = (oImageData->GetByType('IDLIMAGEPIXELS'))[0]

   ; If we did not get any image data, try retrieving a
   ; 2D array.
   IF (~ OBJ_VALID(oData)) THEN BEGIN
      oData = (oImageData->GetByType('IDLARRAY2D'))[0]
      IF (~ OBJ_VALID(oData)) THEN RETURN, 0
   ENDIF

   ; If we got neither image data nor a 2D array, 
   ; exit with a failure code.
   IF (~ oData->GetData(image)) THEN BEGIN
      MESSAGE, 'Error retrieving image data.', /CONTINUE
      RETURN, 0 ; failure
   ENDIF

   ; Next, try to retrieve a palette object from the selected
   ; object.
   oPalette = (oImageData->GetByType('IDLPALETTE'))[0]

   ; If we got a palette object, retrive the palette data
   ; and store the information in the variables red, green,
   ; and blue.
   IF (OBJ_VALID(oPalette)) THEN BEGIN
      success = oPalette->GetData(palette)
      IF (N_ELEMENTS(palette) GT 0) THEN BEGIN
         red = REFORM(palette[0,*])
         green = REFORM(palette[1,*])
         blue = REFORM(palette[2,*])
      ENDIF
   ENDIF

   ; Retrieve the number of dimensions in our image.
   ndim = SIZE(image, /N_DIMENSIONS)

   ; Write the file. The REVERSE ensures that other
   ; applications will read the image in right side up.
   WRITE_TIFF, strFilename, REVERSE(image, ndim), $
      RED = red, GREEN = green, BLUE = blue

   RETURN, 1  ; success

END


; Class definition routine. We inherit from the IDLitWriter
; class, which gives us most of the functionality we need
; to write files.
PRO example1_writeTIFF__Define

   struct = {example1_writeTIFF,       $
             inherits IDLitWriter  $
           }
END

