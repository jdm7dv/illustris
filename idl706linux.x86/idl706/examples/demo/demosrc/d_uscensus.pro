; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_uscensus.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       D_Uscensus.pro
;
;  CALLING SEQUENCE: D_Uscensus [, GROUP_LEADER = GROUP_LEADER $]
;                               [, /ANIMATE_STATES $]
;                               [, /BACKDROP $]
;                               [, /DEPTH]
;
;  PURPOSE:
;       Demonstrate the definition and use of object classes.  Each of the
;       50 U.S.A. states in this program is an instance of a class defined
;       by this program.
;
;  KEYWORD PARAMETERS:
;       GROUP_LEADER can be set to the ID of a parent widget when
;       this routine is called as a compound widget.
;
;       APPTLB returns the application top level base, mainly for
;       use in the IDL Demo.
;
;       /ANIMATE_STATES when set allows States to be individually
;       rendered when a new year of data is displayed.  By default
;       all States are scaled before the view is rendered.  This
;       option is recommended only on machines with good rendering
;       speed, such as a Pentium Pro 200 or Sun Ultra.
;
;       /BACKDROP when set causes a backdrop image to be drawn behind
;       the USA map.  It's a good example of view object instancing.
;       This is recommended only for machines with TrueColor displays
;       and good rendering speed.  By default, the backdrop image is
;       not displayed.
;
;       /DEPTH turns on depth cueing in the view.  By default, depth
;       cueing is not performed.
;
;  MAJOR TOPICS: Visualization, Analysis, Demo, Language
;
;  CATEGORY:
;       IDL Demo System
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  MODIFICATION HISTORY:
;       4/97,       JLP       - Initial version for IDL 5.0.
;       1997-1999   JLP & PCS - Revisions.
;
;-

function d_uscensusAngle3123, $
    cos_mat      ; IN: cosine direction matrix (3 x 3)
;
;This function returns the 3 angles of a space three 1-2-3
;given a 3 x 3 cosine direction matrix
;else -1 on failure.
;
;Definition :
;   Given 2 sets of dextral orthogonal unit vectors
;   (a1, a2, a3) and (b1, b2, b3), the cosine direction matrix
;   C (3 x 3) is defined as the dot product of:
;
;   C(i,j) = ai . bi  where i = 1,2,3
;
;   A column vector X (3 x 1) becomes X' (3 x 1)
;   after the rotation as defined as :
;
;   X' = C X
;
;   The space three 1-2-3 means that the x rotation is first,
;   followed by the y rotation, then the z.
;
;Verify input parameter.
;
if (n_params() ne 1) then begin
    print,'Error in d_uscensusAngle3123: 1 parameters must be passed.'
    return, -1
    end
sizec = size(cos_mat)
if (sizec[0] ne 2) then begin
    print,'Error, the input matrix must be of dimension 2'
    return, -1
    end
if ((sizec[1] ne 3) or (sizec[2] ne 3)) then begin
    print,'Error, the input matrix must be 3 by 3'
    return, -1
    end
;
;Compute the 3 angles (in degrees)
;
cos_mat = transpose(cos_mat)
angle = fltarr(3)
angle[1] = -cos_mat[2,0]
angle[1] = asin(angle[1])
c2 = COS(angle[1])
if (abs(c2) lt 1.0e-6) then begin
    angle[0] = atan(-cos_mat[1,2], cos_mat[1,1])
    angle[2] = 0.0
    end $
else begin
    angle[0] = atan(cos_mat[2,1], cos_mat[2,2])
    angle[2] = atan(cos_mat[1,0], cos_mat[0,0])
    end
angle = angle * (180.0 / !dpi)

return, angle
end
;--------------------------------------------------------------------
function d_uscensusSpace3123, $
    theta, $        ; IN: angle of rotation around the x axis (in degrees).
    phi, $          ; IN: angle of rotation around the y axis (in degrees).
    gamma           ; IN: angle of rotation around the z axis (in degrees).
;
;This function returns the cosine direction matrix (3 x 3)
;given the space three 1-2-3 rotation angles(i.e. rotation around
;x axis, followed by Y axis, then z axis),
;else -1 on failure.
;
;Definition :
;   Given 2 sets of dextral orthogonal unit vectors
;   (a1, a2, a3) and (b1, b2, b3), the cosine direction matrix
;   C (3 x 3) is defined as the dot product of:
;
;   C(i,j) = ai . bi  where i = 1,2,3
;
;   A column vector X (3 x 1) becomes X' (3 x 1)
;   after the rotation as defined as :
;
;   X' = C X
;
;Verify the input parameters.
;
if (n_params() ne 3) then begin
    print,'Error in d_uscensusSpace3123: 3 parameters must be passed.'
    return, -1
endif

cos_mat = fltarr(3, 3)
;
;Transform the angle in radians.
;
r_theta = theta * !dpi / 180.0
r_phi = phi * !dpi / 180.0
r_gamma = gamma * !dpi / 180.0

cos1 = cos(r_theta)
cos2 = cos(r_phi)
cos3 = cos(r_gamma)
sin1 = sin(r_theta)
sin2 = sin(r_phi)
sin3 = sin(r_gamma)
;
;Compute the cosine direction matrix.
;
cos_mat[0,0] = cos2*cos3
cos_mat[1,0] = cos2*sin3
cos_mat[2,0] = -sin2
cos_mat[0,1] = (sin1*sin2*cos3) - (cos1*sin3)
cos_mat[1,1] = (sin1*sin2*sin3) + (cos1*cos3)
cos_mat[2,1] = sin1*cos2
cos_mat[0,2] = (cos1*sin2*cos3) + (sin1*sin3)
cos_mat[1,2] = (cos1*sin2*sin3) - (sin1*cos3)
cos_mat[2,2] = cos1*cos2

return, cos_mat
end
;--------------------------------------------------------------------
function d_uscensusMercator, coordinate, circumference
;
;Given [longitude, latitude] on a sphere of size CIRCUMFERENCE,
;return a Mercator projection of [longitude, latitude].
;
if n_elements(circumference) eq 0 then $
    circumference = 360
result = coordinate
result[0, 0] = result[0, *] * float(circumference)/360.
result[1, 0] = (circumference/(2*!pi)) $
             * alog( 1/cos(!dtor*result[1, *]) + tan(!dtor*result[1, *]) )
return, result
end
;--------------------------------------------------------------------
pro d_uscensusDraw, app_state, indx, create_instance=create_instance
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
;Draw.
;
if keyword_set(create_instance) then begin
    app_state.window_objects[indx]->Draw, $
        app_state.view_objects[indx], $
        create_instance=create_instance
    end $
else begin
    app_state.window_objects[indx]->Draw, $
        app_state.view_objects[indx], $
        draw_instance=([app_state.backdrop, 0b])[indx eq 1]
    end
