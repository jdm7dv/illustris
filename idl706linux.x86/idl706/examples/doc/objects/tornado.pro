; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/tornado.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       TORNADO
;
; PURPOSE:
;       Provide an entertaining, animated graphic that looks like
;       a tornado.
;
; CALLING SEQUENCE:
;       TORNADO
;
; KEYWORD PARAMETERS:
;       COW:    If set, include a brown cow in the tornado scene.
;
;-
;
pro tornado_cleanup, wid
compile_opt hidden

widget_control, wid, get_uvalue=pState
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
ptr_free, pState
end
;--------------------------------------------------------------------
pro tornado_event, event
compile_opt hidden

widget_control, event.top, get_uvalue=pState

if (*pState).oRotator->Update(event) then begin
    (*pState).oWindow->Draw, (*pState).oView
    end

if tag_names(event, /structure_name) EQ 'WIDGET_TIMER' then begin
    if (*pState).mb1_is_down then begin
        if (*pState).we_are_animating then $
            widget_control, event.id, timer=.1
        return
        end
    seed = (*pState).seed
    (*pState).count = (*pState).count + 1.0

;   (*pState).vel_clouds_z = (*pState).vel_clouds_z + ((*pState).float_vel / 20.0)

    z_pos_ramp = 1.0 - (*pState).pos_tornado_z

    (*pState).vel_tornado_x = (*pState).vel_tornado_x + $
       ((*pState).ramp * z_pos_ramp^2 * (randomu(seed, (*pState).n_tornado_pts) - 0.5) / 4.0)

    (*pState).vel_tornado_y = (*pState).vel_tornado_y + $
       ((*pState).ramp * z_pos_ramp^2 * (randomu(seed, (*pState).n_tornado_pts) - 0.5) / 4.0)

    (*pState).vel_tornado_z = (*pState).vel_tornado_z - $
       ((*pState).ramp * (*pState).float_vel * (randomu(seed, (*pState).n_tornado_pts) - 0.5))

    IF ((*pState).pos_tornado_z[0] GE 0.25) THEN $
       (*pState).vel_tornado_z(0) = (*pState).vel_tornado_z(0) < (*pState).vel_tornado_z(1) < (0.0)

    (*pState).vel_tornado_x((*pState).max_torn_pt) = 0.0
    (*pState).vel_tornado_y((*pState).max_torn_pt) = 0.0
    (*pState).vel_tornado_z((*pState).max_torn_pt) = 0.0

    (*pState).vel_tornado_x = Smooth((*pState).vel_tornado_x,  3, /Edge_Truncate)
    (*pState).vel_tornado_y = Smooth((*pState).vel_tornado_y,  3, /Edge_Truncate)
    (*pState).vel_tornado_z = Smooth((*pState).vel_tornado_z,  3, /Edge_Truncate)

    (*pState).pos_tornado_x = (*pState).pos_tornado_x + ((*pState).vel_tornado_x * (*pState).time_inc)
    (*pState).pos_tornado_y = (*pState).pos_tornado_y + ((*pState).vel_tornado_y * (*pState).time_inc)
    (*pState).pos_tornado_z = (*pState).pos_tornado_z + ((*pState).vel_tornado_z * (*pState).time_inc)

