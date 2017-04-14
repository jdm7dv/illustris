;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_load, id, pxco
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  wState = widget_info(id, find_by_uname='descovstatebase_tab3')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab3_remove, pstate

  ; we just store the ptr to the idl struc holding describe cov data created in tab1
  (*pstate).pxco = pxco
  xco = *(*pstate).pxco

  widget_control, (*pstate).wtxtSelCo,          set_value = xco.co_name
  widget_control, (*pstate).wtxtCoLabel,        set_value = xco.co_label

  if (xco.num_range_axes gt 0) then begin
     idxarr = make_array(xco.num_range_axes, /string)
     for zz=0, xco.num_range_axes-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlAxisIdx,      set_value = idxarr
  endif

  widget_control, (*pstate).wtxtRngName,      set_value = xco.range.name
  widget_control, (*pstate).wtxtRngLabel,     set_value = xco.range.label
  widget_control, (*pstate).wtxtRngDesc,      set_value = xco.range.desc
  widget_control, (*pstate).wdlRngNull,       set_value = xco.range.null_single_values

  if (xco.range.num_null_intervals gt 0) then begin
     idxarr = make_array(xco.range.num_null_intervals, /string)
     for zz=0, xco.range.num_null_intervals-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlRngNullIntIdx,      set_value = idxarr
  endif

  cw_ogc_wcs_descov_tab3_load_range_null_int, pstate, 0
  cw_ogc_wcs_descov_tab3_load_range_axis, pstate, 0

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_remove, pstate
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  widget_control, (*pstate).wtxtSelCo,                  set_value = ''
  widget_control, (*pstate).wtxtCoLabel,                set_value = ''

  widget_control, (*pstate).wtxtRngName,                set_value = ''
  widget_control, (*pstate).wtxtRngLabel,               set_value = ''
  widget_control, (*pstate).wtxtRngDesc,                set_value = ''
  widget_control, (*pstate).wdlRngNull,                 set_value = ''

  widget_control, (*pstate).wdlRngNullIntIdx,           set_value = ''
  widget_control, (*pstate).wtxtRngNullIntMin,          set_value = ''
  widget_control, (*pstate).wtxtRngNullIntMax,          set_value = ''
  widget_control, (*pstate).wtxtRngNullIntRes,          set_value = ''


  widget_control, (*pstate).wdlAxisIdx,                 set_value = ''
  widget_control, (*pstate).wtxtAxisName,               set_value = ''
  widget_control, (*pstate).wtxtAxisDesc,               set_value = ''
  widget_control, (*pstate).wtxtAxisLabel,              set_value = ''
  widget_control, (*pstate).wtxtAxisDefault,            set_value = ''
  widget_control, (*pstate).wdlAxisSingle,              set_value = ''

  widget_control, (*pstate).wdlAxisIntIdx,              set_value = ''
  widget_control, (*pstate).wtxtAxisIntMin,             set_value = ''
  widget_control, (*pstate).wtxtAxisIntMax,             set_value = ''
  widget_control, (*pstate).wtxtAxisIntRes,             set_value = ''
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_load_range_axis, pstate, idx
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  xco = *(*pstate).pxco

  widget_control, (*pstate).wtxtAxisName,           set_value = xco.range_axis[idx].name
  widget_control, (*pstate).wtxtAxisDesc,           set_value = xco.range_axis[idx].desc
  widget_control, (*pstate).wtxtAxisLabel,          set_value = xco.range_axis[idx].label

  widget_control, (*pstate).wtxtAxisDefault,        set_value = xco.range_axis[idx].default


  ; xco.range_axis[idx].single_value is created to hold the max number of single_values over all
  ; the axes so remove any values that are '', these are the unused single values in a particular
  ; xco.range_axis[idx]
  single_value = ''
  cnt = size(xco.range_axis[idx].single_value, /n_dim) ? n_elements(xco.range_axis[idx].single_value) : 0
  if (cnt gt 0) then begin
      numValues = 0
      for xx=0, cnt-1 do begin
        if (xco.range_axis[idx].single_value[xx] ne '') then begin
           numValues++
        endif
      endfor
      single_value = make_array(numValues, /string)
      for xx=0, cnt-1 do begin
        if (xco.range_axis[idx].single_value[xx] ne '') then begin
           single_value[xx] = xco.range_axis[idx].single_value[xx]
        endif
      endfor
  endif
  widget_control, (*pstate).wdlAxisSingle,          set_value = single_value

  widget_control, (*pstate).wdlAxisIntIdx,              set_value = ''
  widget_control, (*pstate).wtxtAxisIntMin,             set_value = ''
  widget_control, (*pstate).wtxtAxisIntMax,             set_value = ''
  widget_control, (*pstate).wtxtAxisIntRes,             set_value = ''

  ; leave the dropdown list blank if this range_axis does not have in intervals
  if (xco.range_axis[idx].num_intervals gt 0) then begin
     idxarr = make_array(xco.range_axis[idx].num_intervals, /string)
     for zz=0, xco.range_axis[idx].num_intervals-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlAxisIntIdx,      set_value = idxarr
     cw_ogc_wcs_descov_tab3_load_range_axis_int, pstate, 0
  endif

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_load_range_null_int, pstate, idx
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  xco = *(*pstate).pxco

  widget_control, (*pstate).wtxtRngNullIntMin,           set_value = xco.range.null_interval[idx].min
  widget_control, (*pstate).wtxtRngNullIntMax,           set_value = xco.range.null_interval[idx].max
  widget_control, (*pstate).wtxtRngNullIntRes,           set_value = xco.range.null_interval[idx].res
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_load_range_axis_int, pstate, idx
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  xco = *(*pstate).pxco

  idxAxis = widget_info((*pstate).wdlAxisIdx, /droplist_select)

  widget_control, (*pstate).wtxtAxisIntMin,           set_value = xco.range_axis[idxAxis].interval[idx].min
  widget_control, (*pstate).wtxtAxisIntMax,           set_value = xco.range_axis[idxAxis].interval[idx].max
  widget_control, (*pstate).wtxtAxisIntRes,           set_value = xco.range_axis[idxAxis].interval[idx].res
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_dlRngNullIntIdx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab3')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlRngNullIntIdx, /droplist_select)

  cw_ogc_wcs_descov_tab3_load_range_null_int, pstate, idx
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_dlAxisIdx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab3')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlAxisIdx, /droplist_select)

  cw_ogc_wcs_descov_tab3_load_range_axis, pstate, idx
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_dlAxisIntIdx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab3')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlAxisIntIdx, /droplist_select)

  cw_ogc_wcs_descov_tab3_load_range_axis_int, pstate, idx
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_kill_event, id
  compile_opt idl2
  catch, errorStatus            ; catch all errors and display an error dialog

  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    return
  endif

  ; called when the main ui is destroyed we let go of objects and pointers

  widget_control, id, get_uvalue = pstate

  if ptr_valid(pstate) then begin
    ptr_free, pstate
  endif
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab3_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  wState = widget_info(id, find_by_uname='descovstatebase_tab3')
  widget_control, wState, get_uvalue = pstate
