--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GET_PART
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GET_PART" (req_line_id NUMBER) RETURN VARCHAR2 AS
--  This function get the part number entereed as a note on the requisition line
x VARCHAR2(32000);
y VARCHAR2(80);

CURSOR c1 IS
SELECT t.long_text
FROM FND_ATTACHED_DOCUMENTS ad,
fnd_documents_tl d,
fnd_documents_long_text t
WHERE ad.entity_name LIKE 'REQ_LINES'
AND ad.pk2_value = 'INFO_TEMPLATE'
and ad.pk1_value = req_line_id
AND d.document_id = ad.document_id
AND d.description = 'New Part'
AND t.media_id = d.media_id;

BEGIN

OPEN c1;

loop
fetch c1 INTO x;
exit WHEN c1%notfound;

Y:= substr(TRIM(REPLACE(X,'Part Number=','')),1,25);



END loop;
CLOSE c1;

return y;
end xx_get_part;
 

/
