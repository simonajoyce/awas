CREATE OR REPLACE PACKAGE XX_BANK_ACCOUNT_WF_PKG AUTHID CURRENT_USER AS
/*******************************************************************************
PACKAGE NAME : XX_BANK_ACCOUNT_WF_PKG
CREATED BY   : Simon Joyce
DATE CREATED : 20-Feb-2013
--
PURPOSE      : Package which contains the procedures used by the AWAS Bank
              Account Approval Workflow
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
20-02-2013 SJOYCE     First Version
25-07-2013 SJOYCE     R12 Version
*******************************************************************************/

PROCEDURE wf_start
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE fyi_result(itemtype IN VARCHAR2,
                        itemkey in varchar2,
                        actid   IN NUMBER,
                        funcmode in varchar2,
                        RESULTOUT  OUT NOCOPY varchar2 );

PROCEDURE update_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        RESULTOUT  OUT NOCOPY varchar2 );

PROCEDURE update_history2(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        RESULTOUT  OUT NOCOPY varchar2 );


PROCEDURE record_approved(itemtype IN VARCHAR2,
                        ITEMKEY in varchar2 );


PROCEDURE set_attribute_values(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 );

PROCEDURE notification_handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE notification_handler2(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  out nocopy varchar2 );

procedure notification_handler3(itemtype in varchar2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode in varchar2,
                        resultout  out nocopy varchar2 );

PROCEDURE notification_handler4(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode in varchar2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE notification_handler5(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode in varchar2,
                        resultout  out nocopy varchar2 );

procedure notification_handler6(itemtype in varchar2,
                        itemkey IN VARCHAR2,
                        actid   in number,
                        funcmode in varchar2,
                        resultout  out nocopy varchar2 );

PROCEDURE notification_handler7(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   in number,
                        funcmode in varchar2,
                        resultout  out nocopy varchar2 );

PROCEDURE Abort_Process(
          P_itemtype     IN   wf_items.item_type%TYPE,
          P_itemkey      IN   wf_items.item_key%TYPE);

PROCEDURE Purge_Process(
          P_itemtype     IN   wf_items.item_type%TYPE,
          P_itemkey      IN   wf_items.item_key%TYPE);

PROCEDURE attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	);


  procedure get_attachments (document_id in varchar2, display_type in varchar2, document in out blob, document_type in out varchar2);

  PROCEDURE xx_bank_account_changes
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode in varchar2,
          resultout OUT NOCOPY VARCHAR2 );
          
 PROCEDURE GET_BANK_ADDRESS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
);

 PROCEDURE GET_BRANCH_ADDRESS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
);

  PROCEDURE GET_BRANCH_CONTACTS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
);

  PROCEDURE GET_ACCOUNT_CONTACTS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
);

END XX_BANK_ACCOUNT_WF_PKG;
/


CREATE OR REPLACE PACKAGE BODY XX_BANK_ACCOUNT_WF_PKG AS

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'XX_BANK_ACCOUNT_WF_PKG';
  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.XX_BANK_ACCOUNT_WF_PKG.';


PROCEDURE fyi_result(itemtype IN VARCHAR2,
                        itemkey in varchar2,
                        actid   IN NUMBER,
                        funcmode in varchar2,
                        resultout  out nocopy varchar2 )
is
begin

  resultout := 'FYI Complete';
           return;
           

end fyi_result;

/*-------------------------------------------------------------------------
-- WF_START base procedure calls other procedures required to initialise wf
-------------------------------------------------------------------------*/
PROCEDURE wf_start
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 )
IS
     
BEGIN


     if ( FUNCMODE = 'RUN' ) then

     -- Call Set_attribute_values to initialise values
     SET_ATTRIBUTE_VALUES(ITEMTYPE,ITEMKEY);
    
     END IF;         
    
  return;
    
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APBANK',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
        RAISE; 

END wf_start;

/*-------------------------------------------------------------------------
-- RECORD_APPROVED procedure runs all updates 
-------------------------------------------------------------------------*/
procedure RECORD_APPROVED(ITEMTYPE in varchar2,
                        ITEMKEY in varchar2 ) is
                        
                        
begin

    UPDATE ap.ap_bank_account_uses_all
    SET  START_DATE = ATTRIBUTE1,
         END_DATE = ATTRIBUTE2
    where BANK_ACCOUNT_USES_ID = ITEMKEY;


end record_approved;

/*-------------------------------------------------------------------------
-- update_history procedure run to handle first stage approval
-------------------------------------------------------------------------*/
PROCEDURE update_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

l_next_approver AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name          varchar2(30);
l_approver_name varchar2(50);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(500);
l_approver	VARCHAR2(150);
l_approver_id	NUMBER(15);
l_xx_trx_id	NUMBER(15);
l_result	VARCHAR2(50);
l_hist_id	NUMBER(15);
l_comments	VARCHAR2(240);
l_status	VARCHAR2(50);
l_org_id	NUMBER(15);
l_user_id	NUMBER(15);
l_login_id	NUMBER(15);
l_api_name      CONSTANT VARCHAR2(100) := 'update_history';
l_temp_invoice_id NUMBER(15);        -- Bug 5037108
l_error_message   VARCHAR2(2000);    -- Bug 5037108
l_bank_account_id number;
l_version_id number;



BEGIN
--Get attribute values to update the history table

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'XX_WFAPPROVAL_PKG.update_history (+)');
    END IF;

	l_approver := WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_ANA');

	l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_ANAI');

	l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

  l_bank_account_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XX_BANK_ACCOUNT_ID');                                  
  
  l_version_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XX_VERSION_ID');                                  

	l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_AC');

	l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AHI');


	l_result := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                        				  'XXAME_RSLT');

        
  l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        ITEMKEY,
                        'XXAME_AOI');

    -----------------------------------------------------------------
    
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -----------------------------------------------------------------

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);


	WF_ENGINE.SetItemAttrText(itemtype,
				ITEMKEY,
				'XXAME_APC',
				l_comments);

 	l_user_id := FND_GLOBAL.USER_ID;
	
  
     select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;

	IF l_result = 'APPROVED' THEN
	   l_result := 'WFAPPROVED';
         
           
	END IF;

	

	IF L_RESULT = 'REJECTED' THEN
               --update trx to rejected status
              
           update ce_bank_accounts
           set   attribute10 = 'R'
           where bank_account_id = l_bank_account_id;
           
       
	end if;
  
  --update approval history 
        insert into xx_bank_account_aprvl_hist (history_id,bank_account_id, approver,response_date,response,comments,version_id)
        values (xx_bank_account_aprvl_hist_s.nextval,l_bank_account_id,l_approver_name,sysdate,l_result,l_comments,l_version_id);
  

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('xx_bank_account_wf_pkg', 'update_history', itemtype, itemkey, to_char(actid), l_debug_info);
    raise;

