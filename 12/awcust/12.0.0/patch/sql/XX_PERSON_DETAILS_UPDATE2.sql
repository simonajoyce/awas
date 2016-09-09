--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_PERSON_DETAILS_UPDATE2
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_PERSON_DETAILS_UPDATE2" BEFORE
  UPDATE ON apps.xx_person_details 
  FOR EACH ROW
    WHEN (old.STATUS = 'TERMINATED' and nvl(new.end_date,sysdate+1) > sysdate) DECLARE l_event_key NUMBER;
v_user_name VARCHAR2(50);
       
  BEGIN
    
    SELECT xx_person_details_hist_s.NEXTVAL INTO l_event_key FROM dual;
    select lower(user_name) into v_user_name from fnd_user where user_id = :old.USER_ID;
    
    Insert into xx_person_details_hist values (:old.PERSON_ID,:old.FIRST_NAME,:old.LAST_NAME,:old.EMAIL,:old.START_DATE,:old.END_DATE,:old.OFFICE,:old.COST_CENTRE,:old.LINE_MANAGER,:old.EXPENSES_APPROVER,:old.JOB_TITLE,:old.EMPLOYEE_TYPE,:old.PC_TYPE,:old.MOBILE_DEVICE,:old.DESK_LOCATION,:old.OTHER_COMMENTS,:old.LAST_UPDATE_DATE,:old.LAST_UPDATE_LOGIN,:old.LAST_UPDATED_BY,:old.CREATION_DATE,:old.CREATED_BY,:old.STATUS,:old.PERSON_WITH,:old.MANAGER_APPROVER,:old.MANAGER_RESPONSE,:old.MANAGER_RESPONSE_DATE,:old.IT_APPROVER,:old.IT_RESPONSE,:old.IT_RESPONSE_DATE,:old.CS_APPROVER,:old.CS_RESPONSE,:old.CS_RESPONSE_DATE,:old.APPROVAL_COMMENTS,:old.BUSINESS_CARDS,:old.MOBILE_NUMBER,:old.DESK_NUMBER,:old.COPY_USER_FROM,:old.USER_ID,:old.DEPARTMENT,l_event_key,:old.PAP_PERSON_ID,:old.EXTERNAL_PERSON_ID);
    
    :new.status := 'COMPLETE';
    :new.copy_user_from := NULL;
    
    -- re-enable person in portfolio system
   UPDATE tblperson@basin 
   SET status_code = 1
   where person_id = :old.EXTERNAL_PERSON_ID;
   
  INSERT INTO tblsecurity_prt@basin(Person_id, SYSTEM_ID, SYSTEM_NAME, USER_ID, PASSWORD)
  VALUES (:old.EXTERNAL_PERSON_ID, 1,'PLUMTREE','AWAS-SYD-DOM1\'||v_user_name, null);
    
    
  END;
/
ALTER TRIGGER "APPS"."XX_PERSON_DETAILS_UPDATE2" ENABLE;
