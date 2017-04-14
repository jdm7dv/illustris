;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/combiningimages.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO CombiningImages

; Determine the path to the file.
file = FILEPATH('worldelv.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize image size parameter.
imageSize = [360, 360]

; Import the elevation image from the file.
elvImage = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 38

; Create a window and display the elevation image.
WINDOW, 0, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'World Elevation (left) and Temperature (right)'
TV, elvImage, 0

; Determine the path to the other file.
file = FILEPATH('worldtmp.png', $
   SUBDIRECTORY = ['examples', 'demo', 'demodata'])

; Import the temperature image from the other file.
tmpImage = READ_PNG(file)

; Display the temperature image.
TV, tmpImage, 1

; Determine where the oceans are located within the
; elevation image.
ocean = WHERE(elvImage LT 125)

; Set the temperature image as the background.
image = tmpImage

; Replace values from the temperature image with values
; from the elevation image only where the ocean pixels
; are located.
image[ocean] = elvImage[ocean]

; Create another window and display the resulting
; temperature over land image.
WINDOW, 1, XSIZE = 2*imageSize[0], YSIZE = imageSize[1], $
   TITLE = 'Temperature Over Land (left) ' + $
   'and Over Oceans (right)'
TV, image, 0

; Determine where the land is located within the
; elevation image.
land = WHERE(elvImage GE 125)

; Set the temperature image as the background.
image = tmpImage

; Replace values from the temperature image with values
; from the elevation image only where the land pixels
; are located.
image[land] = elvImage[land]

; Display the resulting temperature over oceans image.
TV, image, 1

END