; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_mathstat.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_mathstat.pro
;
;  CALLING SEQUENCE: d_mathstat
;
;  PURPOSE:
;       Shows 6 mathematical data analysis routines :
;       Surface fitting, polynomial fitting, linear regression,
;       optimization, solving equations, and inegration.
;
;  MAJOR TOPICS: Data analysis and plotting
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       func d_mathstatNewtonFunc         - callback for Newton routine
;       func d_mathstatPowellFunc         - callback for Powell routine
;       pro d_mathstatMakeSurfaceFit      - Surface fitting
;       pro d_mathstatMakePolyFit         - Polynomial fitting
;       pro d_mathstatMakeRegression      - Linear regression
;       pro d_mathstatMakeMinimization    - Optimization or minimization
;       pro d_mathstatMakeSolving         - Solving equations
;       pro d_mathstatGenerateIntegration - Integration of functions
;       pro d_mathstatEvent               - Event handler
;       pro d_mathstatCleanup             - Cleanup
;       pro d_mathstat                    - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       pro demo_puttips        - Change tips text
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:  Written by:  DC, RSI,  1995
;                         Modified by DAT,RSI,  November 1996
;                         Combining tour elements 270, 271 and 272
;-
;--------------------------------------------------------------------
;
;  Purpose:  Compute the function new value for solving equation
;
function d_mathstatNewtonFunc, x
    RETURN, [-(x[0]^2 - x[1] - 4.0), x[0]^2 + x[1]^2 - 8.0]
end

;--------------------------------------------------------------------
;
;  Purpose:  Compute the function new value  for minimization
;
function d_mathstatPowellFunc, x, All_Elem=all_elem
    IF (KEYWORD_SET(all_elem)) THEN $
        param = x ELSE param = x[0]
    RETURN, SIN(SIN(param^2) - COS(param)) + $
        COS(SIN(param) + SIN(param)^2)
end

;--------------------------------------------------------------------
;
;  Purpose:  Create surface fit
;
pro  d_mathstatMakeSurfaceFit, $
    points, $            ; IN: number of points
    drawXSize, $         ; IN:   x dimension of drawing area
    drawYSize, $         ; IN:   y dimension of drawing area
    drawWindowID         ; IN: window ID

    LOADCT, 1 , /SILENT
    TEK_COLOR
    WSET, drawWindowID

    x = RANDOMN(s, points)
    y = RANDOMN(s, points)
    z = SIN(x - COS(y)^2) - COS(SIN(x^2) + SIN(y)) + 4.0

    zz = MIN_CURVE_SURF(z, x, y, Nx=points, Ny=points)
    min_x = MIN(x, MAX=max_x)
    min_y = MIN(y, MAX=max_y)
    xx = min_x + ((max_x - min_x) * FINDGEN(points) / FLOAT(points-1))
    yy = min_y + ((max_y - min_y) * FINDGEN(points) / FLOAT(points-1))

    save_name = !D.Name
    SET_PLOT, 'Z'
    DEVICE, Set_Resolution=[drawXSize, drawYSize]

    SHADE_SURF, zz, xx, yy, XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        TICKLEN=(-0.02), AX=65, AZ=30, BACKGROUND=14, SKIRT=0.0
    img = TVRD(0, 0, drawXSize, drawYSize)
    ERASE
    TV, img

    SURFACE, zz, xx, yy, /NODATA, /NOERASE, $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        TICKLEN=(-0.02), COLOR=3, AX=65, AZ=30, SKIRT=0.0, /SAVE

    for i=0, (N_ELEMENTS(x)-1L) do begin
        PLOTS, x[i], y[i], 0.0, PSYM=1, /T3D, /Data, COLOR=3, $
            SYMSIZE=3.0
        PLOTS, [x[i], x[i]], [y[i], y[i]], [0.0, z[i]], $
            /T3D, /DATA, COLOR=2
    endfor

    SURFACE, zz, xx, yy, /SAVE, XSTYLE=5, YSTYLE=5, ZSTYLE=5, $
        TICKLEN=(-0.02), /NOERASE, COLOR=15, AX=65, AZ=30, SKIRT=0.0

    EMPTY
    img = TVRD(0, 0, drawXSize, drawYSize)
    DEVICE, /CLOSE
    SET_PLOT, save_name
    TV, img
    EMPTY

    delt_x = 0.01 / !X.S[1]
    delt_y = 0.01 / !Y.S[1]
    for i=0, (N_ELEMENTS(x)-1L) do begin
       px = [x[i]-delt_x, x[i]+delt_x, x[i]+delt_x, x[i]-delt_x, x[i]-delt_x]
       py = [y[i]-delt_y, y[i]-delt_y, y[i]+delt_y, y[i]+delt_y, y[i]-delt_y]
       ix = FLOAT(points-1) * (px - min_x) / (max_x - min_x)
       iy = FLOAT(points-1) * (py - min_y) / (max_y - min_y)
       pz = INTERPOLATE(zz, ix, iy)
       PLOTS, px, py, pz, /T3D, /DATA, COLOR=0
    endfor

    EMPTY

