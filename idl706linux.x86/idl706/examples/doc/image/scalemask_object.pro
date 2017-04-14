;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/scalemask_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ScaleMask_Object

; Select the image file and get the image dimensions.
file= FILEPATH('md5290fc1.jpg', $
   SUBDIRECTORY = ['examples', 'data'])
READ_JPEG, file, img, /GRAYSCALE
dims = SIZE(img, /DIMENSIONS)

; Pass the image to XROI and define the region.
XROI, img, REGIONS_OUT = ROIout, /BLOCK

; Assign the ROI data to the arrays, x and y.
ROIout -> GetProperty, DATA = ROIdata
x = ROIdata[0,*]
y = ROIdata[1,*]

; Set the properties of the ROI.
ROIout -> SetProperty, COLOR = [255,255,255], THICK = 2

; Create the image object.
oImg = OBJ_NEW('IDLgrImage', img,$
   DIMENSIONS = dims)

; Create a window in which to display the selected ROI.
oWindow = OBJ_NEW('IDLgrWindow', DIMENSIONS = dims, $
   RETAIN = 2, TITLE = 'Selected ROI')

; Create the display objects and display the region.
viewRect = [0, 0, dims[0], dims[1]]
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = viewRect)

oModel = OBJ_NEW('IDLgrModel')
oModel -> Add, oImg
oModel -> Add, ROIout
oView -> Add, oModel
oWindow -> Draw, oView

; Create a mask and print area of the mask.
maskResult = ROIout -> ComputeMask( $
   DIMENSIONS = dims)
IMAGE_STATISTICS, img, MASK = MaskResult, COUNT = count
PRINT, 'area of mask =  ', count,' pixels'

; Mask out all portions of the image except for the ROI.
mask = (maskResult GT 0)
maskImg = img*mask

; Create a image containing only the cropped ROI.
cropImg = maskImg[min(x):max(x), min(y): max(y)]
cropDims = SIZE(cropImg, /DIMENSIONS)
oMaskImg = OBJ_NEW('IDLgrImage', cropImg, $
   DIMENSIONS = dims)

; Create a window in which to display the cropped ROI.
; Multiply the dimensions times the value you wish to
; magnify the ROI.
oMaskWindow = OBJ_NEW('IDLgrWindow', $
   DIMENSIONS = 2 * cropDims, RETAIN = 2, $
   TITLE = 'Magnified ROI', LOCATION = dims)

; Create the display objects and display the cropped
; ROI.
oMaskView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = viewRect)
oMaskModel = OBJ_NEW('IDLgrModel')
oMaskModel -> Add, oMaskImg
oMaskView -> Add, oMaskModel
OMaskWindow -> Draw, oMaskView

; Clean up objects.
OBJ_DESTROY, [oView, oMaskView, ROIout]

END