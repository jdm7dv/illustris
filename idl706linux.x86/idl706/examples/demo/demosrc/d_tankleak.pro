;valid $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_tankleak.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_tankleak.pro
;
;  CALLING SEQUENCE: d_tankleak
;
;  PURPOSE:  Shows the contamination of leaky tanks.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and proCEDURES:
;       fun d_tankleakIndexColor2RGB  - Change the color index into RGB
;       fun d_tankleakReadBores       - Read bore holes data
;       pro d_tankleakWin3dEvent      - Drawing area event handler
;       pro d_tankleakVolumeBounds    - Draw the volume
;       fun d_tankleakExtentBounds    - Drawing a box (event handler)
;       pro d_tankleakGenIso          - Compute the isosurface
;       pro d_tankleakMenuEvent       - menu bar event handler
;       pro d_tankleakOptionEvent     - option event handler
;       pro d_tankleakViewEvent       - view event handler
;       pro d_tankleakEvent           - main event handler
;       pro d_tankleakCleanup         - Cleanup
;       pro d_tankleak                - Main procedure
;
;  EXTERNAL FUNCTIONS, proCEDURES, and FILES:
;       pro trackball__define   - Create the trackball object
;       pro demo_gettips        - Read the tip file and create widgets
;       pro demo_puttips        - Change tips text
;       vol1.sav
;       vol2.sav
;       bores0.dat
;       tankleak.tip
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODifICATION HISTORY:  WRITTEN, SDG, RSI, DEC, 1996.
;
;-
;-----------------------------------------------------------
;
;    PURPOSE Convert an array of index color
;            to an array of RGB color. The function returns
;            the RGB colr array.
;
function d_tankleakIndexColor2RGB, $
    index_color, $   ; IN: array of index colors to convert
    range            ; IN: range of the color wheel
                     ;      to use for the conversion

    ;  Find min index_color.
    ;
    imin = FLOAT(MIN(index_color, MAX=imax))

    hue = range * (index_color-imin) / (imax-imin)
    sat = 1.0
    val = 1.0
    n = N_ELEMENTS(hue)
    color_convert, hue, REPLICATE(sat, n), REPLICATE(val,n), $
         r,g,b, /HSV_RGB

    RETURN, TRANSPOSE([[r],[g],[b]])

end ; end function vert_col


;-----------------------------------------------------------
;
;    PURPOSE Read a bore hole file
;
function d_tankleakReadBores, $
    file_lun, $    ; IN: file lun
    parent_obj, $  ; IN: parent object
    color          ; IN: assigned color

    ;  Read the title string.
    ;
    title = ' '
    READF, file_lun, title

    ;  Read the number of boreholes.
    ;
    num_bores = 0
    READF, file_lun, num_bores
    num_points = 0
    READF, file_lun, num_points

    x_coords = FLTARR(num_bores * num_points)
    y_coords = FLTARR(num_bores * num_points)
    z_coords = FLTARR(num_bores * num_points)
    elem1   = FLTARR(num_bores * num_points)
    elem2   = FLTARR(num_bores * num_points)
    vert_col1 = INTARR(3,num_bores * num_points)
    vert_col2 = INTARR(3,num_bores * num_points)
    pl_num = num_points + 1
    pl   = INTARR(num_bores * pl_num)
    counter  = 0

    x = 0.0
    y = 0.0
    z = 0.0
    val1 = 0.0
    val2 = 0.0
    bore_number = 0

    for i = 0, num_bores-1 do begin

        ;  Read the number of boreholes.
        ;
        READF, file_lun, bore_number

        pl[i*pl_num] = num_points
        for j = 0, num_points-1 do begin
            READF, file_lun, x, y, z, val1, val2
            x_coords[counter] = x
            y_coords[counter] = y
            z_coords[counter] = z
            elem1[counter] = val1
            elem2[counter] = val2
            pl[i*pl_num + j + 1] = counter
            counter = counter + 1
        endfor ; for j

    endfor ; for i

    ;  Compute the vertex colors for the polylines
    ;
    vert_col1 = d_tankleakIndexColor2RGB(elem1,225.0)

    vert_col2 = d_tankleakIndexColor2RGB(elem2,225.0)

    ;  Create the bores holes colored with
    ;  the first element: element1.
    ;
    bore_obj = OBJ_NEW('IDLgrModel')
    parent_obj->Add, bore_obj

    bore_obj_pl = OBJ_NEW('IDLgrPolyline', x_coords, y_coords, z_coords, $
        POLYLINES=pl, THICK=2, VERT_COLOR=vert_col1)

    bore_obj->Add, bore_obj_pl

    ;  Return the bore object model.
    ;
    RETURN, bore_obj

end ; End read_bore

;----------------------------------------------------------------------------
;
;  Purpose:  Handle rotations, quit on any button except left.
;
pro d_tankleakWin3dEvent, $
    sEvent                 ; IN: event sturcture

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval, /NO_COPY

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY


    ;  Expose.
    ;
    if (sEvent.type eq 4) then begin
        state.oWindow->Draw, state.oView
    endif

    ;  Handle trackball update.
    ;
    bHaveTransform = state.oTrack->Update(sEvent, TRANSFORM=qmat )
    if (bHaveTransform NE 0) then begin
        state.top3D->GetProperty, TRANSFORM=t
        mt = t # qmat
        state.top3D->SetProperty,TRANSFORM=mt
    endif

    ;  Button press event.
    ;
    if (sEvent.type EQ 0) then begin    ; Button press.
        state.btnDown = 1B
        state.oWindow->SetProperty, QUALITY=state.dragq  ;Refresh quality
        WIDGET_CONTROL, sEvent.id, /DRAW_MOTION
    endif     ;   of  Button press

    ;  Button motion event.
    ;
    if ((sEvent.type eq 2) and (state.btndown eq 1b)) then begin
        if (bHaveTransform) then begin
            state.oWindow->Draw, state.oView
        endif
    endif    ;  end of Button motion

    ;  Button release.
    ;
    if (sEvent.type eq 1) then begin
        state.btndown = 0b
        state.oWindow->SetProperty, QUALITY=2
        state.oWindow->Draw, state.oView
        WIDGET_CONTROL, sEvent.id, DRAW_MOTION=0
    endif    ;  end of Button release

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
end

