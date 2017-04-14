;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/slice_head.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO slice_head

; Select the file, create an array and read in the data.
file = FILEPATH('head.dat', SUBDIRECTORY=['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = [80, 100, 57])
;OPENR, unit, file , /GET_LUN
;READU, unit, head
;CLOSE, unit

; Load a color table and prepare the display window.
LOADCT,5
DEVICE, DECOMPOSED = 0, RETAIN = 2
WINDOW, 0, XSIZE =800, YSIZE = 600

; Initialize the FOR statement. Use i as the loop element
; for the slice and the position. Use "255b -" to display
; the images with the inverse of the selected color table.
FOR i = 0, 56,1 DO TVSCL, 255b - image [*,*,i], /ORDER, i

; Now extract a single perpendicular slice of data.
sliceImg = REFORM(image[40,*,*])

; Compensate for the flattened array and display the image.
sliceImg = CONGRID(sliceImg, 100, 100)
TV, 255b - sliceImg, 47

END