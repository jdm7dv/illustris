; $Id: //depot/idl/IDL_70/idldir/examples/misc/gear.pro#2 $
;
; Copyright (c) 1988-2008, ITT Visual Information Solutions. All
;       rights reserved.

PRO GEAR,FRONT, REAR		; Help pick bike gears
;+NODOCUMENT
; NAME:
;	GEAR
;
; PURPOSE:
;	Graphically display how the front and rear gears of a bike
;	interact by calculating the "inches of chain" for each
;	combination.  Inches of chain (as used here) is calculated as:
;
;		IOC = (# chainring teeth)/(# freewheel teeth) * 27
;
;	The 27 is for a 27" wheel, but 27 is generally used for all
;	wheels.  Inches of chain is a relative measure, so the difference
;	is not important.  Also 700C wheels are pretty close to 27" anyway.
;
; CATEGORY:
;	?? - Misc.
;
; CALLING SEQUENCE:
;	GEAR, Front, Rear
;
; INPUTS:
;	Front:	A scalar, or vector.  Each element contains the number
;		of teeth on one of the chainrings, in increasing
;		order (e.g. [36, 42, 52]).
;
;	Rear:	A vector.  Each element contains the number
;		of teeth on one of the freewheel cluster, in increasing
;		order (e.g. [13, 15, 17, 19, 21, 24]).
;		of the front chainring.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	GEAR produces two side-by-side plots.  The first shows the inches of 
;	chain as a function of the freewheel gear while holding the chainring 
;	size constant.  The second shows how the front and rear gears must
;	be switched to move through the possible settings in a monotonic way. 
;	This plot allows you to see duplications in gear combinations.
;
; RESTRICTIONS:
;	This routine can't handle a single gear setup, but it would be 
;	meaningless anyway.
;
; MODIFICATION HISTORY:
;	23, June, 1988, Written by AB, RSI.
;-
;
;
  on_error, 2		; Return to caller if an error occurs

  f_size = size(front)
  IF (f_size[0] EQ 0) THEN BEGIN
    f_front = FLTARR(1)
    f_front[0] = FLOAT(front)
    f_size = size(f_front)
  ENDIF ELSE f_front = FLOAT(front)

  r_size = size(rear)
  f_rear = FLOAT(rear)

  if ((f_size[0] ne 1) or (r_size[0] ne 1)) then begin
    message, 'FRONT and/or REAR have the wrong number of dimensions.'
    endif

  chainrings = f_size[1]
  cogs = r_size[1]

  ratio = {gear_struct, front:0.0, rear:0.0, inches:0.0}
  ratio = replicate(ratio,chainrings, cogs)
  for I = 0, chainrings-1 do ratio[I,*].front = f_front[I]
  for I = 0, cogs-1 do ratio[*,I].rear = f_rear[I]
  ratio.inches = 27. * ratio.front / ratio.rear


  OLD_P_MULTI = !P.MULTI				; Remember
  !P.MULTI = [0, 2, 0, 0, 0]

  OLD_FONT = !P.FONT
  if (!D.NAME eq "PS") then !P.FONT = 0 else !P.FONT = -1

  ; Basic Plot
  PLOT, F_REAR, F_FRONT , $
	XRANGE=[min(F_REAR), max(F_REAR)], $
	YRANGE=[min(RATIO.INCHES), max(RATIO.INCHES)], $
	XTITLE = 'Teeth (Rear Cluster)', $
	YTITLE = 'Inches of Chain', $
	TITLE = 'Gearing By Chainring', FONT = 0, /NODATA, $
	XSTYLE=2, YSTYLE=2, XTICKS = cogs-1, XTICKV=f_rear
  for I = 0, CHAINRINGS-1 do begin
    yval = ratio[I,*].inches
    OPLOT, f_rear, yval, PSYM=(-4-(i MOD 3))
    tmp = STRING('Crank = ', f_front[i], FORMAT='(a, I0)')
    XYOUTS,f_rear[0]+.2, yval[0], TMP,size=.5
    endfor

  ; Shifting pattern plot
  ind = SORT(ratio.inches)
  PLOT, ratio[ind].front, ratio[ind].inches , $
	XRANGE=[min(F_FRONT)-5, max(F_FRONT)+5], $
	YRANGE=[min(RATIO.INCHES), max(RATIO.INCHES)], $
	XTITLE = 'Teeth (Front Chainring)', $
	YTITLE = 'Inches of Chain', $
	TITLE = 'Monotonic Curve', FONT = 0, XSTYLE=2, YSTYLE=2, $
	XTICKS = chainrings-1, XTICKV=f_front

  for I = 0, CHAINRINGS-1 do $
    for J = 0, COGS-1 do BEGIN
      tmp = STRING(COGS-J, FORMAT='(I1)')
      XYOUTS,ratio[I,J].front,ratio[I,J].inches,tmp
    endfor

  !P.MULTI = OLD_P_MULTI			; Restore
  !P.FONT = OLD_FONT
end
