;  $Id: //depot/idl/IDL_70/idldir/examples/doc/sdf/cdf_rdwr.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;
;	Simple example #1
;
;	Save a matrix
;
PRO MakeCDFData, filename

	;	Check for a filename. Provide a default if none
	;	is given.
	IF N_ELEMENTS(filename) EQ 0 THEN filename="cdf_example"

	;	Remove any file(s) that might currently exist that
	;	would interfere with creating the new data.

	ON_IOERROR, NoFileToRemove
	Id	= CDF_OPEN(Filename)
	CDF_DELETE, Id

   NoFileToRemove:	

	;	Create the CDF file. We need to specify the dimensions
	;	as part of the creation.
	;	By default the file created is ROW_MAJOR and has
	;	NETWORK_ENCODING

	Id	= CDF_CREATE(filename, [ 100, 200 ])

	;	Create data to store
	Data	= DIST(100,200)

	;	Create a variable to hold the data that varies
	;	in both dimensions.

	VarId	= CDF_VARCREATE(Id,'MyData', ['VARY', 'VARY'], /CDF_FLOAT)

	;	Create some attributes (to tell about our variable)

	dummy	= CDF_ATTCREATE(Id, "TITLE", /GLOBAL)
	dummy	= CDF_ATTCREATE(Id, "UNITS", /VARIABLE)

	;	Save the attributes for this particular variable

	CDF_ATTPUT, Id, "TITLE", 0, "X-Ray of my brain"
	CDF_ATTPUT, Id, "UNITS", VarId, "Furlongs per Fortnight"

	;	Write the data
	CDF_VARPUT, Id, VarId, Data

	;	Done
	CDF_CLOSE, Id
END

PRO ReadCDFData, filename

	;	Open the file for reading
	Id	= CDF_OPEN(filename)

	;	Read in the Title. Note that we assume that
	;	the file will have a global attribute 'TITLE'
	;	with entry number 0 (pretty much the NSSDC standard --
	;	except we don't care how long the title is )
	;	This may not be the case in general but for
	;	our example, we assume it will be there

	CDF_ATTGET, Id, "TITLE", 0, Title

	;	Read the data
	CDF_VARGET, Id, 'MyData', Data

	;	Now show our data with a title

	Print,'Displaying Data'
	erase
	loadct,2	; choose a different colormap
	TVSCL, Data
	XYOUTS, !d.x_size/2, !d.y_size - 20, ALIGNMENT=0.5, /DEVICE, $
		STRING(title)
	CDF_CLOSE, Id
END

PRO cdf_rdwr,Filename

	Print, 'Writing Data' & MakeCDFData,filename
	Print, 'Reading Data' & ReadCDFData,filename
END

