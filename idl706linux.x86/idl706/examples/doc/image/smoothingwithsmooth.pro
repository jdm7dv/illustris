;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/smoothingwithsmooth.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO SmoothingWithSMOOTH

; Import the image from the file.
file = FILEPATH('rbcells.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, image
imageSize = SIZE(image, /DIMENSIONS)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the original image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Original Image'
TV, image

; Create another window and display the original image
; as a surface.
WINDOW, 1, TITLE = 'Original Image as a Surface'
SHADE_SURF, image, /XSTYLE, /YSTYLE, CHARSIZE = 2., $
   XTITLE = 'Width Pixels', $
   YTITLE = 'Height Pixels', $
   ZTITLE = 'Intensity Values', $
   TITLE = 'Red Blood Cell Image'

; Smooth the image with the SMOOTH function, which uses
; the averages of image values.
smoothedImage = SMOOTH(image, 5, /EDGE_TRUNCATE)

; Create another window and display the smoothed image
; as a surface.
WINDOW, 2, TITLE = 'Smoothed Image as a Surface'
SHADE_SURF, smoothedImage, /XSTYLE, /YSTYLE, CHARSIZE = 2., $
   XTITLE = 'Width Pixels', $
   YTITLE = 'Height Pixels', $
   ZTITLE = 'Intensity Values', $
   TITLE = 'Smoothed Cell Image'

; Create another window and display the smoothed image.
WINDOW, 3, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Smoothed Image'
TV, smoothedImage

END