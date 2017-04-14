C-----------------------------------------------------------------
C  	Routine to print a floating point value from an IDL variable.

	SUBROUTINE PRINT_FLOAT(VPTR)

C       Declare a Fortran Record type that has a compatible form with 
C       the IDL C struct IDL_VARIABLE for a floating point value.
C       Note this structure contains a union which is the size of 
C       the largest data type.  This structure has been padded to
C       support the union.   Fortran records are not part of
C       F77, but most compilers have this option.

	STRUCTURE /IDL_VARIABLE/
           CHARACTER*1 TYPE 
           CHARACTER*1 FLAGS 
           INTEGER*4 PAD	!Pad for largest data type 
           REAL*4 VALUE_F
	END STRUCTURE 

	RECORD /IDL_VARIABLE/ VPTR

	WRITE(*, 10) VPTR.VALUE_F
  10	FORMAT('Program total is: ', F6.2)

	RETURN

	END

C-----------------------------------------------------------------
C  This function will be called when IDL is finished with the 
C  array F.  

       SUBROUTINE FREE_CALLBACK(ADDR)

          INTEGER*4 ADDR

          WRITE(*,20) LOC(ADDR)
  20	  FORMAT ('IDL Released:', I12)

          RETURN

       END

C-----------------------------------------------------------------
C   This program demonstrates how to import data from a Fortran
C   program into IDL, execute IDL statements and obtain data
C   from IDL variables.  

      PROGRAM CALLTEST

C   Some Fortran compilers require external definitions for IDL routines
        EXTERNAL IDL_Init !$pragma C(IDL_Init)    
        EXTERNAL IDL_Cleanup !$pragma C(IDL_Cleanup)    
        EXTERNAL IDL_Execute !$pragma C(IDL_Execute)
        EXTERNAL IDL_ExecuteStr !$pragma C(IDL_ExecuteStr)
        EXTERNAL IDL_ImportNamedArray !$pragma C(IDL_ImportNamedArray)
        EXTERNAL IDL_FindNamedVariable !$pragma C( IDL_FindNamedVariable )


C   Define arguments for IDL_Init routine
        INTEGER*4 ARGC
        INTEGER*4 ARGV(1)
        DATA ARGC, ARGV(1) /2 * 0/
  
C   Define IDL Definitions  for IDL_ImportNamedArray

        PARAMETER (IDL_MAX_ARRAY_DIM = 8)
        PARAMETER (IDL_TYP_FLOAT = 4)

        REAL*4 F(10)
        INTEGER*4 DIM(IDL_MAX_ARRAY_DIM)
        DATA DIM /10, 7*0/
        INTEGER*4 VAR_PTR 	!Address of IDL variable
        EXTERNAL FREE_CALLBACK	!Declare external routine for use as arg

        PARAMETER (MAXLEN=80)   !Maximum character string length
	PARAMETER (N_ELTS=10)	!Number of elements in array F

C  Define commands to be executed by IDL

        CHARACTER*(MAXLEN) CMDS(3)
        DATA CMDS /"tmp2 = total(tmp)",
     &            "print, 'IDL total is ', tmp2",
     &            "plot, tmp"/
        INTEGER*4 CMD_ARGV(10)

C  Define widget commands to be executed by IDL

        CHARACTER*(MAXLEN) WIDGET_CMDS(5)
        DATA  WIDGET_CMDS /"a = widget_base()",
     &    "b = widget_button(a,val='Press When Done',xs=300,ys=200)",
     &    "widget_control, /realize, a",
     &    "dummy = widget_event(a)", 
     &    "widget_control, /destroy, a"/

        INTEGER*4 ISTAT 

C    Null Terminate command strings and store the address
C    for each command string in CMD_ARGV 

        DO I = 1, 3  
           CMDS(I)(MAXLEN:MAXLEN) = CHAR(0)
           CMD_ARGV(I) = LOC(CMDS(I))
        ENDDO

C   Initialize floating point array, equivalent to IDL FINDGEN(10)

        DO I = 1, N_ELTS
           F(I) = FLOAT(I-1)
        ENDDO

C   Print address of F 

	WRITE(*,30) LOC(F)
   30	FORMAT('ARRAY ADDRESS:', I12)

C   Initialize Callable IDL

        ISTAT = IDL_Init(%VAL(0), ARGC, ARGV(1))

        IF (ISTAT .EQ. 1) THEN 

C   Import the floating point array into IDL as a variable named TMP 

          CALL IDL_ImportNamedArray('TMP'//CHAR(0), %VAL(1), DIM, 
     &	       %VAL(IDL_TYP_FLOAT), F, FREE_CALLBACK, %VAL(0))

C   Have IDL print the value of tmp

          CALL IDL_ExecuteStr('PRINT, TMP'//CHAR(0))

C   Execute a short sequence of IDL statements from a string array 

          CALL IDL_Execute(%VAL(3), CMD_ARGV)

C   Set tmp to zero, causing IDL to release the pointer to the
C   floating point array.

          CALL IDL_ExecuteStr('TMP = 0'//CHAR(0))

C   Obtain the address of the IDL variable containing the
C   the floating point data 

          VAR_PTR = IDL_FindNamedVariable('TMP2'//CHAR(0), %VAL(0)) 

C   Call a Fortran routine to print the value of the IDL tmp2 variable 
          CALL PRINT_FLOAT(%VAL(VAR_PTR))


C    Null Terminate command strings and store the address
C    for each command string in CMD_ARGV 

          DO I = 1, 5  
             WIDGET_CMDS(I)(MAXLEN:MAXLEN) = CHAR(0)
             CMD_ARGV(I) = LOC(WIDGET_CMDS(I))
          ENDDO

C   Execute a small widget program.  Pressing the button allows
C   the program to end 

          CALL IDL_Execute(%VAL(5), CMD_ARGV)

C   Shut down IDL
          CALL IDL_Cleanup(%VAL(0))

        ENDIF

      END
    