;----------------------------------------------------------------------------
;
;  Purpose: Draw a box around a volume.
;
pro d_tankleakVolumeBounds, $
    volume, $   ; IN: volume data coordinates
    color       ; IN: color of the box

    s = SIZE(volume)

    ;  Plot bottom 4 lines.
    ;
    PLOTS, [0.0,s[1]], [0.0,0.0], [0.0,0.0], COLOR=color, /T3D
    PLOTS, [s[1],s[1]], [0.0,s[2]], [0.0,0.0], COLOR=color, /T3D
    PLOTS, [s[1],0.0], [s[2],s[2]], [0.0,0.0], COLOR=color, /T3D
    PLOTS, [0.0,0.0], [s[2],0.0], [0.0,0.0], COLOR=color, /T3D

    ;  Plot top 4 lines.
    ;
    PLOTS, [0.0,s[1]], [0.0,0.0], [s[3],s[3]], COLOR=color, /T3D
    PLOTS, [s[1],s[1]], [0,s[2]], [s[3],s[3]], COLOR=color, /T3D
    PLOTS, [s[1],0.0], [s[2],s[2]], [s[3],s[3]], COLOR=color, /T3D
    PLOTS, [0.0,0.0], [s[2],0.0], [s[3],s[3]], COLOR=color, /T3D

    ;  Plot vertical 4 lines.
    ;
    PLOTS, [0.0,0.0], [0.0,0.0], [0.0,s[3]], COLOR=color, /T3D
    PLOTS, [s[1],s[1]], [0.0,0.0], [0.0,s[3]], COLOR=color, /T3D
    PLOTS, [s[1],s[1]], [s[2],s[2]], [0.0,s[3]], COLOR=color, /T3D
    PLOTS, [0.0,0.0], [s[2],s[2]], [0.0,s[3]], COLOR=color, /T3D

end ; d_tankleakVolumeBounds

;----------------------------------------------------------------------------
;
;  Purpose: Draw a box given extents.
;
;           Exts = [xmin, xmax, ymin, ymax, zmin, zmax]
;           Exts = [  0     1     2     3    4      5 ]
;
function d_tankleakExtentBounds, $
    exts, $       ; IN: extents vector (see above)
    parent_obj, $ ; IN: prent object of the box
    color1, $     ; IN: color of x axis
    color2, $     ; IN: color of y axis
    color3        ; IN: color of z axis

    xverts = [exts[0], exts[1], exts[1], exts[0], $
              exts[0], exts[1], exts[1], exts[0]]
    yverts = [exts[2], exts[2], exts[3], exts[3], $
              exts[2], exts[2], exts[3], exts[3]]
    zverts = [exts[4], exts[4], exts[4], exts[4], $
              exts[5], exts[5], exts[5], exts[5]]

    p1 = [5,0,1,2,3,0]
    p2 = [2,0,4, $
          2,1,5, $
          2,2,6, $
          2,3,7]
    p3 = [5,4,5,6,7,4]

    pl = [5,0,1,2,3,0, $
          5,4,5,6,7,4, $
          2,0,4, $
          2,1,5, $
          2,2,6, $
          2,3,7]

    box_obj = OBJ_NEW('IDLgrModel')
    parent_obj->Add, box_obj

    box_top = OBJ_NEW('IDLgrpolyline',xverts, yverts, zverts, $
        POLYLINES=p3,COLOR=color1)
    box_bot = OBJ_NEW('IDLgrpolyline',xverts, yverts, zverts, $
        POLYLINES=p1, COLOR=color3)
    box_sides = OBJ_NEW('IDLgrpolyline',xverts, yverts, zverts, $
        POLYLINES=p2, COLOR=color2)

    ;  Add the parts of the box to the box_obj.
    ;
    box_obj->Add, box_top
    box_obj->Add, box_bot
    box_obj->Add, box_sides

    RETURN, box_obj

end ; d_tankleakExtentBounds

;----------------------------------------------------------------------------
;
;  Purpose:  Generate the isosurface.
;
pro d_tankleakGenIso, $
    volume, $    ; IN: volume data
    colors, $    ; IN: vertex colors
    iso_value, $ ; IN: isometric value
    low,  $      ; IN: lowest value to plot
    verts, $     ; IN: vertices coordinates
    polys,  $    ; IN: polygons coordinates
    vert_color   ; IN: vertices colors

    vert_COLOR=colors

    SHADE_VOLUME, volume, iso_value, LOW=low, verts, polys, $
        SHADES=vert_color

end ; d_tankleakGenIso

;----------------------------------------------------------------------------
;
;  Purpose:  Main menu bar event handler.
;
pro d_tankleakMenuEvent, $
    sEvent   ; IN: event structure

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    case uval of

        'QUIT' : begin
            WIDGET_CONTROL, sEvent.top, /DESTROY
        end ; Case of QUIT

        'INFO' : begin
            ONLINE_HELP, 'd_tankleak', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH

        end   ; of INFO

    endcase ; of uval

end ; end of d_tankleakMenuEvent

;----------------------------------------------------------------------------
;
;  Purpose:  Options menu event handler.
;
pro d_tankleakOptionEvent, $
    sEvent   ; IN: event structure

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    case uval of

        ;  Set the shading to flat.
        ;
        'FLAT': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            WIDGET_CONTROL, state.wFlatButton, SENSITIVE=0
            WIDGET_CONTROL, state.wGouraudButton, SENSITIVE=1
            state.isosurface1->SetProperty, SHADING=0
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end; Case of FLAT

        ;  Set the shading to Gouraud.
        ;
        'GOURAUD': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            WIDGET_CONTROL, state.wFlatButton, SENSITIVE=1
            WIDGET_CONTROL, state.wGouraudButton, SENSITIVE=0
            state.isosurface1->SetProperty, SHADING=1
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end; Case of GOURAUD

        ;  Set the surface style to wire.
        ;
        'WIRE': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            state.isosurface1->SetProperty, STYLE=1
            WIDGET_CONTROL, state.wWireButton, SENSITIVE=0
            WIDGET_CONTROL, state.wSolidButton, SENSITIVE=1
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end; Case of WIRE

        ;  Set the surface style to solid.
        ;
        'SOLID': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            state.isosurface1->SetProperty, STYLE=2
            WIDGET_CONTROL, state.wWireButton, SENSITIVE=1
            WIDGET_CONTROL, state.wSolidButton, SENSITIVE=0
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end; Case of SOLID

    endcase ; of uval

end ; end of d_tankleakOptionEvent

