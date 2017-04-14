;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: 'hello world' type example using Java in IDL
;
; Usage:
;    IDL> hellojava
;
 
pro HELLOJAVA

  ; Create a java String object in IDL.  
  joStr = OBJ_NEW("IDLJavaObject$JAVA_LANG_STRING", "java.lang.String", $
                  "hello IDL (from Java)")
  IF (OBJ_CLASS(joStr) NE "IDLJAVAOBJECT$JAVA_LANG_STRING") THEN BEGIN
    PRINT, '(ERR) creating java.lang.String.  joStr =', joStr
  ENDIF

  ; get the string and show it in IDL
  PRINT, joStr->toString()

  ; delete the object
  OBJ_DESTROY, joStr

end
