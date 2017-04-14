The Windows IDL Call Proxy Library (idl_callproxy.lib)
----------------------------------------------------------------------------

IDL is built as a sharable library, known as a Dynamic Link Library
(DLL) under Microsoft Windows. This document will use the two terms
interchangeably to refer to the same basic concept.

The standard interactive form of IDL is in fact a fairly small
front end program that is linked to the IDL sharable library.
The IDL sharable library can also be called from other programs
written in languages like C/C++ or Fortran. We refer to IDL used
in this way as "Callable IDL". Typically, Callable IDL programs are
linked directly to the IDL sharable library. This works well as long
as the IDL sharable library is in a known location on the system.
However, when distributing a program to be run on other systems,
there is the possibility that IDL is installed at a different
location than the program expects. Unless all the necessary libraries
are found, the operating system will not be able to run the program.

Under Unix, if a library cannot be found when the program is run,
error messages provide the name of the missing library. This makes
diagnosing the problem relatively easy, and problems with missing
libraries can usually be solved using a wrapper shell script
that sets the LD_LIBRARY_PATH environment variable so that the
sharable library can be found. 

When a Microsoft Windows program fails to locate the DLLs it needs
at startup, the result is that the program simply doesn't run -- no
errors are produced. This can be confusing for users, especially
those who are relatively non-technical.

The rules used by Windows to locate DLLs are described in the
documentation for the LoadLibrary() system function. Among the
possible solutions to the problem of missing DLLs are:
  - copying the IDL DLLs into standard system directories
    (a very bad idea).
  - setting the PATH environment variable to include the
    IDL bin directory.
  - using the IDL Call Proxy library.

The IDL Call Proxy library is a library of stub functions that offer
the same function interfaces as Callable IDL. Your program links to
this library instead of to Callable IDL. Since it is a standard
library (not a DLL), its code is contained within your program.
Hence, your program does not require the IDL sharable library to run.
Before you can call IDL functions from such a program, you must make a
call to an initialization function telling it where the IDL library is
found. The Call Proxy library loads the Callable IDL library, and then
your program uses callable IDL as usual.

To use the Call Proxy library in your program, start by getting
it to work with Callable IDL in the standard way. Once you have
your program working, the following steps will convert it to use
the proxy library:

    1) Modify your project makefile to link with idl_callproxy.lib
       instead of idl.lib.

    2) In your source code, add a #include statement for
       "idl_callproxy.h" next to the existing #include for
       "idl_export.h".

    3) Add a call to IDL_CallProxyInit("idlpath") to your application
       during its initialization phase. This must be the first IDL
       function called by your program, and is often called immediately
       above the call to IDL_Win32Init(). Note that idlpath must be
       a complete path to the IDL DLL. If the path is invalid or if
       IDL and its required DLLs are not found, then IDL_CallProxyInit()
       will return FALSE to indicate failure.  A return value of TRUE
       indicates that IDL is loaded properly and is available for use.

       To provide a path to the IDL DLL, we suggest the following
       steps:

	    a) Check a typical default path
	       (e.g. <IDL_DIR>\bin\bin.x86\idl.dll)
          and if the DLL is present, use it.

	    b) Display a file search dialog and let the user find the DLL.

	    c) If your program cannot find the DLL, provide a helpful
          error message so that the user will know what is wrong
          and can take steps to fix the problem.

The calltest program found in this directory is by default
a standard Callable IDL application. By uncommenting two lines
in the makefile and rebuilding the program, you can convert calltest
to use the Call Proxy library. Search the file calltest_win.c for the
IDL_CALLPROXY_LIB preprocessor macro to see the necessary changes
(which consist of two additional lines of code).
