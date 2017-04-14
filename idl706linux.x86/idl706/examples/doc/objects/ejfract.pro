; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/ejfract.pro#2 $
;
; Copyright (c) 1988-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
; Demo file to determine ejection fraction of file abnorm.dat.
; Assumes abnorm.dat is in images subdirectory.
;
; Color table common:
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

;	Make a new window?
if !d.window lt 0 and ((!d.flags and 256) ne 0) then window,title="Cardiac Demonstration"
;	Load orange color table if none loaded yet.
if n_elements(r_orig) eq 0 then loadct,3  ;Load red color table if none
				;have been loaded.
top = !d.n_colors-1		;Max display value
xsize = 192			;Size of movie display
close,1				;Be sure unit 1 is closed
;;;;	read,1,'Filename: ',filename
openr,1,filepath('abnorm.dat', subdirectory=['examples','data'])	;Open data file
b = fstat(1)		;Get size
nframes = b.size / 4096	;# of frames
aa=assoc(1,bytarr(64,64)) ;64 x 64 images.
erase
diastole = fix(aa[0])	;Diastolic image is first frame, use 16 bits
tv,rebin(bytscl(diastole, top = top),256,256)	;Blow up for display, show it
print,'Mark ventricular region:'
vent = defroi(64,64,zoom=4)	;Get region of interest subscript array
print,'Mark background region:'
bkg = defroi(64,64,zoom=4)	;Background region subscripts
c=bytscl(diastole,top=top)	;Copy for display...
c[vent] = 255			;Show regions by filling ROI's with 0's & 255.
c[bkg] = 0
tvcrs				;No more cursor
erase
tv,rebin(c,xsize,xsize)		;Show it blown up

c = fltarr(nframes-1)			;Counts
svmax = max(smooth(diastole - aa[7],3))	;Scaling for sv

for i=0,nframes-2 do begin	;Get time / activity curve.
	a = aa[i]		;Read image
	if i le 19 then begin	;show 1st 16
	 tvscl,a,i		;Show image
	 tv,bytscl(smooth(diastole-a,3),$
		min=0,max=svmax,top=top),i+20	;Stroke volume
	 endif
				;Counts = ventricle less background
	c[i] = total(a[vent]) - total(a[bkg])*n_elements(vent)/n_elements(bkg)
	endfor

plot,/noerase,title='Ejection Fraction',xtitle='Frame', $ 
	pos = [.6,.12,.95,.46], $
	ytitle='Ejection Fraction', 1-c/max(c) ;Plot and scale to eject fract
ans = ""			;Define a string for response
read,"Do you want a movie (Y, N)? ",ans
if strupcase(ans) eq "Y" then begin	;Make a movie
	b = bytarr(xsize,xsize,nframes-1,/noz)	;memory for each frame
	for i=0,nframes-2 do $
	  b[0,0,i] = rebin(reverse(bytscl(aa[i],top=top),2),xsize, xsize)
	movie,b			;show it
	endif

close,1
end
