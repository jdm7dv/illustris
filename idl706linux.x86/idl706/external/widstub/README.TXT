------------------------------------------------------------
README file: <IDL_Directory>	
		  external
		    widstub
------------------------------------------------------------

This directory contains files used to build the WIDGET_ARROWB
WIDGET_STUB demonstration program. It uses the WIDGET_STUB functionality
in IDL to add a Motif Arrow Button Widget to the built in widgets supported
by IDL. Using the MAKE_DLL procedure, WIDGET_ARROWB automatically compiles
and links the necessary C code from the IDL distribution transparently to
the user, on demand.

This example assumes Unix IDL and the Motif toolkit. WIDGET_STUB can be
used under Microsoft Windows as well, but a better approach would be to
use WIDGET_ACTIVEX to import ActiveX controls.

To Run the WIDGET_ARROWB example:

	IDL> pushd, FILEPATH('', SUBDIRECTORY=['external','widstub'])
	IDL> widget_arrowb_test
	IDL> popd

When running WIDGET_ARROWB_TEST, you can specify the VERBOSE keyword,
in which case, it will show you the compilation and linking steps it
takes to build the sharable library from the C code.

The use of pushd and popd are due to the fact that your IDL search
path (!PATH) is unlikely to have the directory containing these
examples in it. Pushd changes your working directory to the location
where these files are found, and popd restores it to its original location.

For more information about WIDGET_STUB, consult the IDL External
Development Guide.

Note: Mac OS 10.5 does not ship with Motif libraries.  After installing
Motif 2.2.3, change widget_arrowb.pro.  The line where "extra_cflags" is
currently set to '-I/usr/X11R6/include' needs to be modified to reference
the Motif 2.2.3 include directory.
