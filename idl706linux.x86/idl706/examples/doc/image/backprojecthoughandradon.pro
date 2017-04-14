;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/backprojecthoughandradon.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO BackprojectHoughAndRadon

; Import the image from the file.
imageSize = [64, 64]
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Define the display size and offset parameters to
; resize and position the images when displaying them.
displaySize = 4*imageSize
offset = displaySize/3

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; With the HOUGH function, transform the image into the
; Hough domain.
houghTransform = HOUGH(image, RHO = houghRadii, $
   THETA = houghAngles, /GRAY)

; Create another window and display the Hough transform
; with axes.
WINDOW, 0, XSIZE = displaySize[0] + 1.5*offset[0], $
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
WINDOW, 1, XSIZE = displaySize[0] + 1.5*offset[0], $
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

; Backproject the Hough and Radon transforms.
backprojectHough = HOUGH(houghTransform, /BACKPROJECT, $
   RHO = houghRadii, THETA = houghAngles, $
   NX = imageSize[0], NY = imageSize[1])
backprojectRadon = RADON(radonTransform, /BACKPROJECT, $
   RHO = radonRadii, THETA = radonAngles, $
   NX = imageSize[0], NY = imageSize[1])

; Create another window and display the original image
; with the Hough and Radon backjections.
WINDOW, 2, XSIZE = (3*displaySize[0]), $
   YSIZE = displaySize[1], $
   TITLE = 'Hough and Radon Backprojections'
TVSCL, CONGRID(image, displaySize[0], $
   displaySize[1]), 0
TVSCL, CONGRID(backprojectHough, displaySize[0], $
   displaySize[1]), 1
TVSCL, CONGRID(backprojectRadon, displaySize[0], $
   displaySize[1]), 2

END