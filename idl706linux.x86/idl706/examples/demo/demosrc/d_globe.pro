; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_globe.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_globe.pro
;
;  CALLING SEQUENCE: d_globe
;
;  PURPOSE:
;       Demonstrates texture mapping, model rotations, and indexed color
;       table stretching with IDL's object graphics system.
;       (object graphics only)
;
;  MAJOR TOPICS: Indexed colors & Color palettes, Texture Mapping, Trackball.
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_globeRGBStretch       - stretches RGB vectors to new RGB vectors
;       pro d_globeStretchEvent     - event handler for stretching colors
;       pro d_globeEvent            - event handler
;       pro d_globeCleanup          - cleanup routine
;       pro d_globeReadImages       - inputs and scales images
;       function d_globeMakeObjects - creates the object hierarchy
;       pro d_globe                 - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro trackball__define.pro - Create trackball object.
;       pro orb__define.pro       - Create an orb object
;       pro demo_gettips          - Read the tip file and create widgets
;       globe.tip                 - "Tips" file
;       worldelv.dat              - global topography image dataset
;       worldtmp.sav              - global temperature image dataset & RGB's
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY: Written by:  MCR, RSI,  February 97
;-
;----------------------------------------------------------------------
; PURPOSE  This routine stretches old RGB vectors
;          (oldReds, oldGreens, oldBlues)  based on
;          low and high stretch values (low, high)
;          and passes back new  RGB vectors
;          (newReds, newGreens, newBlues).  This routine
;          is based on the Stretch.pro routine found within
;          the IDL distribution.  One  may stretch color vectors
;          of any length.
;
pro d_globeRGBStretch, $
    oldReds, oldGreens, oldBlues, $ ;IN: Input RGB Vectors
    newReds, newGreens, newBlues, $ ;OUT: Output RGB Vectors
    LOW=low, HIGH=high          ;IN: (opt) stretch indices

    WIDGET_CONTROL, HOURGLASS = 1

    nColors=N_ELEMENTS(oldReds)

    if (not KEYWORD_SET(low)) then $
        low=0L

    if (not KEYWORD_SET(high)) then $
        high=nColors-1L

    if (high-low ne 0) then begin        ;if low and high are not equal
        slope=FLOAT(nColors-1)/(high-low)
        intercept=-slope*low
    endif else begin                     ;if low and high are equal
        slope=0b & intercept=low
    endelse

    sub=LONG(FINDGEN(nColors)*slope+intercept)
    newReds=oldReds[sub]
    newGreens=oldGreens[sub]
    newBlues=oldBlues[sub]
    WIDGET_CONTROL, HOURGLASS = 0

end

