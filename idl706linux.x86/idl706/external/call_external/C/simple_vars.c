/*
 * $Id: //depot/idl/IDL_70/idldir/external/call_external/C/simple_vars.c#1 $
 *
 * NAME:
 * 	simple_vars.c
 *
 * PURPOSE:
 *	This C function is used to demonstrate how to pass simple
 *	variables from IDL to a C function using the IDL function
 *	CALL_EXTERNAL. The variables values are squared and
 *	returned to show how variable values can be changed.
 *
 * CATEGORY:
 *	Dynamic Linking Examples
 *
 * CALLING SEQUENCE:
 *	This function is called in IDL by using the following command
 *
 *	IDL> result = CALL_EXTERNAL(library_name, 'simple_vars',    $
 *	IDL>            byte_var, short_var, long_var, float_var,        $
 *	IDL>		double_var)
 *
 * INPUTS:
 *
 *	Byte_var:	A scalar byte variable
 *	Short_var:	A scalar short integer variable
 *	Long_var:	A scalar long integer variable
 *	Float_var:	A scalar float variable
 *	Double_var:	A scalar float variable
 *
 * OUTPUTS:
 *	The function returns a 1 (long) on success and a 0 otherwise.
 *
 * SIDE EFFECTS:
 *	None.
 *
 * RESTRICTIONS:
 *
 *      None.
 *
 * MODIFICATION HISTORY:
 *	Written October, 1993           KDB
 *	Modified    May, 1998           JJG
 *	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
*/

#include <stdio.h>
#include "idl_export.h"		/* IDL external definitions */



int simple_vars_natural(char *byte_var, short *short_var, IDL_LONG *long_var,
			float *float_var, double *double_var)
/*
 * Version with natural C interface. This version can be called directly
 * by IDL using the AUTO_GLUE keyword to CALL_EXTERNAL.
 */
{
  /* Square each variable. */
  *byte_var     *= *byte_var;
  *short_var    *= *short_var;
  *long_var     *= *long_var;
  *float_var    *= *float_var;
  *double_var   *= *double_var;

  return 1;
}







int simple_vars(int argc, void* argv[])
/* 
 * Version with IDL portable calling convension.
 *
 * entry:
 *	argc - Must be 5.
 *	argv[0] - Address of byte scalar.
 *	argv[1] - Address of 16-bit scalar.
 *	argv[2] - Address of 32-bit scalar.
 *	argv[3] - Address of float scalar.
 *	argv[4] - Address of double scalar.
 *
 * exit:
 *	Returns TRUE for success, and FALSE for failure.
 */
{
  /* Insure that the correct number of arguments were passed in */
  if(argc != 5) return 0;

  return simple_vars_natural((char *) argv[0], (short *) argv[1],
			     (IDL_LONG *) argv[2], (float *) argv[3],
			     (double *) argv[4]);
}
