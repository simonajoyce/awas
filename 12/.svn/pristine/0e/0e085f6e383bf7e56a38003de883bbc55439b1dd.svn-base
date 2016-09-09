--------------------------------------------------------
--  File created - Thursday-September-19-2013
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XXAWAS_DEBTOR_KPI_V
--------------------------------------------------------
CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_DEBTOR_KPI_V" ("CUSTOMER_OR_LOCATION", "CUSTOMER_NAME", "CUSTOMER_NUMBER", "DSO", "LOCATION", "PASTDUE_INVOICES", "ACCTD_BALANCE", "ACCTD_PASTDUE_BALANCE", "ACCTD_OPEN_CREDIT")
AS
  SELECT 'L' "CUSTOMER_OR_LOCATION",
    substrb(party.party_name, 1, 50) "CUSTOMER_NAME",
    CUST_ACCT.ACCOUNT_NUMBER "CUSTOMER_NUMBER",
    ROUND(((SUM(DECODE(ps.class, 'INV', 1, 'DM', 1, 'CB', 1, 'DEP', 1, 'BR', 1,0) * ps.acctd_amount_due_remaining) *MAX(sp.cer_dso_days)) / DECODE(SUM(DECODE(ps.class, 'INV', 1, 'DM', 1, 'DEP', 1, 0) *DECODE(SIGN(TRUNC(sysdate) -ps.trx_date -sp.cer_dso_days), -1, (ps.amount_due_original + NVL(ps.amount_adjusted, 0)) *NVL(ps.exchange_rate, 1), 0)), 0, 1, SUM(DECODE(ps.class, 'INV', 1, 'DM', 1, 'DEP', 1, 0) *DECODE(SIGN(TRUNC(sysdate) -ps.trx_date -sp.cer_dso_days), -1, (ps.amount_due_original + NVL(ps.amount_adjusted, 0)) *NVL(ps.exchange_rate, 1), 0)))), 0) "DSO",
    su.location "LOCATION",
    SUM(DECODE(ps.status, 'OP', DECODE(SIGN(TRUNC(sysdate) -TRUNC(NVL(ps.due_date, sysdate))), 1, 1, 0), 0)) "PASTDUE_INVOICES",
    SUM(NVL(ps.acctd_amount_due_remaining, 0)) "ACCTD_BALANCE",
    SUM(DECODE(SIGN(TRUNC(sysdate)                  -TRUNC(NVL(ps.due_date, sysdate))), 1, ps.acctd_amount_due_remaining, 0)) "ACCTD_PASTDUE_BALANCE",
    SUM(DECODE(SIGN(ps.acctd_amount_due_remaining), -1, (ps.acctd_amount_due_remaining *-1), DECODE(ps.class, 'PMT', ps.acctd_amount_due_remaining, 0))) "ACCTD_OPEN_CREDIT"
  FROM ar_system_parameters_all sp,
    ar_collectors COL,
    hz_cust_profile_classes cpc,
    hz_customer_profiles cp_cust,
    hz_customer_profiles cp_site,
    ar_payment_schedules_all ps,
    hz_cust_site_uses_all su,
    hz_cust_acct_sites_all a,
    hz_cust_accounts_all cust_acct,
    hz_parties party
  WHERE cust_acct.cust_account_id            = a.cust_account_id
  AND cust_acct.party_id                     = party.party_id
  AND su.org_id                              = sp.org_id
  AND a.cust_acct_site_id                    = su.cust_acct_site_id
  AND su.site_use_id                         = ps.customer_site_use_id(+)
  AND su.site_use_code                      IN('BILL_TO', 'DRAWEE')
  AND cp_cust.cust_account_id                = cust_acct.cust_account_id
  AND cp_cust.site_use_id                   IS NULL
  AND cp_site.site_use_id(+)                 = su.site_use_id
  AND COL.collector_id                       = NVL(cp_site.collector_id, cp_cust.collector_id)
  AND cpc.profile_class_id(+)                = cp_site.profile_class_id
  AND NVL(ps.receipt_confirmed_flag(+), 'Y') = 'Y'
  GROUP BY cust_acct.cust_account_id,
    party.party_name,
    cust_acct.account_number,
    cust_acct.status,
    cp_site.account_status,
    cpc.name,
    cp_site.risk_code,
    COL.name,
    su.site_use_id,
    su.location
  UNION ALL
  SELECT 'C',
    /* CUSTOMER_ID */
    substrb(party.party_name, 1, 50),
    /* CUSTOMER_NAME */
    cust_acct.account_number,
    /* CUSTOMER_NUMBER */
    ROUND(((SUM(DECODE(ps.class, 'INV', 1, 'DM', 1, 'CB', 1, 'DEP', 1, 'BR', 1, 0) *ps.acctd_amount_due_remaining) *MAX(sp.cer_dso_days)) / DECODE(SUM(DECODE(ps.class, 'INV', 1, 'DM', 1, 'DEP', 1, 0) *DECODE(SIGN(TRUNC(sysdate) -ps.trx_date -sp.cer_dso_days), -1, (ps.amount_due_original + NVL(ps.amount_adjusted, 0)) *NVL(ps.exchange_rate, 1), 0)), 0, 1, SUM(DECODE(ps.class, 'INV', 1, 'DM', 1, 'DEP', 1, 0) *DECODE(SIGN(TRUNC(sysdate) -ps.trx_date -sp.cer_dso_days), -1, (ps.amount_due_original + NVL(ps.amount_adjusted, 0)) *NVL(ps.exchange_rate, 1), 0)))), 0),
    /* CUSTOMER_SITE_USE_ID */
    NULL,
    --/* LOCATION */ NULL,
    /* CREDIT_AVAILABLE */
    SUM(DECODE(ps.status, 'OP', DECODE(SIGN(TRUNC(sysdate) -TRUNC(NVL(ps.due_date, sysdate))), 1, 1, 0), 0)),
    /* BALANCE */
    SUM(NVL(ps.acctd_amount_due_remaining, 0)),
    /* PASTDUE_BALANCE */
    SUM(DECODE(SIGN(TRUNC(sysdate) -TRUNC(NVL(ps.due_date, sysdate))), 1, ps.acctd_amount_due_remaining, 0)),
    /* OPEN_CREDIT */
    SUM(DECODE(SIGN(ps.acctd_amount_due_remaining), -1, (ps.acctd_amount_due_remaining *-1), DECODE(ps.class, 'PMT', ps.acctd_amount_due_remaining, 0)))
    /* ACCTD_OPEN_CREDIT */
  FROM ar_system_parameters_all sp,
    hz_cust_profile_classes cpc,
    hz_customer_profiles cp,
    ar_collectors COL,
    hz_cust_accounts_all cust_acct,
    hz_parties party,
    ar_payment_schedules_all ps
  WHERE cust_acct.cust_account_id            = ps.customer_id(+)
  AND cust_acct.party_id                     = party.party_id
  AND sp.org_id                              = -3113
  AND cp.cust_account_id                     = cust_acct.cust_account_id
  AND cp.site_use_id                        IS NULL
  AND COL.collector_id                       = cp.collector_id
  AND cpc.profile_class_id(+)                = cp.profile_class_id
  AND NVL(ps.receipt_confirmed_flag(+), 'Y') = 'Y'
  GROUP BY sp.org_id,
    cust_acct.cust_account_id,
    party.party_name,
    cust_acct.account_number,
    cust_acct.status,
    cp.account_status,
    cpc.name,
    cp.risk_code,
    COL.name ;
