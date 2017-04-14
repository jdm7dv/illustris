

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_reload_servers, ev, lastSvr
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate


  if (lastSvr eq 1) then begin
    widget_control, (*pstate).wtxtSvrName,     get_value = svr
;    svr = widget_info((*pstate).wcbSvrList, /combobox_gettext)
  endif

  ; ------- load appl entity fields: combo, name, aet, host, port, sln, type ----------

  num = widget_info((*pstate).wcbSvrList, /combobox_number)
  if (num ne 0) then begin
    for ii=num, 0, -1 do begin
      widget_control, (*pstate).wcbSvrList, combobox_deleteitem = ii
    endfor
  endif

  if (size(*(*pstate).paxServers, /type) ne 8) then begin
     widget_control, (*pstate).wtxtSvrName,        set_value = ''
     widget_control, (*pstate).wtxtScheme,         set_value = 'http'
     widget_control, (*pstate).wtxtHost,           set_value = ''
     widget_control, (*pstate).wtxtPort,           set_value = '80'
     widget_control, (*pstate).wtxtPath,           set_value = ''
     widget_control, (*pstate).wtxtQueryPrefix,    set_value = ''
     widget_control, (*pstate).wtxtQuerySuffix,    set_value = ''
     widget_control, (*pstate).wtxtWcsVer,         set_value = '1.0.0'
     return
  endif

  ;(*pstate).paxServers is a ptr to an array of structures, (*(*pstate).paxServers) is the array of structures
  count = n_elements(*(*pstate).paxServers)
  for xx = 0, count-1 do begin
     widget_control, (*pstate).wcbSvrList, combobox_additem = (*(*pstate).paxServers)[xx].SvrName
  endfor

  ; make the last svr show up in the combobox
  svrMatch = -1
  if (lastSvr eq 1) then begin
    widget_control, (*pstate).wcbSvrList, get_value = svrStrings
    cnt = n_elements(svrStrings)

    for ii=0, cnt-1 do begin
      if (svr eq svrStrings[ii])then begin
        svrMatch = ii
        break
      endif
    endfor
  endif

  ;; set match to 0 if we are not restoring the last SVR selected in
  ;; the combobox or a match was not found for the last SVR selected
  ;; in the combobox
  if (lastSvr eq 0) || (svrMatch eq -1) then begin
    svrMatch = 0
  endif

  widget_control, (*pstate).wcbSvrList, SET_COMBOBOX_SELECT=svrMatch

  widget_control, (*pstate).wtxtSvrName,        set_value = (*(*pstate).paxServers)[svrMatch].SvrName
  widget_control, (*pstate).wtxtScheme,         set_value = (*(*pstate).paxServers)[svrMatch].Scheme
  widget_control, (*pstate).wtxtHost,           set_value = (*(*pstate).paxServers)[svrMatch].Host
  widget_control, (*pstate).wtxtPort,           set_value = (*(*pstate).paxServers)[svrMatch].Port
  widget_control, (*pstate).wtxtPath,           set_value = (*(*pstate).paxServers)[svrMatch].Path
  widget_control, (*pstate).wtxtQueryPrefix,    set_value = (*(*pstate).paxServers)[svrMatch].QueryPrefix
  widget_control, (*pstate).wtxtQuerySuffix,    set_value = (*(*pstate).paxServers)[svrMatch].QuerySuffix
  widget_control, (*pstate).wtxtWcsVer,         set_value = (*(*pstate).paxServers)[svrMatch].WcsVer
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_cbSvrs_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  widget_control, ev.id, get_value = wstrings
  svrName = wstrings[ev.index]

  if (svrName eq '') then begin
    return
  endif

  ;(*pstate).paxServers is a ptr to an array of structures, (*(*pstate).paxServers) is the array of structures
  count = n_elements(*(*pstate).paxServers)
  for xx = 0, count-1 do begin
     if (svrName eq (*(*pstate).paxServers)[xx].SvrName) then begin
         widget_control, (*pstate).wtxtSvrName,        set_value = (*(*pstate).paxServers)[xx].SvrName
         widget_control, (*pstate).wtxtScheme,         set_value = (*(*pstate).paxServers)[xx].Scheme
         widget_control, (*pstate).wtxtHost,           set_value = (*(*pstate).paxServers)[xx].Host
         widget_control, (*pstate).wtxtPort,           set_value = (*(*pstate).paxServers)[xx].Port
         widget_control, (*pstate).wtxtPath,           set_value = (*(*pstate).paxServers)[xx].Path
         widget_control, (*pstate).wtxtQueryPrefix,    set_value = (*(*pstate).paxServers)[xx].QueryPrefix
         widget_control, (*pstate).wtxtQuerySuffix,    set_value = (*(*pstate).paxServers)[xx].QuerySuffix
         widget_control, (*pstate).wtxtWcsVer,         set_value = (*(*pstate).paxServers)[xx].WcsVer
         break;
     endif
  endfor

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_btnSave_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_svr_Save, ev, 0
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_btnNew_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_svr_Save, ev, 1

  widget_control, (*pstate).wtxtSvrName,        set_value = ''
  widget_control, (*pstate).wtxtScheme,         set_value = 'http'
  widget_control, (*pstate).wtxtHost,           set_value = ''
  widget_control, (*pstate).wtxtPort,           set_value = '80'
  widget_control, (*pstate).wtxtPath,           set_value = ''
  widget_control, (*pstate).wtxtQueryPrefix,    set_value = ''
  widget_control, (*pstate).wtxtQuerySuffix,    set_value = ''
  widget_control, (*pstate).wtxtWcsVer,         set_value = '1.0.0'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_btnDelete_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  svrName = widget_info((*pstate).wcbSvrList, /combobox_gettext)

  if (svrName[0] eq '') then begin
    return
  endif

  ;(*pstate).paxServers is a ptr to an array of structures, (*(*pstate).paxServers) is the array of structures
  count = n_elements(*(*pstate).paxServers)
  if (count eq 0) then begin
     return
  endif

  servers = *(*pstate).paxServers
  for xx = 0, count-1 do begin
     if (svrName[0] eq servers[xx].SvrName) then begin
         break;
     endif
  endfor

  rm = xx
  num = 0
  newpaxServers = ptr_new(0)
  for xx = 0, count-1 do begin
    if (xx ne rm) then begin
      if (num eq 0) then begin
        *newpaxServers = servers[xx]
        num++
      endif else begin
        *newpaxServers = [*newpaxServers, servers[xx]]
        num++
      endelse
    endif
  endfor

  ptr_free, (*pstate).paxServers
  (*pstate).paxServers = ptr_new(*newpaxServers, /no_copy)

  cw_ogc_wcs_svr_reload_servers, ev, 0
  cw_ogc_wcs_svr_Save, ev, 1
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_btnParse_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    if (obj_valid(owcs)) then begin
       obj_destroy, owcs
    endif
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate


  widget_control, (*pstate).wtxtUrlParse,     get_value = val
  if (val eq '') then begin
    r = dialog_message('Paste in OGC Server URL before pressing Parse.', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif

;  valUp = STRUPCASE(val)
;  if (strpos(valUp, 'SERVICE=') eq -1) then begin
;    r = dialog_message('Invalid OGC URL...it does not contain a Service= segment.', title='OGC WCS Error', dialog_parent=ev.top, /error)
;    return
;  endif

  ; create a ogc wcs object..it is needed to convert url's into properties
  owcs = obj_new('IDLnetOgcWcs')
  owcs->ParseURL, val[0]
  owcs->getproperty, url_scheme=scheme, url_host=host, url_port=port, url_path=path, url_query_prefix=queryprefix, url_query_suffix=querysuffix, wcs_version=wcsver
  obj_destroy, owcs

  widget_control, (*pstate).wtxtSvrName,    set_value = ''
  widget_control, (*pstate).wtxtScheme,     set_value = scheme
  widget_control, (*pstate).wtxtHost,       set_value = host
  widget_control, (*pstate).wtxtPort,       set_value = port
  widget_control, (*pstate).wtxtPath,       set_value = path
  widget_control, (*pstate).wtxtQueryPrefix,set_value = queryprefix
  widget_control, (*pstate).wtxtQuerySuffix,set_value = querysuffix
  widget_control, (*pstate).wtxtWcsVer,     set_value = wcsver
end


;;----------------------------------------------------------------------------
function cw_ogc_wcs_svr_CreateSvrStruct
  compile_opt idl2
  on_error, 2                   ; return errors to caller


  xSvr = create_struct(   'SvrName',    '', $
                          'Scheme',     '', $
                          'Host',       '', $
                          'Port',       '', $
                          'Path',       '', $
                          'QueryPrefix','', $
                          'QuerySuffix','', $
                          'WcsVer',     '')
  return, xSvr

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_Save, ev, returnOnBlank
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  ;(*pstate).paxServers is a ptr to an array of structures, (*(*pstate).paxServers) is the array of structures
  ; are we saving an entry that already exists?
  alreadyExists = -1
  if (size(*(*pstate).paxServers, /type) eq 8) then begin
      widget_control, (*pstate).wtxtSvrName,    get_value = val
      count = n_elements(*(*pstate).paxServers)
      for xx = 0, count-1 do begin
         if (val eq (*(*pstate).paxServers)[xx].SvrName) then begin
             alreadyExists = xx
             break;
         endif
      endfor
  endif

  xSvr = cw_ogc_wcs_svr_CreateSvrStruct()
  widget_control, (*pstate).wtxtSvrName,    get_value = val
  xSvr.SvrName = val
  if (val eq '') then begin
    if (returnOnBlank gt 0) then return
    r = dialog_message('Entry Name can not be null', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif


  widget_control, (*pstate).wtxtScheme,     get_value = val
  xSvr.Scheme = val
  if (val eq '') then begin
    if (returnOnBlank gt 0) then return
    r = dialog_message('Server Name can not be null', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].Scheme = val
  endif

  widget_control, (*pstate).wtxtHost,       get_value = val
  xSvr.Host = val
  if (val eq '') then begin
    if (returnOnBlank gt 0) then return
    r = dialog_message('Host Name can not be null', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].Host = val
  endif

  widget_control, (*pstate).wtxtPort,       get_value = val
  xSvr.Port = val
  if (val eq '') then begin
    if (returnOnBlank gt 0) then return
    r = dialog_message('Port can not be null', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].Port = val
  endif

  widget_control, (*pstate).wtxtPath,       get_value = val
  xSvr.Path = val
  if (val eq '') then begin
    if (returnOnBlank gt 0) then return
    r = dialog_message('Path can not be null', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].Path = val
  endif

  widget_control, (*pstate).wtxtQueryPrefix,get_value = val
  xSvr.QueryPrefix = val

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].QueryPrefix = val
  endif

  widget_control, (*pstate).wtxtQuerySuffix,get_value = val
  xSvr.QuerySuffix = val

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].QuerySuffix = val
  endif

  widget_control, (*pstate).wtxtWcsVer,get_value = val
  xSvr.WcsVer = val
  if (val eq '') then begin
    if (returnOnBlank gt 0) then return
    r = dialog_message('Version can not be null', title='OGC WCS Error', dialog_parent=ev.top, /error)
    return
  endif

  if (alreadyExists ne -1) then begin
    (*(*pstate).paxServers)[xx].WcsVer = val
  endif


  if (alreadyExists eq -1) then begin
      ; initially we do not have a save file with an array of structures so the *(*pstate).paxServers type will not be a structure
      if (size(*(*pstate).paxServers, /type) ne 8) then begin
          ; add the very first structure
          *(*pstate).paxServers = xSvr
      endif else begin
          ; append new svr to existing array of structs
          *(*pstate).paxServers = [*(*pstate).paxServers, xSvr]
      endelse
  endif

  cw_ogc_wcs_svr_reload_servers, ev, 1
  ogc_wcs_SaveValuesAndNotify, ev.top, 'svrstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_kill_event, id
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
pro cw_ogc_wcs_svr_refresh, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  ; this reloads the (*pstate).xxxx config vars with the current contents of the config file
  prefsFile = ogc_wcs_getConfigInfo(id, 'svrstatebase')

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_svr_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname='svrstatebase')
  widget_control, wState, get_uvalue = pstate

  if (size(*(*pstate).paxServers, /type) ne 8) then begin
     return
  endif

  ;(*pstate).paxServers is a ptr to an array of structures, (*(*pstate).paxServers) is the array of structures
  count = n_elements(*(*pstate).paxServers)
  for xx = 0, count-1 do begin
     widget_control, (*pstate).wcbSvrList, combobox_additem = (*(*pstate).paxServers)[xx].SvrName
  endfor

  widget_control, (*pstate).wtxtSvrName,        set_value = (*(*pstate).paxServers)[0].SvrName
  widget_control, (*pstate).wtxtScheme,         set_value = (*(*pstate).paxServers)[0].Scheme
  widget_control, (*pstate).wtxtHost,           set_value = (*(*pstate).paxServers)[0].Host
  widget_control, (*pstate).wtxtPort,           set_value = (*(*pstate).paxServers)[0].Port
  widget_control, (*pstate).wtxtPath,           set_value = (*(*pstate).paxServers)[0].Path
  widget_control, (*pstate).wtxtQueryPrefix,    set_value = (*(*pstate).paxServers)[0].QueryPrefix
  widget_control, (*pstate).wtxtQuerySuffix,    set_value = (*(*pstate).paxServers)[0].QuerySuffix
  widget_control, (*pstate).wtxtWcsVer,         set_value = (*(*pstate).paxServers)[0].WcsVer

