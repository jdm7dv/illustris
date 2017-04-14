;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morpherodedilate.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MorphErodeDilate

DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Load an image.
file = FILEPATH('pollens.jpg', $
   SUBDIRECTORY = ['examples', 'demo', 'demodata'])
READ_JPEG, file, img, /GRAYSCALE

; Get the image size.
dims = SIZE(img, /DIMENSIONS)

; Create the structuring element, a disk with a radius
; of 2.
radius = 2
strucElem = SHIFT(DIST(2*radius+1), $
   radius, radius) LE radius

; Print the structuring element in order to visualize
; the previous statement.
PRINT, strucElem

; To avoid indeterminate edge values, add padding equal
; to one half the size of the structuring element
; (equal to the radius). Pad image to be eroded with
; maximum array value, and image to be dilated with
; minimum array value.
erodeImg = REPLICATE(MAX(img), dims[0]+2, dims[1]+2)
erodeImg [1,1] = img
dilateImg = REPLICATE(MIN(img), dims[0]+2, dims[1]+2)
dilateImg [1,1] = img

; Get the size of either of the padded images,
;  create a window and display the original image.
padDims = SIZE(erodeImg, /DIMENSIONS)
WINDOW, 0, XSIZE = 3*padDims[0], YSIZE = padDims[1], $
   TITLE = "Original, Eroded and Dilated Grayscale Images"
TVSCL, img, 0

; Use the erosion operator on the image, applying the
; structuring element. Display the image.
erodeImg = ERODE(erodeImg, strucElem, /GRAY)
TVSCL, erodeImg, 1

; Apply the dilation operator to the image, and display
; it.
dilateImg = DILATE(dilateImg, strucElem, /GRAY)
TVSCL, dilateImg, 2

; Create a window and display a histogram to help
; determine the threshold intensity value.
WINDOW, 1, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(img)

; Create a binary image of the grayscale image.
img = img GE 120

; Create padded binary images for the erode
; and dilate operations.
erodeImg = REPLICATE(1B, dims[0]+2, dims[1]+2)
erodeImg [1,1] = img
dilateImg = REPLICATE(0B, dims[0]+2, dims[1]+2)
dilateImg [1,1] = img

; Get the dimensions, create a second window
; and display the binary image.
dims = SIZE(erodeImg, /DIMENSIONS)
WINDOW, 2, XSIZE = 3*dims[0], YSIZE = dims[1], $
   TITLE = "Original, Eroded and Dilated Binary Images"
TVSCL, img, 0

; Apply the erosion and dilation operators to the
; binary images and display the results.
erodeImg = ERODE(erodeImg, strucElem)
TVSCL, erodeImg, 1
dilateImg = DILATE(dilateImg, strucElem)
TVSCL, dilateImg, 2

END