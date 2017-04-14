;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/drag_and_drop_simple.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; drag_and_drop_simple.pro
;
; This application demonstrates drag and drop in a single
; selection tree.  This example illustrates:
;
; (1) How to enable dragging.
; (2) How to enable drop events.
; (3) How to move a node in response to a drop event.
;   (A) How to determine the insertion parent.
;   (B) How to determine the insertion index.


; drag_and_drop_simple_event
;
; This procedure is the application's main event handler.
; The tree has its own event handler.

PRO drag_and_drop_simple_event, event

END

; DnDSE_handle_drop_event
;
; This procedure repositions a node.  The event structure
; contains the widget identifier of the drop target and the
; relative position to it where the dragged node should be
; moved.

PRO DnDSE_handle_drop_event, event

  ; figure out the new node's parent and the index
  ;
  ; The key to this is to know whether or not the drop took
  ; place directly on a folder.  If it was then the new node
  ; will be created within the folder as the last child.
  ; Otherwise the new node will be created as a sibling of
  ; the drop target and the index must be computed based on
  ; the index of the destination widget and the position
  ; information (below or above/on).

  IF (( event.position EQ 2 && $
        WIDGET_INFO( event.id, /TREE_FOLDER ))) THEN BEGIN

    wParent = event.id
    index = -1

  ENDIF ELSE BEGIN

    wParent = WIDGET_INFO( event.id, /PARENT )
    index = WIDGET_INFO( event.id, /TREE_INDEX )
    IF ( event.position EQ 4 ) THEN index++

  ENDELSE

  ; move the dragged node (single selection tree)

  wDraggedNode = WIDGET_INFO( event.drag_id, /TREE_SELECT )

  WIDGET_TREE_MOVE, wDraggedNode, wParent, INDEX = index

END

; DnDSE_handle_tree_event
;
; This is the tree widget event handler.

PRO DnDSE_handle_tree_event, event

  CASE ( TAG_NAMES( event, /STRUCTURE ) ) OF

    'WIDGET_DROP': DnDSE_handle_drop_event, event

    ELSE:

  ENDCASE

END

; drag_and_drop_simple
;
; This is the application main procedure.  It creates
; a top level base and a tree widget whose nodes can
; be reorganized by dragging and dropping.

PRO drag_and_drop_simple

  wTopBase = WIDGET_BASE()

  ; create a tree
  ;
  ; The tree is kept simple, with single selection and
  ; default icons.  The root is set to be draggable and
  ; although it cannot be dragged, the value is inherited
  ; by all the children.  Drop events are also enabled.

  wRoot = WIDGET_TREE( wTopBase, $
    /DRAGGABLE, $
    /DROP_EVENTS, $
    EVENT_PRO = 'DnDSE_handle_tree_event' )

  wFolder1 = WIDGET_TREE( wRoot, /FOLDER, /EXPANDED, $
    VALUE = 'Solid' )
  wLeaf11 = WIDGET_TREE( wFolder1, VALUE = 'Puma' )
  wLeaf12 = WIDGET_TREE( wFolder1, VALUE = 'Panther' )

  wFolder2 = WIDGET_TREE( wRoot, /FOLDER, /EXPANDED, $
    VALUE = 'Spotted' )

  wLeaf21 = WIDGET_TREE( wFolder2, VALUE = 'Cheetah' )
  wLeaf22 = WIDGET_TREE( wFolder2, VALUE = 'Jaguar' )
  wLeaf23 = WIDGET_TREE( wFolder2, VALUE = 'Leopard' )

  wFolder3 = WIDGET_TREE( wRoot, /FOLDER, /EXPANDED, $
    VALUE = 'Striped' )
  wLeaf31 = WIDGET_TREE( wFolder3, VALUE = 'Tiger' )

  ; realize the widgets

  WIDGET_CONTROL, wTopBase, /REALIZE

  XMANAGER, 'drag_and_drop_simple', wTopBase, /NO_BLOCK

END
