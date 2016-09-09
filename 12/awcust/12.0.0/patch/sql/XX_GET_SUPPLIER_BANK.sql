--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GET_SUPPLIER_BANK
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GET_SUPPLIER_BANK" 
(
  P_INVOICE_ID IN NUMBER  
) RETURN NUMBER AS 

PRAGMA AUTONOMOUS_TRANSACTION;

L_SITE_ACCOUNT_ID  NUMBER;
L_VENDOR_ACCOUNT_ID NUMBER;
retval number;  

BEGIN


L_SITE_ACCOUNT_ID := NULL;
L_VENDOR_ACCOUNT_ID := NULL;

SELECT max(B.EXT_BANK_ACCOUNT_ID)
into l_vendor_account_id
FROM AP_INVOICES_ALL I,
PO_VENDORS V,
FND_LOOKUP_VALUES L,
CE_BANK_ACCOUNTS C,
ce_BANK_BRANCHES_v BB,
IBY_EXT_BANK_ACCOUNTS B,
IBY_PMT_INSTR_USES_ALL IU,
IBY_EXTERNAL_PAYEES_ALL ep
WHERE V.VENDOR_ID = I.VENDOR_ID
AND L.LOOKUP_TYPE = 'PAY GROUP'
AND L.LOOKUP_CODE = I.PAY_GROUP_LOOKUP_CODE
AND C.BANK_ACCOUNT_ID = L.ATTRIBUTE1
AND C.BANK_ACCOUNT_NUM = BB.BRANCH_NUMBER
AND B.BRANCH_ID = BB.BRANCH_Party_ID
AND I.INVOICE_ID = P_INVOICE_ID
AND B.CURRENCY_CODE = I.PAYMENT_CURRENCY_CODE
and IU.INSTRUMENT_ID = B.EXT_BANK_ACCOUNT_ID
AND IU.INSTRUMENT_TYPE = 'BANKACCOUNT'
AND IU.EXT_PMT_PARTY_ID = eP.EXT_PAYEE_ID
AND EP.PAYEE_PARTY_ID = V.PARTY_ID
AND TRUNC ( NVL ( IU.START_DATE, SYSDATE ) )                           <= TRUNC ( SYSDATE )
AND TRUNC ( NVL ( IU.END_DATE, SYSDATE + 1 ) )                         >= TRUNC ( SYSDATE );

SELECT MAX(B.EXT_BANK_ACCOUNT_ID)
into l_site_account_id
FROM AP_INVOICES_ALL I,
PO_VENDORS V,
FND_LOOKUP_VALUES L,
CE_BANK_ACCOUNTS C,
ce_BANK_BRANCHES_v BB,
IBY_EXT_BANK_ACCOUNTS B,
IBY_PMT_INSTR_USES_ALL IU,
IBY_EXTERNAL_PAYEES_ALL ep
WHERE V.VENDOR_ID = I.VENDOR_ID
AND L.LOOKUP_TYPE = 'PAY GROUP'
AND L.LOOKUP_CODE = I.PAY_GROUP_LOOKUP_CODE
AND C.BANK_ACCOUNT_ID = L.ATTRIBUTE1
AND C.BANK_ACCOUNT_NUM = BB.BRANCH_NUMBER
AND B.BRANCH_ID = BB.BRANCH_Party_ID
AND I.INVOICE_ID = P_INVOICE_ID
AND B.CURRENCY_CODE = I.PAYMENT_CURRENCY_CODE
and IU.INSTRUMENT_ID = B.EXT_BANK_ACCOUNT_ID
AND IU.INSTRUMENT_TYPE = 'BANKACCOUNT'
AND IU.EXT_PMT_PARTY_ID = eP.EXT_PAYEE_ID
AND EP.PAYEE_PARTY_ID = V.PARTY_ID
and ep.supplier_site_id = i.vendor_site_id
AND TRUNC ( NVL ( IU.START_DATE, SYSDATE ) )                           <= TRUNC ( SYSDATE )
AND TRUNC ( NVL ( IU.END_DATE, SYSDATE + 1 ) )                         >= TRUNC ( SYSDATE );


IF L_SITE_ACCOUNT_ID IS NOT NULL THEN

RETVAL := L_SITE_ACCOUNT_ID;

ELSIF L_VENDOR_ACCOUNT_ID IS NOT NULL THEN

RETVAL := L_VENDOR_ACCOUNT_ID;

ELSE

RETVAL := NULL;

end if;


  RETURN RETVAL;
  
END XX_GET_SUPPLIER_BANK;

/
