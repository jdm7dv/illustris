; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/slots.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

; This is a demo slot machine game.

PRO slots_event, event

COMPILE_OPT hidden

COMMON slotsblock, handle, win1, win2, win3, done, money, bank, message
COMMON pictures, pics, blank, handlepic, handlepic2, numfiles
COMMON scoring, winval

ON_ERROR, 2  ; return to caller

winval = intarr(3)

WIDGET_CONTROL, event.id, GET_UVALUE = eventval


CASE eventval OF
	"PULL"	: BEGIN
		  ; Do the slot machine thang.

		  ; Pull the handle down.
		  WIDGET_CONTROL, handle, SET_VALUE = handlepic2

		  ; "Spin" the slot machine wheels.
		  extraspin = FIX(RANDOMU(SEED)*8)
		  spin1 = 15
		  spin2 = 20 + extraspin
		  spin3 = 25 + 2*extraspin

		  FOR i = 0, spin3 DO BEGIN
			r = FIX(RANDOMU(SEED, 3)* numfiles)
			IF i LT spin1 THEN BEGIN
			WIDGET_CONTROL, win1, SET_VALUE = pics[*,*,r[0]]
			winval[0] = r[0]
			ENDIF

			IF i LT spin2 THEN BEGIN
			WIDGET_CONTROL, win2, SET_VALUE = pics[*,*,r[1]]
			winval[1] = r[1]
			ENDIF

			WIDGET_CONTROL, win3, SET_VALUE = pics[*,*,r[2]]

		  ENDFOR
		  winval[2] = r[2]

		  ; Put the handle back up.
		  WIDGET_CONTROL, handle, SET_VALUE = handlepic

		  ; Increment or decrement the player's bankroll:
		  score, money, msg
		  WIDGET_CONTROL, bank, SET_VALUE = '$ ' + STRING(money)
		  WIDGET_CONTROL, message, SET_VALUE = msg

		  ; Is the player out of money? If they are, BACK TO WORK!
		  IF (money EQ 0) THEN WIDGET_CONTROL, event.top, /DESTROY

		  END ; PULL case.

	"DONE"	: WIDGET_CONTROL, event.top, /DESTROY
	ELSE	: donothing = 0
ENDCASE
END

PRO score, money, message
COMPILE_OPT hidden
COMMON scoring, winval
ON_ERROR, 2  ; return to caller

; This procedure returns the new amount for the bankroll and a
; corresponding message.

IF (((winval[0] EQ 8) AND (winval[1] EQ 8)) AND (winval[2] EQ 8)) THEN $
	BEGIN
	money = money + 1000000000
	message = 'SUPER HAL JACKPOT !!!'
	RETURN
	ENDIF

IF ((winval[0] EQ winval[1]) AND (winval[1] EQ winval[2])) THEN $
	BEGIN
	money = money + 10
	message = 'JACKPOT !!!'
	RETURN
	ENDIF

IF winval[0] EQ winval[1] THEN $
	BEGIN
	money = money + 2
	message = 'Two of a Kind!'
	RETURN
	ENDIF

IF winval[1] EQ winval[2] THEN $
	BEGIN
	money = money + 3
	message = 'Two of a Kind!'
	RETURN
	ENDIF

money = money - 1
message = 'Bummer, Dude!'

IF (money EQ 0) THEN message = 'Back to Work, Dude!'

RETURN
END


PRO makepics
COMPILE_OPT hidden
; This procedure reads the bitmaps of the slot machine handle and wheels.

COMMON pictures, pics, blank, handlepic, handlepic2, numfiles
ON_ERROR, 2  ; return to caller

; DEFINE THE PICS HERE:

blank = bytarr(8, 64)
wexmaster_path = ['examples', 'widgets', 'wexmast']

; Read the normal handle:
OPENR, 5, FILEPATH('handle.bm', SUBDIR=wexmaster_path)
b = ASSOC(5, BYTARR(4,100))
handlepic = b[0]
CLOSE, 5

; Read the pulled handle:
OPENR, 5, FILEPATH('handle2.bm', SUBDIR=wexmaster_path)
b = assoc(5, BYTARR(4,100))
handlepic2 = b[0]
CLOSE, 5

; The array 'files' contains the filenames for the icons to use.
; You can add more pictures to the slot machine 'wheels' by creating new
; 64 by 64 bitmaps with XBM_EDIT and appending the names of their
; files to the list of names already shown.

