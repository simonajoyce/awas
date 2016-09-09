CREATE OR REPLACE PACKAGE XX_UMX_PKG AS 

  PROCEDURE UMX_CAT_MAIN ( ERRBUF OUT VARCHAR2,
                           RETCODE OUT NUMBER);
                           
  PROCEDURE UMX_CREATE_ROLES (ERRBUF OUT VARCHAR2,
                           RETCODE OUT NUMBER);
                           
   PROCEDURE UMX_CREATE_ROLES_MANUALLY (ERRBUF OUT VARCHAR2,
                                      RETCODE OUT NUMBER,
                                      P_ROLE_DISPLAY_NAME VARCHAR2,
                                      P_ROLE_NAME VARCHAR2,
                                      P_CAT_ID VARCHAR2,
                                      P_REG_SERVICE_CODE VARCHAR2);
                           
                           
  PROCEDURE xx_external_access
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
    PROCEDURE  delete_role
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
          
procedure query_role_description (item_type    in  varchar2,
                                     item_key     in  varchar2,
                                     activity_id  in  number,
                                     command      in  varchar2,
                                     resultout    out NOCOPY varchar2);

 PROCEDURE check_notes(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,Funcmode In Varchar2
                                ,RESULT   IN OUT VARCHAR2);
  

END XX_UMX_PKG;
 
/


CREATE OR REPLACE PACKAGE BODY XX_UMX_PKG AS

  PROCEDURE UMX_CAT_INS_API(P_CATEGORY_REC IN OUT FND_LOOKUP_VALUES%ROWTYPE);
  PROCEDURE UMX_HIER_INS_API(P_HIER_REC IN OUT FND_LOOKUP_ASSIGNMENTS%ROWTYPE);
  PROCEDURE UMX_REG_SVCS_B_INS_API(P_UMX_REG_SVC_B IN OUT UMX_REG_SERVICES_B%ROWTYPE);
  PROCEDURE UMX_REG_SVCS_TL_INS_API(P_UMX_REG_SVC_TL IN OUT UMX_REG_SERVICES_TL%ROWTYPE);
  PROCEDURE XX_CREATE_GRANTS(L_INSTANCE_PK1_VALUE IN VARCHAR2, L_DESCRIPTION IN VARCHAR2);
  
  PROCEDURE UMX_CAT_MAIN ( ERRBUF OUT VARCHAR2,
                           RETCODE OUT NUMBER) AS

  L_CATEGORY_REC  FND_LOOKUP_VALUES%ROWTYPE;
  
  -- New Category to be inserted cursor                           
  CURSOR C1 IS  SELECT DISTINCT 'X'||KS.SYSTEM_ID  LOOKUP_CODE, 
                       KS.SYSTEM_DESC      MEANING, 
                       substr(KS.FULL_DESCRIPTION,1,240) DESCRIPTION
                FROM TBLSYSROLE@BASIN SR,
                     TLKPSYSTEM@BASIN KS
                WHERE SR.SYSTEM_ID = KS.SYSTEM_ID
                and KS.ALLOW_REQUEST_ACCESS = 1
                AND 'X'||KS.SYSTEM_ID NOT IN (SELECT LOOKUP_CODE FROM FND_LOOKUP_VALUES WHERE LOOKUP_TYPE = 'UMX_CATEGORY_LOOKUP')
                ORDER BY 1;
                           
  BEGIN
  DBMS_OUTPUT.PUT_LINE ( 'Looking for new Applications to create..' ) ;
  
  FOR R1 IN C1 LOOP
        
        
                     L_CATEGORY_REC.LOOKUP_CODE := R1.LOOKUP_CODE;
                     L_CATEGORY_REC.MEANING     := R1.MEANING;
                     L_CATEGORY_REC.DESCRIPTION := R1.DESCRIPTION;
                     

        UMX_CAT_INS_API(L_CATEGORY_REC);
  
        DBMS_OUTPUT.PUT_LINE ( R1.LOOKUP_CODE||' Created.' ) ;
  END LOOP;
         

  -- Now sync systems enabled flag
  update FND_LOOKUP_VALUES l
  set enabled_flag = (select decode(KS.ALLOW_REQUEST_ACCESS,1,'Y','N') from TLKPSYSTEM@BASIN KS where 'X'||KS.SYSTEM_ID = l.lookup_code)
  where LOOKUP_TYPE  = 'UMX_CATEGORY_LOOKUP'
  AND lookup_code IN (SELECT 'X'||SYSTEM_ID FROM TLKPSYSTEM@BASIN);
  
  -- delete end dated role assignments
  UPDATE wf_user_role_assignments
SET end_Date = role_end_Date
WHERE end_date IS NULL
AND role_end_Date IS NOT NULL
AND role_end_date < SYSDATE
and role_name like 'UMX%';
  
  
  END UMX_CAT_MAIN;



