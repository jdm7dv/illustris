/*
**	$Id: //depot/idl/IDL_70/idldir/external/call_external/Fortran/unix/simple_c2f.c#1 $
**
** NAME:
** 	simple_c2f
**
** PURPOSE:
**	This C function is used to demonstrate how to pass all IDL
**	simple varable types to a FORTRAN routine via a C wrapper function.
**	The passed variables are squared in the Fortran routine and
**	returned.
**
** CATEGORY:
**	Dynamic Link
**
** CALLING SEQUENCE:
**      This function is called in IDL by using the following command
**
**      IDL> result = CALL_EXTERNAL('simple_c2f.so', '_simple_c2f',    $
**      IDL>            byte_var, short_var, long_var, float_var,        $
**      IDL>            double_var, string_var, /S_VALUE )
**
** INPUTS:
**
**      Byte_var:       A scalar byte variable
**
**      Short_var:      A scalar short integer variable
**
**      Long_var:       A scalar long integer variable
**
**      Float_var:      A scalar float variable
**
**      Double_var:     A scalar float variable
**
**      String_var:     A scalar string value (Actally an IDL STRING struct)
**
** OUTPUTS:
**	All numeric variables are squared and the "squared" string value
**	is returned as the result of Call external. All this squaring
**	is performed in the Fortran function simple_c2f1.	
**
** SIDE EFFECTS:
**	None.
**
** RESTRICTIONS:
**	This example assumes that the values are long (4 bytes) and not
**	short integers. An IDL integer is only 2 bytes long, so the variables
**	should be delcared in IDL at type long.
**
** EXAMPLE:
**-----------------------------------------------------------------------------
;; The following are the commands that would be used to call this
;; routine in IDL.
;;
        byte_var        = 1b
        short_var       = 2
        long_var        = 3l
        float_var       = 4.0
        double_var      = 5d0
        string_var      = "SIX"

        result = CALL_EXTERNAL('simple_c2f.so', '_simple_c2f',     $
                        byte_var, short_var, long_var, float_var,            $
                        double_var, string_var , /S_VALUE)

**-----------------------------------------------------------------------------
**
** MODIFICATION HISTORY:
**	Written October, 1993		KDB
**	
** Declare Header files
*/
#include <stdio.h>

/*
** Declare the structure for an IDL string (From IDL User's Guide).
*/
typedef struct {
   unsigned short slen;         /* length of the string         */
   short stype;                 /* Type of string               */
   char *s;                     /* Pointer to chararcter array  */
} STRING;

/*
** Define a C macro that will return the length of an IDL String
*/

#define STR_LEN(__str)    ((long)(__str)->slen)

/*
** Declare the function
*/

char *
simple_c2f(argc, argv)
int argc;
void *argv[];
{
/*
** Since this function is used on different UNIX platforms the fortran
** entry points can differ. Some systems (SUN) fortran compliers will
** add and extra '_' to the end of the routine. To correct for this
** add some preprocessor commmands. 
*/
  
#if defined(SPARC) || defined(OSF1)
   void simple_c2f1_();
#else
   void simple_c2f1();  /* function prototype for the fortran funct */
#endif

/*
** Declare variables
*/
   char         *byte_var;      /* Pointer to a char ( One byte )       */
   short        *short_var;     /* Pointer to short integer             */
   long         *long_var;      /* Pointer to long                      */
   float        *float_var;     /* Pointer to float                     */
   double       *double_var;    /* Pointer to double                    */
   STRING       *string_var;    /* Pointer to IDL string structure      */
   char		*return_string; /* Pointer to the returned string	*/
   long		ch_size = 100;  /* size of the return string 		*/

/*
** Insure that the correct number of arguments were passed in (argc = 6)
*/

   if(argc != 6)
   {
   /*
   ** Print an error message and return
   */
      fprintf(stderr,"simple_c2f: Incorrect number of arguments\n");
      return((char*)NULL);  /* Signal an error */
   }
/*
** Cast the pointer in argv to the pointer variables
*/
   byte_var     = (char *)   argv[0];
   short_var    = (short *)  argv[1];
   long_var     = (long *)   argv[2];
   float_var    = (float *)  argv[3];
   double_var   = (double *) argv[4];
   string_var   = (STRING *) argv[5];

/*
** Now malloc some space for the return string.
*/
   if( (return_string=(char*)malloc((unsigned)ch_size+1))
       == (char*)NULL)
   {
      fprintf(stderr,"simple_c2f: malloc error \n");
      return(return_string);
   }

/*
** Now we need to call the fortran subroutine. The FORTRAN subroutine 
** uses varable length strings for the string parameter( CHARACTER*(*) ).
** Because of this we must pass in the length of each string that is 
** passed to the FORTRAN subprocedure. The string lengths are added 
** to the end of the parameter list. 
*/

#if defined(SPARC) || defined(OSF1)
   simple_c2f1_(byte_var, short_var, long_var, float_var, double_var, 
	 string_var->s, return_string, &ch_size, STR_LEN(string_var),ch_size );
#else
   simple_c2f1(byte_var, short_var, long_var, float_var, double_var,
         string_var->s, return_string, &ch_size, STR_LEN(string_var),ch_size );
#endif

/*
** That should be it, return the new string to the calling routine
*/
   return((char*)return_string);
} 


