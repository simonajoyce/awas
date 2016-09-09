--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_PA_PROJECT_PARTIES_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_PA_PROJECT_PARTIES_V" ("RESOURCE_PARTY_ID", "RESOURCE_SOURCE_NAME") AS 
  SELECT DISTINCT
    resource_party_id,
    resource_source_name
  FROM
    pa_project_parties_v
  where
    party_type <> 'ORGANIZATION'
 ;
