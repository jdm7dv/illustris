;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displayxvolume.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayXVOLUME

; Select the file and read in the data using known dimensions.
file = FILEPATH('head.dat', SUBDIRECTORY = ['examples', 'data'])
volume = READ_BINARY(file, DATA_DIMS = [80, 100, 57])

; Decrease the size of the array to speed up processing.
smallVol = CONGRID(volume, 40, 50, 27)

; Display the data using XVOLUME.
XVOLUME, smallVol, /INTERPOLATE

END