PROCEDURE UMX_CAT_INS_API(P_CATEGORY_REC IN OUT FND_LOOKUP_VALUES%ROWTYPE) IS
BEGIN
--Set create/update fields alter to use FND-USER records when in Production
P_CATEGORY_REC.LOOKUP_TYPE        := 'UMX_CATEGORY_LOOKUP';
P_CATEGORY_REC.LANGUAGE           := 'US';
P_CATEGORY_REC.ENABLED_FLAG       := 'Y';
P_CATEGORY_REC.START_DATE_ACTIVE  := SYSDATE;
P_CATEGORY_REC.END_DATE_ACTIVE    := NULL;
P_CATEGORY_REC.SOURCE_LANG        := 'US';
P_CATEGORY_REC.SECURITY_GROUP_ID  := 0;
P_CATEGORY_REC.VIEW_APPLICATION_ID:= 0;

P_CATEGORY_REC.CREATED_BY         := 1234;
P_CATEGORY_REC.CREATION_DATE      := SYSDATE;
P_CATEGORY_REC.LAST_UPDATE_LOGIN  := -1;
P_CATEGORY_REC.LAST_UPDATED_BY    := 1234;
P_CATEGORY_REC.LAST_UPDATE_DATE   := SYSDATE;

-- Do the insert
INSERT INTO FND_LOOKUP_VALUES
VALUES P_CATEGORY_REC;

END UMX_CAT_INS_API;

 PROCEDURE UMX_CREATE_ROLES (ERRBUF OUT VARCHAR2,
                           RETCODE OUT NUMBER) AS
                           
                           
  CURSOR C2 IS    SELECT substr(NVL(KS.ALIAS,KS.SYSTEM_NAME)||' - '||SR.SYSROLE_DESC,1,30) ROLE_DISPLAY_NAME,
                      'UMX|'||SR.SYSTEM_ID||'X'||SR.SYSROLE_ID ROLE_NAME,
                      'X'||SR.SYSTEM_ID CAT_ID,
                      substr(NVL(KS.ALIAS,KS.SYSTEM_NAME)||' - '||SR.SYSROLE_DESC,1,30) REG_SERVICE_CODE
               FROM      TBLSYSROLE@BASIN SR,
                         TLKPSYSTEM@BASIN KS
               WHERE SR.SYSTEM_ID = KS.SYSTEM_ID
               and KS.ALLOW_REQUEST_ACCESS = 1
               AND 'UMX|'||SR.SYSTEM_ID||'X'||SR.SYSROLE_ID not in (select NAME from wf_local_roles where name like 'UMX%');

  L_HIER_REC          FND_LOOKUP_ASSIGNMENTS%ROWTYPE;
  L_UMX_REG_SVC_B     UMX_REG_SERVICES_B%ROWTYPE;
  L_UMX_REG_SVC_TL    UMX_REG_SERVICES_TL%ROWTYPE;
  ROLE_NAME VARCHAR2(200);
  ROLE_DISPLAY_NAME VARCHAR2(200);
  ORIG_SYSTEM VARCHAR2(200);
  ORIG_SYSTEM_ID NUMBER;
  LANGUAGE VARCHAR2(200);
  TERRITORY VARCHAR2(200);
  ROLE_DESCRIPTION VARCHAR2(200);
  NOTIFICATION_PREFERENCE VARCHAR2(200);
  EMAIL_ADDRESS VARCHAR2(200);
  FAX VARCHAR2(200);
  STATUS VARCHAR2(200);
  EXPIRATION_DATE DATE;
  START_DATE DATE;
  PARENT_ORIG_SYSTEM VARCHAR2(200);
  PARENT_ORIG_SYSTEM_ID NUMBER;
  OWNER_TAG VARCHAR2(200);
  LAST_UPDATE_DATE DATE;
  LAST_UPDATED_BY NUMBER;
  CREATION_DATE DATE;
  CREATED_BY NUMBER;
  LAST_UPDATE_LOGIN NUMBER;
  
    
