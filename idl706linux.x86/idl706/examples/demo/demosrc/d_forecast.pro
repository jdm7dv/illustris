; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_forecast.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_forecast.pro
;
;  CALLING SEQUENCE: d_forecast
;
;  PURPOSE:
;       Shows forecast of a data set.
;
;  MAJOR TOPICS: Statistics and widget.
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_forecastAutoCorr       - Compute the autocorrelation function
;       pro d_forecastAutoFCast      - Compute the autoforecast function
;       fun d_forecastTsData         - Create a time series.
;       pro d_forecastEvent          - Event handler
;       pro d_forecastCleanup        - Cleanup
;       pro d_forecast               - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       forecast.tip
;
;  REFERENCE: The Analysis of Time Series, An Introduction (Fourth Edition)
;             Chapman and Hall
;             ISBN 0-412-31820-2
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY: Written by:  GGS, RSI, January 1995
;                        Modified by DAT,RSI,  July 1996 New GUI
;                        Remove common blocs.
;-
;--------------------------------------------------------------------
;
;   PURPOSE  Compute and plot the autocorrelation function.
;
pro d_forecastAutoCorr, $
    event        ; IN: event structure
 
    ;  Get the info structure.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  This call-back function computes the sample autocorrelation function
    ;  and the 95% confidence interval of cYdata. The results are plotted in
    ;  the draw window, cPwindow2.

    currentYMargin = !Y.MARGIN
    !Y.Margin = [3, currentYMargin[1]]

    ;  Set the active plot window to cPwindow2.
    ; 
    WSET, info.cPwindow2

    ;  Compute the sample autocorrelation function of cYdata for the time 
    ;  indexes, [0, 1, 2, ... , cNy-2].
    ;
    autocorrY = A_CORRELATE(info.cYdata, INDGEN(info.cNy-1))

    ;  Compute the 95% confidence interval for cYdata.
    ;
    conf = 1.96 / SQRT(info.cNy)

    ;  Establish the plotting coordinate system.
    ;
    PLOT, autocorrY, YSTYLE=1, YMINOR=1, YTICKLEN=-0.008, $
        YTICKS=1, $
        YRANGE = [-1.0, 1.0], $
        LINESTYLE=0, COLOR=0, BACKGROUND=1, $
        YTITLE='!7r!x', XTITLE='Time Lag', $
        TITLE="Time-Series Sample Autocorrelation", /NODATA

    ;  Overplot the sample autocorrelation function of cYdata.
    ;
    OPLOT, autocorrY, COLOR=4

    ;  Plot the upper confidence interval limit line.
    ;
    PLOTS, 0, conf, COLOR=0
    PLOTS, info.cXmax, conf, COLOR=0, LINESTYLE=5, /CONTINUE

    ;  Plot the lower confidence interval limit line.
    ;
    PLOTS, 0, -conf, COLOR=0
    PLOTS, info.cXmax, -conf, COLOR=0, LINESTYLE=5, /CONTINUE

    ;  Restore the information structure.
    ;
    WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

    !Y.Margin = currentYMargin

end  ; of d_forecastAutoCorr

