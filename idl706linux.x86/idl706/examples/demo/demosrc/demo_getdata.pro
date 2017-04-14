; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo_getdata.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; NAME:
;	demo_getdata
; PURPOSE:
;	Retrieves a data file from the examples/data directory in the main IDL
;	directory.  The file can be specified when calling the routine
;	or the file can be chosen by the user with a widget that lets them
;	make the selection.
; CATEGORY:
;	Widgets
; CALLING SEQUENCE:
;	demo_getdata, NEWDATA
; KEYWORD PARAMETERS:
;	ASSOC_IT = When set, this keyword forces the routine to return
;		an associated variable instead of a standard IDL variable.  
;		This is more efficient when loading animations for instance
;		as it removes the need to create two copies of the data
;		in memory (one for the animation, one for the load data).
;	DESCRIPTION = This keyword returns the description of the data
;		selected by the GetData routine (NEWDATA).
;	DIMENSIONS = This keyword returns the dimensions of the data
;		selected by the GetData routine.  These dimensions 
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
;	Getdat2 must find the subdirectory called examples/dataimages of
;       the main IDL directory(IDL_DIR) and the directory must contain a
;       file called data.txt that describes the contents of the directory.
; PROCEDURE:
;	If the FILENAME keyword was not set, determine the file name using
;	a widget that lets the user make a selection from the data.txt file
;	and then open that file, read the data, dimensions, and description,
;	and return the data.
; MODIFICATION HISTORY:
;	Written by Steve Richards,	Dec, 1990
;       Modified by DAT, renamed demo_getdata, add group keyword, 2/97
;-
;---------------------------------------------------------------------
;
;  PURPOSE  : Event handler
;
pro demo_getdataEvent, $
    event              ; IN: event structure.

    COMMON GF, selection

    WIDGET_CONTROL, event.id, GET_UVALUE=selected

    case selected of
        "FILELST": begin
		WIDGET_CONTROL, event.top, SENSITIVE=0
		WIDGET_CONTROL, event.top, /DESTROY
		selection = event.index + 1
        end    ;  of FILELST

        "CANCEL": WIDGET_CONTROL, event.top, /DESTROY
    endcase

end    ;   of GetData_event 


;---------------------------------------------------------------------
;
;  PURPOSE  : Main procedure.
;	Retrieves a data file from the examples/data directory in the main IDL
;	directory.  The file can be specified when calling the routine
;	or the file can be chosen by the user with a widget that lets them
;	make the selection.
;
pro demo_getdata, $
    NEWDATA, $                    ; OUT: new data set
    GROUP=group, $                ; IN: (opt) group leader identifer.
    DESCRIPTION = DESCRIPTION, $  ; OUT:  (opt)Data set description.
    DIMENSIONS = DIMENSIONS, $    ; OUT: (opt) dimension of the data set
    ONE_DIM = ONE_DIM, $          ; IN: (opt) Routine will consider 1-D data.
    TWO_DIM = TWO_DIM, $          ; IN: (opt) Routine will consider 2-D data.
    THREE_DIM = THREE_DIM, $      ; IN: (opt) Routine will consider 3-D data.
    TITLE = TITLE, $              ; IN: (opt) Selection window title.
    FILENAME = FILENAME, $        ; IN: File name of the data set.
    OFILENAME = OFILENAME, $      ; OUT: (opt) output file name.
    ASSOC_IT = ASSOC_IT           ; IN: (opt) routine returns an associate 
                                  ;     variable instead of IDL variable. 

    COMMON GF, selection

    ;  For demo 5, the image files are located in the same directory
    ;  tnan this procedure. Therefore, the data path is set to ' ' .
    ;
    datapath = filepath('', SUBDIR=['examples','data'])

    ;  Initialize working variables.
    ;
    name = ''
    dim = LONARR(3)
    des = ''
    del = ''
    numfiles = 0L
    ONE_MASK = 1
    TWO_MASK = 2
    THREE_MASK = 4

    DESCRIPTION = 0
    DIMENSIONS = 0

    if (KEYWORD_SET(FILENAME)) then begin
        OPENR, unit, datapath + "data.txt", /GET_LUN
        READF, unit, numfiles
        if (numfiles NE 0) then begin
            goodindex = 0
            nameindex = 0

            while((nameindex LT (numfiles)) AND (goodindex EQ 0)) do begin
                READF, unit, name, dim, des, del
                if (name EQ FILENAME) then goodindex = 1
                if (del NE '*') then MESSAGE, $
                    "* delimiter not found in data.txt"
            endwhile

            FREE_LUN, unit

            if (goodindex NE 0) then begin
	        ofilename = filename
                OPENR, unit, datapath + FILENAME, /GET_LUN, /BLOCK

                if (KEYWORD_SET(ASSOC_IT)) then begin
	            NEWDATA = ASSOC(unit, BYTARR(dim[0],dim[1]))
                endif else begin
	            NEWDATA = bytarr(dim[0], dim[1], dim[2])
	            READU, unit, NEWDATA
                    FREE_LUN, unit
                endelse

                DESCRIPTION = des
                DIMENSIONS = dim
            endif
        endif
    endif else if ((XRegistered("demo_getdata") EQ 0)) then begin

        FILTER = 0

        if (KEYWORD_SET(ONE_DIM)) then begin
            FILTER = FILTER OR ONE_MASK
        endif

        if (KEYWORD_SET(TWO_DIM)) then begin
            FILTER = FILTER OR TWO_MASK OR THREE_MASK
        endif

        if (KEYWORD_SET(THREE_DIM)) then begin
            FILTER = FILTER OR THREE_MASK
        endif

        if ((FILTER EQ 0)) then begin
            FILTER = ONE_MASK + TWO_MASK + THREE_MASK
        endif

        OPENR, unit, datapath + "data.txt", /GET_LUN
        READF, unit, numfiles
        if (numfiles NE 0) then begin
            names = STRARR(numfiles)
            descriptions = STRARR(numfiles)
            dimensions = LONARR(3,numfiles)
            goodindex = 0

            for nameindex = 0, numfiles - 1 do begin
                READF, unit, name, dim, des, del
                TEMPFILT = 0
                if (DIM[0] GT 1) then  TEMPFILT = ONE_MASK
                if (DIM[1] GT 1) then  TEMPFILT = TWO_MASK
                if (DIM[2] GT 1) then  TEMPFILT = THREE_MASK

                if ((TEMPFILT AND FILTER) NE 0) then begin
                    names[goodindex] = name
                    dimensions[*,goodindex] = dim
                    descriptions[goodindex] = des
                    goodindex = goodindex + 1
                endif

                if (del NE '*') then begin
                    MESSAGE, "* delimiter not found in data.txt"
                endif

            endfor

            FREE_LUN, unit

            neworder = SORT(names[0:goodindex-1])
            names = names[neworder]
            descriptions = descriptions[neworder]
            dimensions = dimensions[*,neworder]

            filler = "........................................"
            fullnames = STRARR(goodindex)

            for i = 0, goodindex - 1 do begin
                dimstring = STRING(dimensions[*,i], $
                    FORMAT = '("[",I0.3,", ",I0.3,", ",I0.3,"]")')
                length = STRLEN(names[i])
                lengthdim = STRLEN(dimstring)
                fullnames[i] = descriptions[i]
