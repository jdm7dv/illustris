;  $Id: //depot/idl/IDL_70/idldir/examples/doc/sdf/ncdf_rdwr.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;
;	Simple example #1
;
;	Save a matrix
;
PRO MakeNetCDFData, filename

	;	Check for a filename. Provide a default if none
	;	is given.
	IF N_ELEMENTS(filename) EQ 0 THEN filename="ncdf_example.cdf"

	;	Create the NetCDF file
	Id	= NCDF_CREATE(filename,/CLOBBER)

	;	Create dimensions
	Dim1	= NCDF_DIMDEF(Id,'Width',100)
	Dim2	= NCDF_DIMDEF(Id,'Height',200)

	;	Create a variable to hold the data
	VarId	= NCDF_VARDEF(Id,'MyData', [Dim1, Dim2], /FLOAT)

	;	Create some attributes (to tell about our variable)

	NCDF_ATTPUT, Id, VarId, "TITLE", "X-Ray of my brain"
	NCDF_ATTPUT, Id, VarId, "UNITS", "Furlongs per Fortnight"

	;	Leave definition mode and enter data write mode
	NCDF_CONTROL, Id, /ENDEF

	;	Create data to store
	Data	= DIST(100,200)

	;	Write the data
	NCDF_VARPUT, Id, VarId, Data

	;	Done
	NCDF_CLOSE, Id
END

PRO ReadNetCDFData, filename

	;	Open the file for reading
	Id	= NCDF_OPEN(filename)

	;	Read in the Title. Note that we assume that
	;	the variable will have an attribute named TITLE.
	;	This may not be the case in general but for
	;	our example, we assume it will be there

	NCDF_ATTGET, Id, 0, "TITLE", Title

	;	Read the data
	NCDF_VARGET, Id, 'MyData', Data

	;	Now show our data with a title

	Print,'Displaying Data'
	erase
	loadct,0
	TVSCL, Data
	XYOUTS, !d.x_size/2, !d.y_size - 20, ALIGNMENT=0.5, /DEVICE, $
		STRING(title)
	NCDF_CLOSE, Id
END

PRO ncdf_rdwr,Filename

	Print, 'Writing Data' & MakeNetCDFData,filename
	Print, 'Reading Data' & ReadNetCDFData,filename
END

