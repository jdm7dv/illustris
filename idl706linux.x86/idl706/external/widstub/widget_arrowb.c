/*
 *	$Id: //depot/idl/IDL_70/idldir/external/widstub/widget_arrowb.c#1 $
 *                                    6 August 1993, AB, RSI
 *				      29 March 2002, AB, Adapted for Unix
 *
 * arrowb.c - This file contains C code to be called from Unix IDL via
 * CALL_EXTERNAL. It uses the IDL stub widget to add a Motif
 * ArrowButton to an IDL created widget hierarchy. The button issues
 * a WIDGET_STUB_EVENT every time the button is released.
 *
 * While this code is Motif-centric, the principles apply across platforms
 * and could be adapted to Microsoft Windows.
 *
 */


#include <stdio.h>
#include <X11/keysym.h>         /* Keysyms for text widget events */
#include <X11/Intrinsic.h>
#include <X11/StringDefs.h>
#include <X11/Shell.h> 
#include <Xm/ArrowB.h>

#include "idl_export.h"


/*ARGSUSED*/
static void arrowb_CB(Widget w, caddr_t client_data, caddr_t call_data)
{
  char *rec;
  XmArrowButtonCallbackStruct *abcs;


  IDL_WidgetStubLock(TRUE);

  if (rec = IDL_WidgetStubLookup((unsigned long) client_data)) {
    abcs = (XmArrowButtonCallbackStruct *) call_data;
    IDL_WidgetIssueStubEvent(rec, abcs->reason == XmCR_ARM);
  }

  IDL_WidgetStubLock(FALSE);
}



static void arrowb_size_func(IDL_ULONG stub, int width, int height)
{
  char *stub_rec;
  unsigned long t_id, b_id;
  char buf[128];


  IDL_WidgetStubLock(TRUE);

  if (stub_rec = IDL_WidgetStubLookup(stub)) {
    IDL_WidgetGetStubIds(stub_rec, &t_id, &b_id);
    sprintf(buf, "Setting WIDGET %d to width %d and height %d",
	   stub, width, height);
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_INFO, buf);
    XtVaSetValues((Widget) b_id, XmNwidth, width, XmNheight, height, NULL);
  }

  IDL_WidgetStubLock(FALSE);
}



int widget_arrowb(IDL_LONG parent, IDL_LONG stub, IDL_LONG use_own_size_func)
{
  Widget parent_w;
  Widget stub_w;
  char *parent_rec;
  char *stub_rec;
  unsigned long t_id, b_id;


  IDL_WidgetStubLock(TRUE);

  if ((parent_rec = IDL_WidgetStubLookup(parent))
      && (stub_rec = IDL_WidgetStubLookup(stub))) {
    /* Bottom widget of parent is parent to arrow button */  
    IDL_WidgetGetStubIds(parent_rec, &t_id, &b_id);
    parent_w = (Widget) b_id;

    stub_w = XtVaCreateManagedWidget("arrowb", xmArrowButtonWidgetClass,
				     parent_w, NULL);

    IDL_WidgetSetStubIds(stub_rec, (unsigned long) stub_w,
			 (unsigned long) stub_w);
    XtAddCallback(stub_w, XmNarmCallback, (XtCallbackProc) arrowb_CB,
                  (XtPointer) stub);
    XtAddCallback(stub_w, XmNdisarmCallback, (XtCallbackProc) arrowb_CB,
                  (XtPointer) stub);

    if (use_own_size_func)
      IDL_WidgetStubSetSizeFunc(stub_rec, arrowb_size_func);
  }

  IDL_WidgetStubLock(FALSE);
  return stub;
}
