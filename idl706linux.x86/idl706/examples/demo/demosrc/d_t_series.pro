; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_t_series.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_t_series.pro
;
;  CALLING SEQUENCE: d_t_series
;
;  PURPOSE:
;       Shows a time series as an image or a 3-D plot.
;
;  MAJOR TOPICS: Data analysis and plotting
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       fun d_t_seriesREAD             - Read the time series file
;       fun d_t_seriesCOLOR            - Define working colors
;       fun d_t_seriesSIZES            - Size the widgets
;       pro d_t_seriesSURF             - Create the surface plot
;       pro d_t_seriesMENUEVENT        - Handle the menu events
;       fun d_t_seriesDATE             - Convert date format
;       fun d_t_seriesTIME             - Find time for the cursor location
;       fun d_t_seriesIMAGE            - Find min and max of image data set
;       pro d_t_seriesLEGEND           - Create the legend
;       pro d_t_seriesDRAWEVENT        - Handle the drawing area event
;       pro d_t_seriesDRAW             - Create the image plot
;       pro d_t_seriesROTATIONEVENT    - Handle the rotation slider event
;       pro d_t_seriesNONEVENT         - Do nothing
;       pro d_t_seriesTOGGLEEVENT      - Toggle z axis button state
;       fun d_t_seriesMONTH_STR        - convert month format
;       pro d_t_seriesMONTHEVENT       - Handle month event slider
;       fun d_t_seriesSTRSLIDER        - Create sliders
;       pro d_t_seriesQuitEvent        - Event Handler
;       pro d_t_seriesCLEANUP          - Cleanup procedure
;       pro d_t_series                 - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:  Written:  DF, RSI,  1995
;                         Modified by SU, RSI, January 1997
;-
;--------------------------------------------------------------------
;
;   PURPOSE : Read the time series data.
;
function d_t_seriesREAD, $
    filename      ; IN: file name

    ;  Read in time series data
    ;  called by D_T_SERIES.PRO.
    ;  This function does NOT check for
    ;  file existence.
    ;
    OPENR, lun, filename, /XDR, /GET_LUN

    ;  Read in the data type.
    ;
    type = 0
    READU, lun, type

    ;  Read in the voltage.
    ;
    voltage = 0
    READU, lun, voltage

    ;  Read in the number of days.
    ;
    n_days = 0L
    READU, lun, n_days

    ;  Read in the array.
    ;
    array = Intarr(n_days, 48, /Nozero)
    READU, lun, array

    ;  Read in the date.
    ;
    date = Lonarr(n_days, /Nozero)
    READU, lun, date

    ;  Read in ?.
    ;
    miss = Bytarr(n_days, 48, /Nozero)
    READU, lun, miss

    ;  Close the file.
    ;
    CLOSE, lun
    FREE_LUN, lun

    ;  Determine the array locations of unique months.
    ;
    uniq_months = Uniq(date / 100L)

    ;  Determine the maximum value of the array.
    ;
    z_max = Max(array)

    ;  Set up the data structure.
    ;
    RETURN, { type:type, $
        voltage:voltage, $
        n_days:n_days, $
        array:array, $
        date:date, $
        miss:miss, $
        uniq_months:uniq_months, $
        z_max:z_max }
end   ;  of d_t_seriesREAD

;--------------------------------------------------------------------
;
;   PURPOSE : Read the time series data.
;             Define colors for time series demo
;             called by D_T_SERIES.PRO.
;             Returns a structure of integers that
;             represent color values.
;             Make sure we have these colors defined and
;             know where they are in the table.
;             Start by checking the number of colors IDL grabbed.
;
function d_t_seriesCOLOR
    if (!D.TABLE_SIZE GT 7) then begin

        ;  Allocate bins for the defined colors to occupy.
        ;
        white = !D.TABLE_SIZE - 1
        yellow = !D.TABLE_SIZE - 2
        green = !D.TABLE_SIZE - 3
        red = !D.TABLE_SIZE - 4
        blue = !D.TABLE_SIZE - 5
        gray = !D.TABLE_SIZE - 6
        black = !D.TABLE_SIZE - 7

        ;  Ct_max is the upper bound of the remaining colors.
        ;
        ct_max = !D.TABLE_SIZE - 8
        LOADCT, 5

        ;  Stretch the loaded color table to the new bounds.
        ;
        STRETCH, 0, ct_max

        ;  Define the colors and assign to appropriate bins.
        ;
        TVLCT, 255, 255, 255, white
        TVLCT, 255, 255,   0, yellow
        TVLCT,   0, 255,   0, green
        TVLCT, 255,  63,  63, red
        TVLCT, 127, 127, 255, blue
        TVLCT,  90,  90,  90, gray
        TVLCT,   0,   0,   0, black
    endif else begin

        ;  If the color table is too small use
        ;  two color approach.
        ;
        white = 1
        yellow = 1
        green = 1
        red = 1
        blue = 1
        gray = 0
        black = 0
        ct_max = 1
    endelse

    ;  Return a structure of colors.
    ;
    RETURN, { white:white, $
          yellow:yellow, $
          green:green, $
          red:red, $
          blue:blue, $
          gray:gray, $
          black:black, $
          ct_max:ct_max }
End

