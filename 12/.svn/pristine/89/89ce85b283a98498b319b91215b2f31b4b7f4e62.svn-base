--|==========================================================================|
--| Name:         WT.ctl					             | 
--| Description:  This file Contains contol file mapping to read the Wilmington Trust 
--|        bank statement file.The file is pipe seperated
--|		  							     |
--|									     |
--|									     |
--| Change Record:							     |
--| =============						  	     |
--| Version	Date	   	Author		   Remarks		     |
--| =======     ===========	=================  ========================= |	
--|  									     |
--|									     |
--|									     |
--|									     |
--+==========================================================================+
LOAD DATA
REPLACE
INTO TABLE XX_WT_STMT_LINES_INTERFACE
WHEN BANK_ACCOUNT_NUM <> '  076314-000    '
AND BANK_ACCOUNT_NUM <>  '  048331-000    '
AND BANK_ACCOUNT_NUM <>  '  055019-000    '
AND ATTRIBUTE3 <> 'CASH MANAGEMENT ACTIVITY        '
AND ATTRIBUTE3 <> 'CASH MANAGEMENT ACTIVITY'
AND ATTRIBUTE3 <> '  CASH MANAGEMENT ACTIVITY        '
FIELDS TERMINATED BY "|" 
TRAILING NULLCOLS 
( BANK_ACCOUNT_NUM       NULLIF BANK_ACCOUNT_NUM =BLANKS "trim(replace(:BANK_ACCOUNT_NUM,'-',''))"   ,
  ATTRIBUTE1               NULLIF ATTRIBUTE1 =BLANKS "trim(:ATTRIBUTE1)",
--  ATTRIBUTE2               NULLIF ATTRIBUTE2 =BLANKS "trim(:ATTRIBUTE2)",
  ATTRIBUTE3               NULLIF ATTRIBUTE3 =BLANKS "trim(:ATTRIBUTE3)",
  TRX_CODE                 NULLIF TRX_CODE =BLANKS "trim(:TRX_CODE)",
  TRX_DATE                 NULLIF TRX_DATE =BLANKS "to_date(to_char(to_date(:TRX_DATE,'MM-DD-YYYY'),'DD-MON-YYYY'))" ,
  ATTRIBUTE4               NULLIF ATTRIBUTE4 =BLANKS "trim(:ATTRIBUTE4)",
  TRX_TEXT POSITION(168:1217)   NULLIF TRX_TEXT =BLANKS "trim(substr(:TRX_TEXT,1,255))",
  AMOUNT                   NULLIF AMOUNT =BLANKS "abs((replace(:AMOUNT,' ','')*1))",
  LINE_NUMBER              "DB_STMT_LINES_INTERFACE_S.NEXTVAL"
  )