;   IF ((*pState).pos_tornado_z(0) GT 0.0) THEN BEGIN
;       index = Where(((*pState).pos_tornado_z(1:*)-(*pState).pos_tornado_z(0:(*pState).max_torn_pt_m1)) LE 0.0)
;           IF (index(0) GT 0L) THEN $
;               (*pState).pos_tornado_z(index) = (*pState).pos_tornado_z(index) - (0.005)
;       ENDIF

    (*pState).pos_tornado_x[0] = (*pState).pos_tornado_x[1]
    (*pState).pos_tornado_x[(*pState).max_torn_pt] = ((*pState).pos_tornado_x)[(*pState).max_torn_pt_m1]
    (*pState).pos_tornado_x = Smooth((*pState).pos_tornado_x,  3, /Edge_Truncate)

    (*pState).pos_tornado_y[0] = ((*pState).pos_tornado_y)[1]
    (*pState).pos_tornado_y[(*pState).max_torn_pt] = (*pState).pos_tornado_y[(*pState).max_torn_pt_m1]
    (*pState).pos_tornado_y = Smooth((*pState).pos_tornado_y,  3, /Edge_Truncate)

    (*pState).pos_tornado_z[0] = (*pState).pos_tornado_z[0] < ((*pState).pos_tornado_z[1] - 0.01)
    (*pState).pos_tornado_z[(*pState).max_torn_pt] = 1.0
    (*pState).pos_tornado_z = Smooth((*pState).pos_tornado_z,  3)

    index = Where(((*pState).pos_tornado_x LE 0.0) OR ((*pState).pos_tornado_x GE 1.0))
    IF (index(0) GE 0L) THEN (*pState).vel_tornado_x(index) = 0.0
    index = Where(((*pState).pos_tornado_y LE 0.0) OR ((*pState).pos_tornado_y GE 1.0))
    IF (index(0) GE 0L) THEN (*pState).vel_tornado_y(index) = 0.0
    index = Where(((*pState).pos_tornado_z LE 0.0) OR ((*pState).pos_tornado_z GE 1.0))
    IF (index(0) GE 0L) THEN (*pState).vel_tornado_z(index) = 0.0
    (*pState).pos_tornado_x = ((*pState).pos_tornado_x > 0.0) < 1.0
    (*pState).pos_tornado_y = ((*pState).pos_tornado_y > 0.0) < 1.0
    (*pState).pos_tornado_z = ((*pState).pos_tornado_z > 0.0) < 1.0

   ;speed_tornado =  ((1.5 + (*pState).ramp) * (*pState).time_inc * 20.0 * (Sqrt((*pState).spin_tornado) + 0.001))
   ;speed_tornado =  ((0.5 + (*pState).ramp) * (*pState).time_inc * 50.0 * (Sqrt((*pState).spin_tornado) + 0.001))
    speed_tornado =  ((.25 + (*pState).ramp) * (*pState).time_inc * 20.0 * (Sqrt((*pState).spin_tornado) + 0.001))

    (*pState).spin_change = (*pState).spin_change + $
       Smooth(((randomu(seed, (*pState).n_tornado_pts) - 0.5) / 10.0), 3, /Edge_Truncate)
      ;Smooth(((randomu(seed, (*pState).n_tornado_pts) - 0.5) / 10.0), 3, /Edge_Truncate)
    (*pState).spin_change = Smooth((*pState).spin_change, 3, /Edge_Truncate)

    bracket = .125
    (*pState).spin_change = ((*pState).spin_change > (-bracket)) < bracket
    (*pState).spin_tornado = (((*pState).spin_tornado + ((*pState).spin_change * (*pState).time_inc)) > 0.05) < 0.15
    (*pState).spin_tornado[(*pState).max_torn_pt] = $
        (*pState).spin_tornado((*pState).max_torn_pt_m1) + ((0.001 * (*pState).count) < 0.15)
    (*pState).spin_tornado = Smooth((*pState).spin_tornado,  3, /Edge_Truncate)
    (*pState).spin_tornado = Smooth((*pState).spin_tornado, ((*pState).n_tornado_pts/4), /Edge_Truncate)
