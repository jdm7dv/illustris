; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/spring.pro#2 $
;
; Copyright (c) 1991-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME: Spring
;
; PURPOSE: This example demonstrates the fundamental principles of statistical
;          time-series analysis.
;
; MAJOR TOPICS: Surface Drawing and Widgets.
;
; CALLING SEQUENCE: Spring
;
; PROCEDURE: Spring computes ...
;
; MAJOR FUNCTIONS and PROCEDURES:
;
; COMMON BLOCKS and STRUCTURES:
;       springCommon : This common block contains...
;
; MODIFICATION HISTORY:  Written by:  DMS, RSI, March 1991
;                        Modified by: WSO, RSI, January 1995
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


;----------------------------------------
   ; Draw square in mark window at cell (x,y)
PRO MarkSquare, x, y, color

     ; Grid is one fifth the size of the edit area
   x = x * 5
   y = y * 5

     ; Build square to mark spring location in edit area
   p0 = [x+1, y]
   p1 = [x+5, y+4]

   POLYFILL, [p0[0], p1[0], p1[0], p0[0]], [p0[1], p0[1], p1[1], p1[1]], $
     COLOR=GetColor(color), /DEVICE
END


;----------------------------------------
PRO DrawGrid

COMMON springCommon, cNumberOfFrames, cImageSize, cSpringStrength, $
                   cMaxSpringStrength, cGridSize, cMethodNames, $
                   cXAxisRotation, cZAxisRotation, cAxSlider, cAzSlider, $
                   cGrid, cViewDrawArea, cSpringDisplacement, cEditDrawArea, $
                   cEditDrawAreaID, cRenderMethod, cSpringWindow

   WSET, cEditDrawArea
   ERASE

   FOR iy = 0, 160, 5 DO $
      PLOTS,[0, 160], [iy, iy], COLOR=GetColor(180), /DEVICE   ;Draw the grid
   FOR ix=  0, 160, 5 DO $
      PLOTS,[ix, ix], [0, 160], COLOR=GetColor(180), /DEVICE

   FOR ix = 0, cGridSize-1 DO $
      FOR iy =  0, cGridSize-1 DO BEGIN
         IF (cGrid[ix, iy] LT 0.) OR (cGrid[ix, iy] GT 0.) THEN $
            MarkSquare, ix[0], iy[0], 0
      ENDFOR
END


PRO DrawShadedSquares, theScaledGrid, theDisplacementGrid, $
           minDisplacement, maxDisplacement

COMMON springCommon
      
   SURFR, AX=cXAxisRotation, AZ=cZAxisRotation      ;Set the scaling

   !X.S = [ 0, 1. / cGridSize ]
   !Y.S = !X.S
   !Z.S = [-minDisplacement, maxDisplacement] / $
                  (maxDisplacement - minDisplacement)
   ERASE

   del = 0.04         ;Fudge factor to cover surface

   px = [ -del, 1.+del, 1.+del, -del]   ;Basic polygon
   py = [ -del, -del, 1.+del, 1.+del]

   FOR iy = cGridSize-1, 0, -1 DO $
      FOR ix = 0, cGridSize-1 DO $ ;Draw squares
         POLYFILL, px+ix, py+iy, $
           REPLICATE(theDisplacementGrid[ix, iy], 4), /T3D, $
             COLOR=GetColor(theScaledGrid[ix,iy])
END


;----------------------------------------
; Draws spring frame
;
PRO DrawSurface, imageSize, DISPLACEMENTGRID=displacementGrid, $
          VELOCITYGRID=velocityGrid, $
          MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
          MAXVELOCITY=maxVelocity, MINVELOCITY=minVelocity

