;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/context_list_example.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This file provides an example of the use of the context-menu widget
; within a list widget. Context menus are discussed in detail in
; the "Widget Application Techniques" chapter of _Building IDL Applications._
;
; To see the context menu in action, run this program, select an item
; from the list widget, and click the right mouse button.
;
; The example uses a set of event-handler routines to print information
; to IDL's output when items are selected from the context menu. In a
; more realistic situation, the event handler routines would perform
; more sophisticated actions.

; Event handler routine for the "Rotate" buttons on the context menu.
PRO CLE_RotateEvent, event

  COMPILE_OPT hidden

  ; Print a message showing which "rotate" button was pressed.
  WIDGET_CONTROL, event.ID, GET_UVALUE=rvar
  PRINT, ' '
  PRINT, 'Rotate ' + rvar + ' Degrees Pressed'

END

; Event handler routine for the "Shift" buttons on the context menu.
PRO CLE_ShiftEvent, event

  COMPILE_OPT hidden

  ; Print a message showing which "shift" button was pressed.
  WIDGET_CONTROL, event.ID, GET_UVALUE=svar
  PRINT, ' '
  PRINT, 'Shift ' + svar + ' Pressed'

END

; Event handler routine for the "Done" button.
PRO CLE_DoneEvent, event

  COMPILE_OPT hidden

  ; Output that the "Done" button has been pressed.
  PRINT, ' '
  PRINT, 'Done Pressed'
  ; Destroy the top level base.
  WIDGET_CONTROL, event.TOP, /DESTROY

END

; Event handler routine for all events generated by the list widget.
PRO CLE_ListEvents, event

  COMPILE_OPT hidden

  ; If either a left- or right-click occurs, obtain the selection index.
  ; The selection index is then used to determine which context menu to
  ; display. Note that if the user right-clicks on the list widget before
  ; selecting an item with a left-click, the selection index will be -1.
  ; If the user right-clicks on the list widget after selecting an item
  ; with a left-click, the selection index will be that of the selected
  ; list item, not the item on which the user right-clicks.
  selection = WIDGET_INFO(event.ID, /LIST_SELECT)

  ; Print the index of the selected list item.
  PRINT, ' '
  PRINT, 'Selection = ', selection

  ; If the event was a right-click, display the appropriate context menu.
  IF (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_CONTEXT') THEN BEGIN
    ; If "Rotate" is selected,  use the rotate context menu.
    IF (selection EQ 0) THEN BEGIN
      ; Obtain the widget ID of the rotate context menu base.
      contextBase = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'contextRotate')
      ; Display the context menu.
      WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
    ENDIF
    ; If "Shift" is selected,  use the shift context menu.
    IF (selection EQ 1) THEN BEGIN
      ; Obtain the widget ID of the shift context menu base.
      contextBase = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'contextShift')
      ; Display the context menu.
      WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
    ENDIF
  ENDIF

END

; Main Routine: create the GUI.
PRO context_list_example

  ; Create the top level (background) base.
  topLevelBase = WIDGET_BASE(/COLUMN)

  ; Create the list widget, enabling context events.
  list = ['Rotate', 'Shift']
  geometryList = WIDGET_LIST(topLevelBase, VALUE = list, $
    /CONTEXT_EVENTS, EVENT_PRO = 'CLE_ListEvents')

  ; Create the base for the rotate context menu.
  contextRotateBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU, $
    UNAME = 'contextRotate')

  ; Create the buttons of the rotate context menu.
  rotate90Button = WIDGET_BUTTON(contextRotateBase, $
    VALUE = 'Rotate 90 Degrees', UVALUE = '90', EVENT_PRO = 'CLE_RotateEvent')
  rotate180Button = WIDGET_BUTTON(contextRotateBase, $
    VALUE = 'Rotate 180 Degrees', UVALUE = '180', EVENT_PRO = 'CLE_RotateEvent')
  rotate270Button = WIDGET_BUTTON(contextRotateBase, $
    VALUE = 'Rotate 270 Degrees', UVALUE = '270', EVENT_PRO = 'CLE_RotateEvent')
  doneButton = WIDGET_BUTTON(contextRotateBase, VALUE = 'Done', $
    /SEPARATOR, EVENT_PRO = 'CLE_DoneEvent')

  ; Create the base for the shift context menu.
  contextShiftBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU, $
    UNAME = 'contextShift')

  ; Create the buttons of the shift context menu.
  shift025Button = WIDGET_BUTTON(contextShiftBase, $
    VALUE = 'Shift One Quarter', UVALUE = 'One Quarter', $
      EVENT_PRO='CLE_ShiftEvent')
  shift050Button = WIDGET_BUTTON(contextShiftBase, $
    VALUE = 'Shift One Half', UVALUE = 'One Half', $
      EVENT_PRO = 'CLE_ShiftEvent')
  shift075Button = WIDGET_BUTTON(contextShiftBase, $
    VALUE = 'Shift Three Quarter', UVALUE = 'Three Quarters', $
    EVENT_PRO = 'CLE_ShiftEvent')
  doneButton = WIDGET_BUTTON(contextShiftBase, VALUE = 'Done', $
    /SEPARATOR, EVENT_PRO = 'CLE_DoneEvent')

  ; Display the GUI.
  WIDGET_CONTROL, topLevelBase, /REALIZE

  ; Handle the events from the GUI.
  XMANAGER, 'context_list_example', topLevelBase

END