;
;Silently flush any accumulated math error.
;
void = check_math()
;
;Restore original math error behavior.
;
!except = orig_except
end
;--------------------------------------------------------------------
function d_uscensusRegion::init, $
    info, $
    offset=offset, $ ; Degrees.  [lon, lat]
    oTessellator=oTessellator, $
    debug=debug, $
    _extra=e

catch, error_status
if error_status ne 0 then begin
    catch, /cancel
    print, !error_state.msg
    return, 0
    end
if keyword_set(debug) then $
    catch, /cancel

outline = fltarr(3, (size(*info.pOutline))[2]) + 1
outline[0:1, *] = *info.pOutline
outline[0, *] = outline[0, *] + offset[0]
outline[1, *] = outline[1, *] + offset[1]
outline[0:1, *] = outline[0:1, *] / 180.
;
;A black outline serves as self's border.
;
self.oOutline = obj_new('IDLgrPolyline', $
    outline, $
    color=[0, 0, 0], $
    thick=([2,3])[!version.os_family eq 'MacOS'], $
    uvalue=self $
    )
;
;Create a skirt for self.  Note that we specify
;backface culling.  Since we won't be looking at the
;"inside" of self, we can speed rendering
;by telling IDL to reject back faces.
;
mesh_obj, 5, verts, polygons, outline, p2=[0,0,-1] ; Extrude
self.oSkirt = obj_new('IDLgrPolygon', $
    verts, $
    polygons=polygons, $
    shading=1, $ ; Gouraud.
    reject=2, $
    uvalue=self $
    )
;
;Create the top and bottom of self, using concave polygons derived
;from self's outline.  Event though the derived polygons are of
;uniform color, they can vary in their apparent color when directional
;IDLgrLight is shined at them.  So we specify Gouraud shading to
;smooth these apparent differences.
;
self.oFace = obj_new('IDLgrPolygon', $
    /reject, $
    shading=1, $ ; Gouraud.
    uvalue=self $
    )
self.oBase = obj_new('IDLgrPolygon', $
    reject=2, $
    shading=1, $ ; Gouraud.
    uvalue=self $
    )
if not keyword_set(oTessellator) then begin
    oTess = obj_new('IDLgrTessellator')
    end $
else begin
    oTess = oTessellator
    end
oTess->Reset
oTess->AddPolygon, outline[*, 0:(size(outline))[2]-2] * 500.
if (oTess->Tessellate(vertices, polygons)) then begin
    self.oFace->SetProperty, $
        data=vertices/500., $
        polygons=polygons
    vertices[2, *] = 0
    self.oBase->SetProperty, $
        data=vertices/500., $
        polygons=polygons, $
        color=[96, 96, 96]
    end $
else $
    message, 'Failed to Tessellate ' + info.state
;
self.oOutlineModel = obj_new('IDLgrModel')
self.oPolygonModel = obj_new('IDLgrModel')

self.oPolygonModel->Add, self.oSkirt
self.oPolygonModel->Add, self.oFace
self.oOutlineModel->Add, self.oOutline
self.oOutlineModel->Add, self.oBase

info.oPolygonRot->Add, self.oPolygonModel
info.oOutlineRot->Add, self.oOutlineModel

self.scale = [1, 1, 1]
self.pPopulation = ptr_new(info.population)
self.region_name = info.state

if not keyword_set(oTessellator) then begin
    obj_destroy, oTess
    end
return, 1 ; Success.
end
;--------------------------------------------------------------------
pro d_uscensusRegion::cleanup
ptr_free, self.pPopulation
end
;--------------------------------------------------------------------
function d_uscensusRegion::Population, year_indx
return, (*self.pPopulation)[year_indx]
end
;--------------------------------------------------------------------
pro d_uscensusRegion::SetProperty, $
    color=color, $
    scale=scale, $
    outline=outline, $
    uvalue=uvalue

if n_elements(color) ne 0 then begin
    self.oFace->SetProperty, color=color
    self.oSkirt->SetProperty, color=color
    end
if n_elements(scale) ne 0 then begin
    self.oPolygonModel->Scale, $
        1/self.scale[0], $
        1/self.scale[1], $
        1/self.scale[2]
    self.oPolygonModel->Scale, $
        scale[0], $
        scale[1], $
        scale[2]

    self.oOutlineModel->Scale, $
        1/self.scale[0], $
        1/self.scale[1], $
        1/self.scale[2]
    self.oOutlineModel->Scale, $
        scale[0], $
        scale[1], $
        scale[2]

    self.scale = scale
    end

if n_elements(outline) ne 0 then $
    self.oOutline->SetProperty, hide=([1,0])[keyword_set(outline)]

if n_elements(uvalue) ne 0 then begin
    self.oFace->SetProperty, uvalue=uvalue
    self.oSkirt->SetProperty, uvalue=uvalue
    self.oOutline->SetProperty, uvalue=uvalue
    self.oBase->SetProperty, uvalue=uvalue
    end
end
;--------------------------------------------------------------------
pro d_uscensusRegion::GetProperty, $
    color=color, $
    region_name=region_name, $
    _ref_extra=e

self.oFace->GetProperty, color=color
region_name = self.region_name
end
;--------------------------------------------------------------------
pro d_uscensusRegion__define
void = {d_uscensusRegion, $
    oFace: obj_new(), $
    oSkirt: obj_new(), $
    oOutline: obj_new(), $
    oBase: obj_new(), $
    oPolygonModel: obj_new(), $
    oOutlineModel: obj_new(), $
    scale: [0., 0., 0.], $
    pPopulation: ptr_new(), $
    region_name: '' $
    }
end
;--------------------------------------------------------------------
Function d_uscensusZColorCalc, PopulationChanges, PopulationScale
;
; Given a population change, determine the color that should be
; used for that State.
;
NPopulations = N_Elements(PopulationChanges)
Colors = BytArr(3, NPopulations)
Loss = Where(PopulationChanges lt PopulationScale.range_max[0], NLoss)
If (NLoss gt 0) then Begin
    For J = 0, 2 Do Begin
        Colors[J, Loss] = PopulationScale.Colors[J, 0]
    EndFor
EndIf
For I = 1, N_elements(PopulationScale.range_max) - 1 Do Begin
    ThisColor = Where(PopulationChanges ge $
        PopulationScale.range_max[I - 1] and $
        PopulationChanges lt PopulationScale.range_max[I], NThisColor)
    If (NThisColor ne 0) then Begin
        For J = 0, 2 Do Begin
            Colors[J, ThisColor] = PopulationScale.Colors[J, I]
        EndFor
    EndIf
EndFor
BigGain = Where(PopulationChanges ge PopulationScale.range_max[ $
    N_elements(PopulationScale.range_max) - 1], NBigGain)
