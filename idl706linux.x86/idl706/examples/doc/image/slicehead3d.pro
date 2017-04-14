;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/slicehead3d.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO slicehead3d

; Select the file and define the array.
file = FILEPATH('head.dat', SUBDIRECTORY=['examples', 'data'])
data = BYTARR(80, 100, 57)

; Open the file, read the data and close the file.
OPENR, unit, file , /GET_LUN
READU, unit, data
CLOSE, unit

; Create a pointer to the data that is passed to SLICER3
hdata = PTR_NEW(data)

; Load the data into the SLICER3 application.
SLICER3, hdata, DATA_NAMES = 'head', /modal

END