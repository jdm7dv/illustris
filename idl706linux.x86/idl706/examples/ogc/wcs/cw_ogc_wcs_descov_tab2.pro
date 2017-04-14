
;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_load, id, pxco
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  wState = widget_info(id, find_by_uname='descovstatebase_tab2')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab2_remove, pstate

  ; we just store the ptr to the idl struc holding describe cov data created in tab1
  (*pstate).pxco = pxco
  xco = *(*pstate).pxco

  widget_control, (*pstate).wtxtSelCo,          set_value = xco.co_name
  widget_control, (*pstate).wtxtCoLabel,        set_value = xco.co_label

  widget_control, (*pstate).wtxtSrsName,        set_value = xco.lonlatenv.srs_name

  widget_control, (*pstate).wtxtPos1,           set_value = xco.lonlatenv.pos1
  if (xco.lonlatenv.dims1 eq '') then begin
     lbl = 'Postion 1 '
  endif else begin
     lbl = 'Postion 1 (' + xco.lonlatenv.dims1 + ' Dims) '
  endelse
  widget_control, (*pstate).wlblPos1,           set_value = lbl

  widget_control, (*pstate).wtxtPos2,           set_value = xco.lonlatenv.pos2
  if (xco.lonlatenv.dims2 eq '') then begin
     lbl = 'Postion 2 '
  endif else begin
     lbl = 'Postion 2 (' + xco.lonlatenv.dims2 + ' Dims) '
  endelse
  widget_control, (*pstate).wlblPos2,           set_value = lbl

  widget_control, (*pstate).wtxtTmPos1,         set_value = xco.lonlatenv.time_pos1
  widget_control, (*pstate).wtxtTmPos2,         set_value = xco.lonlatenv.time_pos2

  widget_control, (*pstate).wdlinterpol,        set_value = xco.interpolation_method
  widget_control, (*pstate).wtxtDfltInterpol,   set_value = xco.native_interpolation

  if (xco.num_spat_dom_grids gt 0) then begin
     idxarr = make_array(xco.num_spat_dom_grids, /string)
     for zz=0, xco.num_spat_dom_grids-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlGridIdx,      set_value = idxarr
  endif

  if (xco.num_temp_tm_periods gt 0) then begin
     idxarr = make_array(xco.num_temp_tm_periods, /string)
     for zz=0, xco.num_temp_tm_periods-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlTmPerIdx,      set_value = idxarr
  endif


  if (xco.num_temp_tm_positions gt 0) then begin
     idxarr = make_array(xco.num_temp_tm_positions, /string)
     for zz=0, xco.num_temp_tm_positions-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlTmPosIdx,      set_value = idxarr
  endif


  cw_ogc_wcs_descov_tab2_load_grid, pstate, 0
  cw_ogc_wcs_descov_tab2_load_temporal_pos, pstate, 0
  cw_ogc_wcs_descov_tab2_load_temporal_period, pstate, 0
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_remove, pstate
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  widget_control, (*pstate).wtxtCoLabel,            set_value = ''

  widget_control, (*pstate).wdlInterpol,            set_value = ''
  widget_control, (*pstate).wtxtDfltInterpol,       set_value = ''
  widget_control, (*pstate).wtxtSrsName,            set_value = ''
  widget_control, (*pstate).wtxtPos1,               set_value = ''
  widget_control, (*pstate).wlblPos1,               set_value = 'Position 1'
  widget_control, (*pstate).wtxtPos2,               set_value = ''
  widget_control, (*pstate).wlblPos2,               set_value = 'Position 2'
  widget_control, (*pstate).wtxtGridRect,           set_value = ''
  widget_control, (*pstate).wtxtGridSrs,            set_value = ''
  widget_control, (*pstate).wdlGridAxis,            set_value = ''
  widget_control, (*pstate).wtxtGridEnvLow,         set_value = ''
  widget_control, (*pstate).wtxtGridEnvHigh,        set_value = ''
  widget_control, (*pstate).wtxtGridOrigPos,        set_value = ''
  widget_control, (*pstate).wdlGridOffVec,          set_value = ''
  widget_control, (*pstate).wdlTmPosIdx,            set_value = ''
  widget_control, (*pstate).wtxtTmPos,              set_value = ''
  widget_control, (*pstate).wtxtTmPosFr,            set_value = ''
  widget_control, (*pstate).wtxtTmPosCal,           set_value = ''
  widget_control, (*pstate).wtxtTmPosIndeter,       set_value = ''
  widget_control, (*pstate).wdlTmPerIdx,            set_value = ''
  widget_control, (*pstate).wtxtTmPerFr,            set_value = ''
  widget_control, (*pstate).wtxtTmPerBegin,         set_value = ''
  widget_control, (*pstate).wtxtTmPerEnd,           set_value = ''
  widget_control, (*pstate).wtxtTmPerCal,           set_value = ''
  widget_control, (*pstate).wtxtTmPerIndeter,       set_value = ''
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_load_grid, pstate, idx
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  xco = *(*pstate).pxco

  ; xco.spat_dom_grid[idx].axis_names is created to hold the max number of axis_names over all
  ; the grids so remove any values that are '', these are the unused axis_names in a particular
  ; xco.spat_dom_grid[idx]
  axes = ''
  cnt = size(xco.spat_dom_grid[idx].axis_names, /n_dim) ? n_elements(xco.spat_dom_grid[idx].axis_names) : 0

  if (cnt gt 0) then begin
      numValues = 0
      for xx=0, cnt-1 do begin
        if (xco.spat_dom_grid[idx].axis_names[xx] ne '') then begin
           numValues++
        endif
      endfor
      axes = make_array(numValues, /string)
      for xx=0, cnt-1 do begin
        if (xco.spat_dom_grid[idx].axis_names[xx] ne '') then begin
           axes[xx] = xco.spat_dom_grid[idx].axis_names[xx]
        endif
      endfor
  endif

  ; xco.spat_dom_grid[idx].offset_vectors is created to hold the max number of offset_vectors over all
  ; the grids so remove any values that are '', these are the unused offset_vectors in a particular
  ; xco.spat_dom_grid[idx]
  vectors = ''
  cnt = size(xco.spat_dom_grid[idx].offset_vectors, /n_dim) ? n_elements(xco.spat_dom_grid[idx].offset_vectors) : 0

  if (cnt gt 0) then begin
      numValues = 0
      for xx=0, cnt-1 do begin
        if (xco.spat_dom_grid[idx].offset_vectors[xx] ne '') then begin
           numValues++
        endif
      endfor
      vectors = make_array(numValues, /string)
      for xx=0, cnt-1 do begin
        if (xco.spat_dom_grid[idx].offset_vectors[xx] ne '') then begin
           vectors[xx] = xco.spat_dom_grid[idx].offset_vectors[xx]
        endif
      endfor
  endif

  widget_control, (*pstate).wtxtGridRect,           set_value = xco.spat_dom_grid[idx].rectified
  widget_control, (*pstate).wtxtGridSrs,            set_value = xco.spat_dom_grid[idx].srs_name
  widget_control, (*pstate).wdlGridAxis,            set_value = axes
  widget_control, (*pstate).wtxtGridEnvLow,         set_value = xco.spat_dom_grid[idx].limits_env_low
  widget_control, (*pstate).wtxtGridEnvHigh,        set_value = xco.spat_dom_grid[idx].limits_env_high
  widget_control, (*pstate).wtxtGridOrigPos,        set_value = xco.spat_dom_grid[idx].origin_pos
  widget_control, (*pstate).wdlGridOffVec,          set_value = vectors
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_load_temporal_period, pstate, idx
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  xco = *(*pstate).pxco
  widget_control, (*pstate).wtxtTmPerBegin,      set_value = xco.temp_tm_period[idx]._begin
  widget_control, (*pstate).wtxtTmPerEnd,        set_value = xco.temp_tm_period[idx]._end
  widget_control, (*pstate).wtxtTmPerRes,        set_value = xco.temp_tm_period[idx].resolution
  widget_control, (*pstate).wtxtTmPerFr,         set_value = xco.temp_tm_period[idx].frame
  widget_control, (*pstate).wtxtTmPerCal,        set_value = xco.temp_tm_period[idx].calendar
  widget_control, (*pstate).wtxtTmPerIndeter,    set_value = xco.temp_tm_period[idx].indeterminate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_load_temporal_pos, pstate, idx
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  xco = *(*pstate).pxco
  widget_control, (*pstate).wtxtTmPos,           set_value = xco.temp_tm_position[idx].position
  widget_control, (*pstate).wtxtTmPosFr,         set_value = xco.temp_tm_position[idx].frame
  widget_control, (*pstate).wtxtTmPosCal,        set_value = xco.temp_tm_position[idx].calendar
  widget_control, (*pstate).wtxtTmPosIndeter,    set_value = xco.temp_tm_position[idx].indeterminate
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_dlTmPerIdx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab2')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlTmPerIdx, /droplist_select)

  cw_ogc_wcs_descov_tab2_load_temporal_period, pstate, idx
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_dlTmPosIdx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab2')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlTmPosIdx, /droplist_select)

  cw_ogc_wcs_descov_tab2_load_temporal_pos, pstate, idx
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_dlGridIdxx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab2')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlGridIdx, /droplist_select)

  cw_ogc_wcs_descov_tab2_load_grid, pstate, idx
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab2_kill_event, id
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
pro cw_ogc_wcs_descov_tab2_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  wState = widget_info(id, find_by_uname='descovstatebase_tab2')
  widget_control, wState, get_uvalue = pstate
