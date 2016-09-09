CREATE OR REPLACE PACKAGE        "XX_PERSON_WF" AS 

/******************************************************************************
--NAME:     XX_PERSON_WF
--PURPOSE:  Used by XXNEWPER New Person Workflow
--REVISIONS:
--Ver        Date        Author           Description
-----------  ----------  ---------------  ------------------------------------
--1.0        02/05/2014  S Joyce          1. Created this package.

******************************************************************************/
PROCEDURE get_assignment
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
PROCEDURE get_old_assignment
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
PROCEDURE approval_type
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
PROCEDURE call_helpdesk_api
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
PROCEDURE call_helpdesk_api2
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

END XX_PERSON_WF;
/


CREATE OR REPLACE PACKAGE BODY        "XX_PERSON_WF" AS

  PROCEDURE get_assignment
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) AS
    
           v_assignment_id    XX_EMPLOYEE_ASSIGNMENTS.assignment_id%type;
           v_person_id        XX_EMPLOYEE_ASSIGNMENTS.person_id%type;
           v_start_date       XX_EMPLOYEE_ASSIGNMENTS.start_date%type;
           v_end_date         XX_EMPLOYEE_ASSIGNMENTS.end_date%type;
           v_office           XX_EMPLOYEE_ASSIGNMENTS.office%type;
           v_cost_center      XX_EMPLOYEE_ASSIGNMENTS.cost_centre%type;
           v_department       XX_EMPLOYEE_ASSIGNMENTS.department%type;
           v_line_manager     XX_EMPLOYEE_ASSIGNMENTS.line_manager%type;
           v_line_manager_id  XX_EMPLOYEE_ASSIGNMENTS.line_manager_id%type;
           v_job_title        XX_EMPLOYEE_ASSIGNMENTS.job_title%type;
           v_job_level        XX_EMPLOYEE_ASSIGNMENTS.job_level%type;
           v_employee_type    XX_EMPLOYEE_ASSIGNMENTS.employee_type%type;
           v_mobile_number    XX_EMPLOYEE_ASSIGNMENTS.mobile_number%type;
           v_desk_number      XX_EMPLOYEE_ASSIGNMENTS.desk_number%type;
           v_business_cards   XX_EMPLOYEE_ASSIGNMENTS.business_cards%type;
           v_remote_access    XX_EMPLOYEE_ASSIGNMENTS.remote_access%type;
           v_pc_type          XX_EMPLOYEE_ASSIGNMENTS.pc_type%type;
           v_mobile_device    XX_EMPLOYEE_ASSIGNMENTS.mobile_device%type;
           v_desk_location    XX_EMPLOYEE_ASSIGNMENTS.desk_location%type;
           v_other_comments   XX_EMPLOYEE_ASSIGNMENTS.other_comments%type;
           v_user_profile     XX_EMPLOYEE_ASSIGNMENTS.user_profile%type;
           v_restrict_fyi     XX_EMPLOYEE_ASSIGNMENTS.restrict_fyi%type;
           v_created_by       XX_EMPLOYEE_ASSIGNMENTS.created_by%type;
           l_created_by       fnd_user.user_name%type;
           v_first_name       XX_EMPLOYEE_DETAILS.first_name%TYPE;
           v_last_name        XX_EMPLOYEE_DETAILS.last_name%TYPE;
           v_copy_user_from   XX_EMPLOYEE_DETAILS.copy_user_from%TYPE;
           X_CHECK            XX_EMPLOYEE_DETAILS.COPY_USER_FROM%type;
           v_portal           xx_employee_assignments.portal%type;
           
