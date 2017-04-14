;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Show IDL-Java bridge version information
;
; Usage:
;    IDL> bridge_version
;

pro BRIDGE_VERSION

  ; Grab the special IDLJavaBridgeSession object
  oBridgeSession = OBJ_NEW("IDLJavaObject$IDLJAVABRIDGESESSION")
  help, oBridgeSession

  oVersion = oBridgeSession->getVersionObject()
  help, oVersion

  print, 'Java version:', oVersion->getJavaVersion()
  print, 'Bridge version:', oVersion->getBridgeVersion()
  print, 'Build date:', oVersion->getBuildDate()


  OBJ_DESTROY, oVersion
  OBJ_DESTROY, oBridgeSession

end
