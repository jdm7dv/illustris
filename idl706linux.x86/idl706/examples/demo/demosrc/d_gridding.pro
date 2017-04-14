; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_gridding.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_gridding.pro
;
;  CALLING SEQUENCE: d_gridding
;
;  PURPOSE:
;       Display the gridding and interpolation routines in IDL.
;
;  MAJOR TOPICS: Data analysis and plotting.
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_griddingGeneratePlots       - Generate all the plots
;       pro d_griddingEvent          - Event handler
;       pro d_griddingCleanup         - Cleanup
;       pro d_gridding                - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       gridding.tip
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY: Written by DAT,RSI,  January 1997
;-
;--------------------------------------------------------------------
;
;  Purpose:  Generate all the plots.
;
pro d_griddingGeneratePlots, $
    drawXSize, $         ; IN:   x dimension of drawing area
    drawYSize, $         ; IN:   y dimension of drawing area
    pixmapArray          ; IN:   pixmap array for plotting windows.

    previousXMargin = !X.MARGIN
    !X.MARGIN=[7,3]

    ;  Generate data. This is a biquadratic function with
    ;  added noise.
    ;
    a = FLTARR(6)
    a = [6.9, -0.0012, -0.1247, -0.035, 0.54, -0.016]
    np =21
    x = FLTARR(np)
    y = FLTARR(np)
    z = FLTARR(np)

    x = (randomu(seed, np) -0.5) * 20.0
    y = (randomu(seed, np) -0.5) * 20.0
    for i = 0, np-1 do begin
        z[i] = a[0] + a[1]*x[i] + a[2]*x[i]*x[i] + $
            a[3]*x[i]*y[i] + a[4]*y[i] + a[5]*y[i]*y[i] + $
            RANDOMN(seed,1)*2.0
    endfor

    ;  Create the X-Y plots showing the points location.
    ;
    WSET, pixmapArray[0]
    PLOT, x, y, PSYM=1, COLOR=3, BACKGROUND=0
    PLOT, x, y, PSYM=1, COLOR=7, /NODATA, $
        /NOERASE, $
        BACKGROUND=0, $
        XTITLE='X', YTITLE='Y', $
        TITLE='Data Point Locations'

    ;  Create the X-Y plots with the Delauney triangulation.
    ;
    WSET, pixmapArray[1]
    PLOT, x, y, PSYM=1, COLOR=3, BACKGROUND=0
    TRIANGULATE, x, y, triangles, bValue
    for i = 0, N_ELEMENTS(triangles)/3-1  do begin
        t = [triangles[*,i], triangles[0,i] ]
        PLOTS, x[t], y[t], COLOR=3
    endfor
    PLOT, x, y, PSYM=1, COLOR=7, /NODATA, $
        /NOERASE, $
        XTITLE='X', YTITLE='Y', $
        BACKGROUND=0, $
        TITLE='Delauney Triangulation'

    ;  Create the bilinear interpolation of the triangles.
    ;
    WSET, pixmapArray[2]
    xCoordinates = (FINDGEN(51) - 25.0) * 0.4
    yCoordinates = (FINDGEN(51) - 25.0) * 0.4

    SURFACE, TRIGRID(x, y, z, triangles, $
        MISSING=-20.0, MIN_VALUE=-20.0), $
        xCoordinates, yCoordinates, $
        COLOR=5, $
        BACKGROUND=0, $
        XMINOR=0, YMINOR=0, ZMINOR=0, $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10.0,10.0], YRANGE=[-10.0, 10.0], ZRANGE=[-30.0,30.0]

    SURFACE, TRIGRID(x, y, z, triangles, $
        MISSING=-20.0, MIN_VALUE=-20.0), $
        xCoordinates, yCoordinates, $
        COLOR=7, $
        BACKGROUND=0, $
        XMINOR=0, YMINOR=0, ZMINOR=0, $
        /NODATA, /NOERASE, $
        XTITLE='X', YTITLE='Y', ZTITLE='Z', $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10.0,10.0], YRANGE=[-10.0, 10.0], ZRANGE=[-30.0,30.0]

    XYOUTS, 0.5, 0.9, 'Bilinear Interpolation', $
        /NORMAL, ALIGNMENT=0.5, COLOR=7


    ;  Create the quintic interpolation of the triangles.
    ;
    WSET, pixmapArray[3]

    SURFACE, TRIGRID(x, y, z, triangles, /QUINTIC, $
        MISSING=-20.0, MIN_VALUE=-20.0), $
        xCoordinates, yCoordinates, $
        COLOR=8, $
        BACKGROUND=0, $
        XMINOR=0, YMINOR=0, ZMINOR=0, $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10.0,10.0], YRANGE=[-10.0, 10.0], ZRANGE=[-30.0,30.0]

    SURFACE, TRIGRID(x, y, z, triangles, /QUINTIC, $
        MISSING=-20.0, MIN_VALUE=-20.0), $
        xCoordinates, yCoordinates, $
        COLOR=7, $
        BACKGROUND=0, $
        XMINOR=0, YMINOR=0, ZMINOR=0, $
        /NODATA, /NOERASE, $
        XTITLE='X', YTITLE='Y', ZTITLE='Z', $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10.0,10.0], YRANGE=[-10.0, 10.0], ZRANGE=[-30.0,30.0]
   
    XYOUTS, 0.5, 0.9, 'Quintic Interpolation', $
        /NORMAL, ALIGNMENT=0.5, COLOR=7

    ;  Create the smooth interpolation of the triangles.
    ;
    WSET, pixmapArray[4]

    SURFACE, TRIGRID(x, y, z, triangles, /QUINTIC, $
        MISSING=-20.0, MIN_VALUE=-20.0, EXTRA=bValue), $
        xCoordinates, yCoordinates, $
        COLOR=10, $
        BACKGROUND=0, $
        XMINOR=0, YMINOR=0, ZMINOR=0, $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10.0,10.0], YRANGE=[-10.0, 10.0], ZRANGE=[-30.0,30.0]

    SURFACE, TRIGRID(x, y, z, triangles, /QUINTIC, $
        MISSING=-20.0, MIN_VALUE=-20.0, EXTRA=bValue), $
        xCoordinates, yCoordinates, $
        COLOR=7, $
        BACKGROUND=0, $
        XMINOR=0, YMINOR=0, ZMINOR=0, $
        /NODATA, /NOERASE, $
        XTITLE='X', YTITLE='Y', ZTITLE='Z', $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10.0,10.0], YRANGE=[-10.0, 10.0], ZRANGE=[-30.0,30.0]
   
    XYOUTS, 0.5, 0.9, 'Smooth Interpolation', $
        /NORMAL, ALIGNMENT=0.5, COLOR=7

    ;  Interpolate and grid by the Kriging method (or
    ;  optimal interpolation).
    ;
    WSET, pixmapArray[5]
    xval = FINDGEN(21) -10.0
    yval = FINDGEN(21) -10.0

    eModel = [6.0, 0.4]
    krigres = KRIG2D(z, x, y, $
        EXPONENTIAL = eModel, $
        GS=[1.0, 1.0], $
        BOUNDS=[-10.0, -10.0, 10.0, 10.0] )

    SURFACE, krigres, $
        xval, yval, $
        COLOR=1, $
        BACKGROUND=0, $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10,10], YRANGE=[-10, 10], ZRANGE=[-30,30]

    SURFACE, krigres, $
        xval, yval, $
        COLOR=7, $
        BACKGROUND=0, $
        /NODATA, /NOERASE, $
        XTITLE='X', YTITLE='Y', ZTITLE='Z', $
        XSTYLE=1, YSTYLE=1, ZSTYLE=1, $
        XRANGE=[-10,10], YRANGE=[-10, 10], ZRANGE=[-30,30]

    XYOUTS, 0.5, 0.9, 'Kriging Interpolation', $
        /NORMAL, ALIGNMENT=0.5, COLOR=7
    x =0
    y =0
    z =0

    !X.MARGIN = previousXMargin

