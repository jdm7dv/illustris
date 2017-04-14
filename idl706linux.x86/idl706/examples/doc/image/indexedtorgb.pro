;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/indexedtorgb.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO IndexedToRGB

; Determine the path to the file.
convecFile = FILEPATH('convec.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
convecSize = [248, 248]

; Import the image from the file.
convecImage = READ_BINARY(convecFile, $
   DATA_DIMS = convecSize)

; Initialize display.
DEVICE, DECOMPOSED = 0
LOADCT, 27
WINDOW, 0, TITLE = 'convec.dat', $
   XSIZE = convecSize[0], YSIZE = convecSize[1]

; Display image.
TV, convecImage

; Obtain the red, green, and blue vectors that form the
; current color table.
TVLCT, red, green, blue, /GET

; Initialize the resulting RGB image.
imageRGB = BYTARR(3, convecSize[0], convecSize[1])

; Derive each color image from the vectors of the
; current color table.
imageRGB[0, *, *] = red[convecImage]
imageRGB[1, *, *] = green[convecImage]
imageRGB[2, *, *] = blue[convecImage]

; Write the resulting RGB image out to a JPEG file.
WRITE_JPEG, 'convec.jpg', imageRGB, TRUE = 1, $
   QUALITY = 100.

END