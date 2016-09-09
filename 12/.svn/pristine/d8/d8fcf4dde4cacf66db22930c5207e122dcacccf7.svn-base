CREATE OR REPLACE PACKAGE XX_AP_AMEX_IMPORT_PKG AS 

  PROCEDURE main
     (
          ERRBUF OUT VARCHAR2,
          retcode OUT NUMBER);
          
     l_request_id NUMBER DEFAULT 0;
     L_PHASE      VARCHAR2 ( 30 ) ;
     l_code       VARCHAR2 ( 30 ) ;

END XX_AP_AMEX_IMPORT_PKG;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AP_AMEX_IMPORT_PKG AS

PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          X_PHASE OUT VARCHAR2,
          X_CODE OUT VARCHAR2 );

PROCEDURE submit_conc_request
     (
          p_application IN VARCHAR2,
          p_program     IN VARCHAR2,
          p_sub_request IN BOOLEAN,
          p_parameter1  IN VARCHAR2,
          p_parameter2  IN VARCHAR2,
          p_parameter3  IN VARCHAR2,
          p_parameter4  IN VARCHAR2,
          p_parameter5  IN VARCHAR2,
          p_parameter6  IN VARCHAR2,
          p_parameter7  IN VARCHAR2,
          p_parameter8  IN VARCHAR2,
          p_parameter9  IN VARCHAR2,
          p_parameter10 IN VARCHAR2,
          p_parameter11 IN VARCHAR2,
          p_parameter12 IN VARCHAR2,
          p_parameter13 IN VARCHAR2,
          P_PARAMETER14 IN VARCHAR2,
          x_request_id OUT NUMBER );

PROCEDURE write_debug
     (
          P_MESSAGE IN VARCHAR2 );




  PROCEDURE main
     (
          ERRBUF OUT VARCHAR2,
          retcode OUT NUMBER) AS
  
  CURSOR C1 IS 
  select filename from xx_ap_AMEX_FILES where imported = 'N';
  
  FP VARCHAR2(256);
  X_REQUEST_ID NUMBER;
  G_DEBUG_MODE BOOLEAN;
   
  
  BEGIN
    
    FOR I IN C1 LOOP
    
    FP := '/u01/app/oracle/apps/apps_st/appl/awcust/12.0.0/AMEX/NEW/'||I.FILENAME;
    
    SUBMIT_CONC_REQUEST ( P_APPLICATION =>'SQLAP', P_PROGRAM =>'APXAMEX', P_SUB_REQUEST => FALSE, P_PARAMETER1 => FP, P_PARAMETER2 => NULL, P_PARAMETER3 => NULL, P_PARAMETER4 => NULL, P_PARAMETER5 => NULL, P_PARAMETER6 => NULL, P_PARAMETER7 => NULL, P_PARAMETER8 => NULL, P_PARAMETER9 => NULL, P_PARAMETER10 => NULL, P_PARAMETER11 => NULL, P_PARAMETER12 => NULL, P_PARAMETER13 => NULL, P_PARAMETER14 => NULL, X_REQUEST_ID =>L_REQUEST_ID ) ;
    
    
    
    IF L_REQUEST_ID <> 0 THEN
          WAIT_CONC_REQUEST ( L_REQUEST_ID, 'Waiting for American Express Transaction Loader to complete', L_PHASE, L_CODE ) ;
          update xx_ap_amex_files set imported = 'Y' where filename = i.filename;
     END IF;
     
    --move file to archive
    SUBMIT_CONC_REQUEST ( P_APPLICATION =>'AWCUST', P_PROGRAM =>'XXAMEXARCH', P_SUB_REQUEST => FALSE, P_PARAMETER1 => i.filename, P_PARAMETER2 => NULL, P_PARAMETER3 => NULL, P_PARAMETER4 => NULL, P_PARAMETER5 => NULL, P_PARAMETER6 => NULL, P_PARAMETER7 => NULL, P_PARAMETER8 => NULL, P_PARAMETER9 => NULL, P_PARAMETER10 => NULL, P_PARAMETER11 => NULL, P_PARAMETER12 => NULL, P_PARAMETER13 => NULL, P_PARAMETER14 => NULL, X_REQUEST_ID =>L_REQUEST_ID ) ;
    
    IF L_REQUEST_ID <> 0 THEN
          WAIT_CONC_REQUEST ( L_REQUEST_ID, 'Waiting for AWAS Amex move files to Archive to complete', L_PHASE, L_CODE ) ;
          update xx_ap_amex_files set archived = 'Y' where filename = i.filename;
     END IF;
     
    
    
    end loop;
    
  
  END main;
  
  PROCEDURE submit_conc_request
     (
          p_application IN VARCHAR2,
          p_program     IN VARCHAR2,
          p_sub_request IN BOOLEAN,
          p_parameter1  IN VARCHAR2,
          p_parameter2  IN VARCHAR2,
          p_parameter3  IN VARCHAR2,
          p_parameter4  IN VARCHAR2,
          p_parameter5  IN VARCHAR2,
          p_parameter6  IN VARCHAR2,
          p_parameter7  IN VARCHAR2,
          p_parameter8  IN VARCHAR2,
          p_parameter9  IN VARCHAR2,
          p_parameter10 IN VARCHAR2,
          p_parameter11 IN VARCHAR2,
          p_parameter12 IN VARCHAR2,
          p_parameter13 IN VARCHAR2,
          p_parameter14 IN VARCHAR2,
          x_request_id OUT NUMBER )
