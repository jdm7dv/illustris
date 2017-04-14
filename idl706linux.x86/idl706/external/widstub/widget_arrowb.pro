;	$Id: //depot/idl/IDL_70/idldir/external/widstub/widget_arrowb.pro#2 $

function WIDGET_ARROWB, parent, use_own_size, UVALUE=uvalue, $
	VERBOSE=verbose, _EXTRA=extra
  ; Uses WIDGET_STUB, and a sharable library containing the necessary
  ; C support code, to provide the IDL user with a Motif Arrow Button
  ; widget. The interface is consistent with that presented by the built
  ; in IDL widgets.
  ;
  ; If the sharable library does not exist, it is built using MAKE_DLL.

  common WIDGET_ARROWB_BLK, shlib

  ; Build sharable library if this is the first call or lib doesn't exist
  build_lib = n_elements(shlib) eq 0
  if (not build_lib) then build_lib = not FILE_TEST(shlib, /READ)
  if (build_lib) then begin
    ; Location of the widget_arrowb files from the IDL distribution
    arrowb_dir = FILEPATH('', SUBDIRECTORY=[ 'external', 'widstub' ])

    if (!version.os eq 'darwin') then extra_cflags = '-I/usr/X11R6/include'

    ; Use MAKE_DLL to build the widget_arrowb sharable library in the
    ; !MAKE_DLL.COMPILE_DIRECTORY directory.
    ;
    ; Normally, you wouldn't use VERBOSE, or SHOW_ALL_OUTPUT once your
    ; work is debugged, but as a learning exercize it can be useful to
    ; see all the underlying work that gets done. If the user specified
    ; VERBOSE, then use those keywords to show what MAKE_DLL is doing.
    MAKE_DLL, 'widget_arrowb','widget_arrowb', INPUT_DIR=arrowb_dir, $
	  DLL_PATH=shlib, VERBOSE=verbose, SHOW_ALL_OUTPUT=verbose, $
	  EXTRA_LFLAGS=extra_lflags, EXTRA_CFLAGS=extra_cflags
  endif

  ; Use a stub widget along with the C code in the library to
  ; create an arrow button widget. The use of the AUTO_GLUE keyword
  ; simplifies the call to the sharable library by eliminating the
  ; need to use the CALL_EXTERNAL portable calling convention.
  l_parent=LONG(parent)
  l_use_own_size = (n_elements(use_own_size) eq 0) ? 0: LONG(use_own_size)
  result = WIDGET_STUB(parent, _extra=extra)
  if (n_elements(uvalue) ne 0) then WIDGET_CONTROL, result, set_uvalue=uvalue
  JUNK = CALL_EXTERNAL(shlib, 'widget_arrowb', l_parent, result, $
		       l_use_own_size, value=[1, 1, 1], /AUTO_GLUE)

  return, result
end