BEGIN

  FOR R2 IN C2 LOOP
  
  ROLE_NAME         := R2.ROLE_NAME;
  ROLE_DISPLAY_NAME := R2.ROLE_DISPLAY_NAME;
  ROLE_DESCRIPTION  := R2.ROLE_DISPLAY_NAME;
  ORIG_SYSTEM := 'UMX';
  ORIG_SYSTEM_ID := 0;
  LANGUAGE := 'AMERICAN';
  TERRITORY := 'AMERICA';
  NOTIFICATION_PREFERENCE := 'QUERY';
  EMAIL_ADDRESS := NULL;
  FAX := NULL;
  STATUS := 'ACTIVE';
  EXPIRATION_DATE := NULL;
  START_DATE := SYSDATE;
  PARENT_ORIG_SYSTEM := 'UMX';
  PARENT_ORIG_SYSTEM_ID := 0;
  OWNER_TAG := 'AWCUST';
  LAST_UPDATE_DATE := SYSDATE;
  LAST_UPDATED_BY := 1622;
  CREATION_DATE := SYSDATE;
  CREATED_BY := 1622;
  LAST_UPDATE_LOGIN := -1;

  WF_DIRECTORY.CREATEROLE(
    ROLE_NAME => ROLE_NAME,
    ROLE_DISPLAY_NAME => ROLE_DISPLAY_NAME,
    ORIG_SYSTEM => ORIG_SYSTEM,
    ORIG_SYSTEM_ID => ORIG_SYSTEM_ID,
    LANGUAGE => LANGUAGE,
    TERRITORY => TERRITORY,
    ROLE_DESCRIPTION => ROLE_DESCRIPTION,
    NOTIFICATION_PREFERENCE => NOTIFICATION_PREFERENCE,
    EMAIL_ADDRESS => EMAIL_ADDRESS,
    FAX => FAX,
    STATUS => STATUS,
    EXPIRATION_DATE => EXPIRATION_DATE,
    START_DATE => START_DATE,
    PARENT_ORIG_SYSTEM => PARENT_ORIG_SYSTEM,
    PARENT_ORIG_SYSTEM_ID => PARENT_ORIG_SYSTEM_ID,
    OWNER_TAG => OWNER_TAG,
    LAST_UPDATE_DATE => LAST_UPDATE_DATE,
    LAST_UPDATED_BY => LAST_UPDATED_BY,
    CREATION_DATE => CREATION_DATE,
    CREATED_BY => CREATED_BY,
    LAST_UPDATE_LOGIN => LAST_UPDATE_LOGIN
  );
 
    L_HIER_REC.LOOKUP_CODE        := R2.CAT_ID;
    L_HIER_REC.INSTANCE_PK1_VALUE := R2.ROLE_NAME;
    
    
    
    SELECT FND_LOOKUP_ASSIGNMENTS_S.NEXTVAL
    INTO L_HIER_REC.LOOKUP_ASSIGNMENT_ID
    FROM DUAL;
       
    --INSERT
    UMX_HIER_INS_API(L_HIER_REC);
 
    L_UMX_REG_SVC_B.REG_SERVICE_CODE := R2.ROLE_NAME;
    L_UMX_REG_SVC_B.WF_ROLE_NAME     := R2.ROLE_NAME;
    
    --INSERT
    UMX_REG_SVCS_B_INS_API(L_UMX_REG_SVC_B);
    
    L_UMX_REG_SVC_TL.REG_SERVICE_CODE  := R2.ROLE_NAME;
    L_UMX_REG_SVC_TL.DISPLAY_NAME      := R2.REG_SERVICE_CODE;
    L_UMX_REG_SVC_TL.DESCRIPTION      := R2.REG_SERVICE_CODE;
    
    
    
    --INSERT
    UMX_REG_SVCS_TL_INS_API(L_UMX_REG_SVC_TL);
    
    --CALL CREATE GRANTS
  
   xx_create_grants(R2.ROLE_NAME,R2.REG_SERVICE_CODE);
   
    
    DBMS_OUTPUT.PUT_LINE ( R2.REG_SERVICE_CODE ) ;
    
  END LOOP;
  
  
  --Insert Lookup values for DATA OWNER adn BUSINESS APPROVER  default to Damien Cormican
  INSERT INTO fnd_lookup_values
(LOOKUP_TYPE,LANGUAGE,
ENABLED_FLAG,
START_DATE_ACTIVE,
CREATED_BY,CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
LAST_UPDATE_DATE,SOURCE_LANG,SECURITY_GROUP_ID,VIEW_APPLICATION_ID,TERRITORY_CODE,ATTRIBUTE_CATEGORY,
ATTRIBUTE2,ATTRIBUTE3,
LOOKUP_CODE,
MEANING,
DESCRIPTION,
ATTRIBUTE1)
SELECT 'AWAS_APPLICATION_APPROVERS','US',
'Y',sysdate,
1622,
sysdate,1622,
2844072,sysdate,
'US',0,3,NULL,
'AWAS_APPLICATION_APPROVERS',
'295',
'295',
upper(substr(display_name,1,30)),
substr(display_name,1,80),
description,
NAME 
FROM wf_local_roles WHERE NAME LIKE 'UMX%'
AND NAME NOT IN (SELECT attribute1 FROM fnd_lookup_values WHERE lookup_type = 'AWAS_APPLICATION_APPROVERS')
AND NAME NOT IN ('UMX|236X9999',
'UMX|29X9999',
'UMX|81X9999',
'UMX|ALS_RO',
'UMX|AME_ADM_VIEWER',
'UMX|AME_APP_ADMIN',
'UMX|AME_BUS_ANALYST',
'UMX|1011X9999',
'UMX|101X9999',
'UMX|AME_BUS_PROCESS_OWNER',
'UMX|AME_TTYPE_ADMIN',
'UMX|APPS_SCHEMA_CONNECT',
'UMX|AWAS_AP_MAN',
'UMX|ODIN',
'UMX|SECURITY_ADMIN',
'UMX|UMX_EXT_ADMIN',
'UMX|UMX_PARTNER_ADMIN',
'UMX|WF_ADMIN_ROLE');
  

