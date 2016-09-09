--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_CE_TRX_SUM1
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_CE_TRX_SUM1" 
(
  P_BANK_ACCOUNT_ID IN NUMBER
, P_RUN_DATE IN DATE
, P_LAST_STMT_DATE IN DATE
) RETURN NUMBER AS

retval number;

begin
retval := 0;

select sum(
decode(trx_type,'DEBIT',amount*-1,'MISC_DEBIT',amount*-1,'SWEEP_OUT',amount*-1,amount))
INTO RETVAL
from ce_statement_headers_v h,
ce_statement_lines l
where h.statement_header_id = l.statement_header_id
and h.bank_account_id = p_bank_account_id
and h.control_end_balance is null
and h.statement_date <= p_run_date
and h.statement_date > P_last_stmt_date
;



  RETURN retval;


END XX_CE_TRX_SUM1;

/