END UPDATE_HISTORY;

/*-------------------------------------------------------------------------
-- update_history2 procedure run to handle second stage approval
-------------------------------------------------------------------------*/
PROCEDURE update_history2(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

l_next_approver AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name          VARCHAR2(30);
l_display_name  varchar2(150);
l_approver_name varchar2(50);
l_debug_info    VARCHAR2(500);
l_approver	VARCHAR2(150);
l_approver_id	NUMBER(15);
l_xx_trx_id	NUMBER(15);
l_result	VARCHAR2(50);
l_hist_id	NUMBER(15);
l_comments	VARCHAR2(240);
l_status	VARCHAR2(50);
l_org_id	NUMBER(15);
l_user_id	NUMBER(15);
l_login_id	NUMBER(15);
l_api_name      CONSTANT VARCHAR2(100) := 'update_history';
l_temp_invoice_id NUMBER(15);        -- Bug 5037108
l_error_message   varchar2(2000);    -- Bug 5037108
l_bank_account_id number;
l_version_id number;

BEGIN
--Get attribute values to update the history table

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'XX_WFAPPROVAL_PKG.update_history (+)');
    END IF;

	l_approver := WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_ANA');

	l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_ANAI');

	l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');
                                  
  l_bank_account_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XX_BANK_ACCOUNT_ID');                                  
  
  l_version_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XX_VERSION_ID');                                  

	l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_AC');

	l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AHI');

	l_result := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                        				  'XXAME_RSLT');

  l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        ITEMKEY,
                        'XXAME_AOI');

    -----------------------------------------------------------------
    
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -----------------------------------------------------------------

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);


	WF_ENGINE.SetItemAttrText(itemtype,
				ITEMKEY,
				'XXAME_APC',
				l_comments);

 	l_user_id := FND_GLOBAL.USER_ID;
	l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);
  
     select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;


	IF l_result = 'APPROVED' THEN
	   l_result := 'WFAPPROVED';
           
           
           update ce_bank_accounts
           set end_date = null,
               attribute10 = 'A'
           where bank_account_id = l_bank_account_id
           and attribute10 <> 'A';
           
           
	END IF;


	IF L_RESULT = 'REJECTED' THEN
               --update trx to rejected status
    
              
           update ce_bank_accounts
           set   attribute1 = 'R'
           where bank_account_id = l_bank_account_id;
  
       
	end if;
  
   --update approval history 
        insert into xx_bank_account_aprvl_hist (history_id,bank_account_id, approver,response_date,response,comments,version_id)
        values (xx_bank_account_aprvl_hist_s.nextval,l_bank_account_id,l_approver_name,sysdate,l_result,l_comments,l_version_id);

EXCEPTION
  when others then
    Wf_Core.Context('xx_bank_account_wf_pkg', 'update_history2', itemtype, itemkey, to_char(actid), l_debug_info);
    raise;

END UPDATE_HISTORY2;

/*-------------------------------------------------------------------------
-- set_attribute_values procedure set initial values and re-initialises as required
-------------------------------------------------------------------------*/
PROCEDURE set_attribute_values(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 ) IS

l_ret_approver VARCHAR2(50);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_name          VARCHAR2(30);
l_approver      VARCHAR2(150);
l_approver_id   NUMBER(15);
l_xx_trx_id    NUMBER(15);
l_result        VARCHAR2(50);
l_org_id       NUMBER(15);
l_comments      VARCHAR2(240);
l_iteration     NUMBER(9);
l_prev_com	VARCHAR2(240);
l_requester_id  NUMBER(15);
l_requester_name varchar(250);
l_created_by_username varchar2(50);

  l_vp_treasury_id       fnd_user.user_name%type;
  l_vp_treasury_name   per_all_people_f.last_name%type;
  
                  l_bank_name           ce_bank_branches_v.bank_name%type;
                  l_bank_description    ce_bank_branches_v.description%type;
                  L_BANK_BRANCH_NAME    CE_BANK_BRANCHES_V.BANK_BRANCH_NAME%TYPE;
                  l_bank_num            ce_bank_branches_v.branch_number%type;
                  l_br_address          varchar2(2000);
                  --R12 l_br_contact_name     varchar2(100);
                  --R12 l_br_contact_num      varchar2(50);
                  --R12 l_br_contact_email    varchar2(50);
                  --R12 l_relationship_mgr    varchar2(50);
                  --R12 l_rm_address          varchar2(150);
                  --R12 l_rm_email            varchar2(50);
                  --R12 L_RM_PHONE            VARCHAR2(50);
                  --R12 l_audit_address       ce_bank_branches_v.address_lines_alt%type;
                  l_bank_account_name   ce_bank_accounts.bank_account_name%type;
                  l_bank_account_num    ce_bank_accounts.bank_account_num%type;
                  l_iban_number         ce_bank_accounts.iban_number%type;
                  l_currency_code       ce_bank_accounts.currency_code%type;
                  l_end_date       ce_bank_accounts.end_date%type;
                  l_created_by          fnd_user.description%type;
                  l_created_id          fnd_user.user_id%type;
                  l_creation_date       ce_bank_accounts.creation_date%type;
                  l_ba_desc             ce_bank_accounts.description%type;
                  l_ba_contact          varchar2(100);
                  l_ba_contact_phone    varchar2(50);
                  l_bank_account_type   ce_bank_accounts.bank_account_type%type;
                  l_instrument          ce_bank_accounts.attribute1%TYPE;
                  l_purpose             ce_bank_accounts.attribute1%type;
                  l_rate_pa             ce_bank_accounts.attribute1%TYPE;
                  l_online              ce_bank_accounts.attribute1%TYPE;
                  l_facility            ce_bank_accounts.attribute1%type;
                  l_msn                 ce_bank_accounts.bank_account_name_alt%type;
                  l_treasury_member     fnd_user.user_name%type;
                  x_treasury_member     fnd_user.user_name%TYPE;
  
