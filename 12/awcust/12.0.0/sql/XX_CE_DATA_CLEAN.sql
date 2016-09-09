CREATE OR REPLACE PACKAGE XX_CE_DATA_CLEAN AS

/* ----------------------------------------------------------------*/
-- Developed By Simon Joyce
-- Script scheduled as a concurrent request to remove trailing whitespace
-- in CE tables and update bank statements as complete when fully reconciled

/*-- Main Procedure called from Apps */
     PROCEDURE MAIN (              errorbuf OUT VARCHAR2,retcode OUT VARCHAR2 ) ;

END XX_CE_DATA_CLEAN;

/


CREATE OR REPLACE PACKAGE BODY xx_ce_data_clean AS

PROCEDURE MAIN (              errorbuf out VARCHAR2,retcode out VARCHAR2 )  AS
  BEGIN

-- Update statements to complete as necessary
UPDATE CE_STATEMENT_HEADERS
SET statement_complete_flag = 'Y'
WHERE statement_complete_flag <> 'Y'
AND STATEMENT_HEADER_ID NOT IN (SELECT DISTINCT STATEMENT_HEADER_ID FROM CE_STATEMENT_LINES);

COMMIT;

-- Remove whitespace from lines
UPDATE ce_statement_lines
SET trx_text = trim(trx_text),
    invoice_text = trim(invoice_text),
    customer_text = trim(customer_text),
    bank_account_text = trim(bank_account_text)
WHERE status <> 'RECONCILED';

COMMIT;

-- Remove whitespace from interface
UPDATE  ce_statement_lines_interface
SET trx_text = trim(trx_text),
    invoice_text = trim(invoice_text),
    customer_text = trim(customer_text),
    bank_account_text = trim(bank_account_text);

COMMIT;

