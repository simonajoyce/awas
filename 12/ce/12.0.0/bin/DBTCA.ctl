		--|==========================================================================|
--| Name:         DBTCA.ctl					             | 
--| Description:  This file Contains contol file mapping to read the DBTCA 
--|        bank statement file.The file is comma seperated
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

INTO TABLE DB_STATEMENT_LINES_INTERFACE
WHEN TRX_CODE <> 'Dividend Reinvestment'
AND BANK_ACCOUNT_NUM <> 'Portfolio Number'
AND TRX_CODE <> 'Pending Purchase'
AND AMOUNT <> '0.00'
AND AMOUNT <> '0'
FIELDS TERMINATED BY "," 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
( TRX_DATE                 NULLIF TRX_DATE =BLANKS "to_date(to_char(to_date(:TRX_DATE,'DD/MM/YYYY'),'DD-MON-YYYY'))" ,
  BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM =BLANKS,
  ATTRIBUTE1               NULLIF ATTRIBUTE1 =BLANKS,
  ATTRIBUTE2               NULLIF ATTRIBUTE2 =BLANKS,
  ATTRIBUTE12              NULLIF ATTRIBUTE12 =BLANKS,
  ATTRIBUTE13              NULLIF ATTRIBUTE13 =BLANKS,
  ATTRIBUTE14              NULLIF ATTRIBUTE14 =BLANKS,
  TRX_CODE                 NULLIF TRX_CODE =BLANKS,
  TRX_TEXT                 NULLIF TRX_TEXT =BLANKS,
  AMOUNT                   NULLIF AMOUNT =BLANKS "replace(replace(:AMOUNT,',',''),'$','')*1",
  ATTRIBUTE3               NULLIF ATTRIBUTE3 =BLANKS,
  ATTRIBUTE4               NULLIF ATTRIBUTE4 =BLANKS,
  ATTRIBUTE5               NULLIF ATTRIBUTE5 =BLANKS "substr(:ATTRIBUTE5, 1,256)",
  ATTRIBUTE6               NULLIF ATTRIBUTE6 =BLANKS,
  ATTRIBUTE7               NULLIF ATTRIBUTE7 =BLANKS,
  LINE_NUMBER              "DB_STMT_LINES_INTERFACE_S.NEXTVAL")


-- Dividend Reinvestment
INTO TABLE DB_STATEMENT_LINES_INTERFACE
WHEN TRX_CODE = 'Dividend Reinvestment' 
--AND BANK_ACCOUNT_NUM <> 'Portfolio Number'
AND AMOUNT <> '0.00'
AND AMOUNT <> '0'
FIELDS TERMINATED BY "," 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
( TRX_DATE                 POSITION(1) NULLIF TRX_DATE =BLANKS "to_date(to_char(to_date(:TRX_DATE,'DD/MM/YYYY'),'DD-MON-YYYY'))" ,
  BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM =BLANKS      ,
  ATTRIBUTE1               NULLIF ATTRIBUTE1 =BLANKS,
  ATTRIBUTE2               NULLIF ATTRIBUTE2 =BLANKS,
  ATTRIBUTE12              NULLIF ATTRIBUTE12 =BLANKS,
  ATTRIBUTE13              NULLIF ATTRIBUTE13 =BLANKS,
  ATTRIBUTE14              NULLIF ATTRIBUTE14 =BLANKS,
  TRX_CODE                 NULLIF TRX_CODE =BLANKS,
  TRX_TEXT                 NULLIF TRX_TEXT =BLANKS "'Interest Income-'||:TRX_TEXT",
  ATTRIBUTE3               NULLIF ATTRIBUTE3 =BLANKS,
  AMOUNT                   NULLIF AMOUNT =BLANKS "replace(replace(:AMOUNT,',',''),'$','')*1",
  ATTRIBUTE4               NULLIF ATTRIBUTE4 =BLANKS,
  ATTRIBUTE5               NULLIF ATTRIBUTE5 =BLANKS "substr(:ATTRIBUTE5, 1,256)",
  ATTRIBUTE6               NULLIF ATTRIBUTE6 =BLANKS,
  ATTRIBUTE7               NULLIF ATTRIBUTE7 =BLANKS,
  LINE_NUMBER              "DB_STMT_LINES_INTERFACE_S.NEXTVAL")

-- Dividend Reinvestment Sweep
INTO TABLE DB_STATEMENT_LINES_INTERFACE
WHEN TRX_CODE = 'Dividend Reinvestment' 
--AND BANK_ACCOUNT_NUM <> 'Portfolio Number'
AND AMOUNT <> '0.00'
AND AMOUNT <> '0'
FIELDS TERMINATED BY "," 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
( TRX_DATE                 POSITION(1) NULLIF TRX_DATE =BLANKS "to_date(to_char(to_date(:TRX_DATE,'DD/MM/YYYY'),'DD-MON-YYYY'))" ,
  BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM =BLANKS      ,
  ATTRIBUTE1               NULLIF ATTRIBUTE1 =BLANKS,
  ATTRIBUTE2               NULLIF ATTRIBUTE2 =BLANKS,
  ATTRIBUTE12              NULLIF ATTRIBUTE12 =BLANKS,
  ATTRIBUTE13              NULLIF ATTRIBUTE13 =BLANKS,
  ATTRIBUTE14              NULLIF ATTRIBUTE14 =BLANKS,
  TRX_CODE                 NULLIF TRX_CODE =BLANKS ":TRX_CODE||' Sweep'",
  TRX_TEXT                 NULLIF TRX_TEXT =BLANKS  "'Sweep to Deposit Acc-'||:TRX_TEXT",
  ATTRIBUTE3               NULLIF ATTRIBUTE3 =BLANKS,
  AMOUNT                   NULLIF AMOUNT =BLANKS "replace(replace(:AMOUNT,',',''),'$','')*-1",
  ATTRIBUTE4               NULLIF ATTRIBUTE4 =BLANKS,
  ATTRIBUTE5               NULLIF ATTRIBUTE5 =BLANKS "substr(:ATTRIBUTE5, 1,256)",
  ATTRIBUTE6               NULLIF ATTRIBUTE6 =BLANKS,
  ATTRIBUTE7               NULLIF ATTRIBUTE7 =BLANKS,
  LINE_NUMBER              "DB_STMT_LINES_INTERFACE_S.NEXTVAL")



