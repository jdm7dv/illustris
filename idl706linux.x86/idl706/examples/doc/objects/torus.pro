; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/torus.pro#2 $
;
; Copyright (c) 1988-2008, ITT Visual Information Solutions. All
;       rights reserved.

pro torus, r, r0, verts, polys  ;Draw a torus, centered about (0,0,0).
; Major circle lies in xy plane.
; r = major radius, r0 = radius in Z direction.
; Verts = current vertex list, a (3,n) array of (x,y,z) coordinates.
; Polys = Polygon list.
; The vertices and polygons are appended to these lists.

n = 15			;# of segments/circle
f = 360./n * !dtor

old_verts = verts
old_polys = polys

vy = sin(findgen(n)*f)	;Y coordinates of circle
vx = cos(findgen(n)*f)	;X coordinates

kv = n_elements(old_verts)/3	;Size of old vertex list
verts = fltarr(3,kv + n^2)	;New vertex list
if kv gt 0 then verts[0,0] = old_verts	;Append to old?
kp = n_elements(old_polys)/4	;Same with polygons
polys = intarr(4,2*n^2+kp)
if kp gt 0 then polys[0,0] = old_polys

;	Draw vertices & edges in counter clockwise direction.
for i=0,n-1 do begin
	i1 = (i+ 1) mod n	;Polygon between segments (i,i1)
	cx = vx[i]*r		;X around major circle
	cy = vy[i]*r		;Y
	for j=0,n-1 do begin	;Minor circle
		j1 = (j+1) mod n  ;Polygon between segments (j,j1)
		rr = vx[j]*r0	;Radius of minor circle
				;Translate
		v = [ rr*vx[i] + cx, rr*vy[i] + cy, vy[j]*r0, 1] # !p.t
		verts[0,i*n+j+kv] = v[0:2]
		polys[0,kp] =  [3,kv+i*n+j,kv+i1*n+j,kv+i1*n+j1]
		polys[0,kp+1] = [3,kv+i*n+j,kv+i1*n+j1, kv+i*n+j1]
		kp = kp + 2
		endfor
	endfor
return
end



t3d,/reset		;Reset transformation to identity
verts = 0		;Init arrays to empty
polys = 0
torus,.7,.25,verts, polys	;1st torus fits into the cube (-1,1),(-1,1)
				;  and (-1,1) approximately.
t3d,ro=[90,0,0]		;Rotate next by 90 about x
t3d,tr=[.7,0,0]		;and move it to right by .7
torus,.7,.25,verts, polys	;2nd torus

vmin = fltarr(3) & vmax = vmin	;get min & max of each coordinate.
for i=0,2 do begin
	v = verts[i,*]
	vmin[i] = min(v)
	vmax[i] = max(v)
	endfor
!x.s = [-vmin[0],.9]/(vmax[0]-vmin[0]) ;Set up data scaling to normalized 
;				coordswhich is the cube [0,1],[0,1],[0,1]
!y.s = [-vmin[1],.9]/(vmax[1]-vmin[1])
!z.s = [-vmin[2],.9]/(vmax[2]-vmin[2])

surfr,ax=45		;view from 45 degree orientation
erase
;  Monochrome?
if !d.n_colors le 2 then top = 255 else top = !d.n_colors -1 < 255
b = polyshade(verts,polys,/t3d,/data, xsize=512,ysize=512, top=top)
tv,b
end
