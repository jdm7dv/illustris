;  $Id: //depot/idl/IDL_70/idldir/examples/doc/sdf/cdf_cat.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;
;	Test program: CATalog of a CDF file
;
;
pro cdf_cat,filename

	cdfid = cdf_open(filename)	; Open a CDF file
	glob = cdf_inquire( cdfid )	; Find out general info

	;	Tell user about each dimension

	print,'Dimensions', glob.ndims
	for i=0,glob.ndims-1 do begin
		print,FORMAT='("    Dim #", I0, ": ", I0)', i, glob.dim[i]
	endfor

	;	Get global attributes

	print_title = 1

	for attr_num = 0,glob.natts-1 do begin
		cdf_attinq, cdfid, attr_num, attname, scope, maxentry
		if scope eq "GLOBAL_SCOPE" then begin
			; assume there is only one entry and it
			; is at maxentry.
			On_IoError, NoGlobAttr
			cdf_attget, cdfid, attr_num, maxentry, attvalue
			if print_title then begin
				print
				print, 'Global Attributes'
				print
				print_title = 0
			endif
			Print, "Attribute: '", attname, "' = ", attvalue
		NoGlobAttr:
		endif
	endfor
	;	Now tell user about the variables

	print
	print, 'Variables'
	print
	for var_num=0,glob.nvars-1 do begin

		;	Get information about the variable

		info = cdf_varinq(cdfid, var_num)

		; Print the name, type and per record variance of the
		; variable
		print, FORMAT='(A," (",A," ) Record Variance:", A)', $
			info.name, info.datatype, info.recvar

		; print any attributes associated with the variable

		;	The attribute may not have a value
		;	associate the given variable.
		On_IoError, NoAttr

		;	Loop through all the attributes and see if
		;	there is an entry for the given variable

		for attr_num=0,glob.natts-1 do begin
			cdf_attinq, cdfid, attr_num, attname, scope, maxentry
			cdf_attget, cdfid, attr_num, var_num, attvalue
			print,"	Attribute: '", attname, "' = ", attvalue
		NoAttr:
		endfor
	endfor
	cdf_close,cdfid
end
