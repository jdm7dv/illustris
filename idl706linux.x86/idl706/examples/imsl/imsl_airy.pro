;$Id: //depot/idl/IDL_70/idldir/examples/imsl/imsl_airy.pro#2 $
;
; Copyright (c) 2001-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;  IMSL_AIRY
;
; PURPOSE:
;  This function computes the Airy function using the
;  Visual Numerics IMSL C Numerical Library.
;
; CALLING SEQUENCE:
;  Result = IMSL_AIRY(X)
;
; INPUTS:
;  X: The expression for which the Airy function is required.
;     The result has the same dimensions as X.
;
; KEYWORD PARAMETERS:
;  DERIVATIVE: Set this keyword to compute the derivative of the
;     Airy function.
;
;  DOUBLE: Set this keyword to force the computation to be done
;     in double-precision arithmetic.
;
;  LIBRARY: Set this keyword to the library path and name.
;     The default is 'cmath.dll'
;
;  SECOND_KIND: Set this keyword to compute the Airy function of the
;     second kind (Bi). The default is to compute Ai.
;
; EXAMPLE:
;   Plot the Airy function for the range -14 to +6.
;   IDL> x = (FINDGEN(101)-70)/5.
;   IDL> airy = IMSL_AIRY(x, LIBRARY='C:\IMSL\CNL\bin\cmath.dll')
;   IDL> plot, x, airy, XTITLE='x', YTITLE='Ai(x)'
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, February 2001
;-
function IMSL_AIRY, x, $
    DERIVATIVE=derivative, $
    DOUBLE=double, $
    LIBRARY=libraryIn, $
    SECOND_KIND=second_kind

    ON_ERROR, 2  ; return to caller

; Location of IMSL math library.
    library = (N_ELEMENTS(libraryIn) eq 1) ? libraryIn : 'cmath.dll'

; Directory in which to compile the auto-glue libraries.
    directory = !MAKE_DLL.compile_directory

; Process keywords.
    ; Convert to single or double precision.
    dbl = (N_ELEMENTS(double) gt 0) ? $
        KEYWORD_SET(double) : (SIZE(x,/TNAME) eq 'DOUBLE')
    result = dbl ? DOUBLE(x) : FLOAT(x)

    ; Construct function name from various keyword options.
    function_name = 'imsl_' + (dbl ? 'd' : 'f') + '_airy_'
    suffix = KEYWORD_SET(second_kind) ? 'Bi' : 'Ai'
    function_name = function_name + suffix
    if KEYWORD_SET(derivative) then $
        function_name = function_name + '_derivative'

; Loop thru each input element.
    for i=0L, N_ELEMENTS(result)-1 do begin
        x1 = result[i]
        result1 = CALL_EXTERNAL(library, function_name, $
            x1, $
            VALUE=[1], $             ; Pass by reference (0) or value (1).
            /AUTO_GLUE, $            ; Automatically create & compile.
            COMPILE_DIR=directory, $ ; Location of glue DLLs.
            /CDECL, $                ; Windows calling convention for IMSL.
            RETURN_TYPE=SIZE(x1,/TYPE))  ; IDL type code of the result.
        result[i] = result1
    endfor

    return, result
end
