;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/drag_and_drop_complex.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; drag_and_drop_complex.pro
;
; This application demonstrates drag and drop in multiple
; selection trees.  This example illustrates:
;
; (1) How to enable dragging.
; (2) How to enable drop events.
; (3) How to augment the default drag notification callback.
;   (A) Augment with control-key copying.
;   (B) Augment with "trigger-loaded" folders.
; (4) How to copy one or more nodes in response to a drop event.
;   (A) How to determine the insertion parent.
;   (B) How to determine the insertion index.
;
; This example also demonstrates many of the tree widget
; manipulation capabilities, such as those involving node
; indexes and masked bitmaps,
;
; Usage:
;
; (1) Press the alt key while over a folder to get it to
;     expand or collapse.
;
; (2) Press the control key to copy nodes instead of
;     moving them.

;----------------------------------------------------------
; event handlers

; drag_and_drop_complex_event
;
; The main tree drag'n'drop even handler.

PRO drag_and_drop_complex_event, event

END

; DnDCE_handle_drop_event
;
; Processes drag'n'drop drop events.
;
; The trees in this application allow for multiple selection
; so some extra processing is required.  It is a policy of
; this application to allow users to select children of selected
; nodes.  Also, if a folder is selected, this application
; chooses to copy all of the children, selected or not.  Hence
; if the "duplicately selected" nodes are not pruned from the
; list of dragged nodes, they will be copied twice.

PRO DnDCE_handle_drop_event, event

  ; determine the parent and the index of the new node(s)
  ;
  ; Drops on folders put the nodes at the end.  Drops on leaf
  ; nodes go either above or below the leaf.

  dropIsOnFolder = $
    (event.position eq 2 && WIDGET_INFO( event.id, /TREE_FOLDER ))

  wParent = dropIsOnFolder ? event.id : WIDGET_INFO( event.id, /PARENT )

  IF ( ~dropIsOnFolder ) THEN BEGIN
    index = WIDGET_INFO( event.id, /TREE_INDEX )
    IF ( event.position EQ 4 ) THEN index++
  ENDIF ELSE $
    index = -1

  ; acquire a list of dragged items
  ;
  ; The keyword TREE_DRAG_SELECT is used instead of TREE_SELECT
  ; because it removes "duplicately selected" nodes.

  wDraggedItems = WIDGET_INFO( event.drag_id, /TREE_DRAG_SELECT )

  ; clear the current selection
  ;
  ; This application is only interested in highlighting the new nodes.

  WIDGET_CONTROL, WIDGET_INFO( wParent, /TREE_ROOT ), $
    SET_TREE_SELECT = 0

  ; move or copy the dragged nodes
  ;
  ; The following procedure takes care of the details of recursively
  ; copying each of the dragged items.  If custom node duplication
  ; behavior was required then the CALLBACK and USERDATA keywords
  ; would be used.

  WIDGET_TREE_MOVE, wDraggedItems, wParent, INDEX = index, $
    COPY = ( event.modifiers eq 2 ), /SELECT

END

; DnDCE_delete_node_event
;
; Deletes all of the currently selected nodes.

PRO DnDCE_delete_node_event, event

  WIDGET_CONTROL, event.id, GET_UVALUE = wRoot

  wSelectedNodes = WIDGET_INFO( wRoot, /TREE_DRAG_SELECT )

  IF ( wSelectedNodes[0] NE -1 ) THEN $
    FOR i = 0, N_ELEMENTS( wSelectedNodes ) - 1 DO $
      WIDGET_CONTROL, wSelectedNodes[i], /DESTROY

END

; DnDCE_handle_context_event
;
; Processes tree widget context events.  The identifier of the
; tree widget that was right-clicked on is stuffed into the
; menu item's uvalue for easy retreival later.

