------------------------------------------------------------
README file: <IDL_Directory>	
                          external
                             include
------------------------------------------------------------

The include directory includes any header files necessary to build
external code to be combined with IDL. In particular, idl_export.h
is found here.

For backwards compatibility, a file named "export.h" exists in the
subdirectory above this one. That file is an exact copy of idl_export.h,
and is kept there for backwards compatibility with older releases of
IDL. New code should use idl_export in preference to that older file.

The renaming of export.h to the prefixed name idl_export.h, and the change
of location to this include subdirectory was done to make it easier
to build code that involves IDL as well as other packages. The non-generic
name and the fact that only header files are kept here minimizes any
include path conflicts that might otherwise occur.

On Windows systems, this directory includes the idl_callproxy.h
header file. This header is used by the IDL Call Proxy library,
described in readme_callproxy.txt in the external/callable 
subdirectory.

On UNIX systems, this directory includes header files used by
the IDL RPC server, described in readme.txt in the external/rpc
directory.
