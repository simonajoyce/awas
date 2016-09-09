CREATE OR REPLACE package XX_AR_RISK_DAILY_REP_PKG
as
  /********************************************************************************
  PACKAGE NAME  : XX_AR_RISK_DAILY_REP_PKG
  CREATED BY    : Simon Joyce
  DATE CREATED  : 04-Mar-2016
  --
  PURPOSE       : Declare parameters and fucntions for AR Daily Risk Report
  --
  MODIFICATION HISTORY
  --------------------
  --
  DATE       WHO?       DETAILS                              DESCRIPTION
  ---------- ---------  -----------------------------------  -----------------------
  04-Mar-16  SJOYCE     First Version
  ********************************************************************************/

p_date               date   := null;
p_days_back          number ;
p_days_back2          number ;
p_miss_date          date   := null;
p_miss_date2          date   := null;
p_request_id         number := fnd_global.conc_request_id;

function before_report return boolean;

end XX_AR_RISK_DAILY_REP_PKG;
/


CREATE OR REPLACE package body XX_AR_RISK_DAILY_REP_PKG
as
  /********************************************************************************
  PACKAGE NAME  : XX_AR_RISK_DAILY_REP_PKG
  CREATED BY    : Simon Joyce
  DATE CREATED  : 04-Mar-2015
  --
  PURPOSE       : Declare parameters and fucntions for XX_AR_RISK_DAILY_REP
  --
  MODIFICATION HISTORY
  --------------------
  --
  DATE       WHO?       DETAILS                              DESCRIPTION
  ---------- ---------  -----------------------------------  -----------------------
  04-Mar-15  SJOYCE     First Version
  ********************************************************************************/

function before_report return boolean is
-- Creates Temporary data for report
--
x varchar(1);

begin
   -- check for Monday and roll back date to Friday
   select to_char(P_DATE,'d')
   into x 
   from dual;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'x='||x);
    FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(P_DATE,'d'));
    
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_days_back='||p_days_back);
   
   P_DAYS_BACK2 := p_days_back;
   
   
   
   
   if p_days_back = 1 then
   
                     
   if x = 7 
   then
   P_MISS_DATE := P_DATE - 2;
   P_DAYS_BACK2 := 2;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting P_MISS_DATE = P_DATE -2');
   
   else 
   P_MISS_DATE := P_DATE;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting P_MISS_DATE = P_DATE');
   end if;
   
   else
   P_MISS_DATE := p_date - p_days_back;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting P_MISS_DATE = P_DATE - p_days_back');
   end if;

   --
   FND_FILE.PUT_LINE(FND_FILE.LOG,'In before_report');
   dbms_output.put_line('In before_report');
   -- delete data from tmp table
   
   delete XX_AR_DEBTORS_TEMP
   where run_date = P_MISS_DATE;
   
   dbms_output.put_line('xx_dwh_ar_trx_temp old rows deleted');
   
   FND_FILE.PUT_LINE(FND_FILE.LOG,'xx_dwh_ar_trx_temp truncated');
    dbms_output.put_line('Setting RUN_DATE = '||P_MISS_DATE);
   -- populate tmp table
     
   insert into xx_ar_debtors_temp 
   select * from xx_ar_debtors_temp_v where due_date <= P_MISS_DATE;
   
   update xx_ar_debtors_temp
   set    RUN_DATE = P_MISS_DATE,
          REQUEST_ID = P_REQUEST_ID
   where REQUEST_ID = -1;
   
   FND_FILE.PUT_LINE(FND_FILE.LOG,'xx_ar_debtors_temp populated with '||SQL%rowcount||' records.');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting RUN_DATE = '||P_MISS_DATE);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Original RUN_DATE = '||P_DATE);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting REQUEST_ID = '||P_REQUEST_ID);
   dbms_output.put_line('xx_ar_debtors_temp populated with '||SQL%rowcount||' records.');
   dbms_output.put_line('Setting RUN_DATE = '||P_MISS_DATE);
   dbms_output.put_line('Original RUN_DATE = '||P_DATE);
   dbms_output.put_line('Setting REQUEST_ID = '||P_REQUEST_ID);
   
   
         P_DATE := P_MISS_DATE;
   --
   if x = 1 then
   p_miss_date2 := to_date(p_miss_date) - 2;
   else
   p_miss_date2 := p_miss_date;
   end if;
     
   fnd_file.put_line(fnd_file.log,'Finished before_report');
   return true;
   --
  exception when others then
  
   return false;
end before_report;

end XX_AR_RISK_DAILY_REP_PKG;
/
