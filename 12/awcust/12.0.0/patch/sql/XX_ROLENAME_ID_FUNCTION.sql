--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_ROLENAME_ID_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_ROLENAME_ID_FUNCTION" 
(
  ROLE_NAME IN VARCHAR2  
) RETURN NUMBER AS 
x number;

BEGIN
SELECT substr(role_name,instr(role_name,'X',4)+1,5)*1
INTO x
from dual;

  RETURN x;
  
EXCEPTION
WHEN others THEN
x := NULL;
  RETURN x;
END XX_ROLENAME_ID_FUNCTION;
 

/
