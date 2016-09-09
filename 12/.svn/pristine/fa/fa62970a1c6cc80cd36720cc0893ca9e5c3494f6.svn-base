CREATE OR REPLACE PACKAGE XX_AP_CITI_PREFORMAT_PKG
AS
     /******************************************************************************
     NAME:       XX_AP_CITI_PREFORMAT_PKG
     PURPOSE:
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/10/2009  S Joyce          1. Created this package.
     ******************************************************************************/
     PROCEDURE MAIN
     (
          errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          P_PAYMENT_BATCH IN VARCHAR2 ) ;
          
     PROCEDURE ROLL_BACK
     (
          errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          P_PAYMENT_BATCH IN VARCHAR2,
          P_CC_ID         IN NUMBER ) ;
          
     FUNCTION PAY_DETAIL
          (
               CHECK_ID IN NUMBER,
               LINE_NUM IN NUMBER )
          RETURN VARCHAR2;
     END XX_AP_CITI_PREFORMAT_PKG;

 
/


CREATE OR REPLACE PACKAGE BODY XX_AP_CITI_PREFORMAT_PKG
AS
     /******************************************************************************
     NAME:       XX_AP_CITI_PREFORMAT_PKG
     PURPOSE:    This package select the correct preformat code to be used for
     citibank and creates the file to be uploaded.
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/10/2009  S Joyce          1. Created this package body.
     ******************************************************************************/
