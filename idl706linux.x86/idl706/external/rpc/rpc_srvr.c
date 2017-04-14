/*
 * rpc_srvr.c - Server side of the IDL RPC implimentation. This routines
 * use Callable IDL to communicate information to idl.
 */

/*
  Copyright (c) 1988-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */

static char rcsid[] = "$Id: //depot/idl/IDL_70/idl_src/idl/rpc_srvr.c#2 $";


#include "idl_rpc.h"
#include "idl_rpc_xdr.h"
#include <stdlib.h>
#if defined(sun) || defined(linux) || defined(_AIX)
#include <rpc/rpc.h>
#include <rpc/pmap_clnt.h>
#endif
#if defined(sun) || defined(__hpux)
#include <rpc/svc_soc.h>
#endif

/*
 * define the switch used for the server id value
 */
#define RPC_SERVER_SW        "-server"

static long s_lServerId;	/* The ID number of the server */

static int  s_ToutEnabled;	/* flag for the output capture */

/*      Used for issuing IDL errors from the RPC message block */
static IDL_MSG_BLOCK idl_rpc_msg_block;

/* Definition used to create RPC message block */
static IDL_MSG_DEF idl_rpc_msg_arr[] = {
#define IDL_M_RPC_CNTCRETRANSPORT	0
  { "IDL_M_RPC_CNTCRETRANSPORT", "Unable to create rpc transport, aborting." },

#define IDL_M_RPC_CNTREGSERVICE		-1
  { "IDL_M_RPC_CNTREGSERVICE", "Unable to register service." },
  
#define IDL_M_RPC_SVCRUNRET		-2
  { "IDL_M_RPC_SVCRUNRET", "Unexpected return from svc_run()" },
  
#define IDL_M_RPC_CNTREPLYTOCMD		-3
  { "IDL_M_RPC_CNTREPLYTOCMD", "Unable to send reply to command." },
  
#define IDL_M_RPC_CNTREPLYTOCLNT	-4
  { "IDL_M_RPC_CNTREPLYTOCLNT", "Unable to send reply to client" },
  
};  


/*
 * Function Prototypes
 */

static void  IDL_RPCDeamon( struct svc_req *pRequest, SVCXPRT *pXport);
static int   IDL_RPCRegister(long lServerId);
void IDL_RPCToutFunc(int flags, char *buf, int n);
/**********************************************************************
 * main 
 * 
 *  Purpose:
 *	This is the main function for the IDL RPC server. This function
 *	initializes IDL, sets up the RPC server and starts up the RPC server
 *	daemon.
 *
 *  Command Line
 *	The IDL RPC server can be started using the following command 
 *	line form:
 *
 *	 	% idlrpc [-server=<ID number>] 
 *		  
 *	Where the <ID number> is the number the server is registered with.
 *	If this value is not provided, the default is used.
 *	
 *	All other command line arguements are pass on to the IDL_Initialize() 
 *	function.
 */
int main( int argc, char *argv[])
{
   int   i;
   int   iFile;
   char *pszId;
   long lServerId = IDL_RPC_DEFAULT_ID;
   IDL_INIT_DATA init_data;

   
   s_ToutEnabled=0;		/* not capturing output */
   /*
    * IDL_Initialize() will only take the switches that it wants. See if the 
    * user has passed in the server id switch?
    */ 
   for(i=0; i< argc; i++){
     if(!strncmp(argv[i], RPC_SERVER_SW, strlen(RPC_SERVER_SW))){
       pszId = argv[i] + strlen(RPC_SERVER_SW);
       if(*pszId == '=')
	  sscanf(pszId, "=%lx", &lServerId);
       argv[i] = '\0';		/* disables passing -server to IDL. */
     }
   }
   /*
    * Initialize IDL
    */
   init_data.options = IDL_INIT_BACKGROUND|IDL_INIT_CLARGS;
   init_data.clargs.argc = argc;
   init_data.clargs.argv = argv;
   if(!IDL_Initialize(&init_data)){
      fprintf(stderr, "Unable to initalize IDL\n");
      exit(-1);
   }

/*
 * Create the RPC message block.
 */
   idl_rpc_msg_block
     = IDL_MessageDefineBlock("IDL_RPC", (sizeof(idl_rpc_msg_arr)
					  / sizeof(idl_rpc_msg_arr[0])),
			      idl_rpc_msg_arr);
   if (!idl_rpc_msg_block) {
      fprintf(stderr, "Unable to initalize IDL RPC message block\n");
      exit(-1);
   }

/*
 * Turn off the more function that is used for output. If we capture
 * output, this can cause a deadlock between the server and the client.
 */
   IDL_ExecuteStr("!MORE=0"); 
/* 
 * Now register with the operating system and start up the deamon.
 */
   if(IDL_RPCRegister(lServerId))
      IDL_Cleanup(0);		/* Had an error */
/*
 * IDL_Cleanup() is not called here, but in the rpc deamon function
 */
   exit(0);
   return 0;			/* Make compiler content */
 }
