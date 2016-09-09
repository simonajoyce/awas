CREATE OR REPLACE PACKAGE XX_AP_APPROVAL_WF IS

PROCEDURE AP_DISTRIBUTION_DETAILS( p_invoice_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
                                   document_type	IN OUT	NOCOPY VARCHAR2
);


PROCEDURE AP_SUPPLIER_INV_ATTRIBUTE(p_invoice_id	IN NUMBER,
	 			    display_type	IN VARCHAR2 DEFAULT 'text/html',
		  		    document		IN OUT	NOCOPY VARCHAR2,
                                    document_type	IN OUT	NOCOPY VARCHAR2);

END XX_AP_APPROVAL_WF;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AP_APPROVAL_WF AS

TYPE ap_inv_dist_record IS RECORD
		(
		  line_type        	ap_invoice_distributions_all.line_type_lookup_code %TYPE,
		  msn	   	          VARCHAR2(6),
		  po_number	   	po_headers_all.segment1%TYPE,
		  item_desc   	   	po_lines_all.item_description%TYPE,
		  qty_inv	   	ap_invoice_distributions_all.quantity_invoiced%TYPE,
		  unit_price	   	ap_invoice_distributions_all.unit_price%TYPE,
		  inv_amount	   	ap_invoice_distributions_all.amount%TYPE,
		  qty_ordered	   	po_distributions_all.quantity_ordered%TYPE,
		  po_unit_price	   	po_line_locations_all.PRICE_OVERRIDE%TYPE,
		  po_variance	   	NUMBER,
      exp_type ap_invoice_distributions_all.expenditure_type%TYPE,
		  gl_code_combination	varchar2(40),
      gl_desc varchar2(400)
		 );




PROCEDURE AP_DISTRIBUTION_DETAILS( p_invoice_id		IN NUMBER ,
		  		   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document		IN OUT	NOCOPY VARCHAR2,
                                   document_type	IN OUT	NOCOPY VARCHAR2
) IS


  l_item_type    		wf_items.item_type%TYPE;
  l_item_key     		wf_items.item_key%TYPE;
  l_invoice_id 			ap_invoices_all.invoice_id%TYPE;
  l_org_id			ap_invoice_distributions.org_id%TYPE;

  l_line			ap_inv_dist_record;
  l_document			VARCHAR2(32000) := '';

  NL				VARCHAR2(1) := fnd_global.newline;
  i				NUMBER := 0;
  max_lines_dsp			NUMBER := 20;
  line_mesg			VARCHAR2(240);
  curr_len			NUMBER := 0;
  prior_len			NUMBER := 0;

 cursor ap_inv_dist_lines_cur ( v_invoice_id number) is
   SELECT aid.line_type_lookup_code TYPE,
  	  gcc.segment4 msn,
  	  poh.segment1 po_number,
  	  aid.description,
  	  sum(aid.quantity_invoiced) qty_inv,
  	  round(AVG(aid.unit_price),2) inv_unit_price,
  	  SUM(aid.amount) inv_amount,
  	  DECODE(aid.line_type_lookup_code,'tax','',
          SUM(pda.quantity_ordered)) qty_ord,
  	     DECODE(aid.line_type_lookup_code,'tax','',
                   AVG(pll.price_override)) po_unit_price,
  	   ((SUM(aid.quantity_invoiced))* (AVG(pll.price_override)) -
           SUM(aid.amount)) po_variance,
      aid.expenditure_type exp_type,
  	   (gcc.segment1||'.'||gcc.segment2||'.'||
           gcc.segment3||'.'||gcc.segment4||'.'||
           gcc.segment5||'.'||gcc.segment6||'.'||
           gcc.segment7 )gl_code_combination,
           XX_GL_CODE_DESCRIPTION(gcc.code_combination_id) GL_DESC
           
  FROM     PO_VENDORS POV,
  	   PO_HEADERS_ALL POH,
  	   PO_LINES_ALL POL,
  	   PO_LINE_LOCATIONS_ALL PLL,
  	   PO_DISTRIBUTIONS_ALL PDA,
  	   GL_CODE_COMBINATIONS GCC,
  	   AP_INVOICES_ALL AIA,
  	   AP_INVOICE_DISTRIBUTIONS_ALL AID
  WHERE    POV.VENDOR_ID 			= AIA.VENDOR_ID
  	   AND AIA.INVOICE_ID 			= AID.INVOICE_ID
  	   AND PDA.PO_DISTRIBUTION_ID (+) 	= AID.PO_DISTRIBUTION_ID
  	   AND POH.PO_HEADER_ID (+) 		= PDA.PO_HEADER_ID
  	   AND PLL.LINE_LOCATION_ID (+) 	= PDA.LINE_LOCATION_ID
  	   AND POL.PO_LINE_ID (+)			= PDA.PO_LINE_ID
  	   and gcc.code_combination_id 		= aid.dist_code_combination_id
  	   and aia.invoice_id 			= v_invoice_id
       and nvl(aid.reversal_flag,'N') = 'N'
       having sum(aid.amount) <> 0
