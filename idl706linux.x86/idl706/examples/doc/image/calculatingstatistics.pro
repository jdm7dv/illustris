;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/calculatingstatistics.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO CalculatingStatistics

; Determine the path to the file.
file = FILEPATH('convec.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [248, 248]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 27

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Earth Mantle Convection'
TV, image

; Make a mask of the core and scale it to range from 0
; to 255.
core = BYTSCL(image EQ 255)

; Subtract the scaled mask from the original image.
difference = image - core

; Create another window and display the difference of
; the original image and the scaled mask.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Difference of Original & Core'
TV, difference

; Determine the statistics of the image.
IMAGE_STATISTICS, difference, COUNT = pixelNumber, $
   DATA_SUM = pixelTotal, MAXIMUM = pixelMax, $
   MEAN = pixelMean, MINIMUM = pixelMin, $
   STDDEV = pixelDeviation, $
   SUM_OF_SQUARES = pixelSquareSum, $
   VARIANCE = pixelVariance

; Print out the resulting statistics.
PRINT, ''
PRINT, 'IMAGE STATISTICS:'
PRINT, 'Total Number of Pixels = ', pixelNumber
PRINT, 'Total of Pixel Values = ', pixelTotal
PRINT, 'Maximum Pixel Value = ', pixelMax
PRINT, 'Mean of Pixel Values = ', pixelMean
PRINT, 'Minimum Pixel Value = ', pixelMin
PRINT, 'Standard Deviation of Pixel Values = ', $
   pixelDeviation
PRINT, 'Total of Squared Pixel Values = ', $
   pixelSquareSum
PRINT, 'Variance of Pixel Values = ', pixelVariance

; Derive a mask of the non-zero values of the image.
nonzeroMask = difference NE 0

; Determine the statistics of the image with the
; mask applied.
IMAGE_STATISTICS, difference, COUNT = pixelNumber, $
   DATA_SUM = pixelTotal, MASK = nonzeroMask, $
   MAXIMUM = pixelMax, MEAN = pixelMean, $
   MINIMUM = pixelMin, STDDEV = pixelDeviation, $
   SUM_OF_SQUARES = pixelSquareSum, $
   VARIANCE = pixelVariance

; Print out the resulting statistics.
PRINT, ''
PRINT, 'MASKED IMAGE STATISTICS:'
PRINT, 'Total Number of Pixels = ', pixelNumber
PRINT, 'Total of Pixel Values = ', pixelTotal
PRINT, 'Maximum Pixel Value = ', pixelMax
PRINT, 'Mean of Pixel Values = ', pixelMean
PRINT, 'Minimum Pixel Value = ', pixelMin
PRINT, 'Standard Deviation of Pixel Values = ', $
   pixelDeviation
PRINT, 'Total of Squared Pixel Values = ', $
   pixelSquareSum
PRINT, 'Variance of Pixel Values = ', pixelVariance

END