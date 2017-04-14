;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/subtractingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO SubtractingImages

; Determine the path to the file.
file = FILEPATH('convec.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [248, 248]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 27

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Earth Mantle Convection'
TV, image

; Make a mask of the core and scale it to range from 0
; to 255.
core = BYTSCL(image EQ 255)

; Create another window and display the scaled mask.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = "The Convection of the Core"
TV, core

; Subtract the scaled mask from the original image.
difference = image - core

; Create another window and display the difference of
; the original image and the scaled mask.
WINDOW, 2, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Difference of Original & Core'
TV, difference

END