;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/tree_widget_example.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Widget Application Techniques"
; chapter of the _Building IDL Applications_ manual.
;
; This example creates a simple tree widget. Clicking on a leaf node
; toggles the text of the display to read either 'On' or 'Off'. This
; is not particularly useful, but serves as an example of how you
; might accomplish something more complicated.

; Event handler routine.
PRO tree_widget_example_event, ev

  COMPILE_OPT hidden

  ; We use widget user values to determine what action to take.
  ; First retrieve the user value (if any) from the widget that
  ; generated the event.

  WIDGET_CONTROL, ev.ID, GET_UVALUE=uName

  ; If the widget that generated the event has a user value, check
  ; its value and take the appropriate action.
  IF (N_ELEMENTS(uName) NE 0) THEN BEGIN
    IF (uName EQ 'LEAF') THEN BEGIN
      ; Make sure the value does not change when the leaf node
      ; is selected with a single click.
      IF (ev.CLICKS EQ 2) THEN TWE_ToggleValue, ev.ID
    ENDIF
    IF (uName EQ 'DONE') THEN WIDGET_CONTROL, ev.TOP, /DESTROY
  ENDIF

END

; Routine to change the value of a leaf node's text.
PRO TWE_ToggleValue, widID

  COMPILE_OPT hidden

  ; Get the current value.
  WIDGET_CONTROL, widID, GET_VALUE=curVal

  ; Split the string at the colon character.
  full_string = STRSPLIT(curVal, ':', /EXTRACT)

  ; Check the value of the text after the colon, and toggle
  ; to the new value.
  full_string[1] = (full_string[1] EQ ' Off') ? ': On' : ': Off'

  ; Reset the value of the leaf node's text.
  WIDGET_CONTROL, widID, SET_VALUE=STRJOIN(full_string)

END

; Widget creation routine.
PRO tree_widget_example

  ; Start with a base widget.
  wTLB = WIDGET_BASE(/COLUMN, TITLE='Tree Example')

  ; The first tree widget has the top-level base as its parent.
  ; The visible tree widget branches and leaves will all be
  ; descendants of this tree widget.
  wTree = WIDGET_TREE(wTLB)

  ; Place a folder at the root level of the visible tree.
  wtRoot = WIDGET_TREE(wTree, VALUE='Root', /FOLDER, /EXPANDED)

  ; Create leaves and branches. Note that we set the user value of
  ; every leaf node (tree widgets that do not have the FOLDER keyword
  ; set) equal to 'LEAF'. We use this in the event handler to determine
  ; whether or not to change the text value.
  wtLeaf11 = WIDGET_TREE(wtRoot, VALUE='Setting 1-1: Off', $
    UVALUE='LEAF')
  wtBranch12 = WIDGET_TREE(wtRoot, VALUE='Branch 1-2', $
    /FOLDER, /EXPANDED)
  wtLeaf121 = WIDGET_TREE(wtBranch12, VALUE='Setting 1-2-1: Off', $
    UVALUE='LEAF')
  wtLeaf122 = WIDGET_TREE(wtBranch12, VALUE='Setting 1-2-2: Off', $
    UVALUE='LEAF')
  wtLeaf13 = WIDGET_TREE(wtRoot, VALUE='Setting 1-3: Off', $
    UVALUE='LEAF')
  wtLeaf14 = WIDGET_TREE(wtRoot, VALUE='Setting 1-4: Off', $
    UVALUE='LEAF')

  ; Create a 'Done' button, setting its user value for use in the
  ; event handler.
  wDone = WIDGET_BUTTON(wTLB, VALUE="Done", UVALUE='DONE')

  ; Realize the widgets and run XMANAGER to manage them.
  WIDGET_CONTROL, wTLB, /REALIZE
  XMANAGER, 'tree_widget_example', wTLB, /NO_BLOCK

END

