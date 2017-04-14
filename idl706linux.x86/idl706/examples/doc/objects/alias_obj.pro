;
; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/alias_obj.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   ALIAS_OBJ
;
; PURPOSE:
;   This procedure serves as an example of using the ALIAS keyword to allow
;   the programmer to add an object to more than one Model object.
;   This procedure demonstrates how space can be saved by referencing
;   a single large object from several views.
;
;
;              Without ALIAS
;
;         view -> model -> graphics atom
;        /
;   scene
;        \
;         view -> model -> graphics atom
;
;
;              With ALIAS
;
;         view -> model
;        /             \
;   scene               graphics atom
;        \             /
;         view -> model
;
;
; CATEGORY:
;   Object graphics.
;
; CALLING SEQUENCE:
;   ALIAS_OBJ, [zData]
;
; OPTIONAL INPUTS:
;   zData: A two-dimensional floating point array representing
;              the data to be displayed as a surface.  By default,
;              the Maroon Bells example data is displayed.
;
; MODIFICATION HISTORY:
;   Written by:  DD, June 1996
;   ALIAS added by : KWS, Oct 1998
;-

;----------------------------------------------------------------------------
FUNCTION Toggle_State, wid

    WIDGET_CONTROL, wid, GET_VALUE=name

    s = STRPOS(name, '(off)')
    IF (s NE -1) THEN BEGIN
        STRPUT, name, '(on) ', s
        ret = 1
    ENDIF ELSE BEGIN
        s = STRPOS(name, '(on) ')
        STRPUT, name, '(off)',s
        ret = 0
    ENDELSE

    WIDGET_CONTROL, wid, SET_VALUE=name
    RETURN, ret
END

