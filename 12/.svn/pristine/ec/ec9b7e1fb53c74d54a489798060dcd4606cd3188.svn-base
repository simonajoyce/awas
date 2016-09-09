CREATE OR REPLACE PACKAGE XX_AWAS_GL_EXCHANGE_RATES

AS
/*-- Main Procedure called from Apps */
PROCEDURE MAIN     (    errorbuf OUT VARCHAR2,
                         retcode OUT VARCHAR2 );

/*-- Private Function to return web service xml*/                         
FUNCTION XX_WS_QUOTE(    Fcurr in varchar2, 
                         TCurr in varchar2) RETURN sys.xmltype;

/*-- Private Function to return Yahoo Exchange Rate*/                            
FUNCTION XX_YAHOO_RATE(  TCurr in varchar2, FCurr in varchar2) return number;

/*-- Procedure to write messages to log file*/
PROCEDURE write_log
     (
          p_message IN VARCHAR2 ) ;

/*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 ) ;

/*-- Procedure to write message in output file.*/
PROCEDURE write_out
     (
          p_message IN VARCHAR2 ) ;

/*-- Procedure to submit a concurrent request.*/
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
          p_parameter25 IN VARCHAR2,
          p_parameter27 IN VARCHAR2,
          x_request_id OUT NUMBER ) ;

/*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2 ) ;
                         
END XX_AWAS_GL_EXCHANGE_RATES;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AWAS_GL_EXCHANGE_RATES
AS
PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 )
IS
     CURSOR C1
     IS
     SELECT currency_code FROM gl_currencies 
     WHERE ATTRIBUTE1 = 'Y'
     and currency_code <> 'USD'
     ;
    
           
     CURSOR C2 (Z VARCHAR2)
     IS
     SELECT XX_ISNUMBER(Z) RESULT FROM DUAL;
     
     CURSOR C3 
     IS 
     SELECT 'USD' FROM_CUR
     FROM DUAL
     UNION ALL
     SELECT 'EUR'
     FROM DUAL
     UNION ALL
     SELECT 'SGD'
     FROM DUAL;
     
     v_RATE          NUMBER;
     l_request_id    NUMBER;
     l_phase         VARCHAR2 ( 20 ) ;
     l_code          VARCHAR2 ( 25 ) ;
     l_error_message VARCHAR2 ( 250 ) ;
BEGIN
     /*-- Clear Old Interface Data*/
     DELETE GL_DAILY_RATES_INTERFACE;
     COMMIT;
     /*-- Report headings.*/
     write_out ( 'AWAS GL CURRENCY EXCHANGE RATES Program.' ) ;
     write_out ( '' ) ;
     write_out ( 'Exchange Rates as at '||TO_CHAR ( SYSDATE, 'DD-MON-RRRR hh24:mm:ss' ) ) ;
     write_out ( '' ) ;
     write_out ( 'To add more exchange rates to this program, simply set the Download from Web flag to Yes' ) ;
     write_out ( 'in the Define Currencies window.' ) ;
     write_out ( '' ) ;
     write_out ( 'From To   Rate' ) ;
     /*-- Open Cursor to loop through currencies with attribute1 set to Y (Web Download)*/
     FOR r IN c1
     LOOP
      
          FOR X IN C3
          LOOP
          
           SELECT  xx_yahoo_rate ( x.FROM_CUR,r.currency_code )
           INTO   V_RATE
           FROM   DUAL;
           
          
          /*-- Output Rate for report*/
          write_out (rpad(x.from_cur,5,' ')||rpad ( r.currency_code, 5, ' ' ) ||lpad ( v_RATE, 10, ' ' ) ) ;
          /*-- Populate New Interface Data*/
          
          
          
          
          IF NVL(V_RATE,0) <> 0
          THEN
          FOR A IN C2(V_rate)
          LOOP
          IF A.RESULT = 1 THEN
           INSERT
                  INTO
                    GL_DAILY_RATES_INTERFACE
                    (
                         FROM_CURRENCY       ,
                         TO_CURRENCY         ,
                         FROM_CONVERSION_DATE,
                         TO_CONVERSION_DATE  ,
                         USER_CONVERSION_TYPE,
                         CONVERSION_RATE     ,
                         MODE_FLAG
                    )
                    VALUES
                    (
                         R.CURRENCY_CODE,
                         x.FROM_CUR     ,
                         sysdate        ,
                         SYSDATE+3        ,  -- insert into future
                         'Corporate'    ,
                         v_RATE         ,
                         'I'
                    ) ;
                    
        
                  COMMIT;
          END IF;
          
          END LOOP;
          END IF;
          END LOOP;
     END LOOP;
     
     delete GL_DAILY_RATES_INTERFACE where from_currency = 'EUR' and to_currency = 'SGD';
     
     /*-- Now All rates inserted, run standard Interface program - Program - Daily Rates Import and Calculation*/
     submit_conc_request
     (
          p_application => 'SQLGL', p_program => 'GLDRICCP', p_sub_request => FALSE, p_parameter1 => NULL, p_parameter2 => NULL, p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter25 => NULL, p_parameter27 => NULL, x_request_id =>l_request_id
     )
     ;
     /*-- wait till Program - Daily Rates Import and Calculation is completed*/
     IF l_request_id <> 0 THEN
          wait_conc_request
          (
               l_request_id, 'Wait for Program - Daily Rates Import and Calculation to complete', l_phase, l_code
          )
          ;
     ELSE
          l_error_message := 'Failed to submit Program - Daily Rates Import and Calculation ' ;
     END IF;
     write_out
     (
          ''
     )
     ;
     write_out
     (
          'End of'
     )
     ;
     write_out
     (
          'AWAS GL CURRENCY EXCHANGE RATES Program.'
     )
     ;
