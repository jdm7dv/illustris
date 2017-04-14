;$Id: //depot/idl/IDL_70/idldir/external/call_external/C/simple_vars.pro#2 $
;
; Copyright (c) 1998-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

;+
; NAME:
;	SIMPLE_VARS
;
; PURPOSE:
;	Demonstrate how to pass simple variables from IDL to a C function
;	using CALL_EXTERNAL. The variables values are squared and
;	returned to show how variable values can be changed.
;
; CATEGORY:
;	Dynamic Linking Examples
;
; CALLING SEQUENCE
;	SIMPLE_VARS, [B], [I], [L], [F], [D]
;
; INPUTS:
;	B
;	Scalar of type BYTE
;
;	I
;	Scalar of type INT
;
;	L
;	Scalar of type LONG
;
;	F
;	Scalar of type FLOAT
;
;	D
;	Scalar of type DOUBLE
;
; OUTPUTS:
;	All input parameters will be set to the square of their input values.
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
;	code, and use CALL_EXTERNAL to call simple_vars().
;
; Modification History:
;	Written May, 1998 JJG
;	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
;-

PRO simple_vars, b, i, l, f, d, AUTO_GLUE=auto_glue, DEBUG=debug, $
	VERBOSE=verbose
   if NOT(KEYWORD_SET(debug)) THEN ON_ERROR,2

   ; Type checking: Any missing (undefined) arguments will be set
   ; to a default value. All arguments will be forced to a scalar
   ; of the apropriate type, which may cause errors to be thrown
   ; if structures are passed in. Local variables are used so that
   ; the values and types of the user supplied arguments don't change.
   b_l = (SIZE(b,/TYPE) EQ 0) ? 2b   :  byte(b[0])
   i_l = (SIZE(i,/TYPE) EQ 0) ? 3    :  fix(i[0])
   l_l = (SIZE(l,/TYPE) EQ 0) ? 4L   :  long(l[0])
   f_l = (SIZE(f,/TYPE) EQ 0) ? 5.0  : float(f[0])
   d_l = (SIZE(d,/TYPE) EQ 0) ? 6.0D :  double(d[0])

   PRINT, 'Calling simple_vars with the following arguments:'
   HELP, b_l, i_l, l_l, f_l, d_l
   func = keyword_set(auto_glue) ? 'simple_vars_natural' : 'simple_vars'
   IF (CALL_EXTERNAL(GET_CALLEXT_EXLIB(VERBOSE=verbose), func, $
                     b_l, i_l, l_l, f_l, d_l, /CDECL, $
		     AUTO_GLUE=auto_glue, VERBOSE=verbose, $
		     SHOW_ALL_OUTPUT=verbose) EQ 1) then BEGIN
       PRINT,'After calling simple_vars:'
       HELP, b_l, i_l, l_l, f_l, d_l

   ENDIF ELSE MESSAGE,'External call to simple_vars failed'
END

