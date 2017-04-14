
;****************************************************************************

pro cw_ogc_wms_map_tab2_enum_layer, wid, xLayers, iLayer

compile_opt idl2

catch, errorStatus            ; catch all errors and display an error dialog
if (errorStatus ne 0) then begin
   catch,/cancel
   r = dialog_message(!error_state.msg, title='OGC Client Test', /error)
   print, !error_state.msg
   return
endif


widget_control, wid, /append, set_value = 'Layer Values'
widget_control, wid, /append, set_value = '------------------------------------------------'

widget_control, wid, /append, set_value = 'Layer=              ' + xLayers[iLayer].layer
widget_control, wid, /append, set_value = 'Parent=             ' + xLayers[iLayer].parent
widget_control, wid, /append, set_value = 'Level=              ' + xLayers[iLayer].level
widget_control, wid, /append, set_value = 'Name=               ' + xLayers[iLayer].name
widget_control, wid, /append, set_value = 'Title=              ' + xLayers[iLayer].title
widget_control, wid, /append, set_value = 'Version=            ' + xLayers[iLayer].version
widget_control, wid, /append, set_value = 'UpdateSeq=          ' + xLayers[iLayer].update_seq
widget_control, wid, /append, set_value = 'Abstract=           ' + xLayers[iLayer].abstract
widget_control, wid, /append, set_value = 'min_scale=          ' + xLayers[iLayer].min_scale
widget_control, wid, /append, set_value = 'max_scale=          ' + xLayers[iLayer].max_scale
widget_control, wid, /append, set_value = 'queryable=          ' + xLayers[iLayer].queryable
widget_control, wid, /append, set_value = 'cascaded=           ' + xLayers[iLayer].cascaded
widget_control, wid, /append, set_value = 'opaque=             ' + xLayers[iLayer].opaque
widget_control, wid, /append, set_value = 'no_subsets=         ' + xLayers[iLayer].no_subsets
widget_control, wid, /append, set_value = 'fixed_width=        ' + xLayers[iLayer].fixed_width
widget_control, wid, /append, set_value = 'fixed_height=       ' + xLayers[iLayer].fixed_height

widget_control, wid, /append, set_value = ' '


ver13 = 0
if (xLayers[iLayer].version eq '1.3.0') then begin
   ver13 = 1
endif

widget_control, wid, /append, set_value = 'NumMapFormat=       ' + xLayers[iLayer].num_map_format
for i=0, xLayers[iLayer].num_map_format-1 do begin
  widget_control, wid, /append, set_value = ' Map Format [' + strtrim(i,2) +']     ' + xLayers[iLayer].map_format[i]
end

widget_control, wid, /append, set_value = 'NumFeatureFormat=   ' + xLayers[iLayer].num_feature_format
for i=0, xLayers[iLayer].num_feature_format-1 do begin
  widget_control, wid, /append, set_value = ' Feature Format [' + strtrim(i,2) +'] ' + xLayers[iLayer].feature_format[i]
end

widget_control, wid, /append, set_value = 'NumKeyword=         ' + xLayers[iLayer].num_keyword
for i=0, xLayers[iLayer].num_keyword-1 do begin
  widget_control, wid, /append, set_value = ' Keyword [' + strtrim(i,2) +']        ' + xLayers[iLayer].keyword[i]
end

if (ver13 eq 0) then begin
  x = xLayers[iLayer].lat_lon_bbox
  widget_control, wid, /append, set_value = 'Lat Lon BBox        minx:' + x.minx + ' miny:' + x.miny + ' maxx:' + x.maxx + ' maxy:' + x.maxy
endif

if (ver13 eq 1) then begin
  x = xLayers[iLayer].ex_geobbox
  widget_control, wid, /append, set_value = 'Ex Geo BBox         west:' + x.west + ' east:' + x.east + ' south:' + x.south + ' north:' + x.north
endif

if (ver13 eq 0) then begin
  widget_control, wid, /append, set_value = 'Num_SRS=            ' + xLayers[iLayer].num_srs
  for i=0, xLayers[iLayer].num_srs-1 do begin
    widget_control, wid, /append, set_value = ' SRS [' + strtrim(i,2) +']            ' + xLayers[iLayer].srs[i]
  end
endif

if (ver13 eq 1) then begin
  widget_control, wid, /append, set_value = 'Num_CRS=            ' + xLayers[iLayer].num_crs
  for i=0, xLayers[iLayer].num_crs-1 do begin
    widget_control, wid, /append, set_value = ' CRS [' + strtrim(i,2) +']            ' + xLayers[iLayer].crs[i]
  end
endif