end     ;   of d_griddingGeneratePlots
;
;--------------------------------------------------------------------
;
pro d_griddingEvent, $
    sEvent      ; IN: event structure

    ;  Quit this application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

    case eventUValue of

        ;  Show the appropriate plot.
        ;
        'SELECT' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WSET, sInfo.rightWindowID
            selection = WIDGET_INFO(sInfo.wSelectDropList, /DROPLIST_SELECT)
            DEVICE, COPY=[0, 0, sInfo.drawXSize, sInfo.drawYSize, $
                0, 0, sInfo.pixmapArray[selection]]
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end   ;                      of   SELECT

        'GENERATE' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sEvent.top, /HOURGLASS
    
            WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
            ;  Generate the new data set and plots.
            ;
            d_griddingGeneratePlots, sInfo.drawXSize, $
                sInfo.drawYSize, sInfo.pixmapArray

            ;  Show the default plots.
            ;
            WSET, sInfo.leftWindowID
            DEVICE, COPY=[0, 0, sInfo.drawXSize, $
                sInfo.drawYSize, 0, 0, sInfo.pixmapArray[2]]

            WSET, sInfo.rightWindowID
            selection = WIDGET_INFO(sInfo.wSelectDropList, /DROPLIST_SELECT)
            DEVICE, COPY=[0, 0, sInfo.drawXSize, $
                sInfo.drawYSize, 0, 0, sInfo.pixmapArray[selection]]

            WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  GENERATE

        'QUIT' : begin
            WIDGET_CONTROL, sEvent.top, /DESTROY
        end

        'ABOUT' : begin
           ONLINE_HELP, 'd_gridding', $
              book=demo_filepath("idldemo.adp", $
                      SUBDIR=['examples','demo','demohelp']), $
                      /FULL_PATH
        end           ;  of ABOUT

        ELSE :   ;  do nothing

    endcase
