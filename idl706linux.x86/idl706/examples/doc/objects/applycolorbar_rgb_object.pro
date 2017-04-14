;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/applycolorbar_rgb_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ApplyColorbar_RGB_Object

; Determine path to "glowing_gas.jpg" file.
cosmicFile = FILEPATH('glowing_gas.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Import image from file into IDL.
READ_JPEG, cosmicFile, cosmicImage

; Determine size of image.
cosmicSize = SIZE(cosmicImage, /DIMENSIONS)

; Initialize objects.
; Initialize display.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [cosmicSize[1], cosmicSize[2]], $
   TITLE = 'glowing_gas.jpg')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., cosmicSize[1], $
   cosmicSize[2]])
oModel = OBJ_NEW('IDLgrModel')
; Initialize image.
oImage = OBJ_NEW('IDLgrImage', cosmicImage, $
   INTERLEAVE = 0, DIMENSIONS = [cosmicSize[1], $
   cosmicSize[2]])

; Add image to model, which is added to view, and then
; display view in window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Initialize color parameter.
fillColor = [[0, 0, 0], $ ; black
   [255, 0, 0], $ ; red
   [255, 255, 0], $ ; yellow
   [0, 255, 0], $ ; green
   [0, 255, 255], $ ; cyan
   [0, 0, 255], $ ; blue
   [255, 0, 255], $ ; magenta
   [255, 255, 255]] ; white

; Initialize polygon location parameters.
x = [5., 25., 25., 5., 5.]
y = [5., 5., 25., 25., 5.] + 5.
offset = 20.*FINDGEN(9) + 5.

; Initialize location of colorbar border.
x_border = [x[0] + offset[0], x[1] + offset[7], $
   x[2] + offset[7], x[3] + offset[0], x[4] + offset[0]]

; Initialize polygon objects.
oPolygon = OBJARR(8)
FOR i = 0, (N_ELEMENTS(oPolygon) - 1) DO oPolygon[i] = $
   OBJ_NEW('IDLgrPolygon', x + offset[i], y, $
   COLOR = fillColor[*, i])

; Initialize polyline (border) object.
z = [0.001, 0.001, 0.001, 0.001, 0.001]
oPolyline = OBJ_NEW('IDLgrPolyline', x_border, y, z, $
   COLOR = [255, 255, 255])

; Add polgons and polyline to model and then re-display
; view in window.
oModel -> Add, oPolygon
oModel -> Add, oPolyline
oWindow -> Draw, oView

; Clean up object references.
OBJ_DESTROY, oView

END