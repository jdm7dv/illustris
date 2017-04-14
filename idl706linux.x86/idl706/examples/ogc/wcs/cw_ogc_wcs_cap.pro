


;;----------------------------------------------------------------------------
function cw_ogc_wcs_cap_callback, status, progress, data
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
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

  retVal = 1
  if (wevCap.id EQ (*data).wbtnCancelCap) then begin
    retVal = 0
  endif

;  if (progress[0]) then begin
;     print, progress
;  endif

  ;widget_control, hourglass=1
  ;print, 'retVal = ', retVal
  return, retVal
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_PageScroll_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        (*pstate).mouseState = 0
        (*pstate).tmrEvCnt = 0
        (*pstate).tmrPeriod = 0.5
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate


  rows  = (*pstate).tblRows
  totCOBs = (*pstate).briefsLoaded

  if (totCOBS le rows) then begin
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

      if (totCOBs gt rows) then begin
         if ((*pstate).scrollUp eq 0) then begin  ; scroll down
            if ((*pstate).cobIndex lt totCOBs) then begin


               (*pstate).cobIndex = (*pstate).cobIndex + (*pstate).pageScrlInc

               idx   = (*pstate).cobIndex
               skip  = idx-rows
               if (skip gt (totCOBs - rows)) then begin
                  skip = totCOBs - rows
                  ;(*pstate).cobIndex = totCOBs-rows
                  (*pstate).cobIndex = totCOBs
               endif

               res   = (*pstate).owcs->GetCoverageOfferingBriefs(index=skip, number=rows)
               cw_ogc_wcs_cap_display_cap_table, ev, res

             endif
         endif else begin  ; scroll up
            if ((*pstate).cobIndex gt rows) then begin


               (*pstate).cobIndex =  (*pstate).cobIndex - (*pstate).pageScrlInc

               idx   = (*pstate).cobIndex
               skip  = idx-rows

               if (skip lt 0) then begin
                  skip = 0
                  (*pstate).cobIndex = rows
               endif

               res   = (*pstate).owcs->GetCoverageOfferingBriefs(index=skip, number=rows)
               cw_ogc_wcs_cap_display_cap_table, ev, res

             endif
         endelse
      endif
  endif
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnScrDn_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 0
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = 1
  cw_ogc_wcs_cap_PageScroll_event, ev

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnScrUp_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 1
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = 1
  cw_ogc_wcs_cap_PageScroll_event, ev
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnPgDn_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 0
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = (*pstate).tblRows
  cw_ogc_wcs_cap_PageScroll_event, ev

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnPgUp_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).scrollUp = 1
  (*pstate).mouseState = ev.select
  (*pstate).pageScrlInc = (*pstate).tblRows
  cw_ogc_wcs_cap_PageScroll_event, ev
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnHome_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  rows  = (*pstate).tblRows
  res   = (*pstate).owcs->GetCoverageOfferingBriefs(index=0, number=rows)

  cw_ogc_wcs_cap_display_cap_table, ev, res
  (*pstate).cobIndex = rows
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnEnd_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  rows  = (*pstate).tblRows
  totCOBs = (*pstate).briefsLoaded

  if (totCOBS le rows) then begin
     return
  endif

  res   = (*pstate).owcs->GetCoverageOfferingBriefs(index=totCOBs-rows, number=rows)
  cw_ogc_wcs_cap_display_cap_table, ev, res
  (*pstate).cobIndex = totCOBs
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_cbServer_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  svrName = widget_info((*pstate).wcbServer, /combobox_gettext)
  (*pstate).covServer = svrName
  ogc_wcs_SaveValuesAndNotify, ev.top, 'capstatebase'
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_table_results_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  ; if the table is empty return
  if ((*pstate).briefsLoaded lt 1) then begin
     return
  end

  ; when a cell is selected highlight the whole row
  if (ev.type eq 4) then begin

    ; determine which row was selected
    sel = widget_info(ev.id, /table_select)

    cnt = n_elements(sel)/2

    if (cnt le 0) then begin
       return
    endif

    if (cnt eq 1) then begin
        sel[0] = -1
    endif else begin
       for i=0, cnt-1 do begin
          sel[0,i] = -1
       endfor
    endelse

    widget_control, ev.id, set_table_select=sel
    widget_control, ev.id, set_table_view=[0,0]

  endif

  ; when a cell is unselected unhighlight the whole row
  if (ev.type eq 9) then begin

    ; determine which row was selected
    sel = widget_info(ev.id, /table_select)

    cnt = n_elements(sel)/2

