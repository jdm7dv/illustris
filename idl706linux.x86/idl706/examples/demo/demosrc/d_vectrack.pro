;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_vectrack.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_vectrack.pro
;
;  CALLING SEQUENCE: d_vectrack
;
;  PURPOSE:
;       Visualization of thunderstorm data.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_vectrackEvent      -  Event handler
;       pro d_vectrackCleanup    -  Cleanup
;       pro d_vectrack           -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro trackball__define   -  Create the trackball object
;       pro demo_gettips        - Read the tip file and create widgets
;       vectrack.tip
;       storm25.sav
;       storm25b.sav
;       storm.opa
;       storm.pal
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       1/97,   ACY   - adapted from vec_track, written by D.D.
;       7/99,   KB    - used PARTICLE_TRACE and STREAMLINE.
;-
;----------------------------------------------------------------------------


;----------------------------------------------------------------------------

PRO d_vectrackMkVectors, u, v, w, fVerts, iConn, X=x, Y=y, Z=z, SCALE=scale,$
               RANDOM=random, NVECTORS=nvectors, STEPSIZE=stepsize,$
               bMAG=bMag, VC=vc

    ; Ensure volumes match in number of elements.
    nSamples = N_ELEMENTS(u)
    IF (nSamples NE N_ELEMENTS(v) OR nSamples NE N_ELEMENTS(w)) THEN BEGIN
        MESSAGE,'Number of elements in u, v, and w must match.'
        RETURN
    ENDIF
    sz = SIZE(u)

    ; Handle keywords, set defaults.
    IF (N_ELEMENTS(scale) EQ 0) THEN scale = 1.0
    IF (N_ELEMENTS(random) EQ 0) THEN random=0
    IF (N_ELEMENTS(nvectors) EQ 0) THEN nvectors = 100
    IF (N_ELEMENTS(stepsize) eq 0) then stepsize = 1
    IF (N_ELEMENTS(bMag) EQ 0) THEN bMag = BYTSCL(SQRT(u^2+v^2+w^2))

    ; Get plane information.
    doPlane = 0
    IF (N_ELEMENTS(x) GT 0) THEN BEGIN
        IF (random EQ 0) THEN BEGIN
            nRow = sz[2] / stepsize
            nCol = sz[3] / stepsize
        ENDIF
        doPlane = 1
    ENDIF
    IF (N_ELEMENTS(y) GT 0) THEN BEGIN
        IF (doPlane) THEN MESSAGE,'X, Y, and Z keywords are mutually exclusive'
        IF (random EQ 0) THEN BEGIN
            nRow = sz[3] / stepsize
            nCol = sz[1] / stepsize
        ENDIF
        doPlane = 2
    ENDIF
    IF (N_ELEMENTS(z) GT 0) THEN BEGIN
        IF (doPlane) THEN MESSAGE,'X, Y, and Z keywords are mutually exclusive'
        IF (random EQ 0) THEN BEGIN
            nRow = sz[2] / stepsize
            nCol = sz[1] / stepsize
        ENDIF
        doPlane = 3
    ENDIF
    IF (doPlane EQ 0) THEN MESSAGE, 'Must specify a plane.'

    ; Grab max, min values in vector volumes.
    maxU = MAX(u, MIN=minU)
    maxV = MAX(v, MIN=minV)
    maxW = MAX(w, MIN=minW)

    ; Compute the magnitude.
    mag = SQRT((maxU-minU)^2 + (maxV-minV)^2 + (maxW-minW)^2)
    fNorm = scale / mag

    ; Compute radomly spaced vectors.
    IF (random) THEN BEGIN
        fVerts = FLTARR(3, 2*nvectors)
        iConn = LONARR(3*nvectors)
        vc = BYTARR(2*nvectors)

        CASE doPlane OF
            1: BEGIN   ; X=x
                randomX = REPLICATE(x, nvectors)
                seed = x
                randomY = RANDOMU(seed, nvectors) * (sz[2]-1)
                randomZ = RANDOMU(seed, nvectors) * (sz[3]-1)
               END
            2: BEGIN   ; Y=y
                seed = y
                randomX = RANDOMU(seed, nvectors) * (sz[1]-1)
                randomY = REPLICATE(y, nvectors)
                randomZ = RANDOMU(seed, nvectors) * (sz[3]-1)
               END
            3: BEGIN   ; Z=z
                seed = z
                randomX = RANDOMU(seed, nvectors) * (sz[1]-1)
                randomY = RANDOMU(seed, nvectors) * (sz[2]-1)
                randomZ = REPLICATE(z, nvectors)
               END
        ENDCASE

        inds = LINDGEN(nvectors)
        x0 = randomx[inds]
        y0 = randomy[inds]
        z0 = randomz[inds]

        v0 = transpose([[x0],[y0],[z0]])
        v1 = transpose([[x0+u[x0,y0,z0]*fNorm],$
                [y0+v[x0,y0,z0]*fNorm],$
                [z0+w[x0,y0,z0]*fNorm]])
        fVerts[*,inds*2] = v0[*,inds]
        fVerts[*,inds*2+1] = v1[*,inds]
        iConn[inds*3] = 2
        iConn[inds*3+1] = inds*2
        iConn[inds*3+2] = inds*2+1

        vc[inds*2] = bMag[x0,y0,z0]
        vc[inds*2+1] = bMag[x0,y0,z0]

    ; Compute evenly sampled vectors.
    ENDIF ELSE BEGIN
        nV = nRow*nCol

        fVerts = FLTARR(3, 2*nV)
        iConn = LONARR(3*nV)
        vc = BYTARR(2*nV)

        CASE doPlane OF
            1: BEGIN   ; X=x
                x0 = REPLICATE(x,nV)
                y0 = REFORM((REPLICATE(1,nCol) # (LINDGEN(nRow)*stepsize)),nV)
                z0 = REFORM(((LINDGEN(nCol)*stepsize) # REPLICATE(1,nRow)),nV)
               END
            2: BEGIN   ; Y=y
                y0 = REPLICATE(y,nRow*nCol)
                z0 = REFORM((REPLICATE(1,nCol) # (LINDGEN(nRow)*stepsize)),nV)
                x0 = REFORM(((LINDGEN(nCol)*stepsize) # REPLICATE(1,nRow)),nV)
               END
            3: BEGIN   ; Z=z
                z0 = REPLICATE(z,nRow*nCol)
                y0 = REFORM((REPLICATE(1,nCol) # (LINDGEN(nRow)*stepsize)),nV)
                x0 = REFORM(((LINDGEN(nCol)*stepsize) # REPLICATE(1,nRow)),nV)
               END
        ENDCASE

        inds = LINDGEN(nV)
        v0 = transpose([[x0],[y0],[z0]])
        v1 = transpose([[x0+u[x0,y0,z0]*fNorm],$
                [y0+v[x0,y0,z0]*fNorm],$
                [z0+w[x0,y0,z0]*fNorm]])
        fVerts[*,inds*2] = v0[*,inds]
        fVerts[*,inds*2+1] = v1[*,inds]
        iConn[inds*3] = 2
        iConn[inds*3+1] = inds*2
        iConn[inds*3+2] = inds*2+1

        vc[inds*2] = bMag[x0,y0,z0]
        vc[inds*2+1] = bMag[x0,y0,z0]
    ENDELSE

END

;----------------------------------------------------------------------------
; Integrate V to get S
; Stream Ribbons
PRO d_vectrackRibbonTrace,vdata,start,auxdata,STEPS=steps,FRAC=frac, $
                          WIDTH=width, UP=up,COLOR=color,  $
                          OUTVERTS = outverts, OUTCONN = outconn,  $
                          VERT_COLORS = vertcolors

    if (N_ELEMENTS(steps) eq 0) then steps = 100
    if (N_ELEMENTS(frac) eq 0) then frac = 1.0
    if (N_ELEMENTS(up) eq 0) then up = [0.0,0.0,1.0]
    if (N_ELEMENTS(width) eq 0) then width = .5

    PARTICLE_TRACE,vdata,start,overts,oconn,onormals, $
        MAX_ITERATIONS=steps, MAX_STEPSIZE=frac,INTEGRATION=0 $
        ,ANISOTROPY=[1,1,1], SEED_NORMALS=up

    if((N_ELEMENTS(oconn) gt 0) and (SIZE(overts, /N_DIMENSIONS) eq 2))  $
        then begin
        STREAMLINE,overts,oconn,onormals*width,outverts,outconn
        cdata = INTERPOLATE(auxdata,outverts[0,*],outverts[1,*],outverts[2,*])
        cdata = REFORM(cdata,N_ELEMENTS(outverts)/3)
        vertcolors = BYTSCL(cdata)
    end
END


;----------------------------------------------------------------------------
; Integrate V to get S
; Streamlines
PRO d_vectrackStreamlineTrace,vdata,start,auxdata,STEPS=steps,FRAC=frac, $
                              OUTVERTS = outverts, OUTCONN = outconn,  $
                              VERT_COLORS = vertcolors

    if (N_ELEMENTS(steps) eq 0) then steps = 100
    if (N_ELEMENTS(frac) eq 0) then frac = 1.0

    PARTICLE_TRACE,vdata,start,outverts,outconn, $
        MAX_ITERATIONS=steps, MAX_STEPSIZE=frac,INTEGRATION=0 $
        ,ANISOTROPY=[1,1,1]

    if((N_ELEMENTS(outconn) gt 0) and (SIZE(outverts, /N_DIMENSIONS) eq 2)) $
        then begin
        cdata = INTERPOLATE(auxdata,outverts[0,*],outverts[1,*],outverts[2,*])
        cdata = REFORM(cdata,N_ELEMENTS(outverts)/3)
        vertcolors = BYTSCL(cdata)
    end
END



;----------------------------------------------------------------------------
; Routine to update the current isosurface

PRO d_vectrackIsoSurfUpdate,sState,bUpdate
    IF (sState.bIsoShow AND ((bUpdate EQ 5) OR (bUpdate EQ 4))) THEN BEGIN
            sState.oVols[sState.iIsoVol]->GetProperty,DATA0=vdata,$
            /NO_COPY
        SHADE_VOLUME,vdata,sState.fIsoLevel,fVerts,iConn
        IF (N_ELEMENTS(fVerts) LE 0) THEN BEGIN
            fVerts=[0,0,0]
            iConn=0
        END
        sState.oIsoPolygon->SetProperty,DATA=fVerts,POLYGONS=iConn
            sState.oVols[sState.iIsoVol]->SetProperty,DATA0=vdata,$
            /NO_COPY
    ENDIF
END


;----------------------------------------------------------------------------
; Routine to update the current planes

PRO d_vectrackPlanesUpdate,sState,bUpdate

    WIDGET_CONTROL, sState.wEvenField, GET_VALUE=stepsize
    WIDGET_CONTROL, sState.wRandomField, GET_VALUE=nvectors
    WIDGET_CONTROL, sState.wScaleField, GET_VALUE=scale

    IF (sState.bShow[0] AND ((bUpdate EQ 1) OR (bUpdate EQ 4))) THEN BEGIN
            WIDGET_CONTROL, sState.wXSlider, GET_VALUE=x
        IF (sState.bImage[0]) THEN BEGIN
            sState.oVols[sState.iImgVol]->GetProperty,DATA0=vdata,$
            /NO_COPY,RGB_TABLE0=ctab
            d_vectrackSampleOrthoPlane,vdata,0,x,sState.oSlices[0], $
            sState.oImages[0],ctab,sState.iAlpha
            sState.oVols[sState.iImgVol]->SetProperty,DATA0=vdata,$
            /NO_COPY
        END ELSE BEGIN
                    sState.oVols[2]->GetProperty,DATA0=bMag,RGB_TABLE0=pal,$
                                                 /NO_COPY
                d_vectrackMkVectors,sState.u,sState.v,sState.w, $
                        fVerts,iConn,X=x, $
                SCALE=scale, RANDOM=sState.bRandom, NVECTORS=nvectors,$
                STEPSIZE=stepsize,BMAG=bMag,Vc=vc
                sState.oXPolyline->SetProperty,DATA=fVerts,$
                                       POLYLINES=iConn, $
                                       VERT_COLORS=transpose(pal[vc,*])
                    sState.oVols[2]->SetProperty,DATA0=bMag,/NO_COPY
        END
        ENDIF
    IF (sState.bShow[1] AND ((bUpdate EQ 2) OR (bUpdate EQ 4))) THEN BEGIN
            WIDGET_CONTROL, sState.wYSlider, GET_VALUE=y
        IF (sState.bImage[1]) THEN BEGIN
            sState.oVols[sState.iImgVol]->GetProperty,DATA0=vdata,$
            /NO_COPY,RGB_TABLE0=ctab
            d_vectrackSampleOrthoPlane,vdata,1,y,sState.oSlices[1], $
            sState.oImages[1],ctab,sState.iAlpha
            sState.oVols[sState.iImgVol]->SetProperty,DATA0=vdata,$
            /NO_COPY
        END ELSE BEGIN
                    sState.oVols[2]->GetProperty,DATA0=bMag,RGB_TABLE0=pal,$
                                                 /NO_COPY
                d_vectrackMkVectors,sState.u,sState.v,sState.w, $
                        fVerts,iConn,Y=y, $
                SCALE=scale, RANDOM=sState.bRandom, NVECTORS=nvectors,$
                STEPSIZE=stepsize,BMAG=bMag,Vc=vc
                sState.oYPolyline->SetProperty,DATA=fVerts,$
                                       POLYLINES=iConn, $
                                       VERT_COLORS=transpose(pal[vc,*])
                sState.oVols[2]->SetProperty,DATA0=bMag,/NO_COPY
        END
        ENDIF
    IF (sState.bShow[2] AND ((bUpdate EQ 3) OR (bUpdate EQ 4))) THEN BEGIN
            WIDGET_CONTROL, sState.wZSlider, GET_VALUE=z
        IF (sState.bImage[2]) THEN BEGIN
            sState.oVols[sState.iImgVol]->GetProperty,DATA0=vdata,$
            /NO_COPY,RGB_TABLE0=ctab
            d_vectrackSampleOrthoPlane,vdata,2,z,sState.oSlices[2], $
            sState.oImages[2],ctab,sState.iAlpha
            sState.oVols[sState.iImgVol]->SetProperty,DATA0=vdata,$
            /NO_COPY
        END ELSE BEGIN
                    sState.oVols[2]->GetProperty,DATA0=bMag,RGB_TABLE0=pal,$
                                                 /NO_COPY
                d_vectrackMkVectors,sState.u,sState.v,sState.w, $
                        fVerts,iConn,Z=z, $
                SCALE=scale, RANDOM=sState.bRandom, NVECTORS=nvectors,$
                STEPSIZE=stepsize,BMAG=bMag,Vc=vc
                sState.oZPolyline->SetProperty,DATA=fVerts,$
                                       POLYLINES=iConn, $
                                       VERT_COLORS=transpose(pal[vc,*])
                sState.oVols[2]->SetProperty,DATA0=bMag,/NO_COPY
        END
        ENDIF
END

;----------------------------------------------------------------------------
; Routine to change the current data (timesteps)

FUNCTION d_vectrackChangeData,sState,iTimeStep

; Can we do anything?
    IF (PTR_VALID(sState.pSteps)) THEN BEGIN

; Is there anything to do?
        IF (iTimeStep GE sState.nSteps) THEN RETURN,0
        IF (iTimeStep EQ sState.curStep) THEN RETURN,0

; Update UVW
        sState.u = *((*sState.pSteps).fU[iTimeStep])
        sState.v = *((*sState.pSteps).fV[iTimeStep])
        sState.w = *((*sState.pSteps).fW[iTimeStep])

; Update volume data
        sState.oVols[0]->SetProperty,$
            DATA0=*((*sState.pSteps).bP[iTimeStep])
        sState.oVols[1]->SetProperty,$
            DATA0=*((*sState.pSteps).bT[iTimeStep])
        sState.oVols[2]->SetProperty,$
            DATA0=*((*sState.pSteps).bM[iTimeStep])
        ;sState.oVols[3]->SetProperty,$
        ;   DATA0=*((*sState.pSteps).bQV[iTimeStep])
        ;sState.oVols[4]->SetProperty,$
        ;   DATA0=*((*sState.pSteps).bQC[iTimeStep])
        ;sState.oVols[5]->SetProperty,$
        ;   DATA0=*((*sState.pSteps).bQR[iTimeStep])

; And the current timestep
        sState.curStep = iTimeStep

; recompute streamlines
        oList = sState.oStreamModel->Get(/ALL)
        sz=size(oList)
        IF (sz[2] EQ 11) THEN BEGIN
            FOR i=0,N_ELEMENTS(oList)-1 DO BEGIN
                oList[i]->GetProperty,UVALUE=xyz
                d_vectrackBuildRibbon,sState,oLIst[i],xyz
            END
        END

; recompute the iso-surface and planes
        d_vectrackIsoSurfUpdate,sState,5
        d_vectrackPlanesUpdate,sState,4

        RETURN,1
    END

    RETURN,0
END

;----------------------------------------------------------------------------
; Routine to generate a movie

PRO d_vectrackRenderMovie,sState

    filename = DIALOG_PICKFILE(/READ, FILTER = '*.scr', /MUST_EXIST)
    IF (filename EQ '') THEN RETURN

    OPENR, lun, filename, ERROR = err, /GET_LUN
    IF (err NE 0) THEN BEGIN
        MESSAGE,"Unable to open input file:"+filename,/CONTINUE
        RETURN
    ENDIF

; Read the file
    ON_IOERROR, end_of_file

    sState.oGroup->GetProperty, TRANSFORM=intrans
    vol_rend = 0
    file_num = 0
    tstr = ''
    base_name = 'image_'
    farg = fltarr(4)
    iarg = intarr(4)
    WHILE (1) DO BEGIN
    READF,lun,tstr
    PRINT,'>',tstr
    str = STRTOK(tstr, ',', /EXTRACT)
    CASE STRUPCASE(str[0]) OF
        'BASENAME': BEGIN      ;[name] - set the filename base
                IF (N_ELEMENTS(str) EQ 2) THEN BEGIN
                    base_name = str[1]
                END
             END
        'ROTATE': BEGIN      ;[dx,dy,dz,ang] - rotate the scene
                IF (N_ELEMENTS(str) EQ 5) THEN BEGIN
                    farg[0] = str[1]
                    farg[1] = str[2]
                    farg[2] = str[3]
                    farg[3] = str[4]
                        sState.oGroup->Rotate,farg[0:2],farg[3]
                END
            END
        'SAVE': BEGIN        ; render and save an image
            sState.oVols[sState.iVrendVol]->SetProperty, $
                HIDE=1-vol_rend
            demo_draw, sState.oWindow, sState.oView, debug=sState.debug
            sState.oVols[sState.iVrendVol]->SetProperty,HIDE=1
            oImage = sState.oWindow->Read()
            oImage->GetProperty,DATA=data
            OBJ_DESTROY,oImage
            file_num = file_num + 1
            outname=base_name+STRING(file_num,FORMAT='(I4.4)')
            OPENW, outlun, outname, /GET_LUN
            WRITEU, outlun, data
                CLOSE, outlun
            FREE_LUN, outlun
            sz = SIZE(data)
            PRINT,"Saved:",outname,sz[1],sz[2],sz[3]
            END
        'TIMESTEP': BEGIN    ;[num]  select time step
                IF (N_ELEMENTS(str) EQ 2) THEN BEGIN
                   iarg[0] = str[1]
                   status=d_vectrackChangeData(sState,iarg[0])
                END
            END
        'VOLUME': BEGIN      ;[0/1]  off/on
                IF (N_ELEMENTS(str) EQ 2) THEN BEGIN
                    iarg[0] = str[1]
                    IF (iarg[0] NE 0) THEN BEGIN
                        vol_rend = 1
                    END ELSE BEGIN
                        vol_rend = 0
                    END
                END
            END
;       'SLICEPOS': BEGIN    ;[axis,pos]  axis-1,2,3,pos
;               IF (N_ELEMENTS(str) EQ 3) THEN BEGIN
;                   iarg[0] = str[1]
;                   iarg[1] = str[2]
;               END
;           END
    ELSE:   BEGIN
            PRINT,'Unknown command:',tstr
        END
    END
    END

end_of_file: ON_IOERROR, NULL

    CLOSE, lun
    FREE_LUN, lun

    sState.oGroup->SetProperty, TRANSFORM=intrans

END

;----------------------------------------------------------------------------
; Routine to update the colorbar display to match the current vrend selection

PRO d_vectrackColorBarUpdate,sState

    oList = sState.oCBTop->Get(/ALL)

; New data space
    fMin = (0.0-sState.fScales[1,sState.iVrendVol])/ $
                sState.fScales[0,sState.iVrendVol]
    fMax = (256.0-sState.fScales[1,sState.iVrendVol])/ $
                sState.fScales[0,sState.iVrendVol]
    sState.oCBTop->SetProperty,TRANSFORM=IDENTITY(4)
    dx = fMax-fMin
    sState.oCBTop->Translate,-(fMax+fMin)*0.5,0.0,0.0
    sState.oCBTop->Scale,1.0/dx,1.0/260.0,1.0
    sState.oCBTop->Translate,0.0,-0.725,0.0

; The Image is (0)
    sState.oVols[sState.iVrendVol]->GetProperty,RGB_TABLE0=pal
    pal = TRANSPOSE(pal)
    rgb = REFORM(pal[*,INDGEN(256*16) MOD 256],3,256,16)
    oList[0]->SetProperty,DATA=rgb,DIMENSIONS=[dx,16],LOCATION=[fMin,0.]

; The Axis is (1)
    CASE sState.iVrendVol OF
        0 : sTitle = 'Pressure Perturbation (millibars)'
        1 : sTitle = 'Temperature Perturbation (degrees K)'
        2 : sTitle = 'Wind Velocity (m/s)'
        3 : sTitle = 'Mixing Ratio (g water/g air)'
        4 : sTitle = 'Cloud Water (g water/g air)'
        5 : sTitle = 'Rain Water (g water/g air)'
    ELSE: sTitle = ' '
    END

    oList[1]->GetProperty,TICKTEXT=oText,TITLE=oTitle
    oText->SetProperty,CHAR_DIMENSIONS=[0,0]
    oTitle->SetProperty,CHAR_DIMENSIONS=[0,0],STRING=sTitle
    oList[1]->SetProperty,RANGE=[fMin,fMax]

END

;----------------------------------------------------------------------------
; Routine to read and setup the volume object palettes

PRO d_vectrackReadVoxelPalettes,vobj

    vColors = BYTARR(256,3,/NOZERO)
    vOpac = BYTARR(256,/NOZERO)

    OPENR, lun, /GET_LUN, $
       demo_filepath('storm.pal', SUBDIR=['examples','demo','demodata'])
    READU, lun,  vColors
    CLOSE, lun
    FREE_LUN, lun

    OPENR, lun, /GET_LUN, $
       demo_filepath('storm.opa', SUBDIR=['examples','demo','demodata'])
    READU, lun,  vOpac
    CLOSE, lun
    FREE_LUN, lun

    FOR i=0,255 DO IF (vOpac[i] GT 128.0) THEN vOpac[i] = 128.0

    vobj->SetProperty,RGB_TABLE0=vColors,OPACITY_TABLE0=vOpac

END

;----------------------------------------------------------------------------
; Routine to update texture mapped image display of slices

PRO d_vectrackSampleOrthoPlane,data,axis,slice,oPoly,oImage,ctab,alpha

    sz=size(data)-1
    CASE axis OF
        0: BEGIN
            img = data[slice,*,*]
            img = REFORM(img,sz[2]+1,sz[3]+1,/OVERWRITE)
                fTxCoords = [[0,0],[1,0],[1,1],[0,1]]
            verts=[[slice,0,0],[slice,sz[2],0], $
                   [slice,sz[2],sz[3]],[slice,0,sz[3]]]
           END
        1: BEGIN
            img = data[*,slice,*]
            img = REFORM(img,sz[1]+1,sz[3]+1,/OVERWRITE)
                fTxCoords = [[0,0],[1,0],[1,1],[0,1]]
            verts=[[0,slice,0],[sz[1],slice,0], $
                   [sz[1],slice,sz[3]],[0,slice,sz[3]]]
           END
        2: BEGIN
            img = data[*,*,slice]
            img = REFORM(img,sz[1]+1,sz[2]+1,/OVERWRITE)
                fTxCoords = [[0,0],[1,0],[1,1],[0,1]]
            verts=[[0,0,slice],[sz[1],0,slice], $
                   [sz[1],sz[2],slice],[0,sz[2],slice]]
           END
    END

; Convert to 3xNxM or 4xNxM
    sz=size(img)
    IF ((alpha[0] EQ 0) AND (alpha[1] EQ 255)) THEN BEGIN
        rgbtab=TRANSPOSE(ctab)
        rgb=rgbtab[*,img]
        rgb=REFORM(rgb,3,sz[1],sz[2],/OVERWRITE)
    END ELSE BEGIN
        rgbtab=bytarr(4,256)
        rgbtab[0:2,*]=TRANSPOSE(ctab)
        rgbtab[3,*] = 0
        rgbtab[3,alpha[0]:alpha[1]] = 255
        rgb=rgbtab[*,img]
        rgb=REFORM(rgb,4,sz[1],sz[2],/OVERWRITE)
    END

    oImage->SetProperty,DATA=rgb
    oPoly->SetProperty,DATA=verts,TEXTURE_COORD=fTxCoords

END

;----------------------------------------------------------------------------
; Convert a mouse point into a streamline...

FUNCTION d_vectrackDoStream,sEvent,sState,new_flag
    pick = sState.oWindow->PickData(sState.oView,$
                                        sState.oVols[0], $
                                        [sEvent.x,sEvent.y],dataxyz)
    IF (pick NE 1) THEN RETURN,0

    sState.oVols[2]->GetProperty,xcoord_conv=xc,ycoord_conv=yc,$
        zcoord_conv=zc

    IF (new_flag) THEN BEGIN
        WIDGET_CONTROL, sState.wRibbons, GET_VALUE = bRibbons
        IF (bRibbons) THEN BEGIN
                    sState.oStreamline = OBJ_NEW('IDLgrPolygon', $
                SHADING=1,STYLE=2,UVALUE=dataxyz,$
                xcoord_conv=xc,ycoord_conv=yc,zcoord_conv=zc)
        END ELSE BEGIN
            sState.oStreamline = OBJ_NEW('IDLgrPolyline', $
                UVALUE=dataxyz,$
                xcoord_conv=xc,ycoord_conv=yc,zcoord_conv=zc)
        END
        sState.oStreamModel->Add,sState.oStreamline
    END

    d_vectrackBuildRibbon,sState,sState.oStreamline,dataxyz

    RETURN,1
END

;--------------------------------------------------------------------------
; Compute a single Ribbon/Streamline

PRO d_vectrackBuildRibbon,sState,oObj,dataxyz

    sState.oVols[sState.iVrendVol]->GetProperty,DATA0=auxdata, $
        RGB_TABLE0=auxpal, /NO_COPY
    auxpal = TRANSPOSE(auxpal)
    grAuxpal = OBJ_NEW('IDLgrPalette',  $
                       auxpal[0, *], auxpal[1, *], auxpal[2, *])
    iStep = 100
    ;fFrac = 1.0/88.0  ; 1.0/max velocity
    fFrac = .5 ;step size

    WIDGET_CONTROL, sState.wRibbons, GET_VALUE = bRibbons
    IF (bRibbons) THEN BEGIN
        d_vectrackRibbonTrace, sState.vdata, dataxyz, auxdata,FRAC=fFrac, $
            STEP=iStep,VERT_COLORS=vertcolors, WIDTH = sState.fWidth, $
            OUTVERTS = outverts, OUTCONN = outconn
    END ELSE BEGIN
        d_vectrackStreamlineTrace, sState.vdata, dataxyz, auxdata,FRAC=fFrac, $
            STEP=iStep,VERT_COLORS=vertcolors, $
            OUTVERTS = outverts, OUTCONN = outconn
    END

    IF ((N_ELEMENTS(outconn) GT 1) AND (SIZE(outverts, /N_DIMENSIONS) EQ 2)) $
        THEN BEGIN
        WIDGET_CONTROL, sState.wRibbons, GET_VALUE = bRibbons
        IF (bRibbons) and OBJ_VALID(oObj) THEN BEGIN 
            ss = N_ELEMENTS(color)*0.5
            oObj->SetProperty, REJECT=0, STYLE=2,SHADING=1,PALETTE=grAuxpal, $
                DATA = outverts, POLYGONS = outconn, VERT_COLORS = vertcolors
        END ELSE BEGIN
            oObj->SetProperty,HIDE=0,DATA=outverts,POLYLINES = outconn, $
                VERT_COLORS=vertcolors, PALETTE = grAuxpal
        END
    END ELSE BEGIN
        oObj->SetProperty,HIDE=1
    END

    sState.oVols[sState.iVrendVol]->SetProperty,DATA0=auxdata,/NO_COPY

END

;-----------------------------------------------------------------
;
;    PURPOSE : cleanup procedure. restore colortable, destroy objects.
;
pro d_vectrackCleanup, wTopBase

    WIDGET_CONTROL, wTopBase, GET_UVALUE=sState, /NO_COPY

; Destroy the objects.
    OBJ_DESTROY, sState.oHolder

; Destroy the time step data
    IF (PTR_VALID(sState.pSteps)) THEN BEGIN
        PTR_FREE,(*sState.pSteps).fU
        PTR_FREE,(*sState.pSteps).fV
        PTR_FREE,(*sState.pSteps).fW

        PTR_FREE,(*sState.pSteps).bP
        PTR_FREE,(*sState.pSteps).bT
        PTR_FREE,(*sState.pSteps).bM

        ;PTR_FREE,(*sState.pSteps).bQV
        ;PTR_FREE,(*sState.pSteps).bQC
        ;PTR_FREE,(*sState.pSteps).bQR

        PTR_FREE,sState.pSteps
    END

    ;  Restore the color table.
    ;
    TVLCT, sState.colorTable

    if WIDGET_INFO(sState.groupBase, /VALID_ID) then $
        WIDGET_CONTROL, sState.groupBase, /MAP

end   ;  of d_vectrackCleanup

;----------------------------------------------------------------------------
; main event handler

PRO d_vectrackEvent, sEvent

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
    demo_record, sEvent, 'd_vectrackEvent', $
        filename=sState.record_to_filename
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ  $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

; By default, no updating is needed
    bUpdate = 0
    bRedraw = 0

; Grab the UValue
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY

; Handle other events.
    CASE uval OF

    'RIBBON':
    'TIME_STEP': BEGIN
            IF (d_vectrackChangeData(sState,sEvent.value) GT 0) $
                           THEN BEGIN
                bRedraw = 1
                bUpdate = 4
            END
             END

    'VREND_VOLSEL': BEGIN
            sState.iVrendVol = sEvent.index
                d_vectrackColorBarUpdate,sState
            bRedraw = 1
              END
        'VREND': BEGIN
          sState.oVols[sState.iVrendVol]->SetProperty,HIDE=0
          WIDGET_CONTROL,sEvent.top,/HOURGLASS
          demo_draw, sState.oWindow, sState.oView, debug=sState.debug
          sState.oVols[sState.iVrendVol]->SetProperty,HIDE=1
          END

    'CLEAR_STREAMS' : BEGIN
                oList = sState.oStreamModel->Get(/ALL)
                sz=size(oList)
                IF (sz[2] EQ 11) THEN BEGIN
                    OBJ_DESTROY,oList
                            bRedraw = 1
                END
            END

    'IMG_VOLSEL': BEGIN
            sState.iImgVol = sEvent.index
            bUpdate = 4
            bRedraw = 1
              END

    'ALPHA_LEVEL': BEGIN
                WIDGET_CONTROL, sState.wAlpha[0], GET_VALUE=v1
                WIDGET_CONTROL, sState.wAlpha[1], GET_VALUE=v2
            IF (v1 GE v2) THEN BEGIN
                sState.iAlpha = [v2,v1]
            END ELSE BEGIN
                sState.iAlpha = [v1,v2]
            END
            bUpdate = 4
            bRedraw = 1
                   END

    'ISO_VOLSEL': BEGIN
            sState.iIsoVol = sEvent.index
            Val = sState.fIsoLevel
            fVal = (Val-sState.fScales[1,sState.iIsoVol])/ $
                sState.fScales[0,sState.iIsoVol]
            WIDGET_CONTROL, sState.wIsotext, SET_VALUE=STRING(fVal)
            IF (sState.bIsoShow) THEN BEGIN
                bUpdate = 5
                bRedraw = 1
            END
              END

    'ISO_LEVEL': BEGIN
                WIDGET_CONTROL, sState.wIsoLevel, GET_VALUE=Val
            fVal = (Val-sState.fScales[1,sState.iIsoVol])/ $
                sState.fScales[0,sState.iIsoVol]
            WIDGET_CONTROL, sState.wIsotext, SET_VALUE=STRING(fVal)
            sState.fIsoLevel = Val
            IF (sState.bIsoShow) THEN BEGIN
                bUpdate = 5
                bRedraw = 1
            END
             END

    'ISO_SHOW': BEGIN
            sState.bIsoShow = 1-sState.bIsoShow
            IF (sState.bIsoShow) THEN BEGIN
                bUpdate = 5
                bRedraw = 1
            END ELSE BEGIN
                sState.oIsopolygon->SetProperty,HIDE=1
                bRedraw = 1
            END
            END

        'X_STYLE': BEGIN
            CASE sEvent.index OF
                0: BEGIN ; Vector.
                    sState.bShow[0] = 1
                                sState.bImage[0] = 0
                    bRedraw = 1
                        bUpdate = 1
                    END
                1: BEGIN ; Image.
                    sState.bShow[0] = 1
                                sState.bImage[0] = 1
                    bRedraw = 1
                        bUpdate = 1
                    END
                2: BEGIN ; Hide.
                    sState.bShow[0] = 0
                                sState.bImage[0] = 0
                        sState.oXPolyline->SetProperty, HIDE=1
                        sState.oSlices[0]->SetProperty, HIDE=1
                    bRedraw = 1
                    END
            ENDCASE
        END
        'Y_STYLE': BEGIN
            CASE sEvent.index OF
                0: BEGIN ; Vector.
                    sState.bShow[1] = 1
                                sState.bImage[1] = 0
                    bRedraw = 1
                        bUpdate = 2
                    END
                1: BEGIN ; Image.
                    sState.bShow[1] = 1
                                sState.bImage[1] = 1
                    bRedraw = 1
                        bUpdate = 2
                    END
                2: BEGIN ; Hide.
                    sState.bShow[1] = 0
                                sState.bImage[1] = 0
                        sState.oYPolyline->SetProperty, HIDE=1
                        sState.oSlices[1]->SetProperty, HIDE=1
                    bRedraw = 1
                    END
            ENDCASE
        END
        'Z_STYLE': BEGIN
            CASE sEvent.index OF
                0: BEGIN ; Vector.
                    sState.bShow[2] = 1
                                sState.bImage[2] = 0
                    bRedraw = 1
                        bUpdate = 3
                    END
                1: BEGIN ; Image.
                    sState.bShow[2] = 1
                                sState.bImage[2] = 1
                    bRedraw = 1
                        bUpdate = 3
                    END
                2: BEGIN ; Hide.
                    sState.bShow[2] = 0
                                sState.bImage[2] = 0
                        sState.oZPolyline->SetProperty, HIDE=1
                        sState.oSlices[2]->SetProperty, HIDE=1
                    bRedraw = 1
                    END
            ENDCASE
        END
        'X_VALUE': BEGIN
                IF (sState.bShow[0]) THEN BEGIN
                    bUpdate = 1
                    bRedraw = 1
            ENDIF
            END
        'Y_VALUE': BEGIN
                IF (sState.bShow[1]) THEN BEGIN
                    bUpdate = 2
                    bRedraw = 1
            ENDIF
            END
        'Z_VALUE': BEGIN
                IF (sState.bShow[2]) THEN BEGIN
                    bUpdate = 3
                    bRedraw = 1
            ENDIF
            END
        'SAMPLE_EVEN': BEGIN
                sState.bRandom = 0
            WIDGET_CONTROL, sState.wRandomField, SENSITIVE=0
                bUpdate = 4
                bRedraw = 1
            END
        'SAMPLE_RANDOM': BEGIN
                sState.bRandom = 1
                WIDGET_CONTROL, sState.wRandomField, SENSITIVE=1
            bUpdate = 4
            bRedraw = 1
            END
        'N_EVEN': BEGIN
                bUpdate = 4
                bRedraw = 1
            END
        'N_RANDOM': BEGIN
                bUpdate = 4
                bRedraw = 1
            END
        'SCALE': BEGIN
                bUpdate = 4
                bRedraw = 1
            END
    'RENDER_MOVIE': BEGIN
            d_vectrackRenderMovie,sState
                bRedraw = 1
        END
        'DRAW': BEGIN

            ; Expose.
            IF (sEvent.type EQ 4) THEN BEGIN
                demo_draw, sState.oWindow, sState.oView, debug=sState.debug
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
                RETURN
            ENDIF

           ; Handle trackball updates.
           bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
           IF (bHaveTransform NE 0) THEN BEGIN
               sState.oGroup->GetProperty, TRANSFORM=t
               sState.oGroup->SetProperty, TRANSFORM=t#qmat
               bRedraw = 1
           ENDIF

           ; Handle other events: PICKING, quality changes, etc.
           ;  Button press.
           IF (sEvent.type EQ 0) THEN BEGIN
           ;    IF (sEvent.press EQ 4) THEN BEGIN ; Right mouse.
           ;    pick = sState.oWindow->PickData(sState.oView,$
           ;                                        sState.oSurface, $
           ;                                        [sEvent.x,sEvent.y],dataxyz)
           ;    IF (pick EQ 1) THEN BEGIN
           ;    str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
           ;     FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
           ;    WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
           ;    ENDIF ELSE BEGIN
           ;    WIDGET_CONTROL, sState.wLabel, $
           ;                 SET_VALUE="Data point: In background."
            ;       ENDELSE

            ;       sState.btndown = 4b
            ;   WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION

                IF (sEvent.press EQ 4) THEN BEGIN ; Right mouse.
           IF (d_vectrackDoStream(sEvent,sState,1)) THEN BEGIN
            bRedraw = 1
                    sState.btndown = 4b
                    sState.oWindow->SetProperty, QUALITY=sState.dragq
                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
           END
                END ELSE IF (sEvent.press EQ 1) THEN BEGIN ; other mouse button.
                   sState.btndown = 1b
                   sState.oWindow->SetProperty, QUALITY=sState.dragq
                   WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                   bRedraw = 1
                ENDIF ELSE BEGIN   ; middle mouse
           oList = sState.oStreamModel->Get(/ALL)
           sz=size(oList)
           IF (sz[2] EQ 11) THEN BEGIN
            OBJ_DESTROY,oList
                    bRedraw = 1
           END
        END
          ENDIF

         ; Button motion.
         IF (sEvent.type EQ 2) THEN BEGIN
             IF (sState.btndown EQ 4b) THEN BEGIN ; Right mouse button.
           status = d_vectrackDoStream(sEvent,sState,0)
           bRedraw = 1
         ENDIF
     ENDIF

         ;IF (sEvent.type EQ 2) THEN BEGIN
         ;    IF (sState.btndown EQ 4b) THEN BEGIN ; Right mouse button.
         ;    pick = sState.oWindow->PickData(sState.oView, $
         ;                                        sState.oSurface, $
         ;                                        [sEvent.x,sEvent.y], dataxyz)
         ;    IF (pick EQ 1) THEN BEGIN
         ;            str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
         ;       FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
         ;    WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
         ;        ENDIF ELSE BEGIN
         ;            WIDGET_CONTROL, sState.wLabel, $
         ;                SET_VALUE="Data point: In background."
         ;        ENDELSE
;
;             ENDIF
;        ENDIF

        ; Button release.
        IF (sEvent.type EQ 1) THEN BEGIN
            IF (sState.btndown EQ 1b) THEN BEGIN
                sState.oWindow->SetProperty, QUALITY=2
                bRedraw = 1
        END ELSE IF (sState.btndown EQ 4b) THEN BEGIN
        status = d_vectrackDoStream(sEvent,sState,0)
                sState.oWindow->SetProperty, QUALITY=2
                bRedraw = 1
; Build a New Polyline...
            ENDIF
            sState.btndown = 0b
            WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
        ENDIF

      END


      'QUIT' : BEGIN
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
            WIDGET_CONTROL, sEvent.top, /DESTROY
            RETURN
      end   ; of QUIT

      'ABOUT' : BEGIN

            ONLINE_HELP, 'd_vectrack', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
      end   ; of ABOUT


    ENDCASE

; Update the current display
    IF (bUpdate NE 0) THEN BEGIN

; start by hiding everything
    hid = (1-sState.bShow)
    sState.oXPolyline->SetProperty,HIDE=hid[0]+sState.bImage[0]
    sState.oYPolyline->SetProperty,HIDE=hid[1]+sState.bImage[1]
    sState.oZPolyline->SetProperty,HIDE=hid[2]+sState.bImage[2]
    sState.oSlices[0]->SetProperty,HIDE=hid[0]+(1-sState.bImage[0])
    sState.oSlices[1]->SetProperty,HIDE=hid[1]+(1-sState.bImage[1])
    sState.oSlices[2]->SetProperty,HIDE=hid[2]+(1-sState.bImage[2])
    sState.oIsopolygon->SetProperty,HIDE=(1-sState.bIsoShow)

    d_vectrackPlanesUpdate,sState,bUpdate
    d_vectrackIsoSurfUpdate,sState,bUpdate

    ENDIF

; Redraw the graphics
    IF (bRedraw) THEN BEGIN
    demo_draw, sState.oWindow, sState.oView, debug=sState.debug
    ENDIF

; Restore state.
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
END




;-----------------------------------------------------------------
;
;    PURPOSE : show the texture mapping capability
;
PRO d_vectrack, $
                LOADDATA=fname, $
                WIDTH = fWidth,  $
                RECORD_TO_FILENAME=record_to_filename, $
                GROUP=group, $               ; IN: (opt) group identifier
                DEBUG=debug, $               ; IN: (opt)
                APPTLB = appTLB              ; OUT: (opt) TLB of this application

    xdim = 600
    ydim = 600

    IF (N_ELEMENTS(fWidth) EQ 0) THEN fWidth = 1.0
    IF (N_ELEMENTS(fname) NE 0) THEN BEGIN
    restore,fname
    u = *(vec_track_data.fU[0])
    v = *(vec_track_data.fV[0])
    w = *(vec_track_data.fW[0])

    pb = *(vec_track_data.bP[0])
    tb = *(vec_track_data.bT[0])
    mb = *(vec_track_data.bM[0])
    ;qvb = *(vec_track_data.bQV[0])
    ;qcb = *(vec_track_data.bQC[0])
    ;qrb = *(vec_track_data.bQR[0])
    nSteps = N_ELEMENTS(vec_track_data.fU)
    pData = PTR_NEW(vec_track_data,/NO_COPY)
    END ELSE BEGIN
        restore, demo_filepath('storm25.sav', $
                    SUBDIR=['examples','demo','demodata'])
        restore, demo_filepath('storm25b.sav', $
                    SUBDIR=['examples','demo','demodata'])
    nSteps = 0
    pData = PTR_NEW()
    END

    ; Check the validity of the group identifier.
    ;
    ngroup = N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check = WIDGET_INFO(group, /VALID_ID)
        if (check NE 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Return to the main application'
            RETURN
        endif
        groupBase = group
    endif else groupBase = 0L

    ;  Get the screen size.
    ;
    Device, GET_SCREEN_SIZE = screenSize

    ;  Set up dimensions of the drawing (viewing) area.
    ;
    xdim = screenSize[0]*0.6
    ydim = xdim*0.8

    ;  Get the current color vectors to restore
    ;  when this application is exited.
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ;  Build color table from color vectors
    ;
    colorTable = [[savedR],[savedG],[savedB]]

    ; Get the data size
    sz = SIZE(u)

    ;  Create widgets.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(/COLUMN, $
            TITLE="Thunderstorm Visualization", $
            XPAD=0, YPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1, MBAR=barBase, $
            UNAME='D_VECTRACK:tlb')
    endif else begin
        wTopBase = WIDGET_BASE(/COLUMN, $
            TITLE="Thunderstorm Visualization", $
            XPAD=0, YPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            GROUP_LEADER=group, $
            TLB_FRAME_ATTR=1, MBAR=barBase, $
            UNAME='D_VECTRACK:tlb')
    endelse

        ;  Create the menu bar. It contains the file/quit,
        ;  edit/ shade-style, help/about.
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE='File', /MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Quit', UVALUE='QUIT')

         ;  Create the menu bar item help that contains the about button
         ;
         wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP, /MENU)

             wAboutButton = WIDGET_BUTTON(wHelpButton, $
                 VALUE='About Thunderstorm Visualization', UVALUE='ABOUT')







    wTopRowBase = WIDGET_BASE(wTopBase,/ROW,/FRAME)
    wGuiBase = WIDGET_BASE(wTopRowBase, /COLUMN)

    wRowBase = WIDGET_BASE(wGuiBase, /ROW )
    wFrameBase = WIDGET_BASE(wRowBase, /COLUMN, /FRAME)
    wLabel = WIDGET_LABEL(wFrameBase,VALUE='Velocity Field Planes:')
    wGuiBase2 = WIDGET_BASE(wFrameBase,/COLUMN)
    wXDrop = WIDGET_DROPLIST(wGuiBase2, VALUE=['Vector','Image','<Off>'],$
                                 TITLE='X:', UVALUE='X_STYLE', $
                                 UNAME='D_VECTRACK:xdroplist')
    wYDrop = WIDGET_DROPLIST(wGuiBase2, VALUE=['Vector','Image','<Off>'],$
                                 TITLE='Y:', UVALUE='Y_STYLE', $
                                 UNAME='D_VECTRACK:ydroplist')
    wZDrop = WIDGET_DROPLIST(wGuiBase2, VALUE=['Vector','Image','<Off>'],$
                                 TITLE='Z:', UVALUE='Z_STYLE', $
                                 UNAME='D_VECTRACK:zdroplist')

    wXSlider = WIDGET_SLIDER(wFrameBase, MAXIMUM=sz[1]-1, $
        TITLE='X Plane', UVALUE='X_VALUE')
    wYSlider = WIDGET_SLIDER(wFrameBase, MAXIMUM=sz[2]-1, $
                value=sz[2]/2, $
        TITLE='Y Plane', UVALUE='Y_VALUE')
    wZSlider = WIDGET_SLIDER(wFrameBase, MAXIMUM=sz[3]-1, $
        TITLE='Z Plane', UVALUE='Z_VALUE')

    wFrameBase = WIDGET_BASE(wRowBase, /COLUMN, /FRAME)
    ;wVVolSel = WIDGET_DROPLIST(wFrameBase,VALUE=['P','T','M','QV','QC','QR'],$
    frame = !version.os_family ne 'unix' ; Workaround problem 7763.
    wVVolSel = WIDGET_DROPLIST(wFrameBase,VALUE=['P','T','M'],$
        FRAME=frame, TITLE='Vrend vol',UVAL='VREND_VOLSEL')
    wVRender = WIDGET_BUTTON(wFrameBase, VALUE='Vol Render', $
        UVALUE='VREND', UNAME='D_VECTRACK:volrendr')

    ;wIVolSel = WIDGET_DROPLIST(wFrameBase,VALUE=['P','T','M','QV','QC','QR'],$
    wIVolSel = WIDGET_DROPLIST(wFrameBase,VALUE=['P','T','M'],$
    FRAME=frame,TITLE='Img vol',UVAL='IMG_VOLSEL')
    ;wSVolSel = WIDGET_DROPLIST(wFrameBase,VALUE=['P','T','M','QV','QC','QR'],$
    wSVolSel = WIDGET_DROPLIST(wFrameBase,VALUE=['P','T','M'],$
    FRAME=frame, TITLE='Iso vol',UVAL='ISO_VOLSEL')
    wIsoText = WIDGET_LABEL(wFrameBase,VALUE='0.00000   ')
    wIsoLevel = WIDGET_SLIDER(wFrameBase,/SUPPRESS_VALUE, $
        TITLE='Level',UVAL='ISO_LEVEL',MAXIMUM=255,VALUE=128,UNAME='D_VECTRACK:iso_level')
    wGuiBase2 = WIDGET_BASE(wFrameBase,/COLUMN,/NONEXCLUSIVE)
    wIsotoggle = WIDGET_BUTTON(wGuiBase2,VALUE='IsoShow',UVALUE='ISO_SHOW')

    wAlphamin = WIDGET_SLIDER(wFrameBase,/SUPPRESS_VALUE,UVAL='ALPHA_LEVEL', $
        MAXIMUM=255,VALUE=0, TITLE='Transparency Min.')
    wAlphamax = WIDGET_SLIDER(wFrameBase,/SUPPRESS_VALUE,UVAL='ALPHA_LEVEL', $
        MAXIMUM=255,VALUE=255, TITLE='Transparency Max.')
    wClearStreams = WIDGET_BUTTON(wFrameBase,VALUE='Clear Streamlines', $
        UVALUE='CLEAR_STREAMS',UNAME='D_VECTRACK:clearstreams')
    wRibbons = CW_BGROUP(wFrameBase, ['Ribbons'], UVALUE='RIBBON', $
                         /NONEXCLUSIVE)
    WIDGET_CONTROL, wRibbons, SET_VALUE=1

    ;wMovie = WIDGET_BUTTON(wFrameBase,VALUE='Movie', $
    ;       UVALUE='RENDER_MOVIE')

    wFrameBase = WIDGET_BASE(wGuiBase, /COLUMN, /FRAME)
    wLabel = WIDGET_LABEL(wFrameBase,VALUE='Vector Sampling:')
    wGuiBase2 = WIDGET_BASE(wFrameBase,/ROW,/EXCLUSIVE)
    wEButton = WIDGET_BUTTON(wGuiBase2, VALUE='Even',$
            UVALUE='SAMPLE_EVEN',/NO_RELEASE, $
            UNAME='D_VECTRACK:even')
    wRButton = WIDGET_BUTTON(wGuiBase2, VALUE='Random',$
            UVALUE='SAMPLE_RANDOM',/NO_RELEASE, $
            UNAME='D_VECTRACK:random')

    wEvenField = CW_FIELD(wFrameBase, /INTEGER, $
            TITLE='Sample Every Nth, N=', XSIZE=2, $
            UVALUE='N_EVEN',VALUE=2,/RETURN_EVENTS)
    wRandomField = CW_FIELD(wFrameBase, /INTEGER, $
            TITLE='Total Number of Samples=', XSIZE=5, $
            UVALUE='N_RANDOM',VALUE=500,/RETURN_EVENTS)

    wScaleField = CW_FIELD(wGuiBase, /FLOAT, TITLE='Vector Length = ', $
            UVALUE='SCALE', VALUE=10.0, XSIZE=8, /RETURN_EVENTS)

    IF (nSteps GT 0) THEN BEGIN
        wTimeStep = WIDGET_SLIDER(wGuiBase,UVAL='TIME_STEP', $
        MAXIMUM=nSteps-1,VALUE=0)
    END

    wDraw = WIDGET_DRAW(wTopRowBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
                        RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                        GRAPHICS_LEVEL=2, UNAME='D_VECTRACK:draw')

    ;wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[0], UVALUE='MM_MIN0')
    ;wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[1], UVALUE='MM_MIN1')
    ;wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[2], UVALUE='MM_MIN2')

    ; Status line.
    ;wGuiBase = WIDGET_BASE(wTopBase, /COLUMN)
    ;wLabel = WIDGET_LABEL(wGuiBase, /FRAME, $
    ;             VALUE="Left Mouse: Trackball" )
    ;wLabel = WIDGET_LABEL(wGuiBase, VALUE=" ", /DYNAMIC_RESIZE)





        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)



    ;  Realize the base widget.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Returns the top level base in the appTLB keyword
    ;
    appTLB = wTopBase

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('vectrack.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)



    ; Get the window id of the drawable.
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    ; Set default widget items.
    WIDGET_CONTROL, wXDrop, SET_DROPLIST_SELECT=2
    WIDGET_CONTROL, wYDrop, SET_DROPLIST_SELECT=1
    WIDGET_CONTROL, wZDrop, SET_DROPLIST_SELECT=2

    WIDGET_CONTROL, wEButton,SET_BUTTON=1
    WIDGET_CONTROL, wRButton,SET_BUTTON=0
    WIDGET_CONTROL, wRandomField, SENSITIVE=0

    ;WIDGET_CONTROL, wStyleDrop, SET_DROPLIST_SELECT=2
    ;WIDGET_CONTROL, wHide, SENSITIVE=0

    ; Compute viewplane rect based on aspect ratio.
    aspect = FLOAT(xdim) / FLOAT(ydim)
    myview = [-0.5, -0.5, 1, 1] * 1.5
    IF (aspect > 1) THEN BEGIN
        myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
        myview[2] = myview[2] * aspect
    ENDIF ELSE BEGIN
        myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
        myview[3] = myview[3] * aspect
    ENDELSE

; Drop the view down a bit to make room for the colorbar
    ;;;myview[1] = myview[1] - 0.1
    myview[1] = myview[1] - 0.15

    ; Create view.
    oView = OBJ_NEW('IDLgrView', PROJECTION=2,$
                    VIEWPLANE_RECT=myview,COLOR=[50,50,70])

    ; Create model.
    oTop = OBJ_NEW('IDLgrModel')
    oTop->Scale,0.8,0.8,0.8
    oGroup = OBJ_NEW('IDLgrModel')
    oTop->Add, oGroup

    ; Compute data bounds.
    sz = SIZE(u)
    xMax = sz[1] - 1
    yMax = sz[2] - 1
    ; zMin= 0
    zMax = sz[3] - 1
    ;zMin2 = zMin - 1
    ;zMax2 = zMax + 1

    ; Compute coordinate conversion to normalize.
    maxDim = MAX([xMax, yMax, zMax])
    xs = [-0.5 * xMax/maxDim,1.0/maxDim]
    ys = [-0.5 * yMax/maxDim,1.0/maxDim]
    ;zs = [(-zMin2/(zMax2-zMin2))-0.5, 1.0/(zMax2-zMin2)]
    zoom = 1.3
    zs = [-0.5*zMax/maxDim, 1.0/maxDim]*zoom

; Create the axis objects.
    oXTitle = OBJ_NEW('IDLgrText', '<- West (km) East->')
    oAxis = OBJ_NEW('IDLgrAxis', 0, COLOR=[255,255,255],RANGE=[0,xMax*2.0],$
             TITLE=oXTitle,TICKLEN=2,$
             XCOORD_CONV=[xs[0],xs[1]*0.5], $
             YCOORD_CONV=ys, $
             ZCOORD_CONV=zs)
    oGroup->Add, oAxis

    oYTitle = OBJ_NEW('IDLgrText','<- South (km) North->')
    oAxis = OBJ_NEW('IDLgrAxis', 1, COLOR=[255,255,255],RANGE=[0,yMax*2.0],$
             TITLE=oYTitle,TICKLEN=2,$
             XCOORD_CONV=xs, $
             YCOORD_CONV=[ys[0],ys[1]*0.5], $
             ZCOORD_CONV=zs)
    oGroup->Add, oAxis

    oZTitle = OBJ_NEW('IDLgrText','Height (km)')
    oTickText = OBJ_NEW('IDLgrText', ['', '5', '10', '15'])
    oAxis = OBJ_NEW('IDLgrAxis', 2, COLOR=[255,255,255], $
             RANGE=[0,zMax*(17.5/24.0)],$
             /EXACT, $
             TICKTEXT=oTickText, $
             TICKLEN=2,TITLE=oZTitle,$
             XCOORD_CONV=xs, $
             YCOORD_CONV=[.5 * yMax/maxDim,1.0/maxDim], $
             ZCOORD_CONV=[zs[0],zs[1]*(24.0/17.5)])
    oGroup->Add, oAxis

; wireframe box
    oBox = OBJ_NEW('IDLgrPolyline', $
        [[0,0,0],[xMax,0,0],[0,yMax,0],[xMax,yMax,0], $
         [0,0,zMax],[xMax,0,zMax],[0,yMax,zMax],$
         [xMax,yMax,zMax]], $
        COLOR=[200,200,200], $
        POLYLINE=[5,0,1,3,2,0,5,4,5,7,6,4,2,0,4,2,1,5,2,2,6,2,3,7],$
        XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oGroup->Add, oBox

    oXPolyline = OBJ_NEW('IDLgrPolyline', COLOR=[255,255,255], HIDE=1, $
                  XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oYPolyline = OBJ_NEW('IDLgrPolyline', COLOR=[255,255,255], HIDE=1, $
                  XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oZPolyline = OBJ_NEW('IDLgrPolyline', COLOR=[255,255,255], HIDE=1, $
                  XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oGroup->Add, oXPolyline
    oGroup->Add, oYPolyline
    oGroup->Add, oZPolyline

; slice image-form objects (texture mapping)
    oXImage = OBJ_NEW('IDLgrImage',dist(5),HIDE=1)
    oYImage = OBJ_NEW('IDLgrImage',dist(5),HIDE=1)
    oZImage = OBJ_NEW('IDLgrImage',dist(5),HIDE=1)
    oXPolygon = OBJ_NEW('IDLgrPolygon', COLOR=[255,255,255], HIDE=1,$
              TEXTURE_MAP=oXImage, TEXTURE_INTERP=1, $
                  XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oYPolygon = OBJ_NEW('IDLgrPolygon', COLOR=[255,255,255], HIDE=1,$
              TEXTURE_MAP=oYImage, TEXTURE_INTERP=1, $
                  XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oZPolygon = OBJ_NEW('IDLgrPolygon', COLOR=[255,255,255], HIDE=1,$
              TEXTURE_MAP=oZImage, TEXTURE_INTERP=1, $
                  XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oGroup->Add, oXPolygon
    oGroup->Add, oYPolygon
    oGroup->Add, oZPolygon

; Iso Surface objects
    oIsoPolygon = OBJ_NEW('IDLgrPolygon', COLOR=[127,127,127], HIDE=1,$
        SHADING=1,XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oGroup->Add, oIsoPolygon

; Stream line objects holder
    oStreamModel = OBJ_NEW('IDLgrModel')
    oGroup->Add, oStreamModel


; Volume objects MUST be added LAST
    oTvol = OBJ_NEW('IDLgrVolume', DATA0 = tb, $
        /ZERO_OPACITY_SKIP, /ZBUFFER, HIDE=1, $
        XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oPvol = OBJ_NEW('IDLgrVolume', DATA0 = pb, $
        /ZERO_OPACITY_SKIP, /ZBUFFER, HIDE=1, $
        XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
    oMvol = OBJ_NEW('IDLgrVolume', DATA0 = mb, $
        /ZERO_OPACITY_SKIP, /ZBUFFER, HIDE=1, $
        XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
;    oQVvol = OBJ_NEW('IDLgrVolume', DATA0 = qvb, $
;       /ZERO_OPACITY_SKIP, /ZBUFFER, HIDE=1, $
;       XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
;    oQCvol = OBJ_NEW('IDLgrVolume', DATA0 = qcb, $
;       /ZERO_OPACITY_SKIP, /ZBUFFER, HIDE=1, $
;       XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
;    oQRvol = OBJ_NEW('IDLgrVolume', DATA0 = qrb, $
;       /ZERO_OPACITY_SKIP, /ZBUFFER, HIDE=1, $
;       XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)

; add the voxel volumes
    oGroup->Add, oTvol
    oGroup->Add, oPvol
    oGroup->Add, oMvol
    ;oGroup->Add, oQVvol
    ;oGroup->Add, oQCvol
    ;oGroup->Add, oQRvol

; setup their palettes/opacity tables
    d_vectrackReadVoxelPalettes,oTvol
    d_vectrackReadVoxelPalettes,oPvol
    d_vectrackReadVoxelPalettes,oMvol
    ;d_vectrackReadVoxelPalettes,oQVvol
    ;d_vectrackReadVoxelPalettes,oQCvol
    ;d_vectrackReadVoxelPalettes,oQRvol

; For 0-MAX volumes, replace the opacity table
    oMvol->SetProperty,OPACITY_TABLE0=((findgen(256)/16)^2.0)/4.0
    ;oQCvol->SetProperty,OPACITY_TABLE0=((findgen(256)/8)^1.0)/0.5
    ;oQRvol->SetProperty,OPACITY_TABLE0=((findgen(256)/8)^1.0)/0.5

; Grab the Volume color table for use by the image objects
    oPvol->GetProperty,RGB_TABLE0=ctab
    oPal = OBJ_NEW('IDLgrPalette',ctab[*,0],ctab[*,1],ctab[*,2])
    oXImage->SetProperty,PALETTE=oPal
    oYImage->SetProperty,PALETTE=oPal
    oZImage->SetProperty,PALETTE=oPal

; Create some lights.
    oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=1, INTENSITY=0.8)
    oTop->Add, oLight
    oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
    oTop->Add, oLight

; Create the color bar annotation (lower left corner)
    oCBTop = OBJ_NEW('IDLgrModel')

    rgb = bytarr(3,256,16)
    rgb[0,*,*] = indgen(256*16) MOD 256
    rgb[1,*,*] = indgen(256*16) MOD 256
    rgb[2,*,*] = indgen(256*16) MOD 256
    oImage = OBJ_NEW('IDLgrImage',rgb,DIMENSIONS=[256,16])
    oCBTitle = OBJ_NEW('IDLgrText','Grayscale')
    oAxis = OBJ_NEW('IDLgrAxis',range=[0,256],/EXACT,COLOR=[255,255,255], $
    TICKLEN=15,MAJOR=5,TITLE=oCBTitle)

    oCBTop->Add,oImage
    oCBTop->Add,oAxis

    oView->Add,oCBTop

; Place the model in the view.
    oView->Add, oTop

; Rotate to standard view for first draw.
    oGroup->Rotate, [1,0,0], -90
    oGroup->Rotate, [0,1,0], 30
    oGroup->Rotate, [1,0,0], 30

; Create a trackball.
    oTrack = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2.)

; Create a holder object for easy destruction.
    oHolder = OBJ_NEW('IDL_Container')
    oHolder->Add, oView
    oHolder->Add, oTrack
    oHolder->Add, oXTitle
    oHolder->Add, oYTitle
    oHolder->Add, oZTitle
    oHolder->Add, oTickText
    oHolder->Add, oCBTitle
    oHolder->Add, oPal
    oHolder->Add, oXImage
    oHolder->Add, oYImage
    oHolder->Add, oZImage


if n_elements(record_to_filename) eq 0 then $
    record_to_filename = ''


    vdims = SIZE(u, /DIMENSIONS)
    vdata = FLTARR(3, vdims[0], vdims[1], vdims[2])
    vdata[0, *, *, *] = FLOAT(u)
    vdata[1, *, *, *] = FLOAT(v)
    vdata[2, *, *, *] = FLOAT(w)

; Save state.
    sState = {nSteps: nSteps,        $
        curStep: 0,            $
        pSteps: pData,         $
        btndown: 0b,           $
        dragq: 1,          $
        u:u,                   $
        v:v,                   $
        w:w,                   $
        vdata:vdata,           $
        bShow: [0b,0b,0b],     $
        bImage: [0b,0b,0b],    $
        bRandom: 0b,           $
        oHolder: oHolder,      $
        oTrack:oTrack,         $
        wXSlider:wXSlider,     $
        wYSlider:wYSlider,     $
        wZSlider:wZSlider,     $
        wEvenField:wEvenField, $
        wRandomField:wRandomField, $
        wScaleField:wScaleField, $
        wIsoLevel: wIsoLevel,  $
        wIsoText: wIsoText,    $
        wAlpha: [wAlphamin,wAlphamax],    $
        wDraw: wDraw,          $
        wLabel: wLabel,        $
        wRibbons: wRibbons, $
        oWindow: oWindow,      $
        oView: oView,          $
        oGroup: oGroup,        $
        oCBTop: oCBTop,        $
        iAlpha: [0,255],       $
        iImgVol: 0,            $
        iVrendVol: 0,          $
        ;oVols: [oPvol,oTvol,oMvol,oQVvol,oQCvol,oQRvol], $
        oVols: [oPvol,oTvol,oMvol], $
        oSlices: [oXPolygon,oYPolygon,oZPolygon], $
        oIsopolygon: oIsopolygon, $
        oStreamModel: oStreamModel, $
        oStreamline: OBJ_NEW(), $
        oImages: [oXImage,oYImage,oZImage], $
        iIsoVol: 0,            $
        fIsoLevel: 128.0,      $
        fWidth: fWidth, $
        bIsoShow: 0,           $
        fScales:[[128.0/7.0,127.0],[128.0/22.0,127.0],[255.0/88.0,0.0],$
            [128.0/0.006,128.0],[255.0/0.0067,0.0],[255.0/0.0162,0.0]], $
        oXPolyline: oXPolyline,$
        oYPolyline: oYPolyline,$
        oZPolyline: oZPolyline, $
        record_to_filename: record_to_filename, $
        ColorTable: colorTable, $ ; Color table to restore at exit
        debug: keyword_set(debug), $
        groupBase: groupBase $               ; Base of Group Leader
        }

    ; Initialize with an interesting view
    sState.bShow[1]=1
    sState.bImage[1]=1
    sState.bIsoShow=1
    widget_control, wIsotoggle, /set_button
    d_vectrackColorBarUpdate,sState
    d_vectrackIsoSurfUpdate,sState,5
    d_vectrackPlanesUpdate,sState,4
    sState.oSlices[1]->SetProperty,HIDE=0
    sState.oIsopolygon->SetProperty,HIDE=0


    WIDGET_CONTROL, wTopBase, SET_UVALUE=sState, /NO_COPY

    XMANAGER, 'D_VECTRACK', wTopBase, $
        EVENT_HANDLER='d_vectrackEvent', $
        /NO_BLOCK, $
        CLEANUP='d_vectrackCleanup'

END





