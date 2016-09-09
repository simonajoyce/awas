--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_INVOICE_APPROVER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_INVOICE_APPROVER" (P_INVOICE_ID NUMBER) RETURN VARCHAR2 AS 


CURSOR c1 IS 
SELECT Approver_name 
FROM ap_inv_aprvl_hist_all aiah
WHERE response IN ('WFAPPROVED','MANUALLY APPROVED')
AND aiah.invoice_id = p_invoice_id
and aiah.iteration = (select max(iteration) from ap_inv_aprvl_hist_all where invoice_id = p_invoice_id)
order by aiah.approval_history_id;

retval VARCHAR2(2000);


BEGIN

retval := NULL;

FOR r1 IN c1
loop
retval := retval||r1.approver_name||',';
END loop;


  RETURN retval;
END XX_AP_INVOICE_APPROVER;
 

/
