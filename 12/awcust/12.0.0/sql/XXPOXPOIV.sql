REM $Header: POXPOIV.sql 115.8 2002/03/11 16:17:58 pkm ship    $
set doc off
/*******************************************************************/
/* FILENAME: POXPOIV.sql					   */
/*								   */
/* DESCRIPTION:							   */
/* 	This SQL script is used to run the Pay On Receipt program  */
/* through the Standard Report Submissions.			   */
/*								   */
/* PARAMETERS:							   */
/*	   1     -- transaction_source (either ASBN or ERS)	   */
/*	   2	 -- commit interval				   */
/*	   3     -- receipt_num	
/*         4     -- Last Receipt Date				   */
/* CHANGE HISTORY:						   */
/*	5/6/96		KKCHAN		Created			   */
/*	9/25/96		GTUMMALA	Source controlling under8.0*/
/*  19-Sep-2013 SJOYCE R12 Version customised for AWAS
/*******************************************************************/
REM dbdrv:none
-- SET serveroutput ON
SET feedback OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

DECLARE
     X_progress 		VARCHAR2(3);
     X_shipment_header_id	NUMBER;
BEGIN
    
    
    asn_debug.put_line('Shipment Header ID from runtime parameter = ' || TO_CHAR(X_shipment_header_id));

    /*** begin processing ***/
    xx_po_invoices_sv1.create_ap_invoices('&&1', '&&2', '&&3', '&&4');

EXCEPTION
WHEN others THEN 
     po_message_s.sql_error('XXPOXPOIV.sql', X_progress, sqlcode);
     po_message_s.sql_show_error;
    
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     RAISE;
END;
/
/*** We can call the interface errors report here ***/
COMMIT;
EXIT;