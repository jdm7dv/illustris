; $Id: //depot/idl/IDL_70/idldir/examples/ogc/wms/ogc_wms.pro#1 $
; Copyright (c) 1993-2005, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;
; **********************************************************************
;
; Description:
;   This pro code presents the ogc wcs dialog.
;   Invocation:
;
;
; MODIFICATION HISTORY:
;   LFG, RSI, October. 2005  Original version.

;;----------------------------------------------------------------------------
pro ogc_wms_btnhelp_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

txt = [ $
'Define OGC WMS Servers', $
'----------------------------------------------------------------------------------------------------------------------', $
'Before requesting data from a OGC WMS server, you need to define the properties of the server by completing the', $
'following steps:', $
'', $
'1. Select the OGC WMS Servers tab.', $
'2. Click the New button to clear property fields.', $
'3. Enter a known working URL into the "Parse known working OGC Server URL into properties" text box and click Parse.', $
'    OGC server properties are extracted from the URL and written to corresponding object properties.', $
'4. Enter a unique name into the "Entry Name" field that identifies the WMS server.', $
'5. Click Save Changes to store the server information.', $
'', $
'Requesting Server Capabilities', $
'----------------------------------------------------------------------------------------------------------------------', $
'Do determine the OGC WMS Server offerings, complete the following steps:', $
'', $
'1. Select the Capabilities tab.', $
'2. In the Get Capabilities section, select the server to query from the "Remote WMS Server" drop-down list.', $
'    Click Get Capabilities button. Status of the query process is printed to the Status window.', $
'3. Select the layer for which to return detailed information.  Use the navigation buttons (Home, ', $
'    Page Up, Scroll Up, etc.) to view the entries. ', $
'4. Click the Layer Info button to return layer information. The IDL OGC WMS Map window ', $
'    appears. Use the various tabs to view characteristics of the layer. ', $
'', $
'Requesting a Map', $
'----------------------------------------------------------------------------------------------------------------------', $
'To request a map, complete the following steps in the IDL OGC WMS MAP window:', $
'', $
'1. Define the dimensions of the map to return in the Map Request section or accept the defaults.', $
'2. In the Get Map section, click the Get Map button to return the Map described in the text box.  ', $
'    Status of the request appears in the Status window. The location and name of the file containing the map is ', $
'    printed to this window when the map is successfully returned. ', $
'', $
'After the coverage request finishes, select the Open Map button to view the map.', $
'The "Format" drop-down list, in the Get Map section, provides a list of formats supported by the server.']

   x = dialog_message(txt, /info, TITLE='IDL OGC WMS Browser Help')
end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_OpenMap, ev, uname
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname=uname)
  widget_control, wState, get_uvalue = pstate

  (*pstate).owms->getproperty, last_file = fpc

  imgData = read_image(fpc)

  if (n_elements(imgData) eq 1) then begin
      msg = 'This file can not be opened in iImage: ' + fpc
      message, msg
      return
  endif

  if (size(imgData, /type) eq 1) then begin
     iImage, fix(imgData), id=id
  endif else begin
     iImage, imgData, id=id
  endelse

  (*pstate).lyritIdArr[(*pstate).lyritIdArrIdx++] = id
end


