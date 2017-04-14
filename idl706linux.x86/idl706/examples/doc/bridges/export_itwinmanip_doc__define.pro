;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/export_itwinmanip_doc__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       export_itWinManip_doc__define.pro
;
;  CALLING SEQUENCE: none
;
;  PURPOSE:
;       This example demonstrates how to create a subclass of the
;       IDLitWindow class for use in an object exported via the
;       IDL Export Bridge assistant, and how to handle keyboard events.
;
;       To use this object, you must export it using the Export
;       Bridge Assistant. Search for the name of this file in the
;       Online Help index for instructions on how to set the object
;       parameters during export.
;
;  MAJOR TOPICS: Bridges
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       com_export_itwinmanip_doc.txt       COM sample application using this object
;       export_itwinmanip_doc_example.java  Java application using this object
;       export_itwinmanip_delete.java       supporting subclass
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       12/05,   SM - written
;-
;---------------------------------------------------------------
FUNCTION export_itWinManip_doc::Init, $
    RENDERER=renderer, _EXTRA=_extra

    ; Some video cards experience problems when using
    ; OpenGL hardware rendering. We set the window to use
    ; IDL's software rendering by default. To use hardware
    ; rendering instead, set renderer=0.
    renderer = 1
    IF (~self->IDLitWindow::Init(RENDERER=renderer, $
        _EXTRA=_extra)) THEN RETURN, 0

    iSurface, USER_INTERFACE='None'
    id = ITGetCurrent(TOOL=oTool)
    oTool->_SetCurrentWindow, self
    iSurface, HANNING(300,300), /OVERPLOT


   ; Print available tools to the output window. You can
   ; then decide which to expose in your external program
   ; and hard code the correct values there.
   vLngthTool = STRLEN(id) + STRLEN('manipulators/')
   vManip = oTool->FindIdentifiers(/MANIPULATORS)
   FOR i = 0, (N_ELEMENTS(vManip)-1) DO BEGIN
      vStr=vManip[i]
      vLngthString = STRLEN(vStr)
      vTool = STRMID(vStr, (vLngthTool+1))
      PRINT, vTool
   ENDFOR

   RETURN, 1

END


;---------------------------------------------------------------
PRO export_itWinManip_doc::ChangeManipulator, manipId

   ; Activate the maniuplator based on the string
   ; manipId value passed in.
    id = ITGetCurrent(TOOL=oTool)
    oTool->_SetCurrentWindow, self
    oTool->ActivateManipulator, manipId

END


;----------------------------------------------------------------
PRO  export_itWinManip_doc::OnKeyboard, IsASCII, Character, $
   KeySymbol, X, Y, Press, Release, Modifiers

   id = ITGetCurrent(TOOL=oTool)
   oTool->_SetCurrentWindow, self

   ; Get the number of selected items.
    array = self->getselecteditems(count=count)

   ; If the delete key has been pressed, then delete selected items.
   IF count GT 0 THEN BEGIN
      IF (isASCII EQ 1) AND  (character eq 127) THEN BEGIN
         FOR i = 0, count-1 DO BEGIN
            OBJ_DESTROY, array[i]
         ENDFOR
         ; Redraw the view.
         self->Draw
      ENDIF 
   ENDIF
      ; Access superclass for text annotations and other keys.
      self->IDLitWindow::OnKeyboard, IsASCII, Character, $
         KeySymbol, X, Y, Press, Release, Modifiers
END

;---------------------------------------------------------------
PRO export_itWinManip_doc__define
     void = {export_itWinManip_doc, inherits IDLitWindow}
END
