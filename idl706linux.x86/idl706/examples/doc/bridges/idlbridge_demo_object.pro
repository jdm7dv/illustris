;  $Id:$

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       idlbridge_demo_object.pro
;
;  CALLING SEQUENCE: idlbridge_demo_object
;
;  PURPOSE:
;       Demonstrates the ability to create multiple child processes
;       and abort each independently. In this example, the main process
;       is indicated by the scrolling status bar. The child process is
;       started by clicking Execute. Additional child processes can be
;       created by selecting File -> New Child Process. Each child
;       process is identified by its index number and can be independently
;       started and aborted without affecting other processes.
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
;       2005,   KB
;-
;--------------------------------------------------------------------------------
;
; Create draw window and draw shape in child process in response to
; Execute button press.
PRO panel_idlbridge_demo_object_do_processing, state

   WIDGET_CONTROL, state.wProcess, SENSITIVE=0

   ; Create a window if one does not already exist.
   IF (state.init EQ 0) THEN BEGIN
      state.oIDLBridge->EXECUTE, "WINDOW, XSIZE=300, YSIZE=300, " $
         + "XPOS=" + String(300*(state.index)) + ", YPOS=100," $
         + "TITLE='Process " + STRING(state.index) + "'"
      state.init=1
   ENDIF

   ; Create the shape variable in the child process.
   n=500
   z = BESELJ(SHIFT(DIST(n)*25/n,n/2,n/2),0)
   state.oIDLBridge->SetVar, "shape", TEMPORARY(z)

   ; Call SURFACE in the child process.
   state.oIDLBridge->Execute, "SURFACE, shape, SHADES=BYTSCL(shape)", /NOWAIT

   ; Sensitize the Abort button
   WIDGET_CONTROL, state.wAbort, /SENSITIVE

   ; Reset the timer.
   WIDGET_CONTROL, state.wTimer, TIMER=1

END

;---------------------------------------------------------------------------
; End child process processing.
;
PRO panel_idlbridge_demo_object_abort, oIDLBridge

   oIDLBridge->Abort

END

;---------------------------------------------------------------------------
; Check status of child processes and update UI.
;
PRO panel_idlbridge_demo_object_timer, state

   iStatus = state.oIDLBridge->Status(ERROR=estr)

   CASE iStatus OF
      0: str="Idle"
      1: BEGIN
         str="Executing"
         WIDGET_CONTROL, state.wProcess, SENSITIVE=0
      END
      2: BEGIN
         str="Completed"
         WIDGET_CONTROL, state.wAbort, SENSITIVE=0
         WIDGET_CONTROL, state.wProcess, /SENSITIVE
      END
      3: BEGIN
         str="Error: " + estr
         WIDGET_CONTROL, state.wProcess, /SENSITIVE
         WIDGET_CONTROL, state.wAbort, SENSITIVE=0
      END
      4: BEGIN
         WIDGET_CONTROL, state.wProcess, /SENSITIVE
         WIDGET_CONTROL, state.wAbort, SENSITIVE=0
         str="Aborted"
      END
      ELSE:
   ENDCASE

   ; Update the child process widget UI to show the status.
   WIDGET_CONTROL, state.wStatus, SET_VALUE=str

   ; Reset the timer.
   IF (iStatus GT 0) THEN $
      WIDGET_CONTROL, state.wTimer, TIMER=1

END

;---------------------------------------------------------------------------
; Clean up. The id parameter contains the widget ID of the
; widget that called this procedure.
;
PRO panel_idlbridge_demo_object_die, id

   ; Retrieve state structure for the main widget UI.
   WIDGET_CONTROL, id, GET_UVALUE=state

   ; If the child process is executing, wait for the process to
   ; finish before destroying the bridge object.
   WHILE ((state).oIDLBridge->Status() NE 0) DO WAIT, 0.5
   OBJ_DESTROY, state.oIDLBridge

END

;---------------------------------------------------------------------------
; Event called by child process wrapper base.
;
PRO panel_idlbridge_demo_object_event, sEvent

   ; Retrieve state structure for the child process
   ; widget UI.
   WIDGET_CONTROL, sEvent.handler, GET_UVALUE=state

   ; Retrieve UVALUE of the button pressed.
   WIDGET_CONTROL, sEvent.id, GET_UVALUE=tag

   ; Process the user's request.
   CASE tag OF
      "EXEC": BEGIN
         panel_idlbridge_demo_object_do_Processing, state
         WIDGET_CONTROL, sEvent.handler, SET_UVALUE=state, /NO_COPY
      END
      "ABORT": panel_idlbridge_demo_object_abort, state.oIDLBridge
      "TIMER": panel_idlbridge_demo_object_timer, state
      ELSE:
   ENDCASE

