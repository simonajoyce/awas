--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_VIEW_REQ
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_VIEW_REQ" 
(
  P_INVOICE_ID IN NUMBER  
) RETURN VARCHAR2 AS 

retval varchar2(2000);

cursor c1 is
select distinct 'https://oracle.awas.com/OA_HTML/OA.jsp?page=/oracle/apps/icx/por/reqmgmt/webui/ReqDetailsPG'||chr(38)||'retainAM=Y'||chr(38)||'addBreadCrumb=Y'||chr(38)||'reqHeaderId='||prla.requisition_header_id URL
    from ap_invoice_distributions_all aid,
    po_distributions_all pda,
    po_req_distributions_all prda,
    po_requisition_lines_all prla,
    po_requisition_headers_all prha
    where aid.po_distribution_id is not null
    and aid.po_distribution_id = pda.po_distribution_id
    and pda.req_distribution_id = prda.distribution_id
    and prla.requisition_line_id = prda.requisition_line_id
    and prha.requisition_header_id = prla.requisition_header_id
    and aid.invoice_id = p_invoice_id;
  
begin
retval := null;

FOR r1 IN c1
loop

if retval is null then
retval := r1.url;
else

retval := retval||chr(13)||r1.url;

end if;

end loop;

  return retval;
  
END XX_AP_VIEW_REQ;
 

/