;--------------------------------------------------------------------
;
;   PURPOSE  Compute the auto forecast function.
;
pro d_forecastAutoFCast, $
    event         ; IN: event structure

    ;  Get the info structure.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE = info, /NO_COPY

    ;  Make sure that the margin are set right.
    ;
    !Y.MARGIN= [6.0, 2.0]
    !X.MARGIN= [10.0, 3.0]

    ;  This call-back function computes the
    ;  autoregressive forecasting model 
    ;  of the time-series data, cYdata.
    ;  The time-series data and forecasts 
    ;  are plotted in the draw window, cPwindow1.

  
    ;  Compute (cNfcast) forecasts using a model of order (cOrder).
    ;
    info.cFuture = TS_FCAST(info.cYdata, info.cOrder, info.cNfcast) 

    ;  Set the active plot window to cPwindow1.
    ;
    WSET, info.cPwindow1

    ;  Establish the plotting coordinate system.
    ;
    PLOT, info.cXdata, info.cYdata, $
        YTITLE='Y', XTITLE='Time', $
        XRANGE=[0, info.cXmax+info.cFcastmax], XSTYLE=2,$ 
        YRANGE=[info.cYmin-1, info.cYmax+1], YSTYLE=2, $
        YMINOR=1, YTICKLEN=-0.008, LINESTYLE=0,  $
        CHARSIZE=1.0*info.charscale, COLOR=0, BACKGROUND=1, /NODATA

    ;  Overplot the time-series data with a "diamond" symbol.
    ;
    OPLOT, info.cXdata, info.cYdata, PSYM=4, SYMSIZE=2, COLOR=4

    ;  Overplot the forecast data with a "triangle" symbol.
    ;
    OPLOT, [info.cXmax+indgen(info.cNfcast)+1], info.cFuture, $
        PSYM=5, SYMSIZE=1.5, COLOR=2

    ;  Compute a smooth spline fit to the
    ;  time-series and forecast data by
    ;  increasing the number of points by a factor(fac).
    ;
    fac = 10
    xint = FINDGEN(fac*MAX(info.cXdata+info.cNfcast)+1) / fac
    yint = SPLINE(FINDGEN(info.cNy+info.cNfcast), $
        [info.cYdata,info.cFuture], xint, 0.1)

    ;  Overplot the time-series and forecast data with the spline fit.
    ;     
    OPLOT, xint, yint, LINESTYLE=0, COLOR=0

    ;  Create a symbol legend using the NORMAL coordinate system.
    ;  Plot a "diamond" symbol.  
    ;  Set Y position 1/3 of the way between the lower edge of the 
    ;  window and the plot window.
    ;
    ypos = !Y.WINDOW[0] / 3.0
    PLOTS, 0.18, ypos+0.01, PSYM=4, SYMSIZE=2, COLOR=4, /NORMAL

    ;  Plot the corresponding label.
    ; 
    XYOUTS, 0.20, ypos, "Time-Series Data", COLOR=0, /NORMAL

    ;  Plot a "triangle" symbol.
    ;
    PLOTS, 0.58, ypos+0.015, PSYM=5, SYMSIZE=1.5, COLOR=2, /NORMAL

    ;  Plot the corresponding label.
    ;
    XYOUTS, 0.60, ypos, "Autoregressive Forecasts", COLOR = 0, /NORMAL

    ;  Restore the info structure.
    ;
    WIDGET_CONTROL, event.top, SET_UVALUE = info, /NO_COPY

end  ; of d_forecastAutoFCast

;--------------------------------------------------------------------
;
;   PURPOSE  Generate a time series data.
;
function d_forecastTsData, $
    RANDOM = random    ; IN: (opt) Generate a random time series.
 
    ;  This call-back function defines either
    ;  a pseudo-random or static time-series.

    ;  Create a pseudo-random time-series.
    ;
    if (KEYWORD_SET(random) NE 0) then begin
       cYdata = SMOOTH(RANDOMN(seed, 41) * RANDOMU(seed, 41) * 50, 5) 
    endif else begin

       ; Uniformly sampled time-series data.
       ;
       cYdata = $
           [66.85, 67.08, 70.79, 69.90, 66.76, 67.43, 65.92, 66.31, $
            67.12, 67.18, 65.05, 66.40, 65.54, 66.08, 65.39, 66.51, $
            67.25, 69.12, 68.45, 68.57, 69.57, 67.05, 67.41, 65.81, $
            67.70, 67.92, 69.67, 68.20, 67.72, 67.56, 65.30, 65.46, $
            63.41, 64.98, 66.03, 66.80, 66.79, 65.96, 67.47, 69.02, $
                                                             69.88]
    endelse

    cNy = N_ELEMENTS(cYdata)  ; Number of time-series points.
    cXdata = LINDGEN(cNy)     ; Indexed time intervals, [0, 1, 2, ... , Cny-1].
    cXmax = MAX(cXdata)       ; Maximum x value.
    cYmax = MAX(cYdata)       ; Maximum y value.
    cYmin = MIN(cYdata)       ; Minimum y value.
    cFcastmax = cNy - 1       ; Maximum number of forecasts.
    
    ;  Define the inside structure for this function.
    ;
    insideStr={cYdata:cYdata, $
        cNy:cNy, $
        cXdata:cXdata,$
        cXmax:cXmax,$
        cYmax:cYmax,$
        cYmin:cYmin,$
        cFcastmax:cFcastmax }
              
    ;  Return the insideStr which contains the data information.
    ;
    RETURN, insideStr
   
end   ; of d_forecastTsData

