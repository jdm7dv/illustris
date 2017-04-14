;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_matrix.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_matrix.pro
;
;  CALLING SEQUENCE: d_matrix
;
;  PURPOSE:
;       This demo shows the various plots in IDL made from 2-D data.
;
;  MAJOR TOPICS: Data analysis and plotting
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_matrixGenerate            -  Generate the 2-D data set
;       pro d_matrixMakePlot            -  Make 5 plots to pixmaps.
;       pro d_matrixEvent            -  Event handler
;       pro d_matrixCleanup          -  Cleanup
;       pro d_matrix                  -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       matrix.tip
;       pro demo_gettips            - Read the tip file and create widgets
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
; -----------------------------------------------------------------------------
;
;  Purpose:  Generate a new data set
;
pro d_matrixGenerate, $
    xArray, $       ; OUT: x coordinates 
    yArray, $       ; OUT: y coordinates
    height, $       ; OUT: height data point 
    xVelocity, $    ; OUT: x velocity vector
    yVelocity       ; OUT: y velocity vector

    xVelocity = FLTARR(94, 78)
    yVelocity = FLTARR(94, 78)
    xArray = FLTARR(80)
    yArray = FLTARR(64)

    xVelocity = RANDOMN(seed, 94, 78)
    yVelocity = RANDOMN(seed, 94, 78)

    xVelocity = SMOOTH(xVelocity, 3)
    xVelocity = SMOOTH(xVelocity, 3)
    xVelocity = SMOOTH(xVelocity, 7)
    xVelocity = SMOOTH(xVelocity, 7)
    xVelocity = SMOOTH(xVelocity, 3)
    xVelocity = SMOOTH(xVelocity, 3)

    yVelocity = SMOOTH(yVelocity, 3)
    yVelocity = SMOOTH(yVelocity, 3)
    yVelocity = SMOOTH(yVelocity, 7)
    yVelocity = SMOOTH(yVelocity, 7)
    yVelocity = SMOOTH(yVelocity, 3)
    yVelocity = SMOOTH(yVelocity, 3)

    xVelocity = xVelocity[7:86, 7:70]
    yVelocity = yVelocity[7:86, 7:70]

    height = SQRT((xVelocity * xVelocity) + (yVelocity * yVelocity))
    xArray = FINDGEN(80) / 79.0
    yArray = FINDGEN(64) / 63.0

end     ;  of d_matrixGenerate

