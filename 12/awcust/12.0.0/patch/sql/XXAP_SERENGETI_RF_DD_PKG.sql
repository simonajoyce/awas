CREATE OR REPLACE PACKAGE XXAP_SERENGETI_RF_DD_PKG AS
/*******************************************************************************
PACKAGE NAME : XXAP_SERENGETI_RF_DD_PKG
CREATED BY   : Simon Joyce
DATE CREATED : 20-Jun-2016
--
PURPOSE      : Support Serengeti Reverse Feed Report
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
20-06-2016 SJOYCE     Initial Version
*******************************************************************************/

--Report Parameters


function email_report return boolean;


end XXAP_SERENGETI_RF_DD_PKG;
/


CREATE OR REPLACE PACKAGE BODY XXAP_SERENGETI_RF_DD_PKG AS

  /*------------------------------------------------------------------------------
FUNCTION     : email_report
CREATED BY   : Simon Joyce
DATE CREATED : 3-Mar-2014
--
PURPOSE      : This function is called after the report has been generated and
               is used to email the report to the user who submitted it
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
04-03-2014 SJOYCE     Initial Version
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

END XXAP_SERENGETI_RF_DD_PKG;
/
