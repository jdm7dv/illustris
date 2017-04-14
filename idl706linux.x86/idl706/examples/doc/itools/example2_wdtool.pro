;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/example2_wdtool.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   example2_wdtool
;
; PURPOSE:
;   Create the IDL UI (widget) interface for an associated
;   tool object. See "Creating a Custom iTool Widget Interface"
;   in the iTool Developer's Guide for a detailed explanation
;   of this routine.
;
; CALLING SEQUENCE:
;   This routine is not meant to be called independently;
;   the IDLITSYS_CREATETOOL routine will call this routine
;   if the INTERFACE_NAME keyword is set to the name of 
;   this interface, as registered with the ITREGISTER
;   procedure using the USER_INTERFACE keyword.
;
; INPUTS:
;   Tool - Object reference to the tool object.
;
;-


;-------------------------------------------------------------------------
; example2_wdtool_callback
;
; Purpose:
;   Callback routine for the tool interface widget, allowing it to
;   receive update messages from the system.
;
; Parameters:
;   wBase     - Base id of this widget
;
;   strID     - ID of the message.
;
;   MessageIn - What is the message
;
;   userdata  - Data associated with the message
;
PRO example2_wdtool_callback, wBase, strID, messageIn, userdata

   ; Make sure we have a valid widget.
   IF (~WIDGET_INFO(wBase, /VALID)) THEN $
      RETURN

   ; Retrieve a pointer to the state structure.
   wChild = WIDGET_INFO(wBase, /CHILD)
   WIDGET_CONTROL, wChild, GET_UVALUE = pState

   ; Handle the message that was passed in.
   CASE STRUPCASE(messageIn) OF

      ; The FILENAME message is received if the user saves
      ; the iTool with a new name. This callback sets the
      ; title of the iTool to match the name of the file.
      'FILENAME': BEGIN
         ; Use the new filename to construct the title.
         filename = FILE_BASENAME(userdata)
         ; Append the filename onto the base title.
         newTitle = (*pState).title + ' [' + filename + ']'
         WIDGET_CONTROL, wBase, TLB_SET_TITLE = newTitle
      END

      ; Other messages would be handled here.
      
      ELSE:  ; Do nothing

   ENDCASE

END


;-------------------------------------------------------------------------
; example2_wdtool_resize
;
; Purpose:
;    Called when the user resizes the top-level base of this tool
;    interface. Will recalculate the size of the major elements
;    in the interface.
;
;    NOTE: In this example, we do not resize the non-iTool widgets
;    included in the interface. You may choose to add additional
;    widget resizing code to this routine to suit the needs of
;    your interface.
;
;    NOTE: Widget resizing code depends heavily on the layout of
;    the widgets (both iTool widgets and "traditional" widgets)
;    in your interface. You will need to adjust this example to
;    match the layout of your interface in order for the elements
;    to resize properly.
;
; Parameters:
;   pState   - pointer to the state struct for this widget.
;
;   deltaW   - The change in the width of the interface.
;
;   deltaH   - The change in the height of the interface.
;
PRO example2_wdtool_resize, pState, deltaW, deltaH

   ; Retrieve the original geometry (prior to the resize)
   ; of the iTool draw and toolbar widgets.
   drawgeom = WIDGET_INFO((*pState).wDraw, /GEOMETRY)
   toolbarGeom = WIDGET_INFO((*pState).wToolbar, /GEOMETRY)

   ; Compute the updated dimensions of the visible portion
   ; of the draw widget.
   newVisW = (drawgeom.xsize + deltaW)
   newVisH = (drawgeom.ysize + deltaH)

   ; Check whether UPDATE is turned on, and save the value.
   isUpdate = WIDGET_INFO((*pState).wBase, /UPDATE)
   
   ; Under Unix, UPDATE must be turned on or windows will
   ; not resize properly. Turn UPDATE off under Windows
   ; to prevent window flashing.
   IF (!VERSION.OS_FAMILY EQ 'Windows') THEN BEGIN
      IF (isUpdate) THEN $
         WIDGET_CONTROL, (*pState).wBase, UPDATE = 0
   ENDIF ELSE BEGIN
      ; On Unix make sure update is on.
      IF (~isUpdate) THEN $
         WIDGET_CONTROL, (*pState).wBase, /UPDATE
   ENDELSE

   ; Update the draw widget dimensions.
   IF (newVisW NE drawgeom.xsize || newVisH ne drawgeom.ysize) $
      THEN BEGIN
      CW_ITWINDOW_RESIZE, (*pState).wDraw, newVisW, newVisH
   ENDIF

   ; Update the width of the toolbar base.
   WIDGET_CONTROL, (*pState).wToolbar, $
      SCR_XSIZE = toolbarGeom.scr_xsize+deltaW

   ; Update the statusbar to be the same width as the toolbar.
   CW_ITSTATUSBAR_RESIZE, (*pState).wStatus, $
      toolbarGeom.scr_xsize+deltaW

   ; Turn UPDATE back on if we turned it off.
   IF (isUpdate && ~WIDGET_INFO((*pState).wBase, /UPDATE)) THEN $
      WIDGET_CONTROL, (*pState).wBase, /UPDATE

   ; Retrieve and store the new top-level base size.
   IF (WIDGET_INFO((*pState).wBase, /REALIZED)) THEN BEGIN
      WIDGET_CONTROL, (*pState).wBase, TLB_GET_SIZE = basesize
      (*pState).basesize = basesize
   ENDIF

