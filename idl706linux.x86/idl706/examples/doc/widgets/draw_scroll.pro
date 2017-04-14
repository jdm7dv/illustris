;  $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/draw_scroll.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Widget Application Techniques"
; chapter of the _Building IDL Applications_ manual.
;

; Event-handler routine. Does nothing in this example.
PRO draw_scroll_event, ev
  COMPILE_OPT hidden
END

; Widget creation routine.
PRO draw_scroll

  ; Read an image for use in the example.
  READ_JPEG, FILEPATH('muscle.jpg', $
    SUBDIR=['examples', 'data']), image

  ; Create the base widget.
  base = WIDGET_BASE()

  ; Create the draw widget. The size of the viewport is set to
  ; 200x200 pixels, but the size of the drawable area is
  ; set equal to the dimensions of the image array using the
  ; XSIZE and YSIZE keywords.
  draw = WIDGET_DRAW(base, X_SCROLL_SIZE=200, Y_SCROLL_SIZE=200, $
    XSIZE=(SIZE(image))[1], YSIZE=(SIZE(image))[2], /SCROLL)

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
  XMANAGER, 'draw_scroll', base, /NO_BLOCK

END
