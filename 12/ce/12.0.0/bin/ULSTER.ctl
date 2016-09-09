-- Ulster bank Statement import control file.
-- Developed by Simon joyce 26/11/12
-- added Optionally Enclosed By clause  26/05/2014

LOAD DATA
REPLACE
INTO TABLE XX_ULSTER_STMT_LINES_INT
WHEN BANK_ACCOUNT_NUM <> 'Account Number'
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(  SORT_CODE			      NULLIF SORT_CODE=BLANKS,
   BANK_ACCOUNT_NUM	             NULLIF BANK_ACCOUNT_NUM=BLANKS,
   ATTRIBUTE1                     NULLIF ATTRIBUTE1=BLANKS, -- Account Alias
   ATTRIBUTE2                     NULLIF ATTRIBUTE2=BLANKS, -- Account Short Name
   CURRENCY_CODE                  NULLIF CURRENCY_CODE=BLANKS,
   TRX_DATE         		      NULLIF TRX_DATE=BLANKS "to_date(:TRX_DATE,'DD/MM/RR')",
   TRX_TEXT                       NULLIF TRX_TEXT=BLANKS,
   ATTRIBUTE3                     NULLIF ATTRIBUTE3=BLANKS, -- Narrative2
   ATTRIBUTE4                     NULLIF ATTRIBUTE4=BLANKS, -- Narrative3
   ATTRIBUTE5                     NULLIF ATTRIBUTE5=BLANKS, -- Narrative4
   ATTRIBUTE6                     NULLIF ATTRIBUTE6=BLANKS, -- Narrative5
   ATTRIBUTE7                     NULLIF ATTRIBUTE7=BLANKS, -- TRX Type
   BANK_TRX_NUMBER		      NULLIF BANK_TRX_NUMBER=BLANKS, 
   VALUE_DATE         	      NULLIF VALUE_DATE=BLANKS "to_date(:VALUE_DATE,'DD/MM/RR')",
   AMOUNT			      INTEGER EXTERNAL TERMINATED BY WHITESPACE ":amount * 1"
   )
   

