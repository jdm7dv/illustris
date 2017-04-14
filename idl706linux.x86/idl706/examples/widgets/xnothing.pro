; $Id: //depot/idl/IDL_70/idldir/examples/widgets/xnothing.pro#2 $
;
; Copyright (c) 1991-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;	XNOTHING
;
; PURPOSE:
;	A demonstration of all the IDL widgets.  This routine demonstrates
;	everything without actually doing anything useful.
;
; CATEGORY:
;	Widgets, demo.
;
; CALLING SEQUENCE:
;	XNOTHING
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; MODIFICATION HISTORY:
;	October, 1990, A.B.
;	Revised to work with XMANAGER, 3 January 1991
;	Modified to handle changed event names.
;
;-

pro xnothing_event, ev

  widget_control, ev.id, get_uvalue=value
  if (n_elements(value) eq 0) then value = ''
  name = strmid(tag_names(ev, /structure_name), 7, 4)
  case (name) of
  "BUTT": begin
	if (value eq "DONE") then begin
	  WIDGET_CONTROL, /destroy, ev.top
	  return
	endif
	if (ev.select eq 0) then begin
	  value = value + ' (released)'
	endif else begin
	  value = value + ' (selected)'
	endelse
	endcase
  "DRAW": begin
	value = string(format="(A,' X(', I0, ')', ' Y(', I0, ')', ' Press('," $
		+ "I0, ')', ' Release(', I0, ')')", value, ev.x, ev.y, $
		ev.press, ev.release)
	end
  "SLID": value = ev.value
  "TEXT": widget_control, ev.id, get_value=value, set_value=''
  "LIST": value=value[ev.index]
  else:
  endcase

  WIDGET_CONTROL, ev.top, get_uvalue=out_text
  WIDGET_CONTROL, out_text , set_value=name + ': ' + string(value),/append
end



