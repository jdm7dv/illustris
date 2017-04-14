; $Id: //depot/idl/IDL_70/idldir/external/call_external/C/incr_struct.pro#2 $
;
; Copyright (c) 1998-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	INCR_STRUCT
;
; PURPOSE:
;	This IDL procedure calls a CALL_EXTERNAL routine which demonstrates
;	how to pass IDL structures to external code.  The purpose of this
;       code is to:
;      	    1) Implement a simple interface to the external code.
;           2) Check the type of arguments that will be passed to the
;	       external code
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	INCR_STRUCT
;       INCR_STRUCT, {astructure}
;
;       See astructure__define.pro for the structure definition.
;
; INPUTS:
;	S_ARR
;	An array of structures of type "ASTRUCTURE". The structure
;       defintion must match the one given in astructure__define.pro
;
; OUTPUTS:
;	S_ARR
;       On return, all of the fields in all of the structures in s_arr
;       will have been incremented by 1.
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
;	ASTRUCTURE structure definition in defined.
;	Sharable library of example code is built.
;
; RESTRICTIONS
;	It is important that the IDL structure definition
;       and the C structure definition match exactly.  Otherwise,
;       there will be no way to prevent this program from
;       segfaulting or doing other strange things.
;
; PROCEDURE:
;	Use GET_CALLEXT_EXLIB to build the sharable library of example
;	code, and use CALL_EXTERNAL to call incr_struct().
;
; Modification History:
;	Written May, 1998 JJG
;	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
;-

PRO incr_struct, s_arr, AUTO_GLUE=auto_glue, DEBUG=debug, VERBOSE=verbose

    if NOT(KEYWORD_SET(debug)) THEN  ON_ERROR,2

    ;check type of s_arr
    CASE SIZE(s_arr, /TYPE) OF
        0 : s_arr = replicate({astructure},2)
        8 : IF TAG_NAMES(s_arr,/STRUCTURE_NAME) NE 'ASTRUCTURE' THEN $
              MESSAGE,'S_ARR is not the correct structure type'

        ;there's no good way to cast things to type struct.
        ELSE:  MESSAGE, 'S_ARR must be a structure'
    ENDCASE

    PRINT, 'Calling external routine incr_struct() with:'
    N = N_ELEMENTS(s_arr)
    FOR I=0,N-1 DO BEGIN
        print,form = '(a,i3,a)','s_arr[',i,']'
        HELP,s_arr[i],/STRUCTURE
        PRINT,s_arr[i].four
    ENDFOR

    j = 0l
    func = keyword_set(auto_glue) ? 'incr_struct_natural' : 'incr_struct'
    IF (CALL_EXTERNAL(GET_CALLEXT_EXLIB(VERBOSE=verbose), func, s_arr, n, $
		      VALUE=[0, 1], /CDECL, AUTO_GLUE=auto_glue, $
		      VERBOSE=verbose, SHOW_ALL_OUTPUT=verbose)) THEN BEGIN
        PRINT,'After calling external routine:'
        N = N_ELEMENTS(s_arr)
        FOR I=0,N-1 DO BEGIN
            print,form = '(a,i3,a)','s_arr[',i,']'
            HELP,s_arr[i], /STRUCTURE
            PRINT,s_arr[i].four
        ENDFOR
    ENDIF ELSE MESSAGE,'Call to incr_struct failed'
END






