; $Id: //depot/idl/IDL_70/idldir/examples/mjpeg2000/mj2_player.pro#2 $

; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       mj2_player
;
; PURPOSE:
;       Play Motion JPEG2000 movies/animations
;
;       Demonstrates the how to use the IDLffMJPEG2000 file access object.
;       To view how the IDLffMJPEG2000 object is used by this example
;       mj2 writer search for oMJPEG-> in this file.
;
;       The ui consists of two tabs.  The first tab contains the control to
;       start and stop the movie playback and a window to display the movie
;       frames.  The second tab contains the movie properties such as number
;       of frames, frame width, frame height, etc...
;
;       When the file btn is pressed and a mj2 file is selected an
;       IDLffMJPEG2000 object is created, if one already was in existence
;       it is shutdown and destroyed and new one is created.
;
;       When the play button is pressed a timer is started and a new frame
;       is displayed in the window each time the timer event fires.
;
;       To create the ui this example uses
;           - widget_button
;           - widget_text
;           - widget_label
;           - widget_slider
;           - widget_draw
;           - idlitwindow
;           - idlgrview
;           - idlgrimage
;           - idlgrmodel
;
;       An iTool (idlitwindow) window is used in a draw widget so that the more accurated
;       iTools window timer can be used.  The rotatorobj is an observer of the idlitwindow
;       events and hence receives the timer event.
;
;
; CATEGORY:
;       file access and object graphics.
;
; CALLING SEQUENCE:
;       mj2_player
;
; INPUTS:
;       none
;
; KEYWORDS:
;       none
;
; MODIFICATION HISTORY:
;       Written by: LFG, August 2005
;-


;*****************************************************************************
pro mj2_player_timer__define

    struct = { mj2_player_timer, tlb:0L }
end

;*****************************************************************************
function mj2_player_timer::init

    return, 1
end

;*****************************************************************************
pro mj2_player_timer::cleanup

end

;*****************************************************************************
pro mj2_player_timer::SetProperty, tlb = tlb

    if N_ELEMENTS(tlb) gt 0 then $
        self.tlb = tlb
end

;*****************************************************************************
pro mj2_player_timer::GetProperty, tlb = tlb

    if ARG_PRESENT(currentImage) then $
        tlb = self.tlb
end

;*****************************************************************************
pro mj2_player_timer::OnTimer, oWin
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error::OnTimer', dialog_parent=self.tlb, /error)
        ; there was an error during playback so turn everything off
        (*pState).oitWindow->SetEventMask, TIMER_EVENTS=0
        (*pstate).seqMode = 'stopped'
        widget_control, (*pstate).wbtnPlay,   set_value='Play'
        if (obj_valid((*pstate).oMJPEG)) then begin
            vRes = (*pstate).oMJPEG->StopSequentialReading()
        endif
        return
    endif

    ; this is the timer routine that fires at the selected frame rate
    ; each time the timer fires we ask for the next frame

    widget_control, self.tlb, get_uvalue = pstate

    ; get the next available frame from the motion jpeg2000 object
    frIdx = (*pstate).oMJPEG->GetSequentialData(imgBuf, frame_num=frNum)

    ; if there was a frame available display it
    if (frIdx ne -1) then begin
        (*pstate).framesPlayed++

         ; put up the new image
        (*pstate).oImage->setproperty, data=imgBuf
        (*pstate).oitWindow->draw, (*pstate).oView

        ; release the frame buffer slot so it can be reused
        (*pstate).oMJPEG->ReleaseSequentialData, frIdx

        ; display the current frame number
        widget_control, (*pstate).wtxtFrNum, set_value = strtrim(string(frNum),2)

        ; if this is the last frame to play then turn off the timer
        ; note we do not call StopSequentialReading() until the user presses stop or file
        ; so that we leave everything setup so if play is pressed again we are ready to go
        if (frNum eq (*pstate).stopFr-1) then begin

            ; actual frame rate
            elapsed = (systime(1) - (*pstate).startTime)
            frPerSec = (*pstate).framesPlayed/elapsed
            widget_control, (*pstate).wtxtFrPerSec, set_value = string(frPerSec, FORMAT='(%"%0.2f")')
            (*pstate).framesPlayed = 0
            (*pstate).startTime = systime(1)

            ; timer off
            (*pState).oitWindow->SetEventMask, TIMER_EVENTS=0

            ; btn text updates
            (*pstate).seqMode = 'played'
            widget_control, (*pstate).wbtnPlay,   set_value='Play'
            widget_control, (*pstate).wbtnStop,   set_value='Reset'

        endif
    endif