;--------------------------------------------------------------------
;
;   PURPOSE  Handle the forecasting events.
;
pro d_forecastEvent, event

    ;  Handle the 'close' or 'Quit' event for the
    ;  close box.
    ;
    if (TAG_NAMES(event, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, event.top, /DESTROY
        RETURN
    endif

    ;  This procedure is the event handler.
    ;  Get the info structure from top-level base.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
   
    ;  Determine which event.
    ; 
    WIDGET_CONTROL, event.id, GET_UVALUE=eventval

    ;  Take the following action based on the corresponding event.
    ;
    CASE eventval OF

        "GenerateTS" :  begin
            ;  Desensitize the buttons
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=0 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=0
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=0
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=0
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=0
       
            ;  Activate the HOURGLASS cursor to indicate 
            ;  a computationally intensive event.
            ;
            WIDGET_CONTROL, info.wGenerateButton, /HOURGLASS
 
            ;  Generate a pseudo-random time-series.
            ;
            TSdataStr=d_forecastTsData(/random)
                       
            ;  Copy the TSdataStr into the info structure.
            ;
            info.cYdata=TSdataStr.cYdata      
            info.cXdata=TSdataStr.cXdata      
            info.cYmax=TSdataStr.cYmax        
            info.cXmax=TSdataStr.cXmax        
            info.cYmin=TSdataStr.cYmin        
            info.cNy=TSdataStr.cNy            
            info.cFcastmax=TSdataStr.cFcastmax
 
            ;  Compute the autoregressive forecasting model.
            ; 
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_forecastAutoFCast, event

            ;  Compute the sample autocorrelation function.
            ;
            d_forecastAutoCorr, event
        
            ;  Get the info structure.
            ;
            WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        
            ;  Sensitize the buttons.
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=1 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=1
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=1
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=1
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=1
                      
            ;  Restore the info structure.
            ;
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
 
        end    ;   of GenerateTS
 
        "INFO" : begin
        
            ; Desensitize the buttons
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=0 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=0
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=0
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=0
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=0
        
            ;  Display the information file.
            ;
            ONLINE_HELP, 'd_forecast', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH

            ; Sensitize the buttons.
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=1 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=1
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=1
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=1
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=1
            
            ;  Restore the info structure.
            ;
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
      
        end     ;   of   INFO
                   
         "QUIT" :    begin
     
            ;  Restore the info structure before destroying event.top.
            ;
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
                   
            ;  Destroy widget hierarchy.
            ;
             WIDGET_CONTROL, event.top, /DESTROY
         
        end     ;   of   QUIT

        "SETOrder" :   begin
        
            ;  Desensitize the buttons.
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=1 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=0
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=0
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=0
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=0
        
            ;  Determine the order of the forecasting model.
            ;
            WIDGET_CONTROL, info.wOrderSlider, GET_VALUE=cOrder
                info.cOrder=cOrder
                      
            ;  Compute the forecast using a model of order (cOrder).
            ;
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_forecastAutoFCast, event
            WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        
            ;  Sensitize the buttons.
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=1 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=1
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=1
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=1
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=1
                      
            ;  Restore the info structure.
            ; 
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
        
        END

        "SETNumber" :  begin
     
            ;  Desensitize the buttons.
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=0 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=1
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=0
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=0
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=0
        
            ;  Determine the number of the forecasts.
            ;
            WIDGET_CONTROL, info.wNumberSlider, GET_VALUE=cNfcast
               info.cNfcast=cNfcast
                      
            ;  Compute (cNfcast) forecasts.
            ;
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_forecastAutoFCast, event
            WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY
        
            ;  Sensitize the buttons.
            ;
            WIDGET_CONTROL, info.wOrderSlider, SENSITIVE=1 
            WIDGET_CONTROL, info.wNumberSlider, SENSITIVE=1
            WIDGET_CONTROL, info.wAboutButton, SENSITIVE=1
            WIDGET_CONTROL, info.wGenerateButton, SENSITIVE=1
            WIDGET_CONTROL, info.wQuitButton, SENSITIVE=1
                      
            ;  Restore the info structure .
            ;
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
        
        end
     
    endcase
   
end      ;    of  d_forecastEvent

;--------------------------------------------------------------------
;
;   PURPOSE  : Cleanup procedure.
;
pro d_forecastCleanup, wTop

    ;  Get the color table saved in the window's user value.
    ;
    WIDGET_CONTROL, wTop, GET_UVALUE=info, /NO_COPY
   
    ;  Restore the previous color table.
    ;
    TVLCT, info.colorTable

    ;  Restore the previous plot font.
    ;
    !P.FONT = info.plotFont

    ;  Restore the !X and !Y system variables.
    ;
    !X = info.previousX
    !Y = info.previousY

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(info.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, info.groupBase, /MAP

end   ; of d_forecastCleanup

;--------------------------------------------------------------------
;
;   PURPOSE  Forecast main procedure.
;
pro d_forecast, $
    GROUP=group, $   ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

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

    ;  Make the system to have a maximum of 256 colors.
    ;
    numcolors = !d.N_COLORS

    if ((( !D.NAME EQ 'X') OR (!D.NAME EQ 'MAC')) $
       AND (!D.N_COLORS GE 256L)) then begin
       DEVICE, PSEUDO_COLOR=8
    endif

    DEVICE, DECOMPOSED=0, BYPASS_TRANSLATION = 0

    ;  Get the current color table, retore it when exiting.
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ;  Store the previuous !Y and !X settings. They
    ;  will be restores when exiting this application.
    ;
    previousY = !Y
    previousX = !X

    ;  Build color table from color vectors.
    ;
    colorTable = [[savedR],[savedG],[savedB]]

    ;  Save the current plot font in order to restore it when
    ;  the spiro application is exited.
    ;
    plotFont = !P.FONT

    ;  Get the screen size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize

    ;  Create the starting up message.
    ;
    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
    endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse

    ;  Call the d_forecastTsData FUNCTION to initialize the data that are
    ;  contained in the structure TSdataStr.
    ;
    TSdataStr=d_forecastTsData()

    ;  Define the initial forecasting parameters.
    ;
    cOrder = 25       ; order of the model
    cNfcast = 40      ; number of forecasts
  
    ;  Load a predefined color tabel.
    ;
    LOADCT, 12, /SILENT
    TEK_COLOR, 0, 8

    ;  Use harware-drawn font.
    ;
    !P.FONT=0

    ;  Define a main widget base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(TITLE="Time-Series Forecasting Tool",  $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            /COLUMN, $
            TLB_FRAME_ATTR=1, Mbar=bar_base)
    endif else begin
        wTopBase = WIDGET_BASE(TITLE="Time-Series Forecasting Tool",  $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            /COLUMN, $
            GROUP_LEADER=group, $
            TLB_FRAME_ATTR=1, Mbar=bar_base)
    endelse

        ;  Create the file|quit button.
        ;
        wFileButton = WIDGET_BUTTON(bar_base, VALUE='File', /MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Quit', UVALUE='QUIT')

        ;  Create the help|about button.
        ;
        wHelpButton = WIDGET_BUTTON(bar_base, /HELP, VALUE='About', /MENU)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Forecasting', UVALUE='INFO')

        ;  Create the first child of the top level base(wTop).
        ; 
        wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2, /FRAME)

            ;  Create a base for the left column.
            ;
            wLeftBase = WIDGET_BASE(wTopRowBase, $
                /BASE_ALIGN_CENTER, /COLUMN)

                ;  Put the 2 sliders
                ;  and the widget labels into a base here.
                ;
                wParamBase = WIDGET_BASE(wLeftBase, /COLUMN, /FRAME, $
                   /BASE_ALIGN_CENTER, YPAD = 15)
   
                    wLabel1ID = WIDGET_LABEL(wParamBase, $
                       VALUE="Forecasting")

                    wLabel1bID = WIDGET_LABEL(wParamBase, $
                       VALUE="Parameters")

                    wLabel2ID = WIDGET_LABEL(wLeftBase, VALUE=" ")

                    ;  Define a slider widget to adjust the order
                    ;  of the forecasting model.
                    ;
                    wOrderSlider = WIDGET_SLIDER(wParamBase, MIN=2, $
                        MAX=TSdataStr.cFcastmax, VALUE=cOrder,$
                        UVALUE="SETOrder", $
                        TITLE="Order of the Model")

                    ;  Define a slider widget to adjust 
                    ;  the number of forecasts.
                    ;
                    wNumberSlider = WIDGET_SLIDER(wParamBase, $
                       MIN=1, MAX=TSdataStr.cFcastmax, $
                       VALUE=cNfcast, $
                       UVALUE="SETNumber", $
                       TITLE="Number of Forecasts")

                ;  Define a button widget to generate 
                ;  a pseudo-random time-series.
                ;
                wGenerateBase = WIDGET_BASE(wLeftBase, /COLUMN) 

                    wGenerateLabel = WIDGET_LABEL(wGenerateBase, $
                        VALUE='Generate new data')

                    wGenerateButton = WIDGET_BUTTON(wGenerateBase, $
                        VALUE="Generate", $
                        UVALUE="GenerateTS")

            ;  Create a base for the right column.
            ;
            wRightBase = WIDGET_BASE(wTopRowBase, Column=1)

               ;  Define a draw widget with a horizontal dimension
               ;  that is 650% of the  horizontal hardware display size and 
               ;  a vertical dimension that is 30%
               ;  of the horizontal hardware display size.
               ;
               wDraw1ID = WIDGET_DRAW(wRightBase, XSIZE=0.65*screenSize[0],  $
                  YSIZE=0.34*screenSize[0], RETAIN=2)

               ;  Define a draw widget with a horizontal dimension 
               ;  that is 40% of the horizontal hardware display size
               ;  and a vertical dimension that is 20%
               ;  of the horizontal hardware display size.
               ;
               wDraw2ID = WIDGET_DRAW(wRightBase, XSIZE=0.65*screenSize[0], $
                   YSIZE=0.19*screenSize[0], RETAIN=2)

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ; Here,  all the widget has been created.

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wTopBase

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('forecast.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)

    ;  Setup the device to use the pointer cursors.
    ;
    DEVICE, /CURSOR_ORIGINAL

    ;  Determine the window value of plot window, wDraw1.
    ;
    WIDGET_CONTROL, wDraw1ID, GET_VALUE=cPwindow1

    ;  Determine the window value of plot window, wDraw2.
    ;
    WIDGET_CONTROL, wDraw2ID, GET_VALUE=cPwindow2

    ;  Set the active plot window to cPwindow2.
    ;
    WSET, cPwindow2

    ;  Get the character scaling factor.
    ;
    charscale = 8.0/!d.X_CH_SIZE


    cFuture=FINDGEN(40)

    ;  Initialize the info structure.
    ;
    info={ $
        cYdata:TSdataStr.cYdata, $          ; array, y coordinates
        cXdata:TSdataStr.cXdata, $          ; array, x coordinates
        cYmax:TSdataStr.cYmax, $            ; Max value of cYdata
        cXmax:TSdataStr.cXmax, $            ; Max value of cXdata
        cYmin:TSdataStr.cYmin, $            ; Min value of cYdata
        cNy:TSdataStr.cNy, $                ; integer number of data in cYdata
        cFcastmax:TSdataStr.cFcastmax, $    ; integer Max number of forecast
        cOrder:cOrder, $                    ; Forecasting model Order parameter
        cNfcast:cNfcast, $                  ; Number of forecast
        cFuture:cFuture, $                  ; array, Future forecast
        cPwindow1:cPwindow1, $              ; index to window 1
        cPwindow2:cPwindow2 , $             ; index to window 2
        wLabel1ID:wLabel2ID,$               ; Widget  label 2 ID
        wLabel2ID:wLabel2ID,$               ; Widget  label 2 ID
        SText: sText, $                     ; Text structure for tips
        wDraw1ID:wDraw1ID,$                 ; Widget  Draw 1 ID
        wDraw2ID:wDraw2ID,$                 ; Widget  Draw 2 ID
        wOrderSlider:wOrderSlider,$         ; Order of parameters slider
        wNumberSlider:wNumberSlider,$       ; Number of parameters slider
        wAboutButton:wAboutButton , $       ; About button
        wGenerateButton:wGenerateButton , $ ; Generate time series button
        wQuitButton:wQuitButton , $         ; Quit button
        colorTable:colorTable, $            ; Original Color Table
        Charscale: charscale, $             ; Character scaling factor
        plotFont:plotFont, $                ; Original Font
        PreviousY : previousY, $            ; !Y system variable
        PreviousX : previousX, $            ; !X system variable
        groupBase: groupBase $              ; Base of Group Leader
    }
    
    ;  Register the info structure in
    ;  the user value of the top-level base.
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=info, /NO_COPY
    
    ;  Create a structure similar to an event such that the
    ;  functions d_forecastAutoCorr and d_forecastAutoFCast can be executed
    ;  before the XMANAGER command has been called.
    ;     
    passwtop = {ID:0L, TOP:wTopBase, HANDLER:0L}

    ;  Compute the initial forecast.
    ;
    d_forecastAutoFCast, passwtop
     
    ;  Compute the initial sample autocorrelation.
    ;
    d_forecastAutoCorr, passwtop

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1


    ;  Register with XMANAGER.
    ;
    XMANAGER, "d_forecast", wTopBase, $
        EVENT_HANDLER="d_forecastEvent", CLEANUP="d_forecastCleanup", $
        /NO_BLOCK

end   ; of d_forecast

