CREATE OR REPLACE PACKAGE XX_AR_TRX_BY_PERIOD_PKG AS
/*******************************************************************************
PACKAGE NAME : XX_AR_TRX_BY_PERIOD_PKG
CREATED BY   : Simon Joyce
DATE CREATED : 26-May-2014
--
PURPOSE      : Package to support AR Transactions by Period Report
               
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
26-05-2014 SJOYCE     Initial Version
*******************************************************************************/

--Report Parameters
p_period            gl_periods.period_name%type;

function before_report return boolean;

end XX_AR_TRX_BY_PERIOD_PKG;
/


CREATE OR REPLACE package body XX_AR_TRX_BY_PERIOD_PKG as
/*------------------------------------------------------------------------------
FUNCTION     : before_report
CREATED BY   : Simon Joyce
DATE CREATED : 3-Mar-2014
--
PURPOSE      : This function is called before report has been generated and
               is used to update where clause variable
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
04-03-2014 SJOYCE     Initial Version
------------------------------------------------------------------------------*/
function before_report return boolean is


begin
  
  return true;
   
end before_report;

end XX_AR_TRX_BY_PERIOD_PKG;
/
