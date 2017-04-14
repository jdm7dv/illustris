; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_map.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_map.pro
;
;  CALLING SEQUENCE: d_map
;
;  PURPOSE:
;       Shows mapping features available in IDL.
;
;  MAJOR TOPICS: Visualization and maps
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       fun d_mapMenuToggleState     -  Toggle off and on state of a button
;       fun d_mapMenuChoice          -  Handle the menu bar selection button
;       pro d_mapMenuCreate          -  Create the menu bar
;       pro d_mapColorInit           -  Initialize working colors
;       pro d_mapDraw                -  Draw the map
;       pro d_mapDrawCirc            -  Draw a great circle
;       pro d_mapCir2P               -  Connect 2 points with a great circle
;       fun d_mapCityMark            -  Mark a city
;       pro d_mapEvent               -  Event handler
;       pro d_mapCleanup             -  Cleanup
;       pro d_map                    -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips         -  Read the tip file and create widgets
;       pro demo_puttips         -  Change tips text
;       map_demo.tip
;       cities.dat
;       worldelv.dat
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCKS:
;       MAP_DEMO_COM
;
;  MODIFICATION HISTORY:
;       3/97,   DMS   - Written.
;-
;----------------------------------------------------------------------------
FUNCTION d_mapStripPath, filename
COMPILE_OPT hidden

    CASE !VERSION.OS_FAMILY OF
        'MacOS': BEGIN
            sep = ':'
          END
        'unix': BEGIN
            sep = '/'
          END
        'vms': BEGIN
            sep = ']'
          END
        'Windows': BEGIN
            sep = '\'
          END
    ENDCASE

    pos = STRPOS(filename, sep, /REVERSE_SEARCH)
    IF ((pos GE 0) AND (pos LT (STRLEN(filename)))) THEN $
        RETURN, STRMID(filename, pos+1) $
    ELSE $
        RETURN, filename
END

;----------------------------------------------------------------------------
;
;    PURPOSE  Calculate a longitude midpoint, given a longitude range.
;
Function d_mapLongitudeMid, range
compile_opt hidden

min_lon = range[0]
max_lon = range[1]

result = MEAN(range)
if min_lon gt 0 and max_lon lt 0 then begin
    chunk_0 = 180 - min_lon
    chunk_1 = 180 + max_lon
    chunk = chunk_0 + chunk_1
    if min_lon lt abs(max_lon) then begin
        result = min_lon + chunk / 2.
    end else begin
        result = max_lon - chunk / 2.
    end
endif
return, result
end
;----------------------------------------------------------------------------
;
;    PURPOSE  Toggle the off and on state of a menu button
;
Function d_mapMenuToggleState, $
                          wid   ;  IN: widget identifier
compile_opt hidden

WIDGET_CONTROL, wid, GET_VALUE=name

s = STRPOS(name, '(Off)')
ret = s ne -1                   ;TRUE if new state is on
if ret then strput, name, '(On )', s $
else strput, name, '(Off)', strpos(name, '(On )')
WIDGET_CONTROL, wid, SET_VALUE=name
RETURN, ret
end                             ;   of  Toggle_state,

;----------------------------------------------------------------------------
;
;    PURPOSE   Given a uservalue from a menu button created
;              by d_mapMenuCreate, return the index of the choice
;              within the category.  Set the selected menu button
;              to insensitive to signify selection, and set all
;              other choices for the category to sensitive.
;
function d_mapMenuChoice, $
            Eventval, $         ; IN: uservalue from seleted menu button
            MenuItems, $        ; IN: menu item array, from d_mapMenuCreate
            MenuButtons         ; IN: button array from d_mapMenuCreate
compile_opt hidden

i = STRPOS(eventval, '|', 0)    ;Get the name less the last qualifier
while (i GE 0) do begin
    j = i
    i = STRPOS(eventval, '|', i+1)
endwhile

base = STRMID(eventval, 0, j+1) ;  Get the common buttons, includes last | .
buttons = WHERE(STRPOS(MenuItems, base) EQ 0) ;  buttons that share base name.
this = (WHERE(eventval EQ MenuItems))[0] ;  Get the Index of the selected item.
for i=0, N_ELEMENTS(buttons)-1 do begin ;Each button in this category
    index = buttons[i]
    WIDGET_CONTROL, MenuButtons[buttons[i]], $
      SENSITIVE=index NE this
endfor

RETURN, this - buttons[0]       ;  Return the selected button's index.
end

;----------------------------------------------------------------------------
;
;    PURPOSE  Create a menu from a string descriptor (MenuItems).
;             Return the parsed menu items in MenuItems (overwritten),
;             and the array of corresponding menu buttons in MenuButtons.
;
;    MenuItems = (input/output), on input the menu structure
;                in the form of a string array.  Each button
;                is an element, encoded as follows:
;
;    Character 1 = integer bit flag.  Bit 0 = 1 to denote a
;                  button with children.  Bit 1 = 2 to denote
;                  this is the last child of its parent.
;                  Bit 2 = 4 to show that this button should
;                  initially be insensitive, to denote selection.
;                  Any combination of bits may be set.
;              On RETURN, MenuItems contains the fully
;                  qualified button names.
;
;    Characters 2-end = Menu button text.  Text should NOT
;                       contain the character |, which is used
;                       to delimit menu names.
;
;    Example:
;
;        MenuItems = ['1File', '0Save', '2Quit', $
;       '1Edit', '3Cut', $
;       '3Help']
;
;         Creates a menu with three top level buttons
;         (file, edit and help). File has 2 choices
;         (save and exit), Edit has one choice, and help has none.
;         On RETURN, MenuItems contains the fully qualified
;         menu button names in a string array of the
;         form: ['<Prefix>|File', '<Prefix>|File|Save',
;           '<Prefix>|File|Quit', '<Prefix>|Edit',..., etc. ]
;
pro d_mapMenuCreate, $
                MenuItems, $    ; IN/OUT: See below
                MenuButtons, $  ; OUT: Button widget id's of the created menu
                Bar_base, $     ; IN: menu base ID
                Prefix=prefix   ; IN: (opt) Prefix for this menu's button names.
                                ;     If omitted, no prefix
compile_opt hidden

level = 0
parent = [ bar_base, 0, 0, 0, 0, 0]
names = STRARR(5)
lflags = INTARR(5)

MenuButtons = LONARR(N_ELEMENTS(MenuItems))

if (N_ELEMENTS(prefix)) then begin
    names[0] = prefix + '|'
endif else begin
    names[0] = '|'
endelse

