;  $Id: //depot/idl/IDL_70/idldir/examples/doc/sdf/hdf_cat.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;
;	Test program: CATalog of a SDS's in an HDF file
;
;

pro hdf_sdsinfo, filename


	;	Get some of the per SDS information

	DFSD_GETINFO, filename, TYPE=type, DIMS=dims, LABEL=label, UNIT=units

	;	Tell user about each dimension

	print,'Dimensions', n_elements(dims)
	for i=0,n_elements(dims)-1 do begin
		dfsd_dimget, i, LABEL=dim_label
		print,FORMAT='("    ",A, ": ", I0)', dim_label, dims[i]
	endfor

	;	Get SDSattributes

	print
	print, 'Attributes'
	print
	Print, "    LABEL = ", label
	Print, "    UNIT = ", units

	; Print, "    RANGE = ", range
	; Print, "    FORMAT = ", format	(Other global attributes)
	; Print, "    COORDSYS = ", coordsys

end


pro hdf_cat,filename

	DFSD_GETINFO, filename, NSDS=NumSDS

	DFSD_SETINFO, /RESTART		; read from first SDS

	FOR I=1,NumSDS DO hdf_sdsinfo, filename
end
