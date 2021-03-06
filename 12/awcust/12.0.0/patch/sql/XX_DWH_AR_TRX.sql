--------------------------------------------------------
--  File created - Tuesday-September-01-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_DWH_AR_TRX
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_DWH_AR_TRX" ("ORACLE_UID", "LAST_UPDATE_DATE", "TYPE", "IS_TRANSACTION", "IS_APPLICATION", "PAYMENT_SCHEDULE_ID", "CUSTOMER_ID", "CUSTOMER_NAME", "CUSTOMER_NUMBER", "MSN", "CUSTOMER_TRX_ID", "TRX_DATE", "INVOICE_NO", "DUE_DATE", "AMOUNT", "DISPUTE_AMOUNT", "CURRENCY_CODE", "TRANSACTION_TYPE", "ENTITY", "GL_ACCOUNT", "GL_MSN", "GL_DATE", "PERIOD", "APP_TRANSACTION", "APP_PAYMENT_SCHEDULE_ID", "LEASE_NUMBER", "ASSET_NUMBER", "CUSTOMER_PROFILE") AS 
  select   'GLD'||gld.CUST_TRX_LINE_GL_DIST_ID ORACLE_UID,
         ps.last_update_date,
         'INVOICE' TYPE,
         'Y' IS_TRANSACTION,
         'N' IS_APPLICATION,
         ps.payment_schedule_id payment_schedule_id,
         ps.customer_id customer_id,
         substrb(party.party_name,1,50)  customer_name,
         cust_acct.account_number customer_number,
         ct.interface_header_attribute1 MSN,
         ps.customer_trx_id customer_trx_id,
         ps.trx_date trx_date,
         ps.trx_number  Invoice_No,
         ps.due_date due_date,
         nvl(gld.acctd_amount,gld.amount) AMOUNT,
         (ps.amount_in_dispute * (nvl(gld.acctd_amount,gld.amount)/ps.amount_due_original)) dispute_amount,
         ps.invoice_currency_code Currency_Code,
         tt.name transaction_type,
         CC.SEGMENT1 ENTITY ,
         cc.segment2 GL_Account ,
         cc.segment4 GL_MSN,
         gld.gl_date,
         to_char(gld.gl_date,'MON-YY') PERIOD,
         null APP_TRANSACTION,
         to_number(null) APP_PAYMENT_SCHEDULE_ID,
         csu.attribute3 LEASE_NUMBER,
         trim(translate(fv.attribute1,'AE','  '))*1 asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from     ar_payment_schedules_all ps,
         ra_customer_trx_all ct,
         hz_cust_accounts_all cust_acct,
         ra_cust_trx_types_all TT,
         ra_cust_trx_LINE_gl_dist_all gld ,
         gl_code_combinations cc ,
         AR_CUSTOMER_PROFILES_V P,
         hz_parties party,
         fnd_flex_values fv,
         hz_cust_site_uses_all CSU
where   ps.customer_trx_id      = ct.customer_trx_id
and     ct.previous_customer_trx_id is null
AND     CT.BIll_to_site_use_id = csu.site_use_id
AND     ps.customer_id = p.customer_id (+)
AND     P.SITE_USE_ID is null
AND     GLD.CUSTOMER_TRX_ID      = ct.CUSTOMER_TRX_ID
AND     GLD.ACCOUNT_CLASS       in ('REV','TAX')
and     tt.type = 'INV'
and     ps.org_id = 85
AND     gld.code_combination_id  = cc.code_combination_id
and     cust_acct.party_id = party.party_id
AND     ct.cust_trx_type_id = tt.cust_trx_type_id
and     ps.customer_id = cust_acct.cust_account_id
and     fv.flex_value_set_id = 1009476
and     fv.flex_value = cc.segment4
union all
select    'GLD'||gld.CUST_TRX_LINE_GL_DIST_ID row_id,
          ps.last_update_date,
         'CREDIT MEMO',
         'Y' IS_TRANSACTION,
         'N' IS_APPLICATION,
         ps.payment_schedule_id payment_schedule_id,
         ps.customer_id customer_id,
         substrb(party.party_name,1,50)  customer_name,
         cust_acct.account_number customer_number,
         ct.interface_header_attribute1 MSN,
         ps.customer_trx_id customer_trx_id,
         ps.trx_date trx_date,
         ps.trx_number  Invoice_No,
         ps.due_date due_date,
        nvl(gld.acctd_amount,gld.amount) AMOUNT,
        (ps.amount_in_dispute * (nvl(gld.acctd_amount,gld.amount)/ps.amount_due_original))  dispute_amount,
         ps.invoice_currency_code Currency_Code,
         tt.name transaction_type,
         CC.SEGMENT1 ENTITY ,
         cc.segment2 GL_Account ,
         cc.segment4 GL_MSN,
         gld.gl_date,
         to_char(gld.gl_date,'MON-YY') PERIOD,
         null APP_TRANSACTION,
         to_number(null) APP_PAYMENT_SCHEDULE_ID,
         csu.attribute3 LEASE_NUMBER,
         trim(translate(fv.attribute1,'AE','  '))*1 asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from     ar_payment_schedules_all ps,
         ra_customer_trx_all ct,
         hz_cust_accounts_all cust_acct,
         ra_cust_trx_types_all TT,
         ra_cust_trx_LINE_gl_dist_all gld ,
         gl_code_combinations cc ,
         AR_CUSTOMER_PROFILES_V P,
         hz_parties party,
         fnd_flex_values fv,
         hz_cust_site_uses_all CSU