;   (*pState).spin_tornado[0] = (*pState).spin_tornado[1] * (1.0 - (*pState).pos_tornado_z[0])^4

    (*pState).twist_ang = (*pState).twist_ang + (10.0 * (*pState).time_inc * speed_tornado)
    index = Where((*pState).twist_ang GE 360.0)
    IF (index(0) GE 0L) THEN (*pState).twist_ang(index) = (*pState).twist_ang(index) - 360.0

    ground_dx = (*pState).pos_ground_x - (*pState).pos_tornado_x[0]
    ground_dy = (*pState).pos_ground_y - (*pState).pos_tornado_y[0]
    ground_dz = (*pState).pos_ground_z - (*pState).pos_tornado_z[0]
    ground_dist = Sqrt(ground_dx^2 + ground_dy^2)
    index = Where(ground_dist GT 0.0)
    (*pState).ground_ang = 0.0
    (*pState).ground_ang(index) = Atan(ground_dy(index), ground_dx(index))

    ground_xyz_dist = Sqrt(ground_dx^2 + ground_dy^2 + ground_dz^2)

    vect_x = (*pState).pos_tornado_x[2] - (*pState).pos_tornado_x[0]
    vect_y = (*pState).pos_tornado_y[2] - (*pState).pos_tornado_y[0]
    pt_dz = Sqrt(vect_x^2 + vect_y^2)
    IF (pt_dz GT 0.0) THEN pt_ang = Atan(vect_y, vect_x) ELSE pt_ang = 0.0
    ang_diff = pt_ang - (*pState).ground_ang
    tilt_fac = (pt_dz * (-Cos(ang_diff))) + (randomu(seed, (*pState).n_ground_pts) / 2.0)

    (*pState).vel_ground_z = (*pState).vel_ground_z - ((*pState).grav_time)

    (*pState).pos_ground_x = (((*pState).pos_ground_x + ((*pState).vel_ground_x * (*pState).time_inc)) > (-1.0)) < 2.0
    (*pState).pos_ground_y = (((*pState).pos_ground_y + ((*pState).vel_ground_y * (*pState).time_inc)) > (-1.0)) < 2.0
    (*pState).pos_ground_z = ((*pState).pos_ground_z + ((*pState).vel_ground_z * (*pState).time_inc)) > 0.0
    index = Where((*pState).pos_ground_z LE 0.0)
    IF (index(0) GE 0L) THEN BEGIN
        (*pState).vel_ground_x(index) = 0.0
        (*pState).vel_ground_y(index) = 0.0
        (*pState).vel_ground_z(index) = (*pState).time_inc * (*pState).spin_tornado(1) * 20.0 * tilt_fac(index) / $
        (ground_xyz_dist(index) + 0.25)^6
        ENDIF

    index = Where((*pState).pos_ground_z GT 0.0)
    IF (index(0) GE 0L) THEN BEGIN
        (*pState).vel_ground_x(index) = (*pState).vel_ground_x(index) - $
          (Sin((*pState).ground_ang(index)) * 4.0 * (*pState).spin_tornado(1) / $
          (1.5*(ground_xyz_dist(index) + 0.5))^6)
        (*pState).vel_ground_y(index) = (*pState).vel_ground_y(index) + $
          (Cos((*pState).ground_ang(index)) * 4.0 * (*pState).spin_tornado(1) / $
          (1.5*(ground_xyz_dist(index) + 0.5))^6)
        ENDIF

    (*pState).vel_ground_x = (*pState).vel_ground_x * 0.85
    (*pState).vel_ground_y = (*pState).vel_ground_y * 0.85
    (*pState).vel_ground_z = (*pState).vel_ground_z * 0.95

    data = (*pState).generic_ground_facet_pts
    for i=0,3 do begin
        data[0, i, *] = (*pState).pos_ground_x[0:(*pState).n_ground_pts-2] + data[0, i, *]
        data[1, i, *] = (*pState).pos_ground_y[0:(*pState).n_ground_pts-2] + data[1, i, *]
        data[2, i, *] = (*pState).pos_ground_z[0:(*pState).n_ground_pts-2] + data[2, i, *]
        end
    (*pState).oGroundPolygon->SetProperty, data=reform(data, 3, ((*pState).n_ground_pts-1) * 4)

    new_cowx = (*pState).cowx + (*pState).pos_ground_x[(*pState).n_ground_pts-1]
    new_cowy = (*pState).cowy + (*pState).pos_ground_y[(*pState).n_ground_pts-1]
    new_cowz = (*pState).cowz + (*pState).pos_ground_z[(*pState).n_ground_pts-1]
    (*pState).oCowPolygon->SetProperty, data=transpose([[new_cowx], [new_cowy], [new_cowz]])

