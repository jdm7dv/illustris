/*$Id: //depot/idl/IDL_70/idldir/external/call_external/C/string_array.c#1 $
 *	
 *
 * NAME:
 *
 * 	string_array.c
 *
 * PURPOSE:
 *	This C function is used to demonstrate how to read an array of
 *      IDL string variables and how to return a string value from a
 *      CALL_EXTERNAL routine
 *
 * CATEGORY:
 *	Dynamic Linking Examples
 *
 * CALLING SEQUENCE:
 *	This function is called in IDL by using the following commands:
 *
 *      IDL>strarr = ['a','bb','ccc','dddd','ee']
 *      IDL>result = CALL_EXTERNAL(library_name,'string_array',strarr,$
 *                                 N_ELEMENTS(strarr),/S_VALUE, VALUE=[0,1])
 *
 *
 *      See string_array.pro for a more complete calling sequence.
 *
 * INPUTS:
 *      string_descr - array of IDL strings  (type is IDL_STRING)
 *      n  - number of elements in the array (type is long)
 *
 * OUTPUTS:
 *	The function returns the longest string in the array.
 *
 * SIDE EFFECTS:
 *	None.
 *
 * RESTRICTIONS:
 *      If the longest input string is longer than 511 characters,
 *      only the first 511 characters will be present in the string
 *      that is returned.
 *
 * MODIFICATION HISTORY:
 *	Written May, 1998 JJG
 *	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup.
 */

#include <stdio.h>
#include <string.h>
#include "idl_export.h"

/*
 * IDL_STRING is declared in idl_export.h like this:
 *
 *    typedef struct {
 *       IDL_STRING_SLEN_T slen;        Length of string, 0 for null
 *       short stype;                   Type of string, static or dynamic
 *       char *s;                       Address of string
 *    } IDL_STRING;
 *
 * However, you should rely on the definition in idl_export.h instead
 * of declaring your own string structure.
*/



char* string_array_natural(IDL_STRING *str_descr, IDL_LONG n)
/*
 * Version with natural C interface. This version can be called directly
 * by IDL using the AUTO_GLUE keyword to CALL_EXTERNAL.
 *
 * entry:
 *	str_desc - Pointer to array of string descriptors.
 *	n - # of string descriptors pointed at by str_desc.
 *
 * exit:
 *	Return a copy of the longest string encountered in str_descr.
 */
{
  /*
   * IDL will make a copy of the string that is returned (if it is not NULL).
   * One way to avoid a memory leak is therefore to return a pointer to
   * a static buffer containing a null terminated string. IDL will copy
   * the contents of the buffer and drop the reference to our buffer
   * immediately on return.
   */
#define MAX_OUT_LEN 511		/* truncate any string longer than this */
  static char result[MAX_OUT_LEN+1];	/* leave a space for a '\0' on the
					   longest string */

  int max_index;		/* index of longest string */
  int max_sofar;		/* length of longest string*/
  int i;


  /*  Check the size of the array passed in. n should be > 0.*/
  if (n < 1) return (char *) 0;
  max_index = 0;
  max_sofar = 0;
  for(i=0; i < n; i++) {
    if (str_descr[i].slen > max_sofar) {
      max_index = i;
      max_sofar = str_descr[i].slen;
    }
  }

  /*
   * If all strings in the array are empty, the longest
   * will still be a NULL string.
   */
   if (str_descr[max_index].s == NULL) return (char *) 0;

   /*
    * Copy the longest string into the buffer, up to MAX_OUT_LEN characters.
    * Explicitly store a NULL byte in the last byte of the buffer, because
    * strncpy() does not NULL terminate if the string copied is truncated.
    */
   strncpy(result, str_descr[max_index].s, MAX_OUT_LEN);
   result[sizeof(result)-1] = '\0';
   
   return(result);
#undef MAX_OUT_LEN
}







char* string_array(int argc, void* argv[])
/* 
 * Version with IDL portable calling convension.
 *
 * entry:
 *	argc - Must be 2.
 *	argv[0] - Address of array of IDL_STRING descriptors.
 *	argv[1] - # of string descriptors in array.
 *
 * exit:
 *	Return a copy of the longest string encountered in str_descr.
 */
{
  /*
   * Make sure there are the correct  # of arguments.
   * IDL will convert the NULL into an empty string ('').
   */
   if (argc != 2) return (char *) 0;

   return string_array_natural((IDL_STRING *) argv[0], (IDL_LONG) argv[1]);
}