end


;*****************************************************************************

pro mj2_player_start_mj2, ev
    compile_opt idl2

    ; do not put a catch here

    widget_control, ev.top, get_uvalue = pstate

    ; number of slots in the frame buffer
    ; the frame buffer holds decompressed images
    widget_control, (*pstate).wtxtfrbuflen, get_value = wstrings
    val = wstrings[0]
    iVal = fix(val) > 1
    (*pstate).oMJPEG->setproperty, frame_buffer_length=iVal

    ; the first frame to be displayed
    widget_control, (*pstate).wtxtStartFr, get_value = startFr
    (*pstate).startFr = startFr[0]

    ; the last frame to be displayed
    widget_control, (*pstate).wtxtStopFr, get_value = stopFr
    (*pstate).stopFr = stopFr[0]

    ; the rate the timer will fire
    ; a new frame is displayed each time the timer fires
    widget_control, (*pstate).wtxtSliderRate, get_value = wstrings
    val = wstrings[0]
    fVal = float(val)
    (*pstate).frameRate = 1/fVal

    ; treat the mj2 as an rgb if it has 3 components
    (*pstate).oMJPEG->getproperty, n_comp=nComps
    if (nComps eq 3) then begin
        rgb = 1
    endif

    ; if the keyword is not set above then it is undefined
    ; if the keyword is undefined then the keyword processing code ignores it hence the interface code uses it's default
    vRes = (*pstate).oMJPEG->StartSequentialReading(rgb=rgb, start_frame=(*pstate).startFr[0], stop_frame=(*pstate).stopFr[0])
end


;*****************************************************************************

pro mj2_player_btnSeqPlay_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error', dialog_parent=ev.top, /error)
        (*pState).oitWindow->SetEventMask, TIMER_EVENTS=0
        (*pstate).seqMode = 'stopped'
        widget_control, (*pstate).wbtnPlay,   set_value='Play'
        if (obj_valid((*pstate).oMJPEG)) then begin
            vRes = (*pstate).oMJPEG->StopSequentialReading()
        endif
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; mode when the Play btn was pressed
    mode = (*pstate).seqMode
    widget_control, (*pstate).wbtnStop,   set_value='Stop'

    ; if stopped then play
    if (mode eq 'stopped') then begin

        mj2_player_start_mj2, ev

        widget_control, (*pstate).wbtnStop,   sensitive=1
        widget_control, (*pstate).wbtnSeqFwd, sensitive=0
        widget_control, (*pstate).wbtnSeqRev, sensitive=0

        (*pstate).startTime = systime(1)
        (*pstate).framesPlayed = 0

        ; start the timer at the desired frame rate
        (*pState).oitWindow->SetEventMask, TIMER_EVENTS=1
        (*pState).oitWindow->SetTimerInterval, (*pstate).frameRate

        (*pstate).seqMode = 'playing'
        widget_control, (*pstate).wbtnPlay,   set_value='Pause'
    end

    ; if playing then pause
    if (mode eq 'playing') then begin

        widget_control, (*pstate).wbtnStop,   sensitive=1
        widget_control, (*pstate).wbtnSeqFwd, sensitive=1
        widget_control, (*pstate).wbtnSeqRev, sensitive=1

        ; stop the timer
        (*pState).oitWindow->SetEventMask, TIMER_EVENTS=0

        (*pstate).seqMode = 'paused'
        widget_control, (*pstate).wbtnPlay,   set_value='Resume'
    end

    ; if paused then resume
    if (mode eq 'paused') then begin

        (*pstate).oMJPEG->getProperty, current_frame=currFrNum
        if (currFrNum ge (*pstate).stopfr-1) then begin
            r = dialog_message('Can not resume because current frame is the last frame', title='m2j warning', dialog_parent=ev.top)
            return
        endif

        widget_control, (*pstate).wbtnStop,   sensitive=1
        widget_control, (*pstate).wbtnSeqFwd, sensitive=0
        widget_control, (*pstate).wbtnSeqRev, sensitive=0

        ; start the timer up again to resume from being paused
        (*pState).oitWindow->SetEventMask, TIMER_EVENTS=1
        (*pState).oitWindow->SetTimerInterval, (*pstate).frameRate

        (*pstate).seqMode = 'playing'
        widget_control, (*pstate).wbtnPlay,   set_value='Pause'
    end

    ; if played then play
    if (mode eq 'played') then begin

        widget_control, (*pstate).wbtnStop,   sensitive=1
        widget_control, (*pstate).wbtnSeqFwd, sensitive=0
        widget_control, (*pstate).wbtnSeqRev, sensitive=0

        ; apply the desired frame rate setting
        widget_control, (*pstate).wtxtSliderRate, get_value = wstrings
        val = wstrings[0]
        fVal = float(val)
        (*pstate).frameRate = 1/fVal

        (*pstate).startTime = systime(1)
        (*pstate).framesPlayed = 0

        ; we are playing the same mj2 over so restart the timer
        (*pState).oitWindow->SetEventMask, TIMER_EVENTS=1
        (*pState).oitWindow->SetTimerInterval, (*pstate).frameRate

        (*pstate).seqMode = 'playing'
        widget_control, (*pstate).wbtnPlay,   set_value='Pause'
    end
