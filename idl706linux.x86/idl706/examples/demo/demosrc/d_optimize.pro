; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_optimize.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_optimize.pro
;
;  CALLING SEQUENCE: d_optimize
;
;  PURPOSE:
;       Shows the path taken by 2 optimization algorithms :
;       Powell and DFP.
;
;  MAJOR TOPICS: Data analysis and plotting
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_optimizeInit16Colors    - Initialize 16 working colors
;       pro d_optimizeInitPoint       - Initialize starting points coordinates
;       pro d_optimizeResetPoint      - Redraw the starting point
;       pro d_optimizeResetSurface    - Redraw the surface (function)
;       pro d_optimizeResetResults    - Reset the result labels
;       pro d_optimizeShowStart       - Show starting point (Label and point)
;       pro d_optimizeAbout           - Display the inforation file
;       pro d_optimizePlotPoint       - Plot the points along the path
;       pro d_optimizeDFP             - DFP algorithm
;       pro d_optimizePoweop          - Powell algorithm
;       pro d_optimizeFuncOp          - function to minimize (DFP and Powell)
;       pro d_optimizeLinmOp          - subroutine in Powell
;       pro d_optimizeBreOp5          - subroutine in Powell
;       pro d_optimizeMnbOp5          - subroutine in Powell
;       pro d_optimizeF1DOp5          - subroutine in Powell
;       pro d_optimizeSign            - subroutine in Powell
;       pro d_optimizeLnSrch          - subroutine in Powell
;       pro d_optimizeGrad            - subroutine in Powell
;       pro d_optimizeEvent           - Event handler
;       pro d_optimizeCleanup         - Cleanup
;       pro d_optimize                - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       optimize.tip
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;             Numerical recipes in C, 2nd ed.
;             Press, Vetterling, Teukolsky, and Flannery
;             Cambridge University Press
;             ISBN 0-521-43108-5
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:  Written by: DAT,RSI, 1996
;
;-
;---------------------------------------------------------------------------
;
;  Purpose:  Returns the funciton value at point X
;
function d_optimizeFuncOp, $
    X, $           ; IN: data coordinates
    surfaceIndex   ; IN: surface index (1, 2, or 3)

    x[0] = double(x[0])
    x[1] = double(x[1])

    ;  Banana function.
    ;
    if (surfaceIndex EQ 1 ) then begin
        val = 100.0D0*(x[1]-x[0]*x[0])^2 + (1.0-x[0])^2
        RETURN, DOUBLE(val)
    endif

    if (surfaceIndex EQ 2 ) then begin
        RETURN, 3.0 * (1.0-x[0])^2 * EXP(-x[0]^2 - (x[1]+1.0)^2)            $
            -10.0 * (x[0]/5.0 - x[0]^3 - x[1]^5) * EXP(-x[0]^2 - x[1]^2) $
            -EXP(-(x[0]+1.0)^2 - x[1]^2)/3.0
    endif

    if (surfaceIndex EQ 3 ) then begin
        RETURN, DOUBLE( (x[0] + 2.0 *x[1] ) * exp(-x[0]^2 - x[1]^2) )
    endif

end  ; Of d_optimizeFuncOp


;---------------------------------------------------------------------------
;
;  Purpose: Returns the gradient value at point X
;
function d_optimizeGrad, $
    X, $          ; IN: data point
    surfaceindex  ; IN: surface index (1, 2, or 3).

    x[0] = double(x[0])
    x[1] = double(x[1])

    ;  Function # 1  : banana function.
    ;
    if (surfaceindex eq 1) then begin
         dzdx0= -400.0*x[0]*(x[1]-x[0]*x[0]) - 2*(1-x[0])
         dzdx1= 200.0*(x[1]-x[0]*x[0])
         RETURN, [double(dzdx0),double(dzdx1)]
    endif

    ;  Function # 2 .
    ;
    if (surfaceindex eq 2) then begin
        exp0 = exp(-x[0]^2 -(x[1]+1.0)^2)
        exp1 = exp(-x[0]^2 -x[1]^2)
        exp2 = exp(-(x[0]+1.0)^2 -x[1]^2)
        xy   = x[0]/5.0 - x[0]^3 - x[1]^5
        RETURN, DOUBLE( [-6.0*exp0*( x[0] * (1.0-x[0])^2 + (1.0-x[0]) ) $
           -10.0 * exp1 * (-2.0 * x[0] * xy + (0.2 - 3.0 * x[0]^2))  $
           +2.0 * (x[0] + 1.0) * exp2/3.0,                           $
           -6.0 * (x[1] + 1.0) * (1.0 - x[0])^2 * exp0               $
           -10.0 * exp1 * (-2.0 * x[1] * xy - (5.0 * x[1]^4))        $
            +2.0 * x[1] * exp2/3.0] )
    endif

    ;  Function # 3 .
    ;
    if (surfaceindex eq 3) then begin
        exp0 = DOUBLE( exp(-x[0]^2 - x[1]^2) )
        RETURN, DOUBLE([exp0 * (1.0 - 2.0*x[0]*x[0] - 4.0*x[0]*x[1] ),  $
            exp0 * (2.0 - 4.0*x[1]*x[1] - 2.0*x[0]*x[1] ) ] )
    endif

end                   ; Of d_optimizeGrad

;---------------------------------------------------------------------------
;
;  Purpose: Execure the line search.
;
pro d_optimizeLnSrch, $
    n, $                         ; IN: Dimension of the function
    xold, $                      ; IN: Old point coordinates
    fold, $                      ; IN: Old function value at x old
    g, $                         ; IN/OUT: Vector of lenght n+1,
                                 ;         where g(0) is the step limit,
                                 ;         9(1) to g(n) is the returned
                                 ;         gradient at point x
    p,  $                        ; OUT: Newton direction (dim = n+1)
    x, $                         ; OUT: New x  coordinates (dim = n+1),
                                 ;      x[0] contains the check flag.
    f, $                         ; OUT: Function value at point x
    Surfaceindex = surfaceindex  ; IN ; function index

    ;  Make variable as double types.
    ;
    xold = double(xold)
    fold = double(fold)
    g = double(g)

    ;  Initialize constants.
    ;
    stpmax = g[0]   ; Maximum number of steps
    check = x[0]    ; check flag is false (0) on normal exit
    tolx = 1.0D-7   ; convergence criterion on DELTA x
    alf = 1.0D-4    ; Ensures sufficient decrease in function x

    ;  Check for proper dimension on x.
    ;
    sizen = SIZE(xold)
    ns = sizen[1]
    if (ns NE (n+1)) then begin
        Message,'Error in d_optimizeLnSrch, dimension of xold  NE n'
    ENDIF

    check = 0.0D0
    x[0] = check
    p[0] = 0.0D0
    sum = 0.0D0
    sum = TOTAL(DOUBLE(p[1:n]*p[1:n]) )
    sum = SQRT(sum)

    ;  Scale in attempted step is too big.
    ;
    if (sum GT stpmax) then begin
        p[1:n] = DOUBLE(p[1:n]) * DOUBLE( stpmax)/sum
    endif

    slope = 0.0D0
    slope = TOTAL(double( g[1:n]*p[1:n] ))
    test = 0.0D0

    for i = 1,n do begin
        temp = ABS(p[i]) / MAX( [ABS(xold[i]), 1.0D0] )
        if (temp GT test) THEN test = temp
    endfor

    alamin = DOUBLE( tolx/test )
    alam = 1.0D0
    alam2 =0.0D0
    fold2 =0.0D0
    f2 = 0.0D0
    count =0
    dummy = 50

    ;  Start of iteration loop.
    ;
    while (dummy EQ 50 ) do begin
        count = count + 1
        x[1:n] = DOUBLE( xold[1:n] + alam*p[1:n] )
        f = DOUBLE(d_optimizeFuncOp(x[1:n],surfaceindex))

        if (alam LT alamin) then begin  ; if 1
            x[1:n] = DOUBLE( xold[1:n] )
            check = 1.0D0
            x[0] = 1.0D0
            RETURN
        endif else if (f LE (fold+alf*alam*slope)) then begin ; if 1
            RETURN
        endif else begin     ; if 1 still
            if ((alam EQ 1.0D0) ) then begin ; if 2
                tmplam = (-1.0D0*slope)/(2.0D0*(f-fold-slope))
            endif else begin ; if 2
                rhs1 = DOUBLE( f -fold-alam*slope )
                rhs2 = DOUBLE( f2-fold2-alam2*slope )
                alamp2 = DOUBLE( alam*alam )
                alam2p2 = DOUBLE( alam2 * alam2 )
                alamdi = DOUBLE( alam-alam2 )
                a = DOUBLE( ((rhs1/alamp2)-(rhs2/alam2p2))/alamdi )
                b = DOUBLE( ( (-1.0D0*alam2*rhs1/alamp2) + $
                    (alam*rhs2/alam2p2))/alamdi )

                if (a EQ 0.0D0) then begin ; if 3
                    tmplam =  -1.0D0*slope/(2.0D0*b)
                endif else begin ; if 3
                    disc = b*b-3.0D0*a*slope

                    if (disc LT 0.0D0) then begin ; if 4
                        Message, ' Roundoff problem in d_optimizeLnSrch'
                    endif else begin
                        tmplam = (-1.0D0*b + sqrt(disc))/(3.0D0*a)
                    endelse   ; end of if loop 4
                endelse   ; end of if loop 3

                if (tmplam GT 0.5D0*alam) THEN tmplam = 0.5D0*alam
            endelse   ; end of if loop 2
        endelse   ; end of if loop 1

        alam2 = DOUBLE(alam)
        f2 = DOUBLE( f )
        fold2 = DOUBLE( fold )
        alam = MAX( [tmplam, 0.1D0*alam])
    endwhile

end       ; of d_optimizeLnSrch procedure

