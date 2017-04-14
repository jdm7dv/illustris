;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Given a fully-qualified classname, display all pblic
;          constructors, mnethods and fields (all from within IDL)
;
; Parameters:
;    sClassName: fully qualified classname (e.g. 'java.lang.String')
;
; Usage:
;    IDL> publicmembers, '<classname>'
;
; Uses:
;    jbexamples.jar (PublicMembers.java)
;

PRO publicmembers, sClassName

  ; Make sure classname was provided
  IF (SIZE(sClassName, /TYPE) EQ 0) THEN BEGIN
     print, 'Usage: publicmembers, <classname>'
     goto, the_end
  ENDIF

  oPublic = OBJ_NEW('IDLJavaObject$Static$PublicMembers', 'PublicMembers')
  oPublic->printAllMembers, sClassName
  OBJ_DESTROY, oPublic

the_end:
END

