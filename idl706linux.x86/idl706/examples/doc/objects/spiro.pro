; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/spiro.pro#2 $
;
; Copyright (c) 1991-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;	SPIRO
; PURPOSE:
;	A Widget front end to draw "Spirograph" (TM) patterns
; CATEGORY:
;	Line Drawing, widgets
; CALLING SEQUENCE:
;	SPIRO
; OUTPUTS:
;	None.
; COMMON BLOCKS:
;	None.
; RESTRICTIONS:
;	None.
; SIDE EFFECTS:
;	Draws a "Spirograph" (TM) pattern on the current window.
;	As the original C program states: "The pattern is produced
;	by rotating a circle inside of another circle with a pen a
;	set distance inside the center of the rotating circle".
; MODIFICATION HISTORY:
;	22, December, 1989, A.B. Inspired by a C program posted
;				 to the Internet by Paul Schmidt (2/2/1988).
;       2,  February, 1995, WSO  Updated the UI and added cams to help visualize
;                                spirograph drawing.
;
;-


    ;
    ; Return the correct color depending on the color depth used.  If !D.N_COLORS
    ; is greater than 256, then the output device is in true color mode.  If that's
    ; the case, we want to use the same index from the red, green and blue color
    ; tables to get the desired color.  If it's not true color than just return 
    ; the color table index.
    ;
FUNCTION GetColor, colorIndex

   IF (!D.N_COLORS GT 256) THEN $
      RETURN, (colorIndex * 256L + colorIndex) * 256L + colorIndex $
   ELSE $
      RETURN, colorIndex
END


;================================================================================
;
;  The following five routines perform the draw operation to display the
;  spirograph and cams (if needed).
;
;  DrawFixedCam         - Draws the cam that is fixed in place
;  DrawRotatingCam      - Draws the cam that rotates about the fixed cam
;  DisplayCams          - Either shows or hides the cams
;  DrawSpirographAndCam - Draws a segment of the spirograph and calls the
;                         above routines to draw the cams
;  DrawSpirograph       - Draws the complete spirograph in one call
;
;     DrawSpirographAndCam is called to simulate
;  the animation of the cams rotating and the pen drawing out the spirograph.
;  Each call to DrawSpirographAndCam draws a frame of the animation.  This
;  includes the cams, pen and one line segment of the spirograph.
;     Animation can be simulated either though a loop or by way of a timer event.
;  When optimum animation speed is required each frame can be drawn at each
;  iteration of a tight loop (i.e.WHILE).  The timer event method activates
;  timer events at desired intervals. As each timer event occurs,
;  another frame of the animation is drawn.
;     Both methods have pluses and minuses.  A loop is used to obtain maximum
;  speed, since none of the timer event processing overhead is needed.  On
;  the other hand, since no events are processed during this loop, the user
;  can't gracefully interupt the animation process and must wait until the
;  animation has completed.  The opposite is true for the timer event method.
;  The timer event method also allows you to vary the animation speed by setting
;  different delay times for each timer event to occur.  Only the timer event
;  method is used in this example.
;
;     If the cams are not visible when the drawing is initiated, no animation
;  is used to draw the spirograph.  Therefore the DrawSpirograph
;  routine is called instead of DrawSpirographAndCam.  This routine simply
;  draws out the complete spirograph in one statement.
;
;================================================================================

    ;
    ; Draw fixed cam
    ;
PRO DrawFixedCam, fixedAngles, fixedRadius, centerX, centerY

     ; Draw the fixed cam in black
     ; This is the second index in the current color table
   camColor = 0

     ; Mark the center of the cam with a small black square
     ; NOTE: the fixed cam's center is always located at the draw area's center
   PLOTS, [centerX-1, centerX-1, centerX+1, centerX+1, centerX-1], $
          [centerY-1, centerY+1, centerY+1, centerY-1, centerY-1], $
          COLOR=GetColor(camColor), /DEVICE, THICK=1

     ; Draw the fixed radius cam by drawing line segments about the center
     ; at intervals of "fixedAngles"
   PLOTS, fixedRadius*COS(fixedAngles)+centerX, $
          fixedRadius*SIN(fixedAngles)+centerY,$
          COLOR=GetColor(camColor), /DEVICE, THICK=2
END


    ;
    ; Draw the rotating cam at an angle about the fixed cam and draw
    ; the pen at an angle about the rotating cam
    ;
