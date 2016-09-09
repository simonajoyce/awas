--------------------------------------------------------
--  File created - Wednesday-August-03-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View ARBPA_AWAS_TRX_HEADER
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."ARBPA_AWAS_TRX_HEADER" ("CUSTOMER_TRX_ID", "TRX_NAME", "TRX_TYPE", "DUE_DATE", "MSN", "TRX_CURRENCY", "INTEREST_PERIOD_DAYS") AS 
  select ct.customer_trx_id
       ,      nvl(TT.DESCRIPTION, TT.NAME)   TRX_NAME
       ,      decode(tt.type,'INV','Invoice','Credit Memo') TRX_TYPE
       ,      'Payment on this Invoice is due on '||to_char(ps.DUE_DATE,'DD-MON-YY') Due_DATE
       ,      site.location MSN
       ,     ct.invoice_currency_code TRX_CURRENCY
       ,  (select INTEREST_PERIOD_DAYS from   hz_customer_profiles cp_site  where  cp_site.site_use_id    = ct.BILL_TO_SITE_USE_ID and    cp_site.cust_account_id    = ct.BILL_TO_CUSTOMER_ID) INTEREST_PERIOD_DAYS
       from ra_customer_trx_all ct,
       ra_cust_trx_types_all tt,
       AR_PAYMENT_SCHEDULES_ALL ps,
       HZ_CUST_SITE_USES site
       where ct.cust_trx_type_id = tt.cust_trx_type_id
       and cT.CUSTOMER_TRX_ID = ps.CUSTOMER_TRX_ID
       and ct.BILL_TO_SITE_USE_ID = site.SITE_USE_ID;