end     ;   of d_mathstatMakeSurfaceFit

;--------------------------------------------------------------------
;
;  Purpose:  Create polynomial fit
;
pro  d_mathstatMakePolyFit, $
        points, $      ; IN: number of points
        degree, $      ; IN: polynomial degree
        x, $           ; IN: x array
        y, $           ; IN: y array
        drawWindowID   ; IN: drawing  window ID

    LOADCT, 1 , /SILENT
    TEK_COLOR

    WSET, drawWindowID
    ERASE

    PLOT, x, y, TITLE='Polynomial Fit', $
        /NODATA, COLOR=3, YRANGE=[-2.0, 2.0], $
        POSITION=[0.15, 0.25, 0.9, 0.75], $
        TICKLEN=(-0.02), XSTYLE=1, YSTYLE=1
    EMPTY
    OPLOT, x, y, PSYM=4, COLOR=5
    EMPTY

    yy = POLY_FIT(x, y, degree, /DOUBLE)
    xx = 2.0 * !PI * FINDGEN(256) / 255.0
    yy = POLY(xx, yy)
    OPLOT, xx, yy, COLOR=1, THICK=2
    EMPTY

end     ;   of  Make PolyFit

;--------------------------------------------------------------------
;
;  Purpose:  Create regression items
;
pro  d_mathstatMakeRegression, $
        above, $       ; IN: number of outliers above
        below, $       ; IN: number of outliers below
        drawWindowID   ; IN: drawing  window ID

    !P.MULTI = [0, 2, 1]
    previousFont = !P.FONT
    !P.FONT = 0

    LOADCT, 0 , /SILENT
    TEK_COLOR

    points = 51
    x = FINDGEN(points)

    ;  Generate the discrete data.
    ;
    y = 0.3 * x - 3.0 + randomn(seed, points)

    ;  Generate the outlying data above.
    ;
    ix = ROUND(RANDOMU(seed, above) * FLOAT(points-1))
    y[ix] = y[ix] + RANDOMU(s, above) * 10.0

    ;  Generate the discrete data.
    ;
    y = 0.3 * x - 3.0 + randomn(seed, points)

    ;  Generate the outlying data above.
    ;
    ix = ROUND(RANDOMU(s, above) * FLOAT(points-1))
    y[ix] = y[ix] + RANDOMU(s, above) * 10.0

    ;  Generate the outlying data below.
    ;
    ix = ROUND(RANDOMU(s, below) * FLOAT(points-1))
    y[ix] = y[ix] - RANDOMU(s, below) * 15.0

    y = (y > (-20.0)) < 20.0

    ;  Compute the fit.
    ;
    result1 = LINFIT(x, y)
    result2 = LADFIT(x, y)

    ;  Plot the regression results.
    ;
    WSET, drawWindowID
    ERASE
    xt1 = STRING(result1[1], FORMAT='(F7.5)') + 'x' + $
        STRING(result1[0], FORMAT='(F9.5)')
    PLOT, x, y, /NODATA, YRANGE=[-20, 20], $
        TITLE='Regression Fit', $
        XTITLE=('y = ' + xt1), COLOR=1, XMARGIN=[5,2], YMARGIN=[5,5]
    PLOTS, x, y, PSYM=4, COLOR=2
    y1 = result1[0] + result1[1] * x
    OPLOT, x, y1, THICK=2, COLOR=5

    ;  PLOT the least-absolute-deviation results.
    ;
    xt2 = STRING(result2[1], FORMAT='(F7.5)') + 'x' + $
        STRING(result2[0], FORMAT='(F9.5)')
    PLOT, x, y, /NODATA, YRANGE=[-20, 20], TITLE= $
        'Least Absolute Deviation', XTITLE=('y = ' + xt2), $
        COLOR=1, XMARGIN=[5,2], YMARGIN=[5,5]
    PLOTS, x, y, PSYM=4, COLOR=2
    y2 = result2[0] + result2[1] * x
    OPLOT, x, y2, THICK=2, COLOR=5

    !P.MULTI = 0
    !P.FONT = previousFont

end   ;  of d_mathstatMakeRegression