end


;*****************************************************************************
pro mj2_player_display_start_fr, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error::display_start_fr', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

   (*pstate).oMJPEG->getproperty, n_comp=nComps
   if (nComps eq 3) then begin
       rgb = 1
   endif

   ; use the random access method to get the start frame and display it
   imgBuf = (*pstate).oMJPEG->GetData((*pstate).startFr, rgb=rgb)
   (*pstate).oImage->setproperty, data=imgBuf
   (*pstate).oitWindow->draw, (*pstate).oView
   widget_control, (*pstate).wtxtFrNum, set_value = strtrim(string((*pstate).startFr),2)
end

;*****************************************************************************

pro mj2_player_btnSeqStop_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error::btnSeqStop_event', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; actual frame rate value
    elapsed = (systime(1) - (*pstate).startTime)
    frPerSec = (*pstate).framesPlayed/elapsed
    widget_control, (*pstate).wtxtFrPerSec, set_value = string(frPerSec, FORMAT='(%"%0.2f")')

    widget_control, (*pstate).wbtnStop,   sensitive=0
    widget_control, (*pstate).wbtnSeqFwd, sensitive=0
    widget_control, (*pstate).wbtnSeqRev, sensitive=0

    ; stop the timer
    (*pState).oitWindow->SetEventMask, TIMER_EVENTS=0

    if (obj_valid((*pstate).oMJPEG)) then begin
        ; release the frame buffer and shutdown the thread
        vRes = (*pstate).oMJPEG->StopSequentialReading()

        mj2_player_display_start_fr, ev
    end

    (*pstate).seqMode = 'stopped'
    widget_control, (*pstate).wbtnPlay,   set_value='Play'
end

;*****************************************************************************

pro mj2_player_btnSeqStepRev_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; ask for the previous frame
    frIdx = (*pstate).oMJPEG->GetSequentialData(imgBuf, frame_num=frNum, step=-1)

    ; did we get the previous frame
    if (frIdx ne -1) then begin
        ; display the previous frame
        (*pstate).oImage->setproperty, data=imgBuf
        (*pstate).oitWindow->draw, (*pstate).oView
        (*pstate).oMJPEG->ReleaseSequentialData, frIdx
        widget_control, (*pstate).wtxtFrNum, set_value = strtrim(string(frNum),2)
    endif
end


;*****************************************************************************

pro mj2_player_btnSeqStepFwd_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; ask for the next frame
    frIdx = (*pstate).oMJPEG->GetSequentialData(imgBuf, frame_num=frNum, step=1)

    ; if we got the next frame then display it
    if (frIdx ne -1) then begin
        (*pstate).oImage->setproperty, data=imgBuf
        (*pstate).oitWindow->draw, (*pstate).oView
        (*pstate).oMJPEG->ReleaseSequentialData, frIdx
        widget_control, (*pstate).wtxtFrNum, set_value = strtrim(string(frNum),2)
    endif
end


;*****************************************************************************

