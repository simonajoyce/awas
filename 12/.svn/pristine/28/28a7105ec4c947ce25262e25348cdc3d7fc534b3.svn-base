--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_CE_STMT_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_CE_STMT_BALANCE" 
(
  P_BANK_ACCOUNT_ID IN NUMBER
, P_BALANCE_DATE IN DATE
, P_START_END IN VARCHAR2
) RETURN NUMBER AS

v_bal number;

BEGIN

if p_start_end = 'S' then

select max(control_end_balance)
INTO V_BAL
from ce_statement_headers_v
where bank_account_id = p_bank_account_id
and statement_date = (select max(statement_date) from ce_Statement_headers_v
                      where bank_account_id = p_bank_account_id and statement_date <= p_balance_date);

else

select max(control_end_balance)
into v_bal
from ce_statement_headers_v
where bank_account_id = p_bank_account_id
and statement_date = (select max(statement_date) from ce_Statement_headers_v
                      where bank_account_id = p_bank_account_id and statement_date <= p_balance_date)
;

end if;

  RETURN v_bal;
END XX_CE_STMT_BALANCE;

/
