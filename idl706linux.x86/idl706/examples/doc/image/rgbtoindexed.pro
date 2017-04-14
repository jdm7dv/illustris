;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/rgbtoindexed.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RGBToIndexed

; Determine path to the "elev_t.jpg" file.
elev_tFile = FILEPATH('elev_t.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Import image from file into IDL.
READ_JPEG, elev_tFile, elev_tImage

; Determine the size of the imported image.
elev_tSize = SIZE(elev_tImage, /DIMENSIONS)

; Initialize display.
DEVICE, DECOMPOSED = 1
WINDOW, 0, TITLE = 'elev_t.jpg', $
   XSIZE = elev_tSize[1], YSIZE = elev_tSize[2]

; Display image.
TV, elev_tImage, TRUE = 1

; Convert RGB image to indexed image with associated
; color table.
DEVICE, DECOMPOSED = 0
imageIndexed = COLOR_QUAN(elev_tImage, 1, red, green, $
   blue)

; Write resulting image and its color table to a PNG
; file.
WRITE_PNG, 'elev_t.png', imageIndexed, red, green, blue

END