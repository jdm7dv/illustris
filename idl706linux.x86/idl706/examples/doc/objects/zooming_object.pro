;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/zooming_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO Zooming_Object

; Determine the path to the file.
file = FILEPATH('convec.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [248, 248]

; Import in the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize display objects.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, $
   TITLE = 'A Grayscale Image')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., imageSize])
oModel = OBJ_NEW('IDLgrModel')

; Initialize image object.
oImage = OBJ_NEW('IDLgrImage', image, /GREYSCALE)

; Add the image object to the model, which is added to
; the view, then display the view in the window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Initialize another window.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, TITLE = 'Enlarged Area')

; Change view to zoom into the lower left quarter of
; the image.
oView -> SetProperty, $
   VIEWPLANE_RECT = [0., 0., imageSize/2]

; Display updated view in new window.
oWindow -> Draw, oView

; Clean up object references.
OBJ_DESTROY, oView

END