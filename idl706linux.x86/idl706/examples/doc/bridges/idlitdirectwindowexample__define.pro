;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/idlitdirectwindowexample__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This example demonstrates how to create a subclass of the
; IDLitDirectWindow class for use in an object exported via the
; IDL Export Bridge assistant.
;
; For an example Java class that uses this class, see the
; file <IDL_DIR>/resource/bridge/export/java/IDLWindowExample.java.
; Instructions for using that class are contained in the .java
; file, and in the IDL Connectivity Bridges manual.
;
; MODIFICATION HISTORY:
;   Created, Sept 2005
FUNCTION IDLitDirectWindowExample::Init, _EXTRA=_extra

    IF (~self->IDLitDirectWindow::Init(_EXTRA=_extra)) THEN $
        RETURN, 0
    self->MakeCurrent
    DEVICE, DECOMPOSED=0
    ERASE
    XYOUTS, 0.05, 0.95, 'Click and drag to draw', /NORM, COLOR=255
    XYOUTS, 0.05, 0.90, 'Hold Shift for thicker line', /NORM, COLOR=255
    XYOUTS, 0.05, 0.85, 'Hold Control to erase', /NORM, COLOR=255
    RETURN, 1
END

PRO IDLitDirectWindowExample::OnMouseDown, x, y, button, $
    keyMods, nClicks

    ; Look for left button down.
    IF (button EQ 1) THEN BEGIN
        self.buttonDown = 1b
        self.inMotion = 0b
    ENDIF
END

PRO IDLitDirectWindowExample::OnMouseUp, x, y, button

    ; Look for left button up.
    IF (button EQ 1) THEN BEGIN
        self.buttonDown = 0b
        self.inMotion = 0b
    ENDIF
END

PRO IDLitDirectWindowExample::OnMouseMotion, x, y, keyMods

    IF (~self.buttonDown) THEN RETURN
    ; Hold <Shift> for a thick line.
    IF ((keyMods AND 1) NE 0) THEN thick = 3
    ; Hold <Ctrl> for a black line (an eraser).
    IF ((keyMods AND 2) NE 0) THEN color = 0
    PLOTS, x, y, /DEVICE, CONTINUE=self.inMotion, $
        THICK=thick, COLOR=color
    self.inMotion = 1b
END

PRO IDLitDirectWindowExample::OnKeyboard, isASCII, $
    Character, keyValue, x, y, Press, Release, keyMods

    ; Suppress messages if we have the mouse down and are just
    ; using a modifier key.
    IF (self.buttonDown) THEN RETURN
    IF (isASCII && Press) THEN BEGIN
        POLYFILL, [0,0.2,0.2,0], [0,0,0.2,0.2], COLOR=0
        XYOUTS, 0.05, 0.05, STRING(Character), /NORM, CHARSIZE=3
    ENDIF
END

PRO IDLitDirectWindowExample::OnEnter
    self->NotifyBridge, "IDLitDirectWindowExample", "OnEnter"
    self->MakeCurrent
END

PRO IDLitDirectWindowExample::OnExit
    self->NotifyBridge, "IDLitDirectWindowExample", "OnExit"
END

PRO IDLitDirectWindowExample__define
     void = {IDLitDirectWindowExample, $
        inherits IDLitDirectWindow, $
        buttonDown: 0b, $
        inMotion: 0b}
END
