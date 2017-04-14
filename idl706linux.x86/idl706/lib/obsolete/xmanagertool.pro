; $Id: //depot/idl/IDL_70/idldir/lib/obsolete/xmanagertool.pro#2 $
;
; Copyright (c) 1992-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.

pro  XManagerTool, GROUP = GROUP
;+NODOCUMENT
;+
; NAME:
;	XManagerTool
;
; PURPOSE:
;	The XmanagerTool procedure has been renamed XMTool for
;	compatibility with operating systems with short filenames
;	(i.e. MS DOS). XManagerTool remains as a wrapper that calls
;	the new version. See the documentation of XMTool for information.
;
; CATEGORY:
;	Widget Management.
;
; MODIFICATION HISTORY:
;	TC, 20 December 1992
;-

XMTOOL, GROUP = GROUP

end