where   ps.customer_trx_id      = ct.customer_trx_id
AND     GLD.CUSTOMER_TRX_ID      = ct.CUSTOMER_TRX_ID
AND     GLD.ACCOUNT_CLASS       in ('REV','TAX')
and     tt.type = 'CM'
and     ps.org_id = 85
AND     ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
AND     gld.code_combination_id  = cc.code_combination_id
and     cust_acct.party_id = party.party_id
AND     ct.cust_trx_type_id = tt.cust_trx_type_id
and     ps.customer_id = cust_acct.cust_account_id
and     fv.flex_value_set_id = 1009476
and     fv.flex_value = cc.segment4
AND     CT.BIll_to_site_use_id = csu.site_use_id
union all
select 	 'CR'||cr.CASH_RECEIPT_ID row_id,
         ps.last_update_date,
        'RECEIPT',
        'Y' IS_TRANSACTION,
         'N' IS_APPLICATION,
          ps.payment_schedule_id pay_sched_id,
          ps.customer_id customer_id,
          substrb(party.party_name,1,50)  customer_name,
          cust_acct.account_number customer_number,
         null MSN,
         cr.cash_receipt_id customer_trx_id,
         CR.RECEIPT_DATE trx_date,
         cr.receipt_number  Invoice_No,
         ps.due_date due_date,
         nvl(acctd_amount_applied_from,app.AMOUNT_applied) * -1,
         null dispute_amount,
         cr.currency_code Currency_Code,
         'Receipt' transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
           null APP_TRANSACTION,
         to_number(null) APP_PAYMENT_SCHEDULE_ID,
         to_number(null) LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_cash_receipts_all cr,
      ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      AR_CUSTOMER_PROFILES_V P,
      hz_parties party,
      hz_cust_accounts_all cust_acct
where	cr.cash_receipt_id = app.cash_receipt_id
and ps.payment_schedule_id = app.payment_schedule_id
AND ps.customer_id = p.customer_id 
AND P.SITE_USE_ID is null
and app.receivable_application_id = (select min(receivable_application_id) from ar_receivable_applications_all a where a.cash_receipt_id = cr.cash_receipt_id)
and ps.customer_id = cust_acct.cust_account_id
and	nvl( cr.confirmed_flag, 'Y' ) = 'Y'
and nvl(ps.org_id,85) = 85
and cust_acct.party_id = party.party_id
and cr.status <> 'REV'
union all
select   'ADJ'||adj.adjustment_id||'.'||gld.CUST_TRX_LINE_GL_DIST_ID row_id,
         adj.last_update_date,
         'ADJUSTMENT',
         'Y' IS_TRANSACTION,
         'N' IS_APPLICATION,
         ps.payment_schedule_id payment_schedule_id,
         ps.customer_id customer_id,
         substrb(party.party_name,1,50)  customer_name,
         cust_acct.account_number customer_number,
         ct.interface_header_attribute1 MSN,
         ps.customer_trx_id customer_trx_id,
         ps.trx_date trx_date,
         ps.trx_number  Invoice_No,
         ps.due_date due_date,
         round((gld.amount/ps.AMOUNT_DUE_ORIGINAL) *   adj.amount,2) AMOUNT,
         null dispute_amount,
         ps.invoice_currency_code Currency_Code,
         tt.name transaction_type,
	       CC.SEGMENT1 ENTITY ,
         cc.segment2 GL_Account ,
         cc.segment4 GL_MSN,
         gld.gl_date,
         to_char(gld.gl_date,'MON-YY') PERIOD,
                    null APP_TRANSACTION,
         to_number(null) APP_PAYMENT_SCHEDULE_ID,
         csu.attribute3 LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from     ar_adjustments_all adj,
         ar_payment_schedules_all ps,
         ra_customer_trx_all ct,
         hz_cust_accounts_all cust_acct,
         ra_cust_trx_types_all TT,
         ra_cust_trx_LINE_gl_dist_all gld ,
         AR_CUSTOMER_PROFILES_V P,
         gl_code_combinations cc ,
         hz_parties party,
         hz_cust_site_uses_all CSU
