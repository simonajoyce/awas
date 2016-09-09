--|==========================================================================|
--| Name:         DB.ctl					             | 
--| Description:  This file Contains contol file mapping to read the Deustch Bank
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
LOAD DATA
REPLACE
INTO TABLE XX_DB_STMT_LINES_INTERFACE
WHEN CURRENCY_CODE <> "Account Currency"
FIELDS TERMINATED BY "|" 
TRAILING NULLCOLS 
( CURRENCY_CODE            NULLIF CURRENCY_CODE =BLANKS "trim(:CURRENCY_CODE)"   ,
  BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM =BLANKS,
  TRX_TEXT                 NULLIF TRX_TEXT =BLANKS "trim(substr(:TRX_TEXT,1,255))",
  TRX_CODE                 NULLIF TRX_CODE =BLANKS "trim(:TRX_CODE)",
  BANK_TRX_NUMBER          NULLIF BANK_TRX_NUMBER =BLANKS ,
  CHARGES_AMOUNT           NULLIF CHARGES_AMOUNT =BLANKS "TO_NUMBER(REPLACE(REPLACE(:CHARGES_AMOUNT,'USD',''),',',''))",
  CUSTOMER_TEXT            NULLIF CUSTOMER_TEXT =BLANKS ,
  ATTRIBUTE1               NULLIF ATTRIBUTE1 =BLANKS,
  ATTRIBUTE2               NULLIF ATTRIBUTE2 =BLANKS "trim(:ATTRIBUTE2)",
  AMOUNT                   NULLIF AMOUNT =BLANKS "replace(:AMOUNT,' ','')*1",
  ATTRIBUTE5                NULLIF ATTRIBUTE5 =BLANKS,
  ATTRIBUTE6                NULLIF ATTRIBUTE6 =BLANKS,
  ATTRIBUTE7                NULLIF ATTRIBUTE7 =BLANKS,
  ATTRIBUTE8                NULLIF ATTRIBUTE8 =BLANKS,
  ATTRIBUTE9                NULLIF ATTRIBUTE9 =BLANKS,
  ATTRIBUTE10                NULLIF ATTRIBUTE10 =BLANKS,
  ATTRIBUTE11                NULLIF ATTRIBUTE11 =BLANKS,
  ATTRIBUTE12                NULLIF ATTRIBUTE12 =BLANKS,
  ATTRIBUTE3                 NULLIF ATTRIBUTE3 =BLANKS,
  ATTRIBUTE4                 NULLIF ATTRIBUTE4 =BLANKS,
  ATTRIBUTE13                NULLIF ATTRIBUTE13 =BLANKS,
  ATTRIBUTE14               NULLIF ATTRIBUTE14 =BLANKS,
  LINE_NUMBER              "DB_STMT_LINES_INTERFACE_S.NEXTVAL"
  )


