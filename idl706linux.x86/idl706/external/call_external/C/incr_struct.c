/*
 * $Id: //depot/idl/IDL_70/idldir/external/call_external/C/incr_struct.c#1 $
 *	
 *
 * NAME:
 * 	incr_struct.c
 *
 * PURPOSE:
 *	This C function is used to demonstrate how to read an IDL
 *      structure or array of IDL structures in a CALL_EXTERNAL routine.
 *      The fields of the IDL structure and the corresponding C structure
 *      must match exactly.
 *
 * CATEGORY:
 *	Dynamic Linking Examples
 *
 * CALLING SEQUENCE:
 *	This function is called in IDL by using the following commands:
 *
 *      IDL>s = {ASTRUCTURE}
 *      IDL>r = call_external(library_name,'incr_struct',s,N_ELEMENTS(s),
 *                            VALUE=[0,1])
 *
 *      See incr_struct.pro for a more complete calling sequence.
 *
 * INPUTS:
 *      mystructure - an array of structures of type ASTRUCTURE
 *      n  - number of elements in the array (type is IDL_LONG)
 *
 * OUTPUTS:
 *	The function returns 1 (long) on success and 0 otherwise.
 *
 * SIDE EFFECTS:
 *	None.
 *
 * RESTRICTIONS:
 *
 *      It is important that the IDL structure definition
 *      and the C structure definition match exactly.  Otherwise,
 *      there will be no way to prevent this program from
 *      segfaulting or doing other strange things.
 *
 * MODIFICATION HISTORY:
 *	Written May, 1998 JJG
 *	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup
 *
*/
#include <stdio.h>
#include "idl_export.h"

/*
 * C definition for the structure that this
 * routine accepts.  The corresponding IDL
 * structure definition would look like this:
 * s = {zero:0B,one:0L,two:0.,three:0D,four: intarr(2)}
*/
typedef struct {
  unsigned char zero;
  IDL_LONG one;
  float two;
  double three;
  short four[2];
} ASTRUCTURE;







int incr_struct_natural(ASTRUCTURE *mystructure, IDL_LONG n)
/*
 * Version with natural C interface. This version can be called directly
 * by IDL using the AUTO_GLUE keyword to CALL_EXTERNAL.
 */
{
  /* for each structure in the array, increment every field */
  for (; n--; mystructure++) {
    mystructure->zero++;
    mystructure->one++;
    mystructure->two++;
    mystructure->three++;
    mystructure->four[0]++;
    mystructure->four[1]++;
  }
  
  return 1;
}







int incr_struct(int argc, void *argv[])
/* 
 * Version with IDL portable calling convension.
 *
 * entry:
 *	argc - Must be 2.
 *	argv[0] - Array of structures.
 *	argv[2] - number of elements in array.
 *
 * exit:
 *	Returns TRUE for success, and FALSE for failure.
 */
{
  if (argc != 2) return 0;
  return incr_struct_natural((ASTRUCTURE*) argv[0], (IDL_LONG) argv[1]);
}