/***************************************************************************
 * IDL_RPCRegister()
 * 
 * Purpose:
 * 	Registers IDL with the system and starts up the Deamon.
 */
static int IDL_RPCRegister(long lServerId)
{

   SVCXPRT  *transport;		/* the created transport */
/* 
 * Set the server id in a static var. This will be used during cleanup
 */
   s_lServerId = (!lServerId ? IDL_RPC_DEFAULT_ID : lServerId);
/*
 * Try to create a transport
 */
   if( (transport = (SVCXPRT*)svctcp_create(RPC_ANYSOCK, 0, 0)) == 
       (SVCXPRT*)NULL){
      IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTCRETRANSPORT,
			   IDL_MSG_INFO);
      return -1;
   }
   pmap_unset(s_lServerId, IDL_RPC_DEFAULT_VERSION); /* uset any old mappings*/
   
/*
 * Register the service
 */ 
   if(!svc_register(transport, s_lServerId, IDL_RPC_DEFAULT_VERSION, 
		    IDL_RPCDeamon, IPPROTO_TCP)){
      IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREGSERVICE,
			   IDL_MSG_INFO);
      return -1; 
   }
/*
 * Start the server message loop. svc_run should not return unless there
 * is an error.
 */
   svc_run();
				/* should never get here! */
   IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_SVCRUNRET, IDL_MSG_INFO);
   return -1;
}
/*****************************************************************
 * IDL_RPCDeamon
 *
 * Purpose:
 * 	This routine is the used to process requests from the RPC clients.
 *	Depending on the message request made by the client, this
 *	routine will take the correct action.
 */