;----------------------------------------------------------------------
;
; PURPOSE ; This is a secondary event handler routine
;           used in the Globe demo. This routine is used
;           to stretch the coor indices of the respective
;           datasets. One can either stretch the color vectors
;           for the temperature data or stretch the colors
;           vectors for the topography data.
;
pro d_globeStretchEvent, $
    sEvent

    WIDGET_CONTROL, HOURGLASS = 1
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
    WIDGET_CONTROL, sEvent.id, GET_UVALUE=wsliders

    ;  Build subscripts of RGB vectors associated
    ;  with the images.
    ;
    elev=LINDGEN(sState.nColors/2)
    temps=LINDGEN(sState.nColors/2)+sState.nColors/2

    ;  Check that minimim sliders do not exceed
    ;  the maximum sliders and
    ;  that maximum sliders are not less than minimum sliders
    ;  and make adjustments as needed.
    ;
    WIDGET_CONTROL, wsliders[0], GET_VALUE=sliderValue0
    WIDGET_CONTROL, wsliders[1], GET_VALUE=sliderValue1
    WIDGET_CONTROL, wsliders[2], GET_VALUE=sliderValue2
    WIDGET_CONTROL, wsliders[3], GET_VALUE=sliderValue3

    if (sEvent.id EQ wsliders[0] and sliderValue0 gt sliderValue1) then begin
        WIDGET_CONTROL, wsliders[0], SET_VALUE=sliderValue1
        sliderValue0 = sliderValue1
    endif

    if (sEvent.id EQ wsliders[1] and sliderValue0 gt sliderValue1) then begin
        WIDGET_CONTROL, wsliders[1], SET_VALUE=sliderValue0
        slidervalue1 = sliderValue0
    endif

    if (sEvent.id EQ wsliders[2] and sliderValue2 gt sliderValue3) then begin
        WIDGET_CONTROL, wsliders[2], SET_VALUE=sliderValue3
        sliderValue2 = sliderValue3
    endif

    if (sEvent.id EQ wsliders[3] and sliderValue2 gt sliderValue3) then begin
        WIDGET_CONTROL, wsliders[3], SET_VALUE=sliderValue2
        sliderValue3 = sliderValue2
    endif

    ;  Stretch the original color vectors and then save the stretched
    ;  vectors into the color palette.  Note, the original colors are
    ;  always stretch so that information is not lost by stretching
    ;  vectors that have already been stretched.
    ;  (both datasets individually)
    ;
    d_globeRGBStretch, sState.reds[elev], sState.greens[elev], $
        sState.blues[elev], newReds1, newGreens1, newBlues1, $
        LOW=sliderValue0, HIGH=sliderValue1

    d_globeRGBStretch, sState.reds[temps], sState.greens[temps], $
        sState.blues[temps], newReds2, newGreens2, newBlues2, $
        LOW=sliderValue2-sState.ncolors/2, $
        HIGH=sliderValue3-sState.ncolors/2

    reds=[newReds1, newReds2]
    greens=[newGreens1, newGreens2]
    blues=[newBlues1, newBlues2]

    sState.oPalette->SetProperty, RED_VALUES=reds, $
        GREEN_VALUES=greens, BLUE_VALUES=blues

    sState.oWindow->Draw, sState.oView

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    WIDGET_CONTROL, HOURGLASS = 0

end

;----------------------------------------------------------------------
;
; PURPOSE  This is the main event handler routine
;          use in the Globe demo.
;
pro d_globeEvent, $
    sEvent

    ;  Quit this application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uvalue
    case uvalue of

        ;  Handle radio button events .
        ;  Here Handle event for showing over continents.
        ;
        'RADIO1': begin
            WIDGET_CONTROL, HOURGLASS=1
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            WIDGET_CONTROL, sState.wGroup2, GET_VALUE=twin
            if (sEvent.value EQ 0 AND twin EQ 0) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTemp
            if (sEvent.value EQ 1 AND twin EQ 0) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTopoTemp
            if (sEvent.value EQ 1 AND twin EQ 1) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTopo
            if (sEvent.value EQ 0 AND twin EQ 1) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTempTopo
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, HOURGLASS=0
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        end

        ;  Reset perspective.
        ;
        'RESET': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            sState.oModelRotate->SetProperty, $
                TRANSFORM=sState.resetTransform
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        end

        ;  Handle radio button events.
        ;  Here Handle event for showing over oceans.
        ;
        'RADIO2': begin
            WIDGET_CONTROL, HOURGLASS=1
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            WIDGET_CONTROL, sState.wGroup1, GET_VALUE=twin
            if (sEvent.value EQ 0 AND twin EQ 0) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTemp
            if (sEvent.value EQ 1 AND twin EQ 0) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTempTopo
            if (sEvent.value EQ 1 AND twin EQ 1) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTopo
            if (sEvent.value EQ 0 AND twin EQ 1) then $
                sState.oImage->SetProperty, DATA=*sState.pImageTopoTemp
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, HOURGLASS=0
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        end

        ;  Handle trackball events here.
        ;  still need to add trackball object
        ;  and place in object hierarchy.
        ;
        'DRAW': begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            bHaveTransform=sState.oTrack->Update(sEvent, TRANSFORM=qmat)
            if (bHaveTransform NE 0) then begin
              sState.oModelRotate->GetProperty, TRANSFORM=trans
              mtrans=trans # qmat
              sState.oModelRotate->SetProperty, TRANSFORM=mtrans
            endif

            ;  Handle button press.
            ;
            if (sEvent.type EQ 0) then $
                WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=1
            if (sEvent.type EQ 2) then begin
                if (bHaveTransform) then begin
                    sState.oWindow->SetProperty, QUALITY=0
                    sState.oWindow->Draw,sState.oView
                endif
            endif

            ;  Handle button release.
            ;
            if (sEvent.type EQ 1) then begin
                sState.oWindow->SetProperty, QUALITY=2
                WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
                sState.oWindow->Draw, sState.oView
            endif

            ;  Handle expose events.
            ;
            if (sEvent.type EQ 4) then begin
                sState.oWindow->Draw, sState.oView
            endif
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        end

        ;  Quit this application.
        ;
        'QUIT': begin
            WIDGET_CONTROL, sEvent.top, /DESTROY
        end

        ; Display the information file.
        ;
        'ABOUT' : begin
            ONLINE_HELP, 'd_globe', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
        end

        ;  Handle all other events.
        ;
    ELSE:    ;  Do nothing

    endcase

