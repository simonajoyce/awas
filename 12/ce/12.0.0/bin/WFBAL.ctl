--|==========================================================================|
--| Name:         WFBAL.ctl					             | 
--| Description:  This file Contains contol file mapping to read the Wells   | 
--|               Fargo account balances                                     |
--|		  							     |
--|									     |
--|									     |
--| Change Record:							     |
--| =============						  	     |
--| Version	Date	   	Author		   Remarks		     |
--| =======     ===========	=================  ========================= |	
--|  								             |
--|									     |
--|									     |
--|									     |
--+==========================================================================+
-- Header First
LOAD DATA
REPLACE
INTO TABLE XX_WF_BANK_BAL_IF
WHEN ACCOUNT_NUM <> 'Account ID'
FIELDS TERMINATED BY "," 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
( ACCOUNT_NUM              NULLIF ACCOUNT_NUM  =BLANKS,
  ACCOUNT_DESC             NULLIF ACCOUNT_DESC      =BLANKS,
  AMOUNT                   INTEGER EXTERNAL TERMINATED BY WHITESPACE NULLIF AMOUNT	    =BLANKS
  )