END UMX_CREATE_ROLES;


 PROCEDURE UMX_CREATE_ROLES_MANUALLY (ERRBUF OUT VARCHAR2,
                                      RETCODE OUT NUMBER,
                                      P_ROLE_DISPLAY_NAME VARCHAR2,
                                      P_ROLE_NAME VARCHAR2,
                                      P_CAT_ID VARCHAR2,
                                      P_REG_SERVICE_CODE VARCHAR2) 
                                      AS
/*--------------------------------------------------------------+
| Developed By Simon Joyce for AWAS                             |
| UMX_CREATE_ROLES_MANUALLY create roles manually from a        |
| concurrent request                                            |
| Revision History:                                             |
| Created By Simon Joyce     16-3-2012                          |
+--------------------------------------------------------------*/
                           
  L_HIER_REC          FND_LOOKUP_ASSIGNMENTS%ROWTYPE;
  L_UMX_REG_SVC_B     UMX_REG_SERVICES_B%ROWTYPE;
  L_UMX_REG_SVC_TL    UMX_REG_SERVICES_TL%ROWTYPE;
  ROLE_NAME VARCHAR2(200);
  ROLE_DISPLAY_NAME VARCHAR2(200);
  ORIG_SYSTEM VARCHAR2(200);
  ORIG_SYSTEM_ID NUMBER;
  LANGUAGE VARCHAR2(200);
  TERRITORY VARCHAR2(200);
  ROLE_DESCRIPTION VARCHAR2(200);
  NOTIFICATION_PREFERENCE VARCHAR2(200);
  EMAIL_ADDRESS VARCHAR2(200);
  FAX VARCHAR2(200);
  STATUS VARCHAR2(200);
  EXPIRATION_DATE DATE;
  START_DATE DATE;
  PARENT_ORIG_SYSTEM VARCHAR2(200);
  PARENT_ORIG_SYSTEM_ID NUMBER;
  OWNER_TAG VARCHAR2(200);
  LAST_UPDATE_DATE DATE;
  LAST_UPDATED_BY NUMBER;
  CREATION_DATE DATE;
  CREATED_BY NUMBER;
  LAST_UPDATE_LOGIN NUMBER;
  
    
BEGIN

   
  ROLE_NAME         := P_ROLE_NAME;
  ROLE_DISPLAY_NAME := P_ROLE_DISPLAY_NAME;
  ROLE_DESCRIPTION  := P_ROLE_DISPLAY_NAME;
  ORIG_SYSTEM := 'UMX';
  ORIG_SYSTEM_ID := 0;
  LANGUAGE := 'AMERICAN';
  TERRITORY := 'AMERICA';
  NOTIFICATION_PREFERENCE := 'QUERY';
  EMAIL_ADDRESS := NULL;
  FAX := NULL;
  STATUS := 'ACTIVE';
  EXPIRATION_DATE := NULL;
  START_DATE := SYSDATE;
  PARENT_ORIG_SYSTEM := 'UMX';
  PARENT_ORIG_SYSTEM_ID := 0;
  OWNER_TAG := 'AWCUST';
  LAST_UPDATE_DATE := SYSDATE;
  LAST_UPDATED_BY := 1622;
  CREATION_DATE := SYSDATE;
  CREATED_BY := 1622;
  LAST_UPDATE_LOGIN := -1;

  WF_DIRECTORY.CREATEROLE(
    ROLE_NAME => ROLE_NAME,
    ROLE_DISPLAY_NAME => ROLE_DISPLAY_NAME,
    ORIG_SYSTEM => ORIG_SYSTEM,
    ORIG_SYSTEM_ID => ORIG_SYSTEM_ID,
    LANGUAGE => LANGUAGE,
    TERRITORY => TERRITORY,
    ROLE_DESCRIPTION => ROLE_DESCRIPTION,
    NOTIFICATION_PREFERENCE => NOTIFICATION_PREFERENCE,
    EMAIL_ADDRESS => EMAIL_ADDRESS,
    FAX => FAX,
    STATUS => STATUS,
    EXPIRATION_DATE => EXPIRATION_DATE,
    START_DATE => START_DATE,
    PARENT_ORIG_SYSTEM => PARENT_ORIG_SYSTEM,
    PARENT_ORIG_SYSTEM_ID => PARENT_ORIG_SYSTEM_ID,
    OWNER_TAG => OWNER_TAG,
    LAST_UPDATE_DATE => LAST_UPDATE_DATE,
    LAST_UPDATED_BY => LAST_UPDATED_BY,
    CREATION_DATE => CREATION_DATE,
    CREATED_BY => CREATED_BY,
    LAST_UPDATE_LOGIN => LAST_UPDATE_LOGIN
  );
 
    --INSERT INTO HIERARCHY
    L_HIER_REC.LOOKUP_CODE        := P_CAT_ID;
    L_HIER_REC.INSTANCE_PK1_VALUE := P_ROLE_NAME;
    
    SELECT FND_LOOKUP_ASSIGNMENTS_S.NEXTVAL
    INTO L_HIER_REC.LOOKUP_ASSIGNMENT_ID
    FROM DUAL;
       
    UMX_HIER_INS_API(L_HIER_REC);

    --INSERT REGISTRATION SERVICE 
    L_UMX_REG_SVC_B.REG_SERVICE_CODE := P_ROLE_NAME;
    L_UMX_REG_SVC_B.WF_ROLE_NAME     := P_ROLE_NAME;

    UMX_REG_SVCS_B_INS_API(L_UMX_REG_SVC_B);
    
    --INSERT REGISTRATION SERVICE TL
    L_UMX_REG_SVC_TL.REG_SERVICE_CODE  := P_ROLE_NAME;
    L_UMX_REG_SVC_TL.DISPLAY_NAME      := P_REG_SERVICE_CODE;
    L_UMX_REG_SVC_TL.DESCRIPTION       := P_REG_SERVICE_CODE;
    
    UMX_REG_SVCS_TL_INS_API(L_UMX_REG_SVC_TL);
    
    --CALL CREATE GRANTS
    xx_create_grants(P_ROLE_NAME,P_REG_SERVICE_CODE);
   
    
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, P_REG_SERVICE_CODE||' Created' ) ;
 

