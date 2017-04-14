;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/drag_and_drop_draw.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; drag_and_drop_draw.pro
;
; This application demonstrates drag and drop from a single
; selection tree to a draw widget.  This example illustrates:
;
; (1) How to enable dragging.
; (2) How to enable drop events.
; (3) How draw widgets can respond to drop events.


; drag_and_drop_draw_event
;
; This procedure is the application's main event handler.
; The draw widget has its own event handler.

PRO drag_and_drop_draw_event, event

END

; DnDDE_handle_drop_event
;
; This procedure handles drop events for the draw widget.
; The event structure contains the widget identifiers of
; the destination draw widget and the source tree.  It also
; contains the (X,Y) coordinates of the drop and the state
; of the modifier keys, but those fields are not used in
; this example application.

PRO DnDDE_handle_drop_event, event

  ; provide end-user feedback for large files

  WIDGET_CONTROL, /HOURGLASS

  ; get the name of the dropped tree node
  ;
  ; This application has been set up so that each node in
  ; the tree matches a known file in the <IDL_DIR>/examples/data
  ; directory.  We know only one node is being dropped because
  ; the tree was created as as a single selection tree.
  ;
  ; The dragged and dropped node is the tree's currently
  ; selected node.

  wTreeNode = WIDGET_INFO( event.drag_id, /TREE_SELECT )
  WIDGET_CONTROL, wTreeNode, GET_VALUE = fileName

  ; display the image
  ;
  ; The targeted draw widget is resized so that the image
  ; can be completely shown (via scrollbars).  Note that
  ; the draw widget is the event's ID field.

  file = FILEPATH( fileName, SUBDIR = ['examples', 'data'] )
  READ_JPEG, file, image, TRUE = 3

  dims = SIZE( image, /DIMENSIONS )
  WIDGET_CONTROL, event.id, $
    DRAW_XSIZE = dims[0], DRAW_YSIZE = dims[1]

  WIDGET_CONTROL, event.id, GET_VALUE = index
  WSET, index
  TV, image, TRUE = 3

END

; DnDDE_handle_draw_event
;
; This is the draw widget event handler.

PRO DnDDE_handle_draw_event, event

  CASE ( TAG_NAMES( event, /STRUCTURE ) ) OF

    'WIDGET_DROP': DnDDE_handle_drop_event, event

    ELSE:

  ENDCASE

END

; drag_and_drop_draw
;
; This is the application main procedure.  It creates
; a top level base, a tree widget whose nodes can be
; dragged, and a draw widget upon which tree nodes can
; be dropped.

PRO drag_and_drop_draw

  wTopBase = WIDGET_BASE( /ROW )

  ; create a tree
  ;
  ; The tree is a simple, single selection tree.  Its
  ; nodes can be dragged only to the draw widget.
  ; Note that only the leaf nodes are draggable.

  wRoot = WIDGET_TREE( wTopBase )

  wFolder1 = WIDGET_TREE( wRoot, /FOLDER, /EXPANDED, $
    VALUE = 'Astronomy' )
  wLeaf11 = WIDGET_TREE( wFolder1, VALUE = 'glowing_gas.jpg', $
     /DRAGGABLE )
  wLeaf12 = WIDGET_TREE( wFolder1, VALUE = 'marsglobe.jpg', $
     /DRAGGABLE )
  wLeaf13 = WIDGET_TREE( wFolder1, VALUE = 'meteor_crater.jpg', $
     /DRAGGABLE )

  wFolder2 = WIDGET_TREE( wRoot, /FOLDER, /EXPANDED, $
    VALUE = 'Aerial Images' )
  wLeaf21 = WIDGET_TREE( wFolder2, VALUE = 'elev_t.jpg', $
     /DRAGGABLE )

  wFolder3 = WIDGET_TREE( wRoot, /FOLDER, /EXPANDED, $
    VALUE = 'Miscellanous' )
  wLeaf31 = WIDGET_TREE( wFolder3, VALUE = 'rose.jpg', $
     /DRAGGABLE1 )
  wLeaf32 = WIDGET_TREE( wFolder3, VALUE = 'n_vasinfecta.jpg', $
     /DRAGGABLE )
  wLeaf33 = WIDGET_TREE( wFolder3, VALUE = 'r_seeberi.jpg', $
     /DRAGGABLE )
  wLeaf34 = WIDGET_TREE( wFolder3, VALUE = 'r_seeberi_spore.jpg', $
     /DRAGGABLE )

  ; create a draw widget
  ;
  ; The draw widget accepts nodes from the tree widget.  The
  ; DRAG_NOTIFY keyword is not used in this example, but
  ; could be used to control where in the draw widget drop
  ; are permitted.  The setting of DROP_EVENTS causes the
  ; widget system's default drag notification callback to be
  ; used.

  draw = WIDGET_DRAW( wTopBase, XSIZE = 300, YSIZE = 300, $
    X_SCROLL_SIZE = 300, Y_SCROLL_SIZE = 300, /DROP_EVENTS, $
    RETAIN = 2, EVENT_PRO = 'DnDDE_handle_draw_event' )

  ; realize the widgets

  WIDGET_CONTROL, wTopBase, /REALIZE

  XMANAGER, 'drag_and_drop_draw', wTopBase, /NO_BLOCK

END
