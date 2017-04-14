C
C	$Id: //depot/idl/IDL_70/idldir/external/call_external/Fortran/unix/ftn_only_sun.f#1 $
C
C NAME:
C 	ftn_only_sun.f
C
C PURPOSE:
C	This Fortran function is used to demonstrate how IDL can
C	pass variables to a Fortran routine and then recieve these
C	variables once they are modified. 
C
C CATEGORY:
C	Dynamic Link
C
C CALLING SEQUENCE:
C      This function is called in IDL by using the following command
C      Access to this function is achived via a C 'wrapper' function.
C	
C      IDL> result = CALL_EXTERNAL('ftn_only.so', '_ftn_only_',    $
C      IDL>      bytevar, shortvar, longvar, floatvar, doublevar,  $
C      IDL>      strvar, floatarr, n_elments(floatarr) ) 
C
C INPUTS:
C
C      Byte_var:       A scalar byte variable
C
C      Short_var:      A scalar short integer variable
C
C      Long_var:       A scalar long integer variable
C
C      Float_var:      A scalar float variable
C
C      Double_var:     A scalar float variable
C
C      strvar:	       A IDL scalar string
C
C      floatarr:       A floating point array
C      
C      cnt:	       Number of elements in the array.
C
C OUTPUTS:
C	The value of each variable is squared and the sum of the 
C	array is returned as the value of the function. 
C
C SIDE EFFECTS:
C	The values of the passed in variables are written to stdout	
C
C RESTRICTIONS:
C	This example is setup to run using the Sun operating system. This
C	does not include a system running solaris. 
C
C EXAMPLE:
C-----------------------------------------------------------------------------
C;; The following are the commands that would be used to call this
C;; routine in IDL. This calls the C function that calls this FORTRAN
C;; Subprogram.
C;;
C        byte_var        = 1b
C        short_var       = 2
C        long_var        = 3l
C        float_var       = 4.0
C        double_var      = 5d0
C	 floatarr	 = findgen(30)*!pi
C
C        result = CALL_EXTERNAL('ftn_only.so', '_ftn_only_',     $
C                        byte_var, short_var, long_var, float_var,      $
C                        double_var, strvar, floatarr, n_elments(floatarr) )
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
C$Function FTN_ONLY
C
C IMPORTANT NOTE:
C    This function should be REAL*8 for SunOS 4.x, REAL*4 for Solaris
C
        REAL*4 FUNCTION FTN_ONLY(ARGC, ARGV)

C PURPOSE:
C
C       Example Fortran function that is called directly from IDL via
C       the CALL_EXTERNAL function.
C
C       Declare the passed in variables

        INTEGER*4               ARGC    !Argument count
        INTEGER*4               ARGV(*) !Vector of pointers to argments

C       Declare the function that will be called so that we can convert the
C       IDL passed variables (ARGV) to Fortran varialbes via the parameter
C       passing function %VAL().

        REAL*4                  FTN_ONLY1

C       Local variables

        INTEGER                 ARG_CNT

C       The argument count is passed in by value. Get the location of
C       this value in memory (a pointer) and convert it into an
C       Fortran integer.

        ARG_CNT = LOC(ARGC)

C	Insure that we got the correct number of arguments

	IF(ARG_CNT .ne. 9)THEN

	   WRITE(*,*)'ftn_only: Incorrect number of arguments'
	   FTN_ONLY = -1.0
	   RETURN

	ENDIF

C       To convert the pointers to the IDL variables contained in ARGV
C       we must use the Fortran function %VAL. This funcion is used
C       in the argument list of a Fortran sub-program. Call the Fortran
C       subroutine that will actually perform the desired operations.
C       Set the return value to the value of this function.

        FTN_ONLY = FTN_ONLY1( %val(ARGV(1)), %val(ARGV(2)),
     &                        %val(ARGV(3)), %val(ARGV(4)),
     &                        %val(ARGV(5)), %val(ARGV(6)),
     & 			      %val(ARGV(7)), %val(ARGV(8)),  
     & 			      %val(ARGV(9)) )

C       Thats all, return to IDL.

        RETURN

        END

C=============================================================================
C$Function FTN_ONLY1

      	REAL*4 FUNCTION FTN_ONLY1(BYTEVAR, SHORTVAR, LONGVAR,
     &		FLOATVAR, DOUBLEVAR, STRVAR,  STRLEN, FLOATARR, N)
	
C	Declare a parameter for the size of the temporary string

	INTEGER			CHAR_SIZE
	PARAMETER	( 	CHAR_SIZE 	= 	100  )