end

;;----------------------------------------------------------------------------
pro  cw_ogc_wcs_descov_tab3, parent
  compile_opt idl2
  on_error, 2

  wDC3Base           = widget_base(parent, /CoLUMN, TITLE='Coverage Offering Spatial Domain', NOTIFY_REALIZE='cw_ogc_wcs_descov_tab3_realize_notify_event', space=5)
  wDC3BaseState      = widget_base(wDC3Base, uname='descovstatebase_tab3', kill_notify='cw_ogc_wcs_descov_tab3_kill_event')

  x_sz      = 860
  lbl_sz    = 140
  widg_sz   = 260

  drop_ysz = 20
  if (!version.os_family eq 'unix') then begin
     drop_ysz = 35
  endif


  ; add the coverage offering frame ------------------------
  wDC3BaseCo        = widget_base(wDC3Base)
  wLblCo            = widget_label(wDC3BaseCo, value=' Coverage Offering Continued ', xoffset=5)
  winfoLblCo        = widget_info(wLblCo, /geometry)
  wDC3BaseFrCo      = widget_base(wDC3BaseCo, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblCo            = widget_label(wDC3BaseCo, value=' Coverage Offering Continued ', xoffset=5)

  ; the currently select coverage name is displayed
  wRow              = widget_base(wDC3BaseFrCo, /row)
  wlblSelCo         = widget_label(wRow, value = 'Selected Coverage ', scr_xsize = lbl_sz, /align_right)
  wtxtSelCo         = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2)

  ; the label for the currently selected coverage
  wRow              = widget_base(wDC3BaseFrCo, /row)
  wlblSelCo         = widget_label(wRow, value = 'Label ', scr_xsize = lbl_sz, /align_right)
  wtxtCoLabel       = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2)


  ; range set
  wDC3BaseRng        = widget_base(wDC3BaseFrCo)
  wLblRng            = widget_label(wDC3BaseRng, value=' Range Set ', xoffset=5)
  winfoLblRng        = widget_info(wLblRng, /geometry)
  wDC3BaseFrRng      = widget_base(wDC3BaseRng, /frame, yoffset=winfoLblRng.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblRng            = widget_label(wDC3BaseRng, value=' Range Set ', xoffset=5)

  wRow               = widget_base(wDC3BaseFrRng, /row)
  wlblRngName        = widget_label(wRow, value = 'Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtRngName        = widget_text(wRow, scr_xsize=widg_sz)

  wlblRngLabel       = widget_label(wRow, value = 'Label ', scr_xsize = lbl_sz-5, /align_right)
  wtxtRngLabel       = widget_text(wRow, scr_xsize=widg_sz)

  wRow               = widget_base(wDC3BaseFrRng, /row)
  wlblRngDesc        = widget_label(wRow, value = 'Description ', scr_xsize = lbl_sz-5, /align_right)
  wtxtRngDesc        = widget_text(wRow, scr_xsize=widg_sz)

  wlblRngNull        = widget_label(wRow, value = 'Null Single Values ', scr_xsize = lbl_sz-5, /align_right)
  wdlRngNull         = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)

  wRow               = widget_base(wDC3BaseFrRng, /row)
  wlblRngNullIntIdx  = widget_label(wRow, value = 'Null Interval Val Idx ', scr_xsize = lbl_sz-5, /align_right)
  wdlRngNullIntIdx   = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro='cw_ogc_wcs_descov_tab3_dlRngNullIntIdx_event')

  wlblRngNullIntRes  = widget_label(wRow, value = 'Null Interval Val Res ', scr_xsize = lbl_sz-5, /align_right)
  wtxtRngNullIntRes  = widget_text(wRow, scr_xsize=widg_sz)

  wRow               = widget_base(wDC3BaseFrRng, /row)
  wlblRngNullIntMin  = widget_label(wRow, value = 'Null Interval Val Min ', scr_xsize = lbl_sz-5, /align_right)
  wtxtRngNullIntMin  = widget_text(wRow, scr_xsize=widg_sz)

  wlblRngNullIntMax  = widget_label(wRow, value = 'Null Interval Val Max ', scr_xsize = lbl_sz-5, /align_right)
  wtxtRngNullIntMax  = widget_text(wRow, scr_xsize=widg_sz)


  ; range set
  wDC3BaseAx         = widget_base(wDC3BaseFrCo)
  wLblAx             = widget_label(wDC3BaseAx, value=' Range Set Axis ', xoffset=5)
  winfoLblAx         = widget_info(wLblAx, /geometry)
  wDC3BaseFrAx       = widget_base(wDC3BaseAx, /frame, yoffset=winfoLblAx.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblAx             = widget_label(wDC3BaseAx, value=' Range Set Axis ', xoffset=5)

  wRow               = widget_base(wDC3BaseFrAx, /row)
  wlblAxisIdx        = widget_label(wRow, value = 'Axis Index ', scr_xsize = lbl_sz-5, /align_right)
  wdlAxisIdx         = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro='cw_ogc_wcs_descov_tab3_dlAxisIdx_event')

  wlblAxisName       = widget_label(wRow, value = 'Axis Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisName       = widget_text(wRow, scr_xsize=widg_sz)

  wRow               = widget_base(wDC3BaseFrAx, /row)
  wlblAxisDesc       = widget_label(wRow, value = 'Axis Decription ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisDesc       = widget_text(wRow, scr_xsize=widg_sz)

  wlbl               = widget_label(wRow, value = 'Axis Default ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisDefault    = widget_text(wRow, scr_xsize=widg_sz)

  wRow               = widget_base(wDC3BaseFrAx, /row)
  wlblAxisLabel      = widget_label(wRow, value = 'Axis Label ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisLabel      = widget_text(wRow, scr_xsize=widg_sz)

  wlblAxisSingle     = widget_label(wRow, value = 'Axis Single Values ', scr_xsize = lbl_sz-5, /align_right)
  wdlAxisSingle      = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)

  wRow               = widget_base(wDC3BaseFrAx, /row)
  wlblAxisIntIdx     = widget_label(wRow, value = 'Axis Interval Val Idx ', scr_xsize = lbl_sz-5, /align_right)
  wdlAxisIntIdx      = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro='cw_ogc_wcs_descov_tab3_dlAxisIntIdx_event')

  wlblAxisIntRes     = widget_label(wRow, value = 'Axis Interval Val Res ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisIntRes     = widget_text(wRow, scr_xsize=widg_sz)

  wRow               = widget_base(wDC3BaseFrAx, /row)
  wlblAxisIntMin     = widget_label(wRow, value = 'Axis Interval Val Min ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisIntMin     = widget_text(wRow, scr_xsize=widg_sz)

  wlblAxisIntMax     = widget_label(wRow, value = 'Axis Interval Val Max ', scr_xsize = lbl_sz-5, /align_right)
  wtxtAxisIntMax     = widget_text(wRow, scr_xsize=widg_sz)


  widget_control, wDC3BaseFrCo,      scr_xsize=x_sz

  pxco = ptr_new()

  ;paxServers is a ptr to an array of structures that define the remote servers, set in ogc_wcs_getConfigInfo
  state = {pxco:pxco, $
           wtxtSelCo:wtxtSelCo, wtxtCoLabel:wtxtCoLabel, $
           wtxtRngName:wtxtRngName, wtxtRngLabel:wtxtRngLabel, wtxtRngDesc:wtxtRngDesc, wdlRngNull:wdlRngNull, $
           wdlAxisIdx:wdlAxisIdx, wtxtAxisName:wtxtAxisName, wtxtAxisLabel:wtxtAxisLabel, wdlAxisSingle:wdlAxisSingle, $
           wtxtAxisDesc:wtxtAxisDesc, wtxtAxisDefault:wtxtAxisDefault, $
           wdlRngNullIntIdx:wdlRngNullIntIdx, wtxtRngNullIntRes:wtxtRngNullIntRes, wtxtRngNullIntMin:wtxtRngNullIntMin, $
           wtxtRngNullIntMax:wtxtRngNullIntMax, $
           wdlAxisIntIdx:wdlAxisIntIdx, wtxtAxisIntRes:wtxtAxisIntRes, wtxtAxisIntMin:wtxtAxisIntMin, wtxtAxisIntMax:wtxtAxisIntMax }

  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wDC3BaseState, set_uvalue=pstate
end