;   clouds_dx = (*pState).pos_clouds_x - (*pState).pos_tornado_x[(*pState).max_torn_pt]
;   clouds_dy = (*pState).pos_clouds_y - (*pState).pos_tornado_y[(*pState).max_torn_pt]
;   clouds_dist = Sqrt(clouds_dx^2 + clouds_dy^2)
;   index = Where(clouds_dist GT 0.0)
;   (*pState).clouds_ang = 0.0
;   (*pState).clouds_ang(index) = Atan(clouds_dy(index), clouds_dx(index))
;   (*pState).vel_clouds_x = (*pState).vel_clouds_x - $
;       (Sin((*pState).clouds_ang) * 2.0 * (*pState).spin_tornado((*pState).max_torn_pt) / (1.5*(clouds_dist + 0.5))^4)
;   (*pState).vel_clouds_y = (*pState).vel_clouds_y + $
;       (Cos((*pState).clouds_ang) * 2.0 * (*pState).spin_tornado((*pState).max_torn_pt) / (1.5*(clouds_dist + 0.5))^4)
;   (*pState).vel_clouds_x = (*pState).vel_clouds_x + (0.075 * (randomu(seed, (*pState).n_cloud_pts) - 0.5))
;   (*pState).vel_clouds_y = (*pState).vel_clouds_y + (0.075 * (randomu(seed, (*pState).n_cloud_pts) - 0.5))
;   (*pState).vel_clouds_x = (*pState).vel_clouds_x * 0.75
;   (*pState).vel_clouds_y = (*pState).vel_clouds_y * 0.75

;   (*pState).vel_clouds_x = (*pState).vel_clouds_x - $
;       (0.03 * Cos((*pState).clouds_ang) / (1.0 + (10.0 * clouds_dist)))
;   (*pState).vel_clouds_y = (*pState).vel_clouds_y - $
;       (0.03 * Sin((*pState).clouds_ang) / (1.0 + (10.0 * clouds_dist)))

    vect_x = (*pState).pos_tornado_x((*pState).max_torn_pt) - (*pState).pos_tornado_x((*pState).max_torn_pt_m2)
    vect_y = (*pState).pos_tornado_y((*pState).max_torn_pt) - (*pState).pos_tornado_y((*pState).max_torn_pt_m2)
    pt_dz = Sqrt(vect_x^2 + vect_y^2)
    IF (pt_dz GT 0.0) THEN pt_ang = Atan(vect_y, vect_x) ELSE pt_ang = 0.0
    ang_diff = pt_ang - (*pState).clouds_ang
    tilt_fac = pt_dz * (-Cos(ang_diff)) * 5.0

;   clouds_dz = (*pState).pos_clouds_z - (*pState).pos_tornado_z((*pState).max_torn_pt)
;   clouds_dist = (clouds_dx^2 + clouds_dy^2 + clouds_dz^2)

;   (*pState).vel_clouds_z = (*pState).vel_clouds_z - $
;       ((*pState).spin_tornado((*pState).max_torn_pt) * tilt_fac / (clouds_dist > 0.01))
;
;   (*pState).vel_clouds_z = (*pState).vel_clouds_z + $
;       ((randomu(seed, (*pState).n_cloud_pts) - 0.5) * (*pState).float_vel / 40.0)

;   (*pState).vel_clouds_z = ((*pState).vel_clouds_z > (-(*pState).float_vel)) < (*pState).float_vel