;--------------------------------------------------------------------
;
;   PURPOSE : Set the size of the main drawing area.
;
function d_t_seriesSIZES, $
    sc_size        ; IN: screen size

    draw_size = [ FIX(0.75 * sc_size[0]), $
                  FIX(0.60 * sc_size[1]) ]

    ;  Set the size of 2-D byte scale image.
    ;
    img_size = [ fix(0.50 * draw_size[0]), $
             fix(0.35 * draw_size[1]) ]

    ;  Calculate the ratio of the y size of the byte.
    ;  Scale plot of the data to the actual
    ;  number of data points (48).
    ;
    ratio = ( img_size[1] / 48. )

    ;  Set the location of the 2-D byte scale image.
    ;
    img_loc = [ fix(0.40 * draw_size[0]), $
            fix(0.57 * draw_size[1]) ]

    ;  Create the coords for the square vertical
    ;  profile display box.
    ;
    x1_time_box = fix(0.10 * draw_size[0])
    y1_time_box = img_loc[1]
    y2_time_box = img_loc[1] + img_size[1]
    x2_time_box = x1_time_box + (y2_time_box - y1_time_box)

    ;  Put the vertical profile box coords in vector
    ;  format for use in the plot routine.
    ;
    time_box = [ x1_time_box, y1_time_box, $
             x2_time_box, y2_time_box ]

    ;  Create an index array for plotting the time profile.
    ;
    time_ind = Indgen(img_size[1])

    ;  Create the coords for the rectangular
    ;  horizontal profile display box.
    ;
    x1_date_box = img_loc[0]
    x2_date_box = img_loc[0] + img_size[0]
    y1_date_box = fix(0.10 * draw_size[1])
    y2_date_box = y1_date_box + img_size[1]

    ;  Put the horizontal profile box coords in vector
    ;  format for use in the plot routine.
    ;
    date_box = [ x1_date_box, y1_date_box, $
             x2_date_box, y2_date_box ]

    RETURN, { draw_size:draw_size, $
          img_size:img_size, $
          img_loc:img_loc, $
          time_box:time_box, $
          date_box:date_box, $
          time_ind:time_ind, $
          ratio:ratio }
End        ;  of d_t_seriesSIZES

;--------------------------------------------------------------------
;
;   PURPOSE : Redraw the surface.
;
pro d_t_seriesSURF, $
    info       ; IN: info structure

    WIDGET_CONTROL, info.ts_base, /HOURGLASS

    WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY
    WIDGET_CONTROL, info.m_slider_value, GET_VALUE=value

    if (value EQ '    ALL    ') then begin
        surf_data = info.data
    endif else begin
        WIDGET_CONTROL, info.main_draw, GET_UVALUE=data, /NO_COPY
        surf_data = data
        WIDGET_CONTROL, info.main_draw, SET_UVALUE=data, /NO_COPY
    endelse

    If (info.axis_toggle EQ 1) then begin
        zrange = [ 0, info.z_max ]
    endif else begin
        zrange = [ image.min_data, image.max_data ]
    endelse

    top = image.max_data * info.scl_ratio
    WSET, info.draw_id

    SHADE_SURF, surf_data, $
        SHADES=Bytscl( surf_data, TOP=top ), $
        AZ=info.az, AX=info.ax, $
        CHARSIZE=1.5, TICKLEN=(-0.02), $
        XSTYLE=1, XTICKS=1, $
        XRANGE=[ 0, (image.n_days - 1) ], $
        XTICKNAME=[ image.min_date_str, image.max_date_str ], $
        YSTYLE=1, YTICKS=4, $
        YTICKNAME=[ '00:00', '06:00', '12:00', '18:00', '24:00' ], $
        ZRANGE=zrange, $
        XTITLE='D A T E', $
        YTITLE='T I M E', $
        ZTITLE='M E G A W A T T S'

    WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
end

;--------------------------------------------------------------------
;
;   PURPOSE :  Handle the events generated from the
;              time series menu bar.
;
pro d_t_seriesMENUEVENT, $
    event         ; IN: event structure

    ;  Get the button value.
    ;
    WIDGET_CONTROL, event.id, GET_VALUE=value

    ;  Check for quit selection.
    ;
    if (value EQ 'Quit') then  begin
        WIDGET_CONTROL, event.top, /DESTROY

        ;  Check for help selection.
        ;
    endif else if (value EQ 'About Time Series') then begin

        ONLINE_HELP, 'd_t_series', $
           book=demo_filepath("idldemo.adp", $
                   SUBDIR=['examples','demo','demohelp']), $
                   /FULL_PATH

    endif else if (value EQ '  Fixed Z Axis') then begin

        WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        info.axis_toggle = 1

        If (info.display_toggle EQ 0) then begin
            WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY
            d_t_seriesDRAW, info, image
            WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
        endif else  begin
            d_t_seriesSURF, info
        endelse

        WIDGET_CONTROL, info.zfixed_bttn, SET_VALUE='* Fixed Z Axis'
        WIDGET_CONTROL, info.zvary_bttn,  SET_VALUE='  Variable Z Axis'
        WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

    endif else if (value EQ '  Variable Z Axis') then begin

        WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        info.axis_toggle = 0

        If (info.display_toggle EQ 0) then begin
            WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY
            d_t_seriesDRAW, info, image
            WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
        endif else  begin
            d_t_seriesSURF, info
        endelse

        WIDGET_CONTROL, info.zfixed_bttn, SET_VALUE='  Fixed Z Axis'
        WIDGET_CONTROL, info.zvary_bttn,  SET_VALUE='* Variable Z Axis'
        WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

    endif else if (value EQ 'Surface') then begin

        WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        WIDGET_CONTROL, info.wSurfaceButton, SENSITIVE=0
        WIDGET_CONTROL, info.wImageButton, SENSITIVE=1
        WIDGET_CONTROL, info.opt_menu, SENSITIVE=1

        WIDGET_CONTROL, info.main_draw, EVENT_PRO='d_t_seriesNONEVENT'
        WIDGET_CONTROL, info.toggle, SET_VALUE='Image'
        WIDGET_CONTROL, info.wSelectionBase[0], MAP=0
        WIDGET_CONTROL, info.wSelectionBase[1], MAP=1
        info.display_toggle = 1

        d_t_seriesSURF, info

        WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

    endif else if (value EQ 'Image') then begin
        WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        WIDGET_CONTROL, info.wSurfaceButton, SENSITIVE=1
        WIDGET_CONTROL, info.wImageButton, SENSITIVE=0
        WIDGET_CONTROL, info.opt_menu, SENSITIVE=0

        WIDGET_CONTROL, info.toggle, SET_VALUE='Surface'
        WIDGET_CONTROL, info.wSelectionBase[0], MAP=1
        WIDGET_CONTROL, info.wSelectionBase[1], MAP=0
        WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY
        info.display_toggle = 0

        d_t_seriesDRAW, info, image

        WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
        WIDGET_CONTROL, info.main_draw, EVENT_PRO='d_t_seriesDRAWEVENT'

        WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

    endif else begin
        RETURN
    endelse

end

