

;;----------------------------------------------------------------------------
function cw_ogc_wms_cap_callback, status, progress, data
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', dialog_parent=cwBase, /error)
    return, 1
  endif

  ; progess messgaes begin with http
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
  wevCap = widget_event((*data).wbtnCancelCap, /nowait)

  if (wevCap.id EQ (*data).wbtnCancelCap) then begin
    return, 0
  endif

;  if (progress[0]) then begin
;     print, progress
;  endif

  ;widget_control, hourglass=1
  return, 1
end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_PageScroll_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        (*pstate).mouseState = 0
        (*pstate).tmrEvCnt = 0
        (*pstate).tmrPeriod = 0.5
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate


  rows  = (*pstate).tblRows
  totlayers = (*pstate).layersLoaded

  if (totlayerS le rows) then begin
     return
  endif

  if ((*pstate).mouseState eq 0) then begin
      (*pstate).tmrEvCnt = 0
      (*pstate).tmrPeriod = 0.5
      return
  endif

  (*pstate).tmrEvCnt++
  widget_control, (*pstate).wTmr, timer=(*pstate).tmrPeriod

;  if (((*pstate).tmrEvCnt eq 2) || ((*pstate).tmrEvCnt eq 3)) then begin
  if ((*pstate).tmrEvCnt eq 2) then begin
      return
  endif

  if ((*pstate).tmrPeriod gt 0.06) then begin
    (*pstate).tmrPeriod = (*pstate).tmrPeriod - 0.05
    ;print, (*pstate).tmrPeriod
  endif


  if ((*pstate).mouseState eq 1) then begin

      if (totlayers gt rows) then begin
         if ((*pstate).scrollUp eq 0) then begin  ; scroll down
            if ((*pstate).layerIndex lt totlayers) then begin


               (*pstate).layerIndex = (*pstate).layerIndex + (*pstate).pageScrlInc

               idx   = (*pstate).layerIndex
               skip  = idx-rows
               if (skip gt (totlayers - rows)) then begin
                  skip = totlayers - rows
                  ;(*pstate).layerIndex = totlayers-rows
                  (*pstate).layerIndex = totlayers
               endif

               res   = (*pstate).owms->GetLayers(index=skip, number=rows)
               cw_ogc_wms_cap_display_cap_table, ev, res

             endif
         endif else begin  ; scroll up
            if ((*pstate).layerIndex gt rows) then begin


               (*pstate).layerIndex =  (*pstate).layerIndex - (*pstate).pageScrlInc

               idx   = (*pstate).layerIndex
               skip  = idx-rows

               if (skip lt 0) then begin
                  skip = 0
                  (*pstate).layerIndex = rows
               endif

               res   = (*pstate).owms->GetLayers(index=skip, number=rows)
               cw_ogc_wms_cap_display_cap_table, ev, res

             endif
         endelse
      endif
  endif
