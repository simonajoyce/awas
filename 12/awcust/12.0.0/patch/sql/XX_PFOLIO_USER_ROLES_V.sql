--------------------------------------------------------
--  File created - Wednesday-September-23-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_PFOLIO_USER_ROLES_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_PFOLIO_USER_ROLES_V" ("USER_NAME", "STATUS_CODE", "START_DATE", "END_DATE", "ROLE_NAME", "ROLE_DESCRIPTION", "JUSTIFICATION", "ROLE_CODE", "SYSROLE_ID", "IN_PFOLIO") AS 
  SELECT u.user_name USER_NAME
            , status_code STATUS_CODE
            , requested_start_date START_DATE
            , requested_end_date END_DATE
            , w.display_name ROLE_NAME
            , w.description ROLE_DESCRIPTION
            , justification JUSTIFICATION
            , w.name ROLE_CODE
            
              , XX_GET_SYSROLE_ID (w.name) SYSROLE_ID
            , DECODE((SELECT sysrole_id FROM tbluserrole@basin b WHERE x.external_person_id = b.person_id
                        AND DECODE(SUBSTR(w.name,1,3),'UMX',DECODE(instr( w.name,'X',4),0,-1,SUBSTR(w.name,instr(w.name,'X',4)+1,
                            LENGTH(w.name)                                                -instr(w.name,'X',4))),-1) = b.sysrole_id
              )
              ,NULL,'N','Y') IN_PFOLIO
          FROM umx_reg_requests r
            , fnd_user u
            , wf_roles w
            , xx_employee_details x
         WHERE u.user_id     = r.requested_for_user_id
          AND r.wf_role_name = w.name
          AND x.user_id      = u.user_id
          AND r.wf_role_name NOT LIKE 'UMX|%X%X%'
          AND r.wf_role_name LIKE 'UMX|%'
          AND r.wf_role_name NOT IN ( 'UMX|UMX_EXT_ADMIN', 'UMX|UMX_PARTNER_ADMIN','UMX|AME_APP_ADMIN','UMX|SECURITY_ADMIN')
          and w.display_name <> 'ODIN - Request Admin Roles'
          
          
      ORDER BY w.display_name;
