--------------------------------------------------------
--  File created - Thursday-April-23-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_GET_SCHED_DATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_GET_SCHED_DATE" 
(
  P_PROJECT_ID in number,
  P_DATE_TYPE in varchar2 -- D for Delivery R for return
) return date as 

RETVAL date;
DEL    date;
ret    date;

begin

select max(DECODE(PE.Type_ID,13160,SCH.SCHEDULED_FINISH_DATE,null)) SCHEDULED_RETURN_DATE,
       max(DECODE(PE.TYPE_ID,14160,SCH.SCHEDULED_FINISH_DATE,null)) SCHEDULED_DELIVERY_DATE
into ret, del
from 
      PA_PROJ_ELEM_VER_STRUCTURE PEVS,
      PA_PROJ_ELEMENT_VERSIONS PEV,
      PA_PROJ_ELEMENTS PE,
      PA_PROJ_ELEM_VER_SCHEDULE SCH,
      PA_PROJ_STRUCTURE_TYPES PST
where PEVS.PROJECT_ID = P_PROJECT_ID
and   PEVS.SOURCE_OBJECT_TYPE = 'PA_PROJECTS'
and   PEVS.ELEMENT_VERSION_ID = PEV.PARENT_STRUCTURE_VERSION_ID
and   PEV.OBJECT_TYPE = 'PA_TASKS'
and   PE.PROJ_ELEMENT_ID = PEV.PROJ_ELEMENT_ID
and   SCH.ELEMENT_VERSION_ID (+) = PEV.ELEMENT_VERSION_ID
and   PST.STRUCTURE_TYPE_ID = 1  -- workplans only
and   PST.PROJ_ELEMENT_ID = PEVS.PROJ_ELEMENT_ID
and   PEVS.LATEST_EFF_PUBLISHED_FLAG = 'Y'
and   pe.TYPE_ID in (13160,14160);

if P_DATE_TYPE = 'D' then
  RETVAL := DEL;
else
  RETVAL := RET;
end if;

  return RETVAL;
  
END XX_PA_GET_SCHED_DATE;

/
