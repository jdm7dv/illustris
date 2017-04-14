; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/obj_vol.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

PRO obj_vol

; Create volume data descriptions.
dim=32
factor = 128./dim

data = BYTARR(dim, dim, dim)
FOR i=0, dim-1 do data[*, i, 0:i] = i*factor

pos0 = LONG(dim * 0.08)
pos1 = pos0 + 2*pos0
pos2 = dim-pos1
pos3 = dim-pos0
 
data[pos0:pos1, pos0:pos1, pos2:pos3] = 128
data[pos2:pos3, pos2:pos3, pos0:pos1] = 255

; Create a volume object.
myvolume = OBJ_NEW('IDlgrVolume', data)

; Scale volume object into normalized coordinates.
cc = [-0.5, 1.0/float(dim)]
myvolume -> SetProperty, XCOORD_CONV=cc, YCOORD_CONV=cc, ZCOORD_CONV=cc

; Set volume object properties.
myvolume -> SetProperty, ZERO_OPACITY_SKIP=1
myvolume -> SetProperty, ZBUFFER=1

; Create object hierarchy.
mywindow = OBJ_NEW('IDLgrWindow', DIMENSIONS=[200, 200])
myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-1, -1, 2, 2], $
	ZCLIP=[2.0, -2.0], COLOR=[200,200,0])
mymodel = OBJ_NEW('IDLgrModel')

myview -> Add, mymodel
mymodel -> Add, myvolume
mymodel -> Rotate, [1, 1, 1], 45

; Draw the volume object.
mywindow -> Draw, myview

; Prompt for user input before proceeding.
var=''
READ, var, PROMPT='Press Return to set opacities'

; Set opacities of the volumes and redraw.
opac = bytarr(256)
opac[0:127] = bindgen(128)/8
opac[255] = 255
opac[128] = 255
myvolume -> SetProperty, OPACITY_TABLE0=opac
mywindow -> Draw, myview

; Prompt for user input before proceeding.
READ, var, PROMPT='Press Return to set colors'

; Set colors of the volumes and redraw.
rgb = bytarr(256, 3)
rgb[0:127, 0] = bindgen(128)
rgb[0:127, 1] = bindgen(128)
rgb[0:127, 2] = bindgen(128)
rgb[128, *] = [255, 0, 0]
rgb[255, *] = [0, 0, 255]
myvolume -> SetProperty, RGB_TABLE0=rgb
mywindow -> Draw, myview

; Prompt for user input before proceeding.
READ, var, PROMPT='Press Return to add lighting'

; Create a light object and redraw.
myvolume -> SetProperty, AMBIENT=[100, 100, 100], LIGHTING_MODEL=1, TWO_SIDED=1
lmodel = OBJ_NEW('IDLgrModel')
myview -> add, lmodel
light = OBJ_NEW('IDLgrLight', TYPE=2, LOCATION=[0, 0, 1], COLOR=[255, 255, 255])
lmodel -> Add, light
mywindow -> Draw, myview

; Prompt for user input before proceeding.
READ, var, PROMPT='Press Return to use MIP compositing'

; Change compositing function and redraw.
myvolume -> SetProperty, COMPOSITE_FUNCTION=1, LIGHTING_MODEL=0
mywindow -> Draw, myview

; Prompt for user input before proceeding.
READ, var, PROMPT='Press Return to destroy objects'

; Destroy the objects.
OBJ_DESTROY, myview
OBJ_DESTROY, mywindow

END
