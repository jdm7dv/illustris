; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_contour.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_contour.pro
;
;  CALLING SEQUENCE: d_contour
;
;  PURPOSE:
;       Shows several feature of contour plots and contour objects.
;
;  MAJOR TOPICS: Plots, widgets and objects
;
;  CATEGORY:
;       IDL Demo System
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  Variable name conventions used herein: r==Reference to Object
;        p==pointer, w==widget ID.
;-
;--------------------------------------------------------------------
;
;   PURPOSE  Format tire contour label strings
;
function d_contourTireLabelFormat, $
    axis, $        ; IN: Axis for which label is being formatted (2=Z)
    indx, $        ; IN: Index of the contour value being labeled
    value, $       ; IN: Value of the contour line being labeled
    DATA=data

    sval = (value / data.maxValue) * data.maxPercent;scale values
    RETURN,(STRING(sval, FORMAT='(I2)'))
end      ;   of  d_contourLabelFormat
;--------------------------------------------------------------------
;
;   PURPOSE  Format terrain contour label strings
;
function d_contourTerrainLabelFormat, $
    axis, $        ; IN: Axis for which label is being formatted (2=Z)
    indx, $        ; IN: Index of the contour value being labeled
    value, $       ; IN: Value of the contour line being labeled
    DATA=data

    sval = (value / data.maxZ) * data.maxElev;scale values
    RETURN,(STRING(sval, FORMAT='(I)'))
end      ;   of  d_contourLabelFormat
;--------------------------------------------------------------------
;
;   PURPOSE  Assign a color to the polyline
;
function d_contourGetColorArray, $
    high_color, $        ; IN: highest color index.
    nLevels              ; IN: number of contour levels.

if (nLevels ge 15) then begin
    ColorArray = [0, 4, 11, 9, 3, 10, 5, 8, 2, 6, 13, 12, 14, 15, 1 ]
endif else if (nLevels ge 11) then begin
    ColorArray = [0, 11,  9, 10, 5, 8, 2, 6, 12,  15, 1 ]
endif else begin
    ColorArray = [0, 11,   5, 8, 2,  15, 1 ]
endelse
RETURN, colorArray + high_color

end      ;   of  d_contourGetColorArray
;
;--------------------------------------------------------------------
;
;   PURPOSE  Assign a color to the polyline
;
function d_contourGetContourColor, $
    level, $      ; IN: level index
    nLevels       ; IN: number of levels

high_color = !D.TABLE_SIZE-18 + 1
colorArray = d_contourGetColorArray( high_color, nLevels)
index = ColorArray[level]
TVLCT, Red, Green, Blue,  /GET

RETURN, [Red[index], Green[index], Blue[index]]

end

;
;--------------------------------------------------------------------
pro d_contourWorld_event, event

WIDGET_CONTROL, event.top, GET_UVALUE=pState

demo_record, event, 'd_contourWorld_event', $
  FILENAME=(*pState).record_to_filename, CW = event.id

if event.id eq (*pState).wWorldStyleRadio1 then begin
    if event.select eq 0 then return ;Ignore release events from exclusive
endif

WIDGET_CONTROL, (*pState).wWorldLevelsSlider, GET_VALUE=levelValue
WIDGET_CONTROL, (*pState).wWorldStyleRadio, GET_VALUE=selection
WIDGET_CONTROL, (*pState).wWorldStyleRadio1, GET_VALUE=proj

;
;Here, level value is 1, 2, or 3. We want to
;have the number of levels to be 7, 11, or 15.
;
(*pState).world_n_levels = levelValue*4 + 3
WIDGET_CONTROL, (*pState).wWorldStyleRadio, GET_VALUE=selection
WSET, (*pState).world_winID
LOADCT, 5, /SILENT
TEK_COLOR, !D.TABLE_SIZE-18, 16
high_color = (*pState).high_color
nlevels = (*pState).world_n_levels
colorArray = d_contourGetColorArray( high_color, nLevels)

WIDGET_CONTROL, (*pState).wWorldLevelsLabel, $
  SET_VALUE=STRING((*pState).world_n_levels, FORMAT='(i2)')
WIDGET_CONTROL, (*pState).wWorldLevelsSlider, SENSITIVE=1
fill = selection[2]
follow = selection[1]

extra = { FOLLOW : follow, $
          C_CHARSIZE: follow ? 1.25 : 0, $
          DOWNHILL : selection[3] , $
          COLOR: high_color+1, $
          BACKGROUND : high_color, $
          TITLE: 'World Elevation', $
          YTITLE: 'Latitude', $
          XTITLE: 'Longitude', $
          LEVELS: fix((1+findgen(nlevels-1)) * (240 / nLevels)), $
          XTICKS:4, YTICKS:4, $
          XTICKNAME:['0', '90', '180', '270', '0'], $
          YTICKNAME:['-90', '-45', '0', '+45', '+90'], $
          FONT: -1, $
          C_LINESTYLE : selection[4] ? [0,1,2,3,4,5] : 0, $
          C_THICK : selection[5] ? [1,2] : [1], $
          XSTYLE:1, $
          YSTYLE:1, $
          TICKLEN: -0.02, $
          OVERPLOT : proj ne 0 }

lon = findgen(91) * 4.
lat = findgen(45) * 4 - 90.
if proj ne 0 then map_set, MOLLWEIDE=proj eq 1, GOODES=proj eq 2, $
  /ISOTROPIC, TITLE='World Elevation'

; We use CELL_FILL for GOODES projection because of slight filling
; errors due to the numerous splits required for this projection.
if fill then CONTOUR, (*pState).world_elev, lon, lat, _EXTRA=extra, $
  FILL = proj ne 2, CELL_FILL = proj eq 2

CONTOUR, (*pState).world_elev, lon, lat, _EXTRA=extra, NOERASE=fill, $
  C_COLORS= selection[0] ? colorArray : high_color+1

if proj ne 0 then begin
    map_continents, color=high_color+1
    map_horizon, color = high_color+3, THICK=2
    map_grid, color=high_color+3
endif
end
;
;--------------------------------------------------------------------
; Purpose: initialize all pointer and reference members of STATE
; that are related to the terrain dataset.
;
pro d_contourTerrain_init, state, n_levels
;
;Compute viewplane rect based on aspect ratio.
;
aspect = FLOAT(state.draw_x_size) / FLOAT(state.draw_y_size)
myview = [ -1.0, -1.0, 2, 2 ]
if (aspect > 1) then begin
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
    end $
else begin
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
    end
;
;Create view.
;
rTerrainView = OBJ_NEW('IDLgrView', PROJECTION=2, EYE=3, $
    ZCLIP=[1.4,-1.4],$
    VIEWPLANE_RECT=myview, COLOR=[40,40,40])
;
;Create model.
;
rTerrainTop = OBJ_NEW('IDLgrModel')
rTerrainGroup = OBJ_NEW('IDLgrModel')
rTerrainTop->Add, rTerrainGroup

z = BYTARR(64,64, /NOZERO)
OPENR, lun, $
    demo_filepath( $
        'elevbin.dat', $
        SUBDIR=['examples','data'] $
        ), $
   /GET_LUN
READU, lun, z
FREE_LUN, lun
z = REVERSE(TEMPORARY(z), 2)

