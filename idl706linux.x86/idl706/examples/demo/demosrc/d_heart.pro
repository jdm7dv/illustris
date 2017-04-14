; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_heart.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_heart.pro
;
;  CALLING SEQUENCE: d_heart
;
;  PURPOSE:
;       Display an animation of a beating heart
;
;  MAJOR TOPICS: Animation and widgets
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_heartWin3dEvent         - Handle viewing area events
;       fun d_heartAxis3d             - Handle the 3-D axis event
;       pro d_heartMenuEvent          - Handle the QUIT and INFO events
;       pro d_heartOptionEvent        - Handle menu bar options events
;       pro d_heartEvent       - Handle heart events (left column)
;       pro d_heartCleanup     - Cleanup
;       pro d_heart             - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       heart.tip
;       heart.sav                - Data file
;       pro trackball__define.pro - Create a trackball object
;       pro demo_gettips         - Read the tip file and create widgets
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODifICATION HISTORY:
;       WRITTEN, SDG, RSI, DEC, 1996.
;
;-------------------------------------------------------
;
;  PURPOSE : Handle rotations, quit on any button except left.
;
pro d_heartWin3dEvent,  $
    sEvent      ;  IN: event structure

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=UVALUE, /NO_COPY

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY

    ;  Expose.
    ;
    if (sEvent.type EQ 4) then begin
        state.oWindow->Draw, state.oView
    endif

    ;  Handle trackball update
    ;
    bHaveTransform = state.oTrack->Update(sEvent, TRANSFORM=qmat )
    if (bHaveTransform NE 0) then begin
        state.top3D->GetProperty, TRANSFORM=t
        mt = t # qmat
        state.top3D->SetProperty,TRANSFORM=mt
    endif

    ;  Button press event.
    ;
    if (sEvent.type EQ 0) then begin
        state.btndown = 1B
        state.oWindow->SetProperty, QUALITY=state.dragq
        WIDGET_CONTROL, sEvent.id, /DRAW_MOTION
    endif

    ;  Button release.
    ;
    if (sEvent.type EQ 1) then begin
        if (state.btndown EQ 1b) then begin
            state.oWindow->SetProperty, QUALITY=2
            state.oWindow->Draw, state.oView
        endif
        state.btndown = 0b
        WIDGET_CONTROL, sEvent.id, DRAW_MOTION=0
    endif

    ;  Button motion.
    ;
    if ((sEvent.type EQ 2) and (state.btndown EQ 1b)) then begin
        if (bHaveTransform) then begin
            state.oWindow->Draw, state.oView
        endif
    endif

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
END

;-------------------------------------------------------
;
;  PURPOSE : Draw an axis given extents
;
;
;      Exts = [xmin, xmax, ymin, ymax, zmin, zmax]
;      Exts = [  0     1     2     3    4      5 ]
;
function d_heartAxis3d, $
    exts, $       ; IN: extents 
    parent_obj, $ ; IN: parent model
    color1, $     ; IN: Color of x axis
    color2, $     ; IN: Color oa z axis
    color3        ; IN: Color of y axis

    xverts = [exts[0], exts[1], 0.0, 0.0, 0.0, 0.0]
    yverts = [0.0, 0.0, exts[2], exts[3], 0.0, 0.0]
    zverts = [0.0, 0.0, 0.0, 0.0, exts[4], exts[5]]

    p1 = [2,0,1]
    p2 = [2,2,3]
    p3 = [2,4,5]

    axis_obj = OBJ_NEW('IDLgrModel')
 
    axis_x = OBJ_NEW('IDLgrpolyline', xverts, yverts, zverts, $
        POLYLINES=p1, COLOR=color1)

    axis_y = OBJ_NEW('IDLgrpolyline', xverts, yverts, zverts, $
        POLYLINES=p2, COLOR=color3)

    axis_z = OBJ_NEW('IDLgrpolyline', xverts, yverts, zverts, $
        POLYLINES=p3, COLOR=color2)
   
    ;  Add the parts of the box to the box_obj.
    ;
    axis_obj->Add, axis_x
    axis_obj->Add, axis_y
    axis_obj->Add, axis_z
 
    RETURN, axis_obj

