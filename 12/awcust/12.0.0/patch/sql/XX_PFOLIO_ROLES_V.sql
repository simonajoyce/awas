--------------------------------------------------------
--  File created - Wednesday-September-23-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_PFOLIO_ROLES_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_PFOLIO_ROLES_V" ("DISPLAY_NAME", "DESCRIPTION", "SYSROLE_ID") AS 
  SELECT t.display_name
            , t.description
            
          , xx_get_sysrole_id(b.reg_service_code) sysrole_id
          FROM UMX_REG_SERVICES_b b
            , umx_reg_services_tl t
         WHERE b.reg_service_code LIKE 'UMX|%'
          AND b.reg_service_code NOT LIKE 'UMX|%X%X%'
          AND b.reg_service_type = 'ADDITIONAL_ACCESS'
          AND T.REG_SERVICE_CODE = B.REG_SERVICE_CODE;
