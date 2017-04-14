; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_volrendr.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_volrendr.pro
;
;  CALLING SEQUENCE: d_volrendr
;
;  PURPOSE:
;       Shows the volume rendering techniques.
;
;  MAJOR TOPICS: Visualization and data processing.
;
;  CATEGORY:
;       IDL 5.1
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  MODIFICATION HISTORY: Written by RF, RSI, 1996
;                        Modified by DAT,RSI, 1996 New GUI
;                        New datasets, controls, code improvements, 1998 PCS
;                        Data-centric rotation constraints, 7/1998 PCS
;
;-

;----------------------------------------------------------------------------
;
;PURPOSE  Load table names per filenames given by wild card string.
;
function d_volrendrTableNames, $
    wild, $         ; IN: wild card string ex: "*_mri.opa".
    full_filenames  ; OUT: fully qualified filenames matching wild card string.

COMPILE_OPT idl2, hidden

;
;Find all files with names that end with the characters specified
;by 'wild' .
;
full_filenames = FILE_SEARCH( $ ; return parameter.
    demo_filepath(wild, SUBDIR=['examples','demo','demodata']) $
    )

case !version.os of
    'vms': sep = "."
    'Win32': sep = "\"
    'MacOS' : sep = ":"
    else: sep = "/"
    endcase

if STRLEN(wild) gt 1 then begin
    splat_pos = STRPOS(wild, '*')
    if splat_pos gt -1 then $
        clipped_wild = STRMID(wild, splat_pos + 1, 1000)
    end

result = strarr(N_ELEMENTS(full_filenames))
for i=0,N_ELEMENTS(result)-1 do begin
;
;   Assign to 'result' the un-qualified filenames that matched 'wild'.
;
    if (!VERSION.OS_FAMILY eq 'vms') then begin
        result[i] = full_filenames[i]
        bracketPos = RSTRPOS(result[i],']')
        if (bracketPos GE 0) then $
            result[i] = strmid( $
                result[i], $
                bracketPos + 1, $
                STRLEN(result[i]) - bracketPos-1 $
                )
        semicolonPos = STRPOS(result[i],';')
        if (semicolonPos GE 0) then $
            result[i] = strmid( $
                result[i], $
                0, $
                semicolonPos $
                )
        end $
    else begin
        temp = STRTOK(full_filenames[i], sep, /EXTRACT)
        result[i] = temp[N_ELEMENTS(temp) - 1]
        end

    if N_ELEMENTS(clipped_wild) gt 0 then begin
;
;       Reduce 'result' to be the part of the filename masked
;       by the '*' in 'wild' (and any characters preceding '*').
;
        result[i] = STRMID( $
            result[i], $
            0, $
            STRPOS( $
                STRUPCASE(result[i]), $
                STRUPCASE(clipped_wild) $
                ) $
            )
        end
;
    end

return, STRLOWCASE(result)
end
;
;----------------------------------------------------------------------------
;
; PURPOSE  Set the color or opacity table.
;
pro d_volrendrSetTable, $
    rVolume, $       ; IN: volume object
    table_type, $    ; IN: 0=color, 1= opacity
    filename, $      ; IN: where to read the table from.
    MULTI_VOLUME=multi_volume ; IN: (optional). Integer.  Enumerate which
                     ;  volume of a multi-volume is to be set.
COMPILE_OPT idl2, hidden

success = 0b
;
;Read the table(color or opacity).
;
GET_LUN, lun
newTable = BYTARR(256,3)

ON_IOERROR, bail_out
OPENR, lun, filename
READU, lun, newTable
CLOSE, lun
FREE_LUN,lun
if N_ELEMENTS(multi_volume) eq 0 then $
    multi_volume = 0

case table_type of
    0 : case multi_volume of ; color
            0: rVolume->SetProperty, RGB_TABLE0=newTable
            1: rVolume->SetProperty, RGB_TABLE1=newTable
            else: MESSAGE, 'Illegal MULTI_VOLUME value.'
        endcase
    1 : case multi_volume of ; opacity
            0: rVolume->SetProperty, OPACITY_TABLE0=newTable[*,0]
            1: rVolume->SetProperty, OPACITY_TABLE1=newTable[*,0]
            else: MESSAGE, 'Illegal MULTI_VOLUME value.'
        endcase
endcase
success = 1b
bail_out:
if not success then begin
    FREE_LUN, lun
    help, filename
    print, !error_state.msg
    end
end       ;    of d_volrendrSetTable
;
;----------------------------------------------------------------------------
function d_volrendrLoadVolume, $
    volume_name, $  ; String identifying which volume to load.
    rParentModel    ; Model to contain the newly created volume object.

COMPILE_OPT idl2, hidden

GET_LUN,lun ; Get a logical unit number.

case volume_name of

    'Brain': begin
;
;       Read the brain data.
;
        restore, demo_filepath('mri.sav', $ ; vol0
            SUBDIR=['examples','demo','demodata'])

        restore, demo_filepath('pet.sav', $ ; vol1
            SUBDIR=['examples','demo','demodata'])

        volume_select = 1 ; do dual volume rendering
        zc = 1.0
        end
;
    'Cloud': begin
;
;       Read the Electron Cloud data.
;
        vol0 = BYTARR(64, 64, 64)
        OPENR, lun, /XDR, demo_filepath('hipiph.dat', $
            SUBDIR=['examples','demo','demodata'])
        READU, lun, vol0

        CLOSE, lun

        volume_select = 0 ; don't do dual volume rendering
        zc = 1.0
        end
;
    endcase
;
;Create the volume object.
;
FREE_LUN,lun
;
;Construct volume object, applying translation and scale such that the volume
;fits inside a 1-unit cube centered at 0,0,0.
;
i = SIZE(vol0)
m = i[1] > i[2] > (i[3] * zc)
sx = 1.0 / m            ; scale x.
sy = 1.0 / m            ; scale y.
sz =(1.0 / m) * zc      ; scale z.
ox = -i[1] * sx * 0.5   ; offset x.
oy = -i[2] * sy * 0.5   ; offset y.
oz = -i[3] * sz * 0.5   ; offset z.

rVolume = OBJ_NEW('IDLgrVolume', $
    vol0, $
    xcoord_conv=[ox, sx], $
    ycoord_conv=[oy, sy], $
    zcoord_conv=[oz, sz], $
    /NO_COPY, $
    NAME=volume_name)
if N_ELEMENTS(vol1) gt 0 then $
    rVolume->SetProperty, DATA1=vol1

rVolume->SetProperty, HINT=2 ; Use multiple CPUs, if we can.

rVolume->SetProperty, /ZERO_OPACITY_SKIP, HIDE=1
rVolume->SetProperty, /ZBUFFER, VOLUME_SELECT=volume_select

rParentModel->Add, rVolume

if (volume_name eq 'Heart') then begin
    rVolume->SetProperty, AMBIENT=[130,130,130]
    endif
;
;Return the volume object.
;
RETURN, rVolume

end         ;  d_volrendrLoadVolume
;----------------------------------------------------------------------------
;
; PURPOSE  Invoke draw method for our application's IDLgrWindow.
;
pro d_volrendrDraw, state, QUALITY=quality

COMPILE_OPT idl2, hidden

if state.suppress_draws then $
    RETURN

if N_ELEMENTS(quality) eq 0 then begin
    state.rWindow->GetProperty, QUALITY=quality
    end $
else begin
    state.rWindow->SetProperty, QUALITY=quality
    end
;
;Silently flush any accumulated math error.
;
void = check_math()
;
;Silently accumulate any subsequent math errors.
;
orig_except = !except
!except = ([0, 2])[keyword_set(state.debug)]
;
;Draw.
;
case quality of
    0: begin
        if state.cur eq 1 then begin ; Probability Cloud
;
;           Show the colored wire box in place of the volume.
;
            state.rVolumeArray[1]->SetProperty, HIDE=1
            state.rPartialBox->SetProperty, HIDE=0
            state.rRedSpoke->SetProperty, HIDE=0
            state.rGreenSpoke->SetProperty, HIDE=0
            state.rBlueSpoke->SetProperty, HIDE=0
            state.rOtherObjectArray[0]->GetProperty, HIDE=wire_box_hidden
            state.rOtherObjectArray[0]->SetProperty, HIDE=1
            end

        state.rView->Add, state.rToysModel
        state.rWindow->Draw, state.rView
        state.rView->Remove, state.rToysModel

        if state.cur eq 1 then begin ; Probability Cloud