;--------------------------------------------------------------------
;
;   PURPOSE :  Convert a long integer date in the form
;              of yymmdd to a string
;              covert to the long integer to a string
;              time series menu bar.
;
function d_t_seriesDATE, $
    date     ; IN: long integer date

    date_str = Strtrim(String(date), 1)

    ;  Get the two year digits.
    ;
    year = Strmid(date_str, 0, 2)

    ;  Get the two month digits & convert to integer.
    ;
    index = Fix(Strmid(date_str, 2, 2))

    ;  Create a string of month names.
    ;
    all_months = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'

    ; Index into the string of month names.
    ;
    month = Strmid(all_months, (index - 1) * 3, 3)

    ;  Get the two day digits.
    ;
    day = Strmid(date_str, 4, 2)

    ;  Return a string in the form: dd mon yy.
    ;
    RETURN, (' ' + day + ' ' + month + ' ' + year)
end

;--------------------------------------------------------------------
;
;   PURPOSE :  Calculate the time of that the current
;              data value was taken based on the
;              the cursor location in the byte scale
;              image, y is the y axis value of the cursor.
;
function d_t_seriesTIME, $
    y, $          ; IN: axis value of the cursor
    y_size, $     ; IN: y size of the image
    ratio         ; IN: display ratio

    ;  Calculate the hour and minute of the data value
    ;  (time series data were collected in half
    ;  hour increments).
    ;
    hour = ( 24L * y ) / y_size

    ;  Minute equals either 0 or 30 since the
    ;  data were taken at half hour increments.
    ;
    minute = (FIX( y / ratio ) mod 2L ) * 30L

    ;  Convert the variables to strings.
    ;
    hour_str = Strtrim( String( hour ), 2 )
    min_str = Strtrim( String( minute ), 2 )

    ;  Add a 0 if necessary.
    ;
    If ( hour LT 10 ) Then hour_str = '0' + hour_str
    If ( minute LT 10 ) Then min_str = '0' + min_str

    ;  Return a time string as HH:MM.
    ;
    RETURN, ' ' + hour_str + ':' + min_str
end

;--------------------------------------------------------------------
;
;   PURPOSE : Find the min and max of the data.
;
function d_t_seriesIMAGE, $
    data, $        ; IN: image data
    date, $        ; IN: date
    img_size, $    ; IN: image size
    scl_ratio      ; IN: scale ratio

    min_data = Min(data)
    max_data = Max(data)

    ;  Resize the time series data.
    ;
    img_data = CONGRID( data, img_size[0], img_size[1] )

    ;  Create the 2-D byte scale image.
    ;
    img_view = BYTSCL( img_data, TOP=(max_data * scl_ratio) )

    ;  Resize the date array to match the data array.
    ;
    img_date = CONGRID( date, img_size[0] )

    ;  Determine the first and last dates,
    ;  convert them to a readable format,
    ;  and add blanks for display positioning.
    ;
    min_date = Min(date)
    max_date = Max(date)
    blanks = '         '
    min_date_str = blanks + d_t_seriesDATE(min_date)
    max_date_str = d_t_seriesDATE(max_date) + blanks

    ;  Determine the number of days within the
    ;  subset of the data.
    ;
    n_days = N_ELEMENTS(data) / 48

    RETURN, { img_data:img_data, $
          img_view:img_view, $
          img_date:img_date, $
          min_data:min_data, $
          max_data:max_data, $
          min_date:min_date, $
          max_date:max_date, $
          min_date_str:min_date_str, $
          max_date_str:max_date_str, $
          n_days:n_days }
end

;--------------------------------------------------------------------
;
;   PURPOSE : Create the color bar legend.
;
pro d_t_seriesLEGEND,  $
    info, $      ; IN: info structure
    image, $     ; IN: image data
    legend_id, $ ; IN: legend identifier
    leg_size     ; IN: legend size

    img = BINDGEN(info.ct_max + 1) # REPLICATE(1B, !D.Y_Size)

    ;  Position the color bar legend.
    ;
    x_leg_pos = FIX(0.50 * (leg_size[0] - (info.ct_max + 1)))

    ;  Display the color bar legend with gray background.
    ;
    WSET, legend_id
    ERASE, info.gray
    TV, img, x_leg_pos, 0

    ;  Calculate the y position of the min & max labels.
    ;
    y_label_pos = fix(0.50 * (leg_size[1] - !D.Y_Ch_Size))

    ;  Label the color bar legend min value.
    ;
    XYOUTS, (x_leg_pos - !D.Y_Ch_Size), y_label_pos, $
        STRTRIM( STRING(image.min_data), 2), $
        COLOR=info.white, FONT=0, ALIGNMENT=(1.0), /DEVICE

    ;  Label the color bar legend max value.
    ;
    XYOUTS, (x_leg_pos + info.ct_max + 1 + !D.Y_Ch_Size), $
        y_label_pos, STRTRIM(STRING(image.max_data), 2), $
        COLOR=info.white, FONT=0, ALIGNMENT=(0.0), /DEVICE

    EMPTY
End