PRO DnDCE_handle_context_event, event

  wContextBase = WIDGET_INFO( event.top, $
    FIND_BY_UNAME = 'TreeContextBase' )
  wDeleteButton = WIDGET_INFO( wContextBase, $
    FIND_BY_UNAME = 'DeleteNodeButton' )

  WIDGET_CONTROL, wDeleteButton, $
    SET_UVALUE = WIDGET_INFO( event.id, /TREE_ROOT )

  WIDGET_DISPLAYCONTEXTMENU, event.id, event.x, event.y, wContextBase

END

; DnDCE_tree_event
;
; This is the tree specific event handler (as set by
; EVENT_PRO when the tree was created).

PRO DnDCE_tree_event, event

  CASE ( TAG_NAMES( event, /STRUCTURE ) ) OF

    'WIDGET_DROP': DnDCE_handle_drop_event, event

    'WIDGET_CONTEXT': DnDCE_handle_context_event, event

    ELSE:

  ENDCASE

END

;----------------------------------------------------------
; drag callbacks
;
; This application defines three drag notification callbacks.
; One is for the root, another is for folders and the last
; one is for non-folder leaves.  All three are very similar
; and could be combined into one callback but are split out
; for demonstration purposes.  It is more memory efficient
; to have just one callback specified on the root.
;
; Each one implements turning on/off of the '+' drag cursor
; indicator.  It is activated when the user presses the
; control key while dragging.
;
; The callback for folders implements "trigger loaded
; folders".  When the user presses the Alt key over a folder,
; the folder's state of expansion is toggled.  This can aid
; the user in navigating a large hierarchy.
;
; A tree widget callback's basic return value is a bit-mask
; that indicates the location of valid drops relative to the
; destination widget:
;
;   0: no drop permitted
;   1: drop above is permitted
;   2: drop on/in is permitted
;   4: drop below is permitted
;
; The callback is also invoked whenever modifier key states
; change.  The drag cursor's plus indicator is turned on by
; setting the "8 bit":
;
;   8: show the plus indicator
;
; The returned value affects the visual feedback that is
; supplied to the user.

; DnDCE_root_drag_notify
;
; The callback just for tree root widgets.  The default is to
; only allow drops onto the root (a value of 2).  If the control
; key is pressed then specify that the drag cursor's '+' indicator
; should be shown.

FUNCTION DnDCE_root_drag_notify, wDestNode, wSourceTree, $
  modifiers, defaultValue

  result = defaultValue
  IF ( modifiers EQ 2 ) THEN $
    result += 8

  RETURN, result

END