;
;           Restore the volume in place of the colored wire box.
;
            state.rVolumeArray[1]->SetProperty, HIDE=0
            state.rPartialBox->SetProperty, HIDE=1
            state.rRedSpoke->SetProperty, HIDE=1
            state.rGreenSpoke->SetProperty, HIDE=1
            state.rBlueSpoke->SetProperty, HIDE=1
            state.rOtherObjectArray[0]->SetProperty, HIDE=wire_box_hidden
            end
        end
    1: begin
        tic = systime(1)
        WIDGET_CONTROL, state.wBase, SENSITIVE=0
        WIDGET_CONTROL, /HOURGLASS

        state.rView->Add, state.rToysModel, POSITION=0
        state.rWindow->Draw, state.rView, /CREATE_INSTANCE
        state.rView->Remove, state.rToysModel

        state.an_instance_exists = 1b ; true from now on.

        state.rTransparentView->Add, state.rToysModel
        state.rWindow->Draw, state.rTransparentView, /DRAW_INSTANCE
        state.rTransparentView->Remove, state.rToysModel
;       print, systime(1) - tic, ' Seconds'
        end
    2: begin
        tic = systime(1)
        WIDGET_CONTROL, state.wBase, SENSITIVE=0
        WIDGET_CONTROL, /HOURGLASS

        state.rView->Add, state.rToysModel, POSITION=0
        state.rWindow->Draw, state.rView, /CREATE_INSTANCE
        state.rView->Remove, state.rToysModel

        state.an_instance_exists = 1b ; true from now on.

        state.rWindow->Draw, state.rTransparentView, /DRAW_INSTANCE
;       print, systime(1) - tic, ' Seconds'
        end
    endcase
;
;Ignore any accumulated floating underflow errors.  (They are benign).
;Display any other accumulated math errors.
;
floating_point_underflow = 32 ; Per IDL Reference Guide: see Check_Math().
status = check_math()         ; Get status and reset.
if (status and not floating_point_underflow) ne 0 then $
    print, 'IDL Check_Math() error: ' + strtrim(status, 2)
;
;Restore original math error behavior.
;
!except = orig_except
;
state.cursor_stale = 0b ; 3D grapics cursor appearance is up to date.
WIDGET_CONTROL, state.wBase, SENSITIVE=1

end
;----------------------------------------------------------------------------
;
; PURPOSE  Refresh our applications's IDLgrWindow
;
pro d_volrendrRefresh, state

COMPILE_OPT idl2, hidden

state.rWindow->GetProperty, QUALITY=quality
if state.an_instance_exists then $
    case quality of
        0: d_volrendrDraw, state, QUALITY=quality
        1: begin
            state.rTransparentView->Add, state.rToysModel, POSITION=0
            state.rWindow->Draw, state.rTransparentView, /DRAW_INSTANCE
            state.rTransparentView->Remove, state.rToysModel
            end
        2: state.rWindow->Draw, state.rTransparentView, /DRAW_INSTANCE
        endcase $
else $
    d_volrendrDraw, state, QUALITY=quality

end
;----------------------------------------------------------------------------
;
; PURPOSE  Toggle the buton state between off and on.
;
function d_volrendrToggleState, $
    widgetID         ; IN: button widget identifer.

COMPILE_OPT idl2, hidden

WIDGET_CONTROL, widgetID, GET_VALUE=name

s = STRPOS(name,'(off)')
if (s NE -1) then begin
    STRPUT, name, '(on )', s
    ret = 1
    end $
else begin
    s = STRPOS(name,'(on )')
    STRPUT, name, '(off)', s
    ret = 0
    end

WIDGET_CONTROL, widgetID, SET_VALUE=name
RETURN, ret
end

;----------------------------------------------------------------------------
;
; PURPOSE  Handle GUI events.
;
pro d_volrendrEvent, $
    event              ; IN: event structure.

COMPILE_OPT idl2, hidden

WIDGET_CONTROL, event.top, GET_UVALUE=pState

demo_record, event, $
    FILENAME=(*pState).record_to_filename, $
    CW=[ $
        (*pState).wQuality, $
        (*pState).wVolBGroup, $
        (*pState).wAutoRenderButton, $
        (*pState).wLightButton $
        ]