end ; d_heartAxis3d

; -----------------------------------------------------------------------------
;
; Purpose:  Main event handler
;
pro d_heartMenuEvent, $
    sEvent          ; IN: event structure

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=UVALUE

    case UVALUE of

        'QUIT' : begin
            WIDGET_CONTROL, sEvent.top, /DESTROY
        end ; Case of QUIT

        'INFO' : begin
            ONLINE_HELP, 'd_heart', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
         end   ; of INFO

    endcase ; of UVALUE

end ; end of d_heartMenuEvent

; -----------------------------------------------------------------------------
;
;  Purpose:  Options menu event handler
;
pro d_heartOptionEvent, $
    sEvent          ; IN: event structure

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=UVALUE

    case UVALUE of

        ;  Set shading to flat.
        ;
        'FLAT': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            state.heart_inner->SetProperty, SHADING=0
            state.heart_outer->SetProperty, SHADING=0
            state.heart_bot->SetProperty, SHADING=0
            WIDGET_CONTROL, state.wFlatButton, SENSITIVE=0
            WIDGET_CONTROL, state.wGouraudButton, SENSITIVE=1
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of FLAT

        ;  Set shading to Gouraud.
        ;
        'GOURAUD': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            state.heart_inner->SetProperty, SHADING=1
            state.heart_outer->SetProperty, SHADING=1
            state.heart_bot->SetProperty, SHADING=1
            WIDGET_CONTROL, state.wFlatButton, SENSITIVE=1
            WIDGET_CONTROL, state.wGouraudButton, SENSITIVE=0
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of GOURAUD

        ;  Set style to wire.
        ;
        'WIRE': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            state.heart_inner->SetProperty, STYLE=1
            state.heart_outer->SetProperty, STYLE=1
            state.heart_bot->SetProperty, STYLE=1
            WIDGET_CONTROL, state.wWireButton, SENSITIVE=0
            WIDGET_CONTROL, state.wSolidButton, SENSITIVE=1
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of WIRE

        ;  Set style to solid.
        ;
        'SOLID': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            state.heart_inner->SetProperty, STYLE=2
            state.heart_outer->SetProperty, STYLE=2
            state.heart_bot->SetProperty, STYLE=2
            WIDGET_CONTROL, state.wWireButton, SENSITIVE=1
            WIDGET_CONTROL, state.wSolidButton, SENSITIVE=0
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of SOLID

        ;  Set the drag quality to low.
        ;
        'LOW': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            state.dragq = 0
            WIDGET_CONTROL, state.wDragLowButton, SENSITIVE=0
            WIDGET_CONTROL, state.wDragHiButton, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of LOW

        ;  Set the drag quality to high.
        ;
        'HIGH': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            state.dragq = 2
            WIDGET_CONTROL, state.wDragLowButton, SENSITIVE=1
            WIDGET_CONTROL, state.wDragHiButton, SENSITIVE=0
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of HIGH

    ENDCASE ; of UVALUE

END ; end of d_heartOptionEvent

; -----------------------------------------------------------------------------
;
; Purpose:  Main menu event handler: heart_event
;

