--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AP_GET_PAYGROUP
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AP_GET_PAYGROUP" ( P_ENTITY VARCHAR2
                            , P_CURRENCY VARCHAR)
RETURN VARCHAR2 AS 

RETVAL VARCHAR2 (40);

-- Returns Entity and Currency Matching Pay Group
  cursor C1 is SELECT lookup_code
  FROM  (SELECT FLEX_VALUE entity,
                v.attribute1 bank_account_id,
                TO_CHAR(b1.bank_account_num),
                b1.currency_code
        FROM fnd_flex_values v,
             ap_bank_accounts_all b1
        WHERE v.flex_value_Set_id   = 1009472
        AND to_number(v.attribute1) = b1.bank_account_id
        UNION
        SELECT flex_value,
               v.attribute2 bank_account_id,
               TO_CHAR(b2.bank_account_num),
               b2.currency_code
        FROM fnd_flex_values v,
             ap_bank_accounts_all b2
        WHERE v.flex_value_Set_id   = 1009472
        AND to_number(v.attribute2) = b2.bank_account_id
        UNION
        SELECT  flex_value,
                v.attribute3 bank_account_id,
               TO_CHAR(b3.bank_account_num),
               b3.currency_code
        FROM ap_bank_accounts_all b3,
              fnd_flex_values v
        WHERE v.flex_value_Set_id   = 1009472
        AND to_number(v.attribute3) = b3.bank_account_id
        UNION
        SELECT flex_value,
                v.attribute4 bank_account_id,
                TO_CHAR(b4.bank_account_num),
                b4.currency_code
        FROM fnd_flex_values v,
             ap_bank_accounts_all b4
        WHERE v.flex_value_Set_id   = 1009472
        AND to_number(v.attribute4) = b4.bank_account_id) X ,
        FND_LOOKUP_VALUES U
    WHERE LOOKUP_TYPE  = 'PAY GROUP'
    AND U.ENABLED_FLAG = 'Y'
    AND u.attribute1*1 = to_number(x.bank_account_id ) 
    AND X.currency_code = P_CURRENCY
    and X.ENTITY = P_ENTITY;

-- Returns Entity only Matching USD Pay Group
cursor c2 is SELECT lookup_code
  FROM  (SELECT FLEX_VALUE entity,
                v.attribute1 bank_account_id,
                TO_CHAR(b1.bank_account_num),
                b1.currency_code
  FROM fnd_flex_values v,
    ap_bank_accounts_all b1
  WHERE v.flex_value_Set_id   = 1009472
  AND to_number(v.attribute1) = b1.bank_account_id
  UNION
  SELECT flex_value,
    v.attribute2 bank_account_id,
    TO_CHAR(b2.bank_account_num),
    b2.currency_code
  FROM fnd_flex_values v,
    ap_bank_accounts_all b2
  WHERE v.flex_value_Set_id   = 1009472
  AND to_number(v.attribute2) = b2.bank_account_id
  UNION
  SELECT flex_value,
    v.attribute3 bank_account_id,
    TO_CHAR(b3.bank_account_num),
    b3.currency_code
  FROM ap_bank_accounts_all b3,
    fnd_flex_values v
  WHERE v.flex_value_Set_id   = 1009472
  AND to_number(v.attribute3) = b3.bank_account_id
  UNION
  SELECT flex_value,
    v.attribute4 bank_account_id,
    TO_CHAR(b4.bank_account_num),
    b4.currency_code
  FROM fnd_flex_values v,
    ap_bank_accounts_all b4
  WHERE v.flex_value_Set_id   = 1009472
  AND to_number(v.attribute4) = b4.bank_account_id  ) X ,
      FND_LOOKUP_VALUES U
    WHERE LOOKUP_TYPE  = 'PAY GROUP'
    AND U.ENABLED_FLAG = 'Y'
    AND u.attribute1*1 = to_number(x.bank_account_id ) 
    AND X.currency_code = 'USD'
    and X.ENTITY = P_ENTITY;
  

BEGIN
  
  RETVAL := 'SUPPLIER';  -- Default to Supplier if nothing found
   
  open c1;
  
  FETCH C1 INTO RETVAL;
  
  IF c1%NOTFOUND THEN
  
  OPEN C2; 
  
  FETCH C2 INTO RETVAL;
 
  CLOSE C2;
  END IF;
  CLOSE C1;
    
  RETURN RETVAL;
  
END XX_AP_GET_PAYGROUP;
 

/
