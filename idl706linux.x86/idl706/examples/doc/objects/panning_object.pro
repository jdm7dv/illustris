;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/panning_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO Panning_Object

; Determine the path to the file.
file = FILEPATH('nyny.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [768, 512]

; Import in the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Resize the image.
imageSize = [256, 256]
image = CONGRID(image, imageSize[0], imageSize[1])

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
   DIMENSIONS = imageSize, $
   TITLE = 'Panning Enlarged Image')

; Change view to zoom into the lower left quarter of
; the image.
viewplane = [0., 0., imageSize/2]
oView -> SetProperty, VIEWPLANE_RECT = viewplane

; Display updated view in new window.
oWindow -> Draw, oView

; Pan the view from the left side of the image to the
; right side of the image.
FOR i = 0, ((imageSize[0]/2) - 1) DO BEGIN
   viewplane = viewplane + [1., 0., 0., 0.]
   oView -> SetProperty, VIEWPLANE_RECT = viewplane
   oWindow -> Draw, oView
ENDFOR

; Clean up object references.
OBJ_DESTROY, oView

END