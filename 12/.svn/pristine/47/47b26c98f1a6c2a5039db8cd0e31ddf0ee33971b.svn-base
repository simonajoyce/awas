--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XXAWAS_INTERNAL_BANK_NAMES
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XXAWAS_INTERNAL_BANK_NAMES" ("BANK_NAME") AS 
  SELECT DISTINCT B.BANK_NAME
  FROM CE_BANK_BRANCHES_V B,
       CE_BANK_ACCOUNTS A
  WHERE b.branch_party_id = a.bank_branch_id
  AND B.END_DATE         IS NULL
  AND A.END_DATE         IS NULL
  ORDER BY 1
  ;
