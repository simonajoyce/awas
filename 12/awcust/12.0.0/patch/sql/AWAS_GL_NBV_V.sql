CREATE OR REPLACE FORCE VIEW "APPS"."AWAS_GL_NBV_V" ("NBV_TYPE", "PERIOD_NAME", "MSN", "AMOUNT")
AS (
SELECT 'NBV DM' NBV_TYPE
                   , DECODE(SUBSTR(P.PERIOD_NAME,1,3),'ADJ','NOV-'
                     ||SUBSTR(p.period_name,5,2),p.period_name) period_name
                   , C.SEGMENT4 MSN
                   , SUM(( ( NVL(A.BEGIN_BALANCE_DR,0)+NVL(A.PERIOD_NET_DR,0) )-( NVL(A.BEGIN_BALANCE_CR,0)+NVL(A.PERIOD_NET_CR,0)
                     ) )) AMOUNT
                 FROM GL_BALANCES A
                   , GL_CODE_COMBINATIONS C
                   , GL_LEDGERS G
                   , --R12
                     GL_PERIODS P
                   , FND_FLEX_VALUES_TL FFVT
                   , FND_FLEX_VALUES FFV
                WHERE C.SEGMENT2 IN ('151405','151410','151105','151115','151135','151305','152005','151110','151120','151140',
                     '151150','151310','152010','172115','172105','172110','172120','183005','172062','172063','242001','242006','242003','242002')
                 AND G.LEDGER_ID            = 8 --R12
                 AND P.PERIOD_SET_NAME      = G.PERIOD_SET_NAME
                 AND A.ACTUAL_FLAG          = 'A'
                 AND A.CURRENCY_CODE        = G.CURRENCY_CODE
                 AND G.LEDGER_ID            = A.LEDGER_ID --R12
                 AND A.LEDGER_ID            = 8           --R12
                 AND A.PERIOD_NAME          = P.PERIOD_NAME
                 AND G.CHART_OF_ACCOUNTS_ID = C.CHART_OF_ACCOUNTS_ID
                 AND A.CODE_COMBINATION_ID  = C.CODE_COMBINATION_ID
                 AND A.ACTUAL_FLAG          = 'A'
                 AND C.SEGMENT1            <> 'T'
                 AND FFV.FLEX_VALUE_SET_ID  = 1009492
                 AND FFVT.FLEX_VALUE_ID     = FFV.FLEX_VALUE_ID
                 AND FFV.FLEX_VALUE         = C.SEGMENT2
                 AND P.period_name          =
                     (
                             SELECT period_name
                               FROM fa_deprn_periods
                              WHERE book_type_code    = 'IFRS'
                               AND period_close_date IS NOT NULL
                               AND period_close_date  =
                                   (
                                           SELECT MAX(period_close_date)
                                             FROM fa_deprn_periods
                                            WHERE book_type_code    = 'IFRS'
                                             AND period_close_date IS NOT NULL
                                   )
                     )
             GROUP BY P.PERIOD_NAME
                   , C.SEGMENT4
              HAVING
                     (
                            (
                                   ABS(( SUM(( ( NVL(A.BEGIN_BALANCE_DR,0)+NVL(A.PERIOD_NET_DR,0) )-( NVL(A.BEGIN_BALANCE_CR,0)+NVL
                                   (A.PERIOD_NET_CR,0) ) )) ))            +ABS(( SUM(( NVL(A.PERIOD_NET_DR,0)-NVL(A.PERIOD_NET_CR,0
                                   ) )) ))                                +ABS(( SUM(( NVL(A.BEGIN_BALANCE_DR,0)-NVL(
                                   A.BEGIN_BALANCE_CR,0) )) ))
                            )
                            > 0
                     )
            UNION ALL
               SELECT 'NBV HC'
                   , DECODE(SUBSTR(P.PERIOD_NAME,1,3),'ADJ','NOV-'
                     ||SUBSTR(p.period_name,5,2),p.period_name) period_name
                   , C.SEGMENT4 MSN
                   , SUM(( ( NVL(A.BEGIN_BALANCE_DR,0)+NVL(A.PERIOD_NET_DR,0) )-( NVL(A.BEGIN_BALANCE_CR,0)+NVL(A.PERIOD_NET_CR,0)
                     ) )) AMOUNT
                 FROM GL_BALANCES A
                   , GL_CODE_COMBINATIONS C
                   , GL_LEDGERS G
                   , --R12
                     GL_PERIODS P
                   , FND_FLEX_VALUES_TL FFVT
                   , FND_FLEX_VALUES FFV
                WHERE C.SEGMENT2 IN ('151405','151410','151105','151115','151135','151305','152005','151110','151120','151140',
                     '151150','151310','152010')
                 AND G.LEDGER_ID            = 8 --R12
                 AND P.PERIOD_SET_NAME      = G.PERIOD_SET_NAME
                 AND A.ACTUAL_FLAG          = 'A'
                 AND A.CURRENCY_CODE        = G.CURRENCY_CODE
                 AND G.LEDGER_ID            = A.LEDGER_ID --R12
                 AND A.LEDGER_ID            = 8           --R12
                 AND A.PERIOD_NAME          = P.PERIOD_NAME
                 AND G.CHART_OF_ACCOUNTS_ID = C.CHART_OF_ACCOUNTS_ID
                 AND A.CODE_COMBINATION_ID  = C.CODE_COMBINATION_ID
                 AND A.ACTUAL_FLAG          = 'A'
                 AND C.SEGMENT1            <> 'T'
                 AND FFV.FLEX_VALUE_SET_ID  = 1009492
                 AND FFVT.FLEX_VALUE_ID     = FFV.FLEX_VALUE_ID
                 AND FFV.FLEX_VALUE         = C.SEGMENT2
                 AND P.period_name          =
                     (
                             SELECT period_name
                               FROM fa_deprn_periods
                              WHERE book_type_code    = 'IFRS'
                               AND period_close_date IS NOT NULL
                               AND period_close_date  =
                                   (
                                           SELECT MAX(period_close_date)
                                             FROM fa_deprn_periods
                                            WHERE book_type_code    = 'IFRS'
                                             AND period_close_date IS NOT NULL
                                   )
                     )
             GROUP BY P.PERIOD_NAME
                   , C.SEGMENT4
              HAVING
                     (
                            (
                                   ABS(( SUM(( ( NVL(A.BEGIN_BALANCE_DR,0)+NVL(A.PERIOD_NET_DR,0) )-( NVL(A.BEGIN_BALANCE_CR,0)+NVL
                                   (A.PERIOD_NET_CR,0) ) )) ))            +ABS(( SUM(( NVL(A.PERIOD_NET_DR,0)-NVL(A.PERIOD_NET_CR,0
                                   ) )) ))                                +ABS(( SUM(( NVL(A.BEGIN_BALANCE_DR,0)-NVL(
                                   A.BEGIN_BALANCE_CR,0) )) ))
                            )
                            > 0
                     )
       )
       ;
