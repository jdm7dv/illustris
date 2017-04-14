;  $Id: //depot/idl/IDL_70/idldir/examples/doc/sdf/ncdf_cat.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;
;	Test program: CATalog of a NetCDF file
;
pro ncdf_cat,filename

	cdfid = ncdf_open(filename,/NOWRITE)	; Open the file
	glob = ncdf_inquire( cdfid )		; Find out general info

	;	Show user the size of each dimension

	print,'Dimensions', glob.ndims
	for i=0,glob.ndims-1 do begin
		ncdf_diminq, cdfid, i, name,size
		if i EQ glob.recdim then	$
			print,'    ', name, size, '(Unlimited dim)'	$
		else			$
			print,'    ', name, size
		
	endfor

	;	Now tell user about the variables

	print
	print, 'Variables'
	for i=0,glob.nvars-1 do begin

		;	Get information about the variable
		info = ncdf_varinq(cdfid, i)
		FmtStr = '(A," (",A," ) Dimension Ids = [ ", 10(I0," "),$)'
		print, FORMAT=FmtStr, info.name,info.datatype, info.dim[*]
		print, ']'

		;	Get attributes associated with the variable
		for j=0,info.natts-1 do begin
			attname = ncdf_attname(cdfid,i,j)
			ncdf_attget,cdfid,i,attname,attvalue
			print,'	Attribute ', attname, '=', string(attvalue)
		endfor
	endfor
	ncdf_close,cdfid	; done
end
