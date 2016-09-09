--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_VALID_GL_CODE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_VALID_GL_CODE" (p_segment1 IN VARCHAR2
		  		   ,p_segment2 IN VARCHAR2
		  		   ,p_segment3 IN VARCHAR2
		  		   ,p_segment4 IN VARCHAR2
		  		   ,p_segment5 IN VARCHAR2
		  		   ,p_segment6 IN VARCHAR2
		  		   ,p_segment7 IN VARCHAR2)
		  		   --,p_ccid OUT NUMBER)
                       RETURN VARCHAR2 AS

  CURSOR C_Get_COA_ID IS
  SELECT id_flex_num 
  FROM   FND_ID_FLEX_STRUCTURES 
  WHERE  id_flex_code='GL#' 
  AND    id_flex_structure_code = 'AWAS_GL_CODE';

  returned_boolean 		   BOOLEAN;
  v_chart_of_accounts_id   NUMBER;
  v_segment_number 		   NUMBER := 7;
  v_seg 				   fnd_flex_ext.SegmentArray; /* Segment values of the linked account */
  v_user_id				   NUMBER;
  v_resp_id				   NUMBER;
  v_resp_appl_id		   NUMBER;
  v_error				   VARCHAR2(2000);
  v_progress			   VARCHAR2(10);
  v_msgout			   VARCHAR2(2000);
  v_out                     varchar2(200);  
  v_ccid                    number;
  
  PRAGMA autonomous_transaction;
  
BEGIN

  OPEN C_Get_COA_ID;
  FETCH C_Get_COA_ID
  INTO v_chart_of_accounts_id;
  CLOSE C_Get_COA_ID;
  
  v_seg(1) := p_segment1; 
  v_seg(2) := p_segment2; 
  v_seg(3) := p_segment3; 
  v_seg(4) := p_segment4; 
  v_seg(5) := p_segment5; 
  v_seg(6) := p_segment6; 
  v_seg(7) := p_segment7; 

  --v_user_id := TO_NUMBER(fnd_profile.value('USER_ID')); 
  --v_resp_id := TO_NUMBER(fnd_profile.value('RESP_ID')); 
  --v_resp_appl_id := TO_NUMBER(fnd_profile.value('RESP_APPL_ID')); 

  -- Get the User ID, otherwise a value of '-1' will be inserted into the last_updated_by field in gl_code_combinations. 
  --Fnd_Global.Apps_Initialize (v_user_id, v_resp_id, v_resp_appl_id); 

  -- Get the CCID. If one does not exist for this combination, one will be created here.
  Returned_boolean := fnd_flex_ext.get_combination_id (application_short_name => 'SQLGL' 
  				   	  								  ,key_flex_code => 'GL#' 
													  ,structure_number => v_chart_of_accounts_id
													  ,validation_date => SYSDATE 
													  ,n_segments => v_segment_number 
													  ,segments => v_seg
													  ,combination_id => v_ccid);
													  
  IF returned_boolean = FALSE THEN
    v_msgout := fnd_flex_ext.get_message; 
    
    v_out := v_msgout;

  ELSIF returned_boolean = TRUE THEN 
  
    COMMIT;
    
    v_out := v_ccid;
    
    
  END IF;

  return v_out;
  
END XX_VALID_GL_CODE;
 

/
