--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_MODS_COST_ESTIMATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_MODS_COST_ESTIMATE" 
(
  P_PROJECT_ID IN NUMBER
, P_PERIOD_NAME IN VARCHAR2
) RETURN NUMBER AS

/* this funciton returns the MODS cost estimate value for the project
-- with the closest period before the p_period_name
*/
l_msn varchar2(6);
l_start_date date;
retval number;

begin

select to_number(attribute1)
into l_msn
from pa_projects_all
where project_id = p_project_id;

select start_Date
into l_start_Date
from gl_periods
where period_set_name = 'AWAS'
and period_name = p_period_name;

select sum(
c.mod_cost_amount)
into retval
from tblmodcostestimate@basin e,
tblmodaccrual@basin a,
tblaircraftlease@basin l,
tblmodcostamount@basin c,
tlkpmodcategory@basin cat,
tlkpfinperiod@basin p,
(select max(e1.mod_accrual_id) mod_accrual_id, max(p1.start_date) start_date , max(e1.mod_cost_estimate_id) ce_id
                           from tblmodcostestimate@basin e1,
                           tlkpfinperiod@basin p1,
                           tblmodaccrual@basin a1,
                           tblaircraftlease@basin l1
                           where e1.period_id = p1.period_id
                           and p1.start_date <= l_start_date
                           and a1.mod_accrual_id = e1.mod_accrual_id
                           and l1.aircraft_lease_no = a1.ex_aircraft_lease_no
                           and fngetmsn@basin(l1.aircraft_no) = l_msn
                           group by fngetmsn@basin(l1.aircraft_no)
                           ) est_max
where a.mod_accrual_id = e.mod_accrual_id
and l.aircraft_lease_no = a.ex_aircraft_lease_no
and fngetmsn@basin(l.aircraft_no) = l_msn
and e.mod_cost_estimate_id = c.mod_cost_estimate_id
and c.mod_category_id = cat.mod_category_id
and e.period_id = p.period_id
and p.start_date = est_max.start_date
and e.mod_cost_estimate_id = est_max.ce_id
and e.mod_accrual_id = est_max.mod_accrual_id;


  RETURN retval;


END XX_PA_MODS_COST_ESTIMATE;

/
