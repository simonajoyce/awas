--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_POR_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_POR_ACCOUNT" (p_requisition_line_id IN NUMBER)
  RETURN VARCHAR2 IS
  v_account VARCHAR2(30);
  v_count number;
BEGIN

SELECT count(*)
into v_count
FROM po_req_distributions_all d,
gl_code_combinations gcc
WHERE d.requisition_line_id = p_requisition_line_id
AND d.code_combination_id = gcc.code_combination_id;

if v_count = 1 then

            SELECT MAX(gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'||gcc.segment5) 
            into v_account
            FROM po_req_distributions_all d,
            gl_code_combinations gcc
            WHERE d.requisition_line_id = p_requisition_line_id
            AND d.code_combination_id = gcc.code_combination_id;

ELSE

            v_account := 'Multiple Accounts';
end if;

RETURN v_account;

EXCEPTION
  WHEN OTHERS THEN

    RETURN NULL;
END;
 

/
