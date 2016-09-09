--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_ROLE_APPROVERS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_ROLE_APPROVERS" ("ROLE_NAME", "ROLE_ID", "ROLE_APPROVER", "DATA_OWNER") AS 
  SELECT v.lookup_code role_name,
    v.attribute1 role_id,
    P.Full_Name Role_Approver,
    p2.full_name Data_Owner
  FROM fnd_lookup_values v,
    Per_All_People_F P,
    per_all_people_f p2
  WHERE lookup_type = 'AWAS_APPLICATION_APPROVERS'
  And P.Person_Id   = V.Attribute2
  AND p2.person_id   = v.attribute3
 ;
