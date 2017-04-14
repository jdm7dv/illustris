;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/paddedimage.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO PaddedImage

; Select and read the image file.
earth = READ_PNG (FILEPATH ('avhrr.png', $
   SUBDIRECTORY = ['examples', 'data']), R, G, B)

; Load the color table and designate white to occupy the
; final position in the red, green and blue bands.
TVLCT, R, G, B
maxColor = !D.TABLE_SIZE - 1
TVLCT, 255, 255, 255, maxColor

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2

; Get the size of the original image array.
earthSize = SIZE(earth, /DIMENSIONS)

; Return an array with the given dimensions.
paddedEarth = REPLICATE(BYTE(maxColor), earthSize[0] + 20, $
   earthSize[1] + 40)

; Copy the original image into the appropriate portion
; of the new array.
paddedEarth [10,10] = earth

; Prepare a window and display the new image.
WINDOW, 0, XSIZE = earthSize[0] + 20, $
   YSIZE = earthSize[1] + 40
TV, paddedEarth

; Place a title at the top of the image using the
; XYOUTS procedure.
x = (earthSize[0]/2) + 10
y = earthSize[1] + 15
XYOUTS, x, y, 'World Map', ALIGNMENT = 0.5, COLOR = 0, $
   /DEVICE

END