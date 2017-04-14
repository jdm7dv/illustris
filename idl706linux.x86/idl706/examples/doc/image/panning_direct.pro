;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/panning_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO Panning_Direct

; Determine the path to the file.
file = FILEPATH('nyny.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [768, 512]

; Import in the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Display the image with the SLIDE_IMAGE procedure.
SLIDE_IMAGE, image

END