;
;Reduce high frequencies in z data, so as to better expose
;contour lines that will be lying on surface of z data.
;
z = SMOOTH(TEMPORARY(z), 3, /EDGE_TRUNCATE) + 1

;
; Scale x and y to proportional dimensions.
dataDims = SIZE(z,/DIMENSIONS)
xyScale = 14.0
x = FINDGEN(dataDims[0])*xyScale
y = FINDGEN(dataDims[1])*xyScale

;
;Create texture map.
;
READ_JPEG, demo_filepath('elev_t.jpg', $
                         SUBDIR=['examples','data']), $
  idata, TRUE=3
rImage = OBJ_NEW('IDLgrImage', REVERSE(TEMPORARY(idata), 2), INTERLEAVE=2)
;
;Create the surface object.
;
rTerrainSurface = OBJ_NEW('IDLgrSurface', z, x, y, $
                          STYLE=2, $
                          SHADING=1, $
                          COLOR=[255,255,255], $
                          DEPTH_OFFSET=100, $
                          TEXTURE_MAP=rImage)

rTerrainPalette = OBJ_NEW('IDLgrPalette')
rTerrainPalette->LoadCT, 34
rTerrainPalette->GetProperty, RED=r, GREEN=g, BLUE=b
r = r * .75
g = g * .75
b = b * .75
rTerrainPalette->SetProperty, RED=r, GREEN=g, BLUE=b

rLabelFont = OBJ_NEW('IDLgrFont','Helvetica',SIZE=8)

sLabelData = {maxZ: FLOAT(MAX(z)), $
              maxElev: 1400.0};scale to realistic elevations for Pasadena
rTerrainContours = OBJ_NEW('IDLgrContour', z, $
                           COLOR=[255,255,0], $
                           GEOMX=x, $
                           GEOMY=y, $
                           GEOMZ=z, $
                           TICKLEN=7, $
                           C_LABEL_SHOW=0, $
                           LABEL_FONT=rLabelFont, $
                           LABEL_FORMAT='d_contourTerrainLabelFormat', $
                           LABEL_FRMTDATA=sLabelData, $
                           N_LEVELS=n_levels $
                          )
rTerrainNewContour = OBJ_NEW('IDLgrContour', z, $
                             COLOR=[0,255,0], $
                             GEOMX=x, $
                             GEOMY=y, $
                             GEOMZ=z, $
                             C_LABEL_SHOW=0, $
                             LABEL_FONT=rLabelFont, $
                             LABEL_FORMAT='d_contourTerrainLabelFormat', $
                             LABEL_FRMTDATA=sLabelData, $
                             C_VALUE=[-1], $
                             HIDE=1 $ ; we will show it on right click.
                            )
rTerrainCustomContours = OBJ_NEW('IDLgrContour', z, $
                                 COLOR=[255,255,0], $
                                 GEOMX=x, $
                                 GEOMY=y, $
                                 GEOMZ=z, $
                                 C_VALUE=[0], $
                                 C_LABEL_SHOW=0, $
                                 LABEL_FONT=rLabelFont, $
                                 LABEL_FORMAT='d_contourTerrainLabelFormat', $
                                 LABEL_FRMTDATA=sLabelData, $
                                 HIDE=1 $ ; we will show it on right click.
                                )
closed_z = bytarr(64, 64)
closed_z[1:62, 1:62] = z[1:62, 1:62]
rTerrainClosedContours = OBJ_NEW('IDLgrContour', closed_z, $
                                 C_COLOR=congrid(state.ramp, n_levels / 2, $
                                                 /MINUS_ONE), $
                                 GEOMX=x, $
                                 GEOMY=y, $
                                 GEOMZ=z, $
                                 N_LEVELS=n_levels, $
                                 /FILL, $
                                 PALETTE=rTerrainPalette, $
                                 /HIDE $
                                )

rTerrainGroup->Add, rTerrainContours
rTerrainGroup->Add, rTerrainNewContour
rTerrainGroup->Add, rTerrainCustomContours
rTerrainGroup->Add, rTerrainSurface
rTerrainGroup->Add, rTerrainClosedContours
;
;Compute coordinate conversion.
;
rTerrainSurface->GetProperty, XRANGE=xrange, YRANGE=yrange, $
    ZRANGE=zrange
xLen = xrange[1] - xrange[0]
yLen = yrange[1] - yrange[0]
zLen = zrange[1] - zrange[0]
;
;Compute coordinate conversion to normalize.
;
maxLen = (xLen > yLen) > zLen
xs = [(((-xrange[0]*2.0)-xLen)/maxLen), 2.0/maxLen]
ys = [(((-yrange[0]*2.0)-yLen)/maxLen), 2.0/maxLen]
zs = [(((-zrange[0]*2.0)-zLen)/maxLen), 2.0/maxLen]

rTerrainContours->SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, $
    ZCOORD_CONV=zs
rTerrainSurface->SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, $
    ZCOORD_CONV=zs
rTerrainClosedContours->SetProperty, XCOORD_CONV=xs, $
    YCOORD_CONV=ys, $
    ZCOORD_CONV=zs
rTerrainNewContour->SetProperty, XCOORD_CONV=xs, $
    YCOORD_CONV=ys, $
    ZCOORD_CONV=zs
rTerrainCustomContours->SetProperty, XCOORD_CONV=xs, $
    YCOORD_CONV=ys, $
    ZCOORD_CONV=zs
;
;Create some lights.
;
rLight = OBJ_NEW('IDLgrLight', LOCATION=[2,1,2], TYPE=1)
rTerrainTop->Add, rLight
rLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
rTerrainTop->Add, rLight
;
;Place the model in the view.
;
rTerrainView->Add, rTerrainTop
;
;Rotate to a nice perspective for first draw.
;
rTerrainGroup->Rotate, [1,0,0], -90
rTerrainGroup->Rotate, [0,1,0], 140
rTerrainGroup->Rotate, [1,0,0], 12

state.rImage = rImage
state.rTerrainView = rTerrainView
state.rTerrainGroup = rTerrainGroup
state.rTerrainContours = rTerrainContours
state.rTerrainNewContour = rTerrainNewContour
state.rTerrainCustomContours = rTerrainCustomContours
state.rTerrainSurface = rTerrainSurface
state.rTerrainClosedContours = rTerrainClosedContours
state.rTerrainPalette = rTerrainPalette
state.rLabelFont = rLabelFont

end

;--------------------------------------------------------------------
pro d_contourTerrain_event, event

WIDGET_CONTROL, event.top, GET_UVALUE=pState

demo_record, $
    event, $
    'd_contourTerrain_event', $
    FILENAME=(*pState).record_to_filename, $
    CW=(*pState).wTerrainStyleRadio

WIDGET_CONTROL, (*pState).wDraw[1], GET_VALUE=rWindow
;
;Handle events.
;
CASE event.id OF
    (*pState).wDraw[1]: begin
;
;       Expose.
;
        if (event.type EQ 4) $
        and (event.id EQ (*pState).wCurrentDraw) then begin
            rWindow->Draw, (*pState).rTerrainView
            return
            endif
;
;       Handle trackball updates.
;
        if (*pState).rTerrainTrackball->Update(event, TRANSFORM=qmat) $
        NE 0 $
        then begin
            (*pState).rTerrainGroup->GetProperty, TRANSFORM=t
            (*pState).rTerrainGroup->SetProperty, TRANSFORM=t#qmat
            rWindow->Draw, (*pState).rTerrainView
            return
            endif