;----------------------------------------------------------------------------
PRO ALIAS_OBJ_EVENT, sEvent

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    ; Handle KILL requests.
    IF TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState

        ; Destroy the objects.
        OBJ_DESTROY, sState.oHolder
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    ENDIF

    ; Handle other events.
    CASE uval OF
    'STYLE': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, STYLE=sEvent.index
        CASE sEvent.index OF
            0: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=0
               END
            1: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=0
               END
            2: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=0
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=1
               END
            3: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=0
               END
            4: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=0
               END
            5: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=0
               END
            6: BEGIN
                   WIDGET_CONTROL, sState.wHide, SENSITIVE=0
                   WIDGET_CONTROL, sState.wShading, SENSITIVE=1
               END
        ENDCASE
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'MM_MIN0': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, MIN_VALUE=sState.zMinVals[0]
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'MM_MIN1': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, MIN_VALUE=sState.zMinVals[1]
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'MM_MIN2': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, MIN_VALUE=sState.zMinVals[2]
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'MM_MAX0': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, MAX_VALUE=sState.zMaxVals[0]
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'MM_MAX1': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, MAX_VALUE=sState.zMaxVals[1]
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'MM_MAX2': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, MAX_VALUE=sState.zMaxVals[2]
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SHADE_FLAT': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, SHADING=0
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SHADE_GOURAUD': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, SHADING=1
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'VC_OFF': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        wParent = WIDGET_INFO(sEvent.id, /PARENT)
        j = Toggle_State(wParent)
        sState.oSurface->SetProperty, VERT_COLORS=0
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'VC_ON': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        wParent = WIDGET_INFO(sEvent.id, /PARENT)
        j = Toggle_State(wParent)
        sState.oSurface->SetProperty, VERT_COLORS=sState.vc
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'HIDE_OFF': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        wParent = WIDGET_INFO(sEvent.id, /PARENT)
        j = Toggle_State(wParent)
        sState.oSurface->SetProperty, HIDDEN_LINES=0
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'HIDE_ON': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        wParent = WIDGET_INFO(sEvent.id, /PARENT)
        j = Toggle_State(wParent)
        sState.oSurface->SetProperty, HIDDEN_LINES=1
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SKIRT0': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, SHOW_SKIRT=0
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SKIRT1': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, SKIRT=sState.zSkirts[0], $
                                      /SHOW_SKIRT
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SKIRT2': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, SKIRT=sState.zSkirts[1], $
                                      /SHOW_SKIRT
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SKIRT3': BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.oSurface->SetProperty, SKIRT=sState.zSkirts[2], $
                                      /SHOW_SKIRT
        FOR i=0, sState.nViews-1 DO $
            sState.oWindows[i]->Draw, sState.oViews[i]
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'DRAGQ0' : BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.dragq = 0
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'DRAGQ1' : BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.dragq = 1
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SYNCOFF' : BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.sync = 0
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    'SYNCON' : BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
        sState.sync = 1
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
    ELSE: BEGIN
        IF (uval EQ 'DRAW0' OR uval EQ 'DRAW1' OR $
            uval EQ 'DRAW2' OR uval EQ 'DRAW3') THEN BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            ; Figure out which of the draw widgets caused the event
            CASE uval OF
            'DRAW0': index=0
            'DRAW1': index=1
            'DRAW2': index=2
            'DRAW3': index=3
            ENDCASE
            wDraw = sState.wDraws[index]
            oWindow = sState.oWindows[index]
            oGroup = sState.oGroups[index]
            oTrack = sState.oTracks[index]
            oView = sState.oViews[index]

            ; Expose.
            IF (sEvent.type EQ 4) THEN BEGIN
                oWindow->Draw, oView
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
                RETURN
            ENDIF

            ; Handle trackball updates.
            bHaveTransform = oTrack->Update( sEvent, TRANSFORM=qmat )
            IF (bHaveTransform NE 0) THEN BEGIN
                IF (sState.sync EQ 0) THEN BEGIN
                    oGroup->GetProperty, TRANSFORM=t
                    oGroup->SetProperty, TRANSFORM=t#qmat
                    oWindow->Draw, oView
                ENDIF ELSE BEGIN
                    FOR i=0, sState.nViews-1 DO BEGIN
                        sState.oGroups[i]->GetProperty, TRANSFORM=t
                        sState.oGroups[i]->SetProperty, TRANSFORM=t#qmat
                        sState.oWindows[i]->Draw, sState.oViews[i]
                    ENDFOR
                ENDELSE
            ENDIF

            ; Handle other events: PICKING, quality changes, etc.
            ;  Button press.
            IF (sEvent.type EQ 0) THEN BEGIN
                IF (sEvent.press EQ 4) THEN BEGIN ; Right mouse.
                    pick = oWindow->PickData(oView,$
                        sState.oSurface, [sEvent.x,sEvent.y],dataxyz, $
                            PATH=[oGroup])
                    IF (pick EQ 1) THEN BEGIN
                        str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
                        FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
                        WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
                    ENDIF ELSE BEGIN
                        WIDGET_CONTROL, sState.wLabel, $
                            SET_VALUE="Data point: In background."
                    ENDELSE

                    sState.btndown = 4b
                    WIDGET_CONTROL, wDraw, /DRAW_MOTION
                ENDIF ELSE BEGIN ; other mouse button.
                    sState.btndown = 1b
                    IF (sState.sync EQ 0) THEN BEGIN
                        oWindow->SetProperty, QUALITY=sState.dragq
                        oWindow->Draw, oView
                        WIDGET_CONTROL, wDraw, /DRAW_MOTION
                    ENDIF ELSE BEGIN
                        FOR i=0, sState.nViews-1 DO BEGIN
                            sState.oWindows[i]->SetProperty, $
                                QUALITY=sState.dragq
                            sState.oWindows[i]->Draw, sState.oViews[i]
                        ENDFOR
                        WIDGET_CONTROL, sState.wDraws[0], /DRAW_MOTION
                        WIDGET_CONTROL, sState.wDraws[1], /DRAW_MOTION
                        WIDGET_CONTROL, sState.wDraws[2], /DRAW_MOTION
                        WIDGET_CONTROL, sState.wDraws[3], /DRAW_MOTION
                   ENDELSE
                ENDELSE
            ENDIF

            ; Button motion.
            IF (sEvent.type EQ 2) THEN BEGIN
                IF (sState.btndown EQ 4b) THEN BEGIN ; Right mouse button.
                    pick = oWindow->PickData(oView, $
                        sState.oSurface, [sEvent.x,sEvent.y], dataxyz, $
                            PATH=[oGroup])
                    IF (pick EQ 1) THEN BEGIN
                        str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
                        FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
                    WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
                    ENDIF ELSE BEGIN
                        WIDGET_CONTROL, sState.wLabel, $
                            SET_VALUE="Data point: In background."
                    ENDELSE
                ENDIF
            ENDIF

            ; Button release.
            IF (sEvent.type EQ 1) THEN BEGIN
                IF (sState.btndown EQ 1b) THEN BEGIN
                    IF (sState.sync EQ 0) THEN BEGIN
                        oWindow->SetProperty, QUALITY=2
                        oWindow->Draw, oView
                    ENDIF ELSE BEGIN
                        FOR i=0, sState.nViews-1 DO BEGIN
                            sState.oWindows[i]->SetProperty, QUALITY=2
                            sState.oWindows[i]->Draw, sState.oViews[i]
                        ENDFOR
                    ENDELSE
                ENDIF
                sState.btndown = 0b
                WIDGET_CONTROL, sState.wDraws[0], DRAW_MOTION=0
                WIDGET_CONTROL, sState.wDraws[1], DRAW_MOTION=0
                WIDGET_CONTROL, sState.wDraws[2], DRAW_MOTION=0
                WIDGET_CONTROL, sState.wDraws[3], DRAW_MOTION=0
            ENDIF
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
            END
        END
    ENDCASE
