; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wpdmenu.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple pull-down menu. Pulldown menus
; can appear in menubars or in standalone buttons. This example
; shows both forms using two buttons labeled "Colors" and "Quit".
; If "Colors" is selected, a pull-down menu appears.  Selecting a
; color causes its name to be printed in the IDL window.  If "Quit"
; is selected, the widget is destroyed.


PRO wpdmenu_event, event
; This procedure is the event handler for a simple pull-down menu. 

; If Quit is pressed, destroy all widgets:

IF (event.value EQ 'Quit') THEN WIDGET_CONTROL, event.top, /DESTROY

; For Menu items, any VALUE returned will be the text of the menu item.
; Therefore, we can just print out the words in the IDL window as they
; are selected:

PRINT, event.value, ' selected.'

END



PRO wpdmenu, GROUP = GROUP

; This COMMON block is not really necessary if we only have a menu:

COMMON wpdmenublock, hi

; Make the top-level base widget:

base = WIDGET_BASE(TITLE = 'Pull-Down Menu Example', /COLUMN, XSIZE = 300, $
                   MBAR = mbar)

; The CW_PdMenu procedure will automatically create the menu items for us.
; We only have to give it the menu item labels. We do it twice, once in
; the menubar and once for standalone buttons.

menu_desc = ['1\File', $
             '2\Quit', $
             '1\Colors', $
             '1\Red', $
             '0\Candy Apple', $
             '0\Medium', $
             '2\Dark', $
             '0\Orange', $
             '2\Yellow']

menu = CW_PdMenu(mbar, /RETURN_NAME, menu_desc, UVALUE='THEMENU', /MBAR)
menu = CW_PdMenu(base, /RETURN_NAME, menu_desc, UVALUE='THEMENU')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'wpdmenu', base, GROUP_LEADER = GROUP, /NO_BLOCK

END
