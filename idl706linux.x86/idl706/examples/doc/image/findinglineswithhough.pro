;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/findinglineswithhough.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO FindingLinesWithHough

; Import the image from file.
file = FILEPATH('rockland.png', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_PNG(file)

; Determine size of image.
imageSize = SIZE(image, /DIMENSIONS)

; Initialize the TrueColor display.
DEVICE, DECOMPOSED = 1

; Create a window and display the original image.
WINDOW, 0, XSIZE = imageSize[1], YSIZE = imageSize[2], $
   TITLE = 'Rockland, Maine'
TV, image, TRUE = 1

; Use the image from green channel to provide outlines
; of shapes.
intensity = REFORM(image[1, *, *])

; Determine size of intensity image.
intensitySize = SIZE(intensity, /DIMENSIONS)

; Mask intensity image to highlight power lines.
mask = intensity GT 240

; Initialize the remaining displays.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create another window and display the masked image.
WINDOW, 1, XSIZE = intensitySize[0], $
   YSIZE = intensitySize[1], $
   TITLE = 'Mask to Locate Power Lines'
TVSCL, mask

; Transform mask.
transform = HOUGH(mask, RHO = rho, THETA = theta)

; Define the size and offset parameters for the
; transform displays.
displaySize = [256, 256]
offset = displaySize/3

; Reverse color table to clarify lines.
TVLCT, red, green, blue, /GET
TVLCT, 255 - red, 255 - green, 255 - blue

; Create another window and display the Hough transform
; with axes.
WINDOW, 2, XSIZE = displaySize[0] + 1.5*offset[0], $
   YSIZE = displaySize[1] + 1.5*offset[1], $
   TITLE = 'Hough Transform'
TVSCL, CONGRID(transform, displaySize[0], $
   displaySize[1]), offset[0], offset[1]
PLOT, theta, rho, /XSTYLE, /YSTYLE, $
   TITLE = 'Hough Transform', XTITLE = 'Theta', $
   YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
   POSITION = [offset[0], offset[1], $
   displaySize[0] + offset[0], $
   displaySize[1] + offset[1]], CHARSIZE = 1.5, $
   COLOR = !P.BACKGROUND

; Scale transform to obtain just the power lines.
transform = (TEMPORARY(transform) - 85) > 0

; Create another window and display the scaled transform.
WINDOW, 3, XSIZE = displaySize[0] + 1.5*offset[0], $
   YSIZE = displaySize[1] + 1.5*offset[1], $
   TITLE = 'Scaled Hough Transform'
TVSCL, CONGRID(transform, displaySize[0], $
   displaySize[1]), offset[0], offset[1]
PLOT, theta, rho, /XSTYLE, /YSTYLE, $
   TITLE = 'Scaled Hough Transform', XTITLE = 'Theta', $
   YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
   POSITION = [offset[0], offset[1], $
   displaySize[0] + offset[0], $
   displaySize[1] + offset[1]], CHARSIZE = 1.5, $
   COLOR = !P.BACKGROUND

; Backproject to compare with original image.
backprojection = HOUGH(transform, /BACKPROJECT, $
   RHO = rho, THETA = theta, $
   NX = intensitySize[0], NY = intensitySize[1])

; Create another window and display the results.
WINDOW, 4, XSIZE = intensitySize[0], $
   YSIZE = intensitySize[1], $
   TITLE = 'Resulting Power Lines'
TVSCL, backprojection

END