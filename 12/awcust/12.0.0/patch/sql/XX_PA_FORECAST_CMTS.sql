--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_FORECAST_CMTS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_FORECAST_CMTS" 
(
  p_project_id in number  
) RETURN VARCHAR2 AS 


retval varchar2(240);

begin

select distinct 
    pbv.description cforecast_description
  into retval
FROM
  pa_budget_versions pbv,
  pa_fin_plan_types_tl pfpt,
  pa_projects_all pa
WHERE
   pbv.fin_plan_type_id       = pfpt.fin_plan_type_id
and pfpt.name                  = 'TAM Accrual Forecast'
and pbv.budget_status_code = 'S'
AND pfpt.fin_plan_type_id     <> 10
and pbv.project_id             = pa.project_id
and pbv.baselined_date        is null
and pa.project_Id = p_project_id;

  RETURN retval;
  
  
END XX_PA_FORECAST_CMTS;
 

/
