/* 
 * idl_rpc_xdr.c - Routines required to perform XDR opts on 
 *	the non-standard structures passed used with the IDL rpc service.
 */
 
/*
  Copyright (c) 1996-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
  */

static char rcsid[] = "$Id: //depot/idl/IDL_70/idl_src/idl/idl_rpc_xdr.c#2 $";


#include <sys/types.h>
#include "idl_rpc.h"
#include "idl_rpc_xdr.h"

/*
 * Determine what array and string functions we should use. If we 
 * are on the server side, use the function available via callable
 * IDL, otherwise use the client side functions.
 */

#ifndef IDL_RPC_CLIENT

#define    IDL_RPC_MAKE_ARRAY           IDL_MakeTempArray
#define    IDL_RPC_STR_ENSURE           IDL_StrEnsureLength
#define    IDL_RPC_VAR_COPY             IDL_VarCopy
#define    IDL_RPC_GET_TMP              IDL_Gettmp
#else

/*
 * Routines available on the client side 
 */

#define    IDL_RPC_MAKE_ARRAY           IDL_RPCMakeArray
#define    IDL_RPC_STR_ENSURE           IDL_RPCStrEnsureLength
#define    IDL_RPC_VAR_COPY             IDL_RPCVarCopy
#define    IDL_RPC_GET_TMP              IDL_RPCGettmp
#endif

/*
 * Declare the xdr routines.
 */

#ifdef IDL_XDR_FAKE_L64
/*
 * On IEEE systems that lack XDR support for 64-bit ints, use
 * xdr_double() to implement xdr_longlong_t() and xdr_u_longlong_t().
 * xdr_double() will work because on a big-endian IEEE floating machine,
 * the types have the same encoding.
 */

cx_public bool_t xdr_longlong_t(XDR *xdrs, longlong_t *llp)
{ return xdr_double(xdrs, (double *) llp); }

cx_public bool_t xdr_u_longlong_t(XDR *xdrs, u_longlong_t *ullp)
{ return xdr_double(xdrs, (double *) ullp); }
#endif


/*************************************************************
 *  IDL_RPC_xdr_complex
 *      This routine is used to perform xdr ops on an IDL complex
 */
cx_public bool_t IDL_RPC_xdr_complex(XDR *xdrsp, IDL_COMPLEX *p)
{
    return(xdr_float(xdrsp, &(p->r)) && xdr_float(xdrsp, &(p->i)));
}
/*************************************************************
 *  IDL_RPC_xdr_dcomplex
 *      This routine is used to perform xdr ops on an IDL double complex
 */
cx_public bool_t IDL_RPC_xdr_dcomplex(XDR *xdrs, IDL_DCOMPLEX *p)
{
  return(xdr_double(xdrs, &(p->r)) && xdr_double(xdrs, &(p->i)));
}

/*************************************************************
 * IDL_RPC_xdr_string
 *      This routine is used to perform xdr ops on an IDL string struct
 */
cx_public bool_t IDL_RPC_xdr_string( XDR *xdrs, IDL_STRING *pStr)
{
   bool_t  statust;
   IDL_STRING_SLEN_T length = pStr->slen;
/*
 * First read/write the length
 */
   if(!XDR_IDL_SLEN(xdrs, &length))
     return FALSE;
/*
 * If we are reading the string, make sure that it is long enough
 */
   if(xdrs->x_op == XDR_DECODE){
      pStr->slen = 0;
      pStr->stype= 0;
      IDL_RPC_STR_ENSURE(pStr, length);
      if(length && pStr->s == NULL)
	 return FALSE;		/* had an error */
   }
/*
 * Read/write the string, but only if it is non-null
 */
   
   return(length ? xdr_string(xdrs, &pStr->s, length) : TRUE);
}

/*************************************************************
 * IDL_RPC_xdr_array
 *
 *   This function performs xdr ops on an IDL array structure.
 *
 */
