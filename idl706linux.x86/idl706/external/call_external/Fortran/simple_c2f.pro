;;	$Id: //depot/idl/IDL_70/idldir/external/call_external/Fortran/unix/simple_c2f.pro#1 $
;;
;; PURPOSE:
;;	This IDL procedure is used to show how to call an external 
;;	C wrapper function that then calls a Fortran routine.
;;	
;;============================================================================

	PRO SIMPLE_C2F
;;
;;	Determine what operating system we are on and set-up the proper
;;	library file extensions.

        CASE !VERSION.ARCH OF

           'sparc'      :BEGIN

                LIB_EXT         = 'so'

;;              Determine if the OS is Solaris

                aa = FILE_SEARCH('/proc',COUNT = CNT)
                IF(CNT eq 0)THEN                $
                   ENTRY_PREFIX = '_'           $
                ELSE                            $
                   ENTRY_PREFIX = ''

            END

           'hp_pa'      :BEGIN

                LIB_EXT         = 'sl'
                ENTRY_PREFIX    = ''

            END

           'hp9000s300' :BEGIN

                LIB_EXT         = 'sl'
                ENTRY_PREFIX    = '_'

            END

           'ibmr2'      :BEGIN

                LIB_EXT         = 'lib'
                ENTRY_PREFIX    = ''

            END

            'alpha'     :BEGIN		;Dec OSF1

               LIB_EXT = 'so'
               ENTRY_PREFIX = ''

            END

            ELSE        :BEGIN

                MESSAGE,"CASE ERROR: User must add correct entry name", $
                        /CONTINUE

                RETURN

            END
        ENDCASE

;;
;; 	Some operating systems require that you use full path names. Get
;;	the current working directory.

	CD, '.', CURRENT=PWD
	PWD= PWD+'/'

;;	Determine if the library file has been build or not. If it 
;;	hasn't write a message and return.

	FILENAME = FILE_SEARCH(PWD+'simple_c2f.'+LIB_EXT, COUNT= CNT)

	IF(CNT eq 0)THEN BEGIN

	  MESSAGE,"The library file, "+PWD+"simple_c2f."+LIB_EXT+ $
		", is not present. The library file must be built.",/CONTINUE

	  RETURN

	ENDIF

;;	Set up some variables to pass into the test routines

	BYTE_VAR		= 2B
	SHORT_VAR		= 3
	LONG_VAR		= 4L
	FLOAT_VAR		= 5.0
	DOUBLE_VAR		= 6D0
	STRING_VAR		= "Seven"

;;	Make the call to the C wrapper via the CALL_EXTERNAL function.

	RESULT = call_external(PWD+'simple_c2f.'+LIB_EXT,		$
			ENTRY_PREFIX+'simple_c2f',			$
			BYTE_VAR, SHORT_VAR, LONG_VAR, FLOAT_VAR,       $
                        DOUBLE_VAR, STRING_VAR, /S_VALUE )

;;	Print the results of the function.

        PRINT,""
        PRINT,"====================================================="
        PRINT,"Inside IDL: Results of C/Fortran function simple_c2f."
        PRINT,"            Simple variables are squared in the Fortran function"
        PRINT,""
        PRINT,"Results:"
        PRINT,"         Squared BYTE Variable:          ", BYTE_VAR,    $
        FORMAT="(/A,I6)"
        PRINT,"         Squared INT Variable:           ", SHORT_VAR,   $
        FORMAT="(A,I6)"
        PRINT,"         Squared LONG Variable:          ", LONG_VAR,    $
        FORMAT="(A,I6)"
        PRINT,"         Squared FLOAT Variable:         ", FLOAT_VAR,   $
        FORMAT="(A,F6.1)"
        PRINT,"         Squared DOUBLE Variable:        ", DOUBLE_VAR,  $
        FORMAT="(A,F6.1)"
        PRINT,"         Squared STRING Variable:        ", RESULT, $
        FORMAT="(A,A10)"
        PRINT,""
        PRINT,"====================================================="

;;	Thats it.

	END
