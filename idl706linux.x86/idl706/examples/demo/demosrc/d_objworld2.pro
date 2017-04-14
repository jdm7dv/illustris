;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_objworld2.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_objworld2.pro
;
;  CALLING SEQUENCE: d_objworld2
;
;  PURPOSE:
;       Visualization of thunderstorm data.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_objworld2Event      -  Event handler
;       pro d_objworld2Cleanup    -  Cleanup
;       pro d_objworld2           -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro trackball__define   -  Create the trackball object
;       pro IDLexModelManip__define - Define Model Manipulator
;       pro IDLexViewManip__define  - Define View Manipulator
;       pro demo_gettips        - Read the tip file and create widgets
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       1/97,   ACY   - adapted from objworld2, written by R.F.
;       7/98,   PCS   - changed GUI to require only the left
;                       mouse-button.  Changed code to use
;                       IDLexModelManip and IDLexViewManip.
;-
;----------------------------------------------------------------------------
function d_objworld2ReadPalette, n

filename = filepath('colors1.tbl', subdir=['resource', 'colors'])
openr,lun,filename, /block, /get_lun
ntables = 0b
readu, lun, ntables
tnum = n
if (tnum LT 0) then tnum = 0
if (tnum GE ntables) then tnum = ntables-1
arr = bytarr(256)
ctab = bytarr(3,256)
point_lun, lun, tnum*768L + 1L
readu, lun, arr
ctab[0,*] = arr
readu, lun, arr
ctab[1,*] = arr
readu, lun, arr
ctab[2,*] = arr
close,lun
free_lun,lun

return,ctab

end

;----------------------------------------------------------------------------
pro d_objworld2SceneAntiAlias, w, v, n
widget_control, /hourglass
case n of
    2 : begin
        jitter = [ $
            [ 0.246490,  0.249999], $
            [-0.246490, -0.249999] $
            ]
        njitter = 2
        end
    3 : begin
        jitter = [ $
            [-0.373411, -0.250550], $
            [ 0.256263,  0.368119], $
            [ 0.117148, -0.117570] $
            ]
        njitter = 3
        end
    8 : begin
        jitter = [ $
            [-0.334818,  0.435331], $
            [ 0.286438, -0.393495], $
            [ 0.459462,  0.141540], $
            [-0.414498, -0.192829], $
            [-0.183790,  0.082102], $
            [-0.079263, -0.317383], $
            [ 0.102254,  0.299133], $
            [ 0.164216, -0.054399] $
            ]
        njitter = 8
        end
    else : begin
        jitter = [ $
            [-0.208147,  0.353730], $
            [ 0.203849, -0.353780], $
            [-0.292626, -0.149945], $
            [ 0.296924,  0.149994] $
            ]
        njitter = 4
        end
    endcase

w->GetProperty, dimension=d
acc = fltarr(3, d[0], d[1])

if obj_isa(v, 'IDLgrView') then begin
    nViews = 1
    oViews = objarr(1)
    oViews[0] = v
    end $
else begin
    nViews = v->count()
    oViews = v->get(/all)
end

rects = fltarr(4, nViews)
for j=0,nViews-1 do begin
    oViews[j]->GetProperty, viewplane_rect=viewplane_rect
    rects[*,j] = viewplane_rect
    end

for i=0,njitter-1 do begin
    for j=0,nViews-1 do begin
        sc = rects[2,j] / float(d[0])
        oViews[j]->setproperty, view=[ $
            rects[0,j] + jitter[0,i] * sc, $
            rects[1,j] + jitter[1,i] * sc, $
            rects[2,j], $
            rects[3,j] $
            ]
        end

    demo_draw, w, v
    img = w->read()
    img->GetProperty ,data=data
    acc = acc + float(data)
    obj_destroy, img

    for j=0,nViews-1 do begin
        oViews[j]->setproperty, viewplane_rect=rects[*,j]
        end
    end

acc = acc / float(njitter)

o = obj_new('IDLgrImage',acc)

v2 = obj_new('IDLgrView', view=[0,0,d[0],d[1]], proj=1)
m = obj_new('IDLgrModel')
m->add, o
v2->add, m

demo_draw, w, v2

obj_destroy, v2

end

;----------------------------------------------------------------------------
function d_objworld2MakeView, xdim, ydim, uval
;
;Compute viewplane rect based on aspect ratio.
;
aspect = xdim / float(ydim)
myview = [-1, -1, 2, 2] * sqrt(2)
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
v = obj_new('IDLgrView', $
    projection=2, $
    eye=3, $
    zclip=[1.5,-1.5], $
    dim=[xdim,ydim],$
    viewplane_rect=myview, $
    color=[30,30,60], $
    uvalue=uval $
    )
;
;Create model.
;
gg = obj_new('IDLgrModel')
g = obj_new('IDLgrModel')
gg->add,g
;
;Create the base plate.
;
b_verts = fltarr(3,5,5)
b_conn = lonarr(5,16)
vert_cols = bytarr(3,25)

j = 0
for i=0,15 do begin
    b_conn[0,i] = 4
    b_conn[1,i] = j
    b_conn[2,i] = j+1
    b_conn[3,i] = j+6
    b_conn[4,i] = j+5
    j = j + 1
    if (j MOD 5) EQ 4 then $
        j = j + 1
    end

k = 0
for i=0,4 do begin
    for j=0,4 do begin
        b_verts[0,i,j] = i
        b_verts[1,i,j] = j
        b_verts[2,i,j] = 0
        if (k EQ 1) then begin
            vert_cols[*, i+j*5] = [40,40,40]
            end $
        else begin
            vert_cols[*, i+j*5] = [255,255,255]-40
            end
        k = 1 - k
        end
    end

b_verts[0,*,*] = (b_verts[0,*,*]-2)/2.0
b_verts[1,*,*] = (b_verts[1,*,*]-2)/2.0
baseplate = obj_new('IDLgrPolygon', $
    b_verts, $
    poly=b_conn, $
    shading=0, $
    vert_colors=vert_cols $
    )

g->add, baseplate
;
;Define the object tree add point.
;
g->add, obj_new('IDLgrModel')
;
;Add some lights.
;
gg->add, obj_new('IDLgrLight', $
    loc=[2,2,5], $
    type=2, $ ; Directional (parallel rays).
    color=[255,255,255], $
    intensity=.5 $
    )
gg->add, obj_new('IDLgrLight', $
    type=0, $ ; Ambient.
    intensity=.5, $
    color=[255,255,255] $
    )
;
;Place the model in the view.
;
v->add, gg
;
return, v

end

;----------------------------------------------------------------------------
pro d_objworld2GetViewObjs, view, oWorldRotModel, oBasePlatePolygon, model_top
;
;Luckily, this portion of the hierarchy is fixed...
;
gg = view->get()
oWorldRotModel = gg->get(pos=0)
oBasePlatePolygon = oWorldRotModel->get(pos=0)
model_top = oWorldRotModel->get(pos=1)

end

;----------------------------------------------------------------------------
pro d_objworld2Cone,verts,conn,n

verts = fltarr(3,n+1)
verts[0,0] = 0.0
verts[1,0] = 0.0
verts[2,0] = 0.1
t = 0.0
tinc = (2.*!PI)/float(n)
for i=1,n do begin
    verts[0,i] = 0.1*cos(t)
    verts[1,i] = 0.1*sin(t)
    verts[2,i] = -0.1
    t = t + tinc
    end
conn = fltarr(4*n+(n+1))
i = 0
conn[0] = n
for i=1,n do conn[i] = (n-i+1)
j = n+1
for i=1,n do begin
    conn[j] = 3
    conn[j+1] = i
    conn[j+2] = 0
    conn[j+3] = i + 1
    if (i EQ n) then conn[j+3] = 1
    j = j + 4
    end
end
;----------------------------------------------------------------------------
function d_objworld2MakeObj,type,thefont