If (NBigGain ne 0) then Begin
    For J = 0, 2 Do Begin
        Colors[J, BigGain] = PopulationScale.Colors[J, $
            N_elements(PopulationScale.range_max) - 1]
    EndFor
EndIf
Return, Colors
End
;--------------------------------------------------------------------
function d_uscensusZ_color, app_state, oRegion
;
;Return a color for the given d_uscensusRegion.
;
oRegion->GetProperty, region_name=region_name
case 1 of
    strpos(region_name, 'LAKE') ne -1: $
        return, [0, 0, 255]
    oRegion->Population(app_state.year) eq 0: $
        return, [20, 20, 20]
    app_state.year eq app_state.n_years - 1: $
        return, [255, 255, 255]
    oRegion->Population(app_state.year + 1) eq 0: $
        return, [255, 255, 255]
    else: begin
        ratio = oRegion->Population(app_state.year) $
              / float(oRegion->Population(app_state.year + 1))
        return, $
            d_uscensusZColorCalc( $
                ratio, $
                app_state.population_scale $
                )
        end
    endcase
end
;--------------------------------------------------------------------
function d_uscensusStrCommas, str
;
;Put commas in a string.
;
bstr = byte(strcompress(str, /remove_all))
if n_elements(bstr) le 3 then $
    return, string(bstr)

position = indgen(n_elements(bstr) / 3) * 3 + (n_elements(bstr) mod 3)
if position[0] eq 0 then $
    position = position[1:*]
result = bytarr(n_elements(bstr) + n_elements(position))
i = 0
j = 0
k = 0
while i le n_elements(result)-1 do begin
    if j le n_elements(position) - 1 then begin
        if i eq position[j] then begin
            result[i] = byte(',')
            j = j + 1
            i = i + 1
            position = position + 1
            end
        end
    result[i] = bstr[k]
    i = i + 1
    k = k + 1
    end
