CREATE OR REPLACE PACKAGE XX_AWAS_AR_INVOICE_LOAD
IS
/*------------------------------------------------------------------*/
/* XX_AWAS_AR_INVOICE_LOAD Package Specification   Version 1.0      */
/* Written by Simon Joyce 10-02-2009                                */
/*------------------------------------------------------------------*/

	PROCEDURE MAIN(errbuf	OUT VARCHAR2,
                 RETCODE	OUT NUMBER,
                 p_period IN VARCHAR2,
                 P_INVOICE_TYPE IN VARCHAR2);

   FUNCTION GET_CONTACT(  P_CUSTOMER_ID IN NUMBER
                          , P_PARTY_SITE_ID IN NUMBER  )return number;

    -- Procedure to write message in log file.
  PROCEDURE	write_log( p_message	IN VARCHAR2 			 );

  -- Procedure to debug messages to log file
  PROCEDURE	write_debug( p_message	IN VARCHAR2		   );

  -- Procedure to write message on output file.
  PROCEDURE	write_out( p_message	IN VARCHAR2 			 );

   PROCEDURE submit_conc_request( p_application  IN   VARCHAR2
			       , p_program	IN   VARCHAR2
			       , p_sub_request  IN   BOOLEAN
			       , p_parameter1   IN   VARCHAR2
			       , p_parameter2	IN   VARCHAR2
			       , p_parameter3	IN   VARCHAR2
			       , p_parameter4	IN   VARCHAR2
			       , p_parameter5   IN   VARCHAR2
			       , p_parameter6	IN   VARCHAR2
			       , p_parameter7	IN   VARCHAR2
			       , p_parameter8	IN   VARCHAR2
			       , p_parameter9   IN   VARCHAR2
			       , p_parameter10	IN   VARCHAR2
			       , p_parameter11	IN   VARCHAR2
			       , p_parameter12	IN   VARCHAR2
			       , p_parameter13  IN   VARCHAR2
			       , p_parameter14	IN   VARCHAR2
             , p_parameter25	IN   VARCHAR2
             , x_request_id   OUT  NUMBER
			       );

  -- Procedure to wait for a request to complete and find the code of its completion.
  PROCEDURE wait_conc_request ( p_request_id	IN 	NUMBER
	           	      , p_description	IN      VARCHAR2
			      , x_phase		OUT	VARCHAR2
			      , x_code		OUT	VARCHAR2
			      );

END XX_AWAS_AR_INVOICE_LOAD;
/


CREATE OR REPLACE PACKAGE BODY XX_AWAS_AR_INVOICE_LOAD
IS
     /*------------------------------------------------------------------*/
     /* XX_AWAS_AR_INVOICE_LOAD Package Body            Version 2.0      */
     /* Written by Simon Joyce 10-02-2009                                */
     /* Updated by Simon Joyce 29-03-2010 to ccomodate Rental billing    */
     /* Update by Simon Joyce 23-07-2013 for R12 compatibility           */
     /*------------------------------------------------------------------*/
     /*--*/


     /*-- Cursors*/
     /*--*/
     CURSOR C_INVOICE_NORMAL ( v_REQUEST_ID NUMBER )
     IS
           SELECT
                    'PORTFOLIO' INTERFACE_LINE_CONTEXT          ,
                    lpad ( msn, 6, 0 ) INTERFACE_LINE_ATTRIBUTE1,
                    REF_TABLE_NAME INTERFACE_LINE_ATTRIBUTE2    ,
                    REF_TABLE_FIELD INTERFACE_LINE_ATTRIBUTE3   ,
                    REF_TABLE_ID INTERFACE_LINE_ATTRIBUTE4      ,
                    BILLING_TYPE_ID INTERFACE_LINE_ATTRIBUTE5   ,
                    AIRCRAFT_LEASE_NO INTERFACE_LINE_ATTRIBUTE6 ,
                    ARBILLING_ID INTERFACE_LINE_ATTRIBUTE7      ,
                    'PORTFOLIO' BATCH_SOURCE_NAME               ,
                    8 SET_OF_BOOKS_ID                           ,
                    'LINE' LINE_TYPE                            ,
                    DECODE ( ref_table_name, 'TBLARRENTALBILLING', DESCRIPTION, COMPONENT_NAME
                    ||' '
                    ||DESCRIPTION ) DESCRIPTION                                                                                                                                                ,
                    'USD' CURRENCY_CODE                                                                                                                                                        ,
                    RESTRANS_VAL*decode(transtype_code,51,-1,1) AMOUNT                                                                                                                                                        ,
                    DECODE (REF_TABLE_NAME, 'TBLARRENTALBILLING', DECODE ( REF_TABLE_FIELD, 'Stepped', 'Stepped Rent Invoice','High/Low','Stepped Rent Invoice', 'Aircraft Rental' ), DECODE(TRANSTYPE_CODE,11,'Maintenance Invoice','Maint. Credit Memo' )) CUST_TRX_TYPE_NAME,
                    decode (transtype_code,51,null,PAYMENT_TERMS_NAME) TERM_NAME                                                                                                                                               ,
                    ORA_CUSTOMER_ID ORIG_SYSTEM_BILL_CUSTOMER_ID                                                                                                                               ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_BILL_CUSTOMER_REF                                                                                                                             ,
                    ORA_BILL_TO_ID ORIG_SYSTEM_BILL_ADDRESS_ID                                                                                                                                 ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_BILL_ADDRESS_REF                                                                                                                              ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_SHIP_CUSTOMER_ID                                                                                                                              ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_SHIP_CUSTOMER_REF                                                                                                                             ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_SHIP_ADDRESS_ID                                                                                                                               ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_SHIP_ADDRESS_REF                                                                                                                              ,
                    ORA_CUSTOMER_ID ORIG_SYSTEM_SOLD_CUSTOMER_ID                                                                                                                               ,
                    TO_CHAR ( NULL ) ORIG_SYSTEM_SOLD_CUSTOMER_REF                                                                                                                             ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_CONTEXT                                                                                                                                      ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE1                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE2                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE3                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE4                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE5                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE6                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE7                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE8                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE9                                                                                                                                   ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE10                                                                                                                                  ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE11                                                                                                                                  ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE12                                                                                                                                  ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE13                                                                                                                                  ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE14                                                                                                                                  ,
                    TO_CHAR ( NULL ) LINK_TO_LINE_ATTRIBUTE15                                                                                                                                  ,
                    'User' CONVERSION_TYPE                                                                                                                                                     ,
                    INVOICE_DATE CONVERSION_DATE                                                                                                                                               ,
                    1 CONVERSION_RATE                                                                                                                                                          ,
                    INVOICE_DATE GL_DATE                                                                                                                                                       ,
                    ORA_INVOICE_NUM TRX_NUMBER                                                                                                                                                 ,
                    DECODE ( ROUND ( qty * rate_amnt, 2 ), restrans_val, DECODE ( QTY, 0, 1, QTY ), 1 )* decode(transtype_code,51,-1,1) QUANTITY                                                                               ,
                    DECODE ( ROUND ( qty * rate_amnt, 2 ), restrans_val, DECODE ( QTY, 0, RESTRANS_VAL, RATE_AMNT ), restrans_val ) UNIT_SELLING_PRICE                                         ,
                    TO_CHAR ( NULL ) REASON_CODE                                                                                                                                               ,
                    TO_CHAR ( NULL ) TAX_CODE                                                                                                                                                  ,
                    TO_CHAR ( NULL ) PRIMARY_SALESREP_NUMBER                                                                                                                                   ,
                    TO_CHAR ( NULL ) SALES_ORDER                                                                                                                                               ,
                    TO_CHAR ( NULL ) SALES_ORDER_DATE                                                                                                                                          ,
                    TO_CHAR ( NULL ) SALES_ORDER_SOURCE                                                                                                                                        ,
                    TO_CHAR ( NULL ) MTL_SYSTEM_ITEMS_SEG1                                                                                                                                     ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_CONTEXT                                                                                                                                    ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE1                                                                                                                                 ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE2                                                                                                                                 ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE3                                                                                                                                 ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE4                                                                                                                                 ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE5                                                                                                                                 ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE6                                                                                                                                 ,
                    TO_CHAR ( NULL ) REFERENCE_LINE_ATTRIBUTE7                                                                                                                                 ,
                    UOM UOM_CODE                                                                                                                                                               ,
                    FND_PROFILE.VALUE ( 'USER_ID' ) CREATED_BY                                                                                                                                 ,
                    SYSDATE CREATION_DATE                                                                                                                                                      ,
                    TO_NUMBER ( NULL ) LAST_UPDATED_BY                                                                                                                                         ,
                    TO_DATE ( NULL ) LAST_UPDATE_DATE                                                                                                                                          ,
                    85 ORG_ID                                                                                                                                                                  ,
                    TO_CHAR ( NULL ) WAREHOUSE_ID                                                                                                                                              ,
                    TRANSTYPE_CODE ORIGINAL_TRANS_TYPE                                                                                                                                         ,
                    TO_CHAR ( NULL ) EQUIVALENT_UNITS                                                                                                                                          ,
                    TO_NUMBER ( NULL ) FILE_LINE_NUMBER                                                                                                                                        ,
                    TO_CHAR ( NULL ) WAREHOUSE_CODE                                                                                                                                            ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE1                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE2                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE3                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE4                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE5                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE6                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE7                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE8                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE9                                                                                                                                       ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE10                                                                                                                                      ,
                    TO_CHAR ( NULL ) HEADER_GDF_ATTRIBUTE1                                                                                                                                     ,
                    TO_CHAR ( NULL ) LINE_GDF_ATTRIBUTE11                                                                                                                                      ,
                    RECEIPT_METHOD_ID RECEIPT_METHOD_ID                                                                                                                                        ,
                    GET_CONTACT(ORA_CUSTOMER_ID, ORA_BILL_TO_ID) ORIG_SYSTEM_BILL_CONTACT_ID
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING
                 WHERE
                    ORA_REQUEST_ID = V_REQUEST_ID
                    AND status_id not in ( 3,7);
     /*-- Types*/
      TYPE T_INV     IS  TABLE OF C_INVOICE_NORMAL%ROWTYPE INDEX BY BINARY_INTEGER;
      TYPE T_NUMBER  IS  TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE T_DATE    IS  TABLE OF DATE INDEX BY BINARY_INTEGER;
      TYPE T_VARCHAR IS  TABLE OF VARCHAR2 ( 2000 ) INDEX BY BINARY_INTEGER;
      TYPE T_main    IS  RECORD(
          INTERFACE_LINE_CONTEXT T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE1 T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE2 T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE3 T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE4 T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE5 T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE6 T_VARCHAR,
          INTERFACE_LINE_ATTRIBUTE7 T_VARCHAR,
          BATCH_SOURCE_NAME T_VARCHAR,
          SET_OF_BOOKS_ID T_VARCHAR,
          LINE_TYPE T_VARCHAR,
          DESCRIPTION T_VARCHAR,
          CURRENCY_CODE T_VARCHAR,
          AMOUNT T_VARCHAR,
          CUST_TRX_TYPE_NAME T_VARCHAR,
          TERM_NAME T_VARCHAR,
          ORIG_SYSTEM_BILL_CUSTOMER_ID T_VARCHAR,
          ORIG_SYSTEM_BILL_CUSTOMER_REF T_VARCHAR,
          ORIG_SYSTEM_BILL_ADDRESS_ID T_VARCHAR,
          ORIG_SYSTEM_BILL_ADDRESS_REF T_VARCHAR,
          ORIG_SYSTEM_SHIP_CUSTOMER_ID T_VARCHAR,
          ORIG_SYSTEM_SHIP_CUSTOMER_REF T_VARCHAR,
          ORIG_SYSTEM_SHIP_ADDRESS_ID T_VARCHAR,
          ORIG_SYSTEM_SHIP_ADDRESS_REF T_VARCHAR,
          ORIG_SYSTEM_SOLD_CUSTOMER_ID T_VARCHAR,
          ORIG_SYSTEM_SOLD_CUSTOMER_REF T_VARCHAR,
          LINK_TO_LINE_CONTEXT T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE1 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE2 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE3 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE4 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE5 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE6 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE7 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE8 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE9 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE10 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE11 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE12 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE13 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE14 T_VARCHAR,
          LINK_TO_LINE_ATTRIBUTE15 T_VARCHAR,
          CONVERSION_TYPE T_VARCHAR,
          CONVERSION_DATE T_VARCHAR,
          CONVERSION_RATE T_VARCHAR,
          GL_DATE T_VARCHAR,
          TRX_NUMBER T_VARCHAR,
          QUANTITY T_VARCHAR,
          UNIT_SELLING_PRICE T_VARCHAR,
          REASON_CODE T_VARCHAR,
          TAX_CODE T_VARCHAR,
          PRIMARY_SALESREP_NUMBER T_VARCHAR,
          SALES_ORDER T_VARCHAR,
          SALES_ORDER_DATE T_VARCHAR,
          SALES_ORDER_SOURCE T_VARCHAR,
          MTL_SYSTEM_ITEMS_SEG1 T_VARCHAR,
          REFERENCE_LINE_CONTEXT T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE1 T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE2 T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE3 T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE4 T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE5 T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE6 T_VARCHAR,
          REFERENCE_LINE_ATTRIBUTE7 T_VARCHAR,
          UOM_CODE T_VARCHAR,
          CREATED_BY T_VARCHAR,
          CREATION_DATE T_VARCHAR,
          LAST_UPDATED_BY T_VARCHAR,
          LAST_UPDATE_DATE T_VARCHAR,
          ORG_ID T_VARCHAR,
          WAREHOUSE_ID T_VARCHAR,
          ORIGINAL_TRANS_TYPE T_VARCHAR,
          EQUIVALENT_UNITS T_VARCHAR,
          FILE_LINE_NUMBER T_NUMBER,
          WAREHOUSE_CODE T_VARCHAR,
          LINE_GDF_ATTRIBUTE1 T_VARCHAR,
          LINE_GDF_ATTRIBUTE2 T_VARCHAR,
          LINE_GDF_ATTRIBUTE3 T_VARCHAR,
          LINE_GDF_ATTRIBUTE4 T_VARCHAR,
          LINE_GDF_ATTRIBUTE5 T_VARCHAR,
          LINE_GDF_ATTRIBUTE6 T_VARCHAR,
          LINE_GDF_ATTRIBUTE7 T_VARCHAR,
          LINE_GDF_ATTRIBUTE8 T_VARCHAR,
          LINE_GDF_ATTRIBUTE9 T_VARCHAR,
          LINE_GDF_ATTRIBUTE10 T_VARCHAR,
          HEADER_GDF_ATTRIBUTE1 T_VARCHAR,
          LINE_GDF_ATTRIBUTE11 T_VARCHAR,
          RECEIPT_METHOD_ID T_VARCHAR,
          ORIG_SYSTEM_BILL_CONTACT_ID T_NUMBER) ;

     /*-- Procedures and Function Declarations*/
     PROCEDURE CREATE_PORTFOLIO_DATA;
     PROCEDURE LOAD_THE_TABLE;
     PROCEDURE VALIDATE_RECORDS;
     PROCEDURE PROCESS_INVOICES_RECEIVABLES;
     PROCEDURE WRITE_REPORT;
     PROCEDURE INSERT_INTO_RECEIVABLES(R_INV    IN T_MAIN,
                                       V_ORG_ID IN NUMBER ) ;
     PROCEDURE KICKOFF_IMPORT;



     /*-- Variables*/
     v_request_id NUMBER;
     v_org_id     NUMBER;
     v_user       VARCHAR2 ( 250 ) ;
     v_period     VARCHAR2 ( 20 ) ;
     errbuf       VARCHAR2 ( 250 ) ;
     retcode      NUMBER;

