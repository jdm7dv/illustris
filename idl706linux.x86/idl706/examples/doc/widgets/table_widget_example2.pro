;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/table_widget_example2.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This file provides an example of the use of the table widget.
; Table widgets are discussed in detail in the "Widget Application
; Techniques" chapter of _Building IDL Applications._

; Event-handler routine for 'Quit' button
PRO table_widget_example2_quit_event, ev

  COMPILE_OPT hidden

  WIDGET_CONTROL, ev.TOP, /DESTROY

END

; Widget creation routine.
PRO table_widget_example2

  ; Create some structure data.
  d0={planet:'Mercury', orbit:0.387, radius:2439, moons:0}
  d1={planet:'Venus', orbit:0.723, radius:6052, moons:0}
  d2={planet:'Earth', orbit:1.0, radius:6378, moons:1}
  d3={planet:'Mars', orbit:1.524, radius:3397, moons:2}

  ; Combine structure data into a vector of structures.
  data = [d0, d1, d2, d3]

  ; Create labels for the rows or columns of the table.
  labels = ['Planet', 'Orbit Radius (AU)', 'Radius (km)', 'Moons']

  ; To make sure the table looks nice on all platforms,
  ; set all column widths to the width of the longest string
  ; that can be a header.
  max_strlen = strlen('Orbit Radius (AU)')
  maxwidth = max_strlen * !d.x_ch_size + 6   ; ... + 6 for padding

  ; Create base widget, two tables (column- and row-major,
  ; respectively), and 'Quit' button.
  base = WIDGET_BASE(/COLUMN)
  table1 = WIDGET_TABLE(base, VALUE=data, /COLUMN_MAJOR, $
    ROW_LABELS=labels, COLUMN_LABELS='', COLUMN_WIDTHS=maxwidth, $
    /RESIZEABLE_COLUMNS)
  table2 = WIDGET_TABLE(base, VALUE=data, /ROW_MAJOR, $
    ROW_LABELS='', COLUMN_LABELS=labels, /RESIZEABLE_COLUMNS)
  b_quit = WIDGET_BUTTON(base, VALUE='Quit', $
    EVENT_PRO='table_widget_example2_quit_event')

  ; Realize the widgets.
  WIDGET_CONTROL, base, /REALIZE

  ; Retrieve the widths of the columns of the first table.
  ; Note that we must realize the widgets before retrieving
  ; this value.
  col_widths = WIDGET_INFO(table1, /COLUMN_WIDTHS)

  ; We need the following trick to get the first column (which is
  ; a header column in our first table) to reset to the width of
  ; our data columns. The initial call to keyword COLUMN_WIDTHS
  ; above only set the data column widths.
  WIDGET_CONTROL, table1, COLUMN_WIDTHS=col_widths[0], $
    USE_TABLE_SELECT=[-1,-1,3,3]
  ; This call gives table 2 the same cell dimensions as table 1
  WIDGET_CONTROL, table2, COLUMN_WIDTHS=col_widths[0], $
    USE_TABLE_SELECT=[-1,-1,3,3]

  ; Call XMANAGER to manage the widgets.
  XMANAGER, 'table_widget_example2', base

END
