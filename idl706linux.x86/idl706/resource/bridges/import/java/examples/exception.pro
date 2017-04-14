;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: demonstrate catching and querying Java exceptions from IDL
;
; Usage:
;    IDL> exception
;

pro EXCEPTION


  size = -2
  ; Our Java constructor might throw an exception, so let's catch it
  catch, error_status
  IF error_status NE 0 THEN BEGIN

     catch, /cancel

     ; This procedure queries the exception and prints information about it
     showexcept

     ; make size big enough that 2nd try will work
     size = size + 100
  ENDIF

  ; This will throw a Java exception the 1st time
  o = OBJ_NEW("IDLJavaObject$java_lang_StringBuffer", "java.lang.StringBuffer", size)

  ; if we get here, we've suceeded
  print, 'Success!'
  help, o

  ; cleanup
  OBJ_DESTROY, o

end
