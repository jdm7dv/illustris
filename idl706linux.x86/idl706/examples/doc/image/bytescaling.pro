;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/bytescaling.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ByteScaling

; Import the image from the file.
file = FILEPATH('mr_brain.dcm', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_DICOM(file)
imageSize = SIZE(image, /DIMENSIONS)

; Initialize the displays.
DEVICE, DECOMPOSED = 0
LOADCT, 5

; Create a window and display the original image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Original Image'
TV, image

; Byte-scale the image.
scaledImage = BYTSCL(image)

; Create another window and display the byte-scaled
; image.
WINDOW, 1, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Byte-Scaled Image'
TV, scaledImage

END