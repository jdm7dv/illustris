;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphdistanceexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MorphDistanceExample

; Prepare the display device and load grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and load an image.
file  = FILEPATH('n_vasinfecta.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, img, /GRAYSCALE
dims = SIZE(img, /DIMENSIONS)

; Pad the image for display purposes.
padImg = REPLICATE(0B, dims[0] + 10, dims[1] + 10)
padImg[5, 5] = img

; Get the size of the padded image.
dims = SIZE(padImg, /DIMENSIONS)
WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
   TITLE = 'Distance Map and Overlay of Thresholded Image'
TVSCL, padImg, 0

; Use an intensity histogram to help determine
; threshold intensity value.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(padImg)

; Create a binary image.
binaryImg = padImg LT 120
WSET, 0
TVSCL, binaryImg, 1

; Compute distance map using "chessboard" neighbor
; sampling.
distanceImg = MORPH_DISTANCE(binaryImg, $
   NEIGHBOR_SAMPLING = 1)
TVSCL, distanceImg, 2

; Overlay the distance map onto the binary image. Black
; areas within the binary image are assigned the maximum
; pixel brightness within the distance image.
distanceImg[WHERE(binaryImg EQ 0)] = MAX(distanceImg)
TVSCL, distanceImg, 3

END