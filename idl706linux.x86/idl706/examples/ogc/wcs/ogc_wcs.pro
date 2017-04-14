; $Id: //depot/idl/IDL_70/idldir/examples/ogc/wcs/ogc_wcs.pro#1 $
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
pro ogc_wcs_btnhelp_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

txt = [ $
'Define OGC WCS Servers', $
'----------------------------------------------------------------------------------------------------------------------', $
'Before requesting data from a OGC WCS server, you need to define the properties of the server by completing the', $
'following steps:', $
'', $
'1. Select the OGC WCS Servers tab.', $
'2. Click the New button to clear property fields.', $
'3. Enter a known working URL into the "Parse known working OGC Server URL into properties" text box and click Parse.', $
'    OGC server properties are extracted from the URL and written to corresponding object properties.', $
'4. Enter a unique name into the "Entry Name" field that identifies the WCS server.', $
'5. Click Save Changes to store the server information.', $
'', $
'Requesting Server Capabilities', $
'----------------------------------------------------------------------------------------------------------------------', $
'Do determine the OGC WCS Server offerings, complete the following steps:', $
'', $
'1. Select the Capabilities tab.', $
'2. In the Get Capabilities section, select the server to query from the "Remote WCS Server" drop-down list.', $
'    Press Get Capabilities button. Status of the query process is printed to the Status window.', $
'3. Select the coverage offering brief for which to return detailed information.  Use the navigation buttons (Home, ', $
'    Page Up, Scroll Up, etc.) to view the entries. ', $
'4. Click the Describe Coverage button to return coverage information. The IDL OGC WCS Describe Coverage window ', $
'    appears. Use the various tabs to view characteristics of the coverage. ', $
'', $
'Requesting a Coverage', $
'----------------------------------------------------------------------------------------------------------------------', $
'To request a coverage, complete the following steps in the IDL OGC WCS Describe Coverage window:', $
'', $
'1. Define the dimensions of the coverage to return in the Coverage Request Dimensions section or accept the defaults.', $
'2. In the Get Coverage section, click the Get Coverage button to return the coverage described in the text box.  ', $
'    Status of the request appears in the Status window. The location and name of the file containing the coverage is ', $
'    printed to this window when the coverage is successfully returned. ', $
'', $
'After the coverage request finishes, select the Open Image button to open an image file or select ', $
'the Browse HDF/NetCDF button to examine a HDF file.  In the Supported Formats section, the "Format" drop-down ', $
'list provides a list of formats supported by the server.']

   x = dialog_message(txt, /info, TITLE='IDL OGC WCS Browser Help')
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_OpenImage, ev, uname
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname=uname)
  widget_control, wState, get_uvalue = pstate

  (*pstate).owcs->getproperty, last_file = fpc

  imgData = read_image(fpc)

help, imgData
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

  (*pstate).coitIdArr[(*pstate).coitIdArrIdx++] = id
