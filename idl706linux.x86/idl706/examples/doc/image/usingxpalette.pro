;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/usingxpalette.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO UsingXPALETTE

; Determine the path to the file.
ctscanFile = FILEPATH('ctscan.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize image size parameter.
ctscanSize = [256, 256]

; Import the image from the file.
ctscanImage = READ_BINARY(ctscanFile, $
   DATA_DIMS = ctscanSize)

; Initialize display.
DEVICE, DECOMPOSED = 0
LOADCT, 0
WINDOW, 0, TITLE = 'ctscan.dat', $
   XSIZE = ctscanSize[0], YSIZE = ctscanSize[1]

; Display image.
TV, ctscanImage

; Click on the "Predefined" button and select the
; "Rainbow + white" color table.
XPALETTE, /BLOCK
TV, ctscanImage

; Click on the 115th index, which is in column 3 and row
; 7, and then change its color to orange with the RGB
; (red, green, and blue) sliders.  Orange is made up of
; 255 red, 128 green, and 0 blue.
XPALETTE, /BLOCK
TV, ctscanImage

; Click on the 115th index, click on the "Set Mark"
; button, click on the 255th index, and click on the
; "Interpolate" button.  The colors within the 115 to
; 255 range are now changed to go between orange and
; white.  To see this change within the XPALETTE
; utility, click on the "Redraw" button.
XPALETTE, /BLOCK
TV, ctscanImage

; Obtain the red, green, and blue vectors of this
; current color table.
TVLCT, red, green, blue, /GET

; Add this modified color table to IDL's list of
; pre-defined color tables and display results.
MODIFYCT, 41, 'Orange to White Bones', $
   red, green, blue
XLOADCT, /BLOCK
TV, ctscanImage

END