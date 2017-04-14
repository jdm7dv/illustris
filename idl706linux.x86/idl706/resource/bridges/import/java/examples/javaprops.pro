;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Show java.lang.System properties that pertain to Java
;
; Usage:
;    IDL> javaprops
;
 
pro JAVAPROPS

  ; Get some properties from Java (via IDL and the Java bridge) and show them

  ; System is a static class, so create an IDLJavaObject STATIC object
  oSystem = OBJ_NEW("IDLJavaObject$STATIC$JAVA_LANG_SYSTEM", "java.lang.System")
  IF (OBJ_CLASS(oSystem) NE "IDLJAVAOBJECT$STATIC$JAVA_LANG_SYSTEM") THEN BEGIN
    PRINT, '(ERR) creating java.lang.System.  oSystem =', oSystem
  ENDIF

  ; Print some of java.lang.System's properties
  print, "java.version: ", oSystem->getProperty("java.version")
  print, "java.vendor: ", oSystem->getProperty("java.vendor")
  print, "java.class.path: ", oSystem->getProperty("java.class.path")
  print, "java home: ", oSystem->getProperty("java.home")
  print, "java.vm.name: ", oSystem->getProperty("java.vm.name")
  print, "java.vm.version: ", oSystem->getProperty("java.vm.version")
  print, "java.vm.vendor: ", oSystem->getProperty("java.vm.vendor")

  ; delete the object
  OBJ_DESTROY, oSystem

end
