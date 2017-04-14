;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/regiongrowex.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RegionGrowEx

; Prepare the display device and load a grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Load an image and get the image dimensions.
file = FILEPATH('md1107g8a.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, img, /GRAYSCALE
dims = SIZE(img, /DIMENSIONS)

; Double the size of the image for display purposes and
; get the new dimensions.
img = REBIN(BYTSCL(img), dims[0]*2, dims[1]*2)
dims = 2*dims

; Create a window and display the image.
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1], $
   TITLE = 'Click on Image to Select Point of ROI'
TVSCL, img

; Define the original region pixels. Use the CURSOR
; function to select the region, making a 10x10 square
; at the selected x,y, coordinates.
CURSOR, xi, yi, /DEVICE
x = LINDGEN(10*10) MOD 10 + xi
y = LINDGEN(10*10) / 10 + yi
roiPixels = x + y * dims[0]

; Delete the window after selecting the point.
WDELETE, 0

; Set the topmost color table entry to red.
topClr = !D.TABLE_SIZE - 1
TVLCT, 255, 0, 0, topClr

; Scale the array, setting the maximum array value
; equal to one less than the value of topClr.
regionPts = BYTSCL(img, TOP = (topClr - 1))

; Show the results of the original region selection.
regionPts[roiPixels] = topClr
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1], $
   TITLE = 'Original Region'
TV, regionPts

; Grow the region. The THRESHOLD values are determined
; empirically.
newROIPixels = REGION_GROW(img, roiPixels, $
   THRESHOLD = [215,255])

; Show the result of the region grown using
; thresholding.
regionImg = BYTSCL(img, TOP = (topClr - 1))
regionImg[newROIPixels] = topClr
WINDOW, 2, XSIZE = dims[0], YSIZE = dims[1], $
   TITLE = 'THRESHOLD Grown Region'
TV, regionImg

; Show the results of growing the region using
; STDDEV_MULTIPLIER in a new window.
stddevPixels = REGION_GROW(img, roiPixels, $
   STDDEV_MULTIPLIER = 7)

WINDOW, 3, XSIZE = dims[0], YSIZE = dims[1], $
   TITLE = "STDDEV_MULTIPLIER Grown Region"
regionImg2 = BYTSCL(img, TOP = (topClr - 1))
regionImg2[stddevPixels] = topClr
TV, regionImg2

END