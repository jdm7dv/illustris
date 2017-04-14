/*
 * calltest - Simple demonstration program for Callable IDL.
 *
 *	$Id: //depot/idl/IDL_70/idldir/external/callable/calltest.c#3 $
 *
 * This program uses callable IDL to do the following things:
 *
 *	- Import a 10 element array (equivalent to a FINDGEN(10))
 *        created by our C program into IDL, under the name TMP.
 *      - Have callable IDL total the imported TMP array, storing the
 *        result in an IDL variable named TMP_TOTAL.
 *      - Use callable IDL to print the values of TMP, TMP_TOTAL,
 *        and to produce a plot of TMP.
 *      - Demonstrate that when callable IDL releases the imported
 *        array TMP, that the user registered callback is called.
 *      - Access an IDL variable (TMP_TOTAL) from our C program.
 *	- Create a blocking IDL WIDGET button with the title "Done".
 *	  When the user presses this button, callable IDL is shut down
 *	  and the program exits.
 *
 * Notes:
 *    - For Microsoft Windows, there is a significant amount of
 *      code required to create a window to display IDL's output
 *      window and to handle the additional initialization steps
 *      required on that platform. That code is found in calltest_win.c.
 *    - The PRINTF_LINE macro is defined in calltest.h. It allows this
 *      rogram to generate printf()-like output on both platforms without
 *	using #ifdef lines everywhere.
 */

/*
 *  Copyright (c) 1992-2008, ITT Visual Information Solutions. All
 *  rights reserved. Reproduction by any means whatsoever is prohibited 
 *  without express written permission.
 */

#ifdef WIN32
#include <windows.h>
#endif
#include <stdio.h>
#include "idl_export.h"
#include "calltest.h"







static void free_callback(UCHAR *addr)
/*
 * This function is called by IDL when the imported TMP variable is
 * set to 0, releasing the imported memory.
 */
{
  PRINTF_LINE("IDL released(%p)", addr);
}



static void demo_callable_idl(void)
{
  float f[10];
  int i;
  IDL_VPTR v;
  IDL_MEMINT dim[IDL_MAX_ARRAY_DIM];
  static char *cmds[] = { "tmp_total = total(tmp)",
			  "print,'IDL total is ', tmp_total",
			  "plot,tmp" };
  static char *cmds2[] = { "a = widget_base()",
     "b = widget_button(a, value='Press When Done', xsize=300, ysize=200)",
     "widget_control,/realize, a",
     "dummy = widget_event(a)",
     "widget_control,/destroy, a" };
  

  for (i=0; i < 10; i++) f[i] = (float) i;
  dim[0] = 10;
  PRINTF_LINE("ARRAY ADDRESS(%u)", f);
  if (v = IDL_ImportNamedArray("TMP", 1, dim, IDL_TYP_FLOAT, (UCHAR *) f,
			       free_callback, (void *) 0)) {
    (void) IDL_ExecuteStr("print, tmp");
    (void) IDL_Execute(sizeof(cmds)/sizeof(char *), cmds);
    (void) IDL_ExecuteStr("print, 'This should free the user memory");
    (void) IDL_ExecuteStr("tmp = 0");
    if (v = IDL_FindNamedVariable("tmp_total", FALSE))
      PRINTF_LINE("Program total is %f", v->value.f);
    (void) IDL_Execute(sizeof(cmds2)/sizeof(char *), cmds2);
  }
}







#ifdef WIN32
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hInstancePrev,
	LPSTR lpszCmndline, int nCmdShow)
/*
 * Windows applications start at WinMain() instead of main().
 */
{
  /* Window's specific initialization */
  if (!CalltestWinMain(hInstance, hInstancePrev, lpszCmndline, nCmdShow))
    return FALSE;

  demo_callable_idl();		/* Use Callable IDL */

  IDL_Cleanup(FALSE);		/* Don't return */
    
  return TRUE;
}
#endif







#ifndef WIN32			/* !WIN32 == Unix */
int main(int argc, char **argv)
{
  IDL_INIT_DATA init_data;

  init_data.options = IDL_INIT_NOCMDLINE;
  if (argc) {
    init_data.options |= IDL_INIT_CLARGS;
    init_data.clargs.argc = argc;
    init_data.clargs.argv = argv;
  }
  if (IDL_Initialize(&init_data)) {
    demo_callable_idl();
    IDL_Cleanup(FALSE);	/* Don't return */
  }

  return 1;			/* Will only get here if IDL_Init() fails. */
}
#endif				/* Unix */