end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnScrDn_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 0
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = 1
  cw_ogc_wms_cap_PageScroll_event, ev

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnScrUp_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 1
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = 1
  cw_ogc_wms_cap_PageScroll_event, ev
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnPgDn_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 0
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = (*pstate).tblRows
  cw_ogc_wms_cap_PageScroll_event, ev

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnPgUp_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 1
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = (*pstate).tblRows
  cw_ogc_wms_cap_PageScroll_event, ev
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnHome_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  rows  = (*pstate).tblRows
  res   = (*pstate).owms->GetLayers(index=0, number=rows)

  cw_ogc_wms_cap_display_cap_table, ev, res
  (*pstate).layerIndex = rows
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnEnd_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  rows  = (*pstate).tblRows
  totlayers = (*pstate).layersLoaded

  if (totlayerS le rows) then begin
     return
  endif

  res   = (*pstate).owms->GetLayers(index=totlayers-rows, number=rows)
  cw_ogc_wms_cap_display_cap_table, ev, res
  (*pstate).layerIndex = totlayers
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_cbServer_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  svrName = widget_info((*pstate).wcbServer, /combobox_gettext)
  (*pstate).covServer = svrName
  ogc_wms_SaveValuesAndNotify, ev.top, 'capstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_table_results_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  ; if the table is empty return
  if ((*pstate).layersLoaded lt 1) then begin
     return
  end

  ; when a cell is selected highlight the whole row
  if (ev.type eq 4) then begin

    ; determine which rows are selected
    sel = widget_info(ev.id, /table_select)
    cnt = n_elements(sel)/2

    ; no selections just clear layerOrder and return
    if (cnt le 0) then begin
       (*pstate).layerOrder[*,*] = -1
       return
    endif

    ; one selection or back to only one selection reset the layerOrder list
    if (cnt le 1) then begin
       (*pstate).layerOrder[*,*] = -1
    endif

    nord = n_elements((*pstate).layerOrder)

    if (cnt eq 1) then begin
        sel[0] = -1
    endif else begin
       for i=0, cnt-1 do begin
          sel[0,i] = -1
       endfor
    endelse

    ; during each select event
    ; if the selected row is already in the list we do not do anything
    ; if the selected row is not in the list we add it to the bottom of the list
    ; the layerOrder list stores the rows in the order they were selected.
    last = -2
    for i=0, cnt-1 do begin
       if (sel[0,i] ne last) then begin
          last = sel[(i*2)+1]
          for x=0, nord-1 do begin
             if ((*pstate).layerOrder[x] eq -1) then begin
                (*pstate).layerOrder[x] = last
                i = 10000
                x = 10000
             endif else begin
                if ((*pstate).layerOrder[x] eq last) then begin
                   x= 10000
                endif
             endelse

          endfor
       endif
    endfor

    widget_control, ev.id, set_table_select=sel
    widget_control, ev.id, set_table_view=[0,0]

  endif
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_init_properties, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  svrName = widget_info((*pstate).wcbServer, /combobox_gettext)

  if (svrName eq '') then begin
    return
  endif

  idx = -1
  count = n_elements(*(*pstate).paxServers)
  for xx = 0, count-1 do begin
     if (svrName eq (*(*pstate).paxServers)[xx].SvrName) then begin
         idx = xx
         break;
     endif
  endfor

  if (idx eq -1) then begin
    r = dialog_message('Unable to locate server properties', title='OGC WMS Error', /error)
  endif

  (*pstate).owms->setproperty, url_scheme            = (*(*pstate).paxServers)[xx].Scheme
  (*pstate).owms->setproperty, url_host              = (*(*pstate).paxServers)[xx].Host
  (*pstate).owms->setproperty, url_path              = (*(*pstate).paxServers)[xx].Path
  (*pstate).owms->setproperty, url_port              = (*(*pstate).paxServers)[xx].Port
  (*pstate).owms->setproperty, url_query_prefix      = (*(*pstate).paxServers)[xx].QueryPrefix
  (*pstate).owms->setproperty, url_query_suffix      = (*(*pstate).paxServers)[xx].QuerySuffix
  (*pstate).owms->setproperty, wms_version           = (*(*pstate).paxServers)[xx].wmsver
  (*pstate).owms->setproperty, callback_function     ='cw_ogc_wms_cap_callback'
  (*pstate).owms->SetProperty, callback_data         = pstate
  (*pstate).owms->setproperty, timeout               = (*pstate).rxtxTo
  (*pstate).owms->setproperty, connect_timeout       = (*pstate).connectTo
  (*pstate).owms->setproperty, proxy_hostname        = (*pstate).proxy
  (*pstate).owms->setproperty, proxy_Port            = (*pstate).proxyPort
  (*pstate).owms->setproperty, verbose               = (*pstate).verbose
  (*pstate).owms->setproperty, username              = (*pstate).usr
  (*pstate).owms->setproperty, password              = (*pstate).pwd
  (*pstate).owms->setproperty, proxy_username        = (*pstate).proxyusr
  (*pstate).owms->setproperty, proxy_password        = (*pstate).proxypwd
  (*pstate).owms->setproperty, encode                = (*pstate).encoding

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_fr_title, ev, ver, cnt

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  val = ' Capabilities     Version = ' + strtrim(string(ver), 2) + '    Count = ' + strtrim(string(cnt), 2) + '  '
  info = widget_info((*pstate).wLblResult, string_size= val)
  widget_control, (*pstate).wLblResult, xsize=info[0], set_value = val

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_display_cap, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  rows = (*pstate).tblRows
  layers = (*pstate).owms->GetLayers(count= cnt, number=rows)

  if (cnt lt 1) then begin
    message, "No Layers are available"
    return
  endif

  cw_ogc_wms_cap_fr_title, ev, layers[0].version, (*pstate).layersLoaded

  ; display the results in results table
  cw_ogc_wms_cap_display_cap_table, ev, layers
  (*pstate).layerIndex = rows
  widget_control, (*pstate).wtblResults, set_table_select=[-1,0]

  ;srvsec = (*pstate).owms->GetCapServiceSection()
  ;help, /struc, srvsec
  ;help, /struc, layers

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_display_cap_table, ev, xlayers

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  numRows = size(xlayers, /n_dim) ? n_elements(xlayers) : 0
  if (numRows eq 0) then begin
     return
  end

  xRow  = create_struct(   'Layer',     '', $
                           'Parent',    '', $
                           'Level',     '', $
                           'Name',      '', $
                           'Title',     '')

  xRows = replicate(xRow, numrows)

  for xx = 0, numRows-1 do begin

      vNum = xLayers[xx].level
      if (xLayers[xx].level GT 0) then begin
         vLvl = strjoin(make_array(xLayers[xx].level, /string, value='>'))
         vNum =  vLvl + xLayers[xx].level
      end

      xRows[xx].Layer        = xlayers[xx].Layer
      xRows[xx].Parent       = xlayers[xx].Parent
      xRows[xx].Level        = vNum
      xRows[xx].Name         = xlayers[xx].Name
      xRows[xx].Title        = xlayers[xx].Title
  endfor

  widget_control, (*pstate).wtblResults, set_value = xRows

