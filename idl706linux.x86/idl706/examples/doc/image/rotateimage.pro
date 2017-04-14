;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/rotateimage.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RotateImage

; Select the file and read in the data using known dimensions.
file = FILEPATH('galaxy.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = [256, 256])

; Prepare the display device and load a color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 4

; Create a window and display the original image.
WINDOW, 0, XSIZE = 256, YSIZE = 256
TVSCL, image

; Rotate the galaxy 270 degrees counterclockwise.
rotateImg = ROTATE(image, 3)

; Display the rotated image in a new window.
WINDOW, 1, XSIZE = 256, YSIZE = 256
TVSCL, rotateImg

END