;   (*pState).pos_clouds_x = (*pState).pos_clouds_x + ((*pState).vel_clouds_x * (*pState).time_inc)
;   (*pState).pos_clouds_y = (*pState).pos_clouds_y + ((*pState).vel_clouds_y * (*pState).time_inc)
;   (*pState).pos_clouds_z = (((*pState).pos_clouds_z + ((*pState).vel_clouds_z * (*pState).time_inc)) > 0.0) < 1.0

;   index = Where(Sqrt(((*pState).pos_clouds_x - 0.5)^2 + ((*pState).pos_clouds_y - 0.5)^2) GT 1.0)
;   IF (index(0) GE 0L) THEN BEGIN
;       (*pState).vel_clouds_x(index) = 0.0
;       (*pState).vel_clouds_y(index) = 0.0
;       ENDIF

    FOR i=0, (*pState).max_torn_pt DO BEGIN
        prev_pt = (i - 1) > 0
        next_pt = (i + 1) < (*pState).max_torn_pt

        vect_x = (*pState).pos_tornado_x(next_pt) - (*pState).pos_tornado_x(prev_pt)
        vect_y = (*pState).pos_tornado_y(next_pt) - (*pState).pos_tornado_y(prev_pt)
        vect_z = ((*pState).pos_tornado_z(next_pt) - (*pState).pos_tornado_z(prev_pt)) > 0.001 > $
                                         (0.01 * Float(i) / Float((*pState).max_torn_pt))
        xy_len = Sqrt(vect_x^2 + vect_y^2)

        IF (xy_len GT 0.0) THEN BEGIN
            ang_z = Atan(vect_y, vect_x)
            ang_y = (!PI / 2.0) - (Atan(vect_z, xy_len))
            ENDIF $
        ELSE BEGIN
            ang_z = 0.0
            ang_y = 0.0
            ENDELSE

        trans = (*pState).ident4
        m4x4 = (*pState).ident4
        s_ang = Sin((*pState).twist_ang(i)-ang_z)
        c_ang = Cos((*pState).twist_ang(i)-ang_z)
        m4x4(0,0) = c_ang
        m4x4(0,1) = s_ang
        m4x4(1,0) = (-s_ang)
        m4x4(1,1) = c_ang
        trans = Temporary(trans) # m4x4

        m4x4 = (*pState).ident4
        s_ang = Sin(ang_y)
        c_ang = Cos(ang_y)
        m4x4(0,0) = c_ang
        m4x4(0,2) = (-s_ang)
        m4x4(2,0) = s_ang
        m4x4(2,2) = c_ang
        trans = Temporary(trans) # m4x4

        m4x4 = (*pState).ident4
        s_ang = Sin(ang_z)
        c_ang = Cos(ang_z)
        m4x4(0,0) = c_ang
        m4x4(0,1) = s_ang
        m4x4(1,0) = (-s_ang)
        m4x4(1,1) = c_ang
        trans = Temporary(trans) # m4x4

        m4x4 = (*pState).ident4
        m4x4[[3,7,11]] = [(*pState).pos_tornado_x(i), (*pState).pos_tornado_y(i), (*pState).pos_tornado_z(i)]
        ring_trans = Temporary(trans) # m4x4

        radius = (((*pState).spin_tornado(i)) * 1.25) > .05

        degree_turn = 0.0
        for j=0,(*pState).n_arc_pts-1 do begin
            m4x4 = (*pState).ident4
            m4x4[[3,7]] = [cos(degree_turn * !dtor), sin(degree_turn * !dtor)] * radius
            trans = m4x4 # ring_trans

            r = !dtor * degree_turn
            m4x4_turn = (*pState).ident4
            m4x4_turn[[0,5]] =cos(r)
            m4x4_turn[1] = -sin(r)
            m4x4_turn[4] = sin(r)

            trans = m4x4_turn # temporary(trans)

            data = Vert_T3d((*pState).generic_facet_pts, Matrix=trans)
            data[2, *] = 0 > data[2, *] < 1.5
            (*pState).oFacet[i, j]->SetProperty, data=data

            degree_turn = degree_turn + (*pState).ang_inc
            endfor
        endfor
    (*pState).oWindow->Draw, (*pState).oView
    if (*pState).we_are_animating then $
        widget_control, event.id, timer=0
    (*pState).seed = seed
    return
    end

