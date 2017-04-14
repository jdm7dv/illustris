C
C
C NAME:
C 	ftn_only_osf1.f
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
C      IDL> result = CALL_EXTERNAL('ftn_only.so', 'ftn_only',    $
C      IDL>      bytevar, shortvar, longvar, floatvar, doublevar,  $
C      IDL>      floatarr, n_elments(floatarr) ) 
C
C INPUTS:
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
C      floatarr:       A floating point array
C      
C      cnt:	       Number of elements in the array.
C
C OUTPUTS:
C	The value of each variable is squared and the sum of the 
C	array is returned as the value of the function. 
C
C SIDE EFFECTS:
C	The values of the passed in variables are written to stdout.
C
C RESTRICTIONS:
C	This example is setup to run using the OSF1 operating system. 
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
C        result = CALL_EXTERNAL('ftn_only.so', 'ftn_only',     $
C                        byte_var, short_var, long_var, float_var,      $
C                        double_var, floatarr, n_elments(floatarr) )
C
C-----------------------------------------------------------------------------
C
C MODIFICATION HISTORY:
C	Copied from HP version, July, 1995		ACY
C
C 	Declare the Fortran function that is called by IDL via the 
C	CALL_EXTERNAL Function.
C
C=============================================================================
C$Function FTN_ONLY

        REAL*4 FUNCTION FTN_ONLY(ARGC, ARGV)

C PURPOSE:
C
C       Example Fortran function that is called directly from IDL via
C       the CALL_EXTERNAL function.
C
C       Declare the passed in variables

        INTEGER*8               ARGC    !Argument count
        INTEGER*8               ARGV(*) !Vector of pointers to argments

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

	IF(ARG_CNT .ne. 7)THEN

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
     & 			      %val(ARGV(7)) )

C       Thats all, return to IDL.

        RETURN

        END

C=============================================================================
C$Function FTN_ONLY1

      	REAL*4 FUNCTION FTN_ONLY1(BYTEVAR, SHORTVAR, LONGVAR,
     &		FLOATVAR, DOUBLEVAR, FLOATARR, N)

        LOGICAL*1               BYTEVAR         !IDL byte

        INTEGER*2               SHORTVAR        !IDL integer

        INTEGER*4               LONGVAR         !IDL long integer
	INTEGER*4		N		!Size of array

        REAL*4                  FLOATVAR        !IDL float
	REAL*4			FLOATARR(N)	!IDL float array
	
        DOUBLE PRECISION        DOUBLEVAR       !IDL double

	INTEGER			I		!Counter
	
	REAL*4			SUM		
C
C       Write the values of the variables that were passed in to
C       Fortran from IDL.

        WRITE(*,10)
 10     FORMAT(1X,/,52('-') )

        WRITE(*,20)
 20     FORMAT(1X,'Inside Fortran function ftn_only1 ',
     &            '(Called from ftn_only)',/)

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

 	WRITE(*,160)
 160	FORMAT(10X,'Float Array:')

	WRITE(*,170)(I, FLOATARR(I), I=1, N)
 170	FORMAT(15X,'Element ',I3,', Value: ',T47, F7.2)

	WRITE(*,10)     !Prints a line across the page

C       Perform a simple operation on each varable (square them).

        BYTEVAR   = BYTEVAR   * BYTEVAR
        SHORTVAR  = SHORTVAR  * SHORTVAR
        LONGVAR   = LONGVAR   * LONGVAR
        FLOATVAR  = FLOATVAR  * FLOATVAR
        DOUBLEVAR = DOUBLEVAR * DOUBLEVAR

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