BEGIN
 
/*   Not required for R12

        -- get org id
        SELECT org_id
        into l_org_id
        FROM ce_bank_accounts
        WHERE bank_account_id = itemkey;

      
        -- set org id
        WF_ENGINE.SETITEMATTRNumber(itemtype,
                        ITEMKEY,
                        'XXAME_AOI',
                        l_org_id);

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);
*/

        wf_engine.setitemattrnumber(itemtype,
                        itemkey,
                        'XX_VERSION_ID',
                        itemkey);
                        
        wf_engine.setitemattrnumber(itemtype,
                        itemkey,
                        'XX_BANK_ACCOUNT_ID',
                        itemkey);
	
 -- set VP Treasury 
        select pap.last_name, fu.user_name
        into l_vp_treasury_name,
              l_vp_treasury_id
        from per_all_people_f pap, 
             per_all_assignments_f asn, 
             per_jobs jobs,
             fnd_user fu
        where pap.person_id = asn.person_id
        and jobs.job_id = asn.job_id
        and fu.employee_id = pap.persoN_id
        and jobs.name = 'VPTREAS';

        WF_ENGINE.SETITEMATtrText(itemtype,
                        ITEMKEY,
                        'XX_VP_TREASURY_NAME',
                        l_vp_treasury_name);
        
        wf_engine.SETITEMATtrText(itemtype,
                        itemkey,
                        'TREASURY_VP',
                        l_vp_treasury_id);



select          b.bank_name,
                  b.description branch_description,
                  b.bank_branch_name, 
                  b.branch_number, 
                  B.ADDRESS_LINE1||DECODE(B.ADDRESS_LINE2,NULL,NULL,', ')||B.ADDRESS_LINE2
                  ||decode(b.address_line3,null,null,', ')||b.address_line3
                  ||decode(b.address_line4,null,null,', ')||b.address_line4
                  ||decode(b.city,null,null,', ')||b.city
                  ||decode(b.state,null,null,', ')||b.state
                  ||decode(b.zip,null,null,', ')||b.zip
                  ||DECODE(B.COUNTRY,NULL,NULL,', ')||B.COUNTRY  BRANCH_ADDRESS,
                  --R12 b.contact_title||decode(b.contact_title,null,' ',null)||b.contact_first_name||' '||b.contact_last_name contact_name,
                  --R12 b.area_code||' '||b.phone contact_number,
                  --R12 b.bank_admin_email contact_email,
                  --R12 b.attribute1 relationship_manager,
                  --R12 b.attribute2 rm_address,
                  --R12 b.attribute3 rm_email,
                  --R12 b.attribute4 rm_phone,
                  --R12 b.address_lines_alt Audit_Address,
                  a.bank_account_name, 
                  a.bank_account_num, 
                  a.iban_number,
                  a.currency_code,
                  a.end_date,
                  f.user_name created_by,
                  f.user_id,
                  a.creation_date,
                  A.DESCRIPTION,
                  --R12 a.contact_first_name||' '||a.contact_last_name,
                  --R12 a.contact_area_code||' '||a.contact_phone,
                  a.bank_account_type,
                  A.ATTRIBUTE2,
                  a.attribute4,
                  a.attribute5,
                  a.attribute6,
                  a.attribute7,
                  a.bank_account_name_alt                  ,
                  f.user_name 
    into          l_bank_name,
                  l_bank_description,
                  l_bank_branch_name,
                  l_bank_num,
                  L_BR_ADDRESS,
                  --R12 l_br_contact_name,
                  --R12 l_br_contact_num,
                  --R12 l_br_contact_email,
                  --R12 l_relationship_mgr,
                  --R12 l_rm_address,
                  --R12 l_rm_email,
                  --R12 l_rm_phone,
                  --R12 l_audit_address,
                  l_bank_account_name,
                  l_bank_account_num,
                  l_iban_number,
                  l_currency_code,
                  l_end_date,
                  l_created_by,
                  l_created_id,
                  L_CREATION_DATE,
                  l_ba_desc,
                  --R12 l_ba_contact,
                  --R12 l_ba_contact_phone,
                  l_bank_account_type,
                  L_INSTRUMENT,
                  l_purpose,
                  l_rate_pa,
                  l_online,
                  l_facility,
                  l_msn,
                  l_created_by_username
          from    ce_bank_accounts a,
                  ce_bank_branches_v b,
                  fnd_user f
          where   b.branch_party_id = a.bank_branch_id
                  and f.user_id = a.created_by
                  and a.bank_account_id = itemkey;
                  


     wf_engine.setitemattrtext(itemtype,itemkey,'BANK_NAME',l_bank_name);
     WF_ENGINE.SetItemAttrText(itemtype,ITEMKEY,'BANK_DESC',l_bank_description);
     wf_engine.setitemattrtext(itemtype,itemkey,'BANK_BRANCH_NAME',l_bank_branch_name);
     WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BR_ADDRESS',L_BR_ADDRESS);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'BR_CONTACT_NAME',l_br_contact_name);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'BR_CONTACT_NUM',l_br_contact_num);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'BR_CONTACT_EMAIL',l_br_contact_email);
     --R12 WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'RM',L_RELATIONSHIP_MGR);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'RM_ADDRESS',l_rm_address);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'RM_PHONE',l_rm_phone);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'RM_EMAIL',l_rm_email);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'AUDIT_ADDRESS',l_audit_address);
     WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_NUM',L_BANK_NUM);
     WF_ENGINE.SetItemAttrText(itemtype,ITEMKEY,'BANK_ACCOUNT_NAME',l_bank_account_name);
     WF_ENGINE.SetItemAttrText(itemtype,ITEMKEY,'BANK_ACCOUNT_NUM',l_bank_account_num);
     WF_ENGINE.SetItemAttrText(itemtype,ITEMKEY,'IBAN_NUM',l_iban_number);
     WF_ENGINE.SetItemAttrText(itemtype,ITEMKEY,'CURRENCY_CODE',l_currency_code);
     wf_engine.setitemattrtext(itemtype,itemkey,'CREATED_BY',l_created_by);
     wf_engine.setitemattrnumber(itemtype,itemkey,'CREATED_ID',l_created_id);
     wf_engine.setitemattrdate(itemtype,itemkey,'CREATION_DATE',l_creation_date);
     wf_engine.setitemattrdate(itemtype,itemkey,'INACTIVE_DATE',l_end_date);
     WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BA_DESC',L_BA_DESC);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'BA_CONTACT',l_ba_contact);
     --R12 wf_engine.setitemattrtext(itemtype,itemkey,'BA_CONTACT_NUMBER',l_ba_contact_phone);
     wf_engine.setitemattrtext(itemtype,itemkey,'BANK_ACCOUNT_TYPE',l_bank_account_type);
     wf_engine.setitemattrtext(itemtype,itemkey,'INSTRUMENT',l_instrument);
     wf_engine.setitemattrtext(itemtype,itemkey,'PURPOSE',l_purpose);
     wf_engine.setitemattrtext(itemtype,itemkey,'RATE_PA',l_rate_pa);
     wf_engine.setitemattrtext(itemtype,itemkey,'ONLINE',l_online);
     wf_engine.setitemattrtext(itemtype,itemkey,'FACILITY',l_facility);
     wf_engine.setitemattrtext(itemtype,itemkey,'MSN',l_msn);
     wf_engine.setitemattrtext(itemtype,itemkey,'CREATED_BY_USER',l_created_by_username);
      
   

    l_requester_name := l_created_by;
    
        WF_ENGINE.SetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII',
                                   itemkey);
    
    
  -- here we set the initial treasury member, random

