;  $Id:$

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;-------------------------------------------------------------
; Simple Multi-Monitor Example
;
; This program displays a "splash screen" centered on the
; primary monitor.  It also displays a trivial GUI widget
; "application" at an offset of [100, 100] on the nth monitor.
;
; This program is designed to work in both Windows and X
; environments with any number of monitors.
;-------------------------------------------------------------

; Event handler for shutdown.
PRO multimon_ex1_event, ev
   WIDGET_CONTROL, ev.top, GET_UVALUE=pState
   WIDGET_CONTROL, ev.id, GET_UVALUE=uval
   CASE uval OF
   "EXIT": BEGIN
      DEVICE, DECOMPOSED=(*pState).decomp
      base = (*pState).wBase
      PTR_FREE, pState
   WIDGET_CONTROL, base, /DESTROY
   ENDCASE
   ELSE:
   ENDCASE
END

PRO multimon_ex1

   ; Get Monitor information
   oInfo = OBJ_NEW('IDLsysMonitorInfo')
   numMons = oinfo->GetNumberOfMonitors()
   names = oinfo->GetMonitorNames()
   rects = oInfo->GetRectangles()
   primaryIndex = oInfo->GetPrimaryMonitorIndex()
   OBJ_DESTROY, oInfo

   ; Read image for splash screen
   imageFile = FILEPATH('examples.tif', SUBDIRECTORY=['examples', 'data'])
   image = READ_TIFF(imageFile, r, g, b, ORIENTATION=orientation)

   ; Compute splash screen parameters
   primaryRect = rects[*, primaryIndex]
   splashSize = SIZE(image, /DIMENSIONS)
   splashLoc = primaryRect[0:1] + primaryRect[2:3] $
      / 2 - splashSize / 2

   ; Define a message to display int he "main" GUI
   textblock = [" This example application displays a splash screen", $
                " on the system's primary monitor and this interface", $
                " on the highest numbered monitor available."]

   ; Set up "main" GUI to display at [100,100] on the nth monitor
   main = WIDGET_BASE(/COL, DISPLAY_NAME=names[numMons-1], $
      XOFFSET=rects[0, numMons-1] + 100, $
      YOFFSET=rects[1, numMons-1] + 100, $
      TITLE='Main')
   text = WIDGET_TEXT(main, VALUE=textblock, $
      XSIZE=STRLEN(textblock[1]), YSIZE=3)
   button = WIDGET_BUTTON(main, VALUE='Exit', UVALUE='EXIT')

   ; Set up splash screen
   splash = WIDGET_BASE(/COL, DISPLAY_NAME=names[primaryIndex], $
      GROUP_LEADER=main, $
      TLB_FRAME_ATTR = 1+2+4+8+16, $
      XOFFSET=splashLoc[0], YOFFSET=splashLoc[1], $
      TITLE='Splash Screen')
   draw = WIDGET_DRAW(splash, $
      XSIZE=splashSize[0], YSIZE=splashSize[1])

   ; Put up splash
   WIDGET_CONTROL, splash, /REALIZE
   WIDGET_CONTROL, draw, GET_VALUE=index
   WSET, index
   DEVICE, GET_DECOMPOSED=decomp
   DEVICE, DECOMPOSED=0
   TVLCT, r, g, b
   order = 0
   IF orientation EQ 0 OR orientation EQ 4 THEN $
      order = 1
   TV, image, ORDER=order

   ; Pause with just splash screen up, then start main GUI.
   WAIT, 2
   WIDGET_CONTROL, main, /REALIZE
   ; A real application would probably remove the splash
   ; screen after realizing the main GUI:
   ; WIDGET_CONTROL, splash, /DESTROY

   sState = {wBase: main, decomp: decomp}
   pState = PTR_NEW(sState, /NO_COPY)
   WIDGET_CONTROL, main, SET_UVALUE=pState
   XMANAGER, 'multimon_ex1', main

END
