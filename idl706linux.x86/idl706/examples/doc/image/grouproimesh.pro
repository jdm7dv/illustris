;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/grouproimesh.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
Pro GroupROIMesh

; Prepare the display device and load a color table
; to more easily distinguish image features.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 5
TVLCT, R, G, B, /GET

; Select and open the file.
file = FILEPATH('head.dat', $
   SUBDIRECTORY = ['examples', 'data'])
img = READ_BINARY(file, DATA_DIMS = [80,100,57])

; Resize the array for display purposes and to
; compensate for the sampling rate of the scan slices.
img = CONGRID(img, 200, 225, 57)

; Initialize a ROI group object to which individual
; ROIs will be added.
oROIGroup = OBJ_NEW('IDLgrROIGroup')

; Use a FOR loop to define ROIs with which to create
; the mesh. Add each ROI to the group.
FOR i=0, 54, 5  DO BEGIN
   XROI, img[*, *,i], R, G, B, REGIONS_OUT = oROI, $
      /BLOCK, ROI_SELECT_COLOR = [255, 255, 255]
   oROI -> GetProperty, DATA = roiData
   roiData[2, *] = 2.2*i
   oRoi -> ReplaceData, roiData
   oRoiGroup -> Add, oRoi
ENDFOR

; Compute the mesh for the group.
result = oROIGroup -> ComputeMesh(verts, conn)

; Prepare to display the mesh, scaling and translating
; the array for display in XOBJVIEW.
nImg = 57
xymax = 200.0
zmax = float(nImg)
oModel = OBJ_NEW('IDLgrModel')
oModel -> Scale, 1./xymax,1./xymax, 1.0/zmax
oModel -> Translate, -0.5, -0.5, -0.5
oModel -> Rotate, [1, 0, 0], -90
oModel -> Rotate, [0, 1, 0], 30
oModel -> Rotate, [1, 0, 0], 30

; Create a polygon object using the results of
; ComputeMesh.
oPoly = OBJ_NEW('IDLgrPolygon', verts, POLYGON = conn, $
   COLOR = [128, 128, 128], SHADING = 1)

; Add the polygon to the model and display the polygon
; object in XOBJVIEW.
oModel -> Add, oPoly
XOBJVIEW, oModel, /BLOCK

; Clean up object references.
OBJ_DESTROY, [oROI, oROIGroup, oPoly, oModel]

END