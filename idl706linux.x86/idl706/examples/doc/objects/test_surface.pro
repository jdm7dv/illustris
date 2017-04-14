; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/test_surface.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

PRO test_surface, VIEW=oView, MODEL=oModel, SURFACE=oSurface, WINDOW=oWindow

    ; Create some data.
    zData = DIST(60)

    ; Create a view.
    oView = OBJ_NEW('IDLgrView', color=[60,60,60], VIEWPLANE_RECT=[-1,-1,2,2])

    ; Create a model.
    oModel = OBJ_NEW('IDLgrModel' )
    oView->Add, oModel

    ; Create a surface.
    oSurface = OBJ_NEW('IDLgrSurface', zData, color=[255,0,0])

    ; Add the surface to the model.
    oModel->Add, oSurface

    ; Get the data range of the surface.
    oSurface->GetProperty,XRANGE=xrange,YRANGE=yrange,ZRANGE=zrange

    ; Scale surface to normalized units and center.
    xs = [-0.5, 1/(xrange[1]-xrange[0])]
    ys = [-0.5, 1/(yrange[1]-yrange[0])]
    zs = [-0.5, 1/(zrange[1]-zrange[0])]
    oSurface->SetProperty,XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs

    ; Rotate model to standard view.
    oModel->Rotate,[1,0,0], -90
    oModel->Rotate,[0,1,0], 30
    oModel->Rotate,[1,0,0], 30

    ; Create a window destination.
    oWindow = OBJ_NEW('IDLgrWindow')

    ; Draw the view.
    oWindow->Draw, oView

END
