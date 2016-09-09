--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PO_INV_PAID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PO_INV_PAID" (P_INVOICE_ID number) RETURN VARCHAR2 AS 

status varchar2(200);
c_date varchar2(20);
c_status varchar2(30);

cursor c1 is select c.check_date, c.status_lookup_code, s.due_date
from ap_invoices_all i,
ap_invoice_payments_all p,
ap_payment_Schedules_all s,
ap_checks_all c
where i.invoice_id = p.invoice_id (+)
and p.check_id = c.check_id (+)
and c.void_date is null
and s.invoice_id = i.invoice_id
and i.invoice_id = p_invoice_id;


BEGIN

for r1 in c1
loop
if r1.check_date is null then 
status := 'Unpaid, payment due:-'||r1.due_date;
else
if status is not null 
then 
status := status ||' ';
end if;

status := status ||r1.check_date||' '||r1.status_lookup_code;

end if;

end loop;

  RETURN status;
END XX_PO_INV_PAID;
 

/