END


;-------------------------------------------------------------------------
; example2_wdtool__cleanup
;
; Purpose:
;   Called when the widget is destroyed, to free the pointer used
;   to store the widget state structure.
;
; Parameters:
;    wChild   - The id of the widget that contains this widget's
;               state structure.
;
PRO example2_wdtool_cleanup, wChild

   ; Make sure we have a valid widget ID.
   IF (~WIDGET_INFO(wChild, /VALID)) THEN $
      RETURN

   ; Retrieve the pointer to the state structure, and
   ; free it.
   WIDGET_CONTROL, wChild, GET_UVALUE = pState
   IF (PTR_VALID(pState)) THEN $
      PTR_FREE, pState

END


;-------------------------------------------------------------------------
; example2_wdtool_event
;
; Purpose:
;    Main event handler for the tool interface. Note that we do not
;    explicitly handle events from the iTool components in use --
;    these events are handled by the iTool framework. We do, however,
;    handle events from the "traditional" widget interface elements.
;    At the least, we must handle events that affect the top-level
;    base widget (resizing, destruction, and focus changes).
;
;    NOTE: in this example, events for non-iTool widgets included
;    in the iTool interface are handled in separate event-handling
;    procedures.
;
; Parameters:
;    event    - The widget event to process.
;
PRO example2_wdtool_event, event

   ; Retrieve a pointer to the state structure.
   wChild = WIDGET_INFO(event.handler, /CHILD)
   WIDGET_CONTROL, wChild, GET_UVALUE = pState

   CASE TAG_NAMES(event, /STRUCTURE_NAME) OF

   ; Destroy the widget
   'WIDGET_KILL_REQUEST': BEGIN
      ; Get the shutdown service and call DoAction.
      ; This code must be here, and not in the _cleanup routine,
      ; because the tool may not actually be killed. (For example
      ; the user may be asked if they want to save, and they may 
      ; hit "Cancel" instead.)
      IF OBJ_VALID((*pState).oUI) THEN BEGIN
         oTool = (*pState).oUI->GetTool()
         oShutdown = oTool->GetService('SHUTDOWN')
         void = (*pState).oUI->DoAction(oShutdown->getFullIdentifier())
      ENDIF
   END

   ; Focus change
   'WIDGET_KBRD_FOCUS': BEGIN
      ; If the iTool is gaining the focus, Get the set current tool
      ; service and call DoAction.
      IF (event.enter && OBJ_VALID((*pState).oUI)) THEN BEGIN
         oTool = (*pState).oUI->GetTool()
         oSetCurrent = oTool->GetService('SET_AS_CURRENT_TOOL')
         void = oTool->DoAction(oSetCurrent->GetFullIdentifier())
      ENDIF
   END

   ; The top-level base was resized
   'WIDGET_BASE': BEGIN
      ; Compute the size change of the base relative to
      ; its cached former size.
      WIDGET_CONTROL, event.top, TLB_GET_SIZE = newSize
      deltaW = newSize[0] - (*pState).basesize[0]
      deltaH = newSize[1] - (*pState).basesize[1]
      example2_wdtool_resize, pState, deltaW, deltaH
      END

   ; Other event handlers for elements of the widget interface
   ; might go here. Alternately, you might define separate
   ; event-handling routines for your own (non-iTool) widgets.
  
   ELSE: ; Do nothing

   ENDCASE

