; $Id: //depot/idl/IDL_70/idldir/examples/doc/widgets/xdice.pro#2 $

; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       XDICE
;
; PURPOSE:
;	The primary purpose of this routine is to serve as an example for
;	the "Creating Widget Applications" chapter of the _Building IDL
;  Applications_ manual. It uses the CW_DICE	compound widget (also
;  written as an example) to present a pair of dice.
;
; CATEGORY:
;       Widgets
;
; CALLING SEQUENCE:
;       XDICE
;
; INPUTS:
;       No explicit inputs.
;
; KEYWORD PARAMETERS:
;       GROUP - Group leader, as passed to XMANAGER.
;
; OUTPUTS:
;       None.
;
; PROCEDURE:
;	Two dice are presented, along with "Done" and "Roll" buttons.
;	Pressing either dice rolls that dice. pressing the Roll
;	button rolls both dice.
;
;	A label widget at the bottom displays the current dice values.
;	Press "Done" to kill the application.
;
; MODIFICATION HISTORY:
;	24 October 1993, AB, RSI
;-

PRO xdice_event, ev

  ; Recover the state
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=state, /NO_COPY

  ; Either the Done or Roll button was pressed.
  IF (ev.ID EQ state.bgroup) THEN BEGIN
    ; The Done button
    IF (ev.VALUE EQ 0) THEN BEGIN
      ; Destroy the application and return, to avoid
      ; trying to update the widget label we just
      ; destroyed.
      WIDGET_CONTROL, /DESTROY, ev.TOP
      RETURN
    ; The Roll button
    ENDIF ELSE BEGIN
      ; Roll the dice by asking for an out of
      ; range value.
      WIDGET_CONTROL, state.d1, SET_VALUE=-1
      WIDGET_CONTROL, state.d2, SET_VALUE=-1
    ENDELSE
  ENDIF

  ; Get value of dice.
  WIDGET_CONTROL, state.d1, get_value=d1v
  WIDGET_CONTROL, state.d2, get_value=d2v
 
  ; Format the initial label text.
  str = STRING(FORMAT='("Current Value: ",I1,", ",I1)', d1v, d2v)

  ; Update the label
  WIDGET_CONTROL, state.label, SET_VALUE=str

  ; Restore the state
  WIDGET_CONTROL, ev.top, SET_UVALUE=state, /NO_COPY

END


PRO xdice, GROUP=group

; Providing standard keywords usually found in other widget
; applications is a nice finishing touch. GROUP is easy 
; to support since we just pass it to XMANAGER.

  ; Create the top-level base that holds everything else.
  base = WIDGET_BASE(/COLUMN, TITLE='Pair O'' Dice')
  
  ; A button group compound widget is used to implement the
  ; Done and Roll buttons. The SPACE keyword simply causes
  ; the buttons to be spread out from each other.
  bgroup = CW_BGROUP(base, ['Done', 'Roll'], /ROW, SPACE=50)

  ; Create a row base to hold the dice. XPAD moves the first die
  ; away from the left side of the application and helps center the
  ; dice.
  dice = WIDGET_BASE(base, /ROW, XPAD=20)

  ; Create the dice.
  d1 = CW_DICE(dice)
  d2 = CW_DICE(dice)

  ; We need the initial dice values to set the label appropriately.
  ; We could have specified initial values for the calls to CW_DICE
  ; above, but it seems better to let them be different on each
  ; invocation.
  WIDGET_CONTROL, d1, GET_VALUE=d1v
  WIDGET_CONTROL, d2, GET_VALUE=d2v

  ; Format the initial label text.
  str=STRING(FORMAT='("Current Value: ",I1,", ",I1)', d1v, d2v)

  ; This label is used to textually display the current dice values.
  label = WIDGET_LABEL(base, VALUE=str)

  ; Keep useful information in a state structure.
  state = { bgroup:bgroup, d1:d1, d2:d2, label:label }

  ; Save the state structure in the base UVALUE, and realize the
  ; application.
  WIDGET_CONTROL, base, SET_UVALUE=state, /NO_COPY, /REALIZE

  ; Pass control to XMANAGER.
  XMANAGER,'xdice', base, GROUP=group, NO_BLOCK=1
  
END