;
;       Button press.
;
        if event.type EQ 0 then begin
            (*pState).btndown = event.press
            (*pState).rTerrainClosedContours->GetProperty, $
                 HIDE=fill_hidden
            if fill_hidden and event.press EQ 4 then begin
                if rWindow->Pickdata( $
                    (*pState).rTerrainView, $
                    (*pState).rTerrainSurface, $
                    [event.x, event.y], $
                    xyzlocation $
                    ) $
                then begin
                    (*pState).rTerrainContours->SetProperty, /HIDE
                    (*pState).rTerrainCustomContours->SetProperty, $
                        HIDE=0
                    (*pState).rTerrainNewContour->SetProperty, HIDE=0, $
                        C_VALUE=[xyzlocation[2]]
                    rWindow->Draw, (*pState).rTerrainView
                    end
                end
            WIDGET_CONTROL, (*pState).wDraw[1], /DRAW_MOTION
            endif
;
;       Motion
;
        if event.type EQ 2 then begin
            (*pState).rTerrainClosedContours->GetProperty, $
                HIDE=fill_hidden
            if fill_hidden and (*pState).btndown EQ 4b then begin
                if rWindow->Pickdata( $
                    (*pState).rTerrainView, $
                    (*pState).rTerrainSurface, $
                    [event.x, event.y], $
                    xyzlocation $
                    ) $
                then begin
                    (*pState).rTerrainNewContour->SetProperty, $
                        C_VALUE=[xyzlocation[2]], $
                        HIDE=0
                    (*pState).rTerrainContours->SetProperty, /HIDE
                    (*pState).rTerrainCustomContours->SetProperty, HIDE=0
                    rWindow->Draw, (*pState).rTerrainView
                    end
                end
            end
;
;       Button release.
;
        if (event.type EQ 1) then begin
            (*pState).rTerrainClosedContours->GetProperty, HIDE=fill_hidden
            if fill_hidden and ((*pState).btndown EQ 4b) then begin
                (*pState).rTerrainNewContour->GetProperty, $
                    C_VALUE=new_c_value
                if new_c_value[0] ne -1 then begin
                    (*pState).rTerrainCustomContours->GetProperty, $
                        C_VALUE=custom_c_values
                    c_values = [new_c_value, custom_c_values]
                    c_values = $
                        c_values[ $
                            0 $
                            :(n_elements(c_values) - 1) $
                                 < ((*pState).max_terrain_levels - 1) $
                            ]
                    c_values = c_values[UNIQ(ROUND(c_values), SORT(c_values))]
                    if n_elements(c_values) GT 1 then begin
                        WIDGET_CONTROL, (*pState).wTerrainLevelsSlider, $
                            SET_VALUE=n_elements(c_values)
                        (*pState).rTerrainCustomContours->SetProperty, $
                            C_VALUE=c_values
                        (*pState).in_sync = 0b
                        end $
                    else begin
                        (*pState).rTerrainContours->SetProperty, HIDE=0
                        end
                    end
                (*pState).rTerrainNewContour->SetProperty, $
                    C_VALUE=[-1], $
                    /HIDE
                rWindow->Draw, (*pState).rTerrainView
                end
            (*pState).btndown = 0b
            WIDGET_CONTROL, (*pState).wDraw[1], DRAW_MOTION=0
            endif
        end
;******
    	(*pState).wTerrainLevelsSlider: begin
		    WIDGET_CONTROL, /HOURGLASS
		    (*pState).rTerrainCustomContours->SetProperty, C_VALUE=[0]
		    (*pState).rTerrainContours->SetProperty, $
		        N_LEVELS=event.value

		    (*pState).rTerrainClosedContours->GetProperty, HIDE=fill_hidden
		    if fill_hidden then begin
		        (*pState).rTerrainContours->SetProperty, HIDE=0
		        (*pState).in_sync = 0b
		        end $
		    else begin
		        (*pState).rTerrainClosedContours->SetProperty, $
		            C_VALUE=0, $
		            N_LEVELS=event.value, $
		            C_COLOR=congrid( $
		                (*pState).ramp, $
		                ((event.value + 1) / 2) > 2, $
		                /MINUS_ONE $
		                )
		        (*pState).in_sync = 1b
		        end

		    rWindow->Draw, (*pState).rTerrainView
        end
    (*pState).wTerrainStyleRadio: begin
        (*pState).rTerrainNewContour->SetProperty, /HIDE
        case event.value of
            0 : begin
                (*pState).rTerrainClosedContours->SetProperty, /HIDE
                (*pState).rTerrainSurface->SetProperty, HIDE=0
                (*pState).rTerrainCustomContours->GetProperty, $
                    C_VALUE=custom_c_value
                   if n_elements(custom_c_value) GT 1 then $
                       (*pState).rTerrainCustomContours->SetProperty, $
                       HIDE=0 $
                   else $
                       (*pState).rTerrainContours->SetProperty, HIDE=0
                WIDGET_CONTROL, /HOURGLASS
                rWindow->Draw, (*pState).rTerrainView
                end
            1 : begin
                WIDGET_CONTROL, /HOURGLASS
                (*pState).rTerrainSurface->SetProperty, /HIDE
                (*pState).rTerrainCustomContours->SetProperty, /HIDE
                (*pState).rTerrainContours->SetProperty, /HIDE

                (*pState).rTerrainClosedContours->SetProperty, HIDE=0
                if not (*pState).in_sync then begin
                    (*pState).rTerrainSurface->GetProperty, $
                        ZRANGE=zrange
                    (*pState).rTerrainCustomContours->GetProperty, $
                        C_VALUE=c_value
                    if n_elements(c_value) LE 1 then $
                        (*pState).rTerrainContours->GetProperty, $
                            C_VALUE=c_value
                    (*pState).rTerrainClosedContours->SetProperty, $
                        C_VALUE=[c_value, zrange[1] + 1], $
                        C_COLOR=congrid( $
                            (*pState).ramp, $
                            (n_elements(c_value) / 2) > 2, $
                            /MINUS_ONE $
                            )
                    (*pState).in_sync = 1b
                    end
                rWindow->Draw, (*pState).rTerrainView
             end
             else:
         endcase
         end
   		    (*pState).wTerrainLabelCheck: begin
    		WIDGET_CONTROL, /HOURGLASS
			(*pState).rTerrainContours->SetProperty, C_LABEL_SHOW=event.select
			(*pState).rTerrainNewContour->SetProperty, C_LABEL_SHOW=event.select
			(*pState).rTerrainCustomContours->SetProperty, C_LABEL_SHOW=event.select
            rWindow->Draw, (*pState).rTerrainView
    		end
        else:
    endcase
