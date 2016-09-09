--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_PO_MATCH
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_PO_MATCH" 
(
  P_INVOICE_ID IN NUMBER  
) return varchar2 as 

-- function to return a number greater than zero if invoice matched to po
retval number;

BEGIN

select count(po_distribution_id) 
into retval
                          from ap_invoice_distributions_all x
                          where x.invoice_id = p_invoice_id ;
                          
  RETURN retval;
END XX_AP_PO_MATCH;
 

/
