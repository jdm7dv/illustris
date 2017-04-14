;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/addingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO AddingImages

; Determine the path to the file.
file = FILEPATH('glowing_gas.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Query the file to determine image parameters.
queryStatus = QUERY_JPEG(file, imageInfo)

; Set the image size parameter from the query
; information.
imageSize = imageInfo.dimensions

; Import the image from the file.
READ_JPEG, file, image

; Initialize the RGB display.
DEVICE, DECOMPOSED = 1

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Glowing Gas RGB Image'
TV, image, TRUE = 1

; Extract the channels (as images) from the RGB image.
redChannel = REFORM(image[0, *, *])
greenChannel = REFORM(image[1, *, *])
blueChannel = REFORM(image[2, *, *])

; Initialize the grayscale displays.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create another window and display each channel of the
; RGB image.
WINDOW, 1, XSIZE = 3*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Red (left), Green (middle), ' + $
   'and Blue (right) Channels of the RGB Image'
TV, redChannel, 0
TV, greenChannel, 1
TV, blueChannel, 2

; Create another window and display the addition of the
; channels, as byte data and as converted data.
WINDOW, 2, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'The Addition of Channels, Byte (left) ' + $
   'and Converted (right)'
TVSCL, redChannel + greenChannel + blueChannel, 0
TVSCL, FLOAT(redChannel) + FLOAT(greenChannel) + $
   FLOAT(blueChannel), 1

END