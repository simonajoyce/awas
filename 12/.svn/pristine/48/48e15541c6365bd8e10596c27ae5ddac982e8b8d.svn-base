--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_INVOICE_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_INVOICE_SOURCE" 
(
  P_INVOICE_ID IN NUMBER  
) RETURN VARCHAR2 AS 

retval varchar2(50);

BEGIN

select decode(i.source,'IMSCAN','IMSCAN',
                       'SelfService','iEXPENSES',
                       decode(    (select max(po_distribution_id) from ap_invoice_distributions_all where invoice_id = i.invoice_id   ),null,'Manual Invoice','PO Matched'))
into retval
from ap_invoices_all i
where i.invoice_id = p_invoice_id;

  return retval;
END XX_AP_INVOICE_SOURCE;
 

/