if (TAG_NAMES(event, /STRUCTURE_NAME) eq  $
    'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, event.top, /DESTROY
    RETURN
    endif
;
;Get the event user value.
;
WIDGET_CONTROL, event.id, GET_UVALUE=uval
;
;Branch to the correct event user value.
;
case uval of
    'HOTKEY' : begin ; Left Mouse-Button Mode.
        case STRUPCASE(event.ch) of
            'U': begin ; unconstrained rotation
                (*pState).lmb_scale = 0
                (*pState).rModelArray[0]->SetProperty, CONSTRAIN=0
                (*pState).rModelArray[1]->SetProperty, CONSTRAIN=0
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=0
                end
            'X': begin
                (*pState).lmb_scale = 0
                (*pState).axis = 0
                (*pState).rModelArray[0]->SetProperty, AXIS=0, /CONSTRAIN
                (*pState).rModelArray[1]->SetProperty, AXIS=0, /CONSTRAIN
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=1
                end
            'Y': begin
                (*pState).lmb_scale = 0
                (*pState).axis = 1
                (*pState).rModelArray[0]->SetProperty, AXIS=1, /CONSTRAIN
                (*pState).rModelArray[1]->SetProperty, AXIS=1, /CONSTRAIN
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=2
                end
            'Z': begin
                (*pState).lmb_scale = 0
                (*pState).axis = 2
                (*pState).rModelArray[0]->SetProperty, AXIS=2, /CONSTRAIN
                (*pState).rModelArray[1]->SetProperty, AXIS=2, /CONSTRAIN
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=3
                end
            'R': begin
                (*pState).lmb_scale = 0
                (*pState).axis = 0
                (*pState).rModelArray[0]->SetProperty, AXIS=0, CONSTRAIN=2
                (*pState).rModelArray[1]->SetProperty, AXIS=0, CONSTRAIN=2
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=4
                end
            'G': begin
                (*pState).lmb_scale = 0
                (*pState).axis = 1
                (*pState).rModelArray[0]->SetProperty, AXIS=1, CONSTRAIN=2
                (*pState).rModelArray[1]->SetProperty, AXIS=1, CONSTRAIN=2
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=5
                end
            'B': begin
                (*pState).lmb_scale = 0
                (*pState).axis = 2
                (*pState).rModelArray[0]->SetProperty, AXIS=2, CONSTRAIN=2
                (*pState).rModelArray[1]->SetProperty, AXIS=2, CONSTRAIN=2
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=6
                end
            'S': begin
                (*pState).lmb_scale = 1
                WIDGET_CONTROL, (*pState).wLMBMode, SET_DROPLIST_SELECT=7
                end
            else:
            endcase
        (*pState).rModelArray[0]->GetProperty, CONSTRAIN=constrain
        if constrain eq 2 and STRUPCASE(event.ch) ne 'S' then begin
            if d_volrendrToggleState((*pState).wAxesButton) eq 0 then $
                void = d_volrendrToggleState((*pState).wAxesButton) $
            else begin
                (*pState).rOtherObjectArray[7]->SetProperty, HIDE=0
                d_volrendrDraw, *pState, $
                    QUALITY= $
                        ([0,(*pState).render_quality])[(*pState).auto_render]
                end
            end
        end
    'LMBMODE' : begin ; Left Mouse-Button Mode.
        case event.index of
            0: begin ; unconstrained rotation
                (*pState).lmb_scale = 0
                (*pState).axis = 3
                (*pState).rModelArray[0]->SetProperty, CONSTRAIN=0
                (*pState).rModelArray[1]->SetProperty, CONSTRAIN=0
                end
            1: begin
                (*pState).lmb_scale = 0
                (*pState).axis = 0
                (*pState).rModelArray[0]->SetProperty, AXIS=0, /CONSTRAIN
                (*pState).rModelArray[1]->SetProperty, AXIS=0, /CONSTRAIN
                (*pState).screen_rotate = 1
                end
            2: begin
                (*pState).lmb_scale = 0
                (*pState).axis = 1
                (*pState).rModelArray[0]->SetProperty, AXIS=1, /CONSTRAIN
                (*pState).rModelArray[1]->SetProperty, AXIS=1, /CONSTRAIN
                end
            3: begin
                (*pState).lmb_scale = 0
                (*pState).axis = 2
                (*pState).rModelArray[0]->SetProperty, AXIS=2, /CONSTRAIN
                (*pState).rModelArray[1]->SetProperty, AXIS=2, /CONSTRAIN
                end
            4: begin
                (*pState).lmb_scale = 0
                (*pState).axis = 0
                (*pState).rModelArray[0]->SetProperty, AXIS=0, CONSTRAIN=2
                (*pState).rModelArray[1]->SetProperty, AXIS=0, CONSTRAIN=2
                end
            5: begin
                (*pState).lmb_scale = 0
                (*pState).axis = 1
                (*pState).rModelArray[0]->SetProperty, AXIS=1, CONSTRAIN=2
                (*pState).rModelArray[1]->SetProperty, AXIS=1, CONSTRAIN=2
                end
            6: begin
                (*pState).lmb_scale = 0
                (*pState).axis = 2
                (*pState).rModelArray[0]->SetProperty, AXIS=2, CONSTRAIN=2
                (*pState).rModelArray[1]->SetProperty, AXIS=2, CONSTRAIN=2
                end
            7: begin
                (*pState).lmb_scale = 1
                end
            else:
            endcase
        (*pState).rModelArray[0]->GetProperty, CONSTRAIN=constrain
        if constrain eq 2 and event.index ne 7 then begin
            if d_volrendrToggleState((*pState).wAxesButton) eq 0 then $
                void = d_volrendrToggleState((*pState).wAxesButton) $
            else begin
                (*pState).rOtherObjectArray[7]->SetProperty, HIDE=0
                d_volrendrDraw, *pState, $
                    QUALITY= $
                        ([0,(*pState).render_quality])[(*pState).auto_render]
                end
            end
        end
    'CUTTING_PLANE' : begin
        for i=0,N_ELEMENTS((*pState).rVolumeArray)-1 do begin
            (*pState).rVolumeArray[i]->GetProperty, YRANGE=yrange
            (*pState).rVolumeArray[i]->SetProperty, $
                CUTTING_PLANE=[0,1,0, -(event.value / 100.) * yrange[1]]
            end

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
    'PET_COLOR' : begin
        d_volrendrSetTable,             $
            (*pState).rVolumeArray[(*pState).cur],  $
            0,                          $
            (*pState).pet_color_files[event.index], $
            MULTI_VOL=1

        white_name = demo_filepath( $
            'white_pet.pal', $; file that contains uniform, pure white.
            SUBDIR=['examples','demo','demodata'] $
            )

        if STRPOS((*pState).pet_color_files[event.index], white_name) $
        eq 0 then $
            (*pState).pet_is_white = 1b $
        else $
            (*pState).pet_is_white = 0b

        if (*pState).pet_is_white and (*pState).pet_is_solid then $
;
;           We don't need to render the PET part of the dual volume.
;
            (*pState).rVolumeArray[(*pState).cur]->SetProperty, $
                VOLUME_SELECT=0 $
        else $
            (*pState).rVolumeArray[(*pState).cur]->SetProperty, $
                VOLUME_SELECT=1

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
    'PET_OPACITY' : begin
        d_volrendrSetTable,             $
            (*pState).rVolumeArray[(*pState).cur],  $
            1,                          $
            (*pState).pet_opacity_files[event.index], $
            MULTI_VOL=1

        solid_name = demo_filepath( $
            'solid_pet.opa', $ ; file that contains uniform solid values
            SUBDIR=['examples','demo','demodata'] $
            )

        if STRPOS((*pState).pet_opacity_files[event.index], solid_name) $
        eq 0 then $
            (*pState).pet_is_solid = 1b $
        else $
            (*pState).pet_is_solid = 0b

        if (*pState).pet_is_white and (*pState).pet_is_solid then $
;
;           We don't need to render the PET part of the dual volume.
;
            (*pState).rVolumeArray[(*pState).cur]->SetProperty, $
                VOLUME_SELECT=0 $
        else $
            (*pState).rVolumeArray[(*pState).cur]->SetProperty, $
                VOLUME_SELECT=1

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
    'MRI_COLOR' : begin
        d_volrendrSetTable,             $
            (*pState).rVolumeArray[(*pState).cur],  $
            0,                          $
            (*pState).mri_color_files[event.index]

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
    'MRI_OPACITY' : begin
        d_volrendrSetTable,             $
            (*pState).rVolumeArray[(*pState).cur],  $
            1,                          $
            (*pState).mri_opacity_files[event.index]

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
    'IRON_COLOR' : begin
        d_volrendrSetTable,             $
            (*pState).rVolumeArray[(*pState).cur],  $
            0,                          $
            (*pState).iron_color_files[event.index]

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
    'IRON_OPACITY' : begin
        d_volrendrSetTable,             $
            (*pState).rVolumeArray[(*pState).cur],  $
            1,                          $
            (*pState).iron_opacity_files[event.index]

        if STRPOS((*pState).iron_opacity_files[event.index], "shells") ne -1 $
        then begin
;
;           For nicety, turn on gradient shading.  It looks good with our
;           "shells" opacity.
;
            WIDGET_CONTROL, (*pState).wLightButton, /SET_BUTTON
            d_volrendrEvent, { $
                id: (*pState).wLightButton, $
                top: event.top, $
                handler: 0L, $
                select: 1 $
                }
            end $
        else $
            d_volrendrDraw, *pState, $
                QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
;
;   Render the image and display it.
;
    'RENDER' : begin
        d_volrendrDraw, *pState, QUALITY=(*pState).render_quality
        end
;
;   Set on or off the auto rendering property.
;
    'AUTORENDER' : begin
        (*pState).auto_render = event.select
        WIDGET_CONTROL, (*pState).wRenderButton, $
            SENSITIVE=([1, 0])[event.select]
        if (*pState).auto_render then begin
            (*pState).rWindow->GetProperty, QUALITY=current_quality

            (*pState).rOtherObjectArray[2]->GetProperty, $ ; 3D Cursor.
                HIDE=hide

            if ((hide eq 0) and (*pState).cursor_stale) $
            or (current_quality ne (*pState).render_quality) then $
                d_volrendrDraw, *pState, QUALITY=(*pState).render_quality
            end
        end   ; of AUTORENDER
;
;   Select a volume to display.
;
    'VOLSEL': begin
        (*pState).cur = event.value
;
;       Hide the annnotation text (all 3).
;
        for i=3,5 do (*pState).rOtherObjectArray[i]->SetProperty, HIDE=1

        case event.value of
;
;           Show the brain.
;
            0: begin
                (*pState).rVolumeArray[0]->SetProperty, HIDE=0
                (*pState).rVolumeArray[1]->SetProperty, HIDE=1
                (*pState).rOtherObjectArray[4]->SetProperty, HIDE=0

                if not (*pState).suppress_draws then begin
                    WIDGET_CONTROL, (*pState).wBrainTablesBase, MAP=1
                    WIDGET_CONTROL, (*pState).wIronTablesBase,  MAP=0
                    end

                d_volrendrDraw, *pState, $
                    QUALITY=$
                        ([0,(*pState).render_quality])[(*pState).auto_render]
                end
;
;           Show the Electron Cloud.
;
            1: begin
                (*pState).rVolumeArray[0]->SetProperty, HIDE=1
                (*pState).rVolumeArray[1]->SetProperty, HIDE=0
                (*pState).rOtherObjectArray[5]->SetProperty, HIDE=0

                if not (*pState).suppress_draws then begin
                    (*pState).suppress_draws = 1

                    WIDGET_CONTROL, (*pState).wBrainTablesBase, MAP=0
                    WIDGET_CONTROL, (*pState).wIronTablesBase,  MAP=1

                    WIDGET_CONTROL, (*pState).wCuttingSlider, SET_VALUE=0
                        d_volrendrEvent, { $
                            id: (*pState).wCuttingSlider, $
                            top: event.top, $
                            handler: 0L, $
                            value: 0, $
                            drag: 0 $
                            }

;
;                   Show the wire box.  Looks nice.
;
                    if d_volrendrToggleState((*pState).wWireBoxButton) eq 0 $
                    then $
                        void = d_volrendrToggleState((*pState).wWireBoxButton)
                    (*pState).rOtherObjectArray[0]->SetProperty, HIDE=0
;
;                   If we are not under a data-centric rotation constraint,
;                   then hide the axes.  Looks nicer.
;
                    (*pState).rModelArray[1]->GetProperty, CONSTRAIN=constrain
                    if constrain ne 2 then begin
                        if d_volrendrToggleState((*pState).wAxesButton) eq 1 $
                        then $
                            void=d_volrendrToggleState((*pState).wAxesButton) $
                        else begin
                            (*pState).rOtherObjectArray[7]->SetProperty, HIDE=1
                            d_volrendrDraw, *pState, $
                                QUALITY= $
                                    ([0,(*pState).render_quality]) $
                                        [(*pState).auto_render]
                            end
                        end
;
                    (*pState).suppress_draws = 0
                    end

                d_volrendrDraw, *pState, $
                    QUALITY= $
                        ([0,(*pState).render_quality])[(*pState).auto_render]

                end

            endcase

        end   ; of VOLSEL
;
;   Turn on or off the lights.
;
    'LIGHTING': begin
        for i = 0, N_ELEMENTS((*pState).rVolumeArray)-1 do begin
            (*pState).rVolumeArray[i]->SetProperty, $
                LIGHTING_MODEL=event.select
            endfor

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]

        end   ; of LIGHTING
