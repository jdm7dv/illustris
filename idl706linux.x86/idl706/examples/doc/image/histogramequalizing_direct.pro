;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/histogramequalizing_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO HistogramEqualizing_Direct

; Determine path to file.
file = FILEPATH('mineral.png', $
   SUBDIRECTORY = ['examples', 'data'])

; Import image from file into IDL.
image = READ_PNG(file)

; Determine size of imported image.
imageSize = SIZE(image, /DIMENSIONS)

;Initialize IDL on a TrueColor display to use
; color-related routines.
DEVICE, DECOMPOSED = 0

; Initialize the image display.
LOADCT, 0
WINDOW, 0, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Histogram/Image'

; Compute and scale histogram of image.
brightnessHistogram = BYTSCL(HISTOGRAM(image))

; Display histogram plot.
PLOT, brightnessHistogram, XSTYLE = 9, YSTYLE = 5, $
   POSITION = [0.05, 0.2, 0.45, 0.9], $
   XTITLE = 'Histogram of Image'

; Display image.
TV, image, 1

; Histogram equalize the color table.
H_EQ_CT, image

; Display image and updated color table in another
; window.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Histogram-Equalized Color Table'
TV, image

; Display the updated color table with the XLOADCT
; utility.
XLOADCT, /BLOCK

; Interactively histogram equalize the color table. The
; H_EQ_INT routine provides an interactive display to
; allow you to select the amount of equalization. Place
; the cursor at about 130 in the x-direction, which is
; about 0.5 equalized. The y-direction is arbitrary.
; Click on the right mouse button.
; NOTE: you do not have to be exact for this example.
H_EQ_INT, image

; Display image and updated color table in another
; window.
WINDOW, 2, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Interactively Equalized Color Table'
TV, image

; Display the updated color table with the XLOADCT
; utility.
XLOADCT, /BLOCK

END