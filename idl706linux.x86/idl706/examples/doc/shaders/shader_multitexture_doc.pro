;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_multitexture_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_multitexture_doc.pro
;
;  CALLING SEQUENCE: shader_multitexture_doc
;
;  PURPOSE:
;       Layer multiple textures on a polygon and use a
;       shader program to interactively blend the textures based
;       on the position of the mouse cursor. .
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY: Shaders
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       winobserver__define.pro
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       7/2006
;-
;-----------------------------------------------------------------
;
PRO shader_multitexture_doc

; Basic scene graph
oWin = OBJ_NEW('IDLitWindow', DIMENSIONS=[1024,512], RENDERER=0)
oView = OBJ_NEW('IDLgrView', COLOR=[0,100,0], VIEWPLANE_RECT=[125,300,256,128])
oModel = OBJ_NEW('IDLgrModel')
oWin->SetProperty, GRAPHICS_TREE=oView
oView->Add, oModel

; Read in the images. Base image will be contained in reserve
; uniform variable _IDL_ImageTextre and need not manually passed to shader
; program. The cloud image will need to be manually passed using
; SetUniformVariable (below).
READ_JPEG, FILEPATH('Day.jpg', SUBDIRECTORY=['examples', 'data']), day
oDay = OBJ_NEW('IDLgrImage', day)
READ_JPEG, FILEPATH('Clouds.jpg', SUBDIRECTORY=['examples', 'data']), clouds
oClouds = OBJ_NEW('IDLgrImage', clouds)

; Base image
oModel->Add, oDay

; Add a shader to blend in the clouds.
vertexFile = FILEPATH('multitextureVert.txt', SUBDIRECTORY=['examples', $
   'doc', 'shaders'])
fragmentFile = FILEPATH('multitextureFrag.txt', SUBDIRECTORY=['examples', $
   'doc', 'shaders'])

oShader = OBJ_NEW('IDLgrShader')
oShader->SetProperty, VERTEX_PROGRAM_FILENAME=vertexFile
oShader->SetProperty, FRAGMENT_PROGRAM_FILENAME=fragmentFile
oShader->SetUniformVariable, 'Clouds', oClouds
oDay->SetProperty, SHADER=oShader

; Mouse event observer.
oObs = OBJ_NEW('winobserver', oShader)
oWin->AddWindowEventObserver, oObs
oWin->SetEventMask, /BUTTON_EVENTS, /MOTION_EVENTS

oWin->Draw

END