pro d_heartEvent, $
    sEvent             ; IN: event structure

    ;  Quit this application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WIDGET_CONTROL, sEvent.id, get_UVALUE=UVALUE

    case UVALUE of

        ;  Reset the initial orientation of the view.
        ;
        'RESET' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            state.top3D->SetProperty, TRANSFORM=state.initTM
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END; Case of RESET

        ;  Toggle between hiding or showing the outer surface.
        ;
        'OUTER' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            if (sEvent.select EQ 0) then HIDE=1 else HIDE=0
            state.heart_outer->SetProperty, HIDE=hide
            ; Update the view
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of OUTER

        ;  Toggle between hiding or showing the inner surface.
        ;
        'INNER' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            if (sEvent.select EQ 0) then HIDE=1 else HIDE=0
            state.heart_inner->SetProperty, HIDE=hide
            ; Update the view
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of INNER

        ;  Toggle between hiding or showing the bottom surface.
        ;
        'BOTTOM' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            if (sEvent.select EQ 0) then HIDE=1 else HIDE=0
            state.heart_bot->SetProperty, HIDE=hide
            ; Update the view
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of BOTTOM

        ;  Toggle between hiding or showing the 3 axes.
        ;
        'AXIS' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            if (sEvent.select EQ 0) then HIDE=1 else HIDE=0
            state.axis_obj->SetProperty, HIDE=hide
            ; Update the view
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of AXIS

        ;  Toggle between hiding or showing the light icons.
        ;
        'LITES' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            if (sEvent.select EQ 0) then HIDE=1 else HIDE=0
            state.lite1_icon->SetProperty, HIDE=hide
            state.lite2_icon->SetProperty, HIDE=hide
            ; Update the view
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of LITES

        ;  Toggle between hiding or showing the annotation text.
        ;
        'ANNO' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            if (sEvent.select EQ 0) then HIDE=1 else HIDE=0
            state.annotation->SetProperty, HIDE=hide
            ; Update the view
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of ANNO

        ;  Animate the display. Make the heart to beat.
        ;
        'START' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            ; Update the view
            i = (state.current_frame + 1) MOD 16
            for j = 0,15 do begin
                state.heart_inner->SetProperty, $
                    DATA=REFORM(state.i_verts[i,*,*])
                state.heart_outer->SetProperty, $
                    DATA=REFORM(state.o_verts[i,*,*])
                state.heart_bot->SetProperty, $
                    DATA=REFORM(state.b_verts[i,*,*])
                state.oWindow->Draw, state.oView
                i = (i + 1) MOD 16
            endfor  ;  of  j
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of CPR

        ;  Show only the next frame.
        ;
        'STEP' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            i = (state.current_frame + 1)  MOD 16
            state.heart_inner->SetProperty, $
                DATA=REFORM(state.i_verts[i,*,*])
            state.heart_outer->SetProperty, $
                DATA=REFORM(state.o_verts[i,*,*])
            state.heart_bot->SetProperty, $
                DATA=REFORM(state.b_verts[i,*,*])
            ; Update the view
            state.oWindow->Draw, state.oView
            state.current_frame = i
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        END ; Case of SKIP

    ENDCASE
END

;-----------------------------------------------------------------
;
;    PURPOSE : cleanup procedure. restore colortable, destroy objects.
;
pro d_heartCleanup, wBase

    WIDGET_CONTROL, wBase, GET_UVALUE=state, /NO_COPY

    ;  Destroy the top objects
    ;
    OBJ_DESTROY, state.oView
    OBJ_DESTROY, state.font18
    OBJ_DESTROY, state.font24
    OBJ_DESTROY, state.font_sm
    OBJ_DESTROY, state.font_big
    OBJ_DESTROY, state.title1
    OBJ_DESTROY, state.title2
    OBJ_DESTROY, state.oTrack
    OBJ_DESTROY, state.oFont
    OBJ_DESTROY, state.oText
    OBJ_DESTROY, state.oContainer

    ;  Restore the color table
    ;
    TVLCT, state.colorTable

    if widget_info(state.groupBase, /valid) then $
        widget_control, state.groupBase, /map

end   ;  of Texture_Cleanup


