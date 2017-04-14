;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displayrgbimage_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayRGBImage_Object

; Determine the path to the file.
file = FILEPATH('rose.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Query the file to determine image parameters.
queryStatus = QUERY_IMAGE(file, imageInfo)

; Output the results of the query.
PRINT, 'Query Status = ', queryStatus
HELP, imageInfo, /STRUCTURE

; Set the image size parameter from the query
; information.
imageSize = imageInfo.dimensions

; Import in the image.
image = READ_IMAGE(file)

; Determine the size of each dimension within the image.
imageDims = SIZE(image, /DIMENSIONS)

; Determine the type of interleaving by comparing
; dimension size and the size of the image.
interleaving = WHERE((imageDims NE imageSize[0]) AND $
   (imageDims NE imageSize[1]))

; Output the results of the interleaving computation.
PRINT, 'Type of Interleaving = ', interleaving

; Initialize the display objects.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, TITLE = 'An RGB Image')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., imageSize])
oModel = OBJ_NEW('IDLgrModel')

; Initialize the image object.
oImage = OBJ_NEW('IDLgrImage', image, $
   INTERLEAVE = interleaving[0])

; Add the image object to the model, which is added to
; the view, then display the view in the window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Clean up object references.
OBJ_DESTROY, oView

END