files=['apple.bm','pc.bm','cherry.bm','face.bm','idlidl.bm','seven.bm',$
       'disk.bm','orange.bm','hal.bm']

; Find out how many pictures there are:
numfiles = N_ELEMENTS(files)

; The array pics will hold the wheel bitmaps:
pics = BYTARR(8,64,numfiles)

; Read each file described in 'files' into an element of array PICS:
FOR i = 0, numfiles-1 DO BEGIN
OPENR, 5, FILEPATH(files[i], SUBDIR=wexmaster_path)
b = ASSOC(5, BYTARR(8,64))
pics[*,*,i] = b[0]
CLOSE, 5
ENDFOR

END	; PRO makepics




PRO slots, GROUP = GROUP
; This procedure make the slot machine widgets.

COMMON slotsblock, handle, win1, win2, win3, done, money, bank, message
COMMON pictures, pics, blank, handlepic, handlepic2, numfiles

ON_ERROR, 2  ; return to caller

; Only one copy of the slot machine can run at a time, so check for other
; copies:

IF(XREGISTERED("slots") NE 0) THEN RETURN

makepics

base = WIDGET_BASE(TITLE = 'One-Armed Bandit', /ROW)
lcol = WIDGET_BASE(base, /COLUMN)
mcol = WIDGET_BASE(base, /COLUMN)
rcol = WIDGET_BASE(base, /COLUMN, XSIZE = 44)

windows = WIDGET_BASE(mcol, /ROW)		;Make the windows for MOTIF.

; Widgets for the left column (lcol):
; Make the Quit button:
done = WIDGET_BUTTON(lcol, VALUE = "Quit Goofin' Off", UVALUE = 'DONE')

; Make the bankroll display window with a label above it:
bankcol = WIDGET_BASE(lcol, /COLUMN, /FRAME)
banklabel = WIDGET_LABEL(bankcol, VALUE = 'Bankroll:')
bank = WIDGET_TEXT(bankcol, /FRAME, UVALUE = 'BANK')


; Widgets for the middle column (mcol):
; The three 'wheel' windows are rendered as buttons that don't really do anything,
; they just display the little bitmap pictures:
win1 = WIDGET_BUTTON(windows, VALUE = blank, UVALUE = 'WIN1')
win2 = WIDGET_BUTTON(windows, VALUE = blank, UVALUE = 'WIN2')
win3 = WIDGET_BUTTON(windows, VALUE = blank, UVALUE = 'WIN3')

; Make the message area below the wheels:
message = WIDGET_TEXT(mcol, VALUE = 'Click on the Handle to Play', /FRAME)

; Make a section of labels that describe the scoring, etc.:
info = WIDGET_BASE(mcol, /FRAME, /COLUMN)

; The following lines demonstrate the use of the new FONT keyword to the
; widget routines.  Just enclose the name of a font available on the
; appropriate machine in quotes as shown below:

VERSION	= WIDGET_INFO(/VERSION)
IF (STRPOS(VERSION.STYLE, 'Windows') NE -1) THEN font='*24' $
ELSE IF (STRPOS(VERSION.STYLE, 'Motif') NE -1) THEN font='fixed' $
ELSE font='v*36'

line1 = WIDGET_LABEL(info, FONT=font, VALUE = 'Match 1st Two --- $2')
line2 = WIDGET_LABEL(info, FONT=font, VALUE = 'Match 2nd Two --- $3')
line3 = WIDGET_LABEL(info, FONT=font, VALUE = '3 of a Kind    --- $20')
line4 = WIDGET_LABEL(info, FONT=font, VALUE = 'Three Hals    --- $1,000,000')

line5 = WIDGET_LABEL(info, VALUE = 'For Entertainment Purposes Only', /FRAME)
line6 = WIDGET_LABEL(info, VALUE = 'Please, No Wagering',/FRAME)

; Widgets for the right column:
handle = WIDGET_BUTTON(rcol, VALUE = handlepic, UVALUE = 'PULL')

; Initailize the bankroll:
money = 10
WIDGET_CONTROL, bank, SET_VALUE = '$ '+ STRING(money)

; Realize the widgets:
WIDGET_CONTROL, base, /REALIZE

; Hand off to the XMANAGER:
XMANAGER, 'slots', base, GROUP_LEADER = GROUP, /NO_BLOCK

END