;;----------------------------------------------------------------------------
function ogc_wms_getConfigInfo, id, findbyuname

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC Client Test', /error)
        print, !error_state.msg
        return, ''
    endif

  wState = widget_info(id, find_by_uname=findbyuname)
  widget_control, wState, get_uvalue = pstate

  ; restore the save file that holds all the configuration data
  AuthorDirname     = 'ITT'
  AuthorDesc        = 'ITT'
  AppDirname        = 'OGC_UI_PREFS-1-100'
  AppDesc           = 'OGC UI Preferences'
  AppReadmeText     = ['Author: rsi', 'This dir is used to hold the sav files that contain the OGC UI preferences']
  AppReadmeVersion  = 1
  dir               = APP_USER_DIR(AuthorDirname, AuthorDesc, AppDirname, AppDesc, AppReadmeText, AppReadmeVersion)
  prefsFile         = filepath(ROOT_DIR=dir, 'ogc_ui_wms.sav')
  if (file_test(prefsFile, /REGULAR)) then begin
    restore, prefsFile
  endif

  ;; if the var was in the config file then override the default value
  if (n_elements(covServer) ne 0) then begin
      (*pstate).covServer = covServer
  endif

  if (n_elements(schemaCk) ne 0) then begin
      (*pstate).schemaCk = schemaCk
  endif

  if (n_elements(validationMode) ne 0) then begin
      (*pstate).validationMode = validationMode
  endif

  if (n_elements(capFN) ne 0) then begin
      (*pstate).capFN = capFN
  endif else begin
      (*pstate).capFN = ''
  endelse

  if (n_elements(mapFN) ne 0) then begin
      (*pstate).mapFN = mapFN
  endif  else begin
      (*pstate).mapFN = ''
  endelse

  if (n_elements(featFN) ne 0) then begin
      (*pstate).featFN = featFN
  endif  else begin
      (*pstate).featFN = ''
  endelse

  if (n_elements(capFromFile) ne 0) then begin
      (*pstate).capFromFile = capFromFile
  endif

  if (n_elements(displayHttp) ne 0) then begin
      (*pstate).displayHttp = displayHttp
  endif

  if (n_elements(rxtxTo) ne 0) then begin
      (*pstate).rxtxTo = rxtxTo
  endif

  if (n_elements(connectTo) ne 0) then begin
      (*pstate).connectTo = connectTo
  endif

  if (n_elements(proxy) ne 0) then begin
      (*pstate).proxy = proxy
  endif

  if (n_elements(proxyPort) ne 0) then begin
      (*pstate).proxyPort = proxyPort
  endif

  if (n_elements(verbose) ne 0) then begin
      (*pstate).verbose = verbose
  endif

  if (n_elements(usr) ne 0) then begin
      (*pstate).usr = usr
  endif

  if (n_elements(pwd) ne 0) then begin
      (*pstate).pwd = pwd
  endif

  if (n_elements(proxyusr) ne 0) then begin
      (*pstate).proxyusr = proxyusr
  endif

  if (n_elements(proxypwd) ne 0) then begin
      (*pstate).proxypwd = proxypwd
  endif

  if (n_elements(encoding) ne 0) then begin
      (*pstate).encoding = encoding
  endif

  if (ptr_valid((*pstate).paxServers)) then begin
     if (size(*(*pstate).paxServers, /type) eq 8) then begin
         ptr_free, (*pstate).paxServers
     endif
  endif

  ; the save file used the named var called paxServersSave to store the array of structures that define the remote servers
  if (n_elements(axServersSave) ne 0) then begin
    (*pstate).paxServers = ptr_new(axServersSave, /no_copy)
  endif

  return, prefsFile
end

;;----------------------------------------------------------------------------
pro ogc_wms_SaveValuesAndNotify, id, findbyuname
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname=findbyuname)
  widget_control, wState, get_uvalue = pstate

  ; we need a named variable to do a save...during the retore we must use this name: 'axServersSave'
  axServersSave     = *(*pstate).paxServers
  covServer         = (*pstate).covServer
  schemaCk          = (*pstate).schemaCk
  capFN             = (*pstate).capFN
  mapFN             = (*pstate).mapFN
  featFN            = (*pstate).featFN
  capFromFile       = (*pstate).capFromFile
  displayHttp       = (*pstate).displayHttp
  rxtxTo            = (*pstate).rxtxTo
  connectTo         = (*pstate).connectTo
  proxy             = (*pstate).proxy
  proxyPort         = (*pstate).proxyPort
  verbose           = (*pstate).verbose
  usr               = (*pstate).usr
  pwd               = (*pstate).pwd
  proxyusr          = (*pstate).proxyusr
  proxypwd          = (*pstate).proxypwd
  encoding          = (*pstate).encoding
  validationMode    = (*pstate).validationMode

  ; write the save file
  save, axServersSave, covServer, schemaCk, $
        capFN, mapFN, featFN, capFromFile, $
        displayHttp, rxtxTo, connectTo, proxy, proxyPort, verbose, $
        usr, pwd, proxyusr, proxypwd, encoding, validationMode, FILENAME=(*pstate).prefsFile

  if (findbyuname eq 'capstatebase') then begin
      cw_ogc_wms_cfg_refresh, id
      cw_ogc_wms_svr_refresh, id
  endif

  if (findbyuname eq 'cfgstatebase') then begin
      cw_ogc_wms_cap_refresh, id
      cw_ogc_wms_svr_refresh, id
  endif

  if (findbyuname eq 'svrstatebase') then begin
      cw_ogc_wms_cfg_refresh, id
      cw_ogc_wms_cap_refresh, id
  endif

