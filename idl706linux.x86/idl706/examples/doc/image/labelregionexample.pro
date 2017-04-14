;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/labelregionexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO LabelRegionExample

; Prepare the display device and load grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open the image file.
file = FILEPATH('r_seeberi.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, image, /GRAYSCALE

; Get the image dimensions and add a border to the
; image.
dims = SIZE(image, /DIMENSIONS)
padImg = REPLICATE(0B, dims[0]+20, dims[1]+20)
padImg [10,10] = image

; Get the size of the padded image and display it.
dims = SIZE(padImg, /DIMENSIONS)
WINDOW, 0, XSIZE = 2*dims[0], YSIZE = 2*dims[1], $
   TITLE = 'Opened, Thresholded and Labeled Region Images'
TVSCL, padImg, 0

; Define the radius of the structuring element and
; create the disk.
radius = 5
strucElem = SHIFT(DIST(2*radius+1), $
   radius, radius) LE radius

; Apply the opening operator to the image.
openImg = MORPH_OPEN(padImg, strucElem, /GRAY)
TVSCL, openImg, 1

; Determine threshold value using histogram as a guide.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(openImg)

; Threshold the image to prepare to remove background
; noise.
threshImg = openImg GE 170

; Display the image.
WSET, 0
TVSCL, threshImg, 2

; Identify regions and print each region's pixel
; population and percentage.
regions = LABEL_REGION(threshImg)
hist = HISTOGRAM(regions)
FOR i=1, N_ELEMENTS (hist) - 1 DO PRINT, 'Region', i, $
   ', Pixel Popluation = ', hist(i), '    Percent = ', $
   100.*FLOAT(hist[i])/(dims[0]*dims[1])

; Load a color table and display the regions.
LOADCT, 12
TVSCL, regions, 3

; Display the pixel population of the regions.
WINDOW, 1, $
   TITLE='Surface Representation of Region Populations'
FOR i=1, N_ELEMENTS(hist)-1 DO $
   regions[WHERE(regions EQ i)] = hist [i]
SURFACE, regions

END