case event.id of
    (*pState).wDraw: begin
        if event.type eq 4 then begin ; Expose event.
            (*pState).oWindow->Draw, (*pState).oView
            end
        if event.press eq 1 then begin ; Left mb event?
            if event.type eq 0 then begin
                (*pState).mb1_is_down = 1b
                widget_control, (*pState).wDraw, draw_motion_events=1
                end
            end
        if event.release eq 1 then begin
            if event.type eq 1 then begin
                (*pState).mb1_is_down = 0b
                widget_control, (*pState).wDraw, draw_motion_events=0
                end
            end
        end
    (*pState).wPause: begin
        widget_control, (*pState).wPause, sensitive=0
        widget_control, (*pState).wContinue, sensitive=1
        (*pState).we_are_animating = 0b
        end
    (*pState).wStart: begin
        widget_control, (*pState).wPause, sensitive=1
        widget_control, (*pState).wStart, sensitive=0
        (*pState).we_are_animating = 1b
        widget_control, (*pState).wControlBase, timer=.1
        end
    (*pState).wContinue: begin
        widget_control, (*pState).wPause, sensitive=1
        widget_control, (*pState).wContinue, sensitive=0
        (*pState).we_are_animating = 1b
        widget_control, (*pState).wControlBase, timer=.1
        end
    else:
    endcase
end
;--------------------------------------------------------------------
pro tornado, $
    cow=cow ; IN: (opt)  If set, include a brown cow in the scene.
;
;This program simulates a tornado.
;
!except = 0
winx = 640.0
winy = 640.0

n_cloud_pts = 200
n_ground_pts = 200
n_tornado_pts = 10 ; 25
n_arc_pts = 5

clouds_center_x = 0.5
clouds_center_y = 0.5

max_torn_pt = n_tornado_pts - 1
max_torn_pt_m1 = max_torn_pt - 1
max_torn_pt_m2 = max_torn_pt - 2

arc_ones = Replicate(1.0, n_arc_pts)
zeroes = Fltarr(n_tornado_pts)
ramp = 1.0 - (Findgen(n_tornado_pts) / Float(n_tornado_pts - 1))
clouds_ang = Fltarr(n_cloud_pts)
ground_ang = Fltarr(n_ground_pts)
;
;A predetermined seed can be used for to make this program
;follow the same psudo-random progression every time.
;
;seed = 8L
;
pos_clouds_x = (randomu(seed, n_cloud_pts) * 2.0) - 0.5
pos_clouds_y = (randomu(seed, n_cloud_pts) * 2.0) - 0.5
pos_clouds_z = Replicate(1.0, n_cloud_pts)

vel_clouds_x = randomu(seed, n_cloud_pts) /  100.0
vel_clouds_y = randomu(seed, n_cloud_pts) /  100.0
vel_clouds_z = randomu(seed, n_cloud_pts) / 1000.0

pos_ground_x = (randomu(seed, n_ground_pts) * 2.0) - 0.5
pos_ground_y = (randomu(seed, n_ground_pts) * 2.0) - 0.5
pos_ground_z = Fltarr(n_ground_pts)

vel_ground_x = Fltarr(n_ground_pts)
vel_ground_y = Fltarr(n_ground_pts)
vel_ground_z = Fltarr(n_ground_pts)

pos_tornado_x = Replicate(clouds_center_x, n_tornado_pts)
pos_tornado_y = Replicate(clouds_center_y, n_tornado_pts)
pos_tornado_z = Replicate(1.0, n_tornado_pts)