;--------------------------------------------------------------------
;
;   PURPOSE : Event handler for the drawing (viewing) area.
;
pro d_t_seriesDRAWEVENT, $
    event       ; IN: event structure

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    demo_record, event, $
        'd_t_seriesDRAWEVENT', $
        filename=info.record_to_filename

    ;  Calculate the position of the cursor within
    ;  the 2-D image box.
    ;
    x = event.x - info.img_loc[0]
    y = event.y - info.img_loc[1]

    ;  Check to see if the cursor is out of the image box.
    ;
    If (x LT 0) OR (y LT 0) OR $
       (x GE info.img_size[0]) OR $
       (y GE info.img_size[1]) then begin
        WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
        RETURN
    endif

    WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY

    time_data = image.img_data[x, *]
    date_data = image.img_data[*, y]

    WSET, info.draw_id
    DEVICE, COPY=[ 0, 0, !D.X_Size, !D.Y_Size, $
               0, 0, info.copy_id ]
    EMPTY

    if (info.axis_toggle EQ 1) then  begin
        data_range = [ 0, info.z_max ]
    endif else begin
        data_range = [ image.min_data, image.max_data ]
    endelse

    ;  Plot the time profile data.
    ;
    PLOT, TEMPORARY(time_data), info.time_ind, $
        XRANGE=data_range, $
        YRANGE=[0, info.img_size[1] - 1], $
        POSITION=info.time_box, $
        XSTYLE=5, YSTYLE=5, COLOR=info.yellow, $
        /NOERASE, /DEVICE

    ;  Plot the date profile data.
    ;
    PLOT, Temporary(date_data), $
        XRANGE=[0, info.img_size[0] - 1], $
        YRANGE=data_range, $
        POSITION=info.date_box, $
        XSTYLE=5, YSTYLE=5, COLOR=info.yellow, $
        /NOERASE, /DEVICE

    ;  Calculate the x position of the data output.
    ;
    x_label_pos = 0.05 * info.draw_size[0] + 50

    ;  Display the date the cursor is on.
    ;
    XYOUTS, x_label_pos, (0.30 * info.draw_size[1]), $
        d_t_seriesDATE(image.img_date[x]), $
        FONT=0, /DEVICE, COLOR=info.green

    ;  Display the time the cursor is on.
    ;
    XYOUTS, x_label_pos, (0.20 * info.draw_size[1]), $
        d_t_seriesTIME(y, info.img_size[1], info.ratio), $
        FONT=0, /DEVICE, COLOR=info.green

    ;  Display the data value the cursor is on.
    ;
    str = ' ' + STRTRIM(String(image.img_data[x,y]),2)
    XYOUTS, x_label_pos, (0.10 * info.draw_size[1]), $
        str, FONT=0, /DEVICE, COLOR=info.green

    ;  Extend the vertical cross hairs into
    ;  the date profile.
    ;
    PLOTS, [event.x, event.x], [0, !D.Y_Size], $
        COLOR=info.gray, /DEVICE

    ;  Extend the horizontal cross hairs into
    ;  the time profile.
    ;
    PLOTS, [0, !D.X_Size], [event.y, event.y], $
        COLOR=info.gray, /DEVICE

    EMPTY

    WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
    WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
end

;--------------------------------------------------------------------
;
;   PURPOSE : Create the byte scale image of the time series
;             data and the time & date profiles.
;
Pro d_t_seriesDRAW, $
    info, $     ; IN: info structure
    image       ; IN: image

    ;  Display hourglass cursor while
    ;  preparing the draw area.
    ;
    WIDGET_CONTROL, info.ts_base, /HOURGLASS

    ;  Set the main draw area color to gray.
    ;
    WSET, info.copy_id
    ERASE, info.gray

    ;  Display the 2-D byte scale image.
    ;
    TV, image.img_view, info.img_loc[0], info.img_loc[1]

    XYOUTS, (info.img_loc[0]+info.img_size[0]/2.0), $
        (info.img_loc[1]+info.img_size[1]+10), $ ; 10 : above the image
        'Feeder Circuits Power', FONT=0, $
        COLOR=info.white, /DEVICE, ALIGNMENT=0.5

    ;  Create the square background for the
    ;  time profile display.
    ;
    POLYFILL, [ info.time_box[0], info.time_box[2],  $
        info.time_box[2], info.time_box[0] ], $
        [ info.time_box[1], info.time_box[1],  $
        info.time_box[3], info.time_box[3] ], $
        /DEVICE, T3D=0, COLOR=info.black

    ;  Create the rectangular background for the
    ;  date profile display.
    ;
    POLYFILL, [ info.date_box[0], info.date_box[2],  $
        info.date_box[2], info.date_box[0] ], $
        [ info.date_box[1], info.date_box[1],  $
        info.date_box[3], info.date_box[3] ], $
        /DEVICE, T3D=0, COLOR=info.black

    if (info.axis_toggle EQ 1) then begin
        data_range = [ 0, info.z_max ]
    endif else begin
        data_range = [ image.min_data, image.max_data ]
    endelse

    ;  Draw the blue grid for the time profile box
    ;
    PLOT, [0, 0], [0, info.img_size[1]],  /DEVICE, $
        XRANGE=data_range, $
        YRANGE=[0, info.img_size[1]], $
        POSITION=info.time_box, $
        XTICKS=2, YTICKS=2, TICKLEN=1.0, XMINOR=1, $
        YTICKNAME=['00:00', '12:00', '24:00'], $
        XSTYLE=1, YSTYLE=1, XGRIDSTYLE=1, YGRIDSTYLE=1, $
        COLOR=info.blue, FONT=0, /NODATA, /NOERASE

    ;  Draw the white time profile box.
    ;
    PLOT, [0, 0], [0, info.img_size[1]],  /DEVICE, $
        TITLE='Time Profile', XTITLE='MW', $
        XRANGE=data_range, $
        YRANGE=[0, info.img_size[1]], $
        POSITION=info.time_box, $
        XTICKS=2, YTICKS=2, TICKLEN=0.0, XMINOR=1, $
        YTICKNAME=['00:00', '12:00', '24:00'], $
        XSTYLE=1, YSTYLE=1, XGRIDSTYLE=1, YGRIDSTYLE=1, $
        COLOR=info.white, FONT=0, /NODATA, /NOERASE

    ;  Draw the blue grid for the date profile box.
    ;
    PLOT, [0, info.img_size[0]], [0, 0], /DEVICE, $
        XRANGE=[0, info.img_size[0]], $
        YRANGE=data_range, $
        POSITION=info.date_box, $
        XTICKS=1, TICKLEN=1.0, YMINOR=1, $
        XTICKNAME=[image.min_date_str, image.max_date_str], $
        XSTYLE=1, YSTYLE=1, XGRIDSTYLE=1, YGRIDSTYLE=1, $
        COLOR=info.blue, FONT=0, /NOERASE

    ;  Draw the white date profile box.
    ;
    PLOT, [0, info.img_size[0]], [0, 0], /DEVICE, $
        TITLE='Date Profile', YTITLE='MW', $
        XRANGE=[0, info.img_size[0]], $
        YRANGE=data_range, $
        POSITION=info.date_box, $
        XTICKS=1, TICKLEN=0.0, Yminor=1, $
        XTICKNAME=[image.min_date_str, image.max_date_str], $
        XSTYLE=1, YSTYLE=1, XGRIDSTYLE=1, YGRIDSTYLE=1, $
        COLOR=info.white, FONT=0, /NOERASE

    ;  Draw the date, time, and data value labels.
    ;
    XYOUTS, 0.05, 0.30, 'DATE:', FONT=0, $
        COLOR=info.white, /NORMAL
    XYOUTS, 0.05, 0.20, 'TIME:', FONT=0, $
        COLOR=info.white, /NORMAL
    XYOUTS, 0.05, 0.10, 'DATA:', FONT=0, $
        COLOR=info.white, /NORMAL

    EMPTY

    WSET, info.draw_id
    DEVICE, COPY=[ 0, 0, !D.X_Size, !D.Y_Size, $
               0, 0, info.copy_id ]
    EMPTY
