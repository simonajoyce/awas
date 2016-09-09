--------------------------------------------------------
--  File created - Tuesday-August-25-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Materialized View XX_DWH_GL_REV_BAL_MV
--------------------------------------------------------

  CREATE MATERIALIZED VIEW "APPS"."XX_DWH_GL_REV_BAL_MV" ("PERIOD_NAME", "PERIOD_YEAR", "PERIOD_NUM", "MSN", "CLOSING_STATUS", "PTD", "QTD", "YTD", "PJTD")
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "APPS_TS_TX_DATA" 
  BUILD IMMEDIATE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "APPS_TS_TX_DATA" 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
  AS select b.period_name,  
b.period_year,  
b.period_num,  
c.segment4 MSN, 
s.closing_status, 
sum(b.period_net_dr - b.period_net_cr) PTD,  
sum((b.quarter_to_date_dr - b.quarter_to_date_cr)+(b.period_net_dr - b.period_net_cr)) QTD,   
sum((b.begin_balance_dr + b.period_net_dr) - (b.begin_balance_cr + b.period_net_cr)) YTD, 
sum(b.project_to_date_dr - b.project_to_date_cr) PJTD 
from gl_balances b, 
gl_code_combinations c, 
gl_period_statuses s 
where c.code_combination_id = b.code_combination_id 
and b.ledger_id = 8 
and b.currency_code = 'USD' 
and b.actual_flag = 'A' 
and c.segment2 = '421005' 
and b.period_num <> 13 
and s.application_id = 101 
and c.summary_flag = 'N'
and decode(c.summary_flag,'Y',decode(c.segment4,'T','N','Y'),'N') = 'N'
and s.set_of_books_id = 8 
and s.period_name = b.period_name 
group by  b.period_name,  
b.period_year,  
b.period_num,  
c.segment4, 
s.closing_status;

  CREATE UNIQUE INDEX "APPS"."I_SNAP$_XX_DWH_GL_REV_BAL_" ON "APPS"."XX_DWH_GL_REV_BAL_MV" (SYS_OP_MAP_NONNULL("PERIOD_NAME"), SYS_OP_MAP_NONNULL("PERIOD_YEAR"), SYS_OP_MAP_NONNULL("PERIOD_NUM"), SYS_OP_MAP_NONNULL("MSN"), SYS_OP_MAP_NONNULL("CLOSING_STATUS")) 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "APPS_TS_TX_DATA" ;

   COMMENT ON MATERIALIZED VIEW "APPS"."XX_DWH_GL_REV_BAL_MV"  IS 'snapshot table for snapshot APPS.XX_DWH_GL_REV_BAL_MV';