END UMX_CREATE_ROLES_MANUALLY;

/*-----------------------------------------------------------------------------
 * PROCEDURE UMX_HIER_INS_API
 * API to insert into FND_LOOKUP_ASSIGNMENTS Table
 * To generate Category Hierarchies
 *----------------------------------------------------------------------------*/ 

  PROCEDURE UMX_HIER_INS_API(P_HIER_REC IN OUT FND_LOOKUP_ASSIGNMENTS%ROWTYPE) AS
  
  BEGIN
  

  -- STATIC VALUES
  P_HIER_REC.LOOKUP_TYPE := 'UMX_CATEGORY_LOOKUP' ;
  P_HIER_REC.OBJ_NAME := 'UMX_ACCESS_ROLE';
  
  --STD COLUMNS
  P_HIER_REC.CREATED_BY         := 1622;
  P_HIER_REC.CREATION_DATE      := SYSDATE;
  P_HIER_REC.LAST_UPDATE_LOGIN  := -1;
  P_HIER_REC.LAST_UPDATED_BY    := 1622;
  P_HIER_REC.LAST_UPDATE_DATE   := SYSDATE;
  
  INSERT INTO FND_LOOKUP_ASSIGNMENTS
  VALUES P_HIER_REC;
  
  END UMX_HIER_INS_API;
  
/*-----------------------------------------------------------------------------
 * PROCEDURE UMX_REG_SVCS_B_INS_API
 * API to insert into UMX_REG_SVCS_B Table
 *----------------------------------------------------------------------------*/   
 PROCEDURE UMX_REG_SVCS_B_INS_API(P_UMX_REG_SVC_B IN OUT UMX_REG_SERVICES_B%ROWTYPE) AS
  
  BEGIN
  

  -- STATIC VALUES
  P_UMX_REG_SVC_B.REG_SERVICE_TYPE            := 'ADDITIONAL_ACCESS';
  P_UMX_REG_SVC_B.WF_NOTIFICATION_EVENT_GUID  := 'D49803E67DCD7DB1E030B98B887F670B';
  P_UMX_REG_SVC_B.EMAIL_VERIFICATION_FLAG     := 'N';
  P_UMX_REG_SVC_B.APPLICATION_ID              := 20003;
  P_UMX_REG_SVC_B.AME_APPLICATION_ID          := 20003;
  P_UMX_REG_SVC_B.AME_TRANSACTION_TYPE_ID     := 'AWAS_ACCESS';
  P_UMX_REG_SVC_B.START_DATE                  := SYSDATE;
  P_UMX_REG_SVC_B.CREATED_BY                  := 1622;
  P_UMX_REG_SVC_B.CREATION_DATE               := SYSDATE;
  P_UMX_REG_SVC_B.LAST_UPDATED_BY             := 1622;
  P_UMX_REG_SVC_B.LAST_UPDATE_DATE            := SYSDATE;
  P_UMX_REG_SVC_B.LAST_UPDATE_LOGIN           := -1;


  INSERT INTO UMX_REG_SERVICES_B
  VALUES P_UMX_REG_SVC_B;
  
  END UMX_REG_SVCS_B_INS_API;
  
/*-----------------------------------------------------------------------------
 * PROCEDURE UMX_REG_SVCS_TL_INS_API
 * API to insert into UMX_REG_SVCS_TL Table
 *----------------------------------------------------------------------------*/ 
PROCEDURE UMX_REG_SVCS_TL_INS_API(P_UMX_REG_SVC_TL IN OUT UMX_REG_SERVICES_TL%ROWTYPE) AS
  
  BEGIN
  

  -- STATIC VALUES
  P_UMX_REG_SVC_TL.LANGUAGE              := 'US';
  P_UMX_REG_SVC_TL.SOURCE_LANG           := 'US';
  
  
  P_UMX_REG_SVC_TL.CREATED_BY                  := 1622;
  P_UMX_REG_SVC_TL.CREATION_DATE               := SYSDATE;
  P_UMX_REG_SVC_TL.LAST_UPDATED_BY             := 1622;
  P_UMX_REG_SVC_TL.LAST_UPDATE_DATE            := SYSDATE;
  P_UMX_REG_SVC_TL.LAST_UPDATE_LOGIN           := -1;


  INSERT INTO UMX_REG_SERVICES_TL
  VALUES P_UMX_REG_SVC_TL;
  
  END UMX_REG_SVCS_TL_INS_API;
  
