/* APPSQRY.VTRIALBALANCEALL View used by Essbase to import data. 
--  Now Excludes ABS Entities */ 
   CREATE OR REPLACE FORCE VIEW "APPSQRY"."VTRIALBALANCEALL" ("PERIOD_NAME", "SEGMENT1", "SEGMENT2", "SEGMENT3", "SEGMENT4",
       "SEGMENT5", "SEGMENT6", "SEGMENT7", "OPEN BAL", "DEBIT", "CREDIT", "NET MOVEMENT", "CLOSE BAL", "CURRENCY_CODE",
       "ACCOUNT_TYPE", "ASSET_CODE")
AS
        SELECT GB.PERIOD_NAME
            , GCC.SEGMENT1
            , GCC.SEGMENT2
            , GCC.SEGMENT3
            , GCC.SEGMENT4
            , GCC.SEGMENT5
            , GCC.SEGMENT6
            , GCC.SEGMENT7
            , NVL (GB.BEGIN_BALANCE_DR, 0) - NVL (GB.BEGIN_BALANCE_CR, 0) "OPEN BAL"
            , NVL (GB.PERIOD_NET_DR, 0) "DEBIT"
            , NVL (GB.PERIOD_NET_CR, 0) "CREDIT"
            , NVL (GB.PERIOD_NET_DR, 0)  - NVL (GB.PERIOD_NET_CR, 0) "NET MOVEMENT"
            , (NVL (GB.PERIOD_NET_DR, 0) + NVL (GB.BEGIN_BALANCE_DR, 0)) - (NVL ( GB.PERIOD_NET_CR, 0) + NVL (GB.BEGIN_BALANCE_CR,
              0)) "CLOSE BAL"
            , GB.CURRENCY_CODE
            , SUBSTR (a.compiled_value_attributes, 5, 1) ACCOUNT_TYPE
            , f.attribute1 ASSET_CODE
          FROM GL_BALANCES GB
            , GL_CODE_COMBINATIONS GCC
            , fnd_flex_values f
            , fnd_flex_values a
         WHERE GCC.CODE_COMBINATION_ID = GB.CODE_COMBINATION_ID
          AND GB.ACTUAL_FLAG           = 'A'
          AND GB.CURRENCY_CODE         = 'USD'
          AND GCC.SUMMARY_FLAG         = 'N'
          AND GB.LEDGER_ID             = 8 
          AND gcc.chart_of_accounts_id = 50230
          AND f.flex_value_set_id      = 1009476
          AND f.flex_value             = gcc.segment4
          AND A.FLEX_VALUE             = GCC.SEGMENT2
          AND A.FLEX_VALUE_SET_ID      = 1009492
          AND GCC.SEGMENT1 not between '3020' and '3040';