end

;--------------------------------------------------------------------
;
pro d_griddingCleanup, wTopBase

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

    ;  Restore the preivous state.
    ;
    !P.CHARSIZE = sInfo.previousCharSize
    !X.MARGIN = sInfo.previousXMar
    !Y.MARGIN = sInfo.previousYMar

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sInfo.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sInfo.groupBase, /MAP

end   ; of MathStatCleanup

;--------------------------------------------------------------------
;
;   PURPOSE  : Show the gridding and interpolation routines.
;              Display the interpolated values.
;
pro d_gridding, $
    GROUP=group, $   ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

    previousXMar = !X.margin
    previousYMar = !Y.margin

    !X.MARGIN = [8, 3]
    !Y.MARGIN = [4, 4]
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

    ;  Load the color table and the tek colors.
    ;
    LOADCT, 1 , /SILENT
    TEK_COLOR

    ;  Save the font
    ;
    plotFont = !P.FONT

    ;  Load a new color table
    ;
    LOADCT, 12, /SILENT
    TEK_COLOR

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

    ;  Here there are 2 display area. Their size (x dimension)
    ;  Set up their dimensions.
    ;
    drawXSize = (0.8 * screenSize[0]) / 2.0
    drawYSize = drawXSize


    ;  Create the widgets
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(TITLE="Gridding", $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            /COLUMN, $
            TLB_FRAME_ATTR = 1, MBAR=barBase)
    endif else begin
        wTopBase = WIDGET_BASE(TITLE="Gridding", $
            /COLUMN, GROUP_LEADER=group, $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            TLB_FRAME_ATTR = 1, MBAR=barBase)
    endelse

        ;  Create the menu bar items
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE='File')

            wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                UVALUE='QUIT')

        ;  Create the generate data buttons.
        ;
        wDataButton = WIDGET_BUTTON(barBase, VALUE='Data')

            wGridButton = WIDGET_BUTTON(wDataButton, $
                VALUE='Generate New Data', $
                UVALUE='GENERATE')

        wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Gridding', $
                UVALUE='ABOUT')

        ;  Create the left and right bases. One display in each
        ;  bases
        ;
        wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2)

            wLeftBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                wLeftDraw = WIDGET_DRAW(wLeftBase, XSIZE=drawXSize, $
                    YSIZE=drawYSize, RETAIN=2, UVALUE='RIGHTDRAW')

            wRightBase = WIDGET_BASE(wTopRowBase, $
                /BASE_ALIGN_CENTER, /COLUMN)

                wRightDraw = WIDGET_DRAW(wRightBase, XSIZE=drawXSize, $
                    YSIZE=drawYSize, RETAIN=2, UVALUE='RIGHTDRAW')

                wSelectDropList = WIDGET_DROPLIST(wRightBase, $
                    VALUE=['Data Point Locations', $
                    'Delauney Triangulation', $
                    'Bilinear Interpolation', $
                    'Quintic Interpolation', $
                    'Smooth Interpolation', $
                    'Kriging Interpolation'], $
                    UVALUE='SELECT')


        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('gridding.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)

    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wTopBase

    WIDGET_CONTROL, wSelectDroplist, SET_DROPLIST_SELECT=4

    ; Determine the window value of plot window, wLeftDraw and wRightDraw.
    ;
    WIDGET_CONTROL, wLeftDraw, GET_VALUE=leftWindowID
    WIDGET_CONTROL, wRightDraw, GET_VALUE=rightWindowID

    ;  Create the pixmaps
    ;
    nPixmap = 6
    pixmapArray = LONARR(nPixmap)
    for i = 0, nPixmap-1 do begin
        WINDOW, /FREE, XSIZE=drawXSize, YSIZE=drawYSize, /PIXMAP
        pixmapArray[i] = !D.Window
    endfor


    ;  Generate the data and make the triangulation and
    ;  bilinear interpolation as default.
    ;
    d_griddingGeneratePlots, drawXSize, drawYSize, pixmapArray

    ;  Show the default views. On the left view, show 
    ;  bilinear interpolation plot, on the right, show
    ;  the smooth interpolation plot.
    ;
    WSET, leftWindowID
    DEVICE, COPY=[0, 0, drawXSize, drawYSize, 0, 0, pixmapArray[2]]

    WSET, rightWindowID
    DEVICE, COPY=[0, 0, drawXSize, drawYSize, 0, 0, pixmapArray[4]]

    ;  Get the character scaling factor.
    ;
    charscale = 8.0/!d.X_CH_SIZE

    previousCharSize = !P.CHARSIZE

    ;  Create the info structure
    ;
    sInfo = { $
        NPixmap: nPixmap, $                    ; Number of pixmaps
        PixmapArray: pixmapArray, $            ; Array of pixmap IDs
        DrawXSize: drawXSize, $                ; X size of drawing area
        DrawYSize: drawYSize, $                ; Y size of drawing area
        ColorTable:colorTable, $               ; color table to restore
        CharScale: charScale, $                ; Character scaling factor
        LeftWindowID: leftWindowID, $          ; Windows ID
        RightWindowID: rightWindowID, $
        WTopBase: wTopBase, $                  ; top level base ID
        WLeftDraw: wLeftDraw, $                ; Widget draw IDs
        WRightDraw: wRightDraw, $
        WSelectDropList: wSelectDropList, $    ; Selection droplist ID
        PreviousCharSize: previousCharSize, $  ; Previous character size
        PreviousXMar: previousXMar, $          ; Previous x margin
        PreviousYMar: previousYMar, $          ; Previous y margin
        plotFont: plotFont, $                  ; Font number
        groupBase: groupBase $                 ; Base of Group Leader
    }

    ;  Register the info structure in the user value of the top-level base
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=sInfo, /NO_COPY

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1

    ; Register with the BIG GUY, XMANAGER
    ;
    XMANAGER, "d_gridding", wTopBase, $
        /NO_BLOCK, $
        EVENT_HANDLER="d_griddingEvent", CLEANUP="d_griddingCleanup"

end   ; of gridding