/*--=========================================================================*/
/*-- MAIN procedure initialises a few variables and call all other procedures*/
PROCEDURE MAIN
     (    errbuf OUT VARCHAR2,
          retcode OUT NUMBER,
          p_period       IN VARCHAR2,
          p_invoice_type IN VARCHAR2 )
                         IS
     errcodeout1 VARCHAR2 ( 200 ) ;
     errcodeout2 VARCHAR2 ( 200 ) ;
BEGIN
     DBMS_APPLICATION_INFO.SET_MODULE ( 'XX_AWAS_AR_INVOICE_LOAD', 'MAIN' ) ;
     V_ORG_ID     := FND_PROFILE.VALUE ( 'ORG_ID' ) ;
     v_request_id := fnd_global.conc_request_id;

     v_period     := p_period;
      SELECT
               email_address
             INTO
               v_user
             FROM
               fnd_user
            WHERE
               user_id = fnd_global.user_id;
     /*-- Start Report Heading*/
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( '========================================== AWAS PORTFOLIO to AR Invoice Program ======================================' ) ;
     WRITE_OUT ( '== Request started at '||TO_CHAR ( sysdate, 'dd-MON-yy HH24:MI:SS' ) ||'                                                          ==' ) ;
     WRITE_OUT ( '== Request Id: '||rpad ( v_request_id, 15, ' ' ) ||'                                                                    ==' ) ;
     WRITE_OUT ( '== Period: '||rpad ( v_period, 19, ' ' ) ||'                                                                    ==' ) ;
     WRITE_LOG ( '== User Email: '||v_user ) ;
     WRITE_LOG ( '== Connecting to PORTFOLIO @BASIN... ' ) ;
     WRITE_LOG ( '== Populating PORTFOLIO TBLARBILLINGINTERFACE... ' ) ;


     /*-- Step 1 Create Billing Information in PORTFOLIO database*/
     IF p_invoice_type = 'RESERVES' THEN /*-- For Reserves billing*/
          CREATE_PORTFOLIO_DATA;
     ELSE /*-- For Rental Billing*/
          PKGRENTALBILLING.RUNBILLING@BASIN ( V_PERIOD
                                             , ERRCODEOUT1
                                              , errcodeout2
                                              ) ;
     END IF;
     /*-- Step 1a*/
     LOAD_THE_TABLE;
     WRITE_LOG ( 'Load Table Complete ' ) ;
     /*-- Step 2*/
     VALIDATE_RECORDS;
     WRITE_LOG ( 'Validate Complete' ) ;
     /*-- Step 3*/
     PROCESS_INVOICES_RECEIVABLES;
     WRITE_LOG ( 'Process Invoices to Receivables Complete' ) ;
     /*-- Step 4*/
     KICKOFF_IMPORT;
     WRITE_LOG ( 'Import Complete' ) ;
     /*-- Step 5*/
     WRITE_REPORT;
     WRITE_LOG ( 'All Done' ) ;

     WRITE_OUT('                                   ****End of Report****') ;

EXCEPTION
WHEN OTHERS THEN
     WRITE_LOG ( 'Error in MAIN' ) ;
     WRITE_LOG ( SQLERRM ) ;
     RAISE;
END MAIN;
/*--=============================================================================*/
/*-- CREATE_PORTFOLIO_DATA procedure creates Invoicing data in Reserves*/
PROCEDURE CREATE_PORTFOLIO_DATA
IS
BEGIN
      INSERT INTO TBLARBILLINGINTERFACE@BASIN
               (
                    ARBILLING_ID     ,
                    REF_TABLE_NAME   ,
                    REF_TABLE_FIELD  ,
                    REF_TABLE_ID     ,
                    BILLING_TYPE_ID  ,
                    INVOICE_DATE     ,
                    STATUS_ID        ,
                    CREATED_PERSON_ID,
                    CREATED_DATE
               )
      SELECT
               TBLARBILLINGINTERFACE_SEQ.NEXTVAL@BASIN AS next_val       ,
               'TBLRESTRANSACTION'                     AS REF_TABLE_NAME ,
               'RESTRANSACTION_ID'                     AS REF_TABLE_FIELD,
               RESTRANSACTION_ID                       AS REF_TABLE_ID   ,
               1                                       AS BILLING_TYPE_ID,
               RT.TRANSACTION_DATE                     AS INVOICE_DATE   ,
               1                                       AS STATUS_ID      ,
               (SELECT
                         P.PERSON_ID
                       FROM
                         TBLPERSON@BASIN P,
                         TBLPEREMAILADDRESS@BASIN M
                      WHERE
                         P.PERSON_ID                      = M.PERSON_ID
                         AND UPPER ( M.PEREMAIL_ADDRESS ) = UPPER ( v_user )
               )       AS CREATED_PERSON_ID,
               SYSDATE AS CREATED_DATE
             FROM
               TBLRESTRANSACTION@BASIN RT  ,
               TBLAIRCRAFTLEASE@BASIN AL   ,
               TBLAIRCRAFTCROSREF@BASIN ACR,
               TBLORGANISATION@BASIN O     ,
               TLKPRESCOMPONENT@BASIN RC   ,
               TBLRESRATE@BASIN RR         ,
               TLKPFINPERIOD@BASIN FP      ,
               TBLALSINVOICEREQUIREMENTS@BASIN IR
            WHERE
               RT.RECSTATUS_CD          = 1
               AND RT.TRANSTYPE_CODE    in (11,51)
               AND RT.AIRCRAFT_LEASE_NO = AL.AIRCRAFT_LEASE_NO
               AND AL.AIRCRAFT_NO       = ACR.AIRCRAFT_NO
               AND ACR.CROSS_REF_CODE   = 1
               AND AL.ORG_ID            = O.ORG_ID
               AND RT.COMPONENT_CODE    = RC.COMPONENT_CODE
               AND RT.AIRCRAFT_LEASE_NO = RR.AIRCRAFT_LEASE_NO
               AND RT.COMPONENT_CODE    = RR.COMPONENT_CODE
               AND RR.FROM_DATE         =
               (SELECT
                         MAX ( FROM_DATE )
                       FROM
                         TBLRESRATE@BASIN r
                      WHERE
                         TRUNC ( R.FROM_DATE )  <= TRUNC ( LAST_DAY ( ADD_MONTHS ( SYSDATE, - 1 ) ) )
                         AND R.AIRCRAFT_LEASE_NO = RR.AIRCRAFT_LEASE_NO
                         AND R.COMPONENT_CODE    = RR.COMPONENT_CODE
                         AND R.RECSTATUS_CD      = 1
               )
               AND RR.RECSTATUS_CD           = 1
               AND RT.AIRCRAFT_LEASE_NO      = IR.AIRCRAFT_LEASE_NO(+)
               AND RT.PERIOD_ID              = FP.PERIOD_ID
               AND FP.PERIOD_NAME            = v_period
               AND RT.PERIOD_ID              > 110 /*-- ignore any transaction before FEB-09*/
               AND RT.RESTRANSACTION_ID NOT IN
               (SELECT
                         REF_TABLE_ID
                       FROM
                         TBLARBILLINGINTERFACE@BASIN
                      WHERE
                         REF_TABLE_FIELD = 'RESTRANSACTION_ID'
               ) ;

     WRITE_LOG ( '== TBLARBILLINGINTERFACE loaded with ' || SQL%ROWCOUNT||' records.' ) ;
     WRITE_OUT ( '' ) ;
     WRITE_OUT ( SQL%ROWCOUNT||' records in PORTFOLIO@BASIN to be transfered to Staging Tables.' ) ;
     COMMIT;
