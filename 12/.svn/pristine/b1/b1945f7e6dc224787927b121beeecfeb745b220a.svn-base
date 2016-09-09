CREATE OR REPLACE PACKAGE XX_AP_SUP_SITE_APRVL_REP_PKG AS
--Package used for Gift Register Report XML
p_run_date              date := null;

--
function before_report return boolean;
--
end XX_AP_SUP_SITE_APRVL_REP_PKG;
/


CREATE OR REPLACE package body XX_AP_SUP_SITE_APRVL_REP_PKG as
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
end XX_AP_SUP_SITE_APRVL_REP_PKG;
/