end
;--------------------------------------------------------------------
;
;PURPOSE: fabricate a tire-shaped set of polygons.
;
PRO d_contourBuild_data, points, conn, ddist
;
;build one wall
;
pts = FLTARR(3,28)
pts[*,0] = [2.00,1.50,0]
pts[*,1] = [1.60,1.50,0]
pts[*,2] = [1.40,1.42,0]
pts[*,3] = [1.33,1.27,0]
pts[*,4] = [1.28,1.08,0]
pts[*,5] = [1.30,0.85,0]
pts[*,6] = [1.36,0.65,0]
pts[*,7] = [1.37,0.55,0]
pts[*,8] = [1.51,0.55,0]
pts[*,9] = [1.51,0.68,0]
pts[*,10] = [1.45,0.87,0]
pts[*,11] = [1.42,1.10,0]
pts[*,12] = [1.50,1.25,0]
pts[*,13] = [1.62,1.35,0]
pts[*,14] = [2.00,1.35,0]
pts[0,*] = pts[0,*]-2.0
;
;mirror to the other side
;
for i=15,27 do begin
    pts[*,i] = pts[*,28-i]
    pts[0,i] = -pts[0,i]
    end
pts[1,*] = 0.75 + pts[1,*]
;
;rotate the cross section
;
n = 24.0
inc = 360.0/n
ang = 0.0
points = FLTARR(3,28*n)
ddist = FLTARR(28*n)
defl = ddist
for i=0,n-1 do begin
    ca = COS(ang*(!PI/180.0))
    sa = SIN(ang*(!PI/180.0))
    for j=0,27 do begin
        pt = [0.0,0.0,0.0]
        pt[0] = pts[0,j]
        pt[1] = pts[1,j]*ca + pts[2,j]*sa
        pt[2] = pts[1,j]*sa + pts[2,j]*ca
        points[*,i*28+j] = pt
        ddist[i*28+j] = SQRT(TOTAL(pt^2))
        end
    ang = ang + inc
    end
;
;create the connectivity array using quads
;
conn = LONARR(28L*n*5)
k = 0
for i=0,n-1 do begin
    s1 = i*28
    s2 = s1 + 28
    if (i EQ n-1) then s2 = 0
    for j=0,27 do begin
        l = j + 1
        if (j EQ 27) then l = 0
        conn[k] = 4
        conn[k+1] = j+s2
        conn[k+2] = j+s1
        conn[k+3] = l+s1
        conn[k+4] = l+s2
        k = k + 5
        end
    end
end
;--------------------------------------------------------------------
;
;PURPOSE: calculate tire deformation.
;
pro d_contourCalc_defl, v, points, ddist, defl, pts

n = N_ELEMENTS(ddist)/28
pts = points
defl = FLTARR(28*n)

val = 5.5 - (v*6.0)
;
;deform the mesh
;
mm = MAX(ddist)
for i=0,(n*28)-1 do begin
    z = pts[2,i] + mm
    zf = 1.0-EXP(-(2.0*mm-z*0.5+val))
    z = z * zf
    pts[2,i] = z - mm

    ; compute the distance
    defl[i] = SQRT(TOTAL(pts[*,i]^2))
    end
;
;compute the deflection
;
defl = ABS(defl - ddist) / ddist

END

;--------------------------------------------------------------------
;
;Purpose: load and initialize all pointer and reference members of
;STATE that are related to the tire.
;
pro d_contourTire_init, state, deform
;
;Fabricate a non-deformed tire.
;
d_contourBuild_data, pts, conn, ddist
;
;Create a view volume to fit the tire and a colorbar.
;
viewRect = [-0.75, -0.75, 1.5, 1.5]
aspect = FLOAT(state.draw_x_size) / FLOAT(state.draw_y_size)
if (aspect GT 1.0) then begin
    left_offset = (aspect - 1.0) * viewRect[2] ; in normalized units
    viewRect[0] = viewRect[0] - left_offset
    viewRect[2] = viewRect[2] * aspect
    state.rTireTrackball->Reset, $
        [(state.draw_x_size - 1) - state.draw_y_size / 2, $
         state.draw_y_size / 2], $
        state.draw_y_size / 2
    end $
else begin
    left_margin_size = 0
    viewRect[1] = viewRect[1] - (((1.0/aspect)-1.0)*viewRect[3])/2.0
    viewRect[3] = viewRect[3] / (1.0/aspect)
    end
rTireView = Obj_New ('IDLgrView', $
    Location = [0,0], $
    Dimension = [0,0], $
    ViewPlane_rect = viewRect, $
    Zclip = [1,-1], $
    Color = [128, 128, 128] $
    )
;
;Create models.
;
rTireTop = OBJ_NEW('IDLgrModel')
rTireGroup = OBJ_NEW('IDLgrModel')
;
;Deform the tire our initial amount.
;
d_contourCalc_defl, deform / 100., pts, ddist, defl, points
vert_colors = BYTSCL(defl, MIN=0.0, MAX=state.max_percent * .01)
;
;Create the Polygon version of the tire.
;
rTirePolygons = Obj_New('IDLgrPolygon', points)
rTirePolygons->SetProperty, POLYGONS=conn, VERT_COLORS=vert_colors
rTirePolygons->SetProperty, SHADING=1, REJECT=1, HIDE=1
;
;Scale the display point (data) range into the draw view range
;
rTirePolygons->GetProperty, XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange
xLen = xrange[1]-xrange[0]
yLen = yrange[1]-yrange[0]
zLen = zrange[1]-zrange[0]
maxLen = (xLen > yLen) > zLen
xs = [0.0, 1.0/maxLen]
ys = [0.0, 1.0/maxLen]
zs = [0.0, 1.0/maxLen]
rTirePolygons->SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs
;
;Add the mesh to the model
;
rTireGroup->Add, rTirePolygons
;
;Create color palettes for tire.
;
black = REPLICATE(40,256)
rBlackPalette = Obj_New('IDLgrPalette', black, black, black)

light_black = black + 50
rLightBlackPalette = OBJ_NEW('IDLgrPalette', light_black, light_black, $
    light_black)

rRainbowPalette = Obj_New('IDLgrPalette')
rRainbowPalette->Loadct, 13
rRainbowPalette->GetProperty, $
    RED_VALUES=r, GREEN_VALUES=g, BLUE_VALUES=b
r = r > 40
g = g > 40
b = b > 40
indx = min(where((r > g > b) gt 40))
indx = (indx - 1) > 0
r = byte(round(congrid(r[indx:*], 256, /interp, /minus_one)))
g = byte(round(congrid(g[indx:*], 256, /interp, /minus_one)))
b = byte(round(congrid(b[indx:*], 256, /interp, /minus_one)))
rRainbowPalette->SetProperty, $
    RED_VALUES=r, GREEN_VALUES=g, BLUE_VALUES=b
;
;Create the contour version of the tire.
;
c_value = [0,25,55,95,135,175,215,255,290] ; look nice
sLabelData = {maxValue: FLOAT(MAX(vert_colors)+15), $
              maxPercent: FLOAT(state.max_percent)}
rTireContour = OBJ_NEW('IDLgrContour',$
    GEOMZ=points, $
    POLYGONS=conn, $
    SHADING=1, $
    PALETTE=rRainbowPalette, $
    FILL=1, $
    C_COLOR=c_value, $
    C_VALUE=c_value, $
    COLOR=[40, 40, 40], $
    DATA_VALUES=vert_colors+15, $
    LABEL_FORMAT='d_contourTireLabelFormat', $
    LABEL_FRMTDATA=sLabelData $
    )
rTireContour->SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs

