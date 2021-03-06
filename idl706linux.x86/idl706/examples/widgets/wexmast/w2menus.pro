; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/w2menus.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a more elaborate menu example.
; In this example, two menus with identical menu items
; are managed.  The menus in this example were made without
; the use of either the /EXCLUSIVE or /NONEXCLUSIVE keywords
; to the XMENU routine.  As a result, the menus look like 
; "action" buttons instead of button lists.




PRO w2menus_event, event

; This is the event handler for a widget with two menus.  Note that
; the buttons and the user values of the buttons are identical.  The
; example illustrates two methods of determining which button was
; selected.

; The first method uses the event id of the button group.
; This allows the procedure to perform some action based on which menu
; was used, but does not differentiate between buttons within that menu.

; The second method uses the event value to determine which button was
; selected.  Note that since the user values of the two menus are the
; same, the corresponding buttons from both menus will be handled by
; the same branch of the case statement.  This method allows the
; procedure to perform some action based on the user value of the
; particular button, but does not necessarily differentiate between
; menus.  Usually the user values of buttons in different menus are
; different, but they need not be.

; The COMMON block is used because both w2menus and w2menus_event must
; know about all widgets that will generate values:

COMMON w2menusblock, first_menu_id, second_menu_id

; Determine whether the menu selection came from the first menu.
; If it did, set the menu number.

IF event.id EQ first_menu_id THEN BEGIN
	; perform some action particular to menu one
	PRINT, ' ' 
	PRINT, 'Button selected from first menu.'
	menu_number=1
ENDIF

; Determine whether the menu selection came from the second menu.
; If it did, set the menu number.
IF event.id EQ second_menu_id THEN BEGIN
	; perform some action particular to menu two
	PRINT, ' '
	PRINT, 'Button selected from second menu.'
	menu_number=2
ENDIF

; Perform actions based on the user value of the button which was pressed.
; Note that a branch of the case statement may handle two buttons from
; different menus which have the same user value.  The user value of buttons
; is likely to be different in most applications, but these are the same
; in order to illustrate how they may be handled by the event handler.

CASE event.value OF
	'ONE':BEGIN
		PRINT, 'Menu Selected:	', menu_number
		PRINT, 'Button Selected:	', event.value		
		END

	'TWO':BEGIN
		PRINT, 'Menu Selected:	', menu_number
		PRINT, 'Button Selected:	', event.value		
		END

	'QUIT':BEGIN
		PRINT, 'Quitting Two Menu Example'
		WIDGET_CONTROL, event.top, /DESTROY
		END
ENDCASE
END



PRO w2menus, GROUP=GROUP
; This is the procedure that creates a widget application with two menus.
; It it used to show two methods for handling the events generated by
; two menus in the same application.

; The COMMON block is used because both w2menus and w2menus_event must
; know about all widgets that will generate values:
COMMON w2menusblock, first_menu_id, second_menu_id

; A top-level base widget with the title "Exclusive Buttons Example" will
; hold the exclusive buttons:

base = WIDGET_BASE(TITLE = 'Two Menu Example', $
	/COLUMN, $
	XSIZE=300)

; Set up the button labels.  The button labels will be used not only for
; the label on the button, but they will also be used for the User Values
; of the buttons.

button_labels = ['ONE', 'TWO', 'QUIT']

; A widget called 'exclus' is created. It has the
; title: 'Exclusive Menu Widget' 

title = WIDGET_BASE(base,/FRAME, /COLUMN)
label = WIDGET_LABEL(title, VALUE='Menu One')
first_menu_id = CW_BGROUP(title, button_labels, $
                          /COLUMN, /FRAME, /RETURN_NAME)

title = WIDGET_BASE(base,/FRAME, /COLUMN)
label = WIDGET_LABEL(title, VALUE='Menu Two')
second_menu_id = CW_BGROUP(title, button_labels, $
                           /COLUMN, /FRAME, /RETURN_NAME)

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off control of the widget to the XMANAGER:
XMANAGER, "w2menus", base, GROUP_LEADER=GROUP, /NO_BLOCK

END
