COMMON springCommon
      
   rebinSize = (imageSize / cGridSize) * cGridSize

   topColor = !D.TABLE_SIZE-1
      
   CASE cRenderMethod OF         ;Which rendering?
      
           ; Surface
      0: SURFACE, displacementGrid, $
           ZRANGE=[minDisplacement, maxDisplacement], $
           AX=cXAxisRotation, AZ=cZAxisRotation
         
           ; Shaded surface (light source)
      1: SHADE_SURF, displacementGrid, $
           ZRANGE=[minDisplacement, maxDisplacement], $
           AX=cXAxisRotation, AZ=cZAxisRotation

           ; Altitude shaded surface
      2: SHADE_SURF, displacementGrid, SHADES=BYTSCL(displacementGrid, $
           TOP=topColor, MIN=minDisplacement, MAX=maxDisplacement),$
           ZRANGE=[minDisplacement, maxDisplacement], $
           AX=cXAxisRotation, AZ=cZAxisRotation

           ; Velocity shaded surface
      3: SHADE_SURF, displacementGrid, SHADES=BYTSCL(velocityGrid, $
           TOP=topColor, MAX=maxVelocity, MIN=minVelocity),$
           ZRANGE=[minDisplacement, maxDisplacement], $
           AX=cXAxisRotation, AZ=cZAxisRotation

           ; Image of displacement
      4: TV, REBIN(BYTSCL(displacementGrid, MAX=maxDisplacement, $
                     MIN = minDisplacement), rebinSize, rebinSize)
         
           ; Image of velocity
      5: TV, REBIN(BYTSCL(velocityGrid, MAX=maxVelocity, $
                     MIN=minVelocity), rebinSize, rebinSize)
         
           ; Contour
      6: CONTOUR, displacementGrid, LEVELS=FINDGEN(16.)/8.-1., XSTYLE=5, $
           YSTYLE=5, C_COLORS=topColor * 0.5 * FINDGEN(16)/8.
         
           ; Squares by displacement
      7: BEGIN
         theScaledGrid = BYTSCL(displacementGrid, MIN=minDisplacement, $
               MAX=maxDisplacement, TOP=topColor)   ;shades

         DrawShadedSquares, theScaledGrid, displacementGrid, $
           minDisplacement, maxDisplacement

         ENDCASE         ; Squares by displacement
      
           ; Squares by velocity
      8: BEGIN   
         theScaledGrid = BYTSCL(ABS(velocityGrid), MIN=0, MAX=maxVelocity, $
                           TOP=topColor)
         DrawShadedSquares, theScaledGrid, displacementGrid, $
           minDisplacement, maxDisplacement
         ENDCASE         ; Squares by velocity

      ENDCASE
   
END


;----------------------------------------
; Does the calculations & drawing for spring animation
;
PRO DrawSpring, GROUP = group

COMMON springCommon

     ; Deactivate all window controls
   WIDGET_CONTROL, cSpringWindow, SENSITIVE = 0
      
     ; Starting displacements, allow for border reflection
   displacementGrid = FLTARR(cGridSize+2, cGridSize+2)
     ; Insert starting displacements
   displacementGrid[1,1] = cGrid
     ; Starting velocity
   velocityGrid = FLTARR(cGridSize+2, cGridSize+2)

     ; Set up animation
   XINTERANIMATE, SET=[cImageSize, cImageSize, cNumberOfFrames], $
            TITLE = cMethodNames[cRenderMethod], /SHOWLOAD, /CYCLE, /TRACK

   currentWindow = !D.WINDOW
   ERASE

     ; Do all at once, displacement
   displacementFrames = FLTARR(cGridSize, cGridSize, cNumberOfFrames, /NOZERO)
   velocityFrames = displacementFrames            ;Velocity
   
     ; Make kernel for convolution
   sq21 = 1./SQRT(2)
   kernel = cSpringStrength * [[ sq21, 1, sq21], [1, 0, 1], [sq21, 1, sq21]]
   kernel[1,1] = -TOTAL(kernel)

   FOR iteration = 0, cNumberOfFrames-1 DO BEGIN   ;Each iteration
        ; Calculate new velocity
      velocityGrid = velocityGrid + CONVOL(displacementGrid, kernel)
        ; Calculate new displacement
      displacementGrid = displacementGrid + velocityGrid
        ; Save for scaling
      velocityFrames[0, 0, iteration] = velocityGrid[1:cGridSize, 1:cGridSize]

      displacementFrames[0, 0, iteration] = $
        displacementGrid[1:cGridSize, 1:cGridSize]
   ENDFOR
   
     ; Get scaling
   maxVelocity = MAX(velocityFrames, MIN=minVelocity)
   maxDisplacement = MAX(displacementFrames, MIN=minDisplacement)

   FOR iteration = 0, cNumberOfFrames-1 DO BEGIN  ; Each frame

      displacementGrid = displacementFrames[*,*,iteration]
      velocityGrid = velocityFrames[*,*,iteration]
   
      DrawSurface, cImageSize, DISPLACEMENTGRID=displacementGrid, $
        VELOCITYGRID=velocityGrid, $
        MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
        MAXVELOCITY=maxVelocity, MINVELOCITY=minVelocity
          
      XINTERANIMATE, FRAME=iteration, WINDOW=currentWindow
   ENDFOR

     ; Active the window controls again
   WIDGET_CONTROL, cSpringWindow, SENSITIVE = 1
   XINTERANIMATE, GROUP = group, 20

