; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/rot_text.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

PRO rot_text

; Create Window, View, Model, Text, and Font objects.

mywindow = OBJ_NEW('IDLgrWindow')
myfont1 = OBJ_NEW('IDLgrFont', 'times', SIZE=14)
myfont2 = OBJ_NEW('IDLgrFont', 'courier', SIZE=20)
myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,0,10,10], COLOR=[255,255,255])
mymodel = OBJ_NEW('IDLgrModel')
mytext = OBJ_NEW('IDLgrText', 'Text String', LOCATION=[4,4], COLOR=[0,0,0])

; Add the model object to the view object, and the text object
; to the model object. Set the projection and clipping planes.

myview -> Add, mymodel
mymodel -> Add, mytext
myview -> SetProperty, PROJECTION=2, EYE=50, ZCLIP=[5,-5]

; Rotate text around Z axis by adjusting the baseline.

FOR i=-5,0 DO BEGIN
  mytext->SetProperty, BASELINE=[1,0,i]
  mywindow->Draw, myview
  WAIT, 0.1
ENDFOR

; Rotate text around Y axis by adjusting the baseline.

FOR i=0,5 DO BEGIN
  mytext->SetProperty, BASELINE=[1,i,0]
  mywindow->Draw, myview
  WAIT, 0.1
ENDFOR

; Text is vertical

mytext->SetProperty, BASELINE=[0,1,0], UPDIR=[-1,0,0]
mywindow->Draw, myview
WAIT, 1

; Text is horizontal, set font, change color.

mytext -> SetProperty, FONT=myfont1, BASELINE=[1,0,0], $
          UPDIR=[0,1,0], COLOR=[200,100,0]
mywindow->Draw, myview
WAIT, 1

; Text is horizontal, set font, change color.

mytext -> SetProperty, FONT=myfont2, COLOR=[255,0,0], $
          LOCATION=[1,4]
mywindow->Draw, myview

; Prompt to destroy objects.

var=''
READ, var, PROMPT='press Return to destroy the window'

; Destroy objects.

OBJ_DESTROY, mywindow
OBJ_DESTROY, myview
OBJ_DESTROY, myfont1
OBJ_DESTROY, myfont2

END
