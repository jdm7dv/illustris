;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/idlgrwindowexample__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This example demonstrates how to create a subclass of the
; IDLgrWindow class for use in an object exported via the
; IDL Export Bridge assistant.
;
; For an example Java class that uses this class, see the
; file <IDL_DIR>/resource/bridge/export/java/IDLWindowExample.java.
; Instructions for using that class are contained in the .java
; file, and in the IDL Connectivity Bridges manual.
;
; MODIFICATION HISTORY:
;   Created, Sept 2005
FUNCTION IDLgrWindowExample::Init, $
    RENDERER=renderer, _EXTRA=_extra

    ; Some video cards experience problems when using
    ; OpenGL hardware rendering. We set the window to use
    ; IDL's software rendering by default. To use hardware
    ; rendering instead, set renderer=0.
    renderer = 1
    if (~self->IDLgrWindow::Init(RENDERER=renderer, $
        _EXTRA=_extra)) then return, 0
    self->CreateObjects
    RETURN, 1
END

PRO IDLgrWindowExample::Cleanup
    ; Clean up myself.
    OBJ_DESTROY, self.oContainer
    ; Clean up superclass.
    self->IDLgrWindow::Cleanup
END

PRO IDLgrWindowExample::CreateObjects

    ; Trackball properties.
    self->GetProperty, DIMENSIONS=dims
    self.center = [dims[0]/2.,dims[1]/2.]
    self.radius = dims[0]

    ; Read elevation data.
    file = FILEPATH('worldelv.dat', $
       SUBDIRECTORY = ['examples', 'data'])
    OPENR,lun,file,/GET_LUN
    image = MAKE_ARRAY(360,360,/BYTE)
    READU,lun,image
    FREE_LUN,lun
    MESH_OBJ, 4, vertices, polygons, REPLICATE(0.25, 101, 101)

    self.oContainer = OBJ_NEW('IDL_Container')

    ; Create graphics hierarchy.
    oModel = OBJ_NEW('IDLgrModel')
    oPalette = OBJ_NEW('IDLgrPalette')
    self.oContainer->Add, oPalette
    oPalette -> LOADCT, 33
    oPalette -> SetRGB, 255, 255, 255, 255
    oImage = OBJ_NEW('IDLgrImage', image, PALETTE = oPalette)
    self.oContainer->Add, oImage
    vector = FINDGEN(101)/100.
    texure_coordinates = FLTARR(2, 101, 101)
    texure_coordinates[0, *, *] = vector # REPLICATE(1., 101)
    texure_coordinates[1, *, *] = REPLICATE(1., 101) # vector
    oPolygons = OBJ_NEW('IDLgrPolygon', SHADING = 1, $
       DATA = vertices, POLYGONS = polygons, $
       COLOR = [255, 255, 255], $
       TEXTURE_COORD = texure_coordinates, $
       TEXTURE_MAP = oImage, /TEXTURE_INTERP)
    oModel -> ADD, oPolygons
    oModel -> ROTATE, [1, 0, 0], -90
    oModel -> ROTATE, [0, 1, 0], -90
    width = 0.5
    height = width*FLOAT(dims[1])/dims[0]
    oView = OBJ_NEW('IDLgrView', $
        VIEWPLANE_RECT=[-width/2, -height/2, width, height])
    oView->Add, oModel
    self.oModel = oModel

    self->SetProperty, GRAPHICS_TREE=oView
END

PRO IDLgrWindowExample::OnMouseDown, x, y, button, keyMods, nClicks

    ; Only look for left mouse button.
    IF (button NE 1) THEN RETURN

    ; Calculate distance of mouse click from center of unit circle.
    xy = ([x,y] - self.center) / self.radius
    r = TOTAL(xy^2)
    self.pt1 = (r gt 1.0) ? [xy/SQRT(r) ,0.0] : [xy,SQRT(1.0-r)]
    self.pt0 = self.pt1
    self.buttonDown = 1b
END

PRO IDLgrWindowExample::OnMouseUp, x, y, button

    ; Only look for left mouse button.
    IF (button NE 1) THEN RETURN
    self.buttonDown = 0b
END

PRO IDLgrWindowExample::OnMouseMotion, x, y, keyMods

    IF (~self.buttonDown) THEN RETURN

    ; Calculate distance of mouse click from center of unit circle.
    xy = ([x, y] - self.center) / self.radius
    r = TOTAL(xy^2)
    pt1 = (r gt 1.0) ? [xy/SQRT(r) ,0.0] : [xy,SQRT(1.0-r)]
    self.pt1 = pt1

    pt0 = self.pt0
    ; Update the transform only if the mouse button has actually
    ; moved from its previous location.
    IF (ARRAY_EQUAL(pt0, pt1)) THEN RETURN

    ; Compute transformation.
    q = [CROSSP(pt0,pt1), TOTAL(pt0*pt1)]
    x = q[0]
    y = q[1]
    z = q[2]
    w = q[3]
    transform = $
        [[ w^2+x^2-y^2-z^2, 2*(x*y-w*z), 2*(x*z+w*y), 0], $
        [ 2*(x*y+w*z), w^2-x^2+y^2-z^2, 2*(y*z-w*x), 0], $
        [ 2*(x*z-w*y), 2*(y*z+w*x), w^2-x^2-y^2+z^2, 0], $
        [ 0          , 0          , 0              , 1]]
    self.pt0 = pt1
    self.oModel->GetProperty, TRANSFORM=modelTrans
    self.oModel->SetProperty, TRANSFORM=modelTrans # transform
    self->Draw
END

PRO IDLgrWindowExample::OnKeyboard, isASCII, Character, keyValue,$
                     x, y, Press, Release, keyMods

    ; Suppress if we have the mouse down and are just
    ; using a modifier key.
    IF (self.buttonDown) THEN RETURN
    ; Ignore ascii characters.
    IF (isASCII) THEN RETURN

    CASE (keyValue) OF
        5: xy = [-10,0]  ; left
        6: xy = [ 10,0]  ; right
        7: xy = [0,10]   ; up
        8: xy = [0,-10]  ; down
        ELSE: RETURN
    ENDCASE

    xy += self.center
    self.pt0 = [0,0,1]
    self.buttonDown = 1b
    self->OnMouseMotion, xy[0], xy[1], 0
    self.buttonDown = 0b
END

PRO IDLgrWindowExample::OnResize, width, height
    ; Recompute the trackball.
    self.center = [width/2.,height/2.]
    self.radius = width
    ; Pass on to superclass to actually change dims.
    self->IDLgrWindow::OnResize, width, height
END

PRO IDLgrWindowExample::OnEnter
    self->NotifyBridge, "IDLgrWindowExample", "OnEnter"
END

PRO IDLgrWindowExample::OnExit
    self->NotifyBridge, "IDLgrWindowExample", "OnExit"
END

PRO IDLgrWindowExample__define
     void = {IDLgrWindowExample, inherits IDLgrWindow, $
        oContainer: OBJ_NEW(), $
        oModel: OBJ_NEW(), $
        center: LONARR(2), $
        radius: 0d, $
        buttonDown: 0b, $
        pt0: DBLARR(3), $
        pt1: DBLARR(3) $
        }
END
