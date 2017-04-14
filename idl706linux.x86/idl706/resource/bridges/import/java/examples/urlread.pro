; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: read from an array into an array of bytes
;
; Parameters:
;    sURLName: the URL (e.g. 'http://www.ittvis.com')
;
; Usage:
;    IDL> data = urlread(<url>)
;
; Uses:
;    jbexamples.jar (URLReader.java)
;

FUNCTION URLREAD, sURLName

  IF (SIZE(sURLName, /TYPE) EQ 0) THEN BEGIN
     print, 'Usage: data = urlread(<URL>)'
     byteArr = 0
  ENDIF ELSE BEGIN

     ; Create our URLReader
     ojURLReader = OBJ_NEW('IDLJavaObject$URLReader', 'URLReader')

     ; read the URL data into our Java-side buffer
     nBytes = ojURLReader->readURL(sURLName)

     ; pull the data into IDL
     byteArr = ojURLReader->getData()

     ; clean up out Java object
     OBJ_DESTROY, ojURLReader
  ENDELSE

  ; return the data 
  return, byteArr
END