vel_tornado_x = Fltarr(n_tornado_pts)
vel_tornado_y = Fltarr(n_tornado_pts)
vel_tornado_z = Replicate((-0.01), n_tornado_pts) * ramp
;
;Hack cow to start near the middle of field.
;
pos_ground_x[n_ground_pts - 1] = 0.5
pos_ground_y[n_ground_pts - 1] = 0.5

twist_ang = randomu(seed, n_tornado_pts) * 180.0
ang_inc = 360.0 / Float(n_arc_pts)

spin_pts = Fltarr(3, n_arc_pts, n_tornado_pts)

spin_tornado = Fltarr(n_tornado_pts)
speed_tornado = Fltarr(n_tornado_pts)

back_color = [015, 015, 031]
ground_color = [191, 063, 031]
cloud_color = [063, 063, 255]
torn_color = [255, 255, 255]
spot_color = [255, 000, 000]

tlb = widget_base(title='TORNADO !', /row)
wControlBase = widget_base(tlb, /col, /frame)

wStart = widget_button(wControlBase, value='Start')
wPause = widget_button(wControlBase, value='Pause', sensitive=0)
wContinue = widget_button(wControlBase, value='Continue', sensitive=0)

wDraw = widget_draw(tlb, $
    xsize=winx, $
    ysize=winy, $
    /button_events, $
    /motion_events, $
    retain=0, $
    /expose_ev, $
    graphics_lev=2 $
    )
widget_control, tlb, /realize
widget_control, wDraw, get_value=oWindow

oView = obj_new('IDLgrView', $
    viewplane_rec=[-1, -1, 2, 2], $
    projection=2, $
    zclip=[3, -3], $
    color=[0, 0, 0] $
    )

oRotator = obj_new('IDLexRotator', [winx, winy] / 2, winx)
oView->Add, oRotator

oModel = obj_new('IDLgrModel')
oModel->Translate, -.5, -.5, -.5
oRotator->Add, oModel
oRotator->Rotate, [0, 0, 1], 30
oRotator->Rotate, [1, 0, 0], -60

oFacet = objarr(n_tornado_pts, n_arc_pts)
oGroundPolygon = obj_new('IDLgrPolygon')

texture_size = 30
row_ramp = bytscl(indgen(texture_size))
image_data = bytarr(4, texture_size, texture_size +1) + 255b
image_data[3, *, *] = [ $ ; An image of an arrow.
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $

    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0], $

    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], $

    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $

    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], $

    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], $
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $

    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] $
    ] * 255b
oTexture = obj_new('IDLgrImage', image_data)
for i=0,n_elements(oFacet)-1 do begin
    oFacet[i] = obj_new( $
      'IDLgrPolygon', $
      texture_map=oTexture, $
      texture_coord=[[0,0], [1,0], [1,1], [0,1]], $
      bottom=[127, 127, 127], $
      color=[255, 255, 255] $
      )
    oModel->Add, oFacet[i]
    end

generic = [ $
    0, 0, 0, $
    1, 0, 0, $
    1, 1, 0, $
    0, 1, 0 $
    ]
generic =  generic - .5
generic[[2, 5, 8, 11]] = 0
generic = generic * .05
generic_ground_facet_pts = generic
for i=1,n_ground_pts-2 do begin
    generic_ground_facet_pts = [generic_ground_facet_pts, generic]
    end
generic_ground_facet_pts = reform(generic_ground_facet_pts, 3, 4, n_ground_pts-1)
connections = shift(lindgen(5), 1)
for i=1,n_ground_pts-2 do begin
    connections = [connections, 4, lindgen(4) + i*4]
    end
oGroundPolygon->SetProperty, $
      bottom=[0, 127, 0], $
      color=[0, 255, 0], $
      data=reform(generic_ground_facet_pts, 3, (n_ground_pts-1) * 4), $
      polygon=connections
oModel->Add, oGroundPolygon

