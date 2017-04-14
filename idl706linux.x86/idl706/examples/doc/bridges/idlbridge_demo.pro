;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/idlbridge_demo.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       idlbridge_demo.pro
;
;  CALLING SEQUENCE: idlbridge_demo
;
;  PURPOSE:
;       Demonstrates the ability to create multiple child processes
;       and abort each independently. In this example, the parent process
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
; The callback procedure is automatically called when the child process
; is completed, aborted, or ends due to an error.
PRO demo_bridge_call, status, error, oBridge, userdata

   ; Access state data.
   state = userdata

   ; When execution ends, desensitize Abort button and
   ; sensitize Process Image button.
   WIDGET_CONTROL, state.wAbort, SENSITIVE=0
   WIDGET_CONTROL, state.wProcess, /SENSITIVE

   ; Write out status, manually setting standard IDL_IDLBridge
   ; status values.
   CASE status of
      2: str="Completed"
      3: str="Error: " + error
      4: str=error ; Aborted message
   ENDCASE

   ; Update status message.
   WIDGET_CONTROL, state.wStatus, SET_VALUE=str

END

;---------------------------------------------------------------------------
; Create draw window and draw shape in child process in response to
; Execute button press or Abort if event is from a WIDGET_BUTTON. 
PRO panel_idlbridge_demo_event, sEvent

   WIDGET_CONTROL, sEvent.HANDLER, GET_UVALUE=state

   ; If Execute button event, create plot window if needed or draw plot
   ; in existing window. If Abort button event, end child processing.
   IF (TAG_NAMES(sEvent, /STRUCTURE) EQ 'WIDGET_BUTTON') THEN BEGIN

      WIDGET_CONTROL, sEvent.ID, GET_UVALUE=tag

      CASE tag OF
         "EXEC": BEGIN
            ; Create a window if one does not already exist.
            IF (state.init EQ 0) THEN BEGIN
               state.oBridge->Execute, "WINDOW, XSIZE=300, YSIZE=300, " $
               + "XPOS=" + String(300*(state.index)) + ", YPOS=100," $
               + "TITLE='Process " + STRING(state.index) + "'"
               state.init=1
            ENDIF

            ; Create the shape variable in the child process.
            n=500
            z = BESELJ(SHIFT(DIST(n)*25/n,n/2,n/2),0)
            state.oBridge->SetVar, "shape", TEMPORARY(z)

            ; Call SURFACE in the child process.
            state.oBridge->Execute, "SURFACE, shape, SHADES=BYTSCL(shape)", /NOWAIT

            ; Sensitize the Abort button
            WIDGET_CONTROL, state.wAbort, /SENSITIVE
            ;Update object status
            status = state.oBridge->Status()
            IF status EQ 1 THEN BEGIN
               WIDGET_CONTROL, state.wStatus, SET_VALUE="Executing"
               WIDGET_CONTROL, state.wProcess, SENSITIVE=0
            ENDIF

         END
         "ABORT": state.oBridge->ABORT
         ELSE:
      ENDCASE
   ENDIF

END

;---------------------------------------------------------------------------
; Clean up. The id parameter contains the widget ID of the
; widget that called this procedure.
;
PRO panel_idlbridge_demo_die, id

   ; Clean up pointers and object references.
   WIDGET_CONTROL, id, GET_UVALUE=state
   parent=WIDGET_INFO(id, /PARENT)
   WIDGET_CONTROL, parent, GET_UVALUE=pstate
   PTR_FREE, pstate
   OBJ_DESTROY, state.oBridge

END

;---------------------------------------------------------------------------
; Function called by File -> New Child Process to create new child process.
; Initializes an IDL_IDLBridge object and adds process controls to main UI.
;
FUNCTION panel_idlbridge_demo, wParent, number

   ; Add a new line to the main widget UI.
   wWrapper = WIDGET_BASE(wParent, /ROW, $
      EVENT_PRO="panel_idlbridge_demo_event", $
      KILL_NOTIFY="panel_idlbridge_demo_die")
   wProcess = WIDGET_BUTTON(wWrapper, VALUE='Execute', $
      UVALUE='EXEC')
   wAbort = WIDGET_BUTTON(wWrapper, VALUE='Abort', $
      UVALUE='ABORT', SENSITIVE=0)
   wLabel = WIDGET_LABEL(wWrapper, VALUE='Status')
   wStatus = WIDGET_TEXT(wWrapper, VALUE='Idle', XSIZE=20)

   ; Initialize the bridge object and define the callback
   ; routine that is automatically called when process status
   ; is complete, aborted, or halts due to an error.
   oBridge = OBJ_NEW('IDL_IDLBridge', CALLBACK='demo_bridge_call')

   ; Save information about widgets and bridge object in
   ; a state structure.
   state = {oBridge:oBridge, index:number, wProcess:wProcess, $
        wAbort:wAbort, wStatus:wStatus, init:0}
   WIDGET_CONTROL, wWrapper, SET_UVALUE= state

   ; Store the state structure in USERDATA property in order
   ; to access it in the callback routine.
   oBridge->SetProperty, USERDATA=state

   RETURN, wWrapper

END

;---------------------------------------------------------------------------
; General event called by XMANAGER. This captures menu choices and updates
; the scrolling progress indicator.
;
PRO idlbridge_demo_event, sEvent

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
         void = panel_idlbridge_demo(sEvent.top, (*pState).index)
         (*pState).index++
      END
      ELSE:
   ENDCASE

END

;---------------------------------------------------------------------------
; Create the main widget UI and an initial IDL_IDLBridge object.
;
pro idlbridge_demo

   ; Top-level base to contain widget UI in the main IDL process.
   wTLB = WIDGET_BASE(TITLE="IDL_IDLBridge Demo", MBAR=wMenu, $
      /COLUMN, XOFFSET=10)

   ; File Menu.
   wFile = WIDGET_BUTTON(wMenu, /MENU, VALUE="File")

   wNew = WIDGET_BUTTON(wFile, VALUE="New Child Process", UVALUE="NEW")
   wExit = WIDGET_BUTTON(wFile, VALUE="Exit", UVALUE="EXIT", /SEPARATOR)

   ; Draw widget for the progress indicator.
   wDraw = WIDGET_DRAW(wTLB, XSIZE=300, YSIZE=20, UVALUE="DRAW")

   ; Call function to create initial IDL_IDLBridge object.
   void = panel_idlbridge_demo(wTLB, 0)

   ; Store state information.
   state = {index:1, xpos:0}
   WIDGET_CONTROL, wTLB, /REALIZE, SET_UVALUE=PTR_NEW(state)

   ; Color table to use when drawing progress indicator. Initialize
   ; timer for scrolling draw window.
   DEVICE, DECOMPOSE=0
   LOADCT, 39
   WIDGET_CONTROL, wDraw, TIMER=0

   ; Manage the widget application.
   XMANAGER,'idlbridge_demo', wTLB, /NO_BLOCK

END
