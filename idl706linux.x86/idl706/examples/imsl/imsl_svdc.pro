;$Id: //depot/idl/IDL_70/idldir/examples/imsl/imsl_svdc.pro#2 $
;
; Copyright (c) 2001-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;  IMSL_SVDC
;
; PURPOSE:
;  This function computes the singular value decomposition of an
;  input array using the Visual Numerics IMSL C Numerical Library.
;
; CALLING SEQUENCE:
;  IMSL_SVDC, A, W, U, V
;
; INPUTS:
;  A: The square (n x n) or non-square (n x m) array to decompose.
;     A can be either single or double precision, and can be complex.
;
;  W: On output, W is an n-element output vector containing the
;     "singular values."
;
;  U: On output, U is an n-column, m-row orthogonal array used
;     in the decomposition of A.
;
;  V: On output, V is an n-column, n-row orthogonal array used
;     in the decomposition of A.
;
; KEYWORD PARAMETERS:
;  DOUBLE: Set this keyword to force the computation to be done
;     in double-precision arithmetic.
;
;  LIBRARY: Set this keyword to the library path and name.
;     The default is 'cmath.dll'
;
; EXAMPLE:
;  Find the SVD of a complex array:
;   IDL> m = 5
;   IDL> n = 20
;   IDL> z = DCOMPLEX(RANDOMN(s,m,n, /DOUBLE), RANDOMN(s,m,n, /DOUBLE))
;   IDL> IMSL_SVDC, z, w1, u1, v1, LIBRARY='C:\IMSL\CNL\bin\cmath.dll'
;   IDL> PRINT, 'IMSL Singular values = ', w1[SORT(w1)]
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, February 2001
;-
pro IMSL_SVDC, arrayIn, wOut, uOut, vOut, $
    DOUBLE=double, $
    LIBRARY=libraryIn

    ON_ERROR, 2  ; return to caller

; Location of IMSL math library.
    library = (N_ELEMENTS(libraryIn) eq 1) ? libraryIn : 'cmath.dll'

; Directory in which to compile the auto-glue libraries.
    directory = !MAKE_DLL.compile_directory

; Input type
    tname = SIZE(arrayIn,/TNAME)
    is_double = (tname eq 'DOUBLE') or (tname eq 'DCOMPLEX')
    is_complex = (tname eq 'COMPLEX') or (tname eq 'DCOMPLEX')

; Single or double precision?
    dbl = (N_ELEMENTS(double) gt 0) ? $
        KEYWORD_SET(double) : is_double

; Construct function name from various keyword options.
    prefix = is_complex ? (dbl ? 'z' : 'c') : (dbl ? 'd' : 'f')
    function_name = 'imsl_' + prefix + '_lin_svd_gen'

; Sample type
    type = is_complex ? (dbl ? DCOMPLEX(0) : COMPLEX(0)) : (dbl ? 0d : 0.0)
    type = SIZE(type, /TYPE)

; Convert to single or double precision.
    array = FIX(arrayIn, TYPE=type)

; Allocate output variables
    dims = SIZE(array, /DIMENSIONS)
    n = dims[0]   ; # of columns
    m = dims[1]   ; # of rows
    wOut = MAKE_ARRAY(n, TYPE=type)
    uOut = MAKE_ARRAY(n, m, TYPE=type)
    vOut = MAKE_ARRAY(n, n, TYPE=type)

; #define values from your imsl/cnl/include/imsl.h (must be long integers).
; These are similar to "keywords" in IDL.
    IMSL_RETURN_USER = 10260L    ; user-allocated output array for W
    IMSL_U_USER      = 10200L    ; user-allocated output array for U
    IMSL_V_USER      = 10203L    ; user-allocated output array for V
    NULL = 0L

; Call the IMSL function
; VALUE = Pass by reference (0) or value (1).
    void = CALL_EXTERNAL(library, function_name, $
        m, n, array, $
        IMSL_RETURN_USER, wOut, $
        IMSL_U_USER, uOut, $
        IMSL_V_USER, vOut, $
        NULL, $                  ; must be the last argument
        VALUE=[1,1,0,1,0,1,0,1,0,1], $
        /AUTO_GLUE, $            ; Automatically create & compile.
        COMPILE_DIR=directory, $ ; Location of glue DLLs.
        /CDECL, $                ; Windows calling convention for IMSL.
        RETURN_TYPE=SIZE(result,/TYPE))  ; IDL type code of the result.

end
