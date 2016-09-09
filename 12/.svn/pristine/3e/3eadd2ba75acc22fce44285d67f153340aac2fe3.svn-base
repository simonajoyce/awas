--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_TEST_EVENT_01
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_TEST_EVENT_01" (
                 p_subscription_guid IN RAW
                ,p_event                IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2 IS
  l_user_name VARCHAR2(100);
  l_user_id   INTEGER;
BEGIN
--read the parameters values passed to this event
  l_user_id   := p_event.getvalueforparameter('XX_TEST_USER_ID');
  l_user_name := p_event.getvalueforparameter('XX_TEST_USER_NAME');
  INSERT INTO xx_event_result
    (x_user_id
    ,x_user_name)
  VALUES
    (l_user_id
    ,l_user_name);
  COMMIT;
  RETURN 'SUCCESS';
END xx_test_event_01;


 

/
