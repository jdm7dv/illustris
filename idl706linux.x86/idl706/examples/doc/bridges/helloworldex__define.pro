
;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/helloworldex__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       helloworldex__define.pro
;
;  CALLING SEQUENCE: none
;
;  PURPOSE:
;       Demonstrates how to create a simple, non-graphical custom
;       IDL object that includes a method. This object will be
;       exported using the IDL Export Bridge Assistant for use in
;       an external application.
;
;       Search for hellowworldex__define.pro in the Online Help index to
;       locate the section of documentation that describes
;       how to use the Export Bridge Assistant to create the export
;       object files associated with this example.
;
;       In a VB.NET console application, you must
;       register helloworldex.dll and add a reference to this
;       COM library in your project.
;
;  MAJOR TOPICS: Bridges
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       com_export_helloex_doc.txt: COM sample application using this object
;       helloworldex_example.java:  Java sample application using this object
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       12/05,   SM - written
; -----------------------------------------------------------
; Method returns message based on presence or
; absence of argument.
FUNCTION helloworldex::HelloFrom, who
      IF (N_ELEMENTS(who) NE 0) THEN BEGIN
      MESSAGE = "Hello World from " + who
      RETURN, message
   ENDIF ELSE BEGIN
      MESSAGE = 'Hello World'
      RETURN, message
   ENDELSE
END

; -----------------------------------------------------------
; Init returns object reference on successful
; initialization.
FUNCTION helloworldex::INIT

   RETURN, 1

END

; -----------------------------------------------------------
; Object definition.
PRO helloworldex__define
  struct = {helloworldex, $
     who: '' , $
     message: ' ' $
  }
END
