--|==========================================================================|
--| Name:         WF.ctl					             | 
--| Description:  This file Contains contol file mapping to read the WellsFargo
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
INTO TABLE XX_WF_STMT_LINES_INTERFACE
WHEN BANK_ACCOUNT_NUM <> 'Account ID'
and AMOUNT <> '0'
and AMOUNT <> '.00'
FIELDS TERMINATED BY "," 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
( BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM =BLANKS,
  EFFECTIVE_DATE           NULLIF EFFECTIVE_DATE =BLANKS "to_date(:EFFECTIVE_DATE,'MM/DD/RRRR')",
  AMOUNT                   NULLIF AMOUNT=BLANKS ,
  TRX_CODE                 NULLIF TRX_CODE=BLANKS ":TRX_CODE*1",
  ATTRIBUTE14              NULLIF ATTRIBUTE14=BLANKS,
  ATTRIBUTE15              NULLIF ATTRIBUTE15=BLANKS,
  ATTRIBUTE13              NULLIF ATTRIBUTE13=BLANKS,
  BANK_TRX_NUMBER          NULLIF BANK_TRX_NUMBER=BLANKS,
  TRX_TEXT                 NULLIF TRX_TEXT=BLANKS,
  CUSTOMER_TEXT            NULLIF CUSTOMER_TEXT=BLANKS ,
  ATTRIBUTE1               NULLIF ATTRIBUTE1=BLANKS,
  ATTRIBUTE3               NULLIF ATTRIBUTE3=BLANKS,
  ATTRIBUTE4               NULLIF ATTRIBUTE4=BLANKS,
  ATTRIBUTE5               NULLIF ATTRIBUTE5=BLANKS,
  TRX_DATE                 NULLIF TRX_DATE=BLANKS "to_date(:TRX_DATE,'MM/DD/RRRR')",
  LINE_NUMBER              "WF_STMT_LINES_INTERFACE_S.NEXTVAL"
  )


