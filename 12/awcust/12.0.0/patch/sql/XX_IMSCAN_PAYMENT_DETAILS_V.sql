--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_IMSCAN_PAYMENT_DETAILS_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_IMSCAN_PAYMENT_DETAILS_V" ("INVOICE_ID", "AMOUNT", "STATUS_LOOKUP_CODE") AS 
  (
select i.attribute2 INVOICE_ID, 
       sum(nvl(p.amount,0)) AMOUNT,
       case when sum(nvl(p.amount,0))=invoice_amount then 'FULLY PAID' else case when sum(nvl(p.amount,0)) = 0 then 'UNPAID' else 'PARTIALLY PAID' end end status_lookup_code
from apps.ap_invoice_payments_all p
,    apps.ap_invoices_all i
where p.invoice_id (+) = i.invoice_id
and   i.source = 'IMSCAN'
group by i.attribute2, i.invoice_id, invoice_amount)
 ;