PRO DrawRotatingCam, rotatingAngles, penCenterX, penCenterY, $
           rotatingCamCenterX, rotatingCamCenterY, penColor, $
           rotatingRadius

   rCamColor = 30 ; purple

     ; Draw the rotating cam by drawing line segments about the center
     ; at intervals of "rotatingAngles"
   PLOTS, COS(rotatingAngles) * rotatingRadius + rotatingCamCenterX, $
          SIN(rotatingAngles) * rotatingRadius + rotatingCamCenterY, $
          COLOR=GetColor(rCamColor), /DEVICE, THICK=2

     ; Draw the pen tip (drawing end) as a square
   PLOTS, [penCenterX-1, penCenterX-1, penCenterX+1, penCenterX+1, penCenterX-1], $
          [penCenterY-1, penCenterY+1, penCenterY+1, penCenterY-1, penCenterY-1], $
          COLOR=GetColor(penColor), /DEVICE, THICK=2

     ; Draw the pen arm - a line to the pen tip
   PLOTS, [rotatingCamCenterX, penCenterX], [rotatingCamCenterY, penCenterY],$
          COLOR=GetColor(penColor), /DEVICE, THICK=2
END


    ;
    ; Show or Hide the cams only
    ;
    ; The spirograph and cams are drawn using offscreen pixmaps.  This gives
    ; the animation a much smoother appearance.  Without using pixmaps, the
    ; erasing and drawing procedures would tend to have a flashing appearance.
    ; The spirograph is drawn to its own pixmap called "spiroGraphPixmap". This
    ; pixmap is then copied to another "work area" pixmap where the cams are
    ; drawn in.  This one is called "completePixmap".  After the cams are added
    ; this pixmap is then copied to the draw area of the window.  If cams are
    ; to be hidden, just the spirograph pixmap is copied to the draw area of
    ; the window.
    ;
PRO DisplayCams, state

     ; If hiding the cams -
   IF NOT state.showCams THEN BEGIN

        ; Make the display window the current graphics window
      WSET, state.currentDrawArea

        ; Copy spirograph from its pixmap to the display area
      DEVICE, COPY=[0, 0, 256, 256, 0, 0, state.spiroGraphPixmap]

   ENDIF ELSE BEGIN     ; Show the cams

        ; Make the complete pixmap the current graphics output pixmap
      WSET, state.completePixmap

        ; First we want to add the spirograph and then add the
        ; cams on top of it, so...
        ; Copy the pixmap of the spirograph to the complete pixmap
      DEVICE, COPY=[0, 0, 256, 256, 0, 0, state.spiroGraphPixmap]

        ; Draw rotating cam, at its new location, with the pen
        ; position in the complete pixmap
      DrawRotatingCam, state.rotatingAngles, state.penCenterX, state.penCenterY, $
        state.rotatingCamCenterX, state.rotatingCamCenterY, state.color, $
        state.rotatingRadius

        ; Draw the fixed cam first in the pixmap
      DrawFixedCam, state.fixedAngles, state.fixedRadius, state.centerX, $
        state.centerY

        ; Make the display window the current graph port
      WSET, state.currentDrawArea

        ; Copy spirograph and cam from complete pixmap to the display window
      DEVICE, COPY=[0, 0, 256, 256, 0, 0, state.completePixmap]

   ENDELSE

END


    ;
    ; Draw the complete spirograph showing cams and pen.  This procedure draws
    ; only one "frame" of the spirograph animation.  It is called either
    ; from a timer event. It will draw the cams, if needed, and one line segment
    ; of the spirograph.
    ;
    ; The spirograph and cams are drawn using offscreen pixmaps.  This gives
    ; the animation a much smoother appearance.  Without using pixmaps, the
    ; erasing and drawing procedures would tend to have a flashing appearance.
    ; The spirograph is drawn to its own pixmap called "spiroGraphPixmap". Each
    ; call to this procedure adds another line segment to the pixmap. This
    ; pixmap is then copied to another "work area" pixmap where the cams are
    ; drawn in.  This one is called "completePixmap".  After the cams are added
    ; this pixmap is then copied to the draw area of the window.
    ;
PRO DrawSpirographAndCam, state

     ; Increment angle of rotating cam within the fixed cam
   state.camAngle = state.camAngle + state.camAngleIncr
     ; Increment angle of the pen within the rotating cam
   state.penAngle = state.penAngle + state.penAngleIncr

     ; If the cam rotates past the starting point - adjust it back
   IF (state.camAngle GT state.maxAngle) THEN BEGIN
      state.camAngle = state.maxAngle
      state.penAngle = 0
   ENDIF

     ; To draw this cam, we need to determine the location of its center
     ; which is at some angle of rotation (camAngle) about the fixed cam.
     ; Calculate the center of the rotating cam by adding its x and y
     ; distance from the center of the draw area
   state.rotatingCamCenterX = COS(state.camAngle) * state.rotatingCamDistance + state.centerX
   state.rotatingCamCenterY = SIN(state.camAngle) * state.rotatingCamDistance + state.centerY

     ; Calculate the pen tip location relative to the rotating cam's center
   penCenterX = COS(state.penAngle) * state.penRadius + state.rotatingCamCenterX
   penCenterY = SIN(state.penAngle) * state.penRadius + state.rotatingCamCenterY

     ; We're drawing the spirograph in a separate off-screen pixmap
     ; from the cams and then later combining them together.
     ; So first set the pixmap to PLOTS the actual spirograph into
   WSET, state.spiroGraphPixmap

     ; Draw spirograph line segment from the previous
     ; pen location to the new pen location.
   PLOTS,[state.penCenterX, penCenterX], [state.penCenterY, penCenterY], $
         COLOR=GetColor(state.color), LINESTYLE=state.linestyle, /DEVICE

     ; Remember the new pen center
   state.penCenterX = penCenterX
   state.penCenterY = penCenterY

     ; Now draw the cams
   DisplayCams, state