end

;;----------------------------------------------------------------------------
pro  cw_ogc_wcs_descov_tab2, parent
  compile_opt idl2
  on_error, 2

  wDCCBase           = widget_base(parent, /CoLUMN, TITLE='Coverage Offering Spatial Domain', NOTIFY_REALIZE='cw_ogc_wcs_descov_tab2_realize_notify_event', space=5)
  wDCCBaseState      = widget_base(wDCCBase, uname='descovstatebase_tab2', kill_notify='cw_ogc_wcs_descov_tab2_kill_event')

  x_sz      = 860
  lbl_sz    = 140
  widg_sz   = 260

  drop_ysz = 20
  if (!version.os_family eq 'unix') then begin
     drop_ysz = 35
  endif


  ; add the coverage offering frame ------------------------
  wDCCBaseCo        = widget_base(wDCCBase)
  wLblCo            = widget_label(wDCCBaseCo, value=' Coverage Offering Continued ', xoffset=5)
  winfoLblCo        = widget_info(wLblCo, /geometry)
  wDCCBaseFrCo      = widget_base(wDCCBaseCo, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblCo            = widget_label(wDCCBaseCo, value=' Coverage Offering Continued ', xoffset=5)

  ; the currently select coverage name is displayed
  wRow              = widget_base(wDCCBaseFrCo, /row)
  wlblSelCo         = widget_label(wRow, value = 'Selected Coverage ', scr_xsize = lbl_sz, /align_right)
  wtxtSelCo         = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2)

  ; the label for the currently selected coverage
  wRow              = widget_base(wDCCBaseFrCo, /row)
  wlblSelCo         = widget_label(wRow, value = 'Label ', scr_xsize = lbl_sz, /align_right)
  wtxtCoLabel       = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2)

  wDCBaseLLE        = widget_base(wDCCBaseFrCo)
  wLblLLE           = widget_label(wDCBaseLLE, value=' Lon Lat Env ', xoffset=5)
  winfoLblLLE       = widget_info(wLblCo, /geometry)
  wDCBaseFrLLE      = widget_base(wDCBaseLLE, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblLLE           = widget_label(wDCBaseLLE, value=' Lon Lat Env ', xoffset=5)

  wRow              = widget_base(wDCBaseFrLLE, /row)
  wlblSrsName       = widget_label(wRow, value = 'SRS Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtSrsName       = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCBaseFrLLE, /row)
  wlblPos1          = widget_label(wRow, value = 'Lon Lat Env Pos 1 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtPos1          = widget_text(wRow, scr_xsize=widg_sz)

  wlblPos2          = widget_label(wRow, value = 'Lon Lat Env Pos 2 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtPos2          = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCBaseFrLLE, /row)
  wlblTmPos1        = widget_label(wRow, value = 'Lon Lat Env Tm Pos 1 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPos1        = widget_text(wRow, scr_xsize=widg_sz)

  wlblTmPos2        = widget_label(wRow, value = 'Lon Lat Env Tm Pos 2 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPos2        = widget_text(wRow, scr_xsize=widg_sz)


  wDCBaseIPOL       = widget_base(wDCCBaseFrCo)
  wLblIPOL          = widget_label(wDCBaseIPOL, value=' Supported Interpolations ', xoffset=5)
  winfoLblIPOL      = widget_info(wLblIPOL, /geometry)
  wDCBaseFrIPOL     = widget_base(wDCBaseIPOL, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblIPOL          = widget_label(wDCBaseIPOL, value=' Supported Interpolations ', xoffset=5)

  wRow              = widget_base(wDCBaseFrIPOL, /row)
  wlblInterpol      = widget_label(wRow, value = 'Interpolation Method ', scr_xsize = lbl_sz-5, /align_right)
  wdlInterpol       = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)

  wlblDfltInterpol  = widget_label(wRow, value = 'Default Interpopation ', scr_xsize = lbl_sz-5, /align_right)
  wtxtDfltInterpol  = widget_text(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)



  wDCCBaseGrid      = widget_base(wDCCBaseFrCo)
  wLblGrid          = widget_label(wDCCBaseGrid, value=' Spatial Domain Grid ', xoffset=5)
  winfoLblGrid      = widget_info(wLblCo, /geometry)
  wDCCBaseFrGrid    = widget_base(wDCCBaseGrid, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblGrid          = widget_label(wDCCBaseGrid, value=' Spatial Domain Grid ', xoffset=5)

  wRow              = widget_base(wDCCBaseFrGrid, /row)
  wlblGridIdx       = widget_label(wRow, value = 'Grid Index ', scr_xsize = lbl_sz-5, /align_right)
  wdlGridIdx        = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wcs_descov_tab2_dlGridIdxx_event')

  wlblGridRect      = widget_label(wRow, value = 'Rectified Grid ', scr_xsize = lbl_sz-5, /align_right)
  wtxtGridRect      = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCCBaseFrGrid, /row)
  wlblGridSrs       = widget_label(wRow, value = 'SRS Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtGridSrs       = widget_text(wRow, scr_xsize=widg_sz)

  wlblGridAxis      = widget_label(wRow, value = 'Axis Names ', scr_xsize = lbl_sz-5, /align_right)
  wdlGridAxis       = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)

  wRow              = widget_base(wDCCBaseFrGrid, /row)
  wlblGridEnvLow    = widget_label(wRow, value = 'Low Limit Grid Env ', scr_xsize = lbl_sz-5, /align_right)
  wtxtGridEnvLow    = widget_text(wRow, scr_xsize=widg_sz)

  wlblGridEnvHigh   = widget_label(wRow, value = 'High Limit Grid Env ', scr_xsize = lbl_sz-5, /align_right)
  wtxtGridEnvHigh   = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCCBaseFrGrid, /row)
  wlblGridOrigPos   = widget_label(wRow, value = 'Origin Position ', scr_xsize = lbl_sz-5, /align_right)
  wtxtGridOrigPos   = widget_text(wRow, scr_xsize=widg_sz)

  wlblGridOffVec    = widget_label(wRow, value = 'Offset Vectors ', scr_xsize = lbl_sz-5, /align_right)
  wdlGridOffVec     = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)


  ; temporal domain time position values
  wDCCBaseTmPos     = widget_base(wDCCBaseFrCo)
  wLblTmPos         = widget_label(wDCCBaseTmPos, value=' Temporal Domain Time Positions ', xoffset=5)
  winfoLblTmPos     = widget_info(wLblCo, /geometry)
  wDCCBaseFrTmPos   = widget_base(wDCCBaseTmPos, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblTmPos         = widget_label(wDCCBaseTmPos, value=' Temporal Domain Time Positions ', xoffset=5)

  wRow              = widget_base(wDCCBaseFrTmPos, /row)
  wlblTmPosIdx      = widget_label(wRow, value = 'Time Position Index ', scr_xsize = lbl_sz-5, /align_right)
  wdlTmPosIdx       = widget_droplist(wRow, scr_xsize=65, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wcs_descov_tab2_dlTmPosIdx_event')

  wlblTmPosFr       = widget_label(wRow, value = 'Frame ', scr_xsize = 45, /align_right)
  wtxtTmPosFr       = widget_text(wRow, scr_xsize=widg_sz-65-45-5)

  wlblTmPos         = widget_label(wRow, value = 'Time Position ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPos         = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCCBaseFrTmPos, /row)
  wlblTmPosCal      = widget_label(wRow, value = 'Calendar Era Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPosCal      = widget_text(wRow, scr_xsize=widg_sz)

  wlblTmPosIndeter  = widget_label(wRow, value = 'Indeterminate Pos ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPosIndeter  = widget_text(wRow, scr_xsize=widg_sz)



  ; temporal domain time period values
  wDCCBaseTmPer     = widget_base(wDCCBaseFrCo)
  wLblTmPer         = widget_label(wDCCBaseTmPer, value=' Temporal Domain Time Periods ', xoffset=5)
  winfoLblTmPer     = widget_info(wLblCo, /geometry)
  wDCCBaseFrTmPer   = widget_base(wDCCBaseTmPer, /frame, yoffset=winfoLblCo.ysize/2, /col, space=2, ypad=5, xpad=10)
  wLblTmPer         = widget_label(wDCCBaseTmPer, value=' Temporal Domain Time Periods ', xoffset=5)

  wRow              = widget_base(wDCCBaseFrTmPer, /row)
  wlblTmPerIdx      = widget_label(wRow, value = 'Time Period Index ', scr_xsize = lbl_sz-5, /align_right)
  wdlTmPerIdx       = widget_droplist(wRow, scr_xsize=65, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wcs_descov_tab2_dlTmPerIdx_event')

  wlblTmPerFr       = widget_label(wRow, value = 'Frame ', scr_xsize = 45, /align_right)
  wtxtTmPerFr       = widget_text(wRow, scr_xsize=widg_sz-65-45-5)

  wlblTmPerRes      = widget_label(wRow, value = 'Resolution ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPerRes      = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCCBaseFrTmPer, /row)
  wlblTmPerBegin    = widget_label(wRow, value = 'Time Period Begin ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPerBegin    = widget_text(wRow, scr_xsize=widg_sz)

  wlblTmPerEnd      = widget_label(wRow, value = 'Time Period End ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPerEnd      = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCCBaseFrTmPer, /row)
  wlblTmPerCal      = widget_label(wRow, value = 'Calendar Era Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPerCal      = widget_text(wRow, scr_xsize=widg_sz)

  wlblTmPerIndeter  = widget_label(wRow, value = 'Indeterminate Pos ', scr_xsize = lbl_sz-5, /align_right)
  wtxtTmPerIndeter  = widget_text(wRow, scr_xsize=widg_sz)

  widget_control, wDCCBaseFrCo,      scr_xsize=x_sz

  pxco = ptr_new()

  ;paxServers is a ptr to an array of structures that define the remote servers, set in ogc_wcs_getConfigInfo
  state = {pxco:pxco, $
           wtxtSelCo:wtxtSelCo, wtxtGridEnvLow:wtxtGridEnvLow, wtxtGridEnvHigh:wtxtGridEnvHigh, $
           wtxtGridRect:wtxtGridRect, wdlGridAxis:wdlGridAxis, wdlGridIdx:wdlGridIdx, wtxtGridOrigPos:wtxtGridOrigPos, $
           wdlGridOffVec:wdlGridOffVec, wtxtGridSrs:wtxtGridSrs, wdlInterpol:wdlInterpol, wtxtDfltInterpol:wtxtDfltInterpol, $
           wtxtSrsName:wtxtSrsName, wtxtPos1:wtxtPos1, wtxtPos2:wtxtPos2, wlblPos1:wlblPos1, wlblPos2:wlblPos2, wtxtTmPos1:wtxtTmPos1, $
           wtxtTmPos2:wtxtTmPos2, $
           wtxtCoLabel:wtxtCoLabel, wdlTmPosIdx:wdlTmPosIdx, wtxtTmPos:wtxtTmPos, wtxtTmPosFr:wtxtTmPosFr, wtxtTmPosCal:wtxtTmPosCal, $
           wtxtTmPosIndeter:wtxtTmPosIndeter, wdlTmPerIdx:wdlTmPerIdx, wtxtTmPerFr:wtxtTmPerFr, wtxtTmPerBegin:wtxtTmPerBegin, $
           wtxtTmPerEnd:wtxtTmPerEnd, wtxtTmPerCal:wtxtTmPerCal, wtxtTmPerIndeter:wtxtTmPerIndeter, wtxtTmPerRes:wtxtTmPerRes }

  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wDCCBaseState, set_uvalue=pstate
end

