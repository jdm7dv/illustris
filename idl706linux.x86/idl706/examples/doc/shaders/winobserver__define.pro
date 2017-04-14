;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/winobserver__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       winobserver__define.pro
;
;  CALLING SEQUENCE: winobserver
;
;  PURPOSE:
;       Window observer.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY: Shaders
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       referenced by shader_multitexture_doc.pro
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       7/2006
;-
;-----------------------------------------------------------------
;
function winobserver::Init, oShader
	self.oShader = oShader
	return, 1
end

pro winobserver::OnKeyboard, Window, IsASCII, Character, KeySymbol, X, Y, $
   Press, Release, Modifiers
	;; nop
end

pro winobserver::OnMouseDown, Window, X, Y, ButtonMask, Modifiers, NumClicks
	;; nop
end


PRO winobserver::OnMouseMotion, Window, X, Y, Modifiers
	if self.state then $
		self.oShader->SetUniformVariable, 'Scrape', $
			[X/1024.0/4.0 + 125.0/1024.0, Y/512.0/4.0+300.0/512.0]
	Window->Draw
end

pro winobserver::OnMouseUp, Window, X, Y, ButtonMask
	self.state = 1 - self.state
	if self.state eq 0 then $
		self.oShader->SetUniformVariable, 'Scrape', [0.0, 0.0]
	if self.state eq 1 then $
		self.oShader->SetUniformVariable, 'Scrape', $
			[X/1024.0/4.0 + 125.0/1024.0, Y/512.0/4.0+300.0/512.0]
	Window->Draw
end

pro winobserver::OnExit
   print, "cleaning up"
   OBJ_DESTROY, self
end

pro winobserver::SetProperty, SHADER=shader
	if N_ELEMENTS(shader) gt 0 then $
		self.oShader = shader
end

pro winobserver__define
void = {winobserver, $
		oShader: OBJ_NEW(), $
		state: 0L}
end
