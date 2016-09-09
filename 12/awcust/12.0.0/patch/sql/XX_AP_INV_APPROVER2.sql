--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_INV_APPROVER2
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_INV_APPROVER2" (p_invoice_id number) return varchar2 as 
-- this function returns a concatenate list of the approvers of an invoice.
cursor c1 is 
SELECT aiah.response, approver_name,aiah.last_update_date
from ap_inv_aprvl_hist_all aiah
WHERE aiah.invoice_id = p_invoice_id
and aiah.iteration = (select max(iteration) from ap_inv_aprvl_hist_all where invoice_id = p_invoice_id)
and aiah.response <> 'NEEDS WFREAPPROVAL'
order by aiah.approval_history_id;

retval VARCHAR2(2000);

BEGIN

retval := NULL;

FOR r1 IN c1
loop

retval := retval||' '||r1.last_update_date||' '||r1.response||' - '||r1.approver_name||chr(13);

END loop;


  return retval;
END XX_AP_INV_APPROVER2;
 

/
