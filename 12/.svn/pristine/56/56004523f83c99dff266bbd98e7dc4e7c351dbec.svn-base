--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_PERSON_DETAILS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_PERSON_DETAILS_INSERT" AFTER
  INSERT ON apps.xx_person_details FOR EACH ROW   WHEN (new.STATUS = 'NEW') DECLARE l_event_key NUMBER;
  l_event_data CLOB;
  l_event_name VARCHAR2(250);
  l_text       VARCHAR2(2000);
  l_message    VARCHAR2(10);
  BEGIN
    --SELECT xx_ap_payment_event_s.NEXTVAL INTO l_event_key FROM dual;
    l_event_key  := :new.person_id;
    l_event_name := 'xx.umx.Person.Created';
    l_message    := wf_event.test(l_event_name);
    dbms_lob.createtemporary(l_event_data ,FALSE ,dbms_lob.CALL);
    l_text := '<?xml version =''1.0'' encoding =''ASCII''?>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    l_text := '<new_person>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<record_type>';
    l_text := l_text || 'INSERT';
    l_text := l_text || '</record_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<last_name>';
    l_text := l_text || replace(replace(:new.last_name,'''',''),'&','') ;
    l_text := l_text || '</last_name>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<first_name>';
    l_text := l_text || replace(replace(:new.first_name,'''',''),'&','') ;
    l_text := l_text || '</first_name>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<start_date>';
    l_text := l_text || :new.start_date;
    l_text := l_text || '</start_date>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<end_date>';
    l_text := l_text || :new.end_date;
    l_text := l_text || '</end_date>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<office>';
    l_text := l_text || :new.office;
    l_text := l_text || '</office>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<cost_center>';
    l_text := l_text || :new.cost_centre;
    l_text := l_text || '</cost_center>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<manager>';
    l_text := l_text || replace(REPLACE(:NEW.line_manager,'''',''),'&','') ;
    l_text := l_text || '</manager>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<expenses_approver>';
    l_text := l_text || :new.expenses_approver;
    l_text := l_text || '</expenses_approver>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<job_title>';
    l_text := l_text || replace(REPLACE(:NEW.job_title,'''',''),'&','') ;
    l_text := l_text || '</job_title>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<employee_type>';
    l_text := l_text || replace(REPLACE(:NEW.employee_type,'''',''),'&','') ;
    l_text := l_text || '</employee_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    ------------------------------------
    l_text := '<pc_type>';
    l_text := l_text || replace(REPLACE(:NEW.pc_type,'''',''),'&','') ;
    l_text := l_text || '</pc_type>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<mobile_device>';
    l_text := l_text || :new.mobile_device;
    l_text := l_text || '</mobile_device>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<desk_location>';
    l_text := l_text || replace(REPLACE(:NEW.desk_location,'''',''),'&','') ;
    l_text := l_text || '</desk_location>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<other_comments>';
    l_text := l_text || replace(REPLACE(:NEW.other_comments,'''',''),'&','') ;
    l_text := l_text || '</other_comments>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '<business_cards>';
    l_text := l_text || :new.business_cards;
    l_text := l_text || '</business_cards>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -----------------------------------
    l_text := '</new_person>';
    dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
    -- raise the event with the event with Role Payload
    wf_event.RAISE(p_event_name => l_event_name ,p_event_key => l_event_key ,p_event_data => l_event_data);
  END;

/
ALTER TRIGGER "APPS"."XX_PERSON_DETAILS_INSERT" ENABLE;