end
;;----------------------------------------------------------------------------
function ogc_wcs_getConfigInfo, id, findbyuname

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
  AuthorDesc        = 'Research Systems, Inc.'
  AppDirname        = 'OGC_UI_PREFS-1-100'
  AppDesc           = 'OGC UI Preferences'
  AppReadmeText     = ['Author: rsi', 'This dir is used to hold the sav files that contain the OGC UI preferences']
  AppReadmeVersion  = 1
  dir               = APP_USER_DIR(AuthorDirname, AuthorDesc, AppDirname, AppDesc, AppReadmeText, AppReadmeVersion)
  prefsFile         = filepath(ROOT_DIR=dir, 'ogc_ui_wcs.sav')
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

  if (n_elements(desCovFN) ne 0) then begin
      (*pstate).desCovFN = desCovFN
  endif  else begin
      (*pstate).desCovFN = ''
  endelse


  if (n_elements(covFN) ne 0) then begin
      (*pstate).covFN = covFN
  endif else begin
      (*pstate).covFN = ''
  endelse


  if (n_elements(capFromFile) ne 0) then begin
      (*pstate).capFromFile = capFromFile
  endif

  if (n_elements(desCovFromFile) ne 0) then begin
      (*pstate).desCovFromFile = desCovFromFile
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
pro ogc_wcs_SaveValuesAndNotify, id, findbyuname
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname=findbyuname)
  widget_control, wState, get_uvalue = pstate

  ; we need a named variable to do a save...during the retore we must use this name: 'axServersSave'
  axServersSave     = *(*pstate).paxServers
  covServer         = (*pstate).covServer
  schemaCk          = (*pstate).schemaCk
  capFN             = (*pstate).capFN
  desCovFN          = (*pstate).desCovFN
  covFN             = (*pstate).covFN
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
        capFN, desCovFN, covFN, capFromFile, $
        displayHttp, rxtxTo, connectTo, proxy, proxyPort, verbose, $
        usr, pwd, proxyusr, proxypwd, encoding, validationMode, FILENAME=(*pstate).prefsFile

  if (findbyuname eq 'capstatebase') then begin
      cw_ogc_wcs_cfg_refresh, id
      cw_ogc_wcs_svr_refresh, id
  endif

  if (findbyuname eq 'cfgstatebase') then begin
      cw_ogc_wcs_cap_refresh, id
      cw_ogc_wcs_svr_refresh, id
  endif

  if (findbyuname eq 'svrstatebase') then begin
      cw_ogc_wcs_cfg_refresh, id
      cw_ogc_wcs_cap_refresh, id
  endif

end

;;----------------------------------------------------------------------------
pro ogc_wcs_btnClose_event, ev
  compile_opt idl2, hidden
  on_error, 2

  ;; make the ui go away
  widget_control, ev.top, /destroy
end

;;----------------------------------------------------------------------------
pro ogc_wcs_event, ev
  compile_opt idl2, hidden

  ;; fake a button close event
  IF TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN $
    ogc_wcs_btnClose_event, ev
end

;;----------------------------------------------------------------------------
pro ogc_wcs
  compile_opt idl2
  on_error, 2

  ; the errors caught in the compound widget's main init routine bubble up to this level.
  ; if there is an error it is displayed and this dialog exits

  catch, errorStatus
  if (errorStatus ne 0) then begin
    catch,/cancel
    r = dialog_message(!error_state.msg, title='IDL OGC WCS Error', dialog_parent=cwBase, /error)
    return
  endif

  ; root level widget for this ui
  cwBase = widget_base(/column, TITLE='IDL OGC WCS Browser', uname='ui_ogc_wcs', tlb_frame_attr=1, /tlb_kill_request_events)

  wTab = widget_tab(cwBase)


  wTab1 = widget_base(wTab, title='   Capabilities   ',/row, uname='ui_ogc_wcs_cap_tab', uvalue=cwBase)
  cov = cw_ogc_wcs_cap(wTab1)

  ; create the server tab
  wTab2 = widget_base(wTab, title='  OGC WCS Servers ',/row, uname='ui_ogc_wcs_svr_tab', uvalue=cwBase)
  cfg = cw_ogc_wcs_svr(wTab2)

  ; create the config tab
  wTab3 = widget_base(wTab, title='   Configuration   ',/row, uname='ui_ogc_wcs_cfg_tab', uvalue=cwBase)
  cfg = cw_ogc_wcs_cfg(wTab3)


  ; add the close button to the tab container
  ;wRow = widget_base(cwBase, /row, /align_right, space=5)
  wRow = widget_base(cwBase, /row, /align_left, space=5)
  wbtnClose = widget_button(wRow, value='Close', xsize = 100, event_pro = 'ogc_wcs_btnClose_event')
  wbtnHelp  = widget_button(wRow, value='Help',  xsize = 100, event_pro = 'ogc_wcs_btnHelp_event')

  ; draw the ui
  widget_control, cwBase, /real

  ;; The XMANAGER procedure provides the main event loop and
  ;; management for widgets created using IDL.  Calling XMANAGER
  ;; "registers" a widget program with the XMANAGER event handler,
  ;; XMANAGER takes control of event processing until all widgets have
  ;; been destroyed.

  ;; NO BLOCK needs to be set 0 in order for the build query events to fire
  XMANAGER,'ogc_wcs', cwBase, GROUP=group, NO_BLOCK=0
end
