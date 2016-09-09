--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_CE_BANK_ACCOUNTS_INS2
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_CE_BANK_ACCOUNTS_INS2" BEFORE
/******************************************************************************
--NAME:       XX_CE_BANK_ACCOUNTS_INS2 trigger
--PURPOSE:    Create Event to send workflow
--REVISIONS:
--Ver        Date        Author           Description
-----------  ----------  ---------------  ------------------------------------
--1.0        25/07/2013  S Joyce          Created this trigger
******************************************************************************/
   INSERT
      ON CE.CE_BANK_ACCOUNTS FOR EACH ROW

   DECLARE l_event_key NUMBER;
   l_event_data CLOB;
   l_event_name VARCHAR2(250);
   l_text       VARCHAR2(2000);
   l_message    VARCHAR2(10);
   BEGIN
      L_EVENT_KEY := :new.bank_account_id; --- Set Item key to bank account id
      -- as insert
      l_event_name := 'xx.ap.bankaccountint.ins';
      l_message    := wf_event.test(l_event_name);
      dbms_lob.createtemporary(l_event_data,FALSE,DBMS_LOB.CALL);
      L_TEXT := '<?xml version =''1.0'' encoding =''ASCII''?>';
      dbms_lob.writeappend(l_event_data,LENGTH(l_text),l_text);
      l_text := '<ap_bank_accounts_all>';
      dbms_lob.writeappend(l_event_data,LENGTH(l_text),L_TEXT);
      ------------------------------------
      L_TEXT := '<record_type>';
      l_text := l_text || 'insert';
      l_text := l_text || '</record_type>';
      dbms_lob.writeappend(l_event_data,LENGTH(l_text),L_TEXT);
      ------------------------------------
      -- Only including bau id in Payload, as other items can be got
      -- dynamically in workflow.
      -- reducing code in trigger
      L_TEXT := '<bank_account_id>';
      L_TEXT := L_TEXT || FND_NUMBER.NUMBER_TO_CANONICAL(:new.bank_account_id);
      l_text := l_text || '</bank_account_id>';
      dbms_lob.writeappend(l_event_data,LENGTH(l_text),L_TEXT);
      l_text := '</ap_bank_accounts_all>';
      -- Now set the populate attribute11 and attribute12 as the start_date and
      -- end_date and set the start_date and end-date to the future.
      -- so they can't be used until after the approval.
      :NEW.ATTRIBUTE11   := SYSDATE;
      :new.attribute12   := :NEW.end_Date;
      :NEW.ATTRIBUTE10   := 'P';
      :NEW.end_date := sysdate-1;
      dbms_lob.writeappend(l_event_data,LENGTH(l_text),L_TEXT);
      -- raise the event with the event with Bank Account Id Payload
      wf_event.RAISE(p_event_name => l_event_name ,p_event_key => l_event_key ,
      p_event_data => l_event_data);
   END;
/
ALTER TRIGGER "APPS"."XX_CE_BANK_ACCOUNTS_INS2" ENABLE;