C       Declare an IDL string structure

	STRUCTURE /STRING/
		INTEGER*2 SLEN
		INTEGER*4 STYPE
		INTEGER	  S
	END STRUCTURE

        LOGICAL*1               BYTEVAR         !IDL byte

        INTEGER*2               SHORTVAR        !IDL integer

        INTEGER*4               LONGVAR         !IDL long integer
	INTEGER*4		N		!Size of array
	INTEGER*4		STRLEN

        REAL*4                  FLOATVAR        !IDL float
	REAL*4			FLOATARR(N)	!IDL float array
	
        DOUBLE PRECISION        DOUBLEVAR       !IDL double

        RECORD /STRING/		STRVAR

	INTEGER			I		!Counter
	
	REAL*4			SUM		

	CHARACTER*(CHAR_SIZE)	TMPSTR		!Temporary String

	CALL IDL_2_FORT(%VAL(STRVAR.S), STRVAR.SLEN, TMPSTR, CHAR_SIZE)

C	Now TMPSTR contains the IDL string in Fortran format
C
C       Write the values of the variables that were passed in to
C       Fortran from IDL.

        WRITE(*,10)
 10     FORMAT(1X,/,52('-') )

        WRITE(*,20)
 20     FORMAT(1X,'Inside Fortran function ftn_only ',
     &            '(Called from IDL using CALL_EXTERNAL)',/)

        WRITE(*,30)
 30     FORMAT(1X,'Scalar Values Passed in From IDL:')

        WRITE(*,100)BYTEVAR
 100    FORMAT(10X,'BYTE Parameter:',T50,I4)

        WRITE(*,110)SHORTVAR
 110    FORMAT(10X,'SHORT Parameter:',T50,I4)

        WRITE(*,120)LONGVAR
 120    FORMAT(10X,'LONG Parameter:',T50,I4)

        WRITE(*,130)FLOATVAR
 130    FORMAT(10X,'FLOAT Parameter:',T50,F4.1)

        WRITE(*,140)DOUBLEVAR
 140    FORMAT(10X,'Double Parameter:',T50,F4.1)

	WRITE(*,150)TMPSTR(1:STRVAR.SLEN)
 150    FORMAT(10X,'String Parameter:',T50,A)

 	WRITE(*,160)
 160	FORMAT(10X,'Float Array:')

	WRITE(*,170)(I, FLOATARR(I), I=1, N)
 170	FORMAT(15X,'Element ',I3,', Value: ',T47, F7.2)

	WRITE(*,10)     !Prints a line across the page

C       Perform a simple operation on each varable (square them).

C    Cannot multiply two logicals under Fortran90
C        BYTEVAR   = BYTEVAR   * BYTEVAR
        SHORTVAR  = SHORTVAR  * SHORTVAR
        LONGVAR   = LONGVAR   * LONGVAR
        FLOATVAR  = FLOATVAR  * FLOATVAR
        DOUBLEVAR = DOUBLEVAR * DOUBLEVAR

C	Now "square" the IDL string

	TMPSTR(1:STRVAR.SLEN) = TMPSTR(1:STRVAR.SLEN/2)//
     &			   TMPSTR(1:STRVAR.SLEN/2)

C	Copy the string over to the IDL string

	CALL FORT_2_IDL(TMPSTR, %val(STRVAR.S), STRVAR.SLEN, CHAR_SIZE)

C 	Now sum the array

	SUM = 0.0

	DO I = 1, N 

	   SUM = SUM + FLOATARR(I)

	ENDDO	

C	Set the function equal to the sum

        FTN_ONLY1 = SUM 

C       Thats it, return to the calling routine

        RETURN

        END

C==========================================================================
C$Subroutine IDL_2_FORT

	SUBROUTINE IDL_2_FORT(IDLSTR, STRLEN, FORTSTR, F_LEN)
	
C PURPOSE:
C       Copies an IDL string to a Fortran character string.

	INTEGER*2		STRLEN
	CHARACTER*(*)		IDLSTR
	
	CHARACTER*(*)		FORTSTR

        INTEGER                 F_LEN

C       If the IDL string is smaller then copy the entire string into
C       the Fortran string, otherwise truncate it.

        IF(STRLEN .le. F_LEN )THEN
            FORTSTR(1:STRLEN)=IDLSTR(1:STRLEN)
        ELSE
            FORTSTR(1:F_LEN)=IDLSTR(1:F_LEN)
        ENDIF

C       Thats it

	RETURN
	END

C=========================================================================
C$Subroutine FORT_2_IDL

	SUBROUTINE FORT_2_IDL(FORTSTR, IDLSTR, STRLEN, F_LEN )

C PURPOSE:
C	Copies a Fortran string to an IDL string

	CHARACTER*(*)	FORTSTR
	CHARACTER*(*)	IDLSTR

	INTEGER*2	STRLEN

        INTEGER         F_LEN

C       If the Fortran string is smaller then copy the entire Fortran
C       string into the IDL string, otherwise truncate it.

        IF(STRLEN .gt. F_LEN )THEN
          IDLSTR(1:F_LEN) = FORTSTR(1:F_LEN)
        ELSE
          IDLSTR(1:STRLEN) = FORTSTR(1:STRLEN)
        ENDIF

C	Thants it.

	RETURN

	END
	
