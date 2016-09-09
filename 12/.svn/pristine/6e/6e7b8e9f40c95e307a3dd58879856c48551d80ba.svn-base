CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_INTERNAL_BANK_NAMES" ("BANK_NAME")
AS
/*******************************************************************************
VIEW NAME : XXAWAS_INTERNAL_BANK_NAMES
CREATED BY   : Simon Joyce
DATE CREATED : 2010
--
PURPOSE      : view shows only bank branches that are being used
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
20-02-2010 SJOYCE     First Version
25-07-2013 SJOYCE     R12 Version
*******************************************************************************/
  SELECT DISTINCT B.BANK_NAME
  FROM CE_BANK_BRANCHES_V B,
       CE_BANK_ACCOUNTS A
  WHERE b.branch_party_id = a.bank_branch_id
  AND B.END_DATE         IS NULL
  AND A.END_DATE         IS NULL
  ORDER BY 1
  ; 
  /