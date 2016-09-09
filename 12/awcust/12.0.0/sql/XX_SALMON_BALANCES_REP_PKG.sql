CREATE OR REPLACE package XX_SALMON_BALANCES_REP_PKG as
--Package used for Salmon Account Balances rep
p_run_date              date := null;

--
function before_report return boolean;
--
end XX_SALMON_BALANCES_REP_PKG;
/


CREATE OR REPLACE package body XX_SALMON_BALANCES_REP_PKG as
--------------------------------------------------------------------------------
-- before_report
--------------------------------------------------------------------------------
function before_report return boolean is
--
--
begin
   --
   FND_FILE.PUT_LINE(FND_FILE.LOG,'In before_report');
   --
   --
   fnd_file.put_line(fnd_file.log,'Finished before_report');
   return true;
   --
end before_report;
--
end XX_SALMON_BALANCES_REP_PKG;
/