-- Update statements to complete as necessary
UPDATE CE_STATEMENT_HEADERS
SET statement_complete_flag = 'Y'
WHERE statement_header_id IN (SELECT statement_header_id FROM (
SELECT l.statement_header_id, sum(decode(status,'RECONCILED
',1,'EXTERNAL',1,0)), count(status)
FROM ce_statement_lines l, CE_STATEMENT_HEADERS h
WHERE h.statement_header_id = l.statement_header_id
AND h.statement_complete_flag <> 'Y'
HAVING sum(decode(l.status,'RECONCILED',1,'EXTERNAL',1,0))=count(l.status)
GROUP BY l.statement_header_id) x)
;

COMMIT;
    -- Clean AP Expense REports with missing exchange rates
UPDATE ap_expense_report_headers_all x
SET default_exchange_rate = (SELECT conversion_rate
                            FROM gl_daily_rates r
                            WHERE r.to_currency = 'USD'
                            AND   r.from_currency = x.default_currency_code
                            AND   r.conversion_date <= x.default_exchange_date
                            AND   r.conversion_date = (SELECT MAX(conversion_date) FROM gl_daily_rates WHERE conversion_date <= x.default_exchange_date))
WHERE reject_code = 'No exchange rate';

COMMIT;
--populate expense flexfield in AP
UPDATE ap_invoice_distributions_all
SET attribute10 = substr(justification,1,150)
WHERE justification IS NOT NULL
AND ATTRIBUTE10 IS NULL;
COMMIT;
-- populate Pay group look up codes
 UPDATE ap_invoices_all x
  set pay_group_lookup_code =
  XX_AP_GET_PAYGROUP((SELECT C.SEGMENT1
                                      FROM GL_CODE_COMBINATIONS C,
                                      ap_invoice_Distributions_all l
                                      WHERE C.CODE_COMBINATION_ID = L.DIST_CODE_COMBINATION_ID
                                      AND L.REVERSAL_FLAG = 'N'
                                      and L.INVOICE_DISTRIBUTION_ID = (select min(t.INVOICE_DISTRIBUTION_ID) from ap_invoice_distributions_all t where invoice_id = l.invoice_id and t.reversal_flag = 'N')
                                      AND L.INVOICE_ID = X.INVOICE_ID)  ,
                                      UPPER(X.INVOICE_CURRENCY_CODE)
                                      )
  WHERE  nvl(PAY_GROUP_LOOKUP_CODE,'X') <> 'EMPLOYEES'
  AND NVL(PAYMENT_STATUS_FLAG,'N') = 'N'
  and cancelled_date is null ;

COMMIT;

  UPDATE AP_INVOICES_ALL X
  SET PAY_GROUP_LOOKUP_CODE = 'EMPLOYEES'
  WHERE INVOICE_TYPE_LOOKUP_CODE = 'EXPENSE REPORT'
  AND NVL(PAY_GROUP_LOOKUP_CODE,'X') <> 'EMPLOYEES'
  AND NVL(PAYMENT_STATUS_FLAG,'N') = 'N';

COMMIT;

UPDATE AP_PAYMENT_SCHEDULES_ALL
SET EXTERNAL_BANK_ACCOUNT_ID = XX_GET_SUPPLIER_BANK(INVOICE_ID)
WHERE PAYMENT_STATUS_FLAG = 'N'
and AMOUNT_REMAINING <> 0
and PAYMENT_METHOD_LOOKUP_CODE = 'WIRE'
AND INVOICE_ID IN (SELECT INVOICE_ID FROM AP_INVOICES_ALL
WHERE PAYMENT_STATUS_FLAG = 'N'
and pay_group_lookup_code <> 'EMPLOYEES'  
AND CANCELLED_DATE IS NULL)
;
COMMIT;

update ap_invoices_all
SET external_bank_account_id = XX_GET_SUPPLIER_BANK(invoice_id)
WHERE PAYMENT_STATUS_FLAG = 'N'
and CANCELLED_DATE is null
and PAYMENT_METHOD_LOOKUP_CODE = 'WIRE'
and pay_group_lookup_code <> 'EMPLOYEES'
;
COMMIT;

-- Invoice Distributions descriptions
UPDATE ap_invoice_distributions_all
SET description = trim(description)
WHERE creation_date > sysdate - 1 ;

COMMIT;
-- Update workflow attributes with missing Imscan URL data
UPDATE wf_item_attribute_values w
set text_value = xx_por_imscan_url2(substr(item_key,1,6))
WHERE NAME LIKE 'IMSCAN_URL%'
AND item_type = 'APINV'
AND TEXT_VALUE = 'https://imscan.awas.com/iwp/external/viewdoc.aspx?token=19-';
COMMIT;

UPDATE wf_notification_attributes x
SET text_value = (SELECT xx_por_imscan_url2(substr(y.item_key,1,6) )
                                   FROM wf_notifications y
                                   WHERE y.notification_id = x.notification_id)
WHERE x.NAME LIKE 'IMSCAN_URL%'
AND X.TEXT_VALUE = 'https://imscan.awas.com/iwp/external/viewdoc.aspx?token=19-';
COMMIT;

-- clean up acceptances on POs
update po_headers_all
set acceptance_required_flag = 'N'
where attribute1 is null
AND ACCEPTANCE_REQUIRED_FLAG = 'Y';
COMMIT;

update po_releases_all
set acceptance_required_flag = 'N'
WHERE ACCEPTANCE_REQUIRED_FLAG = 'Y';
COMMIT;

-- fill in missing IMSCAN links on workflows.
update wf_notification_attributes z
set text_value =
(select XX_POR_IMSCAN_URL2(number_value)
from wf_notification_attributes a
where notification_id in (
select notification_id
from wf_notification_attributes
where name = 'IMSCAN_URL'
and text_value = 'https://imscan.awas.com/AwasDocView/View/Doc?token=19-'
and notification_id = z.notification_id)
and name = 'APINV_AII')
where name = 'IMSCAN_URL'
and text_value = 'https://imscan.awas.com/AwasDocView/View/Doc?token=19-'
;
COMMIT;

update wf_item_attribute_values z
set text_value =
(select XX_POR_IMSCAN_URL2(number_value)
from wf_item_attribute_values a
where item_key in (
      select item_key
      from wf_item_attribute_values
      where name = 'IMSCAN_URL'
      and text_value = 'https://imscan.awas.com/AwasDocView/View/Doc?token=19-'
      and item_key = z.item_key
      and item_type = 'APINV')
and name = 'APINV_AII'
and item_type = 'APINV')
where name = 'IMSCAN_URL'
and item_type = 'APINV'
and text_value = 'https://imscan.awas.com/AwasDocView/View/Doc?token=19-'
;
COMMIT;
-- Clean invalid non-printable characters from reqs and POs
update po_requisition_lines_all
set item_description = replace(item_description,chr(29),'')
WHERE ITEM_DESCRIPTION LIKE '%'||CHR(29)||'%';
COMMIT;
update po_lines_all
set item_description = replace(item_description,chr(29),'')
WHERE ITEM_DESCRIPTION LIKE '%'||CHR(29)||'%';
COMMIT;
-- clean trailing spaces
update po_lines_all
set item_description = trim(item_description)
WHERE ITEM_DESCRIPTION <> TRIM(ITEM_DESCRIPTION);
COMMIT;
--update project target_finish_dates to Contractual lease end dates in ALS
UPDATE PA_PROJECTS_ALL Z
set TARGET_FINISH_DATE = (SELECT X.LEASE_EDATE
FROM PA_PROJECTS_ALL P,
TBLAIRCRAFTLEASE@BASIN X
WHERE X.AIRCRAFT_LEASE_NO = TO_NUMBER(P.ATTRIBUTE7)
and p.project_id = z.project_id);
COMMIT;
-- update suggested buyers on requisitions if any pointing to AWAS Buyer
UPDATE PO_REQUISITION_LINES_ALL X
set suggested_buyer_id = (SELECT person_id
FROM pa_project_players
WHERE PROJECT_ROLE_TYPE = '1001'
AND project_id = (select attribute10 from po_requisition_headers_all where requisition_header_id = x.requisition_header_id))
WHERE REQS_IN_POOL_FLAG = 'Y'
AND SUGGESTED_BUYER_ID = 2527;
COMMIT;

  END MAIN;

END xx_ce_data_clean;
/
