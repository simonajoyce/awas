CREATE OR REPLACE PACKAGE XX_AIB_STMT_INTERFACE_PKG
IS
     /*-- Main procedure which will be run on the submission of the concurrent request*/
PROCEDURE bank_statement_load
     (
          errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          p_input_file IN VARCHAR2
          /*-- , p_dir_path     IN     VARCHAR2*/
          ,
          p_debug IN VARCHAR2
          /*-- , p_backup_dir   IN     VARCHAR2*/
          ,
          p_option         IN VARCHAR2,
          p_Bank_Branch    IN VARCHAR2,
          p_Bank_Account   IN VARCHAR2,
          p_stmt_from      IN VARCHAR2,
          p_stmt_to        IN VARCHAR2,
          p_stmt_date_from IN VARCHAR2,
          p_stmt_date_to   IN VARCHAR2,
          p_gl_date        IN VARCHAR2,
          P_ar_activity    IN VARCHAR2,
          p_payment_method IN VARCHAR2,
          p_nsf_handling   IN VARCHAR2,
          p_display_debug  IN VARCHAR2,
          p_debug_path     IN VARCHAR2,
          p_debug_file     IN VARCHAR2 ) ;
     /*--Procedure which will upload XX_AIB Bank format file into Oracle Cash Management*/
PROCEDURE XX_AIB_bank_stmt_load
     (
          x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER,
          p_input_file IN VARCHAR2,
          p_dir_path   IN VARCHAR2 ) ;
     /*-- Procedure to validate the statement loaded into the staging table*/
     /*-- returns 0 if loaded successfully, >0 otherwise along with error message.*/
PROCEDURE validate_bank_stmt
     (
          x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER ) ;
     /*-- Procedure to load data from staging table to Cash managment interface tables.*/
     /*-- returns 0 if loaded successfully, >0 otherwise along with error message.*/
PROCEDURE interface_XX_AIB_bank_stmt_std
     (
          x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER ) ;
     /*-- Procedure to load bank balances only*/
     /*-- Procedure to write message in log file.*/
PROCEDURE write_log
     (
          p_message IN VARCHAR2 ) ;
     /*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 ) ;
     /*-- Procedure to write message on output file.*/
PROCEDURE write_out
     (
          p_message IN VARCHAR2 ) ;
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
          P_PARAMETER12 IN VARCHAR2,
          P_PARAMETER13 IN VARCHAR2,
          P_PARAMETER14 IN VARCHAR2,
          P_PARAMETER15 IN VARCHAR2,
          p_parameter16 IN VARCHAR2,
          x_request_id OUT NUMBER ) ;
     /*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2 ) ;
     /*-- procedure  to get bank name, branch name and currency for SQLLOADER call.*/
PROCEDURE get_bank_ac_details
     (
          p_sort_code        IN VARCHAR2,
          p_bank_account_num IN VARCHAR2,
          x_bank_name OUT VARCHAR2,
          x_branch_name OUT VARCHAR2,
          x_currency_code OUT VARCHAR2 ) ;
     G_DEBUG_MODE BOOLEAN DEFAULT FALSE;
     G_USER_ID    NUMBER DEFAULT FND_PROFILE.VALUE ( 'USER_ID' ) ;
     G_ORG_ID     NUMBER DEFAULT FND_PROFILE.VALUE ( 'ORG_ID' ) ;
     G_CUR_CODE   VARCHAR2 ( 30 ) DEFAULT NULL;
     L_REQUEST_ID NUMBER DEFAULT 0;
     l_phase      VARCHAR2 ( 30 ) ;
     L_CODE       VARCHAR2 ( 30 ) ;
     fileloc      VARCHAR2 ( 150 ) ;
END XX_AIB_STMT_INTERFACE_PKG;
/


CREATE OR REPLACE PACKAGE BODY XX_AIB_STMT_INTERFACE_PKG
IS
     /*--+==========================================================================+*/
     /*--| Name:         XX_AIB_STMT_INTERFACE_PKGBODY        |*/
     /*--| Description:  XX_AIB_STMT_INTERFACE_PKGbody contains the  definition |*/
     /*--|               of procedures/functions used in bank statement upload into |*/
     /*--|    Oracle Cash Management.                |*/
     /*--+==========================================================================+*/
     /*--=============================================================================*/
     /*-- Main procedure which will be run on the submission of the concurrent request*/
     g_stmt_date DATE;
