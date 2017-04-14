;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example4_panel.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example4_panel
;
; PURPOSE:
;   Example user interface panel definition. See "Creating
;   a User Interface Panel" in the iTool Developer's Guide
;   for a complete description of this
;
; CATEGORY:
;   iTools
;   
;-
;
PRO Example4_panel_callback, wPanel, strID, messageIn, component

   ; Make sure we have a valid widget ID.
   IF ~ WIDGET_INFO(wPanel, /VALID) THEN RETURN

   ; Retrieve the widget ID of the first child widget of
   ; the UI panel.
   wChild = WIDGET_INFO(wPanel, /CHILD)

   ; Retrieve the state structure from the user value of
   ; the first child widget.
   WIDGET_CONTROL, wChild, GET_UVALUE = state
   
   ; Process as necessary, depending on the message received.
   SWITCH STRUPCASE(messageIn) OF
   
      ; This section handles messages generated when the rotate
      ; operation becomes available or unavailable, and sensitizes
      ; or desensitizes the "Rotate" button accordingly.
      'SENSITIVE':
      'UNSENSITIVE': BEGIN
         WIDGET_CONTROL, state.wRotate, $
            SENSITIVE = (messageIn EQ 'SENSITIVE')
         BREAK
      END

      ; This section handles messages generated when the
      ; item selected in the iTool window changes and changes
      ; the sensitivity of the "Hide/Show" and "Rotate" buttons
      ; accordingly.
      'SELECTIONCHANGED': BEGIN
         ; Retrieve the item that was selected last, which is
         ; stored in the first element of the returned array.
         oSel = state.oTool->GetSelectedItems()
         oSel = oSel[0]
         ; If the last item selected is not a visualization, 
         ; desensitize the "Hide/Show" and "Rotate" buttons.
         IF (~OBJ_ISA(oSel, 'IDLITVISUALIZATION')) THEN BEGIN
            WIDGET_CONTROL, state.wHide, SENSITIVE = 0
            WIDGET_CONTROL, state.wRotate, SENSITIVE = 0
         ENDIF ELSE BEGIN
         ; If the selected object is a visualization, sensitize
         ; the "Hide/Show" and "Rotate" buttons.
            WIDGET_CONTROL, state.wHide, SENSITIVE = 1
            WIDGET_CONTROL, state.wRotate, SENSITIVE = 1
         ENDELSE
         BREAK
      END
      ELSE:
   ENDSWITCH
   
END


PRO Example4_panel_event, event

   ; Retrieve the widget ID of the first child widget of
   ; the UI panel.
   wChild = WIDGET_INFO(event.handler, /CHILD)

   ; Retrieve the state structure from the user value of
   ; the first child widget.
   WIDGET_CONTROL, wChild, GET_UVALUE = state

   ; Retrieve the user value of the widget that generated
   ; the event.
   WIDGET_CONTROL, event.id, GET_UVALUE = uvalue

   ; Now do the work for each panel item.
   SWITCH STRUPCASE(uvalue) OF
      'ROTATE': BEGIN
         ; Apply the Rotate Left operation to the selected item.
         success = state.oUI->DoAction(state.idRotate)
         RETURN
      END
      'HIDE': BEGIN
         ; Hide the selected item.
         ;
         oTargets = state.oTool->GetSelectedItems(count = nTarg)
         IF nTarg GT 0 THEN BEGIN
            ; If there are selected items, use only the last item
            ; selected, which is stored in the first element of
            ; the returned array.
            oTarget = oTargets[0]
            ; Get the iTool identifier of the selected item.
            name = oTarget->GetFullIdentifier()
            ; Retrive the setting of the HIDE property.
            oTarget->GetProperty, HIDE = hide
            ; Change the value of the HIDE property from 0 to 1
            ; or from 1 to 0. Use the DoSetProperty and
            ; CommitActions method to ensure that the change
            ; is entered into the undo/redo transaction buffer.
            void = state.oTool->DoSetProperty(name, "HIDE", $
               ((hide+1) MOD 2))
            state.oTool->CommitActions
         ENDIF
         BREAK
      END
      ELSE:
   ENDSWITCH

   ; Refresh the iTool window.
   state.oTool->RefreshCurrentWindow

END



PRO Example4_panel, wPanel, oUI

   ; Set the title used on the panel's tab.
   WIDGET_CONTROL, wPanel, BASE_SET_TITLE = 'Example Panel'

   ; Specify the event handler
   WIDGET_CONTROL, wPanel, EVENT_PRO = "Example4_panel_event"

   ; Register the panel with the user interface object.
   strObserverIdentifier = oUI->RegisterWidget(wPanel, "Panel", $
      'Example4_panel_callback')
   ; Register to receive selection events on visualizations.
   oUI->AddOnNotifyObserver, strObserverIdentifier, $
      'Visualization'
   
   ; Retrieve a reference to the current iTool.
   oTool = oUI->GetTool()

   ; Create a base widget to hold the contents of the panel.
   wBase = WIDGET_BASE(wPanel, /COLUMN, SPACE = 5, /ALIGN_LEFT)
   
   ; Create panel contents.
   wLabel = WIDGET_LABEL(wBase, VALUE = "Choose an Action:", $
      /ALIGN_LEFT)
   
   ; Get the Operation ID of the rotate operation. If the operation
   ; exists, create the "Rotate Item" button and monitor whether
   ; the operation is available for the selected item.
   opID = 'Operations/Operations/Rotate/RotateLeft'
   oRotate = oTool->GetByIdentifier(opID)

   IF (OBJ_VALID(oRotate)) THEN BEGIN
      idRotate = oRotate->GetFullIdentifier()
      wRotate = WIDGET_BUTTON(wBase, VALUE = "Rotate Item", $
         UVALUE="ROTATE")
      ; Monitor for availablity of the Rotate operation.
      oUI->AddOnNotifyObserver, strObserverIdentifier, idRotate
   ENDIF ELSE $
   idRotate = 0

   wHide = WIDGET_BUTTON(wBase, VALUE = "Show/Hide Item", $
      UVALUE = "HIDE")

   ; Pack up the state structure and store in first child.
   state = {oTool:oTool, $         
            oUI:oUI, $
            idRotate : idRotate, $
            wPanel:wPanel, $
            wBase:wBase, $
            wRotate:wRotate, $
            wHide:wHide $
          }
   wChild = WIDGET_INFO(wPanel, /CHILD)

   IF wChild NE 0 THEN $
      WIDGET_CONTROL, wChild, SET_UVALUE = state, /NO_COPY

END