;
;   Hide or show the wire box object.
;
    'WIREBOX' : begin
        j = d_volrendrToggleState(event.id)
        (*pState).rOtherObjectArray[0]->SetProperty, HIDE=1-j

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]

        end
;
;   Hide or show the solid plane object.
;
    'SOLIDPLANE' : begin
        j = d_volrendrToggleState(event.id)
        (*pState).rOtherObjectArray[1]->SetProperty, HIDE=1-j
        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end   ; of SOLIDPLANE
;
;   Show or hide the axis object.
;
    'AXES' : begin
        j = d_volrendrToggleState(event.id)
        (*pState).rOtherObjectArray[7]->SetProperty,HIDE=1-j
        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
;
;   Show or hide the 3D cursor object.

    'CURSOR' : begin
        j = d_volrendrToggleState(event.id)
        (*pState).rOtherObjectArray[2]->SetProperty,HIDE=1-j
        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]
        end
;
;   Set the user-indicated render step.
;
    'XSTEP' : begin
        (*pState).rVolumeArray[0]->GetProperty, RENDER_STEP=render_step
        render_step[0] = event.value + 1
        for i = 0, N_ELEMENTS((*pState).rVolumeArray)-1 do begin
            (*pState).rVolumeArray[i]->SetProperty, RENDER_STEP=render_step
            end

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]

        end

    'YSTEP' : begin
        (*pState).rVolumeArray[0]->GetProperty, RENDER_STEP=render_step
        render_step[1] = event.value + 1
        for i = 0, N_ELEMENTS((*pState).rVolumeArray)-1 do begin
            (*pState).rVolumeArray[i]->SetProperty, RENDER_STEP=render_step
            end

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]

        end

    'ZSTEP' : begin
        (*pState).rVolumeArray[0]->GetProperty, RENDER_STEP=render_step
        render_step[2] = event.value + 1
        for i = 0, N_ELEMENTS((*pState).rVolumeArray)-1 do begin
            (*pState).rVolumeArray[i]->SetProperty, RENDER_STEP=render_step
            end

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]

        end
;
;   Set the user-indicated render quality.
;
    'QUALITY' : begin
        (*pState).render_quality = event.value + 1

        for i=0,N_ELEMENTS((*pState).rVolumeArray)-1 do begin
            (*pState).rVolumeArray[i]->SetProperty, INTERP=event.value
            end

        d_volrendrDraw, *pState, $
            QUALITY=([0,(*pState).render_quality])[(*pState).auto_render]

        end
;
;   Handle events that occur in the drawing area.
;
    'DRAW': begin
        if (event.type eq 4) then begin ; Expose.
            d_volrendrRefresh, *pState
            endif

        if (event.type eq 0) then $
            if (event.press eq 1) AND ((*pState).lmb_scale eq 1) then $
                event.press = 2     ; virtual button 2 event.
;
;       Rotation updates.
;
        if (*pState).rModelArray[0]->Update(event) $
        or (*pState).rModelArray[1]->Update(event) then begin
            d_volrendrDraw, *pState, QUALITY=0
            end
;
;       Mouse button press.
;
        if (event.type eq 0) then begin
            case event.press of
                2 : begin
;
;                   Middle mouse-button.  Scale the objects.
;
                    xy = ([event.x, event.y] - (*pState).center)
                    r= TOTAL(xy^2) ; distance from center of unit circle
                    (*pState).sc[1] = SQRT(r)
                    (*pState).sc[2] = 1.0
                    end
                4 : begin
;
;                   Right mouse-button
;
                    (*pState).rWindow->GetProperty, QUALITY=current_quality
                    if (current_quality ge 1) then begin
;
;                       Pick a voxel point.
;
                        j = (*pState).rVolumeArray[(*pState).cur]->pickvoxel( $
                            (*pState).rWindow, $
                            (*pState).rView,[event.x, event.y] $
                            )
                        k = -1

                        if (j[0] NE -1) then begin
                            if (*pState).cur eq 0 then $; Get PET volume
                                (*pState).rVolumeArray[0]->GetProperty, $
                                    DATA1=dd, /NO_COPY $
                            else $
                                (*pState).rVolumeArray[ $
                                    (*pState).cur]->GetProperty, $
                                        DATA0=dd, /NO_COPY
                            k = dd[j[0],j[1],j[2]]
                            if (*pState).cur eq 0 then $; Set PET volume
                                (*pState).rVolumeArray[0]->SetProperty, $
                                        DATA1=dd, /NO_COPY $
                            else $
                                (*pState).rVolumeArray[ $
                                    (*pState).cur]->SetProperty, $
                                        DATA0=dd, /NO_COPY
                            end
;
;                       Display the point coordinates and its value.
;
                        str = string(   $
                            j[0],       $
                            j[1],       $
                            j[2],       $
                            k,          $
                            FORMAT='("X=",I3.3,",Y=",I3.3,",Z=",I3.3,' $
                                  +'",Value=",I3.3)' $
                            )
                        demo_putTips, (*pState), str, 10
                        end
                    end
                else:
                endcase
            (*pState).btndown = event.press
            WIDGET_CONTROL,(*pState).wDraw, /DRAW_MOTION
            endif
;
;       Mouse-button motion.
;
        if event.type eq 2 then begin
            case (*pState).btndown of
                4: begin ; Right mouse-button.
                    (*pState).rWindow->GetProperty, QUALITY=current_quality
                    if current_quality ge 1 then begin
                        j = (*pState).rVolumeArray[(*pState).cur]->pickvoxel( $
                                (*pState).rWindow, $
                                (*pState).rView,[event.x,event.y] $
                                )
                        k= -1

                        if (j[0] NE -1) then begin
                            if (*pState).cur eq 0 then $ ; Get PET volume
                                (*pState).rVolumeArray[0]->GetProperty, $
                                    DATA1=dd, /NO_COPY $
                            else $
                                (*pState).rVolumeArray[ $
                                    (*pState).cur]->GetProperty, $
                                        DATA0=dd, /NO_COPY
                            k = dd[j[0],j[1],j[2]]
                            if (*pState).cur eq 0 then $ ; Set PET volume
                                (*pState).rVolumeArray[0]->SetProperty, $
                                        DATA1=dd, /NO_COPY $
                            else $
                                (*pState).rVolumeArray[ $
                                    (*pState).cur]->SetProperty, $
                                        DATA0=dd, /NO_COPY
                            end