where   nvl(adj.postable, 'Y') = 'Y'
and     adj.payment_schedule_id = ps.payment_schedule_id
and     ps.customer_trx_id      = ct.customer_trx_id
and     ct.previous_customer_trx_id is null
AND     ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
AND     GLD.CUSTOMER_TRX_ID      = ct.CUSTOMER_TRX_ID
AND     GLD.ACCOUNT_CLASS        = 'REV'
AND     gld.code_combination_id  = cc.code_combination_id
and     cust_acct.party_id = party.party_id
and ps.AMOUNT_DUE_ORIGINAL <> 0
AND     ct.cust_trx_type_id = tt.cust_trx_type_id
and     ps.customer_id = cust_acct.cust_account_id
and     ps.org_id = 85
AND     CT.BIll_to_site_use_id = csu.site_use_id
union all
select 	 'CA'||app.receivable_application_id row_id,
         app.last_update_date,
         'CASH APPLICATION',
         'N' IS_TRANSACTION,
         'Y' IS_APPLICATION,
          ps.payment_schedule_id pay_sched_id,
          ps.customer_id customer_id,
          substrb(party.party_name,1,50)  customer_name,
          cust_acct.account_number customer_number,
         ct.interface_header_attribute1 MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         ct.trx_number  Invoice_No,
         ps.due_date due_date,
         nvl(acctd_amount_applied_to,acctd_amount_applied_from) * -1,
         null dispute_amount,
         cr.currency_code Currency_Code,
         tt.name transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         cr.RECEIPT_NUMBER APP_TRANSACTION,
         app.payment_schedule_id APP_PAYMENT_SCHEDULE_ID,
        csu.attribute3 LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_cash_receipts_all cr,
      ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      AR_CUSTOMER_PROFILES_V P,
      hz_cust_accounts_all cust_acct,
      ra_customer_trx_all ct,
      ra_cust_trx_types_all TT,
      hz_cust_site_uses_all CSU
where	cr.cash_receipt_id = app.cash_receipt_id
and ps.payment_schedule_id = app.applied_payment_schedule_id
and ct.customer_trx_id = app.applied_customer_trx_id
AND ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
AND ct.cust_trx_type_id = tt.cust_trx_type_id
and app.receivable_application_id <> (select min(receivable_application_id) from ar_receivable_applications_all a where a.cash_receipt_id = cr.cash_receipt_id and status = 'UNAPP')
and ps.customer_id = cust_acct.cust_account_id
and	nvl( cr.confirmed_flag, 'Y' ) = 'Y'
and nvl(ps.org_id,85) = 85
and cust_acct.party_id = party.party_id
and cr.status <> 'REV'
and app.STATUS = 'APP'
and app.APPLICATION_TYPE = 'CASH'
AND CT.BIll_to_site_use_id = csu.site_use_id
union all
select 	 'RA'||app.receivable_application_id row_id,
         app.last_update_date,
         'RECEIPT APPLICATION',
         'N' IS_TRANSACTION,
         'Y' IS_APPLICATION,
         app.payment_schedule_id pay_sched_id,
         ps.customer_id customer_id,
         substrb(party.party_name,1,50)  customer_name,
         cust_acct.account_number customer_number,
         null MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         cr.RECEIPT_NUMBER  Invoice_No,
         ps.due_date due_date,
         nvl(app.acctd_amount_applied_from,app.AMOUNT_applied) * -1,
         null dispute_amount,
         cr.currency_code Currency_Code,
         'Receipt' transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         null APP_TRANSACTION,
          null APP_PAYMENT_SCHEDULE_ID,
          to_number(null) LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_cash_receipts_all cr,
      ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      AR_CUSTOMER_PROFILES_V P,
      hz_cust_accounts_all cust_acct      
