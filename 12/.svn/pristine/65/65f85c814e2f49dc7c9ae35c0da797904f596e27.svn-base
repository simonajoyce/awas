--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure XX_CREATE_SET_ROLES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "APPS"."XX_CREATE_SET_ROLES" 
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          RESULT   IN OUT VARCHAR2 )
                   IS
     v_email_address xx_notifications_api.email_address%TYPE;
     v_user_name xx_notifications_api.user_name%TYPE;
     v_role_name wf_roles.NAME%TYPE;
     n_notification_api_id INTEGER;
     l_error          VARCHAR ( 100 ) := 'CREATE_SET_ROLES';
     e_user_exception EXCEPTION;
BEGIN
     
     wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'SEND_TO_ROLE', avalue => 'Simon Joyce' ) ;
     RESULT := 'COMPLETE:Y';

END xx_create_set_roles;

 

/
