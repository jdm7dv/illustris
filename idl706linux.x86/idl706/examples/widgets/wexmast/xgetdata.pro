; $Id: //depot/idl/IDL_70/idldir/examples/widgets/wexmast/xgetdata.pro#2 $
;
; Copyright (c) 1993-2008, ITT Visual Information Solutions. All
;       rights reserved.

;------------------------------------------------------
;   procedure XGetData_event
;------------------------------------------------------

PRO XGetData_event, event

COMMON GF, selection

WIDGET_CONTROL, event.id, GET_UVALUE = selected

CASE selected OF
  "FILELST": BEGIN
		WIDGET_CONTROL, event.top, SENSITIVE = 0
		WIDGET_CONTROL, event.top, /DESTROY
		selection = event.index + 1
	     END
  "CANCEL": WIDGET_CONTROL, event.top, /DESTROY
ENDCASE

END
;---------- end of procedure XGetData_event ------------



;------------------------------------------------------
;   procedure XGetData
;------------------------------------------------------

PRO XGetData, 	NEWDATA, GROUP = GROUP, $
		DESCRIPTION = DESCRIPTION, $
		DIMENSIONS = DIMENSIONS, $
		ONE_DIM = ONE_DIM, $
		TWO_DIM = TWO_DIM, $
		THREE_DIM = THREE_DIM, $
		TITLE = TITLE, $
		FILENAME = FILENAME, $
		OFILENAME = OFILENAME, $
		ASSOC_IT = ASSOC_IT

;+
; NAME:
;	XGetData
; PURPOSE:
;	Retrieves a data file from the images directory in the main IDL
;	directory.  The file can be specified when calling the routine
;	or the file can be chosen by the user with a widget that lets them
;	make the selection.
; CATEGORY:
;	Widgets
; CALLING SEQUENCE:
;	XGetData, NEWDATA
; KEYWORD PARAMETERS:
;	ASSOC_IT = When set, this keyword forces the routine to return
;		an associated variable instead of a standard IDL variable.  
;		This is more efficient when loading animations for instance
;		as it removes the need to create two copies of the data
;		in memory (one for the animation, one for the load data).
;	DESCRIPTION = This keyword returns the description of the data
;		selected by the XGetData routine (NEWDATA).
;	DIMENSIONS = This keyword returns the dimensions of the data
;		selected by the XGetData routine.  These dimensions 
;		are the dimensions of the NEWDATA variable.
;	FILENAME = The name of the file that is to be selected from the
;		images subdirectory.  If this keyword is set, no user 
;		selection widget is created.
;	OFILENAME = name of file selected.
;	ONE_DIM = This keyword is set when the routine is to consider
;		one dimensional data from the data contained in the
;		images subdirectory.
;	TWO_DIM = This keyword is set when the routine is to consider
;		two dimensional data from the data contained in the
;		images subdirectory.  When searching for two dimensional
;		data, this routine will use the first slice of any 
;		three dimensional data that it encounters.
;	THREE_DIM = This keyword is set when the routine is to consider
;		three dimensional data from the data contained in the
;		images subdirectory.
;	TITLE = The string that will appear in the title portion
;		of the data selection widget.  If not specified, the
;		title will be "Please Select Data".
; OUTPUTS:
;	NEWDATA = the variable that is to be filled with the new data.
; COMMON BLOCKS:
;	GF - maintains which selection was made when using the data
;		selection widget.
; SIDE EFFECTS:
;	Desensitizes all the other widgets and is modal in behavior.  It 
;	forces the user to make a selection before proceeding with other 
;	widget functions.
; RESTRICTIONS:
;	Needs to have directory called images in the main IDL directory
;	(IDL_DIR) and the directory must contain a file called data.txt
;	that describes the contents of the directory.
; PROCEDURE:
;	If the FILENAME keyword was not set, determine the file name using
;	a widget that lets the user make a selection from the data.txt file
;	and then open that file, read the data, dimensions, and description,
;	and return the data.
; MODIFICATION HISTORY:
;	Written by Steve Richards,	Dec, 1990
;-


COMMON GF, selection

datapath = FILEPATH("", SUBDIR = ['examples', 'data'] )

name = ''
dim = lonarr(3)
des = ''
del = ''
numfiles = 0L
ONE_MASK = 1
TWO_MASK = 2
THREE_MASK = 4

NEWDATA = 0
DESCRIPTION = 0
DIMENSIONS = 0

IF (KEYWORD_SET(FILENAME)) THEN BEGIN
  OPENR, unit, datapath + "data.txt", /GET_LUN
  READF, unit, numfiles
  IF (numfiles NE 0) THEN BEGIN
    goodindex = 0
    nameindex = 0
    WHILE((nameindex LT (numfiles)) AND (goodindex EQ 0)) DO BEGIN
      READF, unit, name, dim, des, del
      IF (name EQ FILENAME) THEN goodindex = 1
      IF (del NE '*') THEN MESSAGE, "* delimiter not found in data.txt"
    ENDWHILE
    FREE_LUN, unit
    IF (goodindex NE 0) THEN BEGIN
	ofilename = filename
      OPENR, unit, datapath + FILENAME, /GET_LUN, /BLOCK
      if KEYWORD_SET(ASSOC_IT) then begin
	NEWDATA = ASSOC(unit, bytarr(dim[0],dim[1]))
      ENDIF ELSE BEGIN
	NEWDATA = bytarr(dim[0], dim[1], dim[2])
	READU, unit, NEWDATA
	FREE_LUN, unit
      ENDELSE
      DESCRIPTION = des
      DIMENSIONS = dim
    ENDIF
  ENDIF