END



;----------------------------------------
PRO SpringEvent, event

COMMON springCommon

     ; Find the user value of the widget where the event occured
   WIDGET_CONTROL, event.id, GET_UVALUE = widgetName     

   CASE widgetName OF
     "METHOD_GROUP": BEGIN

         cRenderMethod = event.index

           ; If render method is "Displacement Image" or "Velocity Image" or
           ; "Contour Plot" then disable x and z axis rotation since they're
           ; only 2 dimensional
         IF (cRenderMethod GE 4 AND cRenderMethod LE 6) THEN BEGIN
            WIDGET_CONTROL, cAxSlider, SENSITIVE=0
            WIDGET_CONTROL, cAzSlider, SENSITIVE=0
         ENDIF ELSE BEGIN
            WIDGET_CONTROL, cAxSlider, SENSITIVE=1
            WIDGET_CONTROL, cAzSlider, SENSITIVE=1
         ENDELSE

         swin = !D.WINDOW
         WSET, cViewDrawArea

         maxDisplacement = MAX(cGrid, MIN=minDisplacement)

         DrawSurface, 192, DISPLACEMENTGRID=cGrid, VELOCITYGRID=cGrid, $
           MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
           MAXVELOCITY=maxDisplacement, MINVELOCITY=minDisplacement
         WSET, swin
      ENDCASE
         
     "KSPRING_SLIDER": cSpringStrength = event.value * cMaxSpringStrength / 100
     
     "NUM_FRAMES_SLIDER": cNumberOfFrames = event.value

     "MARK_DRAW_AREA": BEGIN

         IF event.press EQ 0 THEN $
            RETURN   ; Ignore release

         swin = !D.WINDOW
         WSET, cEditDrawArea

         p = [ event.x/5, event.y/5 ] 
         p[0] = FIX(p[0]) > 0 < (cGridSize-1)
         p[1] = FIX(p[1]) > 0 < (cGridSize-1)

         IF (cGrid[p[0], p[1]] EQ 0) THEN BEGIN ; Mark???
            cGrid[p[0], p[1]] = cSpringDisplacement/100.
            MarkSquare, p[0], p[1], 0 ; Draw in black mark
         ENDIF ELSE BEGIN
            cGrid[p[0], p[1]] = 0.
            MarkSquare, p[0], p[1], !D.TABLE_SIZE-1  ; Erase old - with white mark
         ENDELSE

         WSET, cViewDrawArea

         maxDisplacement = MAX(cGrid, MIN=minDisplacement)

         DrawSurface, 192, DISPLACEMENTGRID=cGrid, VELOCITYGRID=cGrid, $
           MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
           MAXVELOCITY=maxDisplacement, MINVELOCITY=minDisplacement

         WSET, swin

      ENDCASE
     
     "HTSLIDER" :  cSpringDisplacement = event.value

     "AX_SLIDER" : BEGIN

         cXAxisRotation = event.value

	 swin = !D.WINDOW
         WSET, cViewDrawArea

         maxDisplacement = MAX(cGrid, MIN=minDisplacement)

         DrawSurface, 192, DISPLACEMENTGRID=cGrid, VELOCITYGRID=cGrid, $
           MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
           MAXVELOCITY=maxDisplacement, MINVELOCITY=minDisplacement
         WSET, swin

      ENDCASE
         
     "AZ_SLIDER" : BEGIN

         cZAxisRotation = event.value

	 swin = !D.WINDOW
         WSET, cViewDrawArea

         maxDisplacement = MAX(cGrid, MIN=minDisplacement)

         DrawSurface, 192, DISPLACEMENTGRID=cGrid, VELOCITYGRID=cGrid, $
           MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
           MAXVELOCITY=maxDisplacement, MINVELOCITY=minDisplacement
	 WSET, swin
      ENDCASE

     "ANIMATE" : $
         IF XREGISTERED("XInterAnimate") EQ 0 THEN $
            DrawSpring, GROUP=event.top
     
     "INFO" : BEGIN

         infoText = [ $
          "The Spring example is a dynamic simulation of a "+ $
          "rectangular grid of weights connected by springs.  The "+ $
          "results may be visualized by a number of methods, "+ $
          "illustrating some of the many ways of displaying data with IDL. ", "", $
          "Pressing the Animate button starts the simulation from an "+ $
          "initial starting grid.  The initial Z position of the "+ $
          'weights may be edited. To edit, set the "Spring Displacement"'+ $
          "to the new Z value (range: -100 to 100), and click on the cell's position "+ $
          "in the left hand grid.  The X and "+ $
          "Y position of the weights is fixed.  The strength of "+ $
          "the springs may be varied, as well as a number of "+ $
          "viewing and simulation parameters. ", "", $
          "WARNING: this example can easily exhaust the memory / swap "+ $
          "space resources of small or improperly configured machines. ", "", $
          "**** CONTROLS **** ", "", $
          "Animate button: starts the simulation from the starting "+ $
          "grid.  Each frame is rendered and the XINTERANIMATE "+ $
          "procedure is called to animate the results. ", "", $
          "Info... button:  Displays this text. ", "", $
          "Rendering Methods: select a method, by clicking in the drop list. ", "", $
          "Spring Strength slider: Sets the spring coefficient.  A "+ $
          "higher setting makes the springs stronger in relation "+ $
          "to the weights.  Higher settings result in more "+ $
          "movement; lower settings result in smoother simulations.  ", "", $
          "X axis rotation slider: Controls the rotation about the "+ $
          "X axis for the 3D displays. ", "", $
          "Z axis rotation slider: Controls the rotation about the "+ $
          "Z axis for 3D displays. ", "", $
          "Number of frames: The number of animation frames in the "+ $
          "animation.  The amount of display memory is "+ $
          "proportional to this number.  WARNING: this demo can "+ $
          "easily exhaust the memory / swap space resources of small machines. "]

         ShowInfo, TITLE="Spring Example Information", GROUP=event.top, WIDTH=80,$
           HEIGHT=24, INFOTEXT=infoText
         ENDCASE
         
      ELSE: $ ; When an event occurs in a widget that has no user value in this
              ; case statement, an error message is shown
         MESSAGE, "Event User Value Not Found"      

   ENDCASE
   
