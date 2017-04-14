;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_plot2d.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_plot2d.pro
;
;  CALLING SEQUENCE: d_plot2d
;
;  PURPOSE:
;       This example demonstrates features of 2-D plots.
;
;  MAJOR TOPICS: Plotting
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_plot2dMakeLine                -  Make a line plot
;       pro d_plot2dMakeSymbol              -  Make a plot with symbols
;       pro d_plot2dMakeBar                 -  Make a histogram plot (bar)
;       pro d_plot2dMakePolar               -  Make a polar plot
;       pro d_plot2dMakeLogLog              -  Make a log-log plot
;       pro d_plot2dMakeSemiLog             -  Make a semi-log plot
;       pro d_plot2dEvent                   -  Event handler
;       pro d_plot2dCleanup                 -  Cleanup
;       pro d_plot2d                        -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       pro demo_puttips        - Change tips text
;       plot2d.tip
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       95,   Dan Carr   - Written.
;       11/95,   DAT     - Modified for IDL 5.0 demo
;-
;--------------------------------------------------------------------
;
;   PURPOSE  Create a line plot
;
pro d_plot2dMakeLine, $
    WindowID, $     ; IN: window Identifier
    periods         ; IN: period of the damped sine wave

    WSET, windowID
    x = Float(periods) * 2.0 * !PI * Findgen(400) / 399.0
    y = 4.0 * !PI * Sin(x) / (x + 1.0)
    PLOT, x, y, YRANGE=[-3.0, 6.0], XSTYLE=1, YSTYLE=1, TICKLEN=(1.0), $
        BACKGROUND=0, COLOR=8, TITLE="DAMPED SINE WAVE", /NODATA, $
        YTITLE='Y',  XTITLE='X', $
        POSITION=[0.15, 0.25, 0.9, 0.75]
    OPLOT, x, y, THICK=3, COLOR=3
    Empty


end     ;  of d_plot2dMakeLine

;--------------------------------------------------------------------
;
;   PURPOSE  Create a scatter plot with symbols
;
pro d_plot2dMakeSymbol, $
    WindowID, $     ; IN: window Identifier
    Variance, $     ; IN: vdata variance
    symbol, $       ; IN: symbol integer identifier
    X=x, $          ; OUT: x data
    Y=y             ; OUT: y data

    symbolSize = 1.5
    if (symbol eq 3) then begin
        symbolSize = 50.0
    endif
    WSET, windowID
    if (N_ELEMENTS(x) eq 0) then begin
        x = FLTARR(40)
        x = FINDGEN(40)
        y = SIN( !pi * 2.0 * x/10.0) + RANDOMN(Seed, 40)* variance
    endif else if (x[1] eq 0.0) then begin
        x = FLTARR(40)
        x = FINDGEN(40)
        y = SIN( !pi * 2.0 * x/10.0) + RANDOMN(Seed, 40)* variance
    endif

    PLOT, x, y, XTITLE='X', YTITLE='Y', $
        PSYM=symbol, $
        YSTYLE=1, YRANGE=[-4, 4], $
        TITLE='Scatter plot with symbols', /NODATA, COLOR=3

    PLOT, x, y, XTITLE='X', YTITLE='Y', $
        PSYM=symbol, $
        XSTYLE=4, YSTYLE=5, YRANGE=[-4, 4], $
        THICK=2.0, $
        COLOR=5, /NOERASE, SYMSIZE=symbolSize

end     ;  of d_plot2dMakeSymbol

;--------------------------------------------------------------------
;
;   PURPOSE  Create a bar plot
;
pro d_plot2dMakeBar, $
    WindowID, $     ; IN: window Identifier
    Variance        ; IN: vdata variance

    WSET, windowID
    x = FLTARR(40)
    x = FINDGEN(40)
    y = SIN( !pi * 2.0 * x/12.0) + RANDOMN(Seed, 40)*variance
    PLOT, x, y, XTITLE='X', YTITLE='Y', $
        YSTYLE=1, YRANGE=[-4, 4], $
        TITLE='Bar plot', /NODATA, COLOR=3

    PLOT, x, y, XTITLE='X', YTITLE='Y', $
        PSYM=10, $
        XSTYLE=4, YSTYLE=5, YRANGE=[-4, 4], $
        THICK=3.0, $
        COLOR=2, /NOERASE, SYMSIZE=1.5

