CREATE OR REPLACE FORCE VIEW "APPS"."AWDEBTORS" ("CUSTOMER_NAME", "CUSTOMER_NUMBER", "TRX_NUMBER", "DUE_DATE", "NAME", "DESCRIPTION", "ORIG", "OUTSTAND", "ENTITY", "MSN", "ACCOUNT")
                               AS
  SELECT INITCAP(P.PARTY_NAME) AS CUSTOMER_NAME,
    e.account_number customer_number,
    a.trx_number AS trx_number,
    a.due_date,
    b.name,
    d.description,
    a.amount_due_original,
    a.amount_due_remaining,
    i.segment1,
    i.segment4,
    I.SEGMENT2
  FROM ar_payment_schedules_all a,
    ra_cust_trx_types_all b,
    ra_customer_trx_all c,
    RA_CUSTOMER_TRX_LINES_ALL D,
    HZ_CUST_ACCOUNTS E,
    HZ_PARTIES P,
    ra_cust_trx_line_gl_dist_all h,
    gl_code_combinations i,
          xla.xla_ae_lines xal,
  xla.xla_ae_headers xah,
  xla.xla_events xe,
  xla.xla_transaction_entities xte,
  xla_distribution_links       lk
  WHERE a.status             = 'OP'
  AND d.org_id               = 85
  AND a.cust_trx_type_id     = b.cust_trx_type_id
  AND a.customer_trx_id      = c.customer_trx_id
  AND A.CUSTOMER_TRX_ID      = D.CUSTOMER_TRX_ID
  AND A.CUSTOMER_ID          = E.CUST_account_ID
  AND e.PARTY_ID             = P.PARTY_ID
  AND d.customer_trx_line_id = h.customer_trx_line_id
  AND d.line_number          =
    (SELECT MIN(line_number)
    FROM ra_customer_trx_lines_all
    WHERE CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
    AND line_type        != 'TAX'
    AND extended_amount  <> 0
    )
    and lk.source_distribution_id_num_1 (+) = h.CUST_TRX_LINE_GL_DIST_ID 
    and lk.source_distribution_type (+)   = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
    and lk.application_id (+)             = 222
    and lk.ae_header_id                   = xal.ae_header_id (+)
    and lk.ae_line_num                    = xal.ae_line_num (+)
    AND xal.application_id = xah.application_id (+)
    AND xal.ae_header_id  = xah.ae_header_id  (+)
    AND xah.application_id = xe.application_id (+)
    AND xah.event_id  = xe.event_id (+)
    AND xe.application_id  = xte.application_id (+)
    AND xte.application_id (+) = 222
    AND xe.entity_id = xte.entity_id (+)
    AND xte.entity_code (+) = 'TRANSACTIONS'
    AND nvl(xte.source_id_int_1,c.customer_trx_id)  = c.customer_trx_id
    and xal.accounting_class_code (+) = 'REVENUE'
    and nvl(xal.CODE_COMBINATION_ID,h.code_combination_id) = i.code_combination_id
    and h.account_class              = 'REV'
  HAVING SUM(H.ACCTD_AMOUNT) <> 0
  GROUP BY initcap(p.party_name),
    e.account_number,
    a.trx_number,
    a.due_date,
    b.name,
    d.description,
    a.amount_due_original,
    a.amount_due_remaining,
    i.segment1,
    I.SEGMENT4,
    I.SEGMENT2
  UNION
  SELECT INITCAP(P.PARTY_NAME) AS CUSTOMER_NAME,
    e.account_number customer_number,
    a.trx_number AS trx_number,
    a.due_date,
    b.name,
    d.description,
    a.amount_due_original,
    a.amount_due_remaining,
    i.segment1,
    i.segment4,
    i.segment2
  FROM ar_payment_schedules_all a,
    ra_cust_trx_types_all b,
    ra_customer_trx_all c,
    RA_CUSTOMER_TRX_LINES_ALL D,
    HZ_CUST_ACCOUNTS E,
    HZ_PARTIES P,
    ra_cust_trx_line_gl_dist_all h,
    gl_code_combinations i,
      xla.xla_ae_lines xal,
  xla.xla_ae_headers xah,
  xla.xla_events xe,
  xla.xla_transaction_entities xte,
  xla_distribution_links       lk
  WHERE a.status             = 'CL'
  AND d.org_id               = 85
  AND a.cust_trx_type_id     = b.cust_trx_type_id
  AND a.customer_trx_id      = c.customer_trx_id
  AND A.CUSTOMER_TRX_ID      = D.CUSTOMER_TRX_ID
  AND A.CUSTOMER_ID          = E.CUST_account_ID
  AND e.PARTY_ID             = P.PARTY_ID
  AND d.customer_trx_line_id = h.customer_trx_line_id
  AND d.line_number          =
    (SELECT MIN(line_number)
    FROM ra_customer_trx_lines_all
    WHERE customer_trx_id = a.customer_trx_id
    AND line_type        != 'TAX'
    )
  AND TRUNC(actual_date_closed,'MM')=TRUNC(sysdate,'MM')
  AND d.description                 =
    (SELECT description
    FROM ra_customer_trx_lines_all
    WHERE customer_trx_id = a.customer_trx_id
    AND rownum            = 1
    )
   and lk.source_distribution_id_num_1 (+) = h.CUST_TRX_LINE_GL_DIST_ID 
    and lk.source_distribution_type (+)   = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
    and lk.application_id (+)             = 222
    and lk.ae_header_id                   = xal.ae_header_id (+)
    and lk.ae_line_num                    = xal.ae_line_num (+)
    AND xal.application_id = xah.application_id (+)
    AND xal.ae_header_id  = xah.ae_header_id  (+)
    AND xah.application_id = xe.application_id (+)
    AND xah.event_id  = xe.event_id (+)
    AND xe.application_id  = xte.application_id (+)
    AND xte.application_id (+) = 222
    AND xe.entity_id = xte.entity_id (+)
    AND xte.entity_code (+) = 'TRANSACTIONS'
    AND nvl(xte.source_id_int_1,c.customer_trx_id)  = c.customer_trx_id
    and xal.accounting_class_code (+) = 'REVENUE'
    and nvl(xal.CODE_COMBINATION_ID,h.code_combination_id) = i.code_combination_id
    and h.account_class              = 'REV'
  HAVING SUM(H.ACCTD_AMOUNT) <> 0
  GROUP BY INITCAP(P.PARTY_NAME),
    e.account_number,
    a.trx_number,
    a.due_date,
    b.name,
    d.description,
    a.amount_due_original,
    a.amount_due_remaining,
    i.segment1,
    i.segment4,
    i.segment2
  ORDER BY CUSTOMER_NAME,
    trx_number ;