static bool_t IDL_RPC_xdr_array(XDR *xdrsp, IDL_VPTR pVar)
{
   xdrproc_t   xdr_data_func;	/* function used for array data */
   char       *pData;		/* pointer to array data area   */
   char       *pDim;		/* pointer to dimension array */
   u_int       dimMax = IDL_MAX_ARRAY_DIM;
   u_int       n_elts;
   int         status;		/* status flag for xdr ops */
   IDL_ARRAY  *pTmpArr;		/* temporary array struct  */
   IDL_ARRAY   sArr={0};
   IDL_VPTR   vTmp;

   /* for handling mem ints */
   IDL_LONG    tmpEltLen;
   IDL_LONG    tmpArrLen;
   IDL_LONG    tmpNElts;
   IDL_LONG    tmpDims[IDL_MAX_ARRAY_DIM];
   int i;
   
/*
 * If we are ecoding, copy over the data contained in the pTmpArr
 * array field. 
 */
   if(xdrsp->x_op != XDR_DECODE){
     if(pVar->flags & IDL_V_ARR) /* is this an array */
        pTmpArr = pVar->value.arr;
     else
        return FALSE;		/* not an array */
   }else 
     pTmpArr = &sArr;
   /* 6/00 kdb
    * The size of elt_len, arr_len and n_elts is a MEM int, 
    * which varies depending on the platform. As such these
    * values are xferred as IDL_LONGS and cast as needed. 
    */
   if(xdrsp->x_op != XDR_DECODE){ /* encode */
     tmpEltLen = (IDL_LONG)pTmpArr->elt_len;
     tmpArrLen = (IDL_LONG)pTmpArr->arr_len;
     tmpNElts  = (IDL_LONG)pTmpArr->n_elts;
     
     /* Now copy over our array dims */
     for(i=0; i < IDL_MAX_ARRAY_DIM; i++)
         tmpDims[i] = (IDL_LONG)pTmpArr->dim[i];
   }
   pDim = (char*)tmpDims;
   
/*
 * read/write the fields that make up the array descriptor. This includes
 * all except the data section.
 */
   status = XDR_LONG(xdrsp, IDL_LONGA(tmpEltLen)) &&
	    XDR_LONG(xdrsp, IDL_LONGA(tmpArrLen)) &&
	    XDR_LONG(xdrsp, IDL_LONGA(tmpNElts)) &&
	    xdr_u_char(xdrsp, IDL_UCHARA(pTmpArr->n_dim)) &&
	    xdr_u_char(xdrsp, IDL_UCHARA(pTmpArr->flags)) &&
	    xdr_short(xdrsp, IDL_SHORTA(pTmpArr->file_unit)) &&
	    xdr_array(xdrsp, &pDim, &dimMax, (u_int)dimMax,
		     sizeof(IDL_LONG), (xdrproc_t)XDR_LONG);

   if( status == 0)
     return FALSE;
   /*
    * 6/00 kdb
    * Unwind our IDL_MEMINT values
    */
   if(xdrsp->x_op == XDR_DECODE){ /* decode */
     pTmpArr->elt_len = (IDL_MEMINT)tmpEltLen;
     pTmpArr->arr_len = (IDL_MEMINT)tmpArrLen;
     pTmpArr->n_elts  = (IDL_MEMINT)tmpNElts;
     
     /* Now copy over our array dims */
     for(i=0; i < IDL_MAX_ARRAY_DIM; i++)
       pTmpArr->dim[i] = (IDL_MEMINT)tmpDims[i];
   }
   
/*
 * Determine what xdr function will be required to read/write the data 
 */
   switch( pVar->type ){
   case IDL_TYP_BYTE:       
      xdr_data_func   =  (xdrproc_t)xdr_u_char; 
      break;
   case IDL_TYP_INT:  
      xdr_data_func   =  (xdrproc_t)xdr_short;  
      break;
   case IDL_TYP_LONG:
      xdr_data_func   =  (xdrproc_t)XDR_LONG;
      break;
   case IDL_TYP_FLOAT:
      xdr_data_func   =  (xdrproc_t)xdr_float;  
      break;
   case IDL_TYP_DOUBLE:   
      xdr_data_func   =  (xdrproc_t)xdr_double; 
      break;
   case IDL_TYP_COMPLEX:    
      xdr_data_func   =  (xdrproc_t)IDL_RPC_xdr_complex; 
      break;
   case IDL_TYP_STRING:     
      xdr_data_func   =  (xdrproc_t)IDL_RPC_xdr_string; 
      break;
   case IDL_TYP_DCOMPLEX:   
      xdr_data_func   =  (xdrproc_t)IDL_RPC_xdr_dcomplex; 
      break;
   case IDL_TYP_UINT:  
      xdr_data_func   =  (xdrproc_t)xdr_u_short;  
      break;
   case IDL_TYP_ULONG:
      xdr_data_func   =  (xdrproc_t)XDR_U_LONG;
      break;
   case IDL_TYP_LONG64:
      xdr_data_func   =  (xdrproc_t)xdr_longlong_t;
      break;
   case IDL_TYP_ULONG64:
      xdr_data_func   =  (xdrproc_t)xdr_u_longlong_t;
      break;
   default:
      return FALSE;		/* An Error Condition */
   }
/*
 * If we are decoding, we will need to get an array of the 
 * desired size and type.
 */
   if(xdrsp->x_op == XDR_DECODE){
     pData = IDL_RPC_MAKE_ARRAY(pVar->type, pTmpArr->n_dim,
				pTmpArr->dim, IDL_ARR_INI_ZERO, &vTmp);
   /*
    * Move this array over to the input variable. Will free up any
    * data that needs to be freed.
    */ 
      IDL_RPC_VAR_COPY(vTmp, pVar);  
        				
    }else 
      pData = (char*)pVar->value.arr->data;
/*
 *  Now to Xdr the data
 */
   /*
    * Bug Fix: 4/01
    * Be sure and use the array size values for this system. 
    * All IDL type sizes are not platform independent. (IDL_STRING)
    */
   n_elts = (u_int) pVar->value.arr->n_elts;
   return xdr_array(xdrsp, &pData, &n_elts,
		    pVar->value.arr->n_elts, 
		    pVar->value.arr->elt_len, xdr_data_func);
}
/*************************************************************
 * IDL_RPC_xdr_vptr()
 *
 * Used to perform xdr ops on an IDL_VPTR
 */
