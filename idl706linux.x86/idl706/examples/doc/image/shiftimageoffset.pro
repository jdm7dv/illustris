;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/shiftimageoffset.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ShiftImageOffset

; Select and read in the image file.
file = FILEPATH('shifted_endocell.png', $
   SUBDIRECTORY = ['examples','data'])
image = READ_PNG(file, R, G, B)

; Prepare the display device and load the
; color translation tables.
DEVICE, DECOMPOSED = 0, RETAIN = 2
TVLCT, R, G, B
HELP, image

; Get the image size.
imageSize = SIZE(image, /DIMENSIONS)

; Prepare the display window.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Original Image'

; Display the original image.
TV, image

; Shift the original image to correct for the misalignment.
image = SHIFT(image, -imageSize[0]/4, -imageSize[1]/3)

; Display the shifted image.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Shifted Image'
TV, image

END