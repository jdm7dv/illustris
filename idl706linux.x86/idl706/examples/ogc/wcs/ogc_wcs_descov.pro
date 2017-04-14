
;;----------------------------------------------------------------------------
pro ogc_wcs_descov_btnClose_event, ev
  compile_opt idl2, hidden
  on_error, 2

  ;; make the ui go away
  widget_control, ev.top, /destroy
end

;;----------------------------------------------------------------------------
pro ogc_wcs_descov_event, ev
  compile_opt idl2, hidden

  ;; fake a button close event
  IF TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN $
    ogc_wcs_descov_btnClose_event, ev
end

;;----------------------------------------------------------------------------
function ogc_wcs_descov, parent, owcs, covNames, fromFile

  compile_opt idl2
  on_error, 2

  ; the errors caught in the compound widget's main init routine bubble up to this level.
  ; if there is an error it is displayed and this dialog exits

  catch, errorStatus
  if (errorStatus ne 0) then begin
    catch,/cancel
    r = dialog_message(!error_state.msg, title='IDL OGC WCS Error', dialog_parent=cwBase, /error)
    return, 0
  endif

  ; root level widget for this ui
  cwBase = widget_base(/column, TITLE='IDL OGC WCS Browser Describe Coverage', uname='ui_ogc_wcs_descov', xoffset=300, yoffset=0)

  wTab = widget_tab(cwBase)

  ; create the tabs
  wTab1 = widget_base(wTab, title='      Coverage Offering       ',/row, uname='ui_ogc_wcs_descov_tab_1', uvalue=cwBase)
  wTab2 = widget_base(wTab, title='  Coverage Offering Continued ',/row, uname='ui_ogc_wcs_descov_tab_2', uvalue=cwBase)
  wTab3 = widget_base(wTab, title='  Coverage Offering Continued ',/row, uname='ui_ogc_wcs_descov_tab_3', uvalue=cwBase)
  cw_ogc_wcs_descov_tab1, wTab1, wTab2, wTab3, owcs, covNames, fromFile
  cw_ogc_wcs_descov_tab2, wTab2
  cw_ogc_wcs_descov_tab3, wTab3

  ; add the close button to the tab container
  wRow = widget_base(cwBase, /row, /align_right, space=5)
  wbtnClose = widget_button(wRow, value='Close', xsize = 100, event_pro = 'ogc_wcs_descov_btnClose_event')

  ; draw the ui
  widget_control, cwBase, /real

  ; load both tabs with data from the describe coverage xml file
  cw_ogc_wcs_descov_tab1_get, wTab1, fromFile

  return, cwBase
end