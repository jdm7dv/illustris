;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/animation_doc.pro#2 $

; Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   animation_doc
;
; PURPOSE:
;   Creates a widget application that includes interactive animation
;   capabilities that let you control the playback of a series of images.
;
; CATEGORY:
;   Objects
;
;-
;;---------------------------------------------------------------------------------------
; Create custom timer behavior object.

; Initialize class.
FUNCTION timer_observer::init
    self.inc = 1
    RETURN, 1
END

; Obligatory cleanup.
PRO timer_observer::cleanup
END

; OnTimer handles notifications that a timer even has occurred
; in the window. Updates currentImage with the increment amount.
; The nImages variable is based on the number of image frames.
; The ACTIVE_POSITION defines the zero-based index number of the
; model container item to be drawn
PRO timer_observer::OnTimer, oWin
    nImages = self.oImages->Count()
    self.currentImage += self.inc
    IF self.currentImage GE nImages THEN self.currentImage = 0
    IF self.currentImage LT 0 THEN self.currentImage = nImages-1
    self.oImages->SetProperty, ACTIVE_POSITION=self.currentImage

    ; Draw the model containing proper frame in the window.
    oWin->Draw
END

; Object SetProperty method. OIMAGES is the animation model contents
PRO timer_observer::SetProperty, $
    CURRENT_IMAGE = currentImage, $
    INCREMENT = inc, $
    OIMAGES = oImages

    IF N_ELEMENTS(currentImage) GT 0 THEN $
        self.currentImage = currentImage

    IF N_ELEMENTS(inc) GT 0 THEN $
        self.inc = inc

    IF N_ELEMENTS(oImages) GT 0 THEN $
        self.oImages = oImages
END

; Object GetProperty method.
PRO timer_observer::GetProperty, $
    CURRENT_IMAGE = currentImage, $
    INCREMENT = inc, $
    OIMAGES = oImages

    IF ARG_PRESENT(currentImage) THEN $
        currentImage = self.currentImage

    IF ARG_PRESENT(inc) THEN $
        inc = self.inc

END

; Define timer_observer instance data.
PRO timer_observer__define
    struct = { timer_observer, $
        currentImage: 0L, $
        inc: 0L, $
        oImages: OBJ_NEW(), $
        wFrameIndicator: 0L, $
        timerImages: 0L $
    }
end

;---------------------------------------------------------------------------------------
; Cleanup when the application is closed.

PRO kill, wBase
    WIDGET_CONTROL, wBase, GET_UVALUE=pState
    WIDGET_CONTROL, (*pState).wBase, TIMER=0
    OBJ_DESTROY, (*pState).oAnimationModel
    OBJ_DESTROY, (*pState).oPalette
    OBJ_DESTROY, (*pState).oObserver
    PTR_FREE, pState
END

;---------------------------------------------------------------------------------------
; Handle window events.

PRO animation_doc_event, sEvent

    COMPILE_OPT idl2, hidden


    IF (TAG_NAMES(sEvent, /STRUC) eq 'WIDGET_TIMER') THEN BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
        WIDGET_CONTROL, (*pState).wBase, TIMER=1
        return
    ENDIF

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
    CASE uval OF

    ; Turn timer events on and off (TIMER_EVENTS), or
    ; increment the frame display. Call SetEventMask to notify window
    ; observers of timer events, or call the custom behavior object's OnTimer
    ; method to determine what frame to display and draw it to the window.
    'ANIMATE_STOP': BEGIN
        (*pState).oWindow->SetEventMask, TIMER_EVENTS=0
        (*pState).oWindow->Draw, (*pState).oView
        WIDGET_CONTROL, (*pState).wAnimateStepF, SENSITIVE=1
        WIDGET_CONTROL, (*pState).wAnimateStepB, SENSITIVE=1
        END
    'ANIMATE_PLAY': BEGIN
        (*pState).oWindow->SetEventMask, TIMER_EVENTS=1
        WIDGET_CONTROL, (*pState).wAnimateStepF, SENSITIVE=0
        WIDGET_CONTROL, (*pState).wAnimateStepB, SENSITIVE=0
        END
    'ANIMATE_STEPF': BEGIN
        (*pState).oObserver->OnTimer, (*pState).oWindow
        END
    'ANIMATE_STEPB': BEGIN
        (*pState).oObserver->GetProperty, INC=advance
        (*pState).oObserver->SetProperty, INC= -advance
        (*pState).oObserver->OnTimer, (*pState).oWindow
        (*pState).oObserver->SetProperty, INC=advance
        END
    'ANIMATE_RATE': BEGIN
        interval = 1.0 / sEvent.value
        (*pState).oWindow->SetTimerInterval, interval
        END
    'ANIMATE_ADVANCE': BEGIN
        advance = sEvent.value
        (*pState).oObserver->SetProperty, INC=advance
        END

    ENDCASE
END