oModel  = obj_new('IDLgrModel')
case type of
    0 : begin
        s = obj_new('orb',color=[255,0,0],radius=0.1,shading=1,$
            select_target=1)
        str = "Sphere"
        end
    1 : begin
        verts = [[-0.1,-0.1,-0.1],[0.1,-0.1,-0.1],[0.1,0.1,-0.1], $
            [-0.1,0.1,-0.1], $
            [-0.1,-0.1,0.1],[0.1,-0.1,0.1],[0.1,0.1,0.1],$
            [-0.1,0.1,0.1]]
        conn = [[4,3,2,1,0],[4,4,5,6,7],[4,0,1,5,4],[4,1,2,6,5], $
            [4,2,3,7,6],[4,3,0,4,7]]
        s = obj_new('IDLgrPolygon',verts,poly=conn,color=[0,255,0],$
            shading=0)
        str = "Cube"
        end
    2 : begin
        d_objworld2Cone,verts,conn,3
        s = obj_new('IDLgrPolygon',verts,poly=conn,$
            color=[0,255,255],shading=0)
        str = "Tetrahedron"
        end
    3 : begin
        d_objworld2Cone,verts,conn,20
        s = obj_new('IDLgrPolygon',verts,poly=conn,$
            color=[255,128,255],shading=1)
        str = "Cone"
        end
    4 : begin
        d_objworld2Cone,verts,conn,4
        l = obj_new('IDLgrPolygon',verts*0.5,poly=conn,$
        color=[100,255,100],shading=0)
        oModel->add,l
        l = obj_new('IDLgrPolyline',[[0,0,0],[0,0,-0.1]],$
        color=[100,255,100])
        oModel->add,l
        s = obj_new('IDLgrLight',loc=[0,0,0],dir=[0,0,-1],cone=40,$
            focus=0,type = 3,color=[100,255,100])
        str = "Green Light"
        end
    5 : begin
        ;  Surface data is read from elevation data file.
        e_height = BYTARR(64,64, /NOZERO)
        OPENR, lun, /GET_LUN, demo_filepath('elevbin.dat', $
            SUBDIR=['examples','data'])
        READU, lun, e_height
        FREE_LUN, lun
        zdata = e_height / (1.7 * max(e_height)) + .001
        xdata = (findgen(64)-32.0)/64.0
        ydata = (findgen(64)-32.0)/64.0
        s = obj_new('IDLgrSurface',zdata,shading=1,style=2,$
            datax=xdata,datay=ydata,color=[150,50,150])
        str = "Surface"
        end
    6 : begin
        ctab = d_objworld2ReadPalette(26)
        restore, demo_filepath('marbells.dat', $
            subdir=['examples','data'])
        image = bytscl(elev, min=2658, max=4241)
        image = image[8:*, *] ; Trim unsightly junk from left side.
        sz = size(image)
        img = bytarr(3,sz[1],sz[2])
        img[0,*,*] = ctab[0,image]
        img[1,*,*] = ctab[1,image]
        img[2,*,*] = ctab[2,image]
        oTextureImage = obj_new('IDLgrImage', $
            img, $
            loc=[0.0,0.0],$
            dim=[0.01,0.01], $
            hide=1 $
            )
        oModel->getProperty,uvalue=uval
        uval = n_elements(uval) GT 0 ? [uval,oTextureImage] : [oTextureImage]
        oModel->setProperty,uvalue=uval
