--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XXAWAS_DEPOSIT_BALANCES_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_DEPOSIT_BALANCES_V" ("PERIOD_NAME", "START_DATE", "ENTITY", "MSN", "LEASEE", "PERIOD_MVMT", "PERIOD_BALANCE") AS 
  (
select b.period_name,
       p.start_date,
       c.segment1 entity,
       c.segment4 MSN,
       c.segment5 LEASEE,
       nvl(b.period_net_dr,0) - nvl(b.period_net_cr,0) PERIOD_MVMT,
       nvl(b.begin_balance_dr,0)-nvl(b.begin_balance_cr,0)+ nvl(b.period_net_dr,0) - nvl(b.period_net_cr,0) PERIOD_BALANCE
from gl_balances b,
     gl_code_combinations c,
     GL_PERIODS P
where b.ledger_id = 8
and c.code_combination_id = b.code_combination_id
and c.segment2 in ('221005','221010')
and c.summary_flag = 'N'
and b.currency_code = 'USD'
and p.period_name = b.period_name
and p.period_set_name = 'AWAS'
AND C.SEGMENT4 <> '000000')
 ;