;      fullnames(i) = names(i) + $
;		STRMID(filler, 0, 30-length) + $
;		dimstring + $
;		STRMID(filler, 0, 30-lengthdim) + $
;		descriptions(i)
            endfor

            if (NOT(KEYWORD_SET(TITLE))) then TITLE =  "Please Select Data"

;    font = '*fixed*'   ;It seems to be impossible to find
;		a simple font on all servers.

            if (NOT(KEYWORD_SET(group))) then begin

                loadbase = WIDGET_BASE(TITLE = TITLE, $
                    /COLUMN, $
                    XPAD = 50, $
                    YPAD = 50, $
                    SPACE = 20)
            endif else begin
                loadbase = WIDGET_BASE(TITLE = TITLE, $
                    GROUP_LEADER=group, /MODAL, $
                    /COLUMN, $
                    XPAD = 50, $
                    YPAD = 50, $
                    SPACE = 20)
            endelse

                loadbox = WIDGET_BASE(loadbase, $
                    /COLUMN, $
                    /FRAME, $
                    SPACE=10)

                    loadlist = WIDGET_LIST(loadbox, $
                        VALUE=fullnames, $
                        UVALUE="FILELST", $
                        YSIZE=10)

                loadcancel = WIDGET_BUTTON(loadbase, $
                    VALUE="Cancel", UVALUE="CANCEL")

        WIDGET_CONTROL, loadbase, /REALIZE
  
        selection = 0
    
        XMANAGER, "demo_getdata", loadbase, $
           EVENT_HANDLER='demo_getdataEvent'

        if (selection NE 0) then begin

            if ((NOT(KEYWORD_SET(THREE_DIM))) AND $
                (dimensions[2,selection-1] NE 1)) then $
                dimensions[2,selection-1] = 1

                OPENR, unit, datapath + $
                    names[selection - 1], /GET_LUN, /BLOCK
                ofilename = names[selection - 1]

                if (KEYWORD_SET(ASSOC_IT))  then begin
	            NEWDATA = ASSOC(unit, $
                        BYTARR(dimensions[0, selection-1], $
                        dimensions[1, selection-1]))
                endif else begin
	            NEWDATA = BYTARR(dimensions[0, selection - 1], $
                        dimensions[1, selection - 1], $
                        dimensions[2, selection - 1])
	            READU, unit, NEWDATA
	            FREE_LUN, unit
                endelse

                DESCRIPTION = descriptions[selection - 1]
                DIMENSIONS = dimensions[*,selection - 1]

            endif    ;  of keyword set three_dim
        endif     ;   of selection NE 0
    endif     ;  of keyword set filename.

end           ;  of demo_getdata

