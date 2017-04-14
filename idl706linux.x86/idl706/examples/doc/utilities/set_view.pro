; $Id: //depot/idl/IDL_70/idldir/examples/doc/utilities/set_view.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
; NAME:
;       SET_VIEW
;
; PURPOSE:
;       This procedure sets a default VIEWPLANE_RECT for a given
;       view and destination.
;
;       The viewplane rect is calculated to hold the models that
;       are currently contained within the view.
;
; CATEGORY:
;       Object graphics.
;
; CALLING SEQUENCE:
;       SET_VIEW, oView, oDest
;
; INPUTS:
;       oView: An instance of an IDLgrView.
;       oDest: An instance of an IDLgrWindow or IDLgrPrinter.
;
; KEYWORD PARAMETERS:
;       DO_ASPECT: Set this keyword to a nonzero value if you would
;                       like to maintain aspect ratio of the bounds
;                       of the models within the viewport.
;       ISOTROPIC: Set this keyword to a nonzero value if you would
;                       like the bounds of the models to be isotropic.
;       XRANGE: Set this keyword to a two-element vector [xmin,xmax]
;                       to use as the bounds of the models.
;       YRANGE: Set this keyword to a two-element vector [ymin,ymax]
;                       to use as the bounds of the models.
;       ZRANGE: Set this keyword to a two-element vector [zmin,zmax]
;                       to use as the bounds of the models.
; MODIFICATION HISTORY:
;       Written by:     DD, February 1997.
;-
PRO set_view, oView, oDest, XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange, $
              ISOTROPIC=isotropic, DO_ASPECT=do_aspect

    IF (N_ELEMENTS(isotropic) EQ 0) THEN isotropic = 0
    IF (N_ELEMENTS(do_aspect) EQ 0) THEN do_aspect = 1

    ; Get the models contained within the view.
    oModelArr = oView->Get(/ALL, COUNT=nModels)

    ; Determine the overall bounding box for the models within the view.
    FOR i=0,nModels-1 DO BEGIN
        get_bounds, oModelArr[i], modelXrange, modelYrange, modelZrange
        IF (i EQ 0) THEN BEGIN
            fullXrange = modelXrange
            fullYrange = modelYrange
            fullZrange = modelZrange
        ENDIF ELSE BEGIN
            fullXrange[0] = fullXrange[0] < modelXrange[0]
            fullXrange[1] = fullXrange[1] > modelXrange[1]
            fullYrange[0] = fullYrange[0] < modelYrange[0]
            fullYrange[1] = fullYrange[1] > modelYrange[1]
            fullZrange[0] = fullZrange[0] < modelZrange[0]
            fullZrange[1] = fullZrange[1] > modelZrange[1]
        ENDELSE
    ENDFOR

    ; If user does not provide XYZRange, use overall model range.
    IF (N_ELEMENTS(xrange) EQ 0) THEN xrange = fullXrange
    IF (N_ELEMENTS(yrange) EQ 0) THEN yrange = fullYrange
    IF (N_ELEMENTS(zrange) EQ 0) THEN zrange = fullZrange

    	
    ; If isotropy is to be maintained, use largest of three dimensions.
    IF (isotropic NE 0) THEN BEGIN
        xlen = xrange[1] - xrange[0]
        ylen = yrange[1] - yrange[0]
        zlen = zrange[1] - zrange[0]
        maxlen = xlen > ylen > zlen
        xrange[0] = xrange[0] - ((maxlen - xlen) / 2.0)
        xrange[1] = xrange[0] + maxlen
        yrange[0] = yrange[0] - ((maxlen - ylen) / 2.0)
        yrange[1] = yrange[0] + maxlen
        zrange[0] = zrange[0] - ((maxlen - zlen) / 2.0)
        zrange[1] = zrange[0] + maxlen
    ENDIF

    ; Pad in X and Y.
    xpad = (xrange[1] - xrange[0]) * 0.1
    ypad = (yrange[1] - yrange[0]) * 0.1
    xrange[0] = xrange[0] - xpad
    xrange[1] = xrange[1] + xpad
    yrange[0] = yrange[0] - ypad
    yrange[1] = yrange[1] + ypad

    ; Set viewplane rect according to given XYRanges.
    IF (do_aspect) THEN BEGIN
        ; Determine the dimensions of the viewport in device units.
        oDest->GetProperty, DIMENSIONS=destDims, RESOLUTION=resolution
        oView->GetProperty, DIMENSIONS=viewDims, UNITS=vUnits
        ; If the view size is unspecified, use the destination dimensions.
        IF ((viewDims[0] EQ 0) OR (viewDims[1] EQ 0)) THEN BEGIN
            viewDims = destDims
        ENDIF ELSE BEGIN
            ; Translate to device units.
            CASE vUnits OF
                0: BEGIN ;Device
                     ; Do nothing.
                   END
                1: BEGIN ; Inches
                       viewDims = viewDims * 2.54 / resolution
                   END
                2: BEGIN ; Centimeters
                       viewDims = viewDims / resolution
                   END
                3: BEGIN ; Normalized
                       viewDims = viewDims * destDims
                   END
            ENDCASE
        ENDELSE

        ; Calculate aspect ratio of viewport.
        aspect = viewDims[0] / viewDims[1]

        ; Add padding to view volume to handle aspect ratio.
        xlen = xrange[1] - xrange[0] 
        ylen = yrange[1] - yrange[0] 
        IF (aspect GT 1.) THEN  BEGIN
            vrect = [xrange[0] - (((aspect - 1.) * xlen )/2.),      $
                     yrange[0],                                     $
                     aspect * xlen,                                 $
                     ylen]
        ENDIF ELSE BEGIN
            vrect = [xrange[0],                                     $
                     yrange[0] - ((((1./aspect) - 1.) * ylen)/2.),  $
                     xlen,                                          $
                     ylen/aspect]
        ENDELSE
    ENDIF ELSE BEGIN
        vrect = [xrange[0],               $
                 yrange[0],               $
                 xrange[1] - xrange[0],   $
                 yrange[1] - yrange[0]]
    ENDELSE

    zclip = [zrange[1]+1,zrange[0]-1]

    ; Position the eye so that there is a 60 degree field of view.
    ; Ensure the eye is positioned in front of the near clip plane.
    eye = (((yrange[1]-yrange[0])/2.) / TAN(!DTOR*30.0)) > (zclip[0] + 1.0)

    oView->SetProperty, VIEWPLANE_RECT=vRect, ZCLIP=zclip, EYE=eye
END