for i=0, N_ELEMENTS(MenuItems)-1 do begin
    flag = FIX(STRMID(MenuItems[i], 0, 1))
    txt = STRMID(MenuItems[i], 1, 100)
    uv = ''

    for j = 0, level do uv = uv + names[j]
    MenuItems[i] = uv + txt     ;  Create the button for fully qualifid names.
    uname = 'd_map:' + MenuItems[i]
    trim_pos = STRPOS(uname, ' (Off)') > STRPOS(uname, '(On )')
    if trim_pos ne -1 then $
        uname = STRMID(uname, 0, trim_pos)
    isHelp = txt eq 'Help' or txt eq 'About'
    MenuButtons[i] = WIDGET_BUTTON(parent[level], $
                                   VALUE= txt, UVALUE=uv+txt, $
                                   MENU=flag and 1, HELP=isHelp, $
                                   UNAME=uname)

    if ((flag AND 4) NE 0) then begin
        WIDGET_CONTROL, MenuButtons[i], SENSITIVE = 0
    endif

    if (flag AND 1) then begin
        level = level + 1
        parent[level] = MenuButtons[i]
        names[level] = txt + '|'
        lflags[level] = (flag and 2) NE 0
    endif else if ((flag AND 2) NE 0) then begin
        while lflags[level] do level = level-1 ;  Pops the previous levels.
        level = level - 1
    endif
endfor
end

;----------------------------------------------------------------------------
;
;    PURPOSE  Initialize the working colors.
;
pro d_mapColorInit, base
compile_opt hidden

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr


nc = !d.table_size < 256 > 16   ;# of colors we use

if (N_ELEMENTS(r_orig) NE nc) then begin
    r_orig = BYTARR(nc)
    g_orig = BYTARR(nc)
    b_orig = BYTARR(nc)
endif

    ;  Define interpolation points:
    ;  (elevation in meters, r, g, b)  be sure elevation of 1st element is
    ;  -5000 (data value 0), and last is 5240 (data value 256).
    ;  With this scaling, sea level is ~ 125.

c = FLTARR(256, 3)

nelev = nc - base               ;# of color for elevations

;      Elev   Red Green Blue
p = [[ -5000,  64,  64,  64], $ ; Dark Gray at 0
     [ -4900,   0,   0, 128], $ ; Dim blue
     [ -1500,   0,   0, 255], $ ; Bright blue
     [   -40, 192, 192, 255], $ ; Brownish
     [     0,  64, 192,  64], $ ; Med green
     [   250, 150, 150,  75], $ ; Dim Yellow
     [  1000, 200, 200, 100], $ ; Brighter yellow
     [  4000, 255, 255, 255], $ ; White
     [  5240, 255, 255, 255]]   ; To white

n = N_ELEMENTS(p)/4

for i=0,n-2 do begin            ;Each interpolation interval
    s0 = (p[0,i]+5000) * nelev / (256 * 40)
    s1 = (p[0,i+1]+5000) * nelev / (256 * 40)
    m = s1 - s0
    if m gt 0 then for j=0,2 do begin ;  Loop over each color.
        s = FLOAT(p[j+1,i+1] - p[j+1,i]) / m
        c[s0, j] = FINDGEN(m) * s + p[j+1,i]
    endfor
endfor

TEK_COLOR, 0, base              ;Load original tektronix color table.
r_orig[base] = BYTE(c[0:nelev-1,0])
g_orig[base] = BYTE(c[0:nelev-1,1])
b_orig[base] = BYTE(c[0:nelev-1,2])
r_curr = r_orig
g_curr = g_orig
b_curr = b_orig
tvlct, r_orig, g_orig, b_orig
end

;----------------------------------------------------------------------------
;
;    PURPOSE Draw a great circle with given rotation and offset.
;
pro d_mapDrawCirc, $
              rot, $            ; IN: rotation angle (in degrees)
              lon0, $           ; IN: longitude
              color             ; IN: color of the great circle
compile_opt hidden

n = 180                         ;Use 180 points
rota = rot * !DTOR      ;Radians

t = FINDGEN(n+1) * (2 * !PI/n)
sint = SIN(t)
y = COS(t)
x = sint * SIN(rota)
z = sint * COS(rota)
lat = ASIN(z) * !RADEG
lon = ATAN(x,y) * !RADEG + lon0
lon = lon + (lon LT -180.) * 360.
lon = lon - (lon GT 180.) * 360.
PLOTS, lon, lat, COLOR=color, THICK=2
end

;----------------------------------------------------------------------------
;
;    PURPOSE   Connect two points, in the form of [lon, lat] with
;              a great circle.
;
pro d_mapCir2P, $
       p1, $                    ; IN: first point
       p2                       ; IN: second point
compile_opt hidden

COMMON map_demo_com, projs, iproj, map_window, $
  lat0, lon0, rot0, do_elev, do_cont, do_avhrr, cir , drawable, lat_slider, $
  lon_slider, sat_params, sat_base, rot_slider, $
  city_pos, elev_data, avhrr_data, avhrr_colors, elev_colors, last_p, iso, $
  all_cities, scale, interpolation, do_rivers, $
  do_political, MenuButtons, MenuItems, ElevColor, $
  sText, city_base, scale_txt, groupBase, SavedColors, MousePress, $
  record_to_filename, $
  new_shapefile, oShapefile, shapeinfo_base, $
  pEnts, pFilenames, pFilepaths, current_ent_indx, $
  pShapefiles, wEntList


r_earth = 6371.007              ; Constants: Mean radius of earth, KM
km_mile = 0.621                 ; Km per mile

p1r = p1 * !dtor                ;To radians
p2r = p2 * !dtor

twopi = 2 * !pi
dlon = twopi + p2r[0] - p1r[0]
while (dlon GT !pi) do dlon = dlon - twopi ;to -pi to +pi

;         Compute the Great Circle Distance (in KM).
cosd = SIN(p1r[1])*SIN(p2r[1]) + COS(p1r[1])*COS(p2r[1])*COS(dlon)
dst = r_earth * ACOS(cosd)

;  Transform the spherical coordinates (long.  lat.) to cartesian (x, y, z).
lon = [p1r[0], p2r[0]]
lat = [p1r[1], p2r[1]]
x = COS(lat) * SIN(lon)
y = COS(lat)* COS(lon)
z = SIN(lat)

;  Compute the Plane containing center of earth and the points.
a = z[0] * y[1] - y[0] * z[1]
b = z[1] * x[0] - x[1] * z[0]   ; aX + bY = Z

elon0 = -ATAN(b/a)              ;  Compute the equatorial crossing location.
rot = ATAN(tan(lat[1]) / SIN(lon[1] - elon0))
rot = 90 - rot * !radeg

cir.lon0 = !RADEG * elon0
cir.rot = rot

str1 = STRING(dst, dst*km_mile, $
              FORMAT="('Distance: ',i5,'km, ', i5, 'mi')")
str2 = STRING(cir.rot, cir.lon0, $
              FORMAT="('Incl.: ',f6.1, ', Eq. cross.: ',F5.1)")
demo_putTips, 0, [str1, str2], [10,11], NOSTATE=sText

cir.color = cir.color+1

if (cir.color GE 10) then cir.color = 4 ;use color indices 4 to 9 for gt circl
d_mapDrawCirc, cir.rot, cir.lon0, cir.color ;  Draw the great circle
PLOTS, p1[0], p1[1], psym=5 ; and mark the points.
PLOTS, p2[0], p2[1], psym=5

end