rTireGroup->Add, rTireContour
rTireGroup->Setproperty,UVALUE='Tire'
;
;Place the model in the view.
;
rTireTop->Add, rTireGroup
rTireView->Add, rTireTop
;
;Add lights
;
rLight = OBJ_NEW('IDLgrLight', loc=[-0.2,0.2,1.0], Inten=0.85, type=2)
rTireTop->Add,rLight
rLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.75)
rTireTop->Add, rLight
;
;Add colorbar legend.
;
rColorBar = OBJ_NEW('IDLgrColorBar', COLOR=[255, 255, 255])
rColorBar->SetProperty, RED=r, GREEN=g, BLUE=b
rColorBar->SetProperty, /SHOW_AXIS, /SHOW_OUTLINE
rColorBar->GetProperty, MAJOR=major
rTickText = OBJ_NEW( $
    'IDLgrText', $
    STRING( $
        FINDGEN(major) * state.max_percent / (major - 1), $
        FORMAT='(I2)' $
        ) $
    )
rColorBarTitle = OBJ_NEW('IDLgrText', 'Resulting % Deformation')
rColorBar->SetProperty, $
    TICKTEXT=rTickText, $
    TICKVALUES=CONGRID(INDGEN(256), major, /MINUS_ONE), $
    TITLE=rColorBarTitle


rColorBar->GetProperty, XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange
xLen = xrange[1]-xrange[0]
yLen = yrange[1]-yrange[0]
zLen = zrange[1]-zrange[0]
maxLen = (xLen > yLen) > zLen
offset = left_offset - .1 ; a little extra room for title and ticktext.
xs = [-.5 - offset, 1.0 / maxLen]
ys = [-.5, 1.0 / maxLen]
zs = [0.0, 1.0 / maxLen]
rColorBar->SetProperty, XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs

rTireTop->Add, rColorbar
;
;Rotate to a nice perspective for first draw.
;
rTireGroup->Rotate, [0,1,0], -45
rTireGroup->Rotate, [1,0,0], -30

pTireData = PTR_NEW({ $
    pts: temporary(pts), $
    ddist: temporary(ddist) $
    })

state.rTickText = rTickText
state.rColorBarTitle = rColorBarTitle
state.pTireData = pTireData
state.rTireView = rTireView
state.rTireTop = rTireTop
state.rTireGroup = rTireGroup
state.rTireContour = rTireContour
state.rTirePolygons = rTirePolygons
state.rRainbowPalette = rRainbowPalette
state.rBlackPalette = rBlackPalette
state.rLightBlackPalette = rLightBlackPalette
state.rColorBar = rColorBar

end

;--------------------------------------------------------------------
;
pro d_contourTire_event, event

WIDGET_CONTROL, event.top, GET_UVALUE=pState

demo_record, $
    event, $
    'd_contourTire_event', $
    FILENAME=(*pState).record_to_filename, $
    CW=(*pState).wTireDisplayMode

WIDGET_CONTROL, (*pState).wDraw[1], GET_VALUE=rWindow

case event.id of
    (*pState).wDraw[1]: begin
;
;       Expose.
;
        if (event.type EQ 4) $
        and (event.id EQ (*pState).wCurrentDraw) then begin
            rWindow->Draw, (*pState).rTireView
            return
            endif
;
;       Handle trackball updates.
;
        if (*pState).rTireTrackball->Update(event, TRANSFORM=qmat) then begin
            (*pState).rTireGroup->GetProperty, TRANSFORM=t
            (*pState).rTireGroup->SetProperty, TRANSFORM=t#qmat
            rWindow->Draw, (*pState).rTireView
            end
;
;       Button press.
;
        if (event.type EQ 0) then begin
            if (event.press EQ 4) then begin ; Right mouse.
                pick = rWindow->PickData( $
                    (*pState).rTireView, $
                    (*pState).rTirePolygons, $
                    [event.x,event.y], $
                    dataxyz $
                    )
                if (pick EQ 1) then begin
                    r = sqrt(total(dataxyz[1:2] * dataxyz[1:2]))
                    t = atan(dataxyz[1] / r, dataxyz[2] / r) * (180.0 / !pi)
                    str = STRING( $
                        r, $
                        t, $
                        dataxyz[0], $
                        FORMAT=(*pState).tire_number_format $
                        )
                    end $
                else begin
                    str = "Data point: In background."
                    end
                demo_putTips, (*pState), str, 10
                (*pState).btndown = 4b
                WIDGET_CONTROL, (*pState).wDraw[1], /DRAW_MOTION
                end $
            else begin ; Other mouse button press.
                (*pState).btndown = 1b
                void = (*pState).rTireTrackball->Update(event)
                rWindow->SetProperty, QUALITY=(*pState).tire_drag_quality
                WIDGET_CONTROL, (*pState).wDraw[1], /DRAW_MOTION
                rWindow->Draw, (*pState).rTireView
                end
            end
;
;       Button motion.
;
        if (event.type EQ 2) then begin
            if ((*pState).btndown EQ 4b) then begin ; Right mouse button.
                pick = rWindow->PickData( $
                    (*pState).rTireView, $
                    (*pState).rTirePolygons, $
                    [event.x,event.y], $
                    dataxyz $
                    )
                if (pick EQ 1) then begin
                    r = sqrt(total(dataxyz[1:2] * dataxyz[1:2]))
                    t = atan(dataxyz[1] / r, dataxyz[2] / r) * (180.0 / !pi)
                    str = STRING( $
                        r, $
                        t, $
                        dataxyz[0], $
                        FORMAT=(*pState).tire_number_format $
                        )
                    end $
                else begin
                    str = "Data point: In background."
                    end
                demo_putTips, (*pState), str, 10
                end
            end ; Button motion
;
;       Button release.
;
        if event.type EQ 1 then begin
            if (*pState).btndown EQ 1b then begin
                rWindow->SetProperty, QUALITY=2
                rWindow->Draw, (*pState).rTireView
                end
            (*pState).btndown = 0b
            WIDGET_CONTROL, (*pState).wDraw[1], DRAW_MOTION=0
            end
        end

    (*pState).wTireDragQuality: begin
        (*pState).tire_drag_quality = event.index
        end
    (*pState).wTireDisplayMode: begin
        WIDGET_CONTROL, /HOURGLASS
        case event.value of
            0 : begin
                (*pState).rTireContour->SetProperty, HIDE=0, FILL=0
                (*pState).rTireContour->SetProperty, C_LABEL_SHOW=1
                (*pState).rTirePolygons->SetProperty, /HIDE
                (*pState).rColorBar->SetProperty, HIDE=0
                end
            1 : begin
                (*pState).rTireContour->SetProperty, HIDE=0, FILL=1
                (*pState).rTirePolygons->SetProperty, /HIDE
                (*pState).rColorBar->SetProperty, HIDE=0
                end
            2 : begin
                (*pState).rTireContour->SetProperty, /HIDE
                (*pState).rTirePolygons->SetProperty, HIDE=0, $
                    PALETTE=(*pState).rBlackPalette, $
                    STYLE=1
                (*pState).rColorBar->SetProperty, /HIDE
                end
            3 : begin
                (*pState).rTireContour->SetProperty, /HIDE
                (*pState).rTirePolygons->SetProperty, HIDE=0, $
                    PALETTE=(*pState).rRainbowPalette, $
                    STYLE=1
                (*pState).rColorBar->SetProperty, HIDE=0
                end
            4 : begin
                (*pState).rTireContour->SetProperty, /HIDE
                (*pState).rTirePolygons->SetProperty, HIDE=0, $
                    PALETTE=(*pState).rBlackPalette, $
                    STYLE=2
                (*pState).rColorBar->SetProperty, /HIDE
                end
            5 : begin
                (*pState).rTireContour->SetProperty, /HIDE
                (*pState).rTirePolygons->SetProperty, HIDE=0, $
                    PALETTE=(*pState).rRainbowPalette, $
                    STYLE=2
                (*pState).rColorBar->SetProperty, HIDE=0
                end
            6 : begin
                (*pState).rTireContour->SetProperty, HIDE=0, FILL=0
                (*pState).rTirePolygons->SetProperty, HIDE=0, $
                    PALETTE=(*pState).rLightBlackPalette, $
                    STYLE=1
                (*pState).rColorBar->SetProperty, HIDE=0
                end
            endcase
        rWindow->Draw, (*pState).rTireView
        end
    (*pState).wTireDeformationSlider: begin
        d_contourCalc_defl, event.value / 100., $
            (*(*pState).pTireData).pts, $
            (*(*pState).pTireData).ddist, $
            defl, $
            points
        colors = BYTSCL(defl, MIN=0.0, MAX=(*pState).max_percent * .01)
        (*pState).rTirePolygons->SetProperty, VERT_COLORS=colors, DATA=points
        (*pState).rTireContour->SetProperty, DATA_VALUES=colors+15, $
            GEOMZ=points
        WIDGET_CONTROL, /HOURGLASS
        rWindow->Draw, (*pState).rTireView
        end
    else:
    endcase
