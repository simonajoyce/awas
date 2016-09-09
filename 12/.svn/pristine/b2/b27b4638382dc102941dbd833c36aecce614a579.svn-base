--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AR_INVOICE_PAID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AR_INVOICE_PAID" 
(
  P_CUSTOMER_TRX_ID IN NUMBER  
) RETURN VARCHAR2 AS 
RETVAL VARCHAR2(1);
BEGIN
  select DECODE(AMOUNT_DUE_REMAINING,0,'Y','N') PAID
  INTO RETVAL
from ra_customer_trx_all t,
ar_payment_schedules_all p
where p.customer_TRX_ID = T.CUSTOMER_TRX_ID
AND T.CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID
;
  
  
  RETURN retval;
END XX_AR_INVOICE_PAID;
 

/
