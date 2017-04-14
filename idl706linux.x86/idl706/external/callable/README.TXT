------------------------------------------------------------
README file: <IDL_Directory>	
     		          external
		                callable
------------------------------------------------------------

This directory contains calltest, an example program that demonstrates
the use of callable IDL from C on all IDL platforms. It demonstrates
the following things:

	- Importing data from a program into IDL, such that it
	  appears to IDL as a variable, while sharing memory
     allocated by the calling program.

	- Accessing the data for IDL variables from a calling program.

	- Issuing commands and statements for IDL to execute.

	- Graphics and widgets.

The calltest program writes information about the variables it is
accessing, produces a line plot in the upper right corner of the
screen, and creates a separate widget button (with the label "Done").
When you press the button, the program exits.

The Unix version writes its output to the standard output, where it
will be visible on your tty. The Windows version creates a log window
in the lower left corner of your screen to display its output.

This program consists of the following files:
	
	[calltest.c]
	    Code that implements the Callable IDL related
       parts of a program that calls IDL. Under Unix,
	    this file is a complete program.

	[calltest_win.c]
	    Under Microsoft Windows, there is additional code
       code required to create a log window for output
	    and to do the additional initialization required on
	    that platform. This code is found in calltest_win.c.

   [calltest.h]
	    Prototypes and macros needed for calltest.c and calltest_win.c
	    to cooperate.
	   
	[makefile]
	    For Windows only. This is a makefile used to build
	    calltest, for use with the Windows-specific nmake command.

Also included is a Fortran version of calltest, in the file calltest.f.

There is an Xcode project for Mac OS X users in the xcode_calltest directory.
See the Xcode-specific section later in this file.


-----------------------------------------------------------------------------
Unix Specific Information
-----------------------------------------------------------------------------

Building calltest follows the same general approach on all Unix
systems: You must compile the source file (calltest.c) and then link
it against the IDL sharable library and any system libraries required
to complete the link. Although this is straightforward, the specific
libraries that must be used, and their locations, differ for different
versions of Unix.

The Unix IDL distribution includes a directory named "bin" that
contains the executables for idl and its related programs. For every
supported operating system and hardware architecture supported by your
installation, you will find a subdirectory containing the platform-
specific binaries for that system. For example, platform-specific
support for Sun Solaris running on 32-bit Sparc hardware is found in
$IDL_DIR/bin/bin.solaris2.sparc. Each of these directories contains a
makefile that shows how to relink IDL. Also found in each makefile is
a rule to build calltest. To understand how calltest is built (and
therefore how to link other callable IDL programs) you should read the
IDL makefile for the platform(s) you are using.

The following instructions include example statements that show how
to build calltest. These examples assume that you have an environment
variable named "IDL_DIR" that points to the root of the IDL installation
of your system, you are running /bin/csh or a compatible shell, and you
wish to build calltest for Solaris on Sparc hardware. If your situation
differs, you will need to adjust these statements accordingly.

To build calltest for Solaris on Sparc hardware:

    (1) Create an empty scratch directory to build calltest in.

		% mkdir ~/calltest
		% cd ~/calltest

    (2) Copy the makefile to your new empty directory.

		% cp $IDL_DIR/bin/bin.solaris2.sparc/Makefile .

    (3) Build calltest.

		% make IDLDIR=$IDL_DIR calltest

    (4) To run calltest on many systems, you will need to add the
        IDL architecture specific bin directory to your dynamic library
        search path. Under most Unixes, this is LD_LIBRARY_PATH. Under
        OS X it is DYLD_LIBRARY_PATH.

		% setenv LD_LIBRARY_PATH \
		         $IDL_DIR/bin/bin.solaris2.sparc:$LD_LIBRARY_PATH
    (5) Run it.

		% ./calltest



-----------------------------------------------------------------------------
Microsoft Windows Specific Information
-----------------------------------------------------------------------------

The calltest program was built and tested using the Microsoft Visual
C++ 8.0 compiler on both 32-bit and 64-bit Windows systems.
Using a different compiler may require you to make changes before this
program will work. Please refer to your compiler documentation for
additional information.

Building calltest under Microsoft Windows is done using the
Microsoft-specific nmake command with the makefile found in this
directory:

