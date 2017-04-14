;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/houghandradonprojections.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO HoughAndRadonProjections

; Import in the image from the file.
imageSize = [64, 64]
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize a display size parameter to resize the
; image when displaying it.
displaySize = 2*imageSize

; Initialize the displays.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], TITLE = 'Original Image'
TVSCL, CONGRID(image, displaySize[0], $
   displaySize[1])

; With the HOUGH function, transform the image into the
; Hough domain.
houghTransform = HOUGH(image, RHO = houghRadii, $
   THETA = houghAngles, /GRAY)

; Create another window and display the Hough transform.
WINDOW, 1, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], TITLE = 'Hough Transform'
TVSCL, CONGRID(houghTransform, displaySize[0], $
   displaySize[1])

; With the RADON function, transform the image into the
; Radon domain.
radonTransform = RADON(image, RHO = radonRadii, $
   THETA = radonAngles, /GRAY)

; Create another window and display the Radon transform.
WINDOW, 2, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], TITLE = 'Radon Transform'
TVSCL, CONGRID(radonTransform, displaySize[0], $
   displaySize[1])

END