--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_BUDGET_VERSIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_BUDGET_VERSIONS" ("PROJECT_ID", "VERSION_NUMBER", "VERSION_NAME", "BUDGET_STATUS_CODE", "CURRENT_FLAG", "ORIGINAL_FLAG", "RAW_COST", "BURDENED_COST", "FINANCIAL_PLAN_NAME") AS 
  select  pbv.project_id,
        pbv.version_number, 
        pbv.version_name,
        pbv.budget_status_code,   -- S = Submitted W = Working
        pbv.current_flag,
        pbv.original_flag,
        pbv.raw_cost,
        pbv.burdened_cost,
        pfpt.name  financial_plan_name      
from pa_budget_versions pbv,
pa_fin_plan_types_tl pfpt
where pbv.fin_plan_type_id = pfpt.fin_plan_type_id
and pfpt.fin_plan_type_id <> 10
 ;