PROCEDURE MAIN
     (
          errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          P_PAYMENT_BATCH IN VARCHAR2 )
                          IS
     /*--------------------------------------------------------------------------*/
     /*-- System:       Oracle Financials   Subsystem: Generic*/
     /*--------------------------------------------------------------------------*/
     /*-- Procedure Name: MAIN*/
     /*-- Language:     PL*SQL*/
     /*--*/
     /*-- Description: This procedure extracts all the preformat payment information*/
     /*--              from an AP payment run and creates the EFT file to be uploaded*/
     /*--              into CitiDirect*/
     /*-- Created For : AWAS*/
     /*-- Created By  : Simon Joyce*/
     /*-- Date Created: 30.10.2009*/
     /*--*/
     /*-- Revision history*/
     /*-- Date        Updated By     Details*/
     /*-- ----------  -------------- --------------------------------------------*/
     /*-- 30/10/2009  S Joyce        No previous version*/
     /*--------------------------------------------------------------------------*/
     /*--*/
     /*-- Cursor to acquire all the individual payment to loop thru to create the individual*/
     /*-- payment records for the EFT file.*/
     CURSOR c_payments ( p_batch_num IN VARCHAR2 )
                                     IS
           SELECT
                    s.check_number                 ,
                    s.vendor_id                    ,
                    s.vendor_site_id ,
                    s.vendor_num customer_num      ,
                    b.bank_account_num payment_acct,
                    s.currency_code
                  FROM
                    ap_bank_accounts_all b          ,
                    ap_inv_selection_criteria_all a ,
                    ap_selected_invoice_checks_all s,
                    ap_bank_branches bb
                 WHERE
                    a.bank_account_id           = b.bank_account_id
                    AND bb.bank_branch_name (+) = b.bank_account_num
                    AND bb.bank_name LIKE '%PREFOR%'
                    AND s.checkrun_name           = a.checkrun_name
                    AND a.checkrun_name           = p_batch_num
                    AND status_lookup_code       IS NULL
                    AND UPPER ( ok_to_pay_flag ) IN ( 'Y', 'F' )
                    AND UPPER ( void_flag )       = 'N';
     /*-- Acquire the bank payment details*/
     CURSOR c_bank_details ( p_vendor_id IN VARCHAR2, p_vendor_site_id in NUMBER,p_payment_acct IN VARCHAR2, p_currency_code IN VARCHAR2 )
                                         IS
         SELECT DISTINCT   segment1                               ,
                    MAX ( bank_account_id ) bank_account_id,
                    MAX ( bank_account_num ) preformat_name,
                    MAX ( bank_num ) sort_code
                  FROM
                    (SELECT
                              v.segment1                          ,
                              ba.bank_account_id                  ,
                              ba.bank_account_num bank_account_num,
                              bb.bank_num
                            FROM
                              ap.AP_BANK_BRANCHES bb         ,
                              ap.AP_BANK_ACCOUNTS_ALL ba     ,
                              ap.ap_bank_account_uses_all bau,
                              po.po_vendors v
                           WHERE  v.vendor_id                      = p_vendor_id
                              AND v.vendor_id                  = bau.vendor_id (+)
                              and bau.vendor_site_id is null
                              AND bau.EXTERNAL_BANK_ACCOUNT_ID = ba.BANK_ACCOUNT_ID (+)
                              AND ba.bank_branch_id            = bb.bank_branch_id (+)
                              AND bb.bank_name LIKE '%PREFORMAT%'
                              AND ba.currency_code                                                     = p_currency_code
                              AND DECODE ( NVL ( bb.bank_num, p_payment_acct ), p_payment_acct, 1, 2 ) = 1
                              AND TRUNC ( NVL ( bau.start_date, sysdate ) )                           <= TRUNC ( sysdate )
                              AND TRUNC ( NVL ( bau.end_date, sysdate + 1 ) )                         >= TRUNC ( sysdate )
                              and not exists (SELECT 1
                            FROM  ap.AP_BANK_BRANCHES bb         ,
                                  ap.AP_BANK_ACCOUNTS_ALL ba     ,
                                  ap.ap_bank_account_uses_all bau,
                                  po.po_vendors v
                           WHERE  v.vendor_id                      = p_vendor_id
                              and bau.vendor_site_id           = p_vendor_site_id
                              AND v.vendor_id                  = bau.vendor_id (+)
                              AND bau.EXTERNAL_BANK_ACCOUNT_ID = ba.BANK_ACCOUNT_ID (+)
                              AND ba.bank_branch_id            = bb.bank_branch_id (+)
                              AND bb.bank_name LIKE '%PREFORMAT%'
                              AND ba.currency_code                                                     = p_currency_code
                              AND DECODE ( NVL ( bb.bank_num, p_payment_acct ), p_payment_acct, 1, 2 ) = 1
                              AND TRUNC ( NVL ( bau.start_date, sysdate ) )                           <= TRUNC ( sysdate )
                              AND TRUNC ( NVL ( bau.end_date, sysdate + 1 ) )                         >= TRUNC ( sysdate ))
 UNION ALL
 SELECT
                              v.segment1                          ,
                              ba.bank_account_id                  ,
                              ba.bank_account_num bank_account_num,
                              bb.bank_num
                            FROM
                              ap.AP_BANK_BRANCHES bb         ,
                              ap.AP_BANK_ACCOUNTS_ALL ba     ,
                              ap.ap_bank_account_uses_all bau,
                              po.po_vendors v
                           WHERE  v.vendor_id                      = p_vendor_id
                              and bau.vendor_site_id = p_vendor_site_id
                              AND v.vendor_id                  = bau.vendor_id (+)
                              AND bau.EXTERNAL_BANK_ACCOUNT_ID = ba.BANK_ACCOUNT_ID (+)
                              AND ba.bank_branch_id            = bb.bank_branch_id (+)
                              AND bb.bank_name LIKE '%PREFORMAT%'
                              AND ba.currency_code                                                     = p_currency_code
                              AND DECODE ( NVL ( bb.bank_num, p_payment_acct ), p_payment_acct, 1, 2 ) = 1
                              AND TRUNC ( NVL ( bau.start_date, sysdate ) )                           <= TRUNC ( sysdate )
                              AND TRUNC ( NVL ( bau.end_date, sysdate + 1 ) )                         >= TRUNC ( sysdate )
UNION ALL
SELECT
                         segment1,
                         NULL    ,
                         NULL    ,
                         NULL
                       FROM
                         po_vendors
                      WHERE
                         vendor_id = p_vendor_id
                    ) x
              GROUP BY
                    segment1;

          /*--Detail Record passing in the check number and the batch number*/
          CURSOR c_detail_rec ( p_check_num IN NUMBER, p_batch_num IN VARCHAR2, p_bank_acct_num IN VARCHAR2 )
                                            IS
                SELECT
                         '#US##'
                         ||TO_CHAR ( payment_date, 'YYYYMMDD' )
                         ||'###'
                         ||bank_account_num
                         ||'###'
                         ||ltrim ( TO_CHAR ( check_amount, '99999999.99' ) )
                         ||'###############'
                         || check_number
                         ||'###############################################'
                         ||'FROM '||substr(bank_account_name,1,25)||' For:'
                         ||'#'
                         ||pay_detail ( selected_check_id, 1 )
                         ||'#'
                         ||pay_detail ( selected_check_id, 2 )
                         ||'#'
                         ||pay_detail ( selected_check_id, 3 )
                         ||'###########' detail_rec                                     ,
                         lpad ( sic.checK_number, 10, ' ' )                            ,
                         sic.payment_date                                              ,
                         lpad ( sic.vendor_num, 5, ' ' )                               ,
                         rpad ( SUBSTR ( sic.vendor_name, 1, 25 ), 25, ' ' )           ,
                         rpad ( SUBSTR ( sic.vendor_site_code, 1, 15 ), 15, ' ' )      ,
                         lpad ( TO_CHAR ( sic.check_amount, '999999999.99' ), 13, ' ' ),
                         sic.currency_code
                       FROM
                         ap.ap_selected_invoice_checks_all sic,
                         ap.ap_inv_selection_criteria_all isc
                      WHERE
                         sic.check_number                  = p_check_num
                         AND sic.checkrun_name             = p_batch_num
                         AND isc.checkrun_name             = sic.checkrun_name
                         AND sic.status_lookup_code       IS NULL
                         AND UPPER ( sic.ok_to_pay_flag ) IN ( 'Y', 'F' )
                         AND UPPER ( sic.void_flag )       = 'N';
          /*-- Cursor to get the totals for all the records processed*/
          CURSOR c_all_totals ( p_batch_num IN VARCHAR2 )
                                            IS
                SELECT
                         TO_CHAR ( SUM ( check_amount ) ),
                         TO_CHAR ( COUNT ( check_amount ) )
                       FROM
                         ap.ap_selected_invoice_checks_all
                      WHERE
                         checkrun_name           = p_batch_num
                         AND status_lookup_code IS NULL
                         AND UPPER ( void_flag ) = 'N';
          /*-- Cursor to get the totals for those succesfully processed*/
          CURSOR c_good_totals ( p_batch_num IN VARCHAR2 )
                                             IS
                SELECT
                         TO_CHAR ( SUM ( check_amount ) ),
                         TO_CHAR ( COUNT ( check_amount ) )
                       FROM
                         ap.ap_selected_invoice_checks_all
                      WHERE
                         checkrun_name                 = p_batch_num
                         AND status_lookup_code       IS NULL
                         AND UPPER ( ok_to_pay_flag ) IN ( 'Y', 'F' )
                         AND UPPER ( void_flag )       = 'N';
          /*-- Cursor to get the totals for thse that failed processing*/
          CURSOR c_bad_totals ( p_batch_num IN VARCHAR2 )
                                            IS
                SELECT
                         TO_CHAR ( SUM ( check_amount ) ),
                         TO_CHAR ( COUNT ( check_amount ) )
                       FROM
                         ap.ap_selected_invoice_checks_all
                      WHERE
                         checkrun_name                     = p_batch_num
                         AND status_lookup_code           IS NULL
                         AND UPPER ( ok_to_pay_flag ) NOT IN ( 'Y', 'F' )
                         AND UPPER ( void_flag )           = 'N';
          /*-- Cursor to get the totals for those that failed processing*/
          CURSOR c_bad_records ( p_batch_num IN VARCHAR2 )
                                             IS
                SELECT
                         lpad ( vendor_num, 6, ' ' ) vendor_num,
                         vendor_name                           ,
                         check_amount                          ,
                         dont_pay_reason_code
                       FROM
                         ap.ap_selected_invoice_checks_all
                      WHERE
                         checkrun_name                     = p_batch_num
                         AND status_lookup_code           IS NULL
                         AND UPPER ( ok_to_pay_flag ) NOT IN ( 'Y', 'F' )
                         AND UPPER ( void_flag )           = 'N';
          /*-- Variables*/
          v_batch_name VARCHAR2 ( 80 ) ;
          /*-- Batch Idenfier*/
          v_trailer VARCHAR2 ( 80 ) ;
          /*-- Trailer Record*/
          v_vol_header VARCHAR2 ( 80 ) ;
          /*-- Volume Header Label*/
          v_file_header VARCHAR2 ( 80 ) ;
          /*-- File Header Label*/
          v_user_header VARCHAR2 ( 80 ) ;
          /*-- User Header Label*/
          v_pmnt_record VARCHAR2 ( 2000 ) ;
          /*-- Detailed Payment Record*/
          v_path             VARCHAR2 ( 128 ) ;
          V_FILENAME         VARCHAR2 ( 40 ) ;
          fileloc           VARCHAR2 ( 100 );
          v_error_message    VARCHAR2 ( 60 ) ;
          v_vendor_number    VARCHAR2 ( 16 ) ;
          v_SORT_CODE        VARCHAR2 ( 10 ) ;
          v_ACCOUNT_NAME     VARCHAR2 ( 80 ) ;
          v_ACCOUNT_NUMBER   VARCHAR2 ( 30 ) ;
          v_preformat_name   VARCHAR2 ( 50 ) ;
          v_bank_account_num VARCHAR2 ( 50 ) ;
          FILE_OUT utl_file.file_type;
          v_pmt_date     VARCHAR2 ( 12 ) ;
          ex_fail_pct    EXCEPTION;
          v_count        NUMBER ( 5 ) := 1;
          v_all_count    VARCHAR2 ( 20 ) ;
          v_all_total    VARCHAR2 ( 20 ) ;
          v_good_count   VARCHAR2 ( 20 ) ;
          v_good_total   VARCHAR2 ( 20 ) ;
          v_bad_count    VARCHAR2 ( 20 ) ;
          v_bad_total    VARCHAR2 ( 20 ) ;
          v_check_num_st NUMBER ( 15 ) ;
          v_check_num    VARCHAR2 ( 15 ) ;
          v_payment_date DATE;
          v_vendor_num      VARCHAR2 ( 6 ) ;
          v_vendor_name     VARCHAR2 ( 25 ) ;
          v_site            VARCHAR2 ( 15 ) ;
          v_check_amount    VARCHAR2 ( 13 ) ;
          v_cur             VARCHAR2 ( 3 ) ;
          v_bank_account_id NUMBER ( 15 ) ;
          xi varchar(7);
          i number(7);
     BEGIN
           SELECT
                    MIN ( s.check_number )
                  INTO
                    v_check_num_st
                  FROM
                    ap_selected_invoice_checks_all s
                 WHERE
                    s.checkrun_name     = p_payment_batch
                    AND s.check_number <> 0;
          
          v_filename   := 'CITI'||fnd_global.conc_request_id||'.dat';
          v_batch_name := P_PAYMENT_BATCH;
          retcode      := 0;
          errbuf       := 'No Errors';
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'AWAS CDFF file creation program.' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    ' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payment Batch: '|| v_batch_name ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    ' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payments included in file' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Line Num PaymentNum  Date     Vendor Num/Name                 Site Code       Cur   Payment Amt' ) ;
          
          fileloc := FND_PROFILE.VALUE('AWAS_AP_PAYMENT_FILE_DIR');
          
          /*-- Production*/           
         --FILE_OUT :=UTL_FILE.FOPEN( 'G:\11i\prdcomn\admin\out\PRD_dubvmpof01\Payments', v_filename, 'W');
          /*-- UAT - directory must be in UTL Directory parameters*/
          FILE_OUT           := UTL_FILE.FOPEN ( fileloc, v_filename, 'W' ) ;
          
          
          i := 1;
          
          FOR c_payments_rec IN c_payments ( v_batch_name )
          LOOP
               /*-- Acquire the bank payment details*/
               OPEN c_bank_details ( c_payments_rec.vendor_id,c_payments_rec.vendor_site_id, c_payments_rec.payment_acct, c_payments_rec.currency_code ) ;
               FETCH
                         c_bank_details
                       INTO
                         V_VENDOR_NUMBER  ,
                         v_bank_account_id,
                         v_preformat_name ,
                         v_sort_code;
               
               CLOSE c_bank_details;
               /*-- Check to see if Bank Account exists*/
               IF v_preformat_name IS NULL THEN
                    /*-- No Preformat for Supplier/Bank/Currency combination, so flag payment as held.*/
                     UPDATE
                              ap.ap_selected_invoice_checks_all ica
                         SET
                              OK_TO_PAY_FLAG       = 'N'              ,
                              dont_pay_reason_code = 'NO BANK ACCOUNT',
                              check_number         = 0
                           WHERE
                              check_number  = c_payments_rec.check_number
                              AND vendor_id = c_payments_rec.vendor_id;
                    /*-- Write info to the OUTPUT file*/
                    /*--FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Customer: '||c_payments_rec.customer_num||'  NO BANK ACCOUNT DEFINED ' ) ;*/
                    COMMIT;
               ELSE
                     UPDATE
                              ap.ap_selected_invoice_checks_all ica
                         SET
                              ica.bank_num                 = v_SORT_CODE                       ,
                              ica.bank_account_num         = v_preformat_name,
                              ica.check_number             = v_check_num_st                    ,
                              ica.external_bank_account_id = v_bank_account_id
                           WHERE
                              ica.vendor_id        = c_payments_rec.vendor_id
                              AND ica.check_number = c_payments_rec.check_number;
                    COMMIT;
                    /*--FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Customer: '||c_payments_rec.customer_num||'  BANK ACCOUNT FOUND - '||v_preformat_name ) ;*/
                    /*--FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payment Number will now be '|| v_check_num_st) ;*/
                    /*-- Put Record into EFT file.*/
                    OPEN c_detail_rec ( v_checK_num_st, v_batch_name, v_preformat_name ) ;
                    FETCH
                              c_detail_rec
                            INTO
                              v_pmnt_record ,
                              v_check_num   ,
                              v_payment_date,
                              v_vendor_num  ,
                              v_vendor_name ,
                              v_site        ,
                              v_check_amount,
                              v_cur;
                    
                    CLOSE c_detail_rec;
                    v_check_num_st := v_checK_num_st + 1;
                    
           --         FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, V_PMNT_RECORD ) ;
                    UTL_FILE.PUT_LINE ( FILE_OUT, v_pmnt_record ) ;
                    
                    
                    select rpad(i,7,' ')
                    into xi
                    from dual;
                    
                    
                    FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, xi||' '||v_check_num||' '||v_payment_date||' '||v_vendor_num||' '||v_vendor_name||' '||v_site||' '||v_cur||' '||v_check_amount ) ;
                    
               END IF;
               /*-- reset the vendor bank info.*/
               V_VENDOR_NUMBER  := NULL;
               v_SORT_CODE      := NULL;
               v_ACCOUNT_NUMBER := NULL;
          END LOOP;
          COMMIT;
          /*-- Cursor to get the totals fore all the records processed*/
          OPEN c_all_totals ( v_batch_name ) ;
          FETCH c_all_totals INTO v_all_total, v_all_count;
          
          CLOSE c_all_totals;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Total Payments Count:     '||lpad ( v_all_count, 5, ' ' ) ||'       Total Payment Amount:        '||v_all_total ) ;
          /*-- Cursor to get the totals for those succesfully processed*/
          OPEN c_good_totals ( v_batch_name ) ;
          FETCH c_good_totals INTO v_good_total, v_good_count;
          
          CLOSE c_good_totals;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Good Payments Count:      '|| lpad ( v_good_count, 5, ' ' ) ||'       Total Good Payments Amount:  '||v_good_total ) ;
          /*-- Acquire the totals for thse that failed processing*/
          OPEN c_bad_totals ( v_batch_name ) ;
          FETCH c_bad_totals INTO v_bad_total, v_bad_count;
          
          CLOSE c_bad_totals;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Failed Payment Count:     '|| lpad ( v_bad_count, 5, ' ' ) ||'       Total Failed Payment Amount: '||v_bad_total ) ;
          /*-- Send a message that the file has been created*/
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    ' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, ' CDFF Payment File created: '|| v_filename|| ' Directory: G:\11i\prdcomn\admin\out\PRD_dubvmpof01\Payments' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    ' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    ' ) ;
          FOR c_bad_rec IN c_bad_records ( v_batch_name )
          LOOP
               IF v_count = 1 THEN
                    FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'FAILED TRANSACTIONS' ) ;
                    FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Vendor Number    Vendor Name                 Failed Amount     Fail Reason' ) ;
                    v_count := v_count + 1;
               END IF;
               FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    '||c_bad_rec.vendor_num||'    '||rpad ( SUBSTR ( c_bad_rec.vendor_name, 1, 25 ), 25, ' ' ) ||'   '||lpad ( TO_CHAR ( c_bad_rec.check_amount ), 12, ' ' ) ||'      '||c_bad_rec.dont_pay_reason_code ) ;
          END LOOP;
          
          IF V_BATCH_NAME LIKE 'Quick Payment%' THEN
          
          /*-- For Quick checks with errors */
              if v_bad_count > 0 then 
              
              DELETE AP_INV_SELECTION_CRITERIA_ALL
              WHERE CHECKRUN_NAME = V_BATCH_NAME;
              
              FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Deleting row from ap.AP_INV_SELECTION_CRITERIA_ALL as format failed' ) ;
              
              DELETE AP_SELECTED_INVOICE_CHECKS_ALL
              WHERE CHECKRUN_NAME = V_BATCH_NAME;
              
              FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Deleting row(s) from ap.AP_SELECTED_INVOICE_CHECKS_ALL as format failed' ) ;
              FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Please enter the transaction manually in Citibank' ) ;
              FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Please enter the transaction manually in Citibank' ) ;
              
          
          ELSE 
          /*-- For Quick checks that are OK */              
              UPDATE ap.AP_INV_SELECTION_CRITERIA_ALL
              SET    STATUS = 'CONFIRMED'
              WHERE  CHECKRUN_NAME = V_BATCH_NAME;
              
              FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Updating the status within the ap.AP_INV_SELECTION_CRITERIA_ALL record' ) ;
              
          END IF;
          
          ELSE
          /*-- Perform the Updates for the Oracle financials table once the Payment Format file*/
          /*-- has been generated.*/
          /*-- Update status within the ap.AP_INV_SELECTION_CRITERIA_ALL record*/
          FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Updating the status within the ap.AP_INV_SELECTION_CRITERIA_ALL record' ) ;
           UPDATE
                    ap.AP_INV_SELECTION_CRITERIA_ALL
               SET
                    status = 'FORMATTED'
                 WHERE
                    checkrun_name = v_batch_name;
                    
          END IF;
          
          /*-- delete the concurrent request audit record*/
          FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Deleting AP_CHECKRUN_CONC_PROCESSES record....' ) ;
           DELETE
                  FROM
                    ap.AP_CHECKRUN_CONC_PROCESSES_ALL
                 WHERE
                    checkrun_name = v_batch_name
                    AND program   = 'FORMAT';
          COMMIT;
     EXCEPTION
     WHEN UTL_FILE.INVALID_MODE THEN
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'UTL_FILE - Invalid Mode' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.LOG, 'UTL_FILE - Invalid Mode' ) ;
          retcode := 1;
          errbuf  := 'UTL_FILE - Invalid Mode';
          ROLLBACK;
     WHEN UTL_FILE.INVALID_FILEHANDLE THEN
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'UTL_FILE - Invalid File Handle' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.LOG, 'UTL_FILE - Invalid File Handle' ) ;
          retcode := 1;
          errbuf  := 'UTL_FILE - Invalid File Handle';
          ROLLBACK;
     WHEN UTL_FILE.INVALID_PATH THEN
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Error UTL_FILE - Invalid Path ' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Error UTL_FILE - Invalid Path ' ) ;
          retcode := 1;
          errbuf  := 'Error UTL_FILE - Invalid Path ';
          ROLLBACK;
          RAISE;
     WHEN UTL_FILE.INTERNAL_ERROR THEN
          BEGIN
               FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'UTL_FILE - Internal Error' ) ;
               FND_FILE.PUT_LINE ( FND_FILE.LOG, 'UTL_FILE - Internal Error' ) ;
               retcode := 1;
               errbuf  := 'UTL_FILE - Internal Error';
               ROLLBACK;
          END;
     WHEN UTL_FILE.INVALID_OPERATION THEN
          BEGIN
               FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'UTL_FILE - Invalid Operation' ) ;
               FND_FILE.PUT_LINE ( FND_FILE.LOG, 'UTL_FILE - Invalid Operation' ) ;
               retcode := 1;
               errbuf  := 'UTL_FILE - Invalid Operation';
               ROLLBACK;
          END;
     WHEN UTL_FILE.WRITE_ERROR THEN
          BEGIN
               FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'UTL_FILE - Write Error' ) ;
               FND_FILE.PUT_LINE ( FND_FILE.LOG, 'UTL_FILE - Write Error' ) ;
               retcode := 1;
               errbuf  := 'UTL_FILE - Write Error';
               ROLLBACK;
          END;
     WHEN OTHERS THEN
          UTL_FILE.FCLOSE_ALL;
          retcode         := SQLCODE;
          errbuf          := SUBSTR ( SQLERRM, 1, 150 ) ;
          v_error_message := ' Error in CITIBANK CREATE LOCKBOX FILE';
          /*--      dbms_output.put_line( to_char(SQLCODE)||'  '||SUBSTR(SQLERRM, 1, 150));*/
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, sqlerrm||' '||v_error_message ) ;
          FND_FILE.PUT_LINE ( FND_FILE.LOG, sqlerrm||' '||v_error_message ) ;
          ROLLBACK;
     END MAIN;
     
     
     FUNCTION PAY_DETAIL
          (
               CHECK_ID IN NUMBER,
               LINE_NUM IN NUMBER )
          RETURN VARCHAR2
                                 IS
          CURSOR c1 ( p_check_id IN NUMBER )
                                 IS
                SELECT
                         invoice_num
                       FROM
                         ap_selected_invoices_all sia
                      WHERE
                         upper ( sia.ok_to_pay_flag ) IN ( 'Y', 'F' )
                         AND sia.pay_selected_check_id = p_check_id;
          
          ret_val   VARCHAR2 ( 2000 ) ;
          ret_val_1 VARCHAR2 ( 35 ) ;
          ret_val_2 VARCHAR2 ( 35 ) ;
          ret_val_3 VARCHAR2 ( 35 ) ;
          ret_val_4 VARCHAR2 ( 35 ) ;
          x         VARCHAR2 ( 35 ) ;
          l         NUMBER;
     BEGIN
          ret_val := NULL;
          --dbms_output.put_line ( 'Opening Loop' ) ;
          FOR i IN c1 ( check_id )
          LOOP
            --   dbms_output.put_line ( 'Inside Loop' ) ;
              -- dbms_output.put_line ( i.invoice_num ) ;
                SELECT
                         NVL ( LENGTH ( ret_val ), 0 ) + NVL ( LENGTH ( i.invoice_num ), 0 )
                       INTO
                         l
                       FROM
                         dual;
               
               --dbms_output.put_line ( l ) ;
               IF NVL ( LENGTH ( ret_val ), 0 ) + NVL ( LENGTH ( i.invoice_num ), 0 ) <= 2000 THEN
                    IF NVL ( LENGTH ( ret_val ), 0 )                                   = 0 THEN
                         ret_val                                                      := ret_val ||i.invoice_num;
                    ELSE
                         ret_val := ret_val ||', '||i.invoice_num;
                    END IF;
               END IF;
               --dbms_output.put_line ( ret_val ) ;
          END LOOP;
           SELECT
                    SUBSTR ( ret_val, 1, 35 ) ,
                    SUBSTR ( ret_val, 36, 35 ),
                    SUBSTR ( ret_val, 71, 35 ),
                    SUBSTR ( ret_val, 106, 35 )
                  INTO
                    ret_val_1,
                    ret_val_2,
                    ret_val_3,
                    ret_val_4
                  FROM
                    dual;
          IF line_num = 1 THEN
               x     := ret_val_1;
          ELSE
               IF line_num = 2 THEN
                    x     := ret_val_2;
               ELSE
                    IF line_num = 3 THEN
                         x     := ret_val_3;
                    ELSE
                         x := ret_val_4;
                    END IF;
               END IF;
          END IF;
          RETURN x;
     END PAY_DETAIL;
     