;----------------------------------------------------------------------------
;
;    PURPOSE Mark the Ith city and return [lon, lat]
;
function d_mapCityMark, $
             i, $               ; IN: City index
             COLOR=color        ; IN: Color index
compile_opt hidden

COMMON map_demo_com

lon = city_pos.pos[1,i]
lat = city_pos.pos[0,i]

p = CONVERT_COORD(lon, lat, /DATA, /TO_DEVICE)

if (FINITE(p[0]) EQ 0) then RETURN, p

PLOTS, p[0], p[1], /DEVICE, PSYM=4, NOCLIP=0

if (N_ELEMENTS(color) EQ 0) then COLOR=1

XYOUTS, p[0], p[1]- 3*!D.Y_CH_SIZE/4, $
  /DEVICE, city_pos.names[i], $
  NOCLIP=0, ALIGNMENT=0.5, COLOR=color

RETURN, [lon, lat]
end
;----------------------------------------------------------------------------
pro d_mapPlotEnt, ent, color=color
compile_opt hidden

case 1 of
    ent.shape_type eq  5 or $   ; Polygon
    ent.shape_type eq 15 or $   ; PolygonZ (ignoring Z)
    ent.shape_type eq 25: begin ; PolygonM (ignoring M)
        if(ptr_valid(ent.parts) ne 0)then begin
            cuts = [*ent.parts, ent.n_vertices]

            for j=0, ent.n_parts-1 do  $
               polyfill, $
                    (*ent.vertices)[0,cuts[j]:cuts[j+1]-1], $
                    (*ent.vertices)[1,cuts[j]:cuts[j+1]-1], $
                    color=10
        endif else $
            polyfill, $
                (*ent.vertices)[0,*], $
                (*ent.vertices)[1,*], $
                color=10
        if(ptr_valid(ent.parts) ne 0)then begin
            cuts = [*ent.parts, ent.n_vertices]

            for j=0, ent.n_parts-1 do  $
               plots, $
                    (*ent.vertices)[0,cuts[j]:cuts[j+1]-1], $
                    (*ent.vertices)[1,cuts[j]:cuts[j+1]-1], $
                    color=color
        endif else $
            plots, $
                (*ent.vertices)[0,*], $
                (*ent.vertices)[1,*], $
                color=color
    endcase
    ent.shape_type eq  3 or $   ; PolyLine
    ent.shape_type eq 13 or $   ; PolyLineZ (ignoring Z)
    ent.shape_type eq 23: begin ; PolyLineM (ignoring M)
        if(ptr_valid(ent.parts) ne 0)then begin
            cuts = [*ent.parts, ent.n_vertices]

            for j=0, ent.n_parts-1 do begin
               plots, $
                    (*ent.vertices)[0,cuts[j]:cuts[j+1]-1], $
                    (*ent.vertices)[1,cuts[j]:cuts[j+1]-1], $
                    color=color
            endfor
        endif else $
            plots, $
                (*ent.vertices)[0,*], $
                (*ent.vertices)[1,*], $
                color=color
    endcase
    ent.shape_type eq  1 or $   ; Point
    ent.shape_type eq 11 or $   ; PointZ (ignoring Z)
    ent.shape_type eq 21 or $   ; PointM (ignoring M)
    ent.shape_type eq  8 or $   ; MultiPoint
    ent.shape_type eq 18 or $   ; MultiPointZ (ignoring Z)
    ent.shape_type eq 28: begin ; MultiPointM (ignoring M)
        plots, $
            ent.bounds[0], $
            ent.bounds[1], $
            psym = 3, $
            color=color
    endcase
    else: print, 'type not handled.'
endcase
end
;----------------------------------------------------------------------------
;
;    PURPOSE  Draw the map
;
pro d_mapDraw
compile_opt hidden

COMMON map_demo_com

WSET, map_window

lat1 = lat0                     ;  Take care of special cases:
rot1 = rot0
scale1 = scale
map_proj_info, iproj, CONIC=is_conic ;Conic projection?

; Projection specific restrictions -----------------------
if is_conic then begin
    if (scale1 EQ 0) then scale1 = 50e6 ;  force default scaling.
    scale1 = scale1 < 100e6
    lat1 = lat1 < 60 > (-60)    ;  Stay away from the poles.
    minlat = 20
    if (ABS(lat1) LT minlat) then lat1 = ([minlat, -minlat])[lat1 LT 0]
    rot1 = 0.0
endif

if (projs[iproj] EQ 'GoodesHomolosine') then begin ;Rot & CenterLat must be 0
    rot1 = 0.
    lat1 = 0.
endif

if (projs[iproj] EQ 'TransverseMercator') then begin
    if (scale1 EQ 0) then scale1 = 50e6 ;  Set default scaling.
    scale1 = scale1 < 100e6     ;maximum scale
endif

if (lat1 NE lat0) then $        ;Update slider if we fudged things
  WIDGET_CONTROL, lat_slider, SET_VALUE=lat1

if (rot0 NE rot1) then $        ; Force rotation?
  WIDGET_CONTROL, rot_slider, SET_VALUE=rot1

lat0 = lat1                     ;Reset lat and rotation?
rot0 = rot1

t0 = systime(1)                 ;  Get the starting time.

if new_shapefile then begin
    entities = oShapeFile->GetEntity(/ALL)
    limit = [ $
        min(entities.bounds[1]), $
        min(entities.bounds[0]), $
        max(entities.bounds[5]), $
        max(entities.bounds[4]) $
        ]

    map_set, mean(limit[[0,2]]), d_mapLongitudeMid(limit[[1,3]]), $
        LIMIT=limit, $
        PROJ=iproj, GRID=0, COLOR=1, $
        sat_p=sat_params, $
        ISOTROPIC=iso

    ; Set widgets to reflect our new limit.
    map_proj_info, $
        /CURRENT, $
        SCALE=meters, $
        LL_LIMITS=ll_limits

    window_size = !d.x_size / !d.x_px_cm / 100. ;width of window in meters
    scale = !x.s[1] * window_size
    scale = meters / scale
    WIDGET_CONTROL, scale_txt, SET_VALUE=STRTRIM(scale / 1.0e6, 2)

    lat0 = ll_limits[0] + (ll_limits[2] - ll_limits[0]) / 2.
    lon0 = ll_limits[1] + (ll_limits[3] - ll_limits[1]) / 2.

    WIDGET_CONTROL, lat_slider, SET_VALUE=lat0
    WIDGET_CONTROL, lon_slider, SET_VALUE=lon0

    new_shapefile = 0b
    oShapefile->DestroyEntity, entities
    scale1 = scale
    lat1 = lat0
endif

map_set, lat1, lon0, rot0, $    ;Draw basic projection
    PROJ = iproj, GRID=0, COLOR=1, $
    sat_p = sat_params, $
    ISOTROPIC=iso, scale=scale1


                                ; print, !map.ll_box, format='(4f10.2)'

wWarningBase = 0

