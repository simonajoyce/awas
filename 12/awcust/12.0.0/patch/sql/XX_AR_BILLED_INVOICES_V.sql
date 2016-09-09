--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_AR_BILLED_INVOICES_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_AR_BILLED_INVOICES_V" ("LEASE_NO", "MSN", "CUSTOMER_NAME", "CUST_NO", "INV_NUM", "INV_TYPE", "PERIOD", "INV_DATE", "INVOICE_AMOUNT", "AMOUNT_REMAINING") AS 
  (
        SELECT    V.AIRCRAFT_LEASE_NO LEASE_NO,
                  LPAD(CTX.INTERFACE_HEADER_ATTRIBUTE1,6,0) MSN,
                  PARTY.PARTY_NAME CUSTOMER_NAME,
                  CUST.ACCOUNT_NUMBER CUST_NO,
                  PS.TRX_NUMBER INV_NUM,
                  ARPT_SQL_FUNC_UTIL.GET_TRX_TYPE_DETAILS(CTX.CUST_TRX_TYPE_ID,'NAME') INV_TYPE,
                  TO_CHAR(PS.TRX_DATE,'MON-YY') PERIOD,
                  PS.TRX_DATE INV_DATE,
                  PS.AMOUNT_DUE_ORIGINAL INVOICE_AMOUNT,
                  due_amount AMOUNT_REMAINING
        FROM 	HZ_customer_profiles      cp, 
              HZ_customer_profiles      cp1, 
              AR_COLLECTORS                    COL, 
              HZ_CUST_ACCOUNTS                   CUST, 
              HZ_PARTIES PARTY,
              RA_CUSTOMER_TRX_ALL              CTX, 
              RA_SALESREPS_ALL                    SREP, 
              (select  xx_ar_get_bal_due(payment_schedule_id,sysdate,org_id,class)     due_amount,
                                                  INVOICE_CURRENCY_CODE,
                                                  amount_due_remaining,
                                                  PAYMENT_SCHEDULE_ID,
                                                  trx_date,
                                                  trx_number,
                                                  status,
                                                  due_date,
                                                  actual_date_closed,
                                                  amount_due_original,
                                                  tax_original  ,
                                                  customer_site_use_id  ,
                                                  customer_trx_id            ,
                                                  cons_inv_id
                                        FROM      AR_PAYMENT_SCHEDULES_ALL
                                          WHERE ORG_ID = 85)   PS,
              (SELECT CUSTOMER_TRX_ID, MAX(CC.SEGMENT2) ACCOUNT FROM RA_CUST_TRX_LINE_GL_DIST_ALL GD, GL_CODE_COMBINATIONS CC
                                        WHERE GD.ACCOUNT_CLASS = 'REV'
                                        AND CC.CODE_COMBINATION_ID = GD.CODE_COMBINATION_ID
                                                  and gd.org_id = 85
                                        GROUP BY CUSTOMER_TRX_ID ) GLC,
              (select distinct aircraft_lease_no, msn, billing_customer_no from vrentalbilling@basin) V
              Where   CUST.CUST_ACCOUNT_ID             = ctx.bill_to_customer_id
              AND       CUST.PARTY_ID  =      PARTY.PARTY_ID
              AND       CTX.CUSTOMER_TRX_ID      = PS.CUSTOMER_TRX_ID
              AND       nvl(V.BILLING_CUSTOMER_NO,CUST.ACCOUNT_NUMBER)   = CUST.ACCOUNT_NUMBER
              and       nvl(lpad(v.msn,6,'0'),lpad(ctx.interface_header_attribute1,6,'0')) = lpad(ctx.interface_header_attribute1,6,'0')
              and       ctx.primary_salesrep_id  = srep.salesrep_id (+)
              and       cp.CUST_ACCOUNT_ID     = CUST.CUST_ACCOUNT_ID
              AND       CP.SITE_USE_ID IS NULL
              AND       GLC.CUSTOMER_TRX_ID = CTX.CUSTOMER_TRX_ID
              AND       ARPT_SQL_FUNC_UTIL.GET_TRX_TYPE_DETAILS(CTX.CUST_TRX_TYPE_ID,'NAME') like '%Rent%'
              and       ctx.org_id = 85
              and       cp1.site_use_id (+)          = ps.customer_site_use_id
              AND       COL.COLLECTOR_ID             = NVL(CP1.COLLECTOR_ID, CP.COLLECTOR_ID)
              )
 ;
