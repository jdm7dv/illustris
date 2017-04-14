;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/sortingvalues.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO SortingValues

; Determine the path to the file.
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize the image size parameter.
imageSize = [64, 64]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Gated Blood Pool'
TV, image

; Sort the image values and output the number of
; these values.
sortedValues = SORT(image)
HELP, sortedValues

; Create another window (allowing for a multiple plot
; display) and display the indices of the sorted values.
WINDOW, 1, TITLE = 'Sorted Images Values'
!P.MULTI = [0, 1, 2, 0, 0]
PLOT, sortedValues, /XSTYLE, PSYM = 3, $
   TITLE = 'Indices of Sorted Values'

; Determine the actual sorted values of the image.
sortedImage = image[sortedValues]

; Display the sorted values of the image.
PLOT, sortedImage, /XSTYLE, PSYM = 3, $
   TITLE = 'Sorted Values of the Image'

; Reset multiple displays system variable back to its
; default.
!P.MULTI = 0

; Sort only the unique image values and output the
; number of these values.
uniqueValues = UNIQ(image, SORT(image))
HELP, uniqueValues

; Create another window (allowing for a multiple plot
; display) and display the indices of the sorted
; unique values.
WINDOW, 2, TITLE = 'Sorted Unique Images Values'
!P.MULTI = [0, 1, 2, 0, 0]
PLOT, uniqueValues, /XSTYLE, PSYM = 3, $
   TITLE = 'Indices of Sorted Unique Values'

; Determine the actual sorted unique values of the image.
uniqueImage = image[uniqueValues]

; Display the sorted unique values of the image.
PLOT, uniqueImage, /XSTYLE, PSYM = 3, $
   TITLE = 'Sorted Unique Values of the Image'

; Reset multiple displays system variable back to its
; default.
!P.MULTI = 0

END