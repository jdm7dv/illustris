
;;----------------------------------------------------------------------------
pro ogc_wms_map_btnClose_event, ev
  compile_opt idl2, hidden
  on_error, 2

  ;; make the ui go away
  widget_control, ev.top, /destroy
end

;;----------------------------------------------------------------------------
pro ogc_wms_map_event, ev
  compile_opt idl2, hidden

  ;; fake a button close event
  IF TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN $
    ogc_wms_map_btnClose_event, ev
end

;;----------------------------------------------------------------------------
function ogc_wms_map, parent, owms, layerNames

  compile_opt idl2
  on_error, 2

  ; the errors caught in the compound widget's main init routine bubble up to this level.
  ; if there is an error it is displayed and this dialog exits

  catch, errorStatus
  if (errorStatus ne 0) then begin
    catch,/cancel
    r = dialog_message(!error_state.msg, title='IDL OGC WMS Error', dialog_parent=cwBase, /error)
    return, 0
  endif

  ; root level widget for this ui
  cwBase = widget_base(/column, TITLE='IDL OGC WMS Browser Map', uname='ui_ogc_wms_map', xoffset=300, yoffset=0)

  wTab = widget_tab(cwBase)

  ; create the tabs
  wTab1 = widget_base(wTab, title='      Layer Offering       ',/row, uname='ui_ogc_wms_map_tab1', uvalue=cwBase)
  wTab2 = widget_base(wTab, title='      Layer Details        ',/row, uname='ui_ogc_wms_map_tab2', uvalue=cwBase)

  cw_ogc_wms_map_tab1, wTab1, wTab2, owms, layerNames
  cw_ogc_wms_map_tab2, wTab2, owms, layerNames

  ; add the close button to the tab container
  wRow = widget_base(cwBase, /row, /align_right, space=5)
  wbtnClose = widget_button(wRow, value='Close', xsize = 100, event_pro = 'ogc_wms_map_btnClose_event')

  ; draw the ui
  widget_control, cwBase, /real

  ; load tabs with data from the cap xml file
  cw_ogc_wms_map_tab1_load_layer, wTab1
  cw_ogc_wms_map_tab2_load_layer, wTab2

  return, cwBase
end