EXCEPTION
WHEN OTHERS THEN
     WRITE_LOG ( 'Error in CREATE_PORTFOLIO_DATA' ) ;
     WRITE_LOG ( SQLERRM ) ;
     RAISE;
END CREATE_PORTFOLIO_DATA;
/*--=============================================================================*/
/*-- LOAD_THE_TABLE procedure populate staging table*/
PROCEDURE LOAD_THE_TABLE
IS
BEGIN
     WRITE_LOG ( ' ' ) ;
     WRITE_LOG ( '== Populating Staging Table... ' ) ;

     -- Reserves Invoices
      INSERT INTO XXAWAS_AR_INVOICE_FILE_STAGING
      SELECT
               arbilling_id       ,
               ref_table_name     ,
               ref_table_field    ,
               ref_table_id       ,
               billing_type_id    ,
               invoice_date       ,
               payment_date       ,
               status_id          ,
               comments           ,
               period_id          ,
               org_id             ,
               org_name           ,
               ora_Fin_customer_id,
               msn                ,
               aircraft_lease_no  ,
               component_name     ,
               transtype_code     ,
               description
               ||DECODE ( ROUND ( restrans_val / ( DECODE ( NVL ( quantity, 0 ), 0, 1, quantity ) ), 2 ), '', ' '
               ||quantity
               ||' '
               ||USAGEUNIT_DESC )                                                                                                                         ,
               decode(transtype_code,11,quantity,quantity*-1) qty                                                                                                                               ,
               rate_amnt                                                                                                                                  ,
               restrans_val                                                                                                                               ,
               transaction_date                                                                                                                           ,
               NULL                                                                                                                                       ,
               NULL                                                                                                                                       ,
               NULL                                                                                                                                       ,
               NULL                                                                                                                                       ,
               v_request_id                                                                                                                               ,
               DECODE ( ROUND ( restrans_val / ( DECODE ( NVL ( quantity, 0 ), 0, 1, quantity ) ), 2 ), rate_amnt, USAGEUNIT_DESC, 'EACH' ) USAGEUNIT_DESC,
               NULL                                                                                                                                       ,
               NULL
             FROM
               VRESERVESBILLING@BASIN
            WHERE
               status_id           = 1
               AND ref_table_name <> 'TBLARRENTALBILLING';

     WRITE_OUT ( SQL%ROWCOUNT||' Reserves records in PORTFOLIO@BASIN to be transfered to Staging Tables.' ) ;


     -- Rental Invoices
      INSERT INTO XXAWAS_AR_INVOICE_FILE_STAGING
      SELECT
               bi.arbilling_id                        ,
               'TBLARRENTALBILLING' ref_table_name    ,
               lease_ratetype_desc ref_table_field    ,
               bi.ref_table_id                        ,
               billing_type_id                        ,
               rb.invoice_date                        ,
               rb.invoice_date payment_date           ,
               status_id                              ,
               comments                               ,
               0 period_id                            ,
               billing_customer_no org_id             ,
               billing_customer_name org_name         ,
               billing_customer_no ora_Fin_customer_id,
               msn                                    ,
               aircraft_lease_no                      ,
               period_name
               ||' RENTAL' component_name,
               0 transtype_code          ,
               DECODE ( lease_ratetype_desc, 'Floating', 'Operating lease due for the period '
               ||TO_CHAR ( bill_from, 'FMddth Month' )
               ||' to '
               ||TO_CHAR ( bill_to, 'FMddth Month RRRR' )
               ||
               chr ( 13 )
               ||'Formula Used: '
               ||lease_rateformula_desc
               || chr ( 13 )
               ||'BLR: '
               ||round(base_lease_rate,2)
               || chr ( 13 )
               ||'R:   '
               ||ROUND ( libor_rate, 5 )
               || chr ( 13 )
               ||'Y:   '
               ||ROUND ( Y_FACTOR, 2 )
               || chr ( 13 )
               ||'RAF: '
               ||RENT_ADJUSTMENT_FACTOR
               ||decode(budget_adjustment, null,'',chr ( 13 )||'Budget Adjustment: '||round(budget_adjustment,2))
               , 'Operating lease due for the period '
               ||TO_CHAR ( bill_from, 'FMddth Month' )
               ||' to '
               ||TO_CHAR ( BILL_TO, 'FMddth Month RRRR' ) )
               ||decode(RB.custom_invoice_text,null,'',chr ( 13 )||rb.custom_invoice_text) description,
               1 qty                                                   ,
               olr_dry_lease_rate rate_amnt                            ,
               olr_dry_lease_rate restrans_val                         ,
               rb.invoice_date transaction_date                        ,
               NULL                                                    ,
               NULL                                                    ,
               NULL                                                    ,
               NULL                                                    ,
               v_request_id                                            ,
               'EACH' USAGEUNIT_DESC                                   ,
               NULL                                                    ,
               NULL
             FROM
               TBLARBILLINGINTERFACE@BASIN BI,
               TBLARRENTALBILLING@BASIN RB
            WHERE
               BI.ARBILLING_ID  = RB.ARBILLING_ID
               AND bi.status_id = 1;

     WRITE_OUT ( SQL%ROWCOUNT||' Rental records in PORTFOLIO@BASIN to be transfered to Staging Tables.' ) ;

     --WRITE_LOG('Line 495');
     /* Do updates to data here */
     /*-- Set Maintenance bill to*/
      UPDATE
               XXAWAS_AR_INVOICE_FILE_STAGING x
          SET  ORA_BILL_TO_ID = (SELECT U.CUST_ACCT_SITE_ID
                                 FROM   HZ_CUST_ACCOUNTS c          ,
                                        hz_cust_acct_sites_all s,
                                        HZ_CUST_SITE_USES_ALL U
                                 WHERE  C.ACCOUNT_NUMBER       = X.CUST_ID
                                 AND s.cust_account_id   = c.cust_account_id
                                 and s.status <> 'I'
                                 AND u.cust_acct_site_id = s.cust_acct_site_id
                                 AND S.ORG_ID            = 85
                                 AND LPAD ( U.LOCATION, 7, '0' ) = LPAD ( X.MSN, 6, '0' )||'M'),
               ORA_CUSTOMER_ID = (SELECT  C.CUST_ACCOUNT_ID
                                  FROM    HZ_CUST_ACCOUNTS C
                                  WHERE   c.account_number = x.cust_id)
              WHERE ora_request_id       = v_request_id
              AND x.ref_table_name = 'TBLRESTRANSACTION';
     commit;
     --WRITE_LOG('Line 515');

     /*-- Set Bill To ID Rental and missing maintenance*/
      UPDATE  XXAWAS_AR_INVOICE_FILE_STAGING x
          SET  ORA_BILL_TO_ID = (SELECT U.CUST_ACCT_SITE_ID
                                 FROM hz_cust_accounts c          ,
                                      hz_cust_acct_sites_all s,
                                      HZ_CUST_SITE_USES_ALL U
                                 WHERE  C.ACCOUNT_NUMBER       = X.CUST_ID
                                 AND s.cust_account_id   = c.cust_account_id
                                 AND u.cust_acct_site_id = s.cust_acct_site_id
                                 and s.status <> 'I'
                                 AND S.ORG_ID            = 85
                                 and lpad ( u.location, 6, '0' ) = lpad ( x.msn, 6, '0' )
                                 AND U.LOCATION NOT LIKE '%M%'),
               ORA_CUSTOMER_ID = (SELECT C.cust_account_id CUSTOMER_ID
                                  FROM HZ_CUST_ACCOUNTS C
                                  WHERE c.account_number = x.cust_id)
            WHERE ora_request_id      = v_request_id
            AND ora_bill_to_id IS NULL;

     commit;
     --WRITE_LOG('Line 535');
     /*--correct UOM*/
      UPDATE
               XXAWAS_AR_INVOICE_FILE_STAGING x
          SET
               UOM = DECODE ( UOM, 'APU Cycle', 'ACY', 'APU Hour', 'AHR', 'Airframe Flight Hours', 'AFH', 'Cycle', 'Cyc', 'Flight Hour', 'FHR', 'Hour', 'Hrs', 'Month', 'MTH', 'Ech' )
            WHERE
               ora_request_id = v_request_id;

      --WRITE_LOG('Line 544');
     /*--add reserves receipt method*/
      UPDATE
               XXAWAS_AR_INVOICE_FILE_STAGING x
          SET
               receipt_method_id =
               (SELECT  MAX ( receipt_method_id )
                       FROM  ar_cust_receipt_methods_v m,
                             HZ_CUST_SITE_USES_ALL H
                      WHERE   sysdate <= NVL ( m.end_date, sysdate )
                         AND m.site_use_id            = h.site_use_id
                         AND site_use_code            = 'BILL_TO'
                         AND h.org_id                 = 85
                         AND m.attribute1            IN ( 'BOTH', 'MAINTENANCE' )
                         AND H.CUST_ACCT_SITE_ID      = X.ORA_BILL_TO_ID
                         AND LPAD ( H.LOCATION, 7, '0' ) = LPAD ( X.MSN, 6, '0' )||'M'
                )
            WHERE
               ora_request_id       = v_request_id
               AND x.ref_table_name = 'TBLRESTRANSACTION';
     commit;

     --WRITE_LOG('Line 566');

      UPDATE
               XXAWAS_AR_INVOICE_FILE_STAGING x
          SET
               receipt_method_id = (SELECT MAX ( receipt_method_id )
                                    FROM  ar_cust_receipt_methods_v m,
                                          hz_cust_site_uses_all h
                                    WHERE sysdate <= NVL ( m.end_date, sysdate )
                                    AND M.SITE_USE_ID                 = H.SITE_USE_ID
                                   AND site_use_code                 = 'BILL_TO'
                                   AND h.org_id                      = 85
                                   AND M.ATTRIBUTE1            IN ( 'BOTH', 'MAINTENANCE' )
                                   AND H.CUST_ACCT_SITE_ID           = X.ORA_BILL_TO_ID
                                   AND lpad ( h.location, 6, '0' ) = lpad ( x.msn, 6, '0' ))
            WHERE  ora_request_id           = v_request_id
               AND x.receipt_method_id IS NULL
               AND x.ref_table_name     = 'TBLRESTRANSACTION';

      --WRITE_LOG('Line 585');
     /*-- add rental receipt methods*/
      UPDATE
               XXAWAS_AR_INVOICE_FILE_STAGING x
          SET
               receipt_method_id =
               (SELECT
                         MAX ( receipt_method_id )
                       FROM
                         ar_cust_receipt_methods_v m,
                         hz_cust_site_uses_all h
                      WHERE
                             sysdate <= NVL ( m.end_date, sysdate )
                         AND m.site_use_id                 = h.site_use_id
                         AND site_use_code                 = 'BILL_TO'
                         AND h.org_id                      = 85
                         AND NVL ( m.attribute1, 'BOTH' ) <> 'MAINTENANCE'
                         AND m.end_Date is null
                         AND H.CUST_ACCT_SITE_ID           = X.ORA_BILL_TO_ID
                         AND lpad ( h.location, 6, '0' ) = lpad ( x.msn, 6, '0' ))
            WHERE  ORA_REQUEST_ID        = V_REQUEST_ID
            AND x.receipt_method_id IS NULL
            AND x.ref_table_name <> 'TBLRESTRANSACTION';
     /*-- add payment method  - RESERVES*/

     --WRITE_LOG('Line 609');

      UPDATE
               xxawas_AR_INVOICE_FILE_STAGING x
          SET
               payment_terms_name =
               (SELECT
                         t.name
                       FROM
                         ra_terms_lines l,
                         ra_terms_tl t
                      WHERE
                         t.term_id              = l.term_id
                         AND l.due_day_of_month =
                         (SELECT
                                   override_mtx_bill_day
                                 FROM
                                   VRESERVESBILLING@BASIN
                                WHERE
                                   arbilling_id = x.arbilling_id
                         )
               )
            WHERE
               ora_request_id       = v_request_id
               AND x.ref_table_name = 'TBLRESTRANSACTION';


      --WRITE_LOG('Line 636');
     /*-- add payment method  - RENTAL*/
      UPDATE
               xxawas_AR_INVOICE_FILE_STAGING x
          SET
               payment_terms_name = 'IMMEDIATE'
            WHERE
               ora_request_id        = v_request_id
               AND x.ref_table_name <> 'TBLRESTRANSACTION';

     WRITE_LOG ( '== Staging Table loaded with ' || SQL%ROWCOUNT||' records.' ) ;
     WRITE_OUT ( '' ) ;
     WRITE_OUT ( '  Oracle Staging Table loaded with ' || SQL%ROWCOUNT||' records.' ) ;
     COMMIT;

