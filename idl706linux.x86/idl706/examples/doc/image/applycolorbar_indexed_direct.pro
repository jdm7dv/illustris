;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/applycolorbar_indexed_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ApplyColorbar_Indexed_Direct

; Determine path to "worldtmp.png" file.
worldtmpFile = FILEPATH('worldtmp.png', $
   SUBDIRECTORY = ['examples', 'demo', 'demodata'])

; Import image from file into IDL.
worldtmpImage = READ_PNG(worldtmpFile)

; Determine size of imported image.
worldtmpSize = SIZE(worldtmpImage, /DIMENSIONS)

; Initialize display.
DEVICE, DECOMPOSED = 0
LOADCT, 38
WINDOW, 0, XSIZE = worldtmpSize[0], $
   YSIZE = worldtmpSize[1], $
   TITLE = 'Average World Temperature (in Celsius)'

; Display image.
TV, worldtmpImage

; Initialize color level parameter.
fillColor = BYTSCL(INDGEN(18))

; Initialize text variable.
temperature = STRTRIM(FIX(((20.*fillColor)/51.) - 60), 2)

; Initialize polygon and text location parameters.
x = [5., 40., 40., 5., 5.]
y = [5., 5., 23., 23., 5.] + 5.
offset = 18.*FINDGEN(19) + 5.

; Apply polygons and text.
FOR i = 0, (N_ELEMENTS(fillColor) - 1) DO BEGIN
   POLYFILL, x, y + offset[i], COLOR = fillColor[i], $
   /DEVICE
   XYOUTS, x[0] + 5., y[0] + offset[i] + 5., $
   temperature[i], COLOR = 255*(fillColor[i] LT 255), $
   /DEVICE
ENDFOR

END