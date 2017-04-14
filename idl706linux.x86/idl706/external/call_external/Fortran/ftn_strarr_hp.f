C
C	$Id: //depot/idl/IDL_70/idldir/external/call_external/Fortran/unix/ftn_strarr_hp.f#1 $
C
C NAME:
C 	ftn_strarr_hp.f	
C
C PURPOSE:
C	This Fortran function is used to demonstrate how IDL can
C	pass a string array to a Fortran routine, how that array can 
C	then be converted into a Fortran array, how the IDL array contents
C	can be changed and how these changes are returned to IDL. 
C
C CATEGORY:
C	Dynamic Link
C
C CALLING SEQUENCE:
C       This function is called in IDL by using the following command:
C
C	IDL> flag=CALL_EXTERNAL("ftn_strarr.sl", "strarr",   $
C	IDL>                     	n_elements(str_arr),str_arr)
C
C INPUTS:
C
C	n_ele:		The number of elements in the string array
C
C	str_arr:	The IDL string array.
C      
C OUTPUTS:
C	The value of the each element of the String array is changed.
C
C SIDE EFFECTS:
C	The passed in value of the IDL array is printed to stdout.
C
C RESTRICTIONS:
C	This example is setup to run using the HP operating system.
C
C EXAMPLE:
C-----------------------------------------------------------------------------
C;; The following are the commands that would be used to call this
C;; routine in IDL.
C;;
C	 str_arr	 = sindgen(10)+" IDL string"
C	 n_el		 = n_elements(str_arr)
C        result = CALL_EXTERNAL('ftn_strarr.sl', 'str_arr',       $
C                      		n_el, str_arr) 
C
C-----------------------------------------------------------------------------
C
C MODIFICATION HISTORY:
C	Written October, 1993		KDB
C
C 	Declare the Fortran function that is called by IDL via the 
C	CALL_EXTERNAL Function.
C
C=============================================================================
C$Function STR_ARR

        SUBROUTINE STR_ARR(ARGC, ARGV)

C PURPOSE:
C
C       Example Fortran function that is called directly from IDL via
C       the CALL_EXTERNAL function. This subroutine is used to convert
C	an IDL string array into a Fortran string array.
C
C       Declare the passed in variables

        INTEGER*4               ARGC    !Argument count
        INTEGER*4               ARGV(*) !Vector of pointers to argments

C       Declare the function that will be called so that we can convert the
C       IDL passed variables (ARGV) to Fortran varialbes via the parameter
C       passing function %VAL().
C
C       Local variables

        INTEGER                 ARG_CNT

C       The argument count is passed in by value. Get the location of
C       this value in memory (a pointer) and convert it into an
C       Fortran integer.

        ARG_CNT = %LOC(ARGC)

C	Insure that we got the correct number of arguments

	IF(ARG_CNT .ne. 2)THEN

	   WRITE(*,*)'str_arr: Incorrect number of arguments'
	   RETURN

	ENDIF

C       To convert the pointers to the IDL variables contained in ARGV
C       we must use the Fortran function %VAL. This funcion is used
C       in the argument list of a Fortran sub-program. Call the Fortran
C       subroutine that will actually perform the desired operations.
C       Set the return value to the value of this function.

        CALL STR_ARR1( %val(ARGV(1)), %val(ARGV(2)) )

C       Thats all, return to IDL.

        RETURN

        END

C=============================================================================
C$Function STR_ARR1

      	SUBROUTINE STR_ARR1(N_ELEMENTS, STRARR)
	
C	Declare a Fortran Record type that has the same form as the 
C	IDL C struct STRING. While Fortran records are not part of 
C	F77, most compilers have this option.
C
C   	Declare the string structure

	STRUCTURE /STRING/
		INTEGER*2 SLEN
		INTEGER*4 STYPE
		INTEGER*4 S
	END STRUCTURE

C	Declare a Fortran Parameter for the size of the fortran array

	INTEGER			ARR_SIZE
	PARAMETER	(	ARR_SIZE	= 	20  )

C	Declare a parameter for the length of the Fortran character strings

	INTEGER			CHAR_SIZE
	PARAMETER	(	CHAR_SIZE	= 	100 )

C	Now declare the passed in variables

	INTEGER*4		N_ELEMENTS	   !Size of array

        RECORD /STRING/		STRARR(N_ELEMENTS) !The string array

C	Declare local variables

	INTEGER			I		!Counter
	
	CHARACTER*(CHAR_SIZE)	TMPSTR		!A temp string variable

	CHARACTER*(CHAR_SIZE)	F_STRARR(ARR_SIZE) 

C	Write a message Indicating we are in the Fortran routine

        WRITE(*,10)
 10     FORMAT(1X,/,52('-') )

        WRITE(*,20)
 20     FORMAT(1X,'Inside Fortran function str_arr ',
     &            '(Called from IDL using CALL_EXTERNAL)',/)

C	Use a do loop to convert the IDL string to a Fortran string.
C	put that string into the Fortran character array and change 
C	the contents of the Fortran string and put the new value into
C	the IDL string.

	DO I=1, N_ELEMENTS 
	
C	  Convert the IDL string to a Fortran String

	  CALL IDL_2_FORT(%VAL(STRARR(I).S), STRARR(I).SLEN, TMPSTR,
     &			char_size)

C	  Now TMPSTR contains the IDL string in Fortran format. Check that 
C	  the size of TMPSTR is GE to the size of the IDL string.

	  IF( CHAR_SIZE .ge. STRARR(I).SLEN)THEN
	      WRITE(*,150)TMPSTR(1:STRARR(I).SLEN)
	  ELSE
	      WRITE(*,150)TMPSTR(1:CHAR_SIZE)
	  ENDIF

 150      FORMAT(10X,'String Parameter:',T30,A)

C	  Put this string into the Fortran String array

	  IF( I .le. ARR_SIZE)   F_STRARR(I)=TMPSTR(1:STRARR(I).SLEN)

C	  Now change the IDL string 

	  WRITE(TMPSTR, 2000)I
2000	  FORMAT('String Index: ',I2)

C	  Copy the string over to the IDL string

	  CALL FORT_2_IDL(TMPSTR, %VAL(STRARR(I).S),
     &		 STRARR(I).SLEN, CHAR_SIZE)

	END DO

	WRITE(*,10)

C	Now we have converted the IDL string array into a Fortran string
C	array, and changed the contents of the IDL string array elements.
C
C       Thats it, return to the calling routine

        RETURN

        END

