;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/dividingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DividingImages

; Determine the path to the file.
file = FILEPATH('worldelv.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [360, 360]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 38

; Create a window and display the image (left) and it
; divided by two (right).
WINDOW, 0, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'World Elevation Image (left) and Divided' + $
   ' by Two (right)'
TV, image, 0
TV, image/2, 1

END