END


    ;
    ; Draw the complete spirograph without showing cams.
    ; This is the procedure to draw the spirograph when the "Show Cams"
    ; checkbox is not set, when the user starts the draw.  The whole
    ; spirograph is drawn at one time, instead of the "frame at a time"
    ; method used for animation by the "DrawSpirographAndCam" procedure.
    ;
PRO DrawSpirograph, state

     ; Display the wait cursor
   WIDGET_CONTROL, /HOURGLASS

     ; Build an array that holds all the points of the spirograph
     ; Add one to include the initial angle of zero radians
   arraySize = CEIL(state.maxAngle/state.camAngleIncr) + 1

     ; Build and initialize arrays to the angles
     ; of all positions for the rotating cam and associated pen
     ; NOTE: Array Operation
   camAngleArray = state.camAngleIncr * FINDGEN(arraySize)
   penAngleArray = state.penAngleIncr * FINDGEN(arraySize)

     ; Make the display window the current output window
   WSET, state.currentDrawArea

     ; Draw each line segment of the spirograph
     ; NOTE: Array Operation
   PLOTS, COS(penAngleArray) * state.penRadius + $
     COS(camAngleArray) * state.rotatingCamDistance + state.centerX, $
     SIN(penAngleArray) * state.penRadius + $
     SIN(camAngleArray) * state.rotatingCamDistance + state.centerY, $
     COLOR=GetColor(state.color), LINESTYLE=state.linestyle, /DEVICE

   WSET, state.spiroGraphPixmap  ; set the pixmap to copy spiro into
     ; Copy spirograph from the display area to its pixmap
   DEVICE, COPY=[0, 0, 256, 256, 0, 0, state.currentDrawArea]

END

;================================================================================
;
;  The following five routines perform the required operation to create, update,
;  and display the spirograph compound widget.
;
;  SpiroEventHdlrCW     - Handles events associated with the spirograph compound
;                         widget. Only the timer event used for animating the cams
;                         is used by this routine.
;  EraseSpiroCW         - Erases the spirograph compound widget.
;  CreateSpiroCW        - Creates the compound widget. Creates pixmaps and other
;                         initial data. It sets up a state structure for keeping
;                         track of the state of the spirograph compound widget.
;  UpdateSpiroCW        - Whenever any spirograph parameters are changed, when the
;                         user manipulates one of the widgets, this
;                         routine is called to update the spirograph.
;  DrawSpiroCW          - Initiates the drawing sequence of the spirograph. This
;                         routine is called whenever the user clicks the Draw/Stop
;                         button is accomplished by either initiating a timer event,
;                         when animating the cam drawing of the spirograph or by just
;                         blasting the complete spirograph out to the display, when
;                         the cams are hidden and therefore no animation required.
;
;================================================================================

    ;
    ; In this example, this event handler is only used for processing timer events.
    ;
FUNCTION SpiroEventHdlrCW, event

    swin = !D.WINDOW

     ; Retrieve the state structure from the first child of the compound widget.
   spiroCW = event.handler
   drawWidget = WIDGET_INFO(spiroCW, /CHILD)

     ; /NO_COPY kills the old uvalue
   WIDGET_CONTROL, drawWidget, GET_UVALUE = state, /NO_COPY

     ; Default the event handler return value to zero.  This is a signal
     ; to the event handling process that the passed in event was
     ; processed and does not need to propagate up the event handling chain.
   returnValue = 0

   CASE event.id OF
      spiroCW: BEGIN   ; timer event

           ; Draw a frame of the spirograph and cams
         DrawSpirographAndCam, state

           ; If not finished animating and a timer hasn't already been set
           ; - set another timer to draw next frame
         IF (state.camAngle LT state.maxAngle) AND (state.timerSet NE 0) THEN $

            WIDGET_CONTROL, spiroCW, TIMER=state.delay $

         ELSE BEGIN
           ; Finished animating - reset angles and timer flag
            IF (state.camAngle GE state.maxAngle) THEN BEGIN
               state.camAngle = 0.0
               state.penAngle = 0.0
            ENDIF

            state.timerSet = 0 ; Reset timer flag to denote completion of animation

              ; Return an event to the compound widget's parent to signal
              ; that the spirograph drawing has been completed
            returnValue = $
              {SpiroEventCW, ID:spiroCW, TOP:event.top, HANDLER:0L, VALUE:0L}

         ENDELSE
      ENDCASE

      ELSE:

   ENDCASE

     ; Restore the state
   WIDGET_CONTROL, drawWidget, SET_UVALUE = state, /NO_COPY

   WSET, swin
   RETURN, returnValue

