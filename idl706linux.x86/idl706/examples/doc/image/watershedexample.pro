;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/watershedexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO WatershedExample

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open image of Barrington Meteor Crater,
; AZ.
file = FILEPATH('meteor_crater.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, img, /GRAYSCALE

; Get the image size, create a window and display the
; image.
dims = SIZE(img, /DIMENSIONS)
WINDOW, 0, XSIZE = 3*dims[0], YSIZE = 2*dims[1], $
   TITLE = 'Defining Boundaries with WATERSHED'

; Display the original image.
TVSCL, img, 0
XYOUTS, 50, 444, 'Original Image', Alignment = .5, $
   /DEVICE, COLOR = 255

; Smooth the image and display it.
smoothImg = SMOOTH(img, 7, /EDGE_TRUNCATE)
TVSCL, smoothImg, 1
XYOUTS, (60 + dims[0]), 444, 'Smoothed Image', $
   ALIGNMENT = .5, /DEVICE, COLOR = 255

; Define the radius and create the structuring element.
radius = 3
strucElem = SHIFT(DIST(2*radius+1), $
   radius, radius) LE radius

; Use the top-hat operator before using watershed to
; highlight bright areas within the image.
tophatImg = MORPH_TOPHAT(smoothImg, strucElem)

; Display the image.
TVSCL, tophatImg, 2
XYOUTS, (60 + 2*dims[0]), 444, 'Top-hat Image', $
   ALIGNMENT = .5, /DEVICE, COLOR = 255

; Determine the intensity value using a histogram as a
; guide. Stretch the image.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(smoothImg)
tophatImg = tophatImg < 70

; Display the stretched image.
WSET, 0
TVSCL, tophatImg
XYOUTS, 75, 210, 'Stretched Top-hat Image', $
   ALIGNMENT = .5, /DEVICE, COLOR = 255

; Use the WATERSHED operator to create boundaries
; and display the results.
watershedImg = WATERSHED(tophatImg, CONNECTIVITY = 8)
TVSCL, watershedImg, 4
XYOUTS, (70 + dims[0]), 210, 'Watershed Image', $
   ALIGNMENT = .5, /DEVICE, COLOR = 255

; Overlay the boundaries defined by watershed onto
; the original image.
img [WHERE (watershedImg EQ 0)] = 0
TVSCL, img, 5
XYOUTS, (70 + 2*dims[0]), 210, 'Watershed Overlay', $
   ALIGNMENT = .5, /DEVICE, COLOR = 255

END