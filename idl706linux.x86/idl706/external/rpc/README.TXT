------------------------------------------------------------
README file: <IDL_Directory>	
		  external
		    rpc
------------------------------------------------------------

This directory contains files used to build the libidl_rpc.so library
file and the idl server executable idlrpc. Note that these files are 
"pre-built" and are located in:

	$IDL_DIR/bin/bin.<OS_NAME>

To build the rpc library file, the rpc server executable and the rpc 
example program (idl_rpc_test)  perform the following:

	- copy the files contained in this directory to a work
	  directory (if desired, the examples directory can also be
	  copied). 
	- cd to your work directory
	- Issue the following command:
		% make
	   Note: If the location of your IDL distribution is non-standard,
		 some edits might have to be performed to the makefile.


Start the RPC server. 
% idlrpc 

Run the example using one of the following options:
% idl_rpc_test <server_id>
% idl_rpc_test <hostname>
% idl_rpc_test <server_id> <hostname>

Where  the server_id is the rpc id for the rpc server and the
hostname is the name of the host that is running the rpc server.
		 
For more information about using IDL as a rpc server, consult the 
Remote Procedure Calls chapter of the IDL External Development Guide.


