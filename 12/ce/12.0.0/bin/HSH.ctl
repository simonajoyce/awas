--|==========================================================================|
--| Name:         HSH.ctl					             | 
--| Description:  This file Contains contol file mapping to read the HSH Germany
--|        bank statement file.The file is pipe seperated
--|		  							     |
--|									     |
--|									     |
--| Change Record:							     |
--| =============						  	     |
--| Version	Date	   	Author		   Remarks		     |
--| =======     ===========	=================  ========================= |	
--|  								     |
--|									     |
--|									     |
--|									     |
--+==========================================================================+
-- Header First
LOAD DATA
REPLACE
INTO TABLE XX_HSH_STMT_LINES_INTERFACE
FIELDS TERMINATED BY "|" 
TRAILING NULLCOLS 
( BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM =BLANKS,
  EFFECTIVE_DATE           NULLIF EFFECTIVE_DATE =BLANKS "to_date(:EFFECTIVE_DATE,'DD.MM.RR')",
  STATEMENT_NUMBER         NULLIF STATEMENT_NUMBER =BLANKS,
  CONTROL_BEGIN_BALANCE    NULLIF CONTROL_BEGIN_BALANCE=BLANKS,
  CONTROL_END_BALANCE      NULLIF CONTROL_END_BALANCE=BLANKS,
  CONTROL_TOTAL_DR         NULLIF CONTROL_TOTAL_DR=BLANKS,
  CONTROL_TOTAL_CR         NULLIF CONTROL_TOTAL_CR=BLANKS,
  CONTROL_LINE_COUNT       NULLIF CONTROL_LINE_COUNT=BLANKS,
  LINE_NUMBER              NULLIF LINE_NUMBER=BLANKS ,
  TRX_CODE                 NULLIF TRX_CODE=BLANKS,
  POSTING_TEXT             NULLIF POSTING_TEXT=BLANKS,
  TRX_TEXT                 NULLIF TRX_TEXT=BLANKS,
  CUSTOMER_TEXT            NULLIF CUSTOMER_TEXT=BLANKS,
  ATTRIBUTE1               NULLIF CUSTOMER_TEXT=BLANKS,
  AMOUNT                   NULLIF AMOUNT=BLANKS ,
  CURRENCY_CODE            ,
  ORIGINAL_AMOUNT          ,
  ORIGINAL_CURRENCY        NULLIF ORIGINAL_CURRENCY=BLANKS,
  SOURCE_AMT               NULLIF SOURCE_AMT=BLANKS,
  SOURCE_CURRENCY          NULLIF source_currency=BLANKS,
  TRX_DATE                 NULLIF TRX_DATE=BLANKS "to_date(:TRX_DATE,'DD.MM.RR')",
  POSTING_DATE             NULLIF POSTING_DATE=BLANKS "to_date(:POSTING_DATE,'DD.MM.RR')",
  ATTRIBUTE3               NULLIF ATTRIBUTE3=BLANKS,
  ATTRIBUTE4               NULLIF ATTRIBUTE4=BLANKS,
  ATTRIBUTE5               NULLIF ATTRIBUTE5=BLANKS,
  ATTRIBUTE6               NULLIF ATTRIBUTE6=BLANKS,
  ATTRIBUTE7               NULLIF ATTRIBUTE7=BLANKS,
  ATTRIBUTE8               NULLIF ATTRIBUTE8=BLANKS,
  ATTRIBUTE9               NULLIF ATTRIBUTE9=BLANKS,
  ATTRIBUTE10              NULLIF ATTRIBUTE10=BLANKS,
  ATTRIBUTE11              NULLIF ATTRIBUTE11=BLANKS,
  ATTRIBUTE12              NULLIF ATTRIBUTE12=BLANKS,
  ATTRIBUTE13              NULLIF ATTRIBUTE13=BLANKS,
  ATTRIBUTE14              NULLIF ATTRIBUTE14=BLANKS,
  ATTRIBUTE15              NULLIF ATTRIBUTE15=BLANKS
  )


