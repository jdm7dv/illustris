C
C	$Id: //depot/idl/IDL_70/idldir/external/call_external/Fortran/unix/simple_c2f1.f#1 $
C
C NAME:
C 	simple_c2f1
C
C PURPOSE:
C	This Fortran function is used to demonstrate how to pass all IDL
C	simple varable types to a FORTRAN routine via a C wrapper function.
C	Each variable is squared and returned to the calling C function.
C
C CATEGORY:
C	Dynamic Link
C
C CALLING SEQUENCE:
C      This function is called in IDL by using the following command
C      Access to this function is achived via a C 'wrapper' function.
C	
C      IDL> result = CALL_EXTERNAL('simple_c2f.so', '_simple_c2f',    $
C      IDL>      bytevar, shortvar, longvar, floatvar, doublevar, stringvar) 
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
C      String_var:     A scalar string value 
C
C OUTPUTS:
C	The value of each variable is squared. Since you should not 
C	change the value of an IDL string. A new string is created,
C	two copies of the original string placed in it and the 
C	string is returned as the value of this function.
C
C SIDE EFFECTS:
C	The values of the original variables are written to stdout.
C
C RESTRICTIONS:
C     None.
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
C        string_var      = "SIX"
C
C        result = CALL_EXTERNAL('simple_c2f.so', '_simple_c2f',     $
C                        byte_var, short_var, long_var, float_var,            $
C                        double_var, string_var )
C
C-----------------------------------------------------------------------------
C
C MODIFICATION HISTORY:
C	Written October, 1993		KDB

	SUBROUTINE SIMPLE_C2F1(BYTE_VAR, SHORT_VAR, LONG_VAR,
     &	     FLOAT_VAR, DOUBLE_VAR, STRING_VAR, RTR_STR, RTR_LEN )

C	Declare subroutine passed in variables 

	BYTE		        BYTE_VAR  	!IDL byte variable

	INTEGER*2		SHORT_VAR	!IDL integer variable 
	INTEGER*4		LONG_VAR	!IDL long integer
	INTEGER*4		RTR_LEN

	REAL			FLOAT_VAR	!IDL float variable

	DOUBLE PRECISION	DOUBLE_VAR	!IDL double variable

	CHARACTER*(*)		STRING_VAR	!IDL string variable

	CHARACTER*(*)		RTR_STR

C	Declare local variables

	INTEGER			LN    	  !Length of input string
	INTEGER		  	LEFT, EN
	
C	Print out each variable that was passed in.

        WRITE(*,10)
 10     FORMAT(1X,/,52('-') )

        WRITE(*,20)
 20     FORMAT(1X,'Inside Fortran function simple_c2f1 ',/
     &     '(Called from IDL using CALL_EXTERNAL via A C function)',/)

        WRITE(*,30)
 30     FORMAT(1X,'Scalar Values Passed in From IDL via a C function:')

        WRITE(*,100)BYTE_VAR
 100    FORMAT(10X,'BYTE Parameter:',T50,I4)

        WRITE(*,110)SHORT_VAR
 110    FORMAT(10X,'SHORT Parameter:',T50,I4)

        WRITE(*,120)LONG_VAR
 120    FORMAT(10X,'LONG Parameter:',T50,I4)

        WRITE(*,130)FLOAT_VAR
 130    FORMAT(10X,'FLOAT Parameter:',T50,F4.1)

        WRITE(*,140)DOUBLE_VAR
 140    FORMAT(10X,'Double Parameter:',T50,F4.1)

        WRITE(*,150)STRING_VAR
 150    FORMAT(10X,'String Parameter:',T50,A)

	WRITE(*,10)
C	Square each variable

	BYTE_VAR 	= BYTE_VAR*BYTE_VAR
	SHORT_VAR	= SHORT_VAR**2
	LONG_VAR	= LONG_VAR**2
	FLOAT_VAR	= FLOAT_VAR**2
	DOUBLE_VAR	= DOUBLE_VAR**2

C	Now to duplicate the string

	RTR_STR = STRING_VAR

	LN = len(STRING_VAR)

	LEFT = RTR_LEN - LN	
	IF( LEFT .gt. LN) LEFT = LN
	
	EN = LN*2
	IF(EN .gt. RTR_LEN)  EN = RTR_LEN 

	RTR_STR(LN+1:EN) = STRING_VAR(1:LEFT)

C	That is all that this subroutine does. Return to the 
C	calling C function.

	RETURN

	END



