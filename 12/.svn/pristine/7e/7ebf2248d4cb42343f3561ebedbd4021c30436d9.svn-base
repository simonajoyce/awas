CREATE OR REPLACE PACKAGE XX_CREATE_EMPLOYEE_SUPPLIERS
AS
/*******************************************************************************
PACKAGE NAME : XX_CREATE_EMPLOYEE_SUPPLIERS
CREATED BY   : Simon Joyce
DATE CREATED : 2009
--
PURPOSE      : Package create suppliers from employees by calling interface
               Programs etc
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
07-08-2013 SJOYCE     R12 Version
*******************************************************************************/
PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 ) ;
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 ) ;
PROCEDURE WriteLog
     (
          p_comments       IN VARCHAR2,
          p_procedure_name IN VARCHAR2,
          p_progress       IN VARCHAR2 ) ;
PROCEDURE write_output
     (
          p_message IN VARCHAR2 ) ;
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
          x_request_id OUT NUMBER ) ;
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2 ) ;
     l_request_id NUMBER DEFAULT 0;
     l_phase      VARCHAR2 ( 30 ) ;
     l_code       VARCHAR2 ( 30 ) ;
END XX_CREATE_EMPLOYEE_SUPPLIERS;

/


CREATE OR REPLACE PACKAGE BODY XX_CREATE_EMPLOYEE_SUPPLIERS
AS
     g_debug_mode  BOOLEAN;
     l_request_id2 NUMBER;
     v_request_id  NUMBER;
PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 )
IS
     CURSOR TODO
     IS
           SELECT
                    p.full_name                                                                    ,
                    p.person_id                                                                    ,
                    p.email_address                                                                ,
                    l.location_code                                                                ,
                    DECODE ( l.location_code, 'Dublin', 'EUR', 'Singapore', 'SGD', 'USD' ) CURRENCY,
                    p.effective_end_date
                  FROM
                    per_all_people_f p     ,
                    per_all_assignments_f a,
                    hr_locations l
                 WHERE
                    a.person_id (+)      = p.person_id
                    AND p.person_id NOT IN
                    ( SELECT DISTINCT
                              employee_id
                            FROM
                              po_vendors
                           WHERE
                              vendor_type_lookup_code = 'EMPLOYEE'
                              AND employee_id        IS NOT NULL
                    )
                    AND p.person_id NOT IN
                    ( select distinct employee_id from ap_suppliers_int WHERE
                              vendor_type_lookup_code = 'EMPLOYEE'
                              AND employee_id        IS NOT NULL)
               AND p.effective_end_date > sysdate
               AND a.effective_end_date > sysdate
               AND l.location_id (+)    = a.location_id;
BEGIN
     FOR r IN todo
     LOOP
           INSERT
                  INTO
                    ap_suppliers_int
                    (
                         vendor_interface_id    ,
                         vendor_name            ,
                         enabled_flag           ,
                         employee_id            ,
                         VENDOR_TYPE_LOOKUP_CODE,
                         ONE_TIME_FLAG,
                         INVOICE_CURRENCY_CODE,
                         PAYMENT_CURRENCY_CODE
                    )
                    VALUES
                    (
                         r.person_id + 1000,
                         r.full_name       ,
                         'Y'               ,
                         r.person_id       ,
                         'EMPLOYEE'        ,
                         'N',
                          R.CURRENCY        ,
                         r.currency
                    ) ;
           INSERT
                  INTO
                    ap_supplier_sites_int
                    (
                         vendor_interface_id  ,
                         vendor_site_code     ,
                         org_id               ,
                         pay_group_lookup_code,
                         terms_name           ,
                         remittance_email     ,
                         invoice_currency_code,
                         payment_currency_code
                    )
                    VALUES
                    (
                         r.person_id + 1000,
                         'WORK'        ,
                         85                ,
                         'EMPLOYEES'       ,
                         'Immediate'       ,
                         r.email_address   ,
                         r.currency        ,
                         r.currency
                    ) ;
          COMMIT;
     END LOOP;
     submit_conc_request
     (
          p_application =>'SQLAP', p_program =>'APXSUIMP', p_sub_request => FALSE, p_parameter1 => 'ALL', p_parameter2 => '1000', p_parameter3 =>'N', p_parameter4 => 'N', p_parameter5 => 'N', p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, x_request_id =>l_request_id2
     )
     ;
     submit_conc_request
     (
          p_application =>'SQLAP', p_program =>'APXSSIMP', p_sub_request => FALSE, p_parameter1 => '85', p_parameter2 => 'ALL', p_parameter3 => '1000', p_parameter4 =>'N', p_parameter5 => 'N', p_parameter6 => 'N',  p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, x_request_id =>l_request_id2
     )
     ;
      submit_conc_request
     (
          p_application =>'SQLAP', p_program =>'APXHRUPD', p_sub_request => FALSE, p_parameter1 => '8', p_parameter2 => NULL, p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, x_request_id =>l_request_id2
     )
     ;
