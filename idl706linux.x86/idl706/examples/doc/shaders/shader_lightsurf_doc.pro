;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_lightsurf_doc.pro#2 $
;
;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_lightsurf_doc.pro
;
;  CALLING SEQUENCE: shader_lightsurf_doc
;
;  PURPOSE:
;       Shader Program Demo
;       Demonstrates usage of a vertex shader to move a
;       portion of a rendered surface.
;
;       Also demonstrates how to implement lighting in a
;       vertex shader to replace the lighting done by
;       the OpenGL fixed-function pipeline.
;
;       Note: One weak area of this approach is that
;       surface normals are not recomputed or adjusted
;       as the displacement is applied.  So, if the surface
;       is changed a great deal from its original shape,
;       the lighting may not be accurate.
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
pro shader_lightsurf_doc_event, event
    if TAG_NAMES(event, /STRUCTURE_NAME) eq $
        'WIDGET_KILL_REQUEST' then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=state
        PRINT, FORMAT='(%"Measured frame rate = %5.1f (fps)")', $
            state.frames / (SYSTIME(1) - state.startTime)
        OBJ_DESTROY, state.oShader
        WIDGET_CONTROL, event.top, /DESTROY
    endif
    if TAG_NAMES(event, /STRUCTURE_NAME) eq $
        'WIDGET_TIMER' then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=state
        state.oShader->SetUniformVariable, 'Time', state.time
        state.time += state.timeDelta
        if state.time gt 1.0 OR state.time lt 0.0 then $
            state.timeDelta *= -1
        state.oWin->Draw
        state.frames++
        WIDGET_CONTROL, event.top, TIMER=state.delay
        WIDGET_CONTROL, event.top, SET_UVALUE=state
    endif
end

pro shader_lightsurf_doc
    
    winsize = 500
    ;; Set up window, view, and models
    wBase = WIDGET_BASE(/COLUMN, /TLB_KILL_REQUEST_EVENTS)
    wDraw = WIDGET_DRAW(wBase, GRAPHICS_LEVEL=2, RENDERER=0, $
                        XSIZE=winsize, YSIZE=winsize)
    oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-10, -10, 120, 120], $
                    ZCLIP=[500, -500], EYE=501, COLOR=[43, 180, 78])
    
    ;; Generate surface data and create surface object.
    surfdata = BESELJ(SHIFT(dist(100), 50, 50) / 2,0) * 40
    oSurface = OBJ_NEW('IDLgrSurface', surfdata, STYLE=2, COLOR=[200,200,40])
    
    ;; The displacement array is a sort of mask that indicates what part
    ;; of the surface will be displaced in the animation and by how much.
    ;; This information is passed to the shader via vertex attributes.
    disp = FLTARR(100,100)
    disp[50:99, 50:99] = MAX(surfdata)
    oSurface->SetVertexAttributeData,'Displacement', REFORM(disp, 100*100)
    
    ;; Create model for visible object and rotate for good viewing angle
    oModel = OBJ_NEW('IDLgrModel')
    oModel->Add, oSurface
    oModel->Translate, -50, -50, 0
    oModel->Rotate, [0,0,1], -30
    oModel->Rotate, [1,0,0], -60
    oModel->Translate, 50, 50, 0
    
    ;; Access shader program files.
    vertexFile=FILEPATH('lightSurfVert.txt', $
                        SUBDIRECTORY=['examples','doc', 'shaders'])
    fragmentFile=FILEPATH('lightSurfFrag.txt', $
                          SUBDIRECTORY=['examples','doc', 'shaders'])
    
    ;; Create shader and associate vertex and fragment programs.
    oShader = OBJ_NEW('IDLgrShader')
    oShader->SetProperty, VERTEX_PROGRAM_FILENAME=vertexFile, $
        FRAGMENT_PROGRAM_FILENAME=fragmentFile
    
    ;; Associate shader with the surface. You can comment out
    ;; this line to run without the shader program.
    oSurface->SetProperty, SHADER=oShader
    
    ;; Set up the lights
    ;; We pick an arbitrary index for the positional light and pass it along
    ;; to our vertex shader so that it can find the light parameters needed
    ;; for lighting calculations.
    oLightModel = OBJ_NEW('IDLgrModel')
    oLightModel->Add, OBJ_NEW('IDLgrLight', TYPE=0, COLOR=[100, 50, 40])
    oLightModel->Add, OBJ_NEW('IDLgrLight', TYPE=1, LOCATION=[200,200,500], $
                              COLOR=[255,255,255], INTENSITY=0.8, $
                              LIGHT_INDEX=4)
    
    ;; The generated shader program (lightSurfVert.txt) requires an integer (4)
    ;; rather than a table entry (gl_LightSource[4]) to identify the light.
    ;; While defining a uniform variable for a light index value is not a
    ;; requirement, using DirectionalLightIndex in the shader program code
    ;; makes it easier to understand than hard-coding the number 4.
    oShader->SetUniformVariable, 'DirectionalLightIndex', 4
    oLightModel->Add, oModel
    oView->Add, oLightModel

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
                oShader:oShader }
    WIDGET_CONTROL, wBase, TIMER=state.delay
    WIDGET_CONTROL, wBase, SET_UVALUE=state
    XMANAGER, 'shader_lightsurf_doc', wBase
end
