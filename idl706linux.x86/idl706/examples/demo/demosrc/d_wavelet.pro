;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_wavelet.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_wavelet.pro
;
;  CALLING SEQUENCE: d_wavelet
;
;  PURPOSE:
;       This example demonstrates the wavelets orthogonal functions
;
;  MAJOR TOPICS: Plotting and data analysis
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       fun d_waveletWVCutoff               -  Returns a threshold value
;       fun d_waveletDecimate               -  Set vals within threshold limits
;       fun d_waveletTV                     -  Display image
;       pro d_waveletGetBasis               -  Compute the wavelet basis
;       fun d_waveletAdjustSize             -  Adjust data size
;       fun d_waveletInRange                -  Set values within a give n range
;       pro d_waveletNoCompressedImage      -  Handle no compressed image state
;       pro d_waveletResetPlot              -  Reset the plots
;       pro d_waveletPercentPlot            -  Display percentage plot
;       pro d_waveletUpdatePlot             -  Redraw the plots
;       pro d_waveletNewPercentage          -  Set to a new percentage (slider)
;       pro d_waveletMoveLine               -  Move the plot line
;       pro d_waveletMoveSlider             -  Update slider value
;       pro d_waveletGotNewImage            -  Display the image
;       pro d_waveletSensitize              -  Sensitize a widget
;       pro d_waveletChangeFilename         -  Update the title
;       pro d_waveletEraseOriginal          -  Erase the original image
;       pro d_waveletEraseSecondary         -  Erase the secondary image
;       pro d_waveletDataInput              -  Load a new data set
;       pro d_waveletDoCompression          -  Compute & display image
;       pro d_waveletNewCoeff               -  Handle the new coefficients
;       pro d_waveletEvent                  -  Event handler
;       pro d_waveletCleanup                -  Cleanup
;       pro d_wavelet                       -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       pro demo_puttips        - Change tips text
;       pro demo_getdata         -  Read new data
;       wavelet.tip
;       hurric.dat (Image of Hurricane Gilbert)
;       Other two dimensional images in the examples/data directory can
;       be viewed by selecting "Open" from the "File" menu
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
;       95,   DS   - Written.
;       11/95,   DAT     - Modified for IDL 5.0 demo
;-
;---------------------------------------------------------------------
;
;  PURPOSE
;       Return array of threshold value versus (% decimation * 10.)
;       For example, to get cutoff value for decimation of 60%,
;   use cutoff(60 * 10).
; Inputs:
;   Wavelet = array containing wavelet transform.
; Outputs:
;   Wvlog = log10 of wavelet transform (elements less than 10^(-4)
;       are set to 10^(-4).
;   Cutoff = 1001 element array containing threshold value versus
;       % decimation.
;
;


;---------------------------------------------------------------------
;
;  PURPOSE  : Compute the cutoff paramater.
;
function d_waveletWVCutoff, $
    wavelet         ; IN: wavelet coefficients.

    lowthr = 4       ; Consider only values over 10-lowthr
    nhist = 1000     ; Number of histogram bins
    nbins = 1000     ; Number of returned bins

    wvlog = alog10(abs(wavelet) > (10.0^(-lowthr))) + lowthr
    wlmin = min(wvlog, MAX = wlmax)
    bins = (wlmax - wlmin) / nhist
    h = histogram(wvlog, min = wlmin, max = wlmax, binsize = bins) / $
    float(n_elements(wvlog))
    for i=1, nhist-1 do h[i] = h[i] + h[i-1]    ;Cumulative integral

    ;  This plus 1 for maximum value.
    ;
    cutoff = FLTARR(nbins+1)
    j = 0
    for i=1, nbins-1 do begin
        t = float(i) / nbins
        while (h[j] lt t) and (j lt nhist) do j = j + 1
        cutoff[i] = j
    endfor
    cutoff = 10.0 ^ (cutoff * (wlmax/nhist) - lowthr)

    ;  Cutoff 1000 must hold the max value of the array
    ;
    cutoff[1000] = max(abs(wavelet))

    RETURN, cutoff

end

;---------------------------------------------------------------------
;
;   PURPOSE : Set the data to zero when below threshold value.
;
function d_waveletDecimate, original, threshold
        new = original
    d = where(abs(new) le threshold, count)

    ;  If d=-1 then there is noplace like that
    ;
    if (count GT 0) then new[d] = 0.0
    return, new
end

;---------------------------------------------------------------------
;
;   PURPOSE : Clamp and scale input data and then display.
;             Assumes display is set to desired window
;
pro d_waveletTV, input
    input = input > 0
    input = input < 255
    TVSCL, input
end
;---------------------------------------------------------------------
;
;   PURPOSE : Compute the wavelet basis.
;
pro d_waveletGetBasis, $
    UVAL     ; IN: uval structure

    ;  Given our uncompressed array
    ;  and coefficients, get a new
    ;  wavelet basis for the image
    ;
    WIDGET_CONTROL, /HOURGLASS
    UVAL.WVLT_IMG = WTN(UVAL.ORIG_IMG, UVAL.COEFFS)

    UVAL.THRESHARRAY = d_waveletWVCutoff(UVAL.WVLT_IMG)

    ;  Now we need to tv the image of the
    ;  undecimated and decimated wavelet bases
    ;
    WSET, UVAL.ID_WAVE1
    d_waveletTV, CONGRID (UVAL.WVLT_IMG, 200, 200)

    ;  Now we need to create the new plot
    ;
    d_waveletPercentPlot, UVAL
    d_waveletResetPlot, UVAL
end

;---------------------------------------------------------------------
;
;   PURPOSE : Adjust the viewwing area size.
;
function d_waveletAdjustSize, $
    Orig_Image       ; IN: original image

    s = SIZE(Orig_Image)

    if ((s[1] EQ 256) AND (s[2] EQ 256)) then begin
        New_Image = Orig_Image
    endif else begin
        New_Image = CONGRID (Orig_Image, 256, 256, /INTERP)
    endelse

    RETURN, New_Image
end

;---------------------------------------------------------------------
;
;   PURPOSE : Make the data to fall within a range
;
function d_waveletInRange, $
    VALUE, $    ; IN: data
    MINVAL, $   ; IN: minimum value
    MAXVAL      ; IN: maximum value

    tmp = VALUE

    if (tmp LT MINVAL) then $
        tmp = MINVAL $
    ELSE if (tmp GT MAXVAL) then tmp = MAXVAL

    return, tmp
end

;---------------------------------------------------------------------
;
;   PURPOSE :  This procedure clears the compressed image
;              and erase an image if appropriate.
;
pro d_waveletNoCompressedImage, UVAL

    ;  This procedure clears the compressed image
    ;  and erase an image if appropriate.
    ;
    if (UVAL.COMPRESSED EQ 1B) then begin
    WSET, UVAL.ID_COMP
    erase
    ; do X plot
    plots, [0,255],[0,255],/DEVICE
    plots, [0,255],[255,0],/DEVICE
    UVAL.COMP_IMG=0
    empty
        if NOT(Widget_Info(UVAL.WID_DIFFBASE, /Valid_Id)) then begin
            B_DIFF = WIDGET_BASE(GROUP_LEADER=UVAL.WID_MAIN, $
                COLUMN=1, MAP=0, $
                TITLE='WaveletTool Image Differences')

                D_DIFF = WIDGET_DRAW( B_DIFF, $
                    RETAIN=2, XSIZE=256, YSIZE=256, /FRAME, $
                    UNAME='d_wavelet:d_diff_draw')

            WIDGET_CONTROL, B_DIFF, /Realize
            WIDGET_CONTROL, D_DIFF, get_value=NEW_DIFF_ID
            UVAL.ID_DIFF = NEW_DIFF_ID
            UVAL.WID_DIFFBASE = B_DIFF
        endif
            WSET, UVAL.ID_DIFF
        erase

        ; do X plot
        plots, [0,255],[0,255],/DEVICE
        plots, [0,255],[255,0],/DEVICE
        empty
        UVAL.COMPRESSED = 0B
    endif
end

;---------------------------------------------------------------------
;
;   PURPOSE : Reset (empty) the drawing plots.
;
pro d_waveletResetPlot, $
    UVAL    ; IN: uval structure

    ;  Reset plots.
    ;
    d_waveletNewPercentage, UVAL, 0.0
    d_waveletMoveLine, UVAL, 0.0
end

;---------------------------------------------------------------------
;
;   PURPOSE :  Refresh is set to 0/1 depending on whether we simply
;              want to refresh the data in the plot.
;
pro d_waveletPercentPlot, $
    UVAL    ; IN: uval structure

    WSET, UVAL.ID_PLOT
    plot_io, FINDGEN(1000)/10, UVAL.THRESHARRAY, $
        ytitle='Threshold', $
    Xtitle='% compression', YCHARSIZE=UVAL.CHARSIZE, $
        XCHARSIZE=UVAL.CHARSIZE
end

;---------------------------------------------------------------------
;
;   PURPOSE :  Update the compression plot.
;
pro d_waveletUpdatePlot, $
    UVAL    ; IN: uval structure

    ;  Refresh is set to 0/1 depending on whether we simply
    ;  want to refresh the data in the plot
    ;
    WSET, UVAL.ID_PLOT
    PLOT_IO, FINDGEN(1000)/10, UVAL.THRESHARRAY, YTITLE='Threshold', $
    XTITLE='% compression', $
        /NOERASE, YCHARSIZE=UVAL.CHARSIZE, $
        XCHARSIZE=UVAL.CHARSIZE

end

;---------------------------------------------------------------------
;
;   PURPOSE : Adjust the plot and slider to the new percentage value.
;
pro d_waveletNewPercentage, $
    UVAL , $    ; IN: uval structure
    PERCENT     ; IN: precentage value

    WIDGET_CONTROL,/hourglass

    ;  Send a 1 to d_waveletMoveLine to refresh plot b/t draws.
    ;
    UVAL.PERCENTAGE = PERCENT

    ;  Get the appropriate threshold and save it
    ;  (from the plotted dataset!).
    ;
    UVAL.THRESHOLD = UVAL.THRESHARRAY [UVAL.PERCENTAGE * 10]
    d_waveletMoveSlider, UVAL
    demo_putTips, UVAL, '', 10
    demo_putTips, UVAL, ['comp1','comp2'], [11,12], /LABEL
    d_waveletUpdatePlot, UVAL

    ;  Then it decimates and displays the new image
    ;  into the decimated wavelet draw widget.
    ;
    WSET, UVAL.ID_WAVE2
    d_waveletTV, CONGRID (d_waveletDecimate(UVAL.WVLT_IMG, UVAL.THRESHOLD), 200, 200)
    demo_putTips, UVAL, ['selecto','adjus','perce'], [10,11,12], /LABEL

end

;---------------------------------------------------------------------
;
;   PURPOSE : Redraw the vertical line of the compression plot.
;
pro d_waveletMoveLine, $
    UVAL , $    ; IN: uval structure
    X           ; IN: precentage value

    ;  Expects X in DATA coordinates.
    ;
    WSET, UVAL.ID_PLOT
    device, SET_GRAPHICS_FUNCTION=6
    plots, [UVAL.PERCENTAGE, UVAL.PERCENTAGE],[1e-10, 1e+10], $
        NOCLIP=0, /DATA, COLOR=200
    empty
    plots, [X,X],[1e-10, 1e+10], NOCLIP=0, /DATA, COLOR=200
    device, SET_GRAPHICS_FUNCTION=3
    xValue = STRING(UVAL.percentage, FORMAT='(f6.2)')
    xValue = STRTRIM(xValue,2)
    xValue = xValue + ' %'
    WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE=xValue
    empty

end

;---------------------------------------------------------------------
;
;   PURPOSE : Update the slider to the new percentage value.
;
pro d_waveletMoveSlider, $
    UVAL     ; IN: uval structure

    WIDGET_CONTROL, UVAL.WID_SLIDER, SET_VALUE=UVAL.PERCENTAGE
end

;---------------------------------------------------------------------
;
;   PURPOSE :  Redo plots with new image.
;
PRO d_waveletGotNewImage, $
    UVAL     ; IN: uval structure

    ;  Display it.
    ;
    demo_putTips, UVAL, '', 10
    demo_putTips, UVAL, ['comp1','comp2'], [11,12], /LABEL
    WSET, UVAL.ID_ORIG
    TVSCL, UVAL.ORIG_IMG

    ;  Get wavelet basis for this image     .
    ;
    d_waveletGetBasis, UVAL
    demo_putTips, UVAL, ['selecto','adjus','perce'], [10,11,12], /LABEL
    WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE=' 75.00%'
end

;---------------------------------------------------------------------
;
;   PURPOSE :  Redo plots with new image.
;
pro d_waveletSensitize, $
    UVAL, $     ; IN: uval structure
    SENSE       ; IN: sensitive case (0 or 1)

    ;  Using ENABLE_WIDS, sensitize/desensitize
    ;  the appropriate widgets.
    ;
    for i=0,(N_ELEMENTS(UVAL.ENABLE_WIDS)-1) do $
        WIDGET_CONTROL, UVAL.ENABLE_WIDS[i], SENSITIVE=SENSE
end

;---------------------------------------------------------------------
;
;   PURPOSE : Change the top level base name to new file name.
;
pro d_waveletChangeFilename, $
    UVAL, $     ; IN: uval structure
    Filename    ; IN: file name (string)

    WIDGET_CONTROL, UVAL.WID_MAIN, $
        TLB_SET_TITLE='WaveletTool - '+Filename
end

;---------------------------------------------------------------------
;
;   PURPOSE : Erases original image draw widget.
;
pro d_waveletEraseOriginal, $
    UVAL     ; IN: uval structure

    WSET, UVAL.ID_ORIG
    erase
end

;---------------------------------------------------------------------
;
;   PURPOSE : Erases original image draw widget.
;
pro d_waveletEraseSecondary, $
    UVAL     ; IN: uval structure

    WSET, UVAL.ID_WAVE1
    erase
    WSET, UVAL.ID_WAVE2
    erase
    WSET, UVAL.ID_PLOT
    erase
    d_waveletNoCompressedImage, UVAL
end

;---------------------------------------------------------------------
;
;   PURPOSE : Get a new data set.
;
pro d_waveletDataInput, $
    UVAL     ; IN: uval structure

    demo_getdata, NewImage, OFILENAME= file, /TWO_DIM, $
        GROUP=UVAL.B_MAIN

    WIDGET_CONTROL,/hourglass

    ;  If file is undefined, no selection
    ;
    if (N_ELEMENTS(file) NE 0) then begin

        ;  Got one, allow input to other widgets
        ;
        d_waveletChangeFilename, UVAL, file

        ;  Adjust size of image to 256,256 if necessary
        ;
        UVAL.ORIG_IMG = d_waveletAdjustSize (NewImage)
        UVAL.FILE_LOADED = 1B
        d_waveletSensitize, UVAL, 1
        d_waveletEraseOriginal, UVAL
        d_waveletEraseSecondary, UVAL
        d_waveletGotNewImage, UVAL
        demo_putTips, UVAL, ['selecto','adjus','perce'], [10,11,12], /LABEL

    endif
end

;---------------------------------------------------------------------
;
;   PURPOSE : Given the wavelet basis and the setting
;             on the slider, do the compression and display it.
;
pro d_waveletDoCompression, $
    UVAL     ; IN: uval structure

    WIDGET_CONTROL, /HOURGLASS
    WSET, UVAL.ID_COMP
    erase
    tmp = WTN(d_waveletDecimate (UVAL.WVLT_IMG, UVAL.THRESHOLD), $
        UVAL.COEFFS, /INVERSE)

    ;  Range the value of the compressed image between 0 and 255.
    ;
    tmp = tmp > 0
    tmp = tmp < 255

    UVAL.COMP_IMG = tmp
    d_waveletTV, tmp

    if (NOT(Widget_Info(UVAL.WID_DIFFBASE, /Valid_Id))) then begin
        B_DIFF = WIDGET_BASE(GROUP_LEADER=UVAL.WID_MAIN, $
            COLUMN=1, MAP=0, $
            TITLE='WaveletTool Image Differences')

            D_DIFF = WIDGET_DRAW( B_DIFF, RETAIN=2, $
                XSIZE=256, YSIZE=256, /FRAME, $
                UNAME='d_wavelet:d_diff_draw')

        WIDGET_CONTROL, B_DIFF, /Realize
        WIDGET_CONTROL, D_DIFF, get_value=NEW_DIFF_ID
        UVAL.ID_DIFF = NEW_DIFF_ID
        UVAL.WID_DIFFBASE = B_DIFF
    endif

    WSET, UVAL.ID_DIFF
    erase
    UVAL.differenceImage = bytscl((UVAL.ORIG_IMG - tmp) > 0, $
       top=!d.table_size-1)
    UVAL.compressImageFlag = 1
    d_waveletTV, UVAL.differenceImage
    UVAL.COMPRESSED = 1B
end

;---------------------------------------------------------------------
;
;   PURPOSE : Get a new wavelet basis, clear the draw window,
;             recompute the new image (do compresssion) and
;             display that image.
;
pro d_waveletNewCoeff, $
    UVAL, $     ; IN: uval structure
    COEFF       ; IN: wavelet coeeficients

    if (COEFF NE UVAL.COEFFS) then begin
        UVAL.COEFFS = COEFF

        if (UVAL.FILE_LOADED EQ 1B) then begin
            demo_putTips, UVAL, '', 10
            demo_putTips, UVAL, ['comp1','comp2'], [11,12], /LABEL
            d_waveletEraseSecondary, UVAL
        d_waveletGetBasis, UVAL
            demo_putTips, UVAL, ['selecto','adjus','perce'], [10,11,12], /LABEL
    endif
    endif
end

;---------------------------------------------------------------------
;
;   PURPOSE : Save the compressed image.
;
;pro Do_Save, $
;    UVAL     ; IN: uval structure
;
;    file = DIALOG_PICKFILE(/WRITE, FILTER='*.dat', $
;                           DIALOG_PARENT=UVAL.WID_MAIN)
;    if (file NE '')  then begin
;
;        ;  Only write if a file was selected.
;        ;
;        openw, unit, /GET_LUN, file, /XDR
;        writeu, unit, UVAL.COMP_IMG
;        free_lun, unit
;    endif
;end
;
;---------------------------------------------------------------------
;
;   PURPOSE : Main event handler.
;
pro d_waveletEvent, $
    Event               ; IN: event structure

    WIDGET_CONTROL,Event.Top, GET_UVALUE=UVAL, /NO_COPY
    demo_record, Event, filename=uval.record_to_filename
    WIDGET_CONTROL,Event.Top, SET_UVALUE=UVAL, /NO_COPY

    if (TAG_NAMES(Event, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, Event.top, /DESTROY
        RETURN
    endif

    ;; catch errors if pdf does not exist or errors occur with Acrobat
    ErrorStatus = 0
    CATCH, ErrorStatus
    IF (ErrorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL
      IF (!error_state.name EQ 'IDL_M_CNTOPNFIL') || $
        (!error_state.name EQ 'IDL_M_FILE_EOF') || $
        (strmid(!error_state.name,0,9) EQ 'IDL_M_OLH') || $
        (strmid(!error_state.msg,0,11) EQ 'ONLINE_HELP') THEN $
        void = dialog_message('An Error has occured with the ' + $
                              'Online Help System',/ERROR)
      WIDGET_CONTROL,Event.Top, SET_UVALUE=UVAL, /NO_COPY
      return
    ENDIF

    WIDGET_CONTROL,Event.Id,GET_UVALUE=WidUvalue
    WIDGET_CONTROL,Event.Top, GET_UVALUE=UVAL, /NO_COPY

    case WidUvalue of

        ;  Open a new file (new data set).
        ;
        'OPEN': begin
            d_waveletDataInput, UVAL
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=0
            UVAL.compressImageFlag = 0

            perc = 75L
            d_waveletMoveLine, UVAL, perc
            d_waveletNewPercentage, UVAL, perc
            xValue = STRING(perc, FORMAT='(f6.2)')
            xValue = STRTRIM(xValue,2)
            xValue = xValue + ' %'
            WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE=xValue
            d_waveletDoCompression, UVAL
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=1

            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=1

        end

        ;  Quit this application.
        ;
        'QUIT': begin
            WIDGET_CONTROL,Event.Top, SET_UVALUE=UVAL, /NO_COPY
            WIDGET_CONTROL,Event.Top, /destroy

            ;  Return after this!
            ;
            return
        end

        ;  Compute the wavelet transform with 4 coefficients.
        ;
        'FOUR': begin
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=0
            WIDGET_CONTROL, UVAL.wFourButton, SENSITIVE=0
            WIDGET_CONTROL, UVAL.wTwelveButton, SENSITIVE=1
            WIDGET_CONTROL, UVAL.wTwentyButton, SENSITIVE=1
            d_waveletNewCoeff, UVAL, 4
            d_waveletDoCompression, UVAL
            WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE='000.00%'
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=1
        end

        ;  Compute the wavelet transform with 12 coefficients.
        ;
        'TWELVE': begin
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=0
            WIDGET_CONTROL, UVAL.wFourButton, SENSITIVE=1
            WIDGET_CONTROL, UVAL.wTwelveButton, SENSITIVE=0
            WIDGET_CONTROL, UVAL.wTwentyButton, SENSITIVE=1
            d_waveletNewCoeff, UVAL, 12
            WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE='000.00%'
            d_waveletDoCompression, UVAL
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=1
        end

        ;  Compute the wavelet transform with 20 coefficients.
        ;
        'TWENTY': begin
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=0
            WIDGET_CONTROL, UVAL.wFourButton, SENSITIVE=1
            WIDGET_CONTROL, UVAL.wTwelveButton, SENSITIVE=1
            WIDGET_CONTROL, UVAL.wTwentyButton, SENSITIVE=0
            d_waveletNewCoeff, UVAL, 20
            d_waveletDoCompression, UVAL
            WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE='000.00%'
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=1
        end

        ;  Show the difference between the original and the
        ;  compressed image.
        ;
        'DIFFERENCE': begin
            if (UVAL.compressImageFlag eq 1) then begin
                if not(Widget_Info(UVAL.WID_DIFFBASE, $
                    /Valid_Id)) then begin

                    B_DIFF = WIDGET_BASE(GROUP_LEADER= $
                        UVAL.WID_MAIN, $
                        COLUMN=1, MAP=0, $
                        TITLE='WaveletTool Image Differences')

                    D_DIFF = WIDGET_DRAW( B_DIFF, $
                        RETAIN=2, XSIZE=256, YSIZE=256, /FRAME, $
                        UNAME='d_wavelet:d_diff_draw')

                    WIDGET_CONTROL, B_DIFF, /REALIZE
                    WIDGET_CONTROL, D_DIFF, get_value=NEW_DIFF_ID
                    UVAL.ID_DIFF = NEW_DIFF_ID
                    UVAL.WID_DIFFBASE = B_DIFF
                    WSET, NEW_DIFF_ID
                    d_waveletTV, UVAL.differenceImage
                endif

                ;  Map the showdiff base
                ;
                WIDGET_CONTROL, UVAL.WID_DIFFBASE, MAP=1
                WIDGET_CONTROL, UVAL.WID_DIFFBASE, /SHOW
            endif
        end

        ;  Load a new color table.
        ;
        'XLOADCT': begin
            WIDGET_CONTROL,Event.Top, SET_UVALUE=UVAL, /NO_COPY
            WIDGET_CONTROL,/hourglass
            XLoadct, GROUP=Event.top
            RETURN
        end

        ;  Display the information text.
        ;
        'ABOUT': begin
            ;  Display the information.
            ;
            ONLINE_HELP, 'd_wavelet', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
        end    ;   of ABOUT



        ;  Handle the compression slider event. Redo all the plots.
        ;
        'S_COMPRESSED': begin

            ;  Need to clear the comp image draw
            ;  we are guarranteed no drag events
            ;
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=0
            d_waveletMoveLine, UVAL, Event.value
            d_waveletNewPercentage, UVAL, Event.value
            xValue = STRING(Event.value, FORMAT='(f6.2)')
            xValue = STRTRIM(xValue,2)
            xValue = xValue + ' %'
            WIDGET_CONTROL, UVAL.SliderValue, SET_VALUE=xValue
            d_waveletDoCompression, UVAL
            WIDGET_CONTROL, UVAL.B_MAIN, SENSITIVE=1
        END

        ;  Handle the compression plot drawing event.
        ;
        'D_PLOT': begin

            CASE Event.Type of

                0: begin

                    ;  Button press
                    ;  check which button (only left buttton is active)
                    ;
                    if (Event.Press EQ 1) then begin

                        ;  Start the drag process
                        ;
                        UVAL.DRAGGING = 1B

                        ;  Draw the first line
                        ;
                        WSET, UVAL.ID_PLOT
                        tmp = Convert_coord(Event.X,0,/device,/to_data)
                        tmp[0]= d_waveletInRange (tmp[0], 0, 100)
                        d_waveletMoveLine, UVAL, tmp[0]
                        UVAL.PERCENTAGE = tmp[0]
                    endif
                END                   ;   of 0

                1: begin

                    ;  Button release
                    ;  check which button (only act on left)
                    ;
                    if (Event.Release EQ 1) then begin

                        ;  Stop the dragging
                        ;
                        UVAL.DRAGGING = 0B

                        ;  Evaluate percentage and update slider, etc.
                        ;  need to clear the comp image draw
                        ;
                        WSET, UVAL.ID_PLOT
                        tmp = Convert_coord(Event.X,0,/device,/to_data)
                        tmp[0]= d_waveletInRange (tmp[0], 0, 100)
                        d_waveletMoveLine, UVAL, tmp[0]
                        d_waveletNewPercentage, UVAL, tmp[0]
                        d_waveletDoCompression, UVAL
                    endif
                END                   ;   of 1

                2: begin

                    ;  Motion event.
                    ;  Check if dragging.
                    ;
                    if (UVAL.DRAGGING EQ 1B) then begin

                        ;  Draw new line (xor'd)
                        ;
                        WSET, UVAL.ID_PLOT
                        tmp = Convert_coord(Event.X,0,/device,/to_data)
                        tmp[0]= d_waveletInRange (tmp[0], 0, 100)
                        d_waveletMoveLine, UVAL, tmp[0]
                        UVAL.PERCENTAGE=tmp[0]
                    endif
                END            ;   of 2

                ELSE:

            endcase
        END

        ELSE:      ;   do nothing

    endcase

    WIDGET_CONTROL, Event.Top, SET_UVALUE=UVAL, /NO_COPY

end

;---------------------------------------------------------------------
;
;   PURPOSE : Cleanup procedure.
;
pro d_waveletCleanup, tlb

    ;  Get the color table saved in the window's user value.
    ;
    WIDGET_CONTROL, tlb, GET_UVALUE=UVAL, /NO_COPY

    ;  Restore the previous color table.
    ;
    TVLCT, UVAL.colorTable

    if widget_info(UVAL.groupBase, /valid) then $
        WIDGET_CONTROL, UVAL.groupBase, /map

end  ; Of d_waveletCleanup

;---------------------------------------------------------------------
;
;   PURPOSE :  Transform an image using the orthogonal
;              wavelet method (Daubechies coefficients).
;
pro d_wavelet, $
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


    CHARSIZE = 6.0 / !D.X_CH_SIZE

    ;  Get the screeen size.
    ;
    device, GET_SCREEN_SIZE=scr

    myScroll = 0   ; For adding scroll bars if necessary
    if (scr[0] LT 1000) then begin
        void =  $
        DIALOG_MESSAGE('This application is optimized for 1024 x 768 resolution')
        myScroll = 1  ; Add the scroll bar when creating the TLB
    endif


    ;  Get the screen size and set an offset..
    ;
    Device, GET_SCREEN_SIZE = scrsize

    ;  Create the starting up message.
    ;
    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
    endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse

    xdimImage = 256
    ydimImage = 256
    xdimBasis = 256
    ydimBasis = 256
    xdimPlot = 256
    ydimPlot = 256

    ;  Save the current color table.
    ;
    TVLCT, savedR, savedG, savedB,/GET
    colorTable=[[savedR], [savedG], [savedB]]

    ;  Load an new color table.
    ;
    LOADCT, 0

    junk   = { CW_PDMENU_S, flags:0, name:'' }

    ;  Create the widget hierarchy starting with the
    ;  top level base.
    ;
    if (myScroll EQ 1) then begin
        if (N_ELEMENTS(group) EQ 0) then begin
            B_MAIN = WIDGET_BASE( $
                TLB_FRAME_ATTR=1, $
                SCROLL=myScroll, $
                X_SCROLL_SIZE=scrsize[0]-75, Y_SCROLL_SIZE=scrsize[1]-75, $
                /TLB_KILL_REQUEST_EVENTS, UNAME='d_wavelet:tlb', $
                COLUMN=1, MAP=0, MBAR=barBase, TITLE='WaveletTool')
        endif else begin
            B_MAIN = WIDGET_BASE(GROUP_LEADER=group, $
                TLB_FRAME_ATTR=1, $
                SCROLL=myScroll, $
                X_SCROLL_SIZE=scrsize[0]-75, Y_SCROLL_SIZE=scrsize[1]-75, $
                /TLB_KILL_REQUEST_EVENTS, UNAME='d_wavelet:tlb', $
                COLUMN=1, MAP=0, MBAR=barBase, TITLE='WaveletTool')
        endelse
    endif else begin
        if (N_ELEMENTS(group) EQ 0) then begin
            B_MAIN = WIDGET_BASE( $
                TLB_FRAME_ATTR=1, $
                /TLB_KILL_REQUEST_EVENTS, UNAME='d_wavelet:tlb', $
                COLUMN=1, MAP=0, MBAR=barBase, TITLE='WaveletTool')
        endif else begin
            B_MAIN = WIDGET_BASE(GROUP_LEADER=group, $
                TLB_FRAME_ATTR=1, $
                /TLB_KILL_REQUEST_EVENTS, UNAME='d_wavelet:tlb', $
                COLUMN=1, MAP=0, MBAR=barBase, TITLE='WaveletTool')
        endelse
    endelse

        ;  Create the file menu.
        ;
        wFileButton = WIDGET_BUTTON(barbase, VALUE='File', /MENU)

            wOpenButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Open', UVALUE='OPEN',$
                UNAME='d_wavelet:open')

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Quit', UVALUE='QUIT', UNAME='d_wavelet:quit')

        ;  Create the option menu.
        ;
        wOptionButton = WIDGET_BUTTON(barbase, VALUE='Options', /MENU)

            wFourButton = WIDGET_BUTTON(wOptionButton, $
                VALUE='4 Coefficients', UVALUE='FOUR', $
                UNAME='d_wavelet:four')

            wTwelveButton = WIDGET_BUTTON(wOptionButton, $
                VALUE='12 Coefficients', UVALUE='TWELVE', $
                UNAME='d_wavelet:twelve')

            wTwentyButton = WIDGET_BUTTON(wOptionButton, $
                VALUE='20 Coefficients', UVALUE='TWENTY', $
                UNAME='d_wavelet:twenty')

            wDifferenceButton = WIDGET_BUTTON(wOptionButton, $
                VALUE='Show Difference Image', UVALUE='DIFFERENCE')

        ;  Create the tool menu.
        ;
        wViewButton = WIDGET_BUTTON(barbase, VALUE='View', /MENU)

            wXLoadctButton = WIDGET_BUTTON(wViewButton, $
                VALUE='Color Palette', UVALUE='XLOADCT')
            ; desensitize the XLOADCT button for visual classes which
            ; don't support automatic updating of the graphics after
            ; changing the colormap
            cmapApplies=COLORMAP_APPLICABLE(redrawRequired)
            if ((cmapApplies LE 0) or $
                ((cmapApplies GT 0) and (redrawRequired GT 0))) then begin
               WIDGET_CONTROL, wXLoadctButton, SENSITIVE=0
            endif

        ;  Create the Help/About button.
        ;
        wHelpButton = WIDGET_BUTTON(barbase, /HELP, Value = 'About',/Menu)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Wavelets', UVALUE='ABOUT')

        B_ALLDISP = WIDGET_BASE(B_MAIN, ROW=1, SPACE=5, XPAD=5, YPAD=5, $
            FRAME=1, MAP=1, TITLE='ALL Display', UVALUE='B_ALLDISP')

            ;  B_DISPLAY is the base that contains the original
            ;  and compressed images.
            ;
            B_DISPLAY = WIDGET_BASE(B_ALLDISP, /COLUMN, SPACE=5, $
            XPAD=5, YPAD=5, FRAME=1, MAP=1, TITLE='Display', $
                UVALUE='B_DISPLAY', /BASE_ALIGN_CENTER)

                B_ORIGINAL = WIDGET_BASE(B_DISPLAY, COLUMN=1, MAP=1, $
                    TITLE='original_base', UVALUE='B_ORIGINAL')

                    L_ORIGINAL = WIDGET_LABEL( B_ORIGINAL, $
                        UVALUE='L_ORIGINAL', VALUE='Original:')

                    D_ORIGINAL = WIDGET_DRAW( B_ORIGINAL, $
                        RETAIN=2, UVALUE='D_ORIGINAL', $
                        XSIZE=256, YSIZE=256, /FRAME, $
                        UNAME='d_wavelet:d_original_draw')

                B_COMPRESSED = WIDGET_BASE(B_DISPLAY, COLUMN=1, $
                    MAP=1, TITLE='compressed_base', $
                    UVALUE='B_COMPRESSED')

                    L_COMPRESSED = WIDGET_LABEL( B_COMPRESSED, $
                        UVALUE='L_COMPRESSED', VALUE='Compressed:')

                    D_COMPRESSED = WIDGET_DRAW( B_COMPRESSED, $
                        RETAIN=2, UVALUE='D_COMPRESSED', $
                        XSIZE=256, YSIZE=256, /FRAME, $
                        UNAME='d_wavelet:d_compressed_draw')

            ;  B_WAVEADJ is the base that contains our interface
            ;  to adjust the compression amount of our wavelet basis.
            ;
            B_WAVES = WIDGET_BASE(B_ALLDISP, COLUMN=1, SPACE=5, $
                XPAD=5, YPAD=5, FRAME=1, MAP=1, $
                TITLE='Wavelets', UVALUE='B_WAVES')

                L_WAVES = WIDGET_LABEL( B_WAVES, $
                    UVALUE='L_WAVES', VALUE='Wavelet Basis:')

                B_WAVEADJ = WIDGET_BASE(B_WAVES, ROW=1, SPACE=10, $
                    XPAD=10, YPAD=10, FRAME=0, MAP=1, $
                    TITLE='Wavelet Adjust', UVALUE='B_WAVEADJ')

                    ;  Base to hold tv's of wavelet basis.
                    ;
                    B_SHOWIMAGE1 = WIDGET_BASE(B_WAVEADJ, $
                        /COLUMN, MAP=1, TITLE='show wavelet images', $
                        UVALUE='B_SHOWIMAGE1')

                        L_WAVE1 = WIDGET_LABEL( B_SHOWIMAGE1, $
                            UVALUE='L_WAVE1', VALUE='Original:')

                        D_WAVE1 = WIDGET_DRAW( B_SHOWIMAGE1, $
                            RETAIN=2, UVALUE='D_WAVE1', $
                            XSIZE=200, YSIZE=200, /FRAME, $
                            UNAME='d_wavelet:d_wave1_draw')

                    B_SHOWIMAGE2 = WIDGET_BASE(B_WAVEADJ, $
                        /COLUMN, MAP=1, TITLE='show wavelet images', $
                        UVALUE='B_SHOWIMAGE2')

                        L_WAVE2 = WIDGET_LABEL( B_SHOWIMAGE2, $
                            UVALUE='L_WAVE2', VALUE='Compressed:')

                        D_WAVE2 = WIDGET_DRAW( B_SHOWIMAGE2, $
                            RETAIN=2, UVALUE='D_WAVE2', $
                            XSIZE=200, YSIZE=200, /FRAME, $
                            UNAME='d_wavelet:d_wave2_draw')

                ;  Base to hold plot and slider for adjusting compression.
                ;
                B_ADJCOMP = WIDGET_BASE(B_WAVES, $
                    COLUMN=1, MAP=1, FRAME=0, SPACE=10, $
                    XPAD=10, YPAD=10, TITLE='adjust compression', $
                    UVALUE='B_ADJCOMP')

                    L_ADJCOMP = WIDGET_LABEL( B_ADJCOMP, $
                        UVALUE='L_ADJCOMP', VALUE='Adjust Compression:')

                    D_PLOT = WIDGET_DRAW( B_ADJCOMP, RETAIN=2, $
                        UVALUE='D_PLOT', $
                        XSIZE=420, YSIZE=200, /FRAME, $
                        /MOTION_EVENTS, /BUTTON_EVENTS, $
                        UNAME='d_wavelet:d_plot_draw')

                    SliderValue = WIDGET_LABEL(B_ADJCOMP, $
                        VALUE='  75.00 %', /ALIGN_CENTER)

                    S_COMPRESSED = WIDGET_SLIDER( B_ADJCOMP, $
                        MAXIMUM=100, XSIZE=420, $
                        TITLE='Percentage Compression', $
                        UNAME='d_wavelet:compression_slider', $
                        UVALUE='S_COMPRESSED', $
            VALUE=75, /SUPPRESS_VALUE)

        ;  Create the status line label.
        ;
        wStatusBase = WIDGET_BASE(B_MAIN, MAP=0, /ROW)

        ;  We have a second top-level base to show differences.
        ;
        B_DIFF = WIDGET_BASE(GROUP_LEADER=B_MAIN, COLUMN=1, $
            MAP=0, TITLE='WaveletTool Image Differences')

            D_DIFF = WIDGET_DRAW( B_DIFF, RETAIN=2, $
            XSIZE=256, YSIZE=256, /FRAME, $
            UNAME='d_wavelet:d_diff_draw')

    WIDGET_CONTROL, B_MAIN, /REALIZE
    WIDGET_CONTROL, B_DIFF, MAP=0, /REALIZE

    ; Returns the top level base to the APPTLB keyword.
    ;
    appTLB = B_MAIN

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('wavelet.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         B_MAIN, $
                         wStatusBase)

    if not keyword_set(record_to_filename) then $
        record_to_filename = ''

    UVAL = {ID_ORIG:0L, $                ; Windows IDs, original
            ID_COMP:0L, $                ;              compressed
            ID_WAVE1:0L, $               ;              wavelet 1
            ID_WAVE2:0L, $               ;              wavelet 2
            ID_PLOT:0L, $                ;              pecentage plot
            ID_DIFF:0L, $                ;              difference image
            B_MAIN: B_MAIN, $            ; Top level base
            WID_STATUS:0L, $             ; Status label ID
            WID_SLIDER:0L, $             ; Percentage slider ID
            WID_DIFFBASE:0L, $           ; Difference image base ID
            WID_MAIN:0L, $               ; Main base ID
            WID_COEFFS:0L, $             ; Number of coefficients button IDs
            ENABLE_WIDS:LONARR(8), $     ; Enabled widgets IDs (see list below)
            THRESHOLD: 0.0, $            ; Threshold value
            COEFFS:0, $                  ; Number of wavelets coefficients
            FILE_LOADED:0B, $            ; File loaded flag
            PERCENTAGE:0.0, $            ; Compression precentage value
            DRAGGING:0B, $               ; Dragging mode:0=not, 1=yes
            WFourButton: wFourButton, $  ; Widget button IDs
            WTwelveButton: wTwelveButton, $
            WTwentyButton: wTwentyButton, $
            DifferenceImage:  $
            BYTARR(xdimImage, yDimImage), $ ; Difference image
            SliderValue: SliderValue, $  ; Percentage slider value
            CompressImageFlag : 0, $     ; 0= not drawn, 1=drawn
            ColorTable: colorTable, $    ; Color table to restore
            CHARSIZE: CHARSIZE, $
            SText: sText, $              ; Text structure for tips
            ;  Set this to 1 to start to force erase of ID_COMP
            COMPRESSED:1B, $             ; Compress flag
            THRESHARRAY:FLTARR(1001), $  ; Threshold array
            ORIG_IMG:BYTARR(256,256), $  ; Original image
            WVLT_IMG:FLTARR(256,256), $  ; Wavelet image
            COMP_IMG:BYTARR(256,256), $  ; Compressed image
            record_to_filename: record_to_filename, $
            groupBase: groupBase $       ; Base of Group Leader
    }


    ;  The ENABLE_WIDS array is an array of widget ids
    ;  to desensitize when there
    ;  is no filename selected.

    ;  Fill the UVALUE structure of our main base with our values.
    ;
    WIDGET_CONTROL, D_ORIGINAL, GET_VALUE=originalValue
    UVAL.ID_ORIG = originalValue
    WIDGET_CONTROL, D_COMPRESSED, GET_VALUE=compressedValue
    UVAL.ID_COMP = compressedValue
    WIDGET_CONTROL, D_WAVE1, GET_VALUE=wave1Value
    UVAL.ID_WAVE1 = wave1Value
    WIDGET_CONTROL, D_WAVE2, GET_VALUE=wave2Value
    UVAL.ID_WAVE2 = wave2Value
    WIDGET_CONTROL, D_PLOT, GET_VALUE=differenceValue
    UVAL.ID_PLOT = differenceValue
    WIDGET_CONTROL, D_DIFF, GET_VALUE=differenceValue
    UVAL.ID_DIFF = differenceValue
    UVAL.WID_SLIDER = S_COMPRESSED
    UVAL.WID_DIFFBASE = B_DIFF
    UVAL.WID_MAIN = B_MAIN
    UVAL.ENABLE_WIDS = $
        [L_COMPRESSED, L_WAVE1, L_WAVE2, L_ADJCOMP, L_ORIGINAL, $
    L_WAVES, S_COMPRESSED, D_PLOT]

    ;  Set up initial parameters.
    ;  Clean up the windows.
    ;
    d_waveletNewCoeff, UVAL, 4
    d_waveletEraseOriginal, UVAL
    d_waveletEraseSecondary, UVAL
    d_waveletSensitize, UVAL, 0
    demo_putTips, UVAL, ['sele1','sele2'], [11,12], /LABEL
    d_waveletChangeFilename, UVAL, '<NONE>'


    ;  Load an initial file .
    ;
    file = 'hurric.dat'
    demo_getdata, NewImage, FILENAME=file, /TWO_DIM
    d_waveletChangeFilename, UVAL, file

    ;  Adjust size of image to 256,256 if necessary.
    ;
    UVAL.ORIG_IMG = d_waveletAdjustSize (NewImage)
    UVAL.FILE_LOADED = 1B
    d_waveletSensitize, UVAL, 1
    d_waveletEraseOriginal, UVAL
    d_waveletEraseSecondary, UVAL
    d_waveletGotNewImage, UVAL
    demo_putTips, UVAL, ['selecto','adjus','perce'], [10,11,12], /LABEL

    WIDGET_CONTROL, B_MAIN, SET_UVALUE=UVAL
    WIDGET_CONTROL, wFourButton, SENSITIVE=0

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, B_MAIN, MAP=1

    ;  Set up the default percentage value to 75 %.
    ;
    pseudoEvent = { $
        ID: S_COMPRESSED, $
        TOP: B_MAIN, $
        HANDLER: 0L, $
        VALUE:75L, $
        DRAG:0 $
    }
    d_waveletEvent, pseudoEvent

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, B_MAIN, MAP=1

    XMANAGER, 'd_wavelet', B_MAIN, $
        EVENT_HANDLER='d_waveletEvent', CLEANUP='d_waveletCleanup', $
        /NO_BLOCK

end  ;    of d_wavelet
