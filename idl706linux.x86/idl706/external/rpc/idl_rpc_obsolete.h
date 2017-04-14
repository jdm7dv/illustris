/*
 *	$Id: //depot/idl/IDL_70/idldir/external/rpc/idl_rpc_obsolete.h#2 $
 */

/*
  Copyright (c) 1992-2008, ITT Visual Information Solutions. All
  rights reserved. Reproduction by any means whatsoever is prohibited 
  without express written permission.
  */

/*
 * If we are a client, define name lenght macros
 */

#ifndef MAXIDLEN
#define MAXIDLEN     128
#endif

/*              Biggest string we can XDR                       */

#define         MAX_STRING_LEN          512

/*              Version/portmapper id                           */

#define         IDL_DEFAULT_ID          0x2010CAFE
#define         IDL_DEFAULT_VERSION     1

/*              Server requests available                       */

#define         OLDGET_VARIABLE         1
#define         OLDSET_VARIABLE         2
#define         RUN_COMMAND             3
#define         FORCED_EXIT             4
#define		RUN_INTERACTIVE		5
#define         GET_VARIABLE            8
#define         SET_VARIABLE            9

/*      Data Extraction Macros                                  */

#define         VarIsArray(v)           ((v)->Variable->flags & IDL_V_ARR)
#define         GetVarType(v)           ((v)->Variable->type)
#define         GetVarByte(v)           ((v)->Variable->value.c)
#define         GetVarInt(v)            ((v)->Variable->value.i)
#define         GetVarLong(v)           ((v)->Variable->value.l)
#define         GetVarFloat(v)          ((v)->Variable->value.f)
#define         GetVarDouble(v)         ((v)->Variable->value.d)
#define         GetVarComplex(v)        ((v)->Variable->value.cmp)
#define         GetVarDComplex(v)        ((v)->Variable->value.dcmp)
#define         GetVarString(v)         STRING_STR((v)->Variable->value.str)

#define         GetArrayData(v)         (v)->Variable->value.arr->data
#define         GetArrayNumDims(v)      (v)->Variable->value.arr->n_dim
#define         GetArrayDimensions(v)   (v)->Variable->value.arr->dim


/* 
 * Define a variable name that can be used to variable type conversions
 */

#define IDL_RPC_CON_VAR "_THIS$VARIABLE$IS$FOR$RPC$VARIABLE$CONVERSION$ONLY_"

/*      XDR structure used to transfer a variable                       */

typedef struct _VARINFO {

    char        Name[MAXIDLEN+1];	/* Variable name in IDL         */
    IDL_VPTR        Variable;		/* IDL internal definition      */
    IDL_LONG        Length;	/* Array length (0 for dynamic, */
					/* sizeof(data) for statics     */
} varinfo_t;

/************************************************************************/
/*      IDL RPC interface routines                                      */
/************************************************************************/

CLIENT *register_idl_client(IDL_LONG server_id, char *hostname,
			    struct timeval *timeout);
void unregister_idl_client(CLIENT *client);
int  kill_server(CLIENT *client);
int  set_idl_timeout(struct timeval *timeout);
int  send_idl_command(CLIENT* client, char* cmd);
void free_idl_var(varinfo_t* var);
int  set_idl_variable(CLIENT* client, varinfo_t* var);
int  get_idl_variable(CLIENT* client, char* name, varinfo_t* var, int typecode);

/************************************************************************/
/*      Helper function declarations                                    */
/************************************************************************/

int v_make_byte(varinfo_t* var, char* name, unsigned int c);
int v_make_int(varinfo_t* var, char* name, int i);
int v_make_long(varinfo_t* var, char* name, IDL_LONG l);
int v_make_float(varinfo_t* var, char* name, double f);
int v_make_double(varinfo_t* var, char* name, double d);
int v_make_complex(varinfo_t* var, char* name, double real, double imag);
int v_make_dcomplex(varinfo_t* var, char* name, double real, double imag);
int v_make_string(varinfo_t* var, char* name, char* s);
int v_fill_array(varinfo_t* var, char* name, int type, int ndims,
                 IDL_MEMINT dims[], UCHAR* data,IDL_LONG data_length);
int v_ensure_vptr(varinfo_t* var);
void v_fill_string(IDL_STRING *str, char *s);
