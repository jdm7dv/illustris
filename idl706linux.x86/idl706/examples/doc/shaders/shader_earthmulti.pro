;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_earthmulti.pro#2 $
;
;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_earthmulti.pro
;
;  CALLING SEQUENCE: shader_earthmulti
;
;  PURPOSE:
;       IDL Example application that displays a rotating Earth
;       using the shader program described in Chapter 10 of
;       the "Orange Book", "OpenGL Shading Language", Second Edition,
;       by Randi J. Rost.
;
;       This IDL code simply loads the textures, creates the Earth
;       spherical polygon. It then draws the rotating Earth using
;       the shader program from the Orange Book.  The shader programs
;       are taken from the Orange Book without any modification.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY: Shaders
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       none.
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

;; Timer and Widget Kill handler
pro shader_earthmulti_event, event
    if TAG_NAMES(event, /STRUCTURE_NAME) eq $
        'WIDGET_KILL_REQUEST' then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=state
        PRINT, FORMAT='(%"Measured frame rate = %5.1f (fps)")', $
            state.frames / (SYSTIME(1) - state.startTime)
        OBJ_DESTROY, state.oClean
        WIDGET_CONTROL, event.top, /DESTROY
    endif
    if TAG_NAMES(event, /STRUCTURE_NAME) eq $
        'WIDGET_TIMER' then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=state
        state.oEarthModel->Rotate, [0,0,1], state.rotDelta, /PREMULTIPLY
        state.oWin->Draw
        state.frames++
        WIDGET_CONTROL, event.top, TIMER=state.delay
        WIDGET_CONTROL, event.top, SET_UVALUE=state
    endif
end

pro shader_earthmulti

    winsize = 900

	;; Set up window, view, and models
    wBase = WIDGET_BASE(/COLUMN, /TLB_KILL_REQUEST_EVENTS)
    wDraw = WIDGET_DRAW(wBase, GRAPHICS_LEVEL=2, RENDERER=0, $
                        XSIZE=winsize, YSIZE=winsize)
    oView = OBJ_NEW('IDLgrView', COLOR=[0,100,0])
    oLightModel = OBJ_NEW('IDLgrModel')
    oEarthModel = OBJ_NEW('IDLgrModel')
    oView->Add, oLightModel
    oLightModel->Add, oEarthModel
    oEarthModel->Rotate, [1,1,0], 23  ;; natural tilt of the Earth
    oEarthModel->Rotate, [1,0,0], -90 ;; set the Earth upright

    ;; Make polygonal sphere and texture coords for the Earth
    MESH_OBJ, 4, v, p, FLTARR(100,100) + 0.9
    tc = FLTARR(2,100,100)
    for i=0, 99 do tc[0,*,i] = FINDGEN(100)/100
    for i=0, 99 do tc[1,i,*] = FINDGEN(100)/100

    ;; Create the Earth.
    oEarth = OBJ_NEW('IDLgrPolygon', v, POLYGONS=p, COLOR=[255,255,255], $
                     STYLE=2, SHADING=1)
    oEarthModel->Add, oEarth

    ;; All three textures are mapped to the surface with the same set of
    ;; texture coordinates, so we need to only pass one set for all
    ;; three textures.  Note that since we are using texture unit 0,
    ;; we could pass these coords with the TEXTURE_COORD property of
    ;; the IDLgrPolygon, but we'll do it this way here for illustration.
    oEarth->SetMultiTextureCoord, 0, tc

    ;; Create the shader with shader code in external files.
    ;; Note that these files are taken from the orange book
    ;; with no modifications.
    oShader = OBJ_NEW('IDLgrShader')
    oEarth->SetProperty, SHADER=oShader
    oShader->SetProperty, VERTEX_PROGRAM_FILENAME= $
        FILEPATH('earthVert.txt', SUBDIRECTORY=['examples', 'doc', 'shaders'])
    oShader->SetProperty, FRAGMENT_PROGRAM_FILENAME=$
        FILEPATH('earthFrag.txt', SUBDIRECTORY=['examples', 'doc', 'shaders'])

    ;; This is the sun.  It is way off on the right.
    oShader->SetUniformVariable, 'LightPosition', [100.0, 0.0, 0.0]

    ;; Read in the images for our three textures.
    READ_JPEG, FILEPATH('Day.jpg', $
                        SUBDIRECTORY=['examples', 'data']), day
    oDay = OBJ_NEW('IDLgrImage', day)
    READ_JPEG, FILEPATH('Clouds.jpg', $
                        SUBDIRECTORY=['examples', 'data']), clouds
    oClouds = OBJ_NEW('IDLgrImage', clouds)
    READ_JPEG, FILEPATH('Night.jpg', $
                        SUBDIRECTORY=['examples', 'data']), night
    oNight = OBJ_NEW('IDLgrImage', night)

    ;; Tell the shader program about our textures.
    oShader->SetUniformVariable, 'EarthDay', oDay
    oShader->SetUniformVariable, 'EarthNight', oNight
    oShader->SetUniformVariable, 'EarthCloudGloss', oClouds

	;; These objects are not in the Scene Graph, so we need
	;; a container for destroying them later.
    oClean = OBJ_NEW('IDL_Container')
    oClean->Add, [oShader, oDay, oClouds, oNight]

	;; Final set up
    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWin
    oWin->SetProperty, GRAPHICS_TREE=oView
    startTime = SYSTIME(1)
    state = { $
                oWin:oWin, $
                oEarthModel:oEarthModel, $
                rotDelta:0.1, $
                delay:1.0/100, $
                startTime: startTime, $
                frames: 0L, $
                oClean:oClean }
    WIDGET_CONTROL, wBase, TIMER=state.delay
    WIDGET_CONTROL, wBase, SET_UVALUE=state
    XMANAGER, 'shader_earthmulti', wBase
end
