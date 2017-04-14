;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphopenexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MorphOpenExample

; Prepare the display device and load grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open the image file.
file = FILEPATH('r_seeberi.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, image, /GRAYSCALE

; Get the image dimensions, prepare a window and
; display the image.
dims = SIZE(image, /DIMENSIONS)
WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
   TITLE='Defining Shapes with the Opening Operator'
TVSCL, image, 0

; Define the radius of the structuring element and
; create the disk.
radius = 7
strucElem = SHIFT(DIST(2*radius+1), $
   radius, radius) LE radius

; Apply the opening operator to the image.
morphImg = MORPH_OPEN(image, strucElem, /GRAY)
TVSCL, morphImg, 1

; Create a window and display an intensity histogram
; to help determine the threshold intensity value.
WINDOW, 1, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(image)

; Threshold the image to prepare to remove background
; noise.
threshImg = image GE 160

; Display the thresholded image.
WSET, 0
TVSCL, threshImg, 2

; Apply the opening operator to the thresholded image.
morphThresh = MORPH_OPEN(threshImg, strucElem)

; Display the image.
TVSCL, morphThresh, 3

END