pro xnothing

  swin = !d.window	;Previous window

  base = WIDGET_BASE(title='XNothing', /row)
  ; Setting the managed attribute indicates our intention to put this app
  ; under the control of XMANAGER, and prevents our draw widgets from
  ; becoming candidates for becoming the default window on WSET, -1. XMANAGER
  ; sets this, but doing it here prevents our own WSETs at startup from
  ; having that problem.
  WIDGET_CONTROL, /MANAGED, base

  b1 = WIDGET_BASE(base, /frame, /column)
  t1 = WIDGET_TEXT(b1, xsize=80, ysize=10, /SCROLL, $
      value=[ 'Nothing Is Everything:', $
	'', $
	'      This is a demonstration of every widget availible', $
	'    under the IDL widget facility. Manipulating the widgets', $
	'    causes messages to be written to this window. Try pushing', $
	'    the buttons, moving the slider, clicking the mouse inside', $
	'    the drawing area, typing inside the 1 line text area', $
	"    (don't forget to type return), or selecting an item in the", $
	'    scrolling list. To exit this demo, press the DONE button.' ])
  WIDGET_CONTROL, base, set_uvalue=t1

  b2 = WIDGET_BASE(base, /frame, /column, space=30)


  t1 = widget_base(b1, /row)
  t2 = widget_label(t1, value = 'Text (Input/Output):')
  intext = widget_text(t1, /editable, xsize=50, ysize=1)

  draw = widget_draw(b1, xsize=320, ysize=256, /button_events)

  t1=widget_label(b1, value='Text (Read-only)')
  t1 = [  '    ROUTINE:', $
    '         DILATE(Image, Structure [, X_0, Y_0])', $
    '', $
    '    DESCRIPTION:', $
    '         The DILATE  function  implements  the  morphologic  dilation', $
    '         operator on both binary and gray scale images.', $
    '', $
    '    ARGUMENTS:', $
    '      Image:', $
    '          The array upon which the operation is to be performed.   If', $
    '         the  parameter is not of byte type, a temporary byte copy is', $
    '         obtained. If neither keyword GRAY or VALUES is present,  the', $
    '         image  is considered a binary image with all non-zero pixels', $
    '         considered as 1.', $
    '', $
    '      Structure:', $
    '          The structuring element which may be a one  or  two  dimen-', $
    '         sional  array.   Elements  are interpreted as binary: values', $
    '         are either zero or non-zero.', $
    '', $
    '      X_0, Y_0:', $
    '          Optional parameters specifying the row and  column  coordi-', $
    "         nate  of  the structuring element's origin.  If omitted, the", $
    '         origin is set to the center,  (  N_X / 2 ,  N_Y  /  2   )  ,', $
    '         where N_X and N_Y are the dimensions of the structuring ele-', $
    '         ment array.  The origin need not be within  the  structuring', $
    '         element.', $
    '', $
    '    KEYWORDS:', $
    '      GRAY:', $
    '          a flag which,  if  present,   indicates  that  gray  scale,', $
    '         rather  than binary dilation is requested. Non-zero elements', $
    '         of Structure parameter determine the  shape  of  structuring', $
    '         element  (neighborhood).  If VALUES is not present, all ele-', $
    '         ments of the structuring element are 0, yielding the  neigh-', $
    '         borhood maximum operator.', $
    '', $
    '      VALUES:', $
    '          an array of the same dimensions as Structure providing  the', $
    '         values of the structuring element.  Presence of this parame-', $
    '         ter implies gray scale dilation.  Each pixel of  the  result', $
    '         is  the  maximum of the sum of the corresponding elements of', $
    '         VALUE overlaid with Image.']

  t1 = widget_text(b1, ysize=14, xsize=80,/scroll, value=t1)


  t1 = widget_button(b2, value="Done", uvalue = "DONE")
  t1 = widget_button(b2, value = 'Push Button', uvalue = 'Push Button')

  t1 = widget_slider(b2, title='Slider')

  t2 = widget_base(b2, /COLUMN)
  list_names= [ 'ABS', $
	'ACOS', $
	'ALOG', $
	'ALOG10', $
	'ASIN', $
	'ASSOC', $
	'ATAN', $
	'AXIS', $
	'BESELI', $
	'BESELJ', $
	'BESELY', $
	'BINDGEN', $
	'BREAKPOINT', $
	'BYTARR', $
	'BYTE', $
	'BYTEORDER', $
	'BYTSCL', $
	'CALL_EXTERNAL', $
	'CD', $
	'CHECK_MATH', $
	'CINDGEN', $
	'CLOSE', $
	'COLOR_CONVERT', $
	'COMPLEX', $
	'COMPLEXARR', $
	'CONJ', $
	'CONTOUR', $
	'CONVOL', $
	'COS', $
	'COSH', $
	'CURSOR', $
	'DBLARR', $
	'DEFINE_KEY', $
	'DEFSYSV', $
	'DELETE_SYMBOL', $
	'DELLOG' ]
  t1 = WIDGET_LIST(t2, ysize=10, uvalue=list_names, value=list_names)

  t2 = widget_base(b2, /column)
  t1 = widget_label(t2, value='Toggle Button Menu')
  pets = [ 'Dog', 'Cat', 'Snake', 'Moose' ]
  XMENU, pets, t2, /EXCLUSIVE, /FRAME, uvalue=pets

  t2 = widget_base(b2, /column)
  t1 = widget_label(t2,value='Pulldown Menu')
  xpdmenu, [ '/Colors/ {', '  /Red/', '  /Green/', '  /Blue/ {', $
	'    /Light/ Light Blue', '    /Medium/ Medium Blue', $
	'    /Dark/ Dark Blue', '    /Royal/ Royal Blue', $
	'    /Navy/ Navy Blue', '  }', '}' ], t2

  widget_control, base, /realize

  WIDGET_CONTROL, get_value=window, draw
  openr, u, filepath('abnorm.dat', subdir=["examples", "data"]), /get_lun
  a=bytarr(64,64)
  readu,u,a
  free_lun, u
  wset, window
  loadct,3
  shade_surf,rebin(a,32,32)
  wset, swin

  XMANAGER, 'XNOTHING', base, /NO_BLOCK
end
