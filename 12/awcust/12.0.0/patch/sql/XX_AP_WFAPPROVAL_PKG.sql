SET DEFINE OFF;

CREATE OR REPLACE PACKAGE XX_AP_WFAPPROVAL_PKG  AS


PROCEDURE set_imscan_url(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);
                        
PROCEDURE notification_handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
                        
PROCEDURE insert_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 );

PROCEDURE insert_history(p_invoice_id  IN NUMBER,
                        p_iteration IN NUMBER,
			p_org_id IN NUMBER,
			p_status IN VARCHAR2);


END XX_AP_WFAPPROVAL_PKG;
 
/


CREATE OR REPLACE PACKAGE BODY xx_AP_WFAPPROVAL_PKG AS

PROCEDURE set_imscan_url(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS


l_url  VARCHAR2(240);
l_invoice_id NUMBER(15);
l_doc NUMBER(15);
v_created_by varchar2(240);

BEGIN
                                  
                               
                
          l_invoice_id :=     WF_ENGINE.GetItemAttrText(itemtype,
                                  ITEMKEY,
                                  'INVOICE_ID');
                
      
      dbms_output.put_line('l_invoice_id-'||l_invoice_id);
      
                 
       /* Not required in R12
          SELECT nvl(aia.doc_sequence_value,aia.voucher_num)
                 into l_doc
                 FROM ap_invoices_all aia
                 where aia.invoice_id = l_invoice_id;
                 
                  WF_ENGINE.SETITEMATTRText(itemtype,
                                  itemkey,
                                  'XX_VOUCHER_NUM',
                                  l_doc);  
                 
                 
                 if l_doc is not null then
                          
                           
                           SELECT  decode(aia.source,'IMSCAN',aia.attribute1,'https://imscan.awas.com/AwasDocView/View/Doc?token=19-'||d_id )
                           into l_url
                           from ap_invoices_all aia,
                           xx_imscan_link@basin xx
                           WHERE nvl(aia.doc_sequence_value,aia.voucher_num) = xx.Oracle_Voucher (+)
                           and aia.invoice_id = l_invoice_id;

                 
                                  
                                  
      WF_ENGINE.SETITEMATTRText(itemtype,
                                  itemkey,
                                  'IMSCAN_URL',
                                  l_url);                                  
                                  
                  END IF;
                  
          */
                  
            SELECT user_name
            INTO v_created_by
            FROM ap_invoices_all a,
            fnd_user f
            where a.invoice_id = l_invoice_id
            AND A.CREATED_BY = F.USER_ID;
            
                dbms_output.put_line('v_created_by-'||v_created_by);
            
            
            wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'XX_CREATED_BY', avalue => v_created_by ) ;
                  
                  
                  
           resultout := wf_engine.eng_completed||':'||'Y';




END;


PROCEDURE notification_handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS
                        
l_comments2      VARCHAR2(240);
L_ACTIVITY_RESULT_CODE VARCHAR2(150);


BEGIN
    
    IF (funcmode IN ('RESPOND','RUN'))
    THEN
      
      
     Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid   
     AND na.NAME = 'RESULT';
   
   
     SELECT text_value
     INTO l_comments2
     From wf_notification_attributes na
     WHERE NA.NOTIFICATION_ID = WF_ENGINE.CONTEXT_NID   
     AND na.NAME = 'WF_NOTE';
   
     
      IF l_activity_result_code = 'REJECTED' AND  l_comments2 IS NULL
      THEN
        RESULTout := 'ERROR: You must enter rejection reason if rejecting.';
        RETURN;
      END IF;
      
    END IF;
    

      if ( funcmode = 'FORWARD' ) then


           resultout := 'COMPLETE';

           return;

      end if;

      if ( funcmode = 'TRANSFER' ) then


           resultout := 'ERROR:WFSRV_NO_DELEGATE';

           return;

      end if;

return;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('AP_WF',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END;


PROCEDURE insert_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 ) IS

l_next_approver AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name         wf_users.name%TYPE;-- for bug 7191171 VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_approver      VARCHAR2(150);
l_approver_id   NUMBER(15);
l_invoice_id    NUMBER(15);
l_result        VARCHAR2(50);
l_org_id       NUMBER(15);
l_comments      VARCHAR2(240);
l_iteration	NUMBER(9);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;

BEGIN
--Get attribute values to create record in the history table

        l_approver := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_ANA');

        l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_ANAI');

        l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AII');

        l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AI');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AOI');

	l_amount := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AIA');


        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);

	SELECT AP_INV_APRVL_HIST_S.nextval
	INTO l_hist_id
	FROM dual;

        --insert into the history table
        INSERT INTO  AP_INV_APRVL_HIST
	(APPROVAL_HISTORY_ID
        ,INVOICE_ID
        ,ITERATION
        ,RESPONSE
        ,APPROVER_ID
        ,APPROVER_NAME
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,ORG_ID
	,AMOUNT_APPROVED)
        VALUES (
	l_hist_id,
	l_invoice_id,
	l_iteration,
	'PENDING',
	l_approver_id,
	l_approver,
	nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
	sysdate,
	sysdate,
	nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
	nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1),
	l_org_id,
	l_amount);

	WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AHI',
				   l_hist_id);

	EXCEPTION
  		WHEN OTHERS THEN
    		Wf_Core.Context('APINV', 'insert_history',
                     itemtype, itemkey, l_debug_info);
    		raise;

END insert_history;

PROCEDURE insert_history(p_invoice_id  IN NUMBER,
                        p_iteration IN NUMBER,
                        p_org_id IN NUMBER,
                        p_status IN VARCHAR2) IS
	l_hist_id	NUMBER;
	l_amount        ap_invoices_all.invoice_amount%TYPE;
BEGIN
		--insert into the history table
		SELECT AP_INV_APRVL_HIST_S.nextval
        	INTO l_hist_id
        	FROM dual;

		SELECT invoice_amount
		INTO l_amount
		FROM AP_INVOICES_ALL
		WHERE invoice_id = p_invoice_id;

        	INSERT INTO  AP_INV_APRVL_HIST
        	(APPROVAL_HISTORY_ID
        	,INVOICE_ID
        	,ITERATION
        	,RESPONSE
        	,APPROVER_ID
        	,APPROVER_NAME
		,AMOUNT_APPROVED
        	,CREATED_BY
        	,CREATION_DATE
        	,LAST_UPDATE_DATE
        	,LAST_UPDATED_BY
        	,LAST_UPDATE_LOGIN
        	,ORG_ID)
        	VALUES (
        	l_hist_id,
        	p_invoice_id,
        	p_iteration,
		p_status,
        	 NULL,
        	FND_PROFILE.VALUE('USERNAME'),
		l_amount,
		TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
        	sysdate,
        	sysdate,
        	TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
        	TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
        	p_org_id);

commit;

END insert_history;


END xx_AP_WFAPPROVAL_PKG;
/
