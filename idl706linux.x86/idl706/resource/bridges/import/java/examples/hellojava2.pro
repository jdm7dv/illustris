;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: 'hello world' type example using Java in IDL
;
; Usage:
;    IDL> hellojava2
;
; Uses:
;    jbexamples.jar (helloWorld.java)
;
 
pro HELLOJAVA2

  ; Create a 'helloWorld' Java object and have it say hello in IDL.

  ; Create the object first
  joHello = OBJ_NEW("IDLJavaObject$HelloWorld", "helloWorld")

  ; Call the 'sayHello' method on the object.  This sends a message to 
  ; System.out, which shows up in IDL.
  joHello->sayHello

  ; delete the object
  OBJ_DESTROY, joHello

end