For Visual C++ 8.0:

    (1) Build calltest.exe

        For a 32-bit build using the default makefile:

		nmake

        For a 64-bit build using the IDL library/DLL from bin.x86_64.

		nmake -f makefile64 APPVER=5.02

    (2) Run it.  You will need to have the idl.dll file in a directory
        included in the PATH environment variable or in the same directory
        as the calltest executable.

		calltest

By default, the supplied makefile links calltest.exe directly to
the IDL DLL. Under some circumstances (described in readme_callproxy.txt
in this directory), you may wish to instead make use of the Windows
IDL Call Proxy library instead of making a direct link to IDL. The
calltest program can also be built using the Call Proxy Library. To
do so:

    (1) Edit makefile, and uncomment the two lines that follow
        the "[CALLPROXY]" comment (one for CFLAGS_CALLPROXY, and the
        other for IDLLIB). To uncomment the lines, remove
        the initial '#' character of each line.

    (2) Remove any previously built copy of calltest.

    (3) Build calltest.exe.  See directions above.

		nmake

    (4) Run it.  See directions above.

		calltest

To see how a Callable IDL application is converted to use
the proxy library, search for the string "IDL_CALLPROXY_LIB"
in the file calltest_win.c.

In order to compile a Callable IDL application, you must pass the
following flags to your C compiler:

	-DMS_WIN -DWIN32 -D_DLL -D_MT

In addition, IDL requires the use of the multi-threaded DLL version
of the Microsoft C runtime library, which means that you must
link with msvcrt.lib. See the makefile for information on how
these options were specified to build the calltest example.


-----------------------------------------------------------------------------
Mac OS X Xcode Project Information
-----------------------------------------------------------------------------

The xcode_calltest directory contains an Xcode 2.2.1 project for building the
'calltest' example program.  The remainder of this section contains
instructions for using this Xcode project.  Xcode 3.0 should be able to read
this project.

CREATING YOUR WORK AREA

If file access permissions allow, you may be able to build and run calltest
in the IDL installation directory (<INSTALL_DIR>/external/callable).  But
it is probably safer to copy the entire callable directory to your own
private workspace, particularly if you think you may make any changes to the
example code.

COMPILING THE PROJECT

Either launch Xcode and locate the Xcode project or use Finder to locate the
Xcode project and launch Xcode from Finder.  The Xcode project is found in
the callable/xcode_calltest/xcode_calltest.xcodeproj file.

You'll need to tell Xcode where the IDL idl_export.h file is and where the
IDL libraries are located.

In Xcode:

Project->Edit Project Settings and Select the Build pane.

Make sure that the "Header Search Paths" setting is set to:

   <IDL_DIR>/external/include

Make sure that the "Library Search Paths" setting is set to one of:

   <IDL_DIR>/bin/bin.darwin.ppc
   <IDL_DIR>/bin/bin.darwin.i386
   <IDL_DIR>/bin/bin.darwin.x86_64

as appropriate for your architecture, where <IDL_DIR> is the path
to your IDL installation.

For 64-bit Intel builds there are a few other changes:

(1) Change "Other Linker Flags" from referencing -lfreetype2_1_3 to just
    -lfreetype.  The x86_64 version of IDL uses the FreeType library that
    Apple ships with Mac OS 10.5+.

(2) Change "Library Search Paths" by adding "/usr/X11/lib".  This is where
    Apple's FreeType library is located.

(3) Change "Architectures" from 32-bit to 64-bit.  The resultant architecture
    should be "x86_64".

At this point, clicking "Build" in Xcode should build the executable
successfully.


RUNNING THE CALLTEST PROGRAM

Before you can run the program from Xcode, you must set some environment
variables.

Open the "Executables" list in Xcode and double-click on the xcode_calltest
executable.

Select the "Arguments" pane.

Set the following environment variables:

DISPLAY
   to the address of the X11 server running on your machine.  If X11 is not
   running, start it.  If you do not know the value of the DISPLAY variable,
   issue "echo $DISPLAY" in the X11's xterm application.

DYLD_LIBRARY_PATH
   to one of

      <IDL_DIR>/bin/bin.darwin.ppc
      <IDL_DIR>/bin/bin.darwin.i386
      <IDL_DIR>/bin/bin.darwin.x86_64

IDL_DIR
   to <IDL_DIR>

where <IDL_DIR> is the path to your IDL installation.

After making the above changes, you should be able to execute your calltest
program from Xcode.  Note that in Xcode 3.0 the console can be opened via
the Run->Console menu item.