END


    ;
    ; Erase all the pixmaps and draw widget
    ;
PRO EraseSpiroCW, spiroCW

     ; Retrieve the structure from the child that contains the sub ids
   drawWidget = WIDGET_INFO(spiroCW, /CHILD)
     ; /NO_COPY kills the old uvalue
   WIDGET_CONTROL, drawWidget, GET_UVALUE = state, /NO_COPY

   state.camAngle = 0.0
   state.penAngle = 0.0

     ; Make the spirograph pixmap the current graph port
   WSET, state.spiroGraphPixmap
     ; Erase the spirograph from pixmap
   ERASE

     ; Make the complete pixmap the current graph port
   WSET, state.completePixmap
     ; Erase the complete drawing (spirograph and cams) from pixmap
   ERASE

     ; If the currentDrawArea has not been setup yet - save it value
     ; This value is only available after the widget's been realized
   IF (state.currentDrawArea EQ 0) THEN BEGIN

        ; Save the window's draw area window id for manipulating drawing
        ; pixmaps
      WIDGET_CONTROL, drawWidget, GET_VALUE=draw_win

      state.currentDrawArea = draw_win
   ENDIF

     ; Make the display window the current graph port
   WSET, state.currentDrawArea
     ; Erase the drawing (spirograph and cams) from window
   ERASE

     ; Restore the state variable
   WIDGET_CONTROL, drawWidget, SET_UVALUE = state, /NO_COPY

END


    ;
    ; Clean up whenthe Spiro application is exited.
    ; Remove the pixmap windows.
    ;
PRO CleanUpSpiroCW, drawWidgetID

   WIDGET_CONTROL, drawWidgetID, GET_UVALUE = state, /NO_COPY

     ; Remove the pixmaps - no longer needed
   WDELETE, state.completePixmap
   WDELETE, state.spiroGraphPixmap
   
END


    ;
    ; Create the spirograph compound widget
    ;
FUNCTION CreateSpiroCW, spiroWindow, UVALUE=uValue, $
                        _EXTRA=otherKeywords

     ; The user can associate a user value with the this compound widget
   IF NOT (KEYWORD_SET(uValue)) THEN $
      uValue = 0

     ; Build arrays of angles (in radians) for drawing the rotating and
     ; fixed cams (circles).
     ; The rotating and fixed cams are drawn by plotting 60 line segments
     ; at a distance of the cams radius from its center. This approximates
     ; arcs of seven degrees. The shorter the line segments, the closer
     ; the approximation to a circle.  The flip side to that is the shorter
     ; the line segments, the more the line segments, the longer it takes
     ; to draw.  Sixty line segments is a good compromise, fast yet still
     ; looks like a circle.
   rotatingAngles = findgen(60) * !DTOR * 7
   fixedAngles = findgen(60) * !DTOR * 7

     ; The center of the rotating cam moves camAngleIncr radian increments
     ; around the center of the fixed cam.
   camAngleIncr = 0.05 * !PI

     ; Create base to encapsulate the compound widget
   spiroCW = WIDGET_BASE(spiroWindow, UVALUE=uValue)

     ; Create the draw widget to draw the spirograph in
   drawWidget = WIDGET_DRAW(spiroCW, /FRAME, KILL_NOTIFY="CleanUpSpiroCW", $
                            _EXTRA=otherKeywords)

     ; Set the event handler function.
     ; Make sure it lingers so the cleanup routine can get at its state.
   WIDGET_CONTROL, spiroCW, SET_UVALUE = uValue, $
     EVENT_FUNC = 'SpiroEventHdlrCW', /DELAY_DESTROY

     ; Create the pixmaps to draw into. These are only used when the cams are
     ; shown.  The spirograph will be drawn in the spiroGraphPixmap (a line
     ; segment per animation frame).  This is then bit copied to the
     ; completePixmap where the rotating cam and pen are added to it. This
     ; completePixmap will then be bit copied to the display window's draw
     ; area. This is what gives us the smooth appearance of the cam animation.
   WINDOW, /FREE, /PIXMAP, _EXTRA=otherKeywords
   completePixmap = !D.WINDOW

   WINDOW, /FREE, /PIXMAP, _EXTRA=otherKeywords
   spiroGraphPixmap = !D.WINDOW

   WIDGET_CONTROL, drawWidget, SET_UVALUE = $
    { camAngleIncr: camAngleIncr, $ ; Rotating cam angle increment
      penAngleIncr: 0.0, $          ; Pen angle increment
      showCams : 0, $               ; Boolean show cams when true
      delay: 0.0D, $                ; Delay between frames (in seconds)
      timerSet:0, $                 ; Boolean flag - TRUE when timer exists
      scale: 1.0, $                 ; scale to fit spirograph in draw area
      centerX: 0.0, $               ; center of draw area
      centerY: 0.0, $               ; center of draw area
      fixedRadius: 0.0, $           ; radius of fixed cam
      rotatingRadius: 0.0, $        ; radius of rotating cam
      penRadius: 0.0, $             ; radius of pen in rotating cam
      maxAngle: 0.0, $              ; number of radian loops for rotating cam
      color: 0, $                   ; color index of pen
      linestyle: 0, $               ; linestyle of pen
      camAngle:0.0, $               ; angle of rotating cam
      penAngle:0.0, $               ; angle of pen in rotating cam
      rotatingCamCenterX:0.0, $     ; X location of center of rotating cam
      rotatingCamCenterY:0.0, $     ; Y location of center of rotating cam
      penCenterX:0.0, $             ; X location of center of pen tip
      penCenterY:0.0, $             ; Y location of center of pen tip
      currentDrawArea:0, $          ; current draw widget window id for spirograph
      completePixmap:completePixmap, $  ; complete pixmap to draw spiro & cam
      spiroGraphPixmap:spiroGraphPixmap, $  ; spirograph pixmap to draw spiro
      rotatingCamDistance: 0.0, $   ; rotating cam center from fixed cam center
      rotatingAngles: rotatingAngles, $ ; angles to draw rotating cam (circle)
      fixedAngles: fixedAngles }     ; angles to draw fixed cam (circle)

   RETURN, spiroCW
