
; $Id: //depot/idl/IDL_70/idldir/examples/mjpeg2000/mj2_writer_rgb.pro#2 $

; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       mj2_writer_rgb
;
; PURPOSE:
;       Create an RGB Motion JPEG2000 movie/animation using the IDLffMJPEG2000
;       object.  To view how the IDLffMJPEG2000 object is used by this example
;       mj2 writer search for oMJPEG-> in this file.
;
;
;       Demonstrates the how to
;          - create a lossless mj2 file using the IDLffMJPEG2000 object.
;
;       The path btn is used to pick the directory to write the new mj2
;       file. The file is named "idl_powered_by.mj2".
;
;       The write button is used to start the creation of a new mj2 file.
;       When the write button is pressed a timer is started. Each time
;       the timer fires:
;           - the image, surface, text objects are updated
;           - the updated window image is read (scraped) into a buffer
;           - the buffer (frame) is added to the mj2 object/file as a video frame
;
;       When the desired number of frames have been written to the mj2 file the
;       the timer is turned off and the mj2 file is saved via a commit call.
;
;       To create the ui this example uses
;           - widget_button
;           - widget_text
;           - widget_label
;           - widget_slider
;           - widget_draw
;           - idlitwindow
;           - idlgrsurface
;           - idlgrview
;           - idlgrimage
;           - idlgrmodel
;           - idlgrtext
;
;       An iTool (idlitwindow) window is used in a draw widget so that the more accurated iTools
;       window timer can be used.  The rotatorobj is an observer of the idlitwindow
;       events and hence receives the timer event.
;
;
; CATEGORY:
;       file access and object graphics.
;
; CALLING SEQUENCE:
;       mj2_writer_rgb
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

;****************************************************************************
; Custom behavior class rotates the model containing the surface object. This class
; could be used to rotate any object (such as a volume or image) that is contained in the model.

function RotatorObj::Init, oSurfaceModel
    self.oSurfaceModel = oSurfaceModel
    return, 1
end

;*****************************************************************************
pro RotatorObj::Cleanup

end

;*****************************************************************************
pro RotatorObj::SetProperty, tlb = tlb, cnt = cnt

    if N_ELEMENTS(tlb) gt 0 then $
        self.tlb = tlb

    if N_ELEMENTS(cnt) gt 0 then $
        self.cnt = cnt

end

;*****************************************************************************
pro RotatorObj::GetProperty, tlb = tlb

    if ARG_PRESENT(currentImage) then $
        tlb = self.tlb
end

;*****************************************************************************
pro RotatorObj::OnTimer, oWin
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg

        if ptr_valid(pstate) then begin
            if (obj_valid((*pstate).objDrwAnimation)) then begin
                (*pState).objDrwAnimation->SetEventMask, TIMER_EVENTS=0
            endif
        endif

        r = dialog_message(!error_state.msg, title='IDL MJ2 Writer RGB Error', dialog_parent=self.tlb, /error)

        if ptr_valid(pstate) then begin
            if (obj_valid((*pstate).oMJPEG)) then begin
                x = (*pState).oMJPEG->Commit(100)
                obj_destroy, (*pstate).oMJPEG
            endif
        endif
        return
    endif

    ; this is the timer routine that fires at the selected frame rate
    ; this timer will fire for each frame to be added to the new mj2 file
    ; each time the timer fires:
    ;           - the iamge, surface, text objects are updated
    ;           - the updated window image is read into a buffer
    ;           - the buffer (frame) is added to the mj2 object/file as a video frame

    widget_control, self.tlb, get_uvalue = pstate

    if (obj_valid((*pstate).oMJPEG)) then begin
        if (self.cnt le (*pstate).numFrames) then begin

            if (self.cnt lt 23) then begin
                ; fade the powered by idl image
                alpha = 1 - (.033 * (self.cnt+1))
                (*pState).oPBIImage->SetProperty, Alpha=alpha

                ; zoom out the powered by idl image
                scale = 1 - (.005 * (self.cnt+1))
                (*pState).oPBIModel->scale, scale, scale, 1
            endif

            ; fade in the rotating surface
            alpha = (.015 * (self.cnt+1))
            if (alpha lt 1) then begin
                (*pState).oSurface->SetProperty, Alpha=alpha
            endif

            ; rotate the surface
            self.oSurfaceModel->Rotate, [0,1,0], 10

            oWin->Draw

            ; scrape the image window
            oWin->getproperty, image_data = img

            ; add the scraped image into the mj2 file
            vFrNum = (*pstate).oMJPEG->SetData(img)

            ; bump the displayed frame count
            self.cnt++
            (*pstate).oText->setproperty, Strings= strtrim(self.cnt,2)

        endif

        ; once we write the desired number of frames we:
        ;   - turn off the timer that triggers this method to run
        ;   - call commit to close the mj2 file and shutdown the write thread
        ;   - we give the write thread upto 10 seconds to empty the write frame buffer
        if (self.cnt ge (*pstate).numFrames) then begin
            (*pState).objDrwAnimation->SetEventMask, TIMER_EVENTS=0
            x = (*pState).oMJPEG->Commit(10000)
            obj_destroy, (*pstate).oMJPEG
            (*pstate).oText->setproperty, Strings= '0'
        endif
    endif
