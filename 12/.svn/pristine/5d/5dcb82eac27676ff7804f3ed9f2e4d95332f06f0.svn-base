--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_GET_BUDGET_AMT2
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_GET_BUDGET_AMT2" 
(
  P_PROJECT_ID IN NUMBER  
, P_BUDGET_STATUS IN VARCHAR2  
, P_FIN_PLAN_NAME IN VARCHAR2  
, p_current in varchar2  
, p_time_id in number
, p_rbs_element_id in number
) RETURN NUMBER AS 

retval number;

begin

   
   select sum(pbl.raw_cost)
   into retval
  from pa_budget_versions pbv,
  pa_resource_assignments pra,
  pa_budget_lines pbl,
      pa_fin_plan_types_tl pfpt,
  (select cal_period_id, start_date, end_date from pji_time_cal_period
union
select cal_qtr_id, start_date, end_date from pji_time_cal_qtr
union
select  cal_year_id, start_date, end_date from pji_time_cal_year
union
select  ent_period_id, start_date, end_date from pji_time_ent_period
union
select  ent_qtr_id, start_date, end_date from pji_time_ent_qtr
union
select  ent_year_id, start_date, end_date from pji_time_ent_year) ti
  where pbv.budget_version_id = pra.budget_version_id
  and pra.resource_assignment_id = pbl.resource_assignment_id
  and pbv.fin_plan_type_id = pfpt.fin_plan_type_id
  and ti.cal_period_id  = p_time_id
  and pbl.start_date between ti.start_date and ti.end_date
  and pfpt.fin_plan_type_id <> 10
  and pbv.project_id = p_project_id
  and pbv.budget_status_code = p_budget_status
  and pfpt.name = p_fin_plan_name
  and pra.rbs_element_id = p_rbs_element_id
  AND PBV.CURRENT_FLAG = P_CURRENT;
  
  
  return retval;
END XX_PA_GET_BUDGET_AMT2;
 

/