pro mj2_player_btnFile_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='MJ2 Player Error::btnFile_event', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; we are picking a new file so force a stop if we are playing and delete the IDLffMJPEG2000 object
    mj2_player_btnSeqStop_event, ev
    if (obj_valid((*pstate).oMJPEG)) then begin
        obj_destroy, (*pstate).oMJPEG
    endif

    ; do we have a path preference
    if ((*pstate).mj2PlayerFilePath eq '') then begin
        (*pstate).mj2PlayerFilePath = filepath('mj2_player.pro', sub= ['examples','mjpeg2000'])
        (*pstate).mj2PlayerFilePath = file_dirname((*pstate).mj2PlayerFilePath)
    endif

    ; pick a new file
    newFile = dialog_pickfile(title='Pick a Motion JPEG2000 File', path=(*pstate).mj2PlayerFilePath, DIALOG_PARENT=ev.top)
    if (newFile eq '') then begin
        return
    endif

    ; save last dir in mj2_player preference file
    (*pstate).mj2PlayerFilePath = file_dirname(newFile)
    mj2PlayerFilePath = (*pstate).mj2PlayerFilePath
    save, mj2PlayerFilePath, FILENAME=(*pstate).prefsFile

    (*pstate).fileName = newFile
    widget_control, (*pstate).wtxtFile, set_value = newFile


    ; create a new mjpeg2000 object
    (*pstate).oMJPEG = OBJ_NEW('IDLffMJPEG2000', newFile)

    ; get the mj2 frame characteristics from the file
    (*pstate).oMJPEG->getproperty, n_frames=nFrames, n_layers=nLayers, n_comp=nComps, n_levels=nlevels, dimens=dims
    (*pstate).oMJPEG->getproperty, duration=dur, scan_mode=scanMode, prog=prog, tile_dimens=tiledims
    (*pstate).oMJPEG->getproperty, n_tiles=ntiles, tile_range=trange, bit_depth=bitdepth, color_space=clrsp
    (*pstate).oMJPEG->GetProperty, frame_period=frPeriod, timescale=tmScale, rev=rev, ycc=yc, signed=sign

    ; display the mj2 frame characteristics
    widget_control, (*pstate).wtxtNumFrames,    set_value = strtrim(string(nFrames),2)
    widget_control, (*pstate).wtxtFrComps,      set_value = strtrim(string(nComps),2)
    widget_control, (*pstate).wtxtFrLayers,     set_value = strtrim(string(nLayers),2)
    widget_control, (*pstate).wtxtFrLevels,     set_value = strtrim(string(nLevels),2)
    widget_control, (*pstate).wtxtFrWidth,      set_value = strtrim(string(dims[0]),2)
    widget_control, (*pstate).wtxtFrHeight,     set_value = strtrim(string(dims[1]),2)
    widget_control, (*pstate).wtxtTrkDuration,  set_value = strtrim(string(dur),2)
    widget_control, (*pstate).wtxtScanMode,     set_value = strtrim(string(scanMode),2)
    widget_control, (*pstate).wtxtProg,         set_value = strtrim(string(prog),2)
    widget_control, (*pstate).wtxtTileDimsw,    set_value = strtrim(string(tiledims[0]),2)
    widget_control, (*pstate).wtxtTileDimsh,    set_value = strtrim(string(tiledims[1]),2)
    widget_control, (*pstate).wtxtNTiles,       set_value = strtrim(string(ntiles),2)
    widget_control, (*pstate).wtxtTileRange,    set_value = strtrim(string(trange[0]),2) + ', ' + strtrim(string(trange[1]),2)
    widget_control, (*pstate).wtxtBitDepth,     set_value = strtrim(string(bitdepth),2)
    widget_control, (*pstate).wtxtClrSp,        set_value = strtrim(string(clrsp),2)
    widget_control, (*pstate).wtxtRev,          set_value = strtrim(string(rev),2)
    widget_control, (*pstate).wtxtSigned,       set_value = strtrim(string(sign),2)
    widget_control, (*pstate).wtxtYcc,          set_value = strtrim(string(yc),2)
    widget_control, (*pstate).wtxtStopFr,       set_value = strtrim(string(nFrames),2)

    frRate = tmScale/frPeriod  ; ticks/sec / ticks/frame
    widget_control, (*pstate).wtxtFileFrRate,   set_value = strtrim(string(frRate),2)
    widget_control, (*pstate).wtxtSliderRate, set_value = frRate
    (*pstate).frameRate = frRate

    widget_control, (*pstate).wtxtStopFr, set_value = strtrim(string(nFrames),2)
    (*pstate).stopFr = nFrames

    widget_control, (*pstate).wtxtStartFr, set_value = '0'
    (*pstate).startFr = 0

    ; resize the draw widget to the dimensions of the new frames
    widget_control, (*pstate).wdrwWindow,  draw_xsize = dims[0]
    widget_control, (*pstate).wdrwWindow,  draw_ysize = dims[1]

    ; resize the iTools window to the dimensions of the new frames
    (*pstate).oitWindow->setproperty, dimensions = dims

    ; update the view plane so the 2d image is positon in the visible window
    (*pstate).oView->setproperty, viewplane=[0,0,dims[0], dims[1]]

    widget_control, (*pstate).wbtnPlay,   sensitive=1

    mj2_player_display_start_fr, ev
