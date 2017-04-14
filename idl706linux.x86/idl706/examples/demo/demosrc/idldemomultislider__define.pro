; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/idldemomultislider__define.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; NAME:
;   IDLdemoMultiSlider
;
; PURPOSE:
;   Define a WIDGET_SLIDER-like control using IDL object graphics.
;
; CATEGORY:
;   IDL demonstration code.
;
; CALLING SEQUENCE:
;   oMultiSlider = obj_new('IDLdemoMultiSlider')
;
; RESTRICTIONS:
;   +--------------------------------------------------------------+
;   |Please note:  This file is demonstration code.  There is no   |
;   |guarantee that programs written using this code will continue |
;   |to work in future releases of IDL.  We reserve the right to   |
;   |change this code or remove it from future versions of IDL.    |
;   +--------------------------------------------------------------+
;
; MODIFICATION HISTORY:
;   Written by: TB, 1998
;
;-
function IDLdemoMultiSlider::GetView
    ; find the view, by moving up through the tree until a view is found
    v=self
    while obj_valid(v) and not obj_isa(v,'IDLgrView') do v->GetProperty,parent=v

    return,(obj_valid(v) and obj_isa(v,'IDLgrView')) ? v : obj_new()
end

function IDLdemoMultiSlider::GetPolygonData,value
    ; get a polygon for a specific value
    c=fltarr(3,3)
    c[0,*]=[-0.5,0.5,0]+value
    c[1,*]=[0,0,1]
    c[2,*]=[0,0,0]
    return,c
end

pro IDLdemoMultiSlider::Append,value
    ; create a new indicator
    self->Add,obj_new('IDLgrPolygon',self->GetPolygonData(value),color=[255,255,255]);,position=self->GetCount()
end

pro IDLdemoMultiSlider::Destroy,index
    ; destroy an indicator
    g=self->Get(position=index+2)
    self->Remove,position=index+2
    obj_destroy,g
end

pro IDLdemoMultiSlider::SetVisibility,show
    ; Hide or show everything in self.
    for index=0,self->Count()-1 do begin
        p=self->Get(position=index)
        p->SetProperty,hide=show ? 0 : 1
    end
end

pro IDLdemoMultiSlider::SetValue,index,value
    ; set the value of an indicator
    p=self->Get(position=index+2)
    p->SetProperty,data=self->GetPolygonData(value)
end

function IDLdemoMultiSlider::GetIndex,value
    ; get the index associated with a value
    c=self->GetCount()-1
    for i=0,c do if self->GetValue(i) eq value then return,i
    return,-1
end

function IDLdemoMultiSlider::GetMouseInfo,win,p, dragging=dragging
    ; see if a mouse event hit the slider, returns a two index integer array [value,index]
    ; if index is invalid then [value,-1] is returned
    ; if value is invalid then [-1,-1] is returned
    ;
    ; Allow user to stray off of the background when DRAGGING.

    ; get the view
    v=self->GetView()
    if not obj_valid(v) then return,-1

    ; find out if it hit the background polygon
    r=win->PickData(v,self.background,p,loc)

    if keyword_set(dragging) then begin ; Allow slop.  Constrain it.
        loc[0]=self.minimum > loc[0] < self.maximum
        loc[1]=0 > loc[1] < 1
        r=1
    end
    if (r eq 1) and (loc[0] ge self.minimum+0.5) and (loc[0] le self.maximum+0.5) and (loc[1] ge 0) and (loc[1] le 1) then begin
        ; get the value of the hit
        v=fix(loc[0]+0.5)
        ; see it has an associated indicator
        return,[v,self->GetIndex(v)]
    endif

    ; no hit
    return,[-1,-1]
end

function IDLdemoMultiSlider::GetColor,index
    ; get the color of the indicator
    p=self->Get(position=index+2)
    p->GetProperty,color=color
    return,color
end

function IDLdemoMultiSlider::GetValue,index
    ; get the value of the indicator
    p=self->Get(position=index+2)
    p->GetProperty,data=data
    return,data[0,2]
end

pro IDLdemoMultiSlider::CancelDrag
    ; Cancel out of a drag and restore the pre-drag value
    if self.in_drag then begin
        self.in_drag=0
        self->SetValue,self.drag_index,self.pre_drag_value
    endif
end

pro IDLdemoMultiSlider::BeginDrag,index
    ; start a drag on an indicator, saving the pre-drag value
    if self.in_drag then self->CancelDrag
    self.in_drag=1
    self.drag_index=index
    self.pre_drag_value=self->GetValue(index)
end

pro IDLdemoMultiSlider::DragMove,win,p
    ; do a drag move
    m=self->GetMouseInfo(win,p,/dragging)
    if self.in_drag then self->SetValue,self.drag_index,(m[0] eq -1) ? self.pre_drag_value : m[0]
end

pro IDLdemoMultiSlider::EndDrag
    ; terminate the drag
    self.in_drag=0
end

function IDLdemoMultiSlider::GetCount
    ; get the number of indicators
    return,self->Count()-2
end

pro IDLdemoMultiSlider::setBackgroundColor,color
    self.background->SetProperty,color=color
end

function IDLdemoMultiSlider::getBackgroundColor
    self.background->GetProperty,color=color
    return,color
end

function IDLdemoMultiSlider::Init,minimum=minimum,maximum=maximum,values=values,colors=colors,_extra=e

    ; initialize the parent
    if (self->IDLgrModel::Init(_extra=e) ne 1) then return,0

    ; set up the min/max
    self.minimum=(n_elements(minimum) ne 1) ? 0 : minimum
    self.maximum=(n_elements(maximum) ne 1) ? 100 : maximum

    ; the vertices of the background
    v_x=[self.minimum-0.5,self.minimum-0.5,self.maximum+0.5,self.maximum+0.5,self.minimum-0.5]
    v_y=[0,1,1,0,0]

    ; create the background
    self.background=obj_new('IDLgrPolygon',v_x,v_y,fltarr(5)-0.2,color=[0,0,0],linestyle=6)
    self->Add,self.background
    self->Add,obj_new('IDLgrPolyline',v_x,v_y,fltarr(5)-0.1,color=[255,255,255])

    ; create the indicators
    for i=0,n_elements(values)-1 do self->Append,values[i]
    for i=0,n_elements(colors)/3-1 do self->SetColor,i,colors[i]

    return,1
end

pro IDLdemoMultiSlider__define
    struct={IDLdemoMultiSlider,INHERITS IDLgrModel,minimum:0,maximum:0,in_drag:0,drag_index:0,pre_drag_value:0,background:obj_new()}
end

