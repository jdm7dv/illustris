; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_lightproperties.pro#2 $
;
;  Copyright (c) 2004-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
;  NAME:
;       d_lightproperties
;
;  CALLING SEQUENCE:
;       d_lightproperties
;
;  PURPOSE:
;       light properties demo
;
;  ARGUMENTS:
;       NONE
;
;  KEYWORDS:
;       _EXTRA - Needed to trap keywords being passed from the demo
;                system calling routine
;
;  MODIFICATION HISTORY:
;       LVP, June 2004, Original
;       AGEH, June 2004, Removed executes and cleaned up code
;
;---------------------------------------------------------------------

;----------------------------------------------------------------------------
; cleanup routine - called when program exits
;----------------------------------------------------------------------------
pro d_lightproperties_cleanup, top
  compile_opt idl2
  widget_control, top, get_uvalue=pstate
  ;; destroy all objects
  obj_destroy,(*pstate).oModel
  obj_destroy,(*pstate).oView
  obj_destroy,(*pstate).oTeapot
  obj_destroy, (*pstate).oTrack
  ;; free the state pointer
  ptr_free, pstate
end

;---------------------------------------------------------------------
; procedure to create tire polygon data
;---------------------------------------------------------------------
PRO d_lightproperties_BuildTire, points, conn, ddist
  compile_opt idl2
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

;---------------------------------------------------------
; function to read in teapot data file
;---------------------------------------------------------
function d_objReadNoff, $
  file, $                       ; IN: filename
  xr, $                         ; OUT: x radius
  yr, $                         ; OUT: y radius
  zr                            ; OUT: z radius

  COMPILE_OPT idl2, hidden

  t0 = systime(1)
  s = ' '
  npsize = 1

  RESTORE, file

  xr = [min(x, max = xx), xx]   ;Get ranges
  yr = [min(y, max = xx), xx]
  zr = [min(z, max = xx), xx]

  sc = [xr[1]-xr[0], yr[1]-yr[0], zr[1]-zr[0]] ;Ranges
  xr[0] = (xr[1] + xr[0])/2.0   ;Midpoint
  yr[0] = (yr[1] + yr[0])/2.0
  zr[0] = (zr[1] + zr[0])/2.0
  s = max(sc)                   ;Largest range...

  x = (x - xr[0]) / s
  y = (y - yr[0]) / s
  z = (z - zr[0]) / s

  xr = [-0.7, 0.7]              ;Fudge the ranges
  yr = xr
  zr = xr
  s = OBJ_NEW("IDLgrPolygon", TRANSPOSE([[x],[y],[z]]), $
              SHADING=1, $
              POLY=mesh, COLOR=[200,200,200])

  RETURN, s

end                             ;   of d_objReadNoff

;--------------------------------------------------------------------------
; draw window - trackball event handler
;--------------------------------------------------------------------------
pro d_lightproperties_draw_object, event
  compile_opt idl2

  widget_control, event.top, get_uvalue=pstate
  update = (*pstate).oTrack->update(event, transform=new)
  if (update) then begin
    (*pstate).oModel->getProperty, transform=old
    (*pstate).oModel->setProperty, transform=old # new
    (*pstate).oWindow->draw,(*pstate).oView
  endif

end

;--------------------------------------------------------------------------
; set the slider values to current material properties
;--------------------------------------------------------------------------
pro d_lightproperties_set_slider_value, ptr, property, r, g, b
  compile_opt idl2

  prop = strupcase(property[0])
  tNames = tag_names(*ptr)

  ;; if the property only has one element the name will match and only
  ;; the 'r' value will be used
  index = where(tNames EQ prop)
  IF (index NE -1) THEN BEGIN
    widget_control,(*ptr).(index),set_value=r
    return
  ENDIF

  index = where(tNames EQ prop+'_R')
  widget_control,(*ptr).(index),set_value=r,bad_id=void
  index = where(tNames EQ prop+'_G')
  widget_control,(*ptr).(index),set_value=g,bad_id=void
  index = where(tNames EQ prop+'_B')
  widget_control,(*ptr).(index),set_value=b,bad_id=void