end


;*****************************************************************************
function mj2_player_GetPrefsDir

    ; build the path to the preference file
    AuthorDirname       = 'ITT'
    AuthorDesc          = 'IDL'
    AppDirname          = 'Motion_JPEG2000'
    AppDesc             = 'Motion JPEG2000 Example UI'
    AppReadmeText       = ['Author: IDL', 'Motion JPEG2000 Player UI properties']
    AppReadmeVersion    = 1
    dir = APP_USER_DIR(AuthorDirname, AuthorDesc, AppDirname, AppDesc, AppReadmeText, AppReadmeVersion)
    return, dir
end


;*****************************************************************************
pro mj2_player_kill_event, id

    widget_control, id, get_uvalue = pstate

    ; destroy the objects we created
    ; see MJ2_Player_event for the higher level kill handling

    if ptr_valid(pstate) then begin

        if (obj_valid((*pstate).oObserver)) then begin
            obj_destroy, (*pstate).oObserver
        endif

        if (obj_valid((*pstate).oModel)) then begin
            obj_destroy, (*pstate).oModel
        endif


        if (obj_valid((*pstate).oMJPEG)) then begin
            obj_destroy, (*pstate).oMJPEG
        endif

        ptr_free, pstate
    endif
end


;*****************************************************************************

pro MJ2_Player_Event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='MJ2 Player Error::MJ2_Player_Event', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; we ensure the iTools window timer is turned off
    ; we ensure the file is closed and the write thread in the mjpeg2000 object is shutdown
    if TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' then begin

        if ptr_valid(pstate) then begin

            if (obj_valid((*pstate).oitWindow)) then begin
                (*pState).oitWindow->SetEventMask, TIMER_EVENTS=0
            endif

            if (obj_valid((*pstate).oMJPEG)) then begin
                vRes = (*pstate).oMJPEG->StopSequentialReading()
            endif
        endif

        widget_control, ev.top, /destroy
   endif
end


;*****************************************************************************

