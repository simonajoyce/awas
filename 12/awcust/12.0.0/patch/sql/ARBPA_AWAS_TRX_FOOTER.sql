--------------------------------------------------------
--  File created - Wednesday-August-03-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View ARBPA_AWAS_TRX_FOOTER
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."ARBPA_AWAS_TRX_FOOTER" ("CUSTOMER_TRX_ID", "BANK_ACCOUNT_NAME", "BANK_DESCRIPTION", "ADDRESS_LINE1", "ADDRESS_LINE2", "ADDRESS_LINE3", "ADDRESS_LINE4", "CREDIT_ACCOUNT", "CITY", "REFERENCE_ACCOUNT", "STATE", "ZIP", "COUNTRY", "BANK_ACCOUNT", "BRANCH_NUMBER", "ABA_NUMBER", "IBAN_NUMBER", "CORRESPONDING_BANK", "CORRESPONDING_ADDRESS", "CORRESPONDING_ACC", "CORRESPONDING_ABA", "CORRESPONDING_IBAN", "CORRESPONDING_SWIFT", "VAT_REG_NUM", "CRO_COMPANY_NUM") AS 
  select t.customer_trx_id customer_trx_id,
 CASE WHEN RM.ATTRIBUTE5 IS NULL THEN 'Account Name:'||BANK_ACCOUNT_NAME ELSE 'Account Name:'||RM.ATTRIBUTE5 END BANK_ACCOUNT_NAME,
 CASE WHEN RM.ATTRIBUTE1 IS NULL THEN 'Bank:        '||BR.DESCRIPTION    ELSE 'Bank:        '||RM.ATTRIBUTE1 END BANK_DESCRIPTION,                                  
 case when rm.attribute1 is null then address_line1 else null end address_line1,
 case when rm.attribute1 is null then address_line2 else null end address_line2,
 case when rm.attribute1 is null then address_line3 else null end address_line3,
 case when rm.attribute1 is null then address_line4 else null end address_line4,
 case when rm.attribute6 is null then null else 'Credit Account: '||rm.attribute6 end Credit_account,
 case when rm.attribute1 is null then br.city else null end city,
 case when rm.attribute7 is null then null else 'Reference Account: '||rm.attribute7 end Reference_Account,
 case when rm.attribute1 is null then br.state else null end state,
 case when rm.attribute1 is null then br.zip else null end zip,
 CASE WHEN RM.ATTRIBUTE1 IS NULL THEN br.COUNTRY ELSE NULL END COUNTRY,
 CASE WHEN RM.ATTRIBUTE1 IS NULL THEN DECODE(BANK_ACCOUNT_NUM,NULL,NULL,'Account No : '|| BANK_ACCOUNT_NUM) ELSE 'Account No:  '||RM.ATTRIBUTE4 END  BANK_ACCOUNT,
 CASE WHEN RM.ATTRIBUTE1 IS NULL THEN DECODE(BR.BANK_NUMBER,NULL,NULL,                   'Swift Code:  '||BR.BANK_NUMBER)            ELSE  decode(RM.ATTRIBUTE2,null,null,'Swift Code:  '||RM.ATTRIBUTE2) END BRANCH_NUMBER,
 CASE WHEN RM.ATTRIBUTE1 IS NULL THEN DECODE(BR.BANK_BRANCH_NAME_ALT,NULL,NULL,0,NULL,'ABA Number:  '||BR.BANK_BRANCH_NAME_ALT) ELSE decode(RM.ATTRIBUTE3,null,null,'ABA Number:  '||RM.ATTRIBUTE3) END ABA_NUMBER,
 CASE WHEN RM.ATTRIBUTE1 IS NULL THEN DECODE(A.IBAN_NUMBER,NULL,NULL,0,NULL,'IBAN Number: '||A.IBAN_NUMBER) ELSE decode(RM.ATTRIBUTE8,null,null,'IBAN Number: '||RM.ATTRIBUTE8) END IBAN_NUMBER,
 CASE WHEN RM.ATTRIBUTE10 IS NOT NULL THEN 'Corresponding Bank: '||RM.ATTRIBUTE10 ELSE NULL END CORRESPONDING_BANK,
 CASE WHEN RM.ATTRIBUTE11 IS NOT NULL THEN 'Address           : '||RM.ATTRIBUTE11 ELSE NULL END CORRESPONDING_ADDRESS,
 CASE WHEN RM.ATTRIBUTE12 IS NOT NULL THEN 'Account No.       : '||RM.ATTRIBUTE12 ELSE NULL END CORRESPONDING_ACC,
 CASE WHEN RM.ATTRIBUTE13 IS NOT NULL THEN 'ABA No.           : '||RM.ATTRIBUTE13 ELSE NULL END CORRESPONDING_ABA,
 CASE WHEN RM.ATTRIBUTE14 IS NOT NULL THEN 'IBAN No.          : '||RM.ATTRIBUTE14 ELSE NULL END CORRESPONDING_IBAN,
 CASE WHEN RM.ATTRIBUTE10 is not null then 'SWIFT Code        : '||RM.ATTRIBUTE15 else null end CORRESPONDING_SWIFT,
 acct_site.attribute6   VAT_REG_NUM
,        acct_site.attribute7   CRO_COMPANY_NUM
 from 
          CE_BANK_ACCT_USES_ALL BAU,
          CE_BANK_BRANCHES_V BR,
          ce_bank_accounts a,
          RA_CUSTOMER_TRX_all T,
          ar_receipt_method_accounts_all rma,
          ar_receipt_methods rm,
          hz_cust_acct_sites_all acct_site,
         hz_party_sites party_site,
         hz_locations loc
 where a.bank_branch_id = br.branch_party_id 
 and rm.receipt_method_id  (+) = t.receipt_method_id
 and rma.receipt_method_id (+) = rm.receipt_method_id
 and rma.end_date is null
 AND bau.BANK_acct_use_id = RMA.remit_bank_acct_use_id
 and bau.bank_account_id = a.bank_account_id
 and acct_site.party_site_id = party_site.party_site_id (+)
 and loc.location_id  (+) = party_site.location_id
 AND acct_site.cust_acct_site_ID (+)  = T.REMIT_TO_ADDRESS_ID;