BEGIN
     IF ( funcmode = 'RUN' ) THEN

    dbms_output.put_line('1');

      select to_number(itemkey) into v_assignment_id from dual;
      
    dbms_output.put_line('itemkey/assignment_id = '||v_assignment_id);
      
    
      select person_id,
              start_date,
              end_date,
              office,
              cost_centre,
              department,
              case when LINE_MANAGER_ID is null then (select USER_NAME from FND_USER F, PER_ALL_PEOPLE_F P where PERSON_ID = EMPLOYEE_ID and FULL_NAME = X.LINE_MANAGER)
              else (select USER_NAME from FND_USER where EMPLOYEE_ID = X.LINE_MANAGER_ID)  end LINE_MANAGER,
              line_manager_id,
              job_title,
              job_level,
              employee_type,
              mobile_number,
              desk_number,
              business_cards,
              remote_access,
              pc_type,
              mobile_device,
              desk_location,
              other_comments,
              user_profile,
              restrict_fyi,
              CREATED_BY,
              PORTAL
      into v_person_id,
           v_start_date,
           v_end_date,
           v_office,
           v_cost_center,
           v_department,
           v_line_manager,
           v_line_manager_id,
           v_job_title,
           v_job_level,
           v_employee_type,
           v_mobile_number,
           v_desk_number,
           v_business_cards,
           v_remote_access,
           v_pc_type,
           v_mobile_device,
           v_desk_location,
           v_other_comments,
           v_user_profile,
           v_restrict_fyi,
           V_CREATED_BY,
           v_portal
      from XX_EMPLOYEE_ASSIGNMENTS x
      where assignment_id = v_assignment_id;
      
      select user_name
      into l_created_by
      from fnd_user
      where user_id = v_created_by;
      
      if V_LINE_MANAGER is null then
      
      select USER_NAME
      into v_line_manager
      from FND_USER 
      where DESCRIPTION = (select LINE_MANAGER from XX_EMPLOYEE_ASSIGNMENTS where ASSIGNMENT_ID = V_ASSIGNMENT_ID);
            
      end if;
      
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CREATED_BY', avalue => l_created_by ) ;

         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'HR_APPROVER', avalue => l_created_by ) ;
         
      select first_name,
             last_name,
             copy_user_from
      into v_first_name,
           v_last_name,
           v_copy_user_from
      from xx_employee_details
      where person_id = v_person_id;
      
      begin 
      
      select name 
      into x_check
      from wf_roles
      where name = V_copy_user_from;
      
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COPY_FROM_USER', avalue => v_copy_user_from ) ;
         
         dbms_output.put_line('Copy_USER_FROM='||v_copy_user_from);
         
      exception when others then
      
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COPY_FROM_USER', avalue => 'GUEST' ) ;
            
            dbms_output.put_line('Copy_USER_FROM=GUEST');
      
      end;

         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME', avalue => v_last_name ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME', avalue => v_first_name ) ;
         
         WF_ENGINE.SETITEMATTRNUMBER ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID', avalue => v_person_id ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE', avalue => v_start_date ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE', avalue => v_end_date ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PC_TYPE', avalue => v_pc_type ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE', avalue => v_office ) ;
          WF_ENGINE.SETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'COST_CENTER', AVALUE => V_COST_CENTER ) ;
          DBMS_OUTPUT.PUT_LINE('Manager='||V_LINE_MANAGER);
          
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER', avalue => v_line_manager ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER_APPROVER', avalue => v_line_manager ) ;
          WF_ENGINE.SETITEMATTRNUMBER ( itemtype => itemtype, itemkey => itemkey,aname => 'JOB_LEVEL', avalue => v_job_level ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE', avalue => v_job_title ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMPLOYEE_TYPE', avalue => v_employee_type ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'USER_PROFILE', avalue => v_user_profile ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MOBILE_DEVICE', avalue => v_mobile_device ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MOBILE_NUMBER', avalue => v_mobile_number ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DESK_NUMBER', avalue => v_desk_number ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BUSINESS_CARDS', avalue => v_business_cards ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DESK_LOCATION', avalue => v_desk_location ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OTHER_COMMENTS', avalue => v_other_comments ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DEPARTMENT', avalue => v_department ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'REMOTE_ACCESS', avalue => v_remote_access ) ;
          WF_ENGINE.SETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'RESTRICT_FYI', AVALUE => V_RESTRICT_FYI ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PORTAL', avalue => v_portal ) ;


    END IF;
    
  END get_assignment;
  
  
  PROCEDURE get_old_assignment
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) AS
    
           v_assignment_id    XX_EMPLOYEE_ASSIGNMENTS.assignment_id%type;
           v_person_id        XX_EMPLOYEE_ASSIGNMENTS.person_id%type;
           v_start_date       XX_EMPLOYEE_ASSIGNMENTS.start_date%type;
           v_end_date         XX_EMPLOYEE_ASSIGNMENTS.end_date%type;
           v_office           XX_EMPLOYEE_ASSIGNMENTS.office%type;
           v_cost_center      XX_EMPLOYEE_ASSIGNMENTS.cost_centre%type;
           v_department       XX_EMPLOYEE_ASSIGNMENTS.department%type;
           v_line_manager     XX_EMPLOYEE_ASSIGNMENTS.line_manager%type;
           v_line_manager_id  XX_EMPLOYEE_ASSIGNMENTS.line_manager_id%type;
           v_job_title        XX_EMPLOYEE_ASSIGNMENTS.job_title%type;
           v_job_level        XX_EMPLOYEE_ASSIGNMENTS.job_level%type;
           v_employee_type    XX_EMPLOYEE_ASSIGNMENTS.employee_type%type;
           v_mobile_number    XX_EMPLOYEE_ASSIGNMENTS.mobile_number%type;
           v_desk_number      XX_EMPLOYEE_ASSIGNMENTS.desk_number%type;
           v_business_cards   XX_EMPLOYEE_ASSIGNMENTS.business_cards%type;
           v_remote_access    XX_EMPLOYEE_ASSIGNMENTS.remote_access%type;
           v_pc_type          XX_EMPLOYEE_ASSIGNMENTS.pc_type%type;
           v_mobile_device    XX_EMPLOYEE_ASSIGNMENTS.mobile_device%type;
           v_desk_location    XX_EMPLOYEE_ASSIGNMENTS.desk_location%type;
           v_other_comments   XX_EMPLOYEE_ASSIGNMENTS.other_comments%type;
           v_user_profile     XX_EMPLOYEE_ASSIGNMENTS.user_profile%type;
           v_restrict_fyi     XX_EMPLOYEE_ASSIGNMENTS.restrict_fyi%type;
           v_created_by       XX_EMPLOYEE_ASSIGNMENTS.created_by%type;
           l_created_by       fnd_user.user_name%type;
           v_first_name       XX_EMPLOYEE_DETAILS.first_name%TYPE;
           v_last_name        XX_EMPLOYEE_DETAILS.last_name%TYPE;
           V_COPY_USER_FROM   XX_EMPLOYEE_DETAILS.COPY_USER_FROM%type;
           V_PORTAL           XX_EMPLOYEE_assignments.PORTAL%type;
           
           v_old_start_date       XX_EMPLOYEE_ASSIGNMENTS.start_date%type;
           v_old_end_date         XX_EMPLOYEE_ASSIGNMENTS.end_date%type;
           v_old_office           XX_EMPLOYEE_ASSIGNMENTS.office%type;
           v_old_cost_center      XX_EMPLOYEE_ASSIGNMENTS.cost_centre%type;
           v_old_department       XX_EMPLOYEE_ASSIGNMENTS.department%type;
           v_old_line_manager     XX_EMPLOYEE_ASSIGNMENTS.line_manager%type;
           v_old_line_manager_id  XX_EMPLOYEE_ASSIGNMENTS.line_manager_id%type;
           v_old_job_title        XX_EMPLOYEE_ASSIGNMENTS.job_title%type;
           v_old_job_level        XX_EMPLOYEE_ASSIGNMENTS.job_level%type;
           v_old_employee_type    XX_EMPLOYEE_ASSIGNMENTS.employee_type%type;
           v_old_mobile_number    XX_EMPLOYEE_ASSIGNMENTS.mobile_number%type;
           v_old_desk_number      XX_EMPLOYEE_ASSIGNMENTS.desk_number%type;
           v_old_business_cards   XX_EMPLOYEE_ASSIGNMENTS.business_cards%type;
           v_old_remote_access    XX_EMPLOYEE_ASSIGNMENTS.remote_access%type;
           v_old_pc_type          XX_EMPLOYEE_ASSIGNMENTS.pc_type%type;
           v_old_mobile_device    XX_EMPLOYEE_ASSIGNMENTS.mobile_device%type;
           v_old_desk_location    XX_EMPLOYEE_ASSIGNMENTS.desk_location%type;
           v_old_other_comments   XX_EMPLOYEE_ASSIGNMENTS.other_comments%type;
           v_old_user_profile     XX_EMPLOYEE_ASSIGNMENTS.user_profile%type;
           v_old_restrict_fyi     XX_EMPLOYEE_ASSIGNMENTS.restrict_fyi%type;
           v_old_created_by       XX_EMPLOYEE_ASSIGNMENTS.created_by%type;
           l_old_created_by       fnd_user.user_name%type;
           v_old_first_name       XX_EMPLOYEE_DETAILS.first_name%TYPE;
           v_old_last_name        XX_EMPLOYEE_DETAILS.last_name%TYPE;
           V_OLD_COPY_USER_FROM   XX_EMPLOYEE_DETAILS.COPY_USER_FROM%type;
           V_OLD_PORTAL           XX_EMPLOYEE_assignments.PORTAL%type;
           
           v_change_mesg                     VARCHAR2 (2000);
           
