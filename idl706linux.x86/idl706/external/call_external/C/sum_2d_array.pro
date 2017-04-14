;$Id: //depot/idl/IDL_70/idldir/external/call_external/C/sum_2d_array.pro#2 $
;
; Copyright (c) 1998-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	SUM_2D_ARRAY
;
; PURPOSE:
; 	This IDL procedure calls a CALL_EXTERNAL routine which demonstrates
;       how to handle multi-dimensional data with external code. This code:
;       1) implements a simple interface to the external code.
;       2) check the type of arguments that will be passed to the external code
;
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	SUM_2D_ARRAY [, ARR] [, X_START] [, X_END] [, Y_START] [, Y_END]
;
;	For Example: SUM_2D_ARRAY, DINDGEN(20,20), 5, 10, 5, 10
;
; INPUTS:
;       arr - a 2 dimensional IDL array of type double
;       x_start - X index of the start of the subsection
;       x_end   - X index of the end of the subsection
;       y_start - Y index of the start of the subsection
;       y_end   - Y index of the end of the subsection
;
; OUTPUTS:
;	Returns the total of the array elements.
;
; KEYWORDS:
;	AUTO_GLUE
;	Use the AUTO_GLUE keyword to CALL_EXTERNAL to call a version of
;	the external C function that has a natural C interface rather
;	than the IDL portable calling convension (argc, argv).
;
;       DEBUG
;	If this keyword is unset, this routine will return to the
;	caller on any error. If this keyword is set, this routine will
;	stop at the point of the error.
;
;	VERBOSE
;	If set, cause the underlying MAKE_DLL to show the commands it
;	executes to build the sharable library, and all of the output
;	produced by those commands. If not set, this routine does its
;	work silently.
;
; SIDE EFFECTS
;	Sharable library of example code is built.
;
; RESTRICTIONS
;	None.
;
; PROCEDURE:
;	Use GET_CALLEXT_EXLIB to build the sharable library of example
;	code, and use CALL_EXTERNAL to call sum_2d_array().
;
; Modification History:
;	Written May, 1998 JJG
;	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
;-

PRO sum_2d_array, arr, x_start, x_end, y_start, y_end, $
	AUTO_GLUE=auto_glue, DEBUG=debug, VERBOSE=verbose

    if NOT(KEYWORD_SET(debug)) THEN ON_ERROR,2

    ;check the layout of the array.
    arr = (SIZE(arr, /TYPE) EQ 0) ? DINDGEN(20,20) : DOUBLE(arr)

    sz = SIZE(arr, /STRUCTURE)
    IF (sz.n_dimensions NE 2) THEN MESSAGE, 'ARR must be 2 dimensional'

    ; x_start must be a nonegative scalar long
    x_start = (SIZE(x_start,/TNAME) EQ 'UNDEFINED') ? 0L : LONG(x_start[0] > 0)
    x_size =  sz.dimensions[0]
    ;x_end must be a scalar long smaller than the x_size of the array.
    x_end = (SIZE(x_end,/TNAME) EQ 'UNDEFINED') ? x_size - 1 : $
             LONG(x_end[0] < (x_size - 1))

    ;make sure x_start and y_end make sense
    IF (x_start GT x_end) THEN $
        MESSAGE,'X_START must be less than or equal to X_END'

    ;y_start must be a nonegative scalar long
    y_start = (SIZE(y_start,/TNAME) EQ 'UNDEFINED') ? 0L : LONG(y_start[0] > 0)
    y_size =  sz.dimensions[1]
    ;y_end must be a scalar long smaller than the y_size of the array.
    y_end = (SIZE(y_end,/TNAME) EQ 'UNDEFINED') ? y_size - 1 : $
             LONG(y_end[0] < (y_size - 1))

    ;make sure y_start and y_end make sense
    IF (y_start GT y_end) THEN $
        MESSAGE,'Y_START must be less than or equal to Y_END'

    PRINT,'Calling external function with:'
    HELP,arr,x_start,x_end,x_size,y_start,y_end,y_size

    func = keyword_set(auto_glue) ? 'sum_2d_array_natural' : 'sum_2d_array'
    result = CALL_EXTERNAL(GET_CALLEXT_EXLIB(VERBOSE=verbose), $
			   func, arr, x_start, x_end, x_size,$
                           y_start, y_end, y_size, VALUE=[0,1,1,1,1,1,1], $
			   /D_VALUE, /CDECL, AUTO_GLUE=auto_glue, $
			   VERBOSE=verbose, SHOW_ALL_OUTPUT=verbose)

    ;this result should be equivalent to what the C code is doing
    check = TOTAL(arr[x_start:x_end,y_start:y_end],/DOUBLE)

    IF (result NE check ) THEN BEGIN
        PRINT,'CALL_EXTERNAL result was: ',result
        PRINT,'real result is          : ',check
    ENDIF ELSE PRINT,'result is: ',result

END