; Load elevations ****
if ( (do_elev NE 0) AND (N_ELEMENTS(elev_data) LE 2) ) then begin ;  1st time?
    wWarningBase = WIDGET_BASE(TITLE='Warning', /COLUMN)
    wWarning1Label = WIDGET_LABEL(wWarningBase, $
                                  VALUE='Warping elevation data to maps can')
    wWarning2Label = WIDGET_LABEL(wWarningBase, $
                                  VALUE='require a significant amount of time.')

    WIDGET_CONTROL, wWarningBase, /REALIZE

    file = demo_filepath('worldelv.dat', $
                    SUBDIR=['examples','data'])

    OPENR,unit, /GET_LUN, file, ERROR=i

    if (i LT 0) then begin
        a = DIALOG_MESSAGE(['Elevation data file', $
                            file, 'not found'], /ERROR)
        do_elev = 0             ;Still have no elevations
    endif else begin            ;we've found the file
        elev_data = BYTARR(360, 360, /NOZERO)
        READU, unit, elev_data
        CLOSE, unit
        FREE_LUN, unit
        elev_data = bytscl(elev_data, TOP=!d.table_size - ElevColor - 1, $
                           MAX=255, MIN=0) + $
          byte(ElevColor) > byte(ElevColor + 1b)
    endelse
endif                           ;  of load elevation data

t1 = systime(1)

;  Draw the elevation data.

if ((do_elev NE 0) AND (N_ELEMENTS(elev_data) GT 2)) then begin
    nlon = ([0,180, 360, 360])[do_elev] ;Low, Medium and High resolutions
    nlat = ([0, 90, 180, 180])[do_elev]

    lat_del = 180 / nlat
    lon_del = 360 / nlon
    lat_0 = -90. & lat1 = 90. - lat_del
    lon_0 = 0. & lon_1 = 360. - lon_del
    tmp = REBIN(elev_data, nlon, nlat,/SAMPLE)

    if (!map.ll_box[0] NE !map.ll_box[2]) then begin ;  Clip the latitude.
        i0 = floor((!map.ll_box[0]+90) / lat_del) ;First bin
        i1 = ceil((!map.ll_box[2]+90) / lat_del)  < (nlat -1) ;Last bin
        tmp = tmp[*, i0:i1 ]
        lat_0 = lat_del * i0 -90.
        lat1 = lat_del * i1 -90.
    endif

    if (!map.ll_box[1] NE !map.ll_box[3]) then begin ;  Clip the longitude.
        i0 = floor(!map.ll_box[1] / lon_del) ;First bin
        i1 = ceil( !map.ll_box[3] / lon_del) ;Last bin
        j0 = i0
        if (j0 LT 0) then j0 = j0 + nlon
        if (j0 NE 0) then tmp = shift(tmp, -j0, 0)
        n = i1 - i0 + 1
        if (n LT nlon) then tmp = tmp[0:n-1, *]
        lon_0 = i0 * lon_del
        lon_1 = i1 * lon_del
    endif

    if (interpolation) then begin
        TV, MAP_PATCH(tmp, LON0=lon_0, LON1=lon_1, $ ;Object interpolation
                      LAT0=lat_0, LAT1=lat1, $
                      XSTART=x0, YSTART=y0), x0, y0
    endif else begin
        TV, MAP_IMAGE(tmp, $    ;Image interpolation
                      LONMIN=lon_0, LONMAX=lon_1, LATMIN=lat_0, LATMAX=lat1, $
                      /BILINEAR, COMPRESS= ([0,4, 4,2,1])[do_elev], x0, y0), $
          x0, y0
    endelse
endif                           ;   of  Do_elev

if do_avhrr and n_elements(avhrr_data) le 1 then begin ;Init AVHRR data
    file = demo_filepath('avhrr.png', SUBDIR=['examples','data'])
    ;file = demo_filepath('world_2004x1002.png', SUBDIR=['examples','data'])
    catch, i
    if i eq 0 then avhrr_data = read_png(file, rr, gg, bb)
    ;avhrr_data = congrid(avhrr_dat, 1080, 540)
    avhrr_data = SHIFT(avhrr_data, 1, -1) ; fudge for sloppy image.
    catch, /cancel
    if n_elements(avhrr_data) gt 1 then begin ;Process avhrr data
        nc = (!d.table_size < 256 > 16) - ElevColor ;# of colors we use
;        cmin = 20               ;Contrast enhancing the AVHRR colors
;        cmax = 220
;        rr = BYTSCL(rr, MIN=cmin, MAX=cmax)
;        gg = BYTSCL(gg, MIN=cmin, MAX=cmax)
;        bb = BYTSCL(bb, MIN=cmin, MAX=cmax)
        tbl = COLOR_QUAN(rr,gg,bb, COLORS=nc, rr,gg,bb)
        avhrr_data = tbl[avhrr_data] + byte(ElevColor)
        tvlct, rr, gg, bb, ElevColor
        tvlct, rr, gg, bb, /GET
        avhrr_colors = [[rr],[gg],[bb]] ;Save AVHRR colors
    endif else begin
        a = DIALOG_MESSAGE(['AVHRR data file', $
                            file, 'not found'], /ERROR)
        do_avhrr = 0
    endelse
endif

if do_avhrr then begin          ;Show AVHRR data
    s = size(avhrr_data)
    lon_scale = (s[1]-1.0) / 360. ;Scale between pixels and lon/lat
    lat_scale = (s[2]-1.0) / 180.
    xnorm = findgen(!d.x_size) / !d.x_size ;A row of data
    out = bytarr(!d.x_size, !d.y_size) ;Result
    for iy=0, !d.y_size-1 do begin ;Form each line of result
        p = convert_coord(xnorm, iy / float(!d.y_size), /NORM, /TO_DATA)
        lon = reform(p[0,*])
        good = where(finite(lon), count)
        if count gt 0 then begin
            lat = reform(p[1,*])
; You might ask, why don't we interpolate, rather than nearest
; neighbor sample?  Things would sure look better.  It's because the
; palette is pseudo color and discrete, and we can't interpolate in
; color index space.  If we had a 24 bit display, we could and should
; interpolate separately each color primary.
                                ;The 0.5 below is for rounding
            out[good, iy] = avhrr_data[(lon[good]+180.5)*lon_scale, $
                                       (lat[good]+90)*lat_scale]
        endif
    endfor
    tv, out
endif

if (wWarningBase NE 0) then WIDGET_CONTROL, wWarningBase, /DESTROY

t1 = systime(1) - t1            ;  Get the executon time.

if (do_elev NE 0) then $        ;  Don't do both continents and elevation.
  i = do_cont < 1 $
else i = do_cont

map_horizon, COLOR=([1,1,4])[i], FILL=i EQ 2 ; Blue horizon

;if (i EQ 1)  or do_avhrr then map_continents, COLOR=1 ;Line continents
if (i EQ 1) then map_continents, COLOR=1 ;Line continents
if (i EQ 2) then map_continents, COLOR=5, /fill ;Filled continents

map_grid, latdel = 10, londel = 10, COLOR=3

