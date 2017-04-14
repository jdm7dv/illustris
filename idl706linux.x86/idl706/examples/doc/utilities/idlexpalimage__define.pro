; $Id: //depot/idl/IDL_70/idldir/examples/doc/utilities/idlexpalimage__define.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;       IDLexPalImage
;
; PURPOSE:
;       This object subclasses the IDLgrImage object to allow for 16bit
;	(or deeper) paletted image support.  This allows the user to
;	use images with a dynamic range greater than 8bits.
;
;	The basic idea is that the object contains a 2D array and a palette
;	of any length.  The palette can be 1xn, 2xn, 3xn or 4xn for GS, GSA
;	RGB or RGBA images.  The 2D array is mapped through the palette into
;	an RGBA image and then sent to the superclass for display.  Values
;	in the input image outside the range of the palette are clamped to
;	the end values of the palette.
;
; CATEGORY:
;       Object graphics examples.
;
; CALLING SEQUENCE:
;
;       oObj = OBJ_NEW('IDLexPalImage')
;
; KEYWORD PARAMETERS:
;
;
; MODIFICATION HISTORY:
;       Written by:     RJF, Jun 1998
;-
;----------------------------------------------------------------------------
;	Init the object
;
FUNCTION IDLexPalImage::Init, DATA=data,PALETTE=palette,NO_COPY=nocopy, $
	_EXTRA=e

	ON_ERROR,2

	IF (self->IDLgrImage::Init(_EXTRA=e) NE 1) THEN RETURN,0

	; create an initial palette
	self.expalette = PTR_NEW(INDGEN(256),/NO_COPY)
	self.expaldims = [1,256]

	; propagate the keywords
	IF (N_ELEMENTS(data) NE 0) THEN self->SetProperty,DATA=data, $
		NO_COPY=KEYWORD_SET(nocopy)
	IF (N_ELEMENTS(palette) NE 0) THEN self->SetProperty,DATA=palette, $
		NO_COPY=KEYWORD_SET(nocopy)

	RETURN,1
END

