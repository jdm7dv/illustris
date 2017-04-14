; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/mbar.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple menu bar.   Menu bars can be placed
; at the top of top-level widget bases.   While holding down the (left)
; mouse button, drag the cursor over the words in the menu bar.
; The appropriate menu will appear when the cursor is over the word.
; Release the mouse button on the desired menu item to make a selection.

; Pull-right menus can be defined for any menu entry.   The pull-right
; menu can be activated by clicking on that menu item, or by dragging the
; cursor off the right side of that menu item.


PRO mbar_event, event
; This is the event handler for a basic menu bar.

; Use WIDGET_CONTROL to get the user value of any widget touched and put
; that value into 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; The selection of a menu item is easily handled with a CASE statement.
; When a menu item is selected, the value of 'eventval' is the user value
; of the selected menu item.

CASE eventval OF
	'QUIT':BEGIN
		; Quit the menu bar example.
		WIDGET_CONTROL, event.top, /Destroy
		END
	ELSE:BEGIN
		; Print the button's user value to the IDL window:
		PRINT, 'Widget User Value = ' + eventval
		END
ENDCASE
END



PRO mbar, GROUP = GROUP
; This is the procedure that creates an example menu bar.

; A top-level base widget with the title "Menu Bar Example" will
; hold the menu bar.   Since this is a top-level base (no parent),
; the "MBAR" keyword may be used.

base = WIDGET_BASE(TITLE = 'Menu Bar Example', MBAR=bar_base)

; The "bar_base" variable now contains the widget base id for the menu bar.

; The menus may now be constructed by creating button widgets with the
; "MENU" keyword.

file_menu = WIDGET_BUTTON(bar_base, Value='File', /Menu)
file_bttn1 = WIDGET_BUTTON(file_menu, Value='File Item 1', Uvalue='FILE 1')
file_bttn2 = WIDGET_BUTTON(file_menu, Value='File Item 2', Uvalue='FILE 2')
file_bttn3 = WIDGET_BUTTON(file_menu, Value='File Item 3', Uvalue='FILE 3')
file_bttn4 = WIDGET_BUTTON(file_menu, Value='Quit', Uvalue='QUIT')

opt_menu = WIDGET_BUTTON(bar_base, Value='Options', /Menu)
opt_bttn1 = WIDGET_BUTTON(opt_menu, Value='Options Item 1', Uvalue='FILE 1')
opt_bttn2 = WIDGET_BUTTON(opt_menu, Value='Options Item 2', Uvalue='FILE 2')
opt_bttn3 = WIDGET_BUTTON(opt_menu, Value='Options Item 3', Uvalue='FILE 3')
opt_pr = WIDGET_BUTTON(opt_menu, Value='Options Pull-Right', /Menu)
   pr_bttn1 = WIDGET_BUTTON(opt_pr, Value='Pull-Right Item 1', Uvalue='PR 1')
   pr_bttn2 = WIDGET_BUTTON(opt_pr, Value='Pull-Right Item 2', Uvalue='PR 2')
opt_bttn5 = WIDGET_BUTTON(opt_menu, Value='Options Item 5', Uvalue='FILE 5')

help_menu = WIDGET_BUTTON(bar_base, Value='Help', /Menu)
help_bttn1 = WIDGET_BUTTON(help_menu, Value='Help Item 1', Uvalue='HELP 1')
help_bttn2 = WIDGET_BUTTON(help_menu, Value='Help Item 2', Uvalue='HELP 2')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off control of the widget to the XMANAGER:
XMANAGER, "mbar", base, GROUP_LEADER = GROUP, /NO_BLOCK

END


