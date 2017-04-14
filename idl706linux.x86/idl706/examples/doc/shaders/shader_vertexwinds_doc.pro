;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_vertexwinds_doc.pro#2 $
;
;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_vertexwinds_doc.pro
;
;  CALLING SEQUENCE: shader_vertexwinds_doc
;
;  PURPOSE:
;       This example displays the effect of wind on a set of particles.
;       The file globalwinds.dat contains the initial position and velocity
;       information for each particle. To create the animation, pass
;       the velocity information to the shader program in an attribute
;       variable using SetVertexAttributeData. The shader program updates the
;       vertices of the points and animates the particles.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY: Shaders
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
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
pro shader_vertexwinds_doc_event, event
    if TAG_NAMES(event, /STRUCTURE_NAME) eq $
        'WIDGET_KILL_REQUEST' then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=state
        PRINT, FORMAT='(%"Measured frame rate = %5.1f (fps)")', $
            state.frames / (SYSTIME(1) - state.startTime)
        OBJ_DESTROY, [state.oPal, state.oShader]
        WIDGET_CONTROL, event.top, /DESTROY
    endif
    if TAG_NAMES(event, /STRUCTURE_NAME) eq $
        'WIDGET_TIMER' then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=state
        state.oShader->SetUniformVariable, 'Time', state.time
        state.time += state.timeDelta
        if state.time gt 2.0 then $
            state.time = 0
        state.oWin->Draw
        state.frames++
        WIDGET_CONTROL, event.top, TIMER=state.delay
        WIDGET_CONTROL, event.top, SET_UVALUE=state
    endif
end

pro shader_vertexwinds_doc
    
    
    ;; Get initial positions and wind velocity data.
    RESTORE, FILE=FILEPATH('globalwinds.dat', $
                           SUBDIRECTORY=['examples', 'data'])
    
    ;; Set up point grid.
    pts = FLTARR(2, 128*64)
    FOR i=0, 63 DO BEGIN
        pts[0, i*128:(i+1)*128-1] = x
        pts[1, i*128:(i+1)*128-1] = y[i]
    ENDFOR
    
    ;; Set up per-sample velocity information.
    u = REFORM(u, 128*64)
    v = REFORM(v, 128*64)
    uv = TRANSPOSE([[u],[v]])
    
    ;; Create graphical object and associate the wind data.
    oPoints = OBJ_NEW('IDLgrPolygon', pts, STYLE=0, THICK=3)
    oPoints->SetVertexAttributeData, 'uv', uv
    
    vertexProgram = [ $
                        'attribute vec2 uv;', $
                        'uniform float Time;', $
                        'void main() {', $
                        'vec4 vert;', $
                        'vert = gl_Vertex + vec4(uv * Time, 0.0, 0.0);', $
                        'gl_Position = gl_ModelViewProjectionMatrix * vert;', $
                        '}']
    
    fragmentProgram = [ $
                          'void main() {', $
                          'gl_FragColor = vec4(1.0, 0.44, 0.122, 0.8);', $
                          '}']
    
    ;; Set up shader object.
    oShader = OBJ_NEW('IDLgrShader')
    oShader->SetProperty, $
        VERTEX_PROGRAM_STRING=STRJOIN(vertexProgram, STRING(10b)), $
        FRAGMENT_PROGRAM_STRING=STRJOIN(fragmentProgram, STRING(10b))
    oPoints->SetProperty, SHADER=oShader
    
    ;; Set up window, view, and models
    wBase = WIDGET_BASE(/COLUMN, /TLB_KILL_REQUEST_EVENTS)
    wDraw = WIDGET_DRAW(wBase, GRAPHICS_LEVEL=2, RENDERER=0, $
                        XSIZE=1080, YSIZE=540)
    oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-180, -90, 360, 180])
    oModel = OBJ_NEW('IDLgrModel')
    oView->Add, oModel
    
    ;; Access background image.
    READ_PNG, FILEPATH('avhrr.png', SUBDIR=['examples','data']), image, r, g, b
    oPal = OBJ_NEW('IDLgrPalette', r, g, b)
    oImage = OBJ_NEW('IDLgrImage', image, PALETTE=oPal, $
                     LOCATION=[-180, -90], DIMENSIONS=[360,180], $
                     DEPTH_WRITE_DISABLE=1)
    
    oModel->Add, oImage
    oModel->Add, oPoints
    
    ;; Final set up
    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWin
    oWin->SetProperty, GRAPHICS_TREE=oView
    startTime = SYSTIME(1)
    timeDelta = 0.01
    state = { $
                oWin:oWin, $
                time:0.0, $
                timeDelta:timeDelta, $
                delay:1.0/100, $
                startTime: startTime, $
                frames: 0L, $
                oPal:oPal, $
                oShader:oShader }
    WIDGET_CONTROL, wBase, TIMER=state.delay
    WIDGET_CONTROL, wBase, SET_UVALUE=state
    XMANAGER, 'shader_vertexwinds_doc', wBase
    
end
