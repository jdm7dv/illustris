;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_hydrogen.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_hydrogen.pro
;
;  CALLING SEQUENCE: d_hydrogen
;
;  PURPOSE:
;       Demonstrate IDL math and graphics capabilities.
;
;  CATEGORY:
;       IDL Demo System
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;-

pro IDLdemoProgressBar::setDecimalValue,value
    l=fix(value*self.count)
    if (l ne self.value) then begin
        s=''
        for i=1,l do s=s+'#'
        widget_control,self.label,set_value=s
        self.value=l
    end
end

function IDLdemoProgressBar::getGeometry
    return,widget_info(self.label,/geometry)
end

function IDLdemoProgressBar::init,parent,indicator_count
    self.count=indicator_count
    s=''
    for i=1,self.count do s=s+'#'
    self.label=widget_label(parent,value=s,frame=1,/align_left)
    self.value=0
    return,1
end

function IDLdemoProgressBar::getBase
    return,self.label
end

pro IDLdemoProgressBar__define
;   +-----------------------------------------------------------------------+
;   |Please note:  IDLdemoProgressBar is demonstration code.  There is no   |
;   |guarantee that programs written using IDLdemoProgessBar will continue  |
;   |to work in future releases of IDL.  We reserve the right to change     |
;   |IDLdemoProgressBar or remove it from future versions of IDL.           |
;   +-----------------------------------------------------------------------+
    struct={IDLdemoProgressBar,label:0l,value:0,count:0}
end

function IDLdemoHydrogen__laguerre,p,q,expon=expon,normalization=normalization
;   calculates the coefficients of a generalized laguerre polynomial.  Returns the coefficients in
;   a vector.  To evaluate the polynomial at a given point, say x, do this:
;
;   c=laguerre(p,q)
;   val=total(c*(x^dindgen(n_elements(c))))
;
;   Reference:  Quantum Theory, David Bohm, Chapter 15, Section 14

    expon=dindgen(p+1)
    normalization=factorial(p)/factorial(p+q)*8/double((2*p+q+1)^2)

;   case p of
;       0: return,[1.0d]
;       1: return,[q+1.0d,-1.0]
;       else: begin
;           minus_1_coeff=IDLdemoHydrogen__laguerre(p-1,q)
;           minus_2_coeff=IDLdemoHydrogen__laguerre(p-2,q)
;           return,((2*p+q-1)*[minus_1_coeff,0]-[0,minus_1_coeff]-(p+q-1)*[minus_2_coeff,0,0])/p
;       end
;   endcase

    ; the coefficient vector
    coeff=dblarr(p+1,/nozero)
    for k=0,p do coeff[k]=(-1)^k*factorial(p+q)/(factorial(p-k)*factorial(q+k)*factorial(k))

    return,coeff
end

function IDLdemoHydrogen__legendre,l,m,expon=expon
;   calculates the coefficients of a generalized legendre polynomial.  Returns the coefficients in
;   a vector.  Also calculates the exponents associated with each coefficient and stores in a variable
;   named by the expon keyword.  To evaluate the polynomial at a given point, say x, do this:
;
;   c=IDLdemoHydrogen__legendre(l,m,expon=e)
;   val=total(c*(x^e))
;
;   This legendre function is normalized
;
;   Reference:  Quantum Theory, David Bohm, Chapter 14, Section 15

    expon=dindgen(2*l+1)-l

    if (m gt l) then return,dblarr(2*l+1)

    if m eq l then begin
        c=sqrt(factorial(2*l+1)/!dpi)/2.0d*(dcomplex(0,1)/4.0d)^l
        coeff=dcomplexarr(2*l+1)
        for k=0,l do coeff[2*(l-k)]=c*(-1)^k/factorial(k)/factorial(l-k)
        return,coeff
    end

    if l eq 1 then return,[1.0d,0.0d,1.0d]*sqrt(3.0d/!dpi)/4.0d

    forward_function IDLdemoHydrogen__legendre
    minus_1_coeff=IDLdemoHydrogen__legendre(l-1,m)
    minus_2_coeff=IDLdemoHydrogen__legendre(l-2,m)

    return,([0,0,minus_1_coeff]/2+[minus_1_coeff,0,0]/2-[0,0,minus_2_coeff,0,0]*sqrt((l+m-1.0d)*(l-m-1.0d)/double((2*l-1.0d)*(2*l-3.0d))))*sqrt((2.0d*l-1.0d)*(2.0d*l+1.0d)/double((l+m)*(l-m)))
end

function IDLdemoHydrogen__outer_power,b,c
    ; return a matrix which is X_ij=b_i^c_j
    X=dcomplexarr(n_elements(c),n_elements(b),/nozero)
    for i=0,n_elements(b)-1 do X[*,i]=b[i]^c
    return,X
end

pro IDLdemoHydrogen::calc_vol, grid_size, range=range
;   The main work specific to the hydrogen atom goes on here.  Note that the data is not normalized,
;   but is byte scaled to the full byte range.  The pre-bytscl range of the data
;   is returned via keyword RANGE.
;
;   Reference:  Quantum Theory, David Bohm, Chapter 14 and 15
;       Overall equation is 14.15 eq 30

    n=self.n
    l=self.l
    m=abs(self.m)

    ; calculate the laguerre polynomial
    laguerre_coeff=IDLdemoHydrogen__laguerre(n-l-1,2*l+1,expon=laguerre_expon,normalization=laguerre_normalization)
;    print,'laguerre_coeff = ',laguerre_coeff
;    print,'laguerre_expon = ',laguerre_expon
;    print,'laguerre_normalization = ',laguerre_normalization
    laguerre_coeff=laguerre_coeff*sqrt(laguerre_normalization)

    ; calculate the legendre polynomial
    legendre_coeff=IDLdemoHydrogen__legendre(l,m,expon=legendre_expon)
