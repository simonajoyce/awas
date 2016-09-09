--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_PERSON_DETAILS_UPDATE3
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_PERSON_DETAILS_UPDATE3" BEFORE
  UPDATE ON apps.xx_person_details 
  FOR EACH ROW
    WHEN (old.STATUS = 'COMPLETE' and new.status <> 'TERMINATED' and nvl(new.end_date,sysdate) <> nvl(old.end_date,sysdate)) DECLARE l_event_key NUMBER;
        
  BEGIN
    
    SELECT xx_person_details_hist_s.NEXTVAL INTO l_event_key FROM dual;
    
    
    Insert into xx_person_details_hist values (:old.PERSON_ID,:old.FIRST_NAME,:old.LAST_NAME,:old.EMAIL,:old.START_DATE,:old.END_DATE,:old.OFFICE,:old.COST_CENTRE,:old.LINE_MANAGER,:old.EXPENSES_APPROVER,:old.JOB_TITLE,:old.EMPLOYEE_TYPE,:old.PC_TYPE,:old.MOBILE_DEVICE,:old.DESK_LOCATION,:old.OTHER_COMMENTS,:old.LAST_UPDATE_DATE,:old.LAST_UPDATE_LOGIN,:old.LAST_UPDATED_BY,:old.CREATION_DATE,:old.CREATED_BY,:old.STATUS,:old.PERSON_WITH,:old.MANAGER_APPROVER,:old.MANAGER_RESPONSE,:old.MANAGER_RESPONSE_DATE,:old.IT_APPROVER,:old.IT_RESPONSE,:old.IT_RESPONSE_DATE,:old.CS_APPROVER,:old.CS_RESPONSE,:old.CS_RESPONSE_DATE,:old.APPROVAL_COMMENTS,:old.BUSINESS_CARDS,:old.MOBILE_NUMBER,:old.DESK_NUMBER,:old.COPY_USER_FROM,:old.USER_ID,:old.DEPARTMENT,l_event_key,:old.PAP_PERSON_ID,:old.EXTERNAL_PERSON_ID);
    
        
  END;

/
ALTER TRIGGER "APPS"."XX_PERSON_DETAILS_UPDATE3" ENABLE;
