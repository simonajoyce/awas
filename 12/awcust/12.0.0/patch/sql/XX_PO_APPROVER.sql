--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PO_APPROVER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PO_APPROVER" (P_PO_ID NUMBER) RETURN VARCHAR2 AS 


CURSOR c1 IS 
SELECT Action_code,  Action_date, pap.last_name, action_date - pah.creation_Date time_to_approve
FROM po_action_history pah,
per_all_people_f pap
WHERE pah.object_type_code = 'PO'
AND pah.object_sub_type_code = 'STANDARD'
AND pah.object_id = p_po_id
AND pah.employee_id = pap.person_id
order by pah.sequence_num;

retval VARCHAR2(4000);


BEGIN

retval := NULL;

FOR r1 IN c1
loop
retval := retval||r1.action_code||' '||r1.action_date||' '||r1.last_Name||' TT:'||round(r1.time_to_approve,2)*24||chr(13);
END loop;


  RETURN retval;
END XX_PO_APPROVER;
 

/