--                write_log('Line 651');


     /*-- *************************************/
     /*-- Update Status on Records transferred.*/
     /*-- *************************************/
      UPDATE
               TBLARBILLINGINTERFACE@BASIN
          SET
               status_id = 2 /*-- 'IN PROCESS'*/
            WHERE
               arbilling_id IN
               (SELECT
                         arbilling_id
                       FROM
                         xxawas_ar_invoice_file_staging
                      WHERE
                         ora_request_id = v_request_id
               ) ;


     WRITE_LOG ( '== '||SQL%ROWCOUNT||' Records in TBLARBILLINGINTERFACE@BASIN have had Status updated to IN PROCESS' ) ;

  --         WRITE_LOG('Line 674');

EXCEPTION
WHEN OTHERS THEN
     WRITE_LOG ( 'Error in LOAD_THE_TABLE' ) ;
     WRITE_LOG ( SQLERRM ) ;
     RAISE;
END LOAD_THE_TABLE;

/*--=========================================================================*/
/*-- VALIDATE_RECORDS procedure does basic data validation and reports errors*/

PROCEDURE VALIDATE_RECORDS
IS
     /*--Cursors*/
     CURSOR c_validate
     IS
          ( SELECT DISTINCT
                    org_id  ,
                    org_name,
                    msn
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING
                 WHERE
                    ora_request_id = v_request_id
                    AND cust_id   IS NULL
          ) ;
     CURSOR c_check_site
     IS
          ( SELECT DISTINCT
                    org_id  ,
                    org_name,
                    msn
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING
                 WHERE
                    ora_request_id      = v_request_id
                    AND ora_bill_to_id IS NULL
          ) ;
     CURSOR c_rm
     IS
          ( SELECT DISTINCT
                    org_id  ,
                    org_name,
                    msn
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING
                 WHERE
                    ora_request_id         = v_request_id
                    AND receipt_method_id IS NULL
          ) ;
     CURSOR c_pt
     IS
          ( SELECT DISTINCT
                    x.org_id  ,
                    x.org_name,
                    x.msn
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING x
                 WHERE
                    x.ora_request_id          = v_request_id
                    AND x.payment_terms_name IS NULL
          ) ;
     V_REJECT_FILE BOOLEAN;
BEGIN
     WRITE_LOG ( ' ' ) ;
     WRITE_LOG ( '======================================= VALIDATE ALL DATA PRESENT =====================================' ) ;
     FOR R1 IN C_validate
     LOOP
          WRITE_LOG ( 'Customer: '|| R1.org_name||' has no Mapped Oracle Customer Id. Please correct.' ) ;
          v_reject_file := TRUE;
           UPDATE
                    XXAWAS_AR_INVOICE_FILE_STAGING
               SET
                    STATUS_ID         = 3,
                    ORA_ERROR_MESSAGE = 'ORACLE CUSTOMER ID MISSING'
                 WHERE
                    nvl(org_id,-1)         = nvl(R1.org_id,-1)
                    AND msn                = r1.msn
                    AND ora_request_id     = v_request_id
                    AND ora_error_message IS NULL;
          COMMIT;
     END LOOP;
     WRITE_LOG ( '================================== END OF ALL DATA PRESENT VALIDATION =================================' ) ;
     WRITE_LOG ( ' ' ) ;
     WRITE_LOG ( '===================================== VALIDATE CUSTOMER SITE EXISTS ===================================' ) ;
     FOR R1 IN C_check_site
     LOOP
          WRITE_LOG ( 'Customer: '|| R1.org_name||' has no Mapped Site for MSN: '||R1.MSN||' Please correct.' ) ;
          v_reject_file := TRUE;
           UPDATE
                    XXAWAS_AR_INVOICE_FILE_STAGING
               SET
                    STATUS_ID         = 3,
                    ORA_ERROR_MESSAGE = ORA_ERROR_MESSAGE
                    ||' NO SITE FOR MSN'
                 WHERE
                    nvl(org_id,-1)         = nvl(R1.org_id,-1)
                    AND msn            = r1.msn
                    AND ora_request_id = v_request_id;
          COMMIT;
     END LOOP;
     WRITE_LOG ( '================================== END VALIDATE CUSTOMER SITE EXISTS ==================================' ) ;
     WRITE_LOG ( ' ' ) ;
     WRITE_LOG ( '================================= VALIDATE CUSTOMER RECEIPT METHOD EXISTS =============================' ) ;
     FOR R1 IN C_rm
     LOOP
          WRITE_LOG ( 'Customer: '|| R1.org_name||' has no Receipt Method defined to match the invoice type or both, for MSN: '||R1.MSN||' Please correct.' ) ;
          v_reject_file := TRUE;
           UPDATE
                    XXAWAS_AR_INVOICE_FILE_STAGING
               SET
                    STATUS_ID         = 3,
                    ORA_ERROR_MESSAGE = ORA_ERROR_MESSAGE
                    ||' NO RECEIPT METHOD FOR MSN'
                 WHERE
                    nvl(org_id,-1)         = nvl(R1.org_id,-1)
                    AND msn            = r1.msn
                    AND ora_request_id = v_request_id;
          COMMIT;
     END LOOP;
     WRITE_LOG ( '================================== END VALIDATE RECEIPT METHOD EXISTS =================================' ) ;
     WRITE_LOG ( ' ' ) ;
     WRITE_LOG ( '==================================== VALIDATE PAYMENT TERMS EXISTS ====================================' ) ;
     FOR R1 IN C_pt
     LOOP
          WRITE_LOG ( 'Customer: '|| R1.org_name||' has no Payment Term defined for MSN: '||R1.MSN||' Please create Payment term.' ) ;
          v_reject_file := TRUE;
           UPDATE
                    XXAWAS_AR_INVOICE_FILE_STAGING
               SET
                    STATUS_ID         = 3,
                    ORA_ERROR_MESSAGE = ORA_ERROR_MESSAGE
                    ||' NO PAYMENT TERM DEFINED IN ORACLE'
                 WHERE
                    nvl(org_id,-1)         = nvl(R1.org_id,-1)
                    AND msn            = r1.msn
                    AND ora_request_id = v_request_id;
          COMMIT;
     END LOOP;
     WRITE_LOG ( '===================================== END VALIDATE PAYMENT TERMS EXISTS ================================' ) ;
     WRITE_LOG ( ' ' ) ;

        UPDATE   XXAWAS_AR_INVOICE_FILE_STAGING X
        SET      STATUS_ID = 7,
                 ORA_ERROR_MESSAGE = ORA_ERROR_MESSAGE||' RENTAL BILLING IN ORACLE ALREADY'
        WHERE ORA_REQUEST_ID       = V_REQUEST_ID
        AND X.REF_TABLE_NAME = 'TBLARRENTALBILLING'
        AND NVL(X.ORA_ERROR_MESSAGE,'X') NOT LIKE '%RENTAL BILLING IN ORACLE ALREADY%'
        AND X.AIRCRAFT_LEASE_NO||TO_CHAR(x.invoice_DATE,'MON-YY') IN (
        SELECT	V.AIRCRAFT_LEASE_NO||TO_CHAR(PS.TRX_DATE,'MON-YY')
                                    from 	HZ_customer_profiles      cp,
                                          HZ_customer_profiles      cp1,
                                          AR_COLLECTORS                    COL,
                                          HZ_CUST_ACCOUNTS                   CUST,
                                          HZ_PARTIES PARTY,
                                          ra_customer_trx_all              ctx,
                                          RA_SALESREPS_ALL                    SREP,
                                          (select  xx_ar_get_bal_due(payment_schedule_id,sysdate,org_id,class)     due_amount,
                                                  INVOICE_CURRENCY_CODE,
                                                  amount_due_remaining,
                                                  PAYMENT_SCHEDULE_ID,
                                                  trx_date,
                                                  trx_number,
                                                  status,
                                                  due_date,
                                                  actual_date_closed,
                                                  amount_due_original,
                                                  tax_original  ,
                                                  customer_site_use_id  ,
                                                  customer_trx_id            ,
                                                  cons_inv_id
                                        FROM      AR_PAYMENT_SCHEDULES_ALL
                                          WHERE ORG_ID = 85)   PS,
                                        (SELECT CUSTOMER_TRX_ID, MAX(CC.SEGMENT2) ACCOUNT FROM RA_CUST_TRX_LINE_GL_DIST_ALL GD, GL_CODE_COMBINATIONS CC
                                        where gd.account_class = 'REV'
                                                  AND CC.CODE_COMBINATION_ID = GD.CODE_COMBINATION_ID
                                                  and gd.org_id = 85
                                                  GROUP BY CUSTOMER_TRX_ID ) GLC,
                                                  (select distinct aircraft_lease_no, msn, billing_customer_no from vrentalbilling@basin) V
                                                  Where   CUST.CUST_ACCOUNT_ID             = ctx.bill_to_customer_id
                                                  AND       CUST.PARTY_ID  =      PARTY.PARTY_ID
                                                  AND       CTX.CUSTOMER_TRX_ID      = PS.CUSTOMER_TRX_ID
                                                  AND       V.BILLING_CUSTOMER_NO (+) = CUST.ACCOUNT_NUMBER
                                                  and nvl(lpad(v.msn,6,'0'),lpad(ctx.interface_header_attribute1,6,'0')) = lpad(ctx.interface_header_attribute1,6,'0')
                                                  and       ctx.primary_salesrep_id  = srep.salesrep_id (+)
                                                  and       cp.CUST_ACCOUNT_ID     = CUST.CUST_ACCOUNT_ID
                                                  and       cp.site_use_id is null
                                                  AND GLC.CUSTOMER_TRX_ID = CTX.CUSTOMER_TRX_ID
                                                  AND ARPT_SQL_FUNC_UTIL.GET_TRX_TYPE_DETAILS(CTX.CUST_TRX_TYPE_ID,'NAME') like '%Rent%'
                                                  and       ctx.org_id = 85
                                                  and       cp1.site_use_id (+)          = ps.customer_site_use_id
                                                  AND       COL.COLLECTOR_ID             = NVL(CP1.COLLECTOR_ID, CP.COLLECTOR_ID)
                                                  AND       TO_CHAR(PS.TRX_DATE,'MON-YY') = TO_CHAR(X.INVOICE_DATE,'MON-YY'));


                      WRITE_LOG ( '== '||SQL%ROWCOUNT||' Records had status_id set to 7 in XXAWAS_AR_INVOICE_FILE_STAGING.' ) ;

                      commit;





     IF v_reject_file THEN
          /*-- rollback transactions in PORTFOLIO*/
           DELETE
                    TBLARBILLINGINTERFACE@BASIN
                 WHERE
                    arbilling_id IN
                    (SELECT
                              arbilling_id
                            FROM
                              XXAWAS_AR_INVOICE_FILE_STAGING
                           WHERE
                              ora_request_id = v_request_id
                              AND STATUS_ID  = 3) ;

          WRITE_LOG ( '== '||SQL%ROWCOUNT||' Records in TBLARBILLINGINTERFACE@BASIN have been deleted. Please amend all incorrect data and rerun' ) ;
          /*-- for rentals delete from billing table also*/

           DELETE
                    tblarrentalbilling@basin R
                 WHERE
                    arbilling_id NOT IN
                    ( SELECT arbilling_id FROM tblarbillinginterface@basin
                    ) ;

          WRITE_LOG ( '== '||SQL%ROWCOUNT||' Records in TBLARRENTAL@BASIN have been deleted. Please amend all incorrect data and rerun' ) ;
          COMMIT;
     END IF;