end

;----------------------------------------------------------------------
;
; PURPOSE  Cleanup everything associated with the
;          Globe demo, including all objects and pointers.
;          Restore the original color table.
;
pro d_globeCleanup, tlb

    WIDGET_CONTROL, tlb, GET_UVALUE=sState, /NO_COPY

    ;  Restore the previous color table.
    ;
    TVLCT, sState.colorTable

    ;  Destroy the top objects & attribute objects.
    ;
    OBJ_DESTROY, sState.oView
    OBJ_DESTROY, sState.oPalette
    OBJ_DESTROY, sState.oTrack
    OBJ_DESTROY, sState.oText
    OBJ_DESTROY, sState.oFont
    OBJ_DESTROY, sState.oContainer

    ;  Free all pointers.
    ;
    PTR_FREE, sState.pImageTempTopo
    PTR_FREE, sState.pImageTopoTemp
    PTR_FREE, sState.pImageTemp
    PTR_FREE, sState.pImageTopo

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sState.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sState.groupBase, /MAP

end

;----------------------------------------------------------------------
;
; PURPOSE  Inputs the images used in the Globe demo.
;          This procedure returns
;          four pointers back to the caller.
;          These pointers point to the given images.
;
pro d_globeReadImages, $
    fileNameElev, $     ;IN: filename for elevation dataset
    fileNameTemp, $     ;IN: filename for temperature dataset
    nColors, $          ;IN: number of colors used to scale both images
    pImageTemp, $       ;OUT: world temperatures
    pImageTopo, $       ;OUT: world topography
    pImageTempTopo, $   ;OUT: continental temperature and oceanic elevation
    pImageTopoTemp, $   ;OUT: ocean temperature and continental elevation
    reds, $             ;OUT: red color indices
    greens, $           ;OUT: green color indices
    blues               ;OUT: blue color indices

    ;  Innput DEM from IDL distribution ("worldelv.dat") and
    ;  corresponding temperature dataset from
    ;  a .SAV file ("worldtmp.sav").
    ;
    OPENR, lun, fileNameElev, /GET_LUN
    topo=BYTARR(360, 360)
    READU, lun, topo
    CLOSE, LUN
    FREE_LUN, lun
    temps=BYTARR(360, 360)

    ;  Read  the temperature image.
    ;
    Temps = Read_Png(fileNameTemp, Reds, Greens, Blues)

    ;  Build masks to divide the two datasets.
    ;
    oceanMask=WHERE(topo lt 124)
    landMask=WHERE(topo ge 124)

    ;  Create DEM( Digital elevation Model) images.
    ;  (Color Ranges: [0]-[nColors/2-1]).
    ;
    topoOceanScaled=BYTSCL(topo, TOP=nColors/2-1, $
        MIN=MIN(topo[oceanMask]), MAX=MAX(topo[oceanMask]))
    topoLandScaled=BYTSCL(topo, TOP=nColors/2-1, $
        MIN=MIN(topo[landMask]), MAX=MAX(topo[landMask]))
    topoScaled=BYTSCL(topo, TOP=nColors/2-1)

    ;  Create temperature images.
    ;  (Color Ranges: [nColors/2]-[nColors-1]).
    ;
    tempLandScaled=BYTSCL(temps, TOP=nColors/2-1, $
        MIN=MIN(temps[landMask]), $
        MAX=MAX(temps[landMask]))+BYTE(nColors/2)
    tempOceanScaled=BYTSCL(temps, TOP=nColors/2-1, $
        MIN=MIN(temps[oceanMask]), $
        MAX=MAX(temps[oceanMask]))+BYTE(nColors/2)
    tempScaled=BYTSCL(temps, TOP=nColors/2-1)+BYTE(nColors/2)

    ;  Create pointers to two images that are created based on the
    ;  respective topography and temperature scalings.
    ;
    pImageTemp=PTR_NEW(tempScaled)
    pImageTopo=PTR_NEW(topoScaled)
    imageTempTopo=BYTARR(360, 360)    ;temperatures over continents
    imageTempTopo[landMask]=tempLandScaled[landMask]
    imageTempTopo[oceanMask]=topoOceanScaled[oceanMask]
    pImageTempTopo=PTR_NEW(imageTempTopo)
    imageTopoTemp=BYTARR(360, 360)    ;temperatures over oceans
    imageTopoTemp[oceanMask]=tempOceanScaled[oceanMask]
    imageTopoTemp[landMask]=topoLandScaled[landMask]
    pImageTopoTemp=PTR_NEW(imageTopoTemp)

    ;  Scale color vectors based on number of colors.
    ;
    reds=CONGRID(reds, nColors)
    greens=CONGRID(greens, nColors)
    blues=CONGRID(blues, nColors)

