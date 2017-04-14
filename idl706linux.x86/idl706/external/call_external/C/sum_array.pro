;$Id: //depot/idl/IDL_70/idldir/external/call_external/C/sum_array.pro#2 $
;
; Copyright (c) 1998-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	SUM_ARRAY
;
; PURPOSE:
; 	This IDL procedure calls a CALL_EXTERNAL routine which demonstrates
;       how to handle array data with external code. This code:
;       1) implements a simple interface to the external code.
;       2) check the type of arguments that will be passed to the external code
;
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	SUM_ARRAY [, ARR]
;
;	For Example: SUM_ARRAY, FINDGEN(10)
;
; INPUTS:
;       arr - an array of data to be summed.
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

PRO sum_array, arr, AUTO_GLUE=auto_glue, DEBUG=debug, VERBOSE=verbose

    if NOT(KEYWORD_SET(debug)) THEN ON_ERROR,2

    ;check the layout of the array.
    arr_l = (SIZE(arr, /TYPE) EQ 0) ? FINDGEN(10) : FLOAT(arr)

    PRINT,'Calling external function with:'
    HELP, arr_l

    func = keyword_set(auto_glue) ? 'sum_array_natural' : 'sum_array'
    result = CALL_EXTERNAL(GET_CALLEXT_EXLIB(VERBOSE=verbose), $
			   func, arr_l, n_elements(arr_l), $
			   VALUE=[0,1], /F_VALUE, /CDECL, AUTO_GLUE=auto_glue,$
			   VERBOSE=verbose, SHOW_ALL_OUTPUT=verbose)

    ;this result should be equivalent to what the C code is doing
    check = TOTAL(arr_l)

    IF (result NE check ) THEN BEGIN
        PRINT,'CALL_EXTERNAL result was: ',result
        PRINT,'real result is          : ',check
    ENDIF ELSE PRINT,'result is: ',result
END