;--------------------------------------------------------------------
;
;  Purpose:  Create minimization item
;
pro d_mathstatMakeMinimization, $
    drawXSize, $         ; IN:   x dimension of drawing area
    drawYSize, $         ; IN:   y dimension of drawing area
    drawWindowID, $      ; IN:   window ID of drawing area
    pixmapID, $          ; IN:   pixmapID
    sInfo                ; IN:   state


    LOADCT, 0 , /SILENT
    TEK_COLOR
    sz = 256
    f_sz_m1 = FLOAT(sz - 1)

    x = !PI * 3.5 * ((FINDGEN(sz) / f_sz_m1) - 0.5)
    y = d_mathstatPowellFunc(x, /All_Elem)

    WSET, pixmapID
    PLOT, x, y, YRANGE=[-1.5, 2.5], XSTYLE=1, YSTYLE=1, COLOR=4, $
        /NODATA, TICKLEN=(1.0), XTITLE='X', YTITLE='Y'
    PLOT, x, y, YRANGE=[-1.5, 2.5], XSTYLE=1, YSTYLE=1, COLOR=5, $
        /NODATA, /NOERASE, TICKLEN=(0.0), XTITLE='X', YTITLE='Y'
    PLOT, x, y, YRANGE=[-1.5, 2.5], XSTYLE=5, YSTYLE=5, COLOR=1, $
        /NOERASE, THICK=2, XTITLE='X', YTITLE='Y'

    Wset, drawWindowID
    DEVICE, COPY=[0, 0, drawXSize, drawYSize, 0, 0, pixmapID]

    p = [0.0, 0.0]
    xi = REPLICATE(0.01, 2, 2)
    ftol = 1.0e-5

    Powell, p, xi, ftol, func_min, 'd_mathstatPowellFunc'

    OPLOT, [0.0], [0.0], PSYM=2, COLOR=7, SYMSIZE=0.5
    OPLOT, [p[0]], [func_min], PSYM=2, COLOR=2, SYMSIZE=0.5
    OPLOT, [p[0]], [func_min], PSYM=4, THICK=2, COLOR=2, SYMSIZE=2.0

    minString = $
        'Minimum : ' + $
        (STRING(p[0], FORMAT='(F7.4)') + ', ' + $
        STRING(func_min, FORMAT='(F7.4)'))
    demo_putTips, sInfo, ['optim1','optim2'], [10,11], /LABEL
    demo_putTips, sInfo, minString, 12

end      ;   of makeMinimum

;--------------------------------------------------------------------
;
;  Purpose:  Generate the plots for the solving equations demo
;            The drawing area must be selected apriori
;
pro d_mathstatMakeSolving, $
    drawXSize, $    ; IN: x dimension of the drawing area
    drawYSize, $    ; IN: y dimension of the drawing area
    windowID, $     ; IN: window identifier
    sInfo           ; IN: state, needed to allow modification of sText field

    WSET, windowID
    LOADCT, 0, /SILENT
    TEK_COLOR

    ;  Graph the surfaces.
    ;
    x = (FINDGEN(51) / 5.0) - 5.0
    y = x

    xx = x # REPLICATE(1.0, 51)
    yy = TRANSPOSE(xx)

    z1 = -(xx^2 - yy - 4.0)
    z2 = xx^2 + yy^2 - 8.0

    p = FLTARR(51, 51)

    zrange = [-45.0, 45.0]
    save_name = !D.Name
    SET_PLOT, 'Z'
    DEVICE, Set_Resolution=[drawXSize, drawYSize]
    ERASE, 0
    SURFACE, p, x, y, ZRANGE=zrange, $
        COLOR=1, AX=70, AZ=30, TICKLEN=(-0.01), $
        /NODATA, /SAVE, XSTYLE=3, YSTYLE=3, ZSTYLE=3, BACKGROUND=14

    SURFACE, p, x, y, ZRANGE=zrange, COLOR=3, /T3D, /NOERASE, $
        XSTYLE=7, YSTYLE=7, ZSTYLE=7

    SHADE_SURF, p, x, y, ZRANGE=zrange, COLOR=3, /T3D, /NOERASE, $
        XSTYLE=7, YSTYLE=7, ZSTYLE=7
    img = TVRD(0, 0, drawXSize, drawYSize)
    SET_PLOT, save_name
    TV, img
    EMPTY

    SET_PLOT, 'Z'
    SURFACE, z1, x, y, ZRANGE=zrange, COLOR=4, /T3D, /NOERASE, $
        XSTYLE=7, YSTYLE=7, ZSTYLE=7
    SHADE_SURF, z1, x, y, ZRANGE=zrange, COLOR=4, /T3D, /NOERASE, $
        XSTYLE=7, YSTYLE=7, ZSTYLE=7
    img = TVRD(0, 0, drawXSize, drawYSize)
    SET_PLOT, save_name
    TV, img
    EMPTY

    SET_PLOT, 'Z'
    SURFACE, z2, x, y, ZRANGE=zrange, COLOR=2, /T3D, /NOERASE, $
        XSTYLE=7, YSTYLE=7, ZSTYLE=7
    SHADE_SURF, z2, x, y, ZRANGE=zrange, COLOR=2, /T3D, /NOERASE, $
        XSTYLE=7, YSTYLE=7, ZSTYLE=7
    img = TVRD(0, 0, drawXSize, drawYSize)
    SET_PLOT, save_name
    TV, img
    EMPTY

    ig = [0.0, 0.0]

    PLOTS, [ig[0]], [ig[1]], [0.0], /DATA, COLOR=0, PSYM=1, /T3D, $
        SYMSIZE=2.0, THICK=2
    EMPTY

    sl = Newton(ig, 'd_mathstatNewtonFunc', /Double)
    solString = $
        'Solution:' + $
        STRING(sl[0], FORMAT='(F7.4)') + ', ' + STRING(sl[1], FORMAT='(F7.4)')
    demo_putTips, sInfo, ['solve1','solve2'], [10,11], /LABEL
    demo_putTips, sInfo, solString, 12

    PLOTS, [sl[0]], [sl[1]], [0.0], /DATA, COLOR=1, PSYM=1, /T3D, $
        SYMSIZE=2.0, THICK=2
    EMPTY

    SET_PLOT, 'Z'
    DEVICE, /Close
    SET_PLOT, save_name