; -----------------------------------------------------------------------------
;
;  Purpose:  Make the plots
;
pro d_matrixMakePlot, $
    pixmapArray, $     ; IN: array of 7 pixmaps
    xArray,  $         ; IN; x data
    yArray, $          ; IN; y data
    height, $          ; IN; z data
    xVelocity, $       ; IN; velocity along x (for velocity plot)
    yVelocity, $       ; IN; velocity along y (for velocity plot)
    drawXSize, $       ; IN; x size of drawing area
    drawYSize, $       ; IN; y size of drawing area
    maxImage, $        ; IN; number of color in the images
    plotPosition       ; IN;  normalized position of the plots

    ;  Initialize the position values
    ;
    x0 = 0.175
    y0 = 0.175
    x1 = 0.5375
    y1 = 0.5375
    x2 = 0.9
    y2 = 0.9

    ;  First plot is the velocity field
    ;
    WSET, pixmapArray[0]
    ERASE
    previousFont = !P.FONT
    previousColor = !P.COLOR
    !P.FONT = (-1)
    !P.COLOR = maxImage + 3
    VEL, xVelocity, yVelocity, NVECS=500, XMAX=1.0, $
        TITLE=''
    !P.COLOR = previousColor
    !P.FONT = previousFont

    XYOUTS, (plotPosition[0]+plotPosition[2])/2.0, $
        (plotPosition[3]+0.03), 'Velocity Field', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0

    WSET, pixmapArray[6]
    ERASE
    previousColor = !P.COLOR
    previousFont = !P.FONT
    !P.FONT = (-1)
    !p.color = maxImage + 3
    VEL, xVelocity, yVelocity, NVECS=500, XMAX=1.0, $
        TITLE=''
    !P.COLOR = previousColor
    !P.FONT = previousFont

    XYOUTS, (plotPosition[0]+plotPosition[2])/2.0, $
        (plotPosition[3]+0.03), 'Velocity Field', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0

    WSET, pixmapArray[5]
    DEVICE, COPY=[ 0, 0, drawXSize/2, drawYSize/2, 0, $
         drawYSize/2, pixmapArray[6]]

    ;  Contour plot
    ;
    WSET, pixmapArray[1]
    colorVector = FIX(FLOAT(maxImage) * FINDGEN(8) / 7.0)
    CONTOUR, height, xArray, yArray, NLEVELS=8, C_COLORS=colorVector
    CONTOUR, height, xArray, yArray, /NODATA, /NOERASE
    XYOUTS, (plotPosition[0]+plotPosition[2])/2.0, $
        (plotPosition[3]+0.03), 'Contour', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0

    WSET, pixmapArray[6]
    ERASE
    colorVector = FIX(FLOAT(maxImage) * FINDGEN(8) / 7.0)
    CONTOUR, height, xArray, yArray, NLEVELS=8, C_COLORS=colorVector
    CONTOUR, height, xArray, yArray, /NODATA, /NOERASE
    XYOUTS, (plotPosition[0]+plotPosition[2])/2.0, $
        (plotPosition[3]+0.03), 'Contour', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0

    WSET, pixmapArray[5]
    DEVICE, COPY=[ 0, 0, drawXSize/2, drawYSize/2, drawXSize/2, $
         drawYSize/2, pixmapArray[6]]

    ;  Image plot
    ;
    WSET, pixmapArray[2]
    ERASE
    imagePosition = plotPosition
    imagePosition[[0,2]] = FIX(imagePosition[[0,2]] * $
        FLOAT(drawXSize))
    imagePosition[[1,3]] = FIX(imagePosition[[1,3]] * $
        FLOAT(drawYSize))
    image = BYTSCL(CONGRID(height, (imagePosition[2]-imagePosition[0]), $
        (imagePosition[3]-imagePosition[1]), /INTERP), TOP=maxImage)
    TV, image, imagePosition[0], imagePosition[1]
    CONTOUR, height, xArray, yArray, /NODATA, /NOERASE
    XYOUTS, (plotPosition[0]+plotPosition[2])/2.0, $
        (plotPosition[3]+0.03), 'Image', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0

    WSET, pixmapArray[6]
    ERASE
    imagePosition = plotPosition
    imagePosition[[0,2]] = FIX(imagePosition[[0,2]] * $
        FLOAT(drawXSize/2))
    imagePosition[[1,3]] = FIX(imagePosition[[1,3]] * $
        FLOAT(drawYSize/2))
    image = BYTSCL(CONGRID(height, (imagePosition[2]-imagePosition[0]), $
        (imagePosition[3]-imagePosition[1]), /INTERP), TOP=maxImage)
    TV, image, imagePosition[0], imagePosition[1]
    CONTOUR, height, xArray, yArray, /NODATA, /NOERASE
    XYOUTS, (plotPosition[0]+plotPosition[2])/2.0, $
        (plotPosition[3]+0.03), 'Image', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0

    WSET, pixmapArray[5]
    DEVICE, COPY=[ 0, 0, drawXSize/2, drawYSize/2, 0, $
         0, pixmapArray[6]]

    ;  Surface plot
    ;
    height2 = CONGRID(height, 20, 16)
    xArray2 = FINDGEN(20)/ 19.0
    yArray2 = FINDGEN(16)/ 15.0
    shadow = BYTSCL(CONGRID((yVelocity-xVelocity), 26, 26, /INTERP), $
        TOP=maxImage)
    previousTicklen = !P.TICKLEN
    !P.TICKLEN=(-0.05)
    previousFont = !P.FONT
    !P.FONT = (-1)
    position = [0.175, 0.175, 0.9, 0.9]

    WSET, pixmapArray[3]
    SHADE_SURF, height2, xArray2, yArray2, $
        AX=60, AZ=30, ZRANGE=[-0.25, 0.75], $
        SHADES=shadow, $
        XTICKNAME=[' 0.0',' 0.2',' 0.4',' 0.6',' 0.8',' 1.0'], $
        YTICKNAME=['0.0 ','0.2 ','0.4 ','0.6 ','0.8 ','    ']
    SURFACE, height2, xArray2, yArray2, $
        AX=60, AZ=30, ZRANGE=[-0.25, 0.75], /NOERASE, $
        XTICKNAME=[' 0.0',' 0.2',' 0.4',' 0.6',' 0.8',' 1.0'], $
        YTICKNAME=['0.0 ','0.2 ','0.4 ','0.6 ','0.8 ','    '], $
        SKIRT=(-0.25), COLOR= maxImage+3
    SURFACE, height2, xArray2, yArray2, $
        AX=60, AZ=30, ZRANGE=[-0.25, 0.75], /NOERASE, $
        XTICKNAME=[' 0.0',' 0.2',' 0.4',' 0.6',' 0.8',' 1.0'], $
        YTICKNAME=['0.0 ','0.2 ','0.4 ','0.6 ','0.8 ','    '], $
        SKIRT=(-0.25), /NODATA
    XYOUTS, (Position[0]+position[2])/2.0, $
        (position[3]+0.03), 'Shaded Surface', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0


    WSET, pixmapArray[6]
    ERASE
    SHADE_SURF, height2, xArray2, yArray2, $
        AX=60, AZ=30, ZRANGE=[-0.25, 0.75], $
        SHADES=shadow, $
        XTICKNAME=[' 0.0',' 0.2',' 0.4',' 0.6',' 0.8',' 1.0'], $
        YTICKNAME=['0.0 ','0.2 ','0.4 ','0.6 ','0.8 ','    ']
    SURFACE, height2, xArray2, yArray2, $
        AX=60, AZ=30, ZRANGE=[-0.25, 0.75], /NOERASE, $
        XTICKNAME=[' 0.0',' 0.2',' 0.4',' 0.6',' 0.8',' 1.0'], $
        YTICKNAME=['0.0 ','0.2 ','0.4 ','0.6 ','0.8 ','    '], $
        SKIRT=(-0.25), COLOR= maxImage+3
    SURFACE, height2, xArray2, yArray2, $
        AX=60, AZ=30, ZRANGE=[-0.25, 0.75], /NOERASE, $
        XTICKNAME=[' 0.0',' 0.2',' 0.4',' 0.6',' 0.8',' 1.0'], $
        YTICKNAME=['0.0 ','0.2 ','0.4 ','0.6 ','0.8 ','    '], $
        SKIRT=(-0.25), /NODATA
    XYOUTS, (position[0]+position[2])/2.0, $
        (position[3]+0.03), 'Shaded Surface', /NORMAL, $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 1.25), FONT=0


    WSET, pixmapArray[5]
    DEVICE, COPY=[ 0, 0, drawXSize/2, drawYSize/2, drawXSize/2, $
         0, pixmapArray[6]]

    !P.TICKLEN= previousTicklen
    !P.FONT = previousFont

    ;  Get the current color vectors to restore when this application is exited.
    ;
    TVLCT, saveR, saveG, saveB, /GET

    ;  Build color table from color vectors.
    ;
    previousTable = [[saveR],[saveG],[saveB]]

    ;  Show3 plot.
    ;
    WSET, pixmapArray[4]
    SHOW3, height

    ;  Scale the image in order to conform to the color table
    ;
    show3Image = TVRD()
    show3Image = BYTSCL(show3Image, TOP = maxImage-1)
    ERASE
    TV, show3Image

    TVLCT, previousTable, 0