EXCEPTION
WHEN OTHERS THEN
     WRITE_LOG ( 'ERROR in VALIDATE_RECORDS' ) ;
     WRITE_LOG ( SQLERRM ) ;
     RAISE;
END VALIDATE_RECORDS;
/*--=========================================================================*/
/*-- PROCESS_INVOICES_RECEIVABLES procedure groups invoice lines together on */
/*-- invoice then calls the INSERT_INTO_RECEIVABLES procedure */
/*--=========================================================================*/
PROCEDURE PROCESS_INVOICES_RECEIVABLES
IS
     v_org_id NUMBER;
     r_inv T_MAIN;
     v_company_code VARCHAR2 ( 4 ) ;
     v_terms        VARCHAR2 ( 15 ) ;
     x              NUMBER;
     cursor c_invoice_grouping
     IS SELECT   X.ORG_ID,
                    p.party_name customer_name,
                    x.msn,
                    to_char ( x.invoice_date, 'DD-MON-RRRR' ) invoice_date,
                    x.billing_type_id,
                    x.transtype_code,
                    COUNT ( * )
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING X,
                    HZ_CUST_ACCOUNTS C,
                    HZ_PARTIES P
                 where
                    X.ORA_REQUEST_ID = V_REQUEST_ID
                    AND C.CUST_ACCOUNT_ID = X.ORA_CUSTOMER_ID
                    and C.PARTY_ID = P.PARTY_ID
                    AND STATUS_ID NOT IN ( 3, 7)
              GROUP BY X.ORG_ID, P.PARTY_NAME, X.MSN, TO_CHAR ( X.INVOICE_DATE, 'DD-MON-RRRR' ), X.BILLING_TYPE_ID, X.TRANSTYPE_CODE
                    order by p.party_name;
BEGIN
     FOR r_99 IN c_invoice_grouping
     LOOP
           if r_99.transtype_code = 11 then
           SELECT awas_portfolio_inv_num_seq.nextVal INTO x FROM dual;
           else
           SELECT AWAS_RENTAL_INV_NUM_SEQ.nextVal INTO x FROM dual;
           end if;

           UPDATE
                    xxawas_ar_invoice_file_staging
               SET
                    ora_invoice_num = x
                 WHERE
                    org_id                                      = r_99.org_id
                    and msn                                     = r_99.msn
                    and transtype_code                          = r_99.transtype_code
                    AND TO_CHAR ( invoice_date, 'DD-MON-RRRR' ) = r_99.invoice_date
                    AND billing_type_id                         = r_99.billing_type_id;
          EXIT
     WHEN C_INVOICE_grouping%NOTFOUND;
     END LOOP;
     v_org_id := FND_PROFILE.VALUE ( 'ORG_ID' ) ;
     OPEN C_INVOICE_NORMAL ( v_REQUEST_ID ) ;
     /*-- Insert record into Receivables*/
     LOOP
          FETCH C_invOICE_normal BULK COLLECT INTO R_inv LIMIT 1000;
          /*--*/
          WRITE_LOG ( 'Starting INSERT INTO RECEIVABLES' ) ;
          INSERT_INTO_RECEIVABLES ( R_INV, V_ORG_ID ) ;
          WRITE_LOG ( 'Completed INSERT INTO RECEIVABLES' ) ;
          /*--*/
          EXIT
     WHEN C_INVOICE_NORMAL%NOTFOUND;
     END LOOP;
     CLOSE C_INVOICE_NORMAL;
EXCEPTION
WHEN OTHERS THEN
     WRITE_LOG ( 'Error in PROCESS_INVOICES_RECEIVABLES' ) ;
     WRITE_LOG ( SQLERRM ) ;
     RAISE;
END PROCESS_INVOICES_RECEIVABLES;
/*--=============================================================================*/
/*-- INSERT_INTO_RECEIVABLES procedure does tha actual inserts in AR interface*/
PROCEDURE INSERT_INTO_RECEIVABLES
     (
          R_inv    IN t_MAIN,
          v_org_id IN NUMBER )
                   IS
