;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/context_tlbase_example.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This file provides an example of the use of the context-menu widget
; within a base widget. Context menus are discussed in detail in
; the "Widget Application Techniques" chapter of _Building IDL Applications._
;
; To see the context menu in action, run this program and click the
; right mouse button on the empty base widget that is displayed.
;
; The example uses a set of event-handler routines to print information
; to IDL's output when items are selected from the context menu. In a
; more realistic situation, the event handler routines would perform
; more sophisticated actions.


; Event handler routine for the "Selection 1" button on the context menu.
PRO CBE_FirstEvent, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Selection 1 Pressed'
END

; Event handler routine for the "Selection 2" button on the context menu.
PRO CBE_SecondEvent, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Selection 2 Pressed'
END

; Event handler routine for the "Done" button on the context menu.
PRO CBE_DoneEvent, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Done Pressed'
  ; Destroy the top level base.
  WIDGET_CONTROL, event.TOP, /DESTROY
END

; Event handler routine for the context menu itself. This routine
; is called when the user right-clicks on the base widget.
PRO context_tlbase_example_event, event

  COMPILE_OPT hidden

  ; Obtain the widget ID of the context menu base.
  contextBase = WIDGET_INFO(event.ID, FIND_BY_UNAME = 'contextMenu')

  ; Display the context menu and send its events to the
  ; other event handler routines.
  WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
END

; Main Routine: create the GUI.
PRO context_tlbase_example

  ; Initialize the top level (background) base. This base
  ; is configured to generate context events, allowing the user
  ; to right-click on the base to display a context menu.
  topLevelBase = WIDGET_BASE(/COLUMN, XSIZE = 100, YSIZE = 100, /CONTEXT_EVENTS)

  ; Initialize the base for the context menu.
  contextBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU, UNAME = 'contextMenu')

  ; Initialize the buttons of the context menu.
  firstButton = WIDGET_BUTTON(contextBase, $
    VALUE = 'Selection 1', EVENT_PRO = 'CBE_FirstEvent')
  secondButton = WIDGET_BUTTON(contextBase, $
    VALUE = 'Selection 2', EVENT_PRO = 'CBE_SecondEvent')
  doneButton = WIDGET_BUTTON(contextBase, VALUE = 'Done', $
    /SEPARATOR, EVENT_PRO = 'CBE_DoneEvent')

  ; Display the GUI.
  WIDGET_CONTROL, topLevelBase, /REALIZE

  ; Handle the events from the GUI.
  XMANAGER, 'context_tlbase_example', topLevelBase

END

