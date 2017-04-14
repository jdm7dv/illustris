;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphtophatexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MorphTophatExample

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT,0

; Select and open the image file.
file = FILEPATH('r_seeberi_spore.jpg',$
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, img, /GRAYSCALE

; Get the image dimensions, create a window and
; display image.
dims = SIZE(img, /DIMENSIONS)

; Pad the image.
padImg = REPLICATE(0B, dims[0]+10, dims[1]+10)
padImg [5,5] = img

; Get the new dimensions, create a window and display
; the image.
dims = SIZE(padImg, /DIMENSIONS)
WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
   TITLE='Detecting Small Features with MORPH_TOPHAT'
TVSCL, padImg, 0

; Define and create the structuring element.
radius = 3
strucElem = SHIFT(DIST(2*radius+1), $
   radius, radius) LE radius

; Apply the top-hat operator to the image and display
; it.
tophatImg = MORPH_TOPHAT(padImg, strucElem)
TVSCL, tophatImg , 1

; Create a window and display an intensity histogram
; to help determine the threshold intensity value.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(padImg)

; Stretch and redisplay the image.
WSET, 0
stretchImg = tophatImg < 70
TVSCL, stretchImg, 2

; Threshold and display the binary image.
threshImg = tophatImg GE 60
TVSCL, threshImg, 3

END