x_treasury_member :=   WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'TREASURY_MEMBER');
                                  
if x_treasury_member is null then                                
  
  select user_name 
  into l_treasury_member
  from (
select distinct fu.user_name
from per_all_people_f pap, 
per_all_assignments_f asn
, per_jobs jobs,
per_all_assignments_f asn2,
per_all_people_f pap2,
fnd_user fu
where pap.person_id = asn.person_id
and jobs.job_id = asn.job_id
and jobs.name = 'VPTREAS'
and asn2.supervisor_id = asn.person_id
and pap2.person_id = asn2.person_id
and fu.employee_id = pap2.person_id
and fu.user_id <> l_created_id
and pap2.current_employee_flag = 'Y'
and sysdate between pap2.effective_start_date and pap2.effective_end_date
order by
                                   dbms_random.value
                                   )
                                   where rownum = 1;

               

wf_engine.SETITEMATtrText(itemtype,
                        itemkey,
                        'TREASURY_MEMBER',
                        l_treasury_member);
        
end if;

	--set previous comments
        l_prev_com :=  WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_AC');

        WF_ENGINE.SetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_APC',
                                  l_prev_com);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'XXAME_AC',
                                  '');
  
END SET_ATTRIBUTE_VALUES;
/*-------------------------------------------------------------------------
-- notification_handler procedure run to handle first stage approval and
-- validate response etc
-------------------------------------------------------------------------*/

PROCEDURE notification_handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
    Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
    v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
  

            If (l_result='APPROVED') then
                                    
            l_result:='WFAPPROVED';
            End IF;
            
            l_user_id := FND_GLOBAL.USER_ID;
            
            WF_ENGINE.SetItemAttrNumber(itemtype,
                        ITEMKEY,
                        'XXAME_APP1',
                        l_user_id);
          
          select user_name||'-'||description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_APU1',
                        l_approver_name);
                        
           wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
            
        End if;
        
	if (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;
            
          select user_name||'-'||description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_APU2',
                        l_approver_name);

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

