--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_AWAS_GL_ENT_HIER
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_AWAS_GL_ENT_HIER" ("GEN1", "GEN1_DESC", "GEN2", "GEN2_DESC", "GEN3", "GEN3_DESC", "GEN4", "GEN4_DESC", "GEN5", "GEN5_DESC") AS 
  (SELECT SUBSTR(path,2,4) GEN1,
    t1.description GEN1_DESC,
    SUBSTR(path,7,4) GEN2,
    t2.description GEN2_DESC,
    SUBSTR(path,12,4) GEN3,
    t3.description GEN3_DESC,
    SUBSTR(path,17,4) GEN4,
    t4.description GEN4_DESC,
    SUBSTR(path,22,4) GEN5,
    t5.description GEN5_DESC
  FROM
    (SELECT SYS_CONNECT_BY_PATH(Level0, '/') Path
    FROM
      (SELECT p.parent_flex_value Level1,
        c.flex_value Level0
      FROM
        (SELECT v.flex_value,
          t.description,
          v.enabled_flag
        FROM fnd_flex_values v,
          fnd_flex_values_tl t
        WHERE v.flex_value_id   = t.flex_value_id
        AND v.flex_value_set_id = 1009472
        ) C,
        (SELECT parent_flex_value,
          child_flex_value_low,
          child_flex_value_high
        FROM FND_FLEX_VALUE_NORM_HIERARCHY
        WHERE flex_value_set_id    = 1009472
        AND range_attribute        = 'P'
        AND parent_flex_value NOT IN ('T','ZZZZ','PAFO')
        AND parent_flex_value NOT LIKE 'HUB%'
        AND parent_flex_value NOT LIKE 'MA%'
        ) P
      WHERE c.flex_value BETWEEN p.child_flex_value_low AND p.child_flex_value_high
      UNION
      SELECT p.parent_flex_value Level1,
        c.flex_value Level0
      FROM
        (SELECT v.flex_value
        FROM fnd_flex_values v
        WHERE v.flex_value_set_id = 1009472
        AND v.summary_flag       <> 'Y'
        ) C,
        (SELECT parent_flex_value,
          child_flex_value_low,
          child_flex_value_high
        FROM FND_FLEX_VALUE_NORM_HIERARCHY
        WHERE flex_value_set_id    = 1009472
        AND range_attribute        = 'C'
        AND parent_flex_value NOT IN ('T','ZZZZ','PAFO')
        AND parent_flex_value NOT LIKE 'HUB%'
        AND parent_flex_value NOT LIKE 'MA%'
        ) P
      WHERE c.flex_value BETWEEN p.child_flex_value_low AND p.child_flex_value_high
      UNION
      SELECT NULL, 'AACL' FROM dual
      )
      CONNECT BY prior level0 = level1
      START WITH level1      IS NULL
    UNION
    SELECT '/'
      ||v.flex_value
    FROM fnd_flex_values v,
      fnd_flex_values_tl t
    WHERE v.flex_value_id   = t.flex_value_id
    AND v.flex_value_set_id = 1009472
    AND v.summary_flag     <> 'Y'
    AND flex_value         <> '0000'
    MINUS
    SELECT '/'
      || c.flex_value
    FROM
      (SELECT v.flex_value,
        t.description,
        v.enabled_flag
      FROM fnd_flex_values v,
        fnd_flex_values_tl t
      WHERE v.flex_value_id   = t.flex_value_id
      AND v.flex_value_set_id = 1009472
      AND v.summary_flag     <> 'Y'
      ) C,
      (SELECT parent_flex_value,
        child_flex_value_low,
        child_flex_value_high
      FROM FND_FLEX_VALUE_NORM_HIERARCHY
      WHERE flex_value_set_id    = 1009472
      AND range_attribute        = 'C'
      AND parent_flex_value NOT IN ('T','ZZZZ','PAFO')
      AND parent_flex_value NOT LIKE 'HUB%'
      AND parent_flex_value NOT LIKE 'MA%'
      ) P
    WHERE c.flex_value BETWEEN p.child_flex_value_low AND p.child_flex_value_high
    ) z,
    fnd_flex_values_tl t1,
    fnd_flex_values_tl t2,
    fnd_flex_values_tl t3,
    fnd_flex_values_tl t4,
    fnd_flex_values_tl t5,
    fnd_flex_values f1,
    fnd_flex_values f2,
    fnd_flex_values f3,
    fnd_flex_values f4,
    fnd_flex_values f5
  WHERE f1.flex_value_set_id (+) = 1009472
  AND f2.flex_value_set_id (+)   = 1009472
  AND f3.flex_value_set_id (+)   = 1009472
  AND f4.flex_value_set_id (+)   = 1009472
  AND f5.flex_value_set_id (+)   = 1009472
  AND f1.flex_value              = SUBSTR(path,2,4)
  AND f2.flex_value (+)          = SUBSTR(path,7,4)
  AND f3.flex_value (+)          = SUBSTR(path,12,4)
  AND f4.flex_value (+)          = SUBSTR(path,17,4)
  AND f5.flex_value (+)          = SUBSTR(path,22,4)
  AND f1.flex_value_id           = t1.flex_value_id
  AND f2.flex_value_id           = t2.flex_value_id (+)
  AND f3.flex_value_id           = t3.flex_value_id (+)
  AND f4.flex_value_id           = t4.flex_value_id (+)
  AND f5.flex_value_id           = t5.flex_value_id (+)
  )
 ;
