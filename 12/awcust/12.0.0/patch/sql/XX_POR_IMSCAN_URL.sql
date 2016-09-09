--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_POR_IMSCAN_URL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_POR_IMSCAN_URL" 
(
  P_INVOICE_ID IN NUMBER  
) RETURN VARCHAR2 AS 
IMSCAN varchar2(240);
BEGIN



SELECT '<a href="https://imscan.awas.com/AwasDocView/View/Doc?token=19-'||x.d_id||' " target="_blank">View Invoice</a>'
INTO IMSCAN
FROM ap_invoices_all ai,
xx_imscan_link@basin x
where invoice_id = p_invoice_id
and nvl(ai.doc_sequence_value,ai.voucher_num) = x.Oracle_Voucher (+)
;

  --imscan := 'www.google.ie';

  RETURN IMSCAN;
END XX_POR_IMSCAN_URL;

/
