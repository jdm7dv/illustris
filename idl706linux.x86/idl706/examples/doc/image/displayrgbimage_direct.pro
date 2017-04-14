;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displayrgbimage_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayRGBImage_Direct

; Determine the path to the file.
file = FILEPATH('rose.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Query the file to determine image parameters.
queryStatus = QUERY_IMAGE(file, imageInfo)

; Output the results of the file query.
PRINT, 'Query Status = ', queryStatus
HELP, imageInfo, /STRUCTURE

; Set the image size parameter from the query
; information.
imageSize = imageInfo.dimensions

; Import the image.
image = READ_IMAGE(file)

; Determine the size of each dimension within the image.
imageDims = SIZE(image, /DIMENSIONS)

; Determine the type of interleaving by comparing the
; dimension sizes with the image size parameter from the
; file query.
interleaving = WHERE((imageDims NE imageSize[0]) AND $
   (imageDims NE imageSize[1])) + 1

; Output the results of the interleaving computation.
PRINT, 'Type of Interleaving = ', interleaving

; Initialize display.
DEVICE, DECOMPOSED = 1

; Create a window and display the image with the TV
; procedure and its TRUE keyword.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'An RGB Image'
TV, image, TRUE = interleaving[0]

END