end     ;  of d_plot2dMakeBar

;--------------------------------------------------------------------
;
;   PURPOSE  Create a polar plot
;
pro d_plot2dMakePolar, $
    WindowID, $        ; IN: window Identifier
    COLOR = color, $   ; IN: color index (corresponds to TEK_COLOR)
    RADIUS= radius, $  ; IN: radius array data
    New = new          ; IN:  1: create new data

    WSET, windowID
    theta = FINDGEN(41) *!pi / 20.0
    x = FINDGEN(41)
    if (N_ELEMENTS(new) eq 1) then begin
        radius = ABS(SIN( !pi * 2.0 * x/100.0) + RANDOMU(Seed, 41)*2.0)
        radius[40] = radius[0]
    endif

    PLOT, /POLAR, radius, theta, TITLE='Polar plot', $
        COLOR=3, /NODATA, $
        XSTYLE=1, YSTYLE=1, $
        XTITLE='X', YTITLE='Y', $
        XRANGE=[-3.0, 3.0], YRANGE=[-3.0, 3.0]

    PLOTS, [0.0, 0.0], [-3.0, 3.0], COLOR=3
    PLOTS, [-3.0, 3.0], [0.0, 0.0], COLOR=3

    PLOT, /POLAR, radius, theta,  $
        PSYM=-4, $
        THICK=3.0, $
        XTITLE='X', YTITLE='Y', $
        XSTYLE=5, YSTYLE=5, COLOR=color, /NOERASE, $
        XRANGE=[-3.0, 3.0], YRANGE=[-3.0, 3.0]

end     ;  of d_plot2dMakePolar

;--------------------------------------------------------------------
;
;   PURPOSE  Create a bar plot
;
pro d_plot2dMakeLogLog, $
    WindowID, $             ; IN: window Identifier
    Thickness= thickness, $ ; IN: window Identifier
    X=x, $                  ; IN/OUT: x data
    Y=y, $                  ; IN/OUT: y data
    New = new               ; IN: if new create new data

    WSET, windowID
    x = FLTARR(40)
    z = FINDGEN(40)
    x = EXP( z/5.0)
    if (N_ELEMENTS(new) eq 1) then begin
         y = EXP( (z + RANDOMU(Seed, 40)*6.0) / 10.0)
    endif
    PLOT, x, y, XTITLE='X', YTITLE='Y', /YLOG, /XLOG, $
        TITLE='Log-Log plot', /NODATA, COLOR=3

    PLOT, x, y, XTITLE='X', YTITLE='Y', $
        YSTYLE=4, XSTYLE=4, /YLOG, /XLOG, $
        THICK=thickness, $
        COLOR=5, /NOERASE

end     ;  of d_plot2dMakeLogLog

;--------------------------------------------------------------------
;
;   PURPOSE  Create a bar plot
;
pro d_plot2dMakeSemiLog, $
    WindowID     ; IN: window Identifier

    WSET, windowID
    x = FLTARR(40)
    x = FINDGEN(40)
    y = EXP( (x + RANDOMU(Seed, 40)*6.0) / 10.0)
    PLOT, x, y, XTITLE='X', YTITLE='Y', /YLOG, $
        TITLE='Semi-Log plot', /NODATA, COLOR=3

    PLOT, x, y, XTITLE='X', YTITLE='Y', $
        YSTYLE=4, XSTYLE=4, /YLOG, $
        THICK=3.0, $
        COLOR=2, /NOERASE

end     ;  of d_plot2dMakeSemiLog


