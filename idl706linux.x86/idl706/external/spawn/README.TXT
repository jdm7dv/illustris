------------------------------------------------------------
README file: <IDL_Directory>	
     		          external
		                spawn
------------------------------------------------------------

This directory contains test_pipe, an example program that demonstrates
how to use the UNIT keyword to the IDL SPAWN procedure to communicate
with a separate program via an operating system pipe. This program is
discussed in the IDL External Development Guide in the
"Using SPAWN and Operating System Pipes" chapter.

There are two files supplied:

	[test_pipe.c]
	    A simple program that reads data from its standard input
	    and writes the result to its standard output.

	[test_pipe.pro]
	    An IDL procedure that demonstrates how to use the IDL
	    SPAWN procedure to run the test_pipe program above and
	    communicate with it.

There are two steps involved in running this example:

	1) Build the test_pipe C program (See instructions below)
	2) From within IDL, change to the <IDL_DIR>/external/spawn
      directory and run the TEST_PIPE procedure.

-----------------------------------------------------------------------------
Unix/Macintosh Specific Information
-----------------------------------------------------------------------------

test_pipe.c is a very simple C program, and can be built
on most platforms using a single command:

	% cc test_pipe.c -o test_pipe


-----------------------------------------------------------------------------
Microsoft Windows Specific Information
-----------------------------------------------------------------------------

The test_pipe program has been built and tested using the Microsoft
Visual C++ development environment. To build test_pipe, you must
run a command window with the necessary compilation environment defined.
For example, under Windows XP with Visual Studio 7, the following command
can be executed from the Start Menu to do so:

	Start->All Programs->Microsoft Visual Studio.NET
	->Visual Studio.NET Tools->Visual Studio.NET Command Prompt

Within that command shell, execute the following commands:

	cl test_pipe.c
	link test_pipe.obj -out:test_pipe.exe