WHEN OTHERS
   then
        WF_CORE.CONTEXT('AWCUST',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler;
/*-------------------------------------------------------------------------
-- notification_handler2 procedure run to handle second stage approval and
-- validate response etc
-------------------------------------------------------------------------*/
PROCEDURE notification_handler2(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
v_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
    Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
    v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
             l_user_id := FND_GLOBAL.USER_ID;

            If (l_result='APPROVED') then
                        
            v_user_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XXAME_APP1') ;
            
          --  IF l_user_id = v_user_id then            
--            RESULTout := 'ERROR: You have already approved this Bank Account, another user must do the second approval.';
  --          RETURN;
    --        end if; 
            
            l_result:='WFAPPROVED';
            End IF;

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        ITEMKEY,
                        'XXAME_APP2',
                        l_user_id);
                        
            select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
    --       WF_ENGINE.SetItemAttrText(itemtype,
      --                  ITEMKEY,
        --                'XXAME_APU2',
          --              l_approver_name);
          
          wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
            
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;
        
	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

        WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

when others
   then
        WF_CORE.CONTEXT('xx_bank_account_wf_pkg.notification_handler2',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler2;

/*-------------------------------------------------------------------------
-- notification_handler3 procedure run to handle second stage approval and
-- validate response etc
-------------------------------------------------------------------------*/
PROCEDURE notification_handler3(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
v_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
    Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
    v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
             l_user_id := FND_GLOBAL.USER_ID;

            If (l_result='APPROVED') then
                        
            v_user_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XXAME_APP1') ;
            
          --  IF l_user_id = v_user_id then            
--            RESULTout := 'ERROR: You have already approved this Bank Account, another user must do the second approval.';
  --          RETURN;
    --        end if; 
            
            l_result:='WFAPPROVED';
            End IF;

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        ITEMKEY,
                        'XXAME_APP3',
                        l_user_id);
                        
            select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_APU3',
                        l_approver_name);
                        
                     wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
            
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;
        
	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

        WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

when others
   then
        WF_CORE.CONTEXT('xx_bank_account_wf_pkg.notification_handler3',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler3;

/*-------------------------------------------------------------------------
-- notification_handler4 procedure run to handle second stage approval and
-- validate response etc
-------------------------------------------------------------------------*/
PROCEDURE notification_handler4(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
v_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
    Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
    v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
             l_user_id := FND_GLOBAL.USER_ID;

            If (l_result='APPROVED') then
                        
            v_user_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XXAME_APP1') ;
            
          --  IF l_user_id = v_user_id then            
--            RESULTout := 'ERROR: You have already approved this Bank Account, another user must do the second approval.';
  --          RETURN;
    --        end if; 
            
            l_result:='WFAPPROVED';
            End IF;

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'XXAME_APP4',
                        l_user_id);
                        
            select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_APU4',
                        l_approver_name);
                        
                     wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
            
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;
        
	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

        WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

when others
   then
        WF_CORE.CONTEXT('xx_bank_account_wf_pkg.notification_handler4',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler4;

/*-------------------------------------------------------------------------
-- notification_handler5 procedure run to handle second stage approval and
-- validate response etc
-------------------------------------------------------------------------*/
PROCEDURE notification_handler5(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
v_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
    Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
    v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
             l_user_id := FND_GLOBAL.USER_ID;

            If (l_result='APPROVED') then
                        
            v_user_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XXAME_APP1') ;
            
          --  IF l_user_id = v_user_id then            
--            RESULTout := 'ERROR: You have already approved this Bank Account, another user must do the second approval.';
  --          RETURN;
    --        end if; 
            
            l_result:='WFAPPROVED';
            End IF;

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        ITEMKEY,
                        'XXAME_APP5',
                        l_user_id);
                        
            select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_APU5',
                        l_approver_name);
                        
                     wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
            
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;
        
	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

        WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

when others
   then
        WF_CORE.CONTEXT('xx_bank_account_wf_pkg.notification_handler5',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler5;


/*-------------------------------------------------------------------------
-- notification_handler6 procedure run to handle 1st stage of bank account update approval
-- validate response etc
-------------------------------------------------------------------------*/
PROCEDURE notification_handler6(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
v_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
    Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
    v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
             l_user_id := FND_GLOBAL.USER_ID;

            If (l_result='APPROVED') then
                        
            v_user_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XXAME_APP1') ;
            
          --  IF l_user_id = v_user_id then            
--            RESULTout := 'ERROR: You have already approved this Bank Account, another user must do the second approval.';
  --          RETURN;
    --        end if; 
            
            l_result:='WFAPPROVED';
            End IF;

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        ITEMKEY,
                        'XXAME_APP1',
                        l_user_id);
                        
            select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_APU1',
                        l_approver_name);
                        
                     wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
            
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;
        
	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

        WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

when others
   then
        WF_CORE.CONTEXT('xx_bank_account_wf_pkg.notification_handler6',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler6;

/*-------------------------------------------------------------------------
-- notification_handler7 procedure run to handle second stage bak account update
--approval and validate response etc
-------------------------------------------------------------------------*/
PROCEDURE notification_handler7(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
l_xx_trx_id    NUMBER(15);
l_iteration     NUMBER;
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id        NUMBER(15);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
v_user_id       NUMBER(15);
l_login_id      NUMBER(15);
v_response_reason      VARCHAR2(240);
l_approver_name varchar2(240);

BEGIN
    l_nid := WF_ENGINE.context_nid;
    l_xx_trx_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  ITEMKEY,
                                  'XXAME_AII');

    l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                                  itemkey,
                                  'XXAME_AOI');

    l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AI');
    l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'XXAME_AC');

    l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'XXAME_AHI');
    
   
    
     select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     And na.Name = 'RESULT';
    
     v_response_reason := wf_notification.getattrtext(l_nid,'XXAME_AC');
    
      IF l_activity_result_code = 'REJECTED' AND  v_response_reason IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
    
    
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     fnd_client_info.set_org_context(l_org_id);

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_ARN',
                        l_role);
                WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'XXAME_FUR',
                        l_role);

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

    IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);
             l_user_id := FND_GLOBAL.USER_ID;

            If (l_result='APPROVED') then
                        
            v_user_id := wf_engine.getitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XXAME_APP1') ;
            
          --  IF l_user_id = v_user_id then            
