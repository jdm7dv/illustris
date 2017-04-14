;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/totalingvalues.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO TotalingValues

; Determine the path to the file.
file = FILEPATH('convec.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [248, 248]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = 3*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Convection Image (left), ' + $
   'Background (middle), Foreground (right)'
TV, image, 0

; Make a mask of the background and display it.
background = image EQ 0.
TVSCL, background, 1

; Make a mask of the foreground and display it.
foreground = image GT 0
TVSCL, foreground, 2

; Determine the number of elements within the image
; array and output the results.
numElements = N_ELEMENTS(image)
PRINT, ' '
PRINT, 'Number of Elements in Image = ', numElements

; Total the number of pixels in the background mask and
; output the results.
numZeros = TOTAL(background)
PRINT, 'Number of Zeros in Image = ', numZeros

; Determine the number of pixels within the foreground
; using the number of elements in the image array and
; the number of pixels in the background mask, and
; output the results.
numValues = numElements - numZeros
PRINT, 'Number of Values in Image = ', numValues

; Total the number of pixels in the foreground mask
; and output the results. This result should be the
; same as the previous calculation of foreground pixels.
numNonZeros = TOTAL(foreground)
PRINT, 'Number of Non-zeros in Image = ', numNonZeros

; Determine the total of all the values within the
; image and output the results.
valueTotal = TOTAL(image)
PRINT, ' '
PRINT, 'Total of the Pixel Values = ', valueTotal

; Determine the average value of all the pixels within
; the image and output the results.
pixelAverage = valueTotal/numElements
PRINT, 'Average of All Pixel Values = ', pixelAverage

; Determine the average value of only the pixels within
; the foreground of the image and output the results.
pixelNonZero = valueTotal/numValues
PRINT, 'Average of Non-zero Pixel Values = ', $
   pixelNonZero

END