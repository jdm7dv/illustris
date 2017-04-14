;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/cropworld.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO CropWorld

; Read in the image file.
world = READ_PNG(FILEPATH('avhrr.png', $
   SUBDIRECTORY = ['examples', 'data']), R,G,B)

; Prepare the display device and load the color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
TVLCT, R, G, B

; Get the size of the image array.
worldSize = SIZE(world, /DIMENSIONS)

; Use the returned dimensions to create a display window
; and display the original image.
WINDOW, 0, XSIZE = worldSize[0], YSIZE = worldSize[1]
TV, world

; Note: the following  section uses numeric coordinates to
; crop the array instead of defining coordinates using the
; CURSOR function. Compared to the step-by-step example,
; this line has  the following structure:
; africa = world[LeftLowX:RightTopX, LeftLowY:RightTopY]
africa = world [312:475, 103:264]

; Define the window size based on the size of the cropped
; array using XSIZE = (RightTopX - LeftLowX + 1),
; YSIZE = (RightTopY - LeftLowY + 1)
WINDOW, 2, XSIZE =(475-312 + 1), YSIZE =(264-103 + 1)

; Display the cropped image.
TV, africa

END