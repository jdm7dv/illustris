;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/projecthoughandradon.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ProjectHoughAndRadon

; Import the image from the file.
imageSize = [64, 64]
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Define the display size and offset parameters to
; resize and position the images when displaying them.
displaySize = 4*imageSize
offset = displaySize/3

; Initialize the displays.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], TITLE = 'Original Image'
TVSCL, CONGRID(image, displaySize[0], $
   displaySize[1])

; With the HOUGH function, transform the image into the
; Hough domain.
houghTransform = HOUGH(image, RHO = houghRadii, $
   THETA = houghAngles, /GRAY)

; Create another window and display the Hough transform
; with axes.
WINDOW, 1, XSIZE = displaySize[0] + 1.5*offset[0], $
   YSIZE = displaySize[1] + 1.5*offset[1], $
   TITLE = 'Hough Transform'
TVSCL, CONGRID(houghTransform, displaySize[0], $
   displaySize[1]), offset[0], offset[1]
PLOT, houghAngles, houghRadii, /XSTYLE, /YSTYLE, $
   TITLE = 'Hough Transform', XTITLE = 'Theta', $
   YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
   POSITION = [offset[0], offset[1], $
   displaySize[0] + offset[0], $
   displaySize[1] + offset[1]], CHARSIZE = 1.5

; With the RADON function, transform the image into the
; Radon domain.
radonTransform = RADON(image, RHO = radonRadii, $
   THETA = radonAngles, /GRAY)

; Create another window and display the Radon transform
; with axes.
WINDOW, 2, XSIZE = displaySize[0] + 1.5*offset[0], $
   YSIZE = displaySize[1] + 1.5*offset[1], $
   TITLE = 'Radon Transform'
TVSCL, CONGRID(radonTransform, displaySize[0], $
   displaySize[1]), offset[0], offset[1]
PLOT, radonAngles, radonRadii, /XSTYLE, /YSTYLE, $
   TITLE = 'Radon Transform', XTITLE = 'Theta', $
   YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
   POSITION = [offset[0], offset[1], $
   displaySize[0] + offset[0], $
   displaySize[1] + offset[1]], CHARSIZE = 1.5

END