END


    ;
    ; Greatest Common Denominator
    ;
FUNCTION GreatComDenom, i, j
   loc_i = i
   loc_j = j

   WHILE (loc_j NE 0) DO BEGIN
      temp = loc_j
      loc_j = loc_i MOD loc_j
      loc_i = temp;
   ENDWHILE

   RETURN, loc_i
END


    ;
    ; This function updates the spirograph parameters.  It is called
    ; after the spirograph creation and any time the parameters change.
    ;
PRO UpdateSpiroCW, spiroCW, fixed_rad, rotating_rad, pen_rad, COLOR = color, $
          LINESTYLE = linestyle, SHOWCAMS=showCams, CAMSPEED=camSpeed

   drawWidget = WIDGET_INFO(spiroCW, /CHILD)
     ; /NO_COPY kills the old uvalue
   WIDGET_CONTROL, drawWidget, GET_UVALUE = state, /NO_COPY

     ; Make the display window the current graphics window for dimensions
   WSET, state.currentDrawArea
 
     ; Set the pen color
   IF (N_ELEMENTS(color) eq 0) THEN $
      state.color = !P.COLOR $
   ELSE $
      state.color = color

     ; Set the cam animation speed
   IF (NOT KEYWORD_SET(camSpeed)) THEN $
      state.delay = 0.0 $ ; default delay in fractions of a second
   ELSE IF (camSpeed EQ 10) THEN $   ; If maximum speed -
      state.delay = 0.0 $ ; Force shortest delay possible
   ELSE $
      state.delay = (10.0 - camSpeed) / 10.0  ; delay in fractions of a second

     ; Set the linestyle
   IF (NOT KEYWORD_SET(linestyle)) THEN $
      state.linestyle = 0 $
   ELSE $
      state.linestyle = linestyle

   state.fixedRadius = FLOAT(fixed_rad)
   state.rotatingRadius = FLOAT(rotating_rad)
   state.penRadius = FLOAT(pen_rad)

     ; Limit condition, cams can't be the same size
   IF fixed_rad EQ rotating_rad THEN $
      state.maxAngle = 0.0 $
   ELSE IF pen_rad EQ 0 THEN $   ; A circle results with the pen at the center
      state.maxAngle = 2.0 * !PI $
   ELSE BEGIN                    ; Full number of radians to draw complete loop
      radiiGCD = GreatComDenom(FIX(state.fixedRadius), FIX(state.rotatingRadius))
      state.maxAngle = 2.0 * !PI * state.rotatingRadius / radiiGCD
   ENDELSE

     ; Calculate the center of the draw widget
   state.centerX = !D.X_SIZE / 2 -1
   state.centerY = !D.Y_SIZE / 2 -1

     ; Scale the spirograph in order to fit completely within the draw widget
   IF (!D.X_SIZE GT !D.Y_SIZE) THEN $
      state.scale = !D.Y_SIZE $
   ELSE $
      state.scale = !D.X_SIZE

     ; Force worst case of pen distance to be 95% of the draw widget (radius)
   state.scale = (state.scale * 0.95 / 2) / $
     (ABS(state.fixedRadius - state.rotatingRadius) + state.penRadius)

     ; After determining the scale - apply it to the radii
   state.fixedRadius = state.fixedRadius * state.scale
   state.rotatingRadius = state.rotatingRadius * state.scale
   state.penRadius = state.penRadius * state.scale

     ; Calculate the radian angle increment of the pen within the rotating cam
   state.penAngleIncr = state.camAngleIncr - state.camAngleIncr * $
         state.fixedRadius / state.rotatingRadius

     ; Calculate offset of center of rotating cam from center of fixed cam
   state.rotatingCamDistance = state.fixedRadius - state.rotatingRadius

     ; To draw the rotating cam, we need to determine the location of its center
     ; which is at some angle of rotation (camAngle) about the fixed cam.
     ; Calculate the center of the rotating cam by adding its x and y
     ; distance from the center of the draw area.
   state.rotatingCamCenterX = $
     COS(state.camAngle) * state.rotatingCamDistance + state.centerX
   state.rotatingCamCenterY = $
     SIN(state.camAngle) * state.rotatingCamDistance + state.centerY

     ; Calculate the pen tip location relative to the rotating cam's center
   state.penCenterX = $
     COS(state.penAngle) * state.penRadius + state.rotatingCamCenterX
   state.penCenterY = $
     SIN(state.penAngle) * state.penRadius + state.rotatingCamCenterY

     ; If the showCams keyword was not set - assume false
   IF (NOT KEYWORD_SET(showCams)) THEN $
      showCams = 0
     ; Save the state of the showCams variable
   state.showCams = showCams
     ; Show the cams (if needed)
   DisplayCams, state

     ; Restore the state
   WIDGET_CONTROL, drawWidget, SET_UVALUE = state, /NO_COPY