PROCEDURE bank_statement_load
     (    errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          p_input_file     IN VARCHAR2,
          p_debug          IN VARCHAR2,
          p_option         IN VARCHAR2,
          p_Bank_Branch    IN VARCHAR2,
          p_Bank_Account   IN VARCHAR2,
          p_stmt_from      IN VARCHAR2,
          p_stmt_to        IN VARCHAR2,
          p_stmt_date_from IN VARCHAR2,
          p_stmt_date_to   IN VARCHAR2,
          p_gl_date        IN VARCHAR2,
          P_ar_activity    IN VARCHAR2,
          p_payment_method IN VARCHAR2,
          p_nsf_handling   IN VARCHAR2,
          p_display_debug  IN VARCHAR2,
          p_debug_path     IN VARCHAR2,
          p_debug_file     IN VARCHAR2 )
                           IS

     ---------------------------------------------------
     l_error_message          VARCHAR2 ( 1000 ) ;
     l_error_code             NUMBER;
     l_org_name               HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
     l_bank_branch            AP_BANK_BRANCHES.BANK_BRANCH_ID%TYPE;
     l_file_ext               VARCHAR2 ( 50 ) ;
     e_bank_stmt_load_failed  EXCEPTION;
     e_backup                 EXCEPTION;
     e_autorec_failed         EXCEPTION;


     CURSOR B_BRANCH is
   SELECT
                              --ABB.BANK_BRANCH_ID BRANCH_ID
                              ABB.BRANCH_party_ID BRANCH_ID
                          FROM
                              XX_CE_STMT_INT_TMP ISL,
                              --AP_BANK_ACCOUNTS_ALL ABA      ,
                              CE_BANK_ACCOUNTS ABA,
                              --AP_BANK_BRANCHES ABB,
                              CE_BANK_BRANCHES_V abb
                           WHERE
                              ISL.COLUMN3      = ABA.BANK_ACCOUNT_NUM
                              AND ABA.BANK_BRANCH_ID    = ABB.BRANCH_party_ID
                              AND ISL.REC_ID_NO = '01'
                        GROUP BY
                        ABB.BRANCH_party_ID;
                              --ABB.BANK_BRANCH_ID;
     ---------------------------------------------------
