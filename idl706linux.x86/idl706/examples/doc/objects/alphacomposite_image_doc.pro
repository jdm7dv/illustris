;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/alphacomposite_image_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO alphacomposite_image_doc

; Open the political map, the base image.
mapFile = FILEPATH('afrpolitsm.png', $
   SUBDIRECTORY = ['examples', 'data'])
mapImg = READ_PNG(mapFile, mapR, mapG, mapB)

; Assign the mapImg's color table to a palette object.
mapPalette = OBJ_NEW('IDLgrPalette', mapR, mapG, mapB)

; Open the land cover characteristics image.
landFile = FILEPATH('africavlc.png', $
   SUBDIRECTORY = ['examples', 'data'])
landImg = READ_PNG (landFile, landR, landG, landB)
landImgDims = SIZE(landImg, /Dimensions)

; To mask out the black values of the land classification image,
; create a 4 channel array for the r, g, b, and alpha data.
alphaLand = BYTARR(4, landImgDims[0], landImgDims[1])

; Get the red, green and blue values used by the image
; and assign them to the first three channels of the
; alpha image array.
alphaLand[0, *, *] = landR[landImg]
alphaLand[1, *, *] = landG[landImg]
alphaLand[2, *, *] = landB[landImg]

; Mask out the black pixels with a values of 0.
; Multiple the values by 255 for complete opacity.
; You could set the byte value (0 to 255) to control
; transparency. If ALPHA_CHANNEL on image object is also
; set, the effects are cumulative.
mask = (landImg GT 0)
alphaLand [3, *, *] = mask*255B

; Create the transparent overlay image object.
oAlphaLand = OBJ_NEW('IDLgrImage', alphaLand, $
   DIMENSIONS=[600, 600], BLEND_FUNCTION=[3,4], $
   ALPHA_CHANNEL=0.35)

; Create the background, mapImg object.
oMapImg = OBJ_NEW('IDLgrImage', mapImg, $
   DIMENSIONS=[600, 600], PALETTE=mapPalette)

; Create the display the objects.
oWindow = OBJ_NEW('IDLgrWindow', $
   DIMENSIONS=[600, 600], RETAIN=2, $
   TITLE='Overlay of Land Cover Transparency')
viewRect = [0, 0, 600, 600]
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=viewRect)
oModel = OBJ_NEW('IDLgrModel')

; Add the transparent image after the base image.
oModel->Add, oMapImg
oModel->Add, oAlphaLand
oView->Add, oModel
oWindow->Draw, oView

; Clean up objects.
OBJ_DESTROY, [oView, oMapImg, oAlphaLand, $
   mapPalette]

END