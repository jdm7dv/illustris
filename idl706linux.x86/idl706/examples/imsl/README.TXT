-------------------------------------------------------------------
README file: <IDL_Directory>
               examples
                 imsl
-------------------------------------------------------------------

This directory contains examples showing how to call functions
from the Visual Numerics IMSL C Numerical Library from within IDL.

   ----------------------------------------------------------------
   NOTE:
   This method assumes you have a separately licensed version of
   the Visual Numerics IMSL C Numberical Library (CNL) installed.
   If you have purchased the IDL Analyst product, which includes
   the IMSL Numerical Library, you do not need to use this method.
   ----------------------------------------------------------------

How to use the IDL example code:

1.  You must have an installed and licensed version of the
    Visual Numerics IMSL C Numerical Library (not the IDL Analyst
    product).

2.  Determine the location of the IMSL shared libraries:
    On Windows platforms these are named "cmath.dll" and "cstat.dll".
    On Unix platforms these are usually named "cmath.so" and "cstat.so",
    although your specific platform may use a different suffix.

3.  When calling the IDL functions, supply the name and fully-qualified
    path for the appropriate IMSL shared library.

Example:

    Plot the Airy function for the range -14 to +6.
    (This assumes you have installed the IMSL library in C:\IMSL.)

    IDL> x = (FINDGEN(101)-70)/5.
    IDL> airy = IMSL_AIRY(x, LIBRARY='C:\IMSL\CNL\bin\cmath.dll')
    IDL> PLOT, x, airy, XTITLE='x', YTITLE='Ai(x)'


Note:   Visual Numerics and IMSL are registered trademarks
        of Visual Numerics, Inc.