;-----------------------------------------------------------------------------------
PRO animation_doc

    renderer = 0
    windowDims = [500L,500]

    ; Set up base and draw widgets.
    wBase = WIDGET_BASE(TITLE='Object Graphics Animation Demo', $
        KILL_NOTIFY='kill', $
        /COLUMN, /TLB_SIZE_EVENT)
    wDraw = WIDGET_DRAW( $
        wBase, $
        XSIZE=windowDims[0], $
        YSIZE=windowDims[1], $
        CLASSNAME='IDLitWindow', $
        GRAPHICS_LEVEL=2, $
        RENDERER=renderer, $
        UVALUE='DRAW' $
        )

    ; Set up widgets for animation controls.
    wPanelRow1 = WIDGET_BASE(wBase, /ROW)

    ; Configure slider widgets for rate and increment.
	wRateBox = WIDGET_BASE(wPanelRow1, /ROW)
    wLabel = WIDGET_LABEL(wRateBox, VALUE="Rate (fps): ")
    wAnimateRate = WIDGET_SLIDER(wRateBox, MINIMUM=1, MAXIMUM=200, $
                                 UVALUE="ANIMATE_RATE")
    wLabel = WIDGET_LABEL(wRateBox, VALUE="    Frame Advance: ")
    wAnimateAdvance = WIDGET_SLIDER(wRateBox, MINIMUM=-5, MAXIMUM=5, VALUE=1, $
                                 UVALUE="ANIMATE_ADVANCE")
    wSpacer = WIDGET_BASE(wPanelRow1, XSIZE=30)

    ; Configure playback control buttons.
    wButtonBox = WIDGET_BASE(wPanelRow1, /ROW)
    wAnimateStepB = WIDGET_BUTTON(wButtonBox, VALUE=FILEPATH("stepback.bmp", $
       SUBDIR=['resource', 'bitmaps']), /BITMAP, $
       TOOLTIP="Step back", UVALUE="ANIMATE_STEPB")
    wAnimateStop = WIDGET_BUTTON(wButtonBox, VALUE=FILEPATH("stop.bmp", $
       SUBDIR=['resource', 'bitmaps']), /BITMAP, $
       TOOLTIP="Stop", UVALUE="ANIMATE_STOP")
    wAnimatePlay = WIDGET_BUTTON(wButtonBox, VALUE=FILEPATH("shift_right.bmp", $
       SUBDIR=['resource', 'bitmaps']), /BITMAP, $
       TOOLTIP="Play", UVALUE="ANIMATE_PLAY")
    wAnimateStepF = WIDGET_BUTTON(wButtonBox, VALUE=FILEPATH("step.bmp", $
       SUBDIR=['resource', 'bitmaps']), /BITMAP, $
       TOOLTIP="Step forward", UVALUE="ANIMATE_STEPF")

    ; Realize widgets and access window object from draw widget.
    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow


    ; Create the graphics hierarchy. Draw the view object when you call Draw on
    ; the window. Also create the custom timer_observer behavior object.
    oView = OBJ_NEW('IDLgrView', $
                    VIEWPLANE_RECT=[0,0,80, 100], $
                    COLOR=[180,180,180], ZCLIP=[100,-100], EYE=101)
    oModel = OBJ_NEW('IDLgrModel')
    oView->Add, oModel
    oWindow->SetProperty, GRAPHICS_TREE=oView
    oObserver = OBJ_NEW('timer_observer')

    ; Read image data, which contains 57 frames.
    nFrames = 57
    head = READ_BINARY( FILEPATH('head.dat', $
        SUBDIRECTORY=['examples','data']), $
        DATA_DIMS=[80,100, 57])

    ; Create animation and frames. Add observer object to window's
    ; list of observers. The oImages object array contains 57 image objects,
    ; one for each frame of data.
    oAnimationModel = OBJ_NEW('IDLgrModel', RENDER_METHOD=1)
    oObserver->SetProperty, oIMAGES=oAnimationModel
    oWindow->AddWindowEventObserver, oObserver
    oImageColl = OBJARR(nFrames)
    oPalette = OBJ_NEW('IDLgrPalette')
    oPalette->LoadCT, 4

    ; Create the image objects, add each to the animation model.
    FOR i=0, nFrames-1 do begin
        oImageColl[i] = OBJ_NEW('IDLgrImage', head[*,*,i], PALETTE=oPalette, /INTERP)
        oAnimationModel->Add, oImageColl[i]
    ENDFOR

    ; Put first frame in main view.
    currentFrame = 0
    oModel->Add, oAnimationModel

    ; Set up initial rate and increment values.
    oWindow->SetTimerInterval, 0.1
    WIDGET_CONTROL, wAnimateRate, SET_VALUE=10
    WIDGET_CONTROL, wAnimateAdvance, SET_VALUE=1
    oObserver->SetProperty, INC=1

    ; Generate a widget timer event.
    WIDGET_CONTROL, wBase, TIMER=1

    ; Set state data.
    sState = {wBase: wBase, $
              wDraw: wDraw, $
              wAnimateStop: wAnimateStop, $
              wAnimatePlay: wAnimatePlay, $
              wAnimateStepF: wAnimateStepF, $
              wAnimateStepB: wAnimateStepB, $
              wAnimateRate: wAnimateRate, $
              wAnimateAdvance: wAnimateAdvance, $
              oWindow: oWindow, $
              oView: oView, $
              oModel: oModel, $
              oPalette: oPalette, $
              oAnimationModel: oAnimationModel, $
              oObserver: oObserver, $
              nFrames : nFrames, $
              currentFrame: currentFrame, $
              windowDims: windowDims, $
              dummy: 0}

    pState = PTR_NEW(sState, /NO_COPY)
    WIDGET_CONTROL, wBase, SET_UVALUE=pState

	; Display animation interface.
    XMANAGER, $
        'animation_doc', CLEANUP=kill, $
        wBase, /NO_BLOCK
END
