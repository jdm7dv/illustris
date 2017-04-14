;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/extractslice.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ExtractSlice

; Select the file and define the image array.
file = FILEPATH('head.dat', SUBDIRECTORY = ['examples', 'data'])
volume = READ_BINARY(file, DATA_DIMS =[80, 100, 57])

; Prepare the display device and load a color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Extract a slice from the volume.
sliceImg = EXTRACT_SLICE(volume, 110, 110, 40, 50, 28, $
    90.0, 90.0, 0.0, OUT_VAL = 0)

; Enlarge the array.
bigImg = CONGRID(sliceImg, 400, 650, /INTERP)

; Display the image.
WINDOW, 0, XSIZE = 400, YSIZE = 650
TVSCL, bigImg

END