CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_DEBTOR_AGEING_V" ("BOOK", "CUSTOMER_NAME", "CUSTOMER_NUMBER", "TYPE",
       "PAYMENT_SCHED_ID", "CLASS", "DUE_DATE", "AMT_DUE_REMAINING", "AMT_DUE_ORIGINAL", "IN_DISPUTE", "DISPUTE_AMT",
       "DAYS_PAST_DUE", "Future", "1-30 Days", "1-7 Days", "8-15 Days", "8-30 Days", "16-30 Days", "31-60 Days", "60+ Days",
       "ENTITY", "MSN", "GL_ACCOUNT", "TRX_TYPE", "CUSTOMER_PROFILE", "XRM_LEASE_NUM")
AS
        SELECT DECODE(d.msn,NULL,'AWAS',CASE
                     WHEN due_date < '01-Aug-2015'
                     THEN 'AWAS'
                     ELSE 'ABS'
              END) BOOK
            , CUSTOMER_NAME
            , customer_number
            , TYPE
            , payment_sched_id
            , class
            , DUE_DATE
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*AMT_DUE_REMAINING AMT_DUE_REMAINING
            , SUM(DIST_AMOUNT) AMT_DUE_ORIGINAL
            , IN_DISPUTE
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*DISPUTE_AMT DISPUTE_AMT
            , DAYS_PAST_DUE
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET0 FUTURE
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET1 "1-30 Days"
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET2 "1-7 Days"
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET3 "8-15 Days"
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET4 "8-30 Days"
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET5 "16-30 Days"
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET6 "31-60 Days"
            , (SUM(DIST_AMOUNT)/AMT_DUE_ORIGINAL)*BUCKET7 "60+ Days"
            , ENTITY
            , x.MSN
            , GL_ACCOUNT
            , TRX_TYPE
            , CUSTOMER_PROFILE
            , x.LEASE_NUM
          FROM
              (
                     SELECT DISTINCT DECODE(ps.org_Id,2,'AWAS',44,'PAFCO',85,'AWAS','UNKNOWN') BOOK
                          , RTRIM(RPAD(SUBSTRB(party.party_name,1,50),36)) customer_name
                          , cust_acct.account_number customer_number
                          , TYPES.NAME TYPE
                          , ps.payment_schedule_id payment_sched_id
                          , ps.CLASS CLASS
                          , PS.DUE_DATE DUE_DATE
                          , DECODE( 'Y', 'Y', PS.ACCTD_AMOUNT_DUE_REMAINING, PS.AMOUNT_DUE_REMAINING ) AMT_DUE_REMAINING
                          , GLD.AMOUNT dist_amount
                          , ps.amount_due_original amt_due_original
                          , CASE
                                   WHEN NVL(PS.AMOUNT_IN_DISPUTE,0) <> 0
                                   THEN 'Y'
                                   ELSE 'N'
                            END IN_DISPUTE
                          , NVL(ps.amount_in_dispute,0) dispute_amt
                          , CEIL(SYSDATE - ps.due_date ) days_past_due
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0,DECODE(
                            NVL(PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 1), DECODE( GREATEST(                               -999999999, CEIL(SYSDATE-PS.DUE_DATE)),
                            LEAST(0, CEIL(SYSDATE                                                                         -PS.DUE_DATE)),1, 0) * DECODE(NVL(
                            PS.AMOUNT_IN_DISPUTE,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))       * DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))*
                            PS.ACCTD_AMOUNT_DUE_REMAINING bucket0
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0,DECODE(
                            NVL(PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 1), DECODE( GREATEST(1, CEIL(SYSDATE                     -PS.DUE_DATE)), LEAST(30
                            , CEIL(SYSDATE                                                                                     -PS.DUE_DATE)),1, 0) *
                            DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(PS.AMOUNT_ADJUSTED_PENDING,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            ))*PS.ACCTD_AMOUNT_DUE_REMAINING BUCKET1
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0,DECODE(
                            NVL(PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 1), DECODE( GREATEST(1, CEIL(SYSDATE                     -PS.DUE_DATE)), LEAST(7,
                            CEIL(SYSDATE                                                                                       -PS.DUE_DATE)),1, 0) *
                            DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(PS.AMOUNT_ADJUSTED_PENDING,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            ))*PS.ACCTD_AMOUNT_DUE_REMAINING BUCKET2
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0,DECODE(
                            NVL(PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 1), DECODE( GREATEST(8, CEIL(SYSDATE                     -PS.DUE_DATE)), LEAST(15
                            , CEIL(SYSDATE                                                                                     -PS.DUE_DATE)),1, 0) *
                            DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(PS.AMOUNT_ADJUSTED_PENDING,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            ))*PS.ACCTD_AMOUNT_DUE_REMAINING BUCKET3
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0,DECODE(
                            NVL(PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 1), DECODE( GREATEST(8, CEIL(SYSDATE                     -PS.DUE_DATE)), LEAST(30
                            , CEIL(SYSDATE                                                                                     -PS.DUE_DATE)),1, 0) *
                            DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(PS.AMOUNT_ADJUSTED_PENDING,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            ))*PS.ACCTD_AMOUNT_DUE_REMAINING BuCKET4
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(
                            NVL(ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(16, CEIL(SYSDATE                    -ps.due_date)), LEAST(
                            30 , CEIL(SYSDATE                                                                                  -ps.due_date)),1, 0) *
                            DECODE(NVL(ps.amount_in_dispute,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(ps.amount_adjusted_pending,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            ))*ps.acctd_amount_due_remaining bucket5
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0,DECODE(
                            NVL(PS.AMOUNT_ADJUSTED_PENDING,0),0,0,1), 1), DECODE( GREATEST(31, CEIL(SYSDATE                    -PS.DUE_DATE)), LEAST(
                            60 , CEIL(SYSDATE                                                                                  -PS.DUE_DATE)),1, 0) *
                            DECODE(NVL(PS.AMOUNT_IN_DISPUTE,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(PS.AMOUNT_ADJUSTED_PENDING,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            )) *PS.ACCTD_AMOUNT_DUE_REMAINING BUCKET6
                          , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
                            ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(
                            NVL(ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(61, CEIL(SYSDATE                    -ps.due_date)), LEAST(
                            999999999999999999, CEIL(SYSDATE                                                                   -ps.due_date)),1, 0) *
                            DECODE(NVL(ps.amount_in_dispute,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) *
                            DECODE(NVL(ps.amount_adjusted_pending,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)
                            )) *ps.acctd_amount_due_remaining bucket7
                          , CC.SEGMENT1 ENTITY
                          , X.LOCATION MSN
                          , cc.segment2 GL_Account
                          , TYPES.NAME TRX_TYPE
                          , DECODE(P.CUSTOMER_PROFILE_CLASS_ID, 1041,'Non Leasing','Leasing') CUSTOMER_PROFILE
                          , R.TRX_NUMBER
                          , GLD.cust_trx_line_gl_dist_id
                          , x.attribute3 LEASE_NUM
                        FROM ra_cust_trx_types_all TYPES
                          , hz_cust_accounts cust_acct
                          , hz_parties party
                          , ar_payment_schedules_all ps
                          , hz_cust_site_uses_all X
                          , hz_cust_acct_sites_all y
                          , ra_cust_trx_LINE_gl_dist_all gld
                          , gl_code_combinations cc
                          , AR_CUSTOMER_PROFILES_V P
                          , ra_customer_trx_all r
                       WHERE TRUNC(PS.GL_DATE)     <= SYSDATE
                        AND PS.CUSTOMER_ID          = CUST_ACCT.CUST_ACCOUNT_ID
                        AND p.customer_id           = cust_acct.cust_account_id
                        AND cust_acct.party_id      = party.party_id
                        AND GLD.CUSTOMER_TRX_ID     = R.CUSTOMER_TRX_ID
                        AND r.bill_to_site_use_id   = x.site_Use_id
                        AND x.site_use_id           = NVL(P.SITE_USE_ID, x.site_use_id)
                        AND X.ORG_ID                = 85
                        AND y.cust_account_id       = cust_acct.cust_account_id
                        AND x.cust_acct_site_id     = y.cust_acct_site_id
                        AND ps.cust_trx_type_id     = TYPES.cust_trx_type_id
                        AND NVL(ps.org_id,-99)      = NVL(TYPES.org_id,-99)
                        AND PS.GL_DATE_CLOSED       > SYSDATE
                        AND PS.CUSTOMER_TRX_ID+0    = GLD.CUSTOMER_TRX_ID
                        AND GLD.ACCOUNT_CLASS       in ('REV','TAX')
                        AND gld.code_combination_id = cc.code_combination_id
                        AND PS.ORG_ID               = TYPES.ORG_ID
                        AND TYPES.ORG_ID            = GLD.ORG_ID
              )
              x
            , xx_diamond_head_aircraft d
         WHERE x.lease_num = d.lease_num (+)
      GROUP BY DECODE(d.msn,NULL,'AWAS',CASE
                     WHEN due_date < '01-Aug-2015'
                     THEN 'AWAS'
                     ELSE 'ABS'
              END)
            , CUSTOMER_NAME
            , customer_number
            , TYPE
            , payment_sched_id
            , class
            , DUE_DATE
            , AMT_DUE_REMAINING
            , AMT_DUE_ORIGINAL
            , IN_DISPUTE
            , DISPUTE_AMT
            , DAYS_PAST_DUE
            , BUCKET0
            , BUCKET1
            , BUCKET2
            , BUCKET3
            , BUCKET4
            , BUCKET5
            , BUCKET6
            , BUCKET7
            , ENTITY
            , x.MSN
            , GL_ACCOUNT
            , TRX_TYPE
            , CUSTOMER_PROFILE
            , x.LEASE_NUM
     UNION ALL
       SELECT DISTINCT DECODE(ps.org_Id,85,'AWAS',44,'PAFCO','UNKNOWN') BOOK
            , RTRIM(RPAD(SUBSTRB(party.party_name,1,50),36)) customer_name
            , cust_acct.account_number customer_number
            , 'ON ACCOUNT' TYPE
            , ps.payment_schedule_id payment_sched_id
            , ps.CLASS CLASS
            , ps.due_date due_date
            , DECODE( 'Y', 'Y', ps.acctd_amount_due_remaining, ps.amount_due_remaining ) amt_due_remaining
            , ps.amount_due_original amt_due_original
            , CASE
                     WHEN NVL(ps.amount_in_dispute,0) <> 0
                     THEN 'Y'
                     ELSE 'N'
              END IN_DISPUTE
            , NVL(ps.amount_in_dispute,0) dispute_amt
            , CEIL(SYSDATE - ps.due_date ) days_past_due
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(      -999999999, CEIL(SYSDATE-ps.due_date)), LEAST(0, CEIL(
              SYSDATE                                                          -ps.due_date)),1, 0) * DECODE(NVL(ps.amount_in_dispute,0)
              , 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)) * DECODE(NVL(ps.amount_adjusted_pending,0), 0, 1,
              DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))        *ps.acctd_amount_due_remaining "Future"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(1, CEIL(SYSDATE -ps.due_date)), LEAST(30, CEIL(SYSDATE-
              ps.due_date)),1, 0)                                                        * DECODE(NVL(ps.amount_in_dispute,0), 0, 1
              , DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))                 * DECODE(NVL(ps.amount_adjusted_pending,0)
              , 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))          *ps.acctd_amount_due_remaining "1-30 Days"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(1, CEIL(SYSDATE -ps.due_date)), LEAST(7, CEIL(SYSDATE-
              ps.due_date)),1, 0)                                                        * DECODE(NVL(ps.amount_in_dispute,0), 0, 1
              , DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))                 * DECODE(NVL(ps.amount_adjusted_pending,0)
              , 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))          *ps.acctd_amount_due_remaining "1-7 Days"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(8, CEIL(SYSDATE -ps.due_date)), LEAST(15, CEIL(SYSDATE-
              ps.due_date)),1, 0)                                                        * DECODE(NVL(ps.amount_in_dispute,0), 0, 1
              , DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))                 * DECODE(NVL(ps.amount_adjusted_pending,0)
              , 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))          *ps.acctd_amount_due_remaining "8-15 Days"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(8, CEIL(SYSDATE -ps.due_date)), LEAST(30, CEIL(SYSDATE-
              ps.due_date)),1, 0)                                                        * DECODE(NVL(ps.amount_in_dispute,0), 0, 1
              , DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))                 * DECODE(NVL(ps.amount_adjusted_pending,0)
              , 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))          *ps.acctd_amount_due_remaining "8-30 Days"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(16, CEIL(SYSDATE-ps.due_date)), LEAST(30, CEIL(SYSDATE-
              ps.due_date)),1, 0)                                                        * DECODE(NVL(ps.amount_in_dispute,0), 0, 1
              , DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))                 * DECODE(NVL(ps.amount_adjusted_pending,0)
              , 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))          *ps.acctd_amount_due_remaining
              "16-30 Days"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(31, CEIL(SYSDATE-ps.due_date)), LEAST(60, CEIL(SYSDATE-
              ps.due_date)),1, 0)                                                        * DECODE(NVL(ps.amount_in_dispute,0), 0, 1
              , DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))                 * DECODE(NVL(ps.amount_adjusted_pending,0)
              , 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1)))          *ps.acctd_amount_due_remaining
              "31-60 Days"
            , DECODE('X', 'DISPUTE_ONLY',DECODE(NVL(ps.amount_in_dispute,0),0,0,1), 'PENDADJ_ONLY',DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 'DISPUTE_PENDADJ',DECODE(NVL(ps.amount_in_dispute,0), 0,DECODE(NVL(
              ps.amount_adjusted_pending,0),0,0,1), 1), DECODE( GREATEST(61, CEIL(SYSDATE                    -ps.due_date)), LEAST(999999999999999999,
              CEIL(SYSDATE                                                                                   -ps.due_date)),1, 0) * DECODE(NVL(
              ps.amount_in_dispute,0), 0, 1, DECODE('X', 'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))        * DECODE(NVL(
              ps.amount_adjusted_pending,0), 0, 1, DECODE('X', 'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0, 1))) *
              ps.acctd_amount_due_remaining "60+ Days"
            , CC.sEGMENT1 ENTITY
            , CC.SEGMENT5 MSN
            , cc.segment2 GL_Account
            , 'ON_ACCOUNT' TRX_TYPE
            , DECODE(p.customer_profile_class_id, 1041,'Non Leasing','Leasing') Customer_Profile
            , site.attribute3 LEASE_NUM
          FROM ar_payment_schedules_all ps
            , ar_receivable_applications_all app
            , gl_code_combinations cc
            , hz_cust_accounts cust_acct
            , hz_parties party
            , hz_cust_site_uses_all site
            , hz_cust_acct_sites_all addr
            , hz_party_sites party_site
            , hz_locations loc
            , ar_customer_profiles_v p
         WHERE 1                           = 1
          AND app.gl_date+0               <= sysdate
          AND p.customer_id                = cust_acct.cust_account_id
          AND ps.customer_id               = cust_acct.cust_account_id(+)
          AND cust_acct.party_id           = party.party_id(+)
          AND ps.cash_receipt_id           = app.cash_receipt_id
          AND ps.customer_site_use_id      = site.site_use_id (+)
          AND site.cust_acct_site_id       = addr.cust_acct_site_id(+)
          AND addr.party_site_id           = party_site.party_site_id(+)
          AND party_site.location_id       = loc.location_id(+)
          AND app.code_combination_id      = cc.code_combination_id
          AND app.status                  IN ( 'ACC', 'UNAPP', 'UNID', 'OTHER ACC')
          AND NVL(app.confirmed_flag, 'Y') = 'Y'
          AND ps.gl_date_closed            > sysdate
          AND display                      = 'Y'
          AND
              (
                     (
                            app.reversal_gl_date IS NOT NULL
                        AND ps.gl_date           <= sysdate
                     )
                  OR app.reversal_gl_date IS NULL
              )
          AND NVL( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
          AND NVL(ADDR.ORG_ID,85)                   = 85
          AND PS.ORG_ID                             = app.ORG_ID;