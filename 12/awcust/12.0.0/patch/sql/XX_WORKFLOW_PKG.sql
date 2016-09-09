SET DEFINE OFF;

CREATE OR REPLACE PACKAGE XX_WORKFLOW_PKG AS
/******************************************************************************
--NAME:     XX_WORKFLOW_PKG
--PURPOSE:  Used by New Person Workflow
--REVISIONS:
--Ver        Date        Author           Description
-----------  ----------  ---------------  ------------------------------------
--1.0        30/10/2011  S Joyce          1. Created this package.
--2.0        26/07/2013  S Joyce          R12 Adjustments
******************************************************************************/
PROCEDURE new_person_start
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE set_mgr
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 );

PROCEDURE set_cs
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 );

PROCEDURE set_is
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 );

PROCEDURE is_approv_comp
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 );

 Procedure Resp_Mgr
      (
          itemtype IN VARCHAR2
          ,itemkey  IN VARCHAR2
          ,actid    IN NUMBER
          ,funcmode IN VARCHAR2
          ,RESULT   IN OUT VARCHAR2);

PROCEDURE resp_cs(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

PROCEDURE resp_is(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

PROCEDURE business_cards(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

PROCEDURE create_person_oracle(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);


PROCEDURE create_person_external(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

PROCEDURE request_roles(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);



PROCEDURE terminate_user( x_error_message OUT VARCHAR2
                                , X_Error_Code    Out Number);

PROCEDURE create_fyi_role   (itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              Result In Out Varchar2
                              ) ;

FUNCTION get_role_for_user_email(
                                 p_user                     IN       VARCHAR2
                                ,p_email                    IN       VARCHAR2 )
                                RETURN VARCHAR2 ;

FUNCTION create_role_email  ( p_user  IN VARCHAR2
                              ,P_Email In Varchar2  )
                              RETURN VARCHAR2;

PROCEDURE update_person_start(itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2,
                                actid    IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2 );

PROCEDURE xx_p_up_approval_path
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 );

PROCEDURE xx_p_up_mgr_resp(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

PROCEDURE xx_p_up_is_resp(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

  PROCEDURE xx_p_up_bc_req(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

  PROCEDURE xx_p_up_sync_oracle(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

 PROCEDURE xx_p_up_sync_external(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2);

PROCEDURE change_details_doc( itemkey		IN VARCHAR2 ,
               display_type		IN VARCHAR2 DEFAULT 'text/html',
               document		IN OUT	NOCOPY VARCHAR2,
               document_type	IN OUT	NOCOPY VARCHAR2
);


PROCEDURE start_fyi
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          Actid    In Number,
          Funcmode In Varchar2,
          Resultout Out Nocopy Varchar2 )    ;

END XX_WORKFLOW_PKG;
/


CREATE OR REPLACE PACKAGE BODY XX_WORKFLOW_PKG AS
---------------------------------------------------------------------------------
--PROCEDURE new_person_start
--This procedures extract the XML data into workflow attributes for processing
---------------------------------------------------------------------------------

PROCEDURE new_person_start
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 )
IS
     change_event_document         CLOB;
     event                         wf_event_t;
     xmldoc                        xmldom.domdocument;
     parser                        xmlparser.parser;
     v_record_type                 VARCHAR2 ( 500 ) ;
     v_created_by                  VARCHAR2 (100);
     v_first_name                 VARCHAR2 (100);
     v_last_name                  VARCHAR2 (100);
     v_line_manager                    VARCHAR2 (100);
     v_expenses_approver                    VARCHAR2 (100);
     v_office                          VARCHAR2 (100);
     v_cost_center                     VARCHAR2 (100);
     v_job_title                      VARCHAR2 (100);
     v_employee_type                   VARCHAR2 (100);
     v_start_date                      date;
     v_end_Date                         date;
     v_pc_type                         VARCHAR2 (100);
     v_desk_location                   VARCHAR2 (100);
     v_department                      VARCHAR2 (100);
     v_other_comments                   VARCHAR2 (250);
     v_mobile_device                   VARCHAR2 (1);
     v_business_cards                  VARCHAR2 (1);
BEGIN
     IF ( funcmode = 'RUN' ) THEN

     dbms_output.put_line('1');

          select distinct u.user_name
          into v_created_by
          from fnd_user u,
               xx_person_details x
          WHERE u.user_id = x.created_by
          and x.person_id = to_number(itemkey);

     dbms_output.put_line('2');
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CREATED_BY', avalue => v_created_by ) ;

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'HR_APPROVER', avalue => v_created_by ) ;


          event := wf_engine.getitemattrevent ( itemtype => itemtype, itemkey => itemkey, NAME => 'EVENT_PAYLOAD' ) ;
          change_event_document   := event.geteventdata ( ) ;


          v_record_type := irc_xml_util.valueof ( change_event_document, '/new_person/record_type' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'RECORD_TYPE', avalue => v_record_type ) ;


          v_last_name := irc_xml_util.valueof ( change_event_document, '/new_person/last_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME', avalue => v_last_name ) ;


          v_first_name := irc_xml_util.valueof ( change_event_document, '/new_person/first_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME', avalue => v_first_name ) ;


          v_start_date := irc_xml_util.valueof ( change_event_document, '/new_person/start_date' ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE', avalue => v_start_date ) ;

          dbms_output.put_line(v_start_Date);

          v_end_date := irc_xml_util.valueof ( change_event_document, '/new_person/end_date' ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE', avalue => v_end_date ) ;
           dbms_output.put_line(v_end_Date);

          v_pc_type := irc_xml_util.valueof ( change_event_document, '/new_person/pc_type' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PC_TYPE', avalue => v_pc_type ) ;
          dbms_output.put_line(v_pc_type);

          v_office := irc_xml_util.valueof ( change_event_document, '/new_person/office' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE', avalue => v_office ) ;

          v_cost_center := irc_xml_util.valueof ( change_event_document, '/new_person/cost_center' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COST_CENTER', avalue => v_cost_center ) ;

          v_line_manager := irc_xml_util.valueof ( change_event_document, '/new_person/manager' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER', avalue => v_line_manager ) ;

          dbms_output.put_line(v_line_manager);

          select replace(full_name,',','')
          into v_line_manager
          FROM PER_ALL_PEOPLE_F
          where replace(replace(last_name,'''',''),',','') = v_line_manager;

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER_APPROVER', avalue => v_line_manager ) ;

          v_expenses_approver := irc_xml_util.valueof ( change_event_document, '/new_person/expenses_approver' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EXPENSES_APPROVER', avalue => v_expenses_approver ) ;

          v_job_title := irc_xml_util.valueof ( change_event_document, '/new_person/job_title' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE', avalue => v_job_title ) ;

          v_employee_type := irc_xml_util.valueof ( change_event_document, '/new_person/employee_type' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMPLOYEE_TYPE', avalue => v_employee_type ) ;

          v_pc_type := irc_xml_util.valueof ( change_event_document, '/new_person/pc_type' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PC_TYPE', avalue => v_pc_type ) ;

          v_mobile_device := irc_xml_util.valueof ( change_event_document, '/new_person/mobile_device' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MOBILE_DEVICE', avalue => v_mobile_device ) ;

          v_business_cards := irc_xml_util.valueof ( change_event_document, '/new_person/business_cards' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BUSINESS_CARDS', avalue => v_business_cards ) ;


          v_desk_location := irc_xml_util.valueof ( change_event_document, '/new_person/desk_location' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DESK_LOCATION', avalue => v_desk_location ) ;

          v_other_comments := irc_xml_util.valueof ( change_event_document, '/new_person/other_comments' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OTHER_COMMENTS', avalue => v_other_comments ) ;

          select department
          into v_department
          from xx_person_details
          where person_id = itemkey;

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DEPARTMENT', avalue => v_department ) ;


    END IF;

END new_person_start;
---------------------------------------------------------------------------------
--PROCEDURE set_mgr
--This procedures set the line status to Awaiting manager approval.
---------------------------------------------------------------------------------
PROCEDURE set_mgr
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 ) is

  BEGIN

    IF funcmode = 'RUN'
    THEN

    update xx_person_details
    set status = 'Awaiting Manager Approval',
        person_with = line_manager
    WHERE  person_id = to_number(itemkey);

    RESULT := 'COMPLETE:Y';

    end if;

  END set_mgr;

---------------------------------------------------------------------------------
--PROCEDURE set_cs
--This procedures set the line status to Awaiting CS (Corporate Services) approval.
--It also sets the Approver attribute
---------------------------------------------------------------------------------
PROCEDURE set_cs
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 )  is

    l_approver             varchar2(40);
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    N_NOTIFICATION_API_ID  NUMBER;
    L_OFFICE            VARCHAR2(200);
    l_role                Varchar2(200);

  BEGIN

    IF funcmode = 'RUN'
    THEN

    L_OFFICE := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'OFFICE' ) ;
    -- check office and set approver role


    SELECT DECODE(upper(L_OFFICE),
                  'DUBLIN',   'FND_RESP20003:50843',
                  'MIAMI',    'FND_RESP20003:50922',
                  'NEW YORK', 'FND_RESP20003:50923',
                  'SINGAPORE','FND_RESP20003:50924')
    INTO L_ROLE
    from dual;



    WF_ENGINE.SETITEMATTRTEXT( itemtype => itemtype, itemkey => itemkey, aname => 'OS_APPROVER', avalue => L_ROLE ) ;

    -- GET NEXT APPROVER
     l_approver := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OS_APPROVER' ) ;

    -- Update relevant record
    update xx_person_details
    SET STATUS = 'Awaiting Corporate Services Approval',
        person_with = (select substr(DISPLAY_NAME, 1, instr(display_name,':')-1) FROM WF_ROLES where name = l_approver),
        manager_response = 'Approved',
        manager_response_date = sysdate
    WHERE  person_id = to_number(itemkey);

    RESULT := 'COMPLETE:APPROVED';

    End If;

  END set_cs;
---------------------------------------------------------------------------------
--PROCEDURE set_is
--This procedures set the line status to Awaiting IS (Information Systems) approval.
--It also sets the Approver attribute
---------------------------------------------------------------------------------

PROCEDURE set_is
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 )  is

    l_approver varchar2(40);

  BEGIN

    IF funcmode = 'RUN'
    THEN

    l_approver := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'IT_APPROVER' ) ;

    update xx_person_details
    Set Status = 'Awaiting IS Approval',
        person_with = l_approver,
        Cs_Response = 'Approved',
        cs_response_date = sysdate
    WHERE  person_id = to_number(itemkey);

    Result := 'COMPLETE:APPROVED';

    End If;

  End Set_Is;
---------------------------------------------------------------------------------
--PROCEDURE is_approv_comp
--This procedures set the line status to Complete
---------------------------------------------------------------------------------

PROCEDURE is_approv_comp
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 )  is

    l_approver varchar2(40);

  BEGIN

    IF funcmode = 'RUN'
    THEN


    -- THEN SET APPROVAL HISTORY
    UPDATE XX_PERSON_DETAILS
      SET    it_response = 'APPROVED',
             it_response_date = sysdate,
             person_with = null
      WHERE  person_id = to_number(itemkey);

    RESULT := 'COMPLETE:APPROVED';
    End If;
  END is_approv_comp;
---------------------------------------------------------------------------------
--PROCEDURE resp_mgr
--This procedures sets the Managers Response to the attributes
---------------------------------------------------------------------------------
PROCEDURE resp_mgr(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    l_responder            VARCHAR2(50);
    v_response_reason      VARCHAR2(100);
    V_Copy_From_User       Varchar2(50);
    v_emp_type             varchar2(50);

  BEGIN
    IF (funcmode IN ('RESPOND','RUN'))
    THEN
      L_Nid := Wf_Engine.Context_Nid;
      V_Emp_Type := Wf_Notification.Getattrtext(L_Nid,'EMPLOYEE_TYPE');
       v_copy_from_user := wf_notification.getattrtext(l_nid,'COPY_FROM_USER');
      v_response_reason := wf_notification.getattrtext(l_nid,'RESPONSE_REASON');


     Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid
     And na.Name = 'RESULT';

     /*  Following select changed to std function for context
      select responder
      into l_responder
      from wf_notifications
      where notification_id = wf_engine.context_nid;
     */

      l_responder := wf_engine.context_user;

      if l_activity_result_Code is null
      THEN
        RESULT := 'ERROR: Result code null';
        RETURN;
      END IF;

      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULT := 'ERROR: You must enter rejection reason if rejecting.';
        RETURN;
      END IF;

      if upper(v_emp_type) not in ( 'AUDITOR','TEMP','CONTRACTOR') then
      IF v_copy_from_user is null and l_activity_result_code = 'APPROVED'
      THEN
        Result := 'ERROR: You must enter an employee name in the "Set user access the same as" field below.';
        RETURN;
      End If;
      end if;

      update xx_person_details
      set approval_comments = v_response_reason,
          manager_response = l_activity_result_code,
          copy_user_from = v_copy_from_user,
          manager_approver = l_responder
      where person_id = to_number(itemkey);

      wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'ROLE_COPIED_FROM',avalue =>v_copy_from_user);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RESULT := SQLERRM;
  END resp_mgr;
---------------------------------------------------------------------------------
--PROCEDURE resp_cs
--This procedures sets the Corporate Services Response to the attributes
---------------------------------------------------------------------------------
PROCEDURE resp_cs(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    l_responder            VARCHAR2(50);
    v_mobile      VARCHAR2(50);
    l_mob    VARCHAR2(1);
  BEGIN
    IF (funcmode IN ('RESPOND','RUN'))
    THEN
      l_nid := wf_engine.context_nid;

      /* commented out following stmt to use std funciton for context
      select responder
      into l_responder
      from wf_notifications
      where notification_id = wf_engine.context_nid;
      */

      l_responder := wf_engine.context_user;

      v_mobile := wf_notification.getattrtext(l_nid,'MOBILE_NUMBER');


      select mobile_device
      into l_mob
      from xx_person_details
      where person_id = to_number(itemkey);


      IF l_mob = 'Y' AND
         v_mobile IS NULL
      THEN
        RESULT := 'ERROR: You must enter the employees Mobile Number to proceed.';
        RETURN;
      END IF;

      update xx_person_details
      set mobile_number = v_mobile,
          cs_approver = l_responder
      where person_id = to_number(itemkey);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RESULT := SQLERRM;


  END resp_cs;
---------------------------------------------------------------------------------
--PROCEDURE resp_is
--This procedures sets the Information Systems Response to the attributes
---------------------------------------------------------------------------------
PROCEDURE resp_is(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    l_responder  varchar2(50);
    V_Mobile      Varchar2(50);
    v_ad_Account  varchar2(40);
    v_email      VARCHAR2(60);
    l_mob    VARCHAR2(1);
  BEGIN
    IF (funcmode IN ('RESPOND','RUN'))
    THEN
      l_nid := wf_engine.context_nid;



     Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid
     And na.Name = 'RESULT';


     if l_activity_result_Code is null
      THEN
        RESULT := 'ERROR: Result code null';
        RETURN;
      END IF;

      l_responder := wf_engine.context_user;
      v_mobile := wf_notification.getattrtext(l_nid,'DESK_NUMBER');
      V_Email  := Wf_Notification.Getattrtext(L_Nid,'EMAIL');
      v_ad_Account := wf_notification.getattrtext(l_nid,'AD_ACCOUNT');


     IF l_activity_result_code = 'APPROVED'
     THEN

     If V_Ad_Account Is Null
     Then
        RESULT := 'ERROR: You must enter the new employees AD Account to proceed.';
        Return;
     END if;

      IF v_mobile IS NULL

      THEN
        RESULT := 'ERROR: You must enter a Desk Telephone Number to proceed.';
        RETURN;
      END IF;

      IF v_email is null
    THEN
        RESULT := 'ERROR: You must enter an email address to proceed.';
        RETURN;
      END IF;

    update xx_person_details
    set email = v_email,
        desk_number = v_mobile,
        it_approver = l_responder
    where person_id = to_number(itemkey);


    END IF;
      END IF;


  EXCEPTION
    WHEN OTHERS THEN
      RESULT := SQLERRM;
  END resp_is;
---------------------------------------------------------------------------------
--PROCEDURE business_cards
--This procedures check to see if business cards need to be ordered
---------------------------------------------------------------------------------
PROCEDURE business_cards(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS

  l_chk    VARCHAR2(1);
  BEGIN
    IF (funcmode IN ('RUN')) THEN
    l_chk := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BUSINESS_CARDS' ) ;
    if l_chk = 'Y' then
    RESULT := 'COMPLETE:Y';
    RETURN;
    end if;
    RESULT := 'COMPLETE:N';
    end if;
  end business_cards;
---------------------------------------------------------------------------------
--PROCEDURE create_person_oracle
--This procedures create the person in Oracle
---------------------------------------------------------------------------------
PROCEDURE create_person_oracle(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) is

v_person_id NUMBER;
v_first_name varchar2(100);
v_last_name varchar2(100);

v_assignment_id NUMBER;
v_per_object_version_number NUMBER;
v_asg_object_version_number NUMBER;
v_per_effective_start_date DATE;
v_per_effective_end_date DATE;
v_per_comment_id NUMBER;
v_assignment_sequence NUMBER;
v_assignment_number VARCHAR2(1000);
v_name_combination_warning BOOLEAN;
v_assign_payroll_warning BOOLEAN;
v_orig_hire_warning BOOLEAN;
v_full_name VARCHAR2(1000);
/*Following Variable is In and Out Parameter*/
v_eno VARCHAR2(2000);
v_ent varchar2(4);
v_manager varchar2(50);
v_title varchar2(50);
v_expenses_approver varchar2(1);
v_location varchar2(50);
v_email varchar2(60);
v_cost_center varchar2(4);
l_code_comb number;
v_party_id number;


  X_USER_NAME VARCHAR2(200);
  X_OWNER VARCHAR2(200);
  X_UNENCRYPTED_PASSWORD VARCHAR2(200);
  X_SESSION_NUMBER NUMBER;
  X_START_DATE DATE;
  X_END_DATE DATE;
  X_LAST_LOGON_DATE DATE;
  X_DESCRIPTION VARCHAR2(200);
  X_PASSWORD_DATE DATE;
  X_PASSWORD_ACCESSES_LEFT NUMBER;
  X_PASSWORD_LIFESPAN_ACCESSES NUMBER;
  X_PASSWORD_LIFESPAN_DAYS NUMBER;
  X_EMPLOYEE_ID NUMBER;
  X_EMAIL_ADDRESS VARCHAR2(200);
  X_FAX VARCHAR2(200);
  X_CUSTOMER_ID NUMBER;
  X_SUPPLIER_ID NUMBER;
  l_Style VARCHAR2(6);
  l_country VARCHAR2(2);
  x_address_id        NUMBER;
  x_obj_no            NUMBER;
  x_errm              VARCHAR2(100);
  sj_tmp              number;
  sj_tmp2             number;

  CURSOR oracle_exists (P_ad_account VARCHAR2)
  is (select user_id from fnd_user where user_name = upper(p_ad_account));




BEGIN
 IF (funcmode IN ('RUN')) THEN

v_first_name                  := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME' ) ;
v_last_name                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME' ) ;
v_per_effective_start_date    := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE' ) ;
v_per_effective_end_date      := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE' ) ;
v_manager                     := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER' ) ;
v_expenses_approver           := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EXPENSES_APPROVER');
v_title                       := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE');
v_location                    := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE');
v_eno                         := 'X'||to_number(itemkey)||'X';
v_email                       := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMAIL' ) ;
v_cost_center                 := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COST_CENTER');
v_full_name                   := v_first_name||' '||v_last_name;
x_user_name                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'AD_ACCOUNT' ) ;

dbms_output.put_line('x_user_name='||x_user_name);


select count(user_id)
into sj_tmp
from fnd_user
where user_name = upper(x_user_name);

IF sj_tmp = 0 THEN

dbms_output.put_line('Checking if employee exists...');

select count(person_id)
into sj_tmp2
from per_all_people_f
where
employee_number = v_eno;

if sj_tmp2 = 0 then

dbms_output.put_line('Creating Employee as employee does not exist...');
hr_employee_api.create_employee(
                     p_validate                   => false
                    ,p_hire_date                  => nvl(v_per_effective_start_date,sysdate)
                    ,p_business_group_id          => 0
                    ,p_last_name                  => v_first_name||' '||v_last_name
                    ,p_sex                        => 'M'
                    ,p_person_type_id             => 6 -- CHECK THIS
                    ,p_date_of_birth              => '01-JAN-1951'
                    ,p_employee_number            => v_eno
                    ,p_first_name                 => null
                    ,p_coord_ben_no_cvg_flag      => 'N'
                    ,p_dpdnt_vlntry_svce_flag     => 'N'
                    ,p_attribute2                 => 'N'
                    ,p_person_id                  => v_person_id
                    ,p_assignment_id              => v_assignment_id
                    ,p_per_object_version_number  => v_per_object_version_number
                    ,p_asg_object_version_number  => v_asg_object_version_number
                    ,p_per_effective_start_date   => v_per_effective_start_date
                    ,p_per_effective_end_date     => v_per_effective_end_date
                    ,p_full_name                  => v_full_name
                    ,p_per_comment_id             => v_per_comment_id
                    ,p_assignment_sequence        => V_assignment_sequence
                    ,p_assignment_number          => v_assignment_number
                    ,p_name_combination_warning   => v_name_combination_warning
                    ,p_assign_payroll_warning     => v_assign_payroll_warning
                    ,p_orig_hire_warning          => v_orig_hire_warning);





dbms_output.put_line('Employee creation completed.');
dbms_output.put_line('Person_id = '||v_person_id);

end if;



IF v_person_id is not NULL THEN
-- store per_all_people_f person_id in custom table
            update xx_person_details
            set pap_person_id = v_person_id
            Where Person_Id = To_Number(Itemkey);


-- reset end date
           v_per_effective_end_date  := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE' ) ;


-- set email address
            update per_all_people_f
            set email_address = v_email
            where person_id = v_person_id;


-- Get location Id
            select decode(v_location,'Dublin','1802','Singapore','1804','New York','1801','Miami','1801','1802')
            into v_ent
            from dual;

-- Get GL COde Combination
          l_code_comb := XX_VALID_GL_CODE(v_ent,'571105',v_cost_center,'000000','000',v_ent,'0000');

-- Create the Address
    SELECT decode(v_location,'Dublin','IE_GLB','Singapore','SG_GLB','US_GLB'),
           decode(v_location,'Dublin','IE','Singapore','SG','US')
    INTO l_Style,
         l_country
    from dual;

     hr_person_address_api.create_person_address(p_validate                => FALSE
                                                    ,p_effective_date          => SYSDATE
                                                    ,p_validate_county         => FALSE
                                                    ,p_person_id               => v_person_id
                                                    ,p_primary_flag            => 'Y'
                                                    ,p_style                   => l_style
                                                    ,p_date_from               => v_per_effective_start_date
                                                    ,p_address_line1           => v_email
                                                    ,p_country                 => l_country
                                                    ,p_address_id              => x_address_id
                                                    ,p_object_version_number   => x_obj_no
                                                    ,p_date_to                 => NULL
                                                    ,p_address_type            => NULL
                                                    ,p_comments                => NULL);


-- update Assignments
            update per_all_assignments_f
            set      set_of_books_id = 8
                   ,default_code_comb_id = l_code_comb
                   ,supervisor_id = (SELECT person_id FROM per_all_people_f WHERE REPLACE(last_name,'''','') = REPLACE(v_manager,'''',''))
                   ,ass_attribute1 = (select person_id from per_all_people_f where replace(last_name,'''','') = replace(v_manager,'''',''))
                   ,location_id = decode(v_location,'Dublin',1728,'Singapore',1729,'New York',1730,'Miami',1731,1728)
                   ,Job_Id =  Decode(V_Expenses_Approver,'Y',26,28)
                   ,Title = substr(V_Title,1,30)
            where person_id = (select pap_person_id from xx_person_details where person_id = To_Number(Itemkey));

-- Now create the User

           select party_id
           into v_party_id
           From Hz_Parties
           where person_identifier = (select pap_person_id from xx_person_details where person_id = To_Number(Itemkey));






    If V_Person_Id Is Null Then
                  Select Pap_Person_Id
                  Into V_Person_Id
                  From Xx_Person_Details Where Person_Id = To_Number(Itemkey);
    end if;

  X_OWNER := 'CUST';
  X_UNENCRYPTED_PASSWORD := 'BOEING747';
  X_SESSION_NUMBER := NULL;
  X_START_DATE := v_per_effective_start_date;
  X_END_DATE :=   v_per_effective_end_date;
  X_LAST_LOGON_DATE := NULL;
  X_DESCRIPTION := v_first_name||' '||v_last_name;
  X_PASSWORD_DATE := NULL;
  X_PASSWORD_ACCESSES_LEFT := NULL;
  X_PASSWORD_LIFESPAN_ACCESSES := NULL;
  X_PASSWORD_LIFESPAN_DAYS := NULL;
  X_EMPLOYEE_ID := v_person_id;
  X_EMAIL_ADDRESS := v_email;
  X_FAX := NULL;
  X_CUSTOMER_ID := NULL;
  X_SUPPLIER_ID := NULL;

  FND_USER_PKG.CREATEUSER(
    X_USER_NAME => X_USER_NAME,
    X_OWNER => X_OWNER,
    X_UNENCRYPTED_PASSWORD => X_UNENCRYPTED_PASSWORD,
    X_SESSION_NUMBER => X_SESSION_NUMBER,
    X_START_DATE => X_START_DATE,
    X_END_DATE => X_END_DATE,
    X_LAST_LOGON_DATE => X_LAST_LOGON_DATE,
    X_DESCRIPTION => X_DESCRIPTION,
    X_PASSWORD_DATE => X_PASSWORD_DATE,
    X_PASSWORD_ACCESSES_LEFT => X_PASSWORD_ACCESSES_LEFT,
    X_PASSWORD_LIFESPAN_ACCESSES => X_PASSWORD_LIFESPAN_ACCESSES,
    X_PASSWORD_LIFESPAN_DAYS => X_PASSWORD_LIFESPAN_DAYS,
    X_EMPLOYEE_ID => X_EMPLOYEE_ID,
    X_EMAIL_ADDRESS => X_EMAIL_ADDRESS,
    X_FAX => X_FAX,
    X_CUSTOMER_ID => X_CUSTOMER_ID,
    X_SUPPLIER_ID => X_SUPPLIER_ID
  );

   Update Xx_Person_Details
   set user_id = (select user_id from fnd_user where user_name = upper(X_USER_NAME))
   where person_id = itemkey;

END IF;

ELSE
  UPDATE Xx_Person_Details
   SET user_id = sj_tmp
   where person_id = itemkey;

     UPDATE xx_person_details
      SET pap_person_id = (SELECT EMPLOYEE_ID FROM FND_USER WHERE USER_NAME = upper(X_USER_NAME))
       Where Person_Id = To_Number(Itemkey);

END IF;



   RESULT := 'COMPLETE:Y';

end if;

 EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);

      RESULT := SQLERRM;

  END create_person_oracle;
---------------------------------------------------------------------------------
--PROCEDURE create_person_external
--This procedures create the person in other systems
---------------------------------------------------------------------------------
PROCEDURE create_person_external(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) is

  IORG_ID NUMBER;
  ISTATUS_CODE NUMBER;
  ISOURCE_CODE NUMBER;
  ICAT_CODE NUMBER;
  ISALUT_CODE NUMBER;
  IPER_SOURCE_DETAIL VARCHAR2(200);
  IPER_FNAME VARCHAR2(200);
  IPER_MNAME VARCHAR2(200);
  IPER_LNAME VARCHAR2(200);
  IPER_DOB DATE;
  IPER_MANAGER VARCHAR2(200);
  IPER_ASSISTANT VARCHAR2(200);
  IPER_JOBTITLE VARCHAR2(200);
  IPER_NOTE VARCHAR2(200);
  IPER_LOGAGAINSTORGYN NUMBER;
  IPER_DATEENTERED DATE;
  IPER_DATEMODIFIED DATE;
  IPER_DOCUMENTDIRNAME VARCHAR2(200);
  IMODIFIED_TM DATE;
  ISUFFIX_CODE NUMBER;
  IDLEVEL_CODE NUMBER;
  IPER_OL_FNAME VARCHAR2(200);
  IMODIFIED_BY NUMBER;
  ICREATED_BY NUMBER;
  ICREATED_TM DATE;
  IAWW_OWNER_ID NUMBER;
  IPER_MANAGER_PERSON_ID NUMBER;
  IPER_SCD_MANAGER_PERSON_ID NUMBER;
  OPERSON_ID NUMBER;
  OERRORCODE NUMBER;
  OERRORMESSAGE VARCHAR2(200);
  L_CREATED_BY VARCHAR2(60);
  L_CREATED_BY_ID NUMBER;
  v_email varchar2(60);
  v_user_name varchar2(40);
  v_address_id number;
  v_location  varchar2(40);
  v_person_role_id number;
  v_bus_tel varchar2(20);
  v_mob_tel varchar2(20);
  IPERSON_ID NUMBER;
  ISTAFF_ACTIVEYN NUMBER;
  ISTAFF_NOTE VARCHAR2(200);
  IPERSON_ID NUMBER;
  IPHTYPE_CODE NUMBER;
  IPERPH_COUNTRYCODE VARCHAR2(200);
  IPERPH_AREACODE VARCHAR2(200);
  Iperph_Number Varchar2(200);
  L_PERSON_ID NUMBER;
  duplicate_count number;


Begin
v_email                      := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMAIL' ) ;
v_location                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE' ) ;
IPER_FNAME                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME' ) ;
IPER_LNAME                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME' ) ;
IPER_JOBTITLE                := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE' ) ;
IPER_DATEENTERED             := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE' ) ;
Iper_Manager                 := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'MANAGER' ) ;
l_person_id                 := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID' ) ;


l_created_by                    := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CREATED_BY' ) ;

  SELECT COUNT(*)
  into duplicate_count
  from tblperson@basin where per_fname = IPER_FNAME and per_lname = IPER_LNAME;

  dbms_output.put_line('duplicate_count'||duplicate_count);

  if duplicate_count = 0 then

     dbms_output.put_line('duplicate_count = 0 so getting attributes');

  select to_number(p.attribute1)
    into l_created_by_id
    from per_all_people_f p,
    fnd_user u
    where person_id = u.employee_id
    and u.user_name = l_created_by;

    dbms_output.put_line('created_by_id ='||l_created_by_id);

  IMODIFIED_BY := l_created_by_id;
  ICREATED_BY := l_created_by_id;
  ICREATED_TM := sysdate;
  IMODIFIED_TM := sysdate;
  IPER_DATEMODIFIED := sysdate;

    dbms_output.put_line('Secondary Attributes Set');
    dbms_output.put_line('Using ItemKey='||itemkey);


        select to_number(m.attribute1)
        into IPER_MANAGER_PERSON_ID
        from fnd_user u,
        xx_person_details x,
        per_all_people_f p,
        per_all_people_f m,
        per_all_assignments_f a
        where p.person_id = u.employee_id
        and a.person_id = p.person_id
        and a.supervisor_id = m.person_id
        AND x.user_id = u.user_id
        and x.person_id = to_number(itemkey)
        ;

  dbms_output.put_line ('IPER_MANAGER_PERSON_ID'||IPER_MANAGER_PERSON_ID);

  IPER_SOURCE_DETAIL := 'Oracle';
  IORG_ID := 10000;
  ISTATUS_CODE := 1;
  ISOURCE_CODE := NULL;
  ICAT_CODE := NULL;
  ISALUT_CODE := NULL;
  IPER_MNAME := NULL;
  IPER_DOB := NULL;
  IPER_ASSISTANT := NULL;
  IPER_NOTE := NULL;
  IPER_LOGAGAINSTORGYN := NULL;
  IPER_DOCUMENTDIRNAME := NULL;
  ISUFFIX_CODE := NULL;
  IDLEVEL_CODE := NULL;
  IPER_OL_FNAME := NULL;
  IAWW_OWNER_ID := NULL;
  IPER_SCD_MANAGER_PERSON_ID := NULL;



  PKGPERSON.STPINSERT@BASIN(
    IORG_ID => IORG_ID,
    ISTATUS_CODE => ISTATUS_CODE,
    ISOURCE_CODE => ISOURCE_CODE,
    ICAT_CODE => ICAT_CODE,
    ISALUT_CODE => ISALUT_CODE,
    IPER_SOURCE_DETAIL => IPER_SOURCE_DETAIL,
    IPER_FNAME => IPER_FNAME,
    IPER_MNAME => IPER_MNAME,
    IPER_LNAME => IPER_LNAME,
    IPER_DOB => IPER_DOB,
    IPER_MANAGER => IPER_MANAGER,
    IPER_ASSISTANT => IPER_ASSISTANT,
    IPER_JOBTITLE => IPER_JOBTITLE,
    IPER_NOTE => IPER_NOTE,
    IPER_LOGAGAINSTORGYN => IPER_LOGAGAINSTORGYN,
    IPER_DATEENTERED => IPER_DATEENTERED,
    IPER_DATEMODIFIED => IPER_DATEMODIFIED,
    IPER_DOCUMENTDIRNAME => IPER_DOCUMENTDIRNAME,
    IMODIFIED_TM => IMODIFIED_TM,
    ISUFFIX_CODE => ISUFFIX_CODE,
    IDLEVEL_CODE => IDLEVEL_CODE,
    IPER_OL_FNAME => IPER_OL_FNAME,
    IMODIFIED_BY => IMODIFIED_BY,
    ICREATED_BY => ICREATED_BY,
    ICREATED_TM => ICREATED_TM,
    IAWW_OWNER_ID => IAWW_OWNER_ID,
    IPER_MANAGER_PERSON_ID => IPER_MANAGER_PERSON_ID,
    IPER_SCD_MANAGER_PERSON_ID => IPER_SCD_MANAGER_PERSON_ID,
    OPERSON_ID => OPERSON_ID,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );

dbms_output.put_line(OERRORCODE);
dbms_output.put_line(OERRORMESSAGE);


  update per_all_people_f
  set attribute1 = OPERSON_ID
  where person_id = (select employee_id from fnd_user u, xx_person_details x where u.user_id = x.user_id and x.person_id = itemkey);

  update xx_person_details
  set external_person_id = operson_id
  where person_id =  itemkey;


  insert into tblperemailaddress@basin
        (person_id, peremail_number,peremail_address,peremail_note,primary_addryn)
  values ( OPERSON_ID,
         1,
         v_email,
         null,
         1);

  select lower(upper(substr(iper_fname,1,1)||iper_lname))
           into v_user_name
           from dual;


  insert into tblsecurity_prt@basin(Person_id, SYSTEM_ID, SYSTEM_NAME, USER_ID, PASSWORD)
  VALUES (OPERSON_ID, 1,'PLUMTREE','AWAS-SYD-DOM1\'||v_user_name, null);


  select decode(v_location,'Dublin',9,'Singapore',693,'New York',5,'Miami',6,9)
  into v_address_id
  from dual;

  insert into tblperaddress_prt@basin (person_id, addr_type_code, address_id, recstatus_cd, default_yn)
  values ( OPERSON_ID, 10, v_address_id,1,1);

  select person_role_id
  into v_person_role_id
  from tlkppersonrole@basin r,
  xx_person_details p
  where r.awas_dept_roleYN = 1
  and r.name = p.department
  and p.person_id = itemkey;

  insert into tblpersonRole@basin (person_id,person_role_id) values (OPERSON_ID,v_person_role_id);

  ISTAFF_ACTIVEYN := 1;
  ISTAFF_NOTE := NULL;

  PKGSTAFF.STPINSERT@BASIN(
    IPERSON_ID => OPERSON_ID,
    ISTAFF_ACTIVEYN => ISTAFF_ACTIVEYN,
    ISTAFF_NOTE => ISTAFF_NOTE,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );


  select desk_number, mobile_number
  into v_bus_tel, v_mob_tel
  from xx_person_details
  where person_id = itemkey;


  -- Insert phone numbers
  IPERPH_AREACODE := NULL;

  select decode(v_location,'Dublin','353','Singapore','65','New York','1','Miami','1','1')
  into IPERPH_COUNTRYCODE
  from dual;

  -- Business Phone
  IPHTYPE_CODE := 1;
  IPERPH_NUMBER := v_bus_tel;

  PKGPERPHONE.STPINSERT@BASIN(
    IPERSON_ID => OPERSON_ID,
    IPHTYPE_CODE => IPHTYPE_CODE,
    IPERPH_COUNTRYCODE => IPERPH_COUNTRYCODE,
    IPERPH_AREACODE => IPERPH_AREACODE,
    IPERPH_NUMBER => IPERPH_NUMBER,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );

   -- Mobile Phone
   IF v_mob_tel is not null then
   IPHTYPE_CODE := 3;
   IPERPH_NUMBER := v_mob_tel;

  PKGPERPHONE.STPINSERT@BASIN(
    IPERSON_ID => OPERSON_ID,
    IPHTYPE_CODE => IPHTYPE_CODE,
    IPERPH_COUNTRYCODE => IPERPH_COUNTRYCODE,
    IPERPH_AREACODE => IPERPH_AREACODE,
    IPERPH_NUMBER => IPERPH_NUMBER,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );
   end if;


   Update Xx_Person_Details
   SET STATUS = 'COMPLETE'
   Where Person_Id = to_number(itemkey);

   RESULT := 'COMPLETE:Y';

   ELSE
   RESULT := 'COMPLETE:PERSON ALREADY EXISTS';
   END IF;

   EXCEPTION
    When Others Then
      RESULT := SQLERRM;

  END create_person_external;
---------------------------------------------------------------------------------
--PROCEDURE REQUEST_ROLES
--This procedures request the new roles for the user using the UMX api
---------------------------------------------------------------------------------
PROCEDURE request_roles(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) is


  X_REG_REQUEST_ID NUMBER;
  X_REG_SERVICE_TYPE VARCHAR2(200);
  X_STATUS_CODE VARCHAR2(200);
  X_REQUESTED_BY_USER_ID NUMBER;
  X_REQUESTED_FOR_USER_ID NUMBER;
  X_REQUESTED_FOR_PARTY_ID NUMBER;
  X_REQUESTED_USERNAME VARCHAR2(200);
  X_REQUESTED_START_DATE VARCHAR2(20);
  a_REQUESTED_START_DATE DATE;
  X_REQUESTED_END_DATE varchar2(20);
  a_REQUESTED_END_DATE DATE;
  X_WF_ROLE_NAME VARCHAR2(200);
  X_REG_SERVICE_CODE VARCHAR2(200);
  X_AME_APPLICATION_ID NUMBER;
  X_AME_TRANSACTION_TYPE_ID VARCHAR2(200);
  X_JUSTIFICATION VARCHAR2(200);

  P_COPY_FROM_USER     VARCHAR2(200);
  P_REQUESTED_BY_ID    number;
  P_USER_ID            number;

  L_REG_SERVICE_CODE   VARCHAR2(200);
  L_ROLE_NAME          VARCHAR2(200);

  P_REGISTRATION_DATA APPS.UMX_REGISTRATION_PVT.UMX_REGISTRATION_DATA_TBL;

  X_RETURN_STATUS VARCHAR2(200);
 	X_MESSAGE_DATA  VARCHAR2(200);


  i number;

cursor C1 IS  select reg_service_code,
                    role_name
              from wf_local_user_roles r,
                  umx_reg_services_b s
              where r.role_name = s.wf_role_name
              and r.expiration_date is null
              and r.role_orig_system = 'UMX'
              and reg_service_type = 'ADDITIONAL_ACCESS'
              and end_date is null
              and r.user_name = P_COPY_FROM_USER
              Union
              select Reg_Service_Code,
                    Wf_Role_Name
              From Umx_Reg_Services_B S
              Where S.Reg_Service_Code = 'FND_RESP|SQLAP|OIE_EXPENSE_REP'
              order by 2 desc;


BEGIN
-- get parameters
  P_Copy_From_User     := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'COPY_FROM_USER' ) ;

  if p_copy_from_user is not null then

  SELECT CREATED_BY,
         USER_ID
  into  P_REQUESTED_BY_ID,
        P_USER_ID
  FROM xx_person_details
  where person_id = itemkey;

  dbms_output.put_line('peron_id '||itemkey);
  dbms_output.put_line('P_REQUESTED_BY '||p_REQUESTED_BY_ID);
  dbms_output.put_line('P_USER_ID '||p_USER_ID);


-- Hardcoded Values
  X_REG_REQUEST_ID := NULL;
  X_REG_SERVICE_TYPE := 'ADDITIONAL_ACCESS';
  /*X_STATUS_CODE := 'PENDING';
  X_AME_APPLICATION_ID := 20003;   -- Check in PROD
  X_AME_TRANSACTION_TYPE_ID := 'AWAS_ACCESS';  -- Check in PROD
  X_REQUESTED_USERNAME := NULL; */

-- Person Specific Values
  X_REQUESTED_BY_USER_ID := P_REQUESTED_BY_ID;
  X_REQUESTED_FOR_USER_ID := P_USER_ID;


  select PERSON_PARTY_ID
  INTO X_REQUESTED_FOR_PARTY_ID
  from fnd_user
  where user_id = P_USER_ID;

  A_REQUESTED_START_DATE  := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE' );
  -- convert to character for string variable
  X_REQUESTED_START_DATE  := to_char(a_REQUESTED_START_DATE,'RRRR-MON-DD');
  A_REQUESTED_END_DATE    := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE' );
  -- convert to character for string variable
  X_Requested_End_Date    :=  To_Char(A_Requested_End_Date,'RRRR-MON-DD');
  X_JUSTIFICATION         := 'New Employee - Roles requested based on existing user: '||P_COPY_FROM_USER;


  for R1 IN C1
  LOOP
-- Loop Through Variables
  X_WF_ROLE_NAME     := R1.ROLE_NAME;
  X_REG_SERVICE_CODE := R1.REG_SERVICE_CODE;

  p_REGISTRATION_DATA(1).attr_name := 'reg_service_type';
  p_REGISTRATION_DATA(1).attr_value := X_REG_SERVICE_TYPE;
  p_REGISTRATION_DATA(2).attr_name := 'reg_request_id';
  p_REGISTRATION_DATA(2).attr_value := null;
  p_REGISTRATION_DATA(3).attr_name := 'reg_service_code';
  p_REGISTRATION_DATA(3).attr_value := X_REG_SERVICE_CODE;
  p_REGISTRATION_DATA(4).attr_name :=  'requested_for_user_id';
  p_REGISTRATION_DATA(4).attr_value := X_REQUESTED_FOR_USER_ID;
  p_REGISTRATION_DATA(5).attr_name :=   'requested_by_user_id';
  p_REGISTRATION_DATA(5).attr_value := P_REQUESTED_BY_ID;
  p_REGISTRATION_DATA(6).attr_name :=  'justification';
  p_REGISTRATION_DATA(6).attr_value := X_JUSTIFICATION;
  p_REGISTRATION_DATA(7).attr_name := 'requested_start_date';
  p_REGISTRATION_DATA(7).attr_value := X_REQUESTED_START_DATE;

  if x_requested_end_date is not null then
  p_REGISTRATION_DATA(8).attr_name :=  'requested_end_date';
  p_REGISTRATION_DATA(8).attr_value := X_REQUESTED_END_DATE;

  end if;

  UMX_REGISTRATION_PVT.ASSIGN_ROLE(P_REGISTRATION_DATA => P_REGISTRATION_DATA,
                                   X_RETURN_STATUS   => X_RETURN_STATUS,
                                   X_MESSAGE_DATA    => X_MESSAGE_DATA);




  -- now reset attributes to null
  i := p_registration_data.first;

    -- looping through
    while (i <= p_registration_data.last) loop
    p_registration_data(i).attr_name := null;
    p_registration_data(i).attr_value := null;
          i:=i+1;
    end loop;


    End Loop;

    end if;

   RESULT := 'COMPLETE:Y';

  END request_roles;
---------------------------------------------------------------------------------
--PROCEDURE terminate_user
--This procedures is called by a concurrent request and end dates the user in
-- Oracle and external systems, along with all access roles.
---------------------------------------------------------------------------------
PROCEDURE terminate_user( x_error_message OUT VARCHAR2
                                , x_error_code    OUT NUMBER) is

l_validate_mode BOOLEAN := FALSE;
L_Business_Group_Id Number;
l_employee_no varchar2(15);
l_date1 DATE;

-- API Return Variables

l_person_id NUMBER;
l_assignment_id NUMBER;
l_obj_version_number NUMBER;
l_eff_start_date DATE;
l_eff_end_date DATE;
l_comment_id NUMBER;
l_error_text VARCHAR2(1000);

l_last_standard_process_date DATE;
l_obj_no1 NUMBER;
l_obj_no2 NUMBER;
l_supervisor_warning BOOLEAN;
l_event_warning BOOLEAN;
l_interview_warning BOOLEAN;
l_review_warning BOOLEAN;
l_recruiter_warning BOOLEAN;
l_asg_future_changes_warning BOOLEAN;
l_entries_changed_warning VARCHAR2(10);
l_pay_proposal_warning BOOLEAN;
l_dod_warning BOOLEAN;
l_ppos_id NUMBER;

-- Constant variables

l_module_id CONSTANT VARCHAR2(30) := 'XX_PERSON_TERMINATE';

-- Error Handling variables

l_error_message VARCHAR2(150);
l_error_code VARCHAR2(30);
l_error_statement VARCHAR2(50);

-- Count Variables
l_count_total NUMBER := 0;
l_count_success NUMBER := 0; -- Total number of successful rows

l_cnt1 NUMBER :=0;
l_errm VARCHAR2(100);
l_err_at_stmt NUMBER;

-- Cursor definitions

CURSOR C_Emp_Ter IS
                    Select distinct  X.End_Date Termination_Date,
                            P.Employee_Number,
                            X.Person_Id,
                            A.Assignment_Id,
                            x.pap_person_id,
                            'Terminated' leave_cd1
                    From Xx_Person_Details X,
                         Per_All_People_F P,
                         per_all_assignments_f a
                    Where X.Pap_Person_Id = P.Person_Id
                    And A.Person_Id = P.Person_Id
                    and x.status = 'COMPLETE'
                    And X.End_Date Is Not Null
                    and x.end_date < sysdate
                    ORDER BY employee_number;

CURSOR c_ppos (c_person_id IN NUMBER) IS
SELECT period_of_service_id, object_version_number
FROM per_periods_of_service
Where Person_Id = C_Person_Id;

Cursor C_User Is Select User_Name
                    From Xx_Person_Details X,
                    fnd_user u
                    where x.user_id = u.user_id
                    and x.status = 'COMPLETE'
                    And X.End_Date Is Not Null
                    AND x.end_date < SYSDATE
                    ;

begin
-- Delete roles
delete TBLUSERROLE@BASIN
where person_id in (select to_number(p.attribute1) from xx_person_details x, fnd_user u, per_all_people_f p
                    where x.user_id = u.user_id
                    and u.employee_id = p.person_id
                    and x.status = 'COMPLETE'
                    and x.end_date is not null
                    and x.end_date < sysdate);

dbms_output.put_line('Line 1308');

-- set person to disabled in portfolio
update tblperson@basin
set status_code = 2
where person_id in (select to_number(p.attribute1) from xx_person_details x, fnd_user u, per_all_people_f p
                    where x.user_id = u.user_id
                    and u.employee_id = p.person_id
                    and x.status = 'COMPLETE'
                    and x.end_date is not null
                    and x.end_date < sysdate);

dbms_output.put_line('Line 1320');

-- delete tblsecurity_prt record
Delete Tblsecurity_Prt@Basin
WHERE PERSON_ID in (select to_number(p.attribute1) from xx_person_details x, fnd_user u, per_all_people_f p
                    where x.user_id = u.user_id
                    and u.employee_id = p.person_id
                    and x.status = 'COMPLETE'
                    and x.end_date is not null
                    And X.End_Date < Sysdate);

dbms_output.put_line('Line 1331');
-- Loop through users and disable

-- Terminate Oracle User Name
for r1 in c_user loop

fnd_user_pkg.disableUser(r1.user_name);

end loop;

SELECT business_group_id
INTO l_business_group_id
FROM per_business_groups
WHERE name = 'Setup Business Group';

dbms_output.put_line('Line 1346');

FOR rec IN c_emp_ter LOOP

l_err_at_stmt :=10;

l_employee_no := rec.employee_number;

l_person_id := NULL;
l_assignment_id := NULL;

l_last_standard_process_date := last_day(rec.termination_date);
l_obj_no1 := NULL;
--l_obj_no2 := NULL;
l_supervisor_warning := NULL;
l_event_warning := NULL;
l_interview_warning := NULL;
l_review_warning := NULL;
l_recruiter_warning := NULL;
l_asg_future_changes_warning := NULL;
l_entries_changed_warning := NULL;
l_pay_proposal_warning := NULL;
l_dod_warning := NULL;

l_cnt1 := l_cnt1 + 1;

dbms_output.put_line('Line 1415');

OPEN c_ppos(rec.pap_person_id);
FETCH c_ppos INTO l_ppos_id, l_obj_no1;
IF c_ppos%NOTFOUND THEN
NULL;
END IF;
CLOSE c_ppos;

dbms_output.put_line('pap_person_id'||rec.pap_person_id);

hr_ex_employee_api.actual_termination_emp(
p_effective_date => rec.termination_date
,p_period_of_service_id => l_ppos_id
,P_Actual_Termination_Date => Rec.Termination_Date
,p_person_type_id => 9 -- ex employee id
,P_Assignment_Status_Type_Id => 3 -- Terminate Assignment status
-- OUT
,p_last_standard_process_date => l_last_standard_process_date
,p_object_version_number => l_obj_no1
,p_supervisor_warning => l_supervisor_warning
,p_event_warning => l_event_warning
,p_interview_warning => l_interview_warning
,p_review_warning => l_review_warning
,p_recruiter_warning => l_recruiter_warning
,p_asg_future_changes_warning => l_asg_future_changes_warning
,p_entries_changed_warning => l_entries_changed_warning
,p_pay_proposal_warning => l_pay_proposal_warning
,p_dod_warning => l_dod_warning
);

dbms_output.put_line('Line 1400');


hr_ex_employee_api.update_term_details_emp
(p_effective_date => rec.termination_date
,p_period_of_service_id => l_ppos_id
,p_notified_termination_date => rec.termination_date
,p_projected_termination_date => rec.termination_date
-- OUT
,p_object_version_number => l_obj_no1
) ;

dbms_output.put_line('Line 1412');

UPDATE per_all_assignments_f
SET effective_end_date = l_last_standard_process_date
WHERE effective_end_date = to_date ('31-DEC-4712','DD-MON-YYYY')
AND assignment_id = rec.assignment_id;

dbms_output.put_line('Line 1419');

END LOOP;


-- End Date Oracle Roles
update wf_local_user_roles
set expiration_date = sysdate,
    effective_end_date = sysdate
where expiration_date is null
and user_name in (select user_name from fnd_user u, xx_person_details x
                    where x.user_id = u.user_id
                    and x.status = 'COMPLETE'
                    and x.end_date is not null
                    and x.end_date < sysdate);

dbms_output.put_line('Line 1435');

update wf_user_role_assignments
set end_date = sysdate,
    effective_end_date = sysdate
where end_date is null
and user_name in (select user_name from fnd_user u, xx_person_details x
                    where x.user_id = u.user_id
                    and x.status = 'COMPLETE'
                    and x.end_date is not null
                    and x.end_date < sysdate);

dbms_output.put_line('Line 1447');

-- Update status to show as terminated
update xx_person_details
set status = 'TERMINATED'
where status = 'COMPLETE'
and end_date is not null
and end_date < sysdate;

dbms_output.put_line('Line 1456');

exception WHEN others

THEN

dbms_output.put_line('Exception found');


 ROLLBACK;

End Terminate_User;
---------------------------------------------------------------------------------
--PROCEDURE create_fyi_role
--This procedures is used to dynamically create and set the FYI email role
--This role is then used to send out a completion message
---------------------------------------------------------------------------------
PROCEDURE create_fyi_role
  ( itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT VARCHAR2
  ) IS


  BEGIN

    RESULT := 'COMPLETE:Y';

  End Create_Fyi_Role;
---------------------------------------------------------------------------------
--FUNCTION get_role_for_user_email
--Gets role from and email string
---------------------------------------------------------------------------------
FUNCTION get_role_for_user_email
  (
    p_user  IN VARCHAR2
   ,p_email IN VARCHAR2
  ) RETURN VARCHAR2 IS

    CURSOR c_get_role IS
      SELECT *
      FROM   wf_roles
      WHERE  NAME = p_user;

    CURSOR c_get_email IS
      SELECT *
      FROM   wf_local_roles
      WHERE email_address = p_email;

    p_get_role  c_get_role%ROWTYPE;
    p_get_email c_get_email%ROWTYPE;

  BEGIN
    OPEN c_get_role;
    FETCH c_get_role
      INTO p_get_role;

    IF c_get_role%FOUND
    THEN
      CLOSE c_get_role;
      RETURN p_get_role.NAME;
    END IF;

    CLOSE c_get_role;
    OPEN c_get_email;
    FETCH c_get_email
      INTO p_get_email;

    IF c_get_email%FOUND
    THEN
      CLOSE c_get_email;
      RETURN p_get_email.NAME;
    END IF;

    CLOSE c_get_email;

    RETURN create_role_email(p_user => p_user, p_email => p_email);

  END get_role_for_user_email;
---------------------------------------------------------------------------------
--FUNCTION create_role_Email
--Creates role using email
---------------------------------------------------------------------------------
FUNCTION create_role_email
  ( p_user  IN VARCHAR2
   ,p_email IN VARCHAR2
  ) RETURN VARCHAR2 IS

 v_role wf_roles.NAME%TYPE := p_user;

  BEGIN

    wf_directory.createadhocrole(role_name               => v_role
                                ,role_display_name       => v_role
                                ,role_description        => v_role
                                ,notification_preference => 'MAILHTML'
                                ,email_address           => p_email
                                ,status                  => 'ACTIVE'
                                ,expiration_date         => NULL);
    Return V_Role;
  END create_role_email;
---------------------------------------------------------------------------------
--PROCEDURE update_person_start
--Reads the XML Package into the workflow attributes
---------------------------------------------------------------------------------
PROCEDURE update_person_start
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 )
IS
     change_event_document         CLOB;
     event                         wf_event_t;
     xmldoc                        xmldom.domdocument;
     parser                        xmlparser.parser;
     v_person_id                   NUMBER;
     v_record_type                 VARCHAR2 ( 500 ) ;
     v_created_by                  VARCHAR2 (100);
     v_first_name                  VARCHAR2 (100);
     v_last_name                   VARCHAR2 (100);
     v_line_manager                VARCHAR2 (100);
     l_line_manager                VARCHAR2 (100);
     v_expenses_approver           VARCHAR2 (100);
     v_office                      VARCHAR2 (100);
     v_cost_center                 VARCHAR2 (100);
     v_job_title                   VARCHAR2 (100);
     v_start_date                  date;
     v_end_Date                    date;
     v_desk_location               VARCHAR2 (100);
     v_department                  VARCHAR2 (100);
     v_other_comments              VARCHAR2 (250);
     v_old_first_name                  VARCHAR2 (100);
     v_old_last_name                   VARCHAR2 (100);
     v_old_line_manager                VARCHAR2 (100);
     v_old_expenses_approver           VARCHAR2 (100);
     v_old_office                      VARCHAR2 (100);
     v_old_cost_center                 VARCHAR2 (100);
     v_old_job_title                   VARCHAR2 (100);
     v_old_start_date                  date;
     v_old_end_Date                    date;
     v_old_desk_location               VARCHAR2 (100);
     v_old_department                  VARCHAR2 (100);
     v_old_other_comments              VARCHAR2 (250);
     v_change_mesg                     VARCHAR2 (2000);


BEGIN
     IF ( funcmode = 'RUN' ) THEN

          event := wf_engine.getitemattrevent ( itemtype => itemtype, itemkey => itemkey, NAME => 'EVENT_PAYLOAD' ) ;
          change_event_document   := event.geteventdata ( ) ;

          change_event_document := replace(change_event_document,'&','');

         dbms_output.put_line('change_event_document'||change_event_document);

          v_record_type := irc_xml_util.valueof ( change_event_document, '/updated_person/record_type' ) ;
          dbms_output.put_line('002');

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'RECORD_TYPE', avalue => v_record_type ) ;

         dbms_output.put_line('003');
          v_person_id := irc_xml_util.valueof ( change_event_document, '/updated_person/person_id' ) ;

          dbms_output.put_line('v_person_id = '||v_person_id);

          wf_engine.setitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID', avalue => v_person_id ) ;

          dbms_output.put_line('v_person_id = '||v_person_id);

          select u.user_name
          into v_created_by
          from fnd_user u,
               xx_person_details x
          where u.user_id = x.last_updated_by
          and   x.person_id = v_person_id;

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CREATED_BY', avalue => v_created_by ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'INITIATOR_ROLE', avalue => v_created_by ) ;



          v_old_last_name := irc_xml_util.valueof ( change_event_document, '/updated_person/old_last_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_LAST_NAME', avalue => v_old_last_name ) ;

          v_last_name := irc_xml_util.valueof ( change_event_document, '/updated_person/new_last_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'LAST_NAME', avalue => v_last_name ) ;

          v_old_first_name := irc_xml_util.valueof ( change_event_document, '/updated_person/old_first_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_FIRST_NAME', avalue => v_old_first_name ) ;

          v_first_name := irc_xml_util.valueof ( change_event_document, '/updated_person/new_first_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME', avalue => v_first_name ) ;

          v_old_start_date := irc_xml_util.valueof ( change_event_document, '/updated_person/old_start_date' ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_START_DATE', avalue => v_old_start_date ) ;

          v_start_date := irc_xml_util.valueof ( change_event_document, '/updated_person/new_start_date' ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE', avalue => v_start_date ) ;

          v_old_end_date := irc_xml_util.valueof ( change_event_document, '/updated_person/old_end_date' ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_END_DATE', avalue => v_old_end_date ) ;

          v_end_date := irc_xml_util.valueof ( change_event_document, '/updated_person/new_end_date' ) ;
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE', avalue => v_end_date ) ;

          v_old_office := irc_xml_util.valueof ( change_event_document, '/updated_person/old_office' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_OFFICE', avalue => v_old_office ) ;

          v_office := irc_xml_util.valueof ( change_event_document, '/updated_person/new_office' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE', avalue => v_office ) ;

          v_old_cost_center := irc_xml_util.valueof ( change_event_document, '/updated_person/old_cost_center' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_COST_CENTER', avalue => v_old_cost_center ) ;

          v_cost_center := irc_xml_util.valueof ( change_event_document, '/updated_person/new_cost_center' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COST_CENTER', avalue => v_cost_center ) ;

          v_old_line_manager := irc_xml_util.valueof ( change_event_document, '/updated_person/old_manager' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_MANAGER', avalue => v_old_line_manager ) ;

          v_line_manager := irc_xml_util.valueof ( change_event_document, '/updated_person/new_manager' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER', avalue => v_line_manager ) ;

          dbms_output.put_line('v_line_manager'||v_line_manager);

          select u.user_name
          into l_line_manager
          from per_all_people_f p,
          Fnd_User U
          where p.last_name = replace(v_line_manager,',','')
          and p.person_id = u.employee_id;

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER_APPROVER', avalue => l_line_manager ) ;

          v_old_expenses_approver := irc_xml_util.valueof ( change_event_document, '/updated_person/old_expenses_approver' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_EXPENSES_APPROVER', avalue => v_old_expenses_approver ) ;

          v_expenses_approver := irc_xml_util.valueof ( change_event_document, '/updated_person/expenses_approver' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EXPENSES_APPROVER', avalue => v_expenses_approver ) ;

          v_old_job_title := irc_xml_util.valueof ( change_event_document, '/updated_person/old_job_title' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_JOB_TITLE', avalue => v_old_job_title ) ;

          v_job_title := irc_xml_util.valueof ( change_event_document, '/updated_person/new_job_title' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE', avalue => v_job_title ) ;

          v_old_desk_location := irc_xml_util.valueof ( change_event_document, '/updated_person/old_desk_location' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_DESK_LOCATION', avalue => v_old_desk_location ) ;

          v_desk_location := irc_xml_util.valueof ( change_event_document, '/updated_person/new_desk_location' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DESK_LOCATION', avalue => v_desk_location ) ;

          v_old_other_comments := irc_xml_util.valueof ( change_event_document, '/updated_person/old_other_comments' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_OTHER_COMMENTS', avalue => v_old_other_comments ) ;

          v_other_comments := irc_xml_util.valueof ( change_event_document, '/updated_person/other_comments' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OTHER_COMMENTS', avalue => v_other_comments ) ;

          v_old_department := irc_xml_util.valueof ( change_event_document, '/updated_person/old_department' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_DEPARTMENT', avalue => v_old_department ) ;

          v_department := irc_xml_util.valueof ( change_event_document, '/updated_person/new_department' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'DEPARTMENT', avalue => v_department ) ;

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
          v_change_mesg := v_change_mesg||'<tr><td>Job Title</td><td><del>'||v_OLD_JOB_TITLE||'&nbsp</del></td><td><ins>'||V_JOB_TITLE||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if v_old_office <> v_office then
          v_change_mesg := v_change_mesg||'<tr><td>Office</td><td><del>'||v_OLD_OFFICE||'</del></td><td><ins>'||V_OFFICE||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if v_old_cost_center <> v_cost_center then
          v_change_mesg := v_change_mesg||'<tr><td>Cost Centre</td><td><del>'||v_OLD_COST_CENTER||'</del></td><td><ins>'||V_COST_CENTER||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if nvl(v_old_department,'x') <> v_department then
          v_change_mesg := v_change_mesg||'<tr><td>Department</td><td><del>'||v_old_department||'null</del></td><td><ins>'||v_department||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          IF V_OLD_EXPENSES_APPROVER <> V_EXPENSES_APPROVER THEN
          v_change_mesg := v_change_mesg||'<tr><td>Expenses Approver?</td><td><del>'||v_OLD_expenses_approver||'&nbsp</del></td><td><ins>'||V_expenses_approver||'</ins></td></tr>';
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH', avalue => 'MANAGER' ) ;
          end if;
          if nvl(v_old_desk_location,'x') <> v_desk_location then
          v_change_mesg := v_change_mesg||'<tr><td>Desk Location</td><td><del>'||v_OLD_desk_location||'&nbsp</del></td><td><ins>'||V_desk_location||'</ins></td></tr>';

          end if;
          if nvl(v_old_other_comments,'x') <> v_other_comments then
          v_change_mesg := v_change_mesg||'<tr><td>Other Comments</td><td><del>'||v_OLD_other_comments||'&nbsp</del></td><td><ins>'||V_other_comments||'</ins></td></tr>';

          end if;

          dbms_output.put_line('old_end_date:'||v_old_end_Date);
          dbms_output.put_line('end_date:'||v_end_Date);

          dbms_output.put_line('old_start_date:'||v_old_start_Date);
          dbms_output.put_line('start_date:'||v_start_Date);

          IF nvl(v_old_start_date,SYSDATE) <> nvl(v_start_date,SYSDATE) THEN
          v_change_mesg := v_change_mesg||'<tr><td>Start Date</td><td><del>'||v_OLD_start_date||'</del></td><td><ins>'||V_start_date||'</ins></td></tr>';
          end if;

          IF nvl(v_old_end_date,SYSDATE) <> nvl(v_end_date,SYSDATE) THEN
          v_change_mesg := v_change_mesg||'<tr><td>End Date</td><td><del>'||v_OLD_end_date||'&nbsp</del></td><td><ins>'||V_end_date||'</ins></td></tr>';
          end if;

          v_change_mesg := v_change_mesg||'</table><br /><br />Please Approve or Reject the Changes. If you are rejecting the changes please enter a rejection reason.<br /><br />';

          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CHANGE_MESG', avalue => v_change_mesg ) ;

    END IF;


End Update_Person_Start;
---------------------------------------------------------------------------------
--PROCEDURE change_details_doc
--Creates HTML Document type for notificaiton messages
---------------------------------------------------------------------------------
PROCEDURE change_details_doc( itemkey		IN VARCHAR2 ,
               display_type		IN VARCHAR2 DEFAULT 'text/html',
               document		IN OUT	NOCOPY VARCHAR2,
               document_type	IN OUT	NOCOPY VARCHAR2
) IS

l_document varchar2(32000);

BEGIN

  l_document := wf_engine.getitemattrclob ( itemtype => 'XXNEWPER', itemkey => itemkey, aname => 'CHANGE_MESG' );

  dbms_output.put_line(l_document);

  document:= l_document;

END change_details_doc;

PROCEDURE xx_p_up_approval_path
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          result OUT NOCOPY VARCHAR2 ) is

l_approval_path varchar2(20);
l_person_id     number;
l_is_approver   varchar2(50);

Begin

 l_approval_path  := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'APPROVAL_PATH') ;
 l_person_id      := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID') ;
 l_is_approver    := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'IT_APPROVER' ) ;

 IF l_approval_path = 'MANAGER'
 then
    update xx_person_details
    set status = 'Awaiting Manager Approval',
        person_with = line_manager
    WHERE  person_id = l_person_id;

 else
    update xx_person_details
    set status = 'Awaiting IS Approval',
        person_with = l_is_approver
    WHERE  person_id = l_person_id;
 end if;


 RESULT := l_approval_path;

END xx_p_up_approval_path;

PROCEDURE xx_p_up_mgr_resp(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    l_responder            VARCHAR2(50);
    v_response_reason      VARCHAR2(50);
    v_copy_from_user       VARCHAR2(50);
    l_person_id            number;
  BEGIN


      l_nid := wf_engine.context_nid;
      insert into xx_debug(comments,progress,create_date) values ('l_nid',l_nid,sysdate);

      v_response_reason   := wf_notification.getattrtext(l_nid,'RESPONSE_REASON');
      insert into xx_debug(comments,progress,create_date) values ('v_response_reason',v_response_reason,sysdate);
      l_person_id         := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID') ;

      l_activity_result_code := wf_notification.getattrtext(l_nid,'RESULT');
     insert into xx_debug(comments,progress,create_date) values ('l_activity_result_code',l_activity_result_code,sysdate);

      l_responder := wf_engine.context_text;

      insert into xx_debug(comments,progress,create_date) values ('l_responder',l_responder,sysdate);



    --IF (funcmode IN ('RESPOND','RUN'))
    --THEN
      l_nid := wf_engine.context_nid;

      v_response_reason   := wf_notification.getattrtext(l_nid,'RESPONSE_REASON');

      l_person_id         := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID') ;
      l_activity_result_code := wf_notification.getattrtext(l_nid,'RESULT');




      if l_activity_result_Code is null
      THEN
        RESULT := 'ERROR: Result code null';
        RETURN;
      END IF;



      IF l_activity_result_code = 'REJECTED' AND
         v_response_reason IS NULL
      THEN
        RESULT := 'ERROR: You must enter rejection reason if rejecting.';
        RETURN;
      END IF;

      update xx_person_details
      set approval_comments = v_response_reason,
          manager_response = l_activity_result_code,
          --copy_user_from = v_copy_from_user,
          manager_approver = l_responder,
          manager_response_date = sysdate,
          status = 'Awaiting IS Approval'
      where person_id = l_person_id;


    --END IF;


  EXCEPTION
    WHEN OTHERS THEN
      RESULT := SQLERRM;
  END  xx_p_up_mgr_resp;

PROCEDURE xx_p_up_is_resp(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    l_responder            VARCHAR2(50);
    l_person_id            NUMBER;
    V_Response_Reason      Varchar2(100);
    V_Ad_Account           Varchar2(40);
    V_Old_Last_Name        Varchar2(40);
    V_Last_Name            Varchar2(40);
    v_email            Varchar2(40);
  BEGIN





    IF (funcmode IN ('RESPOND','RUN'))
    THEN
      l_nid := wf_engine.context_nid;
      V_Response_Reason   := Wf_Notification.Getattrtext(L_Nid,'RESPONSE_REASON');
      V_Ad_Account        := Wf_Notification.Getattrtext(L_Nid,'AD_ACCOUNT');
      v_email             := wf_notification.getattrtext(l_nid,'EMAIL');
      l_person_id         := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID') ;
      l_activity_result_code := wf_notification.getattrtext(l_nid,'RESULT');
      L_Responder := Wf_Engine.Context_Text;
      V_Old_Last_Name      := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'OLD_LAST_NAME') ;
      V_Last_Name          := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'LAST_NAME') ;



      if l_activity_result_Code is null
      THEN
        RESULT := 'ERROR: Result code null';
        RETURN;
      END IF;

     If V_Old_Last_Name <> V_Last_Name And V_Ad_Account Is Null
     Then
        RESULT := 'ERROR: You must enter an AD Account when the employees surname has changed.';
        Return;
     END if;

     If V_Old_Last_Name <> V_Last_Name And V_email Is Null
     Then
        RESULT := 'ERROR: You must enter a new email address when the employees surname has changed.';
        Return;
     END if;

      IF l_activity_result_code = 'REJECTED' AND
         v_response_reason IS NULL
      THEN
        RESULT := 'ERROR: You must enter rejection reason if rejecting.';
        RETURN;
      END IF;

      update xx_person_details
      set approval_comments = v_response_reason,
          it_response = l_activity_result_code,
          it_approver = l_responder,
          It_Response_Date = Sysdate,
          email = v_email
      where person_id = l_person_id;


    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      RESULT := SQLERRM;
  END  xx_p_up_is_resp;

PROCEDURE xx_p_up_bc_req(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS

  begin
  RESULT := 'COMPLETE:N';

  End Xx_P_Up_Bc_Req;

PROCEDURE xx_p_up_sync_oracle(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS

  v_person_id NUMBER;
  V_Manager Varchar2(50);
  V_First_Name  varchar2(40);
  V_Last_Name varchar2(40);
  v_old_last_name varchar2(40);
  v_title varchar2(50);
  v_expenses_approver varchar2(1);
  v_location varchar2(50);
  v_cost_center varchar2(4);
  l_code_comb number;
  V_Ent Varchar2(4);
  V_Ad_Account Varchar2(50);
  V_Email Varchar2(40);
  V_old_user Varchar2(40);

begin

v_cost_center                 := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'COST_CENTER');
v_location                    := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE');
v_expenses_approver           := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EXPENSES_APPROVER');
v_manager                     := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'MANAGER' ) ;
v_title                       := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE');
V_Person_Id		                := Wf_Engine.Getitemattrnumber ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'PERSON_ID');
V_First_Name                  := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'FIRST_NAME');
V_Last_Name                   := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'LAST_NAME');
V_Old_Last_Name               := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'OLD_LAST_NAME');
V_Ad_Account                  := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'AD_ACCOUNT');
v_email                       := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMAIL');

IF (funcmode IN ('RUN'))
 THEN

 v_manager := replace(v_manager,',','');

 If V_Last_Name <> V_Old_Last_Name Then -- change user name etc?

  Select User_Name
  Into V_Old_User
  from fnd_user
  Where employee_id = (Select Pap_Person_Id From Xx_Person_Details Where Person_Id = V_Person_Id);

  Update Per_All_People_F
  Set Last_Name = V_First_Name||' '||V_Last_Name,
      Full_Name = V_First_Name||' '||V_Last_Name,
      email_address = v_email
  Where Person_Id = (Select Pap_Person_Id From Xx_Person_Details Where Person_Id = V_Person_Id);

  Update Fnd_User
  Set User_Name = Upper(V_Ad_Account)
      , User_Guid = Null
      , description = v_first_name||' '||v_last_name
  Where Employee_Id = (Select Pap_Person_Id From Xx_Person_Details Where Person_Id = V_Person_Id);

  Update Wf_User_Roles
  Set User_Name = Upper(V_Ad_Account)
  where user_name = v_old_user;

  Update Wf_User_Role_Assignments
  Set User_Name = Upper(V_Ad_Account)
  where user_name = v_old_user;

  End If;

--find entity by location
            select decode(v_location,'Dublin','1802','Singapore','1804','New York','1801','Miami','1801','1802')
            into v_ent
            from dual;

--cost center code combination
            l_code_comb := XX_VALID_GL_CODE(v_ent,'571105',v_cost_center,'000000','000',v_ent,'0000');

-- update assignment
            update per_all_assignments_f
            set     set_of_books_id = 8
                   ,default_code_comb_id = l_code_comb
                   ,supervisor_id = (select person_id from per_all_people_f where last_name = v_manager)
                   ,ass_attribute1 = (select person_id from per_all_people_f where last_name = v_manager)
                   ,location_id = decode(v_location,'Dublin',1728,'Singapore',1729,'New York',1730,'Miami',1731,1728)
                   --,job_id =  decode(v_expenses_approver,'Y',26,28)
                   ,title = v_title
            where person_id = (select pap_person_id from xx_person_details where person_id = v_person_id);




  RESULT := 'COMPLETE:N';

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
      RESULT := SQLERRM;

  end xx_p_up_sync_oracle;

PROCEDURE xx_p_up_sync_external(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS



  v_location  varchar2(40);
IPER_PERSON_ID	NUMBER;
IADDR_TYPE_CODE NUMBER;
IADDRESS_ID NUMBER;
IDEFAULT_YN NUMBER;
IRECSTATUS_CD NUMBER;
OERRORCODE NUMBER;
OERRORMESSAGE VARCHAR2(200);
l_person_id number;
l_created_by_id number;
IPERSON_ID NUMBER;
  IORG_ID NUMBER;
  ISTATUS_CODE NUMBER;
  ISOURCE_CODE NUMBER;
  ICAT_CODE NUMBER;
  ISALUT_CODE NUMBER;
  IPER_SOURCE_DETAIL VARCHAR2(200);
  IPER_FNAME VARCHAR2(200);
  IPER_MNAME VARCHAR2(200);
  IPER_LNAME VARCHAR2(200);
  IPER_DOB DATE;
  IPER_MANAGER VARCHAR2(200);
  IPER_ASSISTANT VARCHAR2(200);
  IPER_JOBTITLE VARCHAR2(200);
  IPER_NOTE VARCHAR2(200);
  IPER_LOGAGAINSTORGYN NUMBER;
  IPER_DATEENTERED DATE;
  IPER_DATEMODIFIED DATE;
  IPER_DOCUMENTDIRNAME VARCHAR2(200);
  IMODIFIED_TM DATE;
  ISUFFIX_CODE NUMBER;
  IDLEVEL_CODE NUMBER;
  IPER_OL_FNAME VARCHAR2(200);
  IMODIFIED_BY NUMBER;
  ICREATED_BY NUMBER;
  ICREATED_TM DATE;
  IAWW_OWNER_ID NUMBER;
  IPER_MANAGER_PERSON_ID NUMBER;
  IPER_SCD_MANAGER_PERSON_ID NUMBER;
  I_ADDRESS_ID NUMBER;
  IPERSON_ROLE_ID number;
  Iperson_Oldrole_Id Number;
  v_ad_Account varchar2 (40);
    V_Last_Name Varchar2(40);
  V_Old_Last_Name Varchar2(40);
  v_email varchar2(40);


Begin


 IF (funcmode IN ('RUN'))
 THEN


l_person_id                  := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'PERSON_ID' ) ;
v_location                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OFFICE' ) ;
IPER_FNAME                   := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'FIRST_NAME' ) ;
Iper_Lname                   := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'LAST_NAME' ) ;
v_email                      := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'EMAIL' ) ;
IPER_JOBTITLE                := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'JOB_TITLE' ) ;
IPER_DATEENTERED             := wf_engine.getitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'START_DATE' ) ;
Iper_Manager                 := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'MANAGER' ) ;
v_ad_Account                 := wf_engine.getitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'AD_ACCOUNT' ) ;
V_Last_Name                   := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'LAST_NAME');
V_Old_Last_Name               := Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'OLD_LAST_NAME');


DBMS_OUTPUT.PUT_LINE(V_LOCATION);
dbms_output.put_line(l_person_id);

select to_number(m.attribute1),
	to_number(p.attribute1)
into IPER_MANAGER_PERSON_ID,
	IPER_PERSON_ID
from fnd_user u,
xx_person_details x,
per_all_people_f p,
per_all_people_f m,
per_all_assignments_f a
where p.person_id = u.employee_id
and a.person_id = p.person_id
and a.supervisor_id = m.person_id
and x.user_id = u.user_id
and x.person_id = l_person_id;

DBMS_OUTPUT.PUT_LINE('IPER_MANAGER_PERSON_ID'||IPER_MANAGER_PERSON_ID);
DBMS_OUTPUT.PUT_LINE('IPER_PERSON_ID'||IPER_PERSON_ID);

	select to_number(p.attribute1)
	into l_created_by_id
    	from per_all_people_f p,
   		fnd_user u,
      xx_person_details x
    	where p.person_id = u.employee_id
    	and u.user_id = x.last_updated_by
	    and x.person_id = l_person_id;

DBMS_OUTPUT.PUT_LINE('l_created_by_id'||l_created_by_id);

        SELECT 	CREATED_BY,
                created_tm
        into ICREATED_BY,
             ICREATED_TM
        from tblperson@basin
        where person_id = IPER_PERSON_ID;

DBMS_OUTPUT.PUT_LINE('ICREATED_BY'||ICREATED_BY);
DBMS_OUTPUT.PUT_LINE('ICREATED_TM'||ICREATED_TM);


  IMODIFIED_BY	:= l_created_by_id;
  IMODIFIED_TM 	:= sysdate;
  IPER_DATEMODIFIED := sysdate;
  IPER_SOURCE_DETAIL := 'Oracle';
  IORG_ID := 10000;
  ISTATUS_CODE := 1;
  ISOURCE_CODE := NULL;
  ICAT_CODE := NULL;
  ISALUT_CODE := NULL;
  IPER_MNAME := NULL;
  IPER_DOB := NULL;
  IPER_ASSISTANT := NULL;
  IPER_NOTE := NULL;
  IPER_LOGAGAINSTORGYN := NULL;
  IPER_DOCUMENTDIRNAME := NULL;
  ISUFFIX_CODE := NULL;
  IDLEVEL_CODE := NULL;
  IPER_OL_FNAME := NULL;
  IAWW_OWNER_ID := NULL;
  IPER_SCD_MANAGER_PERSON_ID := NULL;



PKGPERSON.STPUPDATE@BASIN(
    IPERSON_ID => IPER_PERSON_ID,
    IORG_ID => IORG_ID,
    ISTATUS_CODE => ISTATUS_CODE,
    ISOURCE_CODE => ISOURCE_CODE,
    ICAT_CODE => ICAT_CODE,
    ISALUT_CODE => ISALUT_CODE,
    IPER_SOURCE_DETAIL => IPER_SOURCE_DETAIL,
    IPER_FNAME => IPER_FNAME,
    IPER_MNAME => IPER_MNAME,
    IPER_LNAME => IPER_LNAME,
    IPER_DOB => IPER_DOB,
    IPER_MANAGER => IPER_MANAGER,
    IPER_ASSISTANT => IPER_ASSISTANT,
    IPER_JOBTITLE => IPER_JOBTITLE,
    IPER_NOTE => IPER_NOTE,
    IPER_LOGAGAINSTORGYN => IPER_LOGAGAINSTORGYN,
    IPER_DATEENTERED => IPER_DATEENTERED,
    IPER_DATEMODIFIED => IPER_DATEMODIFIED,
    IPER_DOCUMENTDIRNAME => IPER_DOCUMENTDIRNAME,
    IMODIFIED_TM => IMODIFIED_TM,
    ISUFFIX_CODE => ISUFFIX_CODE,
    IDLEVEL_CODE => IDLEVEL_CODE,
    IPER_OL_FNAME => IPER_OL_FNAME,
    IMODIFIED_BY => IMODIFIED_BY,
    ICREATED_BY => ICREATED_BY,
    ICREATED_TM => ICREATED_TM,
    IAWW_OWNER_ID => IAWW_OWNER_ID,
    IPER_MANAGER_PERSON_ID => IPER_MANAGER_PERSON_ID,
    IPER_SCD_MANAGER_PERSON_ID => IPER_SCD_MANAGER_PERSON_ID,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );

  DBMS_OUTPUT.PUT_LINE('OERRORCODE'||OERRORCODE);
  DBMS_OUTPUT.PUT_LINE('OERRORMESSAGE'||OERRORMESSAGE);

  If V_Last_Name <> V_Old_Last_Name
  Then
  Update Tblsecurity_Prt@basin
  Set User_Id = 'AWAS-SYD-DOM1\'||Lower(V_Ad_Account)
  Where Person_Id = Iper_Person_Id;

  Update Tblperemailaddress@Basin
  Set Peremail_address = V_Email
  Where Person_Id = Iper_Person_Id;

  end if;

	select decode(v_location,'Dublin',9,'Singapore',693,'New York',5,'Miami',6,9)
	into iaddress_id
	from dual;

  PKGPERADDRESS_PRT.STPUPDATElocation@BASIN(
    IPERSON_ID => IPER_PERSON_ID,
    IADDRESS_ID => IADDRESS_ID,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );


	 select person_role_id
	 into IPERSON_ROLE_ID
  	 from tlkppersonrole@basin r,
	 	xx_person_details p
  	 where r.awas_dept_roleYN = 1
  	 and r.name = p.department
  	 and p.person_id = l_person_id;

	select person_role_id
	into 	IPERSON_OLDROLE_ID
	from tblpersonrole@basin
	where person_id = iper_person_id;


  PKGPERSONROLE.STPUPDATE@BASIN(
    IPERSON_ID => IPER_PERSON_ID,
    IPERSON_ROLE_ID => IPERSON_ROLE_ID,
    IPERSON_OLDROLE_ID => IPERSON_OLDROLE_ID,
    OERRORCODE => OERRORCODE,
    OERRORMESSAGE => OERRORMESSAGE
  );

-- Update record to complete
  UPDATE XX_PERSON_DETAILS
      SET STATUS = 'COMPLETE',
          person_with = null
      where person_id = l_person_id;


  RESULT := 'COMPLETE:Y';

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
      RESULT := SQLERRM;



  End Xx_P_Up_Sync_External;


  PROCEDURE start_fyi
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          Funcmode In Varchar2,
          resultout OUT NOCOPY VARCHAR2 )    is

    L_Itemtype Varchar2(30) := 'XXNEWPER';
    L_Itemkey  Varchar2(300);


    L_First_Name Varchar2(30);
    L_Last_Name Varchar2(30);
    L_Job_Title Varchar2(50);
    L_Department  Varchar2(30);
    L_Office      Varchar2(20);
    L_Cost_Center Varchar2(10);
    L_Manager     Varchar2(30);
    L_Employee_Type Varchar2(20);
    L_Start_Date  Date;
    L_Role_Copied_From  Varchar2(30);
    L_Other_Comments Varchar2(250);

  cursor c1 is Select     P.User_Name FYI_ROLE
                            From Fnd_Lookup_Values V,
                              fnd_user P
                            Where Lookup_Type = 'AWAS_APPLICATION_APPROVERS'
                            And P.Employee_Id   = V.Attribute2
                          -- Data Owners
                            union
                          SELECT
                              p2.user_name Data_Owner
                            From Fnd_Lookup_Values V,
                            fnd_user p2
                            Where Lookup_Type = 'AWAS_APPLICATION_APPROVERS'
                            And P2.Employee_Id   = V.Attribute3
                          -- AWAS FYI Employee Responsibility
                          UNION
                          SELECT User_Name
                          FROM Wf_Local_User_Roles WHERE Role_Name LIKE '%AWAS%FYI%'
                          and sysdate between start_Date and nvl(expiration_date, sysdate+1);
/*
--  For Testing only
    Cursor C1 Is Select User_Name fyi_role
                  From Fnd_User
                  Where User_Name = 'SJOYCE';
*/
     X_Id Number := 200;

    begin

     If (Funcmode In ('RUN'))

     THEN

    L_First_Name :=         Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'FIRST_NAME' ) ;
    L_Last_Name   :=        Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'LAST_NAME' ) ;
    L_Job_Title :=          Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'JOB_TITLE' ) ;
    L_Department :=         Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'DEPARTMENT' ) ;
    L_Office  :=            Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'OFFICE' ) ;
    L_Cost_Center :=        Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'COST_CENTER' ) ;
    L_Manager     :=        Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'MANAGER' ) ;
    L_Employee_Type :=      Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'EMPLOYEE_TYPE' ) ;
    L_Start_Date :=        Wf_Engine.Getitemattrdate ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'START_DATE'    ) ;
    L_Role_Copied_From :=        Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'ROLE_COPIED_FROM' ) ;
    L_Other_Comments :=         Wf_Engine.Getitemattrtext ( Itemtype => Itemtype, Itemkey => Itemkey, Aname => 'OTHER_COMMENTS' ) ;


    for r1 in c1 loop

    X_Id := X_Id + 1;

    l_itemkey := 'FYI-'||ITEMKEY||'-'||x_id;


    wf_engine.createprocess(l_itemtype, l_itemkey, 'NEW_EMPLOYEE_FYI_NOTIFICATION');

    wf_engine.setitemuserkey(itemtype => l_itemtype
                            ,itemkey  => l_itemkey
                            ,Userkey  => L_Itemkey);

    /*wf_engine.setitemowner(itemtype => l_itemtype
                          ,itemkey  => l_itemkey
                          ,owner    => 'SYSADMIN');
 */
    wf_engine.setitemattrtext(itemtype => l_itemtype
                               ,Itemkey  => L_Itemkey
                               ,Aname    => 'FYI_ROLE'
                               ,avalue   => R1.FYI_ROLE);

    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'FIRST_NAME',Avalue   => L_First_Name) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'LAST_NAME' ,Avalue   =>L_Last_Name) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'JOB_TITLE' ,Avalue   =>L_Job_Title) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'DEPARTMENT',Avalue   =>L_Department ) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'OFFICE' ,Avalue   =>L_Office) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'COST_CENTER' ,Avalue   =>L_Cost_Center) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'MANAGER' ,Avalue   =>L_Manager) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'EMPLOYEE_TYPE' ,Avalue   =>L_Employee_Type) ;
    Wf_Engine.Setitemattrdate ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'START_DATE'   ,Avalue   => L_Start_Date) ;
    Wf_Engine.Setitemattrtext ( Itemtype => L_Itemtype, Itemkey => L_Itemkey, Aname => 'ROLE_COPIED_FROM',Avalue   => L_Role_Copied_From) ;
    Wf_Engine.setitemattrtext ( Itemtype => l_Itemtype, Itemkey => L_Itemkey, Aname => 'OTHER_COMMENTS' ,avalue   =>L_Other_Comments) ;


    wf_engine.startprocess(l_itemtype, l_itemkey);

    End Loop;


     RESULTOUT := 'COMPLETE:Y';

  END IF;

  EXCEPTION
  When Others Then
      ResultOUT := Sqlerrm;

  End Start_Fyi;




END XX_WORKFLOW_PKG;
/