END

;---------------------------------------------------------------------------
; Function called by File -> New Child Process to create new child process.
; Initializes an IDL_IDLBridge object and adds process controls to main UI.
;
FUNCTION panel_idlbridge_demo_object, wParent, number

   ; Add a new line to the main widget UI.
   wWrapper = WIDGET_BASE(wParent, /ROW, $
      EVENT_PRO="panel_idlbridge_demo_object_event", $
      KILL_NOTIFY='panel_idlbridge_demo_object_die')
   wProcess = WIDGET_BUTTON(wWrapper, VALUE='Execute', $
      UVALUE='EXEC')
   wAbort = WIDGET_BUTTON(wWrapper, VALUE='Abort', $
      UVALUE='ABORT', SENSITIVE=0)
   wTimer = WIDGET_LABEL(wWrapper, VALUE='Status', $
      UVALUE='TIMER')
   wStatus = WIDGET_TEXT(wWrapper, VALUE='Idle', XSIZE=20)

   ; Create a new IDL_IDLBridge object.
   oIDLBridge = OBJ_NEW("IDL_IDLBridge")
   IF (~OBJ_VALID(oIDLBridge)) THEN BEGIN
      void=DIALOG_MESSAGE(/ERROR,'Unable to create an IDL_IDLBridge session')
      WIDGET_CONTROL, wWrapper, /DESTROY
      RETURN, 0l
   ENDIF

   ; Save information about widgets and bridge object in
   ; a state structure.
   WIDGET_CONTROL, wWrapper, SET_UVALUE= $
    {oIDLBridge:oIDLBridge, index:number, wAbort:wAbort, $
     wTimer:wTimer, wStatus:wStatus, wProcess:wProcess, init:0}

   RETURN, wWrapper

END

;---------------------------------------------------------------------------
; General event called by XMANAGER. This captures menu choices and updates
; the scrolling progress indicator.
;
PRO idlbridge_demo_object_event, sEvent

   WIDGET_CONTROL, sEvent.id, GET_UVALUE=tag
   WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
   CASE tag OF
      'DRAW': BEGIN
         ; Update the progress indicator
         (*pState).xpos = ((*pState).xpos +5) MOD 300
         ERASE, 255
         POLYFILL, (*pState).xpos+[0,0,5,5], $
            [0, 19, 19,0], /DEVICE, color=140
         WIDGET_CONTROL, sEvent.id, TIMER=.2
      END
      'EXIT': WIDGET_CONTROL, sEvent.top, /DESTROY
      'NEW': BEGIN
         void = panel_idlbridge_demo_object(sEvent.top, (*pState).index)
         (*pState).index++
      END
      ELSE:
   ENDCASE

END

;---------------------------------------------------------------------------
; Create the main widget UI and an initial IDL_IDLBridge object.
;
pro idlbridge_demo_object

   ; Top-level base to contain widget UI in the main IDL process.
   wTLB = WIDGET_BASE(TITLE="IDL_IDLBridge Demo", MBAR=wMenu, $
      /COLUMN, XOFFSET=10 )

   ; File Menu.
   wFile = WIDGET_BUTTON(wMenu, /MENU, VALUE="File")

   wNew = WIDGET_BUTTON(wFile, VALUE="New Child Process", UVALUE="NEW")
   wExit = WIDGET_BUTTON(wFile, VALUE="Exit", UVALUE="EXIT", /SEPARATOR)

   ; Draw widget for the progress indicator.
   wDraw = WIDGET_DRAW(wTLB, XSIZE=300, YSIZE=20, UVALUE="DRAW")

   ; Call function to create initial IDL_IDLBridge object.
   void = panel_idlbridge_demo_object(wTLB, 0)

   ; Store state information.
   state = {index:1, xpos:0}
   WIDGET_CONTROL, wTLB, /REALIZE, SET_UVALUE=PTR_NEW(state)

   ; Color table to use when drawing progress indicator.
   DEVICE, DECOMPOSE=0
   LOADCT, 39

   ; Implement timer event each second.
   WIDGET_CONTROL, wDraw, TIMER=1

   ; Manage the widget application.
   XMANAGER,'idlbridge_demo_object', wTLB, /NO_BLOCK

END