END

;----------------------------------------------------------------------------
PRO ALIAS_OBJ, zData

    xdim = 640
    ydim = 480

    nViews = 4

    ; Default surface data is the Maroon Bells sample data
    IF (N_ELEMENTS(zData) EQ 0) THEN BEGIN
        RESTORE, filepath('marbells.dat', $
            subdir=['examples','data'])
        image = bytscl(elev, min=2658, max=4241)
        image = image[10:*,*] ; remove bad data
        zData = CONGRID(image, 80, 80, /INTERP) ; cut it down to size
    ENDIF


    ; Compute potential skirt values.
    zMax = MAX(zData, MIN=zMin)
    zQuart = (zMax - zMin) * 0.25
    zSkirts = [zMin-zQuart, zMin, zMin+zQuart]

    ; Create the widgets.
    wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
                        TITLE="Aliased Objects Example", $
                        /TLB_KILL_REQUEST_EVENTS)
    wDrawBase = WIDGET_BASE(wBase, ROW=2)
    wDraws = LONARR(4)
    wDraws[0] = WIDGET_DRAW(wDrawBase, XSIZE=xdim/2, YSIZE=ydim/2, $
                         UVALUE='DRAW0', $
                         RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                         GRAPHICS_LEVEL=2)
    wDraws[1] = WIDGET_DRAW(wDrawBase, XSIZE=xdim/2, YSIZE=ydim/2, $
                         UVALUE='DRAW1', $
                         RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                         GRAPHICS_LEVEL=2)
    wDraws[2] = WIDGET_DRAW(wDrawBase, XSIZE=xdim/2, YSIZE=ydim/2, $
                         UVALUE='DRAW2', $
                         RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                         GRAPHICS_LEVEL=2)
    wDraws[3] = WIDGET_DRAW(wDrawBase, XSIZE=xdim/2, YSIZE=ydim/2, $
                         UVALUE='DRAW3', $
                         RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                         GRAPHICS_LEVEL=2)
    wGuiBase = WIDGET_BASE(wBase, /ROW, /ALIGN_CENTER)
    wStyleDrop = WIDGET_DROPLIST(wGuiBase, VALUE=['Point','Wire','Solid',$
                                 'Ruled XZ','Ruled YZ','Lego Wire', $
                                 'Lego Solid'], /FRAME, $
                                 TITLE='Style', UVALUE='STYLE')

    wOptions = WIDGET_BUTTON(wGuiBase, MENU=2, VALUE="Additional Options...")

    wDrag = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Drag Quality")
    wButton = WIDGET_BUTTON(wDrag, VALUE='Low', UVALUE='DRAGQ0')
    wButton = WIDGET_BUTTON(wDrag, VALUE='Medium', UVALUE='DRAGQ1')

    wHide = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Hidden Lines (off)")
    wButton = WIDGET_BUTTON(wHide, VALUE='Off', UVALUE='HIDE_OFF')
    wButton = WIDGET_BUTTON(wHide, VALUE='On', UVALUE='HIDE_ON')

    wMinMax = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Minimum")
    zMinVals = [zMin, zMin+zQuart, zMin+2*zQuart]
    zLabels = ['Reset', STRCOMPRESS(STRING(zMinVals[1:2]), /REMOVE_ALL)]
    wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[0], UVALUE='MM_MIN0')
    wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[1], UVALUE='MM_MIN1')
    wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[2], UVALUE='MM_MIN2')
    wMinMax = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Maximum")
    zMaxVals = [zMax, zMax-zQuart, zMax-2*zQuart]
    zLabels = ['Reset', STRCOMPRESS(STRING(zMaxVals[1:2]), /REMOVE_ALL)]
    wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[0], UVALUE='MM_MAX0')
    wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[1], UVALUE='MM_MAX1')
    wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[2], UVALUE='MM_MAX2')

    wShading = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Shading")
    wButton = WIDGET_BUTTON(wShading, VALUE='Flat', UVALUE='SHADE_FLAT')
    wButton = WIDGET_BUTTON(wShading, VALUE='Gouraud', UVALUE='SHADE_GOURAUD')

    wVC = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Vertex Colors (off)")
    wButton = WIDGET_BUTTON(wVC, VALUE='Off', UVALUE='VC_OFF')
    wButton = WIDGET_BUTTON(wVC, VALUE='On', UVALUE='VC_ON')

    zLabels = ['None', STRCOMPRESS(STRING(zSkirts[*]), /REMOVE_ALL)]
    wSkirt = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Skirt")
    wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[0], UVALUE='SKIRT0')
    wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[1], UVALUE='SKIRT1')
    wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[2], UVALUE='SKIRT2')
    wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[3], UVALUE='SKIRT3')

    wSync = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Synchronize Views")
    wButton = WIDGET_BUTTON(wSync, VALUE='Off', UVALUE='SYNCOFF')
    wButton = WIDGET_BUTTON(wSync, VALUE='On', UVALUE='SYNCON')

    ; Status line.
    wGuiBase2 = WIDGET_BASE(wBase, /COLUMN, /ALIGN_CENTER)
    wLabel = WIDGET_LABEL(wGuiBase2, /FRAME, $
        VALUE="Left Mouse: Trackball    Right Mouse: Data Picking" )
    wLabel = WIDGET_LABEL(wGuiBase2, VALUE=" ", /DYNAMIC_RESIZE)

    WIDGET_CONTROL, wBase, /REALIZE

    ; Get the window ids of the drawables.
    ; These window objects are freed when the widgets die.
    oWindows = OBJARR(nViews)
    WIDGET_CONTROL, wDraws[0], GET_VALUE=oTmp
    oWindows[0] = oTmp
    WIDGET_CONTROL, wDraws[1], GET_VALUE=oTmp
    oWindows[1] = oTmp
    WIDGET_CONTROL, wDraws[2], GET_VALUE=oTmp
    oWindows[2] = oTmp
    WIDGET_CONTROL, wDraws[3], GET_VALUE=oTmp
    oWindows[3] = oTmp

    ; Set default droplist items.
    WIDGET_CONTROL, wStyleDrop, SET_DROPLIST_SELECT=2
    WIDGET_CONTROL, wHide, SENSITIVE=0

    ; Compute viewplane rect based on aspect ratio.
    aspect = FLOAT(xdim) / FLOAT(ydim)
    sqrt2 = SQRT(2.0)
    myview = [ -sqrt2*0.5, -sqrt2*0.5, sqrt2, sqrt2 ]
    IF (aspect GT 1) THEN BEGIN
        myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
        myview[2] = myview[2] * aspect
    ENDIF ELSE BEGIN
        myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
        myview[3] = myview[3] / aspect
    ENDELSE

    ; Create views.
    oViews = OBJARR(nViews);
    oViews[0] = OBJ_NEW('IDLgrView', PROJECTION=1, $
                    VIEWPLANE_RECT=myview, COLOR=[40,40,40])
    oViews[1] = OBJ_NEW('IDLgrView', PROJECTION=1, $
                    VIEWPLANE_RECT=myview, COLOR=[40,40,40])
    oViews[2] = OBJ_NEW('IDLgrView', PROJECTION=1, $
                    VIEWPLANE_RECT=myview, COLOR=[40,40,40])
    oViews[3] = OBJ_NEW('IDLgrView', PROJECTION=2, $
                    EYE=1.8, ZCLIP=[1.4,-1.4],$
                    VIEWPLANE_RECT=myview, COLOR=[40,40,40])
    ; Create models.
    ; View -> Top -> Group -> Surface
    ; Lights are applied to Top.
    ; Rotations are applied to Group.
    oTops = OBJARR(nViews)
    oGroups = OBJARR(nViews)
    FOR i=0, nViews-1 DO BEGIN
        oTops[i] = OBJ_NEW('IDLgrModel')
        oGroups[i] = OBJ_NEW('IDLgrModel')
        oTops[i]->Add, oGroups[i]
    ENDFOR

    ; Compute data bounds.
    sz = SIZE(zData)
    xMax = sz[1] - 1
    yMax = sz[2] - 1
    zMin2 = zMin - 1
    zMax2 = zMax + 1

    ; Compute coordinate conversion to normalize.
    xs = [-0.5,1.0/xMax]
    ys = [-0.5,1.0/yMax]
    zs = [(-zMin2/(zMax2-zMin2))-0.5, 1.0/(zMax2-zMin2)]

    ; Generate vertex colors to emulate height fields.
    vc = BYTARR(3,sz[1]*sz[2], /NOZERO)
    cbins=[[255,0,0],$
           [255,85,0],$
           [255,170,0],$
           [255,255,0],$
           [170,255,0],$
           [85,255,0],$
           [0,255,0]]
    zi = ROUND((zData - zMin)/(zMax-zMin) * 6.0)
    vc[*,*] = cbins[*,zi]

    ; Create the surface.  Note: Only one!
    oSurface = OBJ_NEW('IDLgrSurface', zData, STYLE=2, SHADING=0, $
                       COLOR=[60,60,255], BOTTOM=[64,192,128], $
                       XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)

    ; Use ALIAS to place the surface in 4 models.
    FOR i=0, nViews-1 DO $
        oGroups[i]->Add, oSurface, /ALIAS

    ; Create some lights.
    ; Use ALIAS again to share the light objects.
    oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=1)
    FOR i=0, nViews-1 DO $
        oTops[i]->Add, oLight, /ALIAS
    oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
    FOR i=0, nViews-1 DO $
        oTops[i]->Add, oLight, /ALIAS

    ; Place the models in the views.
    FOR i=0, nViews-1 DO $
        oViews[i]->Add, oTops[i]

    ; Label each view.
    oText = OBJ_NEW('IDLgrText', 'Rotate about Y', /ONGLASS, $
       COLOR=[255,255,255], LOCATIONS=[[-0.9, -0.6, -0.0]])
    oTops[0]->Add, oText
    oText = OBJ_NEW('IDLgrText', 'Rotate about Z', /ONGLASS, $
       COLOR=[255,255,255], LOCATIONS=[[-0.9, -0.6, -0.0]])
    oTops[1]->Add, oText
    oText = OBJ_NEW('IDLgrText', 'Rotate about X', /ONGLASS, $
       COLOR=[255,255,255], LOCATIONS=[[-0.9, -0.6, -0.0]])
    oTops[2]->Add, oText
    oText = OBJ_NEW('IDLgrText', 'Perspective', /ONGLASS, $
       COLOR=[255,255,255], LOCATIONS=[[-0.9, -0.6, -0.0]])
    oTops[3]->Add, oText

    ; Rotate to standard view for initial display.

    FOR i=0, nViews-1 DO BEGIN
        oGroups[i]->Rotate, [1,0,0], -90
        oGroups[i]->Rotate, [0,1,0], 30
        oGroups[i]->Rotate, [1,0,0], 30
    ENDFOR

    ; Create 4 trackballs with different constraints.
    oTracks = OBJARR(4)
    oTracks[0] = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2., $
        /CONSTRAIN, AXIS=1)
    oTracks[1] = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2., $
        /CONSTRAIN, AXIS=2)
    oTracks[2] = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2., $
        /CONSTRAIN, AXIS=0)
    oTracks[3] = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2.)

    ; Create a holder object for easy destruction.
    ; Destroying a View also destroys everything inside of it.
    ; But objects created with ALIAS are not destroyed this way.
    oHolder = OBJ_NEW('IDL_Container')
    oHolder->Add, oViews
    oHolder->Add, oTracks
    oHolder->Add, oSurface

    ; Save state.
    sState = {btndown:  0b,        $
              dragq:    0,         $
              nViews:   nViews,    $
              oGroups:  oGroups,   $
              oHolder:  oHolder,   $
              oSurface: oSurface,  $
              oTracks:  oTracks,   $
              oViews:   oViews,    $
              oWindows: oWindows,  $
              sync:     0,         $
              vc:       vc,        $
              wDraws:   wDraws,    $
              wHide:    wHide,     $
              wLabel:   wLabel,    $
              wShading: wShading,  $
              zMaxVals: zMaxVals,  $
              zMinVals: zMinVals,  $
              zSkirts:  zSkirts    $
             }

    WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY

    XMANAGER, 'ALIAS_OBJ', wBase, /NO_BLOCK

END
