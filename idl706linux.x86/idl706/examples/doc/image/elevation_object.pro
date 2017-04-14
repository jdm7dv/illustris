;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/elevation_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO Elevation_Object

; Obtaining path to image file.
imageFile = FILEPATH('elev_t.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Importing image file.
READ_JPEG, imageFile, image

; Obtaining path to DEM data file.
demFile = FILEPATH('elevbin.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Importing data.
dem = READ_BINARY(demFile, DATA_DIMS = [64, 64])
dem = CONGRID(dem, 128, 128, /INTERP)

; Initialize the display.
DEVICE, DECOMPOSED = 0, RETAIN = 2

; Displaying original DEM elevation data.
WINDOW, 0, TITLE = 'Elevation Data'
SHADE_SURF, dem

; Initialize the  display objects.
oModel = OBJ_NEW('IDLgrModel')
oView = OBJ_NEW('IDLgrView')
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   COLOR_MODEL = 0)
oSurface = OBJ_NEW('IDLgrSurface', dem, STYLE = 2)
oImage = OBJ_NEW('IDLgrImage', image, $
   INTERLEAVE = 0, /INTERPOLATE)

; Calculating normalized conversion factors and
; shifting -.5 in every direction to center object
; in the window.
; Keep in mind that your view default coordinate
; system is [-1,-1], [1, 1]
oSurface -> GetProperty, XRANGE = xr, $
   YRANGE = yr, ZRANGE = zr
xs = NORM_COORD(xr)
xs[0] = xs[0] - 0.5
ys = NORM_COORD(yr)
ys[0] = ys[0] - 0.5
zs = NORM_COORD(zr)
zs[0] = zs[0] - 0.5
oSurface -> SetProperty, XCOORD_CONV = xs, $
   YCOORD_CONV = ys, ZCOORD = zs

; Applying image to surface (texture mapping).
oSurface -> SetProperty, TEXTURE_MAP = oImage, $
   COLOR = [255, 255, 255]

; Adding objects to model,then adding model to view.
oModel -> Add, oSurface
oView -> Add, oModel

; Rotating model for better display of surface
; in the object window.
oModel -> ROTATE, [1, 0, 0], -90
oModel -> ROTATE, [0, 1, 0], 30
oModel -> ROTATE, [1, 0, 0], 30

; Drawing the view of the surface (Displaying the
; results).
oWindow -> Draw, oView

; Displaying results in XOBJVIEW utility to allow
; rotation
XOBJVIEW, oModel, /BLOCK, SCALE = 1

; Destroying object references, which are no longer
; needed.
OBJ_DESTROY, [oView, oImage]

END