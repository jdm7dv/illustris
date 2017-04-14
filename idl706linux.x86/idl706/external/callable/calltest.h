/*
 * callable.h - Simple demonstration program for Callable IDL
 *
 *	$Id: //depot/idl/IDL_70/idldir/external/callable/calltest.h#2 $
 */

/*
 *  Copyright (c) 1992-2008, ITT Visual Information Solutions. All
 *  rights reserved. Reproduction by any means whatsoever is prohibited
 *  without express written permission.
 */

#ifndef callable_IDL_DEF
#define callable_IDL_DEF


#ifdef WIN32
extern int WINAPI CalltestWinMain(HINSTANCE hInstance, HINSTANCE hInstancePrev,
				  LPSTR lpszCmndline, int nCmdShow);
extern int CalltestWinPrintfLine(char *fmt, ...);

#define PRINTF_LINE(fmt, arg) (void) CalltestWinPrintfLine(fmt, arg)
#endif



#ifndef WIN32			/* !WIN32 == Unix */
#define PRINTF_LINE(fmt, arg) (void) printf(fmt "\r\n", arg)
#endif				/* Unix */


#endif				/* callable_IDL_DEF */