; todo code the deselection of the entire row
; this means removing all the cells for the deselected row from the sel array
;    if (cnt le 0) then begin
;       return
;    endif
;
;    if (cnt eq 1) then begin
;        sel[0] = -1
;    endif else begin
;       for i=0, cnt-1 do begin
;          sel[0,i] = -1
;       endfor
;    endelse
;
;    widget_control, ev.id, set_table_select=sel
;    widget_control, ev.id, set_table_view=[0,0]

  endif
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_init_properties, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
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
    r = dialog_message('Unable to locate server properties', title='OGC WCS Error', /error)
  endif

  (*pstate).owcs->setproperty, url_scheme            = (*(*pstate).paxServers)[xx].Scheme
  (*pstate).owcs->setproperty, url_host              = (*(*pstate).paxServers)[xx].Host
  (*pstate).owcs->setproperty, url_path              = (*(*pstate).paxServers)[xx].Path
  (*pstate).owcs->setproperty, url_port              = (*(*pstate).paxServers)[xx].Port
  (*pstate).owcs->setproperty, url_query_prefix      = (*(*pstate).paxServers)[xx].QueryPrefix
  (*pstate).owcs->setproperty, url_query_suffix      = (*(*pstate).paxServers)[xx].QuerySuffix
  (*pstate).owcs->setproperty, wcs_version           = (*(*pstate).paxServers)[xx].wcsver
  (*pstate).owcs->setproperty, callback_function     ='cw_ogc_wcs_cap_callback'
  (*pstate).owcs->SetProperty, callback_data         = pstate
  (*pstate).owcs->setproperty, timeout               = (*pstate).rxtxTo
  (*pstate).owcs->setproperty, connect_timeout       = (*pstate).connectTo
  (*pstate).owcs->setproperty, proxy_hostname        = (*pstate).proxy
  (*pstate).owcs->setproperty, proxy_Port            = (*pstate).proxyPort
  (*pstate).owcs->setproperty, verbose               = (*pstate).verbose
  (*pstate).owcs->setproperty, username              = (*pstate).usr
  (*pstate).owcs->setproperty, password              = (*pstate).pwd
  (*pstate).owcs->setproperty, proxy_username        = (*pstate).proxyusr
  (*pstate).owcs->setproperty, proxy_password        = (*pstate).proxypwd
  (*pstate).owcs->setproperty, encode                = (*pstate).encoding

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_cob_fr_title, ev, ver, cnt

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  val = ' Coverage Offering Briefs     Version = ' + strtrim(string(ver), 2) + '    Count = ' + strtrim(string(cnt), 2) + '  '
  info = widget_info((*pstate).wLblResult, string_size= val)
  widget_control, (*pstate).wLblResult, xsize=info[0], set_value = val

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_display_cap, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  rows = (*pstate).tblRows
  cobs = (*pstate).owcs->GetCoverageOfferingBriefs(count= cnt, number=rows)

  if (cnt lt 1) then begin
    message, "No Coverage Offering Briefs are available"
    return
  endif

  cw_ogc_wcs_cap_cob_fr_title, ev, cobs[0].version, (*pstate).briefsLoaded

  ; display the results in results table
  cw_ogc_wcs_cap_display_cap_table, ev, cobs
  (*pstate).cobIndex = rows
  widget_control, (*pstate).wtblResults, set_table_select=[-1,0]

  ;srvsec = (*pstate).owcs->GetCapServiceSection()
  ;help, /struc, srvsec
  ;help, /struc, cobs

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_display_cap_table, ev, xCobs

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  ; since the returned cob struc has an array of strings we must create a new struc
  ; with the elements that are to be displayed in the cob table

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  numRows = size(xCobs, /n_dim) ? n_elements(xCobs) : 0
  if (numRows eq 0) then begin
     return
  end

  xRow  = create_struct(   'Index',     '', $
                           'Name',      '', $
                           'Label',     '', $
                           'SRS_Name',  '', $
                           'Pos1',      '', $
                           'Dims1',     '', $
                           'Pos2',      '', $
                           'Dims2',     '', $
                           'Tm_Pos1',   '', $
                           'Tm_Pos2',   '' )

  xRows = replicate(xRow, numrows)

  for xx = 0, numRows-1 do begin
      xRows[xx].Index       = xCobs[xx].Index
      xRows[xx].Name        = xCobs[xx].Name
      xRows[xx].Label       = xCobs[xx].Label
      xRows[xx].SRS_Name    = xCobs[xx].SRS_Name
      xRows[xx].Pos1        = xCobs[xx].Pos1
      xRows[xx].Dims1       = xCobs[xx].Dims1
      xRows[xx].Pos2        = xCobs[xx].Pos2
      xRows[xx].Dims2       = xCobs[xx].Dims2
      xRows[xx].Tm_Pos1     = xCobs[xx].Tm_Pos1
      xRows[xx].Tm_Pos2     = xCobs[xx].Tm_Pos2
  endfor

  widget_control, (*pstate).wtblResults, set_value = xRows

