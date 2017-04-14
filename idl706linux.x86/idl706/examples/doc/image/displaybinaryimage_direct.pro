;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displaybinaryimage_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayBinaryImage_Direct

; Determine the path to the file:
file = FILEPATH('continent_mask.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [360, 360]

; Import in the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display,
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the original image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'A Binary Image, Not Scaled'
TV, image

; Create another window and display the image scaled
; to range from 0 up to 255.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'A Binary Image, Scaled'
TVSCL, image

END