end

;--------------------------------------------------------------------
;
;   PURPOSE : Handle the events from the X & Z
;             rotation slider bars for the time
;             series surface plot.
;
pro d_t_seriesROTATIONEVENT, $
    event              ; IN: event structure

    ;  Get info from the ts_base widget.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE=info, /No_copy

    ;  Get the string id of the slider bar.
    ;
    WIDGET_CONTROL, event.id, GET_UVALUE=uvalue

    ;  Get the current slider bar value.
    ;
    WIDGET_CONTROL, event.id, GET_VALUE=value

    ;  Check to see which rotation slider bar
    ;  generated the event and modify the
    ;  value that info holds on to.
    ;
    If (uvalue EQ 'z_slider') then begin
        info.az = value
    endif else begin       ; 'x_slider'
        info.ax = value
    endelse

    ;  Replot the time series surface.
    ;
    d_t_seriesSURF, info

    ;  Replace info back into the ts_base widget.
    ;
    WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
end

;--------------------------------------------------------------------
;
;   PURPOSE :  Handle the no event
;
pro d_t_seriesNONEVENT, $
    event         ; IN: event structure

end

;--------------------------------------------------------------------
;
;   PURPOSE :  Handle Surface/Image button event.
;
pro d_t_seriesTOGGLEEVENT, $
    event         ; IN: event structure

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    demo_record, event, 'd_t_seriesTOGGLEEVENT', $
        filename=info.record_to_filename

    WIDGET_CONTROL, event.id, GET_VALUE=value

    if (value EQ 'Surface') then begin
        WIDGET_CONTROL, info.main_draw, EVENT_PRO='d_t_seriesNONEVENT'
        WIDGET_CONTROL, event.id, SET_VALUE='Image'
        WIDGET_CONTROL, info.wSelectionBase[0], MAP=0
        WIDGET_CONTROL, info.wSelectionBase[1], MAP=1
        WIDGET_CONTROL, info.wSurfaceButton, SENSITIVE=0
        WIDGET_CONTROL, info.opt_menu, SENSITIVE=1
        WIDGET_CONTROL, info.wImageButton, SENSITIVE=1
        info.display_toggle = 1

        d_t_seriesSURF, info

    endif else begin
        WIDGET_CONTROL, event.id, SET_VALUE='Surface'
        WIDGET_CONTROL, info.wSelectionBase[0], MAP=1
        WIDGET_CONTROL, info.wSelectionBase[1], MAP=0
        WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY
        WIDGET_CONTROL, info.wSurfaceButton, SENSITIVE=1
        WIDGET_CONTROL, info.opt_menu, SENSITIVE=0
        WIDGET_CONTROL, info.wImageButton, SENSITIVE=0
        info.display_toggle = 0

        d_t_seriesDRAW, info, image

        WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
        WIDGET_CONTROL, info.main_draw, EVENT_PRO='d_t_seriesDRAWEVENT'
    endelse

    WIDGET_CONTROL, event.top, SET_UVALUE=info, /No_copy
end

;--------------------------------------------------------------------
;
;   PURPOSE :  Convert a long integer date in the form
;              of yymmdd to a string
;              covert to the long integer to a string
;
function d_t_seriesMONTH_STR, $
    date       ; IN: long integer date

    date_str = Strtrim(String(date), 1)

    ;  Get the two year digits.
    ;
    year = STRMID(date_str, 0, 2)

    ;  Get the two month digits & convert to integer.
    ;
    index = FIX(Strmid(date_str, 2, 2))

    ;  Create a string of month names.
    ;
    all_months = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'

    ;  Index into the string of month names.
    ;
    month = STRMID(all_months, (index - 1) * 3, 3)

    ;  Return a string in the form: mon yy
    ;  pad with spaces because of alignment bug.
    ;
    RETURN, (' ' + month + ' ' + year + ' ')
end

;--------------------------------------------------------------------
;
;   PURPOSE :  Handle the events from the d_t_seriesSTRSLIDER
;              allow the user to select which month to
;              display data from.
;
pro d_t_seriesMONTHEVENT, $
    event         ; IN: event structure

    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    demo_record, event, 'd_t_seriesMONTHEVENT', $
        filename=info.record_to_filename

    WIDGET_CONTROL, info.draw_base, GET_UVALUE=image, /NO_COPY

    ;  If slider value is 0 then use data from all months
    ;  else use data from a specific month.
    ;
    If (event.value EQ 0) then begin
        WIDGET_CONTROL, info.m_slider_value, SET_VALUE='    ALL    '
        image = d_t_seriesIMAGE(info.data, info.date, $
            info.img_size, info.scl_ratio)
    endif else begin
        date = info.date[info.uniq_months[event.value - 1]]
        WIDGET_CONTROL, info.m_slider_value, $
            SET_VALUE=d_t_seriesMONTH_STR(date)

        month = (date / 100L) * 100L

        if (event.value LT N_ELEMENTS(info.uniq_months)) then begin
            next_date = info.date[info.uniq_months[event.value]]
            next_month = (next_date / 100L) * 100L
            index = WHERE(info.date GT month AND $
                info.date LT next_month)
        endif else begin
            index = WHERE(info.date GT month)
        endelse

        days = info.date[index]
        new_data = info.data[index, *]

        image = d_t_seriesIMAGE(new_data, days, $
            info.img_size, info.scl_ratio)

        WIDGET_CONTROL, info.main_draw, SET_UVALUE=new_data, /NO_COPY
    endelse

    if (info.display_toggle EQ 0) then begin
        d_t_seriesDRAW, info, image
        WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
    endif else begin
        WIDGET_CONTROL, info.draw_base, SET_UVALUE=image, /NO_COPY
        d_t_seriesSURF, info
    endelse

    WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
