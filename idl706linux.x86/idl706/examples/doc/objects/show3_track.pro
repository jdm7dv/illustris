;
; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/show3_track.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;	SHOW3_TRACK
;
; PURPOSE:
;	This procedure serves as an example of using the trackball
;	object to manipulate a composite object.
;
; CATEGORY:
;	Object graphics.
;
; CALLING SEQUENCE:
;	SHOW3_TRACK[, Data]
;
; OPTIONAL INPUTS:
; 	Data: A two-dimensional array representing the data to be displayed 
;             as a combination of an image, a surface, and a contour.  By
;             default, a BESEL function is displayed.
;
; MODIFICATION HISTORY:
; 	Written by:	DLD, July 1998
;-

;----------------------------------------------------------------------------
PRO SHOW3_TRACK_EVENT, sEvent

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    ; Handle KILL requests.
    IF TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState

       ; Destroy the objects.
       OBJ_DESTROY, sState.oView
       OBJ_DESTROY, sState.oTrack
       WIDGET_CONTROL, sEvent.top, /DESTROY
       RETURN
    ENDIF

    ; Handle other events.
    CASE uval OF
        'DRAW': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY

            ; Expose.
            IF (sEvent.type EQ 4) THEN BEGIN
                sState.oWindow->Draw, sState.oView
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
                RETURN
            ENDIF

           ; Handle trackball updates.
           bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
           IF (bHaveTransform NE 0) THEN BEGIN
               sState.oTopModel->GetProperty, TRANSFORM=t
               sState.oTopModel->SetProperty, TRANSFORM=t#qmat
               sState.oWindow->Draw, sState.oView
           ENDIF

           ; Handle other events.
           ;  Button press.
           IF (sEvent.type EQ 0) THEN BEGIN
               sState.btndown = 1b
               WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
               sState.oWindow->Draw, sState.oView
          ENDIF

        ; Button release.
        IF (sEvent.type EQ 1) THEN BEGIN
            IF (sState.btndown EQ 1b) THEN $
      	        sState.oWindow->Draw, sState.oView
            sState.btndown = 0b
            WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
        ENDIF
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    ENDCASE
END

;----------------------------------------------------------------------------
PRO show3_track, data
    xdim = 480 
    ydim = 360

    ; Default surface data is a Besel function.
    IF (N_ELEMENTS(data) EQ 0) THEN $
 	data = BESELJ(SHIFT(DIST(40),20,20)/2,0)

    ; Create the widgets.
    wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
                        TITLE="SHOW3 Trackball Example", $
                        /TLB_KILL_REQUEST_EVENTS)

    wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
                        RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                        GRAPHICS_LEVEL=2)

    ; Realize the widgets.	
    WIDGET_CONTROL, wBase, /REALIZE

    ; Get the window id of the drawable.
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    ; Compute viewplane rect based on aspect ratio.
    aspect = FLOAT(xdim) / FLOAT(ydim)
    sqrt3 = SQRT(3.0)
    myview = [ -sqrt3*0.5, -sqrt3*0.5, sqrt3, sqrt3 ]
    IF (aspect GT 1) THEN BEGIN
        myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
        myview[2] = myview[2] * aspect
    ENDIF ELSE BEGIN
        myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
        myview[3] = myview[3] / aspect
    ENDELSE

    ; Create the view.
    oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=myview)

    ; Create a top level model.
    oTopModel = OBJ_NEW('IDLgrModel')
    oView->Add, oTopModel

    ; Create the show3 object.
    oShow3 = OBJ_NEW('IDLexShow3', data)
    oTopModel->Add, oShow3

    ; Scale and translate the show3 object to fit within view bounds.
    GET_BOUNDS, oShow3, xr, yr, zr
    xs = NORM_COORD(xr)
    ys = NORM_COORD(yr)
    zs = NORM_COORD(zr)
    oShow3->Scale, xs[1], ys[1], zs[1]
    oShow3->Translate, xs[0]-0.5, ys[0]-0.5, zs[0]-0.5

    ; Apply standard initial rotation.
    oTopModel->Rotate, [1,0,0], -90
    oTopModel->Rotate, [0,1,0], 30
    oTopModel->Rotate, [1,0,0], 30

    ; Create a trackball.
    oTrack = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2.)

    ; Save state.
    sState = {btndown: 0b, $
              wDraw: wDraw, $
              oWindow: oWindow, $
              oView: oView, $
              oTopModel: oTopModel, $
              oTrack: oTrack }

    WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY

    XMANAGER, 'SHOW3_TRACK', wBase, /NO_BLOCK
END