END


    ;
    ; This function draws the spirograph and cams if needed
    ; Called when the user hits the Draw/Stop button
    ;
PRO DrawSpiroCW, spiroCW, NOERASE = noerase, CAMSPEED=camSpeed, STOP=stop

   drawWidget = WIDGET_INFO(spiroCW, /CHILD)
     ; /NO_COPY kills the old uvalue
   WIDGET_CONTROL, drawWidget, GET_UVALUE = state, /NO_COPY

     ; If stopping the animation - user hit the stop button (i.e. Draw/Stop button)
   IF KEYWORD_SET(stop) THEN $
        ; Reset timer flag to indicate that the animation has stopped
      state.timerSet = 0 $
   ELSE BEGIN
      WSET, state.spiroGraphPixmap

      IF NOT KEYWORD_SET(noerase) THEN ERASE

        ; If showCams is true
      IF (state.showCams NE 0) THEN BEGIN

           ; Draw spirograph segments at timer intervals to in order
           ; to animate the cam rotation.  A frame of the animation
           ; will be drawn at each timer event. When the timer event occurs
           ; in the spiroCW event handler, "SpiroEventHdlrCW", the drawing
           ; routine "DrawSpirographAndCam" is called to draw a segment of
           ; the spirograph and to display the next rotation of the cams. Also
           ; the next timer event is established.

           ; If timer not already in progress - set timer
         IF (state.timerSet EQ 0) THEN BEGIN
              ; Set timer flag to keep track if its been set
            state.timerSet = 1

              ; Establish a timer event to occur after a specific delay time
            WIDGET_CONTROL, spiroCW, TIMER=state.delay

         ENDIF
      ENDIF ELSE BEGIN
           ; Not drawing cams -
           ; There is no animation in this case. Just draw complete spirograph
           ; directly to display.
         DrawSpirograph, state

           ; Reset camangles back to zero
         state.camAngle = 0.0
         state.penAngle = 0.0

      ENDELSE
   ENDELSE
     ; Restore the state
   WIDGET_CONTROL, drawWidget, SET_UVALUE = state, /NO_COPY

END

;================================================================================
;
;  The following two routines create the Spiro widget application and handles events.
;
;  SpiroEventHdlr       - Process events for the Spiro widget application
;  Spiro                - Create the Spiro widget application. This includes
;                         creating a window and all of the controls including
;                         the spirograph compound widget that keeps track
;                         of drawing and animating the spirograph.
;
;================================================================================

    ;
    ; Process events to the spirograph application
    ;
