;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/alphaimage_obj_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO alphaImage_obj_doc

; Load a CT and PT image and get the image dimensions.
file_pt = FILEPATH('head_pt.dcm', $
   SUBDIRECTORY=['examples', 'data'])
file_ct = FILEPATH('head_ct.dcm', $
   SUBDIRECTORY=['examples', 'data'])
img_pt = READ_DICOM(file_pt)
img_ct = READ_DICOM(file_ct)
dims_ct = SIZE(img_ct, /DIMENSIONS)
dims_pt = SIZE(img_pt, /DIMENSIONS)

; Check for dimension equality and resize if different.
IF dims_pt[0] NE dims_ct[0] then begin
   x = dims_ct[0]/dims_pt[0]
   img_pt = REBIN(img_pt, dims_pt[0]*x, dims_pt[1]*x)
   dims_pt = x*dims_pt
   If dims_pt[0] NE dims_ct[0] THEN BEGIN
      status = DIALOG_MESSAGE ('Incompatible images', /ERROR)
   ENDIF
ENDIF

; BYTSCL data before creating the base CT image.
img_ct = BYTSCL(img_ct)
oImageCT = OBJ_NEW('IDLgrImage', img_ct)

; Create display objects and display CT image.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN=2, $
   DIMENSIONS=[dims_ct[0], dims_ct[1]], $
   TITLE='CT Image')
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0., 0., $
   dims_ct[0], dims_ct[1]])
oModel = OBJ_NEW('IDLgrModel')
oModel->Add, oImageCT
oView->Add, oModel
oWindow->Draw, oView

; Create a palette object and load
; the red-temperature table.
oPalette = OBJ_NEW('IDLgrPalette')
oPalette->Loadct, 3

; BYTSCL the data and create the PT image object.
; Set the BLEND_FUNCTION and ALPHA_CHANNEL
; properties to support image transparency.
img_pt = BYTSCL(img_pt)
oImagePT = OBJ_NEW('IDLgrImage', img_pt, $
   PALETTE=oPalette, BLEND_FUNCTION=[3,4], $
   ALPHA_CHANNEL=0.50)

; Create a second window, add the semi-transparent
; image to the model containing the original image
; and display the overlay.
oWindow2 = OBJ_NEW('IDLgrWindow', RETAIN=2, $
   DIMENSIONS=[dims_pt[0], dims_pt[1]],  $
   LOCATION=[dims_ct[0]+10, 0],$
   TITLE='CT/PET Transparency')
oModel -> Add, oImagePT
oWindow2 -> Draw, oView

; Clean-up object references.
OBJ_DESTROY, [oView, oImageCT, oImagePT]

END