return, string(result)
end
;--------------------------------------------------------------------
Pro d_uscensusBuild_Backdrop, BackdropImage, BackdropObject
;
; This routine builds the "curtain" or backdrop
; in front of which the map data are rendered.
; There's no real magic here.  I ("JLP") just played around
; with the values until I got the effect I wanted.
;
; Note that when texture mapping, IDL operates most
; efficiently on images that are a) square and b)
; dimensioned by powers of 2.
;
; ZZ defines the surface "height" of the backdrop.
; XX and YY are the coordinates of each of the
; ZZ values.
;
; Since the image is not a true child of the
; backdrop object (it's a property), we need
; to pass that back so we can destroy it later.
;
ZZ = Findgen(256)^7/1.E15 + .01
Z = FltArr(256, 256)
For I = 0, 255 Do Begin
    Z[I, *] = ZZ
EndFor
XX = FltArr(256, 256)
YY = XX
;
; Center the X and Y values
;
X = Reverse(.25 - Findgen(256)/512)
Y = Findgen(256)/128 - 1
;
; The Y values of the mapped image are
; the same across a row.  The X values
; spread out toward the bottom of the
; backdrop so the image appears "splayed".
;
For I = 0, 255 Do Begin
    YY[I, *] = Y/10.
    XX[*, I] = X * (1 + ((255 - I)/128.)^1.5)
EndFor
;
; Create the image that will be mapped onto
; the coordinates defined above, It's simply
; an image of vertical stripes with some border
; pixels.
;
Image = BytArr(3, 256, 256)
Image[*,254:*, *] = 255
Image[*, *, 254:*] = 255
Image[*,0:3, *] = 255
Image[*, *, 0:2] = 255
;
; Now we get obnoxiously partiotic and make
; the stripes red, white, and blue with some
; black left in for "shadows".
;
K = -1
For X = 30, 220, 10 Do Begin
    K = (K + 1) mod 3
    If (K eq 1) then Begin
        Image[*, X:X + 5, *] = 255
    EndIf Else Begin
        For I = 0, 2 Do Begin
            Image[I, X:X + 5, *] = 255 * (I eq K)
        EndFor
    EndElse
EndFor
;
; The next trick we perform is to de-focus the
; image in steps so that pixels nearest the
; top that appear farthest away are also the most
; out-of-focus.
;
For Y = (Size(Image))[2] - 31, 0, -32 Do Begin
    For I = 0, 2 Do Begin
;
; Smooth pixels from this row up.  Rows at the
; top are smoothed more often than rows at the
; bottom.
;
        Layer = Smooth(Reform(Image[I, *, Y:*]), 3)
        Image[I, *, Y:*] = Layer
    EndFor
EndFor
;
; Create the backdrop image.  Don't forget it's TrueColor!
;
BackdropImage = Obj_New('IDLgrImage', Image, Interleave = 0)
;
; Create the backdrop object using the image object as the
; texture object.  Keep in mind that the texture mapped image
; colors are convolved with the COLOR property of the surface
; object.
;
BackdropObject = Obj_New('IDLgrSurface', .2 - Z/100., 2.5*XX, YY*3.5, $
    Shading = 1, Style = 2, Texture_Map = BackdropImage, $
    Color = [255, 255, 255], /Texture_Interp)
End

;--------------------------------------------------------------------
function d_uscensusBuild_Scale_Legend, info
;
;This routine builds the legend for the display.  Each legend entry
;consists of a color block and a text label associated
;with that color.  Colors in d_uscensus represent rate of
;population change.
;
oScaleModel  = obj_new('IDLgrModel')

n_scale_colors = n_elements(info.range_max) + 2
scale_color_models = ObjArr(n_scale_colors)
scale_color_images = ObjArr(n_scale_colors)
scale_color_labels = ObjArr(n_scale_colors)
oFont = Obj_New('IDLgrFont', 'Hershey*3', size=7)
;
;Store font so that it will get destroyed when the Scale Legend
;is destroyed.
;
oContainer = obj_new('IDL_Container')
oContainer->Add, oFont
oScaleModel->Add, oContainer
;
pixel_block = bytarr(3, 30, 20)
;
;The color white is used when a State is "new"; no census
;was performed the previous decade.
;
scale_color_images[0] = obj_new('IDLgrImage', $
    pixel_block + 255, $
    interleave=0, $
    dimensions=[.1, .2] $
    )
scale_color_labels[0] = obj_new('IDLgrText', $
    'New State', $
    /onglass, $
    location=[.11, -0.06], $
    color=[255, 255, 255], $
    font=oFont $
    )
;
;Red indicates there was population loss compared with the
;previous decade.
;
pixel_block[0, *, *] = 255b ; Fill with red.
scale_color_images[1] = obj_new('IDLgrImage', $
    pixel_block, $
    interleave=0, $
    Dimensions=[.1, .2] $
    )
scale_color_labels[1] = obj_new('IDLgrText', $
    'Pop. Loss', $
    /onglass, $
    location=[.11, -0.06], $
    color = [255, 255, 255], $
    font=oFont $
    )
;
;The remaining keys indicate population change between one
;percentage and the next.
;
for i=2,n_scale_colors-1 do begin
    for j=0,2 do $
        pixel_block[j, *, *] = info.colors[j, i-1]
    scale_color_images[i] = obj_new('IDLgrImage', $
        pixel_block, $
        interleave=0, $
        dimensions=[0.1, 0.2] $
        )
    scale_color_labels[i] = obj_new('IDLgrText', $
        '> ' + strtrim(fix(100 * (info.range_max[i - 2] - .99999)), 2) $
             + '%', $
        color=[255, 255, 255], $
        location=[0.11, -0.06], $
        /onglass, $
        font=oFont $
        )
    end
;
;Combine the color blocks and text into a models, then
;translate them so we end up in 2 rows, each with 5 entries.
;
for i=0, n_scale_colors - 1 do begin
    scale_color_models[i] = obj_new('IDLgrModel')
    scale_color_models[i]->Add, scale_color_images[i]
    scale_color_models[i]->Add, scale_color_labels[i]
    scale_color_models[i]->Translate, $
        -.94 + .4 * (i mod 5), $
        -.575 * fix(i / 5), $
        0.
    end
oScaleModel->Add, obj_new('IDLgrText', $
    'Relative Population Change', $
    Location=[-.98, .55], $
    Font=oFont, $
    /onglass, $
    color=[255, 255, 255] $
    )
oScaleModel->Add, scale_color_models
return, oScaleModel
end
;--------------------------------------------------------------------
function d_uscensusBuild_State_Objects, $
    states, $           ; IN
    xdim, $             ; IN
    ydim, $             ; IN
    oPolygonRot, $      ; IN
    oOutlineRot, $      ; IN
    debug=debug         ; IN
;
;Create a tessellator object.  A d_uscensusRegion needs to use
;a Tessellator object to construct itself.  For efficiency, we will
;pass this single Tessellator to each of the regions we create,
;rather than requiring each region to construct its own Tessellator.
;
oTessellator = obj_new('IDLgrTessellator')
;
state_objects = objarr(n_elements(states))
hawaii_uval = obj_new()
for i=0,n_elements(states)-1 do begin
    info = create_struct( $
        states[i], $
        'oPolygonRot', oPolygonRot, $
        'oOutlineRot', oOutlineRot $
        )
;
;   Perform a Mercator projection on state's outline.
;   We use the Mercator projection in an attempt to
;   makes the state's shape look more familiar.
;
    *info.pOutline = d_uscensusMercator(*info.pOutline)
;
;   Move Alaska and Hawaii so they lie closer to the
;   continental USA.  Make Alaska smaller.
;
    if info.state eq 'ALASKA' then begin
        *info.pOutline = *info.pOutline * .4
        (*info.pOutline)[0, *] = (*info.pOutline)[0, *] - 75
        (*info.pOutline)[1, *] = (*info.pOutline)[1, *] + 15
        end
    if info.state eq 'HAWAII' then begin
        (*info.pOutline)[0, *] = (*info.pOutline)[0, *] + 25
        (*info.pOutline)[1, *] = (*info.pOutline)[1, *] + 10
        end
;
;   Construct an object from the state info.
;
    state_objects[i] = obj_new('d_uscensusRegion', $
        info, $
        offset=d_uscensusMercator([104, -40]), $
        oTessellator=oTessellator, $
        debug=debug $
        )
;
;   Color lakes blue.
;
    if (strpos(states[i].state, 'LAKE') ne -1) then begin
        state_objects[i]->SetProperty, color=[0, 0, 255]
        end
;
;   Gather up Hawaiian islands regions.
;
    if info.state eq 'HAWAII' then begin
        hawaii_uval = hawaii_uval[0] eq obj_new() ? $
            state_objects[i] : [hawaii_uval, state_objects[i]]
        end
    end
;
for i=0,n_elements(state_objects)-1 do begin
    state_objects[i]->GetProperty, region_name=region_name
    if strupcase(region_name eq 'HAWAII') then begin
        state_objects[i]->SetProperty, uvalue=hawaii_uval
        end
    end
;
obj_destroy, oTessellator
return, state_objects
end
;--------------------------------------------------------------------
Pro d_uscensusDisplay_Census_Year, $
    app_state, $
    draw_individually=draw_individually

if n_elements(draw_individually) le 0 then $
    draw_indiv = app_state.draw_individually $
else $
    draw_indiv = draw_individually

if draw_indiv then begin
    widget_control, app_state.wYearDroplist, $
        set_droplist_select=app_state.n_years - app_state.year - 1
    end
;
;Label the census year.
;
str = strtrim(1980 - (app_state.year - 1)*10, 2)
app_state.oYearText->SetProperty, string=str
;
for i=0,n_elements(app_state.state_objects)-1 do begin
    oRegion = app_state.state_objects[i]
    oRegion->SetProperty, color=d_uscensusZ_color(app_state, oRegion)
    if oRegion->Population(app_state.year) eq 0 then begin
        oRegion->SetProperty, scale=[1, 1, 1.e-4]
        end $
    else begin
        oRegion->SetProperty, scale=[ $
            1, $
            1, $
            (oRegion->Population(app_state.year) $
                / float(app_state.MaxZValue)) * .25 $
            ]
;
;       If we're on a fast machine, we might want to animate the States
;       individually growing.
;
        if draw_indiv then begin
            d_uscensusDraw, app_state, 0
            end
        end
    end
;
if not draw_indiv then begin
    d_uscensusDraw, app_state, 0
    widget_control, app_state.wYearDroplist, $
        set_droplist_select=app_state.n_years - app_state.year - 1
    end
end
;--------------------------------------------------------------------
pro d_uscensusCleanup, tlb
widget_control, tlb, get_uvalue=pAppState

tvlct, (*pAppState).color_table
if widget_info((*pAppState).groupbase, /valid) then $
    widget_control, (*pAppState).groupbase, /map
;
;Clean up heap variables.
;
for i=0,n_tags(*pAppState)-1 do begin
    case size((*pAppState).(i), /tname) of
        'POINTER': $
            ptr_free, (*pAppState).(i)
        'OBJREF': $
            obj_destroy, (*pAppState).(i)
        else:
        endcase
    end
ptr_free, pAppState
end
;--------------------------------------------------------------------
pro d_uscensusUnselect, app_state, no_draw=no_draw
if (*app_state.pChosenRegions)[0] ne obj_new() then begin
    for i=0,n_elements(*app_state.pChosenRegions)-1 do begin
        (*app_state.pChosenRegions)[i]->SetProperty, $
            color=d_uscensusZ_color( $
                app_state, $
                (*app_state.pChosenRegions)[i] $
                )
        end
    app_state.oStateText->SetProperty, string=''
    *app_state.pChosenRegions = obj_new()
    if not keyword_set(no_draw) then begin
        d_uscensusDraw, app_state, 0
        end
    end
end
;--------------------------------------------------------------------
pro d_uscensusSetOutlinesOnOrOff, app_state
;
;Turn region outlines on or off, depending on whether they are
;facing toward the user.
;
app_state.oPolygonRot->GetProperty, transform=transform
for i=0,n_elements(app_state.state_objects)-1 do begin
    app_state.state_objects[i]->SetProperty, $
        outline=transform[10] gt 0
    end
end
;--------------------------------------------------------------------
pro d_uscensus_event, event
widget_control, event.top, get_uvalue=pAppState ; Get state of application.
demo_record, event, filename=(*pAppState).record_to_filename
;
;Handle Widget Kill Requests explicitly.  Doing this is friendly
;to the demo_tour. i.e. it allows demo_tour recordings of d_uscensus to
;have quit-via-the-window-manager events in them.
;
if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
    widget_control, event.id, /destroy
    return
    end
;
if tag_names(event, /structure_name) eq 'WIDGET_BASE' then begin
    widget_control, /hourglass
;
;   Handle resize events on the top level base.
;
    scale_geom = widget_info((*pAppState).wScale, /geometry)
    button_base_geom = widget_info((*pAppState).wControls, /geometry)
    draw_xsize = event.x-button_base_geom.xsize-2
    draw_ysize = event.y-scale_geom.ysize-(*pAppState).status_geom.scr_ysize
    widget_control, $
        (*pAppState).wDraw, $
        xsize=draw_xsize, $
        ysize=draw_ysize
    (*pAppState).oPolygonRot->SetProperty, $
        center=[draw_xsize, draw_ysize]/2, $
        radius=draw_xsize/2
    (*pAppState).oOutlineRot->SetProperty, $
        center=[draw_xsize, draw_ysize]/2, $
        radius=draw_xsize/2
    widget_control, (*pAppState).wScale, xsize=draw_xsize
    widget_control, event.id, xsize=event.x
;
;   Resize the backdrop, if it's there, and create the
;   new instance.
;
    if (*pAppState).backdrop then begin
        (*pAppState).view_objects[0]->SetProperty, transparent=0
        (*pAppState).oUnitedStates->SetProperty, hide=1
        (*pAppState).oYearText->SetProperty, hide=1
        (*pAppState).oStateText->SetProperty, hide=1
        (*pAppState).oBackDropModel->SetProperty, hide=0

        d_uscensusDraw, *pAppState, 0, /create_instance

        (*pAppState).oUnitedStates->SetProperty, hide=0
        (*pAppState).oYearText->SetProperty, hide=0
        (*pAppState).oStateText->SetProperty, hide=0
        (*pAppState).oBackDropModel->SetProperty, hide=1
        (*pAppState).view_objects[0]->SetProperty, transparent=1
    endif
;
;   Draw the view.
;
    d_uscensusDraw, *pAppState, 0
    d_uscensusDraw, *pAppState, 1
    return
    end
;
;Handle Trackball updates.
;
void = (*pAppState).oPolygonRot->Update(event)
if (*pAppState).oOutlineRot->Update(event) then begin

    (*pAppState).oOutlineRot->GetProperty, transform=transform
    angle = d_uscensusAngle3123(transform[0:2, 0:2])
    widget_control, (*pAppState).wXSlider, set_value=angle[0]
    widget_control, (*pAppState).wYSlider, set_value=angle[1]
    widget_control, (*pAppState).wZSlider, set_value=angle[2]

    d_uscensusSetOutlinesOnOrOff, *pAppState
    d_uscensusDraw, *pAppState, 0
    end
;
widget_control, event.id, get_uvalue=uvalue
case uvalue of
    'QUIT' : begin
        widget_control, event.top, /destroy
        return
        end
    'DRAW' : begin
        case event.type of
;
;           Dwell event.
;
            2: begin
                if (*pAppState).we_are_animating $
                or (*pAppState).we_are_rotating then $
                    return
                selected = (*pAppState).window_objects[0]->Select( $
                    (*pAppState).view_objects[0], $
                    [event.x, event.y] $
                    )
                if obj_valid(selected[0]) then begin
                    selected[0]->GetProperty, uvalue=chosen_regions
                    if n_elements(chosen_regions) eq 0 then $
                        chosen_regions = obj_new()
                    if obj_valid(chosen_regions[0]) then begin
                        if (*(*pAppState).pChosenRegions)[0] $
                        ne chosen_regions[0] $
                        then begin
                            d_uscensusUnselect, *pAppState, /no_draw

                            pop = chosen_regions[0]->Population( $
                                (*pAppState).year $
                                )
                            chosen_regions[0]->GetProperty, region_name=str
                            if pop gt 0 then $
                                str = str $
                                    + '  population: ' $
                                    + d_uscensusStrCommas(pop)
                            (*pAppState).oStateText->SetProperty, string=str

                            *(*pAppState).pChosenRegions = chosen_regions
                            for i=0,n_elements(chosen_regions)-1 do begin
                                chosen_regions[i]->SetProperty, $
                                    color=[255,255,63]
                                end
                            d_uscensusDraw, *pAppState, 0
                            end
                        end
                    end $
                else begin
                    d_uscensusUnselect, *pAppState
                    end
                end
;
;           Mouse-button press.
;
            0: begin
                if event.press eq 1 then $
                    (*pAppState).we_are_rotating = 1b
                widget_control, (*pAppState).wDraw, draw_motion_events=1
                end
;
;           Mouse-button release.
;
            1: if event.release eq 1 then begin
                (*pAppState).we_are_rotating = 0b
                end
;
;           Expose event.
;
            4: begin
                d_uscensusDraw, *pAppState, 0
                d_uscensusDraw, *pAppState, 1
                end
            else:
            endcase
        end
    'CANCELANIMATION' : begin
        widget_control, (*pAppState).wAnimateButton, $
            set_value='Animate Census', $
            set_uvalue='ANIMATE'

        widget_control, event.top, /clear_events

        (*pAppState).we_are_animating = 0b
        widget_control, (*pAppState).wDraw, draw_motion_events=1
        end
    'DOINGANIMATION' : begin
;
;       This event was thrown from the controls base.  we use a timer
;       event off this base to indicate "frame advance" in the animation.
;
        case 1 of
            (*pAppState).we_are_rotating: $
                widget_control, (*pAppState).wControls, timer=.01
            (*pAppState).year ne 0 and (*pAppState).we_are_animating: begin
                (*pAppState).year = (*pAppState).year - 1
                d_uscensusDisplay_census_year, *pAppState
                widget_control, (*pAppState).wControls, timer=.01
                end
            else: begin
;
;               End the animation,
;
                widget_control, (*pAppState).wAnimateButton, $
                    set_value='Animate Census', $
                    set_uvalue='ANIMATE'
                (*pAppState).we_are_animating=0b
                widget_control, (*pAppState).wDraw, draw_motion_events=1
                ;print, systime(1) - (*pAppState).tic
                end
            endcase
        end
    'ANIMATE' : begin
        widget_control, (*pAppState).wDraw, draw_motion_events=0
        d_uscensusUnselect, *pAppState
        (*pAppState).we_are_animating = 1b
;
;       Modify the "Animate Census" button so it will now throw
;       "CANCELANIMATION" events.
;
        widget_control, (*pAppState).wAnimateButton, $
            set_value = 'Cancel Animation', $
            set_uvalue = 'CANCELANIMATION'
;
;       Initialize the year.
;
        (*pAppState).year = (*pAppState).n_years
;
;       Throw a timer event from the controls base.  Events from the
;       controls base are handled as "animation frame advance" events.
;
        (*pAppState).tic = systime(1)
        widget_control, (*pAppState).wcontrols, timer = .001
        end
    'LEGEND' : begin
        d_uscensusDraw, *pAppState, 0
        d_uscensusDraw, *pAppState, 1
        end
    'CENSUSYEAR' : begin
        widget_control, /hourglass
        d_uscensusUnselect, *pAppState, /no_draw
        (*pAppState).year = ((*pAppState).n_years-1) - event.index
        d_uscensusDisplay_census_year, (*pAppState)
        end
    'ROTATION_SLIDER': begin
        widget_control, (*pAppState).wXSlider, get_value=x_degree
        widget_control, (*pAppState).wYSlider, get_value=y_degree
        widget_control, (*pAppState).wZSlider, get_value=z_degree

        (*pAppState).oPolygonRot->GetProperty, transform=t
        rot_mat = d_uscensusSpace3123(x_degree, y_degree, z_degree) $
                # t[0:2, 0:2]
;
;       Find the Euler parameters 'e4' of rot_mat which
;       is the rotation it takes to go from the original (T)
;       to the final (d_uscensusSpace3123(X_DEGREE, Y_DEGREE, ZDEGREE)).
;
        e4 = 0.5 * sqrt(1.0 + rot_mat[0,0] + rot_mat[1,1] + rot_mat[2,2])
;
;       Find the unit vector of the single rotation axis
;       and the angle of rotation.
;
        case e4 of
            0: begin
                case 1 of
                    rot_mat[0, 0] eq 1: axis_rot = [1, 0, 0]
                    rot_mat[1, 1] eq 1: axis_rot = [0, 1, 0]
                    else: axis_rot = [0, 0, 1]
                    endcase
                angle_rot = 180.0
                end
            1: return ; We can't take ACOS(E4) so bail out.
            else: begin
                e1 = (rot_mat[2,1] - rot_mat[1,2]) / (4.0*e4)
                e2 = (rot_mat[0,2] - rot_mat[2,0]) / (4.0*e4)
                e3 = (rot_mat[1,0] - rot_mat[0,1]) / (4.0*e4)
                modulus_e = sqrt(e1*e1 + e2*e2 +e3*e3)
                if modulus_e eq 0.0 then $
                    return
                axis_rot = [e1, e2, e3] / modulus_e
                angle_rot = (2.0 * acos(e4)) * 180 / !dpi
                end
            endcase

        indx = where(abs(axis_rot) lt 1.0e-6)
        if indx[0] ne -1 then $
            axis_rot[indx] = 1.0e-6
;
;       Apply what we have found.
;
        (*pAppState).oPolygonRot->Rotate, axis_rot, angle_rot
        (*pAppState).oOutlineRot->Rotate, axis_rot, angle_rot
        d_uscensusSetOutlinesOnOrOff, *pAppState
        d_uscensusDraw, (*pAppState), 0
        end
    'SCALING': begin
        (*pAppState).oUnitedStates->Scale, $
            1/(*pAppState).scale, $
            1/(*pAppState).scale, $
            1

        range = widget_info(event.id, /slider_min_max)
        (*pAppState).scale = 0.25 + float(event.value) / (range[1] /2)
        widget_control, (*pAppState).wScalingLabel, $
            set_value='Scaling : ' $
                     + string((*pAppState).scale * 100., format='(f5.1)') $
                     + ' %'

        (*pAppState).oUnitedStates->Scale, $
            (*pAppState).scale, $
            (*pAppState).scale, $
            1
        widget_control, /hourglass
        d_uscensusDisplay_census_year, *pAppState, draw_individually=0
        end
    'HELP' : begin
        online_help, 'd_uscensus', $
            book=demo_filepath( $
                "idldemo.adp", $
                subdir=['examples','demo','demohelp'] $
                ), $
            /full_path
        end
    else :
    endcase
end
;--------------------------------------------------------------------

Pro D_Uscensus, Resizeable=Resizeable, $
    Animate_States = Animate_States, Backdrop = Backdrop, $
    Depth = Depth, Debug = Debug, $
    Record_To_Filename=record_to_filename, $
    Group_Leader = Group_Leader, AppTLB = AppTLB

If (XRegistered('D_Uscensus', /NoShow)) then Begin
    v = Dialog_Message('An instance of D_Uscensus is already running.')
    return
EndIf
If (N_elements(Group_Leader) ne 0) then Begin
    If (N_elements(Group_Leader) eq 1) then Begin
        OkayGroupLeader = Widget_Info(Group_Leader, /Valid_ID)
    EndIf Else Begin
        OkayGroupLeader = 0
    EndElse
    If (not OkayGroupLeader) then Begin
        v = Dialog_Message('The GROUP_LEADER parameter is invalid.')
        return
    EndIf
        groupBase = Group_Leader
EndIf else groupBase = 0L

ngroup = N_elements(Group_Leader)
;
; Get the current color vectors to restore
; when this application is exited.
;
TVLCT, savedR, savedG, savedB, /GET
;
; Build color table from color vectors
;
colorTable = [[savedR],[savedG],[savedB]]
;
If (Keyword_Set(Depth)) then Begin
    Depth_Cue = [-.75, -0.25]
EndIf Else Begin
    Depth_Cue = [0., 0.]
EndElse
;
; We show relative population changes from decade to decade
; via color indices.
;
range_max = [1., 1.01, 1.1, 1.2, 1.5, 2., 3.]
Colors = [ $
    [255, 0, 0], $
    [115, 40, 100], $
    [105, 95, 105], $
    [15, 150, 0], $
    [0, 255, 0], $
    [105, 105, 200], $
    [145, 195, 125], $
    [195, 215, 255]]
population_scale = {range_max : range_max, Colors : Colors}
;
; Set the draw window size.
;
DEVICE, GET_SCREEN_SIZE = screenSize
XDim= 0.70 * screenSize[0]
YDim= 0.55 * XDim
;
; Restore the States database.  This contains
; the State outlines and census data.
;
Restore, DEMO_FILEPATH('states2.sav', SubDir = $
        ['examples', 'demo', 'demodata'])

NStates = N_elements(States)
NYears = N_elements(States[0].Population)
;
; Create widgets.
;
If not Keyword_Set(resizeable) Then $
    If (Keyword_Set(Group_Leader)) then Begin
        wBase = Widget_Base(/COLUMN, Group=Group_Leader, MBar=MenuBar, $
            XPad = 0, YPad = 0, Title = 'US Census Data', $
            /TLB_Size_Events, Space = 0, $
            TLB_Frame_Attr=1, $
            /TLB_Kill_Request_Events, $ ; A nicety for DEMO, /RECORD.
            UName = 'D_Uscensus:tlb')
    EndIf Else Begin
        wBase = Widget_Base(/COLUMN, MBar = MenuBar, $
            XPad = 0, YPad = 0, Title = 'US Census Data', $
            /TLB_Size_Events, Space = 0, $
            TLB_Frame_attr=1, $
            UName = 'D_Uscensus:tlb')
    EndElse $
Else $
    If (Keyword_Set(Group_Leader)) then Begin
        wBase = Widget_Base(/COLUMN, Group=Group_Leader, MBar=MenuBar, $
            XPad = 0, YPad = 0, Title = 'US Census Data', $
            /TLB_Size_Events, Space = 0, $
            UName = 'D_Uscensus:tlb')
    EndIf Else Begin
        wBase = Widget_Base(/COLUMN, MBar = MenuBar, $
            XPad = 0, YPad = 0, Title = 'US Census Data', $
            /TLB_Size_Events, Space = 0, $
            UName = 'D_Uscensus:tlb')
    EndElse

wBase1 = WIDGET_BASE(wBase,/Row)

AppTLB = wBase
FileMenu = Widget_Button(MenuBar, Value = 'File', /Menu)
QuitButton = Widget_Button(FileMenu, Value = 'Quit', $
    UValue = 'QUIT', UName = 'D_Uscensus:quit')

HelpMenu = Widget_Button(MenuBar, Value = 'About', /Help,  /Menu)
HelpButton = Widget_Button(HelpMenu, $
    Value = 'About the U.S. Census demo...', UValue = 'HELP')

wControls = Widget_Base(wBase1, $
    /Column, $
    UValue = 'DOINGANIMATION', $
    UName = 'D_Uscensus:controls_base' $
    )

wAnimateButton = Widget_Button(wControls, $
    Value = 'Animate Census', $
    UValue = 'ANIMATE', $
    UName = 'D_Uscensus:animate' $
    )

void = Widget_Label(wControls, Value='Select Census Year:', /Align_Center)
wYearDroplist = Widget_Droplist(wControls, $
    Value=StrTrim(1790 + Indgen(NYears)*10, 2), $
    UValue = 'CENSUSYEAR', $
    /Align_Center, $
    UName='D_Uscensus:year' $
    )

wCenteringBase = Widget_Base(wControls, /Align_Center, /Column)
    initial_angles = [-10, 0, 0] ; degrees. [x, y, z]
    wRotationsBase = Widget_Base(wCenteringBase, /Column, /Frame)
        void = Widget_Label(wRotationsBase, Value='Rotation Angle')
        wXSlider = Widget_Slider( $
            wRotationsBase, $
            Title='X', $
            Minimum=-180, $
            Maximum=180, $
            UValue='ROTATION_SLIDER', $
            Value=initial_angles[0] $
            )
        wYSlider = Widget_Slider( $
            wRotationsBase, $
            Title='Y', $
            Minimum=-180, $
            Maximum=180, $
            UValue='ROTATION_SLIDER', $
            Value=initial_angles[1] $
            )
        wZSlider = Widget_Slider( $
            wRotationsBase, $
            Title='Z', $
            Minimum=-180, $
            Maximum=180, $
            UValue='ROTATION_SLIDER', $
            Value=initial_angles[2] $
            )

    wScalingBase = Widget_Base(wCenteringBase, /Column)
        wScalingLabel = Widget_Label( $
            wScalingBase, $
            Value='Scaling : ' $
                 + string(100, format='(f5.1)') $
                 + ' %' $
            )
        wScalingSlider = widget_slider(wScalingBase, $
            Minimum=0, $
            Maximum=40, $
            value=15, $
            /Suppress_Value, $
            Uvalue='SCALING' $
            )

Drawbase = Widget_Base(wBase1, $
    /Column, $
    XPad = 0, $
    YPad = 0, $
    Space = 0, $
    Frame = 0 $
    )

wDraw = Widget_Draw(DrawBase, XSize = XDim, YSize = YDim, $
    /Button_Events, UValue = 'DRAW', Retain = 0, /Expose_Events, $
    Graphics_Level = 2, /Motion_Events, $
    Uname='D_Uscensus:draw')
wScale = Widget_Draw(DrawBase, XSize = XDim, YSize = 60, $
    UValue = 'LEGEND', Retain = 0, /Expose_Events, $
    Graphics_Level = 2)

        ; Create the status line label.
        ;
        wStatusBase = WIDGET_BASE(wBase, MAP=0, /ROW)
;
; Get the tips
;
sText = demo_getTips(demo_filepath('uscensus.tip', $
                     SUBDIR=['examples','demo', 'demotext']), $
                     wBase, $
                     wStatusBase)
StatusGeom = Widget_Info(wStatusBase, /Geometry)
;
; Realize the base widget.
;
Widget_Control, wBase, /Realize

Widget_Control, /Hourglass
;
; Get the window objects associated with the two
; draw widgets we've created.
;
Widget_Control, wDraw, Get_Value = oWindow
Widget_Control, wScale, Get_Value = oScale
;
; Create the views.  One will contain the USA and backdrop and
; the other will contain the scale legend.
;
ViewObject1 = Obj_New('IDLgrView', $
    viewplane_rect=[-.5, -ydim/xdim*.5, 1., ydim/xdim], $
    Color = [255, 255, 255], $
    proj=2, $
    ZClip = [2., -1.], Depth_Cue = Depth_Cue)
ViewObject2 = Obj_New('IDLgrView', $
    Viewplane_Rect=[-1, -1, 2, 2], Color = [0, 0, 0])
;
; Build the backdrop
;
oBackDropModel = Obj_New('IDLgrModel')
d_uscensusBuild_Backdrop, BackdropImage, BackdropObject
oBackDropModel->Add, BackdropObject
If (not Keyword_Set(Backdrop)) then Begin
    BackdropObject->SetProperty, Hide = 1
EndIf
;
; Create the population scale legend, add it to the
; appropriate view, and draw it.
;
ViewObject2->Add, d_uscensusBuild_Scale_Legend(population_scale)
oScale->Draw, ViewObject2
;
; Create a model for lights and place an ambient and
; directional light into the appropriate view.
;
LightFrame = Obj_New('IDLgrModel')
Light1 = Obj_New('IDLgrLight', Type = 0, Intensity = 0.85, $
    Color = [255, 255, 255])
Light2 = Obj_New('IDLgrLight', Location = [0, 2, 2], Type = 1, $
    Color = [255, 255, 255], Intensity = .5)
LightFrame->Add, Light1
LightFrame->Add, Light2
ViewObject1->Add, LightFrame

oPolygonRot = obj_new('IDLexRotator', [xdim, ydim] / 2, xdim / 2)
oOutlineRot = obj_new('IDLexRotator', [xdim, ydim] / 2, xdim / 2)

oOutlineOffset = obj_new('IDLgrModel')
oOutlineOffset->Add, oOutlineRot
;
; To avoid conflict with polygons, move outlines slightly.
;
oOutlineOffset->Translate, 0, 0, .001 ; Amount determined empirically.
;
oUnitedStates = obj_new('IDLgrModel')
oUnitedStates->Add, oOutlineOffset
oUnitedStates->Add, oPolygonRot

state_objects = d_uscensusBuild_State_Objects( $
    states, $
    xdim, $
    ydim, $
    oPolygonRot, $
    oOutlineRot, $
    debug=keyword_set(debug) $
    )
;
; Rotate the nation slightly for a nice initial view.  We rotate
; the individual IDLexRotators, rather than calling
; oUnitedStates->Rotate, because we want to keep oOutlineOffset's
; translation "straight out from the screen".  If oOutlineOffset
; were rotated (which would happen if we called oUnitedStates->Rotate),
; we risk that the small gap that oOutlineOffset's translation
; (deliberately) introduces would become discernable.
;
oPolygonRot->Rotate, [1, 0, 0], initial_angles[0]
oOutlineRot->Rotate, [1, 0, 0], initial_angles[0]
oPolygonRot->Rotate, [0, 1, 0], initial_angles[1]
oOutlineRot->Rotate, [0, 1, 0], initial_angles[1]
oPolygonRot->Rotate, [0, 0, 1], initial_angles[2]
oOutlineRot->Rotate, [0, 0, 1], initial_angles[2]
;
; Translate the model up Z toward the viewer so we can
; make room for the backdrop.
;
oUnitedStates->Translate, 0., 0., .5
;
; Zoom-in for a nice initial view.
;
oUnitedStates->Scale, 2.0, 2.0, 1
;
; Add the nation to the appropriate view.
;
ViewObject1->Add, oUnitedStates
;
; Add a text objects which will hold the census year, and
; US State readouts.
;
TextModel = Obj_New('IDLgrModel')
If (Keyword_Set(Backdrop)) then Begin
    TextColor = [127,127,127]
Endif Else Begin
    TextColor = [0, 0, 0]
EndElse
;
; Create font for titles.
;
oFont = Obj_New('IDLgrFont', 'Helvetica*Bold', Size = 11 - $
    2*(!d.y_ch_size gt 12))
;
; Store font so that it will get destroyed when ViewObject1 is
; destroyed.
;
oContainer = obj_new('IDL_Container')
oContainer->Add, oFont
ViewObject1->Add, oContainer
;
oYearText = Obj_New('IDLgrText',  '', $
    Location=[-.48,-.26], $
    Color = TextColor, $
    /OnGlass, $
    Font = oFont $
    )
oStateText = Obj_New('IDLgrText',  $
    '', $
    Location = [0, -.26], $
    Color = TextColor, $
    /OnGlass, $
    Font = oFont, $
    Align=.5 $
    )
TextModel->Add, oStateText
TextModel->Add, oYearText
ViewObject1->Add, TextModel

if not keyword_set(record_to_filename) then $
    record_to_filename = ''

app_state = { $
    view_objects    : [ViewObject1, ViewObject2], $
    window_objects  : [oWindow, oScale], $
    wDraw           : wDraw, $
    wScale          : wScale, $
    wControls       : wControls, $
    wYearDroplist   : wYearDroplist, $
    wXSlider        : wXSlider, $
    wYSlider        : wYSlider, $
    wZSlider        : wZSlider, $
    wScalingLabel   : wScalingLabel, $
    wScalingSlider  : wScalingSlider, $
    scale           : 1., $
    oYearText       : oYearText, $
    oStateText      : oStateText, $
    state_objects   : state_objects, $
    oUnitedStates   : oUnitedStates, $
    oPolygonRot     : oPolygonRot, $
    oOutlineRot     : oOutlineRot, $
    n_years         : NYears, $
    year            : NYears - 1, $
    oBackDropModel  : oBackDropModel, $
    BackdropImage   : BackdropImage, $
    DepthCue        : Depth_Cue, $
    draw_individually : Keyword_Set(Animate_States), $
    Backdrop        : Keyword_Set(Backdrop), $
    MaxZValue       : Max(States.Population), $
    population_scale : population_scale, $
    wAnimateButton  : wAnimateButton, $
    pChosenRegions  : ptr_new(obj_new()), $
    we_are_animating: 0b, $
    we_are_rotating : 0b, $
    status_geom     : StatusGeom, $
    color_table     : colorTable, $     ; Color table to restore at exit
    debug           : keyword_set(debug), $
    record_to_filename : record_to_filename, $
    tic             : 0.0d, $           ; Clock time at begin animation.
    groupBase       : groupBase $       ; Base of Group Leader
    }
;
; If we're employing a backdrop image, we only need to draw it
; once as an instance and use that in subsequent draws of the USA.
;
If Keyword_Set(Backdrop) then Begin
    ViewObject1->Add, oBackDropModel
    oUnitedStates->SetProperty, Hide = 1
    oBackDropModel->SetProperty, Hide = 0
    d_uscensusDraw, app_state, 0, /create_Instance
    oUnitedStates->SetProperty, Hide = 0
    oBackDropModel->SetProperty, Hide = 1
    ViewObject1->SetProperty, Transparent = 1
EndIf
d_uscensusDisplay_Census_Year, app_state, draw_individually=0

Widget_Control, wBase, Set_UValue = ptr_new(app_state, /no_copy)
ptr_free, states.pOutline
ptr_free, states.pNormalOutline
ptr_free, states.pPolygonList
ptr_free, states.pVertexList
Widget_Control, wBase, /Clear_Events

XManager, 'D_Uscensus', wBase, $
    /No_Block, $
    CLEANUP='d_uscensusCleanup'
return
End