if (do_rivers) then map_continents, /RIVER, COLOR=4
if (do_political) then map_continents, /COUNTRIES, /USA, COLOR=1
if ((do_cont GE 2) OR (do_elev NE 0)) then CCOLOR=0 else CCOLOR=1
if (all_cities) then for i=0, N_ELEMENTS(city_pos.names)-1 do $
  p = d_mapCityMark(i, COLOR=ccolor)

if (do_elev NE 0) then  begin   ;Execution time
    t = t1 + systime(1)-t0
endif else begin
    t = systime(1)-t0
endelse

; Draw shapefiles.
if PTR_VALID(pEnts) then begin
    for i=n_elements(*pEnts)-1,0,-1 do begin
        d_mapPlotEnt, (*pEnts)[i], color=7
    end
    if current_ent_indx gt -1 then begin
        d_mapPlotEnt, (*pEnts)[current_ent_indx], color=2
    end
endif ; ptr_valid


estr='Time =' + STRING(t, FORMAT='(F6.1)')+ ' seconds' ;Display exec time
demo_putTips, 0, 'selecto', 10, /LABEL, NOSTATE=sText
demo_putTips, 0, estr, 11, NOSTATE=sText
end
;----------------------------------------------------------------------------
pro d_mapShapeInfo_event, event
compile_opt hidden

common map_demo_com
WIDGET_CONTROL, event.top, GET_UVALUE=pState
case event.id of
    (*pState).wEntList: begin
        if current_ent_indx gt -1 then $
            d_mapPlotEnt, (*pEnts)[current_ent_indx], color=7
        current_ent_indx = event.index
        ent = (*pEnts)[current_ent_indx]
        d_mapPlotEnt, ent, color=2
        ((*pShapefiles)[current_ent_indx])->GetProperty, $
            ATTRIBUTE_NAMES=attribute_names
        attribute_vals = STRARR(N_ELEMENTS(attribute_names))
        for i=0,N_ELEMENTS(attribute_vals)-1 do begin
            attribute_vals[i] = STRTRIM((*ent.attributes).(i), 2)
        end
        WIDGET_CONTROL, (*pState).wPropertyTable, SET_VALUE=[ $
            TRANSPOSE(attribute_names), $
            TRANSPOSE(attribute_vals) $
            ]
    end
    else:
endcase
end
;----------------------------------------------------------------------------
pro d_mapShapeInfo_cleanup, wID
compile_opt hidden

WIDGET_CONTROL, wID, GET_UVALUE=pState
ptr_free, pState
end
;----------------------------------------------------------------------------
;
;  PURPOSE Main event handler.
;
pro d_mapEvent,  $
       event                    ; IN: event structure
compile_opt hidden

COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
COMMON map_demo_com

demo_record, event, filename=record_to_filename