;
;                       Display the voxel location and value.
;
                        str = string(   $
                            j[0],       $
                            j[1],       $
                            j[2],       $
                            k,          $
                            FORMAT='("X=",I3.3,",Y=",I3.3,",Z=",I3.3,' $
                                  +'",Value=",I3.3)' $
                            )
                        demo_putTips, (*pState), str, 10
                        end
                    end
                2: begin
                    xy = ([event.x,event.y] - (*pState).center)
                    r = total(xy^2) ; distance from center of unit circle
                    (*pState).sc[2] = (SQRT(r) $
                                    / (*pState).sc[1]) $
                                    / (*pState).sc[2]
                    (*pState).rScaleToys->Scale, $
                        (*pState).sc[2], $
                        (*pState).sc[2], $
                        (*pState).sc[2]
                    (*pState).rScaleVolumes->Scale, $
                        (*pState).sc[2], $
                        (*pState).sc[2], $
                        (*pState).sc[2]
                    (*pState).rModelArray[0]->GetProperty, $
                        RADIUS=radius
                    (*pState).rModelArray[0]->SetProperty, $
                        RADIUS=radius*(*pState).sc[2]
                    (*pState).rModelArray[1]->SetProperty, $
                        RADIUS=radius*(*pState).sc[2]
                    (*pState).sc[2] = (SQRT(r)/(*pState).sc[1])
                    d_volrendrDraw, *pState, QUALITY=0
                    end
                else:
                endcase
            end
;
;       Mouse-button release.
;
        if (event.type eq 1) then begin
            case (*pState).btndown of
                2: begin
                    (*pState).sc[0] = (*pState).sc[2] * (*pState).sc[0]
                    end
                4: begin
                    (*pState).rWindow->GetProperty, QUALITY=current_quality
                    if current_quality ge 1 then begin
                        j = (*pState).rVolumeArray[(*pState).cur]->pickvoxel( $
                            (*pState).rWindow, $
                            (*pState).rView,[event.x,event.y] $
                            )
                        k = -1

                        if (j[0] NE -1) then begin
                            if (*pState).cur eq 0 then $ ; Get PET volume
                                (*pState).rVolumeArray[0]->GetProperty, $
                                    DATA1=dd, /NO_COPY $
                            else $
                                (*pState).rVolumeArray[ $
                                    (*pState).cur]->GetProperty, $
                                        DATA0=dd, /NO_COPY
                            k = dd[j[0],j[1],j[2]]
                            if (*pState).cur eq 0 then $ ; Set PET volume
                                (*pState).rVolumeArray[0]->SetProperty, $
                                        DATA1=dd, /NO_COPY $
                            else $
                                (*pState).rVolumeArray[ $
                                    (*pState).cur]->SetProperty, $
                                        DATA0=dd, /NO_COPY
;
;                           Get the volume's coordinate transform.
;
                            (*pState).rVolumeArray[ $
                                (*pState).cur]->GetProperty, $
                                        XCOORD_CONV=x_conv, $
                                        YCOORD_CONV=y_conv, $
                                        ZCOORD_CONV=z_conv
;
;                           Convert to normal coordinates.
;
                            jack = FLTARR(3)
                            jack[0] = x_conv[1]*j[0] + x_conv[0]
                            jack[1] = y_conv[1]*j[1] + y_conv[0]
                            jack[2] = z_conv[1]*j[2] + z_conv[0]
;
;                           Apply the difference.
;
                            (*pState).rOtherObjectArray[6]->Translate, $
                                jack[0]-(*pState).jpos[0], $
                                jack[1]-(*pState).jpos[1], $
                                jack[2]-(*pState).jpos[2]
;
;                           Store the new location.
;
                            (*pState).jpos = jack
;
                            (*pState).cursor_stale = 1b ; Until it is drawn.
                            (*pState).rOtherObjectArray[2]->GetProperty, $
                                HIDE=hide
                            if (hide eq 0) and ((*pState).auto_render eq 1) $
                            then $
                                d_volrendrDraw, *pState, $
                                    QUALITY=(*pState).render_quality
                            end
;
;                       Display the voxel location and value numerically.
;
                        str = string(   $
                            j[0],       $
                            j[1],       $
                            j[2],       $
                            k,          $
                            FORMAT='("X=",I3.3,",Y=",I3.3,",Z=",I3.3,' $
                                  +'",Value=",I3.3)' $
                            )
                        demo_putTips, (*pState), str, 10
                        end
                    end
                else:
                endcase

            if (*pState).auto_render then begin
                (*pState).rWindow->GetProperty, QUALITY=current_quality
                if current_quality ne (*pState).render_quality then $
                    d_volrendrDraw, *pState, QUALITY=(*pState).render_quality
                end

            (*pState).btndown = 0
            WIDGET_CONTROL, (*pState).wDraw, DRAW_MOTION=0

            endif

        end   ;of DRAW
;
;   Quit this application.
;
    'QUIT' : begin
        WIDGET_CONTROL, event.top, /DESTROY
        RETURN
        end   ; of QUIT

    'ABOUT' : begin
;
        ONLINE_HELP, $
           book=demo_filepath("d_volrendr.pdf", $
                   SUBDIR=['examples','demo','demohelp']), $
                   /FULL_PATH

        RETURN
        end   ; of ABOUT

    else:
    endcase

if XREGISTERED('demo_tour') eq 0 then $
    WIDGET_CONTROL, (*pState).wHotKeyReceptor, /INPUT_FOCUS

end
;
;----------------------------------------------------------------------------
;
;  Purpose:  Destroy the top objects and restore the previous
;         color table.
;
pro d_volrendrCleanup, $
    wTopBase        ;  IN: top level base identifier

COMPILE_OPT idl2, hidden

WIDGET_CONTROL, wTopBase, GET_UVALUE=pState
;
;Restore the color table.
;
TVLCT, (*pState).colorTable

if WIDGET_INFO((*pState).groupBase, /VALID) then $
    WIDGET_CONTROL, (*pState).groupBase, /MAP
;
;Clean up heap variables.
;
for i=0,n_tags(*pState)-1 do begin
    case size((*pState).(i), /TNAME) of
        'POINTER': $
            ptr_free, (*pState).(i)
        'OBJREF': $
            obj_destroy, (*pState).(i)
        else:
        endcase
    end
PTR_FREE, pState

end
;
;----------------------------------------------------------------------------
;
;  Purpose:  Perform volume rendering.
;
pro d_volrendr, $
    initial_volume=$
    initial_volume, $   ; IN: (opt) 0=start up showing brain, 1=cloud.
    GROUP=group, $      ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    DEBUG=debug, $      ; IN: (opt)
    APPTLB = appTLB, $  ; OUT: (opt) TLB of this application
    rVolumeArray        ; OUT: (opt) references to the volumes.

COMPILE_OPT idl2

;
;Check the validity of the group identifier
;
ngroup = N_ELEMENTS(group)
if (ngroup NE 0) then begin
    check = WIDGET_INFO(group, /VALID_ID)
    if (check NE 1) then begin
        print,'Error, the group identifier is not valid'
        print, 'Returning to the main application'
        RETURN
        endif
    groupBase = group
    endif $
else $
    groupBase = 0L
;
if n_elements(initial_volume) le 0 then $
    initial_volume = 0
if (initial_volume ne 0) and (initial_volume ne 1) then begin
    message, /INFORM, $
        'Incorrect value for keyword INITIAL_VOLUME, using default.'
    initial_volume = 0
    end
;
;Get the current color vectors to restore
;when this application is exited.
;
TVLCT, savedR, savedG, savedB, /GET
;
;Build color table from color vectors
;
colorTable = [[savedR],[savedG],[savedB]]
;
;Create the starting up message.
;
if (ngroup eq 0) then begin
    wStartMes = demo_startmes('Volume Demo', $
        STATUS='Loading volume data...')
    end $
else begin
    wStartMes = demo_startmes('Volume Demo', $
        GROUP=group, $
        STATUS='Loading volume data...')
    end