ENDIF ELSE IF ((XRegistered("XGetData") EQ 0)) THEN BEGIN

  FILTER = 0
  IF KEYWORD_SET(ONE_DIM) THEN FILTER = FILTER OR ONE_MASK
  IF KEYWORD_SET(TWO_DIM) THEN FILTER = FILTER OR TWO_MASK OR THREE_MASK
  IF KEYWORD_SET(THREE_DIM) THEN FILTER = FILTER OR THREE_MASK
  IF (FILTER EQ 0) THEN FILTER = ONE_MASK + TWO_MASK + THREE_MASK

  OPENR, unit, datapath + "data.txt", /GET_LUN
  READF, unit, numfiles
  IF (numfiles NE 0) THEN BEGIN
    names = STRARR(numfiles)
    descriptions = STRARR(numfiles)
    dimensions = LONARR(3,numfiles)
    goodindex = 0
    FOR nameindex = 0, numfiles - 1 DO BEGIN
      READF, unit, name, dim, des, del
      TEMPFILT = 0
      IF DIM[0] GT 1 THEN TEMPFILT = ONE_MASK
      IF DIM[1] GT 1 THEN TEMPFILT = TWO_MASK
      IF DIM[2] GT 1 THEN TEMPFILT = THREE_MASK
      IF ((TEMPFILT AND FILTER) NE 0) THEN BEGIN
        names[goodindex] = name
        dimensions[*,goodindex] = dim
        descriptions[goodindex] = des
        goodindex = goodindex + 1
      ENDIF
      IF (del NE '*') THEN MESSAGE, "* delimiter not found in data.txt"
    ENDFOR
    FREE_LUN, unit

    neworder = SORT(names[0:goodindex-1])
    names = names[neworder]
    descriptions = descriptions[neworder]
    dimensions = dimensions[*,neworder]

    filler = "........................................"
    fullnames = STRARR(goodindex)
    FOR i = 0, goodindex - 1 DO BEGIN
      dimstring = STRING(dimensions[*,i], $
			FORMAT = '("[",I0.3,", ",I0.3,", ",I0.3,"]")')
      length = STRLEN(names[i])
      lengthdim = STRLEN(dimstring)
      fullnames[i] = names[i] + $
		STRMID(filler, 0, 30-length) + $
		dimstring + $
		STRMID(filler, 0, 30-lengthdim) + $
		descriptions[i]
    ENDFOR

    IF (NOT(KEYWORD_SET(TITLE))) THEN TITLE =  "Please Select Data"

;    font = '*fixed*'   ;It seems to be impossible to find
;		a simple font on all servers.
    loadbase = WIDGET_BASE(TITLE = TITLE, $
		GROUP_LEADER = GROUP, /MODAL, /COLUMN, $
		XPAD = 50, $
		YPAD = 50, $
		SPACE = 20)

    loadbox = WIDGET_BASE(loadbase, $
		/COLUMN, $
		/FRAME, $
		SPACE = 10)

;    loadlbl = WIDGET_LABEL(loadbox, $
;		VALUE = "File Name                     Dimensions                    Description")

    loadlist = WIDGET_LIST(loadbox, $
		VALUE = fullnames, $
		UVALUE = "FILELST", $
		YSIZE = 10)

    loadcancel = WIDGET_BUTTON(loadbase, VALUE = "Cancel", UVALUE = "CANCEL")

    WIDGET_CONTROL, loadbase, /REALIZE
  
    selection = 0

    Xmanager, "XGetData", loadbase
    IF (selection NE 0) THEN BEGIN
      IF ((NOT(KEYWORD_SET(THREE_DIM))) AND $
	 (dimensions[2,selection-1] NE 1)) THEN $
	dimensions[2,selection-1] = 1
      OPENR, unit, datapath + names[selection - 1], /GET_LUN, /BLOCK
      ofilename = names[selection - 1]
      IF KEYWORD_SET(ASSOC_IT) THEN BEGIN
	NEWDATA = ASSOC(unit, bytarr(dimensions[0, selection-1], $
			dimensions[1, selection-1]))
      ENDIF ELSE BEGIN
	      NEWDATA = BYTARR(dimensions[0, selection - 1], $
			       dimensions[1, selection - 1], $
			       dimensions[2, selection - 1])
	      READU, unit, NEWDATA
	      FREE_LUN, unit
      ENDELSE
      DESCRIPTION = descriptions[selection - 1]
      DIMENSIONS = dimensions[*,selection - 1]
    ENDIF
  ENDIF
ENDIF

END
;------------- end of procedure XGetData --------------


