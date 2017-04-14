;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/thresholdingimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ThresholdingImages

; Determine the path to the file.
file = FILEPATH('hurric.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Define the image size parameter.
imageSize = [440, 340]

; Import image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Hurricane Gilbert'
TV, image

; Threshold the image by determining which pixel values
; are greater than 125.
topThreshold = image > 125

; Create another window and display the threshold image
; with the TV (left) and the TVSCL (right) procedures.
WINDOW, 1, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Image Greater Than 125, TV (left) ' + $
   'and TVSCL (right)'
TV, topThreshold, 0
TVSCL, topThreshold, 1

; Threshold the image by determining which pixel values
; are less than 125.
bottomThreshold = image < 125

; Create another window and display the threshold image
; with the TV (left) and the TVSCL (right) procedures.
WINDOW, 2, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Image Less Than 125, TV (left) ' + $
   'and TVSCL (right)'
TV, bottomThreshold, 0
TVSCL, bottomThreshold, 1

END