;
;Create the PLEASE WAIT text.
;
rFont = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=18)
rText = OBJ_NEW('IDLgrText', $
    'Starting up  Please wait...', $
    ALIGN=0.5, $
    LOCATION=textLocation, $
    COLOR=[255,255,0], FONT=rFont)
;
;Set up dimensions for the drawing (viewing) area.
;
device, GET_SCREEN_SIZE=scr
xdim = scr[0] * 0.6; * 0.85
ydim = xdim   * 0.8; * 0.85
;
;Create  model tree.
;
rModelArray = OBJARR(4)
rModelArray[3] = OBJ_NEW('IDLgrModel')
rModelArray[0] = OBJ_NEW('IDLexRotator', $
    [xdim/2.0, ydim/2.0], $
    xdim/2.0 $
    )
rModelArray[1] = OBJ_NEW('IDLexRotator', $
    [xdim/2.0, ydim/2.0], $
    xdim/2.0 $
    )
rModelArray[3]->Add, rModelArray[1]
rModelArray[2] = OBJ_NEW('IDLgrModel')
rModelArray[3]->Add, rModelArray[2]
;
;Add the top model to the view.
;
rView = OBJ_NEW('IDLgrView')
rView->Add, rModelArray[3]
;
rModelArray[3]->Add, rText
;
;Introduce graphics tree nodes dedicated to scaling.
;
rScaleToys = obj_new('IDLgrModel')
rScaleVolumes = obj_new('IDLgrModel')
rModelArray[0]->Add, rScaleToys
;
;Load up the volumes.
;
WIDGET_CONTROL, /HOURGLASS
rVolumeArray = OBJARR(2)
rVolumeArray[0] = d_volrendrLoadVolume('Brain', rScaleVolumes)
rVolumeArray[1] = d_volrendrLoadVolume('Cloud', rScaleVolumes)

rModelArray[1]->Add, rScaleVolumes
;
;Rotate for a nice initial view...
;
rModelArray[1]->Rotate,[0,0,1],([-45, +45])[initial_volume]
rModelArray[0]->Rotate,[0,0,1],([-45, +45])[initial_volume]
rModelArray[1]->Rotate,[1,0,0],-75
rModelArray[0]->Rotate,[1,0,0],-75
;
;Create other intermixed objects.
;
rOtherObjectArray = OBJARR(8)
;
;Create a wire box.
;
xp=[-1, 1, 1,-1, $
    -1, 1, 1,-1] * .5
yp=[-1,-1, 1, 1, $
    -1,-1, 1, 1] * .5
zp=[ 1, 1, 1, 1, $
    -1,-1,-1,-1] * .5
rOtherObjectArray[0] = OBJ_NEW('IDLgrPolyline', $
    xp, $
    yp, $
    zp, $
    POLYLINES=[ $
        5,0,1,2,3,0, $
        5,4,5,6,7,4, $
        3,5,6,7, $
        2,0,4, $
        2,1,5, $
        2,2,6, $
        2,3,7 $
        ], $
    COLOR=[255,255,255] $
    )
rScaleToys->Add, rOtherObjectArray[0]
;
;Create a wire box with colored axes.
;
rPartialBox = OBJ_NEW('IDLgrPolyline', $
    xp, $
    yp, $
    zp, $
    POLYLINES=[ $
        5,0,1,2,3,0, $
        3,5,6,7, $
        2,1,5, $
        2,2,6, $
        2,3,7 $
        ], $
    COLOR=[255,255,255], $
    /HIDE $
    )
rRedSpoke = OBJ_NEW('IDLgrPolyline', $
    xp, $
    yp, $
    zp, $
    POLYLINES=[2,4,5], $
    COLOR=[255,0,0], $
    /HIDE $
    )
rGreenSpoke = OBJ_NEW('IDLgrPolyline', $
    xp, $
    yp, $
    zp, $
    POLYLINES=[2,4,7], $
    COLOR=[0,255,0], $
    /HIDE $
    )
rBlueSpoke = OBJ_NEW('IDLgrPolyline', $
    xp, $
    yp, $
    zp, $
    POLYLINES=[2,4,0], $
    COLOR=[0,0,255], $
    /HIDE $
    )
rScaleToys->Add, rPartialBox
rScaleToys->Add, rRedSpoke
rScaleToys->Add, rGreenSpoke
rScaleToys->Add, rBlueSpoke
;
;Create a solid plane.
;
o = 0.3
verts = TRANSPOSE([[-o,o,o,-o],[-o,-o,o,o],[-o,-o,o,o]])
poly = [4,0,1,2,3]
vc = [200B, 200B, 200]
vc = [[vc],[vc],[vc],[vc]]

rOtherObjectArray[1] = OBJ_NEW('IDLgrPolygon', verts, POLYGONS=poly, $
    VERT_COLOR=vc, SHADING=1)

rScaleToys->Add, rOtherObjectArray[1]
;
;Create 3D Cursor.
;
xpc = [-1.,1.,0.,0.,0.,0.] * .5
ypc = [0.,0.,-1.,1.,0.,0.] * .5
zpc = [0.,0.,0.,0.,-1.,1.] * .5
plc = [2,0,1,2,2,3,2,4,5]

rOtherObjectArray[2] = OBJ_NEW('IDLgrPolyline', xpc, ypc, zpc, $
    POLYLINES=plc, COLOR=[255,255,128])
;
;Something to move the 3D Cursor with.
;
rOtherObjectArray[6] = OBJ_NEW('IDLgrModel')
rOtherObjectArray[6]->Add,  rOtherObjectArray[2]
rScaleToys->Add, rOtherObjectArray[6]
;
;Create Axes.
;
xpc = [-1.,1.,0.,0.,0.,0.]
ypc = [0.,0.,-1.,1.,0.,0.]
zpc = [0.,0.,0.,0.,-1.,1.]
plc = [2,0,1,2,2,3,2,4,5]
vcc = [[255B,0B,0B],[255B,0B,0B], $
       [0B,255B,0B],[0B,255B,0B], $
       [0B,0B,255B],[0B,0B,255B] $
      ]

rOtherObjectArray[7] = OBJ_NEW('IDLgrPolyline', xpc, ypc, zpc, $
    POLYLINES=plc, VERT_COLOR=vcc)

rScaleToys->Add,  rOtherObjectArray[7]
;
;Create a text for information on the objects.
;
font24 = OBJ_NEW( 'IDLgrFont', 'Helvetica', size=18. )
rOtherObjectArray[3] = OBJ_NEW( 'IDLgrText', LOCATION=[10,10], $
    'Hog heart, 132x202x144, X-ray CT', COLOR=[255,255,0], $
    FONT=font24)

rModelArray[2]->Add, rOtherObjectArray[3]
rOtherObjectArray[4] = OBJ_NEW( 'IDLgrText', LOCATION=[10,10], $
    'Human brain, 138,174,119, MRI (T2)', COLOR=[255,255,0], $
    FONT=font24,HIDE=1)

rModelArray[2]->Add, rOtherObjectArray[4]
rOtherObjectArray[5] = OBJ_NEW( 'IDLgrText', LOCATION=[10,10], $
    'Electron Probability Density 64x64x64', COLOR=[255,255,0], $
    FONT=font24,HIDE=1)

rModelArray[2]->Add, rOtherObjectArray[5]
;
;Set to thick lines.
;
if (N_elements(thick) NE 0) then begin
    rOtherObjectArray[2]->SetProperty, THICK=2.0
    rOtherObjectArray[0]->SetProperty, THICK=2.0
    end
;
;Hide the other objects to start.
;
rOtherObjectArray[0]->SetProperty, HIDE=1
rOtherObjectArray[1]->SetProperty, HIDE=1
rOtherObjectArray[2]->SetProperty, HIDE=1
;
;Create s lights.
;
vl = OBJ_NEW('IDLgrLight', DIRECTION=[-1,0,1], TYPE=2)
vl->SetProperty, COLOR=[255,255,255], INTENSITY=1.0
rModelArray[3]->Add, vl

