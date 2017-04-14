; $Id: //depot/idl/IDL_70/idldir/examples/doc/utilities/idlexshow3__define.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       IDLexShow3
;
; PURPOSE:
;       This object subclasses from the IDLgrModel object to combine
;	an image, surface mesh, and contour plot representation of a
;	given two-dimensional data set into a single entity.
;
; CATEGORY:
;       Object Graphics examples.
;
; CALLING SEQUENCE:
;
;       oObj = OBJ_NEW('IDLexShow3'[, Data] )
;
; KEYWORD PARAMETERS:
;
;       DATA - Set this keyword to a two-dimensional array of values to
;              be displayed as an image, surface mesh, and contour.
;
;       NO_COPY - Set this keyword to a nonzero value to indicate that
;              the value data may be taken away from the variable passed in 
;              via the DATA keyword and attached directly to the IDLexShow3 
;              object's data heap variable.
;
; MODIFICATION HISTORY:
;       Written by:     DLD, Jul 1998
;-
;----------------------------------------------------------------------------
; IDLexShow3::Init
;
FUNCTION IDLexShow3::Init, inData, DATA=data, NO_COPY=no_copy, _EXTRA=e

    ON_ERROR,2

    IF (self->IDLgrModel::Init(_EXTRA=e) NE 1) THEN RETURN,0

    ; Create a polygon.
    self.exPoly = OBJ_NEW('IDLgrPolygon', COLOR=[255,255,255], $
                          TEXTURE_COORD=[[0,0],[1,0],[1,1],[0,1]])
    IF (OBJ_VALID(self.exPoly)) THEN $
        self->IDLgrModel::Add, self.exPoly $
    ELSE BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDELSE
        
    ; Create a surface.
    self.exSurf = OBJ_NEW('IDLgrSurface')
    IF (OBJ_VALID(self.exSurf)) THEN $
        self->IDLgrModel::Add, self.exSurf $
    ELSE BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDELSE

    ; Create a contour.
    self.exCont = OBJ_NEW('IDLgrContour')
    IF (OBJ_VALID(self.exCont)) THEN $
        self->IDLgrModel::Add, self.exCont $
    ELSE BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDELSE

    ; Create the axes.
    self.exAxes[0] = OBJ_NEW('IDLgrAxis', 0, /EXACT)
    IF (OBJ_VALID(self.exAxes[0])) THEN $
        self->IDLgrModel::Add, self.exAxes[0] $
    ELSE BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDELSE
    self.exAxes[1] = OBJ_NEW('IDLgrAxis', 1, /EXACT)
    IF (OBJ_VALID(self.exAxes[1])) THEN $
        self->IDLgrModel::Add, self.exAxes[1] $
    ELSE BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDELSE
    self.exAxes[2] = OBJ_NEW('IDLgrAxis', 2, /EXACT)
    IF (OBJ_VALID(self.exAxes[2])) THEN $
        self->IDLgrModel::Add, self.exAxes[2] $
    ELSE BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDELSE

    ; Create an image for texture mapping.
    self.exImage = OBJ_NEW('IDLgrImage')
    IF (NOT OBJ_VALID(self.exImage)) THEN BEGIN
        self->IDLgrModel::Cleanup
        RETURN, 0
    ENDIF

    ; Create a palette for the image.
    self.exPal = OBJ_NEW('IDLgrPalette')
    IF (NOT OBJ_VALID(self.exPal)) THEN BEGIN
        self->IDLgrModel::Cleanup
        OBJ_DESTROY,self.exImage
        RETURN, 0
    ENDIF
    self.exPal->LoadCT, 0
    self.exImage->SetProperty, PALETTE=self.exPal

    ; Propagate the arguments and keywords.
    IF (N_ELEMENTS(inData) NE 0) THEN self->SetProperty, DATA=inData, $
        NO_COPY=KEYWORD_SET(nocopy) $
    ELSE IF (N_ELEMENTS(data) NE 0) THEN self->SetProperty, DATA=data, $
        NO_COPY=KEYWORD_SET(nocopy)

    RETURN,1
