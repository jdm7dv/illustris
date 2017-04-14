;  $Id: //depot/idl/IDL_70/idldir/examples/doc/sdf/hdf_rdwr.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;
;	Simple example #1
;
;	Save a matrix as a SDS
;
PRO MakeHDFData, filename

	;	Check for a filename. Provide a default if none
	;	is given.
	IF N_ELEMENTS(filename) EQ 0 THEN filename="hdf_example.hdf"

	;	Create (or overwrite) a Scientific Data Set (SDS)
	;	We always want to write the first SDS so...
    file = FILEPATH('mr_brain.dcm', SUBDIRECTORY = ['examples', 'data'])  
    xray = READ_DICOM(file)    
	myRANGE=[max(xray,min=min_xray),min_xray]
        ;
	sd_id=HDF_SD_START(filename,/CREATE)
	sds_id=HDF_SD_CREATE(sd_id,'brain X-ray', $
	   [(SIZE(xray))[1],(SIZE(xray))[2]],/FLOAT)
	HDF_SD_SETINFO,sds_id,FILL=0.0,LABEL='X-Ray of my brain', $
		       UNIT='Furlongs per Fortnight',$
		       RANGE=myRANGE
	;
	; Write labels to each of the dimensions
	;
	HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,0),NAME='Width',LABEL='Width of my brain'
	HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,1),NAME='Height',LABEL='Height of my brain'

	;	Create and write the data
	HDF_SD_ADDDATA, sds_id, xray

	;	Done Close down the SDS

	HDF_SD_ENDACCESS,sds_id
	HDF_SD_END,sd_id
END

PRO ReadHDFData, filename

	;	See if there is anything there to read

	sd_id=HDF_SD_START(filename)
        HDF_SD_FILEINFO,sd_id,NumSDS,attributes

	IF NumSDS LT 1 THEN Message, "No Scientific Data Sets in File"

	;	Find out about the first SDS

	sds_id=HDF_SD_SELECT(sd_id,0)
	help,sds_id
	HDF_SD_GETINFO,sds_id,RANGE=RANGE
	HDF_SD_GETINFO,sds_id,NDIMS=NDIMS,LABEL=LABEL,DIMS=DIMS,TYPE=TYPE
	HDF_SD_GETDATA,sds_id,xray_out
	;
	; Close down the HDF file
        ;
	HDF_SD_ENDACCESS,sds_id
	HDF_SD_END,sd_id
        ;
	help,NDIMS,RANGE,LABEL,DIMS,TYPE
	Print,'Displaying Data'
	window,xsize=DIMS[0],ysize=DIMS[1]
	erase
	loadct,8
	TVSCL, xray_out
	XYOUTS, !d.x_size/2, !d.y_size - 20, ALIGNMENT=0.5, /DEVICE, $
		STRING(LABEL),charsize=0.75
END

PRO hdf_rdwr,Filename
	Print, 'Writing Data' & MakeHDFData,filename
	Print, 'Reading Data' & ReadHDFData,filename
END

