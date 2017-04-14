;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: demonstrate passing array data between IDL and Java
;
; Usage:
;    IDL> arraydemo
;
; Uses:
;    jbexamples.jar (array2d.java)
;

pro ARRAYDEMO

  ; the Java class array2d creates 2 initial arrays, one of longs and one of shorts
  ; We can interogate and change this array.
  joArr = OBJ_NEW('IDLJavaObject$ARRAY2D', 'array2d')


  ; first let's see what in the short array at index (2,3)
  print, 'array2d short(2,3)=', joArr->getShortByIndex(2,3), '    (should be 23)'

  ; now let's copy the entire array from Java to IDL
  IDL_Short_Arr = joArr->getShorts()
  help, IDL_Short_Arr
  print, 'IDL_Short_arr[2,3]=', IDL_Short_Arr[2,3], '    (should be 23)'

  ; let's change this value
  IDL_Short_Arr[2,3]=999
  ; ...and copy it back to Java.
  joArr->setShorts, IDL_Short_Arr
  ; ... now its value should be different
  print, 'array2d short(2,3)=', joArr->getShortByIndex(2,3), '    (should be 999)'

  ;lets set our array to something different
  joArr->setShorts, indgen(10,8)
  print, 'array2d short(0,0)=', joArr->getShortByIndex(0,0), '    (should be 0)'
  print, 'array2d short(1,0)=', joArr->getShortByIndex(1,0), '    (should be 1)'
  print, 'array2d short(2,0)=', joArr->getShortByIndex(2,0), '    (should be 2)'
  print, 'array2d short(0,1)=', joArr->getShortByIndex(0,1), '    (should be 10)'

  ; array2d has a setLongs method, but b/c arrays do not (currently)
  ; promote, the first call to setLongs works but the second fails
  joArr->setLongs, l64indgen(10,8)
  print, 'array2d long(0,1)=', joArr->getLongByIndex(0,1), '    (should be 10)'

  ; If uncommented, this line would give an error
  ;joArr->setLongs, indgen(10,8)

  ; clean up our object
  OBJ_DESTROY, joArr

end
