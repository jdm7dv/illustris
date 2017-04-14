/*
 * idl_rpc_xdr.h
 *
 *	$Id: //depot/idl/IDL_70/idl_src/idl/idl_rpc_xdr.h#2 $
 */

/*
   Copyright (c) 1990-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
  */


#ifndef _RPC_IDL_XDR_
#define _RPC_IDL_XDR_

/*
 * Nothing here yet
 */


/* On 64-bit systems, use xdr_int() instead of xdr_long() */
#if IDL_SIZEOF_C_LONG == 8
#define XDR_LONG xdr_int
#define XDR_U_LONG xdr_u_int
#elif IDL_SIZEOF_C_LONG == 4
#define XDR_LONG xdr_long
#define XDR_U_LONG xdr_u_long
#else
#error "XDR_LONG/XDR_U_LONG not defined --- unexpected value of IDL_SIZEOF_C_LONG"
#endif

bool_t IDL_RPC_xdr_line_s (XDR *xdrs, IDL_RPC_LINE_S *pLine);
bool_t IDL_RPC_xdr_variable(XDR *xdrs, IDL_RPC_VARIABLE *pVar);
bool_t IDL_RPC_xdr_vptr(XDR *xdrs, IDL_VPTR *pVar);
static bool_t IDL_RPC_xdr_array(XDR *xdrsp, IDL_VPTR pVar);


#if (defined(sgi) && !defined(IRIX_64)) || defined(_AIX) || defined(LINUX_X86_32) || defined(MSWIN)
#define IDL_XDR_FAKE_L64
#ifndef _AIX
/*
 * IEEE machines that lack the 64-bit integer functions.
 * We emulate them in this module. These XDR types are needed.
 */
typedef IDL_ULONG64 u_longlong_t;
typedef IDL_LONG64 longlong_t;
#endif
#endif

/*
 * Define the function used to pass IDL strings around. Note: Added
 * a compile time check to make sure that if IDL string lenght changes
 * in the future, a compiler error is thrown.
 */
#if IDL_STRING_MAX_SLEN == 0x7fffffff
#define XDR_IDL_SLEN xdr_int
#else
#error IDL String length has changed. Check the string xdr code in idl_rpc_xdr.c
#endif

#endif				/* _RPC_IDL_XDR_ */



