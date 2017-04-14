;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/removingnoisewithleefilt.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RemovingNoiseWithLEEFILT

; Import the image from the file.
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])
imageSize = [64, 64]
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize a display size parameter to resize the
; image when displaying it.
displaySize = 2*imageSize

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the original image.
WINDOW, 0, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], $
   TITLE = 'Original Image'
TVSCL, CONGRID(image, displaySize[0], displaySize[1])

; Apply the Lee filter to the image.
filteredImage = LEEFILT(image, 1)

; Create another window and display the Lee filtered
; image
WINDOW, 1, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], $
   TITLE = 'Lee Filtered Image'
TVSCL, CONGRID(filteredImage, displaySize[0], $
   displaySize[1])

END