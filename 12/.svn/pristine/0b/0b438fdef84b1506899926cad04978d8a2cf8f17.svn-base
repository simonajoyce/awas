--|==========================================================================|
--| Name:         WTBAL.ctl					             | 
--| Description:  This file Contains contol file mapping to read the Wilmington 
--|               Trust account balances
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
INTO TABLE XX_WT_BANK_BAL_IF
FIELDS TERMINATED BY "|" 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
( BANK_ACCOUNT_NUM         NULLIF BANK_ACCOUNT_NUM  =BLANKS,
  PORTFOLIO                NULLIF PORTFOLIO         =BLANKS,
  BALANCE_TYPE             NULLIF BALANCE_TYPE      =BLANKS,
  BALANCE_CAT              NULLIF BALANCE_CAT       =BLANKS,
  BALANCE_AMT              NULLIF BALANCE_AMT       =BLANKS,
  BLANK1                   NULLIF BLANK1            =BLANKS,
  BALANCE_PC               NULLIF BALANCE_PC        =BLANKS,
  BALANCE_AMT2             NULLIF BALANCE_AMT2      =BLANKS,
  BLANK2                   NULLIF BLANK2            =BLANKS,
  BALANCE2_PC              NULLIF BALANCE2_PC       =BLANKS
  )