BEGIN
     fileloc           := FND_PROFILE.VALUE('AWAS_CE_STMT_DIR');
     IF p_debug         = 'Y' THEN
          G_DEBUG_MODE := TRUE;
     ELSE
          G_DEBUG_MODE := FALSE;
     END IF;
     /*-- Display concurrent Program Paramteres*/
     write_debug ( '**************************** Concurrent Program Parameteres ****************************' ) ;
     write_debug ( 'p_input_file -> '||p_input_file ) ;
     /*--  write_debug('p_dir_path   -> '||p_dir_path);*/
     write_debug ( 'p_debug      -> '||p_debug ) ;
     /*--  write_debug('p_backup_dir -> '||p_backup_dir);*/
     write_debug ( '**************************** End of Concurrent program parameters **********************' ) ;
     write_debug ( 'bank_statement_load -> Starting...' ) ;
     /*-- Get org Name*/
     BEGIN
          write_debug ( 'bank_statement_load -> Fetch l_org_name' ) ;
           SELECT
                    SUBSTR ( name, 1, 30 )
                  INTO
                    l_org_name
                  FROM
                    hr_all_organization_units
                 WHERE
                    organization_id = G_ORG_ID;

          write_debug ( 'bank_statement_load ->  fetch of l_org_name successful. l_org_name:'||l_org_name ) ;
     EXCEPTION
     WHEN OTHERS THEN
          write_log ( 'Error in fetching the organization name' ) ;
     END;
     Write_out ( l_org_name||'            AIB - Bank Statement Upload Execution Report             '||TO_CHAR ( SYSDATE, 'DD-MON-YYYY HH:MI:SS' ) ) ;
     Write_out ( '-----------------------------------------------------------------------------------------------' ) ;
     write_out ( '' ) ;

     /*-- Load the statements into cash management*/

     l_file_ext := '\XX_AIB';
     write_debug ( 'bank_statement_load -> calling XX_AIB_bank_stmt_load' ) ;
     XX_AIB_bank_stmt_load ( l_error_message, l_error_code, p_input_file, fileloc ) ;
     write_debug ( 'bank_statement_load ->returned from XX_AIB_bank_stmt_load' ) ;
     IF l_error_code <> 0 THEN
          raise e_bank_stmt_load_failed;
     ELSE
          Write_out ( 'Bank statement file transfer to Cash Management is Successful' ) ;
          Write_out ( '' ) ;
          /*
          -- utl file copy to move the file
          write_debug('p_dir_path-   '||fileloc || l_file_ext);
          write_debug('p_backup_dir- '||fileloc || '\BACKUP');
          write_debug('p_input_file- '||p_input_file);
          UTL_FILE.FCOPY(fileloc || l_file_ext, p_input_file, fileloc || '\BACKUP', p_input_file||'LOADED');
          write_debug('MID');
          UTL_FILE.FREMOVE(fileloc || l_file_ext, p_input_file);
          Write_out('Backup of the file is successful.');
          */
          IF p_option <> 'LOAD' THEN
               /*--Fetching Bank Branch Name from the file*/


                    for i in b_branch

               loop
                             l_bank_branch := i.branch_id;



               submit_conc_request ( p_application => 'CE'
                                   , p_program => 'ARPLABIR'
                                   , p_sub_request => TRUE
                                   , p_parameter1 => p_option
                                   , p_parameter2 => l_bank_branch
                                   , p_parameter3 => p_Bank_Account
                                   , P_PARAMETER4 => P_STMT_FROM
                                   , P_PARAMETER5 => P_STMT_TO
                                   , P_PARAMETER6 => TO_CHAR ( TO_DATE ( SUBSTR ( P_STMT_DATE_FROM, 1, 10 ), 'RRRR/MM/DD' ), 'RRRR-MON-DD' )
                                   , P_PARAMETER7 => TO_CHAR ( TO_DATE ( SUBSTR ( P_STMT_DATE_TO, 1, 10 ), 'RRRR/MM/DD' ), 'RRRR-MON-DD' )
                                   , P_PARAMETER8 => TO_CHAR ( TO_DATE ( SUBSTR ( P_GL_DATE, 1, 10 ), 'RRRR/MM/DD' ), 'RRRR-MON-DD' )
                                   , P_PARAMETER9 => NULL
                                   , P_PARAMETER10 => NULL
                                   , P_PARAMETER11 => P_AR_ACTIVITY
                                   , P_PARAMETER12 => P_PAYMENT_METHOD
                                   , P_PARAMETER13 => P_NSF_HANDLING
                                   , P_PARAMETER14 => P_DISPLAY_DEBUG
                                   , P_PARAMETER15 => P_DEBUG_PATH
                                   , P_PARAMETER16 => P_DEBUG_FILE
                                   , x_request_id => l_request_id ) ;
               /*-- wait till the Standard Cash management auto reconcilation program is completed*/
               IF l_request_id <> 0 THEN
                    wait_conc_request ( l_request_id, 'Wait for bank statement loader program to complete', l_phase, l_code ) ;
               ELSE
                    l_error_message := 'Failed to submit request Bank Statement Import and AutoReconciliation Program ' ;
                    raise e_autorec_failed;
               END IF;
               end loop;
               write_out ( '' ) ;
               write_out ( 'Bank Statement Import and AutoReconciliation Program completed.' ) ;
               write_out ( 'Check the output and/or logfile of the request:'|| l_request_id ) ;
          END IF;
          write_out ( '' ) ;
          write_out ( '' ) ;
          Write_out ( '                                   ****End of Report****' ) ;
     END IF;


     -----------------------------------------------------------------
     -- Complete Statements and clear trailing spaces
     -----------------------------------------------------------------
     commit;


     update CE_STATEMENT_HEADERS
     set STATEMENT_COMPLETE_FLAG = 'Y'
     where statement_complete_flag <> 'Y'
     and statement_header_id not in (select distinct statement_header_id from ce_statement_lines);


     update ce_statement_lines
     set trx_text = trim(trx_text),
          invoice_text = trim(invoice_text),
          customer_text = trim(customer_text),
          bank_account_text = trim(bank_account_text)
     where status <> 'RECONCILED';

     update CE_STATEMENT_HEADERS
     set STATEMENT_COMPLETE_FLAG = 'Y'
     where statement_header_id in (select statement_header_id from (
          select l.statement_header_id, sum(decode(status,'RECONCILED
                    ',1,'EXTERNAL',1,0)), count(status)
          from ce_statement_lines l, CE_STATEMENT_HEADERS h
          where h.statement_header_id = l.statement_header_id
          and h.statement_complete_flag <> 'Y'
          having sum(decode(l.status,'RECONCILED',1,'EXTERNAL',1,0))=count(l.status)
          group by l.statement_header_id) x);

     commit;

     -----------------------------------------------------------------



END bank_statement_load;
/*--=============================================================================*/
/*--=============================================================================*/
/*--Procedure which will upload XX_AIB Bank format file into Oracle Cash Management*/
PROCEDURE XX_AIB_bank_stmt_load
     (
          x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER,
          p_input_file IN VARCHAR2,
          p_dir_path   IN VARCHAR2 )
                       IS
     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     e_return_error  EXCEPTION;
BEGIN
     WRITE_DEBUG ( 'XX_AIB_bank_stmt_load -> Begining of procedure' ) ;
     submit_conc_request ( p_application =>'CE', p_program =>'CESLRPROAIB', p_sub_request => FALSE, p_parameter1 => p_dir_path||'/'||p_input_file, p_parameter2 => NULL, p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter15 => NULL,p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Wait for bank statement loader program to complete', l_phase, l_code ) ;
     ELSE
          x_error_message := 'Failed to submit request to load XX_AIB Bank Statement' ;
          raise e_return_error;
     END IF;
     write_log ( 'XX_AIB_bank_stmt_load -> after waiting for the request' ) ;
     IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
          write_log ( 'Bank statement Uploaded into the staging tables completed with a status of '||l_code ) ;
          /*-- validate and load this data into the standard open interface tables.*/
          validate_bank_stmt ( l_error_message, l_error_code ) ;
          write_debug ( 'Banks statement Validated with error code:(0-no errors)'|| l_error_code ) ;
          IF l_error_code = 0 THEN
               interface_XX_AIB_bank_stmt_std ( l_error_message, l_error_code ) ;
               IF l_error_code <> 0 THEN
                    write_debug ( 'Failed trasferring data to standard tables' ) ;
                    x_error_message := 'Failed trasferring data to standard tables';
                    raise e_return_error;
               ELSE
                    write_debug ( 'XX_AIB Bank Statement loaded into the standard interface tables successfully.' ) ;
               END IF;
          ELSE
               x_error_message := 'Error: Bank statement validation failed. Action: Please Correct the errors and resubmit the request';
               raise e_return_error;
          END IF;
     ELSE
          x_error_message := 'Error: Bank Statement Load failed. Action: Please look at the log file for errors';
          raise e_return_error;
     END IF;
     x_error_code := 0;
EXCEPTION
WHEN e_return_error THEN
     x_error_code := 2;
END XX_AIB_bank_stmt_load;
/*--=============================================================================*/
/*-- Procedure to validate  bank statement*/
/*--=============================================================================*/
PROCEDURE validate_bank_stmt
     (
          x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER )
IS
     CURSOR bank_stmt_headers_cur
     IS           SELECT  column3 BANK_ACCOUNT_NUM,
                    ASCII ( column3)
                  FROM
                    xx_ce_stmt_int_tmp x
                 WHERE
                    rec_id_no = '01'
                    and column3 is not null
                    AND NOT EXISTS
                    (SELECT
                              1
                           FROM
                              CE_BANK_ACCOUNTS ABA,
                              ce_BANK_BRANCHES_v ABB
                           WHERE
                              ABA.BANK_BRANCH_ID       = ABB.BRANCH_PARTY_ID
                              AND ABA.account_owner_org_id           = 85
                              AND ABA.BANK_ACCOUNT_NUM = x.column3
                    ) ;
  /*
     CURSOR trx_code_valid_cur
     IS
          SELECT DISTINCT
                    TRX_CODE,
                    BANK_ACCOUNT_NUM
                  FROM
                    XX_AIB_STMT_LINES_INTERFACE ISL
                 WHERE
                    BANK_ACCOUNT_NUM IS NOT NULL
                    AND NOT EXISTS
                    (SELECT
                              1
                            FROM
                              CE_TRANSACTION_CODES CTC,
                              AP_BANK_ACCOUNTS_ALL AAA
                           WHERE
                              CTC.BANK_ACCOUNT_ID      = AAA.BANK_ACCOUNT_ID
                              AND aaa.org_id           = 85
                              AND AAA.BANK_ACCOUNT_NUM = ISL.BANK_ACCOUNT_NUM
                              AND TRX_CODE             = ISL.TRX_CODE
                    )
         ORDER BY 2;   */

     CURSOR NULL_AMOUNTS_CUR
     IS
           SELECT
                    COUNT ( 1 )
                  FROM
                    xx_ce_stmt_int_tmp
                 WHERE
                    nvl(nvl(column5,column6),column7)               IS NULL
                    AND rec_id_no = '02';

     L_HEADER BANK_STMT_HEADERS_CUR%ROWTYPE;
     --L_TRX_CODE_VALID TRX_CODE_VALID_CUR%ROWTYPE;
     L_ZERO_AMOUNTS NUMBER DEFAULT 0;
     L_ERROR_COUNT  NUMBER DEFAULT 0;
BEGIN
     write_debug ( 'validate_bank_stmt -> Start of procedure' ) ;
     x_error_code  := 0;
     l_error_count := 0;
     /*-- validating the bank account number*/
     write_debug ( 'validate_bank_stmt -> Start validating the bank account number' ) ;
     OPEN bank_stmt_headers_cur;
     FETCH bank_stmt_headers_cur INTO l_header;

     write_debug ( 'validate_bank_stmt -> after fetch records from bank_stmt_headers_cur' ) ;
     IF bank_stmt_headers_cur%NOTFOUND THEN
          write_debug ( 'validate_bank_stmt -> Correct Bank account Numbers' ) ;
     ELSE
          write_out ( '' ) ;
          write_out ( 'The following Bank account number(s) doesnot exist' ) ;
          LOOP
               write_out ( l_header.bank_account_num ) ;
               FETCH bank_stmt_headers_cur INTO l_header;
               EXIT
          WHEN bank_stmt_headers_cur%NOTFOUND;
          END LOOP;
          x_error_message := x_error_message||'Bank Account not defined in Oracle Accounts Payable.';
          l_error_count   := l_error_count + 1;
          write_log ( 'validate_bank_stmt -> Incorrect Bank account numbers exists' ) ;
     END IF;
     CLOSE bank_stmt_headers_cur;
     write_debug ( 'validate_bank_stmt -> End validating bank account number' ) ;
     /*-- validating the trx_code from*/

     /*
     OPEN trx_code_valid_cur;
     FETCH trx_code_valid_cur INTO l_trx_code_valid;
     IF trx_code_valid_cur%NOTFOUND THEN
          write_debug ( 'validate_bank_stmt ->  Correct transaction codes' ) ;
     ELSE
          write_out ( '' ) ;
          write_out ( 'The following bank transaction codes do not exist' ) ;
          LOOP
               write_out ( 'Bank Account->'||l_trx_code_valid.bank_account_num||'  Transaction Code -> '||l_trx_code_valid.trx_code ) ;
               FETCH trx_code_valid_cur INTO l_trx_code_valid;
               EXIT
          WHEN trx_code_valid_cur%notfound;
          END LOOP;
          x_error_message := x_error_message||' Incorrect transaction codes';
          l_error_count   := l_error_count + 1;
          write_debug ( 'validate_bank_stmt -> Incorrect transaction codes.' ) ;
          write_out ( 'Error: Bank statement contains invalid transaction codes' ) ;
     END IF;
     CLOSE trx_code_valid_cur;  */
     write_debug ( 'validate_bank_stmt -> End of validation of Trx_code' ) ;
     /*-- Validate if the amount for any of the columns is Zero*/
     write_debug ( 'validate_bank_stmt -> Start of procedure' ) ;
     OPEN null_amounts_cur;
     FETCH null_amounts_cur INTO l_zero_amounts;
     IF l_zero_amounts = 0 THEN
          write_debug ( 'No Bank statement lines with Null Amounts' ) ;
     ELSE
          write_out ( 'Error: Bank statement contains lines with NULL amounts' ) ;
          x_error_message := x_error_message||' Banks statement lines exists with NULL values.';
          l_error_count   := l_error_count + 1;
          write_debug ( 'Error: Amount Cannot be null in the bank statement lines ' ) ;
     END IF;
     CLOSE null_amounts_cur;
     write_debug ( 'validate_bank_stmt -> l_error_count:'||l_error_count ) ;
     IF l_error_count  <> 0 THEN
          x_error_code := 2;
     ELSE
          x_error_code := 0;
     END IF;
     write_debug ( 'validate_bank_stmt -> exit procedure' ) ;
EXCEPTION
WHEN OTHERS THEN
     x_error_code    := 2;
     x_error_message := 'Error:'||SQLERRM;
     write_debug ( 'validate_bank_stmt -> When Others exception' ) ;
END validate_bank_stmt;
/*--=============================================================================*/
/*--=============================================================================*/
PROCEDURE interface_XX_AIB_bank_stmt_std
     (
          x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER )
IS
     CURSOR XX_MAIN
     is    select rec_no, rec_id_no, column1, column2, column3, column4, column5, column6, column7
          from xx_ce_stmt_int_tmp
          order by rec_no;


     CURSOR XX_AIB_INTERFACE_STD
     IS
          SELECT    ISL.COLUMN23                   STATEMENT_NUMBER,
                    to_date(ISL.COLUMN23,'DD/MM/RRRR') TRX_DATE                 ,
                    ISL.COLUMN21 STMT_AC                           ,
                    SUM ( DECODE ( trx_type, 'CREDIT', 1, 'MISC_CREDIT', 1, 0 ) ) CREDIT_TRX             ,
                    SUM ( DECODE ( trx_type, 'DEBIT', 1, 'MISC_DEBIT', 1, 0 ) ) DEBIT_TRX                ,
                    SUM ( DECODE ( trx_type, 'CREDIT', isl.column27, 'MISC_CREDIT', isl.column27, 0 ) ) CREDIT_AMOUNT,
                    SUM ( DECODE ( trx_type, 'DEBIT', isl.column27, 'MISC_DEBIT', isl.column27, 0 ) ) DEBIT_AMOUNT   ,
                    sum(nvl(isl.column7,0)) control_end_balance,
                    ABA.BANK_ACCOUNT_NUM                                                                 ,
                    ABB.BANK_NAME                                                                        ,
                    ABB.BANK_BRANCH_NAME                                                                 ,
                    ABA.CURRENCY_CODE                                                                    ,
                    ABA.BANK_ACCOUNT_ID
                  FROM
                    XX_CE_STMT_INT_TMP   ISL,
                    CE_BANK_ACCOUNTS ABA      ,
                    CE_BANK_BRANCHES_V ABB          ,
                    CE_TRANSACTION_CODES CTC
                 WHERE
                    ISL.COLUMN21      = ABA.BANK_ACCOUNT_NUM
                    AND ABA.BANK_BRANCH_ID    = ABB.BRANCH_PARTY_ID
                    and ABA.ACCOUNT_OWNER_ORG_ID = 85
                    AND ISL.column26          = upper(CTC.TRX_CODE(+))
                    AND NVL(CTC.BANK_ACCOUNT_ID,ABA.BANK_ACCOUNT_ID)   = ABA.BANK_ACCOUNT_ID
                    AND ISL.REC_ID_NO = '02'
                 GROUP BY
                    ISL.COLUMN21
                    ||'-'
                    ||ISL.column23      ,
                    ABA.BANK_ACCOUNT_NUM,
                    ABB.BANK_BRANCH_NAME,
                    ABB.BANK_NAME       ,
                    ABA.CURRENCY_CODE   ,
                    ISL.column23        ,
                    ISL.column21,
                    ABA.BANK_ACCOUNT_ID
                    order by isl.column21,to_date(ISL.COLUMN23,'DD/MM/RRRR') ;




     L_XX_AIB_INTERFACE_STD XX_AIB_INTERFACE_STD%ROWTYPE;
     L_STATMENT_EXISTS CHAR ( 1 ) DEFAULT 'N';
     l_STMT_NUM        NUMBER;
     L_STMT            VARCHAR2(200);
     L_ACCOUNT         VARCHAR2(200);
     L_ACC_NAME        VARCHAR2(200);
     L_SORT_CODE       VARCHAR2(200);
     L_REC_NO          NUMBER;
     L_TRX_DATE        VARCHAR2(200);
     L_TRX_TEXT        VARCHAR2(200);
     L_CURRENCY        VARCHAR2(200);

BEGIN
     write_debug ( 'interface_XX_AIB_bank_stmt_std-> Begining of the procedure' ) ;

     FOR i IN XX_MAIN
     LOOP

     IF i.rec_id_no = '01' THEN
     L_ACC_NAME     := i.column4;
     L_ACCOUNT      := i.column3;
     L_SORT_CODE    := i.column2;
     L_REC_NO       := i.rec_no;

     update xx_ce_stmt_int_tmp
     set  column20 = L_SORT_CODE
     ,    column21 = L_ACCOUNT
     ,    column22 = L_ACC_NAME
     where rec_no = L_REC_NO;

     COMMIT;

     ELSE IF i.rec_id_no = '02' THEN
     L_REC_NO       := i.rec_no;
     L_TRX_DATE     := i.column1;
     L_CURRENCY     := i.column4;
     L_TRX_TEXT     := i.column3;


     update xx_ce_stmt_int_tmp
     set  column20 = L_SORT_CODE
     ,    column21 = L_ACCOUNT
     ,    column22 = L_ACC_NAME
     ,    column23 = L_TRX_DATE
     ,    column24 = L_CURRENCY
     ,    COLUMN25 = L_TRX_TEXT
     ,    column26 = decode(column2,null,'BALANCE',decode(column5,null,'RECEIPT','Payment'))
     ,    column27 = nvl(column5,column6)
     where rec_no = L_REC_NO;
     
     update XX_CE_STMT_INT_TMP
     set COLUMN26 = DECODE(SUBSTR(COLUMN3,1,7),'IBB-QTR','Payment',COLUMN26) 
     where rec_no = L_REC_NO;

     commit;
     end if;
     end if;

     end loop;


     OPEN XX_AIB_INTERFACE_STD;
     LOOP
          FETCH XX_AIB_INTERFACE_STD INTO L_XX_AIB_INTERFACE_STD;
          EXIT
     WHEN XX_AIB_INTERFACE_STD%NOTFOUND;
          /*-- GENERATE STATEMENT NUMBER*/

           INSERT
                  INTO
                    CE_STATEMENT_HEADERS_INT      -- R12
                    (
                         STATEMENT_NUMBER     ,
                         BANK_ACCOUNT_NUM     ,
                         BANK_NAME            ,
                         BANK_BRANCH_NAME     ,
                         STATEMENT_DATE       ,
                         CURRENCY_CODE        ,
                         ORG_ID               ,
                         CONTROL_TOTAL_DR     ,
                         CONTROL_TOTAL_CR     ,
                         CONTROL_DR_LINE_COUNT,
                         CONTROL_CR_LINE_COUNT,
                         RECORD_STATUS_FLAG   ,
                         CREATED_BY           ,
                         CREATION_DATE        ,
                         LAST_UPDATED_BY      ,
                         LAST_UPDATE_DATE     ,
                         CONTROL_END_BALANCE
                    )
                    VALUES
                    (
                         L_XX_AIB_INTERFACE_STD.STATEMENT_NUMBER,
                         L_XX_AIB_INTERFACE_STD.BANK_ACCOUNT_NUM,
                         L_XX_AIB_INTERFACE_STD.BANK_NAME       ,
                         L_XX_AIB_INTERFACE_STD.BANK_BRANCH_NAME,
                         L_XX_AIB_INTERFACE_STD.TRX_DATE        ,
                         L_XX_AIB_INTERFACE_STD.CURRENCY_CODE   ,
                         G_ORG_ID                              ,
                         L_XX_AIB_INTERFACE_STD.DEBIT_AMOUNT    ,
                         L_XX_AIB_INTERFACE_STD.CREDIT_AMOUNT   ,
                         L_XX_AIB_INTERFACE_STD.DEBIT_TRX       ,
                         L_XX_AIB_INTERFACE_STD.CREDIT_TRX      ,
                         'N'                                   ,
                         G_USER_ID                             ,
                         SYSDATE                               ,
                         G_USER_ID                             ,
                         SYSDATE                                 ,
                         L_XX_AIB_INTERFACE_STD.CONTROL_END_BALANCE
                    ) ;

           INSERT
                  INTO
                    CE_STATEMENT_LINES_INTERFACE
                    (
                         BANK_ACCOUNT_NUM,
                         STATEMENT_NUMBER,
                         LINE_NUMBER     ,
                         CURRENCY_CODE   ,
                         AMOUNT          ,
                         BANK_TRX_NUMBER ,
                         TRX_DATE        ,
                         TRX_CODE        ,
                         TRX_TEXT        ,
                         CREATED_BY      ,
                         CREATION_DATE   ,
                         LAST_UPDATED_BY ,
                         LAST_UPDATE_DATE,
                         CUSTOMER_TEXT
                    )
           SELECT             L_XX_AIB_INTERFACE_STD.BANK_ACCOUNT_NUM,
                    L_XX_AIB_INTERFACE_STD.STATEMENT_NUMBER,
                    L.REC_NO                               ,
                    L_XX_AIB_INTERFACE_STD.CURRENCY_CODE   ,
                    to_number(L.COLUMN27)                  ,
                    NULL                     ,
                    to_date(L.column23,'DD/MM/RRRR')       ,
                    L.column26                            ,
                    l.column25                              ,
                    G_USER_ID                             ,
                    SYSDATE                               ,
                    G_USER_ID                             ,
                    SYSDATE                               ,
                    null
                  FROM   XX_ce_stmt_int_tmp L
                 WHERE  L.column21      = L_XX_AIB_INTERFACE_STD.STMT_AC
                    AND L.rec_id_no = '02'
                    and l.column26 <> 'BALANCE'
                    AND L.column21||l.COLUMN23 = L_XX_AIB_INTERFACE_STD.STMT_AC||L_XX_AIB_INTERFACE_STD.STATEMENT_NUMBER;


          WRITE_LOG ( 'No of statement lines for the Bank account: '||L_XX_AIB_INTERFACE_STD.STMT_AC||' '||sql%rowcount ) ;
     END LOOP;
     CLOSE XX_AIB_INTERFACE_STD;
     write_debug ( 'interface_XX_AIB_bank_stmt_std->  End of procedure' ) ;

EXCEPTION
WHEN OTHERS THEN
     write_log ( 'Error in inserting into Standard interface tables' ) ;
     write_out ( 'Sql Error: '||sqlerrm ) ;
     ROLLBACK;
     x_error_code    := 2;
     x_error_message := 'Error in inserting records into Cash Management tables';
     --CLOSE XX_AIB_INTERFACE_STD;
END interface_XX_AIB_bank_stmt_std;


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
     IF G_debug_mode THEN
          fnd_file.put_line ( fnd_file.log, p_message ) ;
     END IF;
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
PROCEDURE get_bank_ac_details
     (
          p_sort_code        IN VARCHAR2,
          p_bank_account_num IN VARCHAR2,
          x_bank_name OUT VARCHAR2,
          x_branch_name OUT VARCHAR2,
          x_currency_code OUT VARCHAR2 )
IS
BEGIN
     write_debug ( 'get_bank_ac_details -> Start' ) ;
     write_debug ( 'get_bank_ac_details -> sort_code:'||p_sort_code ) ;
     write_debug ( 'get_bank_ac_details -> bank_account_number:'||p_bank_account_num ) ;
      SELECT
               abaa.currency_code,
               abb.bank_name     ,
               abb.bank_branch_name
             INTO
               x_currency_code,
               x_bank_name    ,
               x_branch_name
             FROM
               CE_BANK_ACCOUNTS ABAA,
               CE_BANK_BRANCHES_V ABB
            WHERE
               ABAA.BANK_BRANCH_ID       = ABB.BRANCH_PARTY_ID
               AND abaa.bank_account_num = p_bank_account_num;
               

     write_debug ( 'get_bank_ac_details -> x_bank_name:'||x_bank_name ) ;
     write_debug ( 'get_bank_ac_details -> x_branch_name:'||x_branch_name ) ;
     write_debug ( 'get_bank_ac_details -> x_currency_code: '||x_currency_code ) ;
     write_debug ( 'get_bank_ac_details -> end' ) ;
EXCEPTION
WHEN OTHERS THEN
     x_bank_name     := NULL;
     x_branch_name   := NULL;
     x_currency_code := NULL;
     write_debug ( 'Error in fetching the Bank Details'||sqlerrm ) ;
END;
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
          P_PARAMETER12 IN VARCHAR2,
          p_parameter13 IN VARCHAR2,
          P_PARAMETER14 IN VARCHAR2,
          P_PARAMETER15 IN VARCHAR2,
          P_PARAMETER16 IN VARCHAR2,
          x_request_id OUT NUMBER )
IS
BEGIN
     WRITE_DEBUG ( 'submit_conc_request -> begining' ) ;
     X_REQUEST_ID   := FND_REQUEST.SUBMIT_REQUEST ( APPLICATION=>P_APPLICATION
                                                    , PROGRAM =>P_PROGRAM
                                                    , SUB_REQUEST=>FALSE
                                                    , ARGUMENT1 =>P_PARAMETER1
                                                    , ARGUMENT2 =>P_PARAMETER2
                                                    , ARGUMENT3 =>P_PARAMETER3
                                                    , ARGUMENT4 =>P_PARAMETER4
                                                    , ARGUMENT5 =>P_PARAMETER5
                                                    , ARGUMENT6 =>P_PARAMETER6
                                                    , ARGUMENT7 =>P_PARAMETER7
                                                    , ARGUMENT8 =>P_PARAMETER8
                                                    , ARGUMENT9 =>P_PARAMETER9
                                                    , ARGUMENT10 =>P_PARAMETER10
                                                    , ARGUMENT11 =>P_PARAMETER11
                                                    , ARGUMENT12 =>P_PARAMETER12
                                                    , ARGUMENT13 =>P_PARAMETER13
                                                    , ARGUMENT14 =>P_PARAMETER14
                                                    , ARGUMENT15 =>P_PARAMETER15
                                                    , argument16 =>p_parameter16 ) ;
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
END XX_AIB_STMT_INTERFACE_PKG;
/
