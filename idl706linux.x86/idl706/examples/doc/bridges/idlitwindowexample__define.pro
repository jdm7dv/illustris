;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/idlitwindowexample__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This example demonstrates how to create a subclass of the
; IDLitWindow class for use in an object exported via the
; IDL Export Bridge assistant.
;
; For an example Java class that uses this class, see the
; file <IDL_DIR>/resource/bridge/export/java/IDLWindowExample.java.
; Instructions for using that class are contained in the .java
; file, and in the IDL Connectivity Bridges manual.
;
; MODIFICATION HISTORY:
;   Created, Sept 2005

FUNCTION IDLitWindowExample::Init, $
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
    RETURN, 1
END

PRO IDLitWindowExample::OnEnter
    self->NotifyBridge, "IDLitWindowExample", "OnEnter"
END

PRO IDLitWindowExample::OnExit
    self->NotifyBridge, "IDLitWindowExample", "OnExit"
END

PRO IDLitWindowExample__define
     void = {IDLitWindowExample, inherits IDLitWindow}
END