end

;----------------------------------------------------------------------
;
; PURPOSE  Creates the object hierarchy
;
function d_globeMakeObjects, $
    reds, $             ;IN: red color lookups
    greens, $                           ;IN: green color lookups
    blues, $                            ;IN: blue color lookups
    drawSize, $                         ;IN: draw dimensions
    pImageTempTopo, $                   ;IN: pointer to image
    oWindow                             ;IN: window object

    myView = [-1.0, -1.0, 2.0, 2.0]
    ;  Create view object.
    ;
    oView = OBJ_NEW('IDLgrView', PROJECTION=2, EYE=4.0, $
        COLOR=[0,0,0], $
        VIEW=[-1.0, -1.0, 2.0, 2.0], ZCLIP=[1.0, -1.0])

    ;  Make the starting up text location centered.
    ;
    textLocation = [myview[0]+0.5*myview[2], myview[1]+0.5*myview[3]]

    ;  Create and display the PLEASE WAIT text.
    ;
    oFont = OBJ_NEW('IDLgrFont', 'Helvetica', SIZE=20)
    oText = OBJ_NEW('IDLgrText', $
        'Starting up  Please wait...', $
        ALIGN=0.5, $
        LOCATION=textLocation, $
        COLOR=[255,255,0], FONT=oFont)


    ;  Create model objects for translation, rotation, and scaling.
    ;
    oModelTranslate=OBJ_NEW('IDLgrModel')
    oModelRotate=OBJ_NEW('IDLgrModel')
    oModelScale=OBJ_NEW('IDLgrModel')
    oModelTranslate->Add, oModelRotate
    oModelRotate->Add, oModelScale

    ;  Show the starting up text.
    ;
    oview->Add, oModelTranslate
    oModelTranslate->Add, oText
    owindow->Draw, oView

    ;  Create color palette object.
    ;
    oPalette=obj_new('IDLgrPalette', reds, greens, blues)

    ;  Create trackball object.
    ;
    oTrack=OBJ_NEW('trackball', $
        [(drawSize[0])/2.0, (drawSize[0])/2.0], $
        (drawSize[0]))

    ;  Create image object and add to model hierarchy.
    ;
    oImage=OBJ_NEW('IDLgrImage', *pImageTempTopo, HIDE=1, $
        PALETTE=oPalette)
    oModelRotate->Add, oImage

    ;  Create orb object and add to model hierarchy.
    ;
    oSphere=OBJ_NEW('orb', DENSITY=0.99, /TEX_COORDS, $
        TEXTURE_MAP=oImage, COLOR=[255, 255, 255], RADIUS=0.90)
    oModelRotate->Add, oSphere

    ;  Add model hierarchy to view, rotate or whatever,
    ;  draw view to window.
    ;
    oModelRotate->Rotate, [1, 0, 0], -90

    oModelRotate->GetProperty, TRANSFORM=resetTransform

    oContainer = OBJ_NEW('IDLgrContainer')
    oContainer->Add, oView
    oContainer->Add, oTrack

    RETURN, {oView:oView, $
        oModelTranslate: oModelTranslate, $
        oModelRotate: oModelRotate, $
        oModelScale: oModelScale, $
        oPalette: oPalette, $
        oImage: oImage, $
        oSphere: oSphere, $
        oTrack: oTrack, $
        oWindow: oWindow, $
        oContainer: oContainer, $
        OText: oText, $
        OFont: oFont, $
        resetTransform:resetTransform}