end

;--------------------------------------------------------------------
;
pro d_contourEvent, $
     event                      ; IN: event structure

WIDGET_CONTROL, event.top, GET_UVALUE=pState

demo_record, $
  event, $
  'd_contourEvent', $
  FILENAME=(*pState).record_to_filename, $
  CW=(*pState).wDatasetRadio

if (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST') $
  then begin
    WIDGET_CONTROL, event.top, /DESTROY
    RETURN
endif

case event.id of

    (*pState).wDatasetRadio : begin
        WIDGET_CONTROL, /HOURGLASS
        newWindow = (*pState).wDraw[event.value ne 0]
        newControlBase = (*pState).wControlsBase[event.value]
        WIDGET_CONTROL, (*pState).wCurrentControlsBase, MAP=0
        WIDGET_CONTROL, newControlBase, MAP=1
        (*pState).wCurrentControlsBase = newControlBase

        if newWindow ne (*pState).wCurrentDraw then begin
            WIDGET_CONTROL, (*pState).wCurrentDraw, MAP=0
            WIDGET_CONTROL, newWindow, MAP=1
            (*pState).wCurrentDraw = newWindow
        endif

        if event.value ge 1 then begin
            WIDGET_CONTROL, (*pState).wDraw[1], $
              EVENT_PRO=(['d_contourTerrain_event','d_contourTire_event'])$
              [event.value-1]

            if event.value eq 2 and $ ;Init tire for first time?
              (*pState).rTireView eq OBJ_NEW() then $
              d_contourTire_init, *pState, 90

            WIDGET_CONTROL, (*pState).wDraw[1], GET_VALUE=rWindow
            rWindow->Draw, event.value eq 1 ? $
              (*pState).rTerrainView : (*pState).rTireView
        endif


        case event.value of
            0 : begin
                WIDGET_CONTROL, (*pState).wVRMLButton, SENSITIVE=0
;
;               Draw.
;
                WIDGET_CONTROL, $
                  (*pState).wWorldStyleRadio, $
                  GET_VALUE=indx
                d_contourWorld_event, { $
                                        id: (*pState).wWorldStyleRadio, $
                                        top: event.top, $
                                        handler: 0L, $
                                        value: indx $
                                      }
            end
            else: begin
                if not (LMGR(/DEMO)) then $
                  WIDGET_CONTROL, (*pState).wVRMLButton, SENSITIVE=1
            end
        endcase

    endcase

    (*pState).wVRMLButton : begin
        filename = dialog_pickfile(/write, $
                                   file='untitled.wrl', $
                                   dialog_parent=event.top, $
                                   filter='*.wrl' $
                                  )
        if filename ne '' then begin
            WIDGET_CONTROL, (*pState).wDatasetRadio, GET_VALUE=indx
            WIDGET_CONTROL, (*pState).wCurrentDraw, GET_VALUE=rWindow
            rWindow->GetProperty, $
              DIMENSIONS=dimensions, $
              RESOLUTION=resolution, $
              COLOR_MODEL=color_model, $
              N_COLORS=n_colors
            rVRML = obj_new('IDLgrVRML', $
                            DIMENSIONS=dimensions, $
                            RESOLUTION=resolution, $
                            COLOR_MODEL=color_model, $
                            N_COLORS=n_colors $
                           )
            rVRML->SetProperty, FILENAME=filename
            rVRML->Draw, $
              ([(*pState).rTerrainView, (*pState).rTireView])[indx - 1]
            obj_destroy, rVRML
        endif
    endcase
;
;   Quit this application.
;
    (*pState).wQuitButton : begin
        WIDGET_CONTROL, event.top, /DESTROY
    end
;
;   Display the information file.
;
    (*pState).wAboutButton : begin
        ONLINE_HELP, 'd_contour', $
          book=demo_filepath("idldemo.adp", $
                             SUBDIR=['examples','demo','demohelp']), $
          /FULL_PATH
    endcase                     ;of ABOUT

    else :                      ;do nothing
endcase
end     ; of d_contourEvent

;--------------------------------------------------------------------
;
pro d_contourCleanup, wTopBase
;
;Get the color table saved in the window's user value.
;
WIDGET_CONTROL, wTopBase, GET_UVALUE=pState
;
;Restore the previous color table.
;
TVLCT, (*pState).color_table
;
;Restore the previous plot font.
;
!P.FONT = (*pState).plot_font
;
;Delete the pixmap.
;
WDELETE, (*pState).pixmap_winID
;
;Restore default margins.
;
!X.MARGIN = [10, 3]
!Y.MARGIN = [4, 2]

if WIDGET_INFO((*pState).group_base, /VALID_ID) then $
    WIDGET_CONTROL, (*pState).group_base, /MAP
;
;Silently flush any accumulated math error.
;
void = check_math()
;
;Restore math exception behavior
;
!except = (*pState).orig_except
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
end   ; of Cleanup

;--------------------------------------------------------------------
;
pro d_contour, $
    GROUP=group, $      ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB=appTLB       ; OUT: (opt) TLB of this application
;
;Check the validity of the group identifier.
;
ngroup = N_ELEMENTS(group)
if (ngroup NE 0) then begin
    check = WIDGET_INFO(group, /VALID_ID)
    if (check NE 1) then begin
        print,'Error, the group identifier is not valid'
        print, 'Return to the main application'
        RETURN
    endif
    group_base = group
endif else group_base = 0L

;
;Silently flush any accumulated math error.
;
void = check_math()
;
;Silently accumulate any subsequent math errors.
;
orig_except = !except
!except = 0
;
DEVICE, DECOMPOSED=0, BYPASS_TRANSLATION = 0

;Get the current color table. It will be restored when exiting.
;
TVLCT, savedR, savedG, savedB, /GET
color_table = [[savedR],[savedG],[savedB]]
;
;Get the screen size.
;
DEVICE, GET_SCREEN_SIZE = screenSize
;
;Create the starting up message.
;
drawbase = demo_startmes(GROUP=group_base)
;
;Also save the font.
;
plot_font = !P.FONT
;
;Get the character scaling factor.
;
char_scale = 8.0/!d.X_CH_SIZE
;
;Load a new color table.
;
LOADCT, 5, /SILENT
high_color = !D.TABLE_SIZE-18
TEK_COLOR, high_color+1, 16
;
;Use hardware-drawn font.
;
!P.FONT=0
;
;Set up the drawing area size.
;
draw_x_size = 0.6 * screenSize[0]
draw_y_size = 0.8 * draw_x_size
;
;Set the initial number of contour levels.
;
world_n_levels = 15
;
;Create the widgets.
;
wTopBase = WIDGET_BASE(TITLE="Contour Plots", $
    /TLB_KILL_REQUEST_EVENTS,   $
    MAP=0,                      $
    /COLUMN,                    $
    GROUP_LEADER=group_base,    $
    TLB_FRAME_ATTR=1,           $
    UNAME='d_contour:tlb',      $
    MBAR=barBase)
;
;   Create the menu bar items.
;
wFileButton = WIDGET_BUTTON(barBase, VALUE='File')
wVRMLButton = WIDGET_BUTTON(wFileButton, VALUE='View to VRML')
wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                            UNAME='d_contour:Quit')

wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP)
wAboutButton = WIDGET_BUTTON(wHelpButton, $
                             VALUE='About contours')
;
;   Create left and right bases.
;
dataset_titles = [ $
                   'World Elevation', $
                   'Terrain Elevation', $
                   'Vehicle Tire' $
                 ]

wRowBase = WIDGET_BASE(wTopBase, /ROW)
wLeftBase = WIDGET_BASE(wRowBase, /COLUMN)
wStackerBase = WIDGET_BASE(wRowBase)
wRightBase = LONARR(N_ELEMENTS(dataset_titles))
wDraw = lonarr(2)
for i=0, 1 do begin             ;Do direct & object graphics windows
    wRightBase[i] = WIDGET_BASE(wStackerBase)
    wDraw[i] = WIDGET_DRAW(wRightBase[i], GRAPHICS_LEVEL=i ? 2 : 1, $
                           XSIZE=draw_x_size, YSIZE=draw_y_size, $
                           RETAIN=i ? 0 : 2, $
                           EXPOSE_EVENTS=i, BUTTON_EVENTS=i, $
                           UNAME='d_contour:draw'+strtrim(i,2))
    widget_control, wDraw[i], MAP=i ;Only map terrain window
endfor

wDatasetRadio = CW_BGROUP( $
                           wLeftBase, $
                           dataset_titles, $
                           UVALUE='DATASET', $
                           SET_VALUE=1, $
                           /EXCLUSIVE, $
                           /NO_RELEASE $
                         )
WIDGET_CONTROL, wDatasetRadio, SET_UNAME='d_contour:DatasetRadio'
;
;   Create Control Panel bases.  One for each dataset.
;
wStackerBase = WIDGET_BASE(wLeftBase)
for i=0, N_ELEMENTS(dataset_titles)-1 do  begin
    temp = WIDGET_BASE( $
                        wStackerBase, $
                        UVALUE=STRUPCASE(dataset_titles[i]), $
                        UNAME='d_contour:'+(['world','terrain','tire'])[i]+'cntrlbase', $
                        /COLUMN, $
                        MAP=0 $
                      )
    wControlsBase = N_ELEMENTS(wControlsBase) eq 0  ? $
      temp : [wControlsBase, temp]
endfor

;
wWorldLevelsLabel = WIDGET_LABEL( $
                                  wControlsBase[0], $
                                  VALUE='15', $
                                  /ALIGN_CENTER $
                                )

wWorldLevelsSlider = WIDGET_SLIDER( $
                                    wControlsBase[0], $
                                    MINIMUM=1, $
                                    MAXIMUM=3, $
                                    VALUE=3, $
                                    UNAME='d_contour:WorldLevelsSlider', $
                                    /SUPPRESS_VALUE, $
                                    TITLE='Number of Levels' $
                                  )

junk = WIDGET_BASE(wControlsBase[0], /COLUMN, /FRAME)
wWorldStyleRadio =  $
  CW_BGROUP( junk, ['Line Color', 'Annotation', 'Fill', $
                    'Downhill Ticks', 'LineStyles', 'Thickness'], $
             /NONEXCLUSIVE, SET_VALUE=[1,0,0,0,0] )
wWorldStyleRadio1= CW_BGROUP( junk, ['Cylindrical', 'Mollweide', 'Goodes'], $
               /EXCLUSIVE, /FRAME, SET_VALUE=0)

WIDGET_CONTROL, wWorldStyleRadio, SET_UNAME='d_contour:worldstyleradio'
WIDGET_CONTROL, wWorldStyleRadio1, SET_UNAME='d_contour:worldstyleradio1'

wTireDragQuality = WIDGET_DROPLIST( $
                                    wControlsBase[2], $
                                    VALUE=['low','medium','high'], $
                                    UNAME='d_contour:TireDragQual', $
                                    TITLE='Drag Quality' $
                                  )

wTireDisplayMode = CW_BGROUP( $
                              wControlsBase[2], $
                              ['Contour Lines', 'Filled Contours', 'Mesh', 'Colored Mesh', $
                               'Surface', 'Colored Surface', 'Mesh and Contours'], $
                              SET_VALUE=1, $
                              /EXCLUSIVE, $
                              /NO_RELEASE $
                            )
WIDGET_CONTROL, wTireDisplayMode, SET_UNAME='d_contour:TireDisplayMode'

; Min and Max are Determined empirically.  Keeps from 1 to 20 contours.
wTireDeformationSlider = WIDGET_SLIDER( $
                                        wControlsBase[2], $
                                        MIN=40, $
                                        MAX=93, $
                                        UNAME='d_contour:TireDeform', $
                                        TITLE='Deformation Parameter' $
                                      )

max_terrain_levels = 20         ; looks nice.
wTerrainLevelsSlider = WIDGET_SLIDER( $
                                      wControlsBase[1], $
                                      MINIMUM=2, $
                                      MAXIMUM=max_terrain_levels, $
                                      UNAME='d_contour:TerrainLevSlider', $
                                      TITLE='Number of Levels' $
                                    )

wTerrainStyleRadio = CW_BGROUP( $
                                wControlsBase[1], $
                                ['Lines', 'Fill'], $
                                SET_VALUE=0, $
                                /EXCLUSIVE, $
                                /NO_RELEASE $
                              )
WIDGET_CONTROL, wTerrainStyleRadio, SET_UNAME='d_contour:TerrainStyleRadio'

wTerrainLabelCheck = CW_BGROUP( $
                                wControlsBase[1], $
                                ['Show Labels'], $
                                SET_VALUE=0, $
                                /NONEXCLUSIVE $
                              )

;
;   Create tips text area.
;
    wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)
