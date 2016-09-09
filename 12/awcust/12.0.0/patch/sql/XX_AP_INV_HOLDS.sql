--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_INV_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_INV_HOLDS" (p_invoice_id number) return varchar2 as 
-- this function returns a concatenated list of the holds on an invoice.
cursor c1 is 
select hold_date, hold_lookup_code, count(invoice_id) holds
from ap_holds_all
where invoice_id = p_invoice_id
and release_lookup_code is null
group by hold_date, hold_lookup_code;

retval VARCHAR2(2000);

BEGIN

retval := NULL;

FOR r1 IN c1
loop

retval := retval||' '||r1.hold_date||' '||r1.hold_lookup_code||' - '||r1.holds||chr(13);

END loop;


  return retval;
END XX_AP_INV_holds;
 

/
