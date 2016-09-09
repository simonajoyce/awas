--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_VENDOR_SITE_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_VENDOR_SITE_LOOKUP" ("VENDOR_SITE_ID", "VENDOR", "SITE_ADDRESS") AS 
  SELECT s.vendor_site_id ,
v.vendor_name||'-'||s.vendor_site_code VENDOR,
s.invoice_Currency_code||'-'||s.address_line1||','||s.address_line2||','||s.address_line3||','||s.address_line4||','||s.city||','||s.state||','||s.zip||','||s.country SITE_ADDRESS
FROM po_vendors v, po_vendor_sites_all s
WHERE v.vendor_id = s.vendor_id
AND s.org_id = 85
AND SYSDATE < nvl(v.end_date_active,SYSDATE+1)
AND SYSDATE < nvl(s.inactive_Date,SYSDATE+1)
AND v.vendor_type_lookup_code <> 'EMPLOYEE'
order by 2
 ;