END MAIN;
FUNCTION XX_YAHOO_RATE
     (
          TCurr IN VARCHAR2, FCurr IN VARCHAR2
     )
     RETURN NUMBER
AS
     l_pieces UTL_HTTP.HTML_PIECES;
     l_two_pages VARCHAR2
     (
          4000
     )
     ;
     l_start_read NUMBER;
     l_end_read   NUMBER;
     l_quote      VARCHAR2
     (
          12
     )
     ;
     url VARCHAR2
     (
          100
     )
     ;
     
     CURSOR C2 (Z VARCHAR2)
      IS
          SELECT XX_ISNUMBER(Z) RESULT FROM DUAL;
BEGIN
     /*-- Grab up to a maxium of 32 2000-byte pages, and then go through them,*/
     /*-- looking at 2 pages at a time in case the data we are looking for*/
     /*-- overlaps a page boundary*/
     url      := 'http://finance.yahoo.com/q?s='||FCurr||TCurr||'=X';
     l_pieces := UTL_HTTP.REQUEST_PIECES
     (
          url, 32
     )
     ;
     FOR i IN 1 .. l_pieces.COUNT
     LOOP
          l_two_pages := l_two_pages || l_pieces
          (
               i
          )
          ;
          /*-- Look for a string preceding the information we want*/
          /*-- If we find it, add 44 (magic, Yahoo-specific number)*/
          /*-- to find the point where the quote will begin*/
           SELECT
                    INSTR ( l_two_pages, 'Prev Close', 1, 1 )
                  INTO
                    l_start_read
                  FROM
                    dual;
          IF ( l_start_read      > 0 ) THEN
               l_start_read     := l_start_read + 44;
               IF ( l_start_read < 3950 ) THEN
                     SELECT INSTR ( l_two_pages, '<', l_start_read, 1 ) INTO l_end_read FROM dual;
                    IF ( l_end_read                         > 0 ) THEN
                         IF ( ( l_end_read - l_start_read ) < 12 ) THEN
                               SELECT
                                        SUBSTR ( l_two_pages, l_start_read, l_end_read - l_start_read )
                                      INTO
                                        l_quote
                                      FROM
                                        dual;
                         ELSE
                              write_out ( 'Error (Quote more than 12 chars)' ) ;
                              write_log ( 'Error (Quote more than 12 chars)' ) ;
                              EXIT;
                         END IF;
                    END IF;
               END IF;
          END IF;
          l_two_pages := l_pieces ( i ) ;
     END LOOP;
     
     -- remove commas from number values
     L_QUOTE := replace(l_quote,',','');
     
     FOR Z IN C2(L_QUOTE) 
     LOOP
     IF Z.RESULT = 1 THEN     
     RETURN ( L_QUOTE ) ;
     ELSE 
     RETURN 0;
     END IF;
     
     END LOOP;
     
     
     
