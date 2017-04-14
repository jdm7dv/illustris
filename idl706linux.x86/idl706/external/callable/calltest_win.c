/*
 * calltest_win.c
 *
 *	$Id: //depot/idl/IDL_70/idldir/external/callable/calltest_win.c#2 $
 *
 * The Microsoft Windows version of this program requires code to create
 * an output log window for the IDL output and to manage the Windows
 * specific details of using Callable IDL. That code is found in this
 * file --- the generic callable IDL code is in calltest.c.
 */

/*
 *  Copyright (c) 1992-2008, ITT Visual Information Solutions. All
 *  rights reserved. Reproduction by any means whatsoever is prohibited
 *  without express written permission.
 */

#include <windows.h>
#include <stdio.h>
#include <stdarg.h>
#ifdef IDL_CALLPROXY_LIB
#include "idl_callproxy.h"
#endif
#include "idl_export.h"
#include "calltest.h"



/* Width and height of the main output window */
#define MAIN_WIDTH 600
#define MAIN_HEIGHT 480



/*
 * HWND for main window needs to be global so that the IDL tout()
 * callback can use it.
 */
struct {
  HWND main;
  HWND log;
} hwnd_state;







static void SendTextToLog(char *text, int newline, int reset)
/*
 * Output text at end of log window.
 *
 * entry:
 *	text - NULL, or ^ to text to output. If NULL, no text is
 *		output, but the newline and reset arguments are still
 *		processed.
 *	newline - TRUE if should start a new line after text.
 *	reset - TRUE to clear window, FALSE to append text to end
 *		of existing text.
 */
{
  LRESULT start;
  LRESULT len;

  /* Get the length of the text in the log window */
  len = SendMessage (hwnd_state.log, WM_GETTEXTLENGTH, 0, 0L);
  if (reset) {
    start = 0;
    if (!text) text = "";
  } else {
    start = len;
  }
  (void) SendMessage (hwnd_state.log, EM_SETSEL, start, len);
  if (text)
    (void) SendMessage (hwnd_state.log, EM_REPLACESEL, 0, (LPARAM) text);

  if (newline) {
    if (text) {
      len += strlen(text);
      (void) SendMessage (hwnd_state.log, EM_SETSEL, len, len);
    }
    (void) SendMessage (hwnd_state.log, EM_REPLACESEL, 0, (LPARAM) "\r\n");
  }
}







int CalltestWinPrintfLine(char *fmt, ...)
/*
 * Function with printf() interface that sends the output to our log
 * window instead of stdout, and which implicitly supplies a newline
 * at the end.
 *
 * Under MS Windows, the PRINTF_LINE macro uses this function to
 * send text from our C program to the log window.
 */
{
  char buf[1024];
  va_list args;
  int r;

  va_start(args, fmt);
  
  if (r = vsnprintf(buf, sizeof(buf)-1, fmt, args))
    SendTextToLog(buf, TRUE, FALSE);

  va_end(args);

  return r;
}







static void IDLToutFcn(int flags, char *buf, int n)
/*
 * idl_tout_fcn() is a wrapper on SendTextToLog() that provides the
 * interface for IDL_ToutPush(). We register this function with IDL,
 * and IDL calls it when it has output to be written out.
 */

{
  static first = TRUE;		/* Reset log on first call from IDL */
  MSG msg;

  SendTextToLog(n ? buf : (char *) 0, flags & IDL_TOUT_F_NLPOST, first);
  first = FALSE;

  /* Flush any pending messages to ensure output shows up immediately */
  while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
}







static BOOL CreateLog(HINSTANCE hInst, HWND hwnd)
/*
 * Create a log window as a child of the main window.
 *
 * exit:
 *	Returns TRUE on success, FALSE otherwise.
 */
{
  RECT rect;

  /* Get the size of the parent window */
  GetClientRect(hwnd, &rect);

  /* Create the read-only edit control for the command log */
  hwnd_state.log = CreateWindowEx(WS_EX_CLIENTEDGE, "edit", NULL,
				  (ES_READONLY  | WS_VISIBLE | ES_AUTOVSCROLL |
				   WS_TABSTOP | WS_VSCROLL | WS_CHILD |
				   WS_BORDER | ES_LEFT | ES_MULTILINE),
				  0, 0, rect.right - rect.left,
				  rect.bottom - rect.top, hwnd,
				  (HMENU) 0, hInst, NULL);
  if (!hwnd_state.log) return FALSE;

  return TRUE;
}







