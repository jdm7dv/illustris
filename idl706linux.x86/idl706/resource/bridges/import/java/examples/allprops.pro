;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Show all java.lang.System properties using a java.util.Enumeration
; and IDL to sort the list
;
; Usage:
;    IDL> allprops
;
 
pro ALLPROPS

  ; java.lang.System static object
  oSystem = OBJ_NEW("IDLJavaObject$STATIC$SYSTEM", "java.lang.System")

  ; get all the properties (java.util.Properties)
  oProps = oSystem->getProperties()

  ; get Properties's Java Enumeration object
  oEnum = oProps->propertyNames()

  ; create a STRING array to store the data in
  propList = STRARR(oProps->size())

  ; Use Enumerator to loop on all properties
  i = 0;
  WHILE (oEnum->hasMoreElements()) DO BEGIN
     ; use enumerator to get next Property object.  Enumerator also increments
     oProp = oEnum->nextElement()

     sPropName = oProp->toString()
     propList[i] = STRING(FORMAT='(A," = ",A)', sPropName, oProps->getProperty(sPropname))
     i = i + 1

     OBJ_DESTROY, oProp

  ENDWHILE

  ; Now use IDL to sort our list
  propList = propList[SORT(propList)]
  FOR i=0,N_ELEMENTS(propList)-1 DO BEGIN
     print, propList[i]
  ENDFOR

  ; cleanup
  OBJ_DESTROY, oSystem, oProps, oEnum

end