END

;-------------------------------------------------------------------------
; draw_plot_event
;
; Purpose:
;    Event handler for the "Insert New Plot" button. This is the
;    code that creates the plot.
;
; Parameters:
;    event    - The widget event to process.
;
PRO draw_plot_event, event

   ; Retrieve a pointer to the state structure.
   wChild = WIDGET_INFO(event.top, /CHILD)
   WIDGET_CONTROL, wChild, GET_UVALUE = pState

   ; Get the iTool identifier and make sure our iTool
   ; is the current tool.
   toolID = (*pState).oTool->GetFullIdentifier()
   ITCURRENT, toolID

   ; Define some line colors.
   colors = [[0,0,0],[255,0,0], [0,255,0], [0,0,255]]

   ; Get the value of the line color droplist and use it
   ; to select the line color.
   linecolor = WIDGET_INFO((*pState).wLineColor, /DROPLIST_SELECT)
   newcolor = colors[*,linecolor]

   ; Get the value of the "number of points" slider
   WIDGET_CONTROL, (*pState).wSlider, GET_VALUE=points

   ; Get the value of the line size droplist.
   linesize = WIDGET_INFO((*pState).wLineSize, /DROPLIST_SELECT)+1

   ; Call IPLOT to create a plot of random values, replacing the data
   ; used in the iTool's window.
   IPLOT, RANDOMU(seed, points), THICK=linesize, $
      COLOR=newcolor, VIEW_NUMBER=1

END

;-------------------------------------------------------------------------
; linesize_event
;
; Purpose:
;    Event handler for the line size droplist. The thickness of
;    the plot line is updated immediately when the user selects
;    a value from the droplist.
;
; Parameters:
;    event    - The widget event to process.
;
PRO linesize_event, event

   ; Retrieve a pointer to the state structure.
   wChild = WIDGET_INFO(event.top, /CHILD)
   WIDGET_CONTROL, wChild, GET_UVALUE = pState
   
   ; Get the iTool identifier and make sure our iTool
   ; is the current tool.
   toolID = (*pState).oTool->GetFullIdentifier()
   ITCURRENT, toolID

   ; Get the value of the line size droplist.
   linesize = WIDGET_INFO((*pState).wLineSize, /DROPLIST_SELECT)+1

   ; Select the first plot line visualization in the window.
   ; There should be only one line, but we select the first one
   ; just to be sure.
   plotID = (*pState).oTool->FindIdentifiers('*plot*', /VISUALIZATIONS)
   plotObj = (*pState).oTool->GetByIdentifier(plotID[0])
   plotObj->Select
   
   ; Set the THICK property on the plot line and commit the change.
   void = (*pState).oTool->DoSetProperty(plotID, 'THICK', linesize)
   (*pState).oTool->CommitActions

END