/*-----------------------------------------------------------------------------
 * PROCEDURE XX_EXTERNAL_ACCESS
 * Used by workflow to insert records back in TBLUSERROLE@BASIN
 *----------------------------------------------------------------------------*/ 
  
PROCEDURE XX_EXTERNAL_ACCESS
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) IS
    
    L_PERSON_ID NUMBER;
    L_ROLE_ID NUMBER;
    L_ROLE VARCHAR2 (320);
    L_USER_ID VARCHAR2(15);
    Xx_Rowid Rowid;
    XX_CHK VARCHAR2(320);
    duplicate_count number;
        
    
    
    BEGIN
    IF ( funcmode = 'RUN' ) THEN
    
    L_ROLE := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'WF_ROLE_NAME' ) ;
   
    L_USER_ID := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'REQUESTED_FOR_USER_ID' ) ;
       
        
    select L_ROLE
    into xx_chk
    from dual;
    
    if xx_chk like 'UMX%X%' then
    
    --dbms_output.put_line('xx_chk='||xx_chk);
    
    --Select Substr(Name,Instr(Name,'X',1,2)+1, 3)*1
    SELECT SUBSTR(NAME,INSTR(NAME,'X',1,2)+1)*1
    INTO L_ROLE_ID
    FROM WF_LOCAL_ROLES  WHERE NAME = L_ROLE;
    
    
    select to_number(p.attribute1)    
    INTO L_PERSON_ID
    from per_all_people_f p,
        fnd_user u
    Where U.User_Id = L_User_Id
    and p.person_type_id = 6
    and p.person_id = u.employee_id;
    
    
    dbms_output.put_line('l_user_id='||l_user_id);
    dbms_output.put_line('xx_chk='||xx_chk);
    dbms_output.put_line('l_person_id:'||l_person_id);
    dbms_output.put_line('l_role_id:'||l_role_id);
    
    If L_Role_Id <> 9999 Then
    
    SELECT COUNT(*)
    INTO DUPLICATE_COUNT
    FROM TBLUSERROLE@BASIN WHERE PERSON_ID = L_PERSON_ID AND SYSROLE_ID = L_ROLE_ID;
    
    if duplicate_count = 0 then
    INSERT INTO TBLUSERROLE@BASIN(PERSON_ID,SYSROLE_ID)
    VALUES (L_PERSON_ID,L_ROLE_ID);
    end if;
    end if;
    END IF;
    
    END IF; 
    
    END XX_EXTERNAL_ACCESS;
    
    
/*-----------------------------------------------------------------------------
 * PROCEDURE XX_CREAET_GRANTS
 * API to call FND_GRANTS_PKG.GRANT_FUNCTION to create grants
 *----------------------------------------------------------------------------*/ 
PROCEDURE XX_CREATE_GRANTS (L_INSTANCE_PK1_VALUE IN VARCHAR2,
                                L_DESCRIPTION IN VARCHAR2) IS
                                
  P_API_VERSION NUMBER;
  P_MENU_NAME VARCHAR2(200);
  P_OBJECT_NAME VARCHAR2(200);
  P_INSTANCE_TYPE VARCHAR2(200);
  P_INSTANCE_SET_ID NUMBER;
  P_INSTANCE_PK1_VALUE VARCHAR2(200);
  P_INSTANCE_PK2_VALUE VARCHAR2(200);
  P_INSTANCE_PK3_VALUE VARCHAR2(200);
  P_INSTANCE_PK4_VALUE VARCHAR2(200);
  P_INSTANCE_PK5_VALUE VARCHAR2(200);
  P_GRANTEE_TYPE VARCHAR2(200);
  P_GRANTEE_KEY VARCHAR2(200);
  P_START_DATE DATE;
  P_END_DATE DATE;
  P_PROGRAM_NAME VARCHAR2(200);
  P_PROGRAM_TAG VARCHAR2(200);
  X_GRANT_GUID RAW(200);
  X_SUCCESS VARCHAR2(200);
  X_ERRORCODE NUMBER;
  P_PARAMETER1 VARCHAR2(200);
  P_PARAMETER2 VARCHAR2(200);
  P_PARAMETER3 VARCHAR2(200);
  P_PARAMETER4 VARCHAR2(200);
  P_PARAMETER5 VARCHAR2(200);
  P_PARAMETER6 VARCHAR2(200);
  P_PARAMETER7 VARCHAR2(200);
  P_PARAMETER8 VARCHAR2(200);
  P_PARAMETER9 VARCHAR2(200);
  P_PARAMETER10 VARCHAR2(200);
  P_CTX_SECGRP_ID NUMBER;
  P_CTX_RESP_ID NUMBER;
  P_CTX_RESP_APPL_ID NUMBER;
  P_CTX_ORG_ID NUMBER;
  P_NAME VARCHAR2(200);
  P_DESCRIPTION VARCHAR2(200);
