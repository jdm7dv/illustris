;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/transparentwarping_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO TransparentWarping_Object

; Open the political map, the base image to which the
; land cover image will be warped.
mapFile= FILEPATH('afrpolitsm.png', $
   SUBDIRECTORY = ['examples', 'data'])
mapImg = READ_PNG(mapFile, mapR, mapG, mapB)

; Assign the mapImg's color table to a palette object.
mapPalette = OBJ_NEW('IDLgrPalette', mapR, mapG, mapB)

; Open the land cover characteristics image
; that will be warped to the political map.
landFile = FILEPATH('africavlc.png', $
   SUBDIRECTORY = ['examples', 'data'])
landImg = READ_PNG (landFile, landR, landG, landB)

; Select the control point using the polygon tool in
; XROI.
XROI, landImg, landR, landG, landB, $
   REGIONS_OUT = landROIout, /BLOCK
PRINT, 'Select control points using Draw Polygon tool'
; Assign the ROI data to the Xi and Yi control point
; vectors.
landROIout -> GetProperty, DATA = landROIdata
Xi = landROIdata[0,*]
Yi = landROIdata[1,*]

; Select the control point in the reference image
; using the polygon tool in XROI.
XROI, mapImg, mapR, mapG, mapB, $
   REGIONS_OUT = mapROIout, /BLOCK
PRINT, 'Select control points using Draw Polygon tool'
; Assign the ROI data to the Xo and Yo control point
; vectors.
mapROIout -> GetProperty, DATA = mapROIdata
Xo = mapROIdata[0,*]
Yo = mapROIdata[1,*]

; Using the control point vectors, warp the land
; classification image to the political map.
warpImg = WARP_TRI(Xo, Yo, Xi, Yi, landImg, $
   OUTPUT_SIZE = [600, 600], /EXTRAPOLATE)

; Quickly display the warped image in a Direct Graphics
; window to check the precision of the warp. Load the
; image's associated color table and display it.
DEVICE, DECOMPOSED = 0
TVLCT, landR, landG, landB
WINDOW, 3, XSIZE = 600, YSIZE = 600, $
   TITLE = 'Image Warped with WARP_TRI'
TV, warpImg

; Make the warped land classification image into a
; 24-bit RGB image in order to use alpha blending.
warpImgDims = SIZE(warpImg, /Dimensions)
alphaWarp = BYTARR(4, warpImgDims[0], warpImgDims[1])

; Get the red, green and blue values used by the image
; and assign them to the first three channels of the
; alpha image array.
alphaWarp[0, *, *] = landR[warpImg]
alphaWarp[1, *, *] = landG[warpImg]
alphaWarp[2, *, *] = landB[warpImg]

; Create a transparency mask, the same size as the
; warpImg array. Mask out the black pixels with a
; values of 0. Set the alpha channel by multiplying
; the mask by 128, resulting in a 50% transparency.
mask = (warpImg GT 0)
alphaWarp [3, *, *] = mask*128B
; To alter the transparency, change the value 128. This
; value can range from 0 (completely transparent) to
; 255 (completely opaque).

; Create the objects necessary for the Object Graphics
; display. Create the transparent overlay image object.
oAlphaWarp = OBJ_NEW('IDLgrImage', alphaWarp, $
   DIMENSIONS = [600, 600], BLEND_FUNCTION = [3,4])

; Create the background, mapImg object and apply its
; palette.
oMapImg = OBJ_NEW('IDLgrImage', mapImg, $
   DIMENSIONS = [600, 600], PALETTE = mapPalette)

; Create a window in which to display the objects.
oWindow = OBJ_NEW('IDLgrWindow', $
   DIMENSIONS = [600, 600], RETAIN = 2, $
   TITLE = 'Overlay of Land Cover Transparency')

; Create a view.
viewRect = [0, 0, 600, 600]
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = viewRect)

; Create a model object.
oModel = OBJ_NEW('IDLgrModel')

; Add the transparent image after the adding the base
; image.
oModel -> Add, oMapImg
oModel -> Add, oAlphaWarp

; Add the model containing the images to the view.
oView -> Add, oModel

; Draw the view in the window.
oWindow -> Draw, oView

; Clean up objects.
OBJ_DESTROY, [oView, oMapImg, oAlphaWarp, $
   mapPalette, landROIout, mapROIout]

END