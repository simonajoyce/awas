CREATE OR REPLACE PACKAGE XX_GL_CODE_COMBS AS

  PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2,
          p_type IN VARCHAR2 ) ;

END XX_GL_CODE_COMBS;
 
/


CREATE OR REPLACE PACKAGE BODY XX_GL_CODE_COMBS AS

-- Simple PAckage to be called as a concurrent request, that will update all
-- GL Code Combinations to Enable or disabled depending on the parameter.
-- Used by the Finanace team to allow Consolidation journals to flow through

  PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2,
          p_type IN VARCHAR2 )  AS
  BEGIN
    
    IF p_type = 'DISABLE' THEN
    
     update gl_code_combinations
          set enabled_flag = 'N',
               attribute1 = null
          where attribute1 = 'N'
          and chart_of_accounts_id = 50230;
          
     ELSE IF p_type = 'ENABLE' THEN
     
     update gl_code_combinations
     set enabled_flag = 'Y',
          attribute1 = 'N'
     where enabled_flag = 'N'
     and chart_of_accounts_id = 50230;
     
     END IF;
     END IF;
     
    
    
  END MAIN;

END XX_GL_CODE_COMBS;
/
