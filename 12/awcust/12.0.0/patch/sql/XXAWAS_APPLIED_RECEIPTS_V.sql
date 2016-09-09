--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XXAWAS_APPLIED_RECEIPTS_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_APPLIED_RECEIPTS_V" ("MSN", "CUSTOMER_NAME", "NAME", "GL_PERIOD", "AMOUNT_APPLIED") AS 
  (
SELECT T.INTERFACE_HEADER_ATTRIBUTE1 MSN,
       substr(p.party_name,1,50) customer_name, 
       tt.name,
       to_char(gl_date,'MON-YY') GL_PERIOD,
       sum(a.amount_applied) amount_applied 
from ar_receivable_applications_all a,
     ra_customer_trx_all t,
     RA_CUST_TRX_TYPES_ALL TT,
     HZ_CUST_ACCOUNTS C,
     hz_parties p
WHERE A.APPLIED_CUSTOMER_TRX_ID = T.CUSTOMER_TRX_ID
AND C.CUST_ACCOUNT_ID = T.PAYING_CUSTOMER_ID
and c.party_id = p.party_id
and a.application_type = 'CASH'
and a.set_of_books_id = '8'
AND T.CUST_TRX_TYPE_ID = TT.CUST_TRX_TYPE_ID
GROUP BY T.INTERFACE_HEADER_ATTRIBUTE1,
       p.party_name, 
       TT.NAME,
       to_char(gl_date,'MON-YY'))
 ;