--            RESULTout := 'ERROR: You have already approved this Bank Account, another user must do the second approval.';
  --          RETURN;
    --        end if; 
            
            l_result:='WFAPPROVED';
            End IF;

           WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'TREASURY_VP',
                        l_user_id);
                        
            select description 
            into l_approver_name
            from fnd_user 
            where user_id = l_user_id;
            
           wf_engine.setitemattrtext(itemtype,
                        itemkey,
                        'XX_VP_TREASURY_NAME',
                        l_approver_name);
            
                       wf_engine.setitemattrtext(itemtype,
                                     itemkey,
                                    'XXAME_ANA',
                                    l_approver_name);
                                    
                        
          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;
        
	IF (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

        WF_ENGINE.SetItemAttrText(itemtype,itemkey,'XXAME_RSLT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'XXAME_FUR',
                        NULL);

            resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

when others
   then
        WF_CORE.CONTEXT('xx_bank_account_wf_pkg.notification_handler7',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END notification_handler7;



PROCEDURE Abort_Process(
          P_itemtype     IN   wf_items.item_type%TYPE,
          P_itemkey      IN   wf_items.item_key%TYPE)
IS
BEGIN

  WF_ENGINE.AbortProcess(itemtype => P_itemtype,
                         itemkey  => P_itemkey);

END Abort_Process;

PROCEDURE Purge_Process(
          P_itemtype     IN   wf_items.item_type%TYPE,
          P_itemkey      IN   wf_items.item_key%TYPE)
IS
BEGIN

  WF_PURGE.Items(itemtype => P_itemtype,
                 itemkey  => P_itemkey);
END Purge_Process;

PROCEDURE attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	)
	IS
	   l_attachment_count   NUMBER                  := NULL;
	   l_file_name          VARCHAR2 (100)          := NULL;
	   l_file_id            fnd_lobs.file_id%TYPE   := NULL;
	   l_file_attached      VARCHAR2 (4000);
	   l_attrname           wf_engine.nametabtyp;
     l_attrval            wf_engine.texttabtyp;
	   
	 
	   CURSOR c_file_table (p_bank_account_id NUMBER)
	   IS
	      select fl.file_id, fl.file_name, entity_name, pk1_value, tl.user_name category
	        from fnd_attached_documents fad, fnd_documents fdt, fnd_lobs fl, fnd_document_categories_tl tl
	       where  entity_name = 'CE_BANK_ACCOUNTS' and fad.pk1_value = p_bank_account_id
           and fad.document_id = fdt.document_id
	         AND fdt.media_id = fl.file_id
	         and (fl.expiration_date is null or fl.expiration_date > sysdate)
	         and tl.category_id = fad.category_id
           ;
	 
	   TYPE file_tbl IS TABLE OF c_file_table%ROWTYPE
	      INDEX BY BINARY_INTEGER;
	 
	   l_file_tbl           file_tbl;
	   l_run_query          VARCHAR2 (2000);
	   ln_bank_account_id      NUMBER;
     
  BEGIN
	   IF (funcmode != wf_engine.eng_run)
	   THEN
	      --  Do nothing in cancel or timeout mode
	      resultout := wf_engine.eng_null;
	      RETURN;
	      END IF;
  
        
	      ln_bank_account_id := apps.wf_engine.getitemattrnumber (itemtype,
	                                                           itemkey,
	                                                           'XXAME_AII'
	                                                          );
                                                            
        ln_bank_account_id := apps.wf_engine.getitemattrnumber (itemtype,
	                                                           itemkey,
	                                                           'XX_BANK_ACCOUNT_ID'
	                                                          );
        dbms_output.put_line('DOCUMENT_ID='||ln_bank_account_id);
   
	      -- Get the attachments into the PL/SQL table
	      OPEN c_file_table (ln_bank_account_id);
	 
	      FETCH c_file_table
	      BULK COLLECT INTO l_file_tbl;
	 
	      CLOSE c_file_table;
	 
	-------------------------------------------------------
	--Get the attachments
	--Assign to Document Attributes
	--------------------------------------------------------
	      IF l_file_tbl.COUNT > 0
	      THEN
        
        
	         FOR idx IN l_file_tbl.FIRST .. l_file_tbl.COUNT
	         LOOP
	            IF idx < 10   -- We are allowing a maximum of 10 attachments for a notification
	            THEN
	               
                 l_attrname (idx) := 'XX_APPROVAL_ATTACHMENT' || idx;
                 
                                  
	               l_attrval (idx) := 'PLSQLBLOB:xx_bank_account_wf_pkg.Get_Attachments/' || TO_CHAR (l_file_tbl (idx).file_id);
                 
                 
	            END IF;
	         END LOOP;
           
             
                wf_engine.setitemattrtextarray (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => l_attrname,
                                  avalue     => l_attrval);
             
        
	      END IF;
	   
	 
	   resultout := wf_engine.eng_completed;
	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xx_bank_account_wf_pkg', 'attachment_exist');
	      RAISE;
	end attachment_exist;
  

PROCEDURE get_attachments (document_id in varchar2, display_type in varchar2, document IN OUT BLOB, document_type IN OUT VARCHAR2)
	IS
	   l_attachment          BLOB;
	   l_amount              NUMBER;
	   l_file_name           VARCHAR2 (240)                    := NULL;
	   l_file_content_type   fnd_lobs.file_content_type%TYPE   := NULL;
	BEGIN
	   l_file_content_type := NULL;
	 
	   SELECT fl.file_data, fl.file_name, fl.file_content_type
	     INTO l_attachment, l_file_name, l_file_content_type
	     FROM fnd_lobs fl
	    WHERE fl.file_id = TO_NUMBER (document_id);
	 
	-------------------------------------------
	--Now copy the content to document
	------------------------------------------
	   l_amount := DBMS_LOB.getlength (l_attachment);
	   DBMS_LOB.COPY (document,
	                  l_attachment,
	                  l_amount,
	                  1,
	                  1
	                 );
	---------------------------------------------------------
	-- Set the MIME type as a part of the document_type.
	---------------------------------------------------------
	   document_type := l_file_content_type || '; name=' || l_file_name;
	EXCEPTION
	   WHEN OTHERS
	   then
	      wf_core.CONTEXT ('xx_bank_account_wf_pkg',
	                       'Get_Attachments',
	                       document_id,
	                       display_type
	                      );
	end get_attachments;
  
  PROCEDURE xx_bank_account_changes
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 )
IS
     bank_event_document CLOB;
     event wf_event_t;
     xmldoc xmldom.domdocument;
     parser xmlparser.parser;
     v_bank_account_number     VARCHAR2 ( 500 ) ;
     v_bank_account_number_old VARCHAR2 ( 500 ) ;
     v_bank_account_name       VARCHAR2 ( 500 ) ;
     v_bank_account_name_old   VARCHAR2 ( 500 ) ;
     v_bank_Asset_Acct         VARCHAR2 ( 500 ) ;
     v_bank_Asset_Acct_old     VARCHAR2 ( 500 ) ;
     v_ui                      VARCHAR2 ( 500 ) ;
     v_updated_by              varchar2 ( 60 ) ;
     v_iban                    ce_bank_accounts.iban_number%type;
     v_iban_old                ce_bank_accounts.iban_number%type;
     v_msn                     ce_bank_accounts.bank_account_name_alt%type;
     v_msn_old                 ce_bank_accounts.bank_account_name_alt%type;
     v_facility                ce_bank_accounts.attribute7%type;
     v_facility_old            ce_bank_accounts.attribute7%type;
     v_rate_p_a                ce_bank_accounts.attribute5%type;
     v_rate_p_a_old            ce_bank_accounts.attribute5%type;
     v_instrument              ce_bank_accounts.attribute2%type;
     v_instrument_old          ce_bank_accounts.attribute2%type;
     v_purpose                 ce_bank_accounts.attribute3%type;
     v_purpose_old             ce_bank_accounts.attribute3%type;
     v_bank_account_type       ce_bank_accounts.bank_account_type%type;
     v_bank_account_type_old   ce_bank_accounts.bank_account_type%type;
     v_contact                 varchar2(120);
     v_contact_old             varchar2(120);
     v_description             ce_bank_accounts.description%type; 
     v_description_old         ce_bank_accounts.description%type; 
     v_temp                    NUMBER;
     v_temp2                   NUMBER;
     v_temp3                   NUMBER;
     v_temp4                   NUMBER;
     v_bank                    VARCHAR2 ( 500 ) ;
     v_branch                  VARCHAR2 ( 500 ) ;
     v_address                 VARCHAR2 ( 500 ) ;
     v_swift                   VARCHAR2 ( 500 ) ;
     v_aba                     VARCHAR2 ( 500 ) ;
     v_currency                VARCHAR2 ( 500 ) ;
     v_currency_old            varchar2 ( 500 ) ;
     v_bank_account_id         number;
     v_date date;
     v_inactive DATE;
     v_old_inactive date;
      l_vp_treasury_id       fnd_user.user_name%type;
  l_vp_treasury_name   per_all_people_f.last_name%type;
       x_treasury_member     fnd_user.user_name%type;
       l_treasury_member     fnd_user.user_name%type;
       
     