end
;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnGetCap_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate


  cw_ogc_wms_cap_init_properties, ev

  if ((*pstate).capFN ne '') then begin
      (*pstate).owms->setproperty, capabilities_filename = (*pstate).capFN
  endif


  ;clear the status window
  as = strarr(12)
  widget_control, (*pstate).wtblResults, set_value = as
  (*pstate).layersLoaded = 0

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  cw_ogc_wms_cap_fr_title, ev, 'x.x.x', '0'

  ; run the get cap

  schemaCk = (*pstate).schemaCk
  validationMode = (*pstate).validationMode
  cnt = (*pstate).owms->GetCapabilities(schema_check=schemaCk, validation_mode=validationMode)
  (*pstate).layersLoaded = cnt

  cw_ogc_wms_cap_display_cap, ev
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnCapFromFile_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate


  if ((*pstate).capFromFile ne '') then begin
    path=file_dirname((*pstate).capFromFile)
  endif else begin
    path=!dir
  endelse

  ;file = 'C:\ogc\filesrxd_wms\cap\wms_cap_test_all_1.3.0.xml'
  ;file = 'C:\Documents and Settings\lgenduso\.idl\itt\ogc_user_files_wms-1-100\cap_nrl_boulder.xml'

  file = dialog_pickfile(title='Pick capabilities xml file to parse', path=path, DIALOG_PARENT=ev.top)

  if (file[0] eq '') then begin
     return
  end

  cw_ogc_wms_cap_init_properties, ev

  (*pstate).capFromFile = file[0]

  ;clear the layer table
  as = strarr(12)
  widget_control, (*pstate).wtblResults, set_value = as
  (*pstate).layersLoaded = 0

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  cw_ogc_wms_cap_fr_title, ev, 'x.x.x', '0'

  ; run the get cap
  schemaCk = (*pstate).schemaCk
  validationMode = (*pstate).validationMode
  cnt = (*pstate).owms->GetCapabilities(from_file=file[0], schema_check=schemaCk, validation_mode=validationMode)
  (*pstate).layersLoaded = cnt

  cw_ogc_wms_cap_display_cap, ev
end