bool_t IDL_RPC_xdr_vptr(XDR *xdrs, IDL_VPTR *pVar)
{
  bool_t status;
  IDL_VPTR  ptmpVar;
  UCHAR     flags;

  if(xdrs->x_op == XDR_DECODE){
     *pVar = IDL_RPC_GET_TMP();	/* Need a variable */
  }else {
    /* client uses the tmp flags */
     flags = ~IDL_V_DYNAMIC & (~IDL_V_TEMP & (*pVar)->flags);	
  }
  ptmpVar = *pVar;

  status = xdr_u_char(xdrs, &ptmpVar->type);
  status = (status && xdr_u_char(xdrs, &flags));

  if(xdrs->x_op == XDR_DECODE)
     ptmpVar->flags |= flags;  /* preserve the old flags */

  if(status == FALSE)
     return status;
/*
 * Do we have an array?
 */
   if(ptmpVar->flags & IDL_V_ARR)
      return IDL_RPC_xdr_array(xdrs, ptmpVar);
/*
 * Must have a scalar, Determine the type and xdr
 */
   switch(ptmpVar->type){
   case IDL_TYP_UNDEF:
      status = TRUE;
      break;
   case IDL_TYP_BYTE:
      status = xdr_u_char(xdrs, &ptmpVar->value.c);
      break;
   case IDL_TYP_INT:
      status = xdr_short(xdrs, &ptmpVar->value.i);
      break;
   case IDL_TYP_LONG:
      status = XDR_LONG(xdrs, &ptmpVar->value.l);
      break;
   case IDL_TYP_FLOAT:
      status = xdr_float(xdrs, &ptmpVar->value.f);
      break;
   case IDL_TYP_DOUBLE:
      status = xdr_double(xdrs, &ptmpVar->value.d);
      break;
   case IDL_TYP_COMPLEX:
      status = IDL_RPC_xdr_complex(xdrs, &ptmpVar->value.cmp);
      break;
   case IDL_TYP_STRING:
      status = IDL_RPC_xdr_string(xdrs, &ptmpVar->value.str);
   /*
    * Make sure that the dynamic flag is set 
    */
      if(ptmpVar->value.str.stype)
         ptmpVar->flags |= IDL_V_DYNAMIC;
      break;
   case IDL_TYP_DCOMPLEX:
      status = IDL_RPC_xdr_dcomplex(xdrs, &ptmpVar->value.dcmp);
      break;
   case IDL_TYP_UINT:
      status = xdr_u_short(xdrs, &ptmpVar->value.ui);
      break;
   case IDL_TYP_ULONG:
      status = XDR_U_LONG(xdrs, &ptmpVar->value.ul);
      break;
   case IDL_TYP_LONG64:
      status = xdr_longlong_t(xdrs,
#if defined(LINUX_X86_64)
			      (quad_t *) /* Header is missing long_long_t */
#endif
#ifdef ALPHA_OSF
			      (long *)
#endif
#ifdef HPUX_64
			      (longlong_t *)
#endif
#ifdef IRIX_64
			      (__int64_t *)
#endif
			      &ptmpVar->value.l64);
      break;
   case IDL_TYP_ULONG64:
      status = xdr_u_longlong_t(xdrs,
#if defined(LINUX_X86_64)
				(u_quad_t *) /* Header missing long_long_t */
#endif
#ifdef ALPHA_OSF
				(unsigned long *)
#endif
#ifdef HPUX_64
				(u_longlong_t *)
#endif
#ifdef IRIX_64
				(__uint64_t *)
#endif
				&ptmpVar->value.ul64);
      break;
   default: status = FALSE;
   }
   return status;
}
/*************************************************************
 * IDL_RPC_xdr_variable()
 *
 * Used to perform xdr ops on an RPC variable structure. This 
 * structure contains the variable name and an IDL_VPTR.
 */
bool_t IDL_RPC_xdr_variable(XDR *xdrs, IDL_RPC_VARIABLE *pVar)
{
   unsigned int maxElem = IDL_MAXIDLEN +1;
   return(xdr_wrapstring(xdrs, &pVar->name) &&
	  IDL_RPC_xdr_vptr(xdrs, &pVar->pVariable));
}
/*************************************************************
 * IDL_RPC_xdr_line_s()
 * 
 * This function is used to perform XDR ops on a structure 
 * of type IDL_RPC_LINE_S. This structure is used to pass 
 * idl output lines between the rpc server and client.
 */

bool_t IDL_RPC_xdr_line_s(XDR *xdrs, IDL_RPC_LINE_S *pLine)
{
   return (xdr_int(xdrs, &pLine->flags) &&
	    xdr_wrapstring(xdrs, &pLine->buf));
}
  


