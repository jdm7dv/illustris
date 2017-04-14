;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/adaptiveequalizing.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO AdaptiveEqualizing

; Import the image from the file.
file = FILEPATH('mineral.png', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_PNG(file, red, green, blue)
imageSize = SIZE(image, /DIMENSIONS)

; Initialize the display.
DEVICE, DECOMPOSED = 0
TVLCT, red, green, blue

; Create a window and display the original image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Original Image'
TV, image

; Create another window and display the histogram of the
; the original image.
WINDOW, 1, TITLE = 'Histogram of Image'
PLOT, HISTOGRAM(image), /XSTYLE, /YSTYLE, $
   TITLE = 'Mineral Image Histogram', $
   XTITLE = 'Intensity Value', $
   YTITLE = 'Number of Pixels of That Value'

; Histogram-equalize the image.
equalizedImage = ADAPT_HIST_EQUAL(image)

; Create another window and display the equalized image.
WINDOW, 2, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Adaptive Equalized Image'
TV, equalizedImage

; Create another window and display the histogram of the
; equalizied image.
WINDOW, 3, TITLE = 'Histogram of Adaptive Equalized Image'
PLOT, HISTOGRAM(equalizedImage), /XSTYLE, /YSTYLE, $
   TITLE = 'Adaptive Equalized Image Histogram', $
   XTITLE = 'Intensity Value', $
   YTITLE = 'Number of Pixels of That Value'

END