;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/mj2_timer_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       mj2_timer_doc.pro
;
;  CALLING SEQUENCE: mj2_timer_doc
;
;  PURPOSE:
;       Demonstrates how to use a widget timer event to control
;       the display rate of a Motion JPEG2000 file that has
;       frames with varying frame lengths.
;
;
;  MAJOR TOPICS: Language
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       none.
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       11/05,   SM - written
;-
;-----------------------------------------------------------------
;
PRO mj2_timer_doc_event, sEvent
;
; General widget event where WIDGET_TIMER events are accessed -
; used to control playback rate of frames (vFrameRate). This is
; computed from the FRAME_RATE and TIMESCALE properties of the
; IDLffMJPEG2000 object.

   COMPILE_OPT IDL2, HIDDEN

   ; Get the number of frames and the current frame number.
   WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
   (*pState).oMJ2->GetProperty, N_Frames=nFrames, TIMESCALE=vTimeScale

   ; If the widget had more than one event, the following line would
   ; find timer events.
   IF (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_TIMER') THEN BEGIN

      ; Play all available frames (nFrames). Return the frame period of
      ; each frame to compute the playback rate.
      frameIndex = (*pstate).oMJ2->GetSequentialData(Data, $
         FRAME_PERIOD = vFramePeriod)
      vFrameRate = FLOAT(vFramePeriod)/FLOAT(vTimeScale)

      ; If request for data is too fast, handle return of -1. Repeat
      ; request until return value is not -1 and then repeat previous
      ; steps to access frame period and compute frame rate.
      If frameIndex EQ -1 THEN BEGIN
         REPEAT BEGIN
            ; Get the next frame from the frame buffer.
            frameIndex = (*pState).oMJ2->GetSequentialData(Data, $
               FRAME_PERIOD = vFramePeriod)
             vFrameRate = FLOAT((vFramePeriod)/vTimeScale)
         ENDREP UNTIL (frameIndex NE -1)
      ENDIF ELSE BEGIN

         ; If a frame is available, display it.
         TV, Data

         ; Release the frame and make buffer slot available.
         (*pState).oMJ2->ReleaseSequentialData, frameIndex

         ; Figure frames per second for display in label on widget.
         vFramePerSec =  STRING(1/(vFrameRate))
         strFrameRate = "Frame rate:" + vFramePerSec + " frames/s"

         ; Update timer with current frame rate.
         WIDGET_CONTROL, (*pState).wBase, Timer=vFrameRate
         WIDGET_CONTROL, (*pState).wLabel, SET_VALUE=strFrameRate
      ENDELSE
   ENDIF

   WIDGET_CONTROL, sEvent.TOP, SET_UVALUE=pState

END


;-----------------------------------------------------------------
;
PRO mj2_timer_doc_cleanup, id
;
; Release the frames from the frame buffer and
; shut down the background processing thread.
; Clean up object and pointer.

   WIDGET_CONTROL, id, GET_UVALUE=pState
   Status = (*pState).oMJ2->StopSequentialReading()
   OBJ_DESTROY, (*pState).oMJ2
   PTR_FREE, pState

END

;-----------------------------------------------------------------
;
PRO mj2_timer_doc
;
; Create a MJ2 file containing frames with varying frame period values.
; These values will be passed to the widget timer to control how
; frequently timer events are fired. Therefore, the playback rate
; reflects the rate set for each frame.

   ; Read image data, which contains 57 frames.
   nFrames = 57
   head = READ_BINARY( FILEPATH('head.dat', $
      SUBDIRECTORY=['examples','data']), $
   DATA_DIMS=[80,100, 57])

   ; Create new MJ2 file in the temporary directory.
   file = FILEPATH("mj2_timer_ex.mj2", /TMP)

   ; Create an IDLffMJPEG2000 object.
   oMJ2write=OBJ_NEW('IDLffMJPEG2000', file, /WRITE, /REVERSIBLE)

   ; Write the data of each frame into the MJ2 file.
   ; Set playback characteristics of the frames based on index value.
   ; An increase in vFramePeriod value slows playback when
   ; the TIMESCALE property is constant.
   FOR i=0, nFrames-1 DO BEGIN
      If (i GE 0)  AND (i LE 18) THEN vFramePeriod=1500
      IF (i GE 19) AND (i LE 37) THEN vFramePeriod=4000
      IF (i GE 38) AND (i LE 57) THEN vFramePeriod=10000
      data = CONGRID(head[*,*,i], 240, 300, /INTERP)
      result = oMJ2write->SetData(data, FRAME_PERIOD=vFramePeriod)
   ENDFOR

   ; Commit and close the IDLffMJPEG2000 object.
   return = oMJ2write->Commit(100000)
   OBJ_DESTROY, oMJ2write

   ; Create a new IDLffMJPEG2000 object to access MJ2 file.
   oMJ2=OBJ_NEW("IDLffMJPEG2000", file)
   oMJ2->GetProperty,N_FRAMES=nFrames, DIMENSIONS=dims, $
      FRAME_PERIOD=vFramePeriod, TIMESCALE=vTimeScale

   ; Figure frames per second for display in label on widget.
   vFrameRate = FLOAT(vFramePeriod)/vTimeScale
   vFramePerSec =  STRING(1/(vFrameRate))

   ; Create base and draw widgets.
   wBase = WIDGET_BASE(/COLUMN, TITLE="Simple MJ2 Playback", $
      KILL_NOTIFY='mj2_timer_doc_cleanup', UVALUE='TIMER')
   wDraw = WIDGET_DRAW(wBase, xsize =240, ysize=300)
   strFrameRate = "Frame rate:" + vFramePerSec + " frames/s"
   wLabel = WIDGET_LABEL(wBase, VALUE=strFrameRate)

   ; Realize base and initialize timer.
   WIDGET_CONTROL,/REALIZE, wBase
   WIDGET_CONTROL, wBase, TIMER=vFrameRate

   ; Start reading the frames into the frame buffer in a
   ; background processing thread.
   Status = oMJ2->StartSequentialReading()

   ; Create state structure.
   state = {oMJ2:oMJ2, wBase:wBase, wLabel:wLabel}
   pState = PTR_NEW(state)
   WIDGET_CONTROL, wBase, set_UVALUE=pstate

   XMANAGER, 'mj2_timer_doc', wBase, /NO_BLOCK

END
