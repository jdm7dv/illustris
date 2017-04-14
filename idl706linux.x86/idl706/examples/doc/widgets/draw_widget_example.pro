;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/draw_widget_example.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Widget Application Techniques"
; chapter of the _Building IDL Applications_ manual.
;
PRO draw_widget_example_event, ev

  COMPILE_OPT hidden

  ; We need to save the value of the seed variable for the random
  ; number generator between calls to the event-handling routine.
  ; We do this using a COMMON block.

  COMMON dwe, seed

  ; Retrieve the anonymous structure contained in the user value of
  ; the top-level base widget. This structure contains the following
  ; fields:
  ;   drawID:    the widget ID of the draw widget
  ;   labelID:   the widget ID of the label widget that will hold
  ;              the color table name.
  ;   sel_index: the index of the current selection in the droplist
  ;   ctable:    the index of the current color table.

  WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash

  ; Set the draw widget as the current IDL drawable.

  WSET, stash.drawID

  ; Check the type of event structure returned. If it is a timer
  ; event, change the color table index to a random number between
  ; 0 and 40, then set the value of the label widget to the name of
  ; the new color table.

  IF (TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_TIMER') THEN BEGIN
    LOADCT, GET_NAMES=ctnames
    stash.ctable = FIX(RANDOMU(seed)*41)
    LOADCT, stash.ctable, /SILENT
    WIDGET_CONTROL, stash.labelID, $
      SET_VALUE='Color Table: ' + ctnames[stash.ctable]
    WIDGET_CONTROL, ev.ID, TIMER=3.0
  ENDIF

  ; If the event is a droplist event, change the value of the
  ; variable 'selection' to the new index value.

  IF (TAG_NAMES(ev, /STRUCTURE_NAME) EQ 'WIDGET_DROPLIST') $
    THEN BEGIN
    stash.sel_index=ev.index
  ENDIF

  ; Reset the user value of the top-level base widget to the modified
  ; stash structure.

  WIDGET_CONTROL, ev.TOP, SET_UVALUE=stash

  ; Display a plot, surface, or shaded surface, or destroy the widget
  ; application, depending on the value of the 'selection' variable.

  CASE stash.sel_index OF
    0: PLOT, DIST(150)
    1: SURFACE, DIST(150)
    2: SHADE_SURF, DIST(150)
    3: WIDGET_CONTROL, ev.TOP, /DESTROY
  ENDCASE

END

PRO draw_widget_example

  ; Define the values for the droplist widget and define the
  ; initially selected index to show a shaded surface.
  select = ['Plot', 'Surface', 'Shaded Surface', 'Done']
  sel_index = 2

  ; Create a base widget containing a draw widget and a sub-base
  ; containing a droplist menu and a label widget.
  base = WIDGET_BASE(/COLUMN)
  draw = WIDGET_DRAW(base, XSIZE=350, YSIZE=350)
  base2 = WIDGET_BASE(base, /ROW)
  dlist = WIDGET_DROPLIST(base2, VALUE=select)
  label = WIDGET_LABEL(base2, XSIZE=200)

  ; Realize the widget hierarchy, then retrieve the widget ID of the
  ; draw widget.
  WIDGET_CONTROL, base, /REALIZE
  WIDGET_CONTROL, draw, GET_VALUE=drawID

  ; Set the timer value of the draw widget.
  WIDGET_CONTROL, draw, TIMER=0.0

  ; Set the droplist to display the proper selection index.
  WIDGET_CONTROL, dlist, SET_DROPLIST_SELECT=sel_index

  ; Store the widget ID of the draw widget, the widget ID of
  ; the label widget, the droplist selection index, and the
  ; initial color table index in an anonymous structure, and
  ; set the user value of the top-level base widget to this
  ; structure.
  stash = { drawID:drawID, labelID:label, $
            sel_index:sel_index, ctable:0}
  WIDGET_CONTROL, base, SET_UVALUE=stash

  ; Register the widget with the XMANAGER.
  XMANAGER, 'draw_widget_example', base, /NO_BLOCK

  ; Set some display device parameters.
  DEVICE, RETAIN=2, DECOMPOSED=0

END
