;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/clippingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ClippingImages

; Determine the path to the file.
file = FILEPATH('hurric.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Define the image size parameter.
imageSize = [440, 340]

; Import image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Hurricane Gilbert'
TV, image

; Clip the image to determine which pixel values are
; greater than 125.
topClippedImage = image > 125

; Create another window and display the clipped image
; with the TV (left) and the TVSCL (right) procedures.
WINDOW, 1, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Image Greater Than 125, TV (left) ' + $
   'and TVSCL (right)'
TV, topClippedImage, 0
TVSCL, topClippedImage, 1

; Clip the image to determine which pixel values are
; less than 125.
bottomClippedImage = image < 125

; Create another window and display the clipped image
; with the TV (left) and the TVSCL (right) procedures.
WINDOW, 2, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Image Less Than 125, TV (left) ' + $
   'and TVSCL (right)'
TV, bottomClippedImage, 0
TVSCL, bottomClippedImage, 1

END