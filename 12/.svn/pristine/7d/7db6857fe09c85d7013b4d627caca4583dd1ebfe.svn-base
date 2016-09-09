CREATE OR REPLACE PACKAGE XX_PO_REQAPPROVAL_ACTION AS

doc_mgr_err_num number; --global variable used to set doc mgr error.

sysadmin_err_msg varchar2(2000); --global variable used to set sysadmin mesg.

-- Verify_authority
--   Verify the approval authority against the PO setup control rules.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - The approver has the authority to approve.
--     N - The approver does not have the authority to approve.
--
procedure Verify_authority(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

end XX_PO_REQAPPROVAL_ACTION;
 
/


CREATE OR REPLACE PACKAGE body XX_PO_REQAPPROVAL_ACTION as
-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

FUNCTION VerifyAuthority(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
-- Verify_authority
--   Verify the approval authority against the PO setup control rules.
--
procedure Verify_authority(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress  varchar2(100);
x_resultout varchar2(30);

l_doc_mgr_return_val varchar2(1);
l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE;
doc_manager_exception exception;
l_document_id NUMBER; 
l_approver_id NUMBER;
l_req_approver NUMBER;
l_project_name varchar2(60);


BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Verify_authority: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
  l_doc_mgr_return_val := VerifyAuthority(itemtype, itemkey);

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  /* If the return value is 'F', then the transition in the Wokflow will
  ** be "Default"
  */
  If l_doc_mgr_return_val = 'F' then
     raise doc_manager_exception;
  End if;
  
  -- AWAS Customisations  if approver is OK check did they approve req
  If l_doc_mgr_return_val = 'Y' then
  
  -- get project name
   l_project_name := wf_engine.getitemattrtext (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'XX_PROJECT_NAME');
  
  -- if TAM PO , ie has a project name then check approvers
  if l_project_name is not null then
  
  -- get current po approver
  l_approver_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');
 
  -- get req approver
  SELECT MAX(rha.preparer_id)
  into l_req_approver
  FROM po_headers_all poh,
  po_distributions_all pda,
  po_req_distributions_all rda,
  po_requisition_lines_all rla,
  po_requisition_headers_all rha
  WHERE pda.po_header_id = poh.po_header_id
  AND rha.requisition_header_id (+) = rla.requisition_header_id
  AND rla.requisition_line_id (+) = rda.requisition_line_id
  AND rda.distribution_id (+) = pda.req_distribution_id
  AND poh.po_header_id = l_document_id;
  
        IF l_approver_id = l_req_approver THEN
        
        l_doc_mgr_return_val := 'N';
        
        END IF;
  
  END IF;
  
  END if;  
  
  resultout := wf_engine.eng_completed || ':' ||  l_doc_mgr_return_val;
  x_resultout := l_doc_mgr_return_val;


  x_progress := 'PO_REQAPPROVAL_ACTION.Verify_authority: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Verify_authority', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.VERIFY_AUTHORITY',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    RAISE;


END Verify_authority;

--
FUNCTION VerifyAuthority(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

L_DM_CALL_REC  PO_DOC_MANAGER_PUB.DM_CALL_REC_TYPE;

x_progress varchar2(200);
BEGIN


  L_DM_CALL_REC.Action := 'VERIFY_AUTHORITY_CHECK';

  L_DM_CALL_REC.Document_Type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  L_DM_CALL_REC.Document_Subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  L_DM_CALL_REC.Document_Id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  x_progress := 'VerifyAuthority: calling Doc. Mgr  with: ' || 'Doc_type= ' ||
  L_DM_CALL_REC.Document_Type || ' Subtype= ' || L_DM_CALL_REC.Document_Subtype ||
  ' Doc_id= ' || to_char(L_DM_CALL_REC.Document_Id);

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

  L_DM_CALL_REC.Line_Id          := NULL;
  L_DM_CALL_REC.Shipment_Id      := NULL;
  L_DM_CALL_REC.Distribution_Id  := NULL;
  L_DM_CALL_REC.Employee_id      := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');

  L_DM_CALL_REC.New_Document_Status  := NULL;
  L_DM_CALL_REC.Offline_Code     := NULL;

  L_DM_CALL_REC.Note             := NULL;

  L_DM_CALL_REC.Approval_Path_Id := NULL;

  L_DM_CALL_REC.Forward_To_Id    := NULL;

  L_DM_CALL_REC.Action_date    := NULL;

  L_DM_CALL_REC.Override_funds    := NULL;

-- Below are the output parameters

  L_DM_CALL_REC.Info_Request     := NULL;

  L_DM_CALL_REC.Document_Status  := NULL;

  L_DM_CALL_REC.Online_Report_Id := NULL;

  L_DM_CALL_REC.Return_Code      := NULL;

  L_DM_CALL_REC.Error_Msg        := NULL;

  /* This is the variable that contains the return value from the
  ** call to the DOC MANAGER:
  ** SUCCESS =0,  TIMEOUT=1,  NO MANAGER=2,  OTHER=3
  */
  L_DM_CALL_REC.Return_Value    := NULL;

  /* Call the API that calls the Document manager */

  PO_DOC_MANAGER_PUB.CALL_DOC_MANAGER(L_DM_CALL_REC);


  /* If the Document manager executed with no errors then, check return_code
  ** from the State_check routine.
  ** Else issue a notification to the system admin that something is wrong with the
  ** document manager.
  */
  IF L_DM_CALL_REC.Return_Value = 0 THEN

     /*  L_DM_CALL_REC.Return_Code has the output from the VERIFY_AUTHORITY_CHECK.
     **  If passed,   then it should be null, otherwise
     **  it should be 'AUTHORIZATION_FAILED'.
     */
     IF ( L_DM_CALL_REC.Return_Code is NULL )  THEN

        return('Y');

     ELSE

        return('N');

     END IF;

  ELSE  /* something went wrong with Doc Manager. Send notification to Sys Admin.
         ** The error message is kept in Item Attribute SYSADMIN_ERROR_MSG */

        x_progress := 'PO_REQAPPROVAL_ACTION.VerifyAuthority: Doc. Mgr returned with: ' ||
               to_char( L_DM_CALL_REC.Return_Value );
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
         END IF;

     /* Bug 1942091. Set the SYSADMIN_ERROR_MSG and DOC_MGR_ERROR_NUM to the
      * global variable. This will be set in the initaize_error of the
      * Error workflow since these will be rolled back when we raise the
      * user exception doc_manager_exception.
     */
     doc_mgr_err_num := L_DM_CALL_REC.Return_Value;
     sysadmin_err_msg :=  L_DM_CALL_REC.Error_Msg;

     return('F');

  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','VerifyAuthority',x_progress);
        raise;

END VerifyAuthority;

end XX_PO_REQAPPROVAL_ACTION;
/