BEGIN
     /*--*/
     /*--*/
     /*--*/
     FORALL i IN 1..R_inv.INTERFACE_LINE_CONTEXT.COUNT
      INSERT
             INTO
               RA_INTERFACE_LINES_ALL
               (
                    INTERFACE_LINE_CONTEXT       ,
                    INTERFACE_LINE_ATTRIBUTE1    ,
                    INTERFACE_LINE_ATTRIBUTE2    ,
                    INTERFACE_LINE_ATTRIBUTE3    ,
                    INTERFACE_LINE_ATTRIBUTE4    ,
                    INTERFACE_LINE_ATTRIBUTE5    ,
                    INTERFACE_LINE_ATTRIBUTE6    ,
                    INTERFACE_LINE_ATTRIBUTE7    ,
                    BATCH_SOURCE_NAME            ,
                    SET_OF_BOOKS_ID              ,
                    LINE_TYPE                    ,
                    DESCRIPTION                  ,
                    CURRENCY_CODE                ,
                    AMOUNT                       ,
                    CUST_TRX_TYPE_NAME           ,
                    TERM_NAME                    ,
                    ORIG_SYSTEM_BILL_CUSTOMER_ID ,
                    ORIG_SYSTEM_BILL_CUSTOMER_REF,
                    ORIG_SYSTEM_BILL_ADDRESS_ID  ,
                    ORIG_SYSTEM_BILL_ADDRESS_REF ,
                    ORIG_SYSTEM_SHIP_CUSTOMER_ID ,
                    ORIG_SYSTEM_SHIP_CUSTOMER_REF,
                    ORIG_SYSTEM_SHIP_ADDRESS_ID  ,
                    ORIG_SYSTEM_SHIP_ADDRESS_REF ,
                    ORIG_SYSTEM_SOLD_CUSTOMER_ID ,
                    ORIG_SYSTEM_SOLD_CUSTOMER_REF,
                    LINK_TO_LINE_CONTEXT         ,
                    LINK_TO_LINE_ATTRIBUTE1      ,
                    LINK_TO_LINE_ATTRIBUTE2      ,
                    LINK_TO_LINE_ATTRIBUTE3      ,
                    LINK_TO_LINE_ATTRIBUTE4      ,
                    LINK_TO_LINE_ATTRIBUTE5      ,
                    LINK_TO_LINE_ATTRIBUTE6      ,
                    LINK_TO_LINE_ATTRIBUTE7      ,
                    LINK_TO_LINE_ATTRIBUTE8      ,
                    LINK_TO_LINE_ATTRIBUTE9      ,
                    LINK_TO_LINE_ATTRIBUTE10     ,
                    LINK_TO_LINE_ATTRIBUTE11     ,
                    LINK_TO_LINE_ATTRIBUTE12     ,
                    LINK_TO_LINE_ATTRIBUTE13     ,
                    LINK_TO_LINE_ATTRIBUTE14     ,
                    LINK_TO_LINE_ATTRIBUTE15     ,
                    CONVERSION_TYPE              ,
                    CONVERSION_DATE              ,
                    CONVERSION_RATE              ,
                    TRX_DATE                     ,
                    GL_DATE                      ,
                    TRX_NUMBER                   ,
                    QUANTITY                     ,
                    UNIT_SELLING_PRICE           ,
                    REASON_CODE                  ,
                    TAX_CODE                     ,
                    PRIMARY_SALESREP_NUMBER      ,
                    SALES_ORDER                  ,
                    SALES_ORDER_DATE             ,
                    SALES_ORDER_SOURCE           ,
                    MTL_SYSTEM_ITEMS_SEG1        ,
                    REFERENCE_LINE_CONTEXT       ,
                    REFERENCE_LINE_ATTRIBUTE1    ,
                    REFERENCE_LINE_ATTRIBUTE2    ,
                    REFERENCE_LINE_ATTRIBUTE3    ,
                    REFERENCE_LINE_ATTRIBUTE4    ,
                    REFERENCE_LINE_ATTRIBUTE5    ,
                    REFERENCE_LINE_ATTRIBUTE6    ,
                    REFERENCE_LINE_ATTRIBUTE7    ,
                    UOM_CODE                     ,
                    CREATED_BY                   ,
                    CREATION_DATE                ,
                    LAST_UPDATED_BY              ,
                    LAST_UPDATE_DATE             ,
                    ORG_ID                       ,
                    INTERFACE_LINE_ATTRIBUTE8    ,
                    INTERFACE_LINE_ATTRIBUTE9    ,
                    INTERFACE_LINE_ATTRIBUTE10   ,
                    INTERFACE_LINE_ATTRIBUTE11   ,
                    INTERFACE_LINE_ATTRIBUTE12   ,
                    INTERFACE_LINE_ATTRIBUTE13   ,
                    INTERFACE_LINE_ATTRIBUTE14   ,
                    LINE_GDF_ATTRIBUTE1          ,
                    LINE_GDF_ATTRIBUTE2          ,
                    LINE_GDF_ATTRIBUTE3          ,
                    LINE_GDF_ATTRIBUTE4          ,
                    LINE_GDF_ATTRIBUTE5          ,
                    LINE_GDF_ATTRIBUTE6          ,
                    LINE_GDF_ATTRIBUTE7          ,
                    LINE_GDF_ATTRIBUTE8          ,
                    LINE_GDF_ATTRIBUTE9          ,
                    LINE_GDF_ATTRIBUTE10         ,
                    HEADER_GDF_ATTRIBUTE1        ,
                    LINE_GDF_ATTRIBUTE11         ,
                    LINE_GDF_ATTRIBUTE12         ,
                    RECEIPT_METHOD_ID            ,
                    ORIG_SYSTEM_BILL_CONTACT_ID
               )
               VALUES
               (
                    R_inv.INTERFACE_LINE_CONTEXT ( i )       ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE1 ( i )    ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE2 ( i )    ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE3 ( i )    ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE4 ( i )    ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE5 ( i )    ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE6 ( i )    ,
                    R_inv.INTERFACE_LINE_ATTRIBUTE7 ( i )    ,
                    R_inv.BATCH_SOURCE_NAME ( i )            ,
                    R_inv.SET_OF_BOOKS_ID ( i )              ,
                    R_inv.LINE_TYPE ( i )                    ,
                    R_inv.DESCRIPTION ( i )                  ,
                    R_inv.CURRENCY_CODE ( i )                ,
                    R_inv.AMOUNT ( i )                       ,
                    R_inv.CUST_TRX_TYPE_NAME ( i )           ,
                    R_inv.TERM_NAME ( i )                    ,
                    R_inv.ORIG_SYSTEM_BILL_CUSTOMER_ID ( i ) ,
                    R_inv.ORIG_SYSTEM_BILL_CUSTOMER_REF ( i ),
                    R_inv.ORIG_SYSTEM_BILL_ADDRESS_ID ( i )  ,
                    R_inv.ORIG_SYSTEM_BILL_ADDRESS_REF ( i ) ,
                    R_inv.ORIG_SYSTEM_SHIP_CUSTOMER_ID ( i ) ,
                    R_inv.ORIG_SYSTEM_SHIP_CUSTOMER_REF ( i ),
                    R_inv.ORIG_SYSTEM_SHIP_ADDRESS_ID ( i )  ,
                    R_inv.ORIG_SYSTEM_SHIP_ADDRESS_REF ( i ) ,
                    R_inv.ORIG_SYSTEM_SOLD_CUSTOMER_ID ( i ) ,
                    R_inv.ORIG_SYSTEM_SOLD_CUSTOMER_REF ( i ),
                    R_inv.LINK_TO_LINE_CONTEXT ( i )         ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE1 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE2 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE3 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE4 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE5 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE6 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE7 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE8 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE9 ( i )      ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE10 ( i )     ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE11 ( i )     ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE12 ( i )     ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE13 ( i )     ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE14 ( i )     ,
                    R_inv.LINK_TO_LINE_ATTRIBUTE15 ( i )     ,
                    R_inv.CONVERSION_TYPE ( i )              ,
                    R_inv.CONVERSION_DATE ( i )              ,
                    R_inv.CONVERSION_RATE ( i )              ,
                    R_inv.GL_DATE ( i ) /*-- TRX_DATE*/
                    ,
                    R_inv.GL_DATE ( i )                  ,
                    R_inv.TRX_NUMBER ( i )               ,
                    R_inv.QUANTITY ( i )                 ,
                    R_inv.UNIT_SELLING_PRICE ( i )       ,
                    R_inv.REASON_CODE ( i )              ,
                    R_inv.TAX_CODE ( i )                 ,
                    R_inv.PRIMARY_SALESREP_NUMBER ( i )  ,
                    R_inv.SALES_ORDER ( i )              ,
                    R_inv.SALES_ORDER_DATE ( i )         ,
                    R_inv.SALES_ORDER_SOURCE ( i )       ,
                    R_inv.MTL_SYSTEM_ITEMS_SEG1 ( i )    ,
                    R_inv.REFERENCE_LINE_CONTEXT ( i )   ,
                    R_inv.REFERENCE_LINE_ATTRIBUTE1 ( i ),
                    R_inv.REFERENCE_LINE_ATTRIBUTE2 ( i ),
                    R_inv.REFERENCE_LINE_ATTRIBUTE3 ( i ),
                    R_inv.REFERENCE_LINE_ATTRIBUTE4 ( i ),
                    R_inv.REFERENCE_LINE_ATTRIBUTE5 ( i ),
                    R_inv.REFERENCE_LINE_ATTRIBUTE6 ( i ),
                    R_inv.REFERENCE_LINE_ATTRIBUTE7 ( i ),
                    R_inv.UOM_CODE ( i )                 ,
                    R_inv.CREATED_BY ( i )               ,
                    R_inv.CREATION_DATE ( i )            ,
                    R_inv.LAST_UPDATED_BY ( i )          ,
                    R_inv.LAST_UPDATE_DATE ( i )         ,
                    R_inv.ORG_ID ( i )                   ,
                    R_inv.FILE_LINE_NUMBER ( i )         ,
                    NVL ( R_inv.WAREHOUSE_ID ( i ), 0 ) /*-- HEADER_GDF_ATTRIBUTE25 9 warehouse_id This is the WAREHOUSE CODE*/
                    ,
                    R_inv.FILE_LINE_NUMBER ( i ) /*-- HEADER_GDF_ATTRIBUTE26 10*/
                    ,
                    NVL ( R_inv.EQUIVALENT_UNITS ( i ), 0 ) /*-- HEADER_GDF_ATTRIBUTE27 11*/
                    ,
                    NVL ( R_inv.ORIGINAL_TRANS_TYPE ( i ), '0' ) /*-- HEADER_GDF_ATTRIBUTE28 12*/
                    ,
                    NVL ( R_inv.WAREHOUSE_CODE ( i ), '0' ) /*-- WAREHOUSE_CODE  13*/
                    ,
                    FND_GLOBAL.CONC_REQUEST_ID /*-- HEADER_GDF_ATTRIBUTE29 14 This is the WAREHOUSE_ID*/
                    ,
                    R_inv.LINE_GDF_ATTRIBUTE1 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE2 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE3 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE4 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE5 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE6 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE7 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE8 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE9 ( i )  ,
                    R_inv.LINE_GDF_ATTRIBUTE10 ( i ) ,
                    R_inv.HEADER_GDF_ATTRIBUTE1 ( i ),
                    R_inv.LINE_GDF_ATTRIBUTE11 ( i ) ,
                    R_INV.EQUIVALENT_UNITS ( I )     ,
                    R_INV.RECEIPT_METHOD_ID ( I )    ,
                    r_inv.ORIG_SYSTEM_BILL_CONTACT_ID(I)
               ) ;
     /*--*/
     /*--*/
     WRITE_LOG
     (
          'in it :' || r_inv.INTERFACE_LINE_CONTEXT.count
     )
     ;
     NULL;
     /*--*/
     /*--*/
     /*--*/
EXCEPTION
WHEN OTHERS THEN
     /*-- WRITE_LOG('Exception in :' || r_inv.INTERFACE_LINE_CONTEXT.count);*/
     WRITE_LOG
     (
          'Error in INSERT_INTO_RECEIVABLES'
     )
     ;
     WRITE_LOG
     (
          SQLERRM
     )
     ;
     RAISE;
END INSERT_INTO_RECEIVABLES;
/*--=============================================================================*/
/*-- KICKOFF_IMPORT submits the standard AutoInvoice Master Program*/
PROCEDURE KICKOFF_IMPORT
IS
     l_request_id NUMBER;
     l_phase      VARCHAR2
     (
          20
     )
     ;
     l_code VARCHAR2
     (
          25
     )
     ;
     L_ERROR_MESSAGE VARCHAR2
     (
          250
     )
     ;
     e_autorec_failed EXCEPTION;
BEGIN
     submit_conc_request
     (
          p_application => 'AR', p_program => 'RAXMTR', p_sub_request => FALSE, p_parameter1 => 1, p_parameter2 => -99, p_parameter3 => 1044, p_parameter4 => 'PORTFOLIO', p_parameter5 => TRUNC ( sysdate ), p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL,  p_parameter25 => 'Y',  x_request_id =>l_request_id
     )
     ;
     /*-- wait till AutoInvoice Master program is completed*/
     IF l_request_id <> 0 THEN
          wait_conc_request
          (
               l_request_id, 'Wait for AutoInvoice Master program to complete', l_phase, l_code
          )
          ;
     ELSE
          l_error_message := 'Failed to submit AutoInvoice Master Program ' ;
          raise e_autorec_failed;
     END IF;
EXCEPTION
WHEN e_autorec_failed THEN
     write_debug
     (
          'Submit AutoInvoice Master Program Failed exception raised'
     )
     ;
     /*--write_out('Bank statement load failed.');*/
     retcode := 2;
     errbuf  := l_error_message;
     write_out
     (
          ''
     )
     ;