end
;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnGetCap_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif


  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate


  cw_ogc_wcs_cap_init_properties, ev

  if ((*pstate).capFN ne '') then begin
      (*pstate).owcs->setproperty, capabilities_filename = (*pstate).capFN
  endif


  ;clear the status window
  as = strarr(12)
  widget_control, (*pstate).wtblResults, set_value = as
  (*pstate).briefsLoaded = 0

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  cw_ogc_wcs_cap_cob_fr_title, ev, 'x.x.x', '0'

  ; run the get cap

  schemaCk = (*pstate).schemaCk
  validationMode = (*pstate).validationMode
  cnt = (*pstate).owcs->GetCapabilities(schema_check=schemaCk, validation_mode=validationMode)
  (*pstate).briefsLoaded = cnt

  cw_ogc_wcs_cap_display_cap, ev
end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnCapFromFile_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
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

  file = dialog_pickfile(title='Pick capabilities xml file to parse', path=path, DIALOG_PARENT=ev.top)

  if (file[0] eq '') then begin
     return
  end

  cw_ogc_wcs_cap_init_properties, ev

  (*pstate).capFromFile = file[0]

  ;clear the cob table
  as = strarr(12)
  widget_control, (*pstate).wtblResults, set_value = as
  (*pstate).briefsLoaded = 0

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  cw_ogc_wcs_cap_cob_fr_title, ev, 'x.x.x', '0'

  ; run the get cap
  schemaCk = (*pstate).schemaCk
  validationMode = (*pstate).validationMode
  cnt = (*pstate).owcs->GetCapabilities(from_file=file[0], schema_check=schemaCk, validation_mode=validationMode)
  (*pstate).briefsLoaded = cnt

  cw_ogc_wcs_cap_display_cap, ev
end

;;----------------------------------------------------------------------------
function cw_ogc_wcs_cap_DesCov, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return, 0
    endif

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_cap_init_properties, ev

  if ((*pstate).desCovFN ne '') then begin
      (*pstate).owcs->setproperty, describe_coverage_filename   = (*pstate).desCovFN
  endif

  (*pstate).owcs->setproperty, callback_function            ='cw_ogc_wcs_cap_callback'
  (*pstate).owcs->SetProperty, callback_data                = pstate


  ; if the table is empty return
  if ((*pstate).briefsLoaded lt 1) then begin
     message, 'First run a GetCapablities request.'
     return, 0
  end

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  ; this gets all the selected cells
  ; we expect column one to be the name
  sel = widget_info((*pstate).wtblResults, /table_select)
  cnt = n_elements(sel)/2


  ; nothing selected.
  if (cnt le 2) then begin
    message, 'First select a coverage offering brief from the table'
    return, 0
  endif


  ; count the number of unique rows that are selected
  ; sel[row,col] is the row and col of every selected cell
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
  ; the first value in each 2 element array is 1 because expect col 1 to be the coverage name column


  subsel = make_array(2, numRows, /byte)  ; an array to hold the unique values
  subsel[0,0] = sel[*,1]
  lastRow = sel[1,0]
  ri = 1

  ;filter out all the rows that repeat
  for i=1, cnt-1 do begin
     if (lastRow ne sel[1,i]) then begin
        sel[0,i] = 1
        subsel[*,ri] = sel[*,i]
        lastRow = sel[1,i]
        ri++
      endif
  endfor

  ; we expect column one to be the coverage name
  ; so get the col one string values for all the selected rows
  widget_control, (*pstate).wtblResults, get_value = covNamesStruc, use_table_select=subsel

  names = TAG_NAMES(covNamesStruc)

  ; convert the structure to an array of strings
  covNames = make_array(numRows, /string)
  for i=0, numrows-1 do begin
      covNames[i] = covNamesStruc.(i)
  endfor

  return, covNames

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnDesCov_event, ev

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
        print, !error_state.msg
        return
    endif

  ;widget_control, hourglass=1

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  ; get the names of the selected coverages
  covNames = cw_ogc_wcs_cap_DesCov(ev)

  ; see if a string or string array was returned
  res = size(covNames, /type)
  if (res ne 7) then begin
     return
  endif

  ; invoke the coverage offering dialog
  (*pstate).coDesCovIdArr[(*pstate).coDesCovIdArrIdx++] = ogc_wcs_descov(ev.top, (*pstate).owcs, covNames, '')

