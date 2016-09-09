--------------------------------------------------------
--  File created - Friday-July-18-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_CE_BANK_ACCOUNTS_UPD1
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_CE_BANK_ACCOUNTS_UPD1" BEFORE
/******************************************************************************
--NAME:       XX_CE_BANK_ACCOUNTS_UPD! trigger
--PURPOSE:    Create Event to send workflow and inserts history record.
--REVISIONS:
--Ver        Date        Author           Description
-----------  ----------  ---------------  ------------------------------------
--1.0        25/07/2013  S Joyce          Created this trigger
--1.1        08/01/2014  S Joyce          Updated when to check for fields
******************************************************************************/
   UPDATE
      ON CE.CE_BANK_ACCOUNTS FOR EACH ROW   WHEN (
         OLD.ATTRIBUTE10                    = 'A'      -- Was Approved Already
      AND NEW.ATTRIBUTE10                   <> 'R'      -- Has not been rejected
      AND (NVL(NEW.BANK_ACCOUNT_NUM,'x')             <> NVL(OLD.BANK_ACCOUNT_NUM,'x')
          OR NVL(NEW.BANK_ACCOUNT_NAME,'x')          <> NVL(OLD.BANK_ACCOUNT_NAME,'x')
          OR NVL(NEW.CURRENCY_CODE,'x')              <> NVL(OLD.CURRENCY_CODE,'x')
          OR NVL(NEW.DESCRIPTION,'x')                <> NVL(OLD.DESCRIPTION,'x')
          OR NVL(NEW.BANK_ACCOUNT_TYPE,'x')          <> NVL(OLD.BANK_ACCOUNT_TYPE,'x')
          OR NVL(NEW.ATTRIBUTE4,'x')                 <> NVL(OLD.ATTRIBUTE4,'x')
          OR NVL(NEW.ATTRIBUTE2,'x')                 <> NVL(OLD.ATTRIBUTE2,'x')
          OR NVL(NEW.ATTRIBUTE5,'x')                 <> NVL(OLD.ATTRIBUTE5,'x')
          OR NVL(NEW.ATTRIBUTE7,'x')                 <> NVL(OLD.ATTRIBUTE7,'x')
          OR NVL(NEW.BANK_ACCOUNT_NAME_ALT,'x')      <> NVL(OLD.BANK_ACCOUNT_NAME_ALT,'x')
          OR NVL(NEW.IBAN_NUMBER,'x')                <> NVL(OLD.IBAN_NUMBER,'x')
          OR NVL(NEW.ASSET_CODE_COMBINATION_ID,-1)  <> NVL(OLD.ASSET_CODE_COMBINATION_ID,-1)
          OR nvl(NEW.END_DATE,sysdate-1)                   <> NVL(OLD.END_DATE,sysdate-1)
          ) 
      ) DECLARE  L_EVENT_KEY NUMBER;
            L_EVENT_DATA CLOB;
            L_EVENT_NAME VARCHAR2(250);
            L_TEXT       VARCHAR2(4000);
            L_MESSAGE    VARCHAR2(10);
            
   BEGIN
      SELECT XX_BANK_ACCOUNT_HIST_S.nextval
      INTO   l_event_key
      FROM   DUAL;

      L_EVENT_NAME := 'xx.ap.bank.accountupdate1';
      L_MESSAGE    := WF_EVENT.TEST(L_EVENT_NAME);
      
      DBMS_LOB.CREATETEMPORARY(L_EVENT_DATA ,FALSE ,DBMS_LOB.CALL);
      
      L_TEXT       := '<?xml version =''1.0'' encoding =''ASCII''?>';
      
      DBMS_LOB.WRITEAPPEND(L_EVENT_DATA ,LENGTH(L_TEXT) ,L_TEXT);
      
      L_TEXT       := '<ap_bank_accounts>';
      
      DBMS_LOB.WRITEAPPEND(L_EVENT_DATA ,LENGTH(L_TEXT) ,L_TEXT);
      
      ------------------------------------
      l_text := '<record_type>';
      l_text := l_text || 'updated';
      l_text := l_text || '</record_type>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<bank_branch_id>';
      l_text := l_text || fnd_number.number_to_canonical(:new.bank_branch_id);
      l_text := l_text || '</bank_branch_id>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<bank_account_id>';
      l_text := l_text || fnd_number.number_to_canonical(:new.bank_account_id);
      l_text := l_text || '</bank_account_id>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<bank_account_number>';
      l_text := l_text || :new.bank_account_num;
      l_text := l_text || '</bank_account_number>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_bank_account_number>';
      l_text := l_text || :old.bank_account_num;
      l_text := l_text || '</old_bank_account_number>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<bank_account_name>';
      l_text := l_text || :new.bank_account_name;
      l_text := l_text || '</bank_account_name>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_bank_account_name>';
      l_text := l_text || :old.bank_account_name;
      l_text := l_text || '</old_bank_account_name>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<currency_code>';
      l_text := l_text || :new.currency_code;
      l_text := l_text || '</currency_code>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_currency_code>';
      l_text := l_text || :old.currency_code;
      l_text := l_text || '</old_currency_code>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      L_TEXT := '<description>';
      l_text := l_text || replace(:new.description,'&','and');
      l_text := l_text || '</description>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      L_TEXT := '<old_description>';
      l_text := l_text || replace(:old.description,'&','and');
      l_text := l_text || '</old_description>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      /*l_text := '<contact>';
      l_text := l_text || :new.contact_first_name||' '||:new.contact_last_name;
      l_text := l_text || '</contact>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_contact>';
      l_text := l_text || :old.contact_first_name||' '||:old.contact_last_name;
      l_text := l_text || '</old_contact>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<contact>';
      l_text := l_text || :new.contact_first_name||' '||:new.contact_last_name;
      l_text := l_text || '</contact>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_contact>';
      l_text := l_text || :old.contact_first_name||' '||:old.contact_last_name;
      l_text := l_text || '</old_contact>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------*/
      l_text := '<bank_account_type>';
      l_text := l_text || :new.bank_account_type;
      l_text := l_text || '</bank_account_type>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_bank_account_type>';
      l_text := l_text || :old.bank_account_type;
      l_text := l_text || '</old_bank_account_type>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<purpose>';
      l_text := l_text || replace(:new.attribute4,'&','and');
      l_text := l_text || '</purpose>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_purpose>';
      l_text := l_text || replace(:old.attribute4,'&','and');
      l_text := l_text || '</old_purpose>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<instrument>';
      l_text := l_text || :new.attribute2;
      l_text := l_text || '</instrument>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_instrument>';
      l_text := l_text || :old.attribute2;
      l_text := l_text || '</old_instrument>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<rate_p_a>';
      l_text := l_text || :new.attribute5;
      l_text := l_text || '</rate_p_a>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_rate_p_a>';
      l_text := l_text || :old.attribute5;
      l_text := l_text || '</old_rate_p_a>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<facility>';
      l_text := l_text || :new.attribute7;
      l_text := l_text || '</facility>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_facility>';
      l_text := l_text || :old.attribute7;
      l_text := l_text || '</old_facility>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<msn>';
      l_text := l_text || :new.bank_account_name_alt;
      l_text := l_text || '</msn>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_msn>';
      l_text := l_text || :old.bank_account_name_alt;
      l_text := l_text || '</old_msn>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<iban>';
      l_text := l_text || :new.iban_number;
      l_text := l_text || '</iban>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_iban>';
      l_text := l_text || :old.iban_number;
      l_text := l_text || '</old_iban>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<asset_code_combination_id>';
      l_text := l_text || :new.asset_code_combination_id;
      l_text := l_text || '</asset_code_combination_id>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_asset_code_combination_id>';
      l_text := l_text || :old.asset_code_combination_id;
      l_text := l_text || '</old_asset_code_combination_id>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<changed_by_user_id>';
      l_text := l_text || fnd_number.number_to_canonical(:new.last_updated_by);
      l_text := l_text || '</changed_by_user_id>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<inactive_date>';
      l_text := l_text || :new.end_date;
      l_text := l_text || '</inactive_date>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<old_inactive_date>';
      l_text := l_text || :old.end_date;
      l_text := l_text || '</old_inactive_date>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '<record_date>';
      l_text := l_text || sysdate;
      l_text := l_text || '</record_date>';
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      ------------------------------------
      l_text := '</ap_bank_accounts>';
      
      l_text := replace(l_text,'&','and');
      
      
      dbms_lob.writeappend(l_event_data ,LENGTH(l_text) ,l_text);
      -- insert into history table
      INSERT
      INTO
         xx_bank_account_hist_2 VALUES
         (
      :new.BANK_ACCOUNT_ID               ,
      :new.BANK_ACCOUNT_NAME             ,
      :new.LAST_UPDATE_DATE              ,
      :new.LAST_UPDATED_BY               ,
      :new.LAST_UPDATE_LOGIN             ,
      :new.CREATION_DATE                 ,
      :new.CREATED_BY                    ,
      :new.BANK_ACCOUNT_NUM              ,
      :new.BANK_BRANCH_ID                ,
      :new.BANK_ID                       ,
      :new.CURRENCY_CODE                 ,
      :new.DESCRIPTION                   ,
      :new.ATTRIBUTE_CATEGORY            ,
      :new.ATTRIBUTE1                    ,
      :new.ATTRIBUTE2                    ,
      :new.ATTRIBUTE3                    ,
      :new.ATTRIBUTE4                    ,
      :new.ATTRIBUTE5                    ,
      :new.ATTRIBUTE6                    ,
      :new.ATTRIBUTE7                    ,
      :new.ATTRIBUTE8                    ,
      :new.ATTRIBUTE9                    ,
      :new.ATTRIBUTE10                   ,
      :new.ATTRIBUTE11                   ,
      :new.ATTRIBUTE12                   ,
      :new.ATTRIBUTE13                   ,
      :new.ATTRIBUTE14                   ,
      :new.ATTRIBUTE15                   ,
      :new.REQUEST_ID                    ,
      :new.PROGRAM_APPLICATION_ID        ,
      :new.PROGRAM_ID                    ,
      :new.PROGRAM_UPDATE_DATE           ,
      :new.CHECK_DIGITS                  ,
      :new.BANK_ACCOUNT_NAME_ALT         ,
      :new.ACCOUNT_HOLDER_ID             ,
      :new.EFT_REQUESTER_IDENTIFIER      ,
      :new.SECONDARY_ACCOUNT_REFERENCE   ,
      :new.ACCOUNT_SUFFIX                ,
      :new.DESCRIPTION_CODE1             ,
      :new.DESCRIPTION_CODE2             ,
      :new.IBAN_NUMBER                   ,
      :new.SHORT_ACCOUNT_NAME            ,
      :new.ACCOUNT_OWNER_PARTY_ID        ,
      :new.ACCOUNT_OWNER_ORG_ID          ,
      :new.ACCOUNT_CLASSIFICATION        ,
      :new.AP_USE_ALLOWED_FLAG           ,
      :new.AR_USE_ALLOWED_FLAG           ,
      :new.XTR_USE_ALLOWED_FLAG          ,
      :new.PAY_USE_ALLOWED_FLAG          ,
      :new.MULTI_CURRENCY_ALLOWED_FLAG   ,
      :new.PAYMENT_MULTI_CURRENCY_FLAG   ,
      :new.RECEIPT_MULTI_CURRENCY_FLAG   ,
      :new.ZERO_AMOUNT_ALLOWED           ,
      :new.MAX_OUTLAY                    ,
      :new.MAX_CHECK_AMOUNT              ,
      :new.MIN_CHECK_AMOUNT              ,
      :new.AP_AMOUNT_TOLERANCE           ,
      :new.AR_AMOUNT_TOLERANCE           ,
      :new.XTR_AMOUNT_TOLERANCE          ,
      :new.PAY_AMOUNT_TOLERANCE          ,
      :new.AP_PERCENT_TOLERANCE          ,
      :new.AR_PERCENT_TOLERANCE          ,
      :new.XTR_PERCENT_TOLERANCE         ,
      :new.PAY_PERCENT_TOLERANCE         ,
      :new.BANK_ACCOUNT_TYPE             ,
      :new.AGENCY_LOCATION_CODE          ,
      :new.START_DATE                    ,
      :new.END_DATE                      ,
      :new.ACCOUNT_HOLDER_NAME_ALT       ,
      :new.ACCOUNT_HOLDER_NAME           ,
      :new.CASHFLOW_DISPLAY_ORDER        ,
      :new.POOLED_FLAG                   ,
      :new.MIN_TARGET_BALANCE            ,
      :new.MAX_TARGET_BALANCE            ,
      :new.EFT_USER_NUM                  ,
      :new.MASKED_ACCOUNT_NUM            ,
      :new.MASKED_IBAN                   ,
      :new.INTEREST_SCHEDULE_ID          ,
      :new.CASHPOOL_MIN_PAYMENT_AMT      ,
      :new.CASHPOOL_MIN_RECEIPT_AMT      ,
      :new.CASHPOOL_ROUND_FACTOR         ,
      :new.ASSET_CODE_COMBINATION_ID     ,
      :new.CASHPOOL_ROUND_RULE           ,
      :new.CE_AMOUNT_TOLERANCE           ,
      :new.CE_PERCENT_TOLERANCE          ,
      :new.CASH_CLEARING_CCID            ,
      :new.BANK_CHARGES_CCID             ,
      :new.BANK_ERRORS_CCID              ,
      :new.OBJECT_VERSION_NUMBER         ,
      :new.NETTING_ACCT_FLAG             ,
      :new.POOL_PAYMENT_METHOD_CODE      ,
      :new.POOL_BANK_CHARGE_BEARER_CODE  ,
      :new.POOL_PAYMENT_REASON_CODE      ,
      :new.POOL_PAYMENT_REASON_COMMENTS  ,
      :new.POOL_REMITTANCE_MESSAGE1      ,
      :new.POOL_REMITTANCE_MESSAGE2      ,
      :new.POOL_REMITTANCE_MESSAGE3      ,
      :new.FX_CHARGE_CCID                ,
      :new.BANK_ACCOUNT_NUM_ELECTRONIC   ,
      :new.STMT_LINE_FLOAT_HANDLING_FLAG ,
      :new.AUTORECON_AP_MATCHING_ORDER   ,
      :new.AUTORECON_AR_MATCHING_ORDER   ,
      :new.RECON_FOREIGN_BANK_XRATE_TYPE ,
      :new.RECON_FOR_BANK_XRATE_DATE_TYPE,
      :new.RECON_ENABLE_OI_FLAG          ,
      :new.RECON_OI_FLOAT_STATUS         ,
      :new.RECON_OI_CLEARED_STATUS       ,
      :new.RECON_OI_MATCHING_CODE        ,
      :new.RECON_OI_AMOUNT_TOLERANCE     ,
      :new.RECON_OI_PERCENT_TOLERANCE    ,
      :new.MANUAL_RECON_AMOUNT_TOLERANCE ,
      :new.MANUAL_RECON_PERCENT_TOLERANCE,
      :new.RECON_AP_FOREIGN_DIFF_HANDLING,
      :new.RECON_AR_FOREIGN_DIFF_HANDLING,
      :new.RECON_CE_FOREIGN_DIFF_HANDLING,
      :new.RECON_AP_TOLERANCE_DIFF_ACCT  ,
      :new.RECON_CE_TOLERANCE_DIFF_ACCT  ,
      :new.XTR_BANK_ACCOUNT_REFERENCE    ,
      :new.AUTORECON_AP_MATCHING_ORDER2  ,
      :new.GAIN_CODE_COMBINATION_ID      ,
      :new.LOSS_CODE_COMBINATION_ID      ,
            l_event_key
         );
      -- raise the event with the event with Bank Account Payload
      wf_event.RAISE(p_event_name => l_event_name ,p_event_key => l_event_key ,
      P_EVENT_DATA => L_EVENT_DATA);
   END;
/
ALTER TRIGGER "APPS"."XX_CE_BANK_ACCOUNTS_UPD1" ENABLE;
