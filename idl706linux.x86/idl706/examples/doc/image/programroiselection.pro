;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/programroiselection.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ProgramROISelection

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open the image file and get its size.
img = READ_PNG(FILEPATH('mineral.png', $
   SUBDIRECTORY = ['examples', 'data']))
dims = SIZE(img, /DIMENSIONS)

; Create a window and display the original image.
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1]
TVSCL, img, 0

; Threshold the image to select the initial ROI.
threshImg = (img LT 50)

; Get rid of gaps, applying a 3x3 element to the image
; using the erosion and dilation morphological
; operators.
strucElem = REPLICATE(1, 3, 3)
threshImg = ERODE(DILATE(TEMPORARY(threshImg), $
   strucElem), strucElem)

; Extract the contours of the thresholded image.
CONTOUR, threshImg, LEVEL = 1,  $
   XMARGIN = [0, 0], YMARGIN = [0, 0], $
   /NOERASE, PATH_INFO = pathInfo, PATH_XY = pathXY, $
   XSTYLE = 5, YSTYLE = 5, /PATH_DATA_COORDS

; Display the original image in a second window and
; load a discrete color table.
WINDOW, 2, XSIZE = dims[0], YSIZE = dims[1]
TVSCL, img
LOADCT, 12

; For each region, feed the ROI data into an IDLgrROI
; object for display with DRAW_ROI.
FOR I = 0, (N_ELEMENTS(pathInfo) - 1 ) DO BEGIN

   ; Initialize the IDLgrROI object with the contour
   ; information of the current region with the FOR
   ; loop.
   line = [INDGEN(pathInfo(I).N), 0]
   oROI = OBJ_NEW('IDLanROI', $
      (pathXY(*,pathInfo(I).OFFSET + line))[0, *], $
      (pathXY(*,pathInfo(I).OFFSET + line))[1, *])

   ; Draw each ROI defined by thresholding and
   ; contouring.
   DRAW_ROI, oROI, COLOR = 80

   ; Use ComputeMask in conjunction with
   ; IMAGE_STATISTICS to obtain the number of pixels
   ; covered by the regions when displayed.
   maskResult = oROI -> ComputeMask(DIMENSIONS = $
      [dims[0], dims[1]])
   IMAGE_STATISTICS, img, MASK = maskResult, $
      COUNT = maskArea

   ; Use ComputeGeometry to obtain the geometric area
   ; and perimeter of each region where 1 pixel =
   ; 1.2 x 1.2 mm.
   ROIStats = oROI -> ComputeGeometry($
      AREA = geomArea, PERIMETER = perimeter, $
      SPATIAL_SCALE = [1.2, 1.2, 1.0])

   ; Print the statistics of each ROI when it is
   ; displayed and wait 3 seconds before proceeding to
   ; next region.
   PRINT, ' '
   PRINT, 'Region''s mask area =	', $
      FIX(maskArea), ' pixels'
   PRINT, 'Region''s geometric area =	', $
      FIX(geomArea), ' mm'
   PRINT, 'Region''s perimeter = 	', $
      FIX(perimeter), ' mm'
   WAIT, 3

   ; Remove each unneeded object reference after
   ; displaying it.
   OBJ_DESTROY, oROI

; End the FOR loop.
ENDFOR

END