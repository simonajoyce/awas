CREATE OR REPLACE PACKAGE XXAP_SERENGETI_IF_REP_PKG AS
/*******************************************************************************
PACKAGE NAME : XXAP_SERENGETI_IF_REP_PKG
CREATED BY   : Simon Joyce
DATE CREATED : 16-Aug-2016
--
PURPOSE      : Package to support AWAS Serengeti Interface Report
               
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
16-08-2016 SJOYCE     Initial Version
*******************************************************************************/

--Report Parameters
p_request_id        number;


function email_report return boolean;

end XXAP_SERENGETI_IF_REP_PKG;
/


CREATE OR REPLACE package body XXAP_SERENGETI_IF_REP_PKG as

/*------------------------------------------------------------------------------
FUNCTION     : email_report
CREATED BY   : Simon Joyce
DATE CREATED : 16-Aug-2016
--
PURPOSE      : This function is called after the report has been generated and
               is used to email the report to the user who submitted it
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
16-08-2016 SJOYCE     Initial Version
------------------------------------------------------------------------------*/
function email_report return boolean is
   l_result        BOOLEAN;
   l_req_id        NUMBER;
   
begin
   mo_global.set_policy_context('S', 85);
    
  l_req_id := fnd_request.submit_request('XDO' 
                                            ,'XDOBURSTREP' 
                                            ,NULL 
                                            ,NULL 
                                            ,FALSE 
                                            ,'Y' 
                                            ,fnd_global.conc_request_id--p_request_id 
                                            ,'N' ); 
                                            
    IF l_req_id != 0 THEN
    fnd_file.put_line(fnd_file.LOG, 'Bursting request successful');
    -- request submitted successfully return true
      l_result := TRUE;
   ELSE
   -- Put message in log
     fnd_file.put_line(fnd_file.LOG, 'Failed to launch bursting request');
 
     -- Return false to trigger error result
     l_result := FALSE;
   END IF;
   
   RETURN l_result;
   
end email_report;

end XXAP_SERENGETI_IF_REP_PKG;
/
