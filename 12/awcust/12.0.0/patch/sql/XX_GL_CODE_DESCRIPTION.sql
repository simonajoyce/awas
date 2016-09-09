--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GL_CODE_DESCRIPTION
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GL_CODE_DESCRIPTION" 
(
  P_CODE_COMBINATION_ID IN NUMBER  
) return varchar2 as 

l_description varchar2(400);

BEGIN

select distinct s1.description||' . '||s2.description||
      decode(s3.description,  null,decode(s5.description,null,'',' . '||s3.description),
            ' . '||s3.description)||decode(s5.description,null,'','.'||s5.description)
into l_description
from 
fnd_flex_values_vl s1,
fnd_flex_values_vl s2,
fnd_flex_values_vl s3,
fnd_flex_values_vl s5,
gl_code_combinations g
where s1.flex_value = g.segment1
and s2.flex_value = g.segment2
and s3.flex_value = g.segment3
and s5.flex_value = g.segment5
and s1.flex_value_set_id = 1009472  -- Entity
and s2.flex_value_set_id = 1009492  -- Account
and s3.flex_value_set_id = 1009475  -- Cost Center
and s5.flex_value_set_id = 1009477  -- Operator
and g.code_combination_id = p_code_combination_id;

  RETURN l_description;
END XX_GL_CODE_DESCRIPTION;
 

/