;-------------------------------------------------------------------------
; color_event
;
; Purpose:
;    Event handler for the color droplist. The color of the plot
;    line is updated immediately when the user selects a value
;    from the droplist.
;
; Parameters:
;    event    - The widget event to process.
;
PRO color_event, event

   ; Retrieve a pointer to the state structure.
   wChild = WIDGET_INFO(event.top, /CHILD)
   WIDGET_CONTROL, wChild, GET_UVALUE = pState
  
   ; Get the iTool identifier and make sure our iTool
   ; is the current tool.
   toolID = (*pState).oTool->GetFullIdentifier()
   ITCURRENT, toolID

   ; Define some line colors.
   colors = [[0,0,0],[255,0,0], [0,255,0], [0,0,255]]

   ; Get the value of the line color droplist and use it
   ; to select the line color.
   linecolor = WIDGET_INFO((*pState).wLineColor, /DROPLIST_SELECT)
   newcolor = colors[*,linecolor]

   ; Select the first plot line visualization in the window.
   ; There should be only one line, but we select the first one
   ; just to be sure.
   plotID = (*pState).oTool->FindIdentifiers('*plot*', /VISUALIZATIONS)
   plotObj = (*pState).oTool->GetByIdentifier(plotID[0])
   plotObj->Select
   
   ; Set the COLOR property on the plot line and commit the change.
   void = (*pState).oTool->DoSetProperty(plotID, 'COLOR', newcolor)
   (*pState).oTool->CommitActions

END

;-------------------------------------------------------------------------
; filter_event
;
; Purpose:
;    Event handler for the "Filter this Plot" button, which applies
;    the Median filter operation to the plot line.
;
; Parameters:
;    event    - The widget event to process.
;
PRO filter_event, event

   ; Retrieve a pointer to the state structure.
   wChild = WIDGET_INFO(event.top, /CHILD)
   WIDGET_CONTROL, wChild, GET_UVALUE = pState
   
   ; Get the iTool identifier and make sure our iTool
   ; is the current tool.
   toolID = (*pState).oTool->GetFullIdentifier()
   ITCURRENT, toolID

   ; Select the first plot line visualization in the window.
   ; There should be only one line, but we select the first one
   ; just to be sure. Also retrieve the identifier for the Median
   ; filter operation.
   plotID = (*pState).oTool->FindIdentifiers('*plot*', /VISUALIZATIONS)
   medianID = (*pState).oTool ->FindIdentifiers('*median', /OPERATIONS)
   plotObj = (*pState).oTool->GetByIdentifier(plotID[0])
   plotObj->Select
   
   ; Apply the Median filter operation to the selected plot line
   ; and commit the change.
   void = (*pState).oTool->DoAction(medianID)
   (*pState).oTool->CommitActions

END