end

;*****************************************************************************
pro RotatorObj__define
    void = { RotatorObj, oSurfaceModel: OBJ_NEW(), cnt:0L, tlb:0L }
end

;*****************************************************************************
pro mj2_writer_rgb_btnWrite_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='IDL MJ2 Writer RGB Error', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    (*pState).oRotator->setproperty, cnt=0

    ; set the desired frame rate into the mj2 file
    widget_control, (*pstate).wsldrCaptureRate, get_value = rate
    timescale = 30000
    frtics = timescale * 1/rate

    ; this is the number of frames to add to the mj2 file
    widget_control, (*pstate).wtxtNumFrames, get_value = wstrings
    (*pstate).numFrames = wstrings[0]

    ; number of frame buffer slots to be used by the write thread
    widget_control, (*pstate).wtxtFrBufLen, get_value = frBufLen

    ; create a new lossless motion jpeg 2000 object/file
    ; frames will be added to this mj2 object/file
    fn = (*pstate).mj2WriterFilePath
    (*pState).oMJPEG = obj_new('idlffmjpeg2000', fn, /write, frame_period=frtics, rev=1, frame_buffer_length=frBufLen[0])

    ; undo the zoom out if zoomed
    (*pState).oPBIModel->reset

    ; Set the timer interval and turn on window timer events.
    vrate = 1/float(rate)
    (*pState).objDrwAnimation->SetTimerInterval, vrate
    (*pState).objDrwAnimation->SetEventMask, /TIMER_EVENTS
end



;*****************************************************************************
pro mj2_writer_rgb_btnPath_event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='IDL MJ2 Writer RGB Error', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; pick a new dir to save the idl_powered_by.mj2 in
    path = file_dirname((*pstate).mj2WriterFilePath)
    newPath = dialog_pickfile(title='Pick a directory to write the idl_powered_by.mj2 file', path=path, DIALOG_PARENT=ev.top, /directory)
    if (newPath eq '') then begin
        return
    endif

    ; save last dir/file in mj2_player preference file
    newFile = filepath('idl_powered_by.mj2', root= newPath)
    mj2WriterFilePath = newFile
    print, newFile
    save, mj2WriterFilePath, FILENAME=(*pstate).prefsFile

    widget_control, (*pstate).wtxtPath, set_value = newFile
end

;*****************************************************************************
function mj2_writer_GetPrefsDir

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
pro MJ2_Writer_RGB_Event, ev
    compile_opt idl2

    catch, errorStatus            ; catch all errors and display an error dialog
    if (errorStatus ne 0) then begin
        catch,/cancel
        print, !error_state.msg
        r = dialog_message(!error_state.msg, title='IDL MJ2 Writer RGB Error', dialog_parent=ev.top, /error)
        return
    endif

    widget_control, ev.top, get_uvalue = pstate

    ; we ensure the iTools window timer is turned off
    if TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' then begin
        if ptr_valid(pstate) then begin
            if (obj_valid((*pstate).objDrwAnimation)) then begin
                (*pState).objDrwAnimation->SetEventMask, TIMER_EVENTS=0
            endif
        endif

        widget_control, ev.top, /destroy
    endif
