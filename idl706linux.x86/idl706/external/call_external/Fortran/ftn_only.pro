;;	$Id: //depot/idl/IDL_70/idldir/external/call_external/Fortran/unix/ftn_only.pro#1 $
;;
;; NAME:
;;	ftn_only.pro
;;
;; PURPOSE:
;;	The IDL procedure is used to demonstrate the IDL commands
;;	that are required to call an external Fortran routine that 
;;	is contained in a sharable image library.
;;
;; CATEGORY:
;;	Dynamic Link
;;
;; CALLING SEQUENCE:
;;	This function is called with the following IDL command.
;;
;;	IDL> ftn_only
;;
;; INPUTS:
;;	None.
;;
;; OUTPUTS:
;; 	None.
;;
;; SIDE EFFECTS:
;;	The returned values from the Fortran function are printed out
;;	to stdout.
;;
;; RESTRICTIONS:
;;	The properly compiled sharable library file must be located in
;;	in current working directory for the CALL_EXTERNAL function 
;;	to work correctly. Consult the makefile to build the library file.
;;
;; EXAMPLE:
;;-----------------------------------------------------------------------------
;;	To run this procedure just call it from the IDL prompt
;;
;;	IDL> ftn_only
;;
;;-----------------------------------------------------------------------------
;;
;; MODIFICATION HISTORY:
;;	Written using previous ftn_only procedure as a reference.
;;		October, 1993 	KDB
;;============================================================================

	PRO FTN_ONLY
;;
;;	First determine the entry point and library name to use in the 
;;	CALL_EXTERNAL function. This is done by looking at the machine
;;	architecture.

	CASE !VERSION.ARCH  OF

   	   'sparc': BEGIN
		tmp = FILE_SEARCH('/proc', count=count)
		if (count GT 0) then begin
			; /proc directory indicates Solaris 2.x
	                LIB_EXT = 'so'
        	        ENTRY_PRE = ''
			ENTRY_POST= '_'
			STR_FLAG =1B
		endif else begin
	                LIB_EXT = 'so'
        	        ENTRY_PRE = '_'
			ENTRY_POST= '_'
			STR_FLAG =1B
		endelse

           END

   	   'hp_pa': BEGIN

               LIB_EXT = 'sl'
               ENTRY_PRE = ''
 	       ENTRY_POST= ''
	       STR_FLAG = 1B
           END
   	
	   'hp9000s300': BEGIN

               LIB_EXT = 'sl'
               ENTRY_PRE = '_'
	       ENTRY_POST= ''
	       STR_FLAG = 1B

           END

   	   'ibmr2': BEGIN

               LIB_EXT = 'lib'
               ENTRY_PRE = ''
	       ENTRY_POST= ''
	       STR_FLAG = 0B

           END

            'alpha'     :BEGIN		;Dec OSF1

               LIB_EXT = 'so'
               ENTRY_PRE = ''
	       ENTRY_POST= '_'
	       STR_FLAG = 0B

           END

   	   ELSE: BEGIN
	    
                MESSAGE,'CASE ERROR: User must add correct entry name', $
		  /CONTINUE

		RETURN

	   END
        
	ENDCASE

;;	Get the library name and check that it is there
	
	CD, '.', CURRENT=PWD

	LIB_NAME   = PWD+'/'+'ftn_only.'+LIB_EXT

;;	Insure that the library file exists

	DUM = FILE_SEARCH(LIB_NAME, COUNT=CNT)

	IF(CNT eq 0)THEN BEGIN

;;	  The library file has not been made. Write a meassage and 
;; 	  exit.

	  PRINT,"The library file: "+ LIB_NAME +" Does not exist."
	  PRINT,"Issue the following command to create the library file:"
	  PRINT,"   % make_callext_demo test_ftn_only "

	  RETURN

	END 

	ENTRY_NAME = ENTRY_PRE+'ftn_only'+ENTRY_POST

;;	Now setup the variables that will be passed to the fortran
;;	routine

	BYTE_VAR 	= 2B
	SHORT_VAR	= 3
	LONG_VAR	= 4L
	FLOAT_VAR	= 5.0
	DOUBLE_VAR	= 6d0
	STRVAR		= "seven     "
	STR_LEN		= strlen(STRVAR)
	FLOAT_ARR	= findgen(12) *!PI
	
;;	Now make the call to the Fortran function. If the function is 
;;	for the IBM, do not pass a string.

	IF(STR_FLAG)THEN BEGIN