;-------------------------------------------------------------------------
; example2_wdtool
;
; Purpose:
;    This is the main entry point for the iTool's IDL widget
;    user interface. This routine is passed an object reference
;    to an iTool; the routine then builds a UI that displays
;    the contents of the tool object.
;
; Parameters:
;   oTool    - The tool object to use.
;
; Keywords:
;    TITLE          - The title for the tool. If not provided, the
;                     string 'IDL iTool' is used.
;
;    LOCATION       - Two-element array [x,y] that specifies where
;                     to place the new iTool on the screen, in pixels.
;
;    VIRTUAL_DIMENSIONS - Two-element array [width,height] that
;                         specifies the virtual size of the drawable
;                         area, in pixels.
;
;    USER_INTERFACE - If set to an IDL variable, will return an object
;                     reference to the user interface object built
;                     by this routine.
;
PRO example2_wdtool, oTool, TITLE = titleIn, $
         LOCATION = location, $
         VIRTUAL_DIMENSIONS = virtualDimensions, $
         USER_INTERFACE = oUI, $  ; output keyword
         _REF_EXTRA = _extra

   ; Make sure the iTool object reference we've been passed
   ; is valid.
   IF (~OBJ_VALID(oTool)) THEN $
      MESSAGE, 'Tool is not a valid object.'

   ; Set the window title.
   title = (N_ELEMENTS(titleIn) GT 0) ? titleIn[0] : 'IDL iTool'

   ; Display the hourglass cursor while the iTool is loading.
   WIDGET_CONTROL, /HOURGLASS

   ; Create a base widget to hold everything
   wBase = WIDGET_BASE(/COLUMN, MBAR = wMenubar, $
      TITLE = title, $
      /TLB_KILL_REQUEST_EVENTS, $
      /TLB_SIZE_EVENTS, $
      /KBRD_FOCUS_EVENTS, $
      _EXTRA = _extra)

   ; Create a new user interface object, using our iTool.
   oUI = OBJ_NEW('IDLitUI', oTool, GROUP_LEADER = wBase)

   ; Menubars
   ; iTool menubars are created using the CW_ITMENU compound
   ; widget. The following statements create the standard iTool
   ; menus, pointing at the standard iTool operations containers.
   ; Note that if the iTool to which this user interface is applied
   ; has registered new operations in these containers, those
   ; operations will show up automatically. Similarly, if the
   ; iTool has unregistered any operations in these containers,
   ; the operations will not appear. Our example tool unregisters
   ; seveal of the standard iTool menu items -- see the
   ; 'example2tool__define.pro' file for examples. Note that we
   ; don't want the standard Help menu in our example interface,
   ; so we don't include it here.
   wFile       = CW_ITMENU(wMenubar, oUI, 'Operations/File')
   wEdit       = CW_ITMENU(wMenubar, oUI, 'Operations/Edit')
   wInsert     = CW_ITMENU(wMenubar, oUI, 'Operations/Insert')
   wOperations = CW_ITMENU(wMenubar, oUI, 'Operations/Operations')
   wWindow     = CW_ITMENU(wMenubar, oUI, 'Operations/Window')
   ;wHelp       = CW_ITMENU(wMenubar, oUI, 'Operations/Help')

   ; You can create additional (non-iTool) menus in the
   ; traditional way. The following lines would create an
   ; additional menu with two menu items. Note that you
   ; must explicitly handle events from non-iTool menus
   ; in your event handler.
   ;
   ; newMenu = WIDGET_BUTTON(wMenubar, VALUE='New Menu')
   ; newMenu1 = WIDGET_BUTTON(newMenu, VALUE='one')
   ; newMenu2 = WIDGET_BUTTON(newMenu, VALUE='two')

   ; Toolbars
   ; iTool toolbars are created using the CW_ITTOOLBAR compound
   ; widget. The following statements create the standard iTool
   ; toolbars. Note that if the iTool to which this user interface
   ; is applied has registered new operations or manipulators in
   ; the referenced containers, those operations or manipulators
   ; will show up automatically. Similarly, if the iTool has
   ; unregistered any items in these containers, the items will
   ; not appear. Our example tool uses the standard operations
   ; and manipulators, but only displays three of the six standard
   ; toolbars.
   wToolbar = WIDGET_BASE(wBase, /ROW, XPAD = 0, YPAD = 0, SPACE = 7)
   ;wTool1 = CW_ITTOOLBAR(wToolbar, oUI, 'Toolbar/File')
   wTool2 = CW_ITTOOLBAR(wToolbar, oUI, 'Toolbar/Edit')
   wTool3 = CW_ITTOOLBAR(wToolbar, oUI, 'Manipulators', /EXCLUSIVE)
   ;wTool4 = CW_ITTOOLBAR(wToolbar, oUI, 'Manipulators/View', /EXCLUSIVE)
   ;wTool5 = CW_ITTOOLBAR(wToolbar, oUI, 'Toolbar/View')
   wTool6 = CW_ITTOOLBAR(wToolbar, oUI, 'Manipulators/Annotation', /EXCLUSIVE)

   ; Widget Layout
   ; This section lays out the main portion of the widget interface.
   ; We create the widget layout in the usual way, incorporating 
   ; iTool compound widgets and "traditional" widgets in the desired
   ; locations.

   ; Create a base to hold the controls and iTool draw window
   wBaseUI = WIDGET_BASE(wBase, /ROW)

   ; Put controls in the left-hand base
   wBaseLeft = WIDGET_BASE(wBaseUI, /COLUMN)
   wButton1 = WIDGET_BUTTON(wBaseLeft, $
      VALUE='Insert New Plot', $
      EVENT_PRO='draw_plot_event')
   padBase = WIDGET_BASE(wBaseLeft, YSIZE=5)
   wSlider = WIDGET_Slider(wBaseLeft, VALUE='10', $
      TITLE='Number of points', MINIMUM=5, MAXIMUM=50)
   padBase = WIDGET_BASE(wBaseLeft, YSIZE=5)
   wLineSize = WIDGET_DROPLIST(wBaseLeft, $
      VALUE=[' 1 ',' 2 ',' 3 ',' 4 '], $
      TITLE='Line Size: ', EVENT_PRO='linesize_event')
   padBase = WIDGET_BASE(wBaseLeft, YSIZE=5)
   wLineColor = WIDGET_DROPLIST(wBaseLeft, $
      VALUE=['Black', 'Red','Green', 'Blue'], $
      TITLE='Line Color: ', EVENT_PRO='color_event')
   padBase = WIDGET_BASE(wBaseLeft, YSIZE=5)
   wButton2 = WIDGET_BUTTON(wBaseLeft, $
      VALUE='Filter this Plot', $
      EVENT_PRO='filter_event')

   ; Put the iTool draw window on the right.
   wBaseRight = WIDGET_BASE(wBaseUI, /COLUMN, /BASE_ALIGN_RIGHT)

   ; Set thie initial dimensions of the draw window, in pixels.
   dimensions = [350, 350]

   wDraw = CW_ITWINDOW(wBaseRight, oUI, $
      DIMENSIONS = dimensions, $
      VIRTUAL_DIMENSIONS = virtualDimensions)

   ; Get the geometry of the top-level base widget.
   baseGeom = WIDGET_INFO(wBase, /GEOMETRY)

   ; Create the status bar.
   wStatus = CW_ITSTATUSBAR(wBase, oUI, $
      XSIZE = baseGeom.xsize-baseGeom.xpad)

   ; If the user did not specify a location, position the
   ; iTool on the screen.
   IF (N_ELEMENTS(location) EQ 0) THEN BEGIN
      location = [(screen[0] - baseGeom.xsize)/2 - 10, $
                 ((screen[1] - baseGeom.ysize)/2 - 100) > 10]
   ENDIF

   WIDGET_CONTROL, wBase, MAP = 0, $
      TLB_SET_XOFFSET = location[0], $
      TLB_SET_YOFFSET = location[1]

   ; Get the widget ID of the first child widget of our
   ; base widget. We'll use the child widget's user value
   ; to store our widget state structure.
   wChild = WIDGET_INFO(wBase, /CHILD)

   ; Create a state structure for the widget and stash
   ; a pointer to the structure in the user value of the
   ; first child widget.
   state = { $
           oTool      : oTool,     $
           oUI        : oUI,       $
           wBase      : wBase,     $
           title      : title,     $
           basesize   : [0L, 0L],  $
           wToolbar   : wToolbar,  $
           wDraw      : wDraw,     $
           wStatus    : wStatus,   $
           wSlider    : wSlider,   $
           wLineSize  : wLineSize, $
           wLineColor : wLineColor }

   pState = PTR_NEW(state, /NO_COPY)
   WIDGET_CONTROL, wChild, SET_UVALUE = pState

   ; Realize our interface. Note that we have left the
   ; interface unmapped, to avoid flashing.
   WIDGET_CONTROL, wBase, /REALIZE

   ; Retrieve the starting dimensions and store them.
   ; Used for window resizing in event processing.
   WIDGET_CONTROL, wBase, TLB_GET_SIZE = basesize
   (*pState).basesize = basesize

   ; Register the top-level base widget with the UI object.
   ; Returns a string containing the identifier of the
   ; interface widget.
   myID = oUI->RegisterWidget(wBase, 'Example 2 Tool', $
      'example2_wdtool_callback')

   ; Register to receive messages from the iTool components
   ; included in the interface.
   oUI->AddOnNotifyObserver, myID, oTool->GetFullIdentifier()

   ; Specify how to handle destruction of the widget interface.
   WIDGET_CONTROL, wChild, KILL_NOTIFY = 'example2_wdtool_cleanup'

   ; Display the iTool widget interface.
   WIDGET_CONTROL, wBase, /MAP

   ; Start event processing.
   XMANAGER, 'example2_wdtool', wBase, /NO_BLOCK

END

