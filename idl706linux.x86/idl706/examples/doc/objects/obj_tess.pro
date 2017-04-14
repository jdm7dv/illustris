; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/obj_tess.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
; The example uses the tessellator object to convert a concave
; polygon into a number of convex polygons (triangles). A "hole"
; is also placed into the polygon using tessellation.
;-------------------------------------------------------------

PRO obj_tess
        
; Create an object hierarchy.
oWin = OBJ_NEW('IDLgrWindow')
oView = OBJ_NEW('IDLgrView',VIEWPLANE_RECT=[-0.1,-0.1,1.2,1.2])
oModel = OBJ_NEW('IDLgrModel')

; Define vertices of a concave polygon.
fPoly1 = [[0,1],[0,0],[1,0],[1,.3],[.5,.3],[.5,.7],[1,.7],[1,1]]

; Define vertices of a second polygon, to add as a "hole".
fPoly2 = [[.2,.2],[.4,.2],[.4,.4],[.2,.4]]

; Create a filled polygon object and an outline polygon object.
; Both polygons objects will (eventually) contain multiple polygons
; and will display the same vertex data in two different ways.
oPoly = OBJ_NEW('IDLgrPolygon',STYLE=2,COLOR=[0,255,0])
oLine = OBJ_NEW('IDLgrPolygon',STYLE=1,COLOR=[0,0,255])

; Create the object hierarchy
oView->Add,oModel
oModel->Add,oPoly
oModel->Add,oLine

; Draw the existing concave polygon twice: once filled and once
; in outline. Note that the filled polygon is drawn incorrectly.

oPoly->SetProperty,DATA=fPoly1
oLine->SetProperty,DATA=fPoly1

oWin -> Draw, oView

; Prompt for user input before proceeding.
var=''
PRINT
PRINT, 'Initial polygon fill (without tesseleation) does not'
PRINT, 'produce the desired result.'
PRINT
READ, var, PROMPT='Press Return to tesselate and re-draw polygons.'


; Create a tessellator object.
oTess = OBJ_NEW('IDLgrTessellator')

; Convert a concave polygon to a series of triangles. The two
; polygon objects are changed to use the new convex polygon
; data.
oTess->AddPolygon,fPoly1
iStatus = oTess->tessellate(fVerts,iConn)
IF (iStatus eq 1) THEN BEGIN
   oPoly->SetProperty,DATA=fVerts,POLYGONS=iConn
   oLine->SetProperty,DATA=fVerts,POLYGONS=iConn
   oWin->Draw,oView
ENDIF ELSE BEGIN
   PRINT,'Unable to tessellate.'
   oWin->Erase
ENDELSE

; Prompt for user input before proceeding.
READ, var, PROMPT='Press Return to add a hole to the polygon'

; Add a hole to the polygon
oTess->Reset
oTess->AddPolygon,fPoly1
oTess->AddPolygon,fPoly2
iStatus = oTess->tessellate(fVerts,iConn)
IF (iStatus eq 1) THEN BEGIN
   oPoly->SetProperty,DATA=fVerts,POLYGONS=iConn
   oLine->SetProperty,DATA=fVerts,POLYGONS=iConn
   oWin->Draw,oView
ENDIF ELSE BEGIN
   PRINT,'Unable to tessellate.'
   oWin->Erase
ENDELSE

; Prompt for user input before proceeding.
READ, var, PROMPT='Press Return to destroy the objects.'

OBJ_DESTROY,oTess
OBJ_DESTROY,oWin
OBJ_DESTROY,oView

END
