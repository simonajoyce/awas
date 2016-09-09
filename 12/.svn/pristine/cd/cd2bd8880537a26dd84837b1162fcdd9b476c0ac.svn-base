CREATE OR REPLACE PACKAGE XX_CE_SKYFIN_DET_STMT_PKG AS

/********************************************************************************
  PACKAGE NAME  : XX_CE_SKYFIN_DET_STMT_PKG
  CREATED BY    : Simon Joyce
  DATE CREATED  : 23-Jun-2015
  --
  PURPOSE       : Format Paramteres for AWAS Skyfin Detailed Bank Stmt Report
  --
  MODIFICATION HISTORY
  --------------------
  --
  DATE       WHO?       DETAILS                              DESCRIPTION
  ---------- ---------  -----------------------------------  -----------------------
  23-Jun-2015 SJOYCE     First Version
  ********************************************************************************/
p_stmt_date              date := null;

--
function before_report return boolean;
--
end XX_CE_SKYFIN_DET_STMT_PKG;
/


CREATE OR REPLACE package body XX_CE_SKYFIN_DET_STMT_PKG as
/********************************************************************************
  PACKAGE NAME  : XX_CE_SKYFIN_DET_STMT_PKG
  CREATED BY    : Simon Joyce
  DATE CREATED  : 23-Jun-2015
  --
  PURPOSE       : Format Paramteres for AWAS Skyfin Detailed Bank Stmt Report
  --
  MODIFICATION HISTORY
  --------------------
  --
  DATE       WHO?       DETAILS                              DESCRIPTION
  ---------- ---------  -----------------------------------  --------------------
  23-Jun-2015 SJOYCE     First Version
  *******************************************************************************/
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
end XX_CE_SKYFIN_DET_STMT_PKG;
/
