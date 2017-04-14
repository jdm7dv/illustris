;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displaymultiples_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayMultiples_Direct

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

; Initialize displays.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and horizontally display the channels.
WINDOW, 0, XSIZE = 3*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'The Channels of an RGB Image'
TV, redChannel, 0
TV, greenChannel, 1
TV, blueChannel, 2

; Create another window and vertically display the
; channels.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = 3*imageSize[1], $
   TITLE = 'The Channels of an RGB Image'
TV, redChannel, 0, 0
TV, greenChannel, 0, imageSize[1]
TV, blueChannel, 0, 2*imageSize[1]

; Create another window.
WINDOW, 2, XSIZE = 2*imageSize[0], YSIZE = 2*imageSize[1], $
   TITLE = 'The Channels of an RGB Image'

; Make a white background.
ERASE, !P.COLOR

; Diagonally display the channels.
TV, redChannel, 0, 0
TV, greenChannel, imageSize[0]/2, imageSize[1]/2
TV, blueChannel, imageSize[0], imageSize[1]

END