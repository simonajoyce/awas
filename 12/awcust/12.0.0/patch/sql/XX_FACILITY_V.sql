--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_FACILITY_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_FACILITY_V" ("SORT_ORD", "FLEX_VALUE", "DESCRIPTION") AS 
  (
    SELECT
      2 sort_ord,
      flex_value,
      t.description
    FROM
      fnd_flex_values v,
      fnd_flex_values_tl t
    WHERE
      flex_value LIKE 'Z%'
    AND v.flex_value_set_id = 1009475
    AND t.flex_value_id     = v.flex_value_id
    UNION
    SELECT
      1,
      'NONE',
      'Not attached to a facility'
    FROM
      dual
  )
 ;
