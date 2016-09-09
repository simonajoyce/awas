--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_POR_REQ_MSN
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_POR_REQ_MSN" 
(  P_REQ_HEADER_ID IN NUMBER  ) 
return varchar2 as 
MSN varchar2(30);
BEGIN

if p_req_header_id is not null then

select nvl(p.name,'Non Project') 
into MSN
from po_requisition_headers_all h,
pa_projects_all p
where h.attribute10 = p.project_id (+)
and h.requisition_header_id = p_req_header_id;

else

msn := null;

end if;

return msn;


END XX_POR_REQ_MSN;
 

/
