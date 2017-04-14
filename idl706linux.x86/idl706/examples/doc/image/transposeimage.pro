;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/transposeimage.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO TransposeImage

; Open the file and prepare to display it with a color table.
READ_JPEG, FILEPATH('muscle.jpg', $
   SUBDIRECTORY=['examples', 'data']), image
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Display the original image.
WINDOW, 0, XSIZE = 652, YSIZE = 444, TITLE = 'Original Image'
TV, image

; Reduce the image size for display purposes.
smallImg = CONGRID(image, 183, 111)

; Flip the image across its main diagonal axis,
; placing the upper left corner in the lower right corner.
transposeImg1 = TRANSPOSE(smallImg)

; Specifying the reversal of array dimensions leads
; to the same result.
transposeImg2 = TRANSPOSE(smallImg, [1,0])

; Specifying the original array arrangement results in
; no transposition.
transposeImg3 = TRANSPOSE(smallImg, [0,1])

; Display the transposed images.
WINDOW, 1, XSIZE= 600, YSIZE=183, TITLE='Transposed Images'
TV, transposeImg1, 0
TV, transposeImg2, 2
TV, transposeImg3, 2

END