; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wexclus.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for an "exclusive" menu.
; This menu contains a list of values.  When a button is
; selected, any previously selected button is released, and
; the two values, new and old, are printed in the IDL
; window.  Selecting the 'Done' button destroys the widget.

; An exclusive menu is a list of buttons in which only
; one button at a time can be selected.

; For an example of a non-exclusive menu, see the routine
; WMENU.PRO.



PRO wexclus_event, event

; This is the event handler for an exclusive menu.  The important
; part of this example is how a state is maintained by the menu.

; The widgetblock common block is used because both wexclus and
; wexclus_event must know about all widgets that will generate values:

COMMON wexclusblock, menu_ids

; The widgetstate common block provides access to the values which
; are used to by the event handler to set and maintain the state.

COMMON widgetstate, state_vals, current_state

; Determine whether the menu selection came from the exclusive menu.
; If it did, set the example state based on the user value.

IF (where(tag_names(event) EQ 'VALUE'))[0] NE -1 THEN BEGIN

button_id = WHERE(menu_ids EQ event.value, count)

IF count GT 0 THEN BEGIN
	; Handle events from the exclusive menu.

	; Save the old value of the state:
	old_state = current_state

	; Retrieve the new state from the user value of the selected
	; button and store it into the 'current_state' common variable:

	WIDGET_CONTROL, event.id, GET_UVALUE = state
        current_state = state[button_id]

	print, 'Old State:	', old_state
	print, 'Current state:	', current_state
	print, ' '	;new line

ENDIF
ENDIF ELSE BEGIN

	WIDGET_CONTROL, event.id, GET_UVALUE = eventval

	CASE eventval OF
		'DONE': WIDGET_CONTROL, event.top, /DESTROY
	ENDCASE
ENDELSE

END



PRO wexclus, GROUP=GROUP

; This is the procedure that creates an exclusive button list using XMENU.

; The COMMON block is used because both wexclus and wexclus_event must
; know about all widgets that will generate values:

COMMON wexclusblock, menu_ids

; The widgetstate common block provides access to the values which
; are used to by the event handler to set and maintain the state.

COMMON widgetstate, state_vals, current_state

; A top-level base widget with the title "Exclusive Buttons Example" will
; hold the exclusive buttons:

base = WIDGET_BASE(TITLE = 'Exclusive Buttons Example', $
	       	   /COLUMN, $
		   XSIZE=300)

; Set up the button labels.  The button labels will be used not only for
;the label on the button, but they will also be used for the user values
;of the buttons.

button_labels = ['Set State Value to 0.1', $
                 'Set State Value to 0.2', $
                 'Set State Value to 0.3']

; Set up the values which represent the state which the exclusive menu
; governs.  Note that the uvalue array must be the same size as the
; value array.

state_vals = [0.1, 0.2, 0.3]

; A widget called 'exclus' is created. It has the
; title: 'Exclusive Menu Widget' 

title = WIDGET_BASE(base,/FRAME, /COLUMN)
label = WIDGET_LABEL(title, VALUE='Exclusive Button List')
buttons = CW_BGROUP(title, button_labels, $
                    IDS = menu_ids, $ ;The 'menu_ids' array holds the widget ID's for all buttons.
                    /FRAME, /COLUMN, /NO_RELEASE, /RETURN_ID, $
                    UVALUE = state_vals)

; Make a 'DONE' button:

button1 = WIDGET_BUTTON(base, $
                UVALUE = 'DONE', $
                VALUE = 'DONE')

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Initialize the state maintained by the current_state variable:
current_state = 0.1

; Set the corresponding button to be pressed:
WIDGET_CONTROL, menu_ids[0], /SET_BUTTON

; Hand off control of the widget to the XMANAGER:
XMANAGER, "wexclus", base, GROUP_LEADER=GROUP, /NO_BLOCK


END

