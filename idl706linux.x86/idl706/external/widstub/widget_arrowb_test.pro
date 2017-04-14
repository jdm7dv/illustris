; $Id: //depot/idl/IDL_70/idldir/external/widstub/widget_arrowb_test.pro#1 $

pro widget_arrowb_test_event, ev

  widget_control, get_uvalue=val, ev.id
  if (val eq 0) then begin
	widget_control, /destroy, ev.top 
  endif else begin
	HELP, /STRUCT, ev
	if (ev.value eq 1) then begin
            widget_control,val,set_value='New label string'
	    tmp = widget_info(ev.id,/GEOMETRY)
	    widget_control, xsize=tmp.xsize+25, ysize=tmp.ysize+25, ev.id
        endif
  endelse

end


pro widget_arrowb_test, VERBOSE=verbose
  a = widget_base(/COLUMN)
  b = widget_button(a, value='Done', uvalue = 0)
  label=widget_label(a,value='A label')
  arrow_w = widget_arrowb(a, 0, xsize=100, ysize=100, uvalue=label, $
		          verbose=verbose)
  arrow_w = widget_arrowb(a, 1, xsize=100, ysize=50, uvalue=label, $
			  verbose=verbose)
  widget_control,/real,a

  xmanager, 'WIDGET_ARROWB_TEST', a, /NO_BLOCK
end