;----------------------------------------------------------------------------
;	SetProperty
;
PRO IDLexPalImage::SetProperty,DATA=data,PALETTE=palette,NO_COPY=nocopy, $
	_EXTRA=e

	ON_ERROR,2

	iNewData = 0

	; First handle the normal IDLgrImage keywords
	self->IDLgrImage::SetProperty, _EXTRA=e

	; Handle the DATA keyword
	IF (N_ELEMENTS(data) NE 0) THEN BEGIN
		; Check its validity
		si = SIZE(data,/TYPE)
		IF (si GE 6) THEN BEGIN
			MESSAGE,"DATA is not a supported type"
		END
		si = SIZE(data,/N_DIMENSIONS)
		IF (si NE 2) THEN BEGIN
			MESSAGE,"DATA must be a 2D array"
		END
		; (re)place the data in the object
		IF (PTR_VALID(self.exdata)) THEN PTR_FREE,self.exdata
		self.exdata = PTR_NEW(data,NO_COPY=KEYWORD_SET(nocopy))
		; retain the size and min/max values for future computations
		self.exsize = SIZE(data,/DIMENSIONS)
		self.exminmax[0] = MAX(*self.exdata,MIN=themin)
		self.exminmax[1] = themin
		iNewData = 1
	END

	; Handle the PALETTE keyword
	IF (N_ELEMENTS(palette) NE 0) THEN BEGIN
		; Check its validity
		temp = MAX(palette,MIN=temp2)
		IF ((temp GT 255) OR (temp2 LT 0)) THEN BEGIN
			MESSAGE,"PALETTE values must be in the range 0-255"
		END
		si = SIZE(palette,/N_DIMENSIONS)
		IF (si EQ 2) THEN BEGIN
			dim = SIZE(palette,/DIMENSIONS)
			IF (dim[0] GT 4) THEN BEGIN
				MESSAGE, $
				"PALETTE leading dimension must be less than 4."
			END
			; Change the palette
			IF (PTR_VALID(self.expalette)) THEN $
				PTR_FREE,self.expalette
			self.expalette = PTR_NEW(palette,$
				NO_COPY=KEYWORD_SET(nocopy))
			; Save the palette size
			self.expaldims = dim
			iNewData = 1
		END ELSE IF (si EQ 1) THEN BEGIN
			; Change the palette
			IF (PTR_VALID(self.expalette)) THEN $
				PTR_FREE,self.expalette
			self.expalette = PTR_NEW(palette,$
				NO_COPY=KEYWORD_SET(nocopy))
			; Save the palette size
			self.expaldims = [1,N_ELEMENTS(*self.expalette)]
			iNewData = 1
		END ELSE BEGIN
			MESSAGE,"PALETTE must be a 1D or 2D array."
		END
	END

	; The Image may need to change
	IF (iNewData AND PTR_VALID(self.exdata)) THEN BEGIN
		; Create a base image for the CI case
		IF (self.expaldims[0] EQ 1) THEN BEGIN
			Img = BYTARR(3,self.exsize[0],self.exsize[1])
		END
		; Does the image need clamping?
		IF ( (FIX(self.exminmax[0]) LT 0) OR $
		     (FIX(self.exminmax[1]) GE self.expaldims[1]) ) THEN BEGIN
			; Clamp
			temp = 0 > (*self.exdata) < (self.expaldims[1] - 1)
			; Build the image (CI or RGB case)
			IF (self.expaldims[0] EQ 1) THEN BEGIN
				Img[0,*,*] = (*self.expalette)[temp]
				Img[1,*,*] = (*self.expalette)[temp]
				Img[2,*,*] = (*self.expalette)[temp]
			END ELSE BEGIN
				Img = (*self.expalette)[*,temp]
				Img = REFORM(Img,self.expaldims[0],$
					self.exsize[0],self.exsize[1],$
					/OVERWRITE)
			END
		END ELSE BEGIN
			; Build the image (CI or RGB case)
			IF (self.expaldims[0] EQ 1) THEN BEGIN
				Img[0,*,*] = (*self.expalette)[*self.exdata]
				Img[1,*,*] = (*self.expalette)[*self.exdata]
				Img[2,*,*] = (*self.expalette)[*self.exdata]
			END ELSE BEGIN
				Img = (*self.expalette)[*,*self.exdata]
				Img = REFORM(Img,self.expaldims[0],$
					self.exsize[0],self.exsize[1],$
					/OVERWRITE)
			END
		END
		; Change the current image
		self->IDLgrImage::SetProperty,DATA=Img,/NO_COPY
	END
END

;----------------------------------------------------------------------------
;	GetProperty
;
PRO IDLexPalImage::GetProperty,DATA=data,PALETTE=palette, $
	_REF_EXTRA=re

	ON_ERROR,2

	; handle the superclass
	self->IDLgrImage::GetProperty, _EXTRA=re

	; return the class specific data
	IF (PTR_VALID(self.exdata)) THEN BEGIN
		data = *(self.exdata)
	END ELSE BEGIN
		data = 0
	END

	IF (PTR_VALID(self.expalette)) THEN BEGIN
		palette = *(self.expalette)
	END ELSE BEGIN
		palette = 0
	END
END

;----------------------------------------------------------------------------
;	Destroy the object
;
PRO IDLexPalImage::Cleanup

	ON_ERROR,2

	; Cleanup any data stored in this class
	IF (PTR_VALID(self.exdata)) THEN PTR_FREE,self.exdata
	IF (PTR_VALID(self.expalette)) THEN PTR_FREE,self.expalette

	; call the superclass
	self->IDLgrImage::Cleanup
END

;----------------------------------------------------------------------------
;       Define the object
;
PRO IDLexPalImage__define

	struct = { IDLexPalImage, $
		   INHERITS IDLgrImage, $
		   exData: PTR_NEW(), $
		   exPalette: PTR_NEW(), $
		   exPalDims: LONARR(2), $
		   exMinMax: FLTARR(2), $
		   exSize: LONARR(2) $
		 }
END

