; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/planet.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;	PLANET
;
; PURPOSE:
;	This procedure demonstrates the use of object graphics to
;	manage local and global transformations. 
;
;	This procedure creates a simple widget application that allows 
;       the user to orbit a planet about a sun, or rotate the planet
;       about its own axis.
;
; CATEGORY:
;	Object graphics.
;
; CALLING SEQUENCE:
;	Planet
;
; MODIFICATION HISTORY:
; 	Written by:	RF, September 1996.
;-

;----------------------------------------------------------------------------
; PLANET_EVENT
;
; Purpose:
;  Handle events for the planet example.
;
PRO planet_event, sEvent

    ; Handle a kill request.
    IF TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
        OBJ_DESTROY, sState.oView
        OBJ_DESTROY, sState.oWindow
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    ENDIF

    ; Handle other events.
    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
    CASE uval OF
        'MOVE': BEGIN  ; Turn on/off automotion.
            WIDGET_CONTROl, sEvent.top, GET_UVALUE=sState
            sState.automotion = sEvent.select
            IF (sState.automotion EQ 1) THEN $
                WIDGET_CONTROL, sState.wBase, TIMER=sState.timer
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
          END
        'DRAW': BEGIN  ; Expose event.
            IF (sEvent.type EQ 4) THEN BEGIN
                WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
                sState.oWindow->Draw, sState.oView 
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
            ENDIF
          END
        'PLANET': BEGIN ; Rotate the planet about its axis. 
             WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
             sState.oRot->Rotate, [0,0,1], -30 
             sState.oWindow->Draw, sState.oView 
             WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
          END
        'TIMER' : BEGIN ; Timer event for automotion.
             WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
             IF (sState.automotion EQ 1) THEN BEGIN
                 sState.oRot->Rotate, [0,0,1], -10 
                 sState.oOrbit->Rotate, [0,1,0], -10
                 sState.oCorr->Rotate, [0,1,0], 10
             ENDIF 
             IF (sState.automotion EQ 1) THEN BEGIN
                 sState.oWindow->Draw, sState.oView 
                 WIDGET_CONTROL, sEvent.id, TIMER=sState.timer
             ENDIF
             WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
          END 
        'SUN': BEGIN    ; Orbit the planet about the sun.
             WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
	     sState.oOrbit->Rotate, [0,1,0], -30
	     sState.oCorr->Rotate, [0,1,0], 30
             sState.oWindow->Draw, sState.oView 
             WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
          END 
    ENDCASE
END

;----------------------------------------------------------------------------
; PLANET
;
; Purpose:
;  This procedure demonstrates the use of object graphics to manage local
;  and global transformations.  It creates a simple widget application 
;  that allows the user to orbit a planet about a sun, or rotate the planet
;  about its own axis.
;
PRO Planet

    xdim = 480
    ydim = 360

    ; Create the widgets.
    wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, TITLE='Planet Example', $
                        /TLB_KILL_REQUEST_EVENTS)
    wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
                        RETAIN=0, /EXPOSE_EVENTS, GRAPHICS_LEVEL=2)
    wGuiBase = WIDGET_BASE(wBase, /ROW, UVALUE='TIMER' )
    wButton = WIDGET_BUTTON(wGuiBase, VALUE="Spin Planet About Axis",$
                            UVALUE='PLANET')
    wButton = WIDGET_BUTTON(wGuiBase, VALUE="Orbit About Sun", UVALUE='SUN')
    wBBase = WIDGET_BASE(wGuiBase, /NONEXCLUSIVE)
    wButton = WIDGET_BUTTON(wBBase, VALUE="Automotion", UVALUE='MOVE')

    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    ; Use low quality so the rotation of the planet about its axis can
    ; be perceived.
    oWindow->Setproperty, QUALITY=0

    ; Create a view.
    aspect = FLOAT(xdim)/FLOAT(ydim)
    myview = [-2.0,-2.0,4.0,4.0]
    IF (aspect GT 1) THEN BEGIN
        myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0 
        myview[2] = myview[2] * aspect 
    ENDIF ELSE BEGIN
        myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0 
        myview[3] = myview[3] / aspect 
    ENDELSE
    oView = OBJ_NEW('IDLgrView', COLOR=[60,60,60], PROJECTION=2, EYE=4, $
                    ZCLIP=[2.0,-2.0], VIEWPLANE_RECT=myview )

    ; Create the top level model.
    oTop = OBJ_NEW('IDLgrModel')

    ; Create some lights.
    oLight1 = OBJ_NEW('IDLgrLight', LOCATION=[2,2,5], TYPE=2, INTENSITY=0.25)
    oTop->Add, oLight1
    oLight2 = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
    oTop->Add,oLight2

    ; Create the galaxy.
    oGalaxy = OBJ_NEW('IDLgrModel')
    oTop->Add, oGalaxy

    ; Create the sun.
    oSun = OBJ_NEW('Orb', COLOR=[255,255,0], DENSITY=0.7)
    oGalaxy->Add, oSun

    ; Create the rotational orbit.
    oOrbit = obj_new('IDLgrModel')
    oGalaxy->add,oOrbit

    ; Create the offset of the planet from the sun.
    oOffset = OBJ_NEW('idlgrmodel')
    oOffset->Translate,1.5,0,0
    oOrbit->Add, oOffset

    ; Create the rotational correction of the planet as it orbits about 
    ; the sun.
    oCorr = OBJ_NEW('IDLgrModel')
    oOffset->Add, oCorr

    ; Create the tilt of the planet's axis.
    oTilt = OBJ_NEW('IDLgrModel')
    oTilt->Rotate, [1,0,0], -60-180
    oTilt->Rotate, [0,0,1], -30
    oCorr->Add, oTilt

    ; Create the rotation of the planet about its axis.
    oRot = OBJ_NEW('IDLgrModel')
    oTilt->Add, oRot

    ; Create the axis of the planet.
    oAxis = OBJ_NEW('IDLgrPolyline', [[0,0,-0.5],[0,0,0.5]], COLOR=[0,255,0])
    oRot->Add, oAxis

    ; Create the planet. 
    oPlanet = OBJ_NEW('Orb', COLOR=[0,0,255], RADIUS=0.25, DENSITY=0.3, $
                      /TEX_COORDS)
    oRot->Add, oPlanet

    ; Add the model tree to the view and draw.
    oView->Add, oTop
    oWindow->Draw, oView

    sState = {wBase: wGuiBase, $
              timer: 0.4, $
              automotion: 0, $
              oRot:oRot, $
              oOrbit:oOrbit, $
              oCorr:oCorr, $
              oWindow:oWindow, $
              oView:oView $ 
              } 
    WIDGET_CONTROL, wBase, SET_UVALUE=sState

    XMANAGER, 'planet', wBase, /NO_BLOCK
END
