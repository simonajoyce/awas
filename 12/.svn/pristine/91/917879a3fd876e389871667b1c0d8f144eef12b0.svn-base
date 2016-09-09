--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_GET_BUDGET_AMT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_GET_BUDGET_AMT" 
(
  P_PROJECT_ID IN NUMBER  
, P_BUDGET_STATUS IN VARCHAR2  
, P_FIN_PLAN_NAME IN VARCHAR2  
, P_CURRENT IN VARCHAR2  
) RETURN NUMBER AS 

retval number;

begin

  SELECT 
    pbv.burdened_cost
    INTO RETVAL
  FROM pa_budget_versions pbv,
    pa_fin_plan_types_tl pfpt
  where pbv.fin_plan_type_id = pfpt.fin_plan_type_id
  and pfpt.fin_plan_type_id <> 10
  and pbv.project_id = p_project_id
  and pbv.budget_status_code = p_budget_status
  and pfpt.name = p_fin_plan_name
  AND PBV.CURRENT_FLAG = P_CURRENT;
  
  RETURN retval;
END XX_PA_GET_BUDGET_AMT;
 

/
