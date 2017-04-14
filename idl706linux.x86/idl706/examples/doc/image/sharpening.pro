;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/sharpening.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO Sharpening

; Import the image from the file.
file = FILEPATH('mr_knee.dcm', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_DICOM(file)
imageSize = SIZE(image, /DIMENSIONS)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the original image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Original Knee MRI'
TVSCL, image

; Create a sharpening (high pass) filter.
kernelSize = [3, 3]
kernel = REPLICATE(-1./9., kernelSize[0], kernelSize[1])
kernel[1, 1] = 1.

; Apply the filter to the image.
filteredImage = CONVOL(FLOAT(image), kernel, $
   /CENTER, /EDGE_TRUNCATE)

; Create another window and display the resulting
; filtered image.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Sharpen Filtered Knee MRI'
TVSCL, filteredImage

; Create another window and display the combined images.
WINDOW, 2, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Sharpened Knee MRI'
TVSCL, image + filteredImage

END