;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/displaymultiples_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayMultiples_Object

; Determine the path to the file.
file = FILEPATH('rose.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Query the file to determine image parameters.
queryStatus = QUERY_IMAGE(file, imageInfo)

; Set the image size parameter from the query
; information.
imageSize = imageInfo.dimensions

; Import the image.
image = READ_IMAGE(file)

; Extract the channels (as images) from the RGB image.
redChannel = REFORM(image[0, *, *])
greenChannel = REFORM(image[1, *, *])
blueChannel = REFORM(image[2, *, *])

; Horizontally display the channels.

; Initialize the display objects.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize*[3, 1], $
   TITLE = 'The Channels of an RGB Image')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., imageSize]*[0, 0, 3, 1])
oModel = OBJ_NEW('IDLgrModel')

; Initialize the image objects.
oRedChannel = OBJ_NEW('IDLgrImage', redChannel)
oGreenChannel = OBJ_NEW('IDLgrImage', greenChannel, $
   LOCATION = [imageSize[0], 0])
oBlueChannel = OBJ_NEW('IDLgrImage', blueChannel, $
   LOCATION = [2*imageSize[0], 0])

; Add the image objects to the model, which is added to
; the view, then display the view in the window.
oModel -> Add, oRedChannel
oModel -> Add, oGreenChannel
oModel -> Add, oBlueChannel
oView -> Add, oModel
oWindow -> Draw, oView

; Vertically display the channels.

; Initialize another window object.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize*[1, 3], $
   TITLE = 'The Channels of an RGB Image')

; Change the view from horizontal to vertical.
oView -> SetProperty, $
   VIEWPLANE_RECT = [0., 0., imageSize]*[0, 0, 1, 3]

; Change the locations of the channels.
oGreenChannel -> SetProperty, $
   LOCATION = [0, imageSize[1]]
oBlueChannel -> SetProperty, $
   LOCATION = [0, 2*imageSize[1]]

; Display the updated view in the new window.
oWindow -> Draw, oView

; Diagonally display the channels.

; Initialize another window object.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize*[2, 2], $
   TITLE = 'The Channels of an RGB Image')

; Change the view from vertical to diagonal.
oView -> SetProperty, $
   VIEWPLANE_RECT = [0., 0., imageSize]*[0, 0, 2, 2]

; Change the locations of the channels.
oGreenChannel -> SetProperty, $
   LOCATION = [imageSize[0]/2, imageSize[1]/2]
oBlueChannel -> SetProperty, $
   LOCATION = [imageSize[0], imageSize[1]]

; Display the updated view in the new window.
oWindow -> Draw, oView

; Clean up object references.
OBJ_DESTROY, oView

END