--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_RECTIFY_NON_ASCII
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_RECTIFY_NON_ASCII" (INPUT_STR IN VARCHAR2)
RETURN VARCHAR2
IS
str VARCHAR2(2000);
act number :=0;
cnt number :=0;
askey number :=0;
OUTPUT_STR VARCHAR2(2000);
BEGIN
str:='^'||TO_CHAR(INPUT_STR)||'^';
cnt:=length(str);
for i in 1 .. cnt loop
askey :=0;
select ascii(substr(str,i,1)) into askey
from dual;
IF askey < 32 OR askey >=127 THEN
str :='^'||REPLACE(str, CHR(askey),'');
end if;
END loop;
OUTPUT_STR := trim(ltrim(rtrim(trim(str),'^'),'^'));
RETURN (OUTPUT_STR);
end;
 

/
