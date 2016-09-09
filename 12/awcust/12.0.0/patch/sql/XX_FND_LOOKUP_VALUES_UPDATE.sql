--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger XX_fnd_lookup_values_update
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "APPS"."XX_fnd_lookup_values_update" AFTER
  UPDATE ON apps.FND_LOOKUP_VALUES
  FOR EACH ROW
    WHEN (old.lookup_type = 'AWAS_APPLICATION_APPROVERS') BEGIN
    



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
ALTER TRIGGER "APPS"."XX_fnd_lookup_values_update" ENABLE;