; DnDCE_folder_drag_notify
;
; This callback is only for folders.  The default folder behavior
; is implemented (see WIDGET_TREE's DRAG_NOTIFY keyword) and some
; special behavior has been added as well.

FUNCTION DnDCE_folder_drag_notify, wDestNode, wSourceTree, $
  modifiers, defaultValue

  IF ( defaultValue EQ 0 ) THEN $
    RETURN, 0

  ; implement "trigger-loaded" folders
  ;
  ; Callback are called not only for drag cursor movements, but
  ; also modify key state changes.  When the Alt key is pressed,
  ; the folder is opened or closed.  This allows the user to
  ; navigate within a tree while dragging.

  IF ( (modifiers AND 8) EQ 8 ) THEN BEGIN

    WIDGET_CONTROL, wDestNode, $
      SET_TREE_EXPANDED = ~WIDGET_INFO( wDestNode, /TREE_EXPANDED )

  ENDIF

  ; indicate where drops are allowed
  ;
  ; In addition to "above", "on" and "below", specify whether or
  ; not the drag cursor's '+' indicator should be shown.

  result = defaultValue
  IF ( modifiers EQ 2 ) THEN $
    result += 8

  RETURN, result

END

; DnDCE_leaf_drag_notify
;
; This callback is only used by leaf nodes.  The default behavior
; only allows for drop above or below (a value of 5).  If the control
; key is pressed then specify that the drag cursor's '+' indicator
; should be shown.

FUNCTION DnDCE_leaf_drag_notify, wDestNode, wSourceTree, $
  modifiers, defaultValue

  result = defaultValue
  IF ( modifiers EQ 2 ) THEN $
    result += 8

  RETURN, result

END

;----------------------------------------------------------
; application GUI setup routines

; DnDCE_insert_node
;
; This function creates a new leaf or folder node as part of
; initial application setup.

FUNCTION DnDCE_insert_node, wParent, value, isFolder, bitmap

  wNewNode = WIDGET_TREE( wParent, $
    FOLDER = isFolder, $
    EXPANDED = isFolder, $
    BITMAP = bitmap, $
    /MASK, $
    DRAG_NOTIFY = isFolder ? $
      'DnDCE_folder_drag_notify' : 'DnDCE_leaf_drag_notify', $
    VALUE = value )

  RETURN, wNewNode

END

; DnDCE_create_context_menu

PRO DnDCE_create_context_menu, wParent

  wContextBase = WIDGET_BASE( wParent, $
    /CONTEXT_MENU, UNAME = 'TreeContextBase' )

  deleteItem = WIDGET_BUTTON( wContextBase, $
    VALUE = 'Delete Selected Nodes', $
    UNAME = 'DeleteNodeButton', $
    EVENT_PRO = 'DnDCE_delete_node_event' )

END

; create_tree

PRO DnDCE_create_tree, wParent, bitmapFile

  ; create the root
  ;
  ; The values for DRAGGABLE and DROP_EVENTS will be inherited
  ; by all the children.  The DRAG_NOTIFY callback will not be
  ; inherited because it will be explicitly set on each child.

  wRoot = WIDGET_TREE( wParent, $
    /MULTIPLE, $
    /DRAGGABLE, $
    DRAG_NOTIFY = 'DnDCE_root_drag_notify', $
    /DROP_EVENTS, $
    /CONTEXT_EVENTS, $
    EVENT_PRO = 'DnDCE_tree_event' )

  ; convert the bitmap file to a 24-bit image array

  file = FILEPATH( bitmapFile, SUBDIR = ['resource', 'bitmaps'] )
  image8 = READ_BMP( file, red, green, blue )

  image24 = BYTARR( 16, 16, 3, /NOZERO )

  image24[0,0,0] = red[image8]
  image24[0,0,1] = green[image8]
  image24[0,0,2] = blue[image8]

  ; create the nodes

  wTreeNode1 = DnDCE_insert_node( wRoot, 'treeNode1', 1, 0 )
    wTreeNode11 = DnDCE_insert_node( wTreeNode1, 'treeNode11', 0, image24 )
    wTreeNode12 = DnDCE_insert_node( wTreeNode1, 'treeNode12', 1, 0 )
      wTreeNode121 = DnDCE_insert_node( wTreeNode12, 'treeNode121', 0, image24  )
    wTreeNode13 = DnDCE_insert_node( wTreeNode1, 'treeNode13', 0, image24 )
  wTreeNode2 = DnDCE_insert_node( wRoot, 'treeNode2', 1, 0 )
    wTreeNode21 = DnDCE_insert_node( wTreeNode2, 'treeNode21', 0, image24 )
    wTreeNode22 = DnDCE_insert_node( wTreeNode2, 'treeNode22', 0, image24 )

END

; drag_and_drop_complex
;
; Sets up three tree widgets that the user can drag to and from.
; Nodes can also be dragged within a given tree.

PRO drag_and_drop_complex

  wTopBase = WIDGET_BASE( /ROW, /TAB_MODE )

  DnDCE_create_context_menu, wTopBase

  DnDCE_create_tree, wTopBase, 'bulb.bmp'
  DnDCE_create_tree, wTopBase, 'gears.bmp'
  DnDCE_create_tree, wTopBase, 'image.bmp'

  WIDGET_CONTROL, wTopBase, /REALIZE
  XMANAGER, 'drag_and_drop_complex', wTopBase, /NO_BLOCK

END