;    print,'legendre_coeff = ',legendre_coeff
;    print,'legendre_expon = ',legendre_expon

    ; set up vectors that make converting between the array indicies and the corresponding point in
    ; 3-space easy
    gs_u=grid_size-1

    z_gs=(grid_size+1)/2
    v_z=dindgen(z_gs)/(z_gs-1)*self.r
    v2_z=v_z^2;
    z_u=z_gs-1

    h_gs=ceil(z_gs*sqrt(2))
    v2_h=(dindgen(h_gs)/z_u*self.r)^2

    ; set up the volume data array
    slice=dcomplexarr(h_gs)
    oct_data=dblarr(z_gs,z_gs,z_gs,/nozero)

    d=(dist(grid_size))[0:z_u,0:z_u]

    ; iterate though the volume data calculating the wavefunction probabilities
    for z=0,z_u do begin
        ; the radius value
        r=sqrt(v2_h+v2_z[z]) ; vector

        w=(z eq 0) ? 1 : 0

        ; r_prime is a scaled version of r that makes normalization easier
        r_prime=2.0d*r[w:z_u]/n  ; vector

        ; calculate the data point
        ; if we calculate the radial component, then square it we can calculate larger values of n since exp(-r_prime/2) is small
        sub_slice=(exp(-r_prime/2)*r_prime^l*(IDLdemoHydrogen__outer_power(r_prime,laguerre_expon)##laguerre_coeff)) ; vector

        ; the z axis projection of the unit vector
        cos_theta=v_z[z]/r[w:z_u]
        sin_theta=sqrt(1-cos_theta^2)
        exp_theta=dcomplex(cos_theta,sin_theta)
        sub_slice=sub_slice*(IDLdemoHydrogen__outer_power(exp_theta,legendre_expon)##legendre_coeff)

        slice[w:z_u]=sub_slice

        oct_data[*,*,z]=interpolate(double(slice*conj(slice)),d)
    end

    oct_min = min(oct_data, max=oct_max)

    oct_data=bytscl(oct_data)

    range = [oct_min, oct_max] ; return parameter.  Is it correct??

    ptr_free,self.principal_data
    self.principal_data=ptr_new(dblarr(5,z_gs,/nozero))
    for i=0,z_u do begin
        (*(self.principal_data))[0,i]=oct_data[0,i,0]/255.0
        (*(self.principal_data))[1,i]=oct_data[i,i,0]*sqrt(2)/255.0
        (*(self.principal_data))[2,i]=oct_data[0,i,i]*sqrt(2)/255.0
        (*(self.principal_data))[3,i]=oct_data[0,0,i]/255.0
        (*(self.principal_data))[4,i]=oct_data[i,i,i]*sqrt(3)/255.0
    end

    self->calc_max_opacity_value

    vol_data=bytarr(grid_size,grid_size,grid_size,/nozero)

    ; -x, -y, -z
    vol_data[0:z_u,0:z_u,0:z_u]=reverse(reverse(reverse(oct_data,1),2),3)
    ; -x, -y, z
    vol_data[0:z_u,0:z_u,z_u:gs_u]=reverse(reverse(oct_data,1),2)
    ; -x, y, -z
    vol_data[0:z_u,z_u:gs_u,0:z_u]=reverse(reverse(oct_data,1),3)
    ; -x, y, z
    vol_data[0:z_u, z_u:gs_u, z_u:gs_u]=reverse(oct_data,1)
    ; x, -y, -z
    vol_data[z_u:gs_u,0:z_u,0:z_u]=reverse(reverse(oct_data,2),3)
    ; x, -y, z
    vol_data[z_u:gs_u,0:z_u,z_u:gs_u]=reverse(oct_data,2)
    ; x, y, -z
    vol_data[z_u:gs_u,z_u:gs_u,0:z_u]=reverse(oct_data,3)
    ; x, y, z
    vol_data[z_u:gs_u,z_u:gs_u,z_u:gs_u]=oct_data

    ; set up the coordinate conversion
    coord_conv=[-1.0,2.0/double(grid_size-1)]

    ; set the volume data and coordinate conversion
    vol=self->get_volume()
    atom=self.scene->GetByName('main/atom')
    vol->GetProperty,rgb_table0=ct
    atom->Remove,vol
    obj_destroy,vol
    vol=self->create_vol()
    vol->SetProperty,rgb_table0=ct
    atom->Add,vol
    vol->SetProperty,xcoord_conv=coord_conv,ycoord_conv=coord_conv,zcoord_conv=coord_conv, $
        data0=vol_data,opacity_table0=byte(findgen(256)/255.0*self.max_opacity)
end

pro IDLdemoHydrogen::calc_iso,grid_size,index
;   Calculate an isosurface.  Fairly straight forward.

    for i=0,n_elements(index)-1 do begin
        ; get the isosurface
        iso=self->get_isosurface(index[i])

        ; set the coordinate conversion
        coord_conv=[-1.0,2.0/double(grid_size-1)]
        iso->SetProperty,xcoord_conv=coord_conv,ycoord_conv=coord_conv,zcoord_conv=coord_conv

        ; find the isosurface
        shade_volume,self->get_volume_data(),self->get_isosurface_level(index[i]),v,p
        if (n_elements(v) eq 0) or (n_elements(p) eq 0) then begin
            v=[[0,0,0]]
            p=[0,0,0]
        end
        iso->SetProperty,data=v,polygons=p,texture_coord=[v[0,*],v[1,*]]
    end
end

pro IDLdemoHydrogen::repair_expose
    self.win->Draw,self.scale_view,/draw_instance
end

pro IDLdemoHydrogen::render_file
    if (LMGR(/DEMO)) then begin
        tmp = DIALOG_MESSAGE( /ERROR, $
              'RENDER TO FILE: Feature disabled for demo mode.')
        return
    endif

    ; get the file
    self.file=dialog_pickfile(group=self.top,/write,filter='*.tif')
    if strlen(self.file) ne 0 then begin
        ; check to make sure the extension is there
        if (strmid(strlen(self.file)-4,4) ne '.tif') then self.file=self.file+'.tif'
        top=widget_base(group_leader=self.top,/modal,column=1,title='Render Image',xoffset=100,yoffset=100,tlb_frame_attr=1, $
            uvalue=self)
        c=widget_base(top,column=2,/align_center,/grid_layout,xpad=30)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Width')
        self.file_width=widget_text(b,xsize=8,uvalue='width',value='640',/editable)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Height')
        self.file_height=widget_text(b,xsize=8,uvalue='height',value='480',/editable)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Data Resolution')
        self.file_grid_size=widget_text(b,xsize=8,uvalue='grid_size',value=strtrim(string(self->grid_size()),1),/editable)
        c=widget_base(top,column=2,/align_center,/grid_layout,xpad=30)
        g=widget_button(c,value='OK',uvalue='ok')
        g=widget_button(c,value='Cancel',uvalue='cancel')
        widget_control,top,/realize
        xmanager,'hydrogen',top,event_handler='IDLdemoHydrogen__render_file_handler'
    end
end

pro IDLdemoHydrogen__render_file_handler,event
    widget_control,event.top,get_uvalue=h
    h->render_file_handler,event
end

pro IDLdemoHydrogen::render_file_handler,event
    widget_control,event.id,get_uvalue=uval
    case uval of
        'ok': begin
            widget_control,event.top,get_uvalue=h
            widget_control,self.file_grid_size,get_value=grid_size
            grid_size=fix(grid_size[0])
            if ((grid_size mod 2) eq 0) then grid_size=grid_size+1
            widget_control,self.file_width,get_value=width
            width=fix(width)
            widget_control,self.file_height,get_value=height
            height=fix(height)
            widget_control,event.top,/destroy
            h->do_render_file,grid_size,width,height
        end
        'cancel': widget_control,event.top,/destroy
        else:
    end
end

pro IDLdemoHydrogen::do_render_file,grid_size,width,height
    self.lock=1

    self->repair_expose
    top=widget_base(group_leader=self.top,/modal,column=1,title='Rendering Image',xoffset=100,yoffset=100, $
        tlb_frame_attr=11)
    status=widget_label(top,value='Ready',/align_left,xsize=300)
    widget_control,top,/realize

    buffer=obj_new('IDLgrBuffer',dimensions=[width,height],graphics_tree=self.scene)
    self->resize_views,width,height
    self->render,0,grid_size,buffer,status

    ; get the image and save it
    widget_control,status,set_value='Writing image...'
    image_obj=buffer->Read()
    image_obj->GetProperty,data=image
    WRITE_TIFF,self.file,reverse(image,3)
    obj_destroy,image_obj
    buffer->SetProperty,graphics_tree=obj_new()
    obj_destroy,buffer
    widget_control,top,/destroy

    self.lock=0

    ; restore the window view
    self->resize_normal
    self->render_win
end

pro IDLdemoHydrogen::animate_file
    if (LMGR(/DEMO)) then begin
        tmp = DIALOG_MESSAGE( /ERROR, $
              'ANIMATE: Feature disabled for demo mode.')
        return
    endif

    self.file=dialog_pickfile(group=self.top,/write,filter='*.mpg')
    if strlen(self.file) ne 0 then begin
        if (strlowcase(strmid(self.file,strlen(self.file)-4)) eq '.mpg') then self.file=strmid(self.file,0,strlen(self.file)-4)
        if (strmid(strlen(self.file)-4,4) ne '.tif') then self.file=self.file+'.mpg'
        top=widget_base(group_leader=self.top,/modal,column=1,title='Render Animation',xoffset=100,yoffset=100,tlb_frame_attr=1, $
            uvalue=self)
        c=widget_base(top,column=1,/align_center)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Data Resolution')
        self.file_grid_size=widget_text(b,xsize=8,uvalue='file_grid_size',value=strtrim(string(self->grid_size()),1),/editable)
        c=widget_base(top,column=2,/align_center,/grid_layout)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Movie Width (pixels)')
        self.file_width=widget_text(b,xsize=8,uvalue='file_width',value='640',/editable)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Movie Height (pixels)')
        self.file_height=widget_text(b,xsize=8,uvalue='file_height',value='480',/editable)

;       self.file_grid_size=widget_slider(c,title='Data Resolution',minimum=1,uvalue='grid_size', $
;           value=self->grid_size())
        c=widget_base(top,column=5,/align_center)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Frame Count')
        self.file_mpeg2=cw_bgroup(c,['MPEG 2'],set_value=[0],/nonexclusive,uvalue='file_mpeg2')
        self.file_frame_count=widget_text(b,xsize=8,value='10',/editable,uvalue='file_frame_count')

        c=widget_base(top,column=6,/align_center)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Axis of Rotation (3-element vector): X')
        self.file_x=widget_text(b,xsize=8,uvalue='file_x',value='1',/editable)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Y')
        self.file_y=widget_text(b,xsize=8,uvalue='file_y',value='0',/editable)
        b=widget_base(c,row=1,/align_center)
        g=widget_label(b,value='Z')
        self.file_z=widget_text(b,xsize=8,uvalue='file_z',value='0.2',/editable)
        c=widget_base(top,column=1,/align_center)
        self.file_frame_rate=widget_droplist(c, title='Frame Rate', $
            value=['23.976 frames/sec: NTSC encapsulated film rate', $
                '24 frames/sec: Standard international film rate', $
                '25 frames/sec: PAL video frame rate', $
                '29.97 frames/sec: NTSC video frame rate', $
                '30 frames/sec: NTSC drop frame video frame rate', $
                '50 frames/sec: Double frame rate/progressive PAL', $
                '59.94 frames/sec: Double frame rate NTSC', $
                '60 frames/sec: Double frame rate NTSC drop frame video'],uvalue='file_frame_rate')
        widget_control,self.file_frame_rate,set_droplist_select=4
        self.file_quality=widget_slider(top,title='Quality',uvalue='file_quality',value=100)
        b=widget_base(top,row=1,/align_center)
        g=widget_label(b,value='Temporary Directory')
        self.file_temp=widget_text(b,xsize=50,uvalue='file_temp',value=filepath('',/tmp),/editable)
        c=widget_base(top,column=2,/align_center,/grid_layout,xpad=30)
        g=widget_button(c,value='OK',uvalue='ok')
        g=widget_button(c,value='Cancel',uvalue='cancel')
        widget_control,top,/realize
        xmanager,'d_hydrogen',top,event_handler='IDLdemoHydrogen__animate_file_handler'
    end
end

pro IDLdemoHydrogen__animate_file_handler,event
    widget_control,event.top,get_uvalue=h
    h->animate_file_handler,event
end

pro IDLdemoHydrogen::animate_file_handler,event
    widget_control,event.id,get_uvalue=uval
    case uval of
        'ok': begin
            widget_control,event.top,get_uvalue=h
            widget_control,self.file_grid_size,get_value=grid_size
            grid_size=(fix(grid_size))[0]
            if ((grid_size mod 2) eq 0) then grid_size=grid_size+1
            widget_control,self.file_width,get_value=width
            width=fix(width)
            widget_control,self.file_height,get_value=height
            height=fix(height)
            widget_control,self.file_frame_count,get_value=frame_count
            frame_count=(fix(frame_count))[0]
            widget_control,self.file_x,get_value=x
            x=double(x)
            widget_control,self.file_y,get_value=y
            y=double(y)
            widget_control,self.file_z,get_value=z
            z=double(z)
            widget_control,self.file_mpeg2,get_value=mpeg2
            widget_control,self.file_quality,get_value=quality
            s=widget_info(self.file_frame_rate,/droplist_select)
            widget_control,self.file_temp,get_value=tmp
            widget_control,event.top,/destroy
            h->do_animate_file,grid_size,width,height,mpeg2,quality,frame_count,s+1,x,y,z,tmp[0]
        end
        'cancel': widget_control,event.top,/destroy
        else:
    end
end

pro IDLdemoHydrogen::do_animate_file,grid_size,width,height,mpeg2,quality,frame_count,frame_rate,x,y,z,tmp
    self.lock=1

    self->repair_expose
    top=widget_base(group_leader=self.top,/modal,column=1,title='Rendering Animation',xoffset=100,yoffset=100, $
        tlb_frame_attr=11)
    progress=obj_new('IDLdemoProgressBar',top,100)
    progress->setDecimalValue,0
    status=widget_label(top,value='Ready',/align_left,xsize=300)
    widget_control,top,/realize

    buffer=obj_new('IDLgrBuffer',dimensions=[width,height],graphics_tree=self.scene)
    mpeg=obj_new('IDLgrMPEG',dimensions=[width,height],filename=self.file,frame_rate=frame_rate,format=mpeg2,quality=quality,TEMP_DIRECTORY=tmp)
    self->resize_views,width,height
    atom=self.scene->GetByName('main/atom')
    atom->GetProperty,transform=old_transform
    rotation=360.0d/(frame_count+1)
    for i=1,frame_count do begin
        if (i eq 1) then self->render,0,grid_size,buffer,status else begin
            widget_control,status,set_value='Rendering frame '+strtrim(string(i),1)+'...'
            buffer->Draw
        end
        atom->Rotate,[x,y,z],rotation
        widget_control,status,set_value='Saving frame '+strtrim(string(i),1)+'...'
        image_obj=buffer->Read()
        mpeg->Put,image_obj,i-1
        progress->setDecimalValue,double(i)/double(frame_count)
        obj_destroy,image_obj
    end

    ; get the image and save it
    widget_control,status,set_value='Generating animation...'
    mpeg->Save

    buffer->SetProperty,graphics_tree=obj_new()
    obj_destroy,buffer
    obj_destroy,mpeg
    widget_control,top,/destroy

    ; restore the window view
    atom->SetProperty,transform=old_transform

    self.lock=0
    self->resize_normal
    self->render_win
end

pro IDLdemoHydrogen::calc_max_opacity_value
    widget_control,self.overall_opacity_s,get_value=overall_opacity
    overall_transparency=255-overall_opacity

    max_opacity=1

    repeat begin
        p=make_array(5,/double,value=1)
        z_u=(size(*(self.principal_data),/dimensions))[1]-1
;        for i=0,z_u do p=p*(1-(*(self.principal_data))[*,i]*max_opacity/255.0)^2
        for i=0,z_u do p=p*(1.0-(*(self.principal_data))[*,i]*max_opacity/255.0)
        o=byte(min(p)*255.0)
        max_opacity=max_opacity+1
    end until (o le overall_transparency) or max_opacity eq 256

    self.max_opacity=byte(max_opacity-1)
;    print,'max opacity = ',self.max_opacity
end

function IDLdemoHydrogen::create_vol
    return,obj_new('IDLgrVolume',name='volume',/zbuffer,/zero_opacity_skip,interpolate=self->use_smoothing(),hide=self->show_vol() ? 0 : 1)
end

function IDLdemoHydrogen::get_volume
    ; get the volume object
    return,self.scene->GetByName('main/atom/volume')
end

function IDLdemoHydrogen::get_volume_data
    ; get the volume data
    (self->get_volume())->GetProperty,data0=vol_data

    return,vol_data
end

function IDLdemoHydrogen::get_color_table
    ; get the color table
    (self->get_volume())->GetProperty,rgb_table0=ct
    return,ct
end

function IDLdemoHydrogen::get_isosurface_parent
    ; get the isosurface model
    return,self.scene->GetByName('main/atom/isosurfaces')
end

function IDLdemoHydrogen::get_isosurface_count
    return,(self->get_isosurface_parent())->Count()
end

function IDLdemoHydrogen::get_isosurfaces
    return,(self->get_isosurface_parent())->Get(/all)
end

function IDLdemoHydrogen::get_isosurface,index
    ; get the isosurface
    return,(self->get_isosurface_parent())->Get(position=index)
end

function IDLdemoHydrogen::get_iso_slider
    ; get the isosurface slider
    return,self.scene->GetByName('scale/iso_slider')
end

function IDLdemoHydrogen::get_isosurface_level,index
    ; get the isosurface level, the max is 50, the data has been byte scaled so rescaling the level is required
    return,byte((self->get_iso_slider())->GetValue(index)/50.0*255)
end

pro IDLdemoHydrogen::set_status,t
    demo_Puttips, $
        0, $
        [' ',' ',t], $
        [10,11,12], $
        nostate=*self.psText
end

pro IDLdemoHydrogen::reset_status
    demo_Puttips, $
        0, $
        [' ',' ','Ready.'], $
        [10,11,12], $
        nostate=*self.psText
end

function IDLdemoHydrogen::grid_size
;   query the grid slider for its value
    widget_control,self.grid_size_s,get_value=v
    return,((v mod 2) eq 0) ? v+1 : v
end

function IDLdemoHydrogen::use_smoothing
;   query the smoothing check button for its value
    widget_control,self.depth_cue_cb,get_value=v
    return,v[1]
end

function IDLdemoHydrogen::auto_refresh
;   query the auto_refresh button for its value
    widget_control,self.auto_refresh_cb,get_value=v
    return,v
end

function IDLdemoHydrogen::show_iso
;   query the show_iso button for its value
    widget_control,self.show_iso_cb,get_value=v
    return,v
end

function IDLdemoHydrogen::depth_cue
;   querry the depth cue widget for its value
    self.win->GetProperty,renderer=renderer
    widget_control,self.depth_cue_cb,get_value=v
    return,([[0,0],[-.5,([1.25,10])[renderer]]])[*,v[0]] ; values determined empirically.
end

function IDLdemoHydrogen::show_vol
;   query the show_vol button for its value
    widget_control,self.show_vol_cb,get_value=v
    return,v
end

pro IDLdemoHydrogen::recalc_isosurfaces
    self->set_status,'Calculating isosurfaces...'
    self->set_color_table
    for i=0,self->get_isosurface_count()-1 do begin
        self->calc_iso,self->grid_size(),i
    end
    self.need_recalc_isosurfaces=0b
end

pro IDLdemoHydrogen::draw,in_motion
    ; draw the display.

    if not in_motion then begin
        widget_control,/hourglass
        self->set_status,'Creating instance...'
    end

    if in_motion eq 0 then begin
        self.win->Draw,/create_instance
        self->set_status,'Drawing instance...'
        self.win->Draw,self.scale_view,/draw_instance
        self.instance_is_current=1b
    end else begin
        self.win->Draw
    end

    if not in_motion then self->reset_status
    self.need_redraw=0b
end

pro IDLdemoHydrogen::set_color_table
    ; Set the isosurfaces and volume color tables
    vol=self->get_volume()
    isos=self->get_isosurface_parent()
    color_bar=self.scene->GetByName('scale/color_bar')

    ; load the color table
    i=widget_info(self.color_table_l,/list_select)
    ct=self.color_tables->get(i)

    vol->SetProperty,rgb_table0=ct

    ; Set all the iso surface colors
    c=isos->Count()-1
    for i=0,c do self->set_iso_color,i

    ; Set the color bar to the new table
    color_bar->SetProperty,red_values=ct[*,0]
    color_bar->SetProperty,green_values=ct[*,1]
    color_bar->SetProperty,blue_values=ct[*,2]
end

function toString,x
    result=strarr(n_elements(x))
    for i=0,n_elements(x)-1 do begin
       ;s=str_sep(string(x[i],FORMAT='(e)'),'e') ; str_sep is obsolete.
        s=strtok(string(x[i],FORMAT='(e)'),'e', /extract)
        mantissa=strtrim(string(double(round(double(s[0])*10.0d))/10.0d,'(g0.2)'),2)
        exponent=fix(s[1])
        result[i]=(exponent eq 0) ? mantissa : mantissa+'e'+strtrim(string(exponent),2)
    endfor
    return,result
end

pro IDLdemoHydrogen::render,instancing,grid_size,win,status
    ; recalculate all data and then display it
    widget_control,/hourglass

    ; do the rescaling
    self->rescale

    ; calc the volume
    self->set_status,'Calculating volume data...'
    self->calc_vol,grid_size,range=range

    ; calculate all surfaces
    self->set_status,'Calculating isosurfaces...'
    c=self->get_isosurface_count()-1
    for i=0,c do self->calc_iso,grid_size,i

    ; update the colorbar tick text.
    obj_destroy, self.colorbar_ticktext

    self.colorbar_ticktext=obj_new('IDLgrText', $
        toString(findgen(11) / 10.0 * (range[1]-range[0]) + range[0]), $ ;,FORMAT='(f4.2)'), $
        font=self.label_font $
        )
    self.color_bar->SetProperty, ticktext=self.colorbar_ticktext

    ; redraw
    if instancing then begin
        self->set_status,'Creating instance...'
        win->Draw,/create_instance
        self->set_status,'Drawing instance...'
        win->Draw,self.empty_view,/draw_instance
        self.instance_is_current=1b
    end else begin
        self->set_status,'Rendering...'
        win->Draw
    end

    self->reset_status

end

pro IDLdemoHydrogen::render_win
    self->render,1,self->grid_size(),self.win,self.status
end

pro IDLdemoHydrogen::assign_style,s,h
    ; assign a polygon style and a hidden surface style to all isosurfaces
    if self->get_isosurface_count() ne 0 then begin
        isos=self->get_isosurfaces()
        c=n_elements(isos)-1
        for i=0,c do (isos[i])->SetProperty,style=s,hidden_lines=h
    end
end

pro IDLdemoHydrogen::assign_style_and_redraw,s,h
    ; reassign all isosurface styles and redraw the display
    if self->get_isosurface_count() ne 0 then begin
        self->assign_style,s,h
        self->set_color_table
        self->draw,0
    end
end

function IDLdemoHydrogen::show_iso_motion
    return,([0,1])[self.show_iso_motion and (self.need_refresh eq 0)]
end

pro IDLdemoHydrogen::prepare_motion
    ; prepare for mouse motion by hiding the volume rendering and showing the isurfaces if the user wants to.
    ; Also set the isosurface styles to the motion styles
    (self->get_volume())->SetProperty,/hide
    (self->get_isosurface_parent())->SetProperty,hide=self->show_iso_motion() ? 0 : 1
    self->assign_style,self.iso_m_style,self.iso_m_hidden

    axes=self.scene->GetByName('main/atom/axes')
    axes->SetProperty,hide=(self->show_iso_motion() or self.show_axes) eq 0 ? 0 : (1b-self.show_axes)
    self.now_cutter=self.use_m_cutter

    ; turn off texture mapping for all isosurfaces
    self->set_color_table
end

pro IDLdemoHydrogen::terminate_motion
    ; terminate mouse motion by showing the volume rendering if it is enabled and showing the isurfaces if the user wants to.
    ; Also set the isosurface styles to the non-motion styles

    ; show all the isosurfaces
    isos=self->get_isosurfaces()
    if obj_valid(isos[0]) then begin
        c=n_elements(isos)-1
        for i=0,c do (isos[i])->SetProperty,hide=0
    end

    (self->get_volume())->SetProperty,hide=self->show_vol() ? 0 : 1
    (self->get_isosurface_parent())->SetProperty,hide=self->show_iso() ? 0 : 1
    self->assign_style,self.iso_style,self.iso_hidden

    self.now_cutter=self.use_cutter
    axes=self.scene->GetByName('main/atom/axes')
    axes->SetProperty,hide=self.show_axes ? 0 : 1

    ; turn on texture mapping for all isosurfaces
    self->set_color_table
end

pro IDLdemoHydrogen::refresh
    ; rescale, recalculate and redraw display

    ; change the title text to reflect possible new quantum numbers
    label_model=self.scene->GetByName('label/label')
    title=self.scene->GetByName('label/label/title')
    label_model->Remove,title
    obj_destroy,title
    t='Hydrogen Atom at n = '+strtrim(string(self.n),1)+', l = '+strtrim(string(self.l),1)+', m = '+strtrim(string(self.m),1)
    title=obj_new('IDLgrText',t,alignment=0.5,/onglass, $
                  color=[255,255,255],name='title',vertical_alignment=0.5)
    label_model->Add,title

    ; recalculate and redraw
    self->render_win

    self.need_refresh=0b
end

function d_hydrogenFlip, value, wSlider
    ; Return value "flipped" per the range of a vertical slider.
    range=widget_info(wSlider, /slider_min_max)
    return, range[0]-(value-range[1])
end

pro IDLdemoHydrogen::setup_l_s
    ; setup the range of the l quantum number slider in response to a change in the n quantum number.
    ; l has a range of 0..n-1

    ; if n=1 then l will be zero, but sliders cannot have a range of length zero, so disable the slider if n=1
    if self.n eq 1 then begin
        self.l=0
        widget_control,self.l_s,set_value=0
        widget_control,self.l_l,sensitive=0
        widget_control,self.l_s,sensitive=0
        widget_control,self.l_s,set_slider_max=1
    end else begin
        self.l=self.l<(self.n-1)
        widget_control,self.l_s,sensitive=1
        widget_control,self.l_l,sensitive=1
        widget_control,self.l_s,set_slider_max=self.n-1
        widget_control,self.l_s,set_value=d_hydrogenFlip(self.l, self.l_s)
    end
    widget_control,self.l_l,set_value='l = '+strtrim(self.l,1)
end

pro IDLdemoHydrogen::setup_m_s
    ; setup the range of the m quantum number slider in response to a change in the l quantum number.
    ; m has a range of -m..m

    ; if l=0 then m will be zero, but sliders cannot have a range of length zero, so disable the slider if l=0
    if self.l eq 0 then begin
        self.m=0
        widget_control,self.m_s,set_value=0
        widget_control,self.m_s,sensitive=0
        widget_control,self.m_l,sensitive=0
        widget_control,self.m_s,set_slider_min=-1
        widget_control,self.m_s,set_slider_max=1
    end else begin
        self.m=(self.m<self.l)>(-self.l)
        widget_control,self.m_s,sensitive=1
        widget_control,self.m_l,sensitive=1
        widget_control,self.m_s,set_slider_min=-self.l
        widget_control,self.m_s,set_slider_max=self.l
        widget_control,self.m_s,set_value=d_hydrogenFlip(self.m, self.m_s)
    end
    widget_control,self.m_l,set_value='m = '+strtrim(self.m,1)
end

pro IDLdemoHydrogen::toggle_tools
    ; toggle the visible state of the tool palette
    self.tools_visible=not self.tools_visible
    draw_geom=widget_info(self.draw,/geometry)
    if not self.tools_visible then begin
        self.tool_width=(widget_info(self.tools,/geometry)).xsize
;       draw_geom.xsize=draw_geom.xsize+self.tool_width-1
        widget_control,self.tools,map=0
        widget_control,self.tools,xsize=1
;       widget_control,self.draw,xsize=draw_geom.xsize
    end else begin
;       draw_geom.xsize=draw_geom.xsize-self.tool_width+1
;       widget_control,self.draw,xsize=draw_geom.xsize
        widget_control,self.tools,xsize=self.tool_width
        widget_control,self.tools,map=1
    end
    self->resize_normal
    self->draw,0
end

pro IDLdemoHydrogen::set_scale
    ; set the labels on the axes to reflect the new scale.  To take advantage of IDLgrAxis' methods of picking the number of
    ; ticks the range of the axes is set to -r..r and the coordinate conversion is set to return the axis to a space of -1..1
    coord_conv=[0,1.0/self.r]
    for i=0,2 do begin
        axes_model=self.scene->GetByName('main/atom/axes')
        a=axes_model->GetByName(string(i,'(I1)'))
        axes_model->Remove, a
        obj_destroy, a

        a=obj_new('IDLgrAxis',i,/exact,/extend,name=string(i,'(I1)'),color=self.label_color)
        a->SetProperty,ticklen=0.1*self.r
        a->SetProperty,range=[-self.r,self.r]
        a->SetProperty,xcoord_conv=coord_conv,ycoord_conv=coord_conv,zcoord_conv=coord_conv

        a->GetProperty,tickvalues=v, major=major
        ticktext = obj_new('IDLgrText',strtrim(string(v,'(g0)'),1),font=self.label_font)
        a->SetProperty,ticktext=ticktext
        obj_destroy, self.ticktext[i]
        self.ticktext[i] = ticktext

        axes_model->Add, a
        end
end

function IDLdemoHydrogen::R,r,l_c,l_e
    ; Evaluate the radial function based on a set of laguerre coefficients and exponents
    ; do not distribute the square since this will decrease the maximum value of r that it is possible to calculate

    ;Flush any accumulated math error.
    void = check_math(/print)

    ;Silently accumulate any subsequent math errors.
    orig_except = !except
    !except = 0

    ;Attempt to calculate our result.
    result = (exp(-r/2)*r^self.l*total(l_c*(r^l_e)))^2

    ;Get status and reset.
    status = check_math()
    !except = orig_except

    ;Handle errors by simply returning zero.
    if status ne 0 then $
        return, 0 $
    else $
        return, result
end

function my_roots,coeff
    for i=(n_elements(coeff)-1),0,-1 do begin
        if coeff[i] ne 0 then return,fz_roots(coeff[0:i])
    endfor
    return,-1
end

pro IDLdemoHydrogen::rescale
    ; auto rescale the space based on the quantum numbers selected.
    ; This routime is slightly involved and no reference is available.

    ; take the derivative of the radial function and find the zeros of it, thereby finding the extrema of the radial equation
    l_c=IDLdemoHydrogen__laguerre(self.n-self.l-1,2*self.l+1,expon=l_e)
    f=2*self.l*[l_c,0]-[0,l_c]+2*[l_c,0]*dindgen(n_elements(l_c)+1)
;    if (self.n ne self.l+1) then f=f+2*[0,IDLdemoHydrogen__laguerre(self.n-self.l-1,2*self.l+2),0]
    extrema=double([(n_elements(f) gt 1) ? my_roots(f) : 0,(n_elements(l_c) gt 1) ? my_roots(l_c) : 0])

    ; get the extrema that is farthest from the origin (excluding the extrema at r=infinity)
    max_r=max(extrema)
    ; evaluate the radial function at that extrema and scale it by 0.1
    offset=self->R(max_r,l_c,l_e)*0.1
    ; a step size
    step=max_r*0.1 > 0.1
    ; move out from the last extrema until the value of the radial function is one tenth of the value at the largest extrema
    if offset gt 0 then begin
        while self->R(max_r,l_c,l_e) gt offset do max_r=max_r+step
    end

    ; rescale the radius back to our units
    self.r=max_r/2*self.n ; & if not self.r then stop

    ; set the scale
    self->set_scale
end

pro IDLdemoHydrogen::resize_views,w,h
    main=self.scene->GetByName('main')
    title=self.scene->GetByName('label/label/title')
    label=self.scene->GetByName('label')
    scale=self.scene->GetByName('scale')

    ; use a margin of 8 pixels
    margin=8

    ; the color scale is 80 units wide
    s_w=80
    w=w-s_w-2*margin
    scale->SetProperty,dimensions=[s_w,h-2*margin],location=[w+margin,margin]

    ; the title is fifty pixels tall
    t_h=50
    h=h-t_h-2*margin
    label->SetProperty,dimensions=[w-2*margin,t_h],location=[margin,h+margin]

    ; the main view is whatever is left over, constrained to a square
    s=w<h
    main->SetProperty,dimensions=[s,s]
    main->SetProperty,location=[(w-s)/2-1,(h-s)/2-1]

    ; update the trackball and the mouse_center used in scaling
    center=[w,h]/2
    self.mouse_center=center
    self.track->Reset,center,s
end

pro IDLdemoHydrogen::resize_normal
    geom=widget_info(self.draw,/geometry)
    self->resize_views,geom.draw_xsize,geom.draw_ysize
end

pro IDLdemoHydrogen::resize,top_xsize,top_ysize
    ; resize the views in response to a main window resize

    x=top_xsize
    y=top_ysize

    tg=widget_info(self.top,/geometry)
    top_xsize=top_xsize-tg.space-2*tg.xpad
    top_ysize=top_ysize-tg.space-2*tg.ypad

    sg=widget_info(self.status,/geometry)
    widget_control,self.status,scr_xsize=top_xsize-2*sg.margin-pg.scr_xsize-2*pg.margin,update=0

    top_ysize=top_ysize-(sg.scr_ysize+2*sg.margin)

    tg=widget_info(self.tools,/geometry)
    dg=widget_info(self.draw,/geometry)
    widget_control,self.tools,scr_ysize=top_ysize-2*tg.margin,update=0
    widget_control,self.draw,scr_xsize=top_xsize-tg.scr_xsize-2*tg.margin-2*dg.margin,scr_ysize=top_ysize-2*dg.margin,update=0

    widget_control,self.top,xsize=x,ysize=y,/update
    dg=widget_info(self.draw,/geometry)
    self->resize_views,dg.xsize,dg.ysize
    tg=widget_info(self.top,/geometry)

    ; clear the display
    self.win->Erase,color=[0,0,0]
end

pro IDLdemoHydrogen::set_iso_color,index
    ; set the color of a particular isosurface

    ; get the color table
    ct=self->get_color_table()
    ; set the color
    level=self->get_isosurface_level(index)

;   m=bytarr(16,16,4)
;   m[*,*,*]=255
;   m[*,*,3]=0
;   for i=0,level do begin
;       repeat p=fix(randomu(c,2)*15) until (m[p[0],p[1],3] ne 255)
;       m[p[0],p[1],3]=255
;   end

;   m=bytarr(7,7,4)
;   m[*,*,*]=255
;   m[*,*,3]=255
;   m[0:5,0:5,3]=0

    image_size=16
    m=bytarr(image_size,image_size,4)+255b

    if self.now_cutter then begin
        w=fix(interpolate([image_size-1,3*float(image_size)/4],level/255.0))-1
        m[0:w,0:w,3]=0
        texture_map=obj_new('IDLgrImage',m,interleave=2)
        self.texture_maps->add,texture_map ; Store this reference for ::cleanup.
    end else $
        texture_map=obj_new()

    (self->get_isosurface(index))->SetProperty, $
        color=[ct[level,0],ct[level,1],ct[level,2]], $
        texture_map=texture_map
end

pro IDLdemoHydrogen::delete_iso,index
    ; delete an isosurface

    ; remove the slider indicator
    (self->get_iso_slider())->Destroy,index

    ; get the isosurface from the parent, remove and destroy it
    isos=self->get_isosurface_parent()
    iso=isos->Get(position=index)
    isos->Remove,position=index
    obj_destroy,iso

    ; redraw
    self.win->Draw,self.scene->GetByName('scale')
    self.need_redraw=1b
    if self->auto_refresh() then begin
        self->draw,0
        self.need_redraw=0b
    end
end

pro IDLdemoHydrogen::create_iso,level,calc
    ; add an indicator to the slider
    (self->get_iso_slider())->Append,level

    ; get the index of the new isosurface
    index=self->get_isosurface_count()
    ; create the isosurface

    (self->get_isosurface_parent())->Add,obj_new('IDLgrPolygon',shading=self->use_smoothing(),style=self.iso_style,hidden_lines=self.iso_hidden)
    ; set its color, recalc and draw
    self->set_iso_color,index

    self.win->Draw,self.scene->GetByName('scale')
    self.need_redraw=1b
    if calc then begin
        self->calc_iso,self->grid_size(),index
        if self->auto_refresh() then begin
            self->draw,0
            self.need_redraw=0b
        end
    end
end

pro IDLdemoHydrogen::on_mouse_down,event
    ; update the trackball
    have_transform=self.track->Update(event,transform=t)
    ; reset moved state
    self.has_moved=0
    self.motion_type=0

    case event.press of
        1: begin
            ; left mouse button down, find out if it hit the slider first
            m=(self->get_iso_slider())->GetMouseInfo(self.win,[event.x,event.y])
            ; if m[1] is not -1 then the cursor hit an indicator, if m[0] is not -1 then the cursor hit the slider, otherwise start
            ; trackball motion
            if m[1] eq -1 then begin
                if m[0] eq -1 then begin
                    selected_objs=self.win->Select(self.scale_view,[event.x,event.y])
                    if obj_valid(selected_objs[0]) then if max(self.color_bar eq selected_objs) eq 1 then return
                    ; it's the trackball motion
                    self.motion_type=1
                    ; prepare for the motion
                    self->prepare_motion
                    ; get the motion events
                    widget_control,self.draw,/draw_motion_events
                ; otherwise, create a new isosurface at the location that the user clicked
                end else begin
;                    widget_control,/hourglass
                    if self.need_refresh eq 0 then begin
                        self->set_status,'Calculating isosurface...'
                        self->create_iso,m[0],1
                    self->assign_style,self.iso_style,self.iso_hidden
                    self->set_color_table ; Takes care of Perforated vs. non-perforated.
                        self->Reset_status
;                    end else self->create_iso,m[0],0
                    end else begin
                        self->create_iso,m[0],0
                        ;self.need_recalc_isosurfaces=1b
                    end
                end
            end else begin
                ; slider drag motion
                self.motion_type=2
                ; get the index of the indicator
                self.iso_index=m[1]
                ; get the motion events
                widget_control,self.draw,/draw_motion_events
                ; start the drag
                (self->get_iso_slider())->BeginDrag,m[1]
                ; if the user wants isosurfaces during motion than prepare for motion, otherwise just leave the display static
                if self->show_iso_motion() then begin
                    self->prepare_motion
                    ; hide all isosurfaces except the one in question
                    isos=self->get_isosurfaces()
                    c=n_elements(isos)-1
                    for i=0,c do (isos[i])->SetProperty,hide=(i eq m[1]) ? 0 : 1
                end
            end
        end
        4: begin
            ; right mouse click, find out if it hit the slider
            m=(self->get_iso_slider())->GetMouseInfo(self.win,[event.x,event.y])
            if m[1] ne -1 then self->delete_iso,m[1]
        end
        else:
    end
end

pro IDLdemoHydrogen::on_mouse_up,event
    ; update the transform
    have_transform=self.track->Update(event,transform=t)

    widget_control, self.draw,draw_motion_events=0
    ; cancel the motion events
    case (self.motion_type) of
        1: begin
            ; it was trackball motion.
            if self.has_moved then begin
                if self->auto_refresh() then begin
                    self->terminate_motion
                    self->draw,0
                end else begin
                    widget_control,/hourglass
                    self->draw,0
                    self.need_redraw=1b
                end
                self->set_status,'Ready.'
            end
        end
        2: begin
            ; it was wedge drag so terminate the drag
            (self->get_iso_slider())->EndDrag
            if self->show_iso_motion() then begin
                if self->auto_refresh() then begin
                    self->terminate_motion
                end
            end else begin
                self.need_recalc_isosurfaces=1b
            end
            if self->auto_refresh()then begin
                if self.need_recalc_isosurfaces then self->recalc_isosurfaces
                self->draw,0
            end else begin
                if self->show_iso_motion() then self->draw,0 ; because we need instance with solo isosurface showing.
                self.need_redraw=1b
                self->set_status,'Ready.'
            end
        end
        3: begin
            ; it was scale motion so terminate the motion
            self->terminate_motion
            ; if the display has changed then redraw if isosurface motion is on (the data was recalculated during motion)
            ; otherwise do the recalculation now
            if self.has_moved then begin
                if self->show_iso_motion() and (self->get_isosurface_count() ne 0) then self->draw,0 else self->render_win
            end
        end
        else:
    end
    self.motion_type=0b
end

pro IDLdemoHydrogen::on_mouse_move,event
    have_transform=self.track->Update(event,transform=t)

    case (self.motion_type) of
        1: if have_transform then begin
            ; trackball motion, so if a transform exists then redraw the data and update the moved flag
            atom=self.scene->GetByName('main/atom')
            main=self.scene->GetByName('main')
            atom->GetProperty,transform=ot
            atom->SetProperty,transform=ot#t
            self->set_status,'Rotating...'
            self.win->Draw,main
            self.has_moved=1
            ;self.instance_is_current=0b
        end
        2: begin
            ; drag motion, so update the slider
            (self->get_iso_slider())->DragMove,self.win,[event.x,event.y]
            ; if the user wants isosurface motion, then recalculate the data and redraw, otherwise just redraw the scale
            if self->show_iso_motion() then begin
                self->set_iso_color,self.iso_index
                self->calc_iso,self->grid_size(),self.iso_index
                self->draw,1
            end else self.win->Draw,self.scene->GetByName('scale')
            self->set_status,'Sliding...'
        end
        3: begin
            ; scale motion, so update the motion flag
            self.has_moved=1
            ; calculate the new radius based on the ratio of the starting mouse radius and the new mouse radius
            self.r=double(self.start_r)*sqrt(double(self.mouse_center[0]-event.x)^2+double(self.mouse_center[1]-event.y)^2)/self.mouse_radius
            ; set the scale
            self->set_scale
            ; if the user wants isosurface motion then recalculate data otherwise just redraw
            if self->show_iso_motion() and (self->get_isosurface_count() ne 0) then self->render_win else self->draw,1
        end
        else:
    end
end

pro IDLdemoHydrogen::handle_event,event
    ; handle an event from the tool palette or the top level

    ; get user value
    widget_control,event.id,get_uvalue=uval

    ; if its a kill request for the tool base the hide the tool base
    if tag_names(event,/structure_name) eq 'WIDGET_KILL_REQUEST' then begin
        self->toggle_tools
        return
    end

    ; it its a message from the top level that it must be a resize
    if event.id eq self.top then begin
        ; make the draw widget fill the new space and resize the status bar the same width
        self->resize,event.x,event.y
        self->draw,0
    end else begin
        case uval of
            'grid_size': if self->auto_refresh() then self->refresh else self.need_refresh=1b
            'overall_opacity_s': if self->auto_refresh() then begin
                    self->calc_max_opacity_value
                    self->render_win
                end else self.need_refresh=1b
            'show_iso_m': begin ; motion menu button
                widget_control,event.id,set_value=(['Hide','Show'])[self.show_iso_motion]+' Isosurfaces When Dragging'
            end
            'tab_selector': begin
                widget_control,self.tab_selector,get_value=v
                widget_control,self.tab1,map=v eq 0 ? 1 : 0
                widget_control,self.tab2,map=v
            end
            'depth_cue_cb': begin
                case event.value of
                    0: begin ; The 'Depth Cue' box was clicked.
                        self.main_view->SetProperty,depth_cue=self->depth_cue()
                        if self->auto_refresh() then self->draw,0 else self.need_redraw=1b
                    end
                    1: begin ; The 'Smoothing' box was clicked.
                        ; change the smoothing state

                        ;(self.win)->SetProperty,quality=use ? 2 : 1

                        ; set interpolation on the volume as required
                        (self->get_volume())->SetProperty,interpolate=self->use_smoothing()

                        ; set the shading to flat or gourard as required for all isosurfaces
                        if (self->get_isosurface_count() ne 0) then begin
                            isos=self->get_isosurfaces()
                            c=n_elements(isos)-1
                            for i=0,c do (isos[i])->SetProperty,shading=self->use_smoothing()
                        end

                        ; redraw
                        if self->auto_refresh() then self->draw,0 else self.need_redraw=1b
                    end
                endcase
            end
            'about': begin
                ONLINE_HELP, 'd_hydrogen', $
                   book=demo_filepath("idldemo.adp", $
                           SUBDIR=['examples','demo','demohelp']), $
                           /FULL_PATH
             end

            'animate_file': self->animate_file
            'render_file': self->render_file
            'color_table_l': begin
                ; a selection on the color table drop list, so set the color table and redraw
                self->set_color_table
                if self->auto_refresh() then self->draw,0 else self.need_redraw=1b
            end
            'save': begin
                if (LMGR(/DEMO)) then begin
                    tmp = DIALOG_MESSAGE( /ERROR, $
                        'SAVE: Feature disabled for demo mode.')
                endif else begin
                    ; show the pickfile dialog for tiff files
                    file=dialog_pickfile(GROUP=event.top,/WRITE,FILTER='*.tif')
                    if strlen(file) ne 0 then begin
                        widget_control,/hourglass
                        ; check to make sure the extension is there
                        if (strmid(strlen(file)-4,4) ne '.tif') then file=file+'.tif'

                        ; get the image and save it
                        image_obj=self.win->Read()
                        image_obj->GetProperty,data=image
                        WRITE_TIFF,file,reverse(image,3)
                        obj_destroy,image_obj
                    end
                endelse
            end
            'iso_style_dl': begin
                case event.index of
                    0: begin
                        ; shift to a point view with no hidden surface removal
                        self.iso_style=0
                        self.iso_hidden=0
                    end
                    1: begin
                        ; shift to a point view with hidden surface removal
                        self.iso_style=0
                        self.iso_hidden=1
                    end
                    2: begin
                        ; shift to a line view with no hidden surface removal
                        self.iso_style=1
                        self.iso_hidden=0
                    end
                    3: begin
                        ; shift to a line view with hidden surface removal
                        self.iso_style=1
                        self.iso_hidden=1
                    end
                    4: begin
                        ; shift to a surface view
                        self.iso_style=2
                        self.iso_hidden=0
                        self.use_cutter=0b
                        self.now_cutter=0b
                    end
                    5: begin
                        ; shift to a purforated surface view
                        self.iso_style=2
                        self.iso_hidden=0
                        self.use_cutter=1b
                        self.now_cutter=1b
                    end
                end
                if self->auto_refresh() then $
                    self->assign_style_and_redraw,self.iso_style,self.iso_hidden $
                else begin
                    ;self->assign_style,self.iso_style,self.iso_hidden
                    ;self->set_color_table ; Takes care of Perforated vs. non-perforated.
                    self.need_redraw=1b
                end
            end
            'iso_m_points': begin
                self.iso_m_style=0
                self.iso_m_hidden=0
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=1b
                end
            'iso_m_pointframe' :begin
                self.iso_m_style=0
                self.iso_m_hidden=1
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=1b
                end
            'iso_m_lines': begin
                self.iso_m_style=1
                self.iso_m_hidden=0
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=1b
                end
            'iso_m_wireframe': begin
                self.iso_m_style=1
                self.iso_m_hidden=1
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=1b
                end
            'iso_m_surface': begin
                self.iso_m_style=2
                self.iso_m_hidden=0
                self.use_m_cutter=0
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=1b
                end
            'iso_m_purfsurf': begin
                self.iso_m_style=2
                self.iso_m_hidden=0
                self.use_m_cutter=1
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=1b
                end
            'iso_m_noshow': begin
                self.iso_m_style=0
                self.iso_m_hidden=0
                widget_control,self.current_motion_button,sensitive=1
                widget_control,event.id,sensitive=0
                self.current_motion_button=event.id
                self.show_iso_motion=0b
                end
            'refresh': begin
                self->terminate_motion
                case 1 of
                    self.need_refresh: self->refresh
                    self.need_recalc_isosurfaces: begin
                        self->recalc_isosurfaces
                        self->draw,0
                    end
                    else: self->draw,0
                endcase
            end
            'exit': begin
                ; destroy the top level on exit
                widget_control,event.top,/destroy
                return
            end
            'toggle_tools': self->toggle_tools
            'n': begin
                ; set the n quantum number and refresh if required
                self.n=d_hydrogenFlip(event.value, event.id)
                widget_control,self.n_l,set_value='n = '+strtrim(self.n,1)
                self->setup_l_s
                self->setup_m_s
                if self->auto_refresh() then self->refresh else self.need_refresh=1b
            end
            'l': begin
                ; set the l quantum number and refresh if required
                self.l=d_hydrogenFlip(event.value, event.id)
                widget_control,self.l_l,set_value='l = '+strtrim(self.l,1)
                self->setup_m_s
                if self->auto_refresh() then self->refresh else self.need_refresh=1b
            end
            'm': begin
                ; set the m quantum number and refresh if required
                self.m=d_hydrogenFlip(event.value, event.id)
                widget_control,self.m_l,set_value='m = '+strtrim(self.m,1)
                if self->auto_refresh() then self->refresh else self.need_refresh=1b
            end
            ; hide the refresh button if auto refresh is on
            'auto_refresh': begin
                widget_control,self.refresh_b,sensitive=self->auto_refresh() ? 0 : 1
                if self->auto_refresh() then $
                    case 1 of
                        self.need_refresh: begin
                            self->terminate_motion
                            self->Refresh
                        end
                        self.need_recalc_isosurfaces: begin
                            self->terminate_motion
                            self->recalc_isosurfaces
                            self->draw,0
                        end
                        self.need_redraw: begin
                            self->terminate_motion
                            self->draw,0
                        end
                        else:
                    endcase
            end
            'draw': case event.type of
                ; process a mouse event from the draw widget
                0: self->on_mouse_down,event
                1: self->on_mouse_up,event
                2: self->on_mouse_move,event
                4: if (not self.lock) then begin
                    self->repair_expose
                end
                else:
            end
            'axes': begin
                ; show or hide the axes
                axes=self.scene->GetByName('main/atom/axes')
                self.show_axes = 1b - self.show_axes
                axes->SetProperty,hide=self.show_axes ? 0 : 1
                widget_control,event.id,set_value=(['Show','Hide'])[self.show_axes]+' Axes'

                ; redraw
                if self->auto_refresh() then self->draw,0 else self.need_redraw=1b
            end
            'show_vol_cb': begin
                ; show or hide the volume and redraw
                if self->auto_refresh() then (self->get_volume())->SetProperty,hide=self->show_vol() ? 0 : 1
                widget_control,self.overall_opacity_s,sensitive=self->show_vol() ? 1 : 0
                if self->auto_refresh() then self->draw,0 else self.need_redraw=1b
            end
            'show_iso_cb': begin
                ; show or hide the isosurfaces and redraw
                (self->get_isosurface_parent())->SetProperty,hide=self->show_iso() ? 0 : 1
                widget_control,self.iso_style_label,sensitive=self->show_iso() ? 1 : 0
                widget_control,self.iso_style_dl,sensitive=self->show_iso() ? 1 : 0
                (self.multi_slider)->SetVisibility,self->show_iso() ? 1 : 0
                if self->auto_refresh() then self->draw,0 else begin
                    self.win->Draw,self.scene->GetByName('scale')
                    self.need_redraw=1b
                end
            end
            else:
        end
    if uval ne 'draw' then $
        widget_control,self.smoothing_cb,sensitive=self->show_vol() or (self.iso_style eq 2 and self->show_iso())
    end
end

pro d_hydrogenHandle_event,event
    ; event handler for xmanager
    ; get the user value as it is a pointer the Hydrogen object
    widget_control,event.top,get_uvalue=h
    ; branch to the handle_event routine in the Hydrogen object
    h->handle_event,event
end

pro IDLdemoHydrogen::Cleanup
    ; Tricky way to clean ourself up. Just look thru all our
    ; struct tags and free any pointers or objrefs.
    ntags = N_TAGS({IDLdemoHydrogen})
    ;Clean up heap variables.
    for i=0,ntags-1 do begin
        case size(self.(i), /tname) of
            'POINTER': $
                ptr_free, self.(i)
            'OBJREF': $
                obj_destroy, self.(i)
            else:
        endcase
    end

    ;Put the group leader on-screen.
    if widget_info(self.group_leader,/valid_id) then $
        widget_control,self.group_leader,/map
end

pro d_hydrogenExit_cleanup,top
    ; branch to the object
    widget_control,top,get_uvalue=h
    obj_destroy,h
end

function IDLdemoHydrogen::Init, $
    group_leader, $           ; INPUT.   Use 0 if no leader.
    apptlb                    ; OUTPUT.  Self's top level widget base.

    ; show the hourglass
    widget_control,/hourglass

    ; label color
    self.label_color = (label_color=[255,255,255])

    ; some initial values
    self.n=7
    self.l=6
    self.m=3
    self.r=1.0
    self.tools_visible=1

    self.iso_style=2
    self.use_cutter=1b
    self.now_cutter=1b
    self.show_axes=1b

    self.iso_m_style=0
    self.iso_m_hidden=0
    self.show_iso_motion=0b

    self.texture_maps=obj_new('IDL_container')

    ; create the top level
    scr_size=get_screen_size()
    self.top=widget_base(mbar=menu_bar,title='Hydrogen Atom', $
        TLB_FRAME_ATTR=1,uvalue=self,row=2,group_leader=group_leader)
    apptlb=self.top ; Return parameter.
    self.group_leader=group_leader

    ; create the menus
    file_menu=widget_button(menu_bar,value='File',/menu)
    t=widget_button(file_menu,value='Save Current View...',uvalue='save')
    t=widget_button(file_menu,value='Render to File...',uvalue='render_file')
    t=widget_button(file_menu,value='Animate...',uvalue='animate_file')
    t=widget_button(file_menu,value='Quit',uvalue='exit',/separator)

    options_menu=widget_button(menu_bar,value='Options',/menu)
    self.show_axes_mb=widget_button(options_menu,value='Hide Axes',uvalue='axes')
    motion_menu=widget_button(options_menu,value='Drag Style',/menu)
    void=widget_button(motion_menu,value='Points',uvalue='iso_m_points')
    void=widget_button(motion_menu,value='Points with Hidden Point Removal',uvalue='iso_m_pointframe')
    void=widget_button(motion_menu,value='Lines',uvalue='iso_m_lines')
    void=widget_button(motion_menu,value='Lines with Hidden Line Removal',uvalue='iso_m_wireframe')
    void=widget_button(motion_menu,value='Surface',uvalue='iso_m_surface')
    void=widget_button(motion_menu,value='Perforated Surface',uvalue='iso_m_purfsurf')
    default=widget_button(motion_menu,value='None',uvalue='iso_m_noshow')
    self.current_motion_button=default
    widget_control,default,sensitive=0
    self.motion_menu=motion_menu

    help_menu=widget_button(menu_bar,value='Help',/menu)
    t=widget_button(help_menu,value='About...',uvalue='about')

    self.tools=widget_base(self.top,column=1,uvalue=self)

    self.tab_selector=cw_bgroup(self.tools,['Quantum Numbers','Display'],uvalue='tab_selector',/exclusive,set_value=0, $
        row=1,/no_release)
    tab_pane=widget_base(self.tools,frame=1)

    self.tab2=widget_base(tab_pane,column=1,map=0)

    self.depth_cue_cb=cw_bgroup(self.tab2,['Depth Cueing','Color Smoothing'],uvalue='depth_cue_cb', $
        /nonexclusive,set_value=[1,1],ids=ids)
    self.smoothing_cb=ids[1]
    self.grid_size_s=widget_slider(self.tab2,title='Data Resolution',uvalue='grid_size',minimum=10,maximum=100,value=35) ;53)

    b=widget_label(self.tab2,value='Color Table')
    self.color_tables=obj_new('IDLdemoClrTblFile')
    self.color_table_l=widget_list(self.tab2,uvalue='color_table_l',value=self.color_tables->getNames(),ysize=4)

    frame_base=widget_base(self.tab2,frame=1,/column)
    self.show_vol_cb=cw_bgroup(frame_base,['Show Voxel Projection'],uvalue='show_vol_cb',/nonexclusive,set_value=[0])
    self.overall_opacity_s=widget_slider(frame_base,title='Approximate Overall Opacity',uvalue='overall_opacity_s',minimum=1,maximum=255,value=255-16)
    frame_base=widget_base(self.tab2,frame=1,/column)
    self.show_iso_cb=cw_bgroup(frame_base,['Show Isosurfaces'],uvalue='show_iso_cb',/nonexclusive,set_value=[1])
    widget_control,self.overall_opacity_s,sensitive=0
    iso_styles=['Points','Points with Hidden Point Removal','Lines','Lines with Hidden Line Removal','Surface','Perforated Surface']
    self.iso_style_label=widget_label(frame_base,value='Isosurface Style');
    self.iso_style_dl=widget_droplist(frame_base,uvalue='iso_style_dl',value=iso_styles);
    widget_control,self.iso_style_dl,set_droplist_select=5

    self.tab1=widget_base(tab_pane,row=1)
    s_f=widget_base(self.tab1,/frame,/row,space=4)
    self.n_s=widget_slider(s_f,minimum=1,maximum=25,uvalue='n',/vertical,/suppress_value)
    self.n_l=widget_label(s_f,value="n = 25")
    s_f=widget_base(self.tab1,/frame,/row,space=4)
    self.l_s=widget_slider(s_f,uvalue='l',maximum=100,/vertical,/suppress_value)
    self.l_l=widget_label(s_f,value="l = 44")
    if (self.n eq 1) then widget_control,self.l_s,sensitive=0
    s_f=widget_base(self.tab1,/frame,/row,space=5)
    self.m_s=widget_slider(s_f,uvalue='m',minimum=-100,maximum=100,/vertical,/suppress_value)
    self.m_l=widget_label(s_f,value="m = -44")
    if (self.l eq 0) then widget_control,self.m_s,sensitive=0

    b=widget_base(self.tools,column=2)
    self.auto_refresh_cb=cw_bgroup(b,['Auto Refresh'],uvalue='auto_refresh',/nonexclusive,set_value=[1])
    self.refresh_b=widget_button(b,value='Refresh',uvalue='refresh')
    widget_control,self.refresh_b,sensitive=0

    ; create the draw view and the status bar
    s=0.7*min(scr_size)
    self.draw=widget_draw(self.top,graphics_level=2,retain=0,uvalue='draw',/button_events, $
        /expose_events,xsize=s,ysize=s, $
        renderer=1) ; We use software rendering (renderer==1) because it is fast at
                    ; drawing IDLgrVolumes and because it is fast at creating
                    ; instances (IDLgrWindow::Draw,/create_instance).
    self.status=widget_base(self.top, map=0, /row)

    ;realize all the bases
    widget_control,self.top,/realize

    self.psText = ptr_new( $
        demo_getTips( $
            demo_filepath( $
                'hydrogen.tip', $
                subdir=['examples','demo', 'demotext'] $
                ), $
            self.top, $
            self.status $
            ) $
        )

    width=(widget_info(self.iso_style_dl,/geometry)).xsize
    widget_control,self.overall_opacity_s,xsize=width

    widget_control,self.l_s,set_slider_max=6
    widget_control,self.m_s,set_slider_min=-6,set_slider_max=6

    tab1_geom=widget_info(tab_pane,/geometry)
    s_f_geom=widget_info(s_f,/geometry)
    slider_geom=widget_info(self.n_s,/geometry)
    scr_ysize=tab1_geom.ysize-2*tab1_geom.ypad-2*slider_geom.margin
    scr_ysize=scr_ysize-(s_f_geom.scr_xsize+2*s_f_geom.margin+2*s_f_geom.ypad-s_f_geom.xsize)+([0,2])[!version.os_family eq 'Windows']
    widget_control,self.n_s,ysize=scr_ysize
    widget_control,self.l_s,ysize=scr_ysize
    widget_control,self.m_s,ysize=scr_ysize

    widget_control,self.n_l,set_value='n = '+strtrim(self.n,1)
    widget_control,self.l_l,set_value='l = '+strtrim(self.l,1)
    widget_control,self.m_l,set_value='m = '+strtrim(self.m,1)

    ; get the window object of the draw widget
    widget_control,self.draw,get_value=win
    self.win=win

    ; set the cursor
    self.win->SetCurrentCursor,'arrow'

    ; create the label font
    self.label_font=obj_new('IDLgrFont',size=6, 'Hershey')

    ; create the top level scene
    self.scene=obj_new('IDLgrScene',color=[0,0,0])
    self.win->SetProperty,graphics_tree=self.scene

    ; create the title view
    label_view=obj_new('IDLgrView',name='label',color=[0,0,0])
    self.scene->Add,label_view

    label_model=obj_new('IDLgrModel',name='label')
    label_view->Add,label_model

    title=obj_new('IDLgrText','Hydrogen Atom at n = 7, l = 6, m = 3',alignment=0.5,/onglass, $
                  color=label_color,name='title',vertical_alignment=0.5)
    label_model->Add,title

    label_model->Scale,2,2,1

    ; create the scale view
    scale_view=obj_new('IDLgrView',name='scale',color=[0,0,0],viewplane_rect=[-5, -1, 8, 53])
    self.scene->Add,scale_view
    self.scale_view = scale_view

    self.colorbar_ticktext=obj_new('IDLgrText', $ ; Self needs to keep this reference for cleanup.
            ['0.0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'], $
            font=self.label_font $
            )

    self.color_bar=obj_new('IDLgrColorbar', $
        dimensions=[1,51], $
        color=label_color, $
        name='color_bar', $
        /show_outline, $
        /show_axis, $
        minor=1, $
        major=11, $
        ticktext=self.colorbar_ticktext $
        )
    scale_view->Add,self.color_bar

    slider=obj_new('IDLdemoMultiSlider',maximum=50,name='iso_slider')
    slider->Rotate,[0,0,1],90
    slider->Translate,2,0.5,0
    scale_view->Add,slider
    self.multi_slider=slider

    ; create the main view
    main_view=obj_new('IDLgrView',name='main',color=[0,0,0],depth_cue=self->depth_cue(),zclip=[sqrt(3),-sqrt(3)])
    self.main_view=main_view
    self.scene->Add,main_view

    ;   create the lights
    light_model=obj_new('IDLgrModel',name='lights')
    directional_light=obj_new('IDLgrLight',location=[1,1,1],direction=[0,0,0],type=2,name='directional')
    light_model->Add,directional_light
    ambient_light=obj_new('IDLgrLight',intensity=0.25,name='ambient')
    light_model->Add,ambient_light
    main_view->Add,light_model

    ; create the atom model
    atom_model=obj_new('IDLgrModel',name='atom')
    main_view->Add,atom_model

;   create the axes, putting labels for each at either end.  Don't worry about the tick mark labelling
;   right now, this will be done in set_scale
    axes=obj_new('IDLgrModel',name='axes')
    axes->Add,obj_new('IDLgrAxis',0,/exact,/extend,name='0',color=label_color)
    axes->Add,obj_new('IDLgrText','x',color=label_color,locations=[1.1,0,0],vertical_alignment=0.5)
    axes->Add,obj_new('IDLgrText','x',color=label_color,locations=[-1.1,0,0],alignment=1.0,vertical_alignment=0.5)
    axes->Add,obj_new('IDLgrAxis',1,/exact,/extend,name='1',color=label_color)
    axes->Add,obj_new('IDLgrText','y',color=label_color,locations=[0,1.1,0],alignment=0.5)
    axes->Add,obj_new('IDLgrText','y',color=label_color,locations=[0,-1.1,0],alignment=0.5,vertical_alignment=1)
    axes->Add,obj_new('IDLgrAxis',2,/exact,/extend,name='2',color=label_color)
    axes->Add,obj_new('IDLgrText','z',color=label_color,locations=[0,0,1.1],alignment=0.5,updir=[0,0,1])
    axes->Add,obj_new('IDLgrText','z',color=label_color,locations=[0,0,-1.1],alignment=0.5,updir=[0,0,1],vertical_alignment=1)
    atom_model->Add,axes

    ; create the isosurface parent
    iso=obj_new('IDLgrModel',name='isosurfaces',hide=self->show_iso() ? 0 : 1)
    atom_model->Add,iso

    ; create the volume object
    vol=self->create_vol()
    atom_model->Add,vol

    atom_model->Rotate,[0,0,1],35
    atom_model->Rotate,[-1,0,0],60
    atom_model->Scale,.8,.8,.8

    ; create the trackball, the center and radius will be reset so these values don't matter
    self.track=obj_new('Trackball',[200,200],200)

    self.empty_view=obj_new('IDLgrView',/transparent)

    ; set the size of the viewport
    ;self.win->SetProperty,dimensions=[450,450]

    ; pick the default color table
    widget_control,self.color_table_l,set_list_select=2 ; 21

    ; set the color table, scale and view sizing
    self->set_color_table
    self->resize_normal

    ; create an isosurface, but don't calculate it yet
    self->create_iso,25,0

    ; render!
    self->render_win

    ; set up the event loop
    xmanager,'d_hydrogen',self.top,event_handler='d_hydrogenHandle_event',cleanup='d_hydrogenExit_cleanup',/no_block

    demo_puttips, $
        0, $
        ['move1','move2','move3'], $
        [10,11,12], $
        /label, $
        nostate=*self.psText

    widget_control,self.n_s,set_value=d_hydrogenFlip(self.n, self.n_s)
    widget_control,self.l_s,set_value=d_hydrogenFlip(self.l, self.l_s)
    widget_control,self.m_s,set_value=d_hydrogenFlip(self.m, self.m_s)

    ; success!
    return,1
end

pro IDLdemoHydrogen__define
    struct={IDLdemoHydrogen, $
            n:0,l:0,m:0,r:1.0d, $
            top:0l,draw:0l,tools:0l, grid_size_s:0l, overall_opacity_s:0l, $
            n_s:0l,l_s:0l,m_s:0l, $
            n_l:0l,l_l:0l,m_l:0l, $
            iso_style:2,iso_m_style:1, $
            iso_hidden:0,iso_m_hidden:0, $
            show_iso_cb:0l, show_iso_m_cb:0l, show_vol_cb:0l,auto_refresh_cb:0l, $
            show_axes_mb:0l, $
            color_table_l:0l, render_top:0l, $
            refresh_b:0l, tools_visible:0b,tool_width:0, file:'', $
            file_grid_size:0l, file_width:0l, file_height:0l, file_frame_count:0l, file_x:0l, file_y:0l, file_z:0l, file_frame_rate:0l, $
            file_mpeg2:0l, file_quality:0l, file_temp:0l, $
            status:0l,color_tables:obj_new(), empty_view:obj_new(), $
            win:obj_new(),track:obj_new(),scene:obj_new(), label_font:obj_new(), $
            ticktext:[obj_new(), obj_new(), obj_new()], $
            label_color: bytarr(3), use_cutter_cb:0l, lock:0, $
            use_cutter: 0b, use_m_cutter:0b, now_cutter:0b, tab1:0l, tab2:0l, tab_selector:0l, iso_style_dl:0l, $
            depth_cue_cb: 0l, $
            main_view: obj_new(), $
            multi_slider: obj_new(), $
            iso_style_label: 0l, $
            current_motion_button: 0l, $
            show_iso_motion: 0b, $
            show_axes: 0b, $
            motion_menu: 0l, $
            scale_view: obj_new(), $
            color_bar: obj_new(), $
            principal_data: ptr_new(), $
            max_opacity: 0b, $
            need_refresh: 0b, $
            need_recalc_isosurfaces: 0b, $
            need_redraw: 0b, $
            hid_multislider: 0b, $
            psText: ptr_new(), $
            instance_is_current: 0b, $
            smoothing_cb: 0l, $
            group_leader: 0l, $
            colorbar_ticktext: obj_new(), $
            texture_maps: obj_new(), $ ; container of texture maps
            has_moved:0,motion_type:0,iso_index:0,mouse_center:intarr(2),mouse_radius:0.0,start_r:0.0d}
end

pro d_hydrogen, $
    group=group, $      ; IN: (opt) group identifier
    record_to_filename=record_to_filename, $
    apptlb=apptlb       ; OUT: (opt) TLB of this application


    ;Check the validity of the group identifier.
    ngroup = n_elements(group)
    if (ngroup ne 0) then begin
        check = widget_info(group, /valid_id)
        if (check ne 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Returning to the main application'
            return
        endif
        group_leader = group
    endif else group_leader = 0L

    h=obj_new('IDLdemoHydrogen',group_leader,apptlb)
end

