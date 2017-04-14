/*
 * $Id: //depot/idl/IDL_70/idldir/external/call_external/C/sum_2d_array.c#1 $
 *	
 *
 * NAME:
 * 	sum_2d_array.c
 *
 * PURPOSE:
 *	This C function is used to demonstrate how to read a 2 dimensional
 *      IDL array. It calculates the sum of a subsection of the input array.
 *      The subsection is specified like this:
 *
 *  0,0--------------------------------------------x_size-1,0
 *  |
 *  |    x_start,y_start------------x_end,y_start
 *  |    |                                    |
 *  |    | this region will be summed         |
 *  |    |                                    |
 *  |    x_start,y_end--------------x_end,y_end
 *  |
 *  |
 *  0,y_size-1
 *
 *      this is equivalent to the IDL statement:
 *      IDL>r = TOTAL(arr[x_start:x_end,y_start:y_end],/DOUBLE)
 *
 * CATEGORY:
 *	Dynamic Linking Examples
 *
 * CALLING SEQUENCE:
 *	This function is called in IDL by using the following commands:
 *
 *      IDL>arr =  DINDGEN(20,20)
 *      IDL>x_start = 5L
 *      IDL>x_end = 10L
 *      IDL>x_size = 20L
 *      IDL>y_start = 5L
 *      IDL>y_end = 10L
 *      IDL>y_size = 20L
 *      IDL>r = CALL_EXTERNAL(library_file,'sum_2d_array',$
 *                            arr,x_start,x_end,x_size,$
 *                            y_start,y_end,y_size,/D_VALUE, VALUE=[0,1])
 *
 *      See sum_2d_array.pro for a more complete calling sequence.
 *
 * INPUTS:
 *      arr - a 2 dimensional IDL array (type is double)
 *      x_start - X index of the start of the subsection (type is long)
 *      x_end   - X index of the end of the subsection   (type is long)
 *      x_size  - size of the X dimension of arr         (type is long)
 *      y_start - Y index of the start of the subsection (type is long)
 *      y_end   - Y index of the end of the subsection   (type is long)
 *      y_size  - size of the Y dimension of arr         (type is long)
 *
 * OUTPUTS:
 *	The function returns the sum of all of the elements of the
 *      subsection of the array.
 *
 * SIDE EFFECTS:
 *	None.
 *
 * RESTRICTIONS:
 *
 *      None.
 *
 * MODIFICATION HISTORY:
 *	Written May, 1998 JJG
 *	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup.
*/

#include <stdio.h>
#include "idl_export.h"



double sum_2d_array_natural(double *arr,
			    IDL_LONG x_start, IDL_LONG x_end, IDL_LONG x_size,
			    IDL_LONG y_start, IDL_LONG y_end, IDL_LONG y_size)
/*
 * Version with natural C interface. This version can be called directly
 * by IDL using the AUTO_GLUE keyword to CALL_EXTERNAL.
 *
 * entry:
 *	arr - Pointer to array of double precision floating values
 *	x_start, x_end, x_size, y_start, y_end, y_size - Dimensions of
 *		2d subarray to be processed.
 *
 * exit:
 *	Return sum of indicated array elements.
 */     
{
  /*
   * since we didn't know the dimensions of the array
   * at compile time, we must treat the input array
   * as if it were a one dimensional vector.
   */
  IDL_LONG x,y;
  double result = 0.0;

  /*
   * Make sure that we don't go outside the array.
   * strictly speaking, this is redundant since identical
   * checks are performed in the IDL wrapper routine.
   * IDL_MIN() and IDL_MAX() are macros from idl_export.h
   */
  x_start = IDL_MAX(x_start,0);
  y_start = IDL_MAX(y_start,0);
  x_end = IDL_MIN(x_end,x_size-1);
  y_end = IDL_MIN(y_end,y_size-1);
  
  /* loop through the subsection */
  for (y = y_start;y <= y_end;y++)
    for (x = x_start;x <= x_end;x++)
      result += arr[x + y*x_size]; /* build the 2d index: arr[x,y] */
  
  return result;
}







double sum_2d_array(int argc,void* argv[])
/* 
 * Version with IDL portable calling convension.
 *
 * entry:
 *	argc - Must be 7.
 *	argv[0] - Address of array of IDL_STRING descriptors.
 *	argv[1] - x_start
 *	argv[2] - x_end
 *	argv[3] - x_size
 *	argv[4] - y_start
 *	argv[5] - y_end
 *	argv[6] - y_size
 *
 * exit:
 *	Return sum of indicated array elements.
 */
{
  if (argc != 7) return 0.0;

  return sum_2d_array_natural((double *) argv[0], (IDL_LONG) argv[1],
			      (IDL_LONG) argv[2], (IDL_LONG) argv[3],
			      (IDL_LONG) argv[4], (IDL_LONG) argv[5],
			      (IDL_LONG) argv[6]);
}