end

;--------------------------------------------------------------------------
; this procedure handles the object droplist
;--------------------------------------------------------------------------
pro d_lightproperties_drop_event, event
  compile_opt idl2

  widget_control, event.top, get_uvalue = pstate
  info = widget_info(event.id, /droplist_select)

  case ((*pstate).o_values[info]) of

    'Teapot': begin

      d_lightproperties_set_slider_value, pstate, 'ambient', 84,57,7
      d_lightproperties_set_slider_value, pstate, 'diffuse', 199,145,29
      d_lightproperties_set_slider_value, pstate, 'specular', 253,240,206
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 27.8974

      (*pstate).oTeapot->GetProperty, POLYGONS=teapotconn
      (*pstate).oTeapot->GetProperty, data = teapotdata
      (*pstate).oObject->setProperty, ALPHA_CHANNEL=1.0
      (*pstate).oObject->setProperty, DATA=teapotdata*5.0
      (*pstate).oObject->setProperty, POLYGONS=teapotconn
      (*pstate).oObject->setProperty,SHADING=1
      (*pstate).oObject->setProperty,style=2
      (*pstate).oObject->setProperty, AMBIENT=[84,57,7]
      (*pstate).oObject->setProperty,DIFFUSE=[199,145,29]
      (*pstate).oObject->setProperty,SPECULAR=[253,240,206]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=27.8974
      (*pstate).oView->setProperty,viewplane_rect=[-3,-3,6,6]
      (*pstate).oView->setProperty, zclip = [3,-3]
      (*pstate).oWindow->draw, (*pstate).oView
      widget_control, (*pstate).material_drop, set_droplist_select=6

    end

    'Tire': begin
      ;; get the data for the tire object
      d_lightproperties_buildtire, points, conn, ddist

      d_lightproperties_set_slider_value, pstate, 'ambient', 5,5,5
      d_lightproperties_set_slider_value, pstate, 'diffuse', 3,3,3
      d_lightproperties_set_slider_value, pstate, 'specular', 102,102,102
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10

      (*pstate).oObject->setProperty, POLYGONS=0

      (*pstate).oObject->setProperty, DATA=points
      (*pstate).oObject->setProperty, POLYGONS=conn
      (*pstate).oObject->setProperty, ALPHA_CHANNEL=1.0
      (*pstate).oObject->setProperty,SHADING = 1
      (*pstate).oObject->setProperty, AMBIENT=[5,5,5]
      (*pstate).oObject->setProperty,DIFFUSE=[3,3,3]
      (*pstate).oObject->setProperty,SPECULAR=[102,102,102]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oView->setProperty, viewplane_rect=[-3,-3,6,6]
      (*pstate).oView->setProperty, zclip = [3,-3]
      (*pstate).oWindow->draw, (*pstate).oView
      widget_control, (*pstate).material_drop, set_droplist_select=18
    end

    'Gemstone': begin
      dxffile = filepath('gem.dxf',subdirectory=['examples','demo','demodata'])
      oGem= obj_new('idlffdxf')
      status = oGem->read(dxffile)
      gemtypes = oGem -> GetContents(COUNT = gemCounts)
      gem = oGem->getEntity(gemtypes[0])

      vertices = *gem.vertices*.5
      connectivity = *gem.connectivity
      ptr_free, gem.vertices
      ptr_free, gem.connectivity
      ptr_free, gem.vertex_colors
      obj_destroy, oGem
      (*pstate).oObject->setProperty, polygons=connectivity
      (*pstate).oObject->setProperty, DATA= vertices
      (*pstate).oObject->setProperty,SHADING=0
      (*pstate).oObject->setProperty,style=2
      (*pstate).oObject->setProperty, ALPHA_CHANNEL=.6
      (*pstate).oObject->setProperty,AMBIENT=[5,44,5]
      (*pstate).oObject->setProperty,DIFFUSE=[19,157,19]
      (*pstate).oObject->setProperty,SPECULAR=[161,186,161]
      (*pstate).oObject->setProperty,SHININESS=76.8
      (*pstate).oView->setProperty, viewplane_rect=[-3,-3,6,6]
      (*pstate).oView->setProperty, zclip = [3,-3]
      (*pstate).oWindow->draw, (*pstate).oView
      widget_control, (*pstate).material_drop, set_droplist_select=0
      d_lightproperties_set_slider_value, pstate, 'ambient', 5,44,5
      d_lightproperties_set_slider_value, pstate, 'diffuse', 19,157,19
      d_lightproperties_set_slider_value, pstate, 'specular', 161,186,161
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 76.8
    end

  endcase

