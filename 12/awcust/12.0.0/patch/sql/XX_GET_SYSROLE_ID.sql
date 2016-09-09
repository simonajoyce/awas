--------------------------------------------------------
--  File created - Wednesday-September-23-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GET_SYSROLE_ID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GET_SYSROLE_ID" 
(
  ROLE_NAME IN VARCHAR2 
) RETURN NUMBER AS 

retval number;
BEGIN

select cast (DECODE(SUBSTR(ROLE_NAME,1,3),'UMX',DECODE(instr( ROLE_NAME,'X',4),0,-1,SUBSTR(ROLE_NAME,instr(ROLE_NAME,'X',4)+1,LENGTH(ROLE_NAME)-
              instr(ROLE_NAME,'X',4))),                                         -1) as number)
into retval
from dual;

  RETURN retval;
exception when others then
retval:= -1;
  RETURN retval;
END XX_GET_SYSROLE_ID;

/