end

;;----------------------------------------------------------------------------
function cw_ogc_wcs_svr, parent  ;, CALLBACKROUTINE=callbackRoutine
  compile_opt idl2
  on_error, 2

;  if ~keyword_set(callbackRoutine) then begin
;     callbackRoutine = ''
;  endif

  size_of_x = 860

  wBase             = widget_base(parent, /COLUMN, PRO_SET_VALUE='cw_ogc_wcs_svr_set_value', $
                                    NOTIFY_REALIZE='cw_ogc_wcs_svr_realize_notify_event', space=5)

  wBaseState        = widget_base(wBase, uname='svrstatebase', kill_notify='cw_ogc_wcs_svr_kill_event')

  xsize = 410
  lxsize = xsize-20
  boxsize = 0.60
  textsize = 0.40

  ; add the servers frame ------------------------
  ; ------- add the Svr to frame
  wBaseCol1         = widget_base(wBase, /Col, space = 10)

  wbaseSvr          = widget_base(wBaseCol1)
  wLblSvr           = widget_label(wbaseSvr, value=' Remote Servers Properties', xoffset=5)
  winfoLblSvr       = widget_info(wLblSvr, /geometry)
  wbaseFrSvr        = widget_base(wbaseSvr, /frame, yoffset=winfoLblSvr.ysize/2, xsize=size_of_x, /col, space=2, ypad=10, xpad=1, tab_mode=1)
  wLblSvr           = widget_label(wbaseSvr, value=' Remote Servers Properties', xoffset=5)

  wSvrr             = widget_base(wbaseFrSvr, /row)
  wlblSvrList       = widget_label(wSvrr, value='Existing Servers ', /align_right, xsize=lxsize*textsize)
  wcbSvrList        = widget_combobox(wSvrr, scr_xsize=lxsize*boxsize, event_pro='cw_ogc_wcs_svr_cbSvrs_event')
  wlbl              = widget_label(wSvrr, value='  List of servers previously defined.')

  wSvrNr            = widget_base(wbaseFrSvr, /row)
  wlblSvrName       = widget_label(wSvrNr, value='Entry Name ', /align_right, xsize=lxsize*textsize)
  wtxtSvrName       = widget_text(wSvrNr, /editable, scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wSvrNr, value='  Unique Entry Name')

  wSchemer          = widget_base(wbaseFrSvr, /row)
  wlblScheme        = widget_label(wSchemer, value='Scheme Name ', /align_right, xsize=lxsize*textsize)
  wtxtScheme        = widget_text(wSchemer, /editable, value = 'http', scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wSchemer, value='  Optional: Defaults to Http')

  wHostr            = widget_base(wbaseFrSvr, /row)
  wlblHost          = widget_label(wHostr, value='Host Name ', /align_right, xsize=lxsize*textsize)
  wtxtHost          = widget_text(wHostr, /editable, scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wHostr, value='  Server that handles OGC requests')

  wPortr            = widget_base(wbaseFrSvr, /row)
  wlblPort          = widget_label(wPortr, value='TCP/IP Port Number ', /align_right, xsize=lxsize*textsize)
  wtxtPort          = widget_text(wPortr, /editable, value = '80', scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wPortr, value='  Optional: Defaults to 80')

  wPathr            = widget_base(wbaseFrSvr, /row)
  wlblPath          = widget_label(wPathr, value='Path ', /align_right, xsize=lxsize*textsize)
  wtxtPath          = widget_text(wPathr, /editable, scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wPathr, value='  Typically this is a path to a CGI routine that handles OGC requests.')

  wQueryPrefixr     = widget_base(wbaseFrSvr, /row)
  wlblQueryPrefix   = widget_label(wQueryPrefixr, value='Query Prefix ', /align_right, xsize=lxsize*textsize)
  wtxtQueryPrefix   = widget_text(wQueryPrefixr, /editable, scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wQueryPrefixr, value='  Optional: Prefix to Service=WCS&Request=Get...')

  wQuerySuffixr     = widget_base(wbaseFrSvr, /row)
  wlblQuerySuffix   = widget_label(wQuerySuffixr, value='Query Suffix ', /align_right, xsize=lxsize*textsize)
  wtxtQuerySuffix   = widget_text(wQuerySuffixr, /editable, scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wQuerySuffixr, value='  Optional: Suffix to Service=WCS&Request=Get...')

  wWcsVerr          = widget_base(wbaseFrSvr, /row)
  wlblWcsVer        = widget_label(wWcsVerr, value='WCS Version Supported ', /align_right, xsize=lxsize*textsize)
  wtxtWcsVer        = widget_text(wWcsVerr, /edit, value = '1.0.0', scr_xsize=lxsize*boxsize)
  wlbl              = widget_label(wWcsVerr, value='  WCS Version supported by both the client and server.')

  wBaseCol2         = widget_base(wbaseFrSvr, /Col, space=10, xpad=5)
  wSvrr             = widget_base(wBaseCol2, /row, xpad=140)
  wbtnSvrNew        = widget_button(wSvrr, value='New', xsize = 80, uvalue=0, event_pro='cw_ogc_wcs_svr_btnNew_event')
  wbtnSvrDelete     = widget_button(wSvrr, value='Delete', xsize = 80, event_pro='cw_ogc_wcs_svr_btnDelete_event')
  wbtnSvrSave       = widget_button(wSvrr, value='Save Changes', xsize = 100, event_pro='cw_ogc_wcs_svr_btnSave_event')

  wUrlParser        = widget_base(wbaseFrSvr, /row)
  wlblUrlParse      = widget_label(wUrlParser, value='Parse known working OGC Server URL into properties ')
  wUrlParser        = widget_base(wbaseFrSvr, /row)
  wtxtUrlParse      = widget_text(wUrlParser, /editable, scr_xsize=740)
  wbtnUrlParse      = widget_button(wUrlParser, value='Parse', xsize = 80, event_pro='cw_ogc_wcs_svr_btnParse_event')

  ;paxServers is a ptr to an array of structures that define the remote servers, set in ogc_wcs_getConfigInfo
  state = { wcbSvrList:wcbSvrList, wtxtSvrName:wtxtSvrName, wtxtScheme:wtxtScheme, wtxtHost:wtxtHost, $
            wtxtPort:wtxtPort, wtxtPath:wtxtPath, wtxtQueryPrefix:wtxtQueryPrefix, wtxtQuerySuffix:wtxtQuerySuffix, $
            wtxtUrlParse:wtxtUrlParse, wtxtWcsVer:wtxtWcsVer,  $
            parent:parent, prefsFile:'', paxServers:ptr_new(0), covServer:'', schemaCk:0, $
            capFN:'', desCovFN:'', covFN:'', capFromFile:'', $
            desCovFromFile:'', displayHttp:1, rxtxTo:'1800', connectTo:'1800', proxy:'', proxyPort:'', verbose:0, $
            usr:'', pwd:'', proxyusr:'', proxypwd:'', encoding:0, validationMode:0 }


  ; passing a ptr is much more efficient
  pstate = ptr_new(state, /no_copy)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wBaseState, set_uvalue=pstate

  ;this will set paxServers if the .sav file exists and has some remote server entries
  (*pstate).prefsFile = ogc_wcs_getConfigInfo(wBase, 'svrstatebase')

  return, wBase

end
