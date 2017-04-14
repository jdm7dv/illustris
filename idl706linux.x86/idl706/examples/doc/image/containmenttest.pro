;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/containmenttest.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ContainmentTest

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2

; Select and open the image file and get its size.
img = READ_PNG(FILEPATH('avhrr.png', $
   SUBDIRECTORY = ['examples', 'data']), R, G, B)
dims = SIZE(img, /DIMENSIONS)

; Open the file in the XROI utility to select a ROI.
XROI, img, REGIONS_OUT = ROIout, R, G, B, /BLOCK, $
   TITLE = 'Create ROI and Close Window'

; Load the image color table and display the image.
TVLCT, R, G, B
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1], $
   TITLE = 'Left-Click Anywhere in Image'
TV, img

; Select and define the coordinates of a point and
; delete window.
PRINT, 'Left-click anywhere in the image.'
CURSOR, xi, yi, /DEVICE
WDELETE, 0

; Test for point containment within the ROI
; and print result of the containment test.
ptTest = ROIout -> ContainsPoints(xi,yi)
containResults = [ $
   'Point lies outside ROI', $
   'Point lies inside ROI', $
   'Point lies on the edge of the ROI', $
   'Point lies on vertex of the ROI']

PRINT, 'Result =', ptTest, ':	', $
   containResults[ptTest]

; Create a 7x7 square indicating original point.
x = LINDGEN(7*7) MOD 7 + xi
y = LINDGEN(7*7) / 7 + yi
point = x + y * dims[0]

; Define the color to use for the ROI and point.
maxClr = !D.TABLE_SIZE - 1
TVLCT, 255, 255, 255, maxClr

; Identify the point within the original image.
regionPt = img
regionPt[point] = maxClr

; Create a window and display the point and ROI.
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1], $
   TITLE='Containment Test Results'
TV, regionPt
DRAW_ROI, ROIout, COLOR = maxClr, /LINE_FILL, $
   THICK = 2, LINESTYLE = 0, ORIENTATION = 315, /DEVICE

; Destroy object references.
OBJ_DESTROY, ROIout

END