end

;--------------------------------------------------------------------------
; this procedure handles the material droplist
;--------------------------------------------------------------------------
pro d_lightproperties_m_drop_event, event
  compile_opt idl2

  widget_control, event.top, get_uvalue = pstate
  info = widget_info(event.id, /droplist_select)

  case ((*pstate).m_values[info]) of

    ;; Gemstones
    'Emerald'   : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 5,44,5
      d_lightproperties_set_slider_value, pstate, 'diffuse', 19,157,19
      d_lightproperties_set_slider_value, pstate, 'specular', 161,186,161
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 76.8
      (*pstate).oObject->setProperty, AMBIENT=[5,44,5]
      (*pstate).oObject->setProperty,DIFFUSE=[19,157,19]
      (*pstate).oObject->setProperty,SPECULAR=[161,186,161]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=76.8
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Jade'   : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 34,57,40
      d_lightproperties_set_slider_value, pstate, 'diffuse', 138,227,161
      d_lightproperties_set_slider_value, pstate, 'specular', 81,81,81
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 12.8
      (*pstate).oObject->setProperty, AMBIENT=[34,57,40]
      (*pstate).oObject->setProperty,DIFFUSE=[138,227,161]
      (*pstate).oObject->setProperty,SPECULAR=[81,81,81]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=12.8
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Obsidian'  : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 14,13,17
      d_lightproperties_set_slider_value, pstate, 'diffuse', 47,43,57
      d_lightproperties_set_slider_value, pstate, 'specular', 85,84,88
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 38.4
      (*pstate).oObject->setProperty, AMBIENT=[14,13,17]
      (*pstate).oObject->setProperty,DIFFUSE=[47,43,57]
      (*pstate).oObject->setProperty,SPECULAR=[85,84,88]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=38.4
      (*pstate).oWindow->draw, (*pstate).oView

    end

    'Pearl'     : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 64,53,53
      d_lightproperties_set_slider_value, pstate, 'diffuse', 255,211,211
      d_lightproperties_set_slider_value, pstate, 'specular', 76,76,76
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 11.26
      (*pstate).oObject->setProperty, AMBIENT=[64,53,53]
      (*pstate).oObject->setProperty,DIFFUSE=[255,211,211]
      (*pstate).oObject->setProperty,SPECULAR=[76,76,76]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=11.26
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Ruby'   : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 44,3,3
      d_lightproperties_set_slider_value, pstate, 'diffuse', 157,11,11
      d_lightproperties_set_slider_value, pstate, 'specular', 186,160,160
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 76.8
      (*pstate).oObject->setProperty, AMBIENT=[44,3,3]
      (*pstate).oObject->setProperty,DIFFUSE=[157,11,11]
      (*pstate).oObject->setProperty,SPECULAR=[186,160,160]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=76.8
      (*pstate).oWindow->draw, (*pstate).oView

    end

    'Turquoise' : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 26,48,44
      d_lightproperties_set_slider_value, pstate, 'diffuse', 101,189,176
      d_lightproperties_set_slider_value, pstate, 'specular', 76,79,78
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 12.8
      (*pstate).oObject->setProperty, AMBIENT=[26,48,44]
      (*pstate).oObject->setProperty,DIFFUSE=[101,189,176]
      (*pstate).oObject->setProperty,SPECULAR=[76,79,78]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=12.8
      (*pstate).oWindow->draw, (*pstate).oView
    end

    ;; Metals
    'Brass'     : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 84,57,7
      d_lightproperties_set_slider_value, pstate, 'diffuse', 199,145,29
      d_lightproperties_set_slider_value, pstate, 'specular', 253,240,206
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 27.8974
      (*pstate).oObject->setProperty, AMBIENT=[84,57,7]
      (*pstate).oObject->setProperty,DIFFUSE=[199,145,29]
      (*pstate).oObject->setProperty,SPECULAR=[253,240,206]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=27.8974
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Bronze'    : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 54,33,14
      d_lightproperties_set_slider_value, pstate, 'diffuse', 182,109,46
      d_lightproperties_set_slider_value, pstate, 'specular', 100,69,43
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 25.6
      (*pstate).oObject->setProperty, AMBIENT=[54,33,14]
      (*pstate).oObject->setProperty,DIFFUSE=[182,109,46]
      (*pstate).oObject->setProperty,SPECULAR=[100,69,43]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=25.6
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Chrome'    : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 64,64,64
      d_lightproperties_set_slider_value, pstate, 'diffuse', 102,102,102
      d_lightproperties_set_slider_value, pstate, 'specular', 198,198,198
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 76.8
      (*pstate).oObject->setProperty, AMBIENT=[64,64,64]
      (*pstate).oObject->setProperty,DIFFUSE=[102,102,102]
      (*pstate).oObject->setProperty,SPECULAR=[198,198,198]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=76.8
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Copper'    : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 49,19,6
      d_lightproperties_set_slider_value, pstate, 'diffuse', 179,69,21
      d_lightproperties_set_slider_value, pstate, 'specular', 65,35,22
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 12.8
      (*pstate).oObject->setProperty, AMBIENT=[49,19,6]
      (*pstate).oObject->setProperty,DIFFUSE=[179,69,21]
      (*pstate).oObject->setProperty,SPECULAR=[65,35,22]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=12.8
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Gold'      : begin
      d_lightproperties_set_slider_value, pstate, 'ambient',63,51,19
      d_lightproperties_set_slider_value, pstate, 'diffuse', 192,155,58
      d_lightproperties_set_slider_value, pstate, 'specular', 160,142,93
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 51.2
      (*pstate).oObject->setProperty, AMBIENT=[63,51,19]
      (*pstate).oObject->setProperty,DIFFUSE=[192,155,58]
      (*pstate).oObject->setProperty,SPECULAR=[160,142,93]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=51.2
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Silver'    : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 49,49,49
      d_lightproperties_set_slider_value, pstate, 'diffuse', 129,129,129
      d_lightproperties_set_slider_value, pstate, 'specular', 130,130,130
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 51.2
      (*pstate).oObject->setProperty, AMBIENT=[49,49,49]
      (*pstate).oObject->setProperty,DIFFUSE=[129,129,129]
      (*pstate).oObject->setProperty,SPECULAR=[130,130,130]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=51.2
      (*pstate).oWindow->draw, (*pstate).oView
    end

    ;; Plastics
    'Black Plastic' : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0, 0, 0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 3,3,3
      d_lightproperties_set_slider_value, pstate, 'specular', 128,128,128
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 32
      (*pstate).oObject->setProperty, AMBIENT=[0,0,0]
      (*pstate).oObject->setProperty,DIFFUSE=[3,3,3]
      (*pstate).oObject->setProperty,SPECULAR=[128,128,128]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=32.0
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Cyan Plastic'  : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0,26,15
      d_lightproperties_set_slider_value, pstate, 'diffuse', 0,130,130
      d_lightproperties_set_slider_value, pstate, 'specular', 128,128,128
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 32
      (*pstate).oObject->setProperty, AMBIENT=[0,26,15]
      (*pstate).oObject->setProperty,DIFFUSE=[0,130,130]
      (*pstate).oObject->setProperty,SPECULAR=[128,128,128]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=32
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Green Plastic' : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0, 0, 0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 26,89,26
      d_lightproperties_set_slider_value, pstate, 'specular', 115,140,115
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 32
      (*pstate).oObject->setProperty, AMBIENT=[0,0,0]
      (*pstate).oObject->setProperty,DIFFUSE=[26,89,26]
      (*pstate).oObject->setProperty,SPECULAR=[115,140,115]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=32
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Red Plastic'   : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0, 0, 0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 128,0,0
      d_lightproperties_set_slider_value, pstate, 'specular', 179,153,153
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 32
      (*pstate).oObject->setProperty, AMBIENT=[0,0,0]
      (*pstate).oObject->setProperty,DIFFUSE=[128,0,0]
      (*pstate).oObject->setProperty,SPECULAR=[179,153,153]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=32
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'White Plastic' : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 140,140,140
      d_lightproperties_set_slider_value, pstate, 'specular', 179,179,179
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 32
      (*pstate).oObject->setProperty, AMBIENT=[0,0,0]
      (*pstate).oObject->setProperty,DIFFUSE=[140,140,140]
      (*pstate).oObject->setProperty,SPECULAR=[179,179,179]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=32
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Yellow Plastic': begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0, 0, 0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 128,128,0
      d_lightproperties_set_slider_value, pstate, 'specular', 153,153,128
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 32
      (*pstate).oObject->setProperty, AMBIENT=[0,0,0]
      (*pstate).oObject->setProperty,DIFFUSE=[128,128,0]
      (*pstate).oObject->setProperty,SPECULAR=[153,153,128]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=32
      (*pstate).oWindow->draw, (*pstate).oView
    end

    ;; Rubber
    'Black Rubber'  : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 5,5,5
      d_lightproperties_set_slider_value, pstate, 'diffuse', 3,3,3
      d_lightproperties_set_slider_value, pstate, 'specular', 102,102,102
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10
      (*pstate).oObject->setProperty, AMBIENT=[5,5,5]
      (*pstate).oObject->setProperty,DIFFUSE=[3,3,3]
      (*pstate).oObject->setProperty,SPECULAR=[102,102,102]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Cyan Rubber'   : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0,13,13
      d_lightproperties_set_slider_value, pstate, 'diffuse', 102,128,128
      d_lightproperties_set_slider_value, pstate, 'specular', 10,179,179
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10
      (*pstate).oObject->setProperty, AMBIENT=[0,13,13]
      (*pstate).oObject->setProperty,DIFFUSE=[102,128,128]
      (*pstate).oObject->setProperty,SPECULAR=[10,179,179]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Green Rubber'  : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 0,13,0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 102,128,102
      d_lightproperties_set_slider_value, pstate, 'specular', 10,179,10
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10
      (*pstate).oObject->setProperty, AMBIENT=[0,13,0]
      (*pstate).oObject->setProperty,DIFFUSE=[102,128,102]
      (*pstate).oObject->setProperty,SPECULAR=[10,179,10]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Red Rubber'    : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 13,0,0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 128,102,102
      d_lightproperties_set_slider_value, pstate, 'specular', 179,10,10
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10
      (*pstate).oObject->setProperty, AMBIENT=[13,0,0]
      (*pstate).oObject->setProperty,DIFFUSE=[128,102,102]
      (*pstate).oObject->setProperty,SPECULAR=[179,10,10]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'White Rubber'  : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 13, 13, 13
      d_lightproperties_set_slider_value, pstate, 'diffuse', 128,128,128
      d_lightproperties_set_slider_value, pstate, 'specular', 179,179, 179
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10
      (*pstate).oObject->setProperty, AMBIENT=[13,13,13]
      (*pstate).oObject->setProperty,DIFFUSE=[128,128,128]
      (*pstate).oObject->setProperty,SPECULAR=[179,179,179]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oWindow->draw, (*pstate).oView
    end

    'Yellow Rubber' : begin
      d_lightproperties_set_slider_value, pstate, 'ambient', 13,13,0
      d_lightproperties_set_slider_value, pstate, 'diffuse', 128,128,102
      d_lightproperties_set_slider_value, pstate, 'specular', 179,179,10
      d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
      d_lightproperties_set_slider_value, pstate, 'shininess', 10
      (*pstate).oObject->setProperty, AMBIENT=[13,13,0]
      (*pstate).oObject->setProperty,DIFFUSE=[128,128,102]
      (*pstate).oObject->setProperty,SPECULAR=[179,179,10]
      (*pstate).oObject->setProperty,EMISSION=[0,0,0]
      (*pstate).oObject->setProperty,SHININESS=10
      (*pstate).oWindow->draw, (*pstate).oView
    end

  endcase