where	cr.cash_receipt_id = app.cash_receipt_id
and ps.payment_schedule_id = app.payment_schedule_id
and app.receivable_application_id <> (select min(receivable_application_id) from ar_receivable_applications_all a where a.cash_receipt_id = cr.cash_receipt_id and status = 'UNAPP')
and ps.customer_id = cust_acct.cust_account_id
and	nvl( cr.confirmed_flag, 'Y' ) = 'Y'
and nvl(ps.org_id,85) = 85
AND ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
and cust_acct.party_id = party.party_id
and cr.status <> 'REV'
and app.STATUS = 'UNAPP'
and app.APPLICATION_TYPE = 'CASH'
union all
select 	 'OA'||app.receivable_application_id row_id,
         app.last_update_date,
        'ONACCOUNT RECEIPTS',
        'N' IS_TRANSACTION,
         'Y' IS_APPLICATION,
         app.payment_schedule_id pay_sched_id,
          ps.customer_id customer_id,
          substrb(party.party_name,1,50)  customer_name,
          cust_acct.account_number customer_number,
         null MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         cr.RECEIPT_NUMBER  Invoice_No,
         ps.due_date due_date,
         nvl(app.acctd_AMOUNT_applied_to,app.acctd_AMOUNT_applied_from) * -1,
         null dispute_amount,
         cr.currency_code Currency_Code,
         'On Account' transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         null APP_TRANSACTION,
          null APP_PAYMENT_SCHEDULE_ID,
          to_number(null) LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_cash_receipts_all cr,
      ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      AR_CUSTOMER_PROFILES_V P,
      hz_cust_accounts_all cust_acct      
where	cr.cash_receipt_id = app.cash_receipt_id
and ps.payment_schedule_id = app.payment_schedule_id
and ps.customer_id = cust_acct.cust_account_id
and	nvl( cr.confirmed_flag, 'Y' ) = 'Y'
and nvl(ps.org_id,85) = 85
AND     ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
and cust_acct.party_id = party.party_id
and cr.status <> 'REV'
and app.STATUS = 'ACC'
and app.APPLICATION_TYPE = 'CASH'
union all
select 	 'AA'||app.receivable_application_id row_id,
         app.last_update_date,
         'ACTIVITY APPLICATION',
        'N' IS_TRANSACTION,
         'Y' IS_APPLICATION,
         app.payment_schedule_id pay_sched_id,
          ps.customer_id customer_id,
          substrb(party.party_name,1,50)  customer_name,
          cust_acct.account_number customer_number,
         null MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         cr.RECEIPT_NUMBER  Invoice_No,
         ps.due_date due_date,
         app.AMOUNT_applied * -1,
         null dispute_amount,
         cr.currency_code Currency_Code,
         RT.NAME transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         RT.NAME APP_TRANSACTION,
          null APP_PAYMENT_SCHEDULE_ID,
         to_number(null) LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_cash_receipts_all cr,
      ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      AR_CUSTOMER_PROFILES_V P,
      hz_cust_accounts_all cust_acct  ,
      ar_receivables_trx_all rt
where	cr.cash_receipt_id = app.cash_receipt_id
and ps.payment_schedule_id = app.payment_schedule_id
and app.receivable_application_id <> (select min(receivable_application_id) from ar_receivable_applications_all a where a.cash_receipt_id = cr.cash_receipt_id and status = 'UNAPP')
and ps.customer_id = cust_acct.cust_account_id
and	nvl( cr.confirmed_flag, 'Y' ) = 'Y'
AND     ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
and nvl(ps.org_id,85) = 85
and cust_acct.party_id = party.party_id
and cr.status <> 'REV'
and app.STATUS = 'ACTIVITY'
and app.APPLICATION_TYPE = 'CASH'
and rt.receivables_trx_id = app.receivables_trx_id
union all
select 	 'ADJA'||app.receivable_application_id row_id,
         app.last_update_date,
        'ADJUSTMENT',   -- Activity Adjustments
        'Y' IS_TRANSACTION,
         'N' IS_APPLICATION,
         app.payment_schedule_id pay_sched_id,
          ps.customer_id customer_id,
          substrb(party.party_name,1,50)  customer_name,
          cust_acct.account_number customer_number,
         null MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         cr.RECEIPT_NUMBER  Invoice_No,
         ps.due_date due_date,
         app.AMOUNT_applied ,
         null dispute_amount,
         cr.currency_code Currency_Code,
         RT.NAME transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         cr.RECEIPT_NUMBER APP_TRANSACTION,
          null APP_PAYMENT_SCHEDULE_ID,
          to_number(null) LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_cash_receipts_all cr,
      ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      AR_CUSTOMER_PROFILES_V P,
      hz_cust_accounts_all cust_acct  ,
      ar_receivables_trx_all rt