end      ;   of d_mathstatMakeSolving
;
;--------------------------------------------------------------------
;
;  Purpose:  Generate a new data set for the integration demo and
;            display it. The window must be set apriori.
;
pro d_mathstatGenerateIntegration, $
    result           ;  OUT:  total area under the curve


    ;  Initialize few parameters
    ;
    points = 21
    points_m1 = points - 1
    time = FINDGEN(points)
    amplitude = RANDOMN(seed, points)
    for i=1, points_m1 do begin
        amplitude[i] = amplitude[i-1] + amplitude[i]
    endfor
    previousRegion = !P.REGION
    !P.REGION = [0.1, 0.1, 0.9, 0.9]

    ;  Smooth the amplitude using a Low pass filter routine
    ;
    amplitude = SMOOTH(amplitude, 3, /EDGE_TRUNCATE)
    min_amp = Min(amplitude, Max=max_amp)
    min_amp = min_amp < 0.0
    max_amp = max_amp > 0.0

    ;  Compute the integral
    ;
    result = INT_TABULATED(time, amplitude)

    ;  Display the result
    ;
    xx = CONGRID(time, 256, /INTERP, /MINUS_ONE)
    yy = SPLINE(time, amplitude, xx)

    PLOT, time, amplitude, COLOR=15, TICKLEN=(0.02), $
        XTITLE='Time', YTITLE='Amplitude', /NODATA, $
        TITLE='Integration of Tabulated Data', $
        YRANGE=[min_amp, max_amp]

    POLYFILL, [0.0, xx, FLOAT(points_m1)], [0.0, yy, 0.0], COLOR=14
    EMPTY

    OPLOT, time, amplitude, COLOR=1, PSYM=10
    OPLOT, time, amplitude, COLOR=2, PSYM=4, THICK=2
    EMPTY

    OPLOT, xx, yy, COLOR=3, THICK=2
    EMPTY

    PLOT, time, amplitude, COLOR=15, TICKLEN=(0.02), $
        XTITLE='Time', YTITLE='Amplitude', /NODATA, $
        TITLE='Integration of Tabulated Data', /NOERASE, $
        YRANGE=[min_amp, max_amp]
    EMPTY

    !P.REGION = previousRegion

end      ;   of d_mathstatGenerateIntegration


