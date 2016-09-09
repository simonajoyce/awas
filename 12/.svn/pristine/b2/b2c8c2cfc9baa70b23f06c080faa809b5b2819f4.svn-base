--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger xx_fnd_lookup_values_insert
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."xx_fnd_lookup_values_insert" BEFORE
  INSERT ON apps.FND_LOOKUP_VALUES
  FOR EACH ROW
    WHEN (new.lookup_type = 'AWAS_APPLICATION_APPROVERS') BEGIN
    

    INSERT INTO xx_application_approvers_hist VALUES 
    (:NEW.lookup_code,
     :NEW.meaning, 
     :NEW.description, 
     :NEW.enabled_flag, 
     :NEW.last_update_date, 
     (SELECT user_name FROM fnd_user WHERE user_id = :NEW.last_updated_by),
     :NEW.attribute1, 
     :NEW.ATTRIBUTE2, 
     :NEW.ATTRIBUTE3
     );
       
  END;

/
ALTER TRIGGER "APPS"."xx_fnd_lookup_values_insert" ENABLE;