PRO SpiroEventHdlr, event
  COMMON spiroCommon, cwSpiroWindow, cwPenColor, cFixedRadius, $
            cRotatingRadius, cPenRadius, cPenColor, cLineStyle, cShowTheCams, $
            cwDrawBase, cCamSpeed, cwCamSpeed, cwDrawButton

   WIDGET_CONTROL, event.id, GET_UVALUE=uValue

   swin = !D.WINDOW

   CASE (uValue) OF

           ; A "Line Style" radio button group event occurred.
      0: cLineStyle = event.value

           ; A "Fixed Cam Radius" slider event occurred
      3: cFixedRadius = event.value

           ; A "Rotating Cam Radius" slider event occurred
      4: cRotatingRadius = event.value

           ; A "Pen Radius" (in rotating cam) slider event occurred
      5: cPenRadius = event.value

           ; A "Pen Color" slider event occurred
      6: cPenColor = event.value

           ; A "Show Cams" Checkbox event occurred
      7: BEGIN
         cShowTheCams = event.select
           ; Only enable the CamSpeed slider if the cams
           ; are visible. Otherwise the spirograph is drawn
           ; in one draw action (PLOTS call)
         WIDGET_CONTROL, cwCamSpeed, SENSITIVE=cShowTheCams
         END

           ; A "Cam Speed" slider event occurred
      8: cCamSpeed = event.value

           ; A "Draw/Stop" pushbutton event occurred
      9: BEGIN

         WIDGET_CONTROL, event.id, GET_VALUE=buttonText

         IF buttonText EQ 'Draw' THEN BEGIN

              ; If currently not drawing - start drawing
            DrawSpiroCW, cwDrawBase, /NOERASE, CAMSPEED=cCamSpeed

              ; If the cams are visible - the draw will be animated
              ; In order to allow the user to stop the animation
              ; change the "Draw" button to a "Stop" button
            IF (cShowTheCams EQ 1) THEN $
               WIDGET_CONTROL, event.id, SET_VALUE='Stop'

         ENDIF ELSE $
              ; If the button label is not "Draw" it must be
              ; "Stop". Therefore tell the Spirograph compound widget
              ; to stop the animation.
            DrawSpiroCW, cwDrawBase, /STOP

         END

            ; An "Erase" pushbutton event occurred -
            ; Erase the spirograph.
      10: EraseSpiroCW, cwDrawBase

            ; A CreateSpiroCW compound widget event occurred
            ; This event occurs when the animated drawing has completed.
            ; Therefore set the "Stop" button back to a "Draw" button.
      11: WIDGET_CONTROL, cwDrawButton, SET_VALUE='Draw'

   ENDCASE

      ; Set new parameters and draw spirograph
   UpdateSpiroCW, cwDrawBase, cFixedRadius, cRotatingRadius, cPenRadius, $
     COLOR=cPenColor, LINESTYLE=cLineStyle, SHOWCAMS=cShowTheCams, $
     CAMSPEED=cCamSpeed

   WSET, swin
END


    ;
    ; Clean up after the spirograph application. Restore the previous
    ; color table and the background color
    ;
PRO CleanUpSpiro, wSpiroWindow

     ; Get the color table saved in the window's user value
   WIDGET_CONTROL, wSpiroWindow, GET_UVALUE=previousState
   
     ; Restore the previous color table.
   TVLCT, previousState.colorTable

     ; Restore the previous background color.
   !P.BACKGROUND = previousState.backgroundColor
   
END


    ;
    ; Create the spirograph window
    ;