END xx_yahoo_rate;
FUNCTION XX_WS_QUOTE
     (
          Fcurr IN VARCHAR2,
          TCurr IN VARCHAR2 )
     RETURN sys.xmltype
     /*-- This function returns the web service html to be consumed.*/
AS
     env VARCHAR2 ( 32767 ) ;
     http_req utl_http.req;
     http_resp utl_http.resp;
     resp sys.xmltype;
     in_xml sys.xmltype;
     url VARCHAR2 ( 2000 ) := 'http://www.webservicex.net/CurrencyConvertor.asmx?wsdl';
BEGIN
     /*--    generate_envelope(req, env);*/
     env      := '<?xml version="1.0" encoding="utf-8"?>          
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">          
<soap:Body>          
<ConversionRate xmlns="http://www.webserviceX.NET/">          
<FromCurrency>'||Fcurr||'</FromCurrency>          
<ToCurrency>'||Tcurr||'</ToCurrency>          
</ConversionRate>          
</soap:Body>          
</soap:Envelope>';
     http_req := utl_http.begin_request ( url, 'POST', 'HTTP/1.1' ) ;
     utl_http.set_body_charset ( http_req, 'UTF-8' ) ;
     /*--   utl_http.set_proxy('proxy:80', NULL);*/
     /*--   utl_http.set_persistent_conn_support(TRUE);*/
     /*--   UTL_HTTP.set_authentication(http_req, '', '3', 'Basic', TRUE );*/
     utl_http.set_header ( http_req, 'Content-Type', 'text/xml' ) ;
     utl_http.set_header ( http_req, 'Content-Length', LENGTH ( env ) ) ;
     utl_http.set_header ( http_req, 'SOAPAction', 'http://www.webserviceX.NET/ConversionRate' ) ;
     utl_http.write_text ( http_req, env ) ;
     http_resp := utl_http.get_response ( http_req ) ;
     utl_http.read_text ( http_resp, env ) ;
     utl_http.end_response ( http_resp ) ;
     in_xml := sys.xmltype.createxml ( env ) ;
     resp   := xmltype.createxml ( env ) ;
     RETURN resp;
END XX_WS_QUOTE;
/*--=============================================================================*/
/*-- Procedure to submit a request*/
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
          p_parameter25 IN VARCHAR2,
          p_parameter27 IN VARCHAR2,
          x_request_id OUT NUMBER )
IS
BEGIN
     write_Debug ( 'submit_conc_request -> begining' ) ;
     x_request_id := FND_REQUEST.SUBMIT_REQUEST ( application=>p_application, program =>p_program, sub_request=>FALSE
     ) ;
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
     write_debug ( 'wait_conc_request -> End' ) ;
END wait_conc_request;
/*--=============================================================================*/
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to write message in log file.*/
PROCEDURE write_log
     (
          p_message IN VARCHAR2 )
                    IS
     l_message VARCHAR2 ( 100 ) ;
BEGIN
     l_message := SUBSTR ( p_message, 1, 100 ) ;
     fnd_file.put_line ( fnd_file.log, l_message ) ;
END write_log;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 )
                    IS
BEGIN
     fnd_file.put_line ( fnd_file.log, p_message ) ;
END write_debug;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to write message on output file.*/
PROCEDURE write_out
     (
          p_message IN VARCHAR2 )
                    IS
     l_message VARCHAR2 ( 100 ) ;
BEGIN
     l_message := SUBSTR ( p_message, 1, 100 ) ;
     fnd_file.put_line ( fnd_file.output, l_message ) ;
END write_out;
/*--=============================================================================*/
/*--=============================================================================*/
END XX_AWAS_GL_EXCHANGE_RATES;
/