;
;Realize the widget hierarchy.
;
if !version.os_family EQ 'Windows' then $
    WIDGET_CONTROL, wTopBase, MAP=1 ; workaround. CRS report #6140
WIDGET_CONTROL, wTopBase, /REALIZE, SENSITIVE=0
WIDGET_CONTROL, /HOURGLASS

appTLB = wTopBase               ; Return parameter.
sText = demo_getTips(demo_filepath('contr.tip', $
                                   SUBDIR=['examples','demo', 'demotext']), $
                     wTopBase, $
                     wStatusBase)
;
;Determine the window ID of plot window and associated pixmap.
;
WIDGET_CONTROL, wDraw[0], GET_VALUE=world_winID
Window, /FREE, XSIZE=draw_x_size, YSIZE=draw_y_size, /PIXMAP
pixmap_winID = !D.Window
;
;Open and read the world elevation data file.
;
WIDGET_CONTROL, /HOURGLASS
world_elev = BYTARR(360, 360, /Nozero)
GET_LUN, data_lun
OPENR, data_lun, demo_filepath('worldelv.dat', $
                               SUBDIR=['examples', 'data'])
READU, data_lun, world_elev
CLOSE, data_lun
FREE_LUN, data_lun
temp = REBIN(TEMPORARY(world_elev), 90, 45)
world_elev = bytarr(91,45)
world_elev[0,0] = temp
world_elev[90,0] = world_elev[0,*] ;Duplicate 1st column at end

if n_elements(record_to_filename) eq 0 then $
  record_to_filename = ''
;
;Create the info structure.
;
pState = { $
           sText: sText, $      ; Text structure for tips
           world_elev: TEMPORARY(world_elev), $ ; Elevation data
           world_n_levels: world_n_levels, $ ; Number of contour levels
           terrain_n_levels: 0, $
           high_color: high_color, $ ; Color index of highest color.
           wCurrentControlsBase: wControlsBase[0], $
           wCurrentDraw: wDraw[0], $
           draw_x_size: draw_x_size, $ ; X size of drawing area
           draw_y_size: draw_y_size, $ ; Y size of drawing area
           color_table: color_table, $ ; Color table to restore at exit
           char_scale: char_scale, $ ; Character scaling factor
           pixmap_winID: pixmap_winID, $
           world_winID: world_winID, $ ; Direct graphics window ID
           wTopBase: wTopBase, $ ; Top level base
           wVRMLButton: wVRMLButton, $
           wQuitButton: wQuitButton, $
           wAboutButton: wAboutButton, $
           wWorldLevelsLabel: wWorldLevelsLabel, $
           wWorldLevelsSlider: wWorldLevelsSlider, $
           wWorldStyleRadio: wWorldStyleRadio, $
           wWorldStyleRadio1: wWorldStyleRadio1, $
           wTerrainLevelsSlider: wTerrainLevelsSlider, $
           wTerrainLabelCheck:wTerrainLabelCheck, $
           wTireDragQuality: wTireDragQuality, $
           wTireDisplayMode: wTireDisplayMode, $
           wTireDeformationSlider: wTireDeformationSlider, $
           wDatasetRadio: wDatasetRadio, $
           wControlsBase: wControlsBase, $
           wDraw: wDraw, $
           plot_font: plot_font, $ ; Font ID
           pTerrainData: PTR_NEW(), $
           rLabelFont: OBJ_NEW(), $
           rImage: OBJ_NEW(), $
           rTerrainView: OBJ_NEW(), $
           rTerrainGroup: OBJ_NEW(), $
           rTerrainContours: OBJ_NEW(), $
           rTerrainNewContour: OBJ_NEW(), $
           rTerrainCustomContours: OBJ_NEW(), $
           rTerrainClosedContours: OBJ_NEW(), $
           rTerrainPalette: OBJ_NEW(), $
           rTerrainSurface: OBJ_NEW(), $
           wTerrainStyleRadio: wTerrainStyleRadio, $
           rTerrainTrackball: OBJ_NEW('Trackball', $
                                      [draw_x_size/2, draw_y_size/2.], $
                                      draw_x_size/2.), $
           rTireView: OBJ_NEW(), $
           rTireTop: OBJ_NEW(), $
           rTireGroup: OBJ_NEW(), $
           rTirePolygons: OBJ_NEW(), $
           rTireContour: OBJ_NEW(), $
           rTireTrackball: OBJ_NEW('Trackball', $
                                   [draw_x_size/2, draw_y_size/2.], $
                                   draw_x_size/2.), $
           rTickText: OBJ_NEW(), $
           rColorBarTitle: OBJ_NEW(), $
           pTireData: PTR_NEW(), $
           rRainbowPalette: OBJ_NEW(), $
           rBlackPalette: OBJ_NEW(), $
           rLightBlackPalette: OBJ_NEW(), $
           rColorBar: OBJ_NEW(), $
           pInitialTireLevels: PTR_NEW(), $
           max_percent: 20, $   ; maximum deformation to be contoured on tire
           tire_drag_quality: 1b, $
           tire_number_format: '("Data point:  R=", F7.2,' $
           + '",  T=", F7.2, ",  Z=", F7.2)', $
           btndown: 0b, $
           max_terrain_levels: max_terrain_levels, $
           orig_except: orig_except, $
           ramp: bindgen(256), $
           in_sync: 0b, $       ; boolean. Filled contour levels == non-filled
           record_to_filename: record_to_filename, $
           group_base: group_base $ ; Base of Group Leader
         }
pState = ptr_new(pState)

WIDGET_CONTROL, wTopBase, SET_UVALUE=pState
;
;Associate event handler routines with widgets.
;
WIDGET_CONTROL, wControlsBase[0], EVENT_PRO='d_contourWorld_event'
WIDGET_CONTROL, wControlsBase[1], EVENT_PRO='d_contourTerrain_event'
WIDGET_CONTROL, wControlsBase[2], EVENT_PRO='d_contourTire_event'

WIDGET_CONTROL, wDraw[1], $
    EVENT_PRO='d_contourTerrain_event'
;
;Initialze widgets and application state
;
WIDGET_CONTROL, wTireDeformationSlider, SET_VALUE=90
WIDGET_CONTROL, wTireDragQuality, SET_DROPLIST_SELECT=1

n_levels = 13 ; looks nice.
WIDGET_CONTROL, (*pState).wTerrainLevelsSlider, SET_VALUE=n_levels
d_contourTerrain_init, *pState, n_levels
;
;Register with the XMANAGER, for subsequent user events.
;
XMANAGER, "d_contour", wTopBase, $
    /NO_BLOCK, $
    EVENT_HANDLER="d_contourEvent", $
    CLEANUP="d_contourCleanup"
;
; Destroy the start-up window.
;
WIDGET_CONTROL, drawbase, /DESTROY
WIDGET_CONTROL, wTopBase, MAP=1, SENSITIVE=1
;
; Draw the terrain view
;
WIDGET_CONTROL, wDraw[1], GET_VALUE=rWindow
rWindow->Draw, (*pState).rTerrainView

d_contourEvent, { $
    id:wDatasetRadio, top:wTopBase, handler:0L, select:1, value:1 $
    }
if (LMGR(/DEMO)) then $
    WIDGET_CONTROL, wVRMLButton, SENSITIVE=0
end                      ; of d_contour