end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_btnDesCovFromFile_event, ev

  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WCS Error', /error)
     print, !error_state.msg
     return
  endif

  ;widget_control, hourglass=1

  wState = widget_info(ev.top, find_by_uname='capstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wcs_cap_init_properties, ev

  if ((*pstate).desCovFromFile ne '') then begin
    path=file_dirname((*pstate).desCovFromFile)
  endif else begin
    path=!dir
  endelse


  file = dialog_pickfile(title='Pick capabilities xml file to parse', path=path, DIALOG_PARENT=ev.top)

  if (file[0] eq '') then begin
     return
  end

  (*pstate).owcs->setproperty, callback_function     ='cw_ogc_wcs_cap_callback'
  (*pstate).owcs->SetProperty, callback_data         = pstate

  (*pstate).desCovFromFile = file[0]

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  ;ogc_wcs_SaveValuesAndNotify, ev.top, 'capstatebase'

  ; invoke the coverage offering dialog
  (*pstate).coDesCovIdArr[(*pstate).coDesCovIdArrIdx++] = ogc_wcs_descov(ev.top, (*pstate).owcs, '', file[0])
end


;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_refresh, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
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
  prefsFile = ogc_wcs_getConfigInfo(id, 'capstatebase')

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
pro cw_ogc_wcs_cap_kill_event, id
  compile_opt idl2
  catch, errorStatus            ; catch all errors and display an error dialog

  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    return
  endif

  ; called when the main ui is destroyed we let go of objects and pointers

  widget_control, id, get_uvalue = pstate

  ; close any descov windows
  for ix=0, n_elements((*pstate).coDesCovIdArr)-1 do begin
      if ((*pstate).coDesCovIdArr[ix] ne 0) then begin
        valid_widget = widget_info((*pstate).coDesCovIdArr[ix], /valid)
        if (valid_widget)then begin
            widget_control, (*pstate).coDesCovIdArr[ix], /destroy
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
    obj_destroy, (*pstate).owcs
    ptr_free, (*pstate).paxservers
    ptr_free, pstate
  endif

end

;;----------------------------------------------------------------------------
pro cw_ogc_wcs_cap_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WCS Error', dialog_parent=cwBase, /error)
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
function cw_ogc_wcs_cap, parent
  compile_opt idl2
  on_error, 2

  size_of_x = 860

  wBase             = widget_base(parent, /COLUMN, PRO_SET_VALUE='cw_ogc_wcs_cap_set_value', TITLE='cw_ogc_wcs_cov', $
                                    NOTIFY_REALIZE='cw_ogc_wcs_cap_realize_notify_event', space=5)

  wBaseState        = widget_base(wBase, uname='capstatebase', kill_notify='cw_ogc_wcs_cap_kill_event')

  wBaseTmr          = widget_base(wBase, map=0, xsize=1, ysize=1)
  wTmr              = widget_button(wBaseTmr, event_pro='cw_ogc_wcs_cap_PageScroll_event')

  ; add the get cap frame ------------------------
  wbaseGetCap       = widget_base(wBase)
  wLblGetCap        = widget_label(wbaseGetCap, value=' Get Capabilities ', xoffset=5)
  winfoLblGetCap    = widget_info(wLblGetCap, /geometry)
  wbaseFrGetCap     = widget_base(wbaseGetCap, /frame, yoffset=winfoLblGetCap.ysize/2, /row, space=10, ypad=5, xpad=10)
  wLblGetCap        = widget_label(wbaseGetCap, value=' Get Capabilities ', xoffset=5)
  wlblServer        = widget_label(wbaseFrGetCap, value = 'Remote WCS Server', xsize = 105)
  wcbServer         = widget_combobox(wbaseFrGetCap, xsize=185, event_pro='cw_ogc_wcs_cap_cbServer_event')
  wbtnGetCap        = widget_button(wbaseFrGetCap, value='Get Capabilities', event_pro='cw_ogc_wcs_cap_btnGetCap_event')
  wbtnCancelCap     = widget_button(wbaseFrGetCap, xsize=60, value='Cancel')
  wbtnCapFromFile   = widget_button(wbaseFrGetCap, value=' Get Capabilities From Existing File', event_pro='cw_ogc_wcs_cap_btnCapFromFile_event')


  ;;add the results frame -----------------------------
  ;wbaseResultC      = widget_base(wBase, /col)
  wbaseResult       = widget_base(wbase)
  wLblResult        = widget_label(wbaseResult, value=' Coverage Offering Briefs ', xoffset=5)
  winfoLblResult    = widget_info(wLblResult, /geometry)
  wbaseFrResult     = widget_base(wbaseResult, /frame, yoffset=winfoLblResult.ysize/2, /col, space=5, ypad=5, xpad=10)
  wLblResultx       = widget_label(wbaseResult, value=' Coverage Offering Briefs ', xoffset=5)
  wRow              = widget_base(wbaseFrResult, /row)
  tblRows           = 10
  vColWidths        = [ 40,      180,    250,    80,         150,    40,      150,    40,      100,       100]
  vColNames         = ['Index', 'Name', 'Label', 'SRS Name', 'Pos1', 'Dims1', 'Pos2', 'Dims2', 'Tm Pos1', 'Tm Pos2']
  wtblResults       = widget_table(wRow, UNAME='TBL_RESULTS', xsize=10, ysize=tblRows, /resizeable_columns, $
                                    event_pro='cw_ogc_wcs_cap_table_results_event', /row_major, /no_row_headers, $
                                    column_labels=vColNames, column_widths=vColWidths, /all_events,  /disjoint_selection)

  wRow              = widget_base(wbaseFrResult, /row)
  wbtnHome          = widget_button(wRow, xsize=100, value='Home',        event_pro='cw_ogc_wcs_cap_btnHome_event')
  wbtnPgUp          = widget_button(wRow, xsize=100, value='Page Up',     /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wcs_cap_btnPgUp_event')
  wbtnScrUp         = widget_button(wRow, xsize=100, value='Scroll Up',   /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wcs_cap_btnScrUp_event')
  wbtnScrDn         = widget_button(wRow, xsize=100, value='Scroll Down', /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wcs_cap_btnScrDn_event')
  wbtnPgDn          = widget_button(wRow, xsize=100, value='Page Down',   /PUSHBUTTON_EVENTS, event_pro='cw_ogc_wcs_cap_btnPgDn_event')
  wbtnEnd           = widget_button(wRow, xsize=100, value='End',         event_pro='cw_ogc_wcs_cap_btnEnd_event')

  wRow2             = widget_base(wbaseFrResult, /row)
  wbtnDesCov        = widget_button(wRow2, value='Describe Coverage', event_pro='cw_ogc_wcs_cap_btnDesCov_event')
  wbtnDesCovFromFile= widget_button(wRow2, value='Describe Coverage From File', event_pro='cw_ogc_wcs_cap_btnDesCovFromFile_event')


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

  coDesCovIdArr    = make_array(256, /uint, value=0)
  coDesCovIdArrIdx = byte(0) ; by design this index will wrap back to 0 after 256 windows

  ; create a config object
  owcs = obj_new('IDLnetOgcWcs')

  ; set in ogc_wcs::cw_ogc_wcs_OpenTiff
  coitIdArr    = make_array(256, /string, value='')
  coitIdArrIdx = byte(0) ; by design this index will wrap back to 0 after 256 windows

  state = { owcs:owcs, cobIndex:0, tblRows:tblRows, scrollUp:0, statusLines:0, mouseState:0, wTmr:wTmr, $
            tmrPeriod:0.5, tmrEvCnt:0, pageScrlInc:1, coDesCovIdArr:coDesCovIdArr, coDesCovIdArrIdx:0, briefsLoaded:0, $
            coitIdArr:coitIdArr, coitIdArrIdx:coitIdArrIdx, $
            wbaseGetCap:wbaseGetCap,  wtblResults:wtblResults, wtxtStatus:wtxtStatus, $
            wcbServer:wcbServer, wbtnCancelCap:wbtnCancelCap, wLblResult:wLblResult, $
            parent:parent, prefsFile:'', paxServers:ptr_new(0), covServer:'', schemaCk:0, $
            capFN:'', desCovFN:'', covFN:'', capFromFile:'', $
            desCovFromFile:'', displayHttp:1, rxtxTo:'1800', connectTo:'1800', proxy:'', proxyPort:'', verbose:0, $
            usr:'', pwd:'', proxyusr:'', proxypwd:'', encoding:0, validationMode:0 }

  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wBaseState, set_uvalue=pstate

  ;this will set paxServers if the .sav file exists and has some remote server entries
  (*pstate).prefsFile = ogc_wcs_getConfigInfo(wBase, 'capstatebase')

  return, wBase

end