;----------------------------------------------------------------------------
;
;  Purpose:  Options menu event handler.
;
pro d_tankleakViewEvent,  $
    sEvent   ; IN: event structure

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    case uval of

        ;  Hide or show the isosurfaces.
        ;
        'ISO' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            if (state.iso_on EQ 1) then begin ; Currently ON so turn OFF
                HIDE=1
                state.iso_on = 0
                WIDGET_CONTROL,sEvent.id, SET_VALUE='Isosurface (off)'
            endif else begin ; Currently OFF so turn ON
                HIDE=0
                state.iso_on = 1
                WIDGET_CONTROL,sEvent.id, SET_VALUE='Isosurface (on)'
            endelse

            ;  Update the view.
            ;
            state.isosurface1->SetProperty, HIDE=hide
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of ISO

        ;  Hide or show the bore holes.
        ;
        'BORES' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            if (state.bores_on EQ 1) then begin ; Currently ON so turn OFF
                HIDE=1
                state.bores_on = 0
                WIDGET_CONTROL,sEvent.id, SET_VALUE='BoreHoles (off)'
            endif else begin ; Currently OFF so turn ON
                HIDE=0
                state.bores_on = 1
                WIDGET_CONTROL,sEvent.id, SET_VALUE='BoreHoles (on)'
            endelse

            ;  Update the view.
            ;
            state.bore_obj->SetProperty, HIDE=hide
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of BORES

        ;  Hide or show the tanks.
        ;
        'TANKS' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            if (state.tanks_on EQ 1) then begin ; Currently ON so turn OFF
                HIDE=1
                state.tanks_on = 0
                WIDGET_CONTROL,sEvent.id,SET_VALUE='Tanks (off)'
            endif else begin ; Currently OFF so turn ON
                HIDE=0
                state.tanks_on = 1
                WIDGET_CONTROL,sEvent.id,SET_VALUE='Tanks (on)'
            endelse

            ;  Update the view.
            ;
            state.tanks->SetProperty, HIDE=hide
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of TANKS

        ;  Hide or show the enclosing box.
        ;
        'BOX' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            if (state.box_on EQ 1) then begin ; Currently ON so turn OFF
                HIDE=1
                state.box_on = 0
                WIDGET_CONTROL,sEvent.id, SET_VALUE='BoundingBox (off)'
            endif else begin ; Currently OFF so turn ON
                HIDE=0
                state.box_on = 1
                WIDGET_CONTROL,sEvent.id, SET_VALUE='BoundingBox (on)'
            endelse

            ;  Update the view.
            ;
            state.bounds->SetProperty, HIDE=hide
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of BOX

        ;  Hide or show the light icons.
        ;
        'LITES' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            if (state.lite_on EQ 1) then begin ; Currently ON so turn OFF
                HIDE=1
                state.lite_on = 0
                WIDGET_CONTROL,sEvent.id, SET_VALUE='Light Icons (off)'
            endif else begin ; Currently OFF so turn ON
                HIDE=0
                state.lite_on = 1
                WIDGET_CONTROL,sEvent.id, SET_VALUE='Light Icons (on)'
            end

            ;  Update the view.
            ;
            state.lite1_icon->SetProperty, HIDE=hide
            state.lite2_icon->SetProperty, HIDE=hide
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of LITES

        ;  Hide or show the text annotation.
        ;
        'ANNO' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            if (state.text_on EQ 1) then begin ; Currently ON so turn OFF
                HIDE=1
                state.text_on = 0
                WIDGET_CONTROL,sEvent.id, SET_VALUE='Annotation (off)'
            endif else begin ; Currently OFF so turn ON
                HIDE=0
                state.text_on = 1
                WIDGET_CONTROL,sEvent.id, SET_VALUE='Annotation (on)'
            end

            ;  Update the view.
            ;
            state.annotation->SetProperty, HIDE=hide
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of LITES

        ;  Set the drag quality to low.
        ;
        'LOW': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            state.dragq = 0
            WIDGET_CONTROL, state.wDragLowButton, SENSITIVE=0
            WIDGET_CONTROL, state.wDragHiButton, SENSITIVE=1
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end; Case of LOW

        ;  Set the drag quality to high.
        ;
        'HIGH': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            state.dragq = 2
            WIDGET_CONTROL, state.wDragLowButton, SENSITIVE=1
            WIDGET_CONTROL, state.wDragHiButton, SENSITIVE=0
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end; Case of HIGH

        ;  Reset the initial orientation of the view.
        ;
        'RESET' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            ident = [[1.0,0,0,0], $
                    [0.0,1,0,0], $
                    [0.0,0,1,0], $
                    [0.0,0,0,1]]
            state.top3D->SetProperty, TRANSFORM=ident
            state.oWindow->Draw, state.oView
            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
         end

    endcase ; of uval

end ; end of d_tankleakViewEvent