BEGIN
     IF ( funcmode = 'RUN' ) THEN

    dbms_output.put_line('1');

    select to_number(itemkey) into v_assignment_id from dual;
      
    dbms_output.put_line('itemkey/assignment_id = '||v_assignment_id);
      
    
      select person_id,
              start_date,
              end_date,
              office,
              cost_centre,
              DEPARTMENT,
              (select user_name from fnd_user where employee_id = x.line_manager_id) LINE_MANAGER,
              line_manager_id,
              job_title,
              job_level,
              employee_type,
              mobile_number,
              desk_number,
              business_cards,
              remote_access,
              pc_type,
              mobile_device,
              desk_location,
              other_comments,
              user_profile,
              restrict_fyi,
              CREATED_BY,
              portal
      into v_person_id,
           v_old_start_date,
           v_old_end_date,
           v_old_office,
           v_old_cost_center,
           v_old_department,
           v_old_line_manager,
           v_old_line_manager_id,
           v_old_job_title,
           v_old_job_level,
           v_old_employee_type,
           v_old_mobile_number,
           v_old_desk_number,
           v_old_business_cards,
           v_old_remote_access,
           v_old_pc_type,
           v_old_mobile_device,
           v_old_desk_location,
           v_old_other_comments,
           v_old_user_profile,
           v_old_restrict_fyi,
           V_OLD_CREATED_BY,
           v_old_portal
      from XX_EMPLOYEE_ASSIGNMENTS x
      where assignment_id = (select max(assignment_id) 
                             from XX_EMPLOYEE_ASSIGNMENTS 
                             where person_id = (select person_id 
                                                from xx_employee_assignments 
                                                where assignment_id = v_assignment_id)
                             and assignment_id <> v_assignment_id);
      
              
      select first_name,
             last_name,
             copy_user_from
      into v_old_first_name,
           v_old_last_name,
           v_old_copy_user_from
      from xx_employee_details
      where person_id = v_person_id;

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_LAST_NAME', avalue => v_old_last_name ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_FIRST_NAME', avalue => v_old_first_name ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_START_DATE', avalue => v_old_start_date ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_END_DATE', avalue => v_old_end_date ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_OFFICE', avalue => v_old_office ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_COST_CENTER', avalue => v_old_cost_center ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_MANAGER', avalue => v_old_line_manager ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_JOB_TITLE', avalue => v_old_job_title ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_DESK_LOCATION', avalue => v_old_desk_location ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_OTHER_COMMENTS', avalue => v_old_other_comments ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_DEPARTMENT', avalue => v_old_department ) ;         
          WF_ENGINE.SETITEMATTRNUMBER( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_JOB_LEVEL', avalue => v_old_job_level ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_EMPLOYEE_TYPE', avalue => v_old_employee_type ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_USER_PROFILE', avalue => v_old_user_profile ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_MOBILE_DEVICE', avalue => v_old_mobile_device ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_MOBILE_NUMBER', avalue => v_old_mobile_number ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_DESK_NUMBER', avalue => v_old_desk_number ) ;
          WF_ENGINE.SETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'OLD_REMOTE_ACCESS', AVALUE => V_OLD_REMOTE_ACCESS ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_PORTAL', avalue => v_old_portal ) ;

          v_first_name  := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME');
          v_last_name   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME');
          v_start_date  := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE');
          v_end_date    := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE');
          v_office      := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE');
          v_cost_center := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COST_CENTER');
          v_line_manager:= wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER');
          v_job_title   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE');
          v_desk_location  := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DESK_LOCATION');
          v_other_comments := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OTHER_COMMENTS');
          v_department     := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DEPARTMENT');
          v_job_level      := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_LEVEL');
          v_employee_type  := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMPLOYEE_TYPE');
          v_user_profile   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'USER_PROFILE');
          v_mobile_device   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MOBILE_DEVICE');
          v_mobile_number   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MOBILE_NUMBER');
          v_desk_number     := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DESK_NUMBER');
          V_REMOTE_ACCESS   := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'REMOTE_ACCESS');
          V_portal         := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'PORTAL');
          
          
          
          
          
          
      
      -- now create HTML table for messages
          V_Change_Mesg := '';  -- reset
          Wf_Engine.Setitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'APPROVAL_PATH', Avalue => 'IS' ) ;
          v_change_mesg := v_change_mesg||'<h4>'||v_first_name||' '||v_old_last_name||' has been modified as follows:</h4>';
          v_change_mesg := v_change_mesg||'<table border="1" cellpadding="10"><tr><table border="1" cellpadding="10"><tr><td><b>Attribute</b></td><td><b>Old Value</b></td><td><b>New Value</b></td></tr>';

          If V_Old_Last_Name <> V_Last_Name Then
          v_change_mesg := v_change_mesg||'<tr><td>Surname</td><td><del>'||v_OLD_last_name||'</del></td><td><ins>'||V_last_name||'</ins></td></tr>';

          end if;

          if v_old_line_manager <> v_line_manager then
          v_change_mesg := v_change_mesg||'<tr><td>Manager</td><td><del>'||v_OLD_line_manager||'</del></td><td><ins>'||V_line_manager||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if nvl(v_old_job_title,'x') <> v_job_title then
          V_CHANGE_MESG := V_CHANGE_MESG||'<tr><td>Job Title</td><td><del>'||V_OLD_JOB_TITLE||'</del></td><td><ins>'||V_JOB_TITLE||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if v_old_office <> v_office then
          V_CHANGE_MESG := V_CHANGE_MESG||'<tr><td>Office</td><td><del>'||V_OLD_OFFICE||'</del></td><td><ins>'||V_OFFICE||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if v_old_cost_center <> v_cost_center then
          v_change_mesg := v_change_mesg||'<tr><td>Cost Centre</td><td><del>'||v_OLD_COST_CENTER||'</del></td><td><ins>'||V_COST_CENTER||'</ins></td></tr>';
          WF_ENGINE.SETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'APPROVAL_PATH', AVALUE => 'MANAGER' ) ;
          end if;
          if nvl(v_old_department,'x') <> v_department then
          V_CHANGE_MESG := V_CHANGE_MESG||'<tr><td>Department</td><td><del>'||V_OLD_DEPARTMENT||'null</del></td><td><ins>'||V_DEPARTMENT||'</ins></td></tr>';
          WF_ENGINE.SETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'APPROVAL_PATH', AVALUE => 'MANAGER' ) ;
          end if;
          IF V_OLD_JOB_LEVEL <> V_JOB_LEVEL THEN
          V_CHANGE_MESG := V_CHANGE_MESG||'<tr><td>Job Level</td><td><del>'||V_OLD_JOB_LEVEL||'</del></td><td><ins>'||V_JOB_LEVEL||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if nvl(v_old_desk_location,'x') <> v_desk_location then
          v_change_mesg := v_change_mesg||'<tr><td>Desk Location</td><td><del>'||v_OLD_desk_location||'</del></td><td><ins>'||V_desk_location||'</ins></td></tr>';

          end if;
          if nvl(v_old_other_comments,'x') <> v_other_comments then
          v_change_mesg := v_change_mesg||'<tr><td>Other Comments</td><td><del>'||v_OLD_other_comments||'</del></td><td><ins>'||V_other_comments||'</ins></td></tr>';

          end if;

          dbms_output.put_line('old_end_date:'||v_old_end_Date);
          dbms_output.put_line('end_date:'||v_end_Date);

          dbms_output.put_line('old_start_date:'||v_old_start_Date);
          dbms_output.put_line('start_date:'||v_start_Date);

          IF nvl(v_old_start_date,SYSDATE) <> nvl(v_start_date,SYSDATE) THEN
          v_change_mesg := v_change_mesg||'<tr><td>Assignment Effective Start Date</td><td><del>'||v_OLD_start_date||'</del></td><td><ins>'||V_start_date||'</ins></td></tr>';
          end if;

          IF nvl(v_old_end_date,SYSDATE) <> nvl(v_end_date,SYSDATE) THEN
          v_change_mesg := v_change_mesg||'<tr><td>End Date</td><td><del>'||v_OLD_end_date||'</del></td><td><ins>'||V_end_date||'</ins></td></tr>';
          end if;

          v_change_mesg := v_change_mesg||'</table><br /><br />Please Approve or Reject the Changes. If you are rejecting the changes please enter a rejection reason.<br /><br />';

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CHANGE_MESG', avalue => v_change_mesg ) ;




    END IF;
    
    
    
  END get_old_assignment;
  
  
  PROCEDURE approval_type
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 )  as

  v_person_id  xx_employee_details.person_id%type;
  v_count number;
  
  begin
  
  v_person_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID') ;
  
  select count(*)
  into v_count
  from xx_employee_assignments where person_id = v_person_id;
  
  if v_count > 1 then resultout := 'AMEND';
  else resultout := 'NEW';
  end if;
  
  
          
          
  end approval_type;
  
  
  PROCEDURE call_helpdesk_api
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as
          
  v_subject  varchar2(150);
  v_description varchar2(2000);
  v_category  varchar2(40);
  v_subcategory varchar2(40);
  v_item  varchar2(40);
  v_requester_email varchar2(40);
  v_proxy varchar2(40) null;
  l_start_date date;
  l_end_date date;
  v_user_profile varchar2(100);
  v_user_profile_tmp varchar2(100);
  v_hr_approver varchar2(100);
          
  begin
  
  v_subject := 'New User in '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE') ||' Office - '
            || wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME')||' '
            || wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME');
  
  l_start_date:=wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE');
  l_end_date:=wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE');
  
  
  v_description := 'Employee Start Date: '||l_start_date;
  if l_end_date is not null then 
  v_description := v_description||'.'||chr(13)||'End Date: '||l_end_date;
  end if;
  v_description := v_description||'.'||chr(13)||'Office: '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE');
  v_description := v_description||'.'||chr(13)||'Department: '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DEPARTMENT');
  v_description := v_description||'.'||chr(13)||'Manager: '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER');
  v_description := v_description||'.'||chr(13)||'Job Title: '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE');
  v_description := v_description||'.'||chr(13)||'Set Access the same as: '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COPY_FROM_USER');
  
  
  v_category    := null;
  v_subcategory := null;
  v_item        := null;
  
  
  v_hr_approver := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'HR_APPROVER');
  
  select email_address 
  into v_requester_email
  from fnd_user
  where user_name = v_hr_approver;
  
  
  v_user_profile_tmp := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'USER_PROFILE');
  
  select lookup_code
  into v_user_profile
  from FND_LOOKUP_VALUES
  where LOOKUP_TYPE = 'AWAS_USER_PROFILE'
  and meaning = v_user_profile_tmp;
  
  
  
  
  xx_raise_me_ticket(    v_subject,
                         v_description,
                         v_category,
                         v_subcategory,
                         v_item,
                         v_requester_email,
                         v_proxy,
                         'New Joiner Template');
  
  
  
  
  
  end call_helpdesk_api;
  
  PROCEDURE call_helpdesk_api2
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as
          
  v_subject  varchar2(150);
  v_description varchar2(2000);
  v_category  varchar2(40);
  v_subcategory varchar2(40);
  v_item  varchar2(40);
  v_requester_email varchar2(40);
  v_proxy varchar2(40) null;
  l_start_date date;
  l_end_date date;
  L_old_end_date date;
  v_user_profile varchar2(100);
  v_user_profile_tmp varchar2(100);
  v_hr_approver varchar2(100);
  l_office  varchar2(100);
  l_old_office varchar2(100);
  l_department  varchar2(100);
  l_old_department varchar2(100);
  l_manager  varchar2(100);
  l_old_manager varchar2(100);
  l_job_title  varchar2(100);
  l_old_job_title varchar2(100);
  l_comments varchar2(400);
  
  begin
  
  v_subject := 'Changes to User in '||wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE') ||' Office - '
            || wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME')||' '
            || wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME');
  
  l_start_date:=wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE');
  l_end_date:=wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE');
  l_old_end_date:=wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_END_DATE');
  
  v_description := '';
  
  if l_end_date <> l_old_end_date then 
  v_description := v_description||'Employee End Date changed to '||l_end_date||'.';
  end if;
  
  l_office := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE');
  l_old_office := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_OFFICE');
  
  if l_office <> l_old_office then
  v_description := v_description||'Office changed to '||l_office||' Office.';
  end if;
  
  l_department := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DEPARTMENT');
  l_old_department := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_DEPARTMENT');
  
  if l_department <> l_old_department then
  v_description := v_description||'Department changed to '||l_department||'.';
  end if;
  
  l_manager := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER');
  l_old_manager := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_MANAGER');

  if l_manager <> l_old_manager then
  v_description := v_description||'Manager changed to '||l_manager||'.';
  end if;
  
  l_job_title := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE');
  l_old_job_title := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_JOB_TITLE');

  if l_job_title <> l_old_job_title then
  v_description := v_description||'Job Title changed to '||l_job_title||'.';
  end if;
 
 l_comments := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OTHER_COMMENTS');
  
  if l_comments is not null then
  v_description := v_description||'Other Comments:'||l_comments||'.';
  end if;
  
  v_category    := null;
  v_subcategory := null;
  v_item        := null;
  
  
  v_hr_approver := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'HR_APPROVER');
  
  select email_address 
  into v_requester_email
  from fnd_user
  where user_name = v_hr_approver;
  
  
  v_user_profile_tmp := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'USER_PROFILE');
  
  select lookup_code
  into v_user_profile
  from FND_LOOKUP_VALUES
  where LOOKUP_TYPE = 'AWAS_USER_PROFILE'
  and meaning = v_user_profile_tmp;
  
  
  
  
  xx_raise_me_ticket(    v_subject,
                         v_description,
                         v_category,
                         v_subcategory,
                         v_item,
                         v_requester_email,
                         v_proxy,
                         'Mover Template');
  
  
  
  
  
  end call_helpdesk_api2;

END XX_PERSON_WF;
/