GROUP BY AID.LINE_TYPE_LOOKUP_CODE,
  	   GCC.SEGMENT4,
  	   POH.SEGMENT1,
   	   AID.DESCRIPTION,
       aid.expenditure_type,
  	   GCC.SEGMENT1||'.'||GCC.SEGMENT2||'.'||
           gcc.segment3||'.'||gcc.segment4||'.'||
           gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7,
           xx_gl_code_description(gcc.code_combination_id)
  ORDER BY 1, 2, 3, 4;



  v_code_combination      VARCHAR2(100);
  v_count_cc		  NUMBER;
  v_display_price	  VARCHAR2(1);
  v_error		  VARCHAR2(2000);
  v_all_code_combinations VARCHAR2(30000);
  v_quantities		  VARCHAR2(30000);

BEGIN

  l_invoice_id := p_invoice_id;
  max_lines_dsp := 20;

  IF (display_type = 'text/html') THEN

    	l_document := NL || NL || '<!-- INVOICE DETAILS -->'|| NL || NL || '<P><B>';
    	l_document := l_document || fnd_message.get_string('AWCUST', 'Invoice Line Details');
    	l_document := l_document || '</B>';

        l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_PO_TO_APPROVE_SUM') || '"> '|| NL;
    	l_document := l_document || '<TR>' || NL;
    	/*l_document := l_document || '<TH  id="DIST_NUM">' ||'Dist. No' || '</TH>' || NL; */
	l_document := l_document || '<TH  id="TYPE">' ||'Line Type'|| '</TH>' || NL;
  l_document := l_document || '<TH  id="MSN">' || 'MSN' || '</TH>' || NL;
  l_document := l_document || '<TH  id="EXP_TYPE">' || 'Expenditure Type' || '</TH>' || NL;
  l_document := l_document || '<TH  id="PO_NUMBER">' ||'PO Number'|| '</TH>' || NL;
	l_document := l_document || '<TH  id="ITEM_DESC">' ||'Item Desc'|| '</TH>' || NL;
  l_document := l_document || '<TH  id="QTY_INV">' ||'Qty Invoiced' || '</TH>' || NL;
  l_document := l_document || '<TH  id="INV_UNIT_PRICE">' ||'Inv unitprice' || '</TH>' || NL;
  l_document := l_document || '<TH  id="INV_AMOUNT">' ||'Inv Amount' || '</TH>' || NL;
  l_document := l_document || '<TH  id="QTY_ORD">' ||'Qty Ordered' || '</TH>' || NL;
  l_document := l_document || '<TH  id="PO_UNIT_PRICE">' || 'PO Unit Price' || '</TH>' || NL;
	l_document := l_document || '<TH  id="PO_VARIANCE">' || 'PO Variance' || '</TH>' || NL;
	l_document := l_document || '<TH  id="GL_CODE_COMBINATION">' || 'GL Code' || '</TH>' || nl;
  l_document := l_document || '<TH  id="GL_DESC">' || 'GL Account Desc' || '</TH>' || NL;
    	l_document := l_document || '</TR>' || NL;

        curr_len  := LENGTHB(l_document);
        prior_len := curr_len;

    	OPEN ap_inv_dist_lines_cur(l_invoice_id);

    	LOOP
  	  FETCH ap_inv_dist_lines_cur INTO l_line;
 		i := i + 1;
      		EXIT WHEN ap_inv_dist_lines_cur%NOTFOUND;

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                prior_len := curr_len;
      		l_document := l_document || '<TR>' || NL;
      		/*l_document := l_document || '<TD nowrap align=center headers="DIST_NUM">'
				         || NVL(TO_CHAR(l_line.DIST_NUM), '&'||'nbsp') || '</TD>' || NL;*/

      		l_document := l_document || '<TD nowrap headers="TYPE">'
				         || NVL(l_line.Line_type, '&'||'nbsp') || '</TD>' || NL;
                 
          l_document := l_document || '<TD nowrap align=left headers="MSN">'
					 || NVL(l_line.msn,0) || '</TD>' || NL;
           
           l_document := l_document || '<TD nowrap align=left headers="EXP_TYPE">'
					 || NVL(l_line.exp_type,0) || '</TD>' || NL;

      		l_document := l_document || '<TD nowrap headers="PO_NUMBER">'
				         || NVL(l_line.po_number, '&'||'nbsp') || '</TD>' || NL;

      		l_document := l_document || '<TD nowrap headers="ITEM_DESC">'
					 || NVL(l_line.item_desc, '&'||'nbsp') || '</TD>' || NL;

      		l_document := l_document || '<TD nowrap headers="QTY_INV">'
					 || NVL(l_line.qty_inv,0) || '</TD>' || NL;

     		l_document := l_document || '<TD nowrap align=right headers="UNIT_PRICE">'
					 || NVL(l_line.unit_price,0) || '</TD>' || NL;

		l_document := l_document || '<TD nowrap align=right headers="INV_AMOUNT">'
					 || NVL(l_line.inv_amount,0) || '</TD>' || NL;

		l_document := l_document || '<TD nowrap align=right headers="QTY_ORDERED">'
					 || NVL(l_line.qty_ordered,0) || '</TD>' || NL;


		l_document := l_document || '<TD nowrap align=right headers="PO_UNIT_PRICE">'
					 || NVL(l_line.PO_UNIT_PRICE,0) || '</TD>' || NL;

		l_document := l_document || '<TD nowrap align=right headers="PO_VARIANCE">'
					 || NVL(l_line.PO_VARIANCE,0) || '</TD>' || NL;

		l_document := l_document || '<TD nowrap align=left headers="GL_CODE_COMBINATION">'
					 || NVL(l_line.gl_code_combination,0) || '</TD>' || NL;

    l_document := l_document || '<TD nowrap align=left headers="GL_DESC">'
					 || nvl(l_line.gl_desc,0) || '</TD>' || nl;

		l_document := l_document || '</TR>' || NL;

                EXIT WHEN i = max_lines_dsp;

                curr_len  := LENGTHB(l_document);
    	END LOOP;
	l_document := l_document || '</TABLE></P>' || NL;

    	CLOSE ap_inv_dist_lines_cur;

	END IF;

	document:= l_document;
END;


PROCEDURE AP_SUPPLIER_INV_ATTRIBUTE(p_invoice_id	IN NUMBER,
	 			    display_type	IN VARCHAR2 DEFAULT 'text/html',
		  		    document		IN OUT	NOCOPY VARCHAR2,
                                    document_type	IN OUT	NOCOPY VARCHAR2) IS
BEGIN

	 SELECT DECODE(aia.source, 'SUNDRY CHEQUES',aia.attribute9, pv.vendor_name)
	 INTO 	document
	 FROM 	po_vendors pv,
	 	    ap_invoices_all aia
	 WHERE  invoice_id = p_invoice_id
	 AND    pv.vendor_id = aia.vendor_id;

END;



END XX_AP_APPROVAL_WF;
/