BEGIN
     if ( funcmode = 'RUN' ) then
     
          /*--*/
          wf_engine.setitemattrnumber(itemtype,itemkey,'XX_VERSION_ID',itemkey);
          
          event                 := wf_engine.getitemattrevent ( itemtype => itemtype, itemkey => itemkey, name => 'BANK_ACC_CHANGED_PAYLOAD' ) ;
          
          
          bank_event_document   := event.geteventdata ( ) ;
          
          v_bank_account_id := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/bank_account_id' ) ;
          wf_engine.setitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'XX_BANK_ACCOUNT_ID', avalue => v_bank_account_id) ;
          
          v_bank_account_number := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/bank_account_number' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_NUMBER', avalue => v_bank_account_number ) ;
          
          --wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BANK_ACCT_NUMBER_FROM_PAYLOAD', avalue => v_bank_account_number ) ;
          v_bank_account_number_old := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_bank_account_number' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_NUMBER', avalue => v_bank_account_number_old ) ;
          v_bank_account_name := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/bank_account_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_NAME', avalue => v_bank_account_name ) ;
          v_bank_account_name_old := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_bank_account_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_NAME', avalue => v_bank_account_name_old ) ;
          
         v_iban                   := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/iban' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_IBAN', avalue => v_iban ) ;
         v_iban_old               := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_iban' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_IBAN', avalue => v_iban_old ) ;
         v_msn                    := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/msn' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_MSN', avalue => v_msn ) ;
         v_msn_old                := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_msn' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_MSN', avalue => v_msn_old ) ;
         v_facility               := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/facility' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_FACILITY', avalue => v_facility ) ;
         v_facility_old           := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_facility' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_FACILITY', avalue => v_facility_old ) ;
         v_rate_p_a               := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/rate_p_a' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_RATE_P_A', avalue => v_rate_p_a ) ;
         v_rate_p_a_old           := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_rate_p_a' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_RATE_P_A', avalue => v_rate_p_a_old ) ;
         v_instrument             := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/instrument' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_INSTRUMENT', avalue => v_instrument ) ;
         v_instrument_old         := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_instrument' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_INSTRUMENT', avalue => v_instrument_old ) ;
         v_purpose                := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/purpose' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_PURPOSE', avalue => v_purpose ) ;
         v_purpose_old            := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_purpose' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_PURPOSE', avalue => v_purpose_old ) ;
         v_bank_account_type      := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/bank_account_type' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_BANK_ACCOUNT_TYPE', avalue => v_bank_account_Type ) ;
         v_bank_account_type_old  := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_bank_account_type' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_BANK_ACCOUNT_TYPE', avalue => v_bank_account_type_old ) ;
         v_contact                := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/contact' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_CONTACT', avalue => v_contact ) ;
         v_contact_old            := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_contact' ) ;
         wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_CONTACT', avalue => v_contact_old ) ;
         
          v_temp := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/asset_code_combination_id' ) ;
           SELECT
                    segment1
                    ||'.'
                    ||segment2
                    ||'.'
                    ||segment3
                    ||'.'
                    ||segment4
                    ||'.'
                    ||segment5
                    ||'.'
                    ||segment6
                    ||'.'
                    ||segment7
                  INTO
                    v_bank_Asset_Acct
                  FROM
                    gl_code_combinations
                 WHERE
                    code_combination_id = v_temp;
          
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_ASSET_ACCT', avalue => v_bank_Asset_acct ) ;
          v_temp2    := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_asset_code_combination_id' ) ;
          IF v_temp2 IS NOT NULL THEN
                SELECT
                         segment1
                         ||'.'
                         ||segment2
                         ||'.'
                         ||segment3
                         ||'.'
                         ||segment4
                         ||'.'
                         ||segment5
                         ||'.'
                         ||segment6
                         ||'.'
                         ||segment7
                       INTO
                         v_bank_Asset_Acct_old
                       FROM
                         gl_code_combinations
                      WHERE
                         code_combination_id = v_temp2;
          ELSE
               v_bank_Asset_Acct_old := NULL;
          END IF;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_ASSET_ACCT', avalue => v_bank_Asset_Acct_old ) ;
          v_currency := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/currency_code' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_CURRENCY', avalue => v_currency ) ;
          v_currency_old := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_currency_code' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_CURRENCY', avalue => v_currency_old ) ;
          v_description := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/description' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_DESCRIPTION', avalue => v_description ) ;
          v_description_old := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_description' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BA_OLD_DESCRIPTION', avalue => v_description_old ) ;
          v_ui := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/record_type' ) ;
          --wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'UPDATE_INSERT', avalue => v_ui ) ;
          v_temp3 := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/changed_by_user_id' ) ;
           SELECT user_name INTO v_updated_by FROM fnd_user WHERE user_id = v_temp3;
          
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'UPDATED_BY', avalue => v_updated_by ) ;
          v_temp4 := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/bank_branch_id' ) ;
           SELECT
                    bank_name       ,
                    bank_branch_name,
                    nvl2 ( address_line1, address_line1
                    ||',', address_line1 )
                    ||nvl2 ( address_line2, address_line2
                    ||',', address_line2 )
                    ||nvl2 ( address_line3, address_line3
                    ||',', address_line3 )
                    ||nvl2 ( address_line4, address_line4
                    ||',', address_line4 )
                    ||nvl2 ( city, city
                    ||',', city )
                    ||nvl2 ( state, state
                    ||',', STATE )
                    ||nvl2 ( zip, zip
                    ||',', zip )
                    ||NVL2 ( COUNTRY, COUNTRY, COUNTRY ) ADDRESS,
                    branch_number                                    ,
                    bank_number
                  INTO
                    v_bank   ,
                    v_branch ,
                    v_address,
                    v_swift  ,
                    v_aba
                  FROM
                    ce_bank_branches_v b
                 WHERE
                    branch_party_id = v_temp4;
          
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BANK_NAME', avalue => v_bank ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BRANCH_NAME', avalue => v_branch ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BANK_ADDRESS', avalue => v_address ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'SWIFT_CODE', avalue => v_swift ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'ABA_NUMBER', avalue => v_aba ) ;
          v_date := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/record_date' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'UPDATE_DATE', avalue => v_date ) ;
          v_inactive := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/inactive_date' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'INACTIVE_DATE', avalue => v_inactive ) ;
          v_old_inactive := irc_xml_util.valueof ( bank_event_document, '/ap_bank_accounts/old_inactive_date' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_INACTIVE_DATE', avalue => v_old_inactive ) ;
          
          
           -- set VP Treasury 
        select pap.last_name, fu.user_name
        into l_vp_treasury_name,
              l_vp_treasury_id
        from per_all_people_f pap, 
             per_all_assignments_f asn, 
             per_jobs jobs,
             fnd_user fu
        where pap.person_id = asn.person_id
        and jobs.job_id = asn.job_id
        and fu.employee_id = pap.persoN_id
        and jobs.name = 'VPTREAS';

        WF_ENGINE.SETITEMATtrText(itemtype,
                        ITEMKEY,
                        'XX_VP_TREASURY_NAME',
                        l_vp_treasury_name);
        
        wf_engine.SETITEMATtrText(itemtype,
                        itemkey,
                        'TREASURY_VP',
                        l_vp_treasury_id);
      
      
      -- here we set the initial treasury member, random

x_treasury_member :=   WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'TREASURY_MEMBER');
                                  