PRO Spiro, GROUP = group

   COMMON spiroCommon

     ; If "Spiro" is already running (registered with the Xmanager)
     ; exit back to where it was called from.
   IF (XREGISTERED('SPIRO')) THEN $
      RETURN      ; Only one copy at a time

   swin = !D.WINDOW		; Save default window

    ; Get the current color vectors to restore when this application is exited.
   TVLCT, savedR, savedG, savedB, /GET
     ; Build color table from color vectors
   colorTable = [[savedR],[savedG],[savedB]]
   
     ; Save the current background color in order to restore it when
     ; the spiro application is exited
   backgroundColor = !P.BACKGROUND
   
     ; Save items to be restored on exit in a structure
   previousState = {colorTable:colorTable, backgroundColor:backgroundColor}
   
     ; Create the strings for the LineStyle radiobutton group.
   lineStyleStrings = ['Solid', 'Dotted', 'Dashed', 'Dash Dot', $
                       'Dash Dot Dot', 'Long Dashes' ]
                       
     ; Set up some initial values for the spirograph widgets
   cFixedRadius = 24
   cRotatingRadius = 10
   cPenRadius = 41
   cCamSpeed = 10   ; Initial draw speed of cams set to maximum speed
   cShowTheCams = 1   ; Initially show the cams

     ; Load a particular color table so we can have a good idea of
     ; the colors we're working with
   loadct, 39, /SILENT

     ; Initialize the background color to white
   !P.BACKGROUND = GetColor(!D.TABLE_SIZE - 1)

     ; Initialize the pen color table index to red
   cPenColor = !D.TABLE_SIZE - 2
   
     ; Save the default plotting line style
   cLineStyle = !P.LINESTYLE

     ; Create the main window - non-sizable
   cwSpiroWindow = WIDGET_BASE(TITLE='Spirographics', XOFFSET=30, $
                    YOFFSET=30, /ROW, TLB_FRAME_ATTR=1)

    ; Setting the managed attribute indicates our intention to put this app
    ; under the control of XMANAGER, and prevents our draw widgets from
    ; becoming candidates for becoming the default window on WSET, -1. XMANAGER
    ; sets this, but doing it here prevents our own WSETs at startup from
    ; having that problem.
   WIDGET_CONTROL, /MANAGED, cwSpiroWindow

     ; Create the base to hold the spirograph controls
   wControlBase = WIDGET_BASE(cwSpiroWindow, /ROW)

     ; Create the compound spiro widget - draw widget and parameters
   cwDrawBase = CreateSpiroCW(cwSpiroWindow, UVALUE=11, $
                              XSIZE=256, YSIZE=256)

     ; Create base for the spirograph parameters - all sliders
   wSliderBase = WIDGET_BASE(wControlBase, /COLUMN)

     ; Create slider control to set the fixed cam radius
   wFixedRadius = WIDGET_SLIDER(wSliderBase, TITLE='Fixed Cam Radius', $
                                VALUE=cFixedRadius, /DRAG, UVALUE=3)

     ; Create slider control to set the rotating cam radius
   wRotatingRadius = WIDGET_SLIDER(wSliderBase, TITLE='Rotating Cam Radius', $
                   VALUE = cRotatingRadius, MAX = 100, MIN=1, /DRAG, UVALUE=4)

     ; Create slider control to set the pen radius in the rotating cam
   wPenRadius = WIDGET_SLIDER(wSliderBase, TITLE='Pen Radius', $
                              VALUE=cPenRadius, /DRAG, UVALUE=5)

     ; Create slider control to set the pen color
   cwPenColor = WIDGET_SLIDER(wSliderBase, TITLE='Pen Color', $
                              /DRAG, MAX = !D.TABLE_SIZE-2, UVALUE=6)
   
     ; Set the "Pen Color" slider value to reflect the current pen color table index
   WIDGET_CONTROL, cwPenColor, SET_VALUE = cPenColor

     ; Create base for linestyle, showCams checkbox, and cam speed control
   wButtonBase = WIDGET_BASE(wControlBase, /COLUMN)

     ; Create linestyle exclusive base
   wLinestyleBase = CW_BGROUP(wButtonBase, lineStyleStrings, /COLUMN, $
                              /EXCLUSIVE, /FRAME, SET_VALUE=0, UVALUE=0, $
                              /NO_RELEASE, LABEL_TOP = "Line Style:")

     ; Create "showCams" checkbox nonexclusive base
   wChkBoxBase = WIDGET_BASE(wButtonBase, /COLUMN, /NONEXCLUSIVE)

     ; Create "showCams" checkbox
   wShowCams = WIDGET_BUTTON(wChkBoxBase, VALUE='Show Cams', UVALUE=7)
     ; Set up the initial value of the checkbox
   WIDGET_CONTROL, wShowCams, SET_BUTTON = cShowTheCams

     ; Create cam speed slider
   cwCamSpeed = WIDGET_SLIDER(wButtonBase, TITLE='Cam Speed', VALUE=cCamSpeed, $
                              MAX = 10, MIN=1, /DRAG, UVALUE=8)

     ; Add base and pushbuttons to Draw and Erase
   wPushButtonBase = WIDGET_BASE(wSliderBase, /ROW, YPAD=20)

     ; Create "Draw/Stop" button.
     ; This button we read "Draw" when the spirograph is not drawing,
     ; and "Stop" during drawing operations
   cwDrawButton = WIDGET_BUTTON(wPushButtonBase, VALUE='Draw', UVALUE=9)

     ; Create "Erase" button
   wEraseButton = WIDGET_BUTTON(wPushButtonBase, VALUE='Erase', UVALUE=10)

     ; Save the previous color table in the user value to retore on exit
   WIDGET_CONTROL, cwSpiroWindow, SET_UVALUE=previousState
   
     ; Make the window visible
   WIDGET_CONTROL, /REALIZE, cwSpiroWindow  ; Show the window

     ; Setup the device to use the pointer cursors
   DEVICE, /CURSOR_ORIGINAL

     ; Erase the Spirograph to update the draw areas background color
   EraseSpiroCW, cwDrawBase

     ; Set the spirograph parameters and draw the cams
   UpdateSpiroCW, cwDrawBase, cFixedRadius, cRotatingRadius, cPenRadius, $
             COLOR = cPenColor, LINESTYLE = cLineStyle, SHOWCAMS=cShowTheCams,$
             CAMSPEED=cCamSpeed

   WSET, swin				; Restore default window

   XMANAGER, 'SPIRO', cwSpiroWindow, GROUP_LEADER = GROUP, $
     EVENT_HANDLER="SpiroEventHdlr", CLEANUP="CleanUpSpiro", /NO_BLOCK
END


