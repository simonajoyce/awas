--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PO_TO_APPROVER_DOC
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PO_TO_APPROVER_DOC" 
(
  P_PO_HEADER_ID IN NUMBER  
) RETURN VARCHAR2 AS 

retval varchar2(1);

BEGIN

select 'Y'
into retval
	        from fnd_attached_documents fad, fnd_documents_tl fdt, fnd_lobs fl
	       where (   (entity_name = 'PO_RELEASES' and fad.pk1_value = p_po_header_id)
	              OR (entity_name = 'PO_HEADERS' AND fad.pk1_value = p_po_header_id)
	              OR (entity_name = 'PO_HEADERS' AND fad.pk1_value = (SELECT po_header_id
	                                                                    from po_releases_all
	                                                                   WHERE po_release_id = p_po_header_id))
	              OR (entity_name = 'PO_LINES' AND pk1_value IN (SELECT po_line_id
	                                                               from po_lines_all
	                                                              WHERE po_header_id = p_po_header_id))
	              OR (entity_name = 'PO_LINES' AND pk1_value IN (SELECT po_line_id
	                                                               FROM po_lines_all
	                                                              WHERE po_header_id = (SELECT po_header_id
	                                                                                      from po_releases_all
	                                                                                     WHERE po_release_id = p_po_header_id)))
	              OR (entity_name = 'PO_SHIPMENTS' AND pk1_value IN (SELECT line_location_id
	                                                                   from po_line_locations_release_v
	                                                                  WHERE po_release_id = p_po_header_id))
                             )
	         AND fad.document_id = fdt.document_id
	         and fdt.media_id = fl.file_id
           and fdt.description <> 'POR:See Address Below'
	         AND fl.upload_date IS NOT NULL
	         AND (fl.expiration_date IS NULL OR fl.expiration_date > SYSDATE)
	         and fl.program_name is not null
           and fad.category_id = 36
           union
           SELECT 'Y'
	         FROM fnd_attached_documents fad, fnd_documents_tl fdt, fnd_lobs fl
           WHERE fad.document_id = fdt.document_id
           and fdt.media_id = fl.file_id
           and fad.category_id = 36
           and fdt.description <> 'POR:See Address Below'
	         and (fl.expiration_date is null or fl.expiration_date > sysdate)
           AND ((entity_name = 'REQ_LINES' and pk2_value is null  AND pk1_value in (SELECT distinct rl.requisition_line_id
                             FROM po_distributions_all pod,
                                  po_req_distributions_all rd,
                                  po_requisition_lines_all rl           
                             WHERE pod.req_distribution_id = rd.distribution_id (+)
                             and rd.requisition_line_id = rl.requisition_line_id (+)
                             AND po_header_id = p_po_header_id))
                             OR (entity_name = 'REQ_HEADERS' AND pk1_value in (SELECT distinct rl.requisition_header_id
                                                                   FROM po_distributions_all pod,
                                                                   po_req_distributions_all rd,
                                                                   po_requisition_lines_all rl           
                                                                   WHERE pod.req_distribution_id = rd.distribution_id (+)
                                                                   and rd.requisition_line_id = rl.requisition_line_id (+)
                                                                   and po_header_id = p_po_header_id)))
           ;



  return retval;
  
END XX_PO_TO_APPROVER_DOC;
 

/
