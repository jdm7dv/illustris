;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/draw_app_scroll.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Widget Application Techniques"
; chapter of the _Building IDL Applications_ manual.
;

; Event-handler routine.
PRO draw_app_scroll_event, ev

  COMPILE_OPT hidden

  ; We need access to the image in both the widget creation routine
  ; and the event-handler routine. We use a COMMON block to make
  ; the variable available in both routines.
  ;
  COMMON app_scr_ex, image

  ; Check the event type. If the event is a viewport event
  ; (type 3), redraw the image in the viewport using the
  ; new X and Y coordinates contained in the event structure.
  ; Note that we can use this simple check for the value of
  ; the TYPE field because there are no other widgets in this
  ; example to generate events; in a more complex widget
  ; application, a more sophisticated check would be necessary.
  ;
  IF (ev.TYPE EQ 3) THEN TVSCL, image, 0-ev.X, 0-ev.Y

END

; Widget creation routine.
PRO draw_app_scroll

  ; We need access to the image in both the widget creation routine
  ; and the event-handler routine. We use a COMMON block to make
  ; the variable available in both routines.
  ;
  COMMON app_scr_ex, image

  ; Read an image for use in the example.
  READ_JPEG, FILEPATH('muscle.jpg', $
    SUBDIR=['examples', 'data']), image

  ; Create the base widget.
  base = WIDGET_BASE()

  ; Create the draw widget. The size of the viewport is set to
  ; 200x200 pixels, but the size of the virtual drawable area is
  ; set equal to the dimensions of the image array using the
  ; XSIZE and YSIZE keywords.
  draw = WIDGET_DRAW(base, X_SCROLL_SIZE=200, Y_SCROLL_SIZE=200, $
    XSIZE=(SIZE(image))[1], YSIZE=(SIZE(image))[2], /APP_SCROLL)

  ; Realize the widgets.
  WIDGET_CONTROL, base, /REALIZE

  ; Retrieve the window ID from the draw widget.
  WIDGET_CONTROL, draw, GET_VALUE=drawID

  ; Set the draw widget as the current drawable area.
  WSET, drawID

  ; Load the image.
  TVSCL, image

  ; Call XMANAGER to manage the widgets.
  ;
  XMANAGER, 'draw_app_scroll', base, /NO_BLOCK

END
