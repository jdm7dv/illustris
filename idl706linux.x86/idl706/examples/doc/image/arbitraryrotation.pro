;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/arbitraryrotation.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ArbitraryRotation

; Select the file and read in the data using known
; dimensions.
file = FILEPATH('m51.dat', SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = [340, 440])

; Prepare the display device and load a black and white
; color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

;Create a window and display the original image.
WINDOW, 0, XSIZE = 340, YSIZE = 440
TVSCL, image

; Rotate the new image 33 degrees clockwise and shrink
; it by 50 % and keep the interpolation from extending
; beyond the array boundaries.
arbitraryImg = ROT(image, 33, .5, /INTERP, MISSING = 127)

; Display the rotated image.
WINDOW, 1, XSIZE = 340, YSIZE = 440
TVSCL, arbitraryImg

END