pro mj2_player

    compile_opt idl2

    ;----------------------------------------------------------
    ; catch errors and display a dialog and exit

    on_error, 2
    catch, errorStatus
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='IDL MJ2 Player Error', dialog_parent=wTlb, /error)
        return
    ENDIF


    ;----------------------------------------------------------
    ; root level widget for this ui
    xsize           = 660
    wTlb            = widget_base(/column, TITLE='IDL Motion JPEG2000 Player', uname='mj2_player', kill_notify='mj2_player_kill_event', /tlb_kill_request_events)


    ;----------------------------------------------------------
    ; play tab

    wTabCntrl       = widget_tab(wTlb)
    wTabPlay        = widget_base(wTabCntrl, title=' Player ',/col, uname='mj2_player_play_tab', uvalue=wTlb)

    ;----------------------------------------------------------
    ; play tab: file frame
    wbaseFile       = widget_base(wTabPlay)
    wLblFile        = widget_label(wbaseFile, value=' File Selection ', xoffset=5)
    winfoLblFile    = widget_info(wLblFile, /geometry)
    wFrFile         = widget_base(wbaseFile, /frame, yoffset=winfoLblFile.ysize/2, xsize=xsize, /col, space=2, ypad=10, xpad=1, tab_mode=1)
    wLblFile        = widget_label(wbaseFile, value=' File ', xoffset=5)
    wRow            = widget_base(wFrFile, /row, space=5)
    wbtnFile        = widget_button(wRow, value='File', xsize = 80, event_pro='mj2_player_btnFile_event')
    wlblFile        = widget_label(wRow, value=' File', /align_right)
    wtxtFile        = widget_text(wRow, value='', scr_xsize=500)

    ;----------------------------------------------------------
    ; play tab: sequential playback controls frame
    wbaseSeq        = widget_base(wTabPlay)
    wLblSeq         = widget_label(wbaseSeq, value=' Sequential PlayBack Controls ', xoffset=5)
    winfoLblSeq     = widget_info(wLblSeq, /geometry)
    wbaseFrSeq      = widget_base(wbaseSeq, /frame, yoffset=winfoLblSeq.ysize/2, xsize=xsize, /col, space=2, ypad=10, xpad=1)
    wLblSeq         = widget_label(wbaseSeq, value=' Sequential Mode ', xoffset=5)

    wRow            = widget_base(wbaseFrSeq, /row, space=5)
    wbtnPlay        = widget_button(wRow, value='Play',          xsize = 80, scr_ysize=30, event_pro='mj2_player_btnSeqPlay_event')
    wbtnStop        = widget_button(wRow, value='Stop',          xsize = 80, scr_ysize=30, event_pro='mj2_player_btnSeqStop_event')
    wbtnSeqRev      = widget_button(wRow, value='Step Rev',      xsize = 80, scr_ysize=30, event_pro='mj2_player_btnSeqStepRev_event')
    wbtnSeqFwd      = widget_button(wRow, value='Step Fwd',      xsize = 80, scr_ysize=30, event_pro='mj2_player_btnSeqStepFwd_event')
    wlblFrNum       = widget_label(wRow,  value=' Frame Num', /align_right)
    wtxtFrNum       = widget_text(wRow,   value='0', scr_xsize=50, scr_ysize=30)
    wlblFrPerSec    = widget_label(wRow,  value=' Frames/Sec', /align_right)
    wtxtFrPerSec    = widget_text(wRow,   value='0', scr_xsize=50, scr_ysize=30)

    widget_control, wbtnPlay,   sensitive=0
    widget_control, wbtnStop,   sensitive=0
    widget_control, wbtnSeqFwd, sensitive=0
    widget_control, wbtnSeqRev, sensitive=0

    ;----------------------------------------------------------
    ; properties tab
    wTab2           = widget_base(wTabCntrl, title=' Properties  ',/col, uname='mj2_player_info_tab')

    ; property tab: mj2 frame characteristics
    wbaseFC         = widget_base(wTab2)
    wLblFC          = widget_label(wbaseFC, value=' MJ2 Frame Characteristics ', xoffset=5)
    winfoLblFC      = widget_info(wLblFC, /geometry)
    wbaseFrFC       = widget_base(wbaseFC, /frame, yoffset=winfoLblFC.ysize/2, xsize=xsize, /col, space=2, ypad=10, xpad=1, tab_mode=1)
    wLblFC          = widget_label(wbaseFC, value=' MJ2 Frame Characteristics ', xoffset=5)


    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblFrComps     = widget_label(wRow, value=' Components', scr_xsize=80,  /align_right)
    wtxtFrComps     = widget_text(wRow, value='--', scr_xsize=60)
    wlblFrWidth     = widget_label(wRow, value=' Width', scr_xsize=80,  /align_right)
    wtxtFrWidth     = widget_text(wRow, value='--', scr_xsize=60)
    wlblFrHeight    = widget_label(wRow, value=' Height', scr_xsize=80,  /align_right)
    wtxtFrHeight    = widget_text(wRow, value='--', scr_xsize=60)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblFrLayers    = widget_label(wRow, value=' Layers', scr_xsize=80,  /align_right)
    wtxtFrLayers    = widget_text(wRow, value='--', scr_xsize=60)
    wlblFrLevels    = widget_label(wRow, value=' Levels', scr_xsize=80,  /align_right)
    wtxtFrLevels    = widget_text(wRow, value='--', scr_xsize=60)
    wlblRev         = widget_label(wRow, value=' Reversible', scr_xsize=80,  /align_right)
    wtxtRev         = widget_text(wRow, value='--', scr_xsize=60)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblNumFrames   = widget_label(wRow, value=' Num Frames', scr_xsize=80,  /align_right)
    wtxtNumFrames   = widget_text(wRow, value='--', scr_xsize=60)
    wlblTrkDuration = widget_label(wRow, value=' Duration', scr_xsize=80,  /align_right)
    wtxtTrkDuration = widget_text(wRow, value='--', scr_xsize=60)
    wlblFileFrRate  = widget_label(wRow, value=' Frame Rate', scr_xsize=80,  /align_right)
    wtxtFileFrRate  = widget_text(wRow, value='--', scr_xsize=60)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblClrSp       = widget_label(wRow, value=' Color Space', scr_xsize=80,  /align_right)
    wtxtClrSp       = widget_text(wRow, value = '---', scr_xsize=60)
    wlblYcc         = widget_label(wRow, value=' Ycc', scr_xsize=80,  /align_right)
    wtxtYcc         = widget_text(wRow, value='--', scr_xsize=60)
    wlblProg        = widget_label(wRow, value=' Progression', scr_xsize=80,  /align_right)
    wtxtProg        = widget_text(wRow, value='----', scr_xsize=60)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblBitDepth    = widget_label(wRow, value=' Bit Depth', scr_xsize=80,  /align_right)
    wtxtBitDepth    = widget_text(wRow, value = '--', scr_xsize=60)
    wlblSigned      = widget_label(wRow, value=' Signed', scr_xsize=80,  /align_right)
    wtxtSigned      = widget_text(wRow, value='--', scr_xsize=60)
    wlblScanMode    = widget_label(wRow, value=' Scan Mode', scr_xsize=80,  /align_right)
    wtxtScanMode    = widget_text(wRow, value='-', scr_xsize=60)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblTileDimsw   = widget_label(wRow, value=' Tile Width', scr_xsize=80,  /align_right)
    wtxtTileDimsw   = widget_text(wRow, value = '--', scr_xsize=60)
    wlblTileDimsh   = widget_label(wRow, value=' Tile Height', scr_xsize=80,  /align_right)
    wtxtTileDimsh   = widget_text(wRow, value = '--', scr_xsize=60)
    wlblNTiles      = widget_label(wRow, value=' Num Tiles', scr_xsize=80,  /align_right)
    wtxtNTiles      = widget_text(wRow, value = '--', scr_xsize=60)
    wlblTileRange   = widget_label(wRow, value=' Tile Range', scr_xsize=80,  /align_right)
    wtxtTileRange   = widget_text(wRow, value = '--', scr_xsize=60)

    ;----------------------------------------------------------
    ; property tab: sequential playback controls
    wbaseFC         = widget_base(wTab2)
    wLblFC          = widget_label(wbaseFC, value=' Sequential Playback Controls ', xoffset=5)
    winfoLblFC      = widget_info(wLblFC, /geometry)
    wbaseFrFC       = widget_base(wbaseFC, /frame, yoffset=winfoLblFC.ysize/2, xsize=xsize, /col, space=2, ypad=10, xpad=1, tab_mode=1)
    wLblFC          = widget_label(wbaseFC, value=' MJ2 Frame Characteristics ', xoffset=5)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblFrRate      = widget_label(wRow, value=' Frame Rate', /align_right)
    wtxtSliderRate  = widget_slider(wRow, min=1, max=60, value=25, scr_xsize=70, scr_ysize=35)
    wlblfrbuflen    = widget_label(wRow, value=' Frame Buffer Length *', /align_right)
    wtxtfrbuflen    = widget_text(wRow, /editable, value = '3', scr_xsize=55, scr_ysize=30)

    wlblStartFr     = widget_label(wRow, value=' Start Frame *', /align_right)
    wtxtStartFr     = widget_text(wRow, /editable, value = '0', scr_xsize=55, scr_ysize=30)

    wlblStopFr      = widget_label(wRow, value=' Stop Frame *', /align_right)
    wtxtStopFr      = widget_text(wRow, /editable, value = '250', scr_xsize=60, scr_ysize=30)

    wRow            = widget_base(wbaseFrFC, /row, space=5)
    wlblStopFr      = widget_label(wRow, value='* to apply these values press the stop/reset button ', scr_xsize=470, /align_right)

    ;----------------------------------------------------------
    ; play tab: frame display window (draw widget, idlitwindow, idlgrview, idlgrimage)
    wDrw            = widget_base(wTabPlay, /row)

    ; create a draw widget that contains a IDLitWindow, the view will draw itself into this window
    wdrwWindow      = widget_draw(wDrw, xsize=xsize, ysize=480, graphics_level=2, CLASSNAME='IDLitWindow', renderer=0)

    ; realize the ui so the IDLitWindow is created
    widget_control, /real, wtlb

    ; get the IDLitWindow from the draw widget
    widget_control, wdrwWindow, get_value=oitWindow

    ; add the observer object to the IDLitWindow
    oObserver       = obj_new('mj2_player_timer')
    oObserver->SetProperty, tlb = wtlb
    oitWindow->AddWindowEventObserver, oObserver

    ; create a view into which the frames will be written
    ; the view will drawn into the IDLitWindow created above
    oView           = obj_new('idlgrview')
    oModel          = obj_new('idlgrmodel')
    oImage          = obj_new('idlgrimage')
    oView->add, oModel
    oModel->add, oImage

    ; use our view instead of the default view embbeded in the IDLitWindow
    oitWindow->setproperty, graphics_tree=oView

    ;----------------------------------------------------------
    ; the motion jpeg2000 object...the ptr is set when a file is selected
    oMJPEG          =  obj_new()

    ;----------------------------------------------------------
    ; variables
    framesPlayed        = 0
    startTime           = 0.0D
    fileName            = ''
    mj2PlayerFilePath   = ''            ; this value is filled in by the restore of the prefernce file
    mj2WriterFilePath   = ''            ; this value is filled in by the restore of the prefernce file
    seqMode             = 'stopped'
    frameRate           = 1.0
    startFr             = 0
    stopFr              = 1


    ;----------------------------------------------------------
    ; if we have a motion jpeg 2000 examples preference file then load it
    prefsDir = mj2_player_GetPrefsDir()
    prefsFile = filepath(ROOT_DIR=prefsDir, 'mjpeg2000_example_ui.sav')
    if (file_test(prefsFile, /REGULAR)) then begin
        restore, prefsFile
    endif

    ;----------------------------------------------------------
    ; state variable holds all the UI properties needed in the event handlers
    state = {   wbtnPlay:wbtnPlay, wbtnStop:wbtnStop, wbtnSeqRev:wbtnSeqRev, wbtnSeqFwd:wbtnSeqFwd, $
                wtxtFile:wtxtFile, wtxtFrNum:wtxtFrNum, wtxtFrPerSec:wtxtFrPerSec, wtxtFrComps:wtxtFrComps, $
                wtxtFrWidth:wtxtFrWidth, wtxtFrHeight:wtxtFrHeight, wtxtFrLayers:wtxtFrLayers, $
                wtxtFrLevels:wtxtFrLevels, wtxtNumFrames:wtxtNumFrames, wtxtTrkDuration:wtxtTrkDuration, $
                wtxtFileFrRate:wtxtFileFrRate, wtxtClrSp:wtxtClrSp, wtxtYcc:wtxtYcc, wtxtScanMode:wtxtScanMode, $
                wtxtProg:wtxtProg, wtxtRev:wtxtRev, wtxtBitDepth:wtxtBitDepth, wtxtSigned:wtxtSigned, $
                wtxtTileDimsw:wtxtTileDimsw, wtxtTileDimsh:wtxtTileDimsh, wtxtNTiles:wtxtNTiles, $
                wtxtTileRange:wtxtTileRange, wtxtSliderRate:wtxtSliderRate, $
                wtxtfrbuflen:wtxtfrbuflen, wtxtStartFr:wtxtStartFr, wtxtStopFr:wtxtStopFr, $
                wdrwWindow:wdrwWindow, oitWindow:oitWindow, oObserver:oObserver, oView:oView, oModel:oModel, $
                oImage:oImage, oMJPEG:oMJPEG, $
                framesPlayed:framesPlayed, startTime:startTime, fileName:fileName, mj2PlayerFilePath:mj2PlayerFilePath, $
                prefsFile:prefsFile, seqMode:seqMode, frameRate:frameRate, startFr:startFr, stopFr:stopFr }

    ; create a ptr to the state variable
    pstate = ptr_new(state, /no_copy)

    ; put the state ptr in the uvalue of the base state widget so all events can get the state
    widget_control, wtlb, set_uvalue=pstate


    ;----------------------------------------------------------
    ; start pumping the ui events
    XMANAGER,'MJ2_Player', wTlb, GROUP=group, NO_BLOCK=1

END
