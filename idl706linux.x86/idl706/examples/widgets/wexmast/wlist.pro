; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/wlist.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is the code for a simple list widget.
; In this example, a list of eleven items numbered
; zero through ten appears.  When a list item is selected, 
; that item's name is printed in the IDL window.

; The items in a list widget can be selected only one at 
; a time.  In this sense, list widgets are similar to 
; exclusive menus.  Lists, however, can be made to display
; only a few items at a time and scroll to show the rest
; of the items in the list.



PRO wlist_event, event
; This procedure is the event handler for a simple list widget.

; This COMMON block is used because both 'wlist' and 'wlist_event' 
; should know about any widget that can be touched: 

COMMON wlistblock, list

; Put the User Value of any widget touched into the variable 'eventval':

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

; This CASE statement branches based upon the value of 'eventval':

CASE eventval OF
	"LIST"	: BEGIN
		  ; The list has been touched.
		  ; The index of the list item touched is held in
		  ; 'event.index'... how convenient!

		  ; Put the value of 'event.index' into the variable
		  ; 'selection':
		  selection = event.index

		  ; Print the index of the item selected in the
		  ; IDL window:
		  PRINT, 'List item ' + STRING(selection) + ' selected.'
		  END
ENDCASE
END


PRO wlist, GROUP = GROUP
; This procedure creates a simple list widget.

; This COMMON block is used because both 'wlist' and 'wlist_event' 
; should know about any widget that can be touched:

COMMON wlistblock, list

; Make the top-level base. The XSIZE keyword is used to make
; the base wide enough so that the full title shows:

base = WIDGET_BASE(TITLE = 'Example List Widget', /COLUMN, XSIZE = 300)

; Make an array that holds the text of the list items:

listitems = [	'Item Zero', $
		'Item One', $
		'Item Two', $
		'Item Three', $
		'Item Four', $
		'Item Five', $
		'Item Six', $
		'Item Seven', $
		'Item Eight', $
		'Item Nine', $
		'Item Ten']

; Make the list widget. The YSIZE keyword controls how many list items
; will be visible at a time:

list = WIDGET_LIST(base, $		; This list belongs to 'base'.
		   VALUE = listitems, $	; Put 'listitems' in the list.
		   UVALUE = 'LIST', $	; 'LIST' is this widgets User Value.
		   YSIZE = 5)		; Show five items at a time.

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'wlist', base, GROUP_LEADER = GROUP, /NO_BLOCK

END







