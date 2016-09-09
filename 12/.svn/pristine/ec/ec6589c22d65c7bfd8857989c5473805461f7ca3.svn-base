--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_PERSON_DETAILS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_PERSON_DETAILS_UPDATE" BEFORE
  UPDATE ON apps.xx_person_details 
  For Each Row
    WHEN (old.STATUS = 'COMPLETE' and new.status <> 'TERMINATED' and nvl(new.end_date,sysdate) = nvl(old.end_date,sysdate)) DECLARE l_event_key NUMBER;
        l_event_data CLOB;
        l_event_name VARCHAR2(250);
        l_text       VARCHAR2(2000);
        l_message    VARCHAR2(10);
  BEGIN
    
    SELECT xx_person_details_hist_s.NEXTVAL INTO l_event_key FROM dual;
    
    l_event_name := 'xx.umx.Person.Updated';
    l_message    := wf_event.test(l_event_name);
    dbms_lob.createtemporary(l_event_data ,FALSE ,dbms_lob.CALL);
    l_text := '<?xml version =''1.0'' encoding =''ASCII''?>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    l_text := '<updated_person>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<record_type>';
    l_text := l_text || 'UPDATE';
    l_text := l_text || '</record_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<person_id>';
    l_text := l_text || :old.person_id;
    l_text := l_text || '</person_id>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    L_Text := '<old_last_name>';
    L_Text := L_Text || Replace(:Old.Last_Name,'''','');
    l_text := l_text || '</old_last_name>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    L_Text := '<new_last_name>';
    L_Text := L_Text || Replace(:New.Last_Name,'''','');
    l_text := l_text || '</new_last_name>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_first_name>';
    l_text := l_text || :old.first_name;
    l_text := l_text || '</old_first_name>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_first_name>';
    l_text := l_text || :new.first_name;
    l_text := l_text || '</new_first_name>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_start_date>';
    l_text := l_text || :old.start_date;
    l_text := l_text || '</old_start_date>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
     ------------------------------------
    l_text := '<new_start_date>';
    l_text := l_text || :new.start_date;
    l_text := l_text || '</new_start_date>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_end_date>';
    l_text := l_text || :old.end_date;
    l_text := l_text || '</old_end_date>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_end_date>';
    l_text := l_text || :new.end_date;
    l_text := l_text || '</new_end_date>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_office>';
    l_text := l_text || :old.office;
    l_text := l_text || '</old_office>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_office>';
    l_text := l_text || :new.office;
    l_text := l_text || '</new_office>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_cost_center>';
    l_text := l_text || :old.cost_centre;
    l_text := l_text || '</old_cost_center>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_cost_center>';
    l_text := l_text || :new.cost_centre;
    l_text := l_text || '</new_cost_center>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_department>';
    l_text := l_text || replace(:old.department,'&','null;');
    l_text := l_text || '</old_department>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_department>';
    l_text := l_text || replace(:new.department,'&','null;');
    l_text := l_text || '</new_department>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_manager>';
    l_text := l_text || :old.line_manager;
    l_text := l_text || '</old_manager>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_manager>';
    l_text := l_text || :new.line_manager;
    l_text := l_text || '</new_manager>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_expenses_approver>';
    l_text := l_text || :old.expenses_approver;
    l_text := l_text || '</old_expenses_approver>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_expenses_approver>';
    l_text := l_text || :new.expenses_approver;
    l_text := l_text || '</new_expenses_approver>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_job_title>';
    l_text := l_text || replace(:old.job_title,'&','null;');
    l_text := l_text || '</old_job_title>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_job_title>';
    l_text := l_text || replace(:new.job_title,'&','null;');
    l_text := l_text || '</new_job_title>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_employee_type>';
    l_text := l_text || :old.employee_type;
    l_text := l_text || '</old_employee_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<new_employee_type>';
    l_text := l_text || :new.employee_type;
    l_text := l_text || '</new_employee_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<old_pc_type>';
    l_text := l_text || :old.pc_type;
    l_text := l_text || '</old_pc_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<new_pc_type>';
    l_text := l_text || :new.pc_type;
    l_text := l_text || '</new_pc_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<old_mobile_device>';
    l_text := l_text || :old.mobile_device;
    l_text := l_text || '</old_mobile_device>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<new_mobile_device>';
    l_text := l_text || :new.mobile_device;
    l_text := l_text || '</new_mobile_device>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<old_desk_location>';
    l_text := l_text || :old.desk_location;
    l_text := l_text || '</old_desk_location>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<new_desk_location>';
    l_text := l_text || :new.desk_location;
    l_text := l_text || '</new_desk_location>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<old_other_comments>';
    l_text := l_text || :old.other_comments;
    l_text := l_text || '</old_other_comments>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<new_other_comments>';
    l_text := l_text || :new.other_comments;
    l_text := l_text || '</new_other_comments>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
     -----------------------------------
    l_text := '<old_business_cards>';
    l_text := l_text || :old.business_cards;
    l_text := l_text || '</old_business_cards>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<new_business_cards>';
    l_text := l_text || :new.business_cards;
    l_text := l_text || '</new_business_cards>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '</updated_person>';
    
    
    Insert into xx_person_details_hist values (:old.PERSON_ID,:old.FIRST_NAME,:old.LAST_NAME,:old.EMAIL,:old.START_DATE,:old.END_DATE,:old.OFFICE,:old.COST_CENTRE,:old.LINE_MANAGER,:old.EXPENSES_APPROVER,:old.JOB_TITLE,:old.EMPLOYEE_TYPE,:old.PC_TYPE,:old.MOBILE_DEVICE,:old.DESK_LOCATION,:old.OTHER_COMMENTS,:old.LAST_UPDATE_DATE,:old.LAST_UPDATE_LOGIN,:old.LAST_UPDATED_BY,:old.CREATION_DATE,:old.CREATED_BY,:old.STATUS,:old.PERSON_WITH,:old.MANAGER_APPROVER,:old.MANAGER_RESPONSE,:old.MANAGER_RESPONSE_DATE,:old.IT_APPROVER,:old.IT_RESPONSE,:old.IT_RESPONSE_DATE,:old.CS_APPROVER,:old.CS_RESPONSE,:old.CS_RESPONSE_DATE,:old.APPROVAL_COMMENTS,:old.BUSINESS_CARDS,:old.MOBILE_NUMBER,:old.DESK_NUMBER,:old.COPY_USER_FROM,:old.USER_ID,:old.DEPARTMENT,l_event_key,:old.PAP_PERSON_ID,:old.EXTERNAL_PERSON_ID);
    
    :new.status := 'PENDING CHANGES';
    :new.copy_user_from := null;
    
    
    
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -- raise the event with the event with Role Payload
    wf_event.RAISE(p_event_name => l_event_name ,p_event_key => l_event_key ,p_event_data => l_event_data);
    
  END;

/
ALTER TRIGGER "APPS"."XX_PERSON_DETAILS_UPDATE" ENABLE;
