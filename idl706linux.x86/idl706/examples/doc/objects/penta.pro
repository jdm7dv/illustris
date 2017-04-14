; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/penta.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

PRO penta, MODEL=m1, COLOR=color, SYMBOL=p1, VIEW=v1

IF KEYWORD_SET(color) THEN COLOR=color ELSE COLOR=[0,0,255]

v1 = OBJ_NEW('IDLgrView', VIEW=[-1,-1,2,2])
m1 = OBJ_NEW('IDLgrModel')
p1 = OBJ_NEW('IDLgrPolygon', [-0.8,0.0,0.8,0.4,-0.4], $
             [0.2,0.8,0.2,-0.8,-0.8], COLOR=color)
v1 -> Add, m1
m1 -> Add, p1
model = m1
sym = p1
view = v1

END
