--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PROJECT_USER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PROJECT_USER" (p_project_id IN NUMBER, p_person_id IN NUMBER) 
RETURN varchar2

IS

retval varchar2 (10);

begin

SELECT 'TRUE'
into retval
FROM pa_project_players
WHERE project_id = p_project_id
AND person_id = p_person_id
AND SYSDATE BETWEEN start_date_active AND nvl(end_date_active,SYSDATE+1);

return retval;

end;
 

/
