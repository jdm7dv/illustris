;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/reverseimage.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ReverseImage

; Select the file and get the image dimensions.
image = READ_DICOM (FILEPATH('mr_knee.dcm', $
   SUBDIRECTORY = ['examples', 'data']))
imgSize = SIZE (image, /DIMENSIONS)

;Prepare the display device and load a color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Reverse dimension 1 to flip the image horizontally.
flipHorzImg = REVERSE(image, 1)

; Reverse dimesion 2 to flip the image vertically.
flipVertImg = REVERSE(image, 2)

; Prepare the window and display the original image.
WINDOW, 0, XSIZE = 2*imgSize[0], YSIZE = 2*imgSize[1], $
    TITLE = 'Original (Top) & Flipped Images (Bottom)'
TV, image, 0

; Display the reversed images.
TV, flipHorzImg, 2
TV, flipVertImg, 3

END