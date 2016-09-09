--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AR_PRORATA
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AR_PRORATA" 
(
  P_CUST_GL_DIST_ID IN NUMBER  
) RETURN NUMBER AS 

REC_TOT NUMBER;
REV_TOT NUMBER;
RETVAL NUMBER;

BEGIN

SELECT SUM(D2.ACCTD_AMOUNT) 
INTO REC_TOT
FROM  APPS.RA_CUST_TRX_LINE_GL_DIST_ALL D,
APPS.RA_CUST_TRX_LINE_GL_DIST_ALL D2
WHERE D2.ACCOUNT_CLASS = 'REC'
AND d2.CUSTOMER_TRX_ID = D.CUSTOMER_TRX_ID
AND D.CUST_TRX_LINE_GL_DIST_ID = P_CUST_GL_DIST_ID;

SELECT D.ACCTD_AMOUNT
INTO REV_TOT
FROM APPS.RA_CUST_TRX_LINE_GL_DIST_ALL D
WHERE D.CUST_TRX_LINE_GL_DIST_ID = P_CUST_GL_DIST_ID;

SELECT REV_TOT/REC_TOT
into retval from dual;



  RETURN RETVAL;
END XX_AR_PRORATA;
 

/