END KICKOFF_IMPORT;
/*--=============================================================================*/
/*-- Procedure WRITE_REPORT creates end user status report for import run*/
PROCEDURE WRITE_REPORT
IS
     CURSOR c_err
     IS
           SELECT
                    status_id                                            ,
                    rpad ( SUBSTR ( org_name, 1, 19 ), 19, ' ' ) cust    ,
                    rpad ( msn, 7, ' ' ) msn                             ,
                    component_name                                       ,
                    rpad ( SUBSTR ( description, 1, 27 ), 27, ' ' ) descr,
                    qty                                                  ,
                    rate_amnt                                            ,
                    restrans_val                                         ,
                    aircraft_lease_no                                    ,
                    ora_error_message err                                ,
                    ora_invoice_num                                      ,
                    invoice_date
                  FROM
                    xxawas_ar_invoice_file_staging
                 WHERE
                    ora_request_id         = v_request_id
                    AND ora_error_message IS NOT NULL
                    AND status_id          = 3;

     CURSOR c_ok
     IS
           SELECT   STATUS_ID                                           ,
                    rpad ( SUBSTR ( nvl(org_name,'.'), 1, 19 ), 19, ' ' ) cust   ,
                    lpad ( msn, 7, ' ' ) msn                            ,
                    rpad ( ora_invoice_num, 9, ' ' ) inv                ,
                    TO_CHAR ( invoice_date, 'DD-MON-RRRR' ) invoice_date,
                    lpad ( COUNT ( msn ), 2, ' ' ) line                 ,
                    SUM ( restrans_val ) total
                  FROM
                    XXAWAS_AR_INVOICE_FILE_STAGING
                 WHERE ORA_REQUEST_ID = V_REQUEST_ID
                 AND STATUS_ID  = 4
              GROUP BY STATUS_ID, RPAD ( SUBSTR (nvl( ORG_NAME,'.'), 1, 19 ), 19, ' ' ), LPAD ( MSN, 7, ' ' ), RPAD ( ORA_INVOICE_NUM, 9, ' ' ), TO_CHAR ( INVOICE_DATE, 'DD-MON-RRRR' )
              ORDER BY rpad ( ora_invoice_num, 9, ' ' );


     CURSOR c_others
     IS
           SELECT
                    status_id                                            ,
                    rpad ( SUBSTR ( org_name, 1, 20 ), 20, ' ' ) cust    ,
                    rpad ( msn, 7, ' ' ) msn                             ,
                    component_name                                       ,
                    rpad ( SUBSTR ( description, 1, 27 ), 27, ' ' ) descr,
                    qty                                                  ,
                    rate_amnt                                            ,
                    restrans_val                                         ,
                    aircraft_lease_no                                    ,
                    ora_error_message err                                ,
                    ora_invoice_num                                      ,
                    invoice_date
                  FROM
                    xxawas_ar_invoice_file_staging
                 WHERE
                    ORA_REQUEST_ID     = V_REQUEST_ID
                    AND status_id NOT IN ( 3, 4, 7 )
              ORDER BY
                    2,
                    3;

            CURSOR c_ab
     IS
           SELECT
                    status_id                                            ,
                    rpad ( SUBSTR ( org_name, 1, 20 ), 20, ' ' ) cust    ,
                    rpad ( msn, 7, ' ' ) msn                             ,
                    component_name                                       ,
                    rpad ( SUBSTR ( description, 1, 27 ), 27, ' ' ) descr,
                    qty                                                  ,
                    rate_amnt                                            ,
                    restrans_val                                         ,
                    aircraft_lease_no                                    ,
                    ora_error_message err                                ,
                    ora_invoice_num                                      ,
                    invoice_date
                  FROM
                    xxawas_ar_invoice_file_staging
                 WHERE
                    ORA_REQUEST_ID     = V_REQUEST_ID
                    AND status_id =  7
              ORDER BY
                    2,
                    3;



     CURSOR C_X
     IS        SELECT LEASE_NO,
                      MSN,
                      CUSTOMER_NAME,
                      CUST_NO,
               LPAD(TO_CHAR(INVOICE_AMOUNT,'9,999,999.09'),14,' ') INVOICE_AMOUNT,
               LPAD(TO_CHAR(ALS_AMOUNT,'9,999,999.09'),14,' ') ALS_AMOUNT,
               CASE WHEN NVL(INVOICE_AMOUNT,0)-NVL(ALS_AMOUNT,0) = 0 THEN 'OK   ' ELSE 'CHECK' END VALID
        FROM (
        SELECT    LPAD(nvl(V.AIRCRAFT_LEASE_NO,'0'),8,' ') LEASE_NO,
                  LPAD(CTX.INTERFACE_HEADER_ATTRIBUTE1,6,0) MSN,
                  RPAD(SUBSTRB(PARTY.PARTY_NAME,1,30),30,' ') CUSTOMER_NAME,
                  LPAD(CUST.ACCOUNT_NUMBER,7,' ') CUST_NO,
                  --LPAD(PS.TRX_NUMBER,7,' ') INV_NUM,
                  --LPAD(ARPT_SQL_FUNC_UTIL.GET_TRX_TYPE_DETAILS(CTX.CUST_TRX_TYPE_ID,'NAME'),20,' ') INV_TYPE,
                  --PS.TRX_DATE INV_DATE,
                  SUM(NVL(PS.AMOUNT_DUE_ORIGINAL,0)) INVOICE_AMOUNT,
                  nvl(ZZ.RESTRANS_VAL,0) ALS_AMOUNT
                  --case when sum(nvl(PS.AMOUNT_DUE_ORIGINAl,0))-nvl(ZZ.RESTRANS_VAL,0) = 0 then 'OK   ' else 'CHECK' end VALID
        FROM 	XXAWAS_AR_INVOICE_FILE_STAGING ZZ,
              HZ_customer_profiles      cp,
              HZ_customer_profiles      cp1,
              AR_COLLECTORS                    COL,
              HZ_CUST_ACCOUNTS                   CUST,
              HZ_PARTIES PARTY,
              RA_CUSTOMER_TRX_ALL              CTX,
              RA_SALESREPS_ALL                    SREP,
              (select  xx_ar_get_bal_due(payment_schedule_id,sysdate,org_id,class)     due_amount,
                                                  INVOICE_CURRENCY_CODE,
                                                  amount_due_remaining,
                                                  PAYMENT_SCHEDULE_ID,
                                                  trx_date,
                                                  trx_number,
                                                  status,
                                                  due_date,
                                                  actual_date_closed,
                                                  amount_due_original,
                                                  tax_original  ,
                                                  customer_site_use_id  ,
                                                  customer_trx_id            ,
                                                  cons_inv_id
                                        FROM      AR_PAYMENT_SCHEDULES_ALL
                                          WHERE ORG_ID = 85)   PS,
              (SELECT CUSTOMER_TRX_ID, MAX(CC.SEGMENT2) ACCOUNT FROM RA_CUST_TRX_LINE_GL_DIST_ALL GD, GL_CODE_COMBINATIONS CC
                                        WHERE GD.ACCOUNT_CLASS = 'REV'
                                        AND CC.CODE_COMBINATION_ID = GD.CODE_COMBINATION_ID
                                                  and gd.org_id = 85
                                        GROUP BY CUSTOMER_TRX_ID ) GLC,
              (select distinct aircraft_lease_no, msn, billing_customer_no from vrentalbilling@basin) V
              WHERE   CUST.CUST_ACCOUNT_ID             = CTX.BILL_TO_CUSTOMER_ID
              AND       CUST.PARTY_ID  =      PARTY.PARTY_ID
              AND       ZZ.STATUS_ID =  7
              AND       ZZ.AIRCRAFT_LEASE_NO  = V.AIRCRAFT_LEASE_NO (+)
              AND       ZZ.ORA_REQUEST_ID  = v_REQUEST_ID
              AND       CTX.CUSTOMER_TRX_ID      = PS.CUSTOMER_TRX_ID
              AND       nvl(V.BILLING_CUSTOMER_NO,CUST.ACCOUNT_NUMBER)   = CUST.ACCOUNT_NUMBER
              and       nvl(lpad(v.msn,6,'0'),lpad(ctx.interface_header_attribute1,6,'0')) = lpad(ctx.interface_header_attribute1,6,'0')
              and       ctx.primary_salesrep_id  = srep.salesrep_id (+)
              and       cp.CUST_ACCOUNT_ID     = CUST.CUST_ACCOUNT_ID
              AND       CP.SITE_USE_ID IS NULL
              AND       GLC.CUSTOMER_TRX_ID = CTX.CUSTOMER_TRX_ID
              AND       ARPT_SQL_FUNC_UTIL.GET_TRX_TYPE_DETAILS(CTX.CUST_TRX_TYPE_ID,'NAME') like '%Rent%'
              and       ctx.org_id = 85
              and       cp1.site_use_id (+)          = ps.customer_site_use_id
              AND       COL.COLLECTOR_ID             = NVL(CP1.COLLECTOR_ID, CP.COLLECTOR_ID)
              --AND       TO_CHAR(PS.TRX_DATE,'MON-YY') = V_PERIOD
              AND       TO_CHAR(PS.TRX_DATE,'MON-YY') = to_char(zz.invoice_date,'MON-YY')
              GROUP BY LPAD(NVL(V.AIRCRAFT_LEASE_NO,'0'),8,' '), LPAD(CTX.INTERFACE_HEADER_ATTRIBUTE1,6,0), RPAD(SUBSTRB(PARTY.PARTY_NAME,1,30),30,' '), LPAD(CUST.ACCOUNT_NUMBER,7,' '), NVL(ZZ.RESTRANS_VAL,0))
              ORDER BY 3,2;


     v_total NUMBER;
     V_COUNT NUMBER;
     FL      NUMBER;

