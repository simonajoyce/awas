--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_COSTS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_COSTS" 
(
  P_PROJECT_ID IN NUMBER  
, P_PERIOD_NAME IN VARCHAR2  
, P_PERIOD_TYPE IN VARCHAR2  
, P_COST_TYPE IN VARCHAR2  
) return number as 

pa_cost number;
other_cost number;
retval number;

BEGIN

if P_COST_TYPE = 'PTD' then

select          sum(decode(svl.segment_value,'000000',cdl.burdened_cost,0)) ptd_cost,
                sum(decode(svl.segment_value,'000000',0,cdl.burdened_cost)) other_cost
                into pa_cost,
                other_cost
                FROM
                apps.pa_cost_distribution_lines_all cdl,
                apps.pa_expenditure_items_all ei,
                apps.pa_projects_all ppa,
                apps.hr_all_organization_units hou,
                apps.gl_code_combinations glcc,
                pa_segment_value_lookups svl
                where nvl(svl.segment_value_lookup_set_id,1) = 1
                AND ppa.carrying_out_organization_id = hou.organization_id
                and ppa.project_id = cdl.project_id
                and ppa.project_id = p_project_id
                and cdl.gl_period_name = p_period_name
                AND EI.EXPENDITURE_tYPE = SVL.SEGMENT_VALUE_LOOKUP (+)
                and cdl.expenditure_item_id = ei.expenditure_item_id
                and cdl.dr_code_combination_id = glcc.code_combination_id;
  
  else 
                select 
                sum(decode(svl.segment_value,'000000',cdl.burdened_cost,0)) ytd_cost,
                sum(decode(svl.segment_value,'000000',0,cdl.burdened_cost)) other_cost
                into pa_cost,
                other_cost
                FROM
                apps.pa_cost_distribution_lines_all cdl,
                apps.pa_expenditure_items_all ei,
                apps.pa_projects_all ppa,
                apps.hr_all_organization_units hou,
                apps.gl_code_combinations glcc,
                pa_segment_value_lookups svl,
                GL_PERIODS GP
                where nvl(svl.segment_value_lookup_set_id,1) = 1
                AND ppa.carrying_out_organization_id = hou.organization_id
                and ppa.project_id = cdl.project_id
                and ppa.project_id = p_project_id
                and gp.period_name = p_period_name
                and ei.expenditure_type = svl.segment_value_lookup (+)
                and cdl.gl_DATE <= GP.END_dATE
                AND GP.PERIOD_SET_NAME = 'AWAS'
                and cdl.expenditure_item_id = ei.expenditure_item_id
                and cdl.dr_code_combination_id = glcc.code_combination_id;
                
    end if;
    
    if p_cost_type = 'PA' then
    retval := pa_cost;
    else
    retval := other_cost;
    end if;
    
                
  return retval;
  
END XX_PA_COSTS;
 

/
