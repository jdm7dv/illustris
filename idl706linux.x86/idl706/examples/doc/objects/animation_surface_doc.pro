;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/animation_surface_doc.pro#2 $

; Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   animation_doc
;
; PURPOSE:
;   Create a simple animation that rotates a surface using timer-based
;   rotation in a window.
;
; CATEGORY:
;   Objects
;
;-
;;---------------------------------------------------------------------------------------
; Custom behavior class rotates the model
; containing the surface object. This class
; could be used to rotate any object (such as
; a volume or image) that is contained in
; the model.

FUNCTION MyRotator::Init, oModel
   self.oModel = oModel
   return, 1
END

PRO MyRotator::Cleanup
END

PRO MyRotator::OnTimer, oWin
   self.oModel->Rotate, [0,1,0], 10
   oWin->Draw
END

PRO MyRotator__define
   void = { MyRotator, $
           oModel: OBJ_NEW() $
          }
END

;;---------------------------------------------------------------------------------------
Pro animation_surface_doc

; Create a surface object and a light object.
zdata = HANNING (40, 40)
osurface = obj_new('IDLgrSurface', zdata, STYLE=2, $
     COLOR=[0,0,255], BOTTOM=[255, 0, 0], SHADING=1)
oLight = OBJ_NEW('IDLgrLight', type=2, location = [-1, -1, 1])
olightmodel = OBJ_NEW('IDLgrModel')
olightmodel->ADD, oLight

; Create display objects. Add the surface to a model. (The model
; does not set RENDER_METHOD as it contains only one object.)
oModel = OBJ_NEW('IDLgrModel')
oView = OBJ_NEW('IDLgrView')
oModel->Add, oSurface
oView->Add, oModel
oView->Add, olightmodel

; Convert data coordinates to normal coordinates.
oSurface->GetProperty, XRANGE=xr, YRANGE=yr, ZRANGE=zr
xc=NORM_COORD(xr)
xc[0] = xc[0] - 0.5
yc=NORM_COORD(yr)
yc[0] = yc[0] - 0.5
zc=NORM_COORD(zr)
zc[0] = zc[0] - 0.5

osurface->SetProperty, XCOORD_CONV=xc, YCOORD_CONV=yc, $
     ZCOORD_CONV=zc

; Position the object in the window.
omodel->ROTATE, [1,0,0], -90
omodel->ROTATE, [0,1,0], 30
omodel->ROTATE, [1,0,0], 30

; Create the window object and add the view.
; Create a new instance of the behavior class (MyRotator)
; and add the behavior object to the observer list of the
; window.
oWin = OBJ_NEW('IDLitWindow', DIMENSIONS=[300,300], $
     TITLE="Simple Surface Animation")
oWin->Add, oView
oRotator = OBJ_NEW('MyRotator', oModel)
oWin->AddWindowEventObserver, oRotator

; Set the timer interval and turn on window timer events.
oWin->SetTimerInterval, 0.04
oWin->SetEventMask, /TIMER_EVENTS

END