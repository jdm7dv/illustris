;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/magnifyimage.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MagnifyImage

; Select the file, and read in the data using known dimensions.
file = FILEPATH('convec.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = [248, 248])

; Load a color table and prepare to display the image.
LOADCT, 28
DEVICE, DECOMPOSED = 0, RETAIN = 2
WINDOW, 0, XSIZE = 248, YSIZE = 248

; Display the original image.
TV, image

; Magnify the image and display it in a new window.
magnifiedImg = CONGRID(image, 600, 600, /INTERP)
WINDOW, 1, XSIZE = 600, YSIZE = 600
TV, magnifiedImg

END