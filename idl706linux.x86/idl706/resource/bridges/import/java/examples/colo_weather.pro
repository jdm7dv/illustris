;
; Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Demonstrate query to URL and parsing of subsequent data
;
; Usage:
;    IDL> colo_weather
;
 
Pro colo_weather

	compile_opt IDL2

	; Create the object first
	jObj = obj_new("IDLJavaObject$WeatherDemo", "WeatherDemo")

   print, 'Connecting to server...'

	tmp = jObj->getWeather()

	; delete the object
	obj_destroy, JObj

	; parse out the data: Town, Elevation,<blank>, time, high, low
	weatherArray = strtok(tmp, ',', /extract)
	print, "Data From IDL.."
	print, weatherArray

End
