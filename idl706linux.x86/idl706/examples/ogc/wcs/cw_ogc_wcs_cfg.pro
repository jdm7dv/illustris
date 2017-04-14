

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnSchema0_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).schemaCk = 0
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnSchema1_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).schemaCk = 1
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnSchema2_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).schemaCk = 2
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnVMode0_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).validationMode = 0
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnVMode1_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).validationMode = 1
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnVMode2_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).validationMode = 2
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnBrowseCap_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  if ((*pstate).capFN ne '') then begin
    path = (*pstate).capFN
  endif else begin
    path=!dir
  endelse

  newpath = dialog_pickfile(title='Pick a directory', path=path, /directory, DIALOG_PARENT=ev.top)
  if (newpath[0] eq '') then begin
    return
  endif

  (*pstate).capFN = newpath[0]
  widget_control, (*pstate).wtxtCapFN,    set_value = (*pstate).capFN
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnBrowseDesCov_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  if ((*pstate).desCovFN ne '') then begin
    path = (*pstate).desCovFN
  endif else begin
    path=!dir
  endelse

  newpath = dialog_pickfile(title='Pick a directory', path=path, /directory, DIALOG_PARENT=ev.top)
  if (newpath[0] eq '') then begin
    return
  endif

  (*pstate).desCovFN = newpath[0]
  widget_control, (*pstate).wtxtDesCovFN,    set_value = (*pstate).desCovFN
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnBrowseCov_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  if ((*pstate).covFN ne '') then begin
    path = (*pstate).covFN
  endif else begin
    path=!dir
  endelse

  newpath = dialog_pickfile(title='Pick a directory', path=path, /directory, DIALOG_PARENT=ev.top)
  if (newpath[0] eq '') then begin
    return
  endif

  (*pstate).covFN = newpath[0]
  widget_control, (*pstate).wtxtCovFN,    set_value = (*pstate).covFN
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnVerbose_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).verbose NE= 1
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnHttpMsgs_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).displayHttp NE= 1
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnNoEncoding_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).encoding = 0
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnDeflateEncoding_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).encoding = 1
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnGzipEncoding_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).encoding = 2
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnBothEncoding_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).encoding = 3
  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_btnSave_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  widget_control, (*pstate).wtxtCapFN,     get_value = val
  len = strlen(val)
  res1 = STRPOS(val, '\', /reverse_search)
  res2 = STRPOS(val, '/', /reverse_search)
  if ((len ne 0) && ((res1 eq len-1) || (res2 eq len-1))) then begin
    message, 'Set the capabilities filename must be set prior to saving.'
  endif

  (*pstate).capFN = val

  widget_control, (*pstate).wtxtDesCovFN,  get_value = val
  len = strlen(val)
  res1 = STRPOS(val, '\', /reverse_search)
  res2 = STRPOS(val, '/', /reverse_search)
  if ((len ne 0) && ((res1 eq len-1) || (res2 eq len-1))) then begin
    message, 'Set the Describe Coverage filename must be set prior to saving.'
  endif

  (*pstate).desCovFN = val

  widget_control, (*pstate).wtxtCovFN,     get_value = val
  len = strlen(val)
  res1 = STRPOS(val, '\', /reverse_search)
  res2 = STRPOS(val, '/', /reverse_search)
  if ((len ne 0) && ((res1 eq len-1) || (res2 eq len-1))) then begin
    message, 'Set the Coverage filename must be set prior to saving.'
  endif

  (*pstate).covFN = val

  widget_control, (*pstate).wtxtRxTxTo,    get_value = val
  ival = fix(val)
  val  = strtrim(string(ival),2)
  widget_control, (*pstate).wtxtRxTxTo,    set_value = val
  (*pstate).rxtxTo = val

  widget_control, (*pstate).wtxtConnectTo, get_value = val
  ival = fix(val)
  val  = strtrim(string(ival),2)
  widget_control, (*pstate).wtxtConnectTo, set_value = val
  (*pstate).connectTo = val

  widget_control, (*pstate).wtxtCovFN,     get_value = val
  (*pstate).covFN = val

  widget_control, (*pstate).wtxtProxy,     get_value = val
  (*pstate).proxy = val

  widget_control, (*pstate).wtxtProxyPort, get_value = val
  (*pstate).ProxyPort = val

  widget_control, (*pstate).wtxtUsr,       get_value = val
  (*pstate).usr = val

  widget_control, (*pstate).wtxtPwd,       get_value = val
  (*pstate).pwd = val

  widget_control, (*pstate).wtxtProxyUsr,  get_value = val
  (*pstate).proxyusr = val

  widget_control, (*pstate).wtxtProxyPwd,  get_value = val
  (*pstate).proxypwd = val

  ogc_wcs_SaveValuesAndNotify, ev.top, 'cfgstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_kill_event, id
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
     ptr_free, (*pstate).paxServers
     ptr_free, pstate
  endif
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_refresh, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate

  ; this reloads the (*pstate).xxxx config vars with the current contents of the config file
  prefsFile = ogc_wcs_getConfigInfo(id, 'cfgstatebase')

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cfg_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname='cfgstatebase')
  widget_control, wState, get_uvalue = pstate


  if ((*pstate).schemaCk eq 0) then begin
     widget_control, (*pstate).wbtnSchema0, /set_button
  endif

  if ((*pstate).schemaCk eq 1) then begin
     widget_control, (*pstate).wbtnSchema1, /set_button
  endif

  if ((*pstate).schemaCk eq 2) then begin
     widget_control, (*pstate).wbtnSchema2, /set_button
  endif

  if ((*pstate).validationMode eq 0) then begin
     widget_control, (*pstate).wbtnVMode0, /set_button
  endif

  if ((*pstate).validationMode eq 1) then begin
     widget_control, (*pstate).wbtnVMode1, /set_button
  endif

  if ((*pstate).validationMode eq 2) then begin
     widget_control, (*pstate).wbtnVMode2, /set_button
  endif

  if ((*pstate).displayHttp ne 0) then begin
     widget_control, (*pstate).wbtnDisplayHttp, /set_button
  endif

  if ((*pstate).verbose ne 0) then begin
     widget_control, (*pstate).wbtnVerbose, /set_button
  endif

  if ((*pstate).encoding eq 0) then begin
     widget_control, (*pstate).wbtnEncodeNone, /set_button
  endif

  if ((*pstate).encoding eq 1) then begin
     widget_control, (*pstate).wbtnEncodeDeflate, /set_button
  endif

  if ((*pstate).encoding eq 2) then begin
     widget_control, (*pstate).wbtnEncodeGzip, /set_button
  endif

  if ((*pstate).encoding eq 3) then begin
     widget_control, (*pstate).wbtnEncodeBoth, /set_button
  endif

  widget_control, (*pstate).wtxtCapFN,     set_value = (*pstate).capFN
  widget_control, (*pstate).wtxtDesCovFN,  set_value = (*pstate).desCovFN
  widget_control, (*pstate).wtxtCovFN,     set_value = (*pstate).CovFN
  widget_control, (*pstate).wtxtRxTxTO,    set_value = strtrim((*pstate).rxtxTo,2)
  widget_control, (*pstate).wtxtConnectTO, set_value = strtrim((*pstate).connectTo,2)
  widget_control, (*pstate).wtxtProxy,     set_value = (*pstate).proxy
  widget_control, (*pstate).wtxtProxyPort, set_value = (*pstate).proxyPort
  widget_control, (*pstate).wtxtUsr,       set_value = (*pstate).usr
  widget_control, (*pstate).wtxtPwd,       set_value = (*pstate).pwd
  widget_control, (*pstate).wtxtProxyUsr,  set_value = (*pstate).proxyUsr
  widget_control, (*pstate).wtxtProxyPwd,  set_value = (*pstate).proxyPwd

end

;;----------------------------------------------------------------------------
function cw_ogc_wcs_cfg, parent
  compile_opt idl2
  on_error, 2

  size_of_x = 860

  wBase             = widget_base(parent, /COLUMN, PRO_SET_VALUE='cw_ogc_wcs_cfg_set_value', $
                                    NOTIFY_REALIZE='cw_ogc_wcs_cfg_realize_notify_event', space=5)

  wBaseState        = widget_base(wBase, uname='cfgstatebase', kill_notify='cw_ogc_wcs_cfg_kill_event')

  xsize = 410
  lxsize = xsize-20
  boxsize = 0.60
  textsize = 0.40

  ;;add the Validation frame -----------------------------
  wbaseSch          = widget_base(wbase)
  wLblSch           = widget_label(wbaseSch, value=' Schema Validation ', xoffset=5)
  winfoLblSch       = widget_info(wLblSch, /geometry)
  wbaseFrSch        = widget_base(wbaseSch, /frame, yoffset=winfoLblSch.ysize/2, xsize=170, /row, space=5, ypad=5, xpad=5)
  wLblSch           = widget_label(wbaseSch, value=' Schema Validation ', xoffset=5)

  wexBase           = widget_base(wbaseFrSch, /exclusive, /row)
  wbtnSchema0       = widget_button(wexBase, value=' Off', event_pro='cw_ogc_wcs_cfg_btnSchema0_event')
  wbtnSchema1       = widget_button(wexBase, value=' On', event_pro='cw_ogc_wcs_cfg_btnSchema1_event')
  wbtnSchema2       = widget_button(wexBase, value=' Full', event_pro='cw_ogc_wcs_cfg_btnSchema2_event')

  wbaseDTD          = widget_base(wbase)
  wLblDTD           = widget_label(wbaseDTD, value=' DTD Validation ', xoffset=5)
  winfoLblDTD       = widget_info(wLblDTD, /geometry)
  wbaseFrDTD        = widget_base(wbaseDTD, /frame, yoffset=winfoLblDTD.ysize/2, xsize=170, /row, space=5, ypad=5, xpad=5)
  wLblDTD           = widget_label(wbaseDTD, value=' DTD Validation ', xoffset=5)

  wexBase           = widget_base(wbaseFrDTD, /exclusive, /row)
  wbtnVMode0        = widget_button(wexBase, value=' Off', event_pro='cw_ogc_wcs_cfg_btnVMode0_event')
  wbtnVMode1        = widget_button(wexBase, value=' On, if DTD present', event_pro='cw_ogc_wcs_cfg_btnVMode1_event')
  wbtnVMode2        = widget_button(wexBase, value=' On', event_pro='cw_ogc_wcs_cfg_btnVMode2_event')

  wbaseHttp         = widget_base(wbase)
  wLblHttp          = widget_label(wbaseHttp, value=' Connection Settings ', xoffset=5)
  winfoLblHttp      = widget_info(wLblHttp, /geometry)
  wbaseFrHttp       = widget_base(wbaseHttp, /frame, yoffset=winfoLblHttp.ysize/2, xsize=630, /col, space=5, ypad=5, xpad=5)
  wLblHttp          = widget_label(wbaseHttp, value=' Connection Settings ', xoffset=5)

  wRow              = widget_base(wbaseFrHttp, /row)
  wlblRxTxTO        = widget_label(wRow, value='Send/Recieve Timeout (sec) ', scr_xsize=190, /align_right)
  wtxtRXTxTO        = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wlblConnectTO     = widget_label(wRow, value='Connect Timeout (sec) ', scr_xsize=190, /align_right)
  wtxtConnectTO     = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wRow              = widget_base(wbaseFrHttp, /row)
  wlbl              = widget_label(wRow, value='Username ', scr_xsize=190, /align_right)
  wtxtUsr           = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wlbl              = widget_label(wRow, value='Password ', scr_xsize=190, /align_right)
  wtxtPwd           = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wRow              = widget_base(wbaseFrHttp, /row)
  wlbl              = widget_label(wRow, value='Proxy Host ', scr_xsize=190, /align_right)
  wtxtProxy         = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wlbl              = widget_label(wRow, value='Proxy Port ', scr_xsize=190, /align_right)
  wtxtProxyPort     = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wRow              = widget_base(wbaseFrHttp, /row)
  wlbl              = widget_label(wRow, value='Proxy Username ', scr_xsize=190, /align_right)
  wtxtProxyUsr      = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  wlbl              = widget_label(wRow, value='Proxy Password ', scr_xsize=190, /align_right)
  wtxtProxyPwd      = widget_text(wRow, /editable, scr_xsize=150, ysize=1)

  ;wRow              = widget_base(wbaseFrHttp, /row)
  wnexBase          = widget_base(wbaseFrHttp, /nonexclusive, /row)
  wbtnDisplayHttp   = widget_button(wnexBase, value=' Display Http Progress Messages', event_pro='cw_ogc_wcs_cfg_btnHttpMsgs_event')

  ;wnexBase          = widget_base(wRow, /nonexclusive)
  wbtnVerbose       = widget_button(wnexBase, value=' Display Http Info/Header Messages (Verbose)', event_pro='cw_ogc_wcs_cfg_btnVerbose_event')

  ;;wRow              = widget_base(wbaseFrHttp, /row)
  wexBase           = widget_base(wbaseFrHttp, /exclusive, /row)
  wbtnEncodeNone    = widget_button(wexBase, value=' No Encoding', event_pro='cw_ogc_wcs_cfg_btnNoEncoding_event')
  wbtnEncodeDeflate = widget_button(wexBase, value=' Deflate Encoding', event_pro='cw_ogc_wcs_cfg_btnDeflateEncoding_event')
  wbtnEncodeGzip    = widget_button(wexBase, value=' Gzip Encoding', event_pro='cw_ogc_wcs_cfg_btnGzipEncoding_event')
  wbtnEncodeBoth    = widget_button(wexBase, value=' Deflate or Gzip Encoding', event_pro='cw_ogc_wcs_cfg_btnBothEncoding_event')

  ;;add the Dirs frame -----------------------------
  wbaseDir          = widget_base(wBase)
  wLblDir           = widget_label(wbaseDir, value=' Directories and Filenames (all fields are optional)', xoffset=5)
  winfoLblDir       = widget_info(wLblDir, /geometry)
  wbaseFrDir        = widget_base(wbaseDir, /frame, yoffset=winfoLblDir.ysize/2, xsize=size_of_x, /col, space=5, ypad=5, xpad=5)
  wLblDir           = widget_label(wbaseDir, value=' Directories and Filenames (all fields are optional)', xoffset=5)

  wDirCapr          = widget_base(wbaseFrDir, /row)
  wlblCapFN        = widget_label(wDirCapr, value='Capabilities Filename ', /align_right, scr_xsize=160)
  wtxtCapFN        = widget_text(wDirCapr, /editable, scr_xsize=360)
  wbtnBrowseCap     = widget_button(wDirCapr, value=' Browse', event_pro='cw_ogc_wcs_cfg_btnBrowseCap_event')

  wDirDesCovr       = widget_base(wbaseFrDir, /row)
  wlblDesCovFN     = widget_label(wDirDesCovr, value='Describe Coverage Filename ', /align_right, scr_xsize=160)
  wtxtDesCovFN     = widget_text(wDirDesCovr, /editable, scr_xsize=360)
  wbtnBrowseDesCov  = widget_button(wDirDesCovr, value=' Browse', event_pro='cw_ogc_wcs_cfg_btnBrowseDesCov_event')

  wDirCovr          = widget_base(wbaseFrDir, /row)
  wlblCovFN        = widget_label(wDirCovr, value='Coverage Filename ', /align_right, scr_xsize=160)
  wtxtCovFN        = widget_text(wDirCovr, /editable, scr_xsize=360)
  wbtnBrowseCov     = widget_button(wDirCovr, value=' Browse', event_pro='cw_ogc_wcs_cfg_btnBrowseCov_event')


  ;---------- save btns
  wRow = widget_base(wBase)
  wbtnSave = widget_button(wRow, value='Save Changes', xsize=100, xoffset=760, yoffset=0, event_pro='cw_ogc_wcs_cfg_btnSave_event')

  ; set frame size
  widget_control, wbaseFrSch,  xsize=size_of_x
  widget_control, wbaseFrDTD,  xsize=size_of_x
  widget_control, wbaseFrHttp, xsize=size_of_x
  widget_control, wbaseFrDir,  xsize=size_of_x


  ;paxServers is a ptr to an array of structures that define the remote servers, set in ogc_wcs_getConfigInfo
  state = { wbtnSchema0:wbtnSchema0, wbtnSchema1:wbtnSchema1, wbtnSchema2:wbtnSchema2, $
            wbtnVMode0:wbtnVMode0, wbtnVMode1:wbtnVMode1, wbtnVMode2:wbtnVMode2, $
            wtxtCapFN:wtxtCapFN, wtxtDesCovFN:wtxtDesCovFN, $
            wtxtCovFN:wtxtCovFN, wbtnDisplayHttp:wbtnDisplayHttp, wtxtRxTxTO:wtxtRxTxTO, $
            wtxtConnectTO:wtxtConnectTO, wtxtProxy:wtxtProxy, wtxtProxyPort:wtxtProxyPort, wbtnVerbose:wbtnVerbose, $
            wtxtUsr:wtxtUsr, wtxtProxyUsr:wtxtProxyUsr, wtxtPwd:wtxtPwd, wtxtProxyPwd:wtxtProxyPwd, wbtnEncodeBoth:wbtnEncodeBoth, $
            wbtnEncodeNone:wbtnEncodeNone, wbtnEncodeDeflate:wbtnEncodeDeflate, wbtnEncodeGzip:wbtnEncodeGzip, $
            parent:parent, prefsFile:'', paxServers:ptr_new(0), covServer:'', schemaCk:0,  $
            capFN:'', desCovFN:'', covFN:'', capFromFile:'', $
            desCovFromFile:'', displayHttp:1, rxtxTo:'1800', connectTo:'1800', proxy:'', proxyPort:'80', verbose:0, $
            usr:'', pwd:'', proxyusr:'', proxypwd:'', encoding:0, validationMode:0 }


  ; passing a ptr is much more efficient
  pstate = ptr_new(state, /no_copy)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wBaseState, set_uvalue=pstate

  ;this will set paxServers if the .sav file exists and has some remote server entries
  (*pstate).prefsFile = ogc_wcs_getConfigInfo(wBase, 'cfgstatebase')

  return, wBase

end