;-----------------------------------------------------
;
;  PURPOSE The beating heart main procedure. This application
;          shows a beating heart.
;
PRO d_heart, $
    filename=filename, $ ; IN: (opt) data file name
    xdim=xdim, $         ; IN: (opt) x dimension
    ydim=ydim, $         ; IN: (opt) y dimension
    GROUP=group, $       ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB      ; OUT: (opt) TLB of this application

    if (N_ELEMENTS(filename) EQ 0) then filename='heart.sav'

    ;  Check the validity of the group identifier
    ;
    ngroup = N_ELEMENTS(group)
    if(ngroup NE 0) then begin
        groupStatus = WIDGET_INFO( group, /VALID_ID)
        if(groupStatus EQ 0) then begin
            print, 'Group leader identifier not valid'
          print, ' Exiting program'
          RETURN
        endif
        groupBase = group
    endif else groupBase = 0L

    ;  Get the current color vectors to restore
    ;  when this application is exited.
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ; Build color table from color vectors
    ;
    colorTable = [[savedR],[savedG],[savedB]]

    ;  Get the screen size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize

    if (!D.N_COLORS LE 256) then begin
        string = 'This application is optimized for >256 colors'
        res = DIALOG_MESSAGE(string, /INFORMATION)
    endif

    if (N_ELEMENTS(xdim) EQ 0) then begin
        xdim = 0.6 * screenSize[0]
    end ; if xdim

    if (N_ELEMENTS(ydim) EQ 0) then begin
        ydim = 0.8 * xdim
    endif

    ;  Set debug flag for comments.
    ;
    debug = 1

    ;  Create the top level base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wBase = WIDGET_BASE(/COLUMN, $
            TITLE="Beating Heart", $
            /TLB_KILL_REQUEST_EVENTS, $
            XPAD=0, YPAD=0, $
            TLB_FRAME_ATTR=1, MBAR=mbarbase)
    endif else begin
        wBase = WIDGET_BASE(/COLUMN, $
            TITLE="Beating Heart", $
            XPAD=0, YPAD=0, $
            TLB_FRAME_ATTR=1, MBAR=mbarbase, $
            /TLB_KILL_REQUEST_EVENTS, $
            GROUP_LEADER=group)
    endelse

    ;  Create the file|quit button.
    ;
    wFileButton = WIDGET_BUTTON(mbarbase,VALUE = 'File',/Menu)

        wQuitButton = WIDGET_BUTTON(wFileButton, $
            VALUE = 'Quit',UVALUE='QUIT', $
            EVENT_PRO='d_heartMenuEvent')

    ;  Create the option menu.
    ;
    wOptionButton = WIDGET_BUTTON(mbarbase,VALUE = 'Options',/Menu)

        ; Create the Shading Options Button.
        ;
        wShadingButton = WIDGET_BUTTON(wOptionButton, $
            EVENT_PRO='d_heartOptionEvent', $
            VALUE = 'Shading',UVALUE='Shading',/MENU)

            wFlatButton = WIDGET_BUTTON(wShadingButton, $
                EVENT_PRO='d_heartOptionEvent', $
                VALUE = 'Flat',UVALUE='FLAT')
 
            wGouraudButton = WIDGET_BUTTON(wShadingButton, $
                EVENT_PRO='d_heartOptionEvent', $
                VALUE = 'Gouraud',UVALUE='GOURAUD')

        ; Create the Style Options Button.
        ;
        wStyleButton = WIDGET_BUTTON(wOptionButton, $
            EVENT_PRO='d_heartOptionEvent', $
            VALUE = 'Style',UVALUE='STYLE',/MENU)

            wWireButton = WIDGET_BUTTON(wStyleButton, $
                EVENT_PRO='d_heartOptionEvent', $
                VALUE = 'Wire',UVALUE='WIRE')

            wSolidButton = WIDGET_BUTTON(wStyleButton, $
                EVENT_PRO='d_heartOptionEvent', $
                VALUE = 'Solid',UVALUE='SOLID')

        ; Create the Drag Quality Options Button.
        ;
        wDragButton = WIDGET_BUTTON(wOptionButton, $
            EVENT_PRO='d_heartOptionEvent', $
            VALUE = 'Drag Quality', UVALUE='DRAG',/MENU)

            wDragLowButton = WIDGET_BUTTON(wDragButton, $
                EVENT_PRO='d_heartOptionEvent', $
                VALUE = 'Low',UVALUE='LOW')

            wDragHiButton = WIDGET_BUTTON(wDragButton, $
                EVENT_PRO='d_heartOptionEvent', $
                VALUE = 'High',UVALUE='HIGH')

    ; Create the help|about button.
    ;
    wHelpButton = WIDGET_BUTTON(mbarbase, $
        VALUE='About', /HELP, /MENU)

        wAboutButton = WIDGET_BUTTON(wHelpButton, $
            EVENT_PRO = 'd_heartMenuEvent', $
            VALUE = 'About Beating Heart',UVALUE='INFO')

    ;  Create the first child of the top level base (wBase).
    ;
    wTopRowBase =  WIDGET_BASE(wBase, Column = 2)

        ;  Create a base for the left column.
        ;
        wLeftBase = WIDGET_BASE(wTopRowBase, $
            /BASE_ALIGN_LEFT, Column=1,/Frame)

            ;  Create the Object Toggle Area.
            ;
            wObjToggleArea = WIDGET_BASE(wLeftBase, /column, /Frame)

                wObjTogLabel = WIDGET_LABEL(wObjToggleArea, $
                    /align_center, $
                    value='Geometry Visiblity')

                wObjToggleBase = WIDGET_BASE(wObjToggleArea, $
                    /column, /NONEXCLUSIVE)

                    wObj1Toggle = WIDGET_BUTTON(wObjToggleBase, $
                        VALUE="Outer Surface", $
                        UVALUE='OUTER', EVENT_PRO='d_heartEvent')

                    wObj2Toggle = WIDGET_BUTTON(wObjToggleBase, $
                        VALUE="Inner Surface", $
                        UVALUE='INNER', EVENT_PRO='d_heartEvent')

                    wObj3Toggle = WIDGET_BUTTON(wObjToggleBase, $
                        VALUE="Bottom Surface", $
                        UVALUE='BOTTOM', EVENT_PRO='d_heartEvent')

                    wObj5Toggle = WIDGET_BUTTON(wObjToggleBase, $
                        VALUE='3D Axis', $
                        UVALUE='AXIS', EVENT_PRO='d_heartEvent')

                    wObj6Toggle = WIDGET_BUTTON(wObjToggleBase, $
                        VALUE="Light Icons", $
                        UVALUE='LITES', EVENT_PRO='d_heartEvent')

                    wObj7Toggle = WIDGET_BUTTON(wObjToggleBase, $
                        VALUE="Annotations", $
                        UVALUE='ANNO', EVENT_PRO='d_heartEvent')

            ;  Create a Animation buttons.
            ;
            wAnimArea = WIDGET_BASE(wLeftBase, /column, /Frame)

                beat_label = WIDGET_LABEL(wAnimArea, $
                    VALUE="Heartbeat Cycle")

                cpr_button = WIDGET_BUTTON(wAnimArea, $
                    VALUE="Start", UVALUE='START')

                stop_button = WIDGET_BUTTON(wAnimArea, $
                    VALUE="Step", UVALUE='STEP')

             reset_button = WIDGET_BUTTON(wLeftBase, $
                 VALUE="Reset Orientation", UVALUE='RESET')

        ;  A.Create a base for the right column
        ;
        wRightBase = WIDGET_BASE(wTopRowBase, Column=1, /Frame)

            wDraw3D = widget_draw(wRightBase, $
                XSIZE=xdim, YSIZE=ydim, /BUTTON_EVENTS, $
                UVALUE='DRAW', RETAIN=0, $
                EVENT_PRO='d_heartWin3dEvent', /EXPOSE_EVENTS, $
                GRAPHICS_LEVEL=2)

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wBase, MAP=0, /ROW)

    ;  Here, all the wideget has been created, now relaize them.
    ;
    WIDGET_CONTROL, wBase, /REALIZE

    ;  Set the state of the buttons.
    ;
    WIDGET_CONTROL, wObj1Toggle, SET_BUTTON=1
    WIDGET_CONTROL, wObj2Toggle, SET_BUTTON=1
    WIDGET_CONTROL, wObj3Toggle, SET_BUTTON=1
    WIDGET_CONTROL, wObj5Toggle, SET_BUTTON=0
    WIDGET_CONTROL, wObj6Toggle, SET_BUTTON=0
    WIDGET_CONTROL, wObj7Toggle, SET_BUTTON=1

    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wBase

    ;  Get the tips.
    ;
    sText = demo_getTips(demo_filepath('heart.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wBase, $
                         wStatusBase)

    WIDGET_CONTROL, wDraw3D, GET_VALUE=oWindow

    ;  Desensitize everything while loading the data.
    ;
    WIDGET_CONTROL, wBase, SENSITIVE=0

    ident = [[1.0,0,0,0], $
        [0.0,1,0,0], $
        [0.0,0,1,0], $
        [0.0,0,0,1]]

    ;  Define Colors.
    ;
    white = [255,255,255]
    red = [255,0,0]
    green = [0,255,0]
    blue = [0,0,255]
    purple = [255,0,255]

    ;  Define the Graphics View.
    ;
    oView = OBJ_NEW('IDLgrView', COLOR=[0,0,0], PROJECTION=1, $
        VIEWPLANE_RECT=[-20,-20,40,40], EYE=21.0, ZCLIP=[20, -20])

    ;  Make the text location to be centered.
    ;
    myview = [-20,-20,40,40]
    textLocation = [myview[0]+0.5*myview[2], myview[1]+0.5*myview[3]]

    ;  Create and display the PLEASE WAIT text.
    ;
    oFont = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=18)
    oText = OBJ_NEW('IDLgrText', $
        'Starting up  Please wait...', $
        ALIGN=0.5, $
        LOCATION=textLocation, $
        COLOR=[255,255,0], FONT=oFont)


    aspect = FLOAT(xdim)/FLOAT(ydim)

    ; Define top level model.
    ;
    top = OBJ_NEW('IDLgrModel')

    top->Add, oText

    ;  top3D is the top object for transformable objects.
    ;
    top3D = OBJ_NEW('IDLgrModel')
    top->Add, top3D

    ;  Add the top object to the view.
    ;
    oView->Add, top

    ;  Draw the starting up screen.
    ;
    oWindow->Draw, oView

    ;  Draw the Text and Title.
    ;
    if (screensize[0] LT 800) then begin
        font_sm = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=10. )
        font_big = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=14. )
    endif else begin
        font_sm = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=14. )
        font_big = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=18. )
    endelse

    font24 = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=24. )
    font18 = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=18. )

    ;  Ceate the annotation.
    ;
    annotation = OBJ_NEW('IDLgrModel')
    top->Add, annotation

    title1 = OBJ_NEW('IDLgrText', LOCATION=[-19,-17], $
                   'Data Courtesy of: ', $
                   color=[0,255,0], font=font_sm)

    ;  Add Title1 to the Annotation Object.
    ;
    annotation->Add, title1

    title2 = OBJ_NEW('IDLgrText', LOCATION=[-19,-19], $
        'Dr. Stephan Nekolla', $
        COLOR=[0,255,0], FONT=font_sm)

    ;  Add Title2 to the Annotation Object.
    ;
    annotation->Add, title2

    ;  Create the Heart Object.
    ;
    heart = OBJ_NEW('IDLgrModel')
    top3D->Add, heart

    ;  Draw the red bounding box.
    ;
    extents = [-40.0, 40.0, -20.0, 20.0, -20.0, 20.0]
    axis_obj = d_heartAxis3d(extents, top3D, red, green, blue)
    top3D->Add,axis_obj
    axis_obj->SetProperty, HIDE=1

    ;  Draw an axis from xmin to xmax etc...
    ;
    extents = [-20.0, 20.0, -20.0, 20.0, -20.0, 0.0]
   
    ;  Define some colors in RGB space.
    ;
    red =   [250, 10,  10]
    green = [10,  250, 10]
    blue =  [10,  10,  250]

    ;  Compute the first geometry.
    ;
    case !VERSION.OS_FAMILY of
        'unix' : dirsep = '/'
        else   : dirsep = '\'
    endcase
   
    ;  heart_file = 'data' + dirsep + 'gated_15.sav'
    ;
    heart_file = demo_filepath('heart.sav', $
                SUBDIR=['examples','demo','demodata'])
    restore, heart_file

    ;  Generate the inner layer from the first frame of data.
    ;
    heart_inner = OBJ_NEW('IDLgrPolygon', $
        REFORM(I_VERTS[0,*,*]), $
        polygons=REFORM(I_POLYS[0,*]), $
        SHADING=1, $
        vert_color=REFORM(I_COLOR[0,*,*]))
    heart->Add, heart_inner

    ;  Generate the outer layer from the first frame of data.
    ;
    heart_outer = OBJ_NEW('IDLgrPolygon', $
        REFORM(O_VERTS[0,*,*]), $
        polygons=REFORM(O_POLYS[0,*]), $
               SHADING=1, $
        vert_color=REFORM(O_COLOR[0,*,*]))
    heart->Add, heart_outer

    ;  Generate the Bottom layer from the first frame of data.
    ;
    heart_bot = OBJ_NEW('IDLgrPolygon', $
        REFORM(B_VERTS[0,*,*]), $
        polygons=REFORM(B_POLYS[0,*]), $
        SHADING=1, $
        vert_color=REFORM(B_COLOR[0,*,*]))
    heart->Add, heart_bot

    ;  Get and Set properties on the bounds of the geometry.
    ;
    ;  X Min/MAX for Inner:       18.0476      38.9740
    ;  Y Min/MAX for Inner:       87.8208      108.416
    ;  Z Min/MAX for Inner:       6.42048      22.5585
    ;  X Min/MAX for Outer:       15.0989      43.3261
    ;  Y Min/MAX for Outer:       84.3699      112.872
    ;  Z Min/MAX for Outer:       1.65995      26.6269
    ;  Color Min/MAX:             3.83333      42.5000
    ;
    xr = [18, 40]
    yr = [85, 115]
    zr = [0.0, 30.0]
    cr = [3.8, 42.5]

    ; Determine the translation required to fit data within plotview,
    ; and its inverse.
    ;
    xc = -29.0
    yc = -98.0
    zc = -13.0
    heart->translate, xc, yc, zc

    ;  Generate the light sources.
    ;
    li_xverts = [-1.0, 1.0, 0.0, 0.0, 0.0, 0.0]
    li_yverts = [0.0, 0.0, 1.0, -1.0, 0.0, 0.0]
    li_zverts = [0.0, 0.0, 0.0, 0.0, 1.0, -1.0]
    li_pl = [2,0,1,$
            2,2,3,$
            2,4,5]

    ;  Generate an ambient light source.
    ;
    lite0 = OBJ_NEW('IDLgrLight', TYPE=0, COLOR=[200,200,200])
    top->Add, lite0

    ;  Generate the first light source.
    ;
    lite1_icon = OBJ_NEW('IDLgrModel')
    top->Add, lite1_icon
    lite1_icon->SetProperty, HIDE=1
    lite1_x = 19.0
    lite1_y = 19.0
    lite1_z = 10.0
    lite1_icon_pl = OBJ_NEW('IDLgrPolyline', $
        li_xverts, li_yverts, li_zverts,$
        POLYLINES=li_pl, COLOR=white)

    lite1_icon->Add,lite1_icon_pl
    lite1_icon->translate, lite1_x, lite1_y, lite1_z

    ;  Add a Positional Light type = 1.
    ;
    lite1 = OBJ_NEW('IDLgrLight', $
        LOCATION=[lite1_x, lite1_y, lite1_z], TYPE=1)
    top->Add,lite1


    ;  Generate the second light source.
    ;
    lite2_icon = OBJ_NEW('IDLgrModel')
    top->Add,lite2_icon
    lite2_icon->SetProperty, HIDE=1
    lite2_x = -19.0
    lite2_y = -19.0
    lite2_z = 10.0
    lite2_icon_pl = OBJ_NEW('IDLgrPolyline', $
        li_xverts, li_yverts, li_zverts,$
        POLYLINES=li_pl, COLOR=white)
    lite2_icon->Add, lite2_icon_pl
    lite2_icon->Translate, lite2_x, lite2_y, lite2_z

    ;  Add a Positional Light type = 1.
    ;
    lite2 = OBJ_NEW('IDLgrLight', $
         LOCATION=[lite2_x, lite2_y, lite2_z], TYPE=1)
    top->Add, lite2

    ;  Set the current frame.
    ;
    current_frame = 0

    ;  Desensitize the current options.
    ;
    WIDGET_CONTROL, wDragLowButton, SENSITIVE=0
    WIDGET_CONTROL, wGouraudButton, SENSITIVE=0
    WIDGET_CONTROL, wSolidButton, SENSITIVE=0

    ;  Add the trackball object for interactive change
    ;  of the scene orientation
    ;
    oTrack = OBJ_NEW('Trackball', [xdim/2.0, ydim/2.0], xdim/2.0)

    oContainer = OBJ_NEW('IDLgrContainer')
    oContainer->Add, oView
    oContainer->Add, oTrack


    ; Setup the state structure
    ;
    state = {center: xdim/2., $            ; x center of drawing area
          radius: ydim/2, $                ; Radius 
          size_2: xdim/2., $               ; 1/2 of x xsize
          btndown: 0b, $                   ; 0= not pressed, otherwise is pressed
          pt0: fltarr(3), $                ; Point 0 location
          pt1: fltarr(3), $                ; Point 1 location
          wDraw3D: wDraw3D, $              ; Wdiget draw ID
          xc: xc, $                        ; Translation of the objects (x, y, z)
          yc: yc, $
          zc: zc, $
          ColorTable: colorTable, $        ; Color table to restore when exiting
          annotation: annotation, $        ; Models   
          top3D: top3D, $
          heart: heart, $
          heart_inner: heart_inner, $      ; Heart polygon objects
          heart_outer: heart_outer, $
          heart_bot: heart_bot, $
          WDragLowButton: wDragLowButton, $; Drag quality button IDs
          WDragHiButton: wDragHiButton, $
          WFlatButton: wFlatButton, $      ; Shading button IDs
          WGouraudButton: wGouraudButton, $
          WWireButton: wWireButton, $      ; Style button IDs
          WSolidButton: wSolidButton, $
          WBase: wBase, $                  ; Top level base
          Font18: font18, $
          Font24: font24, $
	  f: font24, $     
          Font_sm:font_sm, $
          Font_big:font_big, $
          Title1: title1, $
          Title2: title2, $
          OTrack: oTrack, $                ; Trackball object
          OContainer: oContainer, $        ; Container object
          i_verts: i_verts, $              ; For Inner heart (i-), Outer heart(o_)
          i_polys: i_polys, $              ; and bottom Heart (b_): these are
          i_color: i_color, $              ; the colors, polylines, and 
          o_verts: o_verts, $              ; and vertices arrays
          o_polys: o_polys, $
          o_color: o_color, $
          b_verts: b_verts, $
          b_polys: b_polys, $
          b_color: b_color, $
          lite1_icon: lite1_icon, $        ; Light objects
          lite2_icon: lite2_icon, $
          axis_obj: axis_obj, $            ; Axis object
          current_frame: current_frame, $  ; current frame index
          OView : oView, $                 ; View object
          OText : oText, $                 ; Text object
          OFont : oFont, $                 ; Font object
          dragq : 0, $                     ; Drag quality (0=low, 1=med., 2=high)
          OWindow: oWindow, $              ; Window object
          InitTM: FLTARR(4,4), $           ; Initial transformation
          groupBase: groupBase $           ; Base of Group Leader
         }

    ;  Draw the initial view to the window.
    ;
    WIDGET_CONTROL, wBase, SENSITIVE=1

    WIDGET_CONTROL, wBase, /HOURGLASS

    top->Remove, oText

    ;  Start up with an animation.
    ;
    WIDGET_CONTROL, state.wBase, SENSITIVE=0
    i = (state.current_frame + 1) MOD 16
    for j = 0,15 do begin
        state.top3D->Rotate, [1,0,0], -1
        state.top3D->Rotate, [0,1,0], 3
        state.heart_inner->SetProperty, $
            DATA=REFORM(state.i_verts[i,*,*])
        state.heart_outer->SetProperty, $
            DATA=REFORM(state.o_verts[i,*,*])
        state.heart_bot->SetProperty, $
            DATA=REFORM(state.b_verts[i,*,*])
        state.oWindow->Draw, state.oView
        i = (i + 1) MOD 16
    endfor  ;  of  j
    WIDGET_CONTROL, state.wBase, SENSITIVE=1

    ;  Get the initial transformation of the top model.
    ;
    top3D->GetProperty, TRANSFORM=TM
    state.initTM = TM

    WIDGET_CONTROL, wBase, SET_UVALUE=state, /NO_COPY

    XMANAGER, 'd_heart', wBase,  $
        EVENT_HANDLER="d_heartEvent", $
        CLEANUP='d_heartCleanup', /NO_BLOCK
       

end         ; Beating Heart
