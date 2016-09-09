--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GETBASE64STRING
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GETBASE64STRING" (p_blob blob)
RETURN CLOB AS 


l_result CLOB;


begin

DBMS_LOB.createtemporary(lob_loc => l_result, CACHE => FALSE, dur => 0);

wf_mail_util.encodeblob ( p_blob, l_result);

  RETURN l_result;
END XX_GETBASE64STRING;
 

/