;;----------------------------------------------------------------------------
function cw_ogc_wms_cap_get_select_layers, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return, 0
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wms_cap_init_properties, ev

  if ((*pstate).mapFN ne '') then begin
      (*pstate).owms->setproperty, map_filename   = (*pstate).mapFN
  endif

  (*pstate).owms->setproperty, callback_function            ='cw_ogc_wms_cap_callback'
  (*pstate).owms->SetProperty, callback_data                = pstate


  ; if the table is empty return
  if ((*pstate).layersLoaded lt 1) then begin
     message, 'First run a GetCapablities request.'
     return, 0
  end

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  ; this gets all the selected cells
  ; we expect column 3 to be the name
  sel = widget_info((*pstate).wtblResults, /table_select)
  cnt = n_elements(sel)/2


  ; nothing selected.
  if (cnt le 2) then begin
    message, 'First select a layer from the table'
    return, 0
  endif


  ; count the number of unique rows that are selected
  ; sel[col,row] is the row and col of every selected cell
  numRows = 1
  lastRow = sel[1,0]
  for i=1, cnt-1 do begin
     if (lastRow ne sel[1,i]) then begin
        numRows++
        lastRow = sel[1,i]
     endif
  endfor

  ; we expect column one to be the name
  ; make a 2 by n array of the unique rows selected...[col, row]
  ; the first value in each 2 element array is 0 because expect col 3 to be the layer number column

  subsel = make_array(2, numRows, /byte)  ; an array to hold the unique values

  subsel[0,0] = sel[*,0]

  lastRow = sel[1,0]
  ri = 1

  ;filter out all the rows that repeat
  for i=1, cnt-1 do begin
     if (lastRow ne sel[1,i]) then begin
        sel[0,i] = 0
        subsel[*,ri] = sel[*,i]
        lastRow = sel[1,i]
        ri++
      endif
  endfor

  ; we expect column one to be the layer number
  ; so get the col one string values for all the selected rows
  widget_control, (*pstate).wtblResults, get_value = layerNumbersStruc, use_table_select=subsel

  names = TAG_NAMES(layerNumbersStruc)

  ; convert the structure to an array of strings
  layerNumbers = make_array(numRows, /string)
  for i=0, numrows-1 do begin
      layerNumbers[i] = layerNumbersStruc.(i)
  endfor

  return, layerNumbers

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_btnLayerInfo_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  ;widget_control, hourglass=1

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wms_cap_init_properties, ev

  if ((*pstate).mapFN ne '') then begin
      (*pstate).owms->setproperty, map_filename   = (*pstate).mapFN
  endif

  (*pstate).owms->setproperty, callback_function            ='cw_ogc_wms_cap_callback'
  (*pstate).owms->SetProperty, callback_data                = pstate


  ; if the table is empty return
  if ((*pstate).layersLoaded lt 1) then begin
     message, 'First run a GetCapablities request.'
     return
  end

  ; get the names of the selected coverages
  ; oldLayerNumbers = cw_ogc_wms_cap_get_select_layers(ev)
  ; print, 'old layer numbers =', oldLayerNumbers

  widget_control, (*pstate).wtblResults, get_value = layerNumbersStruc
  names = TAG_NAMES(layerNumbersStruc)

  ; count the number of selected rows
  numRows = 0
  numOrd = n_elements((*pstate).layerOrder)
  for x=0, numOrd-1 do begin
     if ((*pstate).layerOrder[x] ne -1) then begin
        numRows++
     endif
  endfor

  ; get the layerNumbers for the selected rows
  layerNumbers = make_array(numRows, /string)
  for i=0, numRows-1 do begin
     row = (*pstate).layerOrder[i]
     layerNumbers[i] = layerNumbersStruc[row].layer
  endfor

  ;print, 'layerNumbers = ', layerNumbers

  ; did we end up with some layers
  num = n_elements(layerNumbers)
  if (num eq 0) then begin
     return
  endif

  ; invoke the layer dialog
  (*pstate).coGetMapIdArr[(*pstate).coGetMapIdArrIdx++] = ogc_wms_map(ev.top, (*pstate).owms, layerNumbers)