;---------------------------------------------------------------------------
;
;  Purpose:  This function computes the minimum point of a function
;            using the Dorovan-fletcher-Powell algorithm.
;            The IDL equivalent is called DFPMIN. The difference is
;            that DFP returns the intermediary steps.
;            For details and comments see Numerical recipes in C 2nd ed.
;
pro d_optimizeDFP, $
    n, $                         ; IN: Dimension of the function
    p, $                         ; IN: Vector (n+1) containing the initial
    gtol, $                      ; IN: Limit of tolerance
    iter, $                      ; OUT: Number of iterations
    xtot, $                      ; OUT: Array ( iter+1, n+1)
                                 ;      that contains the data path.
    Surfaceindex                 ; IN ; function index

    ;  Initialize constants.
    ;
    itmax = 200               ; maximum number of iterations
    eps = 3.0D-7              ; machine precision
    tolx = double(4.0* eps)   ; Convergence criterion on x
    stpmx = double(100.0)     ; scaled max. step length allowed in d_optimizeLnSrch

    ;  Initialize working arrays.
    ;
    dg = DBLARR(n+1)
    g = DBLARR(n+1)
    pnew = DBLARR(n+1)
    hdg = DBLARR(n+1)
    hessin = DBLARR(n+1,n+1)
    xi = DBLARR(n+1)

    ;  Evaluate the function value at the starting point.
    ;
    fp = d_optimizeFuncOp(double(p[1:n]), surfaceindex)

    ;  Evaluate the function gradient at the starting point.
    ;
    g[1:n] = d_optimizeGrad(DOUBLE(p[1:n]), surfaceindex)

    xtot[0,0:1] =DOUBLE( p[1:2] )
    xtot[0,2] = DOUBLE(fp)

    ; Initialize the matrix hessin to the identity matrix
    ;
    hessin = hessin + DOUBLE(0.0)
    for i = 1, n do begin
        hessin[i,i] = DOUBLE(1.0)
    endfor

    sum = TOTAL(DOUBLE( p[1:n]*p[1:n] ) )
    xi[1:n] =  DOUBLE( -g[1:n] )
    stpmax = stpmx*MAX([DOUBLE(n),SQRT(sum)])

    ; Begin loop over max number of iterations
    ;
    for its=1, itmax do begin
        g[0] = DOUBLE(stpmax)
        xi[0] = DOUBLE(0.0)
        iter = its

        ;  Performs a line search by calling the function d_optimizeLnSrch.
        ;
        d_optimizeLnSrch,n,p,fp,g,xi,pnew,fret, Surfaceindex = surfaceindex

        xtot[its,0:1] = DOUBLE( pnew[1:2] )
        xtot[its,2] = DOUBLE(fret )
        check = DOUBLE( pnew[0] )
        fp = DOUBLE(fret)
        xi[1:n] = DOUBLE( pnew[1:n] - p[1:n] )
        p[1:n] = pnew[1:n]
        test = DOUBLE(0.0)

        for i = 1, n do begin
           temp = DOUBLE(ABS(xi[i]) / MAX( [ABS(p[i]),double(1.0)]))
           if (temp GT test) then test = temp
        endfor

        if (test LT tolx) then RETURN

        dg[1:n] = DOUBLE( g[1:n] )

        ;  Get the dradient at the new point.
        ;
        g[1:n] = d_optimizeGrad(DOUBLE( p[1:n]),surfaceindex)

        test = DOUBLE(0.0)
        den = MAX([DOUBLE(fret),1.0D0])

        for i = 1, n do begin
           temp = ABS(g[i])*MAX([ABS(p[i]),1.0D0])/den
           IF(temp GT test) THEN test = temp
        endfor

        ;  Return if test is smaller that the tolerance limit.
        ;
        if (test LT gtol) then RETURN

        dg[1:n] = double(  g[1:n] - dg[1:n] )
        hdg[1:n] = double( dg[1:n] - dg[1:n] )
        hdg[1:n] = double( dg[1:n] ## hessin[1:n,1:n] )

        ;  Initialize working variables.
        ;
        fac   = 0.0D0
        fae   = 0.0D0
        sumdg = 0.0D0
        sumxi = 0.0D0

        fac   = TOTAL( DOUBLE( dg[1:n] *xi[1:n] ))
        fae   = TOTAL(DOUBLE( dg[1:n] * hdg[1:n] ))
        sumdg = TOTAL( DOUBLE( dg[1:n]*dg[1:n] ))
        sumxi = TOTAL(DOUBLE( xi[1:n]*xi[1:n] ))

        if ((fac * fac) GT (eps*sumdg*sumxi) ) then begin
           fac = 1.0D0/fac
           fad = 1.0D0/fae
           dg[1:n] = fac*xi[1:n] - fad*hdg[1:n]
           hessin[1:n,1:n] = hessin[1:n,1:n] + $
           transpose(fac*xi[1:n]##xi[1:n] - $
           fad*hdg[1:n]##hdg[1:n] +fae*dg[1:n]##dg[1:n] )
        endif

        xi = double( xi-xi )
        hessint = double( -1.0D0*hessin )
        xi[1:n] = double( g[1:n] ## hessint[1:n,1:n] )

    ;  End of iteration loop.
    ;
    endfor

    ; If the function does not returns from inside the
    ; previous loop, then returns the message
    ;
    MESSAGE, ' Too many iterations in DFPMIN'

end                  ; Of DFP function

;---------------------------------------------------------------------------
;
;  Purpose: Compute the minimum of a function
;           using the POWELL algortihm.
;
pro d_optimizePoweop, $
    p, $                     ; IN/OUT: initial starting point
    xi, $                    ; IN: initial matrix (usually identity matrix)
    ftol, $                  ; IN: fractional tolerance
    iter, $                  ; OUT: number of iterations
    fret, $                  ; OUT; function value at minimum point (fret)
    path, $                  ; OUT: array containing the iteration steps.
    status, $                ; OUT: function status (0=failure, 1=success)
    SURFACEINDEX=surfaceindex; IN: Surface index (1, 2,or 3)

    ;  Get the dimension of the function.
    ;
    n = p[0]
    n = 2

    ;  Initialize working variables and arrays.
    ;
    ITMAX    = 200                  ; maximuim number of iterations allowed
    NMAX     = 21                   ; maximum dimension of the system.
    i        = 0                    ; integer
    ibig     = 0                    ; integer
    j        = 0                    ; integer
    del      = 0.0D0                ; DOUBLE precision
    fp       = 0.0D0                ; DOUBLE precision
    fptt     = 0.0D0                ; DOUBLE precision
    t        = 0.0D0                ; DOUBLE precision
    pt       = DBLARR(nmax)         ; array
    ptt      = DBLARR(nmax)         ; array
    xit      = DBLARR(nmax)         ; array
    status   = 1                    ; Status is Valid (OK)
    iter     = 1                    ; iteration number
    path     = DBLARR(itmax+1, n+1) ; array


    ;  Get the function value at point p.
    ;
    fret = DOUBLE(d_optimizeFuncOp(p[1:n], surfaceIndex) )

    ;  Initialize the vector path.
    ;
    path[0, 0:n-1 ] = p[1:n]
    path[0, n] = fret

    ;  Set pt to p. Save the initial point.
    ;
    pt[1:n] = DOUBLE( p[1:n] )

    ;  Loop over iteration.
    ;  Integer iter has already been set to one. It is
    ;  incremented at the end of the for loop.
    ;
    dummy = 0

    for iter = 1, ITMAX+1 do begin

        fp = DOUBLE( fret )
        ibig = 0
        del = 0.0D0       ; Will be the biggest function decrease

        ;  In each iteration, loop over all directions in the set.
        ;
        for i = 1, n  do begin

            ;  Copy the direction.
            ;
            xit[1:n] = DOUBLE( xi[ 1:n, i]  )
            fptt = DOUBLE(  fret )

            ;  Minimize along that direction.
            ;
            d_optimizeLinmOp, p, xit, n, fret, check, $
                SURFACEINDEX=surfaceIndex

            ;  Verify the check status of linmin.
            ;
            if (check EQ 0) then begin
                PRINT, ' Error in d_optimizeLinmOp NO 1 in d_optimizePoweop'
                RETURN
            endif

            ;  Augment the vector path.
            ;
            path[iter, 0:n-1] =DOUBLE( p[1:n] )
            path[iter, n] = DOUBLE( fret )

            ;  Record it and if it is the largest decrease so far.
            ;
            if (ABS(fptt - fret) GT del ) then begin
                del = DOUBLE( ABS( fptt - fret) )
                ibig = i
            endif

        endfor

        ;  Termination criterion.
        ;
        if ((2.0* (ABS(fp - fret)) ) LE $
            (ftol*(ABS(fp) + ABS(fret)) ) ) then begin
            status = 1  ; Valid
            RETURN
        endif

        if (iter  EQ ITMAX) then begin
            status = 0   ; NOT Valid
            PRINT, 'Number of iteration exceeds the limit in POWELM'
            RETURN
        endif

        ;  Construct the extrapolated point and the average
        ;  direction moved. Save the old starting point.
        ;
        ptt[1:n] = DOUBLE( 2.0 * p[1:n] - pt[1:n] )
        xit[1:n] = DOUBLE( p[1:n] - pt[1:n] )
        pt[1:n] = DOUBLE( p[1:n] )

        ;  Function value at extrapolated point.
        ;
        fptt = DOUBLE( d_optimizeFuncOp( ptt[1:n], surfaceIndex) )


        ;  Move to the minimum of the new direction,
        ;  and save the new direction.
        ;
        if (fptt LT fp) then begin
            square1 = DOUBLE(  (fp - fret - del) * (fp - fret - del) )
            square2 = DOUBLE( (fp - fptt) * (fp - fptt) )
            t = DOUBLE( 2.0*(fp - (2.0*fret) + fptt) * square1 - $
                del * square2 )
            if (t LT 0.0d) then begin
                d_optimizeLinmOp, p, xit, n, fret, check, $
                    SURFACEINDEX=surfaceIndex

                ;  Verify the check status of linmin.
                ;
                if (check EQ 0) then begin
                    PRINT, ' Error in d_optimizeLinmOp NO 2 in d_optimizePoweop'
                    RETURN
                endif

                ;  Augment or reset  the vector path.
                ;
                path[iter, 0:n-1] = p[1:n]
                path[iter, n] = DOUBLE( fret )
                xi[1:n, ibig] = DOUBLE( xi[ 1:n, n] )
                xi[1:n, n]    = DOUBLE( xit[1:n] )
            endif
        endif
    endfor

end   ; of POWELM.pro


;---------------------------------------------------------------------------
;
;  Purpose:  This function returns
;            absolute of arg1         if arg2 is positive
;            minus  absolute of arg1  if arg2 is less or equal to 0
;
function d_optimizeSign, $
    arg1, $       ; IN: argument 1
    arg2, $       ; IN: argument2
    STATUS=status ; OUT: 0 = failure, 1= success

    if (N_Elements(status) ) then begin
        status = 1
    endif

    nparam = N_Params()
    if (nparam NE 2) THEN BEGIN
        print, ' Error calling d_optimizeSign, must have 2 arguments'
        status = 0
        RETURN, double( arg1)
    endif

    if (arg2 GT 0.0) then begin
        RETURN, double( ABS(arg1) )
    endif else begin
        RETURN, double( -(ABS(arg1))  )
    endelse

end   ; of function d_optimizeSign



;---------------------------------------------------------------------------
;
;  Purpose: Returns the function value at the updated point.
;
function d_optimizeF1DOp5, $
    x , $                       ; IN: non updated point
    pcom, $                     ; IN: vector for updaing the point
    xicom, $                    ; IN: vector for updaing the point
    ncom, $                     ; IN: dimension of the function
    status, $                   ; OUT: status check flag.
    SURFACEINDEX=surfaceindex   ; IN: surface index

    ;  Check the validity of input parameters.
    ;
    nparam = N_Params()
    if (nparam NE 5) then begin
        PRINT, ' Error calling f1dim, must have 5 arguments'
        status = 0
        RETURN, x
    endif

    ;  Set status to valid.
    ;
    status = 1

    ;  Initialize variables.
    ;
    f  =  0.0D0            ; double precision
    xt =  dblarr(ncom+1)   ; double precision

    ;  Update the point.
    ;
    xt[1:ncom] = double( pcom[1:ncom] + x*xicom[1:ncom] )

    ;  Get the function value at point  xt.
    ;
    f = double( d_optimizeFuncOp( xt[1:ncom],surfaceindex ) )

    RETURN, f

end   ; of f1dim.pro



;---------------------------------------------------------------------------
;
;  Purpose: Isolate the minimum value.
;
function d_optimizeBreOp5, $
    ax, $                       ; IN: Inital abscissa
    bx, $                       ; IN: Inital abscissa
    cx, $                       ; IN: Inital abscissa
    tol, $                      ; IN: Limit of tolerance
    xmin, $                     ; OUT: Returned minimum
    status ,$                   ; OUT: 0 = Not valid for function BRENT
    Ppassed = pp, $             ; IN: Vector passed to BRENT
    Xipassed = xip, $           ; IN: Vector passed to BRENT
    Npassed = np, $             ; IN: Value  passed to BRENT
    SurfaceIndex=surfaceindex

    ;  Verify that p, n, and xi have been passed correctly.
    ;
    keywordp = N_Elements(pp)
    if (keywordp EQ 0 ) then begin
        PRINT, ' Error : p not passed to BRENT'
        status = 0
        RETURN, 0
    endif

    keywordn = N_Elements(np)
    if (keywordn EQ 0 ) then begin
        PRINT, ' Error : n not passed to BRENT'
        status = 0
        RETURN, 0
    endif

    keywordxi = N_Elements(xip)
    if (keywordxi EQ 0 ) then begin
        PRINT, ' Error : xi not passed to BRENT'
        status = 0
        RETURN, 0
    endif

    ;  Initialize working variables and arrays.
    ;
    itmax  = 100           ; maximum number of iterations
    cgold  = 0.381966D0   ; golden ratio
    zeps   = 1.0D-10       ; small number for numerical protection
    iter   = 0             ; iteration number
    a      = 0.0D0         ; DOUBLE precision
    b      = 0.0D0         ; DOUBLE precision
    d      = 0.0D0         ; DOUBLE precision
    etemp  = 0.0D0         ; DOUBLE precision
    fu     = 0.0D0         ; DOUBLE precision
    fv     = 0.0D0         ; DOUBLE precision
    fw     = 0.0D0         ; DOUBLE precision
    fx     = 0.0D0         ; DOUBLE precision
    p      = 0.0D0         ; DOUBLE precision
    q      = 0.0D0         ; DOUBLE precision
    r      = 0.0D0         ; DOUBLE precision
    tol1   = 0.0D0         ; DOUBLE precision
    tol2   = 0.0D0         ; DOUBLE precision
    u      = 0.0D0         ; DOUBLE precision
    v      = 0.0D0         ; DOUBLE precision
    w      = 0.0D0         ; DOUBLE precision
    x      = 0.0D0         ; DOUBLE precision
    xm     = 0.0D0         ; DOUBLE precision
    e      = 0.0D0         ; Distance moved on the step before last
    status = 1             ; Status is Valid (OK)

    if (ax LT cx) then a = ax else a = cx
    if (ax GT cx) then b = ax else b = cx

    x = DOUBLE(bx)
    w = DOUBLE(bx)
    v = DOUBLE(bx)

    ;  Call the function f1dim.pro  .
    ;
    fx =DOUBLE( d_optimizeF1DOp5(x, pp, xip, np , $
        checkF1dim, SURFACEINDEX=surfaceindex) )

    ;  Verify the check status of d_optimizeF1DOp5.
    ;
    if (checkF1dim EQ 0) then begin
        PRINT, ' error in F1dim function NO 1 (in BRENT)'
        status = 0
        RETURN, 0
    endif

    fv = DOUBLE(fx)
    fw = DOUBLE(fx)

    ;  Main loop program.
    ;
    for iter = 1, ITMAX do begin
        xm =  DOUBLE( 0.5*(a + b) )
        tol1 = DOUBLE( tol*ABS(x) + zeps )
        tol2 = DOUBLE( 2.0 * tol1 )

        ;  Test for done here.
        ;
        if (ABS( x - xm) LE ( tol2 - 0.5d*(b-a)) ) then begin
           xmin = x
           RETURN, fx
        endif

        ;  Construct a trial parabolic fit.
        ;
        if (ABS(e) GT tol1 ) then begin
            r = DOUBLE( (x - w) * (fx - fv) )
            q =  DOUBLE( (x - v) * (fx - fw) )
            p =  DOUBLE( (x - v)*q - (x - w)*r )
            q =  DOUBLE( 2.0d * (q - r) )
            if (q GT 0.0d) then p =  DOUBLE( -p )
            q = DOUBLE( ABS(q) )
            etemp = DOUBLE( e )
            e =  DOUBLE( d )

            ;  Check for the acceptability for the parabolic fit
            ;  otherwise, take the golden section step into the larger
            ;  of the 2 segments.
            if (( ABS(p) GE ABS(0.5d*q*etemp) ) OR $
                ( p LE q*(a - x) ) OR $
                ( p GE q*(b - x) ) ) then begin

                if (x GE xm ) then begin
                    e = DOUBLE(a - x)
                endif else begin
                    e = DOUBLE(b - x)
                endelse

                d = DOUBLE( cgold * e )

            endif else begin

                d = DOUBLE( p/q )
                u = DOUBLE( x + d )
                if (( (u-a) LT tol2 ) OR ( (b - u) LT tol2 ) ) then begin
                    d = DOUBLE( d_optimizeSign(tol1, (xm - x), Status = status ) )
                    if (status EQ 0) then begin
                        print, ' error in d_optimizeSign function NO 1 (in BRENT)'
                        RETURN, 0
                    endif
                endif
            endelse
        endif else begin

            if (x GE xm ) then begin
                e = DOUBLE(a - x)
            endif else begin
                e = DOUBLE(b - x)
            endelse

            d = DOUBLE( cgold * e )
        endelse

        if (ABS(d) GE tol1) then begin
            u =  DOUBLE( x+d)
        endif else begin
            u = x + d_optimizeSign( tol1, d, Status = status)
            if (status EQ 0) then begin
               print, ' error in d_optimizeSign function NO 2 (in BRENT)'
               RETURN, 0
            endif
        endelse

        ;
        fu = d_optimizeF1DOp5(u, pp, xip, np , $
            checkF1dim, SURFACEINDEX=surfaceindex)

        ;  Verify the check status of d_optimizeF1DOp5.
        ;
        if (checkF1dim EQ 0) then begin
            PRINT, ' error in d_optimizeF1DOp5 function NO 2 (in BRENT)'
            status = 0
            RETURN, 0
        endif

        ;  This is the one function evaluation per iteration.
        ;
        if ( fu LE fx) then begin
            if (u GE x ) then  a = DOUBLE(x)  else b=DOUBLE(x)
            v = w
            w = x
            x = u
            fv = fw
            fw = fx
            fx = fu
        endif else begin

            if (u LT x) then a=u else b=u

            if ((fu LE fw) OR (w EQ x) ) then begin
                v  =  DOUBLE(w)
                w  = DOUBLE(u)
                fv = DOUBLE(fw)
                fw = DOUBLE(fu)
            endif else if ( (fu LE fv) OR (v EQ x) OR (v EQ w) )then begin
                v  = DOUBLE(u)
                fv = DOUBLE(fu)
            endif
        endelse

    endfor  ; end of the main loop

    ;  If the program reaches here,
    ;  then the number of iteration is too high.
    ;
    status = 0
    PRINT, ' Error in BRENT, too many iterations'
    RETURN, 0

end ; of d_optimizeBreOp5

;---------------------------------------------------------------------------
;
;  Purpose:  This function searches in the downhill direction,
;            and returns the new points ax, bx, cx (as parametrs) that bracket
;            a minimum of the function d_optimizeF1DOp5. The status is returned
;            as value by the function.
;
function d_optimizeMnbOp5, $
    ax, $                       ; IN/OUT: initial/final point
    bx, $                       ; IN/OUT: initial/final point
    cx, $                       ; OUT: final point
    fa, $                       ; OUT: value function at ax
    fb, $                       ; OUT: value function at bx
    fc, $                       ; OUT: value function at cx
    PPASSED = pp, $             ; IN: parameter used by d_optimizeF1DOp5
    XIPASSED = xip, $           ; IN: parameter used by d_optimizeF1DOp5
    NPASSED = np, $             ; IN: parameter used by d_optimizeF1DOp5
    SURFACEINDEX = surfaceIndex ; IN: surface index (1, 2, or 3)

    ;  Verify that pp, np, and xip have been passed.
    ;
    keywordp = N_ELEMENTS(pp)
    if (keywordp EQ 0 ) then begin
        PRINT, ' Error in d_optimizeMNBOP5 : p not passed to d_optimizeMnbOp5'
        status = 0
        RETURN, status
    endif

    keywordn = N_ELEMENTS(np)
    if (keywordn EQ 0 ) then begin
        PRINT, ' Error in d_optimizeMnbOp5 : n not passed to d_optimizeMnbOp5'
        status = 0
        RETURN, 0
    endif

    keywordxi = N_ELEMENTS(xip)
    if (keywordxi EQ 0 ) then begin
        PRINT, ' Error in d_optimzeMnbOp5 : xi not passed to d_optimzeMnbOp5'
        status = 0
        RETURN, 0
    endif

    ;  Initialize working variables and arrays.
    ;
    gold   = 1.618034d     ; default ratio
    glimit = 100.0D0       ; max. magnification for parabolic-fit step
    tiny   = 1.0D-20       ; double precision
    ulim   = 0.0D0         ; double precision
    u      = 0.0D0         ; double precision
    r      = 0.0D0         ; double precision
    q      = 0.0D0         ; double precision
    fu     = 0.0D0         ; double precision
    dum    = 0.0D0         ; double precision
    status = 1             ; Status is Valid (OK)

    ;  Call the function d_optimizeF1DOp5 twice .
    ;
    fa = d_optimizeF1DOp5(ax, pp, xip, np , checkF1dim, SURFACEINDEX=surfaceindex)

    ;  Verify the check status of d_optimizeF1DOp5.
    ;
    if (checkF1dim EQ 0) then begin
        PRINT, ' error in d_optimizeF1DOp5 function NO 1 (in d_optimizeMnbOp5)'
        status = 0
        RETURN, 0
    endif

    fb = d_optimizeF1DOp5(bx, pp, xip, np , checkF1dim, SURFACEINDEX=surfaceindex)

    ;  Verify the check status of f1dim.
    ;
    if (checkF1dim EQ 0) then begin
        PRINT, ' error in d_optimizeF1DOp5 function NO 2 (in d_optimizeMnbOp5)'
        status = 0
        RETURN, 0
    endif


    ;  Switch roles of a and b so that we can go
    ;  downhill in the direction for a to b.
    ;
    if (fb GT fa) then begin
        dum = ax
        ax = bx
        bx = dum
        dum = fb
        fb = fa
        fa = dum
    endif


    ;  First guess for c.
    ;
    cx = DOUBLE( bx + gold*(bx - ax) )

    fc = d_optimizeF1DOp5(cx, pp, xip, np , checkF1dim, SURFACEINDEX=surfaceindex)

    ;  Verify the check status of d_optimizeF1DOp5.
    ;
    if (checkF1dim EQ 0) then begin
        PRINT, ' error in F1dim function NO 3 (in d_optimizeMnbOp5)'
        status = 0
        RETURN, 0
    endif


    ;  Keep returning here until we bracket.
    ;
    while (fb GT fc) do begin

        ;  Compute u by parabolic extrapolation from a,b,c.
        ;  Tiny is used to prevent any possible division by zero.
        ;
        r = DOUBLE( (bx - ax) * (fb - fc) )
        q = DOUBLE( (bx - cx) * (fb - fa) )
        valueFmax =  DOUBLE( MAX( ABS(q-r), tiny) )
        valueSign = d_optimizeSign( valueFmax,  (q-r), STATUS=status)
        if (status eq 0) then begin
            PRINT, ' Error calling d_optimizeSign (in d_optimzeMnbOp5)'
            RETURN, 0
        endif

        u = DOUBLE( bx - ( (bx-cx)*q - (bx-ax)*r ) / $
            (2.0 * valueSign ) )

        ulim =  DOUBLE( bx + glimit*(cx - bx) )

        ;  Test various possibility.
        ;
        if (((bx - u)*(u - cx)) GT 0.0 )  then begin

            fu = d_optimizeF1DOp5(u, pp, xip, np ,checkF1dim, $
                SURFACEINDEX=surfaceindex)

            ;  Verify the check status of f1dim.
            ;
            if (checkF1dim EQ 0) then begin
               PRINT, ' error in d_optimizeF1DOp5 function NO 4 (in d_optimizeMnbOp5)'
               status = 0
               RETURN, 0
            endif

            ;  Got a minimum between b and c.
            ;
            if (fu LT fc) then begin
                ax =  DOUBLE( bx )
                bx =  DOUBLE( u )
                fa =  DOUBLE( fb )
                fb =  DOUBLE( fu )
                RETURN, 1   ; status should be 1 (ok) here

            ;  Got a minimum between a and u.
            ;
            endif else if (fu GT fb) then begin
                cx = DOUBLE( u )
                fc = DOUBLE( fu )
                RETURN, 1   ; status should be 1 (ok) here
            endif

            ;  Parabolic fit was no use, Use default magnification.
            ;
            u =  double( cx + gold*(cx - bx) )

            fu = d_optimizeF1DOp5(u, pp, xip, np ,checkF1dim, $
                SURFACEINDEX=surfaceindex)

            ;  Verify the check status of f1dim.
            ;
            if (checkF1dim EQ 0) then begin
                PRINT, ' error in d_optimizeF1DOp5 function NO 5 (in d_optimizeMnbOp5)'
                status = 0
                RETURN, 0
            endif

        ; Parabolic fit is between c and its allowed limit.
        ;
        endif else if (((cx - u)*( u - ulim)) GT 0.0) then begin

            fu = d_optimizeF1DOp5(u, pp, xip, np ,checkF1dim, $
                SURFACEINDEX=surfaceindex)

            ;  Verify the check status of f1dim.
            ;
            if (checkF1dim EQ 0) then begin
                PRINT, ' error in d_optimizeF1DOp5 function NO 6 (in d_optimizeMnbOp5)'
                status = 0
                RETURN, 0
            endif

            if (fu LT fc) then begin
                arg4 = cx+gold*(cx-bx)
                bx = cx
                cx = u
                u = arg4
                fut = d_optimizeF1DOp5(u, pp, xip, np , checkF1dim, $
                    SURFACEINDEX=surfaceindex)

                if (checkF1dim EQ 0) then begin
                    PRINT, ' error in d_optimizeF1DOp5 function NO 7 (in d_optimizeMnbOp5)'
                    status = 0
                    RETURN, 0
                endif

                fb = fc
                fc = fu
                fu = fut
            endif

        ;  Limit parabolic u to maximum allowed limit.
        ;
        endif else if (( u - ulim)*(ulim - cx) GE 0.0) then begin
            u = DOUBLE( ulim )

            fu = d_optimizeF1DOp5(u, pp, xip, np , checkF1dim, $
                SURFACEINDEX=surfaceindex)

            ;  Verify the check status of f1dim.
            ;
            if (checkF1dim EQ 0) then begin
                PRINT, ' error in F1dim function NO 8 (in d_optimizeMnbOp5)'
                status = 0
                RETURN, 0
             endif

        ;  Reject parabolic u, use default magnification.
        ;
        endif else begin
            u =  double( cx + gold*(cx - bx) )

            fu = d_optimizeF1DOp5(u, pp, xip, np , checkF1dim, $
                SURFACEINDEX=surfaceindex)

            ;  Verify the check status of f1dim.
            ;
            if (checkF1dim EQ 0) then begin
                PRINT, ' error in F1dim function NO 9 (in d_optimizeMnbOp5)'
                status = 0
                RETURN, 0
             endif
        endelse

        ;  Eliminate oldest point and continue.
        ;
        ax = bx
        bx = cx
        cx = u
        fa = fb
        fb = fc
        fc = fu
    endwhile

    RETURN, status

end  ; of mnbrak.pro

pro d_optimizeLinmOp, p, xi, n , fret, status,SurfaceIndex = surfaceindex
;
; TAKEN from Numerical Recipes in C (2nd ed.).
;
; This procedure finds the minimum point along the
; direction xi and passing by the point p
;
; INPUT
;      xi             :   inital direction ( dim : n, xi(1) to xi(n)  )
;      n              :   The dimension of the surface minus
;                          one. Example : the surface z = 3 x + 6y +2.5
;                         (which is a plane) has n = 2 .
; surfaceindex :   index that indicates the selected surface (1,2,3)
;
; INPUT/OUTPUT
;      p          :   Initial starting point stored in
;                     p(1) to p(n).
;                     The returned value is the
;                     location of the function minimum along the direction
;                     given by xi
; OUTPUT
;      fret         :   value of the function at point p (minimum)
;      status     :   0 = Not valid
;
;


    ;  Initialize working variables and arrays.
    ;
    tol    = 2.0D-6        ; tolerance passed to BRENT.pro
    xx     = 1.0D0         ; double precision
    xmin   = 0.0D0         ; double precision
    fx     = 0.0D0         ; double precision
    fb     = 0.0D0         ; double precision
    fa     = 0.0D0         ; double precision
    bx     = 0.0D0         ; double precision
    ax     = 0.0D0         ; double precision
    status = 1             ; Status is Valid (OK)

    psaved1 = double(p)
    psaved2 = double( p )
    xisaved1 = double( xi )
    xisaved2 = double( xi )
    nsaved1 = double( n)
    nsaved2 = double( n )

    ;  Call the function MNBRAK.pro .
    ;  IMPORTANT NOTE : p,xi and n MUST be passed,
    ;  otherwise an error will be issued.
    ;
    checkMnbrak = d_optimizeMnbOp5(ax, xx, bx, fa, fx, fb, $
        Ppassed = psaved1, Xipassed = xisaved1, Npassed = nsaved1, $
        SurfaceIndex = surfaceindex)

    ;  Verify the check status of MNBRAK.
    ;
    if (checkMnbrak EQ 0) then begin
        print, ' error in MNBRAK NO 1 in LINMIN.pro'
        status = 0
        RETURN
    endif

    ;  Call the function BRENT.pro.
    ;  IMPORTANT NOTE : p,xi and n MUST be passed,
    ;  Otherwise an error will be issued.
    ;
    fret = double( d_optimizeBreOp5(ax, xx, bx, tol, xmin, checkBrent, $
        Ppassed = psaved2, Xipassed = xisaved2, Npassed = nsaved2, $
        SurfaceIndex = surfaceindex) )

    ;  Verify the check status of  BRENT.PRO.
    ;
    if (checkBrent EQ 0) then begin
        print, ' error in BRENT NO 1 in LINMIN.pro'
        status = 0
        RETURN
    endif

    ;  Construct the vector results to return.
    ;
    xi[1:n] = double( xi[1:n]* xmin )
    p[1:n] = double( p[1:n] + xi[1:n])

end  ; of LINMIN



;---------------------------------------------------------------------------
;
;  Purpose:   Initialize 16 working (predefined) colors.
;
pro d_optimizeInit16colors, $
    colornames  ; IN: color anmes array

    TVLCT, 255, 255, 255, colornames[0]     ; white
    TVLCT, 255, 255,   0, colornames[1]     ; yellow
    TVLCT, 200, 180, 255, colornames[2]     ; lavender
    TVLCT,  80, 255, 255, colornames[3]     ; aqua
    TVLCT, 255, 100, 150, colornames[4]     ; pink
    TVLCT,  55, 255,  55, colornames[5]     ; green
    TVLCT, 255,  30,  30, colornames[6]     ; red
    TVLCT, 255, 180,  80, colornames[7]     ; orange
    TVLCT,  80,  80, 255, colornames[8]     ; blue
    TVLCT, 180, 180, 180, colornames[9]     ; lt_gray
    TVLCT,  55, 130, 100, colornames[10]    ; med_green
    TVLCT,  80,  30,  30, colornames[11]    ; brown
    TVLCT,  55,  55,   0, colornames[12]    ; olive
    TVLCT, 100,  30,  80, colornames[13]    ; purple
    TVLCT,  55,  55,  55, colornames[14]    ; dk_gray
    TVLCT,   0,   0,   0, colornames[15]    ; black

end  ; of d_optimizeinit16colors

; -----------------------------------------------------------------------------
;
;  Purpose:  This procedure initialize the starting points
;            (4 points per surface, 3 surfaces, total 12 points).
;
pro d_optimizeInitPoint, $
    startpoints   ; OUT: start points locations.

    point = dblarr(2)        ; working array
    i = 1                    ; surface index

    point  = [ -1.8d, 2.0d ]
    startpoints[i,1, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ -1.0d, 1.9d ]
    startpoints[i,2, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ 0.0d, 1.9d ]
    startpoints[i,3, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ 1.0d, 2.0d ]
    startpoints[i,4, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    i = 2

    point  = [ -1.6d, 1.0d ]
    startpoints[i,1, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ -0.7d, 0.7d ]
    startpoints[i,2, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ 0.75d, -0.875d ]
    startpoints[i,3, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ 1.375d, -1.8d ]
    startpoints[i,4, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    i = 3

    point  = [ -0.9d, 0.7d ]
    startpoints[i,1, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ -0.2d, 0.5d ]
    startpoints[i,2, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ 0.2d, -0.2d ]
    startpoints[i,3, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

    point  = [ 0.6d, -0.5d ]
    startpoints[i,4, 1:3] = [point[0], point[1], $
       d_optimizeFuncOp(point[0:1],i) ]

end  ; of INITPOINTS

; -----------------------------------------------------------------------------
;
;  Purpose:  This procedure resets the starting points.
;
pro d_optimizeResetPoint, $
    event,  $     ; IN: event structure.
    pointIndex    ; IN: point index

    ;  Get the info structure.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    info.pointindex = pointindex

    ;  Reset the results labels.
    ;
    d_optimizeResetResult, info.ResultLBLx,info.ResultLBLy, $
        info.ResultLBLz,info.ResultLBLi

    if (info.surfaceIndex EQ 1) then begin
        saved3Dt = info.saved3d1
        pix = info.pixmap1ID
    endif else if (info.surfaceIndex EQ 2) then begin
        saved3Dt = info.saved3d2
        pix = info.pixmap2ID
    endif else begin
        saved3Dt = info.saved3d3
        pix = info.pixmap3ID
    endelse

    ;  Desensitize all the points buttons.
    ;
    WIDGET_CONTROL, info.Point1ID, SENSITIVE=0
    WIDGET_CONTROL, info.Point2ID, SENSITIVE=0
    WIDGET_CONTROL, info.Point3ID, SENSITIVE=0
    WIDGET_CONTROL, info.Point4ID, SENSITIVE=0

    ;  Redraw the surface from the pixmap.
    ;
    WSET, info.drawWinID
    Device, Copy=[ 0,0,info.drawxsize, $
        info.drawysize, 0,0, pix]

    ;  Plot all the points.
    ;
    d_optimizePlotPoint, info.surfaceIndex, pointindex, $
        info.charscale,info.red, $
        saved3dt, info.startPoints,  $
        info.startPointsdev, info.fontflag

    ;  Sensitize the appropriate buttons
    ; and change the information text label.
    ;
    WIDGET_CONTROL, info.startbuttonID, SENSITIVE=1
    WIDGET_CONTROL, info.surface1ID, SENSITIVE=1
    WIDGET_CONTROL, info.surface2ID, SENSITIVE=1
    WIDGET_CONTROL, info.surface3ID, SENSITIVE=1
    WIDGET_CONTROL, info.StartButtonID, SENSITIVE=1
    WIDGET_CONTROL, info.FindButton, SENSITIVE=1

    if (pointindex EQ 1) then begin
        WIDGET_CONTROL, info.Point1ID, SENSITIVE=0
        WIDGET_CONTROL, info.Point2ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point3ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point4ID, SENSITIVE=1
    endif else if (pointindex EQ 2) then begin
        WIDGET_CONTROL, info.Point1ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point2ID, SENSITIVE=0
        WIDGET_CONTROL, info.Point3ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point4ID, SENSITIVE=1
    endif else if (pointindex EQ 3) then begin
        WIDGET_CONTROL, info.Point1ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point2ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point3ID, SENSITIVE=0
        WIDGET_CONTROL, info.Point4ID, SENSITIVE=1
    endif else begin
        WIDGET_CONTROL, info.Point1ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point2ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point3ID, SENSITIVE=1
        WIDGET_CONTROL, info.Point4ID, SENSITIVE=0
    endelse

    ;  Add the annotation string on top of the points.
    ;
    d_optimizeShowStart, info.surfaceIndex, pointindex, $
        info.StartPoints, info.StartLBL

    ;  Restore the info structure.
    ;
    WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

end  ; d_optimizeResetPoint

; -----------------------------------------------------------------------------
;
;  Purpose:   Redraw the appropriate surface.
;
pro d_optimizeResetSurface, $
    event, $       ; IN: event structure
    surfaceindex   ; IN: surface index (1,2, or 3)

    ;  Get the info structure.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  Desensitize all the surface buttons.
    ;
    WIDGET_CONTROL, info.surface1ID, sensitive = 0
    WIDGET_CONTROL, info.surface2ID, sensitive = 0
    WIDGET_CONTROL, info.surface3ID, sensitive = 0

    ;  Reset the results labels.
    ;
    d_optimizeResetResult, info.ResultLBLx,info.ResultLBLy, $
        info.ResultLBLz,info.ResultLBLi

    info.surfaceIndex = surfaceindex
    info.pointIndex = 0
    WSET, info.drawWinID

    ;  Reset the data system coordinates to the appropriate
    ;  surface by creating an empty plot....
    ;
    if (surfaceindex EQ 1) then begin
        pix = info.pixmap1ID
        saved3dt = info.saved3d1
        SURFACE, info.zdata1, info.xdata1, $
            info.ydata1,/nodata,  $
            AZ=10, AX=60, $
            XSTYLE=4, YSTYLE=4, ZSTYLE=4, $
            POSITION=[0.1, 0.20, 0.95, 1.]
    endif else if (surfaceindex EQ 2) then begin
        pix = info.pixmap2ID
        saved3dt = info.saved3d2
        SURFACE, info.zdata2, info.xdata2, $
            info.ydata2,  /nodata, $
            AZ=30, AX=30,$
            XRANGE=[-2,2], $
            YRANGE=[-2,2], $
            ZRANGE=[-7,7],$
            XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
            POSITION=[0.05, 0.05, 0.95, 1.]
    endif else begin
        pix = info.pixmap3ID
        saved3dt = info.saved3d3
        SURFACE, info.zdata3, info.xdata3,$
            info.ydata3, /SAVE,/NODATA, $
            AZ=30,AX= 30, $
            XRANGE=[-1,1], $
            YRANGE=[-1,1], $
            ZRANGE=[-1,1],$
            XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
            POSITION=[0.05, 0.05, 0.95, 1.]
    endelse

    ;  Copy the selected surface from
    ;  the pixmap into the drawing window.
    ;
    DEVICE, COPY=[0, 0, info.drawxsize, $
        info.drawysize, 0, 0, pix]

    ;  Plot the starting points.
    ;
    d_optimizePlotPoint, surfaceindex, 1, info.charscale,info.red, $
        saved3dt, info.startPoints, $
        info.startPointsdev, info.fontflag,  /ALL

    ;  Sensitize the appropriate buttons
    ;  and reset the starting point and information labels.
    ;
    WIDGET_CONTROL, info.startbuttonID, SENSITIVE=1
    WIDGET_CONTROL, info.StartButtonID, SENSITIVE=1
    WIDGET_CONTROL, info.Point1ID, SENSITIVE=1
    WIDGET_CONTROL, info.Point2ID, SENSITIVE=1
    WIDGET_CONTROL, info.Point3ID, SENSITIVE=1
    WIDGET_CONTROL, info.Point4ID, SENSITIVE=1
    WIDGET_CONTROL, info.FindButton, SENSITIVE=0
    WIDGET_CONTROL, info.StartLBL, $
        Set_Value = 'X = ---  Y = ---'

    strings = '  Select another surface or a starting point'

    if (surfaceindex EQ 1) then begin
        WIDGET_CONTROL, info.surface2ID, SENSITIVE=1
        WIDGET_CONTROL, info.surface3ID, SENSITIVE=1
    endif else if( surfaceindex EQ 2) then begin
        WIDGET_CONTROL, info.surface1ID, SENSITIVE=1
        WIDGET_CONTROL, info.surface3ID, SENSITIVE=1
    endif else if( surfaceindex EQ 3) then begin
        WIDGET_CONTROL, info.surface1ID, SENSITIVE=1
        WIDGET_CONTROL, info.surface2ID, SENSITIVE=1
    endif

    ;  Restore the info structure.
    ;
    WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

end ; of RESETSURFACE


; -----------------------------------------------------------------------------
;
;  Purpose:   This procedure open a text window and display
;             the text file.
;
pro d_optimizeAbout, $
    group_leader    ;  IN: group leader identifer

    ONLINE_HELP, 'd_optimize', $
       book=demo_filepath("idldemo.adp", $
               SUBDIR=['examples','demo','demohelp']), $
               /FULL_PATH

end   ; of d_optimizeAbout

; -----------------------------------------------------------------------------
;
;  Purpose:   Reset the result labels.
;
pro d_optimizeResetResult, $
    LabeLxID, $    ; IN: x label
    LabeLyID, $    ; IN: y label
    LabeLzID, $    ; IN: z label
    LabeLiID       ; IN: iteration label

    ; Reset the result labels
    ;
    WIDGET_CONTROL, LabeLxID, $
        SET_VALUE= 'X =        -----    -----'
    WIDGET_CONTROL, LabeLyID, $
        SET_VALUE= 'Y =        -----    -----'
    WIDGET_CONTROL, LabeLzID, $
        SET_VALUE= 'Z =        -----    -----'
    WIDGET_CONTROL, LabeLiID, $
        SET_VALUE= '#STEPS =   --       --'

end  ; of d_optimizeResetResult

; -----------------------------------------------------------------------------
;
;  Purpose: Shows the value of the selected starting point in
;           the starting point label.
;
PRO d_optimizeShowStart, $
    surfaceIndex, $   ; IN: surface index
    pointIndex, $     ; IN: point index
    startPoints, $    ; IN: starting points array
    StartLBL          ; IN: start label identifier

    ;  Shows the value of the selected starting point in
    ;  the starting point label.
    ;
    xval = StartPoints[surfaceIndex, pointIndex, 1]
    yval = StartPoints[surfaceIndex, pointIndex, 2]
    xs = STRING(xval, FORMAT='(f6.1)')
    xs = STRTRIM(xs,2)
    ys = STRING(yval, FORMAT='(f6.1)')
    ys = STRTRIM(ys,2)
    stringh ='X = ' + xs +'   Y = ' + ys
    WIDGET_CONTROL, StartLBL, SET_VALUE=stringh

END  ; d_optimizeShowStart

; -----------------------------------------------------------------------------
;
;  Purpose:  This porcedure plots the starting points
;            either the  selected one  or all of them.
;
pro d_optimizePlotPoint, $
    surfaceIndex, $     ; IN: surface index
    pointnumber, $      ; IN: point index
    charscale, $        ; IN: character scaling factor
    red, $              ; IN: red color index in color table
    saved3dIndex, $     ; IN: 3-D transformation matrix
    startPoints, $      ; IN: start points (data coordinates)
    startPointsdev, $   ; IN: start points (device coordinates)
    fontFlag, $         ; IN: font( 0 = hardware, 1 = user selection)
    All=all             ; IN: (opt) plot all the point

    !P.T = 0
    si = surfaceIndex

    ; If all of the points
    ;
    if (N_Elements(all) EQ 1) then begin
        init =1
        final = 4
    endif else begin
        init = pointNumber
        final = pointNumber
    endelse


    for i = init, final do begin
        if (i EQ 1) then begin
            if (fontFlag EQ 0 ) then begin
                string ='!51!x'
            endif else begin
                string = '1'
            endelse
        endif else if (i EQ 2) then begin
            if (fontFlag EQ 0 ) then begin
                string ='!52!x'
            endif else begin
                string ='2'
            endelse
        endif else if (i EQ 3) then begin
            if (fontFlag EQ 0 ) then begin
                string ='!53!x'
            endif else begin
                string ='3'
            endelse
        endif else begin
            if (fontFlag EQ 0 ) then begin
                string ='!54!x'
            endif else begin
                string ='4'
            endelse
        endelse

        ;  Plot the point annotations (P1, P2, etc...).
        ;
        if (fontFlag EQ 1) then begin
            !P.FONT = 0
            DEVICE, FONT="TIMES*24"
        endif

        XYOUTS, startPointsdev[si,i,1], startPointsdev[si,i,2]+10, $
            string, COLOR=red, CHARSIZE=2.*charScale, $
            /DEVICE, ALIGNMENT=0.5

        if (fontFlag EQ 1) then begin
            DEVICE, FONT="TIMES*8"
            !P.FONT = -1
        endif

        ;  Set he 3-D transformation matrix.
        ;
        !P.T = saved3dIndex

        ;  Plot the point symbols.
        ;
        PLOTS, $
            [startPoints[si,i,1], startPoints[si,i,1], $
                startPoints[si,i,1]], $
            [startPoints[si,i,2], startPoints[si,i,2], $
                startPoints[si,i,2]], $
            [startPoints[si,i,3], startPoints[si,i,3], $
                startPoints[si,i,3]], $
            PSYM=1, /Z, COLOR=red, THICK=2.6*charScale, /T3D
    endfor


    ;  Reset the 3d transformation.
    ;
    !P.T = 0

end  ; of d_optimizePlotPoint

; -----------------------------------------------------------------------------
;
;  Purpose:  Main event handler.
;
pro d_optimizeEvent, $
    event      ; IN: event structure

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(event, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, event.top, /DESTROY
        RETURN
    endif


    ;  Get the info structure.
    ;
    WIDGET_CONTROL, event.top, GET_UVALUE=info, /NO_COPY

    ;  Get the button identifier value.
    ;
    WIDGET_CONTROL, event.id, GET_VALUE=buttonValue

    ;  Branch to the appropriate button.
    ;
    case buttonValue of

        'Surface 1' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetSurface, event, 1
        end  ; of  Surface 1

        'Surface 2' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetSurface, event, 2
        end  ; of  Surface 2

        'Surface 3' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetSurface, event, 3
        end  ; of  Surface 3

        'Reset Surface' : begin
            surfaceIndex = info.surfaceIndex
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetSurface, event, surfaceIndex
        end  ; of  reset surface

        'Point 1' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetPoint, event, 1
        end  ; of Point 1

        'Point 2' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetPoint, event, 2
        end  ; of Point 2

        'Point 3' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetPoint, event, 3
        end  ; of Point 3

        'Point 4' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            d_optimizeResetPoint, event, 4
        end  ; of Point 4

        'Quit' :  begin
            WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY
            WIDGET_CONTROL, event.top, /DESTROY
        end   ;  of Quit

        'Find Minimum' : begin

             ;  Sensitize (desensitize) the appropeiate buttons
             ;  And reset the information label.
             ;
             WIDGET_CONTROL, info.StartButtonID, SENSITIVE=0
             WIDGET_CONTROL, info.SurfaceButtonID, SENSITIVE=0
             WIDGET_CONTROL, info.wResetButton, SENSITIVE=0
             WIDGET_CONTROL, info.findButton, SENSITIVE=0
             WIDGET_CONTROL, info.QuitButton, SENSITIVE=0
             WIDGET_CONTROL, info.AboutButtonID, SENSITIVE=0

             ;  Initialize variable for the DFP function call.
             ;
             itmax = 200                 ; Maximum number of iterations
             gtol = double(1.0D-7)       ; Limit of tolerance
             xtot = DBLARR(itmax+1,3)    ; Array that contains all the points
             n = 2                       ; Dimension of the banana function
             pin = dblarr(3)
             pin = [0.0, 0.0, 2.5]       ; Initial starting point (p(0) = 0.0)
             pin[1] = info.startpoints[info.surfaceIndex,$
                 info.pointIndex,1]
             pin[2] = info.startpoints[info.surfaceIndex, $
                 info.pointIndex,2]
             iter = 0

             ;  Computes the data points (path).
             ;
             d_optimizeDFP, n, pin, gtol, iter, xtot, info.surfaceIndex

             ;  Put the data path (contained in xtot) within 3 vectors.
             ;
             xvec = DBLARR(iter+1)
             yvec = DBLARR(iter+1)
             zvec = DBLARR(iter+1)
             xvec[0:iter] = xtot[0:iter,0]
             yvec[0:iter] = xtot[0:iter,1]
             zvec[0:iter] = xtot[0:iter,2]

             ;  Compute the path with the Powell algorithm.
             ;
             ;  Initialize variables for the Powell function call.
             ;
             itmax = 200                 ; Maximum number of iterations
             gtol = double(1.0D-7)       ; Limit of tolerance
             xtot = DBLARR(itmax+1,3)    ; Array that contains all the points
             n = 2                       ; Dimension of the banana function
             pin = dblarr(3)
             pin = [0.0, 0.0, 2.5]       ; Initial starting point (p(0) = 0.0)
             pin[0] = 2
             pin[1] = info.startpoints[info.surfaceIndex,$
                info.pointIndex,1]
             pin[2] = info.startpoints[info.surfaceIndex, $
                info.pointIndex,2]
             ftol = 1.0d-7
             xi = dblarr(3,3)
             xi = xi - xi
             xi[0,0] = 1.0d
             xi[1,1] = 1.0d
             xi[2,2] = 1.0d

             ;  Find the minimum using the POWELL algrithm.
             ;
             d_optimizePoweop, pin, xi, ftol, $
                iterpo, fretpo,  pathpo, $
                statuspo, Surfaceindex = info.surfaceindex


             ;  Put the data path (contained in pathpo) within 3 vectors.
             ;
             xvecpo = DBLARR(iterpo+1)
             yvecpo = DBLARR(iterpo+1)
             zvecpo = DBLARR(iterpo+1)
             xvecpo[0:iterpo] = pathpo[0:iterpo,0]
             yvecpo[0:iterpo] = pathpo[0:iterpo,1]
             zvecpo[0:iterpo] = pathpo[0:iterpo,2]

             ;  Now plotting the DFP only...
             ;
             WAIT, 1.0
             if (info.surfaceIndex EQ 1) then begin
                 !P.T = info.saved3d1
             endif else IF( info.surfaceIndex EQ 2) then begin
                 !P.T = info.saved3d2
             endif else  begin
                 !P.T = info.saved3d3
             endelse

             ;  Showing the message in the information label.
             ;
             string1 = '!3DFP!X'
             string2 = '!3Powell!X'

             if (info.fontflag EQ 0) then begin
                 string1 = '!3DFP!X'
                 string2 = '!3Powell!X'
             endif else if (info.fontflag EQ 1) then begin
                 !p.FONT = 0
                 Device, FONT = "TIMES*18"
                 string1 = 'DFP'
                 string2 = 'Powell'
             endif

             XYOUTS, 0.80, 0.1, $
                 string1, COLOR=info.orange, CHARSIZE=1.0*info.charScale, $
                 /NORMAL, CHARTHICK=1.0

             XYOUTS, 0.80, 0.05, $
                 string2, COLOR=info.white, CHARSIZE=1.0*info.charScale, $
                 /NORMAL, CHARTHICK=1.0


             if (info.fontflag EQ 1) then begin
                 DEVICE, FONT="TIMES*8"
                 !P.FONT = -1
             endif

             ;  Plot the path points, wait 0.3 seconds between each points.
             ;  Plot the DFP path first.
             ;
             for i = 0,iter-1 do begin
                 PLOTS, [xvec[i],xvec[i+1]], [yvec[i],yvec[i+1]], $
                     [zvec[i], zvec[i+1]], $
                     COLOR=info.orange, PSYM=-4, /T3D, $
                     THICK=2.25,SymSize = 1.6
                     WAIT, 0.3
             endfor

             WAIT, 1.0

             ;  Plot the POWELL path.
             ;
             for i = 0,iterpo-1 do begin
                 PLOTS, [xvecpo[i],xvecpo[i+1]], [yvecpo[i],yvecpo[i+1]], $
                     [zvecpo[i], zvecpo[i+1]], $
                     COLOR=info.white, PSYM=-4, /T3D, $
                     THICK=2.25,SymSize=1.6
                 WAIT, 0.3
             endfor

             ; Compute the device coordinates of the minimum point.
             ;
             mindev = DBLARR(3)
             mindev = $
                 CONVERT_COORD(xvec[iter-1], $
                 yvec[iter-1], $
                 zvec[iter-1], $
                 /to_device, /t3D)

             ;  Annotate the Minimum point.
             ;
             string = '!5Min!x'
             if (info.fontFlag EQ 1) then begin
                 !P.FONT = 0
                 DEVICE, FONT="TIMES*24"
                 string='Min'
             endif
             if (info.fontflag EQ 0) then begin
                 string = '!5Min!x'
             endif else if (info.fontflag EQ 1) then begin
                 !p.FONT = 0
                 DEVICE, FONT = "TIMES*24"
                 string = 'Min'
             endif
             XYOUTS,mindev[0]+ 20,mindev[1] -10,$
                 string, COLOR=info.red, $
                 CHARSIZE=2.*info.charScale,/device
             if (info.fontflag EQ 1) then begin
                 Device, FONT = "TIMES*8"
                 !p.FONT = -1
             endif

             ;  Draw a circle at the minimum point location.
             ;
             XYOUTS, xvec[iter-1], yvec[iter-1], Z=zvec[iter-1], $
                 '!20P!X', COLOR=info.red, CHARSIZE=2.*info.charScale, $
                 /T3D, CHARTHICK=2.0

             ;  Show the results in label box.
             ;
             xval = xvec[iter-1]
             yval = yvec[iter-1]
             zval = zvec[iter-1]

             xvalpo = xvecpo[iterpo-1]
             yvalpo = yvecpo[iterpo-1]
             zvalpo = zvecpo[iterpo-1]

             xsdfp = STRING(xval, FORMAT='(f7.4)')
             xsdfp = STRTRIM(xsdfp,2)
             ysdfp = STRING(yval, FORMAT='(f7.4)')
             ysdfp = STRTRIM(ysdfp,2)
             zsdfp = STRING(zval, FORMAT='(f7.4)')
             zsdfp = STRTRIM(zsdfp,2)
             isdfp = STRING(iter, FORMAT='(i3)')
             isdfp = STRTRIM(isdfp,2)

             xspow = STRING(xvalpo, FORMAT='(f7.4)')
             xspow = STRTRIM(xspow,2)
             yspow = STRING(yvalpo, FORMAT='(f7.4)')
             yspow = STRTRIM(yspow,2)
             zspow = STRING(zvalpo, FORMAT='(f7.4)')
             zspow = STRTRIM(zspow,2)
             ispow = STRING(iterpo, FORMAT='(i3)')
             ispow = STRTRIM(ispow,2)

             space = ' '

             if (xval   GE 0.0) then sp1 = space else sp1 =''
             if (xvalpo GE 0.0) then sp2 = space else sp2 =''
             stringx = 'X =     ' + sp1 + xsdfp + '    ' + sp2 + xspow
             if (yval   GE 0.0) then sp1 = space else sp1 =''
             if (yvalpo GE 0.0) then sp2 = space else sp2 =''
             stringy = 'Y =     ' + sp1 + ysdfp + '    ' + sp2 + yspow
             if (zval   GE 0.0) then sp1 = space else sp1 =''
             if (zvalpo GE 0.0) then sp2 = space else sp2 =''
             stringz = 'Z =     ' + sp1 + zsdfp + '    ' + sp2 + zspow
             stringi ='#STEPS = ' + isdfp + '            ' +ispow


             WIDGET_CONTROL, info.ResultLBLx, SET_VALUE=stringx
             WIDGET_CONTROL, info.ResultLBLy, SET_VALUE=stringy
             WIDGET_CONTROL, info.ResultLBLz, SET_VALUE=stringz
             WIDGET_CONTROL, info.ResultLBLi, SET_VALUE=stringi

             WIDGET_CONTROL, info.SurfaceButtonID, SENSITIVE=1
             WIDGET_CONTROL, info.StartButtonID, SENSITIVE=1
             WIDGET_CONTROL, info.findbutton, SENSITIVE=0
             WIDGET_CONTROL, info.wResetButton, SENSITIVE=1
             WIDGET_CONTROL, info.QuitButton, SENSITIVE=1
             WIDGET_CONTROL, info.AboutButtonID, SENSITIVE=1

             ;  Restore the info structure.
             ;
             WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

         end  ; of Find Minimum

         'About Minimization' :  begin

             ;  Shows the text file into a window.
             ;
             d_optimizeAbout, event.top
             WIDGET_CONTROL, event.top, SET_UVALUE=info, /NO_COPY

         end  ; of About Minimization

    endcase   ;  of  buttonValue

end  ; d_optimizeEvent

; -----------------------------------------------------------------------------
;
;  Purpose:  Cleanup procedure.
;
pro d_optimizeCleanup, $
    tlb     ;  IN: top level base

    ;  Get the info structure.
    ;
    WIDGET_CONTROL, tlb, GET_UVALUE=info, /no_copy

    ;  Restore the previous color table.
    ;
    TVLCT, info.colorTable

    ;  Delete the 3 pixmaps.
    ;
    WDELETE, info.pixmap1ID
    WDELETE, info.pixmap2ID
    WDELETE, info.pixmap3ID

    if WIDGET_INFO(info.groupBase, /VALID_ID) then $
        WIDGET_CONTROL, info.groupBase, /MAP

end  ; Of d_optimizeCleanup

; -----------------------------------------------------------------------------
;
;  Purpose:  This application shows the minimization (optimization)
;            methods by the DFP and POWELL algortihms.
;            the user select a starting point and the path
;            is displayed.
;
pro d_optimize, $
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

    ;  This procedure plot the path taken by the
    ;  DFP and the Powell  minimzation algorithms.
    ;
    ;  The user can choose between 3 surfaces and 4 points
    ;  in each of these surfaces.

    ;  If there is an error, go back to the user.
    ;
    ON_Error, 1


    ;  Find the number of available colors.
    ;
    Window, /FREE, XSIZE = 2, YSIZE=2, /PIXMAP
    pixid = !D.WINDOW
    WDELETE, pixid
    numcolors = !D.TABLE_SIZE

    ;  If 'OPTIMIZE' is already open, then return...
    ;
    if (Xregistered('d_optimize') NE 0) then begin
      RETURN
    endif

    fontFlag = 0     ; 0 = use hersey fonts
                     ; 1 = use the buitlt in PS fonts (helvetica, etc..)

    ;  Save the current color table.
    ;
    TVLCT, savedR, savedG, savedB, /GET
    colorTable = [[savedR], [savedG], [savedB]]

    ; Check the validity of the group identifier.
    ;
    ngroup = N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check = WIDGET_INFO(group, /VALID_ID)
        if (check NE 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Return to the main application'
            RETURN
        endif
        groupBase = group
    endif else groupBase = 0L

    begintime = systime(1)

    ;  Get the screen size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize

    ;  Create the starting up message.
    ;
    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
    endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse

    ;  Set up the color table.
    ;  Here we shift down the color table by 'nshift' positions.
    ;
    Window, /FREE, XSIZE=10, YSIZE=10, /PIXMAP
    pixid = !D.WINDOW
    WDELETE, pixid

    if (!D.TABLE_SIZE GE 2L) then begin
        white = (!D.TABLE_SIZE - 1L)  > 0L
        yellow = (!D.TABLE_SIZE - 2L) > 0L
        lavender = (!D.TABLE_SIZE - 3L) > 0L
        aqua = (!D.TABLE_SIZE - 4L) > 0L
        pink = (!D.TABLE_SIZE - 5L) > 0L
        green = (!D.TABLE_SIZE - 6L) > 0L
        red = (!D.TABLE_SIZE - 7L) > 0L
        orange = (!D.TABLE_SIZE - 8L) > 0L
        blue = (!D.TABLE_SIZE - 9L) > 0L
        lt_gray = (!D.TABLE_SIZE - 10L) > 0L
        med_green = (!D.TABLE_SIZE - 11L) > 0L
        brown = (!D.TABLE_SIZE - 12L) > 0L
        olive = (!D.TABLE_SIZE - 13L) > 0L
        purple = (!D.TABLE_SIZE - 14L) > 0L
        dk_gray = (!D.TABLE_SIZE - 15L) > 0L
        black = (!D.TABLE_SIZE - 16L) > 0L
    endif else begin
        white = 1L
        yellow = 1L
        lavender = 1L
        aqua = 1L
        pink = 1L
        green = 1L
        red = 1L
        orange = 1L
        blue = 1L
        lt_gray = 1L
        med_green = 0L
        brown = 0L
        olive = 0L
        purple = 0L
        dk_gray = 0L
        black = 0L
    endelse

    colornames = [white, yellow, lavender, aqua, pink, $
        green, red, orange, blue, lt_gray, med_green, brown, $
        olive, purple, dk_gray, black]

    ;  Number of color indices to shift down.
    ;
    bias = FIX( (!D.TABLE_SIZE ) * 0.40)
    nshift = bias
    loadct, 23
    TVLCT, Rori, Gori, Bori, /GET

    r = Rori
    g = Gori
    b = Bori

    r[0:!D.TABLE_SIZE-nshift-1] = Rori[nshift:!D.TABLE_SIZE-1]
    g[0:!D.TABLE_SIZE-nshift-1] = Gori[nshift:!D.TABLE_SIZE-1]
    b[0:!D.TABLE_SIZE-nshift-1] = Bori[nshift:!D.TABLE_SIZE-1]

    for i = 1, nshift do begin
        r[!D.TABLE_SIZE-nshift-1+i] = Rori[!D.TABLE_SIZE-1]
        g[!D.TABLE_SIZE-nshift-1+i] = Gori[!D.TABLE_SIZE-1]
        b[!D.TABLE_SIZE-nshift-1+i] = Bori[!D.TABLE_SIZE-1]
    endfor

    ;  Set up the color table.
    ;
    TVLCT, r, g, b, 0

    ;  Assign 16 selected colors at the top of the color table.
    ;
    d_optimizeInit16Colors, colornames

    ;  This is the character scaling factor for
    ;  cross-platform compatibility.
    ;
    charScale = 8.0/!D.X_CH_SIZE

    ;  Create the widget heirarchy.
    ;
    if (ngroup EQ 0) then begin
        tlb = WIDGET_BASE(TITLE='Minimization', /COLUMN, $
            MBAR=bar_base,  $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1)
    endif else begin
        tlb = WIDGET_BASE(TITLE='Minimization', /COLUMN, $
            GROUP_LEADER=group, $
            MBAR=bar_base,  $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1)
    endelse

        ; Create the File|Quit buttons.
        ;
        file_menu = WIDGET_BUTTON(bar_base, VALUE='File', /MENU)

            quit_button = WIDGET_BUTTON(file_menu, VALUE='Quit')

        ; Create the Help|About buttons.
        ;
        help_menu = WIDGET_BUTTON(bar_base, VALUE='About', /HELP, /MENU)

            about_button = WIDGET_BUTTON(help_menu, $
                VALUE='About Minimization')


        ;  Create the 1st base child of tlb.
        ;
        first_base = WIDGET_BASE(tlb, Column = 2)

            ;  Create sub base of  second base.
            ;
            subbase1 = WIDGET_BASE(first_base, Column=1)

                ;  Create the selection base (surface and start).
                ;
                select_base = WIDGET_BASE(subbase1, /COLUMN, $
                    /BASE_ALIGN_CENTER)

                    ;  Create the surface pull-down menu
                    ;
                    surfaceButtonID = WIDGET_BUTTON(select_base, $
                        VALUE=' Select a Surface', Menu = 1)

                        surface1ID = Widget_Button(surfaceButtonID, $
                            VALUE='Surface 1')

                        surface2ID = Widget_Button(surfaceButtonID, $
                            VALUE='Surface 2')

                        surface3ID = Widget_Button(surfaceButtonID, $
                            VALUE='Surface 3')

                    ;  Create the staritng points pull-down menu.
                    ;
                    startButtonID = WIDGET_BUTTON(select_base, $
                        VALUE=' Select a Starting Point', Menu = 1)

                        point1ID = WIDGET_BUTTON(startButtonID, $
                            VALUE='Point 1')

                        point2ID = WIDGET_BUTTON(startButtonID, $
                            VALUE='Point 2')

                        point3ID = WIDGET_BUTTON(startButtonID, $
                            VALUE='Point 3')

                        point4ID = WIDGET_BUTTON(startButtonID, $
                            VALUE='Point 4')

                    ;  Create the button that activates the selections.
                    ;
                    find_button = WIDGET_BUTTON(select_base, $
                        VALUE='Find Minimum')

                    wResetbutton = WIDGET_BUTTON(select_base, $
                        VALUE='Reset Surface')

                ;  Create a 2nd base child of subbase1
                ;  that shows the coordinate of
                ;  the selected starting point.
                ;
                show_Start_base = WIDGET_BASE(subbase1,  $
                    /COLUMN, /ALIGN_CENTER, YPAD=10)

                    show_start_label = WIDGET_LABEL(show_start_base, $
                        VALUE='Starting Point')

                    show_start_xy = WIDGET_LABEL(show_start_base, $
                        VALUE='X = -1.2    Y = 2.0')

                ;  Create a 3rd base child of subbase1
                ;  that shows the DFP results.
                ;
                show_RES_base = WIDGET_BASE(subbase1, /COLUMN)


                    show_RES_label = WIDGET_LABEL(show_RES_base, $
                        /ALIGN_LEFT, $
                        VALUE='Results   DFP       Powell   ')

                    show_RES_x = WIDGET_LABEL(show_RES_base, $
                        /ALIGN_LEFT, $
                        VALUE='X =      -1.000    -1.000    ')

                    show_RES_y = WIDGET_LABEL(show_RES_base, $
                        /ALIGN_LEFT, $
                        VALUE='Y =      -1.000    -1.000    ')

                    show_RES_z = WIDGET_LABEL(show_RES_base, $
                        /ALIGN_LEFT, $
                        VALUE='Z =      -0.000    -0.000    ')

                    show_RES_i = WIDGET_LABEL(show_RES_base, $
                        /ALIGN_LEFT, $
                        VALUE='#ITER =   24          26    ')


            ;   Create sub base of the first base.
            ;
            subbase2 = WIDGET_BASE(first_base)

                ;  Create the drawing area.
                ;
                drawxsize = 0.6*screenSize[0]
                drawysize = 0.8*drawxsize
                drawID = Widget_DRAW(subbase2, RETAIN=2, $
                    XSIZE=drawxsize, YSIZE=drawysize)

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(tlb, MAP=0, /ROW)

    ;  All the widgets has been created.

    ;  Realize the top-level base.
    ;
    WIDGET_CONTROL, tlb, /REALIZE

    ;  Returns the top level base to the APPTLB keyword.
    ;
    appTLB = tlb

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('optimize.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         tlb, $
                         wStatusBase)

    ; Get the drawing window index
    ;
    WIDGET_CONTROL, drawID, GET_VALUE=drawWindowID

    ;  Create the 3 surfaces.
    ;  Surface index 1 first (banana function
    ;
    surfaceIndex = 1
    dim_array = 33   ; dimension of the array
    zdata1 = DBLARR(dim_array, dim_array)

    xdata1 = FINDGEN(dim_array)/8.0 -2.0
    ydata1 = FINDGEN(dim_array)/8.0 -1.0

    ; Create the 2-D arrays of the mesh points
    ;
    for i = 0, dim_array-1 do begin
        for j = 0 , dim_array-1 do begin
            x = [xdata1[i], ydata1[j]]
            zdata1[i,j] = d_optimizeFuncOp(x, surfaceIndex)
        endfor
    endfor

    ;  Create the surface 2 and surface 3 data SETS here.
    ;
    surfaceindex = 2
    dim_array = 33
    zdata2 = DBLARR(dim_array, dim_array)
    xdata2 = FINDGEN(dim_array)/8.0 -2.0
    ydata2 = FINDGEN(dim_array)/8.0 -2.0

    ;  Create the 2-D arrays of the mesh points.
    ;
    for i = 0, dim_array-1 do begin
        for j = 0 , dim_array-1 do begin
            x = [xdata2[i], ydata2[j]]
            zdata2[i,j] = d_optimizeFuncOp(x, surfaceIndex)
        endfor
    endfor

    ; Create the surface 3  data SETS here
    ;
    surfaceindex = 3

    dim_array = 17
    zdata3 = DBLARR(dim_array, dim_array)

    xdata3 = FINDGEN(dim_array)/8.0 -1.0
    ydata3 = FINDGEN(dim_array)/8.0 -1.0

    ; Create the 2-D arrays of the mesh points
    ;
    for i = 0, dim_array-1 do begin
        for j = 0 , dim_array-1 do begin
            x = [xdata3[i], ydata3[j]]
            zdata3[i,j] = d_optimizeFuncOp(x, surfaceIndex)
        endfor
    endfor

    ;  Draw the default surface (surface 1) on a newly
    ;  created pixmap.
    ;
    WINDOW, /FREE, XSIZE=drawxsize, YSIZE=drawysize, /PIXMAP
    pixmap1ID = !d.Window

    WSET, pixmap1ID

    ;  Plot the surface 1 on the pixmap
    ;  and save the 3d tranformation
    ;
    if (!D.TABLE_SIZE EQ 16) then begin
        topc = 15
    endif else if (!D.TABLE_SIZE GE 17) then begin
        topc = !D.TABLE_SIZE - 16
    endif else begin
        topc = 1
    endelse

    ;  Draw the shaded surface of the Banana function without axes.
    ;
    SHADE_SURF, zdata1, xdata1, ydata1, /SAVE, $
        SHADES= BYTSCL(zdata1, TOP=topc), $
        BACKGROUND=black, AZ=10, AX= 60, $
        XSTYLE=4, YSTYLE=4, ZSTYLE=4, $
        POSITION=[0.1, 0.20, 0.95, 1.]

    ; Draw the mesh surface of the Banana function without axes
    ;
    SURFACE, zdata1, xdata1, ydata1, /SAVE,/NOERASE, $
        COLOR = 31,AZ=10, AX = 60, $
        XSTYLE=4, YSTYLE=4, ZSTYLE=4, $
        BACKGROUND=black, $
        POSITION=[0.1, 0.20, 0.95, 1.]

    saved3d1 = !p.t
    !P.T = 0

    ; Now create the pixmap for the 2nd surface
    ;
    WINDOW, /FREE, XSIZE=drawxsize, YSIZE=drawysize, /PIXMAP
    pixmap2ID = !d.Window

    !p.T = 0
    WSET, pixmap2ID

    SHADE_SURF, zdata2, xdata2, ydata2, /SAVE, $
        SHADES=BYTSCL(zdata2, TOP=topc-nshift), $
        BACKGROUND=black, AZ=30, AX=30, $
        XRANGE=[-2,2], $
        YRANGE=[-2,2], $
        ZRANGE=[-7,7],$
        XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
        POSITION=[0.05, 0.05, 0.95, 1.]

    SURFACE, zdata2, xdata2, ydata2, /SAVE,/NOERASE, $
        BACKGROUND=black, AZ=30, AX=30, $
        XRANGE=[-2,2], $
        YRANGE=[-2,2], $
        ZRANGE=[-7,7],$
        COLOR=31, $
        XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
        POSITION=[0.05, 0.05, 0.95, 1.]

    saved3d2 = !p.t

    ;  Now create the pixmap for the 3rd surface.
    ;
    WINDOW, /FREE, XSIZE=drawxsize, YSIZE=drawysize, /PIXMAP
    pixmap3ID = !d.Window

    !p.T = 0
    WSET, pixmap3ID
    SHADE_SURF, zdata3, xdata3, ydata3, /SAVE, $
        shades = BYTSCL(zdata3, TOP = topc-nshift), $
        BACKGROUND=black, AZ=30, AX=30, $
        XRANGE=[-1,1], $
        YRANGE=[-1,1], $
        ZRANGE=[-1,1],$
        XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
        POSITION=[0.05, 0.05, 0.95, 1.]

    SURFACE, zdata3, xdata3, ydata3, /SAVE,/NOERASE, $
        BACKGROUND=black, AZ=30, AX=30, $
        XRANGE=[-1,1], $
        YRANGE=[-1,1], $
        ZRANGE=[-1,1],$
        COLOR=31, $
        XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
        POSITION=[0.05, 0.05, 0.95, 1.]

    saved3d3 = !p.t

    WSET, drawWindowID
    !P.T = 0

    ;  Initialize the  starting points.
    ;
    ;  1st index : surface index (1,2,3)
    ;  2nd index : point index (1,2,3,4)
    ;  3rd index ; x, y, z data coordinates
    ;
    startPoints = DBLARR(4,5,4)
    startPointsdev = DBLARR(4,5,4)
    d_optimizeInitPoint, startpoints

    ;  Convert the surface 1 data into device coordinates.
    ;
    !P.T = 0
    !P.T = saved3d1

    d = DBLARR(3,1)

    ;  Here we create an empty surface in order to
    ;  establish the data system coordinates.
    ;  Then, we are able to convert the data into device coordinates.
    ;
    SURFACE, zdata1, xdata1, ydata1,/nodata,  $
        COLOR = 31,AZ=10, AX = 60, $
        XSTYLE=4, YSTYLE=4, ZSTYLE=4, $
        BACKGROUND=black, $
        POSITION=[0.1, 0.20, 0.95, 1.]

    for i = 1, 4 do begin
        d = CONVERT_COORD(startPoints[1, i, 1], $
            startPoints[1, i, 2], $
            startPoints[1, i, 3], $
            /TO_DEVICE, /T3D)
        startPointsdev[1, i, 1:3] = d[0:2, 0]
    endfor

    ; Convert the surface 2 data into device coordinates
    ;
    !P.T = 0
    !P.T = saved3d2

    SURFACE, zdata2, xdata2, $
        ydata2,  /NODATA, $
        BACKGROUND=black, AZ=30, AX=30,$
        XRANGE=[-2,2], $
        YRANGE=[-2,2], $
        ZRANGE=[-7,7],$
        XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
        POSITION=[0.05, 0.05, 0.95, 1.]

    d = DBLARR(3,1)
    for i = 1, 4 do begin
        d = CONVERT_COORD(startPoints[2, i, 1], $
            startPoints[2, i, 2], $
            startPoints[2, i, 3], $
            /TO_DEVICE, /T3D)
        startPointsdev[2, i, 1:3] = d[0:2, 0]
    endfor

    ; Convert the surface 3 data into device coordinates
    ;
    !P.T = 0
    !P.T = saved3d3

    SURFACE, zdata3, xdata3, ydata3, /SAVE,/NODATA, $
        BACKGROUND=black, AZ=30, AX=30,$
        XRANGE=[-1,1], $
        YRANGE=[-1,1], $
        ZRANGE=[-1,1],$
        XSTYLE=6, YSTYLE=6, ZSTYLE=6, $
        POSITION=[0.05, 0.05, 0.95, 1.]

    d = DBLARR(3,1)
    for i = 1, 4 do begin
        d = CONVERT_COORD(startPoints[3, i, 1], $
            startPoints[3, i, 2], $
            startPoints[3, i, 3], $
            /TO_DEVICE, /T3D)
        startPointsdev[3, i, 1:3] = d[0:2, 0]
    endfor

    !P.T = 0

    ;  Point Flag  0 =  No starting point has been selected
    ;              1 =  A starting point has been selected
    ;
    pointFlag = 0

    ;  Desensitize the Find minimum button.
    ;
    WIDGET_CONTROL, find_button, sensitive = 0
    WIDGET_CONTROL, surface1ID, sensitive = 0

    ;  Define the info structure.
    ;
    info = { $
        SurfaceButtonID: surfacebuttonID, $   ; Surface button
        Surface1ID: surface1ID, $             ; Surfaces 1,2,3 buttons
        Surface2ID: surface2ID, $
        Surface3ID: surface3ID, $
        WResetButton: wResetButton, $         ; Reset surface button
        SurfaceIndex: 1, $                    ; Default surface is no.1
        StartButtonID: startbuttonID, $       ; Starting Point buttons
        AboutButtonID: about_button, $        ; Information on the applet
        Point1ID: point1ID, $
        Point2ID: point2ID, $
        Point3ID: point3ID, $
        Point4ID: point4ID, $
        FindButton: find_button, $            ; Find button
        StartLbL: show_start_xy, $            ; Starting point label
        ResultLbLx : show_res_x, $            ; Results labels
        ResultLbLy : show_res_y, $
        ResultLbLz : show_res_z, $
        ResultLbLi : show_res_i, $            ; Iterations
        Quitbutton: quit_button, $            ; Quit button in file menu
        Pixmap1ID: pixmap1ID, $               ; Pixmaps ID's
        Pixmap2ID: pixmap2ID, $
        Pixmap3ID :pixmap3ID, $
        DrawWinID: drawwindowID, $            ; Drawing window
        Xdata1: xdata1, $                     ; Surface data sets
        Ydata1: ydata1, $
        Zdata1: zdata1, $
        Xdata2: xdata2, $
        Ydata2: ydata2, $
        Zdata2: zdata2, $
        Xdata3: xdata3, $
        Ydata3: ydata3, $
        Zdata3: zdata3, $
        ColorTable: colortable, $             ; Color table to restore
        PointIndex: 0, $                      ; Selected point
        PointFlag: pointFlag, $               ; If point selected(0 = no)
        StartPoints: startpoints, $           ; Starting points in data coor.
        StartPointsdev: startpointsdev, $     ; Start. points in device coor.
        Saved3d1: saved3d1, $                 ; 3-D transformation surface 1
        Saved3d2: saved3d2, $                 ; 3-D transformation surface 2
        Saved3d3: saved3d3, $                 ; 3-D transformation surface 3
        drawxsize: drawxsize, $               ; Drawing window size
        drawysize: drawysize, $
        Red: red, $                           ; Colors indices
        Yellow: yellow, $
        Lavender: lavender, $
        Aqua: aqua, $
        Pink: pink, $
        White: white, $
        Green: green, $
        Orange: orange, $
        Blue: blue, $
        Lt_gray: lt_gray, $
        Med_green: med_green, $
        Brown: brown, $
        Olive: olive, $
        Purple: purple, $
        Dk_gray: dk_gray, $
        Black: black, $
        FontFlag : fontflag, $
        CharScale: charScale, $                ; Character scaling factor
        groupBase: groupBase $                 ; Base of Group Leader
    }

    ;  Reset the result label to default.
    ;
    d_optimizeResetResult, info.ResultLBLx, info.ResultLBLy, $
        info.ResultLBLz, info.ResultLBLi

    ;  Set the info structure.
    ;
    WIDGET_CONTROL, tlb, SET_UVALUE=info, /NO_COPY


    ;  Copy surface 1 into the drawing window.
    ;
    WSET, drawWindowID
    SURFACE, zdata1, xdata1, ydata1, /NODATA,  $
        COLOR=31, AZ=10, AX=60, $
        XStyle=4, YStyle=4, ZStyle=4, $
        POSITION=[0.1, 0.20, 0.95, 1.],background = black

    Device, Copy=[0, 0, drawxsize, drawysize, 0, 0, pixmap1ID]

    ;  Plot the 4 starting points into the drawing window.
    ;
    surfaceIndex = 1
    pointnumber = 1
    saved3dt = saved3d1
    d_optimizePlotPoint, surfaceIndex, pointnumber, charscale,red, $
        saved3dt, startPoints, startPointsdev, FontFlag,  /all


    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, tlb, MAP=1

    ;  Register with the XManager.
    ;
    XMANAGER, "d_optimize", tlb, Event_Handler="d_optimizeEvent",$
        CLEANUP='d_optimizeCleanup', $
        /NO_BLOCK

end   ; of d_optimize.pro