;;	   The fortran routine is set-up and tested to handle strings

	      SUM = CALL_EXTERNAL( LIB_NAME, ENTRY_NAME,	$
		BYTE_VAR,	       $;First parameter, byte variable
		SHORT_VAR,	       $;Short integer
		LONG_VAR,	       $;Long integer
		FLOAT_VAR,	       $;Float 
		DOUBLE_VAR,	       $;Double 
		STRVAR, STR_LEN,       $;STRING
		FLOAT_ARR,	       $;Float array
		n_elements(FLOAT_ARR), $;Number of elements in the array
 		/F_VALUE)		;Function returns sum of float array

	ENDIF ELSE BEGIN

;;	   The Fortran routine is not set up for strings.

              SUM = CALL_EXTERNAL( LIB_NAME, ENTRY_NAME,        $
                BYTE_VAR,              $;First parameter, byte variable
                SHORT_VAR,             $;Short integer
                LONG_VAR,              $;Long integer
                FLOAT_VAR,             $;Float
                DOUBLE_VAR,            $;Double
                FLOAT_ARR,             $;Float array
                n_elements(FLOAT_ARR), $;Number of elements in the array
                /F_VALUE)               ;Function returns sum of float array

	ENDELSE

;;      Now print out the results

        PRINT,""
        PRINT,"====================================================="
        PRINT,"Inside IDL: Results of Fortran function ftn_only. "
        PRINT,"            Simple variables were squared"
        PRINT,""
        PRINT,"Results:"
        PRINT,"         Squared BYTE Variable:          ", byte_var,    $
        FORMAT="(/A,I6)"
        PRINT,"         Squared INT Variable:           ", short_var,   $
        FORMAT="(A,I6)"
        PRINT,"         Squared LONG Variable:          ", long_var,    $
        FORMAT="(A,I6)"
        PRINT,"         Squared FLOAT Variable:         ", float_var,   $
        FORMAT="(A,F6.1)"
        PRINT,"         Squared DOUBLE Variable:        ", double_var,  $
        FORMAT="(A,F6.1)"

;;	Test if a string was sent

	IF(STR_FLAG)THEN						$
  	   PRINT,"         Squared STRING Variable:        ", strvar,	$
	   FORMAT="(A,'""',A,'""')"

        PRINT,"         Sum of the float array:        ", SUM, 		$
        FORMAT="(A,F7.2)"
        PRINT,""
        PRINT,"====================================================="

	PRINT,""
	PRINT,"Sum of array using the IDL TOTAL fuction: ",total(FLOAT_ARR), $
        FORMAT="(A,F7.2)"

;;	If the Fortran compiler can handle IDL strings, pass in a string 
;;	array

	IF(STR_FLAG)THEN BEGIN

;;	  Set the entry and library name

           LIB_NAME   = PWD+'/'+'ftn_only.'+LIB_EXT

;;	   Insure that the library file exists

           DUM = FILE_SEARCH(LIB_NAME, COUNT=CNT)

           IF(CNT eq 0)THEN BEGIN

;;           The library file has not been made. Write a meassage and
;;           exit.

             PRINT,"The library file: "+ LIB_NAME +" Does not exist."
             PRINT,"Issue the following command to create the library file:"
             PRINT,"   % make_callext_demo test_ftn_only "

             RETURN

           END

	   ENTRY_NAME = ENTRY_PRE+'str_arr'+ENTRY_POST

;;	   Create some data to send to the fortran array

	   STR_ARR   = sindgen(10)+" IDL String"
	   N_EL	     = n_elements(STR_ARR)

;;	   Now call the Fortran routine

	   STATUS = call_external(LIB_NAME, ENTRY_NAME, $
				N_EL,    $ ;Number of elements in array
				STR_ARR)   ;The IDL string array. 
	  
;;	   Print out the results returned
	
	   PRINT,""
	   PRINT,"Inside IDL: Results of Fortran subroutine ftn_strarr."
	   PRINT,"            The values of the string array were changed"
	   PRINT,""
	   PRINT,"Results:"
	   PRINT,""
	   FOR I=0,N_EL-1 DO			$
		PRINT,I, STR_ARR(I),		$
		FORMAT="(T10,'Value of Element ',I2,': ""',A,'""')"

           PRINT,"====================================================="

;;	   Thats it for the string array

	ENDIF

;;	Thats it

	RETURN

	END