end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_refresh, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', dialog_parent=cwBase, /error)
    return
  endif


  wState = widget_info(id, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  num = widget_info((*pstate).wcbServer, /combobox_number)
  if (num ne 0) then begin
    for ii=num, 0, -1 do begin
      widget_control, (*pstate).wcbServer, combobox_deleteitem = ii
    endfor
  endif

  ; this reloads the (*pstate).xxxx config vars with the current contents of the config file
  prefsFile = ogc_wms_getConfigInfo(id, 'capstatebase')

  if (size(*(*pstate).paxServers, /type) ne 8) then begin
     return
  endif


  count = n_elements(*(*pstate).paxServers)
  for xx = 0, count-1 do begin
     widget_control, (*pstate).wcbServer, combobox_additem = (*(*pstate).paxServers)[xx].SvrName
  endfor

  ; select the correct sln for this ae
  match = -1
  widget_control, (*pstate).wcbServer, get_value = srvstrs
  cnt = n_elements(srvstrs)

  for ii=0, cnt-1 do begin
    if ((*pstate).covServer eq srvstrs[ii])then begin
      match = ii
      break
    endif
  endfor

  if (match ne -1) then begin
    widget_control, (*pstate).wcbServer, SET_COMBOBOX_SELECT=match
  endif
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_kill_event, id
  compile_opt idl2
  catch, errorStatus            ; catch all errors and display an error dialog

  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    return
  endif

  ; called when the main ui is destroyed we let go of objects and pointers

  widget_control, id, get_uvalue = pstate

  ; close any map windows
  for ix=0, n_elements((*pstate).coGetMapIdArr)-1 do begin
      if ((*pstate).coGetMapIdArr[ix] ne 0) then begin
        valid_widget = widget_info((*pstate).coGetMapIdArr[ix], /valid)
        if (valid_widget)then begin
            widget_control, (*pstate).coGetMapIdArr[ix], /destroy
        endif
      endif
  endfor

  ; close any iImage windows
  for ix=0, n_elements((*pstate).coitIdArr)-1 do begin
      if ((*pstate).coitIdArr[ix] ne '') then begin
         itdelete, (*pstate).coitIdArr[ix]
      endif
  endfor

  if ptr_valid(pstate) then begin
    obj_destroy, (*pstate).owms
    ptr_free, (*pstate).paxservers
    ptr_free, pstate
  endif

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_cap_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(id, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  ; get the number of visible lines in the status text window
  winfowtxtStatus = widget_info((*pstate).wtxtStatus,/geometry)

  (*pstate).statusLines = winfowtxtStatus.ysize - 2

  if (size(*(*pstate).paxServers, /type) ne 8) then begin
     return
  endif

  count = n_elements(*(*pstate).paxServers)
  for xx = 0, count-1 do begin
     widget_control, (*pstate).wcbServer, combobox_additem = (*(*pstate).paxServers)[xx].SvrName
  endfor


  match = -1
  widget_control, (*pstate).wcbServer, get_value = srvstrs
  cnt = n_elements(srvstrs)

  for ii=0, cnt-1 do begin
    if ((*pstate).covServer eq srvstrs[ii])then begin
      match = ii
      break
    endif
  endfor

  if (match ne -1) then begin
    widget_control, (*pstate).wcbServer, SET_COMBOBOX_SELECT=match
  endif

end

;;----------------------------------------------------------------------------
function cw_ogc_wms_cap, parent
  compile_opt idl2
  on_error, 2

  size_of_x = 760

  wBase             = widget_base(parent, /COLUMN, PRO_SET_VALUE='cw_ogc_wms_cap_set_value', TITLE='cw_ogc_wms_cap', $
                                    NOTIFY_REALIZE='cw_ogc_wms_cap_realize_notify_event', space=5)

  wBaseState        = widget_base(wBase, uname='capstatebase', kill_notify='cw_ogc_wms_cap_kill_event')

  wBaseTmr          = widget_base(wBase, map=0, xsize=1, ysize=1)
  wTmr              = widget_button(wBaseTmr, event_pro='cw_ogc_wms_cap_PageScroll_event')

  ; add the get cap frame ------------------------
  wbaseGetCap       = widget_base(wBase)
  wLblGetCap        = widget_label(wbaseGetCap, value=' Get Capabilities ', xoffset=5)
  winfoLblGetCap    = widget_info(wLblGetCap, /geometry)
  wbaseFrGetCap     = widget_base(wbaseGetCap, /frame, yoffset=winfoLblGetCap.ysize/2, /row, space=10, ypad=5, xpad=10)
  wLblGetCap        = widget_label(wbaseGetCap, value=' Get Capabilities ', xoffset=5)
  wlblServer        = widget_label(wbaseFrGetCap, value = 'Remote WMS Server', xsize = 105)
  wcbServer         = widget_combobox(wbaseFrGetCap, xsize=185, event_pro='cw_ogc_wms_cap_cbServer_event')
  wbtnGetCap        = widget_button(wbaseFrGetCap, value='Get Capabilities', event_pro='cw_ogc_wms_cap_btnGetCap_event')
  wbtnCancelCap     = widget_button(wbaseFrGetCap, xsize=60, value='Cancel')
  wbtnCapFromFile   = widget_button(wbaseFrGetCap, value=' Get Capabilities From Existing File', event_pro='cw_ogc_wms_cap_btnCapFromFile_event')


  ;;add the results frame -----------------------------
  ;wbaseResultC      = widget_base(wBase, /col)
  wbaseResult       = widget_base(wbase)
  wLblResult        = widget_label(wbaseResult, value=' Capabilities ', xoffset=5)
  winfoLblResult    = widget_info(wLblResult, /geometry)
  wbaseFrResult     = widget_base(wbaseResult, /frame, yoffset=winfoLblResult.ysize/2, /col, space=5, ypad=5, xpad=10)
  wLblResultx       = widget_label(wbaseResult, value=' Capabilities ', xoffset=5)
  wRow              = widget_base(wbaseFrResult, /row)
  tblRows           = 10
  vColWidths        = [ 40,      40,     60,     285,     285]
  vColNames         = ['Layer', 'Parent', 'Level', 'Name', 'Title']
  wtblResults       = widget_table(wRow, UNAME='TBL_RESULTS', xsize=5, ysize=tblRows, /resizeable_columns, $
                                    event_pro='cw_ogc_wms_cap_table_results_event', /row_major, /no_row_headers, $
                                    column_labels=vColNames, column_widths=vColWidths, /all_events,  /disjoint_selection)

  wRow              = widget_base(wbaseFrResult, /row)
  wbtnHome          = widget_button(wRow, xsize=100, value='Home',        event_pro='cw_ogc_wms_cap_btnHome_event')
  wbtnPgUp          = widget_button(wRow, xsize=100, value='Page Up',     /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wms_cap_btnPgUp_event')
  wbtnScrUp         = widget_button(wRow, xsize=100, value='Scroll Up',   /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wms_cap_btnScrUp_event')
  wbtnScrDn         = widget_button(wRow, xsize=100, value='Scroll Down', /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wms_cap_btnScrDn_event')
  wbtnPgDn          = widget_button(wRow, xsize=100, value='Page Down',   /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wms_cap_btnPgDn_event')
  wbtnEnd           = widget_button(wRow, xsize=100, value='End',         event_pro='cw_ogc_wms_cap_btnEnd_event')

  wRow2             = widget_base(wbaseFrResult, /row)
  wbtnLayerInfo     = widget_button(wRow2, value='Layer Info', event_pro='cw_ogc_wms_cap_btnLayerInfo_event')
  wLbl              = widget_label(wRow2, value='                             ', xoffset=5)
  wLbl              = widget_label(wRow2, value=' Multiple Layers can be selected.  Select bottom most layer first.', xoffset=50)



  ;;add the status frame -------------------------------
  wbaseStatus       = widget_base(wBase)
  wlblStatus        = widget_label(wbaseStatus, value=' Status ', xoffset=5)
  winfolblStatus    = widget_info(wlblStatus, /geometry)
  wbaseFrStatus     = widget_base(wbaseStatus, /frame, yoffset=winfolblStatus.ysize/2, /row, space=20, ypad=5, xpad=10)
  wlblStatus        = widget_label(wbaseStatus, value=' Status ', xoffset=5)
  wtxtStatus        = widget_text(wbaseFrStatus, value='', /scroll, UNAME='TXT_STATUS', font='Courier New*14', ysize=12, scr_xsize=size_of_x-30)


  widget_control, wbaseFrGetCap, xsize=size_of_x
  widget_control, wbaseFrResult, xsize=size_of_x
  widget_control, wbaseFrStatus, xsize=size_of_x

  coGetMapIdArr    = make_array(256, /uint, value=0)
  coGetMapIdArrIdx = byte(0) ; by design this index will wrap back to 0 after 256 windows

  ; create a config object
  owms = obj_new('IDLnetOgcWms')

  ; set in ogc_wms::cw_ogc_wms_OpenTiff
  coitIdArr    = make_array(256, /string, value='')
  coitIdArrIdx = byte(0) ; by design this index will wrap back to 0 after 256 windows

  layerOrder    = make_array(10, /int, value=-1)
  layerOrder[0] = 0

  state = { owms:owms, layerIndex:0, tblRows:tblRows, scrollUp:0, statusLines:0, mouseState:0, wTmr:wTmr, $
            tmrPeriod:0.5, tmrEvCnt:0, pageScrlInc:1, coGetMapIdArr:coGetMapIdArr, coGetMapIdArrIdx:0, layersLoaded:0, $
            coitIdArr:coitIdArr, coitIdArrIdx:coitIdArrIdx, layerOrder:layerOrder, $
            wbaseGetCap:wbaseGetCap,  wtblResults:wtblResults, wtxtStatus:wtxtStatus, $
            wcbServer:wcbServer, wbtnCancelCap:wbtnCancelCap, wLblResult:wLblResult, $
            parent:parent, prefsFile:'', paxServers:ptr_new(0), covServer:'', schemaCk:0, $
            capFN:'', mapFN:'', featFN:'', capFromFile:'', $
            displayHttp:1, rxtxTo:'1800', connectTo:'1800', proxy:'', proxyPort:'', verbose:0, $
            usr:'', pwd:'', proxyusr:'', proxypwd:'', encoding:0, validationMode:0 }

  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wBaseState, set_uvalue=pstate

  ;this will set paxServers if the .sav file exists and has some remote server entries
  (*pstate).prefsFile = ogc_wms_getConfigInfo(wBase, 'capstatebase')

  return, wBase

end
