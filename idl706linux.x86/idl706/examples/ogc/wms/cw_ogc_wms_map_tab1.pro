
;;----------------------------------------------------------------------------
function cw_ogc_wms_map_construct_bbox_string, minx, miny, maxx, maxy

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return, ''
    endif

    bbox = ''

    ;; this code just converts values with exponents to long strings

    if (strpos(minx, 'e') eq -1) then begin
       bbox = minx
    endif else begin
       bbox = strtrim(long(double(minx)),2)
    endelse

    if (strpos(miny, 'e') eq -1) then begin
       bbox = bbox + ', ' + miny
    endif else begin
       bbox = bbox + ', ' + strtrim(long(double(miny)),2)
    endelse

    if (strpos(maxx, 'e') eq -1) then begin
       bbox = bbox + ', ' + maxx
    endif else begin
       bbox = bbox + ', ' + strtrim(long(double(maxx)),2)
    endelse

    if (strpos(maxy, 'e') eq -1) then begin
       bbox = bbox + ', ' + maxy
    endif else begin
       bbox = bbox + ', ' + strtrim(long(double(maxy)),2)
    endelse

    return, bbox

end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_load_layer, id

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(id, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  widget_control, (*pstate).wtxtStatus, set_value=''

  widget_control, (*pstate).wtxtLayerName,           set_value = "Loading."

  numbers       = (*pstate).layerNumbers
  xlayer = (*pstate).owms->GetLayers(index=numbers[0], number=1, count=cnt)
  if ptr_valid((*pstate).pxLyr) then begin
    ptr_free, (*pstate).pxLyr
  endif

  nLayers = n_elements(numbers)
  (*pstate).layerNames = ''
  for x=0, nLayers-1 do begin
     layer = (*pstate).owms->GetLayers(index=numbers[x], number=1)
     if (x eq 0) then begin
        (*pstate).layerNames = layer[0].name
     endif else begin
        (*pstate).layerNames = (*pstate).layerNames + ',' + layer[0].name
     endelse
  endfor

  (*pstate).pxLyr = ptr_new(xlayer, /no_copy)
  xlayer = *(*pstate).pxLyr

  widget_control, (*pstate).wtxtLayerName,        set_value = xlayer[0].name
  widget_control, (*pstate).wtxtLayerTitle,       set_value = xlayer[0].title

  if (xlayer[0].num_style ne 0) then begin
      values = strarr(xlayer[0].num_style)
      for i=0, xlayer[0].num_style-1 do begin
         values[i] = xlayer[0].style[i].name
      endfor
      widget_control, (*pstate).wdlStyle,            set_value = values
  endif

  if (xlayer[0].version eq '1.3.0') then begin
     widget_control, (*pstate).wdlCrs,      set_value = xlayer[0].crs
  endif else begin
     widget_control, (*pstate).wdlCrs,      set_value = xlayer[0].srs
  endelse


  if (xlayer[0].version eq '1.3.0') then begin
     ;;;  west=minx, south=miny, east=maxx, north=maxy
     value = cw_ogc_wms_map_construct_bbox_string(xlayer[0].ex_geobbox.west, xlayer[0].ex_geobbox.south, xlayer[0].ex_geobbox.east, xlayer[0].ex_geobbox.north)
  endif else begin
     value = cw_ogc_wms_map_construct_bbox_string(xlayer[0].lat_lon_bbox.minx, xlayer[0].lat_lon_bbox.miny, xlayer[0].lat_lon_bbox.maxx, xlayer[0].lat_lon_bbox.maxy)
  endelse
  widget_control, (*pstate).wtxtLatLonBBox,           set_value = value

  if (xlayer[0].num_bounding_box  ne 0) then begin
      values = strarr(xlayer[0].num_bounding_box)
      for i=0, xlayer[0].num_bounding_box-1 do begin
         values[i] = cw_ogc_wms_map_construct_bbox_string(xlayer[0].bounding_box[i].minx, xlayer[0].bounding_box[i].miny, xlayer[0].bounding_box[i].maxx, xlayer[0].bounding_box[i].maxy)
      endfor
      widget_control, (*pstate).wdlBBox,            set_value = values
  endif

  if (xlayer[0].num_map_format  ne 0) then begin
      widget_control, (*pstate).wdlMapFmt,          set_value = xlayer[0].map_format
  endif

  if (xlayer[0].num_feature_format  ne 0) then begin
      widget_control, (*pstate).wdlFeatFmt,          set_value = xlayer[0].feature_format
  endif

  if (xlayer[0].num_feature_format  ne 0) then begin
      widget_control, (*pstate).wlblFeatAvail,      set_value = ' Feature Info Avalable: Yes '
      widget_control, (*pstate).wbtnFeat,           sensitive = 1
  endif else begin
      widget_control, (*pstate).wlblFeatAvail,      set_value = ' Feature Info Avalable: No  '
      widget_control, (*pstate).wbtnFeat,           sensitive = 0
  endelse

  cw_ogc_wms_map_tab1_build_get_map_str, pstate

end

;;----------------------------------------------------------------------------
pro  cw_ogc_wms_map_tab1_build_get_map_str, pstate
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
     print, !error_state.msg
     return
  endif

  xlayer = *(*pstate).pxLyr

  widget_control, (*pstate).wdlStyle, get_value = dlval
  idx = widget_info((*pstate).wdlStyle, /droplist_select)
  style = ''
  if (idx ne -1) then begin
     style = dlval[idx]
  endif

  widget_control, (*pstate).wdlCRS, get_value = dlval
  idx = widget_info((*pstate).wdlCRS, /droplist_select)
  crs = ''
  if (idx ne -1) then begin
     crs = dlval[idx]
  endif

  widget_control, (*pstate).wdlMapFmt, get_value = dlval
  idx = widget_info((*pstate).wdlMapFmt, /droplist_select)
  fmt = ''
  if (idx ne -1) then begin
     fmt = dlval[idx]
  endif

  if ((*pstate).activeBBox eq 0) then begin
    widget_control, (*pstate).wtxtLatLonBBox, get_value = bbox
  endif else begin
    widget_control, (*pstate).wdlBBox, get_value = dlval
    idx = widget_info((*pstate).wdlBBox, /droplist_select)
    bbox = ''
    if (idx ne -1) then begin
       bbox = dlval[idx]
    endif
  endelse

  widget_control, (*pstate).wdlWX, get_value = dlval
  idx = widget_info((*pstate).wdlWX, /droplist_select)
  wx = dlval[idx]

  widget_control, (*pstate).wdlHY, get_value = dlval
  idx = widget_info((*pstate).wdlHY, /droplist_select)
  hy = dlval[idx]

  widget_control, (*pstate).wtxtMapOpt, get_value = opts

  getMapStr = 'LAYERS=' + (*pstate).layerNames
  getMapStr = getMapStr + '&STYLES=' + style

  if (xlayer[0].version eq '1.3.0') then begin
      getMapStr = getMapStr + '&CRS=' + crs
  endif else begin
      getMapStr = getMapStr + '&SRS=' + crs
  endelse

  getMapStr = getMapStr + '&BBOX=' + STRCOMPRESS(bbox, /REMOVE_ALL)
  getMapStr = getMapStr + '&Width=' + wx
  getMapStr = getMapStr + '&Height=' + hy
  getMapStr = getMapStr + '&FORMAT=' + fmt

  if (opts ne '') then getMapStr = getMapStr + '&' + opts

  widget_control, (*pstate).wtxtGetMapStr, set_value = getMapStr

  cw_ogc_wms_map_tab1_build_get_feat_str, pstate
end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_btnGetMap_event, ev

  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
     print, !error_state.msg
     return
  endif


  wState = widget_info(ev.top, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  if ((*pstate).mapFN ne '') then begin
      (*pstate).owms->setproperty, map_filename = (*pstate).mapFN
  endif

  ln = (*pstate).layerNames
  len = strlen(ln)

  ; no layers selected that have a name
  if (ln eq '') then begin
     message, 'All selected layers must have layer names'
     return
  endif

  ; first selected layer did not have a name
  if (ln[0] eq ',') then begin
     message, 'All selected layers must have layer names'
     return
  endif

  ; a selected layer did not have a name
  pos = strpos(ln, ',,')
  if (pos ne -1) then begin
     message, 'All selected layers must have layer names'
     return
  endif

  pos = strpos(ln, ',', /reverse_search)
  ; last selected layer did not have a name
  if (pos eq len-1) then begin
     message, 'All selected layers must have layer names'
     return
  endif



  (*pstate).owms->setproperty, callback_function            ='cw_ogc_wms_map_tab1_callback'
  (*pstate).owms->SetProperty, callback_data                = pstate
  (*pstate).owms->setproperty, timeout                      = (*pstate).rxtxTo
  (*pstate).owms->setproperty, connect_timeout              = (*pstate).connectTo

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  widget_control, (*pstate).wtxtGetMapStr, get_value = getMapStr

  xlayer = *(*pstate).pxLyr
  if (xlayer[0].name eq '') then begin
     x = dialog_message('GetMap can only be called for layers that have a layer name.')
     return
  endif

  ; get the map(s)
  res = (*pstate).owms->GetMap(getMapStr[0])
end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_UpdateMapStr_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wms_map_tab1_build_get_map_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_btnLatLonBBox_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).activeBBox = 0

  cw_ogc_wms_map_tab1_build_get_map_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_btnBBox_event, ev
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', dialog_parent=cwBase, /error)
    return
  endif

  wState = widget_info(ev.top, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  (*pstate).activeBBox = 1

  cw_ogc_wms_map_tab1_build_get_map_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_btnOpenMap_event, ev
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
    return
  endif

  cw_ogc_wms_OpenMap, ev, 'mapstatebase'
end

;;----------------------------------------------------------------------------
pro  cw_ogc_wms_map_tab1_build_get_feat_str, pstate
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
     print, !error_state.msg
     return
  endif

  xlayer = *(*pstate).pxLyr

  widget_control, (*pstate).wdlCRS, get_value = dlval
  idx = widget_info((*pstate).wdlCRS, /droplist_select)
  crs = ''
  if (idx ne -1) then begin
     crs = dlval[idx]
  endif

  widget_control, (*pstate).wdlFeatFmt, get_value = dlval
  idx = widget_info((*pstate).wdlFeatFmt, /droplist_select)
  fmt = ''
  if (idx ne -1) then begin
     fmt = dlval[idx]
  endif

  if ((*pstate).activeBBox eq 0) then begin
    widget_control, (*pstate).wtxtLatLonBBox, get_value = bbox
  endif else begin
    widget_control, (*pstate).wdlBBox, get_value = dlval
    idx = widget_info((*pstate).wdlBBox, /droplist_select)
    bbox = ''
    if (idx ne -1) then begin
       bbox = dlval[idx]
    endif
  endelse

  widget_control, (*pstate).wdlWX, get_value = dlval
  idx = widget_info((*pstate).wdlWX, /droplist_select)
  wx = dlval[idx]

  widget_control, (*pstate).wdlHY, get_value = dlval
  idx = widget_info((*pstate).wdlHY, /droplist_select)
  hy = dlval[idx]

  widget_control, (*pstate).wtxtI, get_value = Ival
  widget_control, (*pstate).wtxtJ, get_value = Jval
  widget_control, (*pstate).wtxtFeatOpt, get_value = opts

  getFeatStr = 'QUERY_LAYERS=' + xlayer[0].name

  if (xlayer[0].version eq '1.3.0') then begin
      getFeatStr = getFeatStr + '&CRS=' + crs
  endif else begin
      getFeatStr = getFeatStr + '&SRS=' + crs
  endelse

  getFeatStr = getFeatStr + '&BBOX=' + bbox
  getFeatStr = getFeatStr + '&Width=' + wx
  getFeatStr = getFeatStr + '&Height=' + hy

  if (xlayer[0].version eq '1.3.0') then begin
      getFeatStr = getFeatStr + '&I=' + Ival
      getFeatStr = getFeatStr + '&J=' + Jval
  endif else begin
      getFeatStr = getFeatStr + '&X=' + Ival
      getFeatStr = getFeatStr + '&Y=' + Jval
  endelse

  getFeatStr = getFeatStr + '&FORMAT=' + fmt

  if (opts ne '') then getFeatStr = getFeatStr + '&' + opts

  widget_control, (*pstate).wtxtGetFeatStr, set_value = getFeatStr
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_UpdateFeatStr_event, ev
  compile_opt idl2

  wState = widget_info(ev.top, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  cw_ogc_wms_map_tab1_build_get_feat_str, pstate
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_btnGetFeat_event, ev

  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
     catch,/cancel
     r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
     print, !error_state.msg
     return
  endif


  wState = widget_info(ev.top, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  if ((*pstate).mapFN ne '') then begin
      (*pstate).owms->setproperty, feature_info_filename = (*pstate).featFN
  endif

  (*pstate).owms->setproperty, callback_function            ='cw_ogc_wms_map_tab1_callback'
  (*pstate).owms->SetProperty, callback_data                = pstate
  (*pstate).owms->setproperty, timeout                      = (*pstate).rxtxTo
  (*pstate).owms->setproperty, connect_timeout              = (*pstate).connectTo

  ; clear the status text widget
  widget_control, (*pstate).wtxtStatus, set_value=''

  widget_control, (*pstate).wtxtGetFeatStr, get_value = getFeatStr

  ; get the feature info
  res = (*pstate).owms->GetFeatureInfo(getFeatStr[0])
end

;;----------------------------------------------------------------------------
function cw_ogc_wms_map_tab1_callback, status, progress, data
  compile_opt idl2
  on_error, 2                   ; return errors to caller

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
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
  wevMap = widget_event((*data).wbtnCancelMap, /nowait)

  if (wevMap.id EQ (*data).wbtnCancelMap) then begin
    return, 0
  endif

;  if (progress[0]) then begin
;     print, progress
;  endif

  ;widget_control, hourglass=1
  return, 1
end



;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_kill_event, id
  compile_opt idl2
  catch, errorStatus            ; catch all errors and display an error dialog

  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    return
  endif

  ; called when the main ui is destroyed we let go of objects and pointers

  widget_control, id, get_uvalue = pstate

  ; this will close all iImage windows...tiff images
  for ix=0, n_elements((*pstate).lyritIdArr)-1 do begin
     if ((*pstate).lyritIdArr[ix] ne '') then begin
            itDelete, (*pstate).lyritIdArr[ix]
      endif
  endfor

  if ptr_valid(pstate) then begin
    if ptr_valid((*pstate).pxLyr) then begin
      ptr_free, (*pstate).pxLyr
    endif
    ptr_free, (*pstate).paxServers
    ptr_free, pstate
  endif

  widget_control, id, /destroy
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab1_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
    return
  endif


  wState = widget_info(id, find_by_uname='mapstatebase')
  widget_control, wState, get_uvalue = pstate

  ; get the number of visible lines in the status text window
  winfowtxtStatus = widget_info((*pstate).wtxtStatus,/geometry)

  (*pstate).statusLines = winfowtxtStatus.ysize - 2

  widget_control, (*pstate).wdlWX, set_droplist_select=1
  widget_control, (*pstate).wdlHY, set_droplist_select=1
  widget_control, (*pstate).wbtnUseLatLonBBox, /set_button

end


;;----------------------------------------------------------------------------
pro  cw_ogc_wms_map_tab1, parent, tab2, owms, layerNumbers
  compile_opt idl2
  on_error, 2

  wDCBase           = widget_base(parent, /Col, TITLE='Layer Info', NOTIFY_REALIZE='cw_ogc_wms_map_tab1_realize_notify_event', space=2)
  wDCBaseState      = widget_base(wDCBase, uname='mapstatebase', kill_notify='cw_ogc_wms_map_tab1_kill_event')

  x_sz      = 810
  lbl_sz    = 120
  widg_sz   = 260

  xpad=7
  ypad=4
  space=0


  drop_ysz = 20
  if (!version.os_family eq 'unix') then begin
     drop_ysz = 35
  endif

  ; we geta any to determine the version number
  xLayer = owms->GetLayers(index=0, number=1)
  ver13 = 0
  if (xLayer.version eq '1.3.0') then begin
     ver13 = 1
  endif

  ; add the map offering frame ------------------------
  wDCBaseMap         = widget_base(wDCBase)
  wLblMap            = widget_label(wDCBaseMap, value=' Map and Feature Requests ', xoffset=5)
  winfoLblMap        = widget_info(wLblMap, /geometry)
  wDCBaseFrMap       = widget_base(wDCBaseMap, /frame, yoffset=winfoLblMap.ysize/2, /col, xpad=xpad, ypad=ypad, space=2)
  wLblMapx           = widget_label(wDCBaseMap, value=' Map and Feature Requests ', xoffset=5)

  wRow              = widget_base(wDCBaseFrMap, /row)
  wlbl              = widget_label(wRow, value = 'Layer Name ', scr_xsize = lbl_sz, /align_right)
  wtxtLayerName     = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2, scr_ysize=drop_ysz)

  wRow              = widget_base(wDCBaseFrMap, /row)
  wlbl              = widget_label(wRow, value = 'Layer Title ', scr_xsize = lbl_sz, /align_right)
  wtxtLayerTitle    = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2, scr_ysize=drop_ysz)


  wDCBaseLP         = widget_base(wDCBaseFrMap)
  wLblLP            = widget_label(wDCBaseLP, value=' Map Request ', xoffset=5)
  winfoLblLP        = widget_info(wLblLP, /geometry)
  wDCBaseFrLP       = widget_base(wDCBaseLP, /frame, yoffset=winfoLblMap.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblLP            = widget_label(wDCBaseLP, value=' Map Request ', xoffset=5)

  wRow              = widget_base(wDCBaseFrLP, /row)
  wlbl              = widget_label(wRow, value = 'Style ', scr_xsize = lbl_sz-5, /align_right)
  wdlStyle          = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')

  if (ver13) then begin
    wlbl              = widget_label(wRow, value = 'CRS ', scr_xsize = lbl_sz-5, /align_right)
  endif else begin
    wlbl              = widget_label(wRow, value = 'SRS ', scr_xsize = lbl_sz-5, /align_right)
  endelse

  wdlCrs            = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')


  wRow              = widget_base(wDCBaseFrLP, /row)
  wlbl              = widget_label(wRow, value = 'Format ', scr_xsize = lbl_sz-5, /align_right)
  fmts              = ['JPEG','GIF','PNG','TIFF']
  wdlMapFmt         = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, value=fmts, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')

  covReqDims        = ['100','250','500','750','1000','1250','1500','1750','2000','2250','2500','2750','3000','3500','4000']
  wlbl              = widget_label(wRow, value = ' Width ', scr_xsize = 75, /align_right)
  wdlWX             = widget_droplist(wRow, scr_xsize=110, scr_ysize=drop_ysz, value = covReqDims, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')
  wlbl              = widget_label(wRow, value = ' Height', scr_xsize =75, /align_right)
  wdlHY             = widget_droplist(wRow, scr_xsize=110, scr_ysize=drop_ysz, value = covReqDims, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')
  widget_control, wdlWX, set_droplist_select=2
  widget_control, wdlHY, set_droplist_select=2

  wRow              = widget_base(wDCBaseFrLP, /row)
  if (ver13) then begin
    wlbl              = widget_label(wRow, value = 'Ex Geo Bound Box ', scr_xsize = lbl_sz-5, /align_right)
  endif else begin
    wlbl              = widget_label(wRow, value = 'Lat/Lon Bound Box ', scr_xsize = lbl_sz-5, /align_right)
  endelse
  wtxtLatLonBBox     = widget_text(wRow, scr_xsize=widg_sz + lbl_sz + widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')


  wRow              = widget_base(wDCBaseFrLP, /row)
  wlbl              = widget_label(wRow, value = 'Bounding Box ', scr_xsize = lbl_sz-5, /align_right)
  wdlBBox           = widget_droplist(wRow, scr_xsize=widg_sz + lbl_sz + widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wms_map_tab1_UpdateMapStr_event')

  wexBase           = widget_base(wDCBaseFrLP, /exclusive, /row, xpad=120)
  if (ver13) then begin
      wbtnUseLatLonBBox     = widget_button(wexBase, value=' Use Ex Geo BBox ', event_pro='cw_ogc_wms_map_tab1_btnLatLonBBox_event')
  endif else begin
      wbtnUseLatLonBBox     = widget_button(wexBase, value=' Use LatLon BBox ', event_pro='cw_ogc_wms_map_tab1_btnLatLonBBox_event')
  endelse
  wbtnUseBBox       = widget_button(wexBase, value=' Use BBox', event_pro='cw_ogc_wms_map_tab1_btnBBox_event')


  wRow              = widget_base(wDCBaseFrLP, /row)
  wlbl              = widget_label(wRow, value = ' Options ', scr_xsize = lbl_sz-5, /align_right)
  wtxtMapOpt       = widget_text(wRow, scr_xsize=widg_sz + lbl_sz + widg_sz, /editable, /all_events, event_pro='cw_ogc_wms_map_tab1_UpdateMapStr_event')

  wDCBaseGet        = widget_base(wDCBaseFrLP)
  wLblGet           = widget_label(wDCBaseGet, value=' Get Map ', xoffset=5)
  winfoLblGet       = widget_info(wLblGet, /geometry)
  wDCBaseFrGet      = widget_base(wDCBaseGet, /frame, yoffset=winfoLblMap.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblGet           = widget_label(wDCBaseGet, value=' Get Map ', xoffset=5)

  wRow              = widget_base(wDCBaseFrGet, /row)
  wlbl              = widget_label(wRow, value = ' Map Request String ')
  wRow              = widget_base(wDCBaseFrGet, /row)
  wtxtGetMapStr     = widget_text(wRow, scr_xsize=widg_sz+widg_sz+lbl_sz-5+100, /editable)
  wRow              = widget_base(wDCBaseFrGet, /row)
  wbtnGetMap        = widget_button(wRow, value='Get Map', scr_xsize = 90, event_pro = 'cw_ogc_wms_map_tab1_btnGetMap_event')
  wbtnCancelMap     = widget_button(wRow, value='Cancel', scr_xsize = 90)
  wbtnOpenMap       = widget_button(wRow, value='Open Map', scr_xsize = 100, event_pro = 'cw_ogc_wms_map_tab1_btnOpenMap_event')


  ; feature info
  wDCBaseFeat       = widget_base(wDCBaseFrMap)
  wLblFeat          = widget_label(wDCBaseFeat, value=' Feature Info Request ', xoffset=5)
  winfoLblFeat      = widget_info(wLblFeat, /geometry)
  wDCBaseFrFeat     = widget_base(wDCBaseFeat, /frame, yoffset=winfoLblMap.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblFeat          = widget_label(wDCBaseFeat, value=' Feature Info Request ', xoffset=5)

  wRow              = widget_base(wDCBaseFrFeat, /row)
  wlbl              = widget_label(wRow, value = 'Format ', scr_xsize = lbl_sz-5, /align_right)
  wdlFeatFmt        = widget_droplist(wRow, scr_xsize=widg_sz, scr_ysize=drop_ysz, event_pro = 'cw_ogc_wms_map_tab1_UpdateFeatStr_event')

  wlbl              = widget_label(wRow, value = ' I ', scr_xsize = 75, /align_right)
  wtxtI             = widget_text(wRow, scr_xsize=110, /edit, scr_ysize=drop_ysz, value = '100', /all_events, event_pro='cw_ogc_wms_map_tab1_UpdateFeatStr_event')
  wlbl              = widget_label(wRow, value = ' J ', scr_xsize =75, /align_right)
  wtxtJ             = widget_text(wRow, scr_xsize=110, /edit, scr_ysize=drop_ysz, value = '100', /all_events, event_pro='cw_ogc_wms_map_tab1_UpdateFeatStr_event')

  wRow              = widget_base(wDCBaseFrFeat, /row)
  wlbl              = widget_label(wRow, value = ' Options ', scr_xsize = lbl_sz-5, /align_right)
  wtxtFeatOpt       = widget_text(wRow, scr_xsize=widg_sz + lbl_sz + widg_sz, /editable, /all_events, event_pro='cw_ogc_wms_map_tab1_UpdateFeatStr_event')

  wDCBaseFeat       = widget_base(wDCBaseFrFeat)
  wLblFeat          = widget_label(wDCBaseFeat, value=' Get Feature Info ', xoffset=5)
  winfoLblFeat      = widget_info(wLblFeat, /geometry)
  wDCBaseFrFeat     = widget_base(wDCBaseFeat, /frame, yoffset=winfoLblMap.ysize/2, /col, xpad=xpad, ypad=ypad, space=space)
  wLblFeat          = widget_label(wDCBaseFeat, value=' Get Feature Info ', xoffset=5)

  wRow              = widget_base(wDCBaseFrFeat, /row)
  wlbl              = widget_label(wRow, value = ' Feature Info Request String ')
  wRow              = widget_base(wDCBaseFrFeat, /row)
  wtxtGetFeatStr    = widget_text(wRow, scr_xsize=widg_sz+widg_sz+lbl_sz-5+100, /editable)
  wRow              = widget_base(wDCBaseFrFeat, /row)
  wbtnFeat          = widget_button(wRow, value='Get Feature Info', scr_xsize = 150, event_pro = 'cw_ogc_wms_map_tab1_btnGetFeat_event')
  wbtnCancelFeat    = widget_button(wRow, value='Cancel', scr_xsize = 90)
  wlblFeatAvail     = widget_label(wRow, value = ' Feature Info Avalable: No  ')


  ;;add the status frame -------------------------------
  wDCBaseStatus     = widget_base(wDCBase)
  wlblStatus        = widget_label(wDCBaseStatus, value=' Status ', xoffset=5)
  winfolblStatus    = widget_info(wlblStatus, /geometry)
  wDCBaseFrStatus   = widget_base(wDCBaseStatus, /frame, yoffset=winfolblStatus.ysize/2, /row, xpad=xpad, ypad=ypad, space=space)
  wlblStatus        = widget_label(wDCBaseStatus, value=' Status ', xoffset=5)
  wtxtStatus        = widget_text(wDCBaseFrStatus, value='', /scroll, font='Courier New*14', UNAME='TXT_STATUS', ysize=9, scr_xsize=x_sz-25)


  widget_control, wDCBaseFrMap,     scr_xsize=x_sz
  widget_control, wDCBaseFrStatus,  scr_xsize=x_sz
  widget_control, wDCBaseFrGet,     scr_xsize=x_sz-45
  widget_control, wDCBaseFrFeat,    scr_xsize=x_sz-45

  ; set in ogc_wms::cw_ogc_wms_OpenMap
  lyritIdArr    = make_array(256, /string, value='')
  lyritIdArrIdx = byte(0) ; by design this index will wrap back to 0 after 256 windows


  ;paxServers is a ptr to an array of structures that define the remote servers, set in ogc_wms_getConfigInfo

  state = {tab2Root:tab2, owms:owms, layerNumbers:layerNumbers, pxlyr:ptr_new(), statusLines:8, layerNames:'', $
           lyritIdArr:lyritIdArr, lyritIdArrIdx:lyritIdArrIdx, activeBBox:0, wtxtGetFeatStr:wtxtGetFeatStr, $
           wtxtStatus:wtxtStatus, wtxtLayerName:wtxtLayerName, wtxtLatLonBBox:wtxtLatLonBBox, wbtnFeat:wbtnFeat, $
           wtxtLayerTitle:wtxtLayerTitle, wdlStyle:wdlStyle, wdlCrs:wdlCrs, wtxtFeatOpt:wtxtFeatOpt, $
           wbtnUseLatLonBBox:wbtnUseLatLonBBox, wdlFeatFmt:wdlFeatFmt, wtxtI:wtxtI, wtxtJ:wtxtJ, $
           wdlBBox:wdlBBox, wdlMapFmt:wdlMapFmt, wbtnCancelMap:wbtnCancelMap, wdlWX:wdlWX, wdlHY:wdlHY, $
           wtxtMapOpt:wtxtMapOpt, wtxtGetMapStr:wtxtGetMapStr, wlblFeatAvail:wlblFeatAvail, $
           prefsFile:'', paxServers:ptr_new(0), covServer:'', schemaCk:0, $
           capFN:'', mapFN:'', featFN:'', capFromFile:'', $
           displayHttp:1, rxtxTo:'1800', connectTo:'1800', proxy:'', proxyPort:'', verbose:0, $
           usr:'', pwd:'', proxyusr:'', proxypwd:'', encoding:0, validationMode:0 }


  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wDCBaseState, set_uvalue=pstate

  ;this will set paxServers if the .sav file exists and has some remote server entries
  (*pstate).prefsFile = ogc_wms_getConfigInfo(wDCBase, 'mapstatebase')
end