end

;--------------------------------------------------------------------
;
;   PURPOSE :  Create a compound slider widget with the
;              slider value centered above the slider bar
;              and the title centered under the bar.
;              the slider value can be displayed as a string
;
function d_t_seriesSTRSLIDER, $
    parent, $                  ; IN: parent identifer
    Value=value, $             ; IN: (opt) value
    Title=title, $             ; IN: (opt) title
    Minimum=minimum, $         ; IN: (opt) minimum value
    Maximum=maximum, $         ; IN: (opt) maximum value
    Event_Pro=event_pro, $     ; IN: (opt) slider event handler
    XOffset=xoffset, $         ; IN: (opt) x offset
    YOffset=yoffset, $         ; IN: (opt) y offset
    Uname=uname, $
    Slider_Value=slider_value  ; IN: (opt) slider value id

    ;  Make sure a parent id has been supplied.
    ;
    if (N_Params() EQ 0) then $
        Message, "d_t_seriesSTRSLIDER: parent widget id required."

    ;  Check the initial value.
    ;
    if (N_ELEMENTS(value) NE 1) then value = 0

    ;  Check the initial value.
    ;
    If N_ELEMENTS(title) NE 1 Then title = ' '

    ;  Check the minimum and maximum values.
    ;
    If N_ELEMENTS(minimum) NE 1 Then minimum = 0
    If N_ELEMENTS(maximum) NE 1 Then maximum = 1

    ;  Check for max < min.
    ;
    if (maximum LE minimum) then $
      Message, "d_t_seriesSTRSLIDER: maximum value < minimum value."

    ;  Check for an event procedure.
    ;
    if (N_ELEMENTS(event_pro) NE 1) then $
      Message, "d_t_seriesSTRSLIDER: event procedure is required."

    ;  Check the offsets.
    ;
    if N_ELEMENTS(xoffset) NE 1 then xoffset = 0
    if N_ELEMENTS(yoffset) NE 1 then yoffset = 0

    ;  Create the base for the CW.
    ;
    slider_base = WIDGET_BASE(parent, $
        XOFFSET=xoffset, $
        YOFFSET=yoffset, $
        /BASE_ALIGN_CENTER, $
        /COLUMN )

    ;  Create the slider value label.
    ;
    slider_value = WIDGET_LABEL(slider_base, $
        VALUE=value, /ALIGN_CENTER)

    ;  Create the actual slider bar.
    ;
    slider_bar = WIDGET_SLIDER(slider_base, $
        EVENT_PRO=event_pro, /SUPPRESS_VALUE, $
        MINIMUM=minimum, MAXIMUM=maximum )
    if N_ELEMENTS(uname) gt 0 then $
        WIDGET_CONTROL, slider_bar, SET_UNAME=uname

    ;  Create the title for the slider bar.
    ;
    slider_title = WIDGET_LABEL(slider_base, VALUE=title)

    Return, slider_base
End

;--------------------------------------------------------------------
;
;  Purpose :  Event Procedure
;
pro d_t_seriesQuitEvent, $
    sEvent

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=info, /NO_COPY
    demo_record, sEvent, 'd_t_seriesQuitEvent', filename=info.record_to_filename
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=info, /NO_COPY

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif
end

;--------------------------------------------------------------------
;
;  Purpose :  Cleanup procedure, restore the previous color table.
;
pro d_t_seriesCleanup, wTopBase

    ;  Get the color table saved in the window's user value
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=Info, /NO_COPY

    ;  Restore the previous color table.
    ;
    TVLCT, Info.colorTable

    if WIDGET_INFO(Info.groupBase, /VALID_ID) then $
        WIDGET_CONTROL, Info.groupBase, /MAP

end   ; of d_t_seriesCleanup