where	cr.cash_receipt_id = app.cash_receipt_id
and ps.payment_schedule_id = app.payment_schedule_id
and app.receivable_application_id <> (select min(receivable_application_id) from ar_receivable_applications_all a where a.cash_receipt_id = cr.cash_receipt_id and status = 'UNAPP')
and ps.customer_id = cust_acct.cust_account_id
and	nvl( cr.confirmed_flag, 'Y' ) = 'Y'
and nvl(ps.org_id,85) = 85
AND     ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
and cust_acct.party_id = party.party_id
and cr.status <> 'REV'
and app.STATUS = 'ACTIVITY'
and app.APPLICATION_TYPE = 'CASH'
and rt.receivables_trx_id = app.receivables_trx_id
union all
select 	 'CMA1'||app.receivable_application_id row_id,
         app.last_update_date,
         'CM APPLICATION',
        'N' IS_TRANSACTION,
         'Y' IS_APPLICATION,
         app.payment_schedule_id pay_sched_id,
         ps.customer_id customer_id,
         substrb(party.party_name,1,50)  customer_name,
         cust_acct.account_number customer_number,
         cm.interface_header_attribute1 MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         cm.trx_number  Invoice_No,
         ps.due_date due_date,
         nvl(acctd_amount_applied_to,acctd_amount_applied_from) ,
         null dispute_amount,
         cm.invoice_currency_code Currency_Code,
         tt.name transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         rt.trx_number APP_TRANSACTION,
         app.APPLIED_PAYMENT_SCHEDULE_ID APP_PAYMENT_SCHEDULE_ID,
         csu.attribute3 LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      AR_CUSTOMER_PROFILES_V P,
      hz_cust_accounts_all cust_acct  ,
      ra_customer_trx_all rt,
      ra_cust_trx_types_all TT,
      ra_customer_trx_all CM,
      hz_cust_site_uses_all CSU
where	ps.payment_schedule_id = app.payment_schedule_id
and cm.customer_trx_id = app.customer_trx_id
and rt.customer_trx_id = app.applied_customer_trx_id
and ps.customer_id = cust_acct.cust_account_id
and nvl(ps.org_id,85) = 85
AND ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
and cust_acct.party_id = party.party_id
and app.APPLICATION_TYPE = 'CM'
AND cm.BIll_to_site_use_id = csu.site_use_id
AND cm.cust_trx_type_id = tt.cust_trx_type_id
union all
select 	 'CMA2'||app.receivable_application_id row_id,
         app.last_update_date,
         'CM APPLICATION',
        'N' IS_TRANSACTION,
         'Y' IS_APPLICATION,
         app.applied_payment_schedule_id pay_sched_id,
         ps.customer_id customer_id,
         substrb(party.party_name,1,50)  customer_name,
         cust_acct.account_number customer_number,
         cm.interface_header_attribute1 MSN,
         app.applied_customer_trx_id customer_trx_id,
         app.apply_date trx_date,
         cm.trx_number  Invoice_No,
         ps2.due_date due_date,
         nvl(acctd_amount_applied_to,acctd_amount_applied_from) * -1,
         null dispute_amount,
         cm.invoice_currency_code Currency_Code,
         tt.name transaction_type,
         null,
         null,
         null,
         app.gl_date gl_date,
         to_char(app.gl_date,'MON-YY') PERIOD,
         rt.trx_number APP_TRANSACTION,
         app.PAYMENT_SCHEDULE_ID APP_PAYMENT_SCHEDULE_ID,
         csu.attribute3 LEASE_NUMBER,
         to_number(null) asset_number,
         DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
from 	ar_receivable_applications_all app,
	    ar_payment_schedules_all ps,
      hz_parties party,
      hz_cust_accounts_all cust_acct  ,
      ra_customer_trx_all rt,
      AR_CUSTOMER_PROFILES_V P,
      ra_customer_trx_all CM,
      ar_payment_schedules_all ps2,
      ra_cust_trx_types_all TT,
      hz_cust_site_uses_all CSU
where	ps.payment_schedule_id = app.payment_schedule_id
and rt.customer_trx_id = app.customer_trx_id
and cm.customer_trx_id = app.applied_customer_trx_id
and ps2.customer_id = cust_acct.cust_account_id
AND ps.customer_id = p.customer_id (+)
AND P.SITE_USE_ID is null
and nvl(ps.org_id,85) = 85
and cust_acct.party_id = party.party_id
and app.APPLICATION_TYPE = 'CM'
and app.applied_payment_schedule_id = ps2.payment_schedule_id
AND cm.BIll_to_site_use_id = csu.site_use_id
AND cm.cust_trx_type_id = tt.cust_trx_type_id;
