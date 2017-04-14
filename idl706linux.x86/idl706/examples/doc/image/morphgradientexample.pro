;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphgradientexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO morphGradientExample

; Prepare the display device
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and read in the file.
file = FILEPATH('nuclear_plant.jpg', $
	SUBDIRECTORY=['examples', 'data'])
READ_JPEG, file, image, /GRAYSCALE

; Get the image size, create a window and dipslay the image.
sz = SIZE(image, /DIMENSIONS)
WINDOW, 0, XSIZE =2*sz[0], YSIZE = 1*sz[1], $
	TITLE = 'Original and MORPH_GRADIENT Images'
TVSCL, image, 0

; Define the structuring element, apply the morphological
; operator and display the image.
radius = 1
strucEl = SHIFT(DIST(2*radius+1), radius, radius) LE radius
morphImg = MORPH_GRADIENT(image, strucEl)
TVSCL, morphImg, 1

END