end

;----------------------------------------------------------------------
;
; PURPOSE  This is the main widget definition
;          routine used in the Globe demo.
;          It constructs a widget and object
;          hierarchy which can be used to
;          manipulate some images.
;
pro d_globe, $
    GROUP=group, $      ;IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB=apptlb       ;OUT: (opt) TLB of this application

    ;  Check the validity of the group identifier.
    ;
    ngroup=N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check=WIDGET_INFO(group, /VALID_ID)
        if (check NE 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Return to the main application'
            RETURN
        endif
        groupBase = group
    endif else groupBase = 0L

    ;  Get the current color table.
    ;  It will be restored when exiting.
    ;
    TVLCT, savedR, savedG, savedB, /GET
    colorTable=[[savedR],[savedG],[savedB]]

    ;  Get the screen size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize
    xdim = ScreenSize[0]*.48
    ydim=xdim  ;keep isotropic

    ;  Declare filenames used with the globe demo.
    ;
    fileNameElev=DEMO_FILEPATH('worldelv.dat', $
        SUBDIR=['examples','data'])
    fileNameTemp=DEMO_FILEPATH('worldtmp.png', $
        SUBDIR=['examples','demo','demodata'])
    fileNameTips=DEMO_FILEPATH('globe.tip', $
        SUBDIR=['examples','demo','demotext'])
    fileNameAbout=DEMO_FILEPATH('globe.txt', $
        SUBDIR=['examples','demo','demotext'])

    ;  Read image datasets.  d_globeReadImages returns two pointers to the
    ;  respective images.  Each image contains two datasets, whereby
    ;  each dataset is scaled using half of the colors specified
    ;  in calling d_globeReadImages.
    ;
    nColors=190
    d_globeReadImages, fileNameElev, fileNameTemp, nColors, $
        pImageTemp, pImageTopo, pImageTempTopo, pImageTopoTemp, $
        reds, greens, blues

    ;  Construct all base widgets.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase=WIDGET_BASE(TITLE='Globe Demo', $
            XPAD=0, YPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            /COLUMN, TLB_FRAME_ATTR=1, MBAR=barBase)
    endif else begin
        wTopBase=WIDGET_BASE(TITLE='Globe Demo', $
            XPAD=0, YPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            GROUP_LEADER=group, $
            /COLUMN, TLB_FRAME_ATTR=1, MBAR=barBase)
    endelse

        ;  Create the buttons in the menu bar.
        ;
        wFileButton=WIDGET_BUTTON(barBase, VALUE='File')

            wQuitButton=WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                UVALUE='QUIT')

        wOptionButton=WIDGET_BUTTON(barBase, VALUE='Options')

            wResetButton=WIDGET_BUTTON(wOptionButton, $
                VALUE='Reset Orientation', UVALUE='RESET')

        wHelpButton=WIDGET_BUTTON(barBase, VALUE='About', /HELP)

            wAboutButton=WIDGET_BUTTON(wHelpButton, UVALUE='ABOUT', $
                VALUE='About the Globe Demo')

        ;  Create the widgets other than the menu bar.
        ;
        wSubBase=WIDGET_BASE(wTopBase, COLUMN=2)

            wLeftBase=WIDGET_BASE(wSubBase, /ALIGN_CENTER, /COLUMN)

                wLeftBaseSub1=WIDGET_BASE(wLeftBase, $
                    /ALIGN_CENTER, /COLUMN, /FRAME)

                    wSelect1=WIDGET_LABEL(wLeftBaseSub1, $
                        VALUE='Display Over Continents:')

                    radioOptions=['Temperature', 'Topography']

                    wGroup1=CW_BGROUP(wLeftBaseSub1, $
                        radioOptions, SET_VALUE=1, $
                        /ROW, /RETURN_INDEX, /EXCLUSIVE, $
                        /NO_RELEASE, UVALUE='RADIO1')

                wLeftBaseSub2=WIDGET_BASE(wLeftBase, $
                    /ALIGN_CENTER, /COLUMN, /FRAME)

                    wSelect2=WIDGET_LABEL(wLeftBaseSub2, $
                        VALUE='Display Over Oceans:')

                    wGroup2=CW_BGROUP(wLeftBaseSub2, $
                        radioOptions, SET_VALUE=0, $
                        /ROW, /RETURN_INDEX, /EXCLUSIVE, $
                        /NO_RELEASE, UVALUE='RADIO2')

                wLeftBaseSub3=WIDGET_BASE(wLeftBase, $
                    /ALIGN_CENTER, /COLUMN, /FRAME)

                    wslider3=WIDGET_SLIDER(wLeftBaseSub3, $
                        /SUPPRESS, MINIMUM=nColors/2, $
                        MAXIMUM=nColors-1, $
                        VALUE=nColors/2, $
                        EVENT_PRO='d_globeStretchEvent', $
                        TITLE='Stretch temperature minimum')

                    wslider4=WIDGET_SLIDER(wLeftBaseSub3, $
                        /SUPPRESS, MINIMUM=nColors/2, $
                        MAXIMUM=nColors-1, $
                        VALUE=nColors-1, $
                        EVENT_PRO='d_globeStretchEvent', $
                        TITLE='Stretch temperature maximum')

                wLeftBaseSub4=WIDGET_BASE(wLeftBase, $
                    /ALIGN_CENTER, /COLUMN, /FRAME)

                    wslider1=WIDGET_SLIDER(wLeftBaseSub4, $
                        /SUPPRESS, MINIMUM=0, $
                        MAXIMUM=nColors/2-1, VALUE=0, $
                        EVENT_PRO='d_globeStretchEvent', $
                        TITLE='Stretch topography minimum ')

                    wslider2=WIDGET_SLIDER(wLeftBaseSub4, $
                        /SUPPRESS, MINIMUM=0, $
                        MAXIMUM=nColors/2-1, VALUE=nColors/2-1, $
                        EVENT_PRO='d_globeStretchEvent', $
                        TITLE='Stretch topography maximum ')

            wRightBase=WIDGET_BASE(wSubBase, /ALIGN_CENTER, /COLUMN)

                wDraw=WIDGET_DRAW(wRightBase, XSIZE=xdim, $
                    YSIZE=ydim, $  ;keep isotropic
                    UVALUE='DRAW', /BUTTON_EVENTS, $
                    GRAPHICS_LEVEL=2, RETAIN=0, /EXPOSE_EVENTS)

        wStatusBase=WIDGET_BASE(wTopBase, /ROW, MAP=0)

    ;  Realize  the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE
    WIDGET_CONTROL, HOURGLASS=1
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    ;  Set the user values of each slider to the ids of all sliders because
    ;  these will be needed in the event handler to avoid cases whereby
    ;  minimum sliders are set to values larger than maximum sliders and
    ;  vice versa.
    ;
    wsliders=[wslider1, wslider2, wslider3, wslider4]

    ;  Set the initial value of the sliders.
    ;
    WIDGET_CONTROL, wslider1, SET_UVALUE=wsliders
    WIDGET_CONTROL, wslider2, SET_UVALUE=wsliders
    WIDGET_CONTROL, wslider3, SET_UVALUE=wsliders
    WIDGET_CONTROL, wslider4, SET_UVALUE=wsliders

    ;  Get the tips
    ;
    sText = demo_getTips(fileNameTips, $
                         wTopBase, $
                         wStatusBase)

    ;  Create the objects.
    ;  Make the continent-topo  & ocean-temperature
    ;  the default view.
    ;
    sObject=d_globeMakeObjects(reds, greens, blues, [xdim, ydim], $
        pImageTopoTemp, oWindow)

    ;  Build sState structure used in event handlers.
    ;
    sState={$
        wGroup1:wGroup1, $                          ; Widget Id radio buttons
        wGroup2:wGroup2, $                          ; Widget Id radio buttons
        wDraw:wDraw, $                              ; Widget draw ID
        oImage:sObject.oImage, $                    ; Image object
        oSphere:sObject.oSphere, $                  ; Sphere object
        oTrack:sObject.oTrack, $                    ; Trackball object
        oModelTranslate:sObject.oModelTranslate, $  ; Models
        oModelRotate:sObject.oModelRotate, $
        oModelScale:sObject.oModelScale, $
        OContainer: sObject.oContainer, $           ; Container object
        oWindow:sObject.oWindow, $                  ; Widnow object
        oView:sObject.oView, $                      ; View object
        oFont:sObject.oFont, $                      ; Font object
        oText:sObject.oText, $                      ; Text object
        oPalette:sObject.oPalette, $                ; Color palette object
        resetTransform:sObject.resetTransform, $    ; Transformation matrix to reset
        pImageTemp:pImageTemp, $                    ; Pointers to images
        pImageTopo:pImageTopo, $
        pImageTempTopo:pImageTempTopo, $
        pImageTopoTemp:pImageTopoTemp, $
        nColors:nColors, $                          ; Number of available colors
        reds:reds, $                                ; RGB color arrays
        greens:greens, $
        blues:blues, $
        colorTable:colorTable, $                    ; Color table to restore
        fileNameAbout:fileNameAbout,  $
        groupBase: groupBase $                      ; Base of Group Leader
    }

    WIDGET_CONTROL, wTopBase, SET_UVALUE=sState, /NO_COPY

    WIDGET_CONTROL, HOURGLASS=0

    ;  Remove the starting up text.
    ;
    sObject.oModelTranslate->Remove, sObject.oText

    ;  Returns the top level base to the APPTLB keyword.
    ;
    appTLB=wTopBase

    ;  Modify the initial setting of the sliders. First create
    ;  a pseudo event structure, then call the d_globeStretchEvent
    ;  routine with the pseudo structure, then set the slider
    ;  to the desired value
    ;
    ;  Stretching the temperature minimum slider at 30% of
    ;  its range and rotate the globe.
    ;
    sObject.oModelRotate->Rotate, [0, 1, 0], -20.0
    sObject.oModelRotate->Rotate, [1, 0, 0], 10.0
    deltaTempMin = (nColors-1 - nColors/2 ) * 0.3
    increment = (deltaTempMin) / 2
    for i = 0, deltaTempMin, increment do begin
        sObject.oModelRotate->Rotate, [0, 1, 0], -5
        sObject.oModelRotate->Rotate, [1, 0, 0], 2.5
         newValue = nColors/2 + i
         pseudoEvent = { $
             ID : wslider3, $
             TOP: wTopBase, $
             HANDLER: wslider3, $
             VALUE: newValue, $
             DRAG: 0 $
         }
         WIDGET_CONTROL, wslider3, SET_VALUE=newValue
         d_globeStretchEvent, pseudoEvent
    endfor

    ;  Stretching the temperature maximum slider at 85% of
    ;  its range and rotate the globe.
    ;
    deltaTempMax = (nColors-1 - nColors/2)*0.15

    increment = (deltaTempMax) / 3
    for i = 0, deltaTempMax, increment do begin
        sObject.oModelRotate->Rotate, [0, 1, 0], -5
        sObject.oModelRotate->Rotate, [1, 0, 0], 2.5
        newValue = (nColors-1) - i
        pseudoEvent = { $
            ID : wslider4, $
            TOP: wTopBase, $
            HANDLER: wslider4, $
            VALUE: newValue, $
            DRAG: 0 $
        }
        WIDGET_CONTROL, wslider4, SET_VALUE=newValue
        d_globeStretchEvent, pseudoEvent
    endfor

    ;  Stretching the topography maximum slider at 35% of
    ;  its range.
    ;
    deltaTempMax = nColors/2 - 1
    newValue = (nColors/2 - 1) * 0.35
    pseudoEvent = { $
        ID : wslider2, $
        TOP: wTopBase, $
        HANDLER: wslider2, $
        VALUE: newValue, $
        DRAG: 0 $
    }
    WIDGET_CONTROL, wslider2, SET_VALUE=newValue
    d_globeStretchEvent, pseudoEvent

    ;  Register with the XMANAGER
    ;
    XMANAGER, 'd_Globe', wTopBase, /NO_BLOCK, $
        EVENT_HANDLER='d_globeEvent', CLEANUP="d_globeCleanup"

end