;--------------------------------------------------------------------
;
pro d_mathstatEvent,  $
    sEvent       ; IN: event structure

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
    demo_record, sEvent, $
        'd_mathstatEvent', $
        filename=sInfo.record_to_filename, $
        cw=sInfo.wSelectButton
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif


    WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

    case eventUValue of

        'DRAWING' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wSelectButton, GET_VALUE=index
            if (sEvent.type eq 1) then begin
                case index of

                    ;  Handle the solving equation demo.
                    ;
                    1 : begin
                        nx = FLOAT(sEvent.x) / FLOAT(sInfo.drawXSize)
                        ny = FLOAT(sEvent.y) / FLOAT(sInfo.drawYSize)
                        ig = COORD2TO3(nx, ny, 2, 0.0)

                        PLOTS, [ig[0]], [ig[1]], [0.0], $
                            /DATA, COLOR=0, PSYM=1, /T3D, $
                            SYMSIZE=2.0, THICK=2

                        EMPTY
                        sl = Newton(ig[0:1], 'd_mathstatNewtonFunc', /Double)
                        solString = $
                            'Solution:' + $
                            (STRING(sl[0], FORMAT='(F7.4)') + $
                            ', ' + STRING(sl[1], FORMAT='(F7.4)'))
                        demo_putTips, sInfo, ['solve1','solve2'], [10,11], $
                           /LABEL
                        demo_putTips, sInfo, solString, 12

                        PLOTS, [sl[0]], [sl[1]], [0.0], $
                            /DATA, COLOR=1, PSYM=1, /T3D, $
                            SYMSIZE=2.0, THICK=2
                        EMPTY
                    end     ;   of 1

                    ;  Handle the minimization button release.
                    ;
                    2 : begin

                        xpos = ((FLOAT(sEvent.x) / $
                            FLOAT(sInfo.drawXSize)) - !X.S[0]) / !X.S[1]
                        ypos = ((FLOAT(sEvent.y) /  $
                            FLOAT(sInfo.drawYSize)) - !Y.S[0]) / !Y.S[1]


                        OPLOT, [xpos], [ypos], PSYM=2, $
                            COLOR=7, SYMSIZE=0.5
                        EMPTY

                        p = [xpos, xpos]
                        xi = REPLICATE(0.01, 2, 2)
                        ftol = 1.0e-5

                        Powell, p, xi, ftol, func_min, 'd_mathstatPowellFunc'
                        DEVICE, COPY=[0, 0, sInfo.drawXSize, $
                            sInfo.drawYSize, 0, 0,  $
                            sInfo.pixmapArray[0]]
                        OPLOT, [xpos], [ypos], PSYM=2, $
                             COLOR=7, SYMSIZE=0.5
                        OPLOT, [p[0]], [func_min], PSYM=2, $
                             COLOR=2, SYMSIZE=0.5
                        OPLOT, [p[0]], [func_min], PSYM=4, $
                            THICK=2, COLOR=2, SYMSIZE=2.0
                        EMPTY
                        minString = $
                            'Minimum : ' + $
                            (STRING(p[0], FORMAT='(F7.4)') + ', ' + $
                            STRING(func_min, FORMAT='(F7.4)'))
                        demo_putTips, sInfo, ['optim1','optim2'], [10,11], $
                            /LABEL
                        demo_putTips, sInfo, minString, 12
                    end    ;   of  2

                endcase
            endif
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end     ;  of  DRAWING

        'SELECT' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY

            WSET, sInfo.drawWindowID
            case sEvent.value of

                ;  Bring up the integration plot.
                ;
                0 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[0], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[0]
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_mathstatGenerateIntegration, result
                    statusString = $
                        'Total Area : ' + STRING(result, FORMAT='(F9.4)')
                    demo_putTips, sInfo, ['integ','curve'], [10,11], $
                        /LABEL
                    demo_putTips, sInfo, statusString, 12
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                end  ;  of 0

                ;  Bring up the solving solution plot.
                ;
                1 : begin
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[1], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[1]
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_mathstatMakeSolving, sInfo.drawXSize, $
                        sInfo.drawYSize, $
                        sInfo.drawWindowID, $
                        sInfo
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=1
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                end   ; of 1

                ;  Bring up the optimization (minimization) plot.
                ;
                2 : begin
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[2], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[2]
                    d_mathstatMakeMinimization, sInfo.drawXSize, $
                        sInfo.drawYSize, sInfo.drawWindowID, $
                        sInfo.pixmapArray[0], sInfo
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=1
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                end   ;  of 2

                ;  Bring up the linear regression plots.
                ;
                3 : begin
                    above = 3
                    below = 15
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[3], MAP=1
                    WIDGET_CONTROL, sInfo.wAboveSlider, SET_VALUE=above
                    WIDGET_CONTROL, sInfo.wBelowSlider, SET_VALUE=below
                    sInfo.currentBase = sInfo.wSelectionBase[3]
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_mathstatMakeRegression, above, below, $
                        sInfo.drawWindowID
                    demo_putTips, sInfo, ['regre1','regre2','regre3'], $
                        [10,11,12], /LABEL
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                end    ;  of 3

                ;  Bring up the polynomial best fit routine.
                ;
                4 : begin
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[4], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[4]
                    WIDGET_CONTROL, sInfo.wNPolySlider, SET_VALUE=32
                    WIDGET_CONTROL, sInfo.wDegreeSlider, SET_VALUE=3
                    nPoints = 32
                    degree = 3
                    WSET, sInfo.drawWindowID
                    ERASE
                    x = 2.0 * !PI * FINDGEN(nPoints) / FLOAT(nPoints - 1)
                    y = SIN(x) + (0.5 * RANDOMN(seed, nPoints))
                    sInfo.xPoly[0:nPoints-1] = x[0:nPoints-1]
                    sInfo.yPoly[0:nPoints-1] = y[0:nPoints-1]
                    d_mathstatMakePolyFit, nPoints, degree, $
                        x, y, $
                        sInfo.drawWindowID
                    demo_putTips, sInfo, ['polyn1','polyn2','polyn3'], $
                        [10,11,12], /LABEL
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                end    ;  of 4

                ;  Show the surfce best fit plot.
                ;
                5 : begin
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[5], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[5]
                    WIDGET_CONTROL, sInfo.wNSurfaceSlider, SET_VALUE=13
                    nPoints = 13
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_mathstatMakeSurfaceFit, nPoints, $
                        sInfo.drawXSize, sInfo.drawYSIZE, $
                        sInfo.drawWindowID
                    demo_putTips, sInfo, ['surfa1','surfa2','surfa3'], $
                        [10,11,12], /LABEL
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                end    ;  of 5

            endcase

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end   ;                      of   SELECT

        ;  Generate a new integration plot.
        ;
        'GENERATE' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            if XREGISTERED('demo_tour') eq 0 then $
                WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
            WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_MOTION=0
            WSET, sInfo.drawWindowID
            ERASE
            d_mathstatGenerateIntegration, result
            statusString = 'Total Area : ' + STRING(result, FORMAT='(F9.4)')
            demo_putTips, sInfo, statusString, 12
            if XREGISTERED('demo_tour') eq 0 then $
                WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  GENERATE

        ;  Create a new data set with a specified number
        ;  of outliers above the main cluster.
        ;
        'ABOVE' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wAboveSlider, GET_VALUE=above
            WIDGET_CONTROL, sInfo.wBelowSlider, GET_VALUE=below
            WSET, sInfo.drawWindowID
            ERASE
            d_mathstatMakeRegression, above, below, $
                sInfo.drawWindowID
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  ABOVE

        ;  Create a new data set with a specified number
        ;  of outliers below the main cluster.
        ;
        'BELOW' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wAboveSlider, GET_VALUE=above
            WIDGET_CONTROL, sInfo.wBelowSlider, GET_VALUE=below
            WSET, sInfo.drawWindowID
            ERASE
            d_mathstatMakeRegression, above, below, $
                sInfo.drawWindowID
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  BELOW

        ;  Generate a new data set that has a specifed number
        ;  of data points. Then display the best fit polynomial.
        ;
        'NPOLY' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wNPolySlider, GET_VALUE=nPoints
            WIDGET_CONTROL, sInfo.wDegreeSlider, GET_VALUE=degree
            WSET, sInfo.drawWindowID
            ERASE
            x = 2.0 * !PI * FINDGEN(nPoints) / $
                 FLOAT(nPoints - 1)
            y = SIN(sInfo.xPoly) + (0.5 * RANDOMN(seed, nPoints))
            sInfo.xPoly[0:nPoints-1] = x[0:nPoints-1]
            sInfo.YPoly[0:nPoints-1] = y[0:nPoints-1]

            if (nPoints LE degree) then begin
                nPoints = degree + 1
                WIDGET_CONTROL, sInfo.wNPolySlider, Set_Value=nPoints
                x = 2.0 * !PI * FINDGEN(nPoints) / $
                     FLOAT(nPoints - 1)
                y = SIN(sInfo.xPoly) + (0.5 * RANDOMN(seed, nPoints))
                sInfo.xPoly[0:nPoints-1] = x[0:nPoints-1]
                sInfo.YPoly[0:nPoints-1] = y[0:nPoints-1]
            endif

            d_mathstatMakePolyFit, nPoints, degree, $
                x, y, $
                sInfo.drawWindowID
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  NPOLY

        ;  Recompute the best fit polynomial given the
        ;  degree of that polynomial.
        ;
        'DEGREE' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wNPolySlider, GET_VALUE=nPoints
            WIDGET_CONTROL, sInfo.wDegreeSlider, GET_VALUE=degree
            WSET, sInfo.drawWindowID
            ERASE

            x = sInfo.xPoly[0:nPoints-1]
            y = sInfo.yPoly[0:nPoints-1]
            if (nPoints LE degree) then begin
                nPoints = degree + 1
                WIDGET_CONTROL, sInfo.wNPolySlider, Set_Value=nPoints
                x = 2.0 * !PI * FINDGEN(nPoints) / $
                     FLOAT(nPoints - 1)
                y = SIN(sInfo.xPoly) + (0.5 * RANDOMN(seed, nPoints))
                sInfo.xPoly[0:nPoints-1] = x[0:nPoints-1]
                sInfo.YPoly[0:nPoints-1] = y[0:nPoints-1]
            endif

            d_mathstatMakePolyFit, nPoints, degree, $
                x, y, $
                sInfo.drawWindowID
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  DEGREE

        ;  Compute and show the best fit surface given
        ;  a specifed number of data points.
        ;
        'NSurface' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wNSurfaceSlider, GET_VALUE=nPoints
            WSET, sInfo.drawWindowID
            ERASE
            d_mathstatMakeSurfaceFit, nPoints, $
                sInfo.drawXSize, sInfo.drawYSIZE, $
                sInfo.drawWindowID
            WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  NSurface

        ;  Quit this application.
        ;
        'QUIT' : begin
            WIDGET_CONTROL, sEvent.top, /DESTROY
        end

        ;  Display the information text file.
        ;
        'ABOUT' : begin
            ONLINE_HELP, 'd_mathstat', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
        end           ;  of ABOUT


        ELSE :   ;  do nothing

    endcase
