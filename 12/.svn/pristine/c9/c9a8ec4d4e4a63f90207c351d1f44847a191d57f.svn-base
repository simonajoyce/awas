--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_GET_PO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_GET_PO" (P_INVOICE_ID number) RETURN VARCHAR2 AS 

CURSOR c1 IS
SELECT distinct poh.segment1 po_num
FROM po_headers_all poh
, po_distributions_all pda
, ap_invoice_distributions_all aid
WHERE aid.po_distribution_id = pda.po_distribution_id
AND pda.po_header_id = poh.po_header_id
and aid.invoice_id = P_INVOICE_ID;

retval varchar2(240);

BEGIN
  retval := null;
    
  FOR r1 IN c1
  loop
  retval := retval||' '||r1.po_num;
  END loop;
  
  IF retval IS NULL
  THEN retval := 'Not PO Matched';
  end if;
  
  RETURN retval;  
   

END XX_AP_GET_PO;
 

/