static void  IDL_RPCDeamon( struct svc_req *pRequest, SVCXPRT *pXport)
{
   int               iResult;
   int               iCount;
   char              CmdBuf[IDL_RPC_MAX_STRLEN];
   char             *pCommand;
   IDL_RPC_LINE_S   *pLine, nullLine;
   IDL_RPC_VARIABLE  RpcVar;
   IDL_VPTR          vTmp;

/*
 * Do a switch on the rq_proc field of the request struct to determine 
 * what request was made.
 */
   switch( pRequest->rq_proc) {

   case IDL_RPC_EXE_STR:	/* Execute an IDL command string */
      pCommand = CmdBuf;  	/* will need a ^^ */
      if(!svc_getargs( pXport, (xdrproc_t)xdr_wrapstring, (caddr_t)&pCommand)){
        svcerr_decode( pXport );    /* had an error */
        return;
      }
   /*
    * Check the value of the command. If it is null, return ok
    */
      if( *pCommand == (char)NULL){
         iResult = 0;	/* null commands always succeed */
      }else{
        iResult = IDL_ExecuteStr(pCommand);
      }
      /* Send reply */
      if(!svc_sendreply(pXport, (xdrproc_t)xdr_int, (caddr_t)&iResult)){
      /*  
       * Had an error, Exit the process
       */
         IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREPLYTOCMD,
			      IDL_MSG_EXIT);
       }
       break;

    case IDL_RPC_OUT_CAPTURE:	/* enable/disable output capture */
       if(!svc_getargs(pXport, (xdrproc_t)xdr_int, (caddr_t)&iCount)){
          svcerr_decode(pXport);
          return;
	}
    /*
     *  If we are enabling output, make sure that tout capture is 
     *  already enabled.
     */
        iResult=1;
        if(s_ToutEnabled && iCount > 0)
           iResult=1;
        else if(iCount > 0){
	   IDL_RPCOutListInit(iCount);
	   IDL_ToutPush((IDL_TOUT_OUTF)IDL_RPCToutFunc);
	   s_ToutEnabled = 1;
	}else{			/* disable the tout capture */
	   s_ToutEnabled = 0;
	/*
	 * Empty out the current output queue.
         */
	   IDL_ToutPop();	/* pop out our function from IDL */
	   while( (pLine = (IDL_RPC_LINE_S*)IDL_RPCOutListPop()) != NULL){
	       free(pLine->buf);
	       free((char*)pLine);
	   }
	}
        if(!svc_sendreply(pXport, (xdrproc_t)xdr_int, (caddr_t)&iResult)){
	   IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREPLYTOCLNT,
				IDL_MSG_EXIT);
	}
        break;
    case IDL_RPC_GET_MAIN_VAR:
         pCommand = CmdBuf;	/* just use this string */
         if(!svc_getargs(pXport, (xdrproc_t)xdr_wrapstring, (caddr_t)&pCommand)){
	    svcerr_decode(pXport);
	    return;
	 }
      /* 
       * Fill in the Struct that is used to pass the var back.
       */ 
         RpcVar.name      = pCommand;
         RpcVar.pVariable = IDL_GetVarAddr(pCommand);
         if(RpcVar.pVariable == (IDL_VPTR)NULL)
	    RpcVar.pVariable = IDL_Gettmp(); /* get an undefined var */
         if(!svc_sendreply(pXport, (xdrproc_t)IDL_RPC_xdr_variable, (caddr_t)&RpcVar)){
	    svcerr_decode(pXport);
	    return;
	 }
         IDL_DELTMP(RpcVar.pVariable); /* delete var if it is one */
         return;
    case IDL_RPC_SET_MAIN_VAR:
      /*
       * Set the variable at the main level
       */
         IDL_BZERO(RpcVar);
         iResult = IDL_ExecuteStr("RETALL"); /* get to main level */
         if(!svc_getargs(pXport, (xdrproc_t)IDL_RPC_xdr_variable, (caddr_t)&RpcVar)){
	    svcerr_decode(pXport);
	    return;
	 }
         vTmp = IDL_GetVarAddr1(RpcVar.name, 1); /* will create var if needed */
         if(RpcVar.pVariable->type == IDL_TYP_UNDEF){
	    vTmp->type = IDL_TYP_UNDEF;
	    vTmp->flags = 0;
	    IDL_DELTMP(RpcVar.pVariable);
	 }else{
            IDL_VarCopy(RpcVar.pVariable, vTmp);
	  }
         if(!svc_sendreply(pXport, (xdrproc_t)xdr_void, 0)){
	    IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREPLYTOCLNT,
				 IDL_MSG_EXIT);
	}
        break;
    case IDL_RPC_GET_VAR:
      /*
       * Get the variable from the current scope of IDL
       */
         pCommand = CmdBuf;	/* just use this string */
         if(!svc_getargs(pXport, (xdrproc_t)xdr_wrapstring, (caddr_t)&pCommand)){
	    svcerr_decode(pXport);
	    return;
	 }
         RpcVar.name      = pCommand;
      /*
       * Is the variable in the current scope?"???
       */
         RpcVar.pVariable = IDL_FindNamedVariable(RpcVar.name, 0);
         if(RpcVar.pVariable == (IDL_VPTR)NULL)
	    RpcVar.pVariable = IDL_Gettmp();
         if(!svc_sendreply(pXport, (xdrproc_t)IDL_RPC_xdr_variable, (caddr_t)&RpcVar)){
	    svcerr_decode(pXport);
	    return;
	 }
         IDL_DELTMP(RpcVar.pVariable);
         return;

    case IDL_RPC_SET_VAR:
      /*
       * Set the variable in the current IDL scope
       */
         IDL_BZERO(RpcVar);
         if(!svc_getargs(pXport, (xdrproc_t)IDL_RPC_xdr_variable, (caddr_t)&RpcVar)){
	    svcerr_decode(pXport);
	    return;
	 }
         vTmp = IDL_FindNamedVariable(RpcVar.name, 1);
         if(RpcVar.pVariable->type == IDL_TYP_UNDEF){
	    vTmp->type = IDL_TYP_UNDEF;
	    vTmp->flags = 0;
	    IDL_DELTMP(RpcVar.pVariable);
	 }else
            IDL_VarCopy(RpcVar.pVariable, vTmp);

         if(!svc_sendreply(pXport, (xdrproc_t)xdr_void, 0)){
	    IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREPLYTOCLNT,
				 IDL_MSG_EXIT);
	}
        break;

    case IDL_RPC_OUT_STR:
         if(!svc_getargs(pXport, (xdrproc_t)xdr_int, (caddr_t)&iCount)){
	    svcerr_decode(pXport);
	    return;
	 }
      /*
       *  Should be Pop or Dequeue
       */
         if(iCount)
	   pLine = (IDL_RPC_LINE_S*)IDL_RPCOutListPop();
         else 
	   pLine = (IDL_RPC_LINE_S*)IDL_RPCOutListDequeue();

         if(!pLine){
         /*
          * Initialize the nullLine struct
          */
   	    IDL_BZERO(nullLine);
     	    nullLine.flags = -1;
	    nullLine.buf = " "; /* a null string dumps xdr on dec alpha */
	    pLine = &nullLine;
	  }
         if(!svc_sendreply(pXport, (xdrproc_t)IDL_RPC_xdr_line_s, (caddr_t)pLine)){
	   IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREPLYTOCLNT,
				IDL_MSG_EXIT);
	}	    
        break;
    case IDL_RPC_CLEANUP:	/* shut the server down */
       (void)svc_sendreply(pXport, (xdrproc_t)xdr_void, 0); /* send reply */
       svc_unregister(s_lServerId, IDL_RPC_DEFAULT_VERSION);
       svc_destroy(pXport);
       (void)IDL_Cleanup(FALSE);  /* exit idl */
       break;

     default:
       printf("code number is "
#ifdef IRIX_64
	      "%ld\n",
#else
	      "%d\n",
#endif
	      pRequest->rq_proc);

       if(!svc_sendreply(pXport, (xdrproc_t)xdr_void, 0))
	 IDL_MessageFromBlock(idl_rpc_msg_block, IDL_M_RPC_CNTREPLYTOCLNT,
			      IDL_MSG_EXIT);
       break;
    } /* end switch */
     
} /* IDL_RPCDeamon */