;----------------------------------------------------------------------------
;
;  Purpose:  Main menu event handler
;
pro d_tankleakEvent, $
    sEvent

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    case uval of

        ;  Volume render one of the volume.
        ;
        'VOLREND_ELEM1': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY

            ;  Redraw the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.vol1_obj->SetProperty,HIDE=0
            state.oWindow->Draw, state.oView
            state.vol1_obj->SetProperty,HIDE=1

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of VOLREND_ELEM1

        'VOLREND_ELEM2': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY

            ;  Redraw the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.vol2_obj->SetProperty,HIDE=0
            state.oWindow->Draw, state.oView
            state.vol2_obj->SetProperty,HIDE=1

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of VOLREND_ELEM2

        ;  Recompute the isosurface with an new value and display it.
        ;
        'ISOVAL': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY

            demo_putTips, state, '', 10
            demo_putTips, state, ['comp1','comp2'], [11,12], /LABEL

            value = FLOAT(sEvent.value)
            d_tankleakGenIso, *state.ivol_ptr, *state.cvol_ptr, $
                value, state.low, $
                iso_verts, iso_polys, iso_color

            ;  Check for isodurface errors.
            ;
            if (N_ELEMENTS(iso_verts) EQ 0) then begin
                PRINT, 'Leaky_Tanks: Error in computing ' + $
                    'isosurface, check iso_value.'
                WIDGET_CONTROL, state.wSlider, $
                    SET_VALUE=state.previousSliderValue
                state.iso_value = state.previousSliderValue
            endif else begin
                if (state.color_model EQ 0) then begin
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                    POLYGONS=iso_polys, VERT_COLORS=0, COLOR=[255,0,255]
                endif else begin
                    vert_colors = d_tankleakIndexColor2RGB(iso_color, 225.0)
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                    POLYGONS=iso_polys, VERT_COLORS=vert_colors
                endelse ; else
                state.previousSliderValue = sEvent.value
                state.iso_value = sEvent.value
            endelse

            ;  Redraw the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.oWindow->Draw, state.oView

            ;  Rewrite the tip text.
            ;
            demo_putTips, state, ['selecto','disp1','disp2'], [10,11,12], $
               /LABEL

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of ISOVAL

        ;  Show element 1.
        ;
        'ELEM1' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0

            demo_putTips, state, '', 10
            demo_putTips, state, ['comp1','comp2'], [11,12], /LABEL

            d_tankleakGenIso, state.volume1, *state.cvol_ptr, $
                state.iso_value, $
                state.low, iso_verts, iso_polys, iso_color

            ;  Determine Color Model to Use.
            ;
            if (state.cvolume EQ 1) THEN color_model=0 else color_model=1

            if (N_ELEMENTS(iso_verts) EQ 0) then begin
                PRINT, 'Leaky_Tanks: Error in computing ' + $
                    'isosurface, check iso_value.'
            endif else begin
                if (color_model EQ 0) then begin
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=0, COLOR=[255,0,255]
                endif else begin
                    vert_colors = d_tankleakIndexColor2RGB(iso_color, 225.0)
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=vert_colors
                endelse ; else
            endelse

            ; Update the State Values.
            ;
            state.ivolume = 1
            state.color_model = color_model
            *state.ivol_ptr = state.volume1

            ; Update the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.oWindow->Draw, state.oView

            demo_putTips, state, ['selecto','disp1','disp2'], [10,11,12], $
               /LABEL

            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of ELEM1

        ;  Show element 1.
        ;
        'ELEM2' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0

            demo_putTips, state, '', 10
            demo_putTips, state, ['comp1','comp2'], [11,12], /LABEL

            d_tankleakGenIso, state.volume2, *state.cvol_ptr, $
                state.iso_value, $
                state.low, iso_verts, iso_polys, iso_color

            ;  Determine Color Model to Use.
            ;
            if (state.cvolume EQ 2) THEN color_model=0 else color_model=1

            if (N_ELEMENTS(iso_verts) EQ 0) then begin
                PRINT, 'Leaky_Tanks: Error in computing ' + $
                    'isosurface, check iso_value.'
            endif else begin
                if (color_model EQ 0) then begin
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=0, COLOR=[255,0,255]
                endif else begin
                    vert_colors = d_tankleakIndexColor2RGB(iso_color, 225.0)
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=vert_colors
                endelse ; else
            endelse

            ;  Update the State Values.
            ;
            state.ivolume = 2
            state.color_model = color_model
            *state.ivol_ptr = state.volume2

            ;  Update the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.oWindow->Draw, state.oView

            demo_putTips, state, ['selecto','disp1','disp2'], [10,11,12], $
               /LABEL

            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of ELEM2

        ;  Set the color of element 1 ( one color or multiple colors).
        ;
        'COLOR_ELEM1' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0
            demo_putTips, state, '', 10
            demo_putTips, state, ['comp1','comp2'], [11,12], /LABEL

            d_tankleakGenIso, *state.ivol_ptr, state.volume1, $
                state.iso_value, $
                state.low, iso_verts, iso_polys, iso_color

            ;  Determine Color Model to Use.
            ;
            if (state.ivolume EQ 1) THEN color_model=0 else color_model=1

            if (N_ELEMENTS(iso_verts) EQ 0) then begin
                PRINT, 'Leaky_Tanks: Error in computing ' + $
                    'isosurface, check iso_value.'
            endif else begin
                if (color_model EQ 0) then begin
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=0, COLOR=[255,0,255]
                endif else begin
                    vert_colors = d_tankleakIndexColor2RGB(iso_color, 225.0)
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=vert_colors
                endelse ; else
            endelse

            ;  Update the State Values.
            ;
            state.cvolume = 1
            state.color_model = color_model
            *state.cvol_ptr = state.volume1

            ;  Update the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.oWindow->Draw,state.oView
            demo_putTips, state, ['selecto','disp1','disp2'], [10,11,12], $
               /LABEL

            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of COLOR_ELEM1

        ;  Set the color of element 1 ( one color or multiple colors).
        ;
        'COLOR_ELEM2' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=state, /NO_COPY
            WIDGET_CONTROL, state.wBase, SENSITIVE=0

            demo_putTips, state, '', 10
            demo_putTips, state, ['comp1','comp2'], [11,12], /LABEL

            d_tankleakGenIso, *state.ivol_ptr, state.volume2, state.iso_value, $
                state.low, iso_verts, iso_polys, iso_color

            ;  Determine Color Model to Use.
            ;
            if (state.ivolume EQ 2) THEN color_model=0 else color_model=1

            if (N_ELEMENTS(iso_verts) EQ 0) then begin
                PRINT, 'Leaky_Tanks: Error in computing ' + $
                    'isosurface, check iso_value.'
            endif else begin
                if (color_model EQ 0) then begin
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=0, COLOR=[255,0,255]
                endif else begin
                    vert_colors = d_tankleakIndexColor2RGB(iso_color, 225.0)
                    state.isosurface1->SetProperty, DATA=iso_verts, $
                        POLYGONS=iso_polys, VERT_COLORS=vert_colors
                endelse ; else
            endelse

            ;  Update the State Values.
            ;
            state.cvolume = 2
            state.color_model = color_model
            *state.cvol_ptr = state.volume2

            ;  Update the view.
            ;
            WIDGET_CONTROL, state.wBase, /HOURGLASS
            state.oWindow->Draw,state.oView

            demo_putTips, state, ['selecto','disp1','disp2'], [10,11,12], $
               /LABEL

            WIDGET_CONTROL, state.wBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=state, /NO_COPY
        end ; Case of COLOR_ELEM2

    endcase
end

;-----------------------------------------------------------------
;
;    PURPOSE : Cleanup procedure, restore colortable, destroy objects.
;
pro d_tankleakCleanup, wBase

    WIDGET_CONTROL, wBase, GET_UVALUE=state, /NO_COPY

    ;  Destroy the top objects
    ;
    OBJ_DESTROY, state.oView
    OBJ_DESTROY, state.f
    OBJ_DESTROY, state.font
    OBJ_DESTROY, state.font_small
    OBJ_DESTROY, state.font_medium
    OBJ_DESTROY, state.font_large
    OBJ_DESTROY, state.oContainer
    OBJ_DESTROY, state.oTrack
    OBJ_DESTROY, state.oText
    OBJ_DESTROY, state.oFont
    PTR_FREE, state.ivol_ptr
    PTR_FREE, state.cvol_ptr

    ;  Restore the color table.
    ;
    TVLCT, state.colorTable

    if WIDGET_INFO(state.groupBase, /VALID_ID) then $
        WIDGET_CONTROL, state.groupBase, /MAP

end   ;  of d_tankleakCleanup

