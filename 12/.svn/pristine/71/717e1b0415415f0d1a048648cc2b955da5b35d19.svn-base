CREATE OR REPLACE PACKAGE XX_GL_SUBMIT_APPROVAL AS

  PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 ) ;

END XX_GL_SUBMIT_APPROVAL;
 
/


CREATE OR REPLACE PACKAGE BODY XX_GL_SUBMIT_APPROVAL AS

  PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 )  AS
          
               P_JE_BATCH_ID NUMBER;
               P_PREPARER_FND_USER_ID NUMBER;
               P_PREPARER_RESP_ID NUMBER;
               P_JE_BATCH_NAME VARCHAR2(200);
          
          
          
          CURSOR C1 is
            SELECT DISTINCT
                    b.je_batch_id JE_BATCH_ID,
                    nvl(h2.created_by,b.created_by) USER_ID     ,
                    50422 RESP_ID            ,
                    b.name BATCH_NAME                    
                  FROM
                    gl_je_batches b,
                    gl_je_headers h,
                    gl_je_headers h2
                 WHERE  b.status                  <> 'P'
                    AND b.approval_status_code in ('R','V')
                    AND b.je_batch_id          = h.je_batch_id
                    AND h.je_source            in ('Spreadsheet','Manual')
                    and h2.je_header_id (+) = h.accrual_rev_je_header_id;
          
          
          
  BEGIN
  
    
    FOR r IN c1
     LOOP
          P_JE_BATCH_ID := r.je_batch_id;
          p_preparer_fnd_user_id := r.user_id;
          p_preparer_resp_id := r.resp_id;
          p_je_batch_name := r.batch_name;
     
-- Clear old attributes on reversed journals     
    update gl_je_batches
     set attribute1 = null,
      attribute2 = null,
      attribute3 = null
     where  status                  <> 'P'
     AND approval_status_code = 'R'
     and je_batch_id = P_JE_BATCH_ID;      
     
    
    
    GL_WF_JE_APPROVAL_PKG.START_APPROVAL_WORKFLOW(
    P_JE_BATCH_ID => P_JE_BATCH_ID,
    P_PREPARER_FND_USER_ID => P_PREPARER_FND_USER_ID,
    P_PREPARER_RESP_ID => P_PREPARER_RESP_ID,
    P_JE_BATCH_NAME => P_JE_BATCH_NAME
     );
    
    commit;
    
    END LOOP;
    
    
  END MAIN;

END XX_GL_SUBMIT_APPROVAL;

/
