--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_FA_RETIREMENT_DATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_FA_RETIREMENT_DATE" 
(
  P_ASSET_ID IN NUMBER  
, p_BOOK_TYPE_CODE IN VARCHAR2  
) RETURN DATE AS 

R_DATE DATE;

BEGIN

SELECT MAX(DATE_retired)
into r_date
FROM FA_RETIREMENTS
WHERE ASSET_ID = P_ASSET_ID
AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;



  RETURN r_date;
END XX_FA_RETIREMENT_DATE;
 

/
