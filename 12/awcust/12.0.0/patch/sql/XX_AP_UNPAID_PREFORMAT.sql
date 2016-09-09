--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_AP_UNPAID_PREFORMAT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_AP_UNPAID_PREFORMAT" ("VENDOR_NAME", "VENDOR_NUM", "VENDOR_SITE_CODE", "INVOICE_NUM", "INVOICE_DATE", "CURR", "INVOICE_AMOUNT", "PAYGROUP", "PAID", "PREFORMAT_CODE", "HOLD_COUNT") AS 
  SELECT v.vendor_name,
    v.segment1 vendor_num,
    s.vendor_site_code,
    i.invoice_num,
    i.invoice_date,
    i.payment_currency_code CURR,
    i.invoice_amount,
    i.pay_group_lookup_code PAYGROUP,
    i.payment_status_flag PAID,
    xx_ap_find_preformat(v.vendor_id ,s.vendor_site_id,i.payment_currency_code, DECODE(i.pay_group_lookup_code, 'EMPLOYEES', DECODE(i.payment_currency_code,'EUR','12356005', 'USD','36782104', 'SGD','819942005', 'X'), NVL(b.bank_account_num,'X')),'PREFORMAT') Preformat_code,
    (select count(*) from ap_holds_all where invoice_id = i.invoice_id and release_lookup_code is null) HOLDS
  FROM ap_invoices_all i,
    po_vendors v,
    po_vendor_sites_all s,
    fnd_lookup_values lv,
    ap_bank_accounts_all b
  WHERE v.vendor_id         = i.vendor_id
  AND s.vendor_site_id      = i.vendor_site_id
  AND i.org_id              = 85
  AND i.invoice_amount     <> 0
  AND lv.lookup_code        = i.pay_group_lookup_code
  AND lv.lookup_type        = 'PAY GROUP'
  AND b.bank_account_id (+) = lv.attribute1
 ;
