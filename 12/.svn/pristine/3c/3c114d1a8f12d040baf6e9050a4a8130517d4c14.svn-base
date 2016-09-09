--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_GL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_GL_BALANCE" 
/* $Header: xxpabalfun.pls 12.1 2013/07/05 sjoyce $ */
(
  p_project_id in number
, p_balance_source in varchar2
, p_balance_type in varchar2
, p_period_name in varchar2
) RETURN NUMBER AUTHID CURRENT_USER AS

l_ob number;
l_ptd number;
l_cb number;
retval number;

begin

if p_balance_source = 'PA'
then
select sum(begin_balance_dr-begin_balance_cr) opening_balance,
       sum(period_net_dr - period_net_cr) ptd,
       sum((begin_balance_dr-begin_balance_cr)+(period_net_dr - period_net_cr)) closing_balance
into l_ob,
l_ptd,
l_cb
from gl_balances
where ledger_id = 8
and code_combination_id =
( select code_combination_id
  from gl_code_combinations c,
       pa_projects_all p
  where p.attribute1 = c.segment4 --MSN
  and p.attribute2 = c.segment1   -- ENTITY
  and p.attribute3 = c.segment2   -- Account
  and p.attribute4 = c.segment5  --OP
  and p.attribute2 = c.segment6  -- IC
  and c.segment3 = '0000'
  and p.project_id = p_project_id
  )
  and period_name = p_period_name
  and actual_flag = 'A'
  and currency_code = 'USD';


 elsif p_balance_source = 'OTHER' then

  select
       sum(begin_balance_dr-begin_balance_cr) opening_balance,
       sum(period_net_dr - period_net_cr) ptd,
       sum((begin_balance_dr-begin_balance_cr)+(period_net_dr - period_net_cr)) closing_balance
       into l_ob,
l_ptd,
l_cb
from gl_balances
where ledger_id = 8
and code_combination_id in
( select code_combination_id
  from gl_code_combinations c,
       pa_projects_all p
  where p.attribute1 = c.segment4 --MSN
  and p.attribute3 = c.segment2   -- Account
  and p.attribute4 <> c.segment5  --OP
  and p.project_id = p_project_id
  )
  and period_name = p_period_name
  and actual_flag = 'A'
  and currency_code = 'USD';

 end if;

 if p_balance_type = 'OB'
 then retval := l_ob;
 elsif p_balance_type = 'PTD'
 then retval := l_ptd;
 elsif p_balance_type = 'CB'
 then retval := l_cb;
 end if;



  RETURN retval;


END XX_PA_GL_BALANCE;

/
