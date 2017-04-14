;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/mj2_simple_sequential_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;-----------------------------------------------------------------
PRO mj2_simple_sequential_doc_event, sEvent
;
; General widget event where WIDGET_TIMER events are accessed -
; used to control playback rate of frames (vFrameRate).

   COMPILE_OPT IDL2, HIDDEN

   ; Get the number of frames and the current frame number.
   WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState

   ; If the widget had more than one event, the following line
   ; would find timer events.
   IF (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_TIMER') $
      THEN BEGIN

      ; Play all available frames (nFrames). Return the frame
      ; period of each frame to compute the playback rate.
      frameIndex = (*pstate).oMJPEG2000->GetSequentialData(Data)

      ; If request for data is too fast, handle return of -1.
      IF (frameIndex NE -1) THEN BEGIN
         ; If a frame is available, display RGB data.
         TV, Data, TRUE=1
         ; Release the frame and make buffer slot available.
         (*pState).oMJPEG2000->ReleaseSequentialData, frameIndex
      ENDIF

      ; Update timer with frame rate.
      WIDGET_CONTROL, (*pState).wBase, Timer=(*pState).vFrameRate
   ENDIF
END

;-----------------------------------------------------------------
;
PRO mj2_timer_doc_cleanup, id
;
; Release the frames from the frame buffer and
; shut down the background processing thread.
; Clean up object and pointer.

   WIDGET_CONTROL, id, GET_UVALUE=pState
   Status = (*pState).oMJPEG2000->StopSequentialReading()
   OBJ_DESTROY, (*pState).oMJPEG2000
   PTR_FREE, pState

END

;-----------------------------------------------------------------
;
PRO mj2_simple_sequential_doc
;
; Create a Motion JPEG2000 object that reads a sample MJ2 file. Use
; a timer mechanism to play back the files at the frame rate of the
; the first frame.

   ; Create a Motion JPEG2000 object and read in the
   ; idl_mjpeg2000_example.mj2 sample movie.
   oMJPEG2000 = Obj_New('IDLffMJPEG2000', $
      FILEPATH('idl_mjpeg2000_example.mj2', $
      SUBDIRECTORY=['examples','mjpeg2000']))

   ; Get the number of frames and frame dimensions.
   oMJPEG2000->GetProperty, N_FRAMES=nFrames, $
      DIMENSIONS=imageSize, FRAME_PERIOD=vFramePeriod, $
      TIMESCALE=vTimeScale

   ; Figure frames per second and print result.
   vFrameRate = FLOAT(vFramePeriod)/vTimeScale
   vFramePerSec =  STRING(1/(vFrameRate))
   PRINT, "Frames per second = " + vFramePerSec

   ; Create base and draw widgets.
   wBase = WIDGET_BASE(/COLUMN, $
      TITLE="Simple Sequential Playback", $
      KILL_NOTIFY='mj2_timer_doc_cleanup', UVALUE='TIMER')
   wDraw = WIDGET_DRAW(wBase, XSIZE =imageSize[0], $
      YSIZE=imageSIZE[1])

   ; Realize base and initialize timer.
   WIDGET_CONTROL,/REALIZE, wBase
   WIDGET_CONTROL, wBase, TIMER=vFrameRate

   ; Start reading the RGB frames into the frame buffer.
   Status = oMJPEG2000->StartSequentialReading(/RGB)

   ; Create state structure.
   state = {oMJPEG2000:oMJPEG2000, wBase:wBase, $
      vFrameRate:vFrameRate}
   pState = PTR_NEW(state)
   WIDGET_CONTROL, wBase, set_UVALUE=pstate

   XMANAGER, 'mj2_simple_sequential_doc', wBase, /NO_BLOCK

END