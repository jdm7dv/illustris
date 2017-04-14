
;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_get, id, fromFile
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    widget_control, (*pstate).wdlSelCo, set_value = "Failed: Attempting to fetch the Describe Coverage XML Doc did not succeed."
    return
  endif

  wState = widget_info(id, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  widget_control, (*pstate).wtxtStatus, set_value=''

  (*pstate).owcs->setproperty, callback_function            ='cw_ogc_wcs_descov_tab1_callback'
  (*pstate).owcs->SetProperty, callback_data                = pstate

  names          = (*pstate).covNames
  ckschema       = (*pstate).schemaCk
  validationMode = (*pstate).validationMode

  cw_ogc_wcs_descov_tab1_remove_coverage_offering, pstate

  widget_control, (*pstate).wdlSelCo,           set_value = "Attempting to fetch the Describe Coverage Doc for the requested coverage."

  cw_ogc_wcs_descov_tab1_co_fr_title, pstate, 'x.x.x', '0'


  if (fromFile) then begin
    *(*pstate).pco_names = (*pstate).owcs->DescribeCoverage(from_file=fromFile, schema_check=ckSchema, validation_mode=validationMode, count=cnt)
  endif else begin
    *(*pstate).pco_names = (*pstate).owcs->DescribeCoverage(names=names, schema_check=ckSchema, validation_mode=validationMode, count=cnt)
  endelse

  if (cnt le 0) then begin
      message, 'DescribeCoverage request failed to fecth a coverage offering(s)'
      return
  end

  cw_ogc_wcs_descov_tab1_load_coverage_offering, pstate, (*pstate).pco_names, 0
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_co_fr_title, pstate, ver, cnt

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  val = ' Coverage Offering     Version = ' + strtrim(string(ver), 2) + '    Count = ' + strtrim(string(cnt), 2) + '  '
  info = widget_info((*pstate).wLblCo, string_size= val)
  widget_control, (*pstate).wLblCo, xsize=info[0], set_value = val

end

;;----------------------------------------------------------------------------
pro  cw_ogc_wcs_descov_tab1_load_coverage_offering, pstate, pco_names, idx

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  ; save this as a reference for future use
  ;cnt = size(xco.request_response, /n_dim) ? n_elements(xco.request_response) : 0
  ;a = double(strsplit(xco.spat_dom_lonlatenv.[sdlleidx].spat_dom_lonlatenv.pos1, /extract))

  co_names = *(*pstate).pco_names
  (*pstate).selectedCo = co_names[idx]
  xco = (*pstate).owcs->getcoverageoffering(index=idx)

  if ptr_valid((*pstate).pxco) then begin
    ptr_free, (*pstate).pxco
  endif

  (*pstate).pxco = ptr_new(xco, /no_copy)
  xco = *(*pstate).pxco

  widget_control, (*pstate).wdlSelCo,           set_value = co_names
  widget_control, (*pstate).wdlSelCo,           set_droplist_select = idx
  widget_control, (*pstate).wdlReqRespCrs,      set_value = xco.crs.request_response
  widget_control, (*pstate).wdlNativeCrs,       set_value = xco.crs.native
  widget_control, (*pstate).wdlReqCrs,          set_value = xco.crs.request
  widget_control, (*pstate).wdlRespCrs,         set_value = xco.crs.response
  widget_control, (*pstate).wdlformat,          set_value = xco.formats
  widget_control, (*pstate).wtxtNativeFormat,   set_value = xco.native_format

  if (xco.num_spat_dom_lles gt 0) then begin
     idxarr = make_array(xco.num_spat_dom_lles, /string)
     for zz=0, xco.num_spat_dom_lles-1 do begin
        idxarr[zz] = strtrim(string(zz+1),2)
     endfor
     widget_control, (*pstate).wdlsdlleidx,      set_value = idxarr
  endif


  ; default to hdf or geotiff for now
  fndhdf = strmatch(xco.formats[0], 'hdf*', /FOLD_CASE)
  fndgeo = strmatch(xco.formats[0], 'geo*', /FOLD_CASE)
  if ((fndhdf eq 0) && (fndgeo eq 0)) then begin
     cnt = size(xco.formats, /n_dim) ? n_elements(xco.formats) : 0
     while (cnt gt 0) do begin
        cnt--
        fndhdf = strmatch(xco.formats[cnt], 'hdf*', /FOLD_CASE)
        fndgeo = strmatch(xco.formats[cnt], 'geo*', /FOLD_CASE)
        if ((fndhdf eq 1) || (fndgeo eq 1)) then begin
           widget_control, (*pstate).wdlformat, set_droplist_select = cnt
           cnt = 0
        endif
     endwhile
  endif

  cw_ogc_wcs_descov_tab1_load_sd_lle, pstate, 0
  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate

  cw_ogc_wcs_descov_tab2_load, (*pstate).tab2Root, (*pstate).pxco
  cw_ogc_wcs_descov_tab3_load, (*pstate).tab3Root, (*pstate).pxco

  cnt = size(co_names, /n_dim) ? n_elements(co_names) : 0
  cw_ogc_wcs_descov_tab1_co_fr_title, pstate, xco[0].version, cnt
end

;;----------------------------------------------------------------------------
pro  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
     print, !error_state.msg
     return
  endif

  xco = *(*pstate).pxco

  crsIdx = widget_info((*pstate).wdlReqRespCrs, /droplist_select)
  crs = xco.crs.request_response[crsIdx]

  if (crs eq '') then begin
     crsIdx = widget_info((*pstate).wdlReqCrs, /droplist_select)
     crs = xco.crs.request[crsIdx]
  endif

  sdlleidx = widget_info((*pstate).wdlsdlleidx, /droplist_select)
  pos1strs = strsplit(xco.spat_dom_lonlatenv[sdlleidx].pos1, /extract)

  posCnt = size(pos1strs, /n_dim) ? n_elements(pos1strs) : 0
  (*pstate).posCnt = posCnt
  pos2strs = strsplit(xco.spat_dom_lonlatenv[sdlleidx].pos2, /extract)


  if ((posCnt ne 2) && (posCnt ne 3)) then begin
      message, 'Unable to determine bounding box value because positon values appear to be unusable.'
      return
  endif

  bbox = ''
  if (posCnt eq 2) then begin
     bbox = pos1strs[0] + ',' + pos1strs[1] + ',' + pos2strs[0] + ',' + pos2strs[1]
  endif

  if (posCnt eq 3) then begin
     bbox = pos1strs[0] + ',' + pos1strs[1] + ',' + pos1strs[2] + ',' + pos2strs[0] + ',' + pos2strs[1] + ',' + pos2strs[2]
  endif

  fmtIdx = widget_info((*pstate).wdlformat, /droplist_select)

  wxIdx = widget_info((*pstate).wdlWX, /droplist_select)
  width = (*pstate).covReqDims[wxIdx]

  hyIdx = widget_info((*pstate).wdlHY, /droplist_select)
  height = (*pstate).covReqDims[hyIdx]

  widget_control, (*pstate).wtxtParams, get_value = params

  getCovStr = 'Coverage=' + (*pstate).selectedCo
  getCovStr = getCovStr + '&CRS=' + crs
  getCovStr = getCovStr + '&BBOX=' + bbox
  getCovStr = getCovStr + '&FORMAT=' + xco.formats[fmtIdx]
  getCovStr = getCovStr + '&Width=' + width
  getCovStr = getCovStr + '&Height=' + height

  if (params ne '') then getCovStr = getCovStr + '&' + params

  (*pstate).owcs->getproperty, url_hostname = host
  if (host eq 'engrnd1') then begin
     getCovStr = getCovStr + '&band=band1'
  endif

  ;print, getCovStr

  widget_control, (*pstate).wtxtGetCovStr, set_value = getCovStr
end

;;----------------------------------------------------------------------------
pro  cw_ogc_wcs_descov_tab1_remove_coverage_offering, pstate

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif


  (*pstate).selectedCo = ''

  widget_control, (*pstate).wdlSelCo,           set_value = ''
  widget_control, (*pstate).wdlReqRespCrs,      set_value = ''
  widget_control, (*pstate).wdlNativeCrs,       set_value = ''
  widget_control, (*pstate).wdlReqCrs,          set_value = ''
  widget_control, (*pstate).wdlRespCrs,         set_value = ''
  widget_control, (*pstate).wdlFormat,          set_value = ''
  widget_control, (*pstate).wtxtNativeFormat,   set_value = ''
  widget_control, (*pstate).wtxtSDSrsName,      set_value = ''
  widget_control, (*pstate).wtxtSDPos1,         set_value = ''
  widget_control, (*pstate).wlblSDPos1,         set_value = 'Position 1'
  widget_control, (*pstate).wtxtSDPos2,         set_value = ''
  widget_control, (*pstate).wlblSDPos2,         set_value = 'Position 2'
  widget_control, (*pstate).wtxtParams,         set_value = ''
  widget_control, (*pstate).wtxtGetCovStr,      set_value = ''
  widget_control, (*pstate).wtxtSDTmPos1,       set_value = ''
  widget_control, (*pstate).wtxtSDTmPos2,       set_value = ''

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_load_sd_lle, pstate, idx

  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
     print, !error_state.msg
     return
  endif

  xco = *(*pstate).pxco

  widget_control, (*pstate).wtxtSDSrsName,        set_value = xco.spat_dom_lonlatenv[idx].srs_name

  widget_control, (*pstate).wtxtSDPos1,           set_value = xco.spat_dom_lonlatenv[idx].pos1
  if (xco.spat_dom_lonlatenv[idx].dims1 eq '') then begin
     lbl = 'Postion 1 '
  endif else begin
     lbl = 'Postion 1 (' + xco.spat_dom_lonlatenv[idx].dims1 + ' Dims) '
  endelse
  widget_control, (*pstate).wlblSDPos1,           set_value = lbl

  widget_control, (*pstate).wtxtSDPos2,           set_value = xco.spat_dom_lonlatenv[idx].pos2
  if (xco.spat_dom_lonlatenv[idx].dims2 eq '') then begin
     lbl = 'Postion 2 '
  endif else begin
     lbl = 'Postion 2 (' + xco.spat_dom_lonlatenv[idx].dims2 + ' Dims) '
  endelse
  widget_control, (*pstate).wlblSDPos2,           set_value = lbl

  widget_control, (*pstate).wtxtSDTmPos1,         set_value = xco.spat_dom_lonlatenv[idx].time_pos1
  widget_control, (*pstate).wtxtSDTmPos2,         set_value = xco.spat_dom_lonlatenv[idx].time_pos2
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_btnGetCoverage_event, ev

  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
     print, !error_state.msg
     return
  endif

  ;widget_control, hourglass=1

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  if ((*pstate).covFN ne '') then begin
      (*pstate).owcs->setproperty, coverage_filename = (*pstate).covFN
  endif

  (*pstate).owcs->setproperty, timeout           = (*pstate).rxtxTo
  (*pstate).owcs->setproperty, connect_timeout   = (*pstate).connectTo

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  widget_control, (*pstate).wtxtGetCovStr, get_value = getCovStr

  ; get the coverage(s)
  res = (*pstate).owcs->GetCoverage(getCovStr[0])
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlSelCo_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
     print, !error_state.msg
     return
  endif

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlSelCo, /droplist_select)
  cw_ogc_wcs_descov_tab1_load_coverage_offering, pstate, (*pstate).pco_names, idx
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlFormat_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  sel = widget_info((*pstate).wdlFormat, /droplist_select)

  xco = *(*pstate).pxco
  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlSDLLEIdx_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  idx = widget_info((*pstate).wdlSDLLEIdx, /droplist_select)
  cw_ogc_wcs_descov_tab1_load_sd_lle, pstate, idx
  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlReqRespCrs_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlReqCrs_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlWX_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlHY_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_dlDZ_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_txtParams_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_btnWHD_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  (*pstate).WHD = 1
  (*pstate).XYZ = 0

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_btnXYZ_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  (*pstate).WHD = 0
  (*pstate).XYZ = 1

  cw_ogc_wcs_descov_tab1_build_get_cov_str, pstate
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_btnBrowseHDF_event, ev
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg + '  File does not appear to be a hdf file:  ' + fpc, title='OGC WCS Error', /error)
    return
  endif


  wState = widget_info(ev.top, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  (*pstate).owcs->getproperty, last_file = fpc

  ; if not a hdf an error is throw, caught and a msg is displayed
  tmpl = hdf_browser(fpc, GROUP=(*pstate).wDCBaseState)

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_btnOpenImage_event, ev
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  cw_ogc_wcs_OpenImage, ev, 'descovstatebase_tab1'
end

;;----------------------------------------------------------------------------
function cw_ogc_wcs_descov_tab1_callback, status, progress, data
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return, 1
  endif

  display = 1
  if ((*data).displayHttp eq 0) then begin
    pos = strpos(status, 'Http:')
    if  (pos ne -1) then display = 0
  endif


  if (display eq 1) then begin

      ; add the text sent form the qr obj in the status parameter to the list box
      widget_control, (*data).wtxtStatus, set_value = status, /append

      ; make the last line written visible
      lastchar = widget_info((*data).wtxtStatus, /text_number)
      xypos = widget_info((*data).wtxtStatus, TEXT_OFFSET_TO_XY=lastchar-1)

      if (xypos[1] GT (*data).statusLines) then begin
        widget_control, (*data).wtxtStatus, set_text_top_line=xypos[1] - (*data).statusLines
      endif

  endif

  ; check to see if the user pressed the cancel button
  wevCov = widget_event((*data).wbtnCancelCov, /nowait)

  if (wevCov.id EQ (*data).wbtnCancelCov) then begin
    return, 0
  endif

;  if (progress[0]) then begin
;     print, progress
;  endif

  ;widget_control, hourglass=1
  return, 1
end



;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_kill_event, id
  compile_opt idl2
  catch, errorStatus            ; catch all errors and display an error dialog

  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    return
  endif

  ; called when the main ui is destroyed we let go of objects and pointers

  widget_control, id, get_uvalue = pstate

  ; this will close all iImage windows...images
  for ix=0, n_elements((*pstate).coitIdArr)-1 do begin
     if ((*pstate).coitIdArr[ix] ne '') then begin
            itDelete, (*pstate).coitIdArr[ix]
      endif
  endfor

  if ptr_valid(pstate) then begin
    if ptr_valid((*pstate).pxco) then begin
      ptr_free, (*pstate).pxco
    endif
    ptr_free, (*pstate).paxServers
    ptr_free, (*pstate).pco_names
    ptr_free, pstate
  endif

  widget_control, id, /destroy
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_descov_tab1_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif


  wState = widget_info(id, find_by_uname='descovstatebase_tab1')
  widget_control, wState, get_uvalue = pstate

  ; get the number of visible lines in the status text window
  winfowtxtStatus = widget_info((*pstate).wtxtStatus,/geometry)

  (*pstate).statusLines = winfowtxtStatus.ysize - 2

  widget_control, (*pstate).wbtnWHD, /set_button

  widget_control, (*pstate).wdlWX, set_droplist_select=0
  widget_control, (*pstate).wdlHY, set_droplist_select=0
  widget_control, (*pstate).wdlDZ, set_droplist_select=0
end


;;----------------------------------------------------------------------------
function cw_ogc_wcs_descov_tab1_make_label_frame, parent, labelText
    labelText = ' ' + labelText + ' '
    mainBase = widget_base( parent )
    label = widget_label( mainBase, value = labelText, xoffset = 5 )
    geo = widget_info( label, /geometry )
    frameBase = widget_base( mainBase, /frame, yoffset = geo.ysize / 2, ypad = 7, xpad =7, /column )
    label = widget_label( mainBase, value = labelText, xoffset = 5 )
    return, frameBase
end

;;----------------------------------------------------------------------------
pro  cw_ogc_wcs_descov_tab1, parent, tab2, tab3, owcs, covNames, fromFile
  compile_opt idl2
  on_error, 2

  wDCBase           = widget_base(parent, /CoLUMN, TITLE='Coverage Offering', NOTIFY_REALIZE='cw_ogc_wcs_descov_tab1_realize_notify_event', $
                                  space=2)
  wDCBaseState      = widget_base(wDCBase, uname='descovstatebase_tab1', kill_notify='cw_ogc_wcs_descov_tab1_kill_event')

  x_sz      = 855
  lbl_sz    = 140
  widg_sz   = 260

  xpad=7
  ypad=4
  space=0


  drop_ysz = 20
  if (!version.os_family eq 'unix') then begin
     drop_ysz = 35
  endif

  ; add the coverage offering frame ------------------------
  wDCBaseCo         = widget_base(wDCBase)
  wLblCo            = widget_label(wDCBaseCo, value=' Coverage Offering ', xoffset=5)
  winfoLblCo        = widget_info(wLblCo, /geometry)
  wDCBaseFrCo       = widget_base(wDCBaseCo, /frame, yoffset=winfoLblCo.ysize/2, /col, xpad=xpad, ypad=ypad, space=2)
  wLblCox           = widget_label(wDCBaseCo, value=' Coverage Offering ', xoffset=5)

  ; combo with the names of the available coverages...the currently select coverage name is displayed
  wRow              = widget_base(wDCBaseFrCo, /row)
  wlblSelCo         = widget_label(wRow, value = 'Selected Coverage ', scr_xsize = lbl_sz, /align_right)
  wdlSelCo          = widget_droplist(wRow, scr_xsize=lbl_sz+2*widg_sz+2, scr_ysize=drop_ysz, event_pro='cw_ogc_wcs_descov_tab1_dlSelCo_event')

  wDCBaseSD         = widget_base(wDCBaseFrCo)
  wLblSD            = widget_label(wDCBaseSD, value=' Spatial Domain ', xoffset=5)
  winfoLblSD        = widget_info(wLblSD, /geometry)
  wDCBaseFrSD       = widget_base(wDCBaseSD, /frame, yoffset=winfoLblCo.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblSD            = widget_label(wDCBaseSD, value=' Spatial Domain ', xoffset=5)

  wRow              = widget_base(wDCBaseFrSD, /row)
  wlblSDLLEIdx      = widget_label(wRow, value = 'LonLatEnvelope Index ', scr_xsize = lbl_sz-5, /align_right)
  wdlSDLLEIdx       = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wcs_descov_tab1_dlSDLLEIdx_event')

  wlblSDSrsName     = widget_label(wRow, value = 'SRS Name ', scr_xsize = lbl_sz-5, /align_right)
  wtxtSDSrsName     = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCBaseFrSD, /row)
  wlblSDPos1        = widget_label(wRow, value = 'Lon Lat Env Pos 1 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtSDPos1        = widget_text(wRow, scr_xsize=widg_sz)

  wlblSDPos2        = widget_label(wRow, value = 'Lon Lat Env Pos 2 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtSDPos2        = widget_text(wRow, scr_xsize=widg_sz)

  wRow              = widget_base(wDCBaseFrSD, /row)
  wlblSDTmPos1      = widget_label(wRow, value = 'Time Position 1 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtSDTmPos1      = widget_text(wRow, scr_xsize=widg_sz)

  wlblSDTmPos2      = widget_label(wRow, value = 'Time Position 2 ', scr_xsize = lbl_sz-5, /align_right)
  wtxtSDTmPos2      = widget_text(wRow, scr_xsize=widg_sz)


  wDCBaseCRS        = widget_base(wDCBaseFrCo)
  wLblCRS           = widget_label(wDCBaseCRS, value=' Supported CRSs ', xoffset=5)
  winfoLblCRS       = widget_info(wLblCRS, /geometry)
  wDCBaseFrCRS      = widget_base(wDCBaseCRS, /frame, yoffset=winfoLblCo.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblCRS           = widget_label(wDCBaseCRS, value=' Supported CRSs ', xoffset=5)

  wRow              = widget_base(wDCBaseFrCRS, /row)
  wlblReqRespCrs    = widget_label(wRow, value = 'Request Response CRSs ', scr_xsize = lbl_sz-5, /align_right)
  wdlReqRespCrs     = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wcs_descov_tab1_dlReqRespCrs_event')

  wlblNativeCrs     = widget_label(wRow, value = 'Native CRSs ', scr_xsize = lbl_sz-5, /align_right)
  wdlNativeCrs     = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)

  wRow              = widget_base(wDCBaseFrCRS, /row)
  wlblReqCrs        = widget_label(wRow, value = 'Request CRSs ', scr_xsize = lbl_sz-5, /align_right)
  wdlReqCrs         = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wcs_descov_tab1_dlReqCrs_event')

  wlblRespCrs       = widget_label(wRow, value = 'Response CRSs ', scr_xsize = lbl_sz-5, /align_right)
  wdlRespCrs        = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz)

  wDCBaseFMT        = widget_base(wDCBaseFrCo)
  wLblFMT           = widget_label(wDCBaseFMT, value=' Supported Formats ', xoffset=5)
  winfoLblFMT       = widget_info(wLblFMT, /geometry)
  wDCBaseFrFMT      = widget_base(wDCBaseFMT, /frame, yoffset=winfoLblCo.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblFMT           = widget_label(wDCBaseFMT, value=' Supported Formats ', xoffset=5)

  wRow              = widget_base(wDCBaseFrFMT, /row)
  wlblFormat        = widget_label(wRow, value = 'Format ', scr_xsize = lbl_sz-5, /align_right)
  wdlFormat         = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro='cw_ogc_wcs_descov_tab1_dlFormat_event')

  wlblNativFormat   = widget_label(wRow, value = 'Native Format ', scr_xsize = lbl_sz-5, /align_right)
  wtxtNativeFormat  = widget_text(wRow, scr_xsize=widg_sz)



  wDCBaseDims       = widget_base(wDCBaseFrCo)
  wLblDims          = widget_label(wDCBaseDims, value=' Coverage Request Dimensions ', xoffset=5)
  winfoLblDims      = widget_info(wLblDims, /geometry)
  wDCBaseFrDims     = widget_base(wDCBaseDims, /frame, yoffset=winfoLblCo.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblDims          = widget_label(wDCBaseDims, value=' Coverage Request Dimensions ', xoffset=5)

  wRow              = widget_base(wDCBaseFrDims, /row)
  wexBase           = widget_base(wRow, /exclusive, /row)
  wbtnWHD           = widget_button(wexBase, value=' Use W,H,D', scr_ysize=18, event_pro='cw_ogc_wcs_descov_tab1_btnWHD_event')
  wbtnXYZ           = widget_button(wexBase, value=' Use X,Y,Z', scr_ysize=18, event_pro='cw_ogc_wcs_descov_tab1_btnXYZ_event')

  covReqDims        = ['100','250','500','750','1000','1250','1500','1750','2000','2250','2500','2750','3000','3500','4000','6000','8000','10000','12000','14000','16000','18000','20000','24000','28000','30000']
  wlblWX            = widget_label(wRow, value = ' Width/Res X ', scr_xsize = 90, /align_right)
  wdlWX             = widget_droplist(wRow, scr_xsize=110, scr_ysize=drop_ysz, value = covReqDims, event_pro = 'cw_ogc_wcs_descov_tab1_dlWX_event')
  wdlHY             = widget_label(wRow, value = ' Height/Res Y ', scr_xsize =90, /align_right)
  wdlHY             = widget_droplist(wRow, scr_xsize=110, scr_ysize=drop_ysz, value = covReqDims, event_pro = 'cw_ogc_wcs_descov_tab1_dlHY_event')
  wlblDZ            = widget_label(wRow, value = ' Depth/Res Z ', scr_xsize =90, /align_right)
  wdlDZ             = widget_droplist(wRow, scr_xsize=110, scr_ysize=drop_ysz, value = covReqDims, event_pro = 'cw_ogc_wcs_descov_tab1_dlDZ_event')
  widget_control, wdlWX, set_droplist_select=2
  widget_control, wdlHY, set_droplist_select=2
  widget_control, wdlDZ, set_droplist_select=2


  wDCBaseGet        = widget_base(wDCBaseFrCo)
  wLblGet           = widget_label(wDCBaseGet, value=' Get Coverage ', xoffset=5)
  winfoLblGet       = widget_info(wLblGet, /geometry)
  wDCBaseFrGet      = widget_base(wDCBaseGet, /frame, yoffset=winfoLblCo.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblGet           = widget_label(wDCBaseGet, value=' Get Coverage ', xoffset=5)

  wRow              = widget_base(wDCBaseFrGet, /row)
  wlblParams        = widget_label(wRow, value = ' Parameters ', /align_right)
  wtxtParams        = widget_text(wRow, scr_xsize=640, /editable, /all_events, event_pro='cw_ogc_wcs_descov_tab1_txtParams_event')
  wRow              = widget_base(wDCBaseFrGet, /row)
  wtxtGetCovStr     = widget_text(wRow, scr_xsize=widg_sz+widg_sz+lbl_sz-5+140, /editable)
  wRow              = widget_base(wDCBaseFrGet, /row)
  wbtnGetCoverage   = widget_button(wRow, value='Get Coverage', scr_xsize = 90, event_pro = 'cw_ogc_wcs_descov_tab1_btnGetCoverage_event')
  wbtnCancelCov     = widget_button(wRow, value='Cancel', scr_xsize = 90)
  wbtnOpenImage     = widget_button(wRow, value='Open Image', scr_xsize = 100, event_pro = 'cw_ogc_wcs_descov_tab1_btnOpenImage_event')
  wbtnBrowseHDF     = widget_button(wRow, value='Browse HDF/NetCDF', scr_xsize = 150, event_pro = 'cw_ogc_wcs_descov_tab1_btnBrowseHdf_event')



  ;;add the status frame -------------------------------
  wDCBaseStatus     = widget_base(wDCBase)
  wlblStatus        = widget_label(wDCBaseStatus, value=' Status ', xoffset=5)
  winfolblStatus    = widget_info(wlblStatus, /geometry)
  wDCBaseFrStatus   = widget_base(wDCBaseStatus, /frame, yoffset=winfolblStatus.ysize/2, /row, xpad=xpad, ypad=ypad, space=space)
  wlblStatus        = widget_label(wDCBaseStatus, value=' Status ', xoffset=5)
  wtxtStatus        = widget_text(wDCBaseFrStatus, value='', /scroll, font='Courier New*14', UNAME='TXT_STATUS', ysize=9, scr_xsize=x_sz-30)

  ; add the close button to the tab container
  wRow              = widget_base(wDCBase, /row, /align_right, space=5)

  widget_control, wDCBaseFrCo,      scr_xsize=x_sz
  widget_control, wDCBaseFrStatus,  scr_xsize=x_sz
  widget_control, wDCBaseFrDims,    scr_xsize=x_sz-33
  widget_control, wDCBaseFrGet,     scr_xsize=x_sz-33

  ; set in ogc_wcs::cw_ogc_wcs_OpenImage
  coitIdArr    = make_array(256, /string, value='')
  coitIdArrIdx = byte(0) ; by design this index will wrap back to 0 after 256 windows

  pco_names = ptr_new(/allocate_heap)

  ;paxServers is a ptr to an array of structures that define the remote servers, set in ogc_wcs_getConfigInfo
  state = {tab2Root:tab2, tab3Root:tab3, owcs:owcs, covNames:covNames, pxco:ptr_new(), statusLines:8, selectedCo:'', whd:1, xyz:0, posCnt:0, $
           covReqDims:covReqDims, coitIdArr:coitIdArr, coitIdArrIdx:coitIdArrIdx, pco_names:pco_names, $
           wDCBaseState:wDCBaseState, wtxtStatus:wtxtStatus, wdlSelCo:wdlSelCo, $
           wdlReqRespCrs:wdlReqRespCrs, wdlReqCrs:wdlReqCrs, wdlRespCrs:wdlRespCrs, wdlFormat:wdlFormat, $
           wdlNativeCrs:wdlNativeCrs, wtxtNativeFormat:wtxtNativeFormat, wbtnCancelCov:wbtnCancelCov, $
           wLblCo:wLblCo, $
           wtxtSDSrsName:wtxtSDSrsName, $
           wtxtSDPos1:wtxtSDPos1, wtxtSDPos2:wtxtSDPos2, wlblSDPos1:wlblSDPos1, $
           wlblSDPos2:wlblSDPos2, wdlSDLLEIdx:wdlSDLLEIdx, wtxtSDTmPos1:wtxtSDTmPos1, wtxtSDTmPos2:wtxtSDTmPos2, $
           wdlWX:wdlWX, wdlHY:wdlHY, wdlDZ:wdlDZ, wbtnWHD:wbtnWHD, wtxtParams:wtxtParams, $
           wtxtGetCovStr:wtxtGetCovStr, $
           prefsFile:'', paxServers:ptr_new(0), covServer:'', schemaCk:0, $
           capFN:'', desCovFN:'', covFN:'', capFromFile:'', $
           desCovFromFile:'', displayHttp:1, rxtxTo:'1800', connectTo:'1800', proxy:'', proxyPort:'', verbose:0, $
           usr:'', pwd:'', proxyusr:'', proxypwd:'', encoding:0, validationMode:0 }

  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wDCBaseState, set_uvalue=pstate

  ;this will set paxServers if the .sav file exists and has some remote server entries
  (*pstate).prefsFile = ogc_wcs_getConfigInfo(wDCBase, 'descovstatebase_tab1')
end