BEGIN
  P_API_VERSION := 1;
  P_MENU_NAME := 'UMX_OBJ_REG_SRVC_PERMS';
  P_OBJECT_NAME := 'UMX_REG_SRVC';
  P_INSTANCE_TYPE := 'INSTANCE';
  P_INSTANCE_SET_ID := NULL;
  P_INSTANCE_PK1_VALUE := L_INSTANCE_PK1_VALUE;
  P_INSTANCE_PK2_VALUE := NULL;
  P_INSTANCE_PK3_VALUE := NULL;
  P_INSTANCE_PK4_VALUE := NULL;
  P_INSTANCE_PK5_VALUE := NULL;
  P_GRANTEE_TYPE := 'GLOBAL';
  P_GRANTEE_KEY :='GLOBAL';
  P_START_DATE := SYSDATE;
  P_END_DATE := NULL;
  P_PROGRAM_NAME := 'ELIGIBLITY';
  P_PROGRAM_TAG := 'UMX';
  P_PARAMETER1 := NULL;
  P_PARAMETER2 := NULL;
  P_PARAMETER3 := NULL;
  P_PARAMETER4 := NULL;
  P_PARAMETER5 := NULL;
  P_PARAMETER6 := NULL;
  P_PARAMETER7 := NULL;
  P_PARAMETER8 := NULL;
  P_PARAMETER9 := NULL;
  P_PARAMETER10 := NULL;
  P_CTX_SECGRP_ID := -1;
  P_CTX_RESP_ID := -1;
  P_CTX_RESP_APPL_ID := -1;
  P_CTX_ORG_ID := -1;
  P_NAME := 'Access Request Eligibility';
  P_DESCRIPTION := 'Grant allowing end users to request the '||L_DESCRIPTION||' role in Access Request page. Do not modify.';

  FND_GRANTS_PKG.GRANT_FUNCTION(
    P_API_VERSION => P_API_VERSION,
    P_MENU_NAME => P_MENU_NAME,
    P_OBJECT_NAME => P_OBJECT_NAME,
    P_INSTANCE_TYPE => P_INSTANCE_TYPE,
    P_INSTANCE_SET_ID => P_INSTANCE_SET_ID,
    P_INSTANCE_PK1_VALUE => P_INSTANCE_PK1_VALUE,
    P_INSTANCE_PK2_VALUE => P_INSTANCE_PK2_VALUE,
    P_INSTANCE_PK3_VALUE => P_INSTANCE_PK3_VALUE,
    P_INSTANCE_PK4_VALUE => P_INSTANCE_PK4_VALUE,
    P_INSTANCE_PK5_VALUE => P_INSTANCE_PK5_VALUE,
    P_GRANTEE_TYPE => P_GRANTEE_TYPE,
    P_GRANTEE_KEY => P_GRANTEE_KEY,
    P_START_DATE => P_START_DATE,
    P_END_DATE => P_END_DATE,
    P_PROGRAM_NAME => P_PROGRAM_NAME,
    P_PROGRAM_TAG => P_PROGRAM_TAG,
    X_GRANT_GUID => X_GRANT_GUID,
    X_SUCCESS => X_SUCCESS,
    X_ERRORCODE => X_ERRORCODE,
    P_PARAMETER1 => P_PARAMETER1,
    P_PARAMETER2 => P_PARAMETER2,
    P_PARAMETER3 => P_PARAMETER3,
    P_PARAMETER4 => P_PARAMETER4,
    P_PARAMETER5 => P_PARAMETER5,
    P_PARAMETER6 => P_PARAMETER6,
    P_PARAMETER7 => P_PARAMETER7,
    P_PARAMETER8 => P_PARAMETER8,
    P_PARAMETER9 => P_PARAMETER9,
    P_PARAMETER10 => P_PARAMETER10,
    P_CTX_SECGRP_ID => P_CTX_SECGRP_ID,
    P_CTX_RESP_ID => P_CTX_RESP_ID,
    P_CTX_RESP_APPL_ID => P_CTX_RESP_APPL_ID,
    P_CTX_ORG_ID => P_CTX_ORG_ID,
    P_NAME => P_NAME,
    P_DESCRIPTION => P_DESCRIPTION
  );                            
    
    END XX_CREATE_GRANTS;
    
PROCEDURE  delete_role
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
     v_end_date                 DATE;
     V_User_Name                 Varchar2 (50 ) ;
     v_role_name                 VARCHAR2 (100 ) ;
     l_person_id  number;
     l_role_id number;
     
