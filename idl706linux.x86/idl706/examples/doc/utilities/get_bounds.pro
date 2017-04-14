; $Id: //depot/idl/IDL_70/idldir/examples/doc/utilities/get_bounds.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       GET_BOUNDS
;
; PURPOSE:
;       This procedure fills in the xrange, yrange, and zrange vectors
;       that represent the overall data ranges of the objects within
;       the given tree.
;
; CATEGORY:
;       Object graphics.
;
; CALLING SEQUENCE:
;       GET_BOUNDS, oObj, xrange, yrange, zrange
;
; INPUTS:
;       oObj - An instance of an IDLgrModel or IDLgrGraphic.  The bounds
;               to be computed will include this object plus all of its
;               children.
; OUTPUTS:
;       xrange: A two-element vector, [xmin, xmax], representing the
;               overall range of the X data values of the objects in
;               the tree.
;       yrange: A two-element vector, [ymin, ymax], representing the
;               overall range of the Y data values of the objects in
;               the tree.
;       zrange: A two-element vector, [zmin, zmax], representing the
;               overall range of the Z data values of the objects in
;               the tree.
;
; MODIFICATION HISTORY:
;       Written by:     DD, February 1997.
;			RJF, Jan 1998.
;			Included Paul Nash's patch to avoid an improper call
;			to GetCTM()
;-
PRO get_bounds, oObj, xrange, yrange, zrange, CTM=ctm

    IF (OBJ_ISA(oObj, 'IDLgrModel')) THEN BEGIN
        ; Update current transformation matrix.
        oObj->GetProperty, TRANSFORM=modelCTM
        IF (N_ELEMENTS(ctm) EQ 0) THEN BEGIN
            ctm = modelCTM
        ENDIF ELSE BEGIN
            ctm = modelCTM # ctm
        ENDELSE

        ; Step thru children of the model.
        oChildArr = oObj->IDL_Container::Get(/ALL, COUNT=nKids)
        IF (nKids GT 0) THEN BEGIN
            ; Get first child's range.
            oChild = oChildArr[0]
            get_bounds, oChild, xrange, yrange, zrange, CTM=ctm

            IF (nKids GT 1) THEN BEGIN
                FOR i=1,nKids-1 DO BEGIN
                    oChild = oChildArr[i]
                    get_bounds, oChild, kidX, kidY, kidZ
                    xrange[0] = xrange[0] < kidX[0]
                    xrange[1] = xrange[1] > kidX[1]
                    yrange[0] = yrange[0] < kidY[0]
                    yrange[1] = yrange[1] > kidY[1]
                    zrange[0] = zrange[0] < kidZ[0]
                    zrange[1] = zrange[1] > kidZ[1]
                ENDFOR
            ENDIF
        ENDIF ELSE BEGIN
            MESSAGE, 'IDLgrModel object has no children. Zeroing Range.', $
                     /INFORMATIONAL
            xrange=[0.0,0.0]
            yrange=[0.0,0.0]
            zrange=[0.0,0.0]
        ENDELSE

    ENDIF ELSE IF (OBJ_ISA(oObj, 'IDLgrGraphic')) THEN BEGIN
        oObj->GetProperty, XRANGE=graphicX, YRANGE=graphicY, ZRANGE=graphicZ

        ; Ensure we have a transformation matrix.
        IF (N_ELEMENTS(ctm) EQ 0) THEN BEGIN
            ctm = identity(4)
        ENDIF

        ; Include any coordinate conversion.
        oObj->GetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys,ZCOORD_CONV=zs
        tmpTrans = [[xs[1],  0,   0,  xs[0]],$
                    [ 0,   ys[1], 0,  ys[0]],$
                    [ 0,      0,zs[1],zs[0]],$
                    [ 0,      0,  0,    1  ]]
        ctm = tmpTrans # ctm

        ; Consider all eight points transformed by CTM.
        FOR i=0,7 DO BEGIN
            p = [ graphicX[(i AND 1)],     $
                  graphicY[((i/2) AND 1)], $
                  graphicZ[((i/4) AND 1)], $
                  1.0] # ctm
            IF (p[3] NE 0.0) THEN p = p / p[3]  ; Divide by W.
            IF (i EQ 0) THEN BEGIN
                pmin = p
                pmax = p
            ENDIF ELSE BEGIN
                pmin = pmin < p
                pmax = pmax > p
            ENDELSE
            xrange = [pmin[0], pmax[0]]
            yrange = [pmin[1], pmax[1]]
            zrange = [pmin[2], pmax[2]]
        END

        nKids = 0
        oChild = OBJ_NEW()
    ENDIF ELSE BEGIN
        MESSAGE, 'Object must be an IDLgrModel or IDLgrGraphic.'
    ENDELSE

END
