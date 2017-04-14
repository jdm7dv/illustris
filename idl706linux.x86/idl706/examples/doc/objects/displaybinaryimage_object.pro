;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/displaybinaryimage_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayBinaryImage_Object

; Determine the path to the file.
file = FILEPATH('continent_mask.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [360, 360]

; Import the image.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize display objects.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, $
   TITLE = 'A Binary Image, Not Scaled')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., imageSize])
oModel = OBJ_NEW('IDLgrModel')

; Initialize image object.
oImage = OBJ_NEW('IDLgrImage', image)

; Add the image to the model, which is added to the
; view, and then display the view in the window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Initialize another window.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, $
   TITLE = 'A Binary Image, Scaled')

; Update the image object with a scaled version of the
; image.
oImage -> SetProperty, DATA = BYTSCL(image)

; Display the view in the window.
oWindow -> Draw, oView

; Clean up object references.
OBJ_DESTROY, oView

END