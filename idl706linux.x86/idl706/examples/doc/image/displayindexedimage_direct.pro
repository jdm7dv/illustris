;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displayindexedimage_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayIndexedImage_Direct

; Determine the path to the file.
file = FILEPATH('avhrr.png', $
   SUBDIRECTORY = ['examples', 'data'])

; Query the file to determine image parameters.
queryStatus = QUERY_IMAGE(file, imageInfo)

; Output the results of the file query.
PRINT, 'Query Status = ', queryStatus
HELP, imageInfo, /STRUCTURE

; Set image size parameter.
imageSize = imageInfo.dimensions

; Import in the image and its associated color table
; from the file.
image = READ_IMAGE(file, red, green, blue)

; Initialize the display.
DEVICE, DECOMPOSED = 0
TVLCT, red, green, blue

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'An Indexed Image'
TV, image

; Use the XLOADCT utility to display the color table.
XLOADCT, /BLOCK

; Change the color table to the EOS B pre-defined color
; table.
LOADCT, 27

; Redisplay the image with the EOS B color table.
TV, image

; Use the XLOADCT utility to display the current color
; table.
XLOADCT, /BLOCK

END