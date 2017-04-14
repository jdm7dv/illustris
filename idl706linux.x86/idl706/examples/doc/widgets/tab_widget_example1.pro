;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/tab_widget_example1.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Widget Application Techniques"
; chapter of the _Building IDL Applications_ manual.
;

; Event-handler routine
;
PRO tab_widget_example1_event, ev

  COMPILE_OPT hidden

  ; Retrieve the anonymous structure contained in the user value of
  ; the top-level base widget. 
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash

  ; If the user clicked the 'Done' button, destroy the widgets.
  IF (ev.ID EQ stash.bDone) THEN WIDGET_CONTROL, ev.TOP, /DESTROY

END

; Widget creation routine.
PRO tab_widget_example1, LOCATION=location

  ; Create the top-level base and the tab.
  wTLB = WIDGET_BASE(/COLUMN, /BASE_ALIGN_TOP)
  wTab = WIDGET_TAB(wTLB, LOCATION=location)

  ; Create the first tab base, containing a label and two
  ; button groups.
  wT1 = WIDGET_BASE(wTab, TITLE='TAB 1', /COLUMN)
  wLabel = WIDGET_LABEL(wT1, VALUE='Choose values')
  wBgroup1 = CW_BGROUP(wT1, ['one', 'two', 'three'], $
    /ROW, /NONEXCLUSIVE, /RETURN_NAME)
  wBgroup2 = CW_BGROUP(wT1, ['red', 'green', 'blue'], $
    /ROW, /EXCLUSIVE, /RETURN_NAME)

  ; Create the second tab base, containing a label and
  ; a slider.
  wT2 = WIDGET_BASE(wTab, TITLE='TAB 2', /COLUMN)
  wLabel = WIDGET_LABEL(wT2, VALUE='Move the Slider')
  wSlider = WIDGET_SLIDER(wT2)

  ; Create the third tab base, containing a label and
  ; a text-entry field.
  wT3 = WIDGET_BASE(wTab, TITLE='TAB 3', /COLUMN)
  wLabel = WIDGET_LABEL(wT3, VALUE='Enter some text')
  wText= WIDGET_TEXT(wT3, /EDITABLE, /ALL_EVENTS)

  ; Create a base widget to hold the 'Done' button, and
  ; the button itself.
  wControl = WIDGET_BASE(wTLB, /ROW)
  bDone = WIDGET_BUTTON(wControl, VALUE='Done')

  ; Create an anonymous structure to hold widget IDs. This
  ; structure becomes the user value of the top-level base
  ; widget.
  stash = { bDone:bDone }

  ; Realize the widgets, set the user value of the top-level
  ; base, and call XMANAGER to manage everything.
  WIDGET_CONTROL, wTLB, /REALIZE
  WIDGET_CONTROL, wTLB, SET_UVALUE=stash
  XMANAGER, 'tab_widget_example1', wTLB, /NO_BLOCK

END