end     ;   of  d_matrixMakePlot

; -----------------------------------------------------------------------------
;
;  Purpose:  Event handler
;
pro d_matrixEvent, $
    sEvent     ; IN: event structure

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    ;  Get the info structure from top-level base.
    ;
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
      
    ;  Determine which event.
    ; 
    WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventval

    ;  Take the following action based on the corresponding event.
    ;
    case eventval of

        "GENERATE": begin
           
            WIDGET_CONTROL, sInfo.wLeftBase, sensitive=0
            WIDGET_CONTROL, sInfo.wFileButton, sensitive=0
            WIDGET_CONTROL, sInfo.wHelpButton, sensitive=0
            
            WSET, sInfo.drawWindowID
            ERASE
            XYOUTS, 0.5, 0.5, /NORMAL, COLOR=sInfo.maxImage+7, $ 
                ' GENERATING DATA   PLEASE WAIT....', $
                ALIGNMENT=0.5, SIZE=(!P.Charsize * 6.0), FONT=0

            ;  Generate a data set
            ;
            d_matrixGenerate, xArray, yArray, height, xvelocity, yvelocity

            d_matrixMakePlot, sInfo.pixmapArray, xArray, yArray, height, $
                xVelocity, yVelocity, sInfo.drawXSize, sInfo.drawYSize, $
                sInfo.maxImage, sInfo.plotPosition

            ;  Display the 4 plots screen
            ;
            WSET, sInfo.drawWindowID
            DEVICE, COPY=[ 0,0, sInfo.drawXSize, sInfo.drawYSize, 0, $
                 0, sInfo.pixmapArray[5]]

            WIDGET_CONTROL, sInfo.wPlotDroplist, SET_VALUE=5

            WIDGET_CONTROL, sInfo.wLeftBase, sensitive=1
            WIDGET_CONTROL, sInfo.wFileButton, sensitive=1
            WIDGET_CONTROL, sInfo.wHelpButton, sensitive=1

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end     ;       of GENERATE

        "PLOTLIST": begin

            case sEvent.Value of
  
                ;  Velocity field
                ;
                0 : begin
                    WSET, sInfo.drawWindowID
                    DEVICE, COPY=[ 0,0, sInfo.drawXSize, $
                        sInfo.drawYSize, 0, $
                        0, sInfo.pixmapArray[0]]
                end    ;    of 0

                ;  Contour plot
                ;
                1 : begin
                    WSET, sInfo.drawWindowID
                    DEVICE, COPY=[ 0,0, sInfo.drawXSize, $
                        sInfo.drawYSize, 0, $
                        0, sInfo.pixmapArray[1]]
                end    ;    of 1

                ;  Image
                ;
                2 : begin
                    WSET, sInfo.drawWindowID
                    DEVICE, COPY=[ 0,0, sInfo.drawXSize, $
                        sInfo.drawYSize, 0, $
                        0, sInfo.pixmapArray[2]]
                end    ;    of 2

                ;  Shaded Surface plot
                ;
                3 : begin
                    WSET, sInfo.drawWindowID
                    DEVICE, COPY=[ 0,0, sInfo.drawXSize, $
                        sInfo.drawYSize, 0, $
                        0, sInfo.pixmapArray[3]]
                end    ;    of 3

                ;  Show3 plot
                ;
                4 : begin
                    WSET, sInfo.drawWindowID
                    DEVICE, COPY=[ 0,0, sInfo.drawXSize, $
                        sInfo.drawYSize, 0, $
                        0, sInfo.pixmapArray[4]]
                end    ;    of 4

                ;  Show 4  plots (velocity, contour, image, surface)
                ;
                5 : begin
                    WSET, sInfo.drawWindowID
                    DEVICE, COPY=[ 0,0, sInfo.drawXSize, $
                        sInfo.drawYSize, 0, $
                        0, sInfo.pixmapArray[5]]
                end    ;    of 5

            endcase     ;  of listValue

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

        end     ;   of PLOTLIST


        "ABOUT": begin
        
            ;  Display the information.
            ;
            ONLINE_HELP, $
               book=demo_filepath("d_matrix.pdf", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH

            ;  Restore the info structure
            ;
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
      
        end   
                   
        "QUIT": begin
     
            ;  Restore the info structure before destroying event.top
            ;
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
                   
            ;  Destroy widget hierarchy.
            ;
            WIDGET_CONTROL, sEvent.top, /DESTROY
         
        end

        ELSE :  begin

            PRINT, 'Case Statement found no matches'

            ; Restore the info structure
            ;
            WIDGET_CONTROL, sEvent.top, Set_UValue=info, /No_Copy
        end

    endcase
   
end               ; of d_matrixEvent

; -----------------------------------------------------------------------------
;
;  Purpose:  Cleanup procedure
;
pro d_matrixCleanup, $
    wTopBase      ; IN: top level base associated with the cleanup

    ;  Get the color table saved in the window's user value.
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sInfo,/No_Copy
      
    ;  Restore the previous color table.
    ;
    TVLCT, sInfo.colorTable
   
    ;  Delete the pixmaps.
    ;
    for i = 0, sInfo.nPixmap-1 do begin
        WDELETE, sInfo.pixmapArray[i]
    endfor
   
    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sInfo.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sInfo.groupBase, /MAP

end   ; of CleanupTemplate


; -----------------------------------------------------------------------------
;
;  Purpose:  Main procedure of the matrix demo
;
pro d_matrix, $
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

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

    ;  Make the system to have a maximum of 256 colors
    ;
    numcolors = !d.N_COLORS
    if( (( !D.NAME EQ 'X') or (!D.NAME EQ 'MAC')) $
        and (!d.N_COLORS GE 256L)) then $
        DEVICE, PSEUDO_COLOR=8

    DEVICE, DECOMPOSED=0, BYPASS_TRANSLATION=0

    ;  Get the current color table 
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ;  Build color table from color vectors
    ;
    colorTable = [[savedR],[savedG],[savedB]]

    LOADCT, 5, /SILENT
    
    ;  Save the currnet position system variables and set a new one
    ;
    previousPosition = !P.Position
    plotPosition = FLTARR(4)
    plotPosition = [0.175, 0.175, 0.9, 0.9]
    !P.Position = plotPosition

    ;  Get the character scaling factor
    ;
    charscale = 8.0/!d.X_CH_SIZE

    ;  Load a color table, reserve the last 9 colors for annotation
    ;
    LOADCT, 5, /SILENT

    maxImage = !D.TABLE_SIZE-9  ;  maximum number of color for plots

    ;  Load 8 tek colors, the last color index is the
    ;  one from the original  color table.
    ;
    TEK_COLOR, maxImage, 8        

    ;  Determine hardware display size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize

    ;  Create the starting up message.
    ;
    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
    endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse

    ; Define a main widget base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(TITLE="Matrix Plotting", /COLUMN, $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            TLB_FRAME_ATTR=1, MBAR=barBase)
    endif else begin
        wTopBase = WIDGET_BASE(TITLE="Matrix Plotting", /COLUMN, $
            /TLB_KILL_REQUEST_EVENTS, $
            MAP=0, $
            GROUP_LEADER=group, $
            TLB_FRAME_ATTR=1, MBAR=barBase)
    endelse

        ;  Create the quit button
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE= 'File', /MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Quit', UVALUE='QUIT')

        ; Create the help button
        ;
        wHelpButton = WIDGET_BUTTON(barBase, /HELP, $
            VALUE='About', /MENU)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Matrix Plotting', UVALUE='ABOUT')

        ;  Create the first child of the top level base
        ; 
        wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2, /FRAME)

            ;  Create a base for the left column
            ;
            wLeftBase = WIDGET_BASE(wTopRowBase, $
                /BASE_ALIGN_CENTER, /COLUMN)
        
                ;  Create a droplist to select the the plot
                ;
                wPlotDropList = CW_BGROUP(wLeftBase, /COLUMN, $
                    ['Velocity Field', 'Contour', $
                    'Image', 'Shaded Surface', $
                    'Show3 Plot', '4 Plots'], $
                    /NO_RELEASE, $
                    /EXCLUSIVE, UVALUE='PLOTLIST', SET_VALUE=5)

                ;  Create the generate button that generates
                ;  a new data set
                ;
                wGenerateBase = WIDGET_BASE(wLeftBase, /COLUMN, $
                    YPAD=20)

                    wGenerateButton = WIDGET_BUTTON(wGenerateBase, $
                        VALUE='Generate New Data', UVALUE='GENERATE')

            ;  Create a base for the right column
            ;
            wRightBase = WIDGET_BASE(wTopRowBase, /COLUMN)

            ;  Create a draw widget
            ;
            drawXSize = 0.6*screenSize[0]
            drawYSize = 0.8*drawXSize
            wAreaDraw = WIDGET_DRAW(wRightBase, XSIZE=drawXSize,  $
                YSIZE=drawYSize, RETAIN=2)

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wTopBase

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('matrix.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)

    WIDGET_CONTROL, wTopBase, SENSITIVE=0

    ; Determine the window value of plot window, wDraw1.
    ;
    WIDGET_CONTROL, wAreaDraw, GET_VALUE=drawWindowID

    WSET, drawWindowID
    XYOUTS, 0.5, 0.5, /NORMAL, COLOR=maxImage+7, $ 
        ' GENERATING DATA   PLEASE WAIT....', $
        ALIGNMENT=0.5, SIZE=(!P.Charsize * 6.0), FONT=0

    ;  Generate a data set
    ;
    d_matrixGenerate, xArray, yArray, height, xvelocity, yvelocity


    ;  Create the plots and place each of them in a pixmap
    ;
    nPixmap = 7
    pixmapArray = LONARR(nPixmap)
    for i = 0, 5 do begin
        Window, /FREE, XSIZE= drawXSize, YSIZE=drawYSize, /PIXMAP
        pixmapArray[i] = !D.Window
    endfor

    Window, /FREE, XSIZE= drawXSize/2, YSIZE=drawYSize/2, /PIXMAP
    pixmapArray[6] = !D.Window

    d_matrixMakePlot, pixmapArray, xArray, yArray, height, $
         xVelocity, yVelocity, drawXSize, drawYSize, $
         maxImage, plotPosition

    ;  Display the 4 plots screen
    ;
    WSET, drawWindowID
    DEVICE, COPY=[ 0,0, drawXSize, drawYSize, 0, $
         0, pixmapArray[5]]

    ;  Create the info structure
    ;
    sInfo={ colorTable: colorTable, $         ; color table to restore
        DrawXSize: drawXSize, $               ; Window dimension
        DrawYSize: drawYSize, $
        PixmapArray: pixmapArray, $           ; Pixmap arrays
        MaxImage: maxImage, $                 ; Number of color for plots
        NPixmap: nPixmap, $                   ; Number of pixmap
        PlotPosition: plotPosition, $         ; Plot position in the view
        DrawWindowID: drawWindowID, $         ; Window ID
        WAreaDraw: wAreaDraw, $               ; Draw window ID
        WPlotDroplist: wPlotDroplist, $       ; Droplist ID
        WHelpButton: wHelpButton, $           ; Help button ID
        WQuitButton: wQuitButton, $           ; Quit button ID
        WFileButton: wFileButton, $           ; File button ID
        WTopBase: wTopBase, $                 ; Top level base ID
        WLeftBase: wLeftBase, $               ; Left base ID
        WStatusBase: wStatusBase, $           ; Statusbase ID
        WGenerateButton: wGenerateButton, $   ; Generate button ID
        groupBase: groupBase $                ; Base of Group Leader
    }
    
    ;  Register the info structure in the user value of the top-level base
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=sInfo, /NO_COPY
    
    WIDGET_CONTROL, wTopBase, SENSITIVE=1

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1

    XMANAGER, "Template", wTopBase, $
        /NO_BLOCK, $
        EVENT_HANDLER="d_matrixEvent", CLEANUP="d_matrixCleanup"

end   ;  main procedure
