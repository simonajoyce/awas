--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_EXP_APPROVER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_EXP_APPROVER" (
      P_INVOICE_ID NUMBER)
    RETURN VARCHAR2
  AS
    /*
    REM +==================================================================+
    REM |                Copyright (c) 2013 Version 1
    REM +==================================================================+
    REM |  Name
    REM |    Function xx_ap_exp_approver
    REM |
    REM |  Description
    REM |   Function to return the approver list of an expense report.
    REM |   Used in many discoverer and BI reports
    REM |
    REM |  History
    REM |    08-Jul-13   SJOYCE     CREATED
    REM |
    REM +==================================================================+
    */
    CURSOR c1
    IS
      SELECT
        fu.description
      FROM
        ap_invoices_all aia,
        ap_expense_report_headers_all aerh,
        ap_notes an,
        fnd_user fu
      WHERE
        aia.invoice_id        = p_invoice_id
      AND aia.invoice_num     = aerh.invoice_num
      AND an.source_object_id = aerh.report_header_id
      AND an.notes_detail LIKE 'Approver Action: Approve%'
      AND FU.USER_ID = AN.ENTERED_BY;

    retval VARCHAR2(2000);

  BEGIN
    retval := NULL;
    FOR r1 IN c1
    LOOP
      retval := retval||r1.description||',';
    END LOOP;
    RETURN retval;
  END XX_AP_EXP_APPROVER;

/