;----------------------------------------------------------
;
;  Purpose :  Display a time series (Images , plot).
;
;  Description :
;         Modified version of the time series analysis
;         procedure in the IDL 4.0.1 Demo.
;         Just one data set is used: 16 Megawatt, 660 Volts.
;         It also reduces the number of windows involved in
;         the demo (just one that toggles between the image
;         and surface displays).
;
pro d_t_series, $
    GROUP=group, $  ; IN: (opt) group identifer
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB=appTLB   ; IN: (opt) Top level base of this main procedure

    ;  Check the validity of the group identifier.
    ;
    ngroup = N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check = WIDGET_INFO(group, /VALID_ID)
        if (check NE 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Return to the main application'
            RETURN
        endif
        groupBase = group
    endif else groupBase = 0L

    ;  Get the current color table. It will be restored when exiting.
    ;
    TVLCT, savedR, savedG, savedB, /GET
    colorTable = [[savedR],[savedG],[savedB]]

    ;  Make sure this program is not already running.
    ;
    if (Xregistered('D_T_SERIES')) then RETURN

    ;  Check for the existence of the data file.
    ;
    filename = demo_filepath('mgwt6616.dat', $
        SUBDIR=['examples','demo','demodata'])
    found = FILE_SEARCH(filename)
    if (found[0] EQ '') then begin
        error = DIALOG_MESSAGE($
            ['You must install the time series data', $
             'before you can run this demonstration.'], $
            /Error)
        RETURN
    endif

    ;  Initialize the graphics by creating a
    ;  non-visible (pixmap) window and deleting it.
    ;
    WINDOW, /FREE, /PIXMAP, XSIZE=100, YSIZE=100
    WDELETE

    ;  Load the data.
    ;
    data = d_t_seriesREAD(filename)

    ;  Make the system to have a maximum of 256 colors.
    ;
    numcolors = !D.N_COLORS

    if ((( !D.NAME EQ 'X') OR (!D.NAME EQ 'MAC')) $
       AND (!D.N_COLORS GE 256L)) then begin
       DEVICE, PSEUDO_COLOR=8
    endif

    DEVICE, DECOMPOSED=0, BYPASS_TRANSLATION = 0

    ;  Create custom color table.
    ;
    colors = d_t_seriesCOLOR()

    ;  Determine monitor resolution.
    ;
    Device, Get_Screen=sc_size

    ;  Set the size and locations of plots, etc,
    ;  Within the draw area.
    ;
    sizes = d_t_seriesSIZES(sc_size)

    ;  Create the top level base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        ts_base = $
            WIDGET_BASE( $
            TITLE='Time Series: Feeder Circuits Power in Megawatts', $
            TLB_FRAME_ATTR=1, $
            /TLB_KILL_REQUEST_EVENTS, $
            SPACE=1, XPAD=1, YPAD=1, /COLUMN, MBAR=mbar, $
            UNAME='D_T_SERIES:tlb')
    endif else begin
        ts_base = $
            WIDGET_BASE( $
            TITLE='Time Series: Feeder Circuits Power in Megawatts', $
            GROUP_LEADER=group, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1, $
            SPACE=1, XPAD=1, YPAD=1, /COLUMN, MBAR=mbar, $
            UNAME='D_T_SERIES:tlb')
    endelse

        ;  Create the "File" menu.
        ;
        file_menu = WIDGET_BUTTON(mbar, Value='File', /MENU)

        ;  Create the quit button.
        ;
        quit_bttn = WIDGET_BUTTON(file_menu, VALUE='Quit', $
            EVENT_PRO='d_t_seriesMENUEVENT')

        ;  Create the "Options" menu.
        ;
        opt_menu = WIDGET_BUTTON(mbar, Value='Options', /MENU)

            ;  Create the z axis range buttons which
            ;  tell the surface routine to use a
            ;  fixed z axis or to let it vary as the
            ;  months change.
            ;
            zfixed_bttn = WIDGET_BUTTON(opt_menu, $
                VALUE='  Fixed Z Axis', EVENT_PRO='d_t_seriesMENUEVENT')

            zvary_bttn = WIDGET_BUTTON(opt_menu, $
                VALUE='* Variable Z Axis', EVENT_PRO='d_t_seriesMENUEVENT')

        ;  Create the View menu.
        ;
        wViewButton= WIDGET_BUTTON(mbar, Value='View', /MENU)

            wSurfaceButton = WIDGET_BUTTON(wViewButton, $
                VALUE='Surface', EVENT_PRO='d_t_seriesMENUEVENT', $
                UNAME='D_T_SERIES:surface')

            wImageButton = WIDGET_BUTTON(wViewButton, $
                VALUE='Image', EVENT_PRO='d_t_seriesMENUEVENT', $
                UNAME='D_T_SERIES:image')

        ;  Create the "Help" menu.
        ;
        help_menu = WIDGET_BUTTON(mbar, VALUE='About', /HELP, /MENU)

            ;  Create the help button.
            ;
            help_bttn = WIDGET_BUTTON(help_menu, $
                VALUE='About Time Series', $
                EVENT_PRO='d_t_seriesMENUEVENT')

        ;  Create the drawing area within the ts_base.
        ;
        draw_base = WIDGET_BASE(ts_base, SPACE=1, XPAD=1, YPAD=1)

            ;  Create the main drawing area.
            ;
            main_draw = WIDGET_DRAW(draw_base, $
                XSIZE=sizes.draw_size[0], $
                YSIZE=sizes.draw_size[1], $
                EVENT_PRO='d_t_seriesDRAWEVENT', $
                /MOTION_EVENTS, $
                UNAME='D_T_SERIES:draw', $
                RETAIN=2 )

            ;  Create the main drawing area in memory.
            ;
            copy_draw = WIDGET_DRAW(draw_base, $
                XSIZE=sizes.draw_size[0], $
                YSIZE=sizes.draw_size[1], $
                RETAIN=2 )

        ;  Create the bottom area of the top level base
        ;
        bottom_ysize = 4 * !D.Y_Ch_Size
        bottom_base = WIDGET_BASE(ts_base, /ROW, $
            /BASE_ALIGN_CENTER)

            ;  Create a base for the toggle button.
            ;
            toggleBase = WIDGET_BASE(bottom_base, $
               /BASE_ALIGN_CENTER, /ROW)

                ;  Create the image / surface toggle button.
                ;
                toggle = WIDGET_BUTTON( toggleBase, $
                    EVENT_PRO='d_t_seriesTOGGLEEVENT', $
                    VALUE='Surface',$
                    UNAME='D_T_SERIES:toggle' )

            ;  Create a base for the month slider.
            ;
            mSliderBase = WIDGET_BASE(bottom_base, /COLUMN)

                ;  Create month slider bar.
                ;
                m_slider = d_t_seriesSTRSLIDER( mSliderbase, $
                    EVENT_PRO='d_t_seriesMONTHEVENT', $
                    MINIMUM=0, $
                    MAXIMUM=N_Elements(data.uniq_months), $
                    VALUE='    ALL    ', $
                    TITLE='Month', $
                    SLIDER_VALUE=m_slider_value, $
                    UNAME='D_T_SERIES:monthslider' )

            ;  Create a base for the surface or image options
            ;
            wSelectionBase = LONARR(2)   ; 2 is the number of selections
            wTempBase = WIDGET_BASE(bottom_base)

                ;  Put the selection bases into the temporary (temp)
                ;  base. This way, the selection bases overlaps each
                ;  another. When the user select from the toggle button,
                ;  (Surface / image),
                ;  only one selection base is mapped.
                ;
                for i=0, N_ELEMENTS(wSelectionbase)-1 do  begin
                    wSelectionbase[i] = WIDGET_BASE(wTempBase, $
                    UVALUE=0L, /COLUMN, MAP=0)
                endfor

                    ;  Create the base for rotation slider bars.
                    ;  Use the same offsets as the legend area.
                    ;
                    rot_base = WIDGET_BASE(wSelectionBase[1], /ROW)

                        ;  Create the z rotation slider bar
                        ;  for the surface plot.
                        ;
                        z_base = WIDGET_BASE(rot_base, /COLUMN)

                            z_slider = WIDGET_SLIDER(z_base, $
                                EVENT_PRO='d_t_seriesROTATIONEVENT', $
                                MINIMUM=0, $
                                MAXIMUM=90, $
                                VALUE=15, $
                                UVALUE='z_slider', $
                                TITLE='    Z Rotation' )

                        ;  Create the z rotation slider bar
                        ;  for the surface plot.
                        ;
                        x_base = WIDGET_BASE(rot_base, /COLUMN)
                            x_slider = WIDGET_SLIDER(x_base, $
                                EVENT_PRO='d_t_seriesROTATIONEVENT', $
                                MINIMUM=0, $
                                MAXIMUM=90, $
                                VALUE=60, $
                                UVALUE='x_slider', $
                                TITLE='    X Rotation' )

                    ;  Set the legend area offset.
                    ;
                    leg_offset = [ FIX(0.40 * sizes.draw_size[0]), $
                                   FIX(0.10 * bottom_ysize) ]

                    ;  Create the legend base (so it can be unmapped).
                    ;
                    legend_base = WIDGET_BASE(wSelectionBase[0], /ROW)

                        ;  Set the size of the legend area.
                        ;
                        leg_size = [ FIX(0.65 * sizes.draw_size[0]), $
                                     FIX(0.80 * bottom_ysize) ]

                        ;  Create the legend area.
                        ;
                        legend_draw = WIDGET_DRAW(legend_base, $
                            XSIZE=leg_size[0], $
                            YSIZE=leg_size[1], $
                            RETAIN=2 )

    ;  Realize the time series base.
    ;
    WIDGET_CONTROL, ts_base, /REALIZE

    ;  Returns the top level base to the APPTLB keyword.
    ;
    appTLB = ts_Base

    ;  Map the surface option base as default.
    ;
    WIDGET_CONTROL, wSelectionBase[0], MAP=1

    ;  Get the id of the display seen on screen.
    ;
    WIDGET_CONTROL, main_draw, GET_VALUE=draw_id

    ;  Get the id of the display seen on screen.
    ;
    WIDGET_CONTROL, copy_draw, GET_VALUE=copy_id

    ;  Get the id of the legend area.
    ;
    WIDGET_CONTROL, legend_draw, GET_VALUE=legend_id

    ;  Scale ratio is used to make sure that the
    ;  TOP keyword is set so that a data value
    ;  always gets the same color shade.
    ;
    scl_ratio = float(colors.ct_max) / float(data.z_max)

    ;  Create the 2-D byte scale image.
    ;
    image = d_t_seriesIMAGE(data.array, data.date, $
        sizes.img_size, scl_ratio)

    if n_elements(record_to_filename) eq 0 then $
        record_to_filename = ''

    ;  Create a structure that contains all the
    ;  info needed by the subroutines and event
    ;  handlers.
    ;
    info = { data:data.array, $            ; Time series data set
         date:data.date, $                 ; Dates
         z_max:data.z_max, $               ; Maximum of time series
         uniq_months:data.uniq_months, $   ; Each months
         ct_max:colors.ct_max, $           ; Number of colors
         white:colors.white, $             ; Color indices
         yellow:colors.yellow, $
         green:colors.green, $
         red:colors.red, $
         blue:colors.blue, $
         gray:colors.gray, $
         black:colors.black, $
         draw_size:sizes.draw_size, $      ; Drawing area size
         img_size:sizes.img_size, $        ; Image size
         img_loc:sizes.img_loc, $          ; Image location
         time_box:sizes.time_box, $        ; Size of time box
         date_box:sizes.date_box, $        ; Size of date box
         time_ind:sizes.time_ind, $        ; Size of time index frame
         ratio:sizes.ratio, $              ; Size ratio of data set
         ts_base:ts_base, $                ; Top level base ID
         draw_base:draw_base, $            ; Draw base ID
         legend_base:legend_base, $        ; Legen base ID
         rot_base:rot_base, $              ; Rotation base ID
         main_draw:main_draw, $            ; Main draw windget ID
         draw_id:draw_id, $                ; Secondary draw windget ID
         copy_id:copy_id, $                ; Copy widget draw ID
         zfixed_bttn:zfixed_bttn, $        ; Flag for fixed
         zvary_bttn:zvary_bttn, $          ; Variable z aixis button ID
         m_slider_value:m_slider_value, $  ; Month slider ID
         ax:60, az:15, $                   ; Initial rotation of x and z aixes
         scl_ratio:scl_ratio, $            ; Color/data scale ratio
         axis_toggle:0, $                  ; Z axis: 0 = fixed, 1=variable
         ColorTable: colorTable, $         ; Color table to restore
         WSelectionBase: wSelectionBase, $ ; Selection base ID
         WSurfaceButton: wSurfaceButton, $ ; Button IDs
         WImageButton: wImageButton, $
         Toggle: toggle, $
         opt_menu: opt_menu, $
         record_to_filename: record_to_filename, $;  Used for the IDL Demo Tour
         display_toggle:0, $               ; display: 0 = image, 1 = surface
         groupBase: groupBase $            ; Base of Group Leader
    }

    ;  Create & draw the color bar legend.
    ;
    d_t_seriesLEGEND, info, image, legend_id, leg_size

    ;  Draw the byte scale image and the
    ;  date & time profiles of the data.
    ;
    d_t_seriesDRAW, info, image

    ;  Store the image info separate from the
    ;  info structure so it can be changed
    ;  by the month slider event handler.
    ;
    WIDGET_CONTROL, draw_base, Set_UVALUE=image

    ;  Store the image info in the top level base.
    ;
    WIDGET_CONTROL, ts_base, SET_UVALUE=info, /NO_COPY

    ;  Place the cursor on the image by default.
    ;
    if (!Version.Os_Family NE 'MacOS') then begin
       TVCRS, sizes.img_loc[0] + 20, sizes.img_loc[1] + 20
    endif

    ;  Desensitize the image button.
    ;  and the option menu
    ;
    WIDGET_CONTROL, wImageButton, SENSITIVE=0
    WIDGET_CONTROL, opt_menu, SENSITIVE=0

    ;  Tell the window manager about time series.
    ;
    XMANAGER, 'D_T_SERIES', ts_base, $
        /NO_BLOCK, $
        EVENT_HANDLER='d_t_seriesQuitEvent', $
        CLEANUP='d_t_seriesCleanup'
End
