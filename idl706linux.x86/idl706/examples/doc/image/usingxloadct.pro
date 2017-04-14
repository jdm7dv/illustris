;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/usingxloadct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO UsingXLOADCT

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

; Select and display the "Rainbow + white" color
; table
XLOADCT, /BLOCK
TV, ctscanImage

; Increase "Stretch Bottom" by 20%.
XLOADCT, /BLOCK
TV, ctscanImage

; Increase "Stretch Bottom" by 20% and decrease
; "Stretch Top" by 20% (to 80%).
XLOADCT, /BLOCK
TV, ctscanImage

; Increase "Stretch Bottom" by 20%, decrease "Stretch
; Top" by 20% (to 80%), and decrease "Gamma Correction"
; to 0.631.
XLOADCT, /BLOCK
TV, ctscanImage

; Switch to "Function" section, select "Add Control
; Point" and drag this center control point one quarter
; of the way up and one quarter of the way left.
XLOADCT, /BLOCK
TV, ctscanImage

END