BEGIN
     IF ( funcmode = 'RUN' ) THEN

          event := wf_engine.getitemattrevent ( itemtype => itemtype, itemkey => itemkey, NAME => 'CHANGE_EVENT_PAYLOAD' ) ;
          change_event_document   := event.geteventdata ( ) ;
          
          v_record_type := irc_xml_util.valueof ( change_event_document, '/wf_user_role_assignments/record_type' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'RECORD_TYPE', avalue => v_record_type ) ;
          
          v_user_name := irc_xml_util.valueof ( change_event_document, '/wf_user_role_assignments/user_name' ) ;
         
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'USER_NAME', avalue => v_user_name ) ;
          
          v_role_name := irc_xml_util.valueof ( change_event_document, '/wf_user_role_assignments/role_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'ROLE_NAME', avalue => v_role_name ) ;
          
          v_end_date := irc_xml_util.valueof ( change_event_document, '/wf_user_role_assignments/end_date' ) ;
          select to_date(v_end_date,'dd-mm-yyyy')
          into v_end_date
          from dual;
          
          wf_engine.setitemattrdate ( itemtype => itemtype, itemkey => itemkey, aname => 'END_DATE', avalue => v_end_date ) ;
         
         dbms_output.put_line('v_user_name:'||v_user_name);
         dbms_output.put_line('v_role_name:'||v_role_name);
         
    if v_role_name like 'UMX%X%' and v_end_date is not null and v_end_date < sysdate+1 then
        
    SELECT SUBSTR(NAME,INSTR(NAME,'X',1,2)+1, 3)*1
    INTO L_ROLE_ID
    FROM WF_LOCAL_ROLES  WHERE NAME = v_role_name;
        
    SELECT P.PERSON_ID 
    INTO L_PERSON_ID
    FROM   TBLPERSON@BASIN p
    WHERE  P.PERSON_ID = ( select to_number(p.attribute1)
                          from per_all_people_f p,
                               fnd_user u
                          Where P.Person_Id = U.Employee_Id
                          and p.person_type_id = 6
                          and u.user_name = V_USER_NAME );
    
    delete TBLUSERROLE@BASIN
    where person_id = L_PERSON_ID
    and sysrole_id = L_ROLE_ID;
    
    wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'RECORD_TYPE', avalue => 'Deleted' ) ;
    
    END IF;
                             
    END IF;         
     
END delete_role;
    
    
procedure query_role_description (item_type    in  varchar2,
                                     item_key     in  varchar2,
                                     activity_id  in  number,
                                     command      in  varchar2,
                                     resultout    out NOCOPY varchar2) is

    l_role_name wf_local_roles.name%type;
    L_Role_Display_Name Umx_Reg_Services_Tl.Description%Type;
    L_Username Fnd_User.User_Name%Type;
    
  BEGIN

    if (command = 'RUN') then

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.queryroledisplayname.begin', 'Begin');
      end if;

      l_role_name := wf_engine.getitemattrtext (itemtype => item_type,
                                                itemkey => item_key,
                                                aname => 'WF_ROLE_NAME',
                                                ignore_notfound => false);

      if (l_role_name is not null) then

        begin
            select t.description 
            into l_role_display_name
          from umx_reg_services_tl t
          where reg_service_code = l_role_name;
          
        exception
          when NO_DATA_FOUND THEN
            l_role_display_name :='No Description Available';
        end;

      end if;

      if (l_role_display_name is not null) then
        wf_engine.setitemattrtext (itemtype => item_type,
                                   itemkey => item_key,
                                   aname  => 'XX_ROLE_DESCRIPTION',
                                   avalue => l_role_display_name);
      end if;
      
            
      
      l_username := wf_engine.getitemattrtext (itemtype => item_type,
                                                Itemkey => Item_Key,
                                                aname => 'REQUESTED_USERNAME',
                                                Ignore_Notfound => False);

      Wf_Engine.Setitemattrtext (Itemtype => item_type,
                                   itemkey => item_key,
                                   Aname  => 'APPLICATION_URL',
                                   Avalue => 'https://portal.awas.com/mysite/Person.aspx?accountname=AWAS%2DSYD%2DDOM1%5C'||l_username);


      resultout := 'COMPLETE';

      if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                        'fnd.plsql.UMXNTFSB.queryRoleDisplayName.end',
                        'roleDisplayName:'|| l_role_display_name);
      end if;
    end if;

  END query_role_description;
  
  
  -- Check notes used by UMXWF to validate that response is flled in.
  PROCEDURE check_notes(itemtype IN VARCHAR2
                                ,itemkey  IN VARCHAR2
                                ,actid    IN NUMBER
                                ,funcmode IN VARCHAR2
                                ,RESULT   IN OUT VARCHAR2) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    l_responder            VARCHAR2(50);
    v_response_reason      VARCHAR2(80);
    
  BEGIN
    IF (funcmode IN ('RESPOND','RUN'))
    THEN
      L_Nid := Wf_Engine.Context_Nid;
      v_response_reason := wf_notification.getattrtext(l_nid,'WF_NOTE');
      
                                                      
      IF v_response_reason IS NULL
      THEN
        RESULT := 'ERROR: You must enter a justification for either rejecting or approving this access request in the Note Field below.';
        RETURN;
      END IF;
      
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      Result := Sqlerrm;
  End Check_Notes;
  
END XX_UMX_PKG;
/
