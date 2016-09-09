CREATE OR REPLACE PACKAGE XX_AR_RESERVES_PKG
/*--------------------------------------------------------------+
| Developed By Simon Joyce for AWAS                             |
| This package transfers all receipt applications against trxs  |
| created from Reserves back to Reserves, creating transactions |
| directly in the Reserves system.                              |
| Revision History:                                             |
| Created By Simon Joyce     Nov-2009                           |
+--------------------------------------------------------------*/
AS
PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 ) ;
END XX_AR_RESERVES_PKG;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AR_RESERVES_PKG
AS
PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 )
AS
     /*------------------------------------------------------------------*/
     /*-- Transfer AR Receipt Application into the Reserves system*/
     /*------------------------------------------------------------------*/
     v_request_id NUMBER;
BEGIN
     v_request_id := fnd_global.conc_request_id;
     /*----------------------------------------------------------------------*/
     /*-- Select receipt applications to process, store concurrent request id*/
     /*-- against transaction to stop reprocessing.*/
     /*----------------------------------------------------------------------*/
      UPDATE
               AR_RECEIVABLE_APPLICATIONS_ALL a
          SET
               a.attribute15 = a.receivable_application_id,
               a.attribute14 = v_request_id
            WHERE
               NVL ( a.attribute15, - 1 ) <> a.receivable_application_id
               AND org_id                  = 85;
     /*----------------------------------------------------------------------*/
     /*-- Do inserts into reserves*/
     /*----------------------------------------------------------------------*/
      INSERT
             INTO
               TBLRESTRANSACTION@BASIN
     SELECT
               tblrestransaction_seq.nextval@BASIN,
               z.aircraft_lease_no                ,
               12 transtype_code                  ,
               x.receipt_date transaction_date    ,
               z.period_id                        ,
               x.receipt_number REFERENCE         ,
               x.application_type
               ||' '
               ||x.status
               ||' Invoice: '
               ||x.invoice_number description                                                    ,
               z.component_code                                                                  ,
               NULL usageunit_code                                                               ,
               NULL rate_amnt                                                                    ,
               NULL quantity                                                                     ,
               ROUND ( ( x.amount_applied / x.total_amount ) * l.revenue_amount, 2 ) restrans_val,
               1 recstatus_cd                                                                    ,
               11796 modified_by                                                                 ,
               sysdate modified_tm                                                               ,
               11796 created_by                                                                  ,
               sysdate created_tm
             FROM
               ra_customer_trx_lines_all l,
               tblrestransaction@basin z  ,
               (SELECT
                         RA.RECEIVABLE_APPLICATION_ID,
                         RA.GL_DATE                  ,
                         RA.APPLY_DATE               ,
                         RA.AMOUNT_APPLIED           ,
                         RA.APPLICATION_TYPE         ,
                         CASE
                              WHEN RA.amount_applied < 0
                              THEN 'UNAPP'
                              ELSE 'APP'
                         END STATUS                        ,
                         CT.TRX_NUMBER INVOICE_NUMBER      ,
                         CT.CUSTOMER_TRX_ID                ,
                         CT.TRX_DATE INVOICE_DATE          ,
                         CT.INTERFACE_HEADER_ATTRIBUTE1 MSN,
                         TT.NAME TRX_TYPE                  ,
                         CR.RECEIPT_NUMBER                 ,
                         CR.RECEIPT_DATE                   ,
                         SUM ( ctl.revenue_amount ) TOTAL_AMOUNT
                       FROM
                         AR_RECEIVABLE_APPLICATIONS_ALL RA,
                         ra_customer_trx_lines_all ctl    ,
                         ra_customer_trx_all CT           ,
                         ra_cust_trx_types_all TT         ,
                         AR_CASH_RECEIPTS_ALL cr
                      WHERE
                         RA.APPLIED_CUSTOMER_TRX_ID = CT.customer_trx_id
                         AND tt.cust_trx_type_id    = cT.cust_trx_type_id
                         AND RA.ATTRIBUTE14         = v_request_id
                         AND ctl.customer_trx_id    = ct.customer_trx_id
                         AND CR.CASH_RECEIPT_ID (+) = RA.cash_receipt_id
                         AND ra.amount_applied     <> 0
                         AND CT.cust_trx_type_id   IN ( 1372, 1373 )
                         AND RA.ORG_ID              = 85
                         AND RA.APPLICATION_TYPE    = 'CASH' /*-- Credit memos excluded*/
                   GROUP BY RA.RECEIVABLE_APPLICATION_ID, RA.GL_DATE, RA.APPLY_DATE, RA.AMOUNT_APPLIED, RA.APPLICATION_TYPE, CASE
                              WHEN RA.amount_applied < 0
                              THEN 'UNAPP'
                              ELSE 'APP'
                         END, CT.TRX_NUMBER, CT.CUSTOMER_TRX_ID, CT.TRX_DATE, CT.INTERFACE_HEADER_ATTRIBUTE1, TT.NAME, CR.RECEIPT_NUMBER, CR.RECEIPT_DATE
             
             UNION ALL
                
                SELECT
                         RA.RECEIVABLE_APPLICATION_ID,
                         RA.GL_DATE                  ,
                         RA.APPLY_DATE               ,
                         RA.AMOUNT_APPLIED           ,
                         RA.APPLICATION_TYPE         ,
                         CASE
                              WHEN RA.amount_applied < 0
                              THEN 'UNAPP'
                              ELSE 'APP'
                         END STATUS                        ,
                         CT.TRX_NUMBER INVOICE_NUMBER      ,
                         CT.CUSTOMER_TRX_ID                ,
                         CT.TRX_DATE INVOICE_DATE          ,
                         CT.INTERFACE_HEADER_ATTRIBUTE1 MSN,
                         TT.NAME TRX_TYPE                  ,
                         PS.TRX_NUMBER                     ,
                         PS.TRX_DATE                       ,
                         SUM ( CTL.REVENUE_AMOUNT ) TOTAL_AMOUNT
                         /*
                       FROM
                         AR_RECEIVABLE_APPLICATIONS_ALL RA,
                         ra_customer_trx_lines_all ctl    ,
                         ra_customer_trx_all CT           ,
                         RA_
                         SUM ( CTL.REVENUE_AMOUNT ) TOTAL_AMOUNTRECEIPTS_ALL cr          ,
                         AR_PAYMENT_SCHEDULES_ALL ps
                      WHERE
                         RA.APPLIED_CUSTOMER_TRX_ID = CT.customer_trx_id
                         AND tt.cust_trx_type_id    = cT.cust_trx_type_id
                         AND RA.ATTRIBUTE14         = v_request_id
                         AND ctl.customer_trx_id    = ct.customer_trx_id
                         AND CR.CASH_RECEIPT_ID (+) = RA.cash_receipt_id
                         AND ps.payment_schedule_id = ra.payment_schedule_id
                         AND ra.amount_applied     <> 0
                         AND CT.cust_trx_type_id   IN ( 1372, 1373 )
                         AND RA.ORG_ID              = 85
                         AND RA.APPLICATION_TYPE    = 'CM'
                         */
                    FROM AR_RECEIVABLE_APPLICATIONS_ALL RA,
                         ra_customer_trx_lines_all ctl    ,
                         RA_CUSTOMER_TRX_ALL CT           ,
                         ra_customer_trx_all Cm           ,
                         ra_cust_trx_types_all TT         ,
                         AR_CASH_RECEIPTS_ALL cr          ,
                         AR_PAYMENT_SCHEDULES_ALL ps
                      WHERE  RA.APPLIED_CUSTOMER_TRX_ID = CT.customer_trx_id
                         AND TT.CUST_TRX_TYPE_ID    = CT.CUST_TRX_TYPE_ID
                         AND RA.ATTRIBUTE14         = v_request_id
                         AND ctl.customer_trx_id    = ct.customer_trx_id
                         AND CR.CASH_RECEIPT_ID (+) = RA.cash_receipt_id
                         AND ps.payment_schedule_id = ra.payment_schedule_id
                         AND ra.amount_applied     <> 0
                         AND CT.cust_trx_type_id   IN ( 1372, 1373 )
                         AND RA.ORG_ID              = 85
                         and CM.CUSTOMER_TRX_ID = RA.APPLIED_CUSTOMER_TRX_ID
                         AND RA.APPLICATION_TYPE    = 'CM'
                         and cm.batch_source_id <> 1044
                         /*-- Credit memos only*/
                   GROUP BY
                         RA.RECEIVABLE_APPLICATION_ID  ,
                         RA.GL_DATE                    ,
                         RA.APPLY_DATE                 ,
                         RA.AMOUNT_APPLIED             ,
                         RA.APPLICATION_TYPE           ,
                         RA.STATUS                     ,
                         CT.TRX_NUMBER                 ,
                         CT.CUSTOMER_TRX_ID            ,
                         CT.TRX_DATE                   ,
                         CT.INTERFACE_HEADER_ATTRIBUTE1,
                         TT.NAME                       ,
                         PS.TRX_NUMBER                 ,
                         PS.TRX_DATE
               ) x
            WHERE
               l.customer_trx_id                                                          = x.customer_trx_id
               AND l.interface_line_attribute4                                            = z.restransaction_id
               AND ROUND ( ( x.amount_applied / x.total_amount ) * l.revenue_amount, 2 ) <> 0;
END MAIN;
END XX_AR_RESERVES_PKG;
/