;        oModel->add, oTextureImage
        xp=0.5
        yp=0.5*(72./92.)
        zp=0.1
        s=obj_new('IDLgrPolygon',$
            [[-xp,-yp,zp],[xp,-yp,zp],[xp,yp,zp],[-xp,yp,zp]],$
            texture_coord=[[0,0],[1,0],[1,1],[0,1]],$
            texture_map=oTextureImage, $
            color=[255,255,255] $
            )
        str = "Image"
        end
    7 : begin
        d_objworld2Cone, verts, conn, 4
        oModel->add, obj_new('IDLgrPolygon', $
            verts*0.5, $
            poly=conn, $
            color=[255,255,255], $
            shading=0 $
            )
        oModel->add, obj_new('IDLgrPolyline', $
            [[0,0,0], [0,0,-0.1]],$
            color=[255,255,255] $
            )
        s = obj_new('IDLgrLight', $
            loc=[0,0,0], $
            dir=[0,0,-1], $
            cone=20,$
            focus=0, $
            type=3, $
            color=[255,255,255] $
            )
        str = "White Light"
        end
    8 : begin
        s=obj_new('IDLgrText', $
            "IDL", $
            location=[0,0,0.001], $
            align=0.5, $
            color=[255,0,255], $
            font=thefont[0] $
            )
        str = "Text"
        end
    9 : begin
        ; Data for plot generated from Magnitude example
        ; in Chapter 13, "Signal Processing", of _Using IDL_.

        N = 1024       ; number of time samples in data set
        delt = 0.02    ; sampling interval in seconds

        U = -0.3 $     ;  DC component
          + 1.0 * Sin(2*!Pi* 2.8 *delt*FIndGen(N)) $ ;2.8 c/s comp
          + 1.0 * Sin(2*!Pi* 6.25*delt*FIndGen(N)) $ ;6.25 c/s comp
          + 1.0 * Sin(2*!Pi*11.0 *delt*FIndGen(N)); 11.0 c/s comp

        V = fft(U) ; compute spectrum v

        ; signal_x is [0.0, 1.0/(N*delt), ... , 1.0/(2.0*delt)]
        signal_x = FINDGEN(N/2+1) / (N*delt)

        mag = ABS(V[0:N/2]); magnitude of first half of v
        signal_y = 20*ALOG10(mag)

        ; phase not used here, included for completeness
        phi = ATAN(V[0:N/2]) ; phase of first half of v

        xc=[-0.5,1.0/25.0]
        yc=[0.5,1.0/80.0]
        s=obj_new('IDLgrPolygon', $
            [[-7,-90,-0.002],[30,-90,-0.002],$
            [30,10,-0.002],[-7,10,-0.002]],$
            color=[0,0,0], $
            xcoord_conv=xc, $
            ycoord_conv=yc $
            )
        oModel->add,s
        s=obj_new('IDLgrAxis', $
            0, $
            range=[0.0,25.0],$
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            location=[0,-80.0], $
            color=[128,60,39], $
            ticklen=5, $
            /exact $
            )
        s->GetProperty,ticktext=tt
        tt->setproperty,font=thefont[3]
        oModel->add,s
        s=obj_new('IDLgrAxis', $
            0, $
            range=[0.0,25.0], $
            /notext,$
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            location=[0.0,0.0], $
            color=[128,60,39], $
            ticklen=-5, $
            /exact $
            )
        oModel->add,s
        s=obj_new('IDLgrAxis', $
            1, $
            range=[-80.0,0.0],$
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            color=[128,60,39], $
            ticklen=1.0, $
            /exact $
            )
        s->GetProperty,ticktext=tt
        tt->setproperty,font=thefont[3]
        oModel->add,s
        s=obj_new('IDLgrAxis', $
            1, $
            range=[-80.0,0.0], $
            /notext,$
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            loc=[25.0,0.0], $
            color=[128,60,39], $
            ticklen=-1.0, $
            /exact $
            )
        oModel->add,s
        s=obj_new('idlgrplot', $
            signal_x, $
            signal_y, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            color=[0,255,255] $
            )
        str = "Plot"
        end
    10 : begin
        x=indgen(200)
        yexp = exp(-x*0.015)
        ysexp = exp(-x*0.015)*sin(x*0.1)
        dataz=fltarr(200,5)
        dataz[*,0] = yexp
        dataz[*,1] = yexp
        dataz[*,2] = REPLICATE(1.1,200)
        dataz[*,3] = ysexp-0.01
        dataz[*,4] = ysexp-0.01
        datay = fltarr(200,5)
        datay[*,0] = 0.0
        datay[*,1] = 1.0
        datay[*,2] = 0.0
        datay[*,3] = 0.0
        datay[*,4] = 1.0
        cbins = bytarr(3,60)
        for i=0,59 do begin
            color_convert, float(i)*4., 1., 1., r,g,b, /HSV_RGB
            cbins[*,59-i] = [r,g,b]
            end
        colors = bytarr(3,200*5)
        colors[0,0:599] = REPLICATE(80,3*200)
        colors[1,0:599] = REPLICATE(80,3*200)
        colors[2,0:599] = REPLICATE(200,3*200)
        colors[*,600:799] = cbins[*,(ysexp+1.0)*30.0]
        colors[*,800:999] = cbins[*,(ysexp+1.0)*30.0]
        xc = [-0.5,1.0/200.0]*0.8
        yc = [-0.5,1.0/1.0]*0.1
        zc = [-0.5,1.0/1.0]*0.4
        s=obj_new('IDLgrAxis', $
            0, $
            range=[0,200],$
            color=[255,255,255], $
            ticklen=0.2, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        oModel->add,s
        s=obj_new('IDLgrAxis', $
            2, $
            range=[-1.,1.],$
            color=[255,255,255], $
            ticklen=4, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        oModel->add,s
        s=obj_new('IDLgrSurface', $
            dataz, $
            style=2, $
            vert_colors=colors,$
            datay=datay, $
            max_value=1.05, $
            shading=1, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        oModel->add,s
        s=obj_new('IDLgrSurface', $
            dataz, $
            style=3, $
            color=[0,0,0],$
            datay=datay, $
            max_value=1.05, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        str = 'Ribbon Plot'
        end
    11 : begin
        dataz = dist(8)
        dataz[1,*] = -1
        dataz[3,*] = -1
        dataz[5,*] = -1
        dataz[*,1] = -1
        dataz[*,3] = -1
        dataz[*,5] = -1
        dataz = dataz + 1
        cbins=[ $
            [255,0,0],$
            [255,85,0],$
            [255,170,0],$
            [255,255,0],$
            [170,255,0],$
            [85,255,0],$
            [0,255,0] $
            ]
        colors = bytarr(3, 8*8)
        minz = min(dataz)
        maxz = max(dataz)
        zi = round((dataz - minz)/(maxz-minz) * 6.0)
        colors[*,*] = cbins[*,zi]
        xc = [-0.5,1.0/8.0]*0.4
        yc = [-0.5,1.0/8.0]*0.4
        zc = [0,1.0/8.0]*0.4
        s=obj_new('IDLgrAxis', $
            0, $
            range=[0,8], $
            major=5, $
            color=[255,255,255], $
            ticklen=0.2, $
            /exact, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        oModel->add,s
        s=obj_new('IDLgrAxis', $
            1, $
            range=[0,8], $
            major=5,$
            color=[255,255,255], $
            ticklen=0.2, $
            /exact, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
         oModel->add,s
         s=obj_new('IDLgrAxis', $
            2, $
            range=[0,8], $
            major=5,$
            color=[255,255,255], $
            ticklen=0.2, $
            /exact, $
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        oModel->add,s
        s=obj_new('IDLgrSurface', $
            dataz, $
            STYLE=6, $
            VERT_COLORS=colors,$
            xcoord_conv=xc, $
            ycoord_conv=yc, $
            zcoord_conv=zc $
            )
        str = 'Bar Plot'
        end
    12 : begin
        ;  Surface data is read from elevation data file.
        e_height = bytarr(64,64, /nozero)
        openr, lun, /get_lun, demo_filepath('elevbin.dat', $
            subdir=['examples','data'])
        readu, lun, e_height
        free_lun, lun

        ;Get image data for texture map.
        read_jpeg, $
            demo_filepath( $
                'elev_t.jpg', $
                subdir=['examples','data'] $
                ), $
            e_image, $
            true=3

        zm=max(e_height)
        zdata = float(e_height)/(1.7*float(zm))
        xdata = (findgen(64)-32.0)/64.0
        ydata = (findgen(64)-32.0)/64.0
        oTextureImage = obj_new('IDLgrImage', $
            e_image, $ ;>255, $
            hide=1, $
;            dim=[0.01,0.01], $
            interleave=2 $
            )
        oModel->getProperty,uvalue=uval
        uval = n_elements(uval) GT 0 ? [uval,oTextureImage] : [oTextureImage]
        oModel->setProperty,uvalue=uval
;        oModel->add, oTextureImage
        s = obj_new('IDLgrSurface', $
            zdata, $
            shading=1, $
            style=2,$
            datax=xdata, $
            datay=ydata, $
            color=[255,255,255], $
            TEXTURE_MAP=oTextureImage $
            )
        str = "Textured Surface"
        end
    endcase
oModel->Add, s
oModel->SetProperty, name=str
; oModel->SetProperty, uvalue=str

return, oModel
end
;----------------------------------------------------------------------------
pro d_objworld2NewMode, state, mode
widget_control, /hourglass
state.oModelMan->SetProperty, mode=mode
widget_control, state.wModelModeRadio, set_value=mode
end
;----------------------------------------------------------------------------
pro d_objworld2Add, state, oModel, as_child=as_child
;
;Procedure d_objworldAdd: Add oModel to objworld's graphics tree.
;
if keyword_set(as_child) then $
    state.selected->add, oModel $
else $
    state.oCurrentTopModel->add, oModel

state.oCurrentView->GetProperty, uvalue=view_uval
*(state.model_lists[view_uval.num]) = $
    [oModel, *(state.model_lists[view_uval.num])]
state.model_cycle_pos = 0
;
;Make the new object be the current selection...
;
state.selected = oModel
g = oModel->get(pos=0)
if (obj_isa(g,'IDLgrText')) then begin
    rect = state.win->gettextdimensions(g)
    end

state.oModelMan->SetTarget, state.selected
state.selected->GetProperty, name=s
; state.selected->GetProperty, uvalue=s
str = "Current selection:" + s
widget_control, state.text, set_value=str
widget_control, state.wModelDeleteButton, sensitive=1
widget_control, state.wAddChildButton, sensitive=1
widget_control, state.wUnselectButton, sensitive=1
widget_control, state.wModelModeRadio, sensitive=1
widget_control, state.wSaveButton, sensitive=([1,0])[lmgr(/demo)]
widget_control, state.wModelSelectButton, $
    sensitive= $
        n_elements(*(state.model_lists[view_uval.num])) gt 2

demo_draw, state.win, state.scene, debug=state.debug
end

;----------------------------------------------------------------------------
Function d_objworld2ToggleState, wid

widget_control, wid, get_value=name

s = strpos(name,'(off)')
if (s NE -1) then begin
    strput,name,'(on )',s
    ret = 1
    end $
else begin
    s = strpos(name,'(on )')
    strput,name,'(off)',s
    ret = 0
    end

widget_control, wid, set_value=name
return,ret
end
;----------------------------------------------------------------------------
pro d_objworld2Cleanup, wTopBase

widget_control, wtopbase, get_uvalue=state, /no_copy
;
;Remove manipulators.
;
state.oModelMan->SetTarget,obj_new()
state.oViewMan->SetTarget,obj_new(),state.win
;
;Clean up heap variables.
;
for i=0,n_tags(state)-1 do begin
  case size(state.(i), /TNAME) of
    'POINTER': $
      ptr_free, state.(i)
    'OBJREF': $
      obj_destroy, state.(i)
    else:
  endcase
end
;
;Restore the color table.
;
tvlct, state.colortable

if widget_info(state.groupbase, /valid_id) then $
    widget_control, state.groupbase, /map

end
;----------------------------------------------------------------------------
pro d_objworld2Event, ev

widget_control, ev.top, get_uvalue=state, /no_copy
demo_record, ev, $
    filename=state.record_to_filename, $
    cw=state.wModelModeRadio
widget_control, ev.top, set_uvalue=state, /no_copy
;
;Shutdown.
;
if tag_names(ev, /structure_name) eq 'WIDGET_KILL_REQUEST' then begin
  ;; first destroy any objects held in the uvalues of oModels
  widget_control, ev.top, get_uvalue=state, /no_copy
  FOR i=0,state.highest_view_count-1 DO BEGIN
    IF ptr_valid(state.model_lists[i]) THEN BEGIN
      modelarr = *state.model_lists[i]
      FOR j=0,n_elements(modelarr)-2 DO BEGIN
        IF obj_valid(modelarr[j]) THEN BEGIN
          modelarr[j]->getproperty,uvalue=uval
          IF obj_valid(uval) THEN obj_destroy,uval
        ENDIF
      ENDFOR
    ENDIF
  ENDFOR
  widget_control, ev.top, set_uvalue=state, /no_copy
  ;; destroy top level base
  widget_control,ev.top,/destroy
  return
end
;
;If mouse buttons are down, only process draw widget events.
;
widget_control, ev.top, get_uvalue=state, /no_copy
widget_control, ev.id, get_uval=uval
if state.btndown eq 1 then begin
    if uval[0] eq 'DRAW' then begin
        if ev.type eq 0 then begin ; Button down event?...
            widget_control, ev.top, set_uvalue=state, /no_copy
            return ; ...ignore it.  A mouse button is already down.
            end
        end $
    else begin
        widget_control, ev.top, set_uvalue=state, /no_copy
        return
        end
    end
 widget_control, ev.top, set_uvalue=state, /no_copy
;
;Normal event handling.
;
case uval[0] of
    'QUIT' : begin
      ;; first destroy any objects held in the uvalues of oModels
      widget_control, ev.top, get_uvalue=state, /no_copy
      FOR i=0,state.highest_view_count-1 DO BEGIN
        IF ptr_valid(state.model_lists[i]) THEN BEGIN
          modelarr = *state.model_lists[i]
          FOR j=0,n_elements(modelarr)-2 DO BEGIN
            IF obj_valid(modelarr[j]) THEN BEGIN
              modelarr[j]->getproperty,uvalue=uval
              IF obj_valid(uval) THEN obj_destroy,uval
            ENDIF
          ENDFOR
        ENDIF
      ENDFOR
      widget_control, ev.top, set_uvalue=state, /no_copy
      ;; destroy top level base
      widget_control, ev.top, /destroy
      return
    end

    'ABOUT' : begin
        ONLINE_HELP, 'd_objworld2', $
           book=demo_filepath("idldemo.adp", $
                   SUBDIR=['examples','demo','demohelp']), $
                   /FULL_PATH
        end


    'VRML' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        if (state.oCurrentView NE obj_new()) then begin
            file = dialog_pickfile( $
                /write, $
                file='untitled.wrl', $
                group=ev.top, $
                filter='*.wrl' $
                )
            if (file NE '') then begin
                widget_control, /hourglass
                state.win->GetProperty, $
                    dimension=wdims, $
                    resolution=res,$
                    color_model=cm, $
                    n_colors=icolors
                oVRML = obj_new('IDLgrVRML', $
                    dimensions=wdims, $
                    resolution=res, $
                    color_model=cm, $
                    n_colors=icolors $
                    )
                oVRML->setproperty, filename=file
                demo_draw, oVRML, state.oCurrentView, debug=state.debug
                obj_destroy,oVRML
                end
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'CLIPBOARD' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        state.win->GetProperty, $
            dimension=wdims, $
            resolution=res, $
            color_model=cm, $
            n_colors=icolors
        oClipboard = obj_new('IDLgrClipboard', $
            dimensions=wdims, $
            resolution=res, $
            color_model=cm, $
            n_colors=icolors $
            )
        demo_draw, oClipboard, state.scene, debug=state.debug
        obj_destroy, oClipboard
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'PRINT' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        oPrinter = obj_new('IDLgrPrinter')
        if (dialog_printersetup(oPrinter)) then begin
            if (dialog_printjob(oPrinter)) then begin
                oPrinter->GetProperty,resolution=res
                DPI = 2.54/float(res)
                state.win->GetProperty,resolution=res
                DPI = 2.54/float(res)

                ;Hack, swap from pixels to inches for views...
                state.win->GetProperty, dimension=wdims
                oViews = state.scene->get(/all)
                for i=0,n_elements(oViews)-1 do begin
                    oViews[i]->IDLgrView::getproperty,$
                        loc=loc,dim=vdim
                    loc = loc/DPI
                    vdim = vdim/DPI
                    oViews[i]->IDLgrView::setproperty,$
                        loc=loc, dim=vdim, units=1
                    end

                ;...PRINT!...
                demo_draw, oPrinter, state.scene, debug=state.debug
                oPrinter->newdocument

                ;...and back to pixels
                for i=0,N_ELEMENTS(oViews)-1 do begin
                    oViews[i]->IDLgrView::getproperty,$
                        loc=loc,dim=vdim
                    loc = loc*DPI
                    vdim = vdim*DPI
                    oViews[i]->IDLgrView::setproperty,$
                        loc=loc,dim=vdim,units=0
                    end

                end
            end
        obj_destroy,oPrinter
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'AA' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        d_objworld2SceneAntiAlias, state.win, state.scene, 8
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'LOAD' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        if ((state.selected ne obj_new()) and $
            (state.cur_tool ne 1)) then begin
            file = dialog_pickfile( $
                /read, $
                /must_exist, $
                group=ev.top, $
                filter='*.sav' $
                )
            if (file NE '') then begin
                restore, file, /relaxed_structure_assignment
                d_objworld2Add, state, tmp_obj
                end
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'SAVE' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        if ((state.selected NE obj_new()) $
        and (state.selected NE state.oCurrentTopModel) $
        and (state.cur_tool NE 1)) then begin
            file = dialog_pickfile(/write, $
                file='untitled.sav', $
                group=ev.top, $
                filter='*.sav' $
                )
            if (file NE '') then begin
;
;               Isolate tmp_obj from the tree.
;
                state.selected->GetProperty, parent=parent
                parent->remove, state.selected
                state.oModelMan->SetTarget, obj_new()
                tmp_obj = state.selected
;
;               Save it.
;
                save, tmp_obj, filename=file
;
;               Repair the tree.
;
                parent->add, state.selected
                state.oModelMan->SetTarget, state.selected
                end
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'MODELSELECT': begin ; Select next object.
        widget_control, ev.top, get_uvalue=state, /no_copy
        wDraw = state.wDraw
        widget_control, ev.top, set_uvalue=state, /no_copy
        d_objworld2Event, { $
            id: wDraw, $
            top: ev.top, $
            handler: 0L, $
            type: 0, $; Button down
            press: 4, $ ; Right Mouse-button.
            x: -2, $
            y: -2  $
            }
        end
    'VIEWSELECT': begin ; Select next view.
        widget_control, ev.top, get_uvalue=state, /no_copy
        wDraw = state.wDraw
        widget_control, ev.top, set_uvalue=state, /no_copy
        d_objworld2Event, { $
            id: wDraw, $
            top: ev.top, $
            handler: 0L, $
            type: 0, $; Button down
            press: 4, $ ; Right Mouse-button.
            x: -2, $
            y: -2  $
            }
        end

    'UNSELECT': begin
        widget_control, /hourglass
        widget_control, ev.top, get_uvalue=state, /no_copy
        state.selected = state.oCurrentTopModel

        widget_control, state.wModelDeleteButton, sensitive=0
        widget_control, state.wAddChildButton, sensitive=0
        widget_control, state.wUnselectButton, sensitive=0
        widget_control, state.wModelModeRadio, sensitive=0
        widget_control, state.wModelSelectButton, sensitive=1
        widget_control, state.wSaveButton, sensitive=0

        widget_control, state.text, set_value="No current selection"
        state.oModelMan->SetTarget, obj_new()
        demo_draw, state.win, state.scene, debug=state.debug
        widget_control, ev.top, set_uvalue=state, /no_copy
        end

    'TOOL': begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        tool = d_objworld2ToggleState(state.wToolButton)
        case 1 of
            (state.cur_tool eq tool): ; Do Nothing...
            tool eq 1: begin ; View Manipulator tool selected.
                state.oModelMan->SetTarget, obj_new()
                state.oViewMan->SetTarget, state.oCurrentView, state.win
                state.selected = state.oCurrentView
                state.selected->GetProperty, uvalue=view_uvalue
                widget_control, state.text, $
                    set_value="Current selection:" + view_uvalue.name
                demo_draw, state.win, state.scene, debug=state.debug

                widget_control, state.wModelModeRadio, sensitive=0
                widget_control, state.wViewControlBase,  map=1
                widget_control, state.wModelControlBase, map=0
                widget_control, state.wLoadButton, sensitive=0
                widget_control, state.wSaveButton, sensitive=0

                state.cur_tool = 1
                end
            tool eq 0: begin ; Model Manipulator tool selected.
                state.oViewMan->SetTarget, obj_new(), state.win

                wDraw = state.wDraw
                state.cur_tool = 0
                widget_control, ev.top, set_uvalue=state, /no_copy
                d_objworld2Event, { $
                    id: wDraw, $
                    top: ev.top, $
                    handler: 0L, $
                    type: 0, $; Button down
                    press: 4, $ ; Right Mouse-button.
                    x: -1, $
                    y: -1  $
                    }
                widget_control, ev.top, get_uvalue=state, /no_copy
                widget_control, state.wViewControlBase,  map=0
                widget_control, state.wModelControlBase, map=1
                state.oCurrentView->GetProperty, uvalue=view_uval
                num = n_elements( $
                    *(state.model_lists[view_uval.num]) $
                    )
                widget_control, $
                    state.wModelSelectButton, $
                    sensitive=([0,1])[num gt 2]
                widget_control, state.wLoadButton, sensitive=1
                widget_control, $
                    state.wSaveButton, $
                    sensitive=([1,0])[lmgr(/demo)]
                end
            endcase
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'MODELMODE': begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        d_objworld2NewMode, state, ev.value
        demo_draw, state.win, state.scene, debug=state.debug
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'ADDVIEW': begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        state.win->GetProperty,dim=wdim
        state.oCurrentView = d_objworld2MakeView( $
            wdim[0], $
            wdim[1], $
            {name:'ObjView ' + strcompress(state.highest_view_count), $
                num: state.highest_view_count} $
            )
        state.model_lists[state.highest_view_count] = ptr_new(obj_new())
        state.oTrackballMB1->Reset, wdim/2.0, wdim[0]/2.0
        state.oTrackballMB2->Reset, wdim/2.0, wdim[0]/2.0, mouse=2
        state.view_count = state.view_count + 1
        state.highest_view_count = state.highest_view_count + 1
        state.scene->add, state.oCurrentView
        state.oViewMan->SetTarget, state.oCurrentView, state.win
        state.selected = state.oCurrentView
        state.oCurrentView->GetProperty, uvalue=view_uvalue
        widget_control, state.wViewDeleteButton, $
            sensitive=([0,1])[view_uvalue.num ne 0]
        widget_control, state.wViewSelectButton, sensitive=1
        d_objworld2GetViewObjs, state.selected, w,b,t
        state.oWorldRotModel = w
        state.oBasePlatePolygon = b
        state.oCurrentTopModel = t
        str = "Current selection:" + view_uvalue.name
        widget_control, state.text, set_value=str
        demo_draw, state.win, state.scene, debug=state.debug
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'ADD': begin
        widget_control, /hourglass
        widget_control, ev.top, get_uvalue=state, /no_copy
        if state.oBasePlatePolygon ne obj_new() then begin
            d_objworld2Add, $
                state, $
                d_objworld2MakeObj( $
                    (where(state.addable_subjects eq uval[1]))[0], $
                    state.theFont $
                    )
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'ADDCHILD': begin
        widget_control, /hourglass
        widget_control, ev.top, get_uvalue=state, /no_copy
        if state.oBasePlatePolygon ne obj_new() then begin
            d_objworld2Add, $
                state, $
                d_objworld2MakeObj( $
                    (where(state.addable_subjects eq uval[1]))[0], $
                    state.theFont $
                    ), $
                /as_child
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end

    'DEL': begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        if ((state.selected ne obj_new()) AND $
            (state.selected ne state.oCurrentTopModel)) then begin
            if (state.cur_tool eq 1) then begin
                state.selected->GetProperty, uvalue=uvalue
                if (uvalue.num ne 0) then begin ; cannot delete first one
                    state.oViewMan->SetTarget, obj_new(), state.win
                    state.selected->GetProperty, parent=p
                    p->remove, state.selected
                    state.selected->getProperty,uvalue=uval
                    IF obj_valid(uval[0]) THEN obj_destroy,uval
                    obj_destroy, state.selected
                    state.view_count =state.view_count - 1

                    widget_control, state.wViewSelectButton, $
                        sensitive=([0,1])[state.view_count gt 1]

                    ; select next view.
                    wDraw = state.wDraw
                    widget_control, ev.top, set_uvalue=state, /no_copy
                    d_objworld2Event, { $
                        id: wDraw, $
                        top: ev.top, $
                        handler: 0l, $
                        type: 0, $  ; Button down
                        press: 4, $ ; Right Mouse-button.
                        x: -2, $
                        y: -2  $
                        }
                    widget_control, ev.top, get_uvalue=state, /no_copy
                    end $
                else begin
                    widget_control, state.text, $
                        set_value="Cannot delete initial view"
                    end
                end $
            else begin ; Current tool is Model Manipulator
                state.oModelMan->SetTarget, obj_new()
                state.selected->GetProperty, parent=p
                p->remove, state.selected
                state.selected->getProperty,uvalue=obj_uval
                IF (N_Elements(obj_uval) gt 0 && Obj_Valid(obj_uval[0])) then obj_destroy,obj_uval
                obj_destroy, state.selected
                state.oCurrentView->GetProperty, uvalue=view_uval
                indx = where( $
                    obj_valid(*(state.model_lists[view_uval.num])), $
                    count $
                    )
                if indx[0] eq -1 then begin
                    *(state.model_lists[view_uval.num]) = obj_new()
                    state.selected = state.oCurrentTopModel
                    str = "No current selection"
                    widget_control, state.text, set_value=str
                    widget_control, state.wModelDeleteButton, sensitive=0
                    widget_control, state.wAddChildButton, sensitive=0
                    widget_control, state.wUnselectButton, sensitive=0
                    widget_control, state.wModelSelectButton, sensitive=0
                    widget_control, state.wSaveButton, sensitive=0
                    widget_control, state.wModelModeRadio, sensitive=0
                    demo_draw, state.win, state.scene, debug=state.debug
                    end $
                else begin
                    *(state.model_lists[view_uval.num]) = [ $
                        (*(state.model_lists[view_uval.num])) $
                            [indx], $
                        obj_new() $
                        ]
;
;                   Select something.
;
                    wDraw = state.wDraw
                    widget_control, ev.top, set_uvalue=state, /no_copy
                    d_objworld2Event, { $
                        id: wDraw, $
                        top: ev.top, $
                        handler: 0L, $
                        type: 0, $  ; Button down
                        press: 4, $ ; Right Mouse-button.
                        x: -1, $
                        y: -1  $
                        }
                    return
                    end
                end
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'DRAGQLOW' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        state.dragq = 0
        widget_control, state.wDragQLow,    sensitive=0
        widget_control, state.wDragQMedium, sensitive=1
        widget_control, state.wDragQHigh,   sensitive=1
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'DRAGQMEDIUM' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        state.dragq = 1
        widget_control, state.wDragQLow,    sensitive=1
        widget_control, state.wDragQMedium, sensitive=0
        widget_control, state.wDragQHigh,   sensitive=1
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'DRAGQHIGH' : begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        state.dragq = 2
        widget_control, state.wDragQLow,    sensitive=1
        widget_control, state.wDragQMedium, sensitive=1
        widget_control, state.wDragQHigh,   sensitive=0
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'GRID' : begin
        widget_control, /hourglass
        widget_control, ev.top, get_uvalue=state, /no_copy
        if (OBJ_VALID(state.oCurrentView)) then begin
            if (OBJ_VALID(state.oBasePlatePolygon)) then begin
                state.oBasePlatePolygon->SetProperty, $
                    hide=1-d_objworld2ToggleState(state.wGridButton)
                demo_draw, state.win, state.scene, debug=state.debug
                end
            end
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'DRAW': begin
        widget_control, ev.top, get_uvalue=state, /no_copy

        ; Expose.
        if (ev.type EQ 4) then $
            demo_draw, state.win, state.scene, debug=state.debug

        ; Handle trackball updates.
        if state.oTrackballMB2->Update(ev, transform=qmat) then begin
            state.oWorldRotModel->GetProperty, transform=t
            mt = t # qmat
            state.oWorldRotModel->setproperty,transform=mt
            demo_draw, state.win, state.scene, debug=state.debug
            end
        have_mb1_transform = $
            state.oTrackballMB1->Update(ev, transform=mb1_transform)

        ; Handle other events (selection, etc.) ...
        case ev.type of
            0 : begin ; Button press
                case 1 of
                    (ev.press EQ 4) AND (state.cur_tool EQ 1): begin
                        widget_control, /hourglass
                        if ev.x eq -2 then begin
                            picked = state.scene->Get()
                            end $
                        else begin
                            state.oViewMan->SetProperty,hide=1
                            picked = state.win->select(state.scene, [ev.x,ev.y])
                            state.oViewMan->SetProperty, hide=0
                            end
                        if obj_valid(picked[0]) then begin
                            state.selected = picked[0]
                            state.selected->GetProperty,uvalue=view_uvalue
                            widget_control, $
                                state.wViewDeleteButton, $
                                sensitive=([1,0])[view_uvalue.num eq 0]
                            str = "Current selection:" + view_uvalue.name

                            ; "pop" the view
                            state.scene->remove, picked[0]
                            state.scene->add, picked[0]
                            end $
                        else begin
                            state.selected = obj_new()
                            str = "No current selection"
                            end

                        ; point the oViewMan at the node...
                        state.oViewMan->GetProperty, target=manip
                        if (manip ne state.selected) then begin
                            state.oViewMan->SetTarget,obj_new(),state.win
                            end
                        if state.selected ne obj_new() then begin
                            state.oCurrentView = state.selected
                            state.oCurrentView->GetProperty,dim=dim,loc=loc
                            state.oTrackballMB1->Reset, loc + dim/2.0, $
                                dim[0]/2.0
                            state.oTrackballMB2->Reset, loc + dim/2.0, $
                                dim[0]/2.0, $
                                mouse=2
                            d_objworld2GetViewObjs,state.selected,w,b,t
                            state.oWorldRotModel = w
                            state.oBasePlatePolygon = b
                            state.oCurrentTopModel = t
                            state.oViewMan->SetTarget,state.selected,state.win
                            end
                        widget_control, state.text, set_value=str
                        state.win->draw,state.scene
                        demo_draw, state.win, state.scene, debug=state.debug
                        end
                    ev.press EQ 4: begin
                        widget_control, /hourglass
                        if ev.x lt 0 then begin
                            state.oCurrentView->GetProperty, uvalue=view_uval
                            if (n_elements(*(state.model_lists[view_uval.num])) gt 1) then begin
                                state.model_cycle_pos = state.model_cycle_pos + ([0,1])[abs(ev.x) - 1]
                                ; Last item on list is obj_new()
                                state.model_cycle_pos = state.model_cycle_pos $
                                    mod (n_elements(*(state.model_lists[view_uval.num])) - 1)
                                picked = (state.model_cycle_pos ge 0) ? $
                                    ((*(state.model_lists[view_uval.num]))[state.model_cycle_pos])->get() : obj_new()
                            endif else begin
                                picked = obj_new()
                            endelse
                        endif else begin
                            state.oModelMan->setproperty,hide=1
                            picked = state.win->select( $
                                state.oCurrentView,[ev.x,ev.y] $
                                )
                            state.oModelMan->setproperty,hide=0
                        endelse
                        if obj_valid(picked[0]) then begin
                            if (picked[0] EQ state.oBasePlatePolygon) $
                            then begin
                                state.selected = state.oCurrentTopModel
                                str = "No current selection"

                                widget_control, state.wModelDeleteButton, $
                                    sensitive=0
                                widget_control, state.wAddChildButton, $
                                    sensitive=0
                                widget_control, state.wUnselectButton, $
                                    sensitive=0
                                widget_control, state.wSaveButton, $
                                    sensitive=0
                                end $
                            else begin
                                ;HACK - for the sphere objs, we use the
                                ;IDLgrModel::getproperty directly
                                if (obj_isa(picked[0],'IDLgrModel') EQ 1) $
                                then begin
                                    picked[0]->IDLgrModel::getproperty,parent=p
                                    end $
                                else begin
                                    picked[0]->GetProperty, parent=p
                                    end

                                if (state.selected EQ p) then begin
                                    state.oModelMan->GetProperty, mode=mode
                                    d_objworld2NewMode, $
                                        state, $
                                        (mode + 1) mod 3
                                    end

                                state.oCurrentView->GetProperty, $
                                    uvalue=view_uval
                                state.model_cycle_pos = $
                                    where(*(state.model_lists[view_uval.num]) eq p)
                                state.selected = p
                                state.selected->GetProperty, name=s
                                str = "Current selection:" + s
                                widget_control, state.wModelDeleteButton, $
                                    sensitive=1
                                widget_control, state.wAddChildButton, $
                                    sensitive=1
                                widget_control, state.wUnselectButton, $
                                    sensitive=1
                                widget_control, state.wModelModeRadio, $
                                    sensitive=1
                                widget_control, state.wSaveButton, $
                                    sensitive=([1,0])[lmgr(/demo)]

                                state.oCurrentView->GetProperty, $
                                    uvalue=view_uval
                                if n_elements( $
                                    *(state.model_lists[view_uval.num]) $
                                    ) le 2 then widget_control, $
                                        state.wModelSelectButton, $
                                        sensitive=0
                                end
                            end $
                        else begin
                            state.selected = state.oCurrentTopModel
                            str = "No current selection"

                            widget_control, state.wModelDeleteButton, $
                                sensitive=0
                            widget_control, state.wAddChildButton, sensitive=0
                            widget_control, state.wUnselectButton, sensitive=0
                            widget_control, state.wModelModeRadio, sensitive=0

                            ; try to change the current view...
                            if ev.x ge 0 then begin
                                state.oViewMan->setproperty,hide=1
                                picked = state.win->select(state.scene,[ev.x,ev.y])
                                state.oViewMan->setproperty, hide=0
                                si = size(picked)
                                if (si[0] ne 0) then begin
                                    if (picked[0] ne state.oCurrentView) then begin
                                        state.oCurrentView = picked[0]
                                        state.oCurrentView->GetProperty,dim=dim,loc=loc
                                        state.oTrackballMB1->Reset, loc + dim/2.0, $
                                            dim[0]/2.0
                                        state.oTrackballMB2->Reset, loc + dim/2.0, $
                                            dim[0]/2.0, $
                                            mouse=2
                                        d_objworld2GetViewObjs, $
                                            state.oCurrentView, $
                                            w,$
                                            b,$
                                            t
                                        state.oWorldRotModel = w
                                        state.oBasePlatePolygon = b
                                        state.oCurrentTopModel = t
                                        state.selected = state.oCurrentTopModel
                                        str = "New view selected"
                                        widget_control, $
                                            state.wModelDeleteButton, $
                                            sensitive=0
                                        widget_control, $
                                            state.wAddChildButton, $
                                            sensitive=0

                                        ; pop it
                                        state.scene->remove, state.oCurrentView
                                        state.scene->add, state.oCurrentView
                                        end
                                    end
                                end

                            state.oCurrentView->GetProperty, uvalue=view_uval
                            if n_elements( $
                                *(state.model_lists[view_uval.num]) $
                                ) gt 1 then widget_control, $
                                    state.wModelSelectButton, $
                                    sensitive=1

                            end

                        ; point the oModelMan at the node...
                        state.oModelMan->GetProperty,target=manip
                        if (manip ne state.selected) then begin
                            state.oModelMan->SetTarget,obj_new()
                            end
                        if ((state.selected ne state.oCurrentTopModel) and $
                            (state.selected ne obj_new())) then begin
                            state.oModelMan->SetTarget,state.selected
                            end

                        widget_control, state.text, set_value=str
                        demo_draw, state.win, state.scene, debug=state.debug

                        end
                    ev.press EQ 2: begin
                        state.win->setproperty, QUALITY=state.dragq
                        widget_control,state.wDraw,/draw_motion
                        end
                    (ev.press EQ 1) and (state.cur_tool EQ 1): begin
                        if (state.selected ne obj_new()) then begin
                            state.oViewMan->MouseDown,[ev.x,ev.y],state.win
                            state.btndown = 1b
                            state.win->setproperty, QUALITY=state.dragq
                            widget_control,state.wDraw,/draw_motion
                            demo_draw, $
                                state.win, $
                                state.scene, $
                                debug=state.debug
                            end
                        end
                    ev.press EQ 1: begin
                        state.win->SetProperty, QUALITY=state.dragq
                        widget_control, state.wDraw, /draw_motion
                        state.btndown = 1b
                        if ((state.selected ne state.oCurrentTopModel) and $
                            (state.selected ne obj_new())) then begin
                            state.oModelMan->MouseDown, $
                                [ev.x,ev.y], $
                                state.win
                            end
                        end
                    else: print, 'Ouch!'
                    endcase
                end

            2: begin ; Button motion.
                if state.btndown eq 1b then begin
                    case 1 of
                        state.cur_tool EQ 1: begin
                            state.oViewMan->MouseTrack, [ev.x,ev.y], state.win
                            demo_draw, $
                                state.win, $
                                state.scene, $
                                debug=state.debug
                            state.oCurrentView->GetProperty,dim=dim,loc=loc
                            state.oTrackballMB1->Reset, loc + dim/2.0, $
                                dim[0]/2.0
                            state.oTrackballMB2->Reset, loc + dim/2.0, $
                                dim[0]/2.0, $
                                mouse=2
                            end
                        (state.selected ne state.oCurrentTopModel) and $
                        (state.selected ne obj_new()): begin
                            state.oModelMan->MouseTrack, [ev.x,ev.y], $
                                state.win
                            demo_draw, $
                                state.win, $
                                state.scene, $
                                debug=state.debug
                            end
                        else: begin
                            ; Rotate.
                            if have_mb1_transform then begin
                                state.oWorldRotModel->GetProperty, $
                                    transform=t
                                state.oWorldRotModel->SetProperty, $
                                    transform=t # mb1_transform
                                demo_draw, $
                                    state.win, $
                                    state.scene, $
                                    debug=state.debug
                                end
                            end
                        endcase
                    end
                end

            1: begin ; Button release.
                if state.btndown eq 1b then begin
                    case 1 of
                        state.cur_tool EQ 1: $
                            state.oViewMan->MouseUp,[ev.x,ev.y],state.win
                        (state.selected ne state.oCurrentTopModel) and $
                        (state.selected ne obj_new()): $
                            state.oModelMan->MouseUp, [ev.x,ev.y], state.win
                        else:
                        endcase
                    end
                state.btndown = 0b
                state.win->setproperty, QUALITY=2
                demo_draw, state.win, state.scene, debug=state.debug
                widget_control,state.wDraw,draw_motion=0
                end
            else:
            endcase
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    'HOTKEY': begin
        widget_control, ev.top, get_uvalue=state, /no_copy
        case strupcase(ev.ch) of
            ' ': begin ; "Next" select.
;
;               Determine how many things there thee are to select.
;
                if state.cur_tool eq 0 then begin
                    state.oCurrentView->GetProperty, uval=view_uval
                    num_selectables = n_elements( $
                        *(state.model_lists[view_uval.num]) $
                        ) - 1 ; Last item on list is obj_new().
                    end $
                else $
                    num_selectables = state.view_count
;
;               Select something.
;
                case 1 of
                    num_selectables gt 1: begin
                        wDraw = state.wDraw
                        widget_control, ev.top, set_uvalue=state, /no_copy
                        d_objworld2Event, { $
                            id: wDraw, $
                            top: ev.top, $
                            handler: 0L, $
                            type: 0, $ ; Button down
                            press: 4, $ ; Right Mouse-button.
                            x: -2, $
                            y: -2  $
                            }
                        widget_control, ev.top, get_uvalue=state, /no_copy
                        end
                    num_selectables eq 1: begin
                        if state.cur_tool eq 0 and $
                           state.selected eq state.oCurrentTopModel then begin
                            wDraw = state.wDraw
                            widget_control, ev.top, set_uvalue=state, /no_copy
                            d_objworld2Event, { $
                                id: wDraw, $
                                top: ev.top, $
                                handler: 0L, $
                                type: 0, $ ; Button down
                                press: 4, $ ; Right Mouse-button.
                                x: -1, $
                                y: -1  $
                                }
                            widget_control, ev.top, get_uvalue=state, /no_copy
                            end
                        end
                    else:
                    endcase
;
                end
            'S': begin ; Scale.
                if state.cur_tool eq 0 then begin ; (0=Model Manipulator)
                    d_objworld2NewMode, state, 2
                    demo_draw, state.win, state.scene, debug=state.debug
                    end
                end
            'R': begin ; Rotate.
                if state.cur_tool eq 0 then begin ; (0=Model Manipulator)
                    d_objworld2NewMode, state, 1
                    demo_draw, state.win, state.scene, debug=state.debug
                    end
                end
            'T': begin ; Translate.
                if state.cur_tool eq 0 then begin ; (0=Model Manipulator)
                    d_objworld2NewMode, state, 0
                    demo_draw, state.win, state.scene, debug=state.debug
                    end
                end
            'U': begin ; Unselect
                if state.cur_tool eq 0 then begin
                    wUnselectButton = state.wUnselectButton
                    widget_control, ev.top, set_uvalue=state, /no_copy
                    d_objworld2Event, { $
                        top: ev.top, $
                        handler: 0L, $
                        id: wUnselectButton $
                        }
                    widget_control, ev.top, get_uvalue=state, /no_copy
                    end
                end
            'D': begin ; Delete
                wDel = state.wModelDeleteButton
                widget_control, ev.top, set_uvalue=state, /no_copy
                d_objworld2Event, { $
                    top: ev.top, $
                    handler: 0L, $
                    id: wDel $
                    }
                widget_control, ev.top, get_uvalue=state, /no_copy
                end
            'V': begin ; Toggle Manipulate Views mode
                wToolButton = state.wToolButton
                widget_control, ev.top, set_uvalue=state, /no_copy
                d_objworld2Event, { $
                    top: ev.top, $
                    handler: 0L, $
                    id: wToolButton $
                    }
                widget_control, ev.top, get_uvalue=state, /no_copy
                end
            else:
            endcase
        widget_control, ev.top, set_uvalue=state, /no_copy
        end
    endcase
widget_control, ev.top, get_uvalue=state, /no_copy
if xregistered('demo_tour') eq 0 then begin
    widget_control, state.wHotKeyReceptor, /input_focus
    end
widget_control, ev.top, set_uvalue=state, /no_copy
end

;-----------------------------------------------------------------
pro d_objworld2, $
    record_to_filename=record_to_filename, $
    group=group, $               ; IN: (opt) group identifier
    debug=debug, $               ; IN: (opt) debug flag
    apptlb=apptlb                ; OUT: (opt) TLB of this application

widget_control, /hourglass
;
;Check the validity of the group identifier.
;
ngroup = n_elements(group)
if (ngroup ne 0) then begin
    check = widget_info(group, /valid_id)
    if (check ne 1) then begin
        print,'Error: the group identifier is not valid.'
        print,'Returning to the main application.'
        return
        end
    groupbase = group
    end $
else $
    groupbase = 0l
;
;Get the screen size.
;
device, get_screen_size = screensize
;
;Set up dimensions of the drawing (viewing) area.
;
xdim = screensize[0]*0.6
ydim = xdim*0.8
;
;Get the current color vectors to restore
;when this application is exited.
;
tvlct, savedr, savedg, savedb, /get
;
;Build color table from color vectors
;
colortable = [[savedr],[savedg],[savedb]]
;
;Get the data size
sz = size(u)
;
;Create widgets.
;
if (n_elements(group) eq 0) then begin
    wTopBase = widget_base( $
        /column, $
        title="Interactive Object Example", $
        xpad=0, $
        ypad=0, $
        /tlb_kill_request_events, $
        tlb_frame_attr=1, $
        mbar=barbase $
        )
    end $
else begin
    wTopBase = widget_base( $
        /column, $
        title="Interactive Object Example", $
        xpad=0, $
        ypad=0, $
        /tlb_kill_request_events, $
        group_leader=group, $
        tlb_frame_attr=1, $
        mbar=barbase $
        )
    end
apptlb = wTopBase ; Return parameter.
widget_control, wTopBase, set_uname='d_objworld2:tlb'
;
;Create the menu bar.
;
wFileButton = widget_button(barbase, value='File', /menu)
    wLoadButton = widget_button( $
        wFileButton, $
        value="Load", $
        uval='LOAD' $
        )
    wSaveButton = widget_button( $
        wFileButton, $
        value="Save selection", $
        uval='SAVE' $
        )
    wPrintButton = widget_button( $
        wFileButton, $
        value="Print", $
        uval='PRINT' $
        )
    wVRMLButton = widget_button( $
        wFileButton, $
        value="Export VRML", $
        uval='VRML' $
        )
    void = widget_button( $
        wFileButton, $
        value='Quit', $
        /separator, $
        uname='d_objworld2:quit', $
        uvalue='QUIT' $
        )
;
;Options menu.
;
wOptionsButton = widget_button(barbase, /menu, value="Options")
    wDragQ = widget_button(wOptionsButton, /menu, value="Drag Quality")
        wDragQLow = widget_button( $
            wDragQ, $
            value='Low', $
            uval='DRAGQLOW' $
            )
        wDragQMedium = widget_button( $
            wDragQ, $
            value='Medium', $
            uval='DRAGQMEDIUM' $
            )
        wDragQHigh = widget_button( $
            wDragQ, $
            value='High', $
            uval='DRAGQHIGH' $
            )
    wGridButton = widget_button( $
        wOptionsButton, $
        value="Show Grid (on )", $
        uname='d_objworld2:togglegrid', $
        uval='GRID' $
        )
    void = widget_button(wOptionsButton, value="Anti-Alias" ,uval='AA')
    wToolButton = widget_button( $
        wOptionsButton, $
        value="Manipulate Views (off)", $
        uval='TOOL' $
        )
    wClipboardButton = widget_button( $
        wOptionsButton, $
        value="Copy to Clipboard", $
        uval='CLIPBOARD' $
        )

if (lmgr(/demo)) then begin
    widget_control, wPrintButton, sensitive=0
    widget_control, wClipboardButton, sensitive=0
    widget_control, wVRMLButton, sensitive=0
    widget_control, wSaveButton, sensitive=0
    end
;
;Create the menu bar item help that contains the about button.
;
wHelpButton = widget_button(barbase, value='About', /help, /menu)

     waboutbutton = widget_button(wHelpButton, $
         value='About Object World', uvalue='ABOUT')

wTopRowBase = widget_base(wTopBase,/row,/frame)

    addable_subjects = [ $
        'Sphere', $
        'Cube', $
        'Tetrahedron', $
        'Cone', $
        'Green Light', $
        'Surface', $
        'Image', $
        'White Light', $
        '3D Text', $
        'Plot', $
        'Ribbon Plot', $
        'Bar Plot', $
        'Textured Surface' $
        ]

    wGuiBase = widget_base(wTopRowBase, /column )

        wStackerBase = widget_base(wGuiBase, xpad=0, ypad=0)

            wViewControlBase = widget_base(wStackerBase, $
                xpad=0, $
                ypad=0, $
                /column, $
                MAP=0)
                void = widget_button( $
                    wViewControlBase, $
                    value='Add View', $
                    uname='d_objworld2:addview', $
                    uvalue='ADDVIEW' $
                    )
                wViewDeleteButton = widget_button( $
                    wViewControlBase, $
                    value="Delete", $
                    uname='d_objworld2:viewdelete', $
                    uval='DEL' $
                    )
                widget_control, wViewDeleteButton, sensitive=0

                wViewSelectButton = widget_button( $
                    wViewControlBase, $
                    value='Select', $
                    uname='d_objworld2:viewselect', $
                    uval='VIEWSELECT' $
                    )
                widget_control, wViewSelectButton, sensitive=0

            wModelControlBase = widget_base(wStackerBase, $
                xpad=0, $
                ypad=0, $
                /column $
                )

                wModelModeRadio = cw_bgroup( $
                    wModelControlBase, $
                    ['Translate', 'Rotate', 'Scale'], $
                    /exclusive, $
                    /no_release, $
                    set_value=0, $
                    uvalue='MODELMODE' $
                    )

                widget_control, wModelModeRadio, $
                    set_uname='d_objworld2:modelmoderadio'

                wAddButton = widget_button( $
                    wModelControlBase, $
                    value='Add', $
                    /menu $
                    )
                for i=0,n_elements(addable_subjects)-1 do begin
                    void = widget_button(wAddButton, $
                        value=addable_subjects[i], $
                        uname='d_objworld2:add' + addable_subjects[i], $
                        uvalue=['ADD', addable_subjects[i]] $
                        )
                       end
                wAddChildButton = widget_button( $
                    wModelControlBase, $
                    value='Add Child', $
                    /menu $
                    )
                for i=0,n_elements(addable_subjects)-1 do begin
                    void = widget_button(wAddChildButton, $
                        value=addable_subjects[i], $
                        uname='d_objworld2:addchild' + addable_subjects[i], $
                        uvalue=['ADDCHILD', addable_subjects[i]] $
                        )
                       end
                wModelDeleteButton = widget_button( $
                    wModelControlBase, $
                    value="Delete", $
                    uname='d_objworld2:delete', $
                    uval='DEL' $
                    )
                wModelSelectButton = widget_button( $
                    wModelControlBase, $
                    value='Select', $
                    uname='d_objworld2:modelselect', $
                    uvalue='MODELSELECT' $
                    )
                wUnselectButton = widget_button( $
                    wModelControlBase, $
                    value='Unselect', $
                    uname='d_objworld2:unselect', $
                    uvalue='UNSELECT' $
                    )

    wStackerBase = widget_base(wTopRowBase, xpad=0, ypad=0)
        wDraw = widget_draw(wStackerBase, $
            xsize=xdim, $
            ysize=ydim, $
            /button_ev, $
            uval='DRAW', $
            retain=0, $
            /expose_ev, $
            uname='d_objworld2:draw', $
            graphics_level=2 $
            )
        wHotKeyReceptor = widget_text(wStackerBase, $
            /all_events, $
            uvalue='HOTKEY', $
            uname='d_objworld2:hotkey' $
            )
;
;Status readout widget.
;
wGuiBase2 = widget_base(wTopBase, /row)
    wText = widget_label(wGuiBase2,value=" ",/dynamic_resize)
;
;Realize the base widget.
;
widget_control, wTopBase, /realize
;
;Add demo tips widgets.
;
sText = demo_gettips( $
    demo_filepath( $
        'objworld2.tip', $
        subdir=['examples','demo', 'demotext'] $
        ), $
    wTopBase, $
    widget_base(wTopBase, map=0, /row) $
    )
;
;Get the window id of the drawable.
;
widget_control, wdraw, get_value=win
;
;Build the scene.
;
scene=obj_new('IDLgrScene')
oCurrentView = d_objworld2makeview(xdim, ydim, {name:'ObjView', num:0})
oCurrentView->getproperty, dim=dim, loc=loc
scene->add, oCurrentView
d_objworld2getviewobjs, $
    oCurrentView, $
    oWorldRotModel, $
    oBasePlatePolygon, $
    oCurrentTopModel
;
;Make a font for the demo.
;
thefont = objarr(4)
thefont[0] = obj_new('IDLgrFont','times',size=30)
thefont[1] = obj_new('IDLgrFont','hershey*3',size=9)
thefont[2] = obj_new('IDLgrFont','helvetica',size=40)
thefont[3] = obj_new('IDLgrFont','helvetica',size=12)
;
if n_elements(record_to_filename) eq 0 then $
    record_to_filename = ''
;
;Save state.
;
state = { $
    oTrackballMB1: obj_new('trackball', $
        (loc + dim/2.0), $
        dim[0] / 2.0 $
        ), $
    oTrackballMB2: obj_new('trackball', $
        (loc + dim/2.0), $
        dim[0] / 2.0, $
        mouse=2b $
        ), $
    btndown: 0b,              $
    thefont: thefont,         $
    pt0: fltarr(3),           $
    pt1: fltarr(3),           $
    wDraw: wDraw,             $
    wToolButton: wToolButton,     $
    oWorldRotModel: oWorldRotModel,     $
    oBasePlatePolygon: oBasePlatePolygon, $
    oCurrentView: oCurrentView,       $
    oModelMan : obj_new('IDLexModelManip', $
        translate=[1,1,1], $
        selector_color=[255,255,255], $
        manipulator_color=[255, 60, 60] $
        ), $
    oViewMan : obj_new('IDLexViewManip', $
        color=[255, 0, 0] $
        ), $
    addable_subjects: addable_subjects, $
    text: wtext,              $
    win: win,                 $
    oCurrentTopModel: oCurrentTopModel, $
    cur_tool: 0,              $
    selected: oCurrentTopModel, $
    scene: scene,             $
    view_count: 1,            $
    highest_view_count: 1, $ ; "High water mark" for view count.
    dragq: 1,                 $
    groupbase: groupbase,     $
    model_lists: ptrarr(50), $ ; One list for each view.
    wViewControlBase: wViewControlBase, $
    wViewSelectButton: wViewSelectButton, $
    wModelControlBase: wModelControlBase, $
    wViewDeleteButton: wViewDeleteButton, $
    wModelDeleteButton: wModelDeleteButton, $
    wAddChildButton: wAddChildButton, $
    wModelSelectButton: wModelSelectButton, $
    wModelModeRadio: wModelModeRadio, $
    wUnselectButton: wUnselectButton, $
    wDragQLow: wDragQLow, $
    wDragQMedium: wDragQMedium, $
    wDragQHigh: wDragQHigh, $
    wGridButton: wGridButton, $
    wHotKeyReceptor: wHotKeyReceptor, $
    wLoadButton: wLoadButton, $
    wSaveButton: wSaveButton, $
    model_cycle_pos: 1, $
    record_to_filename: record_to_filename, $
    debug: keyword_set(debug), $
    colortable: colortable    $
    }
;
;Restore a sample scene containing a surface and a light
;
restore, $
    demo_filepath('objw_surf.sav', $
        subdir=['examples','demo','demodata'] $
        ), $
    /relaxed_structure_assignment
;; set up and add names to new objects
tmp1 = obj_new('IDLgrModel',name='Surface')
surf = tmp_obj->Get(position=0)
tmp_obj->remove,surf
tmp1->add,surf
tmp2 = obj_new('IDLgrModel',name='Green Light')
gl = tmp_obj->Get(position=0)
tmp_obj->remove,gl
tmp2->add,gl
obj_destroy,tmp_obj

tmp1->translate, 0, 0, .001, /premultiply ; Lift off of baseplate.
tmp2->translate, 0, 0, .001, /premultiply ; Lift off of baseplate.
; tmp_obj->translate, 0, 0, .001, /premultiply ; Lift off of baseplate.
;
;Add tmp_obj to the current tree.
;
state.selected->add, tmp1
state.selected->add, tmp2
; state.selected->add, tmp_obj
;
;Add our restored objects to array of selectable objects.
;
state.model_lists[0] = ptr_new([tmp1,tmp2, $
    obj_new() $ ; Placeholder NULL at end of each list.
    ])
; state.model_lists[0] = ptr_new([ $
;     tmp_obj, $
;     tmp_obj->get(position=1), $
;     obj_new() $ ; Placeholder NULL at end of each list.
;     ])
;
;Target the Green Light.
;
state.selected = tmp2
; state.selected = tmp_obj->Get(position=1)
state.oModelMan->SetTarget, state.selected
state.selected->getproperty,name=s
str = "current selection:" + s
widget_control, state.text, set_value=str
;
;Add some rotation on the whole thing.
;
state.oWorldRotModel->rotate, [-1,0,0], 40
state.oWorldRotModel->rotate, [0,1,0], 20
state.oWorldRotModel->rotate, [0,0,1], 20
;
widget_control, wDragQMedium, sensitive=0
widget_control, wTopBase, set_uvalue=state, /no_copy

xmanager, 'd_objworld2', wTopBase, $
    event_handler='d_objworld2event', $
    /no_block, $
    cleanup='d_objworld2cleanup'

end