IS
BEGIN
     write_Debug ( 'submit_conc_request -> begining' ) ;
     x_request_id   := FND_REQUEST.SUBMIT_REQUEST ( application=>p_application, program =>p_program, sub_request=>FALSE, argument1 =>p_parameter1, argument2 =>p_parameter2, argument3 =>p_parameter3, argument4 =>p_parameter4, argument5 =>p_parameter5, argument6 =>p_parameter6, argument7 =>p_parameter7, argument8 =>p_parameter8, argument9 =>p_parameter9, argument10 =>p_parameter10, argument11 =>p_parameter11, argument12 =>p_parameter12, argument13 =>p_parameter13, argument14 =>p_parameter14 ) ;
     IF x_request_id = 0 THEN
          ROLLBACK;
     ELSE
          COMMIT;
     END IF;
     write_Debug ( 'submit_conc_request -> request_id :'|| x_request_id ) ;
     write_Debug ( 'submit_conc_request -> end' ) ;
END submit_conc_request;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2 )
IS
     l_request_code BOOLEAN DEFAULT FALSE;
     l_dev_phase    VARCHAR2 ( 30 ) ;
     l_dev_code     VARCHAR2 ( 30 ) ;
     l_sleep_time   NUMBER DEFAULT 15;
     l_message      VARCHAR2 ( 100 ) ;
BEGIN
     write_debug ( 'wait_conc_request -> begining' ) ;
     write_debug ( 'Waiting for ' || p_description || ' request to complete.' ) ;
     l_request_code := FND_CONCURRENT.WAIT_FOR_REQUEST ( p_request_id, l_Sleep_Time, 0, x_Phase, x_code, l_dev_phase, l_dev_code, l_Message ) ;
     write_Debug ( 'Completion code details are :- ' ) ;
     write_Debug ( 'Phase      -> '||x_Phase ) ;
     write_Debug ( 'code       -> '||x_code ) ;
     write_Debug ( 'Dev Phase  -> '||l_dev_phase ) ;
     write_Debug ( 'Dev code   -> '||l_dev_code ) ;
     write_Debug ( 'Message    -> '||l_Message ) ;
     WRITE_DEBUG ( 'wait_conc_request -> End' ) ;
END wait_conc_request;

PROCEDURE write_debug
     (
          p_message IN VARCHAR2 )
                    IS
BEGIN
     --IF G_debug_mode THEN
          FND_FILE.PUT_LINE ( FND_FILE.LOG, P_MESSAGE ) ;
     --END IF;
END write_debug;
  
  

END XX_AP_AMEX_IMPORT_PKG;
/