static LRESULT WINAPI MainWndProc(HWND hwnd, UINT uMsg,
				  WPARAM wParam, LPARAM lParam)
/*
 * Window procedure (event handler) for our main window.
 * All messages (events) sent to our app are routed through here
*/
{
  switch (uMsg) {
  case WM_CREATE:
    /*
     * When our app is first created, we are sent this message.
     * We take this opportunity to create our child controls and
     * place them in their desired locations on the window.
     */
    if (!CreateLog(((LPCREATESTRUCT)lParam)->hInstance, hwnd)) return 0;
    break;

  case WM_DESTROY:
    PostQuitMessage(1);
    break;

  case WM_QUIT:
    IDL_Cleanup(FALSE);
    return FALSE;
  }

  return DefWindowProc(hwnd, uMsg, wParam, lParam);
}







static HWND CreateMainWindow(HINSTANCE hInst)
/*
 * Register the class and create the main window for our program.
 *
 * entry:
 *	The "Callable" class has already been registered.
 *
 * exit:
 *	On success, returns the handle to the main window. On failure,
 *      returns NULL.
 */
{
  WNDCLASS wc;
  HWND hwnd;
  CREATESTRUCT cs;
  RECT rect;

  /* Register the class for the main window */
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc = MainWndProc;
  wc.cbClsExtra = 0;
  wc.cbWndExtra = 0;
  wc.hInstance = hInst;
  wc.hIcon = NULL;
  wc.hCursor = LoadCursor(NULL, IDC_ARROW);
  wc.hbrBackground = (HBRUSH)(COLOR_BTNFACE + 1);
  wc.lpszMenuName = NULL;
  wc.lpszClassName = "Callable";
  if (!RegisterClass(&wc)) return (HWND) 0;
	
  /*
   * Set output log window in the lower left corner. The IDL button widget
   * will go to the upper left, and the plot window will go in upper right.
   */
  if (SystemParametersInfo(SPI_GETWORKAREA, 0, &rect, 0)) {
    rect.right = 0;
    rect.bottom = rect.bottom - MAIN_HEIGHT;
  } else {
    rect.right = rect.bottom = 0;
  }

  hwnd = CreateWindow("Callable", "Simple IDL Callable Application",
		      WS_DLGFRAME | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE,
		      rect.right, rect.bottom, MAIN_WIDTH, MAIN_HEIGHT,
		      NULL, NULL, hInst, &cs);

  if (hwnd) {
    ShowWindow(hwnd, SW_SHOWNORMAL);
    UpdateWindow(hwnd);
  }

  return hwnd;
}







int WINAPI CalltestWinMain(HINSTANCE hInstance, HINSTANCE hInstancePrev,
			   LPSTR lpszCmndline, int nCmdShow)
/*
 * Called by WinMain(). Create the output window, and get callable
 * IDL ready to use.
 */
{
  IDL_INIT_DATA init_data;

  /* Create and display the main window. */
  if ((hwnd_state.main = CreateMainWindow(hInstance)) == NULL) return 0;

  /*
   * If we are using the proxy lib instead of linking directly to
   * Callable IDL then initialize it the proxy library.
   */
#ifdef IDL_CALLPROXY_LIB
#ifdef IDL_CALLPROXY_DEBUG
  /* Have Call Proxy library use MessageBox to tell us what it is doing */
  IDL_CallProxyDebug(IDL_CPDEBUG_ALL);
#endif

  if (!IDL_CallProxyInit(IDL_CALLPROXY_LIB)) return FALSE;
#endif
  
  /* Register a function with IDL to divert IDL's output to our log window */
  IDL_ToutPush(IDLToutFcn);
	
  /* Starting IDL can take a few moments, so output a message */
  SendTextToLog("Please Wait While IDL Starts...", TRUE, FALSE);

  /* Initialize IDL */
  init_data.options = IDL_INIT_NOCMDLINE;
  if (hwnd_state.main) {
    init_data.options |= IDL_INIT_HWND;
    init_data.hwnd = hwnd_state.main;
  }
  return IDL_Initialize(&init_data);
}
