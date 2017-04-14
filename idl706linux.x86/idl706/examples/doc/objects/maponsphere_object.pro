;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/maponsphere_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MapOnSphere_Object

; Importing image into IDL.
file = FILEPATH('worldelv.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = [360, 360])

; Creating a 51x51 sphere with a constant radius of
; 0.25 to use as the data.
MESH_OBJ, 4, vertices, polygons, $
   REPLICATE(0.25, 101, 101)

; Creating a model object to contain the display.
oModel = OBJ_NEW('IDLgrModel')

; Creating image and palette objects to contain the
; imported image and color table.
oPalette = OBJ_NEW('IDLgrPalette')
oPalette -> LoadCT, 33
oPalette -> SetRGB, 255,255,255,255
oImage = OBJ_NEW('IDLgrImage', image, $
   PALETTE = oPalette)

; Deriving texture map coordinates.
vector = FINDGEN(101)/100.
texure_coordinates = FLTARR(2, 101, 101)
texure_coordinates[0, *, *] = vector # REPLICATE(1., 101)
texure_coordinates[1, *, *] = REPLICATE(1., 101) # vector

; Creating the polygon object containing the data.
oPolygons = OBJ_NEW('IDLgrPolygon', SHADING = 1, $
   DATA = vertices, POLYGONS = polygons, $
   COLOR = [255,255,255], $
   TEXTURE_COORD = texure_coordinates, $
   TEXTURE_MAP = oImage, /TEXTURE_INTERP)

; Adding polygon to model container.  NOTE:  the polygon
; object already contains the texture map image and its
; related palette.
oModel -> ADD, oPolygons

; Rotating model to display zero degrees latitude and
; zero degrees longitude as front.
oModel -> ROTATE, [1, 0, 0], -90
oModel -> ROTATE, [0, 1, 0], -90

; Displaying results.
XOBJVIEW, oModel, /BLOCK

; Cleaning up object references.
OBJ_DESTROY, [oModel, oImage, oPalette]

END