widget_control, wid, /append, set_value = 'Num_Bounding_Box=   ' + xLayers[iLayer].num_bounding_box
for i=0, xLayers[iLayer].num_bounding_box-1 do begin
  x= xLayers[iLayer].bounding_box[i]
  widget_control, wid, /append, set_value = ' Bounding_Box [' + strtrim(i,2) +']   srs:' + x.srs + ' crs:' + x.crs + ' minx:' + x.minx + ' miny:' + x.miny + ' maxx:' + x.maxx + ' maxy:' + x.maxy + ' resx:' + x.resx + ' resy:' + x.resy
end

if (ver13 eq 0) then begin
  widget_control, wid, /append, set_value = 'Num_Extent=         ' + xLayers[iLayer].num_Extent
  for i=0, xLayers[iLayer].num_extent-1 do begin
    x= xLayers[iLayer].extent[i]
    widget_control, wid, /append, set_value = ' Extent [' + strtrim(i,2) +']         name:' + x.name + ' def:' + x.default + ' near:' + x.nearest_value + ' ext:' + x.extent
  end
endif

widget_control, wid, /append, set_value = 'Num_Dimemsion=      ' + xLayers[iLayer].num_dimension
for i=0, xLayers[iLayer].num_dimension-1 do begin
  x= xLayers[iLayer].dimension[i]
  if (ver13 eq 0) then begin
    widget_control, wid, /append, set_value = ' Dimension [' + strtrim(i,2) +']      name:' + x.name + ' units:' + x.units + ' sym:' + x.unit_symbol
  endif
  if (ver13 eq 1) then begin
    widget_control, wid, /append, set_value = ' Dimension [' + strtrim(i,2) +']      name:' + x.name + ' units:' + x.units + ' sym:' + x.unit_symbol
    widget_control, wid, /append, set_value = '               def:' + x.default + ' multi:' + x.multiple_values + ' near:' + x.nearest_value + ' cur:' + x.current + ' ext:' + x.extent
  endif
end

x = xLayers[iLayer].attribution
widget_control, wid, /append, set_value = 'Attribution         title:' + x.title + ' online:' + x.online + ' logo_fmt:' + x.logo_format + ' logo_on:' + x.logo_online + ' logo_w:' + x.logo_width + ' logo_h:' + x.logo_height


widget_control, wid, /append, set_value = 'Num_Authority=      ' + xLayers[iLayer].num_authority
for i=0, xLayers[iLayer].num_authority-1 do begin
  x= xLayers[iLayer].authority[i]
  widget_control, wid, /append, set_value = ' Authority [' + strtrim(i,2) +']      name:' + x.name + ' online:' + x.online
end

widget_control, wid, /append, set_value = 'Num_Id=             ' + xLayers[iLayer].num_identifier
for i=0, xLayers[iLayer].num_identifier-1 do begin
  x= xLayers[iLayer].identifier[i]
  widget_control, wid, /append, set_value = ' Id [' + strtrim(i,2) +']             id:' + x.id + ' authority:' + x.authority
end

widget_control, wid, /append, set_value = 'Num_Metadata_Url=   ' + xLayers[iLayer].num_metadata_url
for i=0, xLayers[iLayer].num_metadata_url-1 do begin
  x= xLayers[iLayer].metadata_url[i]
  widget_control, wid, /append, set_value = ' Metadata_Url [' + strtrim(i,2) +']   type:' + x.type + ' format:' + x.format + ' online:' + x.online
end

widget_control, wid, /append, set_value = 'Num_Data_Url=       ' + xLayers[iLayer].num_data_url
for i=0, xLayers[iLayer].num_data_url-1 do begin
  x= xLayers[iLayer].data_url[i]
  widget_control, wid, /append, set_value = ' Data_Url [' + strtrim(i,2) +']       format:' + x.format + ' online:' + x.online
end

widget_control, wid, /append, set_value = 'Num_Feature=        ' + xLayers[iLayer].num_feature_url
for i=0, xLayers[iLayer].num_feature_url-1 do begin
  x= xLayers[iLayer].feature_url[i]
  widget_control, wid, /append, set_value = ' Feature [' + strtrim(i,2) +']        format:' + x.format + ' online:' + x.online
end

widget_control, wid, /append, set_value = 'Num_Style=          ' + xLayers[iLayer].num_style
for i=0, xLayers[iLayer].num_style-1 do begin
  x= xLayers[iLayer].style[i]
  widget_control, wid, /append, set_value = ' Style [' + strtrim(i,2) +']          name:' + x.name + ' title:' + x.title + ' abs:' + x.abstract
  widget_control, wid, /append, set_value = '                    lgnd_fmt:' + x.legend_format + ' lgnd_on:' + x.legend_online + ' lgnd_w:' + x.legend_width + ' lgnd_h:' + x.legend_height
  widget_control, wid, /append, set_value = '                    sheet_fmt:' + x.sheet_format + ' sheet_on:' + x.sheet_online
  widget_control, wid, /append, set_value = '                    style_fmt:' + x.style_format + ' style_on:' + x.style_online
