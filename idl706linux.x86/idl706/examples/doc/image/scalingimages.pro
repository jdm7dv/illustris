;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/scalingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ScalingImages

; Determine the path to the file.
file = FILEPATH('worldtmp.png', $
   SUBDIRECTORY = ['examples', 'demo', 'demodata'])

; Import image from the file.
image = READ_PNG(file)

; Determine the image size parameter.
imageSize = SIZE(image, /DIMENSIONS)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'World Temperature Data'
TV, image

; Make a mask by determining the values within the image
; that are greater than 156.
scale = image > 156

; Create another window and display the mask,
; plain (left) and scaled (right).
WINDOW, 1, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Image Greater Than 156, Plain (left) and Scaled (right)'
TV, scale, 0
TVSCL, scale, 1

; Make a mask by determining the values within the image
; that are less than 156.
scale = image < 156

; Create another window and display the mask,
; plain (left) and scaled (right).
WINDOW, 2, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Image Less Than 156, Plain (left) and Scaled (right)'
TV, scale, 0
TVSCL, scale, 1

END