sl = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=1.0)
rModelArray[3]->Add, sl
;
;Enable the brain volume.
;
rVolumeArray[0]->SetProperty, HIDE=0
;
;Set the axes to not show.
;
jack = FLTARR(3)
jack = [0.0,0.0,0.0]
;
;Set up dimensions for the drawing (viewing) area.
;
device, GET_SCREEN_SIZE=scr
xdim = scr[0] * 0.6; * 0.85
ydim = xdim   * 0.8; * 0.85
;
;Update the startup message.
;
void = demo_startmes('Creating widgets...', UPDATE=wStartmes)
;
;Create widgets.
;
if (N_ELEMENTS(group) eq 0) then begin
    wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
        TITLE="Volumes", $
        /TLB_KILL_REQUEST_EVENTS, $
        UNAME='d_volrendr:tlb', $
        TLB_FRAME_ATTR=1, MBAR=barBase)
    endif else begin
    wBase = WIDGET_BASE(/column, XPAD=0, YPAD=0, $
        TITLE="Volumes", $
        GROUP_LEADER=group, $
        /TLB_KILL_REQUEST_EVENTS, $
        UNAME='d_volrendr:tlb', $
        TLB_FRAME_ATTR=1, MBAR=barBase)
    endelse
;
;Create the menu bar.
;
fileMenu = WIDGET_BUTTON(barBase, VALUE='File', /MENU)

wQuitButton = WIDGET_BUTTON(fileMenu, VALUE='Quit', UVALUE='QUIT', $
    UNAME='d_volrendr:quit')

wOptionButton = WIDGET_BUTTON(barBase, VALUE='Options', /MENU)

    wWireBoxButton = WIDGET_BUTTON(wOptionButton, $
        VALUE="Wire Box (off)", UVALUE='WIREBOX', $
        UNAME='d_volrendr:wirebox')

    wSolidPlaneButton = WIDGET_BUTTON(wOptionButton, $
        VALUE="Solid Plane (off)", UVALUE='SOLIDPLANE', $
        UNAME='d_volrendr:solidplane')

    wAxesButton = WIDGET_BUTTON(wOptionButton, $
        VALUE='Axis Lines (off)', UVALUE='AXES', $
        UNAME='d_volrendr:axes')

    wCursorButton = WIDGET_BUTTON(wOptionButton, $
        VALUE='3D Cursor (off)', UVALUE='CURSOR', $
        UNAME='d_volrendr:cursor')
;
;Create the menu bar item help that contains the about button
;
wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP, /MENU)

    wAboutButton = WIDGET_BUTTON(wHelpButton, $
        VALUE='About volumes', UVALUE='ABOUT')
;
subBase = WIDGET_BASE(wBase, COLUMN=2)

    wLeftbase = WIDGET_BASE(subBase, /COLUMN)
        wVolBGroup = CW_BGROUP(wLeftBase, /COLUMN, $
            ['Dual Volume PET MRI','Electron Probability Density'], $
            /EXCLUSIVE, /NO_REL, FRAME=0, UVALUE='VOLSEL', IDS=vol_buttonID)
        WIDGET_CONTROL, wVolBgroup, SET_UNAME='d_volrendr:wVolBGroup'

        wRenderButton = WIDGET_BUTTON(wLeftBase, $
            VALUE="Render", UVALUE='RENDER', UNAME='d_volrendr:render')

        wNonExclusiveBase = WIDGET_BASE(wLeftBase, /NONEXCLUSIVE)
            wAutoRenderButton = WIDGET_BUTTON(wNonExclusiveBase, $
                VALUE="Auto-Render", UVALUE='AUTORENDER', $
                UNAME='d_volrendr:autorender')
            wLightButton = WIDGET_BUTTON(wNonExclusiveBase, $
                VALUE="Gradient Shading",  UVALUE='LIGHTING', $
                UNAME='d_volrendr:gradient_shade')

        pet_color = d_volrendrTableNames('*_pet.pal', pet_color_files)
        mri_color = d_volrendrTableNames('*_mri.pal', mri_color_files)
        iron_color = d_volrendrTableNames('*_hipiph.pal', iron_color_files)

        pet_opacity = d_volrendrTableNames('*_pet.opa', pet_opacity_files)
        mri_opacity = d_volrendrTableNames('*_mri.opa', mri_opacity_files)
        iron_opacity = d_volrendrTableNames('*_hipiph.opa', iron_opacity_files)

        indx = SORT(pet_color)
        pet_color = pet_color[indx]
        pet_color_files =       pet_color_files[indx]

        indx = SORT(mri_color)
        mri_color = mri_color[indx]
        mri_color_files =       mri_color_files[indx]

        indx = SORT(iron_color)
        iron_color = iron_color[indx]
        iron_color_files =      iron_color_files[indx]

        indx = SORT(pet_opacity)
        pet_opacity = pet_opacity[indx]
        pet_opacity_files =     pet_opacity_files[indx]

        indx = SORT(mri_opacity)
        mri_opacity = mri_opacity[indx]
        mri_opacity_files =     mri_opacity_files[indx]

        indx = SORT(iron_opacity) & indx = SHIFT(indx, -1)
        iron_opacity = iron_opacity[indx]
        iron_opacity_files =    iron_opacity_files[indx]

        wStackerBase = WIDGET_BASE(wLeftBase)
            wBrainTablesBase = WIDGET_BASE(wStackerBase, /COLUMN)
                wPetColor = WIDGET_DROPLIST(wBrainTablesBase, $
                    VALUE=pet_color, $
                    TITLE='PET Colors', $
                    UVALUE='PET_COLOR', $
                    UNAME='d_volrendr:pet_color')
                wPetOpacity = WIDGET_DROPLIST(wBrainTablesBase, $
                    VALUE=pet_opacity, $
                    TITLE='PET Opacities', $
                    UVALUE='PET_OPACITY', $
                    UNAME='d_volrendr:pet_opacity')
            wIronTablesBase = WIDGET_BASE(wStackerBase, /COLUMN)
                wIronColor = WIDGET_DROPLIST(wIronTablesBase, $
                    VALUE=iron_color, $
                    TITLE='Colors', $
                    UVALUE='IRON_COLOR', $
                    UNAME='d_volrendr:iron_color')
                wIronOpacity = WIDGET_DROPLIST(wIronTablesBase, $
                    VALUE=iron_opacity, $
                    TITLE='Opacities', $
                    UVALUE='IRON_OPACITY', $
                    UNAME='d_volrendr:iron_opacity')
            WIDGET_CONTROL, wIronTablesBase, MAP=0

        wQuality = CW_BGROUP(wLeftBase, $
            ['medium (faster)', 'high'], $
            LABEL_TOP='Rendering Quality:', $
            /EXCLUSIVE, $
            UVALUE='QUALITY', $
            /NO_RELEASE, $
            /FRAME)
        WIDGET_CONTROL, wQuality, SET_UNAME='d_volrendr:quality_radio'

        void = WIDGET_LABEL(wLeftBase,  $
            VALUE='Left Mouse-Button Action:', $
            /ALIGN_LEFT)
        wLMBMode = WIDGET_DROPLIST(wLeftBase, $ ; left mouse-button mode
            VALUE=["Rotate Unconstrained", $
                "Rotate about Screen X", $
                "Rotate about Screen Y", $
                "Rotate about Screen Z", $
                "Rotate about Data X (Red)", $
                "Rotate about Data Y (Green)", $
                "Rotate about Data Z (Blue)", $
                "Scale"], $
            UVALUE='LMBMODE', $
            UNAME='d_volrendr:mouse_mode', $
            /ALIGN_LEFT)

        wCuttingSlider = WIDGET_SLIDER(wLeftBase, $
            TITLE='Cutting Plane %', $
            UVALUE='CUTTING_PLANE', $
            UNAME='d_volrendr:cutting_plane')
    wRightbase = WIDGET_BASE(subBase)
;
;       Use IDL's software renderer because it is fast at
;       rendering volumes.
;
        renderer=1
;
        wDraw = WIDGET_DRAW(wRightBase, $
            GRAPHICS_LEVEL=2,   $
            XSIZE=xdim,         $
            YSIZE=ydim,         $
            /BUTTON_EVENTS,     $
            UVALUE='DRAW',      $
            RETAIN=0,           $
            /EXPOSE_EVENTS,     $
            UNAME='d_volrendr:draw', $
            RENDERER=renderer)
        wHotKeyReceptor = WIDGET_TEXT(wRightBase, $
            /ALL_EVENTS, $
            UVALUE='HOTKEY', $
            UNAME='d_volrendr:hotkey')
