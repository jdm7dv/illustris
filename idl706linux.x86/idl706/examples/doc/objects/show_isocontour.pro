;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/show_isocontour.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;$Id: //depot/idl/IDL_70/idldir/examples/doc/objects/show_isocontour.pro#2 $
;Event handler for trackball.
pro SHOW3_TRACK_EVENT, sEvent

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    ; Handle KILL requests.
    if TAG_NAMES(sEvent, /STRUCTURE_NAME) eq 'WIDGET_KILL_REQUEST' then begin
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState

       ; Destroy the objects.
       OBJ_DESTROY, sState.oView
       OBJ_DESTROY, sState.oTrack
       WIDGET_CONTROL, sEvent.top, /DESTROY
       return
    endif

    ; Handle other events.
    case uval of
        'DRAW': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY

            ; Expose.
            if (sEvent.type eq 4) then begin
                sState.oWindow->Draw, sState.oView
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
                return
            endif

           ; Handle trackball updates.
           bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
           if (bHaveTransform ne 0) then begin
               sState.oTopModel->GetProperty, TRANSFORM=t
               sState.oTopModel->SetProperty, TRANSFORM=t#qmat
               sState.oWindow->Draw, sState.oView
           endif

           ; Handle other events.
           ;  Button press.
           if (sEvent.type eq 0) then begin
               sState.btndown = 1b
               WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
               sState.oWindow->Draw, sState.oView
          endif

        ; Button release.
        if (sEvent.type eq 1) then begin
            if (sState.btndown eq 1b) then $
                sState.oWindow->Draw, sState.oView
            sState.btndown = 0b
            WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
        endif
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      end
    endcase
end

;-----------------------------------------------------------------------
;This example contours a surface using ISOCONTOUR. Texture coordinates
;are passed in as auxilliary data. The texture coordinates
;interpolated at contour vertices are then used to apply texturing
;to each contour level.

pro SHOW_ISOCONTOUR

    z = BYTARR(64,64, /NOZERO)
    OPENR, lun, FILEPATH('elevbin.dat', $
                              SUBDIR=['examples','data']), /GET_LUN
    READU, lun, z
    FREE_LUN, lun
    z = REVERSE(TEMPORARY(z), 2)

    ;Reduce high frequencies in z data, so as to better expose
    ;contour lines that will be lying on surface of z data.
    data = SMOOTH(TEMPORARY(z), 3, /EDGE_TRUNCATE) + 1

    ;Create texture map.
    nmaps = 1
    oTexMap = MAKE_ARRAY(nmaps,/OBJ)
    READ_JPEG, FILEPATH('elev_t.jpg', SUBDIR= $
                             ['examples','data']), idata, TRUE=3
    oTexMap[0] = OBJ_NEW('IDLgrImage', REVERSE(TEMPORARY(idata), 2), $
                         INTERLEAVE = 2)

    ;Generate texture coordinates to be interpolated at contour vertices.
    n=64L
    auxin = FLTARR(2,n,n)
    coords = (FINDGEN(n)/FLOAT(n-1)) # REPLICATE(1, n)
    auxin[0,*,*] = coords
    auxin[1,*,*] = TRANSPOSE(coords)

    nlevels=5

    ISOCONTOUR, data, outverts, outconn, AUXDATA_IN=auxin, $
        AUXDATA_OUT=auxout, OUTCONN_INDICES=outinds, N_LEVELS=nlevels, /FILL

    oModel = OBJ_NEW('IDLgrModel')

    levmax = nlevels -1
    oContour = MAKE_ARRAY(nlevels,/OBJ)
    for l=0,levmax-1 do begin
        shade = l*(255./(levmax-1))
        ;Set properties for each filled contour level. The
        ;interpolated auxilliary values may be used to control polygon
        ;properties.
        oContour[l] = OBJ_NEW('IDLgrPolygon',outverts, $
                              POLYGONS=outconn[outinds[l*2]:outinds[l*2+1]], $
                              STYLE=2,SHADING=1, $
                              COLOR=[shade, (255-shade)>0, (255-shade)>0], $
                              TEXTURE_MAP=oTexmap[l mod nmaps], $
                              TEXTURE_COORD=auxout)
        oModel->Add, oContour[l]
    end

    xdim = 512
    ydim = 512

    ; Create the view.
    oView = OBJ_NEW('IDLgrView')
    oView->Add, oModel

    ; Scale and translate the Contour object to fit within view bounds.
    GET_BOUNDS, oModel, xr, yr, zr
    xs = NORM_COORD(xr)
    ys = NORM_COORD(yr)
    zs = NORM_COORD(zr)
    oModel->Scale, xs[1], ys[1], zs[1]
    oModel->Translate, xs[0]-0.5, ys[0]-0.5, zs[0]-0.5
    oModel->Rotate, [1,0,0], -70
    oModel->Rotate, [0,1,0], 30
    oModel->Rotate, [1,0,0], 30

    wBase = WIDGET_BASE(TITLE='ISOCONTOUR', /COLUMN, $
                        /TLB_KILL_REQUEST_EVENTS )
    wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, GRAPHICS_LEVEL=2, $
                        RETAIN=1, /BUTTON_EVENTS, /EXPOSE_EVENTS, $
                        UVALUE='DRAW')
    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    oWindow->Draw, oView

    ; Create a trackball.
    oTrack = OBJ_NEW('Trackball', [xdim/2., ydim/2.], xdim/2.)

    ; Save state.
    sState = {btndown: 0b, $
              wDraw: wDraw, $
              oWindow: oWindow, $
              oView: oView, $
              oTopModel: oModel, $
              oTrack: oTrack }

    WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY

    XMANAGER, 'SHOW3_TRACK', wBase, /NO_BLOCK

end


















