;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/removebridges.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RemoveBridges

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Read an image of New York using known dimensions.
xsize = 768
ysize = 512
img = READ_BINARY(FILEPATH('nyny.dat', $
   SUBDIRECTORY = ['examples', 'data']), $
   DATA_DIMS = [xsize, ysize])

; Increase image's contrast and display it.
img = BYTSCL(img)
WINDOW, 0
TVSCL, img

; Use a histogram to determine threshold value.
WINDOW, 4, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(img)

; Create an image mask from thresholded image.
maskImg = img LT 70

; Make a square-shaped structuring element.
side = 3
strucElem = DIST(side) LE side

; Remove details in the mask's shape.
maskImg = MORPH_OPEN(maskImg, strucElem)

; Fuse gaps in the mask's shape and display.
maskImg = MORPH_CLOSE(maskImg, strucElem)
WINDOW, 1, title='Mask After Opening and Closing'
TVSCL, maskImg

; Label regions to prepare to remove all but
; the largest region in the mask.
labelImg = LABEL_REGION(maskImg)

; Remove background and all but the largest region.
regions = labelImg[WHERE(labelImg NE 0)]
mainRegion = WHERE(HISTOGRAM(labelImg) EQ $
	MAX(HISTOGRAM(regions)))
maskImg = labelImg EQ mainRegion[0]

; Display the resulting mask.
Window, 3, TITLE = 'Final Masked Image'
TVSCL, maskImg

; Remove noise and smooth contours in  the original
; image.
newImg = MORPH_OPEN(img, strucElem, /GRAY)

; Replace new image with original image, where not
; masked.
newImg[WHERE(maskImg EQ 0)] = img[WHERE(maskImg EQ 0)]

; View result, comparing the new image with the
; original.
PRINT, 'Hit any key to end program.'
WINDOW, 2, XSIZE = xsize, YSIZE = ysize, $
   TITLE = 'Hit Any Key to End Program'

; Flicker between original and new image.
FLICK, img, newImg

END