end


;*****************************************************************************
pro mj2_writer_rgb_kill_event, id

    widget_control, id, get_uvalue = pstate

    ; destroy the objects we created
    ; the mj2 file is closed and the write thread is thread is stopped, if not already closed/stopped,
    ; see MJ2_Writer_RGB_Event for the higher level kill handling

    if ptr_valid(pstate) then begin

        if (obj_valid((*pState).objDrwAnimation)) then begin
            (*pState).objDrwAnimation->SetEventMask, TIMER_EVENTS=0
        end

        if (obj_valid((*pstate).oRotator)) then begin
            obj_destroy, (*pstate).oRotator
        endif

        if (obj_valid((*pstate).oSurfaceModel)) then begin
            obj_destroy, (*pstate).oSurfaceModel
        endif

        if (obj_valid((*pstate).oMJPEG)) then begin
            x = (*pState).oMJPEG->Commit(100)        ; we close the file end the user forgot to
            obj_destroy, (*pstate).oMJPEG
        endif

        ptr_free, pstate
    endif
end


;****************************************************************************
pro mj2_writer_rgb
    compile_opt idl2

    ;----------------------------------------------------------
    ; catch errors and display a dialog and exit

    on_error, 2
    catch, errorStatus
    if (errorStatus ne 0) then begin
        catch,/cancel
        r = dialog_message(!error_state.msg, title='IDL MJ2 Writer RGB Error', dialog_parent=wTlb, /error)
        return
    ENDIF

    ;----------------------------------------------------------
    ; root level widget for this ui
    xsize           = 565
    wtlb            = widget_base(/col, title='IDL - Motion JPEG 2000 Writer RGB', kill_notify='mj2_writer_rgb_kill_event', /TLB_KILL_REQUEST_EVENTS )

    ;----------------------------------------------------------
    ; file frame widgets
    wbaseRB         = widget_base(wtlb)
    wLblRB          = widget_label(wbaseRB, value=' File ', xoffset=5)
    winfoLblRB      = widget_info(wLblRB, /geometry)
    wbaseFrRB       = widget_base(wbaseRB, /frame, yoffset=winfoLblRB.ysize/2, xsize=xsize, /col, space=2, ypad=10, xpad=1, tab_mode=1)
    wLblRB          = widget_label(wbaseRB, value=' File ', xoffset=5)

    wRow            = widget_base(wbaseFrRB, /row, space=5)
    wbtnPath        = widget_button(wRow, value='Path', xsize = 60, event_pro='mj2_writer_rgb_btnPath_event')
    wlblPath        = widget_label(wRow, value=' Path', /align_right)
    wtxtPath        = widget_text(wRow, value='', scr_xsize=450)
    wRow            = widget_base(wbaseFrRB, /row, space=5)

    ;----------------------------------------------------------
    ; capture frame widgets
    wbaseMP         = widget_base(wtlb)
    wLblMP          = widget_label(wbaseMP, value=' Capture ', xoffset=5)
    winfoLblMP      = widget_info(wLblMP, /geometry)
    wbaseFrMP       = widget_base(wbaseMP, /frame, yoffset=winfoLblMP.ysize/2, xsize=xsize, /col, space=2, ypad=10, xpad=1, tab_mode=1)
    wLblMP          = widget_label(wbaseMP, value=' Capture ', xoffset=5)

    wRow            = widget_base(wbaseFrMP, /row, space=5)
    wbtnWrite       = widget_button(wRow, value='Write', xsize = 80, event_pro='mj2_writer_rgb_btnWrite_event')
    wlblNumFrames   = widget_label(wRow, value=' # Frames', /align_right)
    wtxtNumFrames   = widget_text(wRow, /editable, value = '120', scr_xsize=40)
    wlblFrBufLen    = widget_label(wRow, value=' Frame Buffer Length', /align_right)
    wtxtFrBufLen    = widget_text(wRow, /editable, value = '4', scr_xsize=30)
    wlblCaptureRate = widget_label(wRow, value=' Capture Rate', /align_right)
    wsldrCaptureRate= widget_slider(wRow, min=1, max=60, value=20, scr_xsize=100, scr_ysize=35)

    ;----------------------------------------------------------
    ; row for draw widget
    wdrwr           = widget_base(wtlb, /row)

    ; create a draw widget that contains a IDLitWindow, the view will draw itself into this window
    wdrwAnimation   = widget_draw(wdrwr, xsize=300, ysize=300, graphics_level=2, CLASSNAME='IDLitWindow')

    ; realize the ui so the IDLitWindow is created
    widget_control, /real, wtlb

    ; get the IDLitWindow from the draw widget
    widget_control, wdrwAnimation, get_value=objDrwAnimation

    ;----------------------------------------------------------
    ; create a view...this view will contain 4 models
    ;  - surface model that rotates, and fades in
    ;  - light model illuminates the surface
    ;  - text model that holds the frame number
    ;  - image model that holds the powered by idl image that fades out
    oView       = OBJ_NEW('IDLgrView')

    ; create a surface and add it to the surface model and add the model to the view
    ; set the initial alpha value so the surface is barely visible
    zdata           = HANNING (40, 40)
    oSurfaceModel   = OBJ_NEW('IDLgrModel')
    oSurface        = obj_new('IDLgrSurface', zdata, STYLE=2, COLOR=[0,0,255], BOTTOM=[255, 0, 0], SHADING=1, ALPHA=.01)
    oSurfaceModel->Add, oSurface
    oView->Add, oSurfaceModel

    ; create a light and add it to the light model and add the model to the view
    oLightModel = OBJ_NEW('IDLgrModel')
    oLight      = OBJ_NEW('IDLgrLight', type=2, location = [-1, -1, 1])
    oLightModel->Add, oLight
    oView->Add, oLightModel

    ; create a light and add it to the light model and add the model to the view
    oTextModel = OBJ_NEW('IDLgrModel')
    oText = OBJ_NEW('IDLgrText', '0', LOCATION=[-.9,-.9,1], COLOR=[0,0,0])
    oTextModel->Add, oText
    oView->Add, oTextModel

    ; create a image and add it to the image model and add the model to the view
    ; use the blend keyword to allow the alpha property on the image object to take affect
    oPBIModel       = obj_new('idlgrmodel')
    oPBIImage       = obj_new('idlgrimage', blend=[3,4])
    oPBIModel->add, oPBIImage
    oView->add, oPBIModel

    ;----------------------------------------------------------
    ; load the powered by idl jpeg into the image object
    pbi = filepath('IDLPoweredBy.jpg', sub= ['examples','mjpeg2000'])
    read_jpeg, pbi, pbibuf
    oPBIImage->setproperty, data=pbibuf

    ;----------------------------------------------------------
    ; pixels to normalized coordinates
    ;
    ; conv factors:
    ;     conv[0] is the offset and conv[1] is the scale factor

    ; conv equation to normalize between 0 and 1
    ;     conv = [(-Ymin)/(Ymax-Ymin), 1/(Ymax-Ymin)]
    ;
    ; conv equation to normalize between -1 and 1
    ;     conv = [(-Ymin)/(Ymax-Ymin)-1, 2/(Ymax-Ymin)]
    ;
    ; viewplane_rect default:
    ;     x = -1, y = -1, w = 1, h = 1
    ;     -1 to 1 means that the view plane rect is 2 by 2
    ;
    ; to use the entire view plane rect
    ;     conv = [(-Ymin)/(Ymax-Ymin)-1, 2/(Ymax-Ymin)]
    ;        when the pixels go from 0 to num pixels
    ;            conv[0] = -1 and conv[1] = 2/num pixels
    ;
    ; to use the 1/2 of the view plane rect
    ;     conv = [(-Ymin)/(Ymax-Ymin)-.5, 1/(Ymax-Ymin)]
    ;        when the pixels go from 0 to num pixels
    ;            conv[0] = -.5 and conv[1] = 1/num pixels
    ;
    ;
    ;----------------------------------------------------------
    ; Convert surface data coordinates to normal coordinates
    ; have the surface use half the view plane rect so that when it is
    ; rotated the surface is not cropped by the view plane rect
    oSurface->Getproperty, XRANGE=xrSurf, YRANGE=yrSurf, ZRANGE=zrSurf

    xcSurf = [(-xrSurf[0])/(xrSurf[1]-xrSurf[0]) -.5, 1/(xrSurf[1]-xrSurf[0])]
    ycSurf = [(-yrSurf[0])/(yrSurf[1]-yrSurf[0]) -.5, 1/(yrSurf[1]-yrSurf[0])]
    zcSurf = [(-zrSurf[0])/(zrSurf[1]-zrSurf[0]) -.5, 1/(zrSurf[1]-zrSurf[0])]

    oSurface->Setproperty, XCOORD_CONV=xcSurf, YCOORD_CONV=ycSurf, ZCOORD_CONV=zcSurf

    ;----------------------------------------------------------
    ; Convert powered by idl data coordinates to normal coordinates.
    ; we are using a draw widget window that is 300 by 300 pixels
    ; IDLPoweredBy.jpg image is 300 pixels wide by 131 pixels high
    ; we want to put the image in the middle of the window w/o streching it

    ; offset  = (0/300-0)-1 = -1    scale factor = 2/300 = .006666
    xcImg = [-1.0,   .00666]  ; 2/300 = .00666

    ; offset  = (300-131/300-0)-1 = .4366    scale factor = 2/300 = .006666
    ycImg = [-.4366, .00666]

    oPBIImage->Setproperty, XCOORD_CONV=xcImg, YCOORD_CONV=ycImg

    ;----------------------------------------------------------
    ; starting position for surface
    oSurfaceModel->ROTATE, [1,0,0], -90
    oSurfaceModel->ROTATE, [0,1,0], 30
    oSurfaceModel->ROTATE, [1,0,0], 30

    ;----------------------------------------------------------
    ; add the observer object to the IDLitWindow
    oRotator = OBJ_NEW('RotatorObj', oSurfaceModel)
    oRotator->SetProperty, tlb = wtlb
    objDrwAnimation->AddWindowEventObserver, oRotator

    ; make are view the default graphics tree for the itWindow
    objDrwAnimation->setproperty, graphics_tree=oView

    ;----------------------------------------------------------
    ; motion jpeg 2000 object...ptr is set when file is created
    oMJPEG = obj_new()

    ;----------------------------------------------------------
    ; variables
    numFrames = 100
    mj2PlayerFilePath   = ''            ; this value is filled in by the restore of the prefernce file
    mj2WriterFilePath   = ''            ; this value is filled in by the restore of the prefernce file

    ;----------------------------------------------------------
    ; if we have a motion jpeg 2000 examples preference file then load it
    prefsDir = mj2_writer_GetPrefsDir()
    prefsFile = filepath(ROOT_DIR=prefsDir, 'mjpeg2000_example_ui.sav')
    if (file_test(prefsFile, /REGULAR)) then begin
        restore, prefsFile
    endif

    if (mj2WriterFilePath eq '') then begin
        fn = filepath(ROOT_DIR=prefsDir, 'idl_powered_by.mj2')
        mj2WriterFilePath = fn
    endif

    widget_control, wtxtPath, set_value = mj2WriterFilePath

    ;----------------------------------------------------------
    ; put the state ptr in the uvalue of the base state widget so all events can get the state
    state = {oMJPEG:oMJPEG, objDrwAnimation:objDrwAnimation, oRotator:oRotator, oSurfaceModel:oSurfaceModel, oView:oView, $
             oSurface:oSurface, oText:oText, oPBIModel:oPBIModel, oPBIImage:oPBIImage, $
             wtxtFrBufLen:wtxtFrBufLen,  wtxtNumFrames:wtxtNumFrames, wtxtPath:wtxtPath, wsldrCaptureRate:wsldrCaptureRate, $
             numFrames:numFrames, mj2WriterFilePath:mj2WriterFilePath, prefsFile:prefsFile}

    pstate = ptr_new(state, /no_copy)
    widget_control, wtlb, set_uvalue=pstate

    ;----------------------------------------------------------
    XMANAGER,'MJ2_Writer_RGB', wtlb, GROUP=group, NO_BLOCK=1
end



