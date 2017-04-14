;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/table_widget_example1.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This file provides an example of the use of the table widget.
; Table widgets are discussed in detail in the "Widget Application
; Techniques" chapter of _Building IDL Applications._

; Event-handler routine
PRO table_widget_example1_event, ev

  COMPILE_OPT hidden

  ; Retrieve the anonymous structure contained in the user value of
  ; the top-level base widget. 
  WIDGET_CONTROL, ev.top, GET_UVALUE=stash

  ; Retrieve the table's selection mode and selection.
  disjoint = WIDGET_INFO(stash.table, /TABLE_DISJOINT_SELECTION)
  selection = WIDGET_INFO(stash.table, /TABLE_SELECT)

  ; Check to see whether a selection exists, setting the
  ; variable 'hasSelection' accordingly.
  IF (selection[0] ne -1) THEN hasSelection = 1 $
    ELSE hasSelection = 0

  ; If there is a selection, get the value.
  IF (hasSelection) THEN WIDGET_CONTROL, stash.table, GET_VALUE=value, $
    /USE_TABLE_SELECT

  ; The following sections define the application's reactions to
  ; various types of events.

  ; If the event came from the table widget, plot the selected data.
  IF ((ev.ID eq stash.table) AND hasSelection) THEN BEGIN
    WSET, stash.draw
    PLOT, value
  ENDIF

  ; If the event came from the 'Show Selected Data' button, display
  ; the data in the text widget.
  IF ((ev.ID eq stash.b_value) AND hasSelection) THEN BEGIN
    IF (disjoint eq 0) THEN BEGIN
      WIDGET_CONTROL, stash.text, SET_VALUE=STRING(value, /PRINT)
    ENDIF ELSE BEGIN
      WIDGET_CONTROL, stash.text, SET_VALUE=STRING(value)
    ENDELSE
  ENDIF

  ; If the event came from the 'Show Selected Cells' button, display
  ; the selection information in the text widget. Use different
  ; displays for standard and disjoint selections.
  IF ((ev.ID eq stash.b_select) AND hasSelection) THEN BEGIN
    IF (disjoint eq 0) THEN BEGIN
      ; Create a string array containing the column and row
      ; values of the selected rectangle.
      list0 = 'Standard Selection'
      list1 = 'Left:   ' + STRING(selection[0])
      list2 = 'Top:    ' + STRING(selection[1])
      list3 = 'Right:  ' + STRING(selection[2])
      list4 = 'Bottom: ' + STRING(selection[3])
      list = [list0, list1, list2, list3, list4]
    ENDIF ELSE BEGIN
      ; Create a string array containing the column and row
      ; information for the selected cells.
      n = N_ELEMENTS(selection)
      list = STRARR(n/2+1)
      list[0] = 'Disjoint Selection'
      FOR j=0,n-1,2 DO BEGIN
        list[j/2+1] = 'Column: ' + STRING(selection[j]) + $
           ', Row: ' + STRING(selection[j+1])
      ENDFOR
    ENDELSE
    WIDGET_CONTROL, stash.text, SET_VALUE=list
  ENDIF

  ; If the event came from the 'Change Selection Mode' button,
  ; change the table selection mode and the title of the button.
  IF (ev.ID eq stash.b_change) THEN BEGIN
    IF (disjoint eq 0) THEN BEGIN
      WIDGET_CONTROL, stash.table, TABLE_DISJOINT_SELECTION=1
      WIDGET_CONTROL, stash.b_change, $
        SET_VALUE='Change to Standard Selection Mode'
    ENDIF ELSE BEGIN
      WIDGET_CONTROL, stash.table, TABLE_DISJOINT_SELECTION=0
      WIDGET_CONTROL, stash.b_change, $
        SET_VALUE='Change to Disjoint Selection Mode'
    ENDELSE
  ENDIF

  ; If the event came from the 'Quit' button, close the application.
  IF (ev.ID eq stash.b_quit) THEN WIDGET_CONTROL, ev.TOP, /DESTROY

END

; Widget creation routine.
PRO table_widget_example1

  ; Create data to be displayed in the table.
  data = DIST(7)

  ; Create initial text to be displayed in the text widget.
  help = ['Select data from the table below using the mouse.']

  ; Create the widget hierarchy.
  base = WIDGET_BASE(/COLUMN)
  subbase1 = WIDGET_BASE(base, /ROW)
  draw = WIDGET_DRAW(subbase1, XSIZE=250, YSIZE=250)
  subbase2 = WIDGET_BASE(subbase1, /COLUMN)
  text = WIDGET_text(subbase2, XS=50, YS=8, VALUE=help, /SCROLL)
  b_value = WIDGET_BUTTON(subbase2, VALUE='Show Selected Data')
  b_select = WIDGET_BUTTON(subbase2, VALUE='Show Selected Cells')
  b_change = WIDGET_BUTTON(subbase2, $
    VALUE='Change to Disjoint Selection Mode')
  b_quit = WIDGET_BUTTON(subbase2, VALUE='Quit')
  table = WIDGET_TABLE(base, VALUE=data, /ALL_EVENTS)

  ; Realize the widgets.
  WIDGET_CONTROL, base, /REALIZE

  ; Get the widget ID of the draw widget.
  WIDGET_CONTROL, draw, GET_VALUE=drawID

  ; Create an anonymous structure to hold widget IDs. This
  ; structure becomes the user value of the top-level base
  ; widget.
  stash = {draw:drawID, table:table, text:text, b_value:b_value, $
           b_select:b_select, b_change:b_change, b_quit:b_quit}
  
  ; Set the user value of the top-level base and call XMANAGER
  ; to manage everything.
  WIDGET_CONTROL, base, SET_UVALUE=stash
  XMANAGER, 'table_widget_example1', base

END

