------------------------------------------------------------
README file: <IDL_Directory>	
		  external
		    dlm
------------------------------------------------------------

This directory contains files used to build the TESTMODULE dynamically
loadable module (DLM).

If your platform supports the MAKE_DLL procedure (Unix, Windows)
then you can use the simplified instructions which take advantage of
IDL's ability to build sharable libraries. Otherwise, you should use
the standard instructions.



    To Build TESTMODULE (simplified, Unix, Windows)

	The simplified way to build TESTMODULE is to use
	the build_testmodule IDL procedure contained in this
	directory:

		IDL> pushd, FILEPATH('', SUBDIRECTORY=['external','dlm'])
		IDL> build_testmodule
		IDL> popd

        The BUILD_TESTMODULE procedure builds and loads the DLM, and then
        calls the 2 routines it contains. If specify the VERBOSE keyword
        to BUILD_TESTMODULE, it will show you the compilation and linking
        steps it takes to build the sharable library from the C code.
        Since the directory containing the testmodule example is not
        usually in your path, PUSHD is used to temporarily move your
        current working directory to the proper location so IDL will
        find build_testmodule.pro to compile. POPD is used to restore
        your working directory to its previous location.





    To build TESTMODULE (standard, all platforms)

	- copy the files contained in this directory to a work
	  directory (if desired, the entire examples directory can also be
	  copied). 
	- cd to your work directory
        - Issue the appropriate command. depending on your operating system:

		Unix:

		    % make

		Windows:

			(Use a command prompt window. Read build_win.bat
			 before executing it and adjust the path of the
			 IDL distribution as needed for your system)

		    C: build_win


For more information about DLMs, consult the IDL External Development Guide.