;-----------------------------------------------------------------
;
;    PURPOSE : Main procedure.
;
pro d_tankleak, $
    xdim=xdim, $       ; IN: (opt) x dimension of the viewing area.
    ydim=ydim, $       ; IN: (opt) y dimension of the viewing area.
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

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

    ;  Get the current color vectors to restore
    ;  when this application is exited.
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ;  Build color table from color vectors.
    ;
    colorTable = [[savedR],[savedG],[savedB]]


    ;  Determine the screen size.
    ;
    Device, GET_SCREEN_SIZE = screenSize

    ;  Set default values of the veiwing area size if not porvided.
    ;
    if (N_ELEMENTS(xdim) EQ 0) then begin
        xdim = screenSize[0]*0.6
    endif
    if (N_ELEMENTS(ydim) EQ 0) then begin
        ydim = 0.8 * xdim
    endif

    ;  Restore the Volume Save Files so max and min are available
    ;  for use when building cw_fslider.
    ;
    vol1_file = demo_filepath('vol1.sav', $
        SUBDIR=['examples','demo','demodata'])
    vol2_file = demo_filepath('vol2.sav', $
        SUBDIR=['examples','demo','demodata'])

    restore, vol1_file
    restore, vol2_file

    vol_min = MIN(volume1, max=vol_max)
    vol_min2 = MIN(volume2, max=vol_max2)
    vol_min = vol_min > vol_min2
    vol_max = fix((vol_max < vol_max2) * 0.95)

    ;  Create the widgets starting with the top level base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wBase = WIDGET_BASE(/COLUMN, $
            TITLE="Environmental Modeling Visualization", $
            YPAD=0, XPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1, MBAR=mbarbase )
    endif else begin
        wBase = WIDGET_BASE(/COLUMN, $
            GROUP_LEADER=group, $
            TITLE="Environmental Modeling Visualization", $
            YPAD=0, XPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1, MBAR=mbarbase)
    endelse

        ;  Create the Menu Bar

        ;  Create the file menu bar item that contains the quit button
        ;
        wFileButton = WIDGET_BUTTON(mbarbase,VALUE='File',/MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE = 'Quit',UVALUE='QUIT', $
                EVENT_PRO='d_tankleakMenuEvent')

        ;  Create the option menu
        ;
        wOptionButton = WIDGET_BUTTON(mbarbase, $
            VALUE='Isosurface', /MENU)

            ;  Create the Shading Options Button.
            ;
            wShadingButton = WIDGET_BUTTON(wOptionButton, $
                EVENT_PRO='d_tankleakOptionEvent', $
                VALUE='Shading',UVALUE='Shading',/MENU)

                wFlatButton = WIDGET_BUTTON(wShadingButton, $
                    EVENT_PRO='d_tankleakOptionEvent', $
                    VALUE='Flat',UVALUE='FLAT')

                wGouraudButton = WIDGET_BUTTON(wShadingButton, $
                    EVENT_PRO='d_tankleakOptionEvent', $
                    VALUE='Gouraud',UVALUE='GOURAUD')

           ;  Create the Style Options Button.
           ;
           wStyleButton = WIDGET_BUTTON(wOptionButton, $
               EVENT_PRO='d_tankleakOptionEvent', $
               VALUE='Style',UVALUE='STYLE',/MENU)

               wWireButton = WIDGET_BUTTON(wStyleButton, $
                   EVENT_PRO='d_tankleakOptionEvent', $
                   VALUE='Wire',UVALUE='WIRE')

               wSolidButton = WIDGET_BUTTON(wStyleButton, $
                   EVENT_PRO='d_tankleakOptionEvent', $
                   VALUE='Solid',UVALUE='SOLID')

        ;  Create the View Menu.
        ;
        wViewButton = WIDGET_BUTTON(mbarbase,VALUE='View',/Menu)

            ;  Create the Object Visibility Button.
            ;
            wObjVizButton = WIDGET_BUTTON(wViewButton, $
                EVENT_PRO='d_tankleakViewEvent', $
                VALUE='Show Object', UVALUE='OBJVIZ',/MENU)

                wIsoButton = WIDGET_BUTTON(wObjVizButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='Isosurface (on)',UVALUE='ISO')

                wBoreButton = WIDGET_BUTTON(wObjVizButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='BoreHoles (on)',UVALUE='BORES')

                wTanksButton = WIDGET_BUTTON(wObjVizButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='Tanks (on)',UVALUE='TANKS')

                wBoxButton = WIDGET_BUTTON(wObjVizButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='Bounding Box (on)',UVALUE='BOX')

                wLiteButton = WIDGET_BUTTON(wObjVizButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='Light Icons (off)',UVALUE='LITES')

            ;  Create the Drag Quality Options Button
            ;
            wDragButton = WIDGET_BUTTON(wViewButton, $
                EVENT_PRO='d_tankleakViewEvent', $
                VALUE='Drag Quality', UVALUE='DRAG',/MENU)

                wDragLowButton = WIDGET_BUTTON(wDragButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='Low',UVALUE='LOW')

                wDragHiButton = WIDGET_BUTTON(wDragButton, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='High',UVALUE='HIGH')

            ;  Create the transform reset button
            ;
            wResetMenu = WIDGET_BUTTON(wViewButton, $
                EVENT_PRO='d_tankleakViewEvent', $
                VALUE='Reset', /MENU)

                wResetButton = WIDGET_BUTTON(wResetMenu, $
                    EVENT_PRO='d_tankleakViewEvent', $
                    VALUE='Reset Orientation',UVALUE='RESET')

        ;  Create the help/About button.
        ;
        wHelpButton = WIDGET_BUTTON(mbarbase, $
            VALUE='About', /HELP, /MENU)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                EVENT_PRO = 'd_tankleakMenuEvent', $
                VALUE='About Environmental Modeling', UVALUE='INFO')

        ;  Create the first child of the top level base (wBase).
        ;
        wTopRowBase =  WIDGET_BASE(wBase, COLUMN=2)

            ; Create a base for the left column
            ;
            wLeftBase = WIDGET_BASE(wTopRowBase, $
                /BASE_ALIGN_LEFT, /COLUMN, /FRAME)

                ;  Create the Element Selection Area.
                ;
                wElemBase = WIDGET_BASE(wLeftBase, /COLUMN, /FRAME)

                    wIsoLabel1 = WIDGET_LABEL(wElemBase, $
                        VALUE="Element Selections", $
                        /ALIGN_CENTER)

                    wIsoLabel2 = WIDGET_LABEL(wElemBase, $
                        VALUE="Isosurface:", /ALIGN_LEFT)

                    wElemIsoBase = WIDGET_BASE(wElemBase,  $
                        /COLUMN, /EXCLUSIVE)

                        wElem1Toggle = WIDGET_BUTTON(wElemIsoBase, $
                            VALUE="Element 1", $
                            UVALUE='ELEM1', /NO_RELEASE, $
                            EVENT_PRO='d_tankleakEvent')

                        wElem2Toggle = WIDGET_BUTTON(wElemIsoBase, $
                            VALUE="Element 2", $
                            UVALUE='ELEM2', /NO_RELEASE, $
                            EVENT_PRO='d_tankleakEvent')

                    wIsoLabel3 = WIDGET_LABEL(wElemBase, $
                        VALUE="Shaded Colors:", /align_left)

                    wColorIsoBase = WIDGET_BASE(wElemBase, $
                        /COLUMN, /EXCLUSIVE)

                        wColor1Toggle = WIDGET_BUTTON(wColorIsoBase, $
                            VALUE="Element 1", $
                            UVALUE='COLOR_ELEM1', /NO_RELEASE, $
                            EVENT_PRO='d_tankleakEvent')

                        wColor2Toggle = WIDGET_BUTTON(wColorIsoBase, $
                            VALUE="Element 2", $
                            UVALUE='COLOR_ELEM2', /NO_RELEASE, $
                            EVENT_PRO='d_tankleakEvent')

                ;  Create the SLIDER for the Isosurface Level
                ;
                wIsoBase = WIDGET_BASE(wLeftBase, /COLUMN, /FRAME)

                    wIsoLabel = WIDGET_LABEL(wIsoBase, $
                        VALUE="Isosurface Controls", $
                        /ALIGN_CENTER)

                    maxValue = FIX(vol_max)
                    wSlider = WIDGET_SLIDER(wIsoBase, $
                        VALUE=maxVAlue/2, $
                        MINIMUM=2, MAXIMUM=maxValue, $
                        UVALUE='ISOVAL')

                ;  Create the Buttons for the volume objects
                ;
                wVolBase = WIDGET_BASE(wLeftBase, /COLUMN, /FRAME)

                    wVolLabel = WIDGET_LABEL(wVolBase, $
                        VALUE="Volume Render", $
                        /ALIGN_CENTER)

                    wVol1Button = WIDGET_BUTTON(wVolBase, $
                        VALUE="Element 1", $
                        UVALUE='VOLREND_ELEM1', $
                        EVENT_PRO='d_tankleakEvent')

                    wVol2Button = WIDGET_BUTTON(wVolBase, $
                        VALUE="Element 2", $
                        UVALUE='VOLREND_ELEM2', $
                        EVENT_PRO='d_tankleakEvent')

            ;  Create a base for the right column.
            ;
            wRightBase = WIDGET_BASE(wTopRowBase, Column=1, /Frame)

                wDraw3D = widget_draw(wRightBase, $
                    XSIZE=xdim, YSIZE=ydim, /BUTTON_EVENTS, $
                    UVALUE='DRAW', RETAIN=0, $
                    EVENT_PRO='d_tankleakWin3dEvent', /EXPOSE_EVENTS, $
                    GRAPHICS_LEVEL=2)

        ;  Create the tip widgets.
        ;
        wStatusBase = WIDGET_BASE(wBase, MAP=0, /ROW)

    ;  All the widget have been created, now realize them
    ;
    WIDGET_CONTROL, wBase, /REALIZE

    WIDGET_CONTROL, /HOURGLASS

    ;  Returns the top level base to the APPTLB keyword.
    ;
    appTLB = wBase

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('tankleak.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wBase, $
                         wStatusBase)

    WIDGET_CONTROL, wDraw3D, GET_VALUE=oWindow

    ;  Set the state of the buttons.
    ;
    WIDGET_CONTROL, wElem1Toggle, SET_BUTTON=1
    WIDGET_CONTROL, wColor1Toggle, SET_BUTTON=1

    ;  Initialize the previous slider value to its actual value.
    ;
    previousSliderValue = (vol_max -vol_min) / 2.0

    ;  Create the identity matrix for transforms.
    ;
    ident = [[1.0,0,0,0], $
            [0.0,1,0,0], $
            [0.0,0,1,0], $
            [0.0,0,0,1]]

    ;  Define a few working colors.
    ;
    white  = [255,255,255]
    red    = [255,0,0]
    green  = [0,255,0]
    blue   = [0,0,255]
    purple = [255,0,255]

    ;  Define the Graphics View.
    ;
    ;Compute viewplane rectangle to nicely fit our volumes.
    ;
    zoom = .75
    myview = [-50, -50, 100, 100] * zoom
    ;
    ;Grow viewplane rectangle to match wDraw's aspect ratio.
    ;
    aspect = FLOAT(xdim)/FLOAT(ydim)
    if (aspect gt 1) then begin
        myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
        myview[2] = myview[2] * aspect
        end $
    else begin
        myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
        myview[3] = myview[3] / aspect
        end

    oView = OBJ_NEW('IDLgrView', COLOR=[0,0,0], PROJECTION=1, $
        EYE= 51.0, $
        VIEWPLANE_RECT=myview, ZCLIP = [50, -100])

    ;  Create a centerd starting up text.
    ;
    textLocation = [myview[0]+0.5*myview[2], myview[1]+0.5*myview[3]]

    ;  Create and display the PLEASE WAIT text.
    ;
    oFont = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=18)
    oText = OBJ_NEW('IDLgrText', $
        'Starting up  Please wait...', $
        ALIGN=0.5, $
        LOCATION=textLocation, $
        COLOR=[255,255,0], FONT=oFont)


    ;  Prepare for the PLEASE WAIT text.
    ;
    ;  Add the temporary top object to the view.
    ;
    top_tmp = OBJ_NEW('IDLgrModel')
    oView->Add, top_tmp

    top_tmp->Add, oText

    oWindow->Draw, oView

    ;  Define top level model.
    ;
    top = OBJ_NEW('IDLgrModel')

    ;  Scale the top model.
    ;
    sct = 0.8
    top->Scale, sct, sct, sct

    WIDGET_CONTROL, /HOURGLASS

    ;  Rotate the top model.
    ;
    top->Rotate, [1,0,0], -30
    top->Rotate, [0,1,0], 15

    ;  top3D is the top object for transformable objects.
    ;
    top3D = OBJ_NEW('IDLgrModel')
    top->Add, top3D

    ;  Add the top object to the view.
    ;
    oView->Add, top

    ;  Draw the Text and Title.
    ;
    font_small = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=16. )
    font_medium = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=18. )
    font_large = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=24. )

    annotation = OBJ_NEW('IDLgrModel')
    top->Add, annotation

    if (screenSize[0] EQ 640) THEN font=font_small else font = font_large

    ;  Add the Wait Text for computing Isosurfaces.
    ;
    iso_text = OBJ_NEW('IDLgrModel')

    iso_text1 = OBJ_NEW('IDLgrText', $
        'COMPUTING NEW ISOSURFACE:', $
        LOCATION=[-40,-35], $
        COLOR=[255,0,0], FONT=font)

    iso_text2 = OBJ_NEW('IDLgrText', $
        'Please Wait ...', $
        LOCATION= [-20,-41], $
        COLOR=[255,0,0], FONT=font)

    iso_text->Add, iso_text1
    iso_text->Add, iso_text2
    top->Add, iso_text
    iso_text->SetProperty, HIDE=1

    ;  Draw the red bounding box.
    ;
    extents = [-40.0, 40.0, -20.0, 20.0, -20.0, 0.0]
    bounds = d_tankleakExtentBounds(extents, top3D, red, green, blue)

    ;  Generate the Storage Tank Data.
    ;
    tank_points = [[0.0,0.0,-4.0],$
                   [5.0,0.0,-4.0],$
                   [5.0,0.0,4.0],$
                   [0.0,0.0,4.0]]

    mesh_obj, 6, tank_verts, tank_polys, tank_points, p1=16

    tank_points1 = [[0.0,0.0,-4.0],$
                   [5.0,0.0,-4.0],$
                   [5.0,0.0,4.0],$
                   [4.0,0.0,5.0],$
                   [1.0,0.0,5.0],$
                   [0.0,0.0,4.0]]
    mesh_obj, 6, tank_verts1, tank_polys1, tank_points1, p1=16

    ;  Generate the Graphics Objects for the Storage Tank Field.
    ;
    tanks = OBJ_NEW('IDLgrModel')
    top3D->Add, tanks

    ;  Tank #1.
    ;
    tank1 = OBJ_NEW('IDLgrModel')
    tanks->Add, tank1
    tank1_poly = OBJ_NEW('IDLgrPolygon', tank_verts1, poly=tank_polys1, $
        COLOR=white)
    tank1->Add, tank1_poly

    ; Tank #2.
    ;
    tank2 = OBJ_NEW('IDLgrModel')
    tanks->Add, tank2
    tank2_poly = OBJ_NEW('IDLgrPolygon', SHARE_DATA=tank1_poly, $
        POLYGONS=tank_polys1, COLOR=white)
    tank2->Add, tank2_poly

    ; Tank #3.
    ;
    tank3 = OBJ_NEW('IDLgrModel')
    tanks->Add, tank3
    tank3_poly = OBJ_NEW('IDLgrPolygon', share_data=tank1_poly, $
        POLYGONS=tank_polys1, COLOR=white)
    tank3->Add, tank3_poly

    ; Tank #4.
    ;
    tank4 = OBJ_NEW('IDLgrModel')
    tanks->Add, tank4
    tank4_poly = OBJ_NEW('IDLgrPolygon', share_data=tank1_poly, $
        POLYGONS=tank_polys1, COLOR=white)
    tank4->Add, tank4_poly

    ; Tank #5.
    ;
    tank5 = OBJ_NEW('IDLgrModel')
    tanks->Add, tank5
    tank5_poly = OBJ_NEW('IDLgrPolygon', share_data=tank1_poly, $
        POLYGONS=tank_polys1, COLOR=white)
    tank5->Add, tank5_poly

    ;  Translate each tank into place.
    ;
    z_depth = -8.0
    tank1->Translate, -24.0, 8.0, z_depth
    tank2->Translate, 0.0, 8.0, z_depth
    tank3->Translate, 24.0, 8.0, z_depth
    tank4->Translate, -12.0, -8.0, z_depth
    tank5->Translate, 12.0, -8.0, z_depth

    ;  Read the borehole data from: bores.dat.
    ;
    bore_file = demo_filepath('bores0.dat', $
        SUBDIR=['examples','demo','demodata'])
    OPENR, bore_lun, bore_file, /GET_LUN
    bore_obj = d_tankleakReadBores(bore_lun, top3D, purple)
    CLOSE, bore_lun
    FREE_LUN, bore_lun

    ;  Generate the first isosurface.
    ;
    iso_COLOR=FLTARR(80,40,20)
    iso_value = (vol_max - vol_min) / 2.0

    WIDGET_CONTROL, wSlider, SET_VALUE=iso_value

    color_model = 0
    low = 1
    d_tankleakGenIso, volume1, volume1, iso_value, low, iso_verts, $
         iso_polys, iso_color

    iso_model1 = OBJ_NEW('IDLgrModel')
    top3D->Add, iso_model1

    if (color_model EQ 0) then begin
        isosurface1 = OBJ_NEW('IDLgrPolygon', iso_verts, $
        POLYGONS=iso_polys, $
        COLOR=[250,0,250])
    endif else begin
        vert_colors = d_tankleakIndexColor2RGB(iso_color, 225.0)
        isosurface1 = OBJ_NEW('IDLgrPolygon', iso_verts, $
        POLYGONS=iso_polys, $
        vert_COLOR=vert_colors)
    endelse ; else

    iso_model1->Add, isosurface1
    iso_model1->translate, -40.0, -20.0, -20.0 ; Translate into place

    vmax = MAX([MAX(volume1),MAX(volume2)])
    vert_colors = d_tankleakIndexColor2RGB(indgen(vmax+1), 225.0)
    ctab = bytarr(256,3)
    ctab[0:vmax,*] = TRANSPOSE(vert_colors)
    vobj1 = OBJ_NEW('IDLgrVolume',BYTE(volume1),HIDE=1,/ZBUFFER, $
        /ZERO_OPACITY_SKIP,RGB_TABLE0=ctab)
    vobj2 = OBJ_NEW('IDLgrVolume',BYTE(volume2),HIDE=1,/ZBUFFER, $
        /ZERO_OPACITY_SKIP,RGB_TABLE0=ctab)

    iso_model1->Add, vobj1
    iso_model1->Add, vobj2

    ;  Get and Set properties on the bounds of the geometry.
    ;
    xr = [extents[0],extents[1]]
    yr = [extents[2],extents[3]]
    zr = [extents[4],extents[5]]

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
    lite0 = OBJ_NEW('IDLgrLight', TYPE=0, COLOR=[128,128,128])
    top->Add, lite0

    ;  Generate the first light source.
    ;
    lite1_icon = OBJ_NEW('IDLgrModel')
    top->Add,lite1_icon
    lite1_x = 40.0
    lite1_y = -20.0
    lite1_z = 10.0
    lite1_icon_pl = OBJ_NEW('IDLgrPolyline',li_xverts,li_yverts,li_zverts,$
        POLYLINES=li_pl, COLOR=white)

    lite1_icon->Add,lite1_icon_pl
    lite1_icon->Translate, lite1_x, lite1_y, lite1_z

    ;  Add a Positional Light type = 1.
    ;
    lite1 = OBJ_NEW('IDLgrLight',  $
        LOCATION=[lite1_x, lite1_y, lite1_z], TYPE=1)
    top->Add,lite1

    ;  Generate the second light source.
    ;
    lite2_icon = OBJ_NEW('IDLgrModel')
    top->Add,lite2_icon

    lite2_x = -40.0
    lite2_y = -20.0
    lite2_z = 10.0
    lite2_icon_pl = OBJ_NEW('IDLgrPolyline', li_xverts, li_yverts, li_zverts,$
        POLYLINES=li_pl, COLOR=white)
    lite2_icon->Add,lite2_icon_pl
    lite2_icon->translate, lite2_x, lite2_y, lite2_z

    ;  Add a Positional Light type = 1.
    ;
    lite2 = OBJ_NEW('IDLgrLight',  $
        LOCATION=[lite2_x, lite2_y, lite2_z], TYPE=1)
    top->Add, lite2

    ;  Initially turn the Light Icons Off.
    ;
    lite1_icon->SetProperty, HIDE=1
    lite2_icon->SetProperty, HIDE=1


    ;  Set the initial state of objects (on or off).
    ;
    iso_on   = 1
    bores_on = 1
    tanks_on = 1
    box_on   = 1
    text_on  = 1
    lite_on  = 0

    ;  Desensitive the initial settings.
    ;
    WIDGET_CONTROL, wDragLowButton, SENSITIVE=0
    WIDGET_CONTROL, wGouraudButton, SENSITIVE=0
    WIDGET_CONTROL, wSolidButton, SENSITIVE=0

    ;  Define two text strings.
    ;
    displayText = 'The display is interactive with the left mouse button'
    computingText = 'Computing new isosurface: Please wait... '

    ;  Add the trackball object for interactive change
    ;  of the scene orientation.
    ;
    oTrack = OBJ_NEW('Trackball', [xdim/2.0, ydim/2.0], xdim/2.0)

    oContainer = OBJ_NEW('IDLgrContainer')
    oContainer->Add, oView
    oContainer->Add, oTrack

    state = {center: xdim/2., $            ; X Center of drawing area
          radius: ydim/2, $                ; Sphere radius (1/2 drawing area height)
          size_2: xdim/2., $               ; Shpere size (1/2 drawing area width)
          btndown: 0b, $                   ; Mouse 0=not pressed, pressed otherwise
          wDraw3D: wDraw3D, $              ; Widget draw ID
          annotation: annotation, $        ; Annotation Model
          top3D: top3D, $                  ; Topmodel for 3-D
          iso_text: iso_text, $            ; Model for isosurface text
          bounds: bounds, $                ; Box object
          lite1_icon: lite1_icon, $        ; Light icon 1 model
          lite2_icon: lite2_icon, $        ; Light icon 2 model
          bore_obj: bore_obj, $            ; Bore holes object
          vol1_obj: vobj1, $               ; Volume objects
          vol2_obj: vobj2, $               ; Volume objects
          tanks: tanks, $                  ; Tanks model
          tank1_poly: tank1_poly, $        ; Tanks polyline objects
          tank2_poly: tank2_poly, $
          tank3_poly: tank3_poly, $
          tank4_poly: tank4_poly, $
          tank5_poly: tank5_poly, $
          isosurface1: isosurface1, $      ; Isosurface (polygon) object
          iso_value: iso_value, $          ; Isosurface value
          low: low, $                      ; Show low values of the isosurface
          DisplayText: displayText, $      ; Text object
          ComputingText: computingText, $  ; 'Computing' string
          WBase: wBase, $                  ; Top level base
          WWireButton: wWireButton, $      ; Functionality buttons
          WSolidButton: wSolidButton, $
          WDragHiButton: wDragHiButton, $
          WDragLowButton: wDragLowButton, $
          WFlatButton: wFlatButton, $
          WGouraudButton: wGouraudButton, $
          WSlider: wSlider, $              ; Isosurface value slider
          OTrack: oTrack, $                ; Trackball object
          OContainer: oContainer, $        ; Container object
          volume1: volume1, $              ; Volume data of element 1
          volume2: volume2, $              ; Volume data of element 2
          ivol_ptr: ptr_new(volume1), $    ; Pointer ot volume data 1
          cvol_ptr: ptr_new(volume1), $    ; Pointer ot volume data 2
          ivolume: 1, $                    ; Current volume for element x
          cvolume: 1, $                    ; Current color for element x
          color_model: color_model, $      ; Color model
          iso_verts: iso_verts, $          ; Isosurface vertices
          iso_polys: iso_polys, $          ; Isosurface polylines coordinates
          iso_color: iso_color, $          ; Isosurface color vertex
          iso_on: iso_on, $                ; Object : 0= hide, 1 = showing
          bores_on: bores_on, $
          tanks_on: tanks_on, $
          box_on: box_on, $
          text_on: text_on, $
          lite_on: lite_on, $
          OView: oView, $                  ; View object
      f: font, $                       ; Font objects
          Font: font, $
          Font_small: font_small, $
          Font_medium: font_medium, $
          Font_large: font_large, $
          ColorTable: colortable, $        ; Color table to restore
          dragq : 0, $                     ; Drag quality: 0=low, 1=med., 2=high
          PreviousSliderValue: previousSliderValue, $ : As is
          SText: sText, $                  ; Text structure for tips
          OText: oText, $                  ; Text object
          OFont: oFont, $                  ; Font object
          OWindow: oWindow, $              ; Window object
          groupBase: groupBase $           ; Base of Group Leader
         }

    ;  Set the isosurface shading to Gouraud.
    ;
    isosurface1->SetProperty, SHADING=1

    ;  Draw the screen. Remove the starting up text.
    ;
    top_tmp->Remove, oText
    oWindow->Draw, oView

    WIDGET_CONTROL, wBase, SET_UVALUE=state, /NO_COPY

    XMANAGER, 'd_tankleak', wBase, $
        /NO_BLOCK, $
        EVENT_HANDLER='d_tankleakEvent', $
        CLEANUP='d_tankleakCleanup'

end ; D_Tankleak
