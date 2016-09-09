--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_UMX_ROLE_END_DATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_UMX_ROLE_END_DATE" 
AFTER UPDATE OF END_DATE ON APPLSYS.WF_USER_ROLE_ASSIGNMENTS 
FOR EACH ROW 
  WHEN (NEW.END_DATE is not null) DECLARE
  l_event_key number;
  l_event_data clob;
  l_event_name varchar2(250);
  l_text varchar2(2000);
  l_message varchar2(10);
  
BEGIN

  SELECT xx_ap_payment_event_s.NEXTVAL INTO l_event_key FROM dual;
  
  l_event_name := 'xx.umx.role.enddate';
  l_message    := wf_event.test(l_event_name);
  
    dbms_lob.createtemporary(l_event_data
                          ,FALSE
                          ,dbms_lob.CALL);
  l_text := '<?xml version =''1.0'' encoding =''ASCII''?>';   
  
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);
  
  l_text := '<wf_user_role_assignments>';
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);
  
  ------------------------------------
l_text := '<record_type>';
  l_text := l_text || 'updated';
  l_text := l_text || '</record_type>';
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);
  ------------------------------------  
  l_text := '<user_name>';
  l_text := l_text || :new.user_name;
  l_text := l_text || '</user_name>';
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);
  ------------------------------------
    ------------------------------------
  l_text := '<role_name>';
  l_text := l_text || :new.role_name;
  l_text := l_text || '</role_name>';
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);
  ------------------------------------
  l_text := '<end_date>';
  l_text := l_text || :new.end_date;
  l_text := l_text || '</end_date>';
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);
  ------------------------------------
  
  l_text := '</wf_user_role_assignments>';
  dbms_lob.writeappend(l_event_data
                      ,length(l_text)
                      ,l_text);

  -- raise the event with the event with Role Payload
  wf_event.RAISE(p_event_name => l_event_name
                ,p_event_key  => l_event_key
                ,p_event_data => l_event_data);
END;

/
ALTER TRIGGER "APPS"."XX_UMX_ROLE_END_DATE" ENABLE;
