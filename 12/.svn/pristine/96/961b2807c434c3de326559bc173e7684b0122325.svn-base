CREATE OR REPLACE
PROCEDURE "APPS"."XX_SUBMIT_BURSTING"(
    p_request_id IN INTEGER)
AS
/*******************************************************************************
PROCEDURE NAME : XX_SUBMIT_BURSTING
CREATED BY   : Simon Joyce
DATE CREATED : 2013
--
PURPOSE      : Package called by Oracle Reports to submit bursting after report 
               created
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
01-07-2013 SJOYCE     Created
*******************************************************************************/
  n_request_id NUMBER;
BEGIN
  mo_global.set_policy_context('S', 85);
  n_request_id := fnd_request.submit_request('XDO' ,'XDOBURSTREP' ,NULL ,NULL ,FALSE ,'Y', p_request_id ,'N' );
END xx_submit_bursting;
/