PROCEDURE ROLL_BACK
     (    errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          P_PAYMENT_BATCH IN VARCHAR2,
          P_CC_ID IN NUMBER)
                          IS
                          
     p_status            ap_inv_selection_criteria_all.status%Type;
     p_batch_num         ap_inv_selection_criteria_all.checkrun_name%Type;
     p_filename          VARCHAR2 (40);
     
     BEGIN
     
     p_filename := 'CITI'||p_cc_id||'.dat';
     p_batch_num := p_payment_batch;
     
      FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'AWAS CDFF Payment Batch roll back program.' ) ;
      FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '    ' ) ;
      FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payment Batch:                  '||p_batch_num) ;
      FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Concurrent request to rollback: '||p_cc_id) ;
      
          
     select status into p_status
     from ap_inv_selection_criteria_all
     where checkrun_name = p_batch_num;
     
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payment Batch has a status of '||p_status) ;
     
     if p_status in ('FORMATTED','FORMATTING') then
     
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'So attempting to rollback.....') ;
     
     
     -- First delete file.
     --DEV
     --UTL_FILE.FREMOVE ('g:\11i\devcomn\temp', P_filename);
     
     --PROD
     UTL_FILE.FREMOVE ('G:\11i\prdcomn\admin\out\PRD_dubvmpof01\Payments', P_filename);
         
     
     -- Confirm deletion in output file
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payment file '|| p_filename||' has been deleted.' ) ;
     
               
     update ap_inv_selection_criteria_all
     set status = 'BUILT'
     where checkrun_name = p_batch_num;
           
     commit;
     -- Confrim status change
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Payment Batch '|| p_payment_batch||' has been rolled back to Built status.' ) ;
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '') ;
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Rollback completed correctly, please adjust payment batch and reformat as required') ;
     else
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'So cannot rollback.') ;
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '') ;
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Only batches with a status of Formatted can be rolled back.') ;
     
     end if;
     
     
     EXCEPTION
     WHEN UTL_FILE.INVALID_OPERATION THEN
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'UTL_FILE - Invalid Operation, file probably does not exist.' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Program exiting without changing payment batch status.......' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '');
          FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, 'Check file exists before trying to rollback again.' ) ;
          FND_FILE.PUT_LINE ( FND_FILE.LOG, 'UTL_FILE - Invalid Operation, file probably does not exist.' ) ;
          retcode := 1;
          errbuf  := 'UTL_FILE - Invalid Operation,file probably does not exist.';
          ROLLBACK;
                         
                          
     END ROLL_BACK;
END XX_AP_CITI_PREFORMAT_PKG;
/
