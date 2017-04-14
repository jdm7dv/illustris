;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/contrastingcellswithradon.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ContrastingCellsWithRadon

; Import the image from the file.
file = FILEPATH('endocell.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, endocellImage

; Determine image's size, but divide it by 4 to reduce
; the image.
imageSize = SIZE(endocellImage, /DIMENSIONS)/4

; Resize image to a quarter its original length and
; width.
endocellImage = CONGRID(endocellImage, $
   imageSize[0], imageSize[1])

; Initialize the displays.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the original image.
WINDOW, 0, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Original (left) and Filtered (right)'
TV, endocellImage, 0

; Filter original image to clarify the edges of the
; cells.
image = ROBERTS(endocellImage)

; Display the filtered image.
TVSCL, image, 1

; Transform the filtered image.
transform = RADON(image, RHO = rho, THETA = theta)

; Define the size and offset parameters for the
; transform displays.
displaySize = [256, 256]
offset = displaySize/3

; Create another window and display the Radon transform
; with axes.
WINDOW, 1, XSIZE = displaySize[0] + 1.5*offset[0], $
   YSIZE = displaySize[1] + 1.5*offset[1], $
   TITLE = 'Radon Transform'
TVSCL, CONGRID(transform, displaySize[0], $
   displaySize[1]), offset[0], offset[1]
PLOT, theta, rho, /XSTYLE, /YSTYLE, $
   TITLE = 'Radon Transform', XTITLE = 'Theta', $
   YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
   POSITION = [offset[0], offset[1], $
   displaySize[0] + offset[0], $
   displaySize[1] + offset[1]], CHARSIZE = 1.5

; Scale the transform to include only the density
; values above the mean of the transform.
scaledTransform = transform > MEAN(transform)

; Create another window and display the scaled Radon
; transform with axes.
WINDOW, 2, XSIZE = displaySize[0] + 1.5*offset[0], $
   YSIZE = displaySize[1] + 1.5*offset[1], $
   TITLE = 'Scaled Radon Transform'
TVSCL, CONGRID(scaledTransform, displaySize[0], $
   displaySize[1]), offset[0], offset[1]
PLOT, theta, rho, /XSTYLE, /YSTYLE, $
   TITLE = 'Scaled Radon Transform', XTITLE = 'Theta', $
   YTITLE = 'Rho', /NODATA, /NOERASE, /DEVICE, $
   POSITION = [offset[0], offset[1], $
   displaySize[0] + offset[0], $
   displaySize[1] + offset[1]], CHARSIZE = 1.5

; Backproject the scaled transform.
backprojection = RADON(scaledTransform, /BACKPROJECT, $
   RHO = rho, THETA=theta, NX = imageSize[0], $
   NY = imageSize[1])

; Create another window and display the backprojection.
WINDOW, 3, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Backproject (left) and Final Result (right)'
TVSCL, backprojection, 0

; Use the backprojection as a mask to provide
; a color density contrast of the original image.
constrastingImage = endocellImage*backprojection

; Display resulting contrast image.
TVSCL, constrastingImage, 1

END