;
;Create the status line label.
;
wStatusBase = WIDGET_BASE(wBase, MAP=0, /ROW)
;
WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, /HOURGLASS
appTLB = wBase ; Returns the top level base to the APPTLB keyword.
sText = demo_getTips(demo_filepath('volrendr.tip', $
                     SUBDIR=['examples','demo', 'demotext']), $
                     wBase, $
                     wStatusBase)

WIDGET_CONTROL, wBase, /CLEAR_EVENTS
WIDGET_CONTROL, wBase, SENSITIVE=0
WIDGET_CONTROL, wStartMes, /SHOW
;
;Grab a refernce to the drawable.
;
WIDGET_CONTROL, wDraw, GET_VALUE=rWindow
;
;Compute viewplane rectangle to nicely fit our volumes.
;
zoom = sqrt(2) ; Nicety. (Length of unit-cube face diagonal.)
myview = [-.5, -.5, 1, 1] * zoom
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
rView->SetProperty,         $
    VIEWPLANE_RECT=myview,  $
    PROJECTION=1,           $
    EYE=2.0,                $
    ZCLIP=[1.0,-1.0],       $
    COLOR=[0,0,0]
;
;Create a transparent view that is just like our established view.
;(Used for screen refreshes.)
;
rTransparentView = OBJ_NEW('IDLgrView', $
    VIEWPLANE_RECT=myview,  $
    PROJECTION=1,           $
    EYE=2.0,                $
    ZCLIP=[1.0,-1.0],       $
    COLOR=[0,0,0],          $
    /TRANSPARENT            $
    )
;
if not keyword_set(record_to_filename) then $
    record_to_filename = ''
;
;Save the state of our application.
;
pState = PTR_NEW({      $
    center: [xdim, ydim] / 2., $ ; Center of drawing area.
    radius: ydim / 2,   $ ; Sphere radius (1/2 of draw area height)
    axis: 3b,           $ ; constrict Trackball rotations. 0=x,1=y,2=z,3=no.
    btndown: 0b,        $ ; which mouse button is pressed.
    pt0: FLTARR(3),     $ ; Position point 0
    pt1: FLTARR(3),     $ ; Position point 1
    sc: FLTARR(3),      $ ; Scaling factor for x, y, z directions
    wDraw: wDraw,       $ ; Widget draw ID
    wHotKeyReceptor: wHotKeyReceptor, $
    wLMBMode: wLMBMode, $
    wRenderButton: wRenderButton, $
    wAutoRenderButton: wAutoRenderButton, $
    wLightButton: wLightButton, $
    wWireBoxButton: wWireBoxButton, $
    wAxesButton: wAxesButton, $
    wCursorButton: wCursorButton, $
    rModelArray: rModelArray, $ ; Model array
    cur: 0,             $ ; Current object shown (0=brain, 1=cloud)
    rVolumeArray: rVolumeArray, $ ; Volume object references
    rOtherObjectArray: rOtherObjectArray, $ ; Other object references
    rScaleToys: rScaleToys, $
    rScaleVolumes: rScaleVolumes, $
    rPartialBox: rPartialBox, $
    rRedSpoke: rRedSpoke, $
    rGreenSpoke: rGreenSpoke, $
    rBlueSpoke: rBlueSpoke, $
    rView: rView,       $ ; View object reference
    font24: font24,     $
    rWindow: rWindow,   $ ; Window object reference
    rTransparentView: rTransparentView, $
    rToysModel: rModelArray[0], $ ; Trinkets.
    sText: sText,       $ ; Text structure for tips
    jpos: jack,         $ ; Axes position
    ColorTable: colorTable, $ ; Color table to restore
    rText: rText,       $ ; Text object refence
    rFont: rFont,       $ ; Font object refence
    wBase: wBase,       $ ; top level base
    wBrainTablesBase: wBrainTablesBase, $
    wIronTablesBase: wIronTablesBase, $
    wCuttingSlider: wCuttingSlider, $
    pet_color_files: pet_color_files, $
    mri_color_files: mri_color_files, $
    pet_opacity_files: pet_opacity_files, $
    mri_opacity_files: mri_opacity_files, $
    iron_color_files: iron_color_files, $
    iron_opacity_files: iron_opacity_files, $
    lmb_scale: 0,        $ ; Left mouse button scaling mode: 0=not on, 1=on
    suppress_draws: 1b, $ ; 1=yes, 0=no
    auto_render:0,      $ ; 1=yes, 0=no
    screen_rotate:1b,   $ ; 1=rotations are with respect to screen axes.
    an_instance_exists: 0b, $
    render_quality: 1,  $ ; 1 ('medium') or 2 ('high')
    pet_is_solid: 0b,   $ ; boolean
    pet_is_white: 0b,   $ ; boolean
    cursor_stale: 0B, $   ; 3D cursor up to date in graphic?
    record_to_filename: record_to_filename, $
    wVolBGroup: wVolBGroup, $
    wQuality: wQuality, $
    debug: keyword_set(debug), $
    groupBase: groupBase $; Base of Group Leader
    })

WIDGET_CONTROL, wBase, SET_UVALUE=pState
;
rModelArray[3]->Remove, rText
;
;Set MRI color and opacity.
;
d_volrendrSetTable, rVolumeArray[0], 0, mri_color_files[0]
d_volrendrSetTable, rVolumeArray[0], 1, mri_opacity_files[0]
;
;Manually send a sequence of clicks to initialize the application.
;
vol_select_event = {        $
    id: wVolBGroup,         $
    top: wBase,             $
    handler: 0L,            $
    select: 1,              $
    value: 0                $
    }
d_volrendrEvent, vol_select_event

WIDGET_CONTROL, wQuality, SET_VALUE=0
event = {           $
    id: wQuality,   $
    top: wBase,     $
    handler: 0L,    $
    select: 1,      $
    value: 0        $
    }
d_volrendrEvent, event

WIDGET_CONTROL, wPetColor, SET_DROPLIST_SELECT=1
event = {WIDGET_DROPLIST, $
    id: wPetColor,      $
    top: wBase,         $
    handler: 0L,        $
    index: 1L           $
    }
d_volrendrEvent, event

WIDGET_CONTROL, wPetOpacity, SET_DROPLIST_SELECT=0
event.index = 0L
event.id = wPetOpacity
d_volrendrEvent, event

vol_select_event.value = 1
d_volrendrEvent, vol_select_event

WIDGET_CONTROL, wIronColor, SET_DROPLIST_SELECT=1
event.id = wIronColor
event.index = 1
d_volrendrEvent, event

WIDGET_CONTROL, wIronOpacity, SET_DROPLIST_SELECT=([0,2])[initial_volume]
event.id = wIronOpacity
event.index = ([0, 2])[initial_volume]
d_volrendrEvent, event

WIDGET_CONTROL, wCuttingSlider, SET_VALUE=20
event = {WIDGET_SLIDER, $
    id: wCuttingSlider, $
    top: wBase,         $
    handler: 0L,        $
    value: 20L,         $
    drag:0              $
    }
d_volrendrEvent, event

d_volrendrEvent, { $
    id: wAxesButton, $
    top: wBase, $
    handler: 0L $
    }

(*pState).suppress_draws = 0

WIDGET_CONTROL, wVolBGroup, SET_VALUE=initial_volume
vol_select_event.value = initial_volume
d_volrendrEvent, vol_select_event

void = demo_startmes('Rendering volume data...', UPDATE=wStartMes)

event.id = wRenderButton
d_volrendrEvent, event
;
;Now we are ready to handle user events.
;
WIDGET_CONTROL, wStartMes, /DESTROY
if XREGISTERED('demo_tour') eq 0 then $
    WIDGET_CONTROL, wHotKeyReceptor, /INPUT_FOCUS
XMANAGER, 'd_volrendr', wBase,       $
    Event_Handler='d_volrendrEvent', $
    CLEANUP='d_volrendrCleanup',     $
    /NO_BLOCK

WIDGET_CONTROL, wBase, SENSITIVE=1
end   ;  of d_volrendr.pro