END

;----------------------------------------------------------------------------
; IDLexShow3::SetProperty
;
PRO IDLexShow3::SetProperty, DATA=data, NO_COPY=nocopy, _EXTRA=e

    ON_ERROR,2

    iNewData = 0

    ; Handle the superclass keywords.
    self->IDLgrModel::SetProperty, _EXTRA=e

    ; Handle the DATA keyword
    IF (N_ELEMENTS(data) NE 0) THEN BEGIN
        ; Check its validity
        si = SIZE(data,/TYPE)
        IF (si GE 6) THEN BEGIN
            MESSAGE,"DATA is not a supported type"
        END
        si = SIZE(data,/N_DIMENSIONS)
        IF (si NE 2) THEN BEGIN
            MESSAGE,"DATA must be a 2D array"
        END
        ; (re)place the data in the object
        IF (PTR_VALID(self.exdata)) THEN PTR_FREE,self.exdata
        self.exdata = PTR_NEW(data,NO_COPY=KEYWORD_SET(nocopy))

        IF (PTR_VALID(self.exdata)) THEN BEGIN
            ; Get the data bounds.
            zMax = MAX(*self.exdata, MIN=zMin)
            si = SIZE(data,/DIMENSIONS)
            xMax = si[0]-1
            yMax = si[1]-1

            ; set the data for each of the graphic objects.
            self.exImage->SetProperty,DATA=BYTSCL(*self.exData)
            self.exPoly->SetProperty, $
              DATA=[[0,0,zMin],[xMax,0,zMin],[xMax,yMax,zMin],[0,yMax,zMin]], $
              TEXTURE_MAP=self.exImage
            self.exSurf->SetProperty, DATAZ=*self.exData
            self.exCont->SetProperty, DATA_VALUES=*self.exData, $
                /PLANAR, GEOMZ=zMax
            self.exAxes[0]->SetProperty, RANGE=[0,xMax], $
                LOCATION=[0,0,zMin], TICKLEN=yMax*0.05
            self.exAxes[1]->SetProperty, RANGE=[0,yMax], $
                LOCATION=[0,0,zMin], TICKLEN=xMax*0.05
            self.exAxes[2]->SetProperty, RANGE=[zMin,zMax], $
                LOCATION=[0,yMax,zMin], TICKLEN=xMax*0.05
        ENDIF 
    ENDIF
END

;----------------------------------------------------------------------------
; IDLexShow3::GetProperty
;
PRO IDLexShow3::GetProperty, DATA=data, _REF_EXTRA=re

    ON_ERROR,2

    ; Handle the superclass properties.
    self->IDLgrModel::GetProperty, _EXTRA=re

    ; Return the class specific property values.
    IF (PTR_VALID(self.exdata)) THEN BEGIN
        data = *(self.exdata)
    END ELSE BEGIN
        data = 0
    END
END

;----------------------------------------------------------------------------
; IDLexShow3::Cleanup
;
PRO IDLexShow3::Cleanup

    ON_ERROR,2

    ; Cleanup any data stored in this class
    IF (PTR_VALID(self.exdata)) THEN PTR_FREE,self.exdata
    IF (OBJ_VALID(self.exImage)) THEN OBJ_DESTROY,self.exImage
    IF (OBJ_VALID(self.exPal)) THEN OBJ_DESTROY,self.exPal

    ; Cleanup the superclass.
    self->IDLgrModel::Cleanup
END

;----------------------------------------------------------------------------
; IDLexShow3__define
;
PRO IDLexShow3__define

    struct = { IDLexShow3, $
               INHERITS IDLgrModel, $
               exPal: OBJ_NEW(), $
               exImage: OBJ_NEW(), $        
               exPoly: OBJ_NEW(), $
               exSurf: OBJ_NEW(), $
               exCont: OBJ_NEW(), $
               exAxes: OBJARR(3), $
               exData: PTR_NEW() $
         }
END
