;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displayslicer3.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplaySLICER3

; Select the file and define the array.
file = FILEPATH('head.dat', SUBDIRECTORY=['examples', 'data'])
volume = READ_BINARY(file, DATA_DIMS = [80, 100, 57])

; Create a pointer to the image data passed to SLICER3.
pData = PTR_NEW(volume)

; Load the data into the SLICER3 application.
SLICER3, pData, DATA_NAMES = 'head', /MODAL

; Release memory used by the pointer.
PTR_FREE, pData

END