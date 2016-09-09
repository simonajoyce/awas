--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_FIND_PREFORMAT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_FIND_PREFORMAT" (
      P_VENDOR_ID IN NUMBER
      ,
      P_VENDOR_SITE_ID IN NUMBER
      ,
      P_CURRENCY_CODE IN VARCHAR2
      ,
      P_PAYMENT_ACCT IN VARCHAR2
      ,
      P_RETURN_TYPE IN VARCHAR2)
    RETURN VARCHAR2
  AS
   /*
    REM +==================================================================+
    REM |                Copyright (c) 2013 Version 1
    REM +==================================================================+
    REM |  Name
    REM |    Function xx_ap_find_preformat
    REM |
    REM |  Description
    REM |   Function to return the citibank preformat reference for a
    REM |   specific vendor
    REM |
    REM |  History
    REM |    08-Jul-13   SJOYCE     CREATED
    REM |
    REM +==================================================================+
    */
    l_segment1 po_vendors.segment1%type;
    l_preformat ap_bank_accounts_all.bank_account_num%type;
    l_source VARCHAR2 (20);
  BEGIN
    SELECT DISTINCT
      segment1 ,
      MAX ( bank_account_num ) preformat_name,
      MAX (SOURCE)
    INTO
      l_segment1,
      l_preformat,
      l_source
    FROM
      (
        SELECT
          v.segment1 ,
          ba.bank_account_id ,
          ba.bank_account_num bank_account_num,
          bb.bank_num,
          'SUPPLIER HEADER' SOURCE
        FROM
          ap.AP_BANK_BRANCHES bb ,
          ap.AP_BANK_ACCOUNTS_ALL ba ,
          ap.ap_bank_account_uses_all bau,
          po_vendors v
        WHERE
          v.vendor_id                    = p_vendor_id
        AND v.vendor_id                  = bau.vendor_id (+)
        AND bau.vendor_site_id          IS NULL
        AND bau.EXTERNAL_BANK_ACCOUNT_ID = ba.BANK_ACCOUNT_ID (+)
        AND ba.bank_branch_id            = bb.bank_branch_id (+)
        AND bb.bank_name LIKE '%PREFORMAT%'
        AND ba.currency_code = p_currency_code
        AND DECODE ( NVL ( bb.bank_num, p_payment_acct ), p_payment_acct, 1, 2
          )                                              = 1
        AND TRUNC ( NVL ( bau.start_date, sysdate ) )   <= TRUNC ( sysdate )
        AND TRUNC ( NVL ( bau.end_date, sysdate + 1 ) ) >= TRUNC ( sysdate )
        UNION ALL
        SELECT
          v.segment1 ,
          ba.bank_account_id ,
          ba.bank_account_num bank_account_num,
          bb.bank_num,
          'SUPPLIER SITE'
        FROM
          ap.AP_BANK_BRANCHES bb ,
          ap.AP_BANK_ACCOUNTS_ALL ba ,
          ap.ap_bank_account_uses_all bau,
          po_vendors v
        WHERE
          v.vendor_id                    = p_vendor_id
        AND bau.vendor_site_id           = p_vendor_site_id
        AND v.vendor_id                  = bau.vendor_id (+)
        AND bau.EXTERNAL_BANK_ACCOUNT_ID = ba.BANK_ACCOUNT_ID (+)
        AND ba.bank_branch_id            = bb.bank_branch_id (+)
        AND bb.bank_name LIKE '%PREFORMAT%'
        AND ba.currency_code = p_currency_code
        AND DECODE ( NVL ( bb.bank_num, p_payment_acct ), p_payment_acct, 1, 2
          )                                              = 1
        AND TRUNC ( NVL ( bau.start_date, sysdate ) )   <= TRUNC ( sysdate )
        AND TRUNC ( NVL ( bau.end_date, sysdate + 1 ) ) >= TRUNC ( sysdate )
        UNION ALL
        SELECT
          segment1,
          NULL ,
          NULL ,
          NULL,
          'NO ACCOUNT DEFINED'
        FROM
          po_vendors
        WHERE
          vendor_id = p_vendor_id
      )
      x
    GROUP BY
      segment1;
    IF P_RETURN_TYPE = 'PREFORMAT' THEN
      RETURN NVL(l_preformat,'XX NO PREFORMAT XX');
    ELSE
      RETURN l_source;
    END IF;
  END XX_AP_FIND_PREFORMAT;

/