end

end


;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab2_load_layer, id

    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
        print, !error_state.msg
        return
    endif

  wState = widget_info(id, find_by_uname='mapstatebasetab2')
  widget_control, wState, get_uvalue = pstate

  widget_control, (*pstate).wtxtStatus, set_value=''



  widget_control, (*pstate).wtxtLayerName,           set_value = "Loading."

  numbers       = (*pstate).layerNumbers
  xlayer = (*pstate).owms->GetLayers(index=numbers[0], number=1, count=cnt)
  if ptr_valid((*pstate).pxLyr) then begin
    ptr_free, (*pstate).pxLyr
  endif

  (*pstate).pxLyr = ptr_new(xlayer, /no_copy)
  xlayer = *(*pstate).pxLyr

  widget_control, (*pstate).wtxtLayerName,        set_value = xlayer[0].name
  widget_control, (*pstate).wtxtLayerTitle,       set_value = xlayer[0].title

  cw_ogc_wms_map_tab2_enum_layer, (*pstate).wtxtStatus, xlayer, 0

end




;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab2_kill_event, id
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
    if ptr_valid((*pstate).pxLyr) then begin
      ptr_free, (*pstate).pxLyr
    endif
    ptr_free, pstate
  endif

  widget_control, id, /destroy
end

;;----------------------------------------------------------------------------
pro cw_ogc_wms_map_tab2_realize_notify_event, id
  compile_opt idl2

  catch, errorStatus            ; catch all errors and display an error dialog
  if (errorStatus ne 0) then begin
    catch,/cancel
    print, !error_state.msg
    r = dialog_message(!error_state.msg, title='OGC WMS Error', /error)
    return
  endif


  wState = widget_info(id, find_by_uname='mapstatebasetab2')
  widget_control, wState, get_uvalue = pstate

  ; get the number of visible lines in the status text window
  winfowtxtStatus = widget_info((*pstate).wtxtStatus,/geometry)

  (*pstate).statusLines = winfowtxtStatus.ysize - 2


end


;;----------------------------------------------------------------------------
pro  cw_ogc_wms_map_tab2, parent, owms, layerNumbers
  compile_opt idl2
  on_error, 2

  wDCBase           = widget_base(parent, /Col, TITLE='Layer Info', NOTIFY_REALIZE='cw_ogc_wms_map_tab2_realize_notify_event', space=2)
  wDCBaseState      = widget_base(wDCBase, uname='mapstatebasetab2', kill_notify='cw_ogc_wms_map_tab2_kill_event')

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

  ; add the map offering frame ------------------------
  wDCBaseMap         = widget_base(wDCBase)
  wLblMap            = widget_label(wDCBaseMap, value=' Layer Info ', xoffset=5)
  winfoLblMap        = widget_info(wLblMap, /geometry)
  wDCBaseFrMap       = widget_base(wDCBaseMap, /frame, yoffset=winfoLblMap.ysize/2, /col, xpad=xpad, ypad=ypad, space=2)
  wLblMapx           = widget_label(wDCBaseMap, value=' Layer Info ', xoffset=5)

  wRow              = widget_base(wDCBaseFrMap, /row)
  wlbl              = widget_label(wRow, value = 'Layer Name ', scr_xsize = lbl_sz, /align_right)
  wtxtLayerName     = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2, scr_ysize=drop_ysz)

  wRow              = widget_base(wDCBaseFrMap, /row)
  wlbl              = widget_label(wRow, value = 'Layer Title ', scr_xsize = lbl_sz, /align_right)
  wtxtLayerTitle    = widget_text(wRow, scr_xsize=lbl_sz+2*widg_sz+2, scr_ysize=drop_ysz)
  wtxtStatus        = widget_text(wDCBaseFrMap, value='', /scroll, font='Courier New*14', UNAME='TXT_STATUS', ysize=29, scr_xsize=x_sz-25)


  widget_control, wDCBaseFrMap,     scr_xsize=x_sz

  state = {owms:owms, layerNumbers:layerNumbers, pxlyr:ptr_new(), statusLines:8, $
           wtxtStatus:wtxtStatus, wtxtLayerName:wtxtLayerName, wtxtLayerTitle:wtxtLayerTitle}

  ; passing a ptr is much more efficient
  pstate = ptr_new(state)

  ; put the state ptr in the uvalue of the base obj so all events can get the state
  widget_control, wDCBaseState, set_uvalue=pstate

end
