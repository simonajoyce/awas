--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AGING_BUCKET_VAL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AGING_BUCKET_VAL" (
      DAYS IN NUMBER
      ,
      AMT IN NUMBER
      ,
      BUCKET IN NUMBER
    )
    RETURN NUMBER
  AS
    /*
    REM +==================================================================+
    REM |                Copyright (c) 2013 Version 1
    REM +==================================================================+
    REM |  Name
    REM |    Function xx_aging_bucket_val
    REM |
    REM |  Description
    REM |   Function to AMT for specified bucket, reduces complexitiy in AR
    REM |   reports
    REM |
    REM |  History
    REM |    08-Jul-13   SJOYCE     CREATED
    REM |
    REM +==================================================================+
    */
    X NUMBER;
  BEGIN
    IF BUCKET = 1 THEN
      IF DAYS BETWEEN -9999 AND 30 THEN
        X := AMT;
      ELSE
        x := 0;
      END IF;
    END IF;
    IF BUCKET = 2 THEN
      IF DAYS BETWEEN 31 AND 60 THEN
        X := AMT;
      ELSE
        x:=0;
      END IF;
    END IF;
    IF BUCKET = 3 THEN
      IF DAYS BETWEEN 61 AND 90 THEN
        X := AMT;
      ELSE
        X:=0;
      END IF;
    END IF;
    IF BUCKET = 4 THEN
      IF DAYS > 90 THEN
        X    := AMT;
      ELSE
        X:=0;
      END IF;
    END IF;
    RETURN X;
  END XX_AGING_BUCKET_VAL;

/
