;-----------------------------------------------------------------
FUNCTION Url_Callback, status, progress, data

   ; print the info msgs from the url object
   PRINT, status

   ; return 1 to continue, return 0 to cancel
   RETURN, 1
END

;-----------------------------------------------------------------
PRO url_docs_ftp_dir

   ; if the url object throws an error it will be caught here
   CATCH, errorStatus
   IF (errorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL

      ; display the error msg in a dialog
      r = DIALOG_MESSAGE(!ERROR_STATE.msg, TITLE='URL Error', $
         /ERROR)
      PRINT, !ERROR_STATE.msg

      ; get the properties that will tell us more detail about $
      ; the error.
      oUrl->GetProperty, RESPONSE_CODE=rspCode, $
         RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
      PRINT, 'rspCode = ', rspCode
      PRINT, 'rspHdr= ', rspHdr
      PRINT, 'rspFn= ', rspFn

      ; since we are done we can destroy the url object
      OBJ_DESTROY, oUrl
      RETURN
   ENDIF


   ; create a new url object
   oUrl = OBJ_NEW('IDLnetUrl')

   ; the url object will make callbacks to this pro code function
   oUrl->SetProperty, CALLBACK_FUNCTION ='Url_Callback'

   ; set VERBOSE to 1 to see more info on the transaction
   oUrl->SetProperty, VERBOSE = 1

   ; an ftp transaction
   oUrl->SetProperty, URL_SCHEME = 'ftp'

   ; The ITT VIS FTP server
   oUrl->SetProperty, URL_HOST = 'data.ittvis.com'

   ; name of dir to get directory listing for on the $
   ; remote ftp server
   oUrl->SetProperty, URL_PATH = 'doc/examples/'

   ; the appropriate username and password
   oUrl->SetProperty, URL_USERNAME = 'Anonymous'
   oUrl->SetProperty, URL_PASSWORD = ''

   ; Get the directory listing
   dirList = oUrl->GetFtpDirList()

   PRINT, ' directory listing: '
   PRINT, dirList, FORMAT='(A)'

   ; we are done so we release the url object
   OBJ_DESTROY, oUrl
END