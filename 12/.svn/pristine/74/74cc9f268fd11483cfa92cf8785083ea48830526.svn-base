--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_COMMITMENTS" 
(
  p_project_id in number  
, p_balance_source in varchar2
) RETURN NUMBER AS 

retval number;

begin

if p_balance_source = 'ACCRUAL'
then
select
   sum( c.tot_cmt_raw_cost)
   into retval
FROM
  pa_commitment_txns c,
    pa_autoaccounting_lookups_view alv
where
 alv.lookup_set_name = 'AWAS Account Overrides'
and alv.segment_value = '000000'
and alv.intermediate_value (+) = c.expenditure_type
and c.project_id = p_project_id;
  
 elsif p_balance_source = 'OTHER' then
 
select
   sum( c.tot_cmt_raw_cost)
   into retval
FROM
  pa_commitment_txns c,
    pa_autoaccounting_lookups_view alv
where
 alv.lookup_set_name = 'AWAS Account Overrides'
and alv.segment_value <> '000000'
and alv.intermediate_value (+) = c.expenditure_type
and c.project_id = p_project_id; 

 end if;
 

  RETURN retval;
  
  
END XX_PA_COMMITMENTS;
 

/
