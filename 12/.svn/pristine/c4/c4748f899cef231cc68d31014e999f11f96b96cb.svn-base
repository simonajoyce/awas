--------------------------------------------------------
--  File created - Friday-January-02-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GET_INTERMEDIARY_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GET_INTERMEDIARY_ACCT" 
(
  P_BANK_ACCT_ID IN NUMBER 
) RETURN VARCHAR2 AS 

RETVAL varchar2(2000);

-- Used in APPPAY report to show intermediary details

cursor C1 is select * 
             from IBY_INTERMEDIARY_ACCTS
             where BANK_ACCT_ID = P_BANK_ACCT_ID
             and object_version_number = (select max(object_version_number) from iby_intermediary_accts where bank_acct_id= p_bank_acct_id);

BEGIN

for R1 in C1 LOOP

    if R1.BANK_NAME is not null then RETVAL := RETVAL||'Int Acc Bank Name: '||R1.BANK_NAME||CHR(13); end if;
    if R1.COUNTRY_CODE is not null then RETVAL := RETVAL||'Int Acc Country: '||R1.COUNTRY_CODE||CHR(13); end if;
    if R1.BANK_CODE is not null then RETVAL := RETVAL||'Int Acc Bank Code: '||R1.BANK_CODE||CHR(13); end if;
    if R1.BRANCH_NUMBER is not null then RETVAL := RETVAL||'Int Acc Branch Num: '||R1.BRANCH_NUMBER||CHR(13); end if;
    if R1.BIC is not null then RETVAL := RETVAL||'Int Acc Branch BIC: '||R1.BIC||CHR(13); end if;
    if R1.ACCOUNT_NUMBER is not null then RETVAL := RETVAL||'Int Account Num: '||R1.ACCOUNT_NUMBER||CHR(13); end if;
    if R1.IBAN is not null then RETVAL := RETVAL||'Int Account IBAN: '||R1.IBAN||CHR(13); end if;
    
end LOOP;

  RETURN RETVAL;
END XX_GET_INTERMEDIARY_ACCT;

/