end

;--------------------------------------------------------------------
;
;    PURPOSE  Cleanup procedure, restore the color table, destroy
;             the pixmaps.
;
pro d_mathstatCleanup, $
    wTopBase       ; IN: top level base identifier.

    ;  Get the color table saved in the window's user value
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sInfo,/No_Copy

    ;  Restore the previous color table.
    ;
    TVLCT, sInfo.colorTable

    ;  Restore the previous plot font.
    ;
    !P.FONT = sInfo.plotFont

    ;  Delete the pixmaps
    ;
    for i = 0, sInfo.nPixmap-1 do begin
        WDELETE, sInfo.pixmapArray[i]
    endfor

    ;  Flush any accumulated math errors
    ;
    void = CHECK_MATH(PRINT=([0,1])[sInfo.debug])

    ;  Restore original math error behavior.
    ;
    !except = sInfo.orig_except

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sInfo.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sInfo.groupBase, /MAP

end   ; of d_mathstatCleanup

;--------------------------------------------------------------------
;
;   PURPOSE Show several numerical routines available in IDL.
;           These are : integration of function,  solving equations,
;                       minimization (or optimization),  linear
;                       regression, best fit polynomial, and
;                       surface fit.
;
pro d_mathstat, $
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    DEBUG=debug, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

    ;  Flush any accumulated math errors.
    ;
    void = CHECK_MATH(PRINT=KEYWORD_SET(debug))

    ;  Silently accumulate any subsequent math erros, unless we are
    ;  debugging.
    ;
    orig_except = !except
    !except = ([0, 2])[KEYWORD_SET(debug)]

    ; Check the validity of the group identifier
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

    ;  Also save the font
    ;
    plotFont = !P.FONT

    ; Get the character scaling factor
    ;
    charscale = 8.0/!d.X_CH_SIZE

    ;  Load a new color table
    ;
    LOADCT, 12, /SILENT
    TEK_COLOR

    ;  Use hardware-drawn font.
    ;
    !P.FONT=0

    ;  Determine hardware display size.
    ;  Set the viewing area size.
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


    filterLength = 32

    ;  Create the widgets
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(TITLE="Mathematics and Statistics", $
            /COLUMN, $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR = 1, MBAR=barBase, $
            UNAME='d_mathstat:tlb')
    endif else begin
        wTopBase = WIDGET_BASE(TITLE="Mathematics and Statistics", $
            GROUP_LEADER=group, $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            /COLUMN, $
            TLB_FRAME_ATTR = 1, MBAR=barBase, $
            UNAME='d_mathstat:tlb')
    endelse

        ;  Create the menu bar items
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE='File')

            wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                UVALUE='QUIT')

        wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Mathematics and Statistics', $
                UVALUE='ABOUT')

        ;  Create the left and right bases
        ;
        wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2)

            wLeftBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                names = ['Integration',    'Solving Equations', $
                    'Minimization',    'Linear Regression', $
                    'Polynomial Fit', 'Surface Fit']
                wSelectButton = CW_BGROUP(wLeftBase, $
                    names, $
                    UVALUE='SELECT', /NO_RELEASE, /EXCLUSIVE, $
                    IDS=ids)
                WIDGET_CONTROL, wSelectButton, SET_UNAME='d_mathstat:radio'

                ;  Create a base for each options
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
                        UVALUE=0L, /COLUMN, MAP=0, YPAD=20)
                    endfor

                        ;  Create the content of each selection base
                        ;  Beginning with integration
                        ;
                        wIntegrationBase = WIDGET_BASE(wSelectionBase[0], $
                            /COLUMN, /FRAME, /BASE_ALIGN_CENTER)

                            wGenerateButton = WIDGET_BUTTON(wIntegrationBase, $
                                VALUE='Generate New Data', UVALUE='GENERATE', $
                                UNAME='d_mathstat:gen_integration')

                        ;  Solving equations base, It has nothing...
                        ;
                        wSolvingBase = WIDGET_BASE(wSelectionBase[1], $
                            /COLUMN)

                        ;  Minimization base, It has nothing...
                        ;
                        wMinimizationBase = WIDGET_BASE(wSelectionBase[2], $
                            /COLUMN)

                        ;  Regression base.
                        ;
                        wRegressionBase = WIDGET_BASE(wSelectionBase[3], $
                            /COLUMN, /FRAME)

                            wAboveSlider = WIDGET_SLIDER(wRegressionBase, $
                                MINIMUM=1, MAXIMUM=25, $
                                VALUE=3, $
                                UNAME='d_mathstat:RegressPointsAbove', $
                                TITLE='Number of Points Above', UVALUE='ABOVE')

                            wBelowSlider = WIDGET_SLIDER(wRegressionBase, $
                                MINIMUM=1, MAXIMUM=25, $
                                VALUE=15, $
                                UNAME='d_mathstat:RegressPointsBelow', $
                                TITLE='Number of Points Below', UVALUE='BELOW')

                        ;  Polynomial fit base.
                        ;
                        wPolynomialBase = WIDGET_BASE(wSelectionBase[4], $
                            /COLUMN, /FRAME)

                            wNPolySlider = WIDGET_SLIDER(wPolynomialBase, $
                                MINIMUM=3, MAXIMUM=200, $
                                VALUE=32, $
                                TITLE='Number of Points', UVALUE='NPOLY', $
                                UNAME='d_mathstat:NumPolyPoints')

                            wDegreeSlider = WIDGET_SLIDER(wPolynomialBase, $
                                MINIMUM=1, MAXIMUM=8, $
                                VALUE=3, $
                                TITLE='Degree', UVALUE='DEGREE', $
                                UNAME='d_mathstat:PolyDegree')

                        ;  Surface fit base.
                        ;
                        wSurfaceBase = WIDGET_BASE(wSelectionBase[5], $
                            /COLUMN, /FRAME)

                            wNSurfaceSlider = WIDGET_SLIDER(wSurfaceBase, $
                                MINIMUM=3, MAXIMUM=50, VALUE=13, $
                                UNAME='d_mathstat:NumSurfPoints', $
                                TITLE='Number of Points', UVALUE='NSurface')

            wRightBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                wAreaDraw = WIDGET_DRAW(wRightBase, XSIZE=drawXSize, $
                    YSIZE=drawYSize, RETAIN=2, UVALUE='DRAWING', $
                    UNAME='d_mathstat:draw')

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('mathstat.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)


    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wTopBase

    WIDGET_CONTROL, wSelectButton, SET_VALUE=0

    ; Determine the window value of plot window, wDraw1.
    ;
    WIDGET_CONTROL, wAreaDraw, GET_VALUE=drawWindowID

    ;  Map the integration demo (index 0) as default
    ;
    WIDGET_CONTROL, wSelectionBase[0], MAP=1

    ;  Generate the integration data set and display it.
    ;
    WSET, drawWindowID
    ERASE
    d_mathstatGenerateIntegration, result
    statusString = 'Total Area : ' + STRING(result, FORMAT='(F9.4)')

    ;  Create the pixmaps
    ;
    nPixmap = 1
    pixmapArray = LONARR(nPixmap)
    for i = 0, nPixmap-1 do begin
        Window, /FREE, XSIZE=drawXSize, YSIZE=drawYSize, /PIXMAP
        pixmapArray[i] = !D.Window
    endfor

    if n_elements(record_to_filename) eq 0 then $
        record_to_filename = ''
    ;  Create the info structure
    ;
    sInfo = { $
        XPoly: FLTARR(200), $                ; Polynomial x ans y data set
        YPoly: FLTARR(200), $
        NPixmap: nPixmap, $                  ; Number of pixmaps
        PixmapArray: pixmapArray, $          ; Pixmap ID array
        DrawXSize: drawXSize, $              ; Size of drawing area
        DrawYSize: drawYSize, $
        CurrentBase : wSelectionBase[0], $   ; ID of current base
        ColorTable:colorTable, $             ; Color table to restore
        CharScale: charScale, $              ; Character scale factor
        DrawWindowID: drawWindowID, $        ; Window ID
        WTopBase: wTopBase, $                ; Top level base
        WSelectionBase: wSelectionBase, $    ; Selecton base ID
        WSelectButton: wSelectButton, $      ; Buttons and sliders IDs
        WGenerateButton: wGenerateButton, $  ; Generate new data button
        WAboveSlider: wAboveSlider, $        ; Set number of outlier above
        WBelowSlider: wBelowSlider, $        ; Set the number of outlier below
        WNPolySlider: wNPolySlider, $        ; Number of points for the polynomial
        WDegreeSlider: wDegreeSlider, $      ; Degree of the polynomial
        WNSurfaceSlider: wNSurfaceSlider, $  ; Number of points for surface fit
        WAreaDraw: wAreaDraw, $              ; Widget draw ID
        SText: sText, $                      ; Text structure for tips.
        plotFont: plotFont, $                ; Font to restore
        record_to_filename: record_to_filename, $
        orig_except: orig_except, $          ; original !except
        debug: keyword_set(debug), $
        groupBase: groupBase $               ; Base of Group Leader
    }

    demo_putTips, sInfo, statusString, 12

    ;  Register the info structure in the user value of the top-level base
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=sInfo, /NO_COPY

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1

    ; Register with the BIG GUY, XMANAGER!
    ;
    XMANAGER, "d_mathstat", wTopBase, /NO_BLOCK, $
        EVENT_HANDLER = "d_mathstatEvent", CLEANUP="d_mathstatCleanup"

end   ; of d_mathstat
