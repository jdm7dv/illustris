;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/multiplyingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MultiplyingImages

; Determine the path to the file.
file = FILEPATH('worldelv.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameters.
imageSize = [360, 360]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 38

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'World Elevation'
TV, image

; Make a mask of the oceans.
oceanMask = image LT 125

; Multiply the ocean mask by the original image.
maskedImage = image*oceanMask

; Create another window and display the mask and the
; results of the multiplication.
WINDOW, 1, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Oceans Mask (left) and Resulting Image (right)'
TVSCL, oceanMask, 0
TV, maskedImage, 1

; Make a mask of the land.
landMask = image GE 125

; Multiply the land mask by the original image.
maskedImage = image*landMask

; Create another window and display the mask and the
; results of the multiplication.
WINDOW, 2, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Land Mask (left) and Resulting Image (right)'
TVSCL, landMask, 0
TV, maskedImage, 1

END