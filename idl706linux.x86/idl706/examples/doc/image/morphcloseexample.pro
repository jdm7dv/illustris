;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphcloseexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MorphCloseExample

; Prepare the display device and load grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open the image file.
file = FILEPATH('mineral.png', $
   SUBDIRECTORY=['examples', 'data'])
img = READ_PNG(file)

; Get the image dimensions, prepare a window and
; display the image.
dims = SIZE(img, /DIMENSIONS)

; Pad the image and get the new dimensions.
padImg = REPLICATE(0B, dims[0]+10, dims[1]+10)
padImg [5, 5] = img
dims = SIZE(padImg, /DIMENSIONS)

; Display the padded image.
WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
   TITLE = 'Extracting Shapes with the Closing Operator'
TVSCL, padImg, 0

; Define the size of the structuring element
;  and create the square.
side = 3
strucElem = DIST(side) LE side
PRINT, strucElem

; Apply the closing operator to the image and display
; it.
closeImg = MORPH_CLOSE(padImg, strucElem, /GRAY)
TVSCL, closeImg, 1

; Create a window and display an intensity histogram
; to help determine the threshold intensity value.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(closeImg)

; Display a binary version of the original image.
binaryImg = padImg LE 160
WSET, 0
TVSCL, binaryImg, 2

; Display a binary version of the closed image for
; for comparison with the original.
binaryClose = closeImg LE 160
TVSCL, binaryClose, 3

END