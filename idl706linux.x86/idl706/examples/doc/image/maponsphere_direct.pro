;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/maponsphere_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MapOnSphere_Direct

; Importing image into IDL.
file = FILEPATH('worldelv.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = [360, 360])

; Initializing color table and setting the final
; index values to white.
DEVICE, DECOMPOSED = 0
LOADCT, 33
TVLCT, 255, 255, 255, !D.TABLE_SIZE - 1

; Displaying the original image.
WINDOW, 0, XSIZE = 360, YSIZE = 360
TVSCL, image

; Creating a 360x360 sphere with a constant radius of
; 0.25 to use as the data.
MESH_OBJ, 4, vertices, polygons, REPLICATE(0.25, 360, 360), $
   /CLOSED

; Creating the window defining the view.
WINDOW, 2, XSIZE = 512, YSIZE = 512
SCALE3, XRANGE = [-0.25,0.25], YRANGE = [-0.25,0.25], $
   ZRANGE = [-0.25,0.25], AX = 0, AZ = -90

; Displaying data with image as texture map.
SET_SHADING, LIGHT = [-0.5, 0.5, 2.0]
!P.BACKGROUND = !P.COLOR
TVSCL, POLYSHADE(vertices, polygons, SHADES = image, /T3D)
!P.BACKGROUND = 0

END