END ;============= end of Spring event handling routine task =============


PRO CleanUpSpring, wSpringWindow

     ; Get the color table saved in the window's user value
   WIDGET_CONTROL, wSpringWindow, GET_UVALUE=previousState
   
     ; Restore the previous color table.
   TVLCT, previousState.colorTable

     ; Restore the previous background color.
   !P.BACKGROUND = previousState.backgroundColor

     ; Restore the previous pen color.
   !P.COLOR = previousState.penColor
END


;----------------------------------------
PRO Spring, GROUP = group

COMMON springCommon

   IF XREGISTERED("Spring") THEN $
      RETURN      ;only one instance

   IF XREGISTERED("XInterAnimate") THEN BEGIN
      tmp = DIALOG_MESSAGE(/ERROR, ['Can''t run Surface Drawing Demo.', ' ', $
      			   'Only one animation can be active at a time.' ])
      RETURN
   ENDIF

   swin = !D.WINDOW

     ; Get the current color vectors to restore when this application is exited.
   TVLCT, savedR, savedG, savedB, /GET
   
     ; Save items to be restored on exit in a structure
   previousState = {colorTable: [[savedR],[savedG],[savedB]], $
                    backgroundColor: !P.BACKGROUND, $
                    penColor: !P.COLOR}
   
     ; Remove axis from all plots
   !X.STYLE = 4
   !Y.STYLE = 4
   !Z.STYLE = 4
   !X.MARGIN = 0
   !Y.MARGIN = 0

     ; Set up defaults and constants:
   IF N_ELEMENTS(cNumberOfFrames) LE 0 THEN BEGIN
      cNumberOfFrames = 16     ; Initial values
      cImageSize = 256         ; Size of spring animation draw widget
      cMaxSpringStrength = 0.2 ; Largest possible spring const
      cSpringStrength = 0.05   ; Initialize spring const
      cGridSize = 32           ; Initialize grid size
      cEditDrawAreaID = 0

      cGrid = FLTARR(cGridSize, cGridSize)  ; Starting grid
      cGrid[cGridSize/3, cGridSize/3] = 1.
   
      cSpringDisplacement = 100
      
      cMethodNames = [ $
         "Mesh Surface",$
         "Light Source Shaded Surface", $
         "Displacement Shaded Surface", $
         "Velocity Shaded Surface",$
         "Displacement Image",$
         "Velocity Image",$
         "Contour Plot", $
         "Displacement Shaded Squares",$
         "Velocity Shaded Squares"]

      cXAxisRotation = 15         ;X axis rotation
      cZAxisRotation = 20         ;Z axis rotation
   ENDIF 

     ; Initial rendering method is here to longest name to force
     ; menu to the largest size
   cRenderMethod = 1 

   LOADCT, 0, /SILENT

     ; Initialize the background to white
   !P.BACKGROUND = GetColor(!D.TABLE_SIZE-1)
     ; Initialize the pen color to black
   !P.COLOR = GetColor(0)

     ; Create the main window
   cSpringWindow = WIDGET_BASE(TITLE="Spring Example", XOFFSET=10, YOFFSET=10)

   topBase = WIDGET_BASE(cSpringWindow, /COLUMN)

   drawBase = WIDGET_BASE(topBase, /ROW)

   gridBase = WIDGET_BASE(drawBase, /COLUMN)

   editDrawLabel = WIDGET_LABEL(gridBase, VALUE='Click to add springs:')

   cEditDrawAreaID = WIDGET_DRAW(gridBase, XSIZE=161, YSIZE=161, $
                       /BUTTON_EVENTS, RET=2, UVALUE='MARK_DRAW_AREA')

   viewDrawAreaID = WIDGET_DRAW(drawBase, XSIZE=192, YSIZE=192, RET=2)

   menuBase = WIDGET_BASE(topBase, /ROW)

     ; Create the method drop list
   methodButtonBase = WIDGET_DROPLIST(menuBase, VALUE=cMethodNames, $
                        UVALUE='METHOD_GROUP', TITLE='Rendering Method:')

     ; Set the drop list to the current method
   WIDGET_CONTROL, methodButtonBase, SET_DROPLIST_SELECT=cRenderMethod

   controlBase = WIDGET_BASE(topBase, /COLUMN)
      
   viewParameterBase = WIDGET_BASE(controlBase, /ROW)
   
   displacementSlider = WIDGET_SLIDER(viewParameterBase, XSIZE=120, $
                          MINIMUM=-100, MAXIMUM=100, $
                          TITLE='Spring Displacement', $
                          VALUE=cSpringDisplacement, UVALUE='HTSLIDER')
   
   cAxSlider = WIDGET_SLIDER(viewParameterBase, XSIZE=120, MINIMUM=-90, $
                 MAXIMUM=90, VALUE=cXAxisRotation, TITLE='X axis rotation', $
                 UVALUE="AX_SLIDER")
   
   cAzSlider = WIDGET_SLIDER(viewParameterBase, XSIZE=120, MINIMUM=0, $
                 MAXIMUM=90, VALUE=cZAxisRotation, TITLE='Z axis rotation', $
                 UVALUE="AZ_SLIDER")
   
   animateParameterBase = WIDGET_BASE(controlBase, /ROW)

   strengthSlider = WIDGET_SLIDER(animateParameterBase, XSIZE=120, MINIMUM=1, $
                      MAXIMUM=100, $
                      VALUE=100*cSpringStrength/cMaxSpringStrength, $
                      TITLE='Spring Strength', UVALUE="KSPRING_SLIDER")
   
   numFramesSlider = WIDGET_SLIDER(animateParameterBase, XSIZE=120, $
                       MINIMUM=2, MAXIMUM=40, VALUE=cNumberOfFrames, $'
                       TITLE='Number of frames', UVALUE="NUM_FRAMES_SLIDER")

     ; Add base and pushbuttons to Draw and Erase
   PushButtonBase = WIDGET_BASE(animateParameterBase, /COLUMN, XPAD=20)

     ; Create "Animate" button
   animateButton_w = WIDGET_BUTTON(PushButtonBase, VALUE='Animate',$
           UVALUE='ANIMATE')
           
     ; Create "Info..." button
   infoButton_w = WIDGET_BUTTON(PushButtonBase, VALUE='Info...', UVALUE='INFO')

     ; Display the window and save the previous color table in 
     ; the user value to retore on exit 
   WIDGET_CONTROL, cSpringWindow, /REALIZE, SET_UVALUE=previousState
   
   WIDGET_CONTROL, viewDrawAreaID, GET_VALUE = cViewDrawArea

   WIDGET_CONTROL, cEditDrawAreaID, GET_VALUE = cEditDrawArea
   
   DrawGrid               ;Show the editing grid

   WSET, cViewDrawArea

   maxDisplacement = MAX(cGrid, MIN=minDisplacement)

   DrawSurface, 192, DISPLACEMENTGRID=cGrid, VELOCITYGRID=cGrid, $
     MAXDISPLACEMENT=maxDisplacement, MINDISPLACEMENT=minDisplacement, $
     MAXVELOCITY=maxDisplacement, MINVELOCITY=minDisplacement

   WSET, swin

   XMANAGER, "Spring", cSpringWindow, EVENT_HANDLER = "SpringEvent", $
         GROUP_LEADER = group, CLEANUP="CleanUpSpring", /NO_BLOCK
END