if x_treasury_member is null then                                
  
  select user_name 
  into l_treasury_member
  from (
select distinct fu.user_name
from per_all_people_f pap, 
per_all_assignments_f asn
, per_jobs jobs,
per_all_assignments_f asn2,
per_all_people_f pap2,
fnd_user fu
where pap.person_id = asn.person_id
and jobs.job_id = asn.job_id
and jobs.name = 'VPTREAS'
and asn2.supervisor_id = asn.person_id
and pap2.person_id = asn2.person_id
and fu.employee_id = pap2.person_id
and fu.user_id <> v_temp3
and pap2.current_employee_flag = 'Y'
and sysdate between pap2.effective_start_date and pap2.effective_end_date
order by
                                   dbms_random.value
                                   )
                                   where rownum = 1;

               

wf_engine.SETITEMATtrText(itemtype,
                        itemkey,
                        'TREASURY_MEMBER',
                        l_treasury_member);
        
end if;
      
          
     END IF;
end xx_bank_account_changes;


 PROCEDURE GET_BANK_ADDRESS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
)
IS
L_DOCUMENT			VARCHAR2(32000) := '';
L_BANK_ID  number;
BEGIN

IF (display_type = 'text/html') THEN

SELECT BANK_ID
INTO L_BANK_ID
from ce_bank_accounts where bank_account_id = p_bank_account_id;

SELECT xx_ce_bank_contacts(l_bank_id,NULL,NULL,'A')
INTO L_DOCUMENT
from dual;

	END IF;

	document:= l_document;
EXCEPTION WHEN OTHERS THEN
WF_CORE.CONTEXT('xx_bank_account_wf_pkg', 'get_branch_contacts', P_BANK_ACCOUNT_ID);
RAISE;
  
END GET_BANK_ADDRESS;

 PROCEDURE GET_BRANCH_ADDRESS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
) IS
L_DOCUMENT			VARCHAR2(32000) := '';
L_BANK_ID NUMBER;
L_BRANCH_ID NUMBER;

BEGIN

IF (DISPLAY_TYPE = 'text/html') THEN
SELECT BANK_ID, BANK_BRANCH_ID
INTO L_BANK_ID, L_BRANCH_ID
FROM CE_BANK_ACCOUNTS WHERE BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID;

SELECT xx_ce_bank_contacts(l_bank_id,l_branch_id,NULL,'A')
INTO L_DOCUMENT
FROM DUAL;

	END IF;

	document:= l_document;
  
EXCEPTION WHEN OTHERS THEN
WF_CORE.CONTEXT('xx_bank_account_wf_pkg', 'get_branch_contacts', P_BANK_ACCOUNT_ID);
RAISE;

  
END GET_BRANCH_ADDRESS;

  PROCEDURE GET_BRANCH_CONTACTS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
) IS
L_DOCUMENT			VARCHAR2(32000) := '';
L_BANK_ID NUMBER;
L_BRANCH_ID NUMBER;
BEGIN

IF (display_type = 'text/html') THEN
SELECT BANK_ID, BANK_BRANCH_ID
INTO L_BANK_ID, L_BRANCH_ID
FROM CE_BANK_ACCOUNTS WHERE BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID;

SELECT XX_CE_BANK_CONTACTS(L_BANK_ID,L_BRANCH_ID,NULL,'C')
INTO L_DOCUMENT
FROM DUAL;
	END IF;

	document:= l_document;

EXCEPTION WHEN OTHERS THEN
WF_CORE.CONTEXT('xx_bank_account_wf_pkg', 'get_branch_contacts', P_BANK_ACCOUNT_ID);
raise;
  
  
END GET_BRANCH_CONTACTS;

  PROCEDURE GET_ACCOUNT_CONTACTS( p_bank_account_id		IN NUMBER ,
				   DISPLAY_TYPE		IN VARCHAR2 DEFAULT 'text/html',
				   document			IN OUT	NOCOPY VARCHAR2,
           DOCUMENT_TYPE	IN OUT	NOCOPY VARCHAR2
) IS
L_DOCUMENT			VARCHAR2(32000) := '';
L_BANK_ID       ce_bank_accounts.bank_account_id%TYPE;
BEGIN

IF (display_type = 'text/html') THEN

SELECT BANK_ID
INTO L_BANK_ID
FROM CE_BANK_ACCOUNTS 
where bank_account_id = p_bank_account_id;

DBMS_OUTPUT.PUT_LINE('here');

SELECT xx_ce_bank_contacts(l_bank_id,NULL,p_bank_account_id,'C')
INTO L_DOCUMENT
FROM DUAL;

	END IF;

	DOCUMENT:= L_DOCUMENT;

EXCEPTION WHEN OTHERS THEN
WF_CORE.CONTEXT('xx_bank_account_wf_pkg', 'get_branch_contacts', P_BANK_ACCOUNT_ID);
RAISE;
  
END GET_ACCOUNT_CONTACTS;
---------------------------------------------------------------------------------
  
end xx_bank_account_wf_pkg;
/
