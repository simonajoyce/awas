--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_CE_STMT_LINE_ERRORS_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_CE_STMT_LINE_ERRORS_V" ("BANK_ACCOUNT_NUMBER", "STATEMENT_NUMBER", "LINE_NUMBER", "TRX_DATE", "TRX_TYPE", "BANK_TRX_NUMBER", "TRX_TEXT", "CUSTOMER_TEXT", "INVOICE_TEXT", "COMMENTS", "DEPT", "AMOUNT") AS 
  (
 SELECT
          b.BANK_ACCOUNT_NUM BANK_ACCOUNT_NUMBER       ,
          a.STATEMENT_NUMBER          ,
          CE_STATEMENT_LINES.LINE_NUMBER    ,
          CE_STATEMENT_LINES.TRX_DATE       ,
          CE_STATEMENT_LINES.TRX_TYPE       ,
          CE_STATEMENT_LINES.BANK_TRX_NUMBER,
          CE_STATEMENT_LINES.TRX_TEXT       ,
          CE_STATEMENT_LINES.CUSTOMER_TEXT  ,
          CE_STATEMENT_LINES.INVOICE_TEXT   ,
          CE_STATEMENT_LINES.ATTRIBUTE2  COMMENTS   ,
          CE_STATEMENT_LINES.ATTRIBUTE3  DEPT   ,
          CE_STATEMENT_LINES.AMOUNT
        FROM
          CE_STATEMENT_HEADERS A,
          CE_BANK_ACCOUNTS b,
          CE_STATEMENT_LINES
       WHERE   a.STATEMENT_HEADER_ID     = CE_STATEMENT_LINES.STATEMENT_HEADER_ID
          AND ( CE_STATEMENT_LINES.STATUS = 'ERROR' AND CE_STATEMENT_LINES.STATUS  IS NOT NULL )
          and b.bank_account_id = a.bank_account_id
    );