end

;;----------------------------------------------------------------------------
pro ogc_wms_btnClose_event, ev
  compile_opt idl2, hidden
  on_error, 2

  ;; make the ui go away
  widget_control, ev.top, /destroy
end

;;----------------------------------------------------------------------------
pro ogc_wms_event, ev
  compile_opt idl2, hidden

  ;; fake a button close event
  IF TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN $
    ogc_wms_btnClose_event, ev
end

;;----------------------------------------------------------------------------
pro ogc_wms
  compile_opt idl2
  on_error, 2

  ; the errors caught in the compound widget's main init routine bubble up to this level.
  ; if there is an error it is displayed and this dialog exits

  catch, errorStatus
  if (errorStatus ne 0) then begin
    catch,/cancel
    r = dialog_message(!error_state.msg, title='IDL OGC WMS Error', dialog_parent=cwBase, /error)
    return
  endif

  ; root level widget for this ui
  cwBase = widget_base(/column, TITLE='IDL OGC WMS Browser', uname='ui_ogc_wms', tlb_frame_attr=1, /tlb_kill_request_events)

  wTab = widget_tab(cwBase)


  wTab1 = widget_base(wTab, title='   Capabilities   ',/row, uname='ui_ogc_wms_cap_tab', uvalue=cwBase)
  lyr = cw_ogc_wms_cap(wTab1)

  ; create the server tab
  wTab2 = widget_base(wTab, title='  OGC WMS Servers ',/row, uname='ui_ogc_wms_svr_tab', uvalue=cwBase)
  cfg = cw_ogc_wms_svr(wTab2)

  ; create the config tab
  wTab3 = widget_base(wTab, title='   Configuraton   ',/row, uname='ui_ogc_wms_cfg_tab', uvalue=cwBase)
  cfg = cw_ogc_wms_cfg(wTab3)


  ; add the close button to the tab container
  ;wRow = widget_base(cwBase, /row, /align_right, space=5)
  wRow = widget_base(cwBase, /row, /align_left, space=5)
  wbtnClose = widget_button(wRow, value='Close', xsize = 100, event_pro = 'ogc_wms_btnClose_event')
  wbtnHelp  = widget_button(wRow, value='Help',  xsize = 100, event_pro = 'ogc_wms_btnHelp_event')

  ; draw the ui
  widget_control, cwBase, /real

; remove these lines
;ev  = create_struct('ID', cwBase, 'TOP', cwBase, 'HANDLER', 0)
;cw_ogc_wms_cap_btnCapFromFile_event, ev
;cw_ogc_wms_cap_btnLayerInfo_event, ev


  ;; The XMANAGER procedure provides the main event loop and
  ;; management for widgets created using IDL.  Calling XMANAGER
  ;; "registers" a widget program with the XMANAGER event handler,
  ;; XMANAGER takes control of event processing until all widgets have
  ;; been destroyed.

  ;; NO BLOCK needs to be set 0 in order for the build query events to fire
  XMANAGER,'ogc_wms', cwBase, GROUP=group, NO_BLOCK=0
end