BEGIN
     v_total := 0;
     v_count := 0;
     /*--Update Status*/
      UPDATE
               xxawas_ar_invoice_file_staging
          SET
               status_id = 4 /*-- 'BILLED'*/
            WHERE
               ref_table_id NOT IN
               ( SELECT interface_line_attribute4 FROM ra_interface_lines_all
               )
               AND status_id      = 1
               AND ora_request_id = v_request_id;
     COMMIT;
     WRITE_OUT ( '== '||SQL%ROWCOUNT||' Records were sucessfully processed through to AR.' ) ;
      UPDATE
               TBLARBILLINGINTERFACE@BASIN i
          SET
               status_id = 4 /*-- 'BILLED'*/
            WHERE
               arbilling_id IN
               (SELECT
                         arbilling_id
                 FROM
                         xxawas_ar_invoice_file_staging
                 WHERE
                         ora_request_id       = v_request_id
                         AND i.ref_table_name = ref_table_name
                         AND status_id        = 4
               ) ;
     COMMIT;
     WRITE_OUT ( '== '||SQL%ROWCOUNT||' Records in the PORTFOLIO were sucessfully updated to Billed.' ) ;
     WRITE_OUT ( 'Records brought through to AR completely............' ) ;
     WRITE_OUT ( 'Customer            MSN    Invoice Number    Lines    Total Amount' ) ;
     FOR R1 IN C_ok
     LOOP
          WRITE_OUT ( r1.cust||r1.MSN||' '||r1.inv||r1.invoice_date||'  '||r1.line||'       '||lpad ( r1.total, 10, ' ' ) ) ;
          v_total := v_total + r1.total;
          v_count := v_count + r1.line;
     END LOOP;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( '                                    Total Invoice Amount '||V_TOTAL ) ;
     WRITE_OUT ( '                                    Total Invoice Lines  '||v_count ) ;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( 'Records rejected............' ) ;
     WRITE_OUT ( 'Customer            MSN    Description                 Error message            ' ) ;
     v_total := 0;
     v_count := 0;
     FOR R1  IN C_err
     LOOP
          WRITE_OUT ( r1.cust||r1.MSN||r1.descr||' '||r1.err ) ;
          v_total := v_total + r1.restrans_val;
          v_count := v_count + 1;
     END LOOP;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( '                                    PORTFOLIO Data Errors' ) ;
     WRITE_OUT ( '                                    Total Invoice Amount '||V_TOTAL ) ;
     WRITE_OUT ( '                                    Total Invoice Lines  '||v_count ) ;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( 'Please correct the setups detailed above and resubmit this program to retry.' ) ;
     WRITE_OUT ( 'These records have been rolled back to the PORTFOLIO as unbilled.' ) ;


     FL:=0;
     V_TOTAL := 0;
     v_count := 0;

     FOR R1  IN C_OTHERS
     LOOP
     IF fl = 0 then
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( 'Records Stuck in AR Interface............' ) ;
     WRITE_OUT ( 'Customer            MSN    Description                 Error message            ' ) ;
     FL := FL+1;
     END IF;


     WRITE_OUT ( r1.cust||r1.MSN||r1.descr||'Check AutoInvoice Import Report for Errors' ) ;
     V_TOTAL := V_TOTAL + R1.RESTRANS_VAL;
     v_count := v_count + 1;
     END LOOP;

     IF FL>0 then
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( '                                    AutoInvoice Errors' ) ;
     WRITE_OUT ( '                                    Total Invoice Amount '||V_TOTAL ) ;
     WRITE_OUT ( '                                    Total Invoice Lines  '||v_count ) ;
     WRITE_OUT ( ' ' ) ;
     WRITE_OUT ( 'Please look at the AutoInvoice Import Program to see rejection reasons, ' ) ;
     WRITE_OUT ( 'correct customer setup issues and rerun AutoInvoice.' ) ;
     ELSE
     WRITE_OUT ( '' ) ;
     WRITE_OUT ( 'No new AutoInvoice Errors have been found.' ) ;
     END IF;



      UPDATE
               xxawas_ar_invoice_file_staging
          SET
               status_id = 4,
               comments  = 'STUCK IN AR'
            WHERE
               ref_table_id IN
               ( SELECT interface_line_attribute4 FROM ra_interface_lines_all
               )
               AND status_id      = 1
               AND ora_request_id = v_request_id;
     COMMIT;

      UPDATE
               TBLARBILLINGINTERFACE@BASIN i
          SET
               ora_invoice_num =
               (SELECT
                         trx_number
                       FROM
                         ra_customer_trx_lines_all l,
                         ra_customer_trx_all h
                      WHERE
                         l.interface_line_attribute4 = i.ref_table_id
                         AND h.customer_trx_id       = l.customer_trx_id
               ),
               comments = NULL
            WHERE
               status_id    = 4
               AND comments = 'STUCK IN AR';
     COMMIT;

      UPDATE
               TBLARBILLINGINTERFACE@BASIN i
          SET
               status_id       = 4,
               ora_invoice_num =
               (SELECT
                         ora_invoice_num
                       FROM
                         xxawas_ar_invoice_file_staging
                      WHERE
                         ora_request_id       = v_request_id
                         AND arbilling_id     = i.arbilling_id
                         AND i.ref_table_name = ref_table_name
               ),
               comments =
               (SELECT
                         comments
                       FROM
                         xxawas_ar_invoice_file_staging
                      WHERE
                         ora_request_id       = v_request_id
                         AND status_id        = 4
                         AND arbilling_id     = i.arbilling_id
                         AND i.ref_table_name = ref_table_name
               )
            WHERE
               arbilling_id IN
               (SELECT
                         arbilling_id
                       FROM
                         xxawas_ar_invoice_file_staging
                      WHERE
                         ora_request_id       = v_request_id
                         AND status_id        = 4
                         AND i.ref_table_name = ref_table_name
               ) ;


     /*--- Finally update remit to addresses in AR, this cannot been done in the interface.*/
      UPDATE
               ra_customer_trx_all t
          SET
               remit_to_address_id =
               (SELECT
                         MAX ( attribute2 )
                       FROM
                         hz_cust_site_uses_all h,
                         xxawas_ar_invoice_file_staging x
                      WHERE
                         site_use_code           = 'BILL_TO'
                         AND x.ora_invoice_num   = t.trx_number
                         AND h.org_id            = 85
                         AND h.cust_acct_site_id = x.ora_bill_to_id
                   GROUP BY
                         h.cust_acct_site_id
               )
            WHERE
               t.batch_source_id = 1044
               AND t.creation_Date > sysdate -1;
     COMMIT;


     FL := 0;

     FOR R1 IN C_X
     LOOP
     IF FL = 0 THEN
     WRITE_OUT ( ' ') ;
     WRITE_OUT ( ' ') ;
     WRITE_OUT ( 'The following lease rentals were not transferred to Oracle as records already exist for this rental period.') ;
     WRITE_OUT ( 'The table below details the comparison with what was being sent and what is already there.') ;
     WRITE_OUT ( '') ;
     WRITE_OUT ( 'LEASE NO   MSN  CUSTOMER NAME                     CUST NO      INV Amount     ALS Amount OK?') ;
     FL := FL+1;
     end if;

     WRITE_OUT (R1.LEASE_NO||' '||R1.MSN||' '||R1.CUSTOMER_NAME||' '||R1.CUST_NO||'     '||R1.INVOICE_AMOUNT||' '||R1.ALS_AMOUNT||' '||R1.VALID ) ;

     end loop;




EXCEPTION
WHEN OTHERS THEN
     WRITE_LOG ( 'Error in WRITE_REPORT' ) ;
     WRITE_LOG ( SQLERRM ) ;
     ROLLBACK;
     RAISE;
END WRITE_REPORT;
/*--=============================================================================*/
/*-- Procedure to submit a request*/
PROCEDURE submit_conc_request
     (
          p_application IN VARCHAR2,
          p_program     IN VARCHAR2,
          p_sub_request IN BOOLEAN,
          p_parameter1  IN VARCHAR2,
          p_parameter2  IN VARCHAR2,
          p_parameter3  IN VARCHAR2,
          p_parameter4  IN VARCHAR2,
          p_parameter5  IN VARCHAR2,
          p_parameter6  IN VARCHAR2,
          p_parameter7  IN VARCHAR2,
          p_parameter8  IN VARCHAR2,
          p_parameter9  IN VARCHAR2,
          p_parameter10 IN VARCHAR2,
          p_parameter11 IN VARCHAR2,
          p_parameter12 IN VARCHAR2,
          p_parameter13 IN VARCHAR2,
          p_parameter14 IN VARCHAR2,
          p_parameter25 IN VARCHAR2,
          x_request_id OUT NUMBER )
IS
BEGIN
     WRITE_DEBUG ( 'submit_conc_request -> begining' ) ;
     x_request_id   := FND_REQUEST.SUBMIT_REQUEST ( application=>p_application, program =>p_program, sub_request=>FALSE, argument1 =>p_parameter1, argument2 =>p_parameter2, argument3 =>p_parameter3, argument4 =>p_parameter4, argument5 =>p_parameter5, argument6 =>p_parameter6, argument7 =>p_parameter7, argument8 =>p_parameter8, argument9 =>p_parameter9, argument10 =>p_parameter10, argument11 =>p_parameter11, argument12 =>p_parameter12, argument13 =>p_parameter13, argument14 =>p_parameter14, argument15 =>NULL, argument16 =>NULL, argument17 =>NULL, argument18 =>NULL, argument19 =>NULL, argument20 =>NULL, argument21 =>NULL, argument22 =>NULL, argument23 =>NULL, argument24 =>NULL, argument25 =>null,argument26 =>p_parameter25,argument27 =>NULL  ) ;
     IF x_request_id = 0 THEN
          ROLLBACK;
     ELSE
          COMMIT;
     END IF;
     write_Debug ( 'submit_conc_request -> request_id :'|| x_request_id ) ;
     write_Debug ( 'submit_conc_request -> end' ) ;
END submit_conc_request;
/*--=============================================================================*/
/*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2 )
IS
     l_request_code BOOLEAN DEFAULT FALSE;
     l_dev_phase    VARCHAR2 ( 30 ) ;
     l_dev_code     VARCHAR2 ( 30 ) ;
     l_sleep_time   NUMBER DEFAULT 15;
     l_message      VARCHAR2 ( 100 ) ;
BEGIN
     write_debug ( 'wait_conc_request -> begining' ) ;
     write_debug ( 'Waiting for ' || p_description || ' request to complete.' ) ;
     l_request_code := FND_CONCURRENT.WAIT_FOR_REQUEST ( p_request_id, l_Sleep_Time, 0, x_Phase, x_code, l_dev_phase, l_dev_code, l_Message ) ;
     write_Debug ( 'Completion code details are :- ' ) ;
     write_Debug ( 'Phase      -> '||x_Phase ) ;
     write_Debug ( 'code       -> '||x_code ) ;
     write_Debug ( 'Dev Phase  -> '||l_dev_phase ) ;
     write_Debug ( 'Dev code   -> '||l_dev_code ) ;
     write_Debug ( 'Message    -> '||l_Message ) ;
     write_debug ( 'wait_conc_request -> End' ) ;
END wait_conc_request;
/*--=============================================================================*/
/*-- Procedure to write message in log file.*/
PROCEDURE write_log
     (
          p_message IN VARCHAR2 )
                    IS
     l_message VARCHAR2 ( 132 ) ;
BEGIN
     L_MESSAGE := SUBSTR ( P_MESSAGE, 1, 132 ) ;
     FND_FILE.PUT_LINE ( FND_FILE.LOG, L_MESSAGE ) ;
     --DBMS_OUTPUT.put_line( L_MESSAGE ) ;
END write_log;
/*--=============================================================================*/
/*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 )
                    IS
BEGIN
     FND_FILE.PUT_LINE ( FND_FILE.LOG, P_MESSAGE ) ;
     --DBMS_OUTPUT.put_line( P_MESSAGE ) ;
END write_debug;
/*--=============================================================================*/
/*-- Procedure to write message on output file.*/
PROCEDURE write_out
     (
          p_message IN VARCHAR2 )
                    IS
     l_message VARCHAR2 ( 132 ) ;
BEGIN
     L_MESSAGE := SUBSTR ( P_MESSAGE, 1, 132 ) ;
     FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, L_MESSAGE ) ;
     --DBMS_OUTPUT.put_line( L_MESSAGE ) ;
END write_out;
/*--=============================================================================*/
FUNCTION GET_CONTACT(  P_CUSTOMER_ID IN NUMBER
                    , p_PARTY_SITE_ID IN NUMBER
                    ) RETURN NUMBER AS

RETVAL NUMBER;

BEGIN

                                SELECT max(AC.CONTACT_ID)
                                 into retval
                                 FROM AR_CONTACTS_V  AC,
                                      hz_role_responsibility rcr
                                 WHERE AC.CUSTOMER_ID = P_CUSTOMER_ID
                                 AND NVL(AC.STATUS,'A') = 'A'
                                 AND AC.CONTACT_ID = RCR.CUST_ACCOUNT_ROLE_ID (+)
                                 AND NVL(RCR.RESPONSIBILITY_TYPE,'INV') = 'INV'
                                 AND NVL(RCR.PRIMARY_FLAG,'Y') = 'Y'
                                 and ac.address_id is null;

  IF SQL%NOTFOUND
  THEN RETVAL := NULL;
  END IF;

  RETURN RETVAL;


END GET_CONTACT;
END XX_AWAS_AR_INVOICE_LOAD;
/
