; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/object_examples.pro#2 $
;
; Copyright (c) 1995-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME: Examples
;
; PURPOSE: This widget application guides the user through the IDL
;          family of technical widget programming examples.
;
; MAJOR TOPICS: Launching widget applications.
;
; CALLING SEQUENCE: Examples
;
; PROCEDURE: Examples ...
;
; MAJOR FUNCTIONS and PROCEDURES:
;
; MODIFICATION HISTORY:  Written by:  WSO, RSI, January 1995
;-

PRO ExamplesEventHdlr, event

; This is the event processing routine that takes care of the events being
; sent to it from the XManager.

   WIDGET_CONTROL, GET_UVALUE=control, event.id

   CASE control OF

     "INFO": BEGIN

         infoText = [ $
          "This application shows some of the capabilities of IDL using "+ $
          "widgets.  Each section shows ways "+ $
          "IDL can be used to easily view data using widgets as the "+ $
          "user interface. ", "", $
          'The "Examples" pull-down menu contains a menu item for each '+ $
          "widget application example. ", "", $
          "The data in this file has all been gathered from people "+ $
          "using IDL or has been generated using IDL.  For more "+ $
          "information on the data in each example select the info... button "+ $
          "option in that example to learn more. ", "", $
          "All computations are performed on your workstation as "+ $
          "you watch.  The source code for all examples and "+ $
          "computations is contained in the $IDL_DIR/examples directory "+ $
          "tree.  All user interfaces and computations are "+ $
          "programmed using only standard IDL.  No displays or "+ $
          "visualizations are pre-computed.  Only one IDL process is "+ $
          "active."]

         ShowInfo, TITLE="Examples Information", GROUP=event.top, $
           WIDTH=80, HEIGHT=24, INFOTEXT=infoText
      ENDCASE

     "EXIT": WIDGET_CONTROL, event.top, /DESTROY

        ; User selected an item from the Examples menu -
        ; execute the proper procedure that was stored in the user value
        ; for each menu item.
      ELSE:  returnValue = EXECUTE(control + ', GROUP=event.top')

   ENDCASE
END


PRO CleanUpExamples, wExamplesWindow

     ; Get the color table saved in the window's user value
   WIDGET_CONTROL, wExamplesWindow, GET_UVALUE=colorTable

     ; Restore the previous color table.
   TVLCT, colorTable

END


PRO object_examples

; This is the main program that creates the widgets for the examples and then
; registers it with the xmanager.

   swin = !D.WINDOW		; Save current window

     ; Get the current color vectors to restore when this application is exited.
   TVLCT, savedR, savedG, savedB, /GET
     ; Build color table from color vectors
   colorTable = [[savedR],[savedG],[savedB]]

     ; Create a non-sizeable window for the Examples widget application
   wExamplesWindow = WIDGET_BASE(TITLE="IDL Examples", MBAR=wMenuBar, TLB_FRAME_ATTR=1)

   ; Setting the managed attribute indicates our intention to put this app
   ; under the control of XMANAGER, and prevents our draw widgets from
   ; becoming candidates for becoming the default window on WSET, -1. XMANAGER
   ; sets this, but doing it here prevents our own WSETs at startup from
   ; having that problem.
   WIDGET_CONTROL, /MANAGED, wExamplesWindow

   wExamplesBase = WIDGET_BASE(wExamplesWindow, /COLUMN)

   wFileMenu = WIDGET_BUTTON(wMenuBar, VALUE='File', /MENU)
   wExitItem = WIDGET_BUTTON(wFileMenu, VALUE='Exit Examples', UVALUE='EXIT')

   wExamplesMenu = WIDGET_BUTTON(wMenuBar, VALUE='Examples', /MENU)
   wExamplesItem = WIDGET_BUTTON(wExamplesMenu, VALUE='Line Drawing...', UVALUE='SPIRO')
   wExamplesItem = WIDGET_BUTTON(wExamplesMenu, VALUE='Surface Drawing...', UVALUE='SPRING')
   wExamplesItem = WIDGET_BUTTON(wExamplesMenu, VALUE='Text Editing...', UVALUE='EDITOR')

   wHelpMenu = WIDGET_BUTTON(wMenuBar, VALUE='Help', /HELP, /MENU)
   wInfoItem = WIDGET_BUTTON(wHelpMenu, VALUE='Examples Info...', UVALUE='INFO')

     ; Read the logo for the Examples window draw widget
   logo = READ_TIFF(FILEPATH("examples.tif", SUBDIRECTORY = ["examples","data"]), $
                    logoR, logoG, logoB, ORDER=order)

     ; Get the dimensions of the logo in order to create the draw widget
   logoSize = SIZE(logo)

     ; Create the draw widget to match the size of the logo TIFF image
   wLogo = WIDGET_DRAW(wExamplesBase, XSIZE = logoSize[1], YSIZE = logoSize[2], RETAIN = 2)

     ; Make the window visible
   WIDGET_CONTROL, /REALIZE, wExamplesWindow

     ; Set cursor to arrow cursor
   DEVICE, /CURSOR_ORIGINAL

     ; Save the previous color table in the user value to retore on exit ("CleanUpExamples")
   WIDGET_CONTROL, wExamplesWindow, SET_UVALUE=colorTable

     ; Display the wait cursor
   WIDGET_CONTROL, wExamplesWindow, /HOURGLASS

   ; Display the logo in the draw widget
   logo = [[[logoR[logo]]], [[logoG[logo]]], [[logoB[logo]]]]
   TV, logo, ORDER=order, TRUE=3

   WSET, swin

     ; Register this application with the xmanager
   XManager, "object_examples", wExamplesWindow, EVENT_HANDLER="ExamplesEventHdlr", $
      CLEANUP="CleanUpExamples", /NO_BLOCK
END
