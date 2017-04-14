;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/animation_image_doc.pro#2 $

; Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   animation_image_doc
;
; PURPOSE:
;   Create a simple animation display in a window that
;   cycles through a series of images.
;
; CATEGORY:
;   Objects
;
;-
;;---------------------------------------------------------------------------------------
; Define the animation behavior object class (MyAnimation),
; which increments the frame number so that the image frames
; are displayed and drawn sequentially.

FUNCTION MyAnimation::Init, oAnimationModel
   self.oAnimationModel = oAnimationModel
   RETURN, 1
END

PRO MyAnimation::Cleanup
END

PRO MyAnimation::OnTimer, oWin

   ; Add one to the current frame number.
   self.currentFrame++

    ; Iterate through the image frames. Define the frame to display
   ; by setting the ACTIVE_POSTION property on the model.
   IF self.currentFrame GE self.oAnimationModel->Count() THEN $
      self.currentFrame = 0
   self.oAnimationModel->SetProperty, ACTIVE_POSITION=self.currentFrame

   ; Draw the scene.
   oWin->Draw
END

PRO MyAnimation__define
   void = {MyAnimation, $
           oAnimationModel: OBJ_NEW(), $
           currentFrame: 0L $
          }
END

;;---------------------------------------------------------------------------------------
PRO animation_image_doc

; Read image data, which contains 57 frames.
nFrames = 57
head = READ_BINARY( FILEPATH('head.dat', $
  SUBDIRECTORY=['examples','data']), $
  DATA_DIMS=[80,100, 57])

; Create main-level view and model objects.
oView = OBJ_NEW('IDLgrView',  $
                    VIEWPLANE_RECT=[0,0,80, 100])
oModel = OBJ_NEW('IDLgrModel')
oView->Add, oModel

; Create the model that supports animation. Add each image
; to the animation model, and add the animation model to the
; main-level model.
oAnimationModel = OBJ_NEW('IDLgrModel', RENDER_METHOD=1)
oModel->Add, oAnimationModel
FOR i=0, nFrames-1 do begin
   oAnimationModel->Add, OBJ_NEW('IDLgrImage', head[*,*,i], /INTERP)
ENDFOR

; Create the window object and add the view.
oWin = OBJ_NEW('IDLitWindow', DIMENSIONS=[300,300], $
   TITLE="Simple Animation")
oWin->Add, oView

; Create a custom animation object, and initialize with
; the animation model. Add the new object to the list
; of window observers, and set the display rate.
oAnimBehavior = OBJ_NEW('MyAnimation', oAnimationModel)
oWin->AddWindowEventObserver, oAnimBehavior
oWin->SetTimerInterval, 0.1

; Play the animation.
oWin->SetEventMask, /TIMER_EVENTS

End