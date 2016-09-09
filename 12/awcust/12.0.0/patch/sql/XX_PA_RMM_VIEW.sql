--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_PA_RMM_VIEW
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_PA_RMM_VIEW" ("CI_ID", "CI_TYPE_ID", "SUMMARY", "STATUS_CODE", "OWNER_ID", "PROGRESS_STATUS_CODE", "PROGRESS_AS_OF_DATE", "CLASSIFICATION_CODE_ID", "REASON_CODE_ID", "RECORD_VERSION_NUMBER", "PROJECT_ID", "OBJECT_TYPE", "OBJECT_ID", "CI_NUMBER", "DATE_REQUIRED", "DESCRIPTION", "STATUS_OVERVIEW", "RESOLUTION", "RESOLUTION_CODE_ID", "PRIORITY_CODE", "EFFORT_LEVEL_CODE", "PROJECT_NAME", "PROJECT_NUMBER", "ATTRIBUTE1", "ATTRIBUTE2", "ATTRIBUTE3", "ATTRIBUTE4", "ATTRIBUTE5", "ATTRIBUTE6", "ATTRIBUTE7", "ATTRIBUTE8", "ATTRIBUTE9", "SOURCE_TYPE_CODE", "SOURCE_COMMENT", "SOURCE_NUMBER", "SOURCE_DATE_RECEIVED", "SOURCE_ORGANIZATION", "SOURCE_PERSON") AS 
  SELECT
  i.ci_id,
  ( SELECT
      name
    FROM
      pa_ci_types_tl
    WHERE
      ci_type_id = i.ci_type_id
  )
  ci_type_id,
  i.summary,
  (
    SELECT
      Meaning
    FROM
      pa_lookups
    WHERE
      lookup_type   = 'CONTROL_ITEM_SYSTEM_STATUS'
    AND lookup_code = i.status_code
  )
  status_code,
  (
    SELECT
      resource_source_name
    FROM
      pa_project_parties_v x
    WHERE
      party_type         <> 'ORGANIZATION'
    and resource_party_id = i.owner_id
    AND project_id        = p.Project_id
  )
  owner_id,
  (
    SELECT
      Meaning
    FROM
      pa_lookups
    WHERE
      lookup_type   = 'PROGRESS_SYSTEM_STATUS'
    AND lookup_code = i.progress_status_code
  )
  progress_status_code,
  i.progress_as_of_date,
  (
    SELECT
      class_code
    FROM
      pa_class_codes
    WHERE
      class_code_id = i.classification_code_id
  )
  classification_code_id,
  (
    SELECT
      class_code
    FROM
      pa_class_codes
    WHERE
      class_code_id = i.reason_code_id
  )
  reason_code_id,
  i.record_version_number,
  i.project_id,
  i.object_type,
  i.object_id,
  i.ci_number,
  i.date_required,
  i.description,
  i.status_overview,
  i.resolution,
  (
    SELECT
      class_code
    FROM
      pa_class_codes
    WHERE
      class_code_id = i.resolution_code_id
  )
  resolution_code_id,
  (
    SELECT
      meaning
    FROM
      pa_lookups
    WHERE
      lookup_Type   = 'PA_PROJECT_PRIORITY_CODE'
    AND lookup_code = i.priority_code
  )
  priority_code,
  (
    SELECT
      meaning
    FROM
      pa_lookups
    WHERE
      lookup_Type   = 'PA_CI_EFFORT_LEVELS'
    AND lookup_code = i.effort_level_code
  )
  effort_level_code,
  p.name project_name,
  p.segment1 project_number,
  i.attribute1,
  i.attribute2,
  i.attribute3,
  i.attribute4,
  i.attribute5,
  i.attribute6,
  i.attribute7,
  i.attribute8,
  i.attribute9,
  i.source_type_code,
  i.source_comment,
  i.source_number,
  i.source_date_received,
  i.source_organization,
  i.source_person
FROM
  pa_control_items i,
  pa_projects_all p
WHERE  i.project_id    = p.project_id
--AND i.project_id  = $param$.Project_Name
AND i.ci_type_id  = 10180
and i.status_code = upper('ci_working')
UNION ALL
SELECT
  NULL,
  (
    SELECT
      name
    FROM
      pa_ci_types_tl
    WHERE
      ci_type_id = 10180
  )
  ,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  p.project_id,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  p.name,
  p.segment1,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  null,
  null,
  NULL,
  NULL,
  NULL,
  null,
  null
FROM
  pa_projects_all p
--where
 -- project_id = $param$.Project_Name
ORDER BY
  8,9,1
 ;
