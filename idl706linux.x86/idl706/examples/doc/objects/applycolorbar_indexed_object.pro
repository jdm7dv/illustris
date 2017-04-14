;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/applycolorbar_indexed_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ApplyColorbar_Indexed_Object

; Determine path to "worldtmp.png" file.
worldtmpFile = FILEPATH('worldtmp.png', $
   SUBDIRECTORY = ['examples', 'demo', 'demodata'])

; Import image from file into IDL.
worldtmpImage = READ_PNG(worldtmpFile)

; Determine size of imported image.
worldtmpSize = SIZE(worldtmpImage, /DIMENSIONS)

; Initialize objects.
; Initialize display.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [worldtmpSize[0], worldtmpSize[1]], $
   TITLE = 'Average World Temperature (in Celsius)')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0, 0, worldtmpSize[0], $
   worldtmpSize[1]])
oModel = OBJ_NEW('IDLgrModel')
; Initialize palette and image.
oPalette = OBJ_NEW('IDLgrPalette')
oPalette -> LoadCT, 38
oImage = OBJ_NEW('IDLgrImage', worldtmpImage, $
   PALETTE = oPalette)

; Add image to model, which is added to view, and then
; display view in window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Initialize color level parameter.
fillColor = BYTSCL(INDGEN(18))

; Initialize text variable.
temperature = STRTRIM(FIX(((20.*fillColor)/51.) - 60), 2)

; Initialize polygon and text location parameters.
x = [5., 40., 40., 5., 5.]
y = [5., 5., 23., 23., 5.] + 5.
offset = 18.*FINDGEN(19) + 5.

; Initialize polygon and text objects.
oPolygon = OBJARR(18)
oText = OBJARR(18)
FOR i = 0, (N_ELEMENTS(oPolygon) - 1) DO BEGIN
   oPolygon[i] = OBJ_NEW('IDLgrPolygon', x, $
   y + offset[i], COLOR = fillColor[i], $
   PALETTE = oPalette)
   oText[i] = OBJ_NEW('IDLgrText', temperature[i], $
   LOCATIONS = [x[0] + 3., y[0] + offset[i] + 3.], $
   COLOR = 255*(fillColor[i] LT 255), $
   PALETTE = oPalette)
ENDFOR

; Add polygons and text to model and then re-display
; view in window.
oModel -> Add, oPolygon
oModel -> Add, oText
oWindow -> Draw, oView

; Clean up object references.
OBJ_DESTROY, [oView, oPalette]

END