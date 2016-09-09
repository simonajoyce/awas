--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_REQ_APPROVER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_REQ_APPROVER" (P_INVOICE_ID NUMBER) RETURN VARCHAR2 AS 

CURSOR c1 IS 
select distinct 'A',
      prh.segment1 req_num, 
      pah.sequence_num, 
      'REQ:'||pah.action_code action_Code, pap.full_name, poh.segment1 po_num
FROM po_distributions_all pda,
po_headers_all poh,
po_req_distributions_all prd,
po_requisition_lines_all prl,
po_action_history pah,
per_all_people_f pap,
po_requisition_headers_all prh
WHERE  pda.req_distribution_id = prd.distribution_id
and poh.po_header_id = pda.po_header_id
AND prd.requisition_line_id = prl.requisition_line_id
AND pah.object_type_code = 'REQUISITION'
AND pah.object_id = prh.requisition_header_id
and pah.employee_id = pap.person_id
AND prh.requisition_header_id = prl.requisition_header_id
and pah.action_code <> 'FORWARD'
and sysdate between pap.effective_start_date and pap.effective_end_date
and pda.po_distribution_id in (select po_distribution_id from ap_invoice_distributions_all where invoice_id = p_invoice_id)
union all
select distinct 'B', null,
      pah.sequence_num, 
      'PO:'||pah.action_code, pap.full_name, poh.segment1 po_num      
FROM po_distributions_all pda,
po_headers_all poh,
po_action_history pah,
per_all_people_f pap
where poh.po_header_id = pda.po_header_id
and pah.object_type_code = 'PO'
and poh.po_header_id = pah.object_id
and pah.employee_id = pap.person_id
and pah.action_code not in ('FORWARD','SUBMIT','REJECT','CLOSE')
and sysdate between pap.effective_start_date and pap.effective_end_date
and pda.po_distribution_id in (select po_distribution_id from ap_invoice_distributions_all where invoice_id = p_invoice_id
and expenditure_type is not null)
order by 1, sequence_num;

retval varchar2(2000);
xt number;

BEGIN

xt := 0;
retval := NULL;

FOR r1 IN c1
loop

IF r1.action_code = 'REQ:SUBMIT'
then retval := retval||'Req Num: '||r1.req_num||' PO Num:'||r1.po_num;
elsif xt = 0
then
retval := retval||'Req Num: '||r1.req_num||' PO Num:'||r1.po_num||chr(13);
xt :=xt+1;

end if;

retval := retval||' '||r1.action_code||' - '||r1.full_name||chr(13);

END loop;


  RETURN retval;
END XX_AP_REQ_APPROVER;
 

/
