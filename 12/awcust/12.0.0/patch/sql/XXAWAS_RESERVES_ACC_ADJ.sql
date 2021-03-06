CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_RESERVES_ACC_ADJ" ("MSN", "LE", "LE_DESC", "CC", "CC_DESC", "BALANCE")
AS
        SELECT c.segment4 msn
            , c.segment5 le
            , t2.description le_desc
            , c.segment3 cc
            , t.description cc_desc
            , SUM((begin_balance_Dr + period_net_dr)-(begin_balance_cr + period_net_cr)) Balance
          FROM gl_balances b
            , gl_code_combinations c
            , fnd_flex_values f
            , fnd_flex_values_tl t
            , fnd_flex_values f2
            , fnd_flex_values_tl t2
         WHERE C.CODE_COMBINATION_ID = B.CODE_COMBINATION_ID
          AND b.ledger_id            = 8
          AND b.currency_code        = 'USD'
          AND f.flex_value           = c.segment3
          AND f.flex_value_set_id    = 1009475
          AND f.flex_value_id        = t.flex_value_id
          AND f2.flex_value          = c.segment5
          AND f2.flex_value_set_id   = 1009477
          AND f2.flex_value_id       = t2.flex_value_id
          AND b.actual_flag          = 'A'
          AND b.period_name          =
              (
                      SELECT period_name
                        FROM gl_periods
                       WHERE TO_CHAR(sysdate,'DD-MON-RRRR') BETWEEN start_date AND end_date
                         and adjustment_period_flag = 'N'
              )
          AND c.segment2 = '261106'
      GROUP BY c.segment4
            , c.segment5
            , t2.description
            , c.segment3
            , t.description
      ORDER BY 1,2,4;