restore, filepath('cow10.sav', subdir=['examples','data'])
cow_connections = polylist
cowx = x * .3
cowy = z * .3
cowz = y * .3
cowz = cowz - (min(cowz[cow_connections]) < 0)
oCowPolygon = obj_new('IDLgrPolygon', $
    color=[155, 105, 80], $
    cowx, $
    cowy, $
    cowz, $
    polygon=cow_connections $
    )

if keyword_set(cow) then begin
    oModel->Add, oCowPolygon
    end

generic_facet_pts = ([ $
    [0, 0, 0], $
    [0, 1, 0], $
    [0, 1, 1], $
    [0, 0, 1] $
    ] - .5) * .075

time_inc = 0.025
time_inc = .07
time_inc = .065

grav = 1.0
grav = .75
grav_time = grav * time_inc
pi2 = !PI * 2.0

widget_control, tlb, set_uvalue=ptr_new({ $
    we_are_animating: 0b, $
    mb1_is_down: 0b, $
    generic_facet_pts: generic_facet_pts, $
    generic_ground_facet_pts: generic_ground_facet_pts, $
    ident4: identity(4), $
    clouds_ang: clouds_ang, $
    grav_time: grav_time, $
    n_cloud_pts: n_cloud_pts, $
    n_tornado_pts: n_tornado_pts, $
    n_ground_pts: n_ground_pts, $
    n_arc_pts: n_arc_pts, $
    n_cow_pts: n_elements(cowx), $
    ground_ang: ground_ang, $
    seed: seed, $
    twist_ang: twist_ang, $
    spin_change: replicate(0.1, n_tornado_pts), $
    spin_tornado: spin_tornado, $
    max_torn_pt: max_torn_pt, $
    max_torn_pt_m1: max_torn_pt_m1, $
    max_torn_pt_m2: max_torn_pt_m2, $
    ramp: ramp, $
    float_vel: 0.1, $
    count: 0.0d, $
    pos_clouds_x: pos_clouds_x, $
    pos_clouds_y: pos_clouds_y, $
    pos_clouds_z: pos_clouds_z, $
    vel_clouds_x: vel_clouds_x, $
    vel_clouds_y: vel_clouds_y, $
    vel_clouds_z: vel_clouds_z, $

    pos_ground_x: pos_ground_x, $
    pos_ground_y: pos_ground_y, $
    pos_ground_z: pos_ground_z, $
    vel_ground_x: vel_ground_x, $
    vel_ground_y: vel_ground_y, $
    vel_ground_z: vel_clouds_z, $

    pos_tornado_x: pos_tornado_x, $
    pos_tornado_y: pos_tornado_y, $
    pos_tornado_z: pos_tornado_z, $
    vel_tornado_x: vel_tornado_x, $
    vel_tornado_y: vel_tornado_y, $
    vel_tornado_z: vel_tornado_z, $

    oRotator: oRotator, $
    oFacet: oFacet, $
    oGroundPolygon: oGroundPolygon, $
    oCowPolygon: oCowPolygon, $
    oTexture: oTexture, $
    oWindow: oWindow, $
    oView: oView, $

    ang_inc: ang_inc, $
    time_inc: time_inc, $

    cowx: cowx, $
    cowy: cowy, $
    cowz: cowz, $
    cow_connections: cow_connections, $

    wControlBase: wControlBase, $
    wPause: wPause, $
    wStart: wStart, $
    wContinue: wContinue, $
    wDraw: wDraw $
    })

xmanager, 'tornado', tlb, /no_bloc, cleanup='tornado_cleanup'
tornado_event, {WIDGET_TIMER, id: wControlBase, top: tlb, handler:0L}
void = dialog_message( $
    ['You can click and drag in the Tornado ', $
     'graphic at any time to rotate your view.'], $
    /inform, $
    dialog_parent=tlb $
    )
widget_control, wStart, /input_focus
end