end

;-------------------------------------------------------------------------
; handles slider and button events
;-------------------------------------------------------------------------
pro d_lightproperties_event, event
  compile_opt idl2

  widget_control, event.top, get_uvalue=pstate
  widget_control, event.id, get_uvalue=uval
  If STRCMP(uval,'tab') then return
  widget_control, event.id, get_value=val

  case (uval) of
    ;; Ambient Reflectance
    'ambient_red':begin
      (*pstate).oObject->getProperty, ambient= amb
      (*pstate).oObject->setProperty, ambient=[val ,amb[1],amb[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'ambient_green':begin
      (*pstate).oObject->getProperty, ambient= amb
      (*pstate).oObject->setProperty, ambient=[amb[0],val ,amb[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'ambient_blue':begin
      (*pstate).oObject->getProperty, ambient= amb
      (*pstate).oObject->setProperty, ambient=[amb[0],amb[1],val]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    ;;  Diffuse Reflectance
    'ambient_red':begin
      (*pstate).oObject->getProperty, ambient= amb
      (*pstate).oObject->setProperty, ambient=[val ,amb[1],amb[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'ambient_green':begin
      (*pstate).oObject->getProperty, ambient= amb
      (*pstate).oObject->setProperty, ambient=[amb[0],val ,amb[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'ambient_blue':begin
      (*pstate).oObject->getProperty, ambient= amb
      (*pstate).oObject->setProperty, ambient=[amb[0],amb[1],val]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    ;;  Diffuse Reflectance
    'diffuse_red':begin
      (*pstate).oObject->getProperty, diffuse=dif
      (*pstate).oObject->setProperty, diffuse=[val ,dif[1],dif[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'diffuse_green':begin
      (*pstate).oObject->getProperty, diffuse=dif
      (*pstate).oObject->setProperty, diffuse=[dif[0],val,dif[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'diffuse_blue':begin
      (*pstate).oObject->getProperty, diffuse=dif
      (*pstate).oObject->setProperty, diffuse=[dif[0],dif[1],val]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    ;;  Diffuse Reflectance
    'specular_red':begin
      (*pstate).oObject->getProperty, specular= spe
      (*pstate).oObject->setProperty, specular=[val ,spe[1],spe[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'specular_green':begin
      (*pstate).oObject->getProperty, specular= spe
      (*pstate).oObject->setProperty, specular=[spe[0],val, spe[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'specular_blue':begin
      (*pstate).oObject->getProperty, specular= spe
      (*pstate).oObject->setProperty, specular=[spe[0] ,spe[1],val]
      (*pstate).oWindow->draw, (*pstate).oView
    end

    ;; Emission
    'emission_red':begin
      (*pstate).oObject->getProperty, emission= emi
      (*pstate).oObject->setProperty, emission=[val ,emi[1],emi[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'emission_green':begin
      (*pstate).oObject->getProperty, emission= emi
      (*pstate).oObject->setProperty, emission=[emi[0],val,emi[2]]
      (*pstate).oWindow->draw, (*pstate).oView
    end
    'emission_blue':begin
      (*pstate).oObject->getProperty, emission= emi
      (*pstate).oObject->setProperty, emission=[emi[0],emi[1],val]
      (*pstate).oWindow->draw, (*pstate).oView
    end

    ;; Shininess
    'shininess': begin
      ;; (*pstate).oObject->getProperty, shininess=shn
      (*pstate).oObject->setProperty, shininess=val
      (*pstate).oWindow->draw, (*pstate).oView
    end
    else: ;no match
  endcase

end

;-------------------------------------------------------------------------
; main routine
;-------------------------------------------------------------------------
pro d_lightproperties, _EXTRA=_extra
  compile_opt idl2

  ;; top level base
  tlb = widget_base(/row, $
                    title="Material Properties Example", $
                    mbar=mbar)

  ;; predefined materials from openGL example
  m_values = ['Emerald','Jade','Obsidian','Pearl','Ruby','Turquoise', $
              'Brass', 'Bronze', 'Chrome', 'Copper', 'Gold', 'Silver',$
              'Black Plastic', 'Cyan Plastic','Green Plastic', 'Red Plastic', $
              'White Plastic', 'Yellow Plastic','Black Rubber', 'Cyan Rubber',$
              'Green Rubber', 'Red Rubber', 'White Rubber', 'Yellow Rubber']

  ;; objects to try
  o_values = ['Teapot', 'Tire', 'Gemstone']
  ;; slider max
  max = 255
  ;; window to draw objects
  draw_base = widget_base(tlb, /column)
  draw = widget_draw(draw_base, xsize=400, ysize=400, graphics_level=2,$
                     /button_events, /motion_events, $
                     event_pro='d_lightproperties_draw_object', retain=2)

  ;; controls
  control_base = widget_base(tlb, /column)
  selection_base = widget_base(control_base, /row)
  object_label = widget_label(selection_base, value = 'Object: ')
  object_drop = widget_droplist(selection_base, value = o_values, $
                                uvalue='o_droplist', $
                                event_pro='d_lightproperties_drop_event')
  material_label = widget_label(selection_base, value = '  Material: ')
  material_drop = widget_droplist(selection_base, value = m_values, $
                                  uvalue='m_droplist',$
                                  event_pro='d_lightproperties_m_drop_event')
  control_tab = widget_tab(control_base, location=2, multiline=1, uvalue='tab')
  ambcntrl_base = widget_base(control_tab, title='Ambient',/row, /frame)
  ambslide_base = widget_base(ambcntrl_base, /column)
  ;; Ambient Reflectance
  ambient_r = widget_slider(ambslide_base, title= "Ambient Red", $
                            max=max, scr_xsize=255, uvalue="ambient_red", $
                            event_pro='d_lightproperties_event')
  ambient_g = widget_slider(ambslide_base, title= "Ambient Green", $
                            max=max, scr_xsize=255, uvalue="ambient_green", $
                            event_pro='d_lightproperties_event')
  ambient_b = widget_slider(ambslide_base, title= "Ambient Blue", $
                            max=max, scr_xsize=255, uvalue="ambient_blue", $
                            event_pro='d_lightproperties_event')
  ;; Diffuse Reflectance
  diff_base = widget_base(control_tab, title='Diffuse', /column, /frame)
  diffuse_r = widget_slider(diff_base, title= "Diffuse Red", $
                            max=max, scr_xsize=255, uvalue="diffuse_red", $
                            event_pro='d_lightproperties_event')
  diffuse_g = widget_slider(diff_base, title= "Diffuse Green", $
                            max=max, scr_xsize=255, uvalue="diffuse_green", $
                            event_pro='d_lightproperties_event')
  diffuse_b = widget_slider(diff_base, title= "Diffuse Blue", $
                            max=max, scr_xsize=255, uvalue="diffuse_blue", $
                            event_pro='d_lightproperties_event')
  ;; Specular
  spec_base = widget_base(control_tab, title='Specular',/column, /frame)
  specular_r = widget_slider(spec_base, title= "Specular Red", $
                             max=max, scr_xsize=255, uvalue="specular_red", $
                             event_pro='d_lightproperties_event')
  specular_g = widget_slider(spec_base, title= "Specular Green", $
                             max=max, scr_xsize=255, uvalue="specular_green", $
                             event_pro='d_lightproperties_event')
  specular_b = widget_slider(spec_base, title= "Specular Blue", $
                             max=max, scr_xsize=255, uvalue="specular_blue", $
                             event_pro='d_lightproperties_event')
  ;; Emissivity
  em_base = widget_base(control_tab, title='Emission',/column, /frame)
  emission_r = widget_slider(em_base, title= "Emission Red", $
                             max=max,  scr_xsize=255, uvalue="emission_red", $
                             event_pro='d_lightproperties_event')
  emission_g = widget_slider(em_base, title= "Emission Green", $
                             max=max,  scr_xsize=255,uvalue="emission_green", $
                             event_pro='d_lightproperties_event')
  emission_b = widget_slider(em_base, title= "Emission Blue", $
                             max=max,  scr_xsize=255, uvalue="emission_blue", $
                             event_pro='d_lightproperties_event')

  ;; Shininess
  shine_base = widget_base(control_base, /column, /frame)
  shininess = cw_fslider(shine_base, title= "Shininess", $
                         max=128.0,  xsize=255, uvalue="shininess")

  ;; Realize widget hierarchy
  widget_control, tlb, /realize

  ;; read teapot data into an object
  filename = FILEPATH('teapot.dat', $
                      SUBDIRECTORY=['examples','demo','demodata'])
  oTeapot = d_objReadNoff(filename, xr, yr, zr)
  oTeapot->GetProperty, POLYGONS=teapotconn
  oTeapot->GetProperty, data = teapotdata

  oObject = OBJ_NEW('IDLgrPolygon', $
                    DATA = teapotdata*5.0, $
                    POLYGONS=teapotconn, $
                    SHADING=1,$
                    style=2, $
                    AMBIENT=[84,57,7], $
                    DIFFUSE=[199,145,29], $
                    SPECULAR=[253,240,206], $
                    EMISSION=[0,0,0], $
                    SHININESS=27.8974)

  ;; Objects
  oModel = OBJ_NEW('IDLgrModel')
  oAmbLight = OBJ_NEW('IDLgrLight', TYPE=0, $
                      COLOR=[50,50,50])
  oPosLight = OBJ_NEW('IDLgrLight', TYPE=1, $
                      COLOR=[255,255,255], LOCATION=[2,99,200])
  oLightModel=obj_new('idlgrmodel')
  oLightModel->Add, [oAmbLight, oPosLight]
  oTrack = obj_new('Trackball', [200,200],200)
  oView = obj_new('idlgrview', color=[100,100,100], zclip=[3,-3], $
                  viewplane_rect=[-3,-3,6,6])
  ;;
  oModel->Add, oObject
  oView->add, oModel
  oView->add, oLightModel


  widget_control, draw, get_value=oWindow
  oWindow->Draw, oView

  ;; state structure
  state = {draw:draw,$
           material_drop:material_drop,$
           object_drop:object_drop,$
           teapotdata:teapotdata,$
           teapotconn:teapotconn,$
           oTeapot:oTeapot, $
           oTrack:oTrack, $
           oModel:oModel, $
           oView:oView, $
           oWindow:oWindow, $
           oAmbLight:oAmbLight,$
           oPosLight:oPosLight,$
           oLightModel:oLightModel, $
           oObject:oObject, $
           m_values:m_values, $
           o_values:o_values,$
           ambient_r:ambient_r, $
           ambient_g:ambient_g, $
           ambient_b:ambient_b, $
           diffuse_r:diffuse_r, $
           diffuse_g:diffuse_g, $
           diffuse_b:diffuse_b, $
           specular_r:specular_r, $
           specular_g:specular_g, $
           specular_b:specular_b, $
           emission_r:emission_r, $
           emission_g:emission_g, $
           emission_b:emission_b, $
           shininess:shininess}

  pstate = ptr_new(state)
  widget_control, (*pstate).material_drop, set_droplist_select=6
  widget_control, tlb, set_uvalue=pstate

  ;; set the initial values for the brass teapot
  d_lightproperties_set_slider_value, pstate, 'ambient', 84,57,7
  d_lightproperties_set_slider_value, pstate, 'diffuse', 199,145,29
  d_lightproperties_set_slider_value, pstate, 'specular', 253,240,206
  d_lightproperties_set_slider_value, pstate, 'emission', 0,0,0
  d_lightproperties_set_slider_value, pstate, 'shininess', 27.8974

  ;; manage events
  xmanager, 'd_lightproperties', tlb, cleanup='d_lightproperties_cleanup'

  ptr_free, pstate

END