;--------------------------------------------------------------------
;
;  PURPOSE   Event handler
;
pro d_plot2dEvent, $
    sEvent      ; IN: event structure

    WIDGET_CONTROL, sEvent.top, get_uvalue=state, /no_copy
    demo_record, sEvent, $
        'd_plot2dEvent', $
        filename=state.record_to_filename, $
        cw=state.wSelectButton
    WIDGET_CONTROL, sEvent.top, set_uvalue=state, /no_copy

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    case eventUValue of

        ;  Show the apporpriate plots from the radio button list.
        ;
        'SELECT' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY

            WSET, sInfo.drawWindowID
            case sEvent.value of

                ;  Show the damped sine curve.
                ;
                0 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[0], MAP=1
                    WIDGET_CONTROL, sInfo.wGenerateButton, SENSITIVE=0
                    sInfo.currentBase = sInfo.wSelectionBase[0]

                    device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                        0, 0, sInfo.pixmapArray[0]]
                    demo_putTips, sInfo, 'perio', 12, /LABEL

                end

                ;  Show the symbols plot.
                ;
                1 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[1], MAP=1
                    WIDGET_CONTROL, sInfo.wGenerateButton, SENSITIVE=1
                    sInfo.currentBase = sInfo.wSelectionBase[1]
                    device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                        0, 0, sInfo.pixmapArray[1]]
                    WIDGET_CONTROL, sInfo.wSymbolSlider, GET_VALUE=variance
                    variance = FLOAT(variance)/5.0
                    symbolString = String(variance, Format='(F3.1)')
                    WIDGET_CONTROL, sInfo.wSymbolLabel, $
                        SET_VALUE=symbolString
                    demo_putTips, sInfo, 'symbo', 12, /LABEL
                end

                ;  Show the bar plot.
                ;
                2 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[2], MAP=1
                    WIDGET_CONTROL, sInfo.wGenerateButton, SENSITIVE=1
                    sInfo.currentBase = sInfo.wSelectionBase[2]
                    device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                        0, 0, sInfo.pixmapArray[2]]
                    WIDGET_CONTROL, sInfo.wBarSlider, GET_VALUE=variance
                    variance = FLOAT(variance)/5.0
                    barString = String(variance, Format='(F3.1)')
                    WIDGET_CONTROL, sInfo.wBarLabel, $
                        SET_VALUE=barString
                    demo_putTips, sInfo, 'varia', 12, /LABEL
                end

                ;  Show the polar plot (with color selection).
                ;
                3 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[3], MAP=1
                    WIDGET_CONTROL, sInfo.wGenerateButton, SENSITIVE=1
                    sInfo.currentBase = sInfo.wSelectionBase[3]
                    device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                        0, 0, sInfo.pixmapArray[3]]
                    demo_putTips, sInfo, 'color', 12, /LABEL
                end

                ;  Show the log-log plot (with line thickness selection).
                ;
                4 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[4], MAP=1
                    WIDGET_CONTROL, sInfo.wGenerateButton, SENSITIVE=1
                    sInfo.currentBase = sInfo.wSelectionBase[4]
                    device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                        0, 0, sInfo.pixmapArray[4]]
                    demo_putTips, sInfo, 'thick', 12, /LABEL
                end

                ;  Show the semi-log plot (with text location selection).
                ;
                5 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[5], MAP=1
                    WIDGET_CONTROL, sInfo.wGenerateButton, SENSITIVE=1
                    WIDGET_CONTROL, sInfo.wXLocSlider, GET_VALUE=xlocation
                    WIDGET_CONTROL, sInfo.wYLocSlider, GET_VALUE=ylocation
                    xlocation = FLOAT(xlocation)/10.0
                    ylocation = FLOAT(ylocation)/10.0
                    sInfo.currentBase = sInfo.wSelectionBase[5]
                    device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                        0, 0, sInfo.pixmapArray[5]]
                    WSET, sInfo.drawWindowID
                    XYOUTS, xlocation, ylocation, 'TEXT', COLOR=1, /NORMAL
                    demo_putTips, sInfo, 'locat', 12, /LABEL
                end

            endcase

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  SELECT

        ;  Generate a new data set.
        ;
        'GENERATE' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
            WIDGET_CONTROL, sInfo.wPeriodSlider, GET_VALUE=period
            WIDGET_CONTROL, sInfo.wSymbolSlider, GET_VALUE=variance
            WIDGET_CONTROL, sInfo.wLogLogSlider, GET_VALUE=thickness
            WIDGET_CONTROL, sInfo.wBarSlider, GET_VALUE=barVariance
            variance = FLOAT(variance)/5.0
            barVariance = FLOAT(barVariance)/5.0
            thickness = FLOAT(thickness)

            d_plot2dMakeLine, sInfo.pixmapArray[0], period

            symbol = WIDGET_INFO(sInfo.wSymbolList, /LIST_SELECT) + 1
            xdata = sInfo.xdata
            ydata = sInfo.ydata
            xdata[1] = 0.0
            d_plot2dMakeSymbol, sInfo.pixmapArray[1], variance, symbol, $
                X=xdata, Y=ydata
            sInfo.xdata = xdata
            sInfo.ydata = ydata

            d_plot2dMakeBar, sInfo.pixmapArray[2], barVariance

            color = WIDGET_INFO(sInfo.wPolarList, /LIST_SELECT) + 1
            d_plot2dMakePolar, sInfo.pixmapArray[3], $
                COLOR=color, RADIUS=sInfo.radius, /NEW

            x = sInfo.xLogLog
            y = sInfo.yLogLog
            d_plot2dMakeLogLog, sInfo.pixmapArray[4], THICKNESS= thickness, $
                X=x, Y=y, /NEW
            sInfo.xLogLog = x
            sInfo.yLogLog = y

            d_plot2dMakeSemiLog, sInfo.pixmapArray[5]

            ;  Redraw the current selection
            ;
            WIDGET_CONTROL, sInfo.wSelectButton, GET_VALUE=selectValue
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[selectValue]]
            if (selectValue eq 5) then begin  ; if Semi log, show text
                WIDGET_CONTROL, sInfo.wXLocSlider, GET_VALUE=xlocation
                WIDGET_CONTROL, sInfo.wYLocSlider, GET_VALUE=ylocation
                xlocation = FLOAT(xlocation)/10.0
                ylocation = FLOAT(ylocation)/10.0
                WSET, sInfo.drawWindowID
                XYOUTS, xlocation, ylocation, 'TEXT', COLOR=1, /NORMAL
            endif

            WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  GENERATE

        ;  Select a new period of the damped sine curve and
        ;  display it.
        ;
        'PERIOD' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wPeriodSlider, GET_VALUE=period
            d_plot2dMakeLine, sInfo.pixmapArray[0], period
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[0]]
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  PERIOD

        ;  Redraw the symbol plot with the selected symbol.
        ;
        'SYMBOL' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wSymbolSlider, GET_VALUE=variance
            symbol = WIDGET_INFO(sInfo.wSymbolList, /LIST_SELECT) + 1
            variance = FLOAT(variance)/5.0
            xdata = sInfo.xdata
            ydata = sInfo.ydata
            xdata[1] = 0.0
            d_plot2dMakeSymbol, sInfo.pixmapArray[1], variance, symbol, $
                X=xdata, Y=ydata
            sInfo.xdata = xdata
            sInfo.ydata = ydata
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[1]]
            symbolString = String(variance, Format='(F3.1)')
            WIDGET_CONTROL, sInfo.wSymbolLabel, $
                SET_VALUE=symbolString
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  PERIOD

        ;  Redraw the symbol plot with the selected symbol.
        ;
        'SYMBOLLIST' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wSymbolSlider, GET_VALUE=variance
            symbol = WIDGET_INFO(sInfo.wSymbolList, /LIST_SELECT) + 1
            variance = FLOAT(variance)/5.0
            xdata = sInfo.xdata
            ydata = sInfo.ydata
            d_plot2dMakeSymbol, sInfo.pixmapArray[1], variance, symbol, $
                X=xdata, Y=ydata
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[1]]
            symbolString = String(variance, Format='(F3.1)')
            WIDGET_CONTROL, sInfo.wSymbolLabel, $
                SET_VALUE=symbolString
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  SYMBOLLIST

        ;  Redraw the polar plot with the selected color.
        ;
        'POLARLIST' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            color = WIDGET_INFO(sInfo.wPolarList, /LIST_SELECT) + 1
            d_plot2dMakePolar, sInfo.pixmapArray[3], $
                COLOR=color, RADIUS=sInfo.radius
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[3]]
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  POLARLIST

        ;  Redo the bar (histogram) plot.
        ;
        'BAR' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wBarSlider, GET_VALUE=variance
            variance = FLOAT(variance)/5.0
            d_plot2dMakeBar, sInfo.pixmapArray[2], variance
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[2]]
            barString = String(variance, Format='(F3.1)')
            WIDGET_CONTROL, sInfo.wBarLabel, $
                SET_VALUE=barString
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  BAR

        ;  Redraw the log-log plot with the selected line thickness.
        ;
        'THICKNESS' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wLogLogSlider, GET_VALUE=thickness
            thickness = FLOAT(thickness)
            x = sInfo.xLogLog
            y = sInfo.yLogLog
            d_plot2dMakeLogLog, sInfo.pixmapArray[4], THICKNESS= thickness, $
                X=x, Y=y
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[4]]
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  THICKNESS


        ;  Redraw the semi-log plot with the selected text
        ;  x location.
        ;
        'XLOCATION' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wXLocSlider, GET_VALUE=xlocation
            WIDGET_CONTROL, sInfo.wYLocSlider, GET_VALUE=ylocation
            xlocation = FLOAT(xlocation)/10.0
            ylocation = FLOAT(ylocation)/10.0
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[5]]
            WSET, sInfo.drawWindowID
            XYOUTS, xlocation, ylocation, 'TEXT', COLOR=1, /NORMAL
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  XLOCATION

        ;  Redraw the semi-log plot with the selected text
        ;  y location.
        ;
        'YLOCATION' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wXLocSlider, GET_VALUE=xlocation
            WIDGET_CONTROL, sInfo.wYLocSlider, GET_VALUE=ylocation
            xlocation = FLOAT(xlocation)/10.0
            ylocation = FLOAT(ylocation)/10.0
            WSET, sInfo.drawWindowID
            Device, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, 0, 0, $
                sInfo.pixmapArray[5]]
            WSET, sInfo.drawWindowID
            XYOUTS, xlocation, ylocation, 'TEXT', COLOR=1, /NORMAL
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end   ;   of  YLOCATION

        ;  Quit this application.
        ;
        'QUIT' : begin
            WIDGET_CONTROL, sEvent.top, /DESTROY
        end

        ;  Display the information text file.
        ;
        'ABOUT' : begin
            ONLINE_HELP, 'd_plot2d', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
        end           ;  of ABOUT


        ELSE :   ;  do nothing

    endcase