if (TAG_NAMES(event, /STRUCTURE_NAME) EQ $ ;Was application closed?
    'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, event.top, /DESTROY
    RETURN
endif

WIDGET_CONTROL, event.id, GET_UVALUE=eventval
s = SIZE(eventval)
WSET, map_window

if (event.id EQ drawable) then begin ;Mouse event in drawable
                                ;  Get inverse transform (lat, lon):
    p = CONVERT_COORD(event.x, event.y, /DEVICE, /TO_DATA)

    if (FINITE(p[0]) EQ 0) then begin ;IDL returns NaN for unmappable pnts
        off_map:
        demo_putTips, 0, '<Off map>', 12, NOSTATE=sText
        RETURN
    endif

    if (event.press NE 0) then begin ;  Save location of button press events
        MousePress = [event.x, event.y]
        goto, set_ll
    endif

    if (event.release EQ 0) then begin ;If release is 0, its a motion event
        sTmp = STRING(p[0], p[1], FORMAT= "('Lon: ',f7.1, ', Lat: ', f6.1)")
        demo_putTips, 0, sTmp, 12, NOSTATE=sText
        RETURN
    endif

; If we get here, its a drag event. Put a hysteresis on the drag so that
;  it's not mistaken for a smudged click.
    if (ABS(event.x-MousePress[0]) + $
        ABS(event.y NE MousePress[1]) GE 4) then begin
        q = CONVERT_COORD(MousePress, /DEVICE, /TO_DATA)
        if (FINITE(q[0]) EQ 0) then return
        lat0 = lat0 + (q[1]-p[1]) ;Get new center of projection
        if (lat0 GT 180.) then lat0 = lat0 - 360.
        if (lat0 LT -180.) then lat0 = lat0 + 360.
        if (lat0 GT 90.) then lat0 = 180.-lat0
        if (lat0 LT -90.) then lat0 = -180.-lat0

        lon0 = lon0 + (q[0]-p[0]) + 360.

        while (lon0 GT 180) do lon0 = lon0 - 360.
        while (lon0 LT -180) do lon0 = lon0 + 360.

        WIDGET_CONTROL, lat_slider, SET_VALUE=lat0
        WIDGET_CONTROL, lon_slider, SET_VALUE=lon0
        goto, draw_it
    endif                       ;  of Drag.

    RETURN

    set_ll:
    sTmp = STRING(p[0], p[1], FORMAT= "('Lon: ',f7.1, ', Lat: ', f6.1)")
    demo_putTips, 0, sTmp, 12, NOSTATE=sText

    if (cir.llflag EQ 2) then begin ;Marked 2nd point for gt circle?
        d_mapCir2P, cir.ll, p[0:1]
        cir.llflag = 0
    endif

    if (cir.llflag EQ 1) then begin ;Marked 1st pnt for gt circle?
        demo_putTips, 0, ['','Mark second point.'], [10,11], NOSTATE=sText
        cir.ll = p[0:1]
        cir.llflag = 2
    endif

    RETURN

endif                           ;Cursor hit on map

if (STRMID(eventval, 0, 1) EQ '|') then begin ;  If '|' in value, its a menu
    ev = STRMID(eventval, 1, 100) ; get event name by stripping off the '|'

    if (ev EQ 'File|Quit') then begin
        WIDGET_CONTROL, event.top, /DESTROY
        RETURN
    endif else if (ev EQ 'Edit|Reset') then begin ;Reset to initial values
        lat0 = 0.
        lon0 = 0.
        rot0 = 0.
        WIDGET_CONTROL, LAT_SLIDER, SET_VALUE=lat0
        WIDGET_CONTROL, LON_SLIDER, SET_VALUE=lon0
        WIDGET_CONTROL, ROT_SLIDER, SET_VALUE=rot0
    endif else if (ev EQ 'About|About Maps') then begin
        ONLINE_HELP, 'd_map', $
           book=demo_filepath("idldemo.adp", $
                   SUBDIR=['examples','demo','demohelp']), $
                   /FULL_PATH
        RETURN

    endif else if (STRPOS(ev, 'Continents') GT 0) then begin
                                ;  Toggle the continents/elevation choices..
        i = d_mapMenuChoice(eventval, MenuItems, MenuButtons)
        do_cont = i le 2 ? i : 0
        do_elev = i lt 6 ? i-2 > 0 : 0
        do_avhrr = i eq 6
        if do_elev then tvlct, elev_colors
        if do_avhrr and n_elements(avhrr_colors) gt 1 then tvlct, avhrr_colors
    endif else if (STRPOS(ev, 'Interpolation') GT 0) then begin
                                ;  image and object interpolation choices
        interpolation = d_mapMenuChoice(eventval, MenuItems, MenuButtons)
        if (do_elev EQ 0) then RETURN ;  don't redraw unless elevations are on.
    endif else if STRPOS(ev, 'Rivers') GT 0 then begin
        do_rivers = d_mapMenuToggleState(event.id) ;New river state
    endif else if STRPOS(ev, 'Isotropy') GT 0 then begin ;New isotropic setting
        iso = d_mapMenuToggleState(event.id)
    endif else if STRPOS(ev, 'Boundaries') GT 0 then begin
        do_political = d_mapMenuToggleState(event.id) ;New political setting
    endif else if STRPOS(ev, 'View|Cities') EQ 0 then begin
        all_cities = d_mapMenuToggleState(event.id) ;New city setting
    endif else if (ev EQ 'Cities|Find...') then begin
        if (WIDGET_INFO(city_base, /VALID) EQ 0) then begin
                                ;  Create the city finder widget.
            city_base = WIDGET_BASE(Title='Cities', /COLUMN, $
                                    EVENT_PRO='d_mapEvent', $
                                    GROUP_LEADER=event.top)

            wCityList = WIDGET_LIST(city_base, VALUE=city_pos.names, $
                                    YSIZE = 12, UVALUE="CITY_SELECT")

            wDismissButton = WIDGET_BUTTON(city_base, $
                                           VALUE='Dismiss', /NO_REL, $
                                           UVALUE='CITY_DISMISS')

            WIDGET_CONTROL, city_base, /REALIZE
            XMANAGER, "map_cities", city_base, $
              EVENT_HANDLER="d_mapEvent",$
              GROUP_LEADER = event.top
        endif $
        else WIDGET_CONTROL, city_base, /MAP ;Already mapped, just show it
        RETURN

    endif else if (ev EQ 'Cities|Mark All') then begin ;Mark all cities
        if ((do_cont GE 2) or (do_elev NE 0)) then begin
            CCOLOR = 0
        endif else begin
            CCOLOR = 1
        endelse

        for i = 0, N_ELEMENTS(city_pos.names)-1 do begin
            p = d_mapCityMark(i, COLOR=ccolor)
        endfor
        return

    endif else if (ev EQ 'Great Circles|Draw') then begin ;Draw great circle
        cir.color = cir.color+1
        if (cir.color GE 16) then cir.color = 4
        d_mapDrawCirc, cir.rot, cir.lon0, cir.color
        RETURN

    endif else if (ev EQ 'Great Circles|Connect Two Points') then begin
        cir.llflag = 1          ;Expecting first point
        demo_putTips, 0, ['','Mark first point.'], [10,11], NOSTATE=sText
        RETURN

    endif else if (ev EQ 'Shapefiles|Import Shapefile...') then begin
        filename = DIALOG_PICKFILE( $
            FILTER='*.shp', $
            /FIX_FILTER, $
            GROUP=event.top, $
            /MUST_EXIST, $
            PATH=DEMO_FILEPATH('', SUBDIR=['examples', 'data']), $
            GET_PATH=path, $
            /READ $
            )

        if filename ne '' then begin
            oShapefile = OBJ_NEW('IDLffShape', filename)
            if not obj_valid(oShapefile) then begin
                void = dialog_message( $
                    'Unable to create IDLffShape from ' + filename $
                    )
                print, !error_state
                RETURN
            endif
            oShapefile->GetProperty, N_ENTITIES=n_entities
            if n_entities eq 0 then $
                RETURN

            if not PTR_VALID(pEnts) then begin
                pEnts = PTR_NEW(/ALLOCATE_HEAP)
                pFilenames = PTR_NEW(/ALLOCATE_HEAP)
                pFilepaths = PTR_NEW(/ALLOCATE_HEAP)
                pShapeFiles = PTR_NEW(/ALLOCATE_HEAP)
            end

            if N_ELEMENTS(*pEnts) eq 0 then begin
                *pEnts = oShapefile->GetEntity(/ALL, /ATTRIBUTES)
                *pFilenames = REPLICATE(d_mapStripPath(filename), n_entities)
                *pFilepaths = REPLICATE(path, n_entities)
                *pShapefiles = REPLICATE(oShapefile, n_entities)
            endif else begin
                *pEnts = [oShapefile->GetEntity(/ALL, /ATTRIBUTES), *pEnts]
                *pFilenames = [ $
                    REPLICATE(d_mapStripPath(filename), n_entities), $
                    *pFilenames $
                    ]
                *pFilepaths = [REPLICATE(path, n_entities), *pFilepaths]
                *pShapefiles = [ $
                    REPLICATE(oShapefile, n_entities), $
                    *pShapefiles $
                    ]
            endelse

            new_shapefile = 1b
            WIDGET_CONTROL, $
                DEMO_FIND_WID('d_map:|Shapefiles|Shape Information...'), $
                /SENSITIVE

            if current_ent_indx ne -1 then $
                current_ent_indx = current_ent_indx + n_entities

            if N_ELEMENTS(wEntList) gt 0 then $
                if WIDGET_INFO(wEntList, /VALID_ID) then begin
                    WIDGET_CONTROL, wEntList, SET_VALUE= $
                        *pFilenames + ' - ' + STRTRIM((*pEnts).ishape, 2)
                endif


        endif

    endif else if (ev EQ 'Shapefiles|Shape Information...') then begin
        if XREGISTERED('d_mapShapeInfo') then $
            RETURN

        tlb = WIDGET_BASE( $
            Title='Shapefile Information', $
            /ROW, $
            GROUP_LEADER=event.top $
            )
        wColumnBase = WIDGET_BASE(tlb, /COLUMN, /FRAME)
        wEntList = WIDGET_LIST(wColumnBase, ysize=9)
        if PTR_VALID(pEnts) then begin
            if N_ELEMENTS(*pEnts) gt 0 then begin
                WIDGET_CONTROL, wEntList, SET_VALUE= $
                    *pFilenames + ' - ' + STRTRIM((*pEnts).ishape, 2)
            endif
        endif
        wRowBase = WIDGET_BASE(wColumnBase, /ROW, /GRID, /ALIGN_CENTER)

        wPropertyTable = WIDGET_TABLE( $
            tlb, $
            VALUE=strarr(2, 50), $
            YSIZE=6, $
            COLUMN_LABELS=['Attribute', 'Value'], $
            /RESIZEABLE_COLUMNS $
            )
        WIDGET_CONTROL, wPropertyTable, COLUMN_WIDTHS=[125, 125]

        WIDGET_CONTROL, tlb, MAP=0
        WIDGET_CONTROL, /REALIZE, tlb, SET_UVALUE=PTR_NEW({ $
            wEntList: wEntList, $
            wPropertyTable: wPropertyTable $
            })
        tlb_geom = WIDGET_INFO(tlb, /GEOMETRY)
        leader_geom = WIDGET_INFO(event.top, /GEOMETRY)
        DEVICE, GET_SCREEN_SIZE=screen_size

        y = leader_geom.scr_ysize + leader_geom.yoffset
        y = y < (screen_size[1] - 30 - tlb_geom.scr_ysize)
        y = y > 0

        WIDGET_CONTROL, tlb, TLB_SET_YOFFSET=y
        WIDGET_CONTROL, tlb, MAP=1

        XMANAGER, 'd_mapShapeInfo', tlb, /NO_BLOC, $
            CLEANUP='d_mapShapeInfo_cleanup'

    endif else print,'Unknown Menu Item: ', ev

endif else case eventval of     ;Must be a slider event
    "LAT_SLIDER":   lat0 = event.value
    "LON_SLIDER":   lon0 = event.value
    "ROT_SLIDER":   rot0 = event.value
    "SALT"      :   sat_params[0] = 1.0 + event.value / 6371.; Sat altitude
    "SALPHA"    :   sat_params[1] = event.value
    "SBETA"     :   sat_params[2] = event.value
    "CITY_DISMISS": begin
        WIDGET_CONTROL, city_base, MAP=0
        RETURN
    endcase

    "CITY_SELECT": begin        ;  Draw the selected city.
        p = d_mapCityMark(event.index) ;The item selected
        if (FINITE(p[0])) then goto, set_ll
        goto, off_map
    endcase

    "SCALE": begin              ;New map scale
        WIDGET_CONTROL, event.id, GET_VALUE=v
        scale = FLOAT(v[0])
        minmax = [1,400]
        if (scale NE 0) and $
          (scale LT minmax[0] or scale GT minmax[1]) then begin
            scale = scale > minmax[0] < minmax[1]
            WIDGET_CONTROL, event.id, SET_VALUE=STRTRIM(scale,2)
        endif
        scale = scale * 1.0e6   ;To millions
    endcase

    "PROJ": begin               ;New projection
        iproj = event.index+1   ;New projection number
        if (last_p EQ iproj) then RETURN ; Nothing to do?
        last_p = iproj

        if (projs[iproj] EQ "Satellite") then begin
                                ;  Case of a satellite projection, open
                                ;  an new window that let select its parameters.
            slide_wid = 250
            sat_base = LONARR(5)
            sat_base[0] = $
              WIDGET_BASE(title='Satellite Projection Parameters', /COLUMN)

            sat_base[1] = $
              WIDGET_SLIDER(sat_base[0], XSIZE=slide_wid, $
                            MINIMUM=100, MAXIMUM=15000, $
                            VALUE=(sat_params[0]-1) * 6371., $
                            TITLE='Altitude (Km)', $
                            UVALUE="SALT")

            sat_base[2] = $
              WIDGET_SLIDER(sat_base[0], XSIZE=slide_wid, $
                            MINIMUM=-89, MAXIMUM=89, $
                            VALUE=sat_params[1], TITLE='Alpha (up)',$
                            UVALUE="SALPHA")

            sat_base[3] = $
              WIDGET_SLIDER(sat_base[0], XSIZE=slide_wid, $
                            MINIMUM=-180, MAXIMUM=180, $
                            VALUE=sat_params[2], $
                            TITLE='Beta (rotation)', $
                            UVALUE="SBETA")

            WIDGET_CONTROL, sat_base[0], /REALIZE

            XMANAGER, "map_demo_satellite", sat_base[0], $
              EVENT_HANDLER="d_mapEvent", $
              GROUP_LEADER=event.top
            RETURN

        endif else begin        ;Not a satellite projection
            if (sat_base[0] NE 0) then begin ;  Kill satellite base if active.
                if (WIDGET_INFO(sat_base[0],/valid)) then $
                  WIDGET_CONTROL, sat_base[0],/DESTROY
                sat_base[0] = 0
            endif
        endelse                 ;Not satellite
    endcase                     ; of Projection

    else: MESSAGE, "Event user value not found " + eventval

endcase

draw_it:  WIDGET_CONTROL, event.top, /HOURGLASS
d_mapDraw                   ;********** Draw the map....
end

;-----------------------------------------------------------------
;
;    PURPOSE : cleanup procedure. restore colortable, destroy objects.
;
pro d_mapCleanup, $
       wTopBase                 ; IN: Top level base identifier
compile_opt hidden

COMMON map_demo_com

TVLCT, SavedColors              ; Restore the color table.
if (WIDGET_INFO(groupBase, /VALID_ID)) then $
  WIDGET_CONTROL, groupBase, /MAP
elev_data = 0                   ;  Free up some memory.
avhrr_data = 0
avhrr_colors = 0
elev_colors = 0

if PTR_VALID(pShapefiles) then begin
    (*pShapefiles)[0]->DestroyEntity, *pEnts
    obj_destroy, *pShapefiles
    ptr_free, pShapefiles
end

if PTR_VALID(pEnts) then $
    ptr_free, pEnts

if PTR_VALID(pFilenames) then $
    ptr_free, pFilenames

if PTR_VALID(pFilepaths) then $
    ptr_free, pFilepaths

end                             ;  of d_mapCleanup

;----------------------------------------------------------------------------
;
;  PURPOSE Main map procedure.
;
pro d_map, $
       Image, $                 ; IN: (opt) image warped around the
                                ; projection that should be properly
                                ; scaled.
       GROUP=GROUP, $           ; IN: (opt) Group leader identifier
       Xsize = Xsize, $         ; IN: (opt) X size of the viewing area.
       RECORD_TO_FILENAME=rec_to_filen, $
       APPTLB=appTlb            ; OUT: (opt) main procedure top level base ID

COMMON map_demo_com

                                ;  Make sure that only one instance is active.
if (XRegistered("d_map")) then RETURN


if N_ELEMENTS(group) then groupbase = group else groupbase = 0L

TVLCT, SavedColors, G, B, /GET ;  save the current color table
SavedColors = [[SavedColors],[G],[B]] ;  save in a (n,3) array

DEVICE, GET_SCREEN_SIZE = scrSize
drawbase = demo_startmes('Mapping Demo', GROUP=groupbase)

if (N_ELEMENTS(image) GT 1) then begin ;image to warp over data provided?
    elev_data = image > 16b     ; Bottom 16 colors are used for grids
endif

iproj = 2                       ; orthographic
last_p = -1
if (N_ELEMENTS(xsize) EQ 0) then begin ;  Size the viewing area to screen
    xsize = FIX(0.56 * scrSize[0])
endif

DEVICE, DECOMPOSED = 0          ;  Set to a 8 bits (256 colors) display.
list_ht = ([6,9])[xsize GE 400] ;  List widget height for small screens.

ysize = xsize * 4 / 5           ;  Initialize working variables.
sliderwidth = 200 < (xsize/3)
lat0 = 0
lon0 = 0
rot0 = 0
do_cont = 2                     ;Initial default = fill continents
do_elev = 0
do_avhrr = 0
do_rivers = 0
do_political = 0
iso = 1
all_cities = 0
scale = 0.0
interpolation = 0
city_base = 0L
elevColor = 10                  ;First color used for elevations
if not keyword_set(rec_to_filen) then $
    record_to_filename = '' $
else $
    record_to_filename = rec_to_filen ; Record events.
!p.multi=0

cir = { CIRCLE_PARAMS, $        ;Great circle object
        base : 0L, lon0 : 0.0, rot : 0.0, color : 4, $
        ll : [0., 0.], llflag : 0 }

sat_params = [ 1.2, 0, 0]       ;Salt, salpha, sbeta  = Initial satellite params

sat_base = LONARR(5)

map_demoBase = WIDGET_BASE(TITLE="Mapping", $ ;Main base, not mapped yet
                           MAP=0, $
                           /TLB_KILL_REQUEST_EVENTS, $
                           TLB_FRAME_ATTR=1, $
                           UNAME='d_map:tlb', $
                           MBAR=bar_base, /COLUMN, GROUP=groupbase)

MenuItems = ['1File', '2Quit', $
             '1Edit', '2Reset', $
             '1View', $
             '1Continents', '0None', '0Outlines', '4Fill', $
                 '0Low Res Elevations', '0Medium Res', '0High Res', $
                 '2AVHRR Data', $
             '1Interpolation', '4Image', '2Object', $
             '0Rivers (Off)', $
             '0Boundaries (Off)', $
             '0Cities (Off)', $
             '2Isotropy (On )', $
             '1Shapefiles', '0Import Shapefile...', '6Shape Information...', $
             '1Cities', '0Mark All', '2Find...', $
             '1Great Circles', '0Connect Two Points', '2Draw', $
             '1About', '2About Maps']

d_mapMenuCreate, MenuItems, MenuButtons, Bar_base ;  Create the menu bar.

if (N_ELEMENTS(projs) EQ 0) then begin ;  Define projection names.
    resolve_routine, 'map_set'  ;  Cause we call map_proj_info first.
    map_proj_info, PROJ_NAMES=projs
endif


wSubBase = WIDGET_BASE(map_demobase, /ROW) ;Create the column sub base.
l_base = WIDGET_BASE(wSubBase, /COLUMN) ;  Create the left side widgets.


wJunk = WIDGET_BASE(l_base, /COLUMN, /FRAME)
wProjLabel = WIDGET_LABEL(wJunk, VALUE='Projection')
p_list = WIDGET_LIST(wJunk, VALUE=projs[1:*], $ ;projection list
                     YSIZE=list_ht, UVALUE='PROJ', UNAME='d_map:proj')

lon_slider = WIDGET_SLIDER(l_base, XSIZE = sliderwidth, $
                           MINIMUM = -180, MAXIMUM = 180, VALUE=lon0, $
                           TITLE = 'Center Longitude', uvalue = "LON_SLIDER", $
                           UNAME='d_map:lon')
lat_slider = WIDGET_SLIDER(l_base, XSIZE = sliderwidth, $
                           MINIMUM = -90, MAXIMUM = 90, VALUE=lat0, $
                           TITLE = 'Center Latitude', uvalue = "LAT_SLIDER", $
                           UNAME='d_map:lat')
rot_slider = WIDGET_SLIDER(l_base, XSIZE = sliderwidth, $
                           MINIMUM = -90, MAXIMUM = 90, VALUE=rot0, $
                           TITLE = 'Rotation', uvalue = "ROT_SLIDER", $
                           UNAME='d_map:rot')
wJunk = WIDGET_BASE(l_base, /ROW)
wScale1Label = WIDGET_LABEL(wJunk, VALUE="Scale ")
scale_txt = WIDGET_TEXT(wJunk, XSIZE=10, YSIZE=1, $
                        VALUE='0.0', $
                        /EDITABLE, UVALUE="SCALE")
wScale2Label = WIDGET_LABEL(wJunk, VALUE="Million : 1")

if (N_ELEMENTS(city_pos) LE 0) then begin ;Input City data base if 1st time
    file = demo_filepath('cities.dat', $
                    SUBDIR=['examples','demo','demodata'])
    OPENR, unit, file, /GET_LUN, ERROR=i

    if (i LT 0) then begin
        a = DIALOG_MESSAGE(['City data file', file, 'not found'],/ERROR)
        i = 4
        city_names = STRARR(i)  ;Fake it
        city_pos = FLTARR(2,i)
    endif else begin
        i = (fstat(unit)).size/12 ;Approx number of cities
        city_names = STRARR(i)
        city_pos = FLTARR(2,i)
        i = 0
        x=0. & y=0. & z = ''

        while (NOT Eof(unit)) do begin
            READF,unit, x, y, z
            city_names[i] = z
            city_pos[0,i] = x   ;Latitude
            city_pos[1,i] = y
            i = i + 1
        endwhile
        CLOSE, unit
        FREE_LUN, unit

        city_pos = city_pos[*,0:i-1] ;correct for file being in degrees.minutes
        icity = FIX(city_pos)
        fcity = city_pos - FIX(city_pos) ;Decimal fractions
        city_pos = icity + (fcity * (100./60.)) ;  Convert minutes to 100ths.
    endelse

    city_pos = { CITY_POS, $
                 names : STRTRIM(city_names[0:i-1],2), $
                 pos : city_pos }
endif

r_base = WIDGET_BASE(wSubBase, /COLUMN) ;  Create the right side widgets.
                                ;
drawable = WIDGET_DRAW(r_base, XSIZE=xsize, YSIZE=ysize, $ ;  view area.
                       RETAIN=2, /BUTTON_EVENTS, /MOTION_EVENTS, $
                       UNAME='d_map:draw')

wStatusBase = WIDGET_BASE(map_demobase, MAP=0, /ROW) ;  Create tips texts.

WIDGET_CONTROL, map_demobase, /REALIZE, /HOURGLASS

appTlb = map_demobase           ;  Return top level base into APPTLB variable.

WIDGET_CONTROL, drawable, GET_VALUE=map_window ;  Get the window ID.

sText = demo_getTips(demo_filepath('map_demo.tip', $ ;  Get the tips.
                        SUBDIR=['examples','demo','demotext']), $
                     map_demobase, wStatusBase)

WIDGET_CONTROL, p_list, SET_LIST_SELECT=1

WSET, map_window
d_mapColorInit, ElevColor       ;  Load our color tables.
TVLCT, /GET, r_curr, g_curr, b_curr
elev_colors = [[r_curr], [g_curr], [b_curr]]

new_shapefile = 0b
current_ent_indx = -1
d_mapDraw                       ;  Draw the first map.

WIDGET_CONTROL, drawbase, /DESTROY ;  Destroy the startup window.
WIDGET_CONTROL, map_demoBase, MAP=1 ;  Map the top level base.
XMANAGER, "d_map", map_demobase, $ ;  Register with XMANAGER.
  EVENT_HANDLER='d_mapEvent', $
  CLEANUP='d_mapCleanup', $
  /NO_BLOCK

WIDGET_CONTROL, map_demobase, HOURGLASS=0
end                             ;   of main procedure d_map