END MAIN;
PROCEDURE WriteLog
     (
          p_comments       IN VARCHAR2,
          p_procedure_name IN VARCHAR2,
          p_progress       IN VARCHAR2
     )
IS
     PRAGMA autonomous_transaction;
BEGIN
      INSERT
             INTO
               xx_debug
               (
                    create_date   ,
                    comments      ,
                    procedure_name,
                    progress      ,
                    request_id
               )
               VALUES
               (
                    SYSDATE         ,
                    p_comments      ,
                    p_procedure_name,
                    p_progress      ,
                    v_request_id
               ) ;
     COMMIT;
END WriteLog;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to wait for a submit a request.*/
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
          x_request_id OUT NUMBER
     )
IS
BEGIN
     write_Debug
     (
          'submit_conc_request -> begining'
     )
     ;
     x_request_id := FND_REQUEST.SUBMIT_REQUEST
     (
          application=>p_application, program =>p_program, sub_request=>FALSE, argument1 =>p_parameter1, argument2 =>p_parameter2, argument3 =>p_parameter3, argument4 =>p_parameter4, argument5 =>p_parameter5, argument6 =>p_parameter6, argument7 =>p_parameter7, argument8 =>p_parameter8, argument9 =>p_parameter9, argument10 =>p_parameter10, argument11 =>p_parameter11, argument12 =>p_parameter12, argument13 =>p_parameter13, argument14 =>p_parameter14
     )
     ;
     IF x_request_id = 0 THEN
          ROLLBACK;
     ELSE
          COMMIT;
     END IF;
     write_Debug
     (
          'submit_conc_request -> request_id :'|| x_request_id
     )
     ;
     write_Debug
     (
          'submit_conc_request -> end'
     )
     ;
END submit_conc_request;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2
     )
IS
     l_request_code BOOLEAN DEFAULT FALSE;
     l_dev_phase    VARCHAR2
     (
          30
     )
     ;
     l_dev_code VARCHAR2
     (
          30
     )
     ;
     l_sleep_time NUMBER DEFAULT 15;
     l_message    VARCHAR2
     (
          100
     )
     ;
BEGIN
     write_debug
     (
          'wait_conc_request -> begining'
     )
     ;
     write_debug
     (
          'Waiting for ' || p_description || ' request to complete.'
     )
     ;
     l_request_code := FND_CONCURRENT.WAIT_FOR_REQUEST
     (
          p_request_id, l_Sleep_Time, 0, x_Phase, x_code, l_dev_phase, l_dev_code, l_Message
     )
     ;
     write_Debug
     (
          'Completion code details are :- '
     )
     ;
     write_Debug
     (
          'Phase      -> '||x_Phase
     )
     ;
     write_Debug
     (
          'code       -> '||x_code
     )
     ;
     write_Debug
     (
          'Dev Phase  -> '||l_dev_phase
     )
     ;
     write_Debug
     (
          'Dev code   -> '||l_dev_code
     )
     ;
     write_Debug
     (
          'Message    -> '||l_Message
     )
     ;
     write_debug
     (
          'wait_conc_request -> End'
     )
     ;
END wait_conc_request;
PROCEDURE write_debug
     (
          p_message IN VARCHAR2
     )
IS
BEGIN
     IF G_debug_mode THEN
          dbms_output.put_line
          (
               p_message
          )
          ;
     END IF;
END write_debug;
PROCEDURE write_output
     (
          p_message IN VARCHAR2
     )
IS
BEGIN
     FND_FILE.PUT_LINE
     (
          FND_FILE.output, p_message
     )
     ;
END WRITE_OUTPUT;
END XX_CREATE_EMPLOYEE_SUPPLIERS;
/