end

;--------------------------------------------------------------------
;
;    PURPOSE  cleanup procedure.
;
pro d_plot2dCleanup, $
    wTopBase       ; IN: top level base

    ;  Get the color table saved in the window's user value
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sInfo,/No_Copy

    ;  Restore the previous color table.
    ;
    TVLCT, sInfo.colorTable

    ;  Restore the previous plot font.
    ;
    !P.FONT = sInfo.plotFont

    ;  Delete the pixmap
    ;
    for i = 0, sInfo.nPixmap-1 do begin
        WDELETE, sInfo.pixmapArray[i]
    endfor

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sInfo.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sInfo.groupBase, /MAP

end   ; of d_plot2dCleanup

;--------------------------------------------------------------------
;
;   PURPOSE : Plot several 2-D plots.
;
pro d_plot2d, $
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

    ;  Check the validity of the group identifier.
    ;
    ngroup = N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check = widget_INFO(group, /valid)
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

    ;  Also save the font.
    ;
    plotFont = !P.FONT

    ;  Load a new color table.
    ;
    LOADCT, 12, /SILENT
    TEK_COLOR

    ;  Use hardware-drawn font.
    ;
    !P.FONT=0

    ;  Determine hardware display size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize
    drawXSize = 0.6 * screenSize[0]
    drawYSize = 0.8 * drawXSize

    ;  Create the starting up message.
    ;
    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
    endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse

    ;  Get the character scaling factor.
    ;
    charscale = 8.0/!d.X_CH_SIZE

    filterLength = 32

    ;  Create the widgets.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(TITLE="Two Dimensional Plotting", $
            /COLUMN, $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            UNAME='d_plot2d:tlb', $
            TLB_FRAME_ATTR = 1, MBAR=barBase)
    endif else begin
        wTopBase = WIDGET_BASE(TITLE="Two Dimensional Plotting", $
            GROUP_LEADER=group, $
            /COLUMN, $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            UNAME='d_plot2d:tlb', $
            TLB_FRAME_ATTR = 1, MBAR=barBase)
    endelse

        ;  Create the menu bar items.
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE='File')

            wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                UVALUE='QUIT', UNAME='d_plot2d:quit')

        wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About 2-D Plotting', $
                UVALUE='ABOUT')

        ;  Create the left and right bases.
        ;
        wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2)

            wLeftBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                wSelectButton = CW_BGROUP(wLeftBase, $
                    ['Line', 'Symbols', 'Bar', $
                    'Polar with Symbols', 'Log-Log', 'Semi-Log'], $
                    UVALUE='SELECT', /EXCLUSIVE,/NO_RELEASE)
                WIDGET_CONTROL, wSelectButton, SET_UNAME='d_plot2d:radio'

                wGenerateBase = WIDGET_BASE(wLeftBase, /COLUMN, $
                    YPAD=0)

                    wGenerateButton = WIDGET_Button(wGenerateBase, $
                        VALUE='Generate New Data', UVALUE='GENERATE', $
                        UNAME='d_plot2d:generate')


                ;  Create a base for each options.
                ;
                wSelectionBase = LONARR(6)   ; 6 is the number of selections
                wTempBase = WIDGET_BASE(wLeftbase)

                    ;  Put the selection bases into the temporary (temp)
                    ;  base. This way, the selection bases overlaps each
                    ;  another. When the user select from wSelectButton,
                    ;  only one selection base is mapped.
                    ;
                    for i=0, N_ELEMENTS(wSelectionbase)-1 do  begin
                        wSelectionbase[i] = WIDGET_BASE(wTempBase, $
                        UVALUE=0L, /COLUMN, MAP=0, YPAD=0)
                    endfor

                        ;  Line plot base (for damped sine wave)  .
                        ;
                        wLineBase = WIDGET_BASE(wSelectionBase[0], $
                            /COLUMN, /FRAME)

                            wPeriodSlider = WIDGET_SLIDER(wLineBase, $
                                MINIMUM=1, MAXIMUM=32, $
                                VALUE=8, $
                                UNAME='d_plot2d:sine_period', $
                                TITLE='Period', UVALUE='PERIOD')

                        ;  Scatter plot base (Symbols).
                        ;
                        wSymbolBase = WIDGET_BASE(wSelectionBase[1], $
                            /COLUMN, /FRAME)

                            wSub1Base = WIDGET_BASE(wSymbolBase, $
                            /COLUMN)

                                wSymbolLabel = WIDGET_LABEL(wSub1Base, $
                                    VALUE='1.0')

                                wSymbolSlider = WIDGET_SLIDER(wSub1Base, $
                                    MINIMUM=0, MAXIMUM=10, $
                                    VALUE=5, /SUPPRESS_VALUE, $
                                    UNAME='d_plot2d:symbolslider', $
                                    TITLE='Variance', UVALUE='SYMBOL')

                            wSub2Base = WIDGET_BASE(wSymbolBase, $
                            /COLUMN)

                                wSymbolList = WIDGET_LIST(wSub2Base, $
                                    VALUE=['Plus sign (+)', $
                                    'Asterisk (*)', $
                                    'Period (.)', $
                                    'Diamond' , $
                                    'Triangle' , $
                                    'Square'] , $
                                    YSIZE=3, $
                                    UNAME='d_plot2d:symbollist', $
                                    UVALUE='SYMBOLLIST')

                                wListLabel = WIDGET_LABEL(wSub2Base, $
                                    VALUE='Symbol selection')


                        ;  Bar plot base (histogram).
                        ;
                        wBarBase = WIDGET_BASE(wSelectionBase[2], $
                            /COLUMN, /FRAME)

                            wSub3Base = WIDGET_BASE(wBarBase, $
                            /COLUMN, YPAD=0)

                                wBarLabel = WIDGET_LABEL(wSub3Base, $
                                    VALUE='1.0')

                                wBarSlider = WIDGET_SLIDER(wSub3Base, $
                                    MINIMUM=0, MAXIMUM=10, $
                                    VALUE=5, /SUPPRESS_VALUE, $
                                    UNAME='d_plot2d:barplot_variance', $
                                    TITLE='Variance', UVALUE='BAR')

                        ;  Polar base base.
                        ;
                        wPolarBase = WIDGET_BASE(wSelectionBase[3], $
                            /COLUMN, /FRAME)

                            wSub4Base = WIDGET_BASE(wPolarBase, $
                            /COLUMN, YPAD=0)

                                wPolarList = WIDGET_LIST(wSub4Base, $
                                    VALUE=['White', $
                                    'Red', $
                                    'Green', $
                                    'Blue' , $
                                    'Cyan' , $
                                    'Magenta' , $
                                    'Yellow' , $
                                    'Orange'] , $
                                    YSIZE=3, $
                                    UNAME='d_plot2d:polarcolors', $
                                    UVALUE='POLARLIST')

                                wPolarLabel = WIDGET_LABEL(wSub4Base, $
                                    VALUE='Color selection')

                        ;  Log-Log base.
                        ;
                        wLogLogBase = WIDGET_BASE(wSelectionBase[4], $
                            /COLUMN, /FRAME)

                            wSub5Base = WIDGET_BASE(wLogLogBase, $
                            /COLUMN, YPAD=0)

                                wLogLogSlider = WIDGET_SLIDER(wSub5Base, $
                                    MINIMUM=1, MAXIMUM=5, $
                                    VALUE=3, $
                                    TITLE='Thickness selection', $
                                    UNAME='d_plot2d:loglog_thick', $
                                    UVALUE='THICKNESS')

                        ;  Seemi-Log base.
                        ;
                        wSemiLogBase = WIDGET_BASE(wSelectionBase[5], $
                            /COLUMN, /FRAME)

                            wSub6Base = WIDGET_BASE(wSemiLogBase, $
                            /COLUMN)

                                wSemiLogLabel = WIDGET_LABEL(wSub6Base, $
                                    VALUE='Text location')

                                wXLocSlider = WIDGET_SLIDER(wSub6Base, $
                                    MINIMUM=1, MAXIMUM=9, $
                                    VALUE=3, $
                                    TITLE='X', $
                                    /SUPPRESS_VALUE, $
                                    UNAME='d_plot2d:text_x_loc', $
                                    UVALUE='XLOCATION')

                                wYLocSlider = WIDGET_SLIDER(wSub6Base, $
                                    MINIMUM=1, MAXIMUM=9, $
                                    VALUE=7, $
                                    TITLE='Y', $
                                    /SUPPRESS_VALUE, $
                                    UNAME='d_plot2d:text_y_loc', $
                                    UVALUE='YLOCATION')

            wRightBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                wAreaDraw = WIDGET_DRAW(wRightBase, XSIZE=drawXSize, $
                    YSIZE=drawYSize, RETAIN=2)

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ; Returns the top level base to the APPTLB keyword.
    ;
    appTLB = wtopBase

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('plot2d.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)

    WIDGET_CONTROL, wSelectButton, SET_VALUE=0

    period = 8
    WIDGET_CONTROL, wPeriodSlider, SET_VALUE=period

    WIDGET_CONTROL, wSymbolList, SET_LIST_SELECT=1
    WIDGET_CONTROL, wPolarList, SET_LIST_SELECT=6

    variance = 1.0
    symbol = 2     ; asterisk as symbol

    ; Determine the window value of plot window, wDraw1.
    ;
    WIDGET_CONTROL, wAreaDraw, GET_VALUE=drawWindowID

    ;  Create 3 pixmaps.
    ;
    nPixmap = 6
    pixmapArray = LONARR(nPixmap)
    for i = 0, nPixmap-1 do begin
        Window, /FREE, XSIZE=drawXSize, YSIZE=drawYSize, /PIXMAP
        pixmapArray[i] = !D.Window
    endfor

    xdata = FLTARR(40)
    ydata = FLTARR(40)
    xLogLog = FLTARR(40)
    yLogLog = FLTARR(40)
    radius = FLTARR(41)
    xdata[1] = 0.0
    d_plot2dMakeLine, pixmapArray[0], period
    d_plot2dMakeSymbol, pixmapArray[1], variance, symbol, X=xdata, Y=ydata
    d_plot2dMakeBar, pixmapArray[2], variance
    d_plot2dMakePolar, pixmapArray[3], COLOR=7, RADIUS=radius, /NEW ;  color is yellow
    d_plot2dMakeLogLog, pixmapArray[4], THICKNESS=3.0, $
        X=xLogLog, Y=yLogLog, /NEW
    d_plot2dMakeSemiLog, pixmapArray[5]

    ;  Make the line plot the default view
    ;
    WSET, drawWindowID
    Device, COPY=[0, 0, drawXSize, drawYSize, 0, 0, $
        pixmapArray[0]]
    WIDGET_CONTROL, wSelectionBase[0], MAP=1

    if n_elements(record_to_filename) eq 0 then $
        record_to_filename = ''

    ;  Create the info structure
    ;
    sInfo = { $
        Xdata: xdata, $                    ; X and Y data set for symbols
        Ydata: ydata, $
        XLogLog: xLogLog, $                ; X and Y data set for log-log plot
        YLogLog: yLogLog, $
        RADIUS:radius, $                   ; Radius for polar plot
        CurrentBase: wSelectionBase[0], $  ; Current selection base
        DrawXSize: drawXSize, $            ; X and Y size of drawing area
        DrawYSize: drawYSize, $
        ColorTable:colorTable, $           ; Color table to restore
        CharScale: charScale, $            ; Character scaling factor
        NPixmap: nPixmap, $                ; Number of pixmaps
        PixmapArray: pixmapArray, $        ; Pixmap array IDs
        DrawWindowID: drawWindowID, $      ; Window ID
        WTopBase: wTopBase, $              ; Top level base
        WSelectButton: wSelectButton, $    ; Selection button ID
        WGenerateButton: wGenerateButton, $; Generate button ID
        WSelectionBase: wSelectionBase, $  ; Selection base ID
        WPeriodSlider: wPeriodSlider, $    ; Sliders IDs
        WSymbolSlider: wSymbolSlider, $
        WLogLogSlider: wLogLogSlider, $
        WBarSlider: wBarSlider, $
        WXLocSlider: wXLocSlider, $
        WYLocSlider: wYLocSlider, $
        WSymbolList: wSymbolList, $        ; Widget list Ids
        WPolarList: wPolarList, $
        WSymbolLabel: wSymbolLabel, $      ; Symblo label ID
        SText: sText, $                    ; Text structure for tips
        WBarLabel: wBarLabel, $            ; Bar plot label ID
        plotFont: plotFont, $              ; Font to restore
        record_to_filename: record_to_filename, $
        groupBase: groupBase $             ; Base of Group Leader
    }

    ;  Register the info structure.
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=sInfo, /NO_COPY

    ;  Desensitize the generate button at start up.
    ;
    WIDGET_CONTROL, wGenerateButton, SENSITIVE=0

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1

    ;  Register with the BIG GUY, XMANAGER!
    ;
    XMANAGER, "d_plot2d", wTopBase, /NO_BLOCK, $
        EVENT_HANDLER = "d_plot2dEvent",CLEANUP="d_plot2dCleanup"

end                      ; of D_Plot2d
