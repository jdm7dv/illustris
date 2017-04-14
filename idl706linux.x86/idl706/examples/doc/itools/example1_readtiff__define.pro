;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example1_readtiff__define.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example1_readtiff
;
; PURPOSE:
;   Example custom iTool file reader.
;   See "Creating File Readers" in the iTool Developer's Guide
;   for a detailed explanation of this class.
;
; CATEGORY:
;   iTools
;   
;-
;
FUNCTION example1_readTIFF::Init, _REF_EXTRA = _extra

   ; Call the superclass Init method
   IF (self->IDLitReader::Init(["tiff", "tif"],$
         NAME="Tiff Files", $
         DESCRIPTION="TIFF File format", $
         _EXTRA = _extra) NE 1) THEN $
   RETURN, 0

   ; Initialize the instance data field
   self._index = 0

   ; Register the index property
   self->RegisterProperty, 'IMAGE_INDEX', /INTEGER, $
      Description='Index of the image to read from the TIFF file.'

   ; Return success.
   RETURN,1

END


; Check whether the selected file is a TIFF file.
FUNCTION example1_readTIFF::Isa, strFilename

   RETURN, QUERY_TIFF(strFilename);

END


; Get the image data out of the TIFF file.
FUNCTION example1_readTIFF::GetData, oImageData

   ; Retrieve the file name from the file reader object.
   filename = self->GetFilename()

   ; If there is no image in the specified image index, return
   ; failure.
   IF (QUERY_TIFF(filename, fInfo, IMAGE_INDEX = self._index) EQ 0) $
      THEN RETURN, 0

   ; Read the image data into a variable.
   IF (fInfo.has_palette) THEN BEGIN
      image = READ_TIFF(filename, palRed, palGreen, palBlue, $
         IMAGE_INDEX = self._index)
   ENDIF ELSE BEGIN
      image = READ_TIFF(filename, IMAGE_INDEX = self._index)
   ENDELSE

   ; Store image data in Image Data object.
   oImageData = OBJ_NEW('IDLitDataIDLImage', $
      NAME = FILE_BASENAME(fileName))
   result = oImageData->SetData(image, 'ImagePixels', /NO_COPY)

   IF (result EQ 0) THEN RETURN, 0

   ; Store palette data in Image Data object.
   IF (fInfo.has_palette) THEN $
      result = oImageData->SetData( TRANSPOSE([[palRed], $
         [palGreen], [palBlue]]), 'Palette')

   IF fInfo.num_images GT 1 THEN $
      self->IDLitIMessaging::StatusMessage, $
         'Read channel ' + strtrim(self._index,2)

   RETURN, result

END


; The GetProperty method retrieves property values from
; the file reader object.
PRO example1_readTIFF::GetProperty, IMAGE_INDEX = image_index, $
   _REF_EXTRA = _extra

   IF (ARG_PRESENT(image_index)) THEN $
      image_index = self._index

   IF (N_ELEMENTS(_extra) GT 0) THEN $
      self->IDLitReader::GetProperty, _EXTRA = _extra

END


; The SetProperty method sets property values on the file
; reader object.
PRO example1_readTIFF::SetProperty, IMAGE_INDEX = image_index, $
   _REF_EXTRA = _extra

   IF (N_ELEMENTS(image_index) GT 0) THEN $
      self._index = image_index

   IF (N_ELEMENTS(_extra) GT 0) THEN $
      self->IDLitReader::SetProperty, _EXTRA = _extra

END


; Class definition routine. We inherit from the IDLitReader
; class, which gives us most of the functionality we need
; to read files.
PRO example1_readTIFF__Define

   struct = {example1_readTIFF,        $
             inherits IDLitReader, $
             _index : 0            $
           }
END

