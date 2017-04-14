------------------------------------------------------------
README file: <IDL_Directory>	
                           external
                              call_external
                                 Fortran
------------------------------------------------------------

This directory contains examples which demonstrate the usage
of the CALL_EXTERNAL function under Unix. 

To run the examples routines, first the shared object libraries must
be built. To build the shared object libraries, issue the following 
command:
	% make
  
    Note: To make all the example shared object libraries, a 
	  C and a Fortran compiler are required.

    To run the call_external() examples, start IDL and call
    one of the following IDL procedures at the IDL command prompt:
	IDL> simple_c2f
	IDL> ftn_only

    Note:  This makefile builds the example and example1 shared
           libraries referenced in the CALL_EXTERNAL documentation.
           To run these examples, please see the CALL_EXTERNAL chapter
           of the External Development Guide. 

    To clean up the directory:
	% make clean

The makefile uses the correct options for the standard compiler
for each supported system. If you use a different compiler,
you may need to change the compilation or link flags. Also, each
of the IDL procedures contains logic to set the name of the
entry point in the shared library. The name of the entry point
in the CALL_EXTERNAL call may be incorrect if you use a different
compiler.

Note that if you have installed IDL in a directory other than the default, then
the macro IDL will need to be changed to the location of you IDL distribution. 
