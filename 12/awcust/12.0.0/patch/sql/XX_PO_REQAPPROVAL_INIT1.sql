CREATE OR REPLACE PACKAGE XX_PO_REQAPPROVAL_INIT1 AUTHID CURRENT_USER AS
/* $Header: POXWPA1S.pls 115.28.11510.8 2009/05/04 11:06:56 rohbansa ship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWPA1S.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_REQAPPROVAL_INIT1
 |
 | NOTES
 | MODIFIED    	Ben Chihaoui (06/10/97)
 | MODIFIED    	davidng (05/24/02)
 |       	Changed parameter PrintFlag to default to 'N' instead of NULL
 *=====================================================================*/


-- Start_WF_Process
--  Generates the itemkey, sets up the Item Attributes,
--  then starts the workflow process.
--
/* RETROACTIVE FPI Change.
 * Added 2 new parameters MassUpdateReleases and RetroactivePriceChange.
 * MassUpdateReleases is Y when approval is initiated from the Form and
 * the user wants to update all the releases against the blanket with
 * the retroactive price change. RetroactivePriceChange is Y when the
 * releases are updated with the retroactive price change.
*/
PROCEDURE Start_WF_Process ( ItemType          VARCHAR2,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ActionOriginatedFrom   VARCHAR2,
                             DocumentID             NUMBER,
                             DocumentNumber         VARCHAR2,
                             PreparerID             NUMBER,
                             DocumentTypeCode       VARCHAR2,
                             DocumentSubtype        VARCHAR2,
                             SubmitterAction        VARCHAR2,
                             forwardToID            NUMBER,
                             forwardFromID          NUMBER,
                             DefaultApprovalPathID  NUMBER,
                             Note                   VARCHAR2,
                             PrintFlag              VARCHAR2 default 'N',
			     FaxFlag		    VARCHAR2 default 'N',
			     FAXNumber		    VARCHAR2 default NULL,
			     EmailFlag              VARCHAR2 default 'N',
                             EmailAddress           VARCHAR2 default NULL,
                             CreateSourcingRule     VARCHAR2 default NULL,
                             ReleaseGenMethod       VARCHAR2 default NULL,
                             UpdateSourcingRule     VARCHAR2 default NULL,
                             MassUpdateReleases     VARCHAR2 default 'N', -- Retroactive FPI
                             RetroactivePriceChange VARCHAR2 default 'N', -- Retroactive FPI
                             OrgAssignChange        VARCHAR2 default 'N', -- GA FPI
                             CommunicatePriceChange VARCHAR2 default 'N', -- <FPJ Retroactive>
                             p_Background_Flag      VARCHAR2 default 'N'); -- <DropShip FPJ>

procedure getReqAttributes(p_requisition_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2);

-- set_multiorg_context
--   Get the org_id and set the context for Mult-org
--
PROCEDURE get_multiorg_context(document_type varchar2, document_id number,
                               x_orgid IN OUT NOCOPY number);


-- Record variable ReqHdr_rec
--   Public record variable used to hold the Requisition_header columns
-- Bug#3147435
-- Added contractor_requisition_flag and contractor_status to ReqHdrRecord
   TYPE ReqHdrRecord IS RECORD(
                               REQUISITION_HEADER_ID NUMBER,
                               DESCRIPTION           VARCHAR2(240),
                               AUTHORIZATION_STATUS  VARCHAR2(25),
                               TYPE_LOOKUP_CODE      VARCHAR2(25),
                               PREPARER_ID           NUMBER,
                               SEGMENT1              VARCHAR2(20),
                               CLOSED_CODE           VARCHAR2(25),
                               EMERGENCY_PO_NUM      VARCHAR2(25),
                               CONTRACTOR_REQUISITION_FLAG VARCHAR2(1),
                               CONTRACTOR_STATUS     VARCHAR2(25),
                               NOTE_TO_AUTHORIZER    VARCHAR2(4000));

   ReqHdr_rec ReqHdrRecord;

-- Record variable ReqLine_rec
--   Public record variable used to hold the Requisition_line columns.

   TYPE ReqLineRecord IS RECORD(
                               LINE_NUM               NUMBER,
                               ITEM_DESCRIPTION       VARCHAR2(240),
                               UNIT_MEAS_LOOKUP_CODE  VARCHAR2(25),
                               UNIT_PRICE             NUMBER,
                               QUANTITY               NUMBER,
                               NEED_BY_DATE           DATE,
                               TO_PERSON_ID           NUMBER,
                               DELIVER_TO_LOCATION_ID NUMBER,

   /** PO UTF8 Column Expansion Project 9/23/2002 tpoon **/
   /** Expanded deliver_to_location from 20 to 60 **/
--                               DELIVER_TO_LOCATION    VARCHAR2(20),
                               DELIVER_TO_LOCATION    VARCHAR2(60),

                               REQUESTOR_FULL_NAME    VARCHAR2(240));

   ReqLine_rec ReqLineRecord;

-- Cursor GetRecHdr_csr
--   Public cursor used to get the Requisition_header columns.

   CURSOR GetRecHdr_csr(p_requisition_header_id NUMBER) RETURN ReqHdrRecord;

--
PROCEDURE get_user_name( p_employee_id IN number, x_username OUT NOCOPY varchar2,
                         x_user_display_name OUT NOCOPY varchar2);

--
PROCEDURE get_employee_id( p_username IN varchar2, x_employee_id OUT NOCOPY number);

--

-- SetStartupValues
--
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_Startup_Values(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
--
-- Get_ReqAttributes
--   Get the requisition attributes. We get the header info and up to 5
--   requisition lines.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Get_Req_Attributes(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);
--
-- Set_req_stat_preapproved
-- Added for WR4
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_doc_stat_preapproved(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_req_stat_inprocess
-- Set the requisition status to IN-PROCESS. That way, the users can not bring
-- the Requisition up in the entry form and make modifications while it's in
-- in the workflow process.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_doc_stat_inprocess(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

-- set_doc_to_originalstat
--  Sets the doc back to it's original status if No Approver was found
--  or doc failed STATE VERIFICATION or COMPLETENESS check before APPROVE,
--  REJECT or FORWARD.

--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure set_doc_to_originalstat(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

-- Register_doc_submitted
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Register_doc_submitted(     itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Can_Owner_Approve
--   Can the owner of a requisition approve it
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y - Owner can approve requisition
--     N - Owner can NOT approve requisition
--
procedure Can_Owner_Approve(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--
-- Is_doc_preapproved
--   Is the document status pre-approved
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     Y -
--     N -
--
procedure Is_doc_preapproved(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

--
-- Ins_actionhist_submit
--   When submitting the document into the workflow, we need to insert
--   action SUBMIT into PO_ACTION_HISTORY
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The notification process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   Resultout
--     ACTIVITY_PERFORMED
--
procedure Ins_actionhist_submit(   itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );
--

--
-- Set_End_VerifyDoc_Failed
--  Sets the value of the transition to FAILED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_End_VerifyDoc_Failed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_End_VerifyDoc_Passed
--  Sets the value of the transition to PASSED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    -
--
procedure Set_End_VerifyDoc_Passed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_End_Valid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Valid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
-- Set_End_Invalid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Invalid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );

--
--
-- Encumb_on_doc_unreserved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If Encumbrance is ON and Document is NOT reserved, then return Y.

procedure Encumb_on_doc_unreserved(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    );


--
--
-- RESERVE_AT_COMPLETION_CHECK
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If the reserve at completion flag is checked, then return Y.

procedure RESERVE_AT_COMPLETION_CHECK(   itemtype        in varchar2,
                                         itemkey         in varchar2,
                                         actid           in number,
                                         funcmode        in varchar2,
                                         resultout       out NOCOPY varchar2    );
--

--
--
-- Is_Interface_ReqImport
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If requisition being generated from the requisiton import program

procedure Is_Interface_ReqImport(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) ;

--
-- Remove_reminder_notif
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Remove the reminder notifications since this doc is now approved.

procedure Remove_reminder_notif(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) ;

-- Print_Doc_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to print the document?

procedure Print_Doc_Yes_No(   itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Fax_Doc_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to fax the document?

procedure Fax_Doc_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;



-- Send_WS_Notif_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to send the notification ?

procedure Send_WS_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Send_WS_Fyi_Notif_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to send the FYI notification ?

procedure Send_WS_Fyi_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Send_WS_Ack_Notif_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to send the acknowledgement notification ?

procedure Send_WS_Ack_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- locate_notifier
-- IN
-- document_number, document_type
-- OUT
-- fnd_user (resultout)
-- What is the web supplier defined for this particular user (if any)?

procedure locate_notifier		(document_id	in	varchar2,
					document_type  	in 	varchar2,
				 resultout	in out NOCOPY  varchar2);


/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >

  PROCEDURE NAME: get_user_list_with_resp

  DESCRIPTION   :
  For the given document_id ( ie. po_header_id ), this procedure
  tries to find out the correct users that need to be sent the
  notifications.

  Referenced by : Workflow procedures
  parameters    :
   Input:
    document_id - the document id
    document_type - Document type
    p_notify_only_flag -
        The values can be 'Y' or 'N'
        'Y' means: The procedure will return all the users that are supplier users related to the document.
        Returns the role containing all the users in the "x_resultout" variable

        'N' means: we want users that need to be sent FYI and also the users with resp.
            x_resultout: will have the role for the users that need to be sent the FYI
            x_role_with_resp: will have the role for users having the fucntion "POS_ACK_ORDER" assigned to
            them.

   Output:
    x_resultout - Role for the users that need to be sent FYI
    x_role_with_resp - Role for the users who have the ability to acknowledge.

  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/

procedure locate_notifier       (p_document_id    in      varchar2,
                                 p_document_type   in     varchar2,
                                 p_notify_only_flag   in     varchar2,
                                 x_resultout      in out NOCOPY  varchar2,
                                 x_role_with_resp in out NOCOPY VARCHAR2) ;
-- Email_Doc_Yes_No
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Does user want to email the document?

procedure Email_Doc_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    ) ;


-- Print_Document
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Print Document.

procedure Print_Document(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;



-- Fax_Document
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Fax Document.

procedure Fax_Document(     itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;



-- Is_document_Approved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Is the document already approved. This may be the case if the document
--   was PRE-APPROVED before it goes through the reserve action. The RESERVE
--   would then approve the doc after it reserved the funds.

procedure Is_document_Approved(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Get_Workflow_Approval_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      On-line
--      Background

procedure Get_Workflow_Approval_Mode(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Get_Create_PO_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed

procedure Get_Create_PO_Mode(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Dummy
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed
-- Dummy procedure that does nothing (NOOP). Used to set the
-- cost above the backgound engine threshold. This causes the
-- workflow to execute in the background.
procedure Dummy(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- Is product source code POR ?
-- Determines if the requisition is created
-- through web requisition
procedure is_apps_source_POR(itemtype in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       out NOCOPY varchar2);

-- Bug#3147435
-- Is contractor status PENDING?
-- Determines if the requisition has contractor_status PENDING at header level
procedure is_contractor_status_pending(itemtype in varchar2,
                                       itemkey         in varchar2,
                                       actid           in number,
                                       funcmode        in varchar2,
                                       resultout       out NOCOPY varchar2);

-- Is_Submitter_Last_Approver
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
-- Bug 823167 kbenjami
--
-- Is the Submitter the last Approver?
-- Checks to see if submitter is also the current
-- approver of the doc.
-- Prevents two notifications from being sent to the
-- same person.
--
procedure Is_Submitter_Last_Approver(itemtype 	in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) ;

-- This function finds out the document type, subtype and number and
-- concatenates them together for PLSQL_ERROR_DOC.  This is need because
-- the document info attribute may be rolled back when error occurs.

function get_error_doc(itemtype in varchar2,
                       itemkey  in varchar2) return varchar2;

-- This function finds out preparer user name.  This is need because
-- the document info attribute may be rolled back when error occurs.

function get_preparer_user_name(itemtype in varchar2,
                                itemkey  in varchar2) return varchar2;

-- This procedure send the 'PLSQL_ERROR_OCCURS' notification to the
-- preparer when PL/SQL error occurs during approval workflow

procedure send_error_notif(itemtype    in varchar2,
                           itemkey     in varchar2,
                           username    in varchar2,
                           doc         in varchar2,
                           msg         in varchar2,
                           loc         in varchar2,
			   document_id in number default NULL);  /* Bug 6874681 Added document_id with default value as NULL*/

/* Bug# 1739194: kagarwal
** Desc: Added new procedure to check the document manager error.
*/
procedure Is_Document_Manager_Error_1_2(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

/* bug 1759631 - procedure to check if there is any second email address
   in the profile */

procedure PROFILE_VALUE_CHECK(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2 ) ;

procedure Check_Error_Count(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);
procedure Initialise_Error(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
			   resultout       out NOCOPY varchar2);

procedure  acceptance_required   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );
--

procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    );

procedure Create_SR_ASL_Yes_No( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    );

/* Bug#2353153: kagarwal
** Added new PROCEDURE set_doc_mgr_context as a global procedure as this
** is being used by wf apis present in different packages.
*/

PROCEDURE Set_doc_mgr_context (itemtype VARCHAR2,
                               itemkey VARCHAR2);

/* FPI RETROACTIVE PRICING CHANGE START */
/*******************************************************************
  PROCEDURE NAME: MassUpdate_Releases_Yes_No

  DESCRIPTION   : This is the API which determines whether the approval;
		  process should also update the releases against the
		  blanket that is getting approved has to be updated
		  with the new price change. Get the value of
		  the parameter massupdatereleases from start_Wf_process.
		  If this value is Y and if it is a blanket agreeement
		  then we need to mass update the releases with the new
		  price.
  Referenced by :
  parameters    : Usual workflow attributes.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

procedure MassUpdate_Releases_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    );

/*******************************************************************
  PROCEDURE NAME: MassUpdate_Releases_Workflow

  DESCRIPTION   : This is the API that is called from PO Approval
		  Workflow if the massupdate checkbox in the
		  Approval  Window is set to Yes.
  Referenced by :
  parameters    : Usual workflow attributes.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
procedure MassUpdate_Releases_Workflow( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
				     resultout       out NOCOPY varchar2 ) ;


/*******************************************************************
  PROCEDURE NAME: Send_Supplier_Comm_Yes_No

  DESCRIPTION   : This is the API which determines whether supplier
		  Communication has to be sent when the document is
		  is approved. There is a new Change Order Workflow
		  attribute which can be set to Y if we need to
		  send supplier when the release is updated with
		  the new price after the Mass update release program is
		  run. If it is yes, then this procedure will return
		  Yes.
  Referenced by :
  parameters    : Usual workflow attributes.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
procedure Send_Supplier_Comm_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    );

/* RETROACTIVE FPI END */


-- <FPJ Retroactive START>
/**
* Public Procedure: Retro_Invoice_Release_WF
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: PO_DISTRIBUTIONS_ALL.invoice_adjustment_flag
* Effects:  This procedure updates invoice adjustment flag, and calls Costing
*           and Inventory APIs.
*/
procedure Retro_Invoice_Release_WF( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2    );


-- <FPJ Retroactive END>

procedure update_print_count(p_doc_id in NUMBER,
			     p_doc_type IN VARCHAR2);

-- <BUG5383646 START>
/**
** Public Procedure: Update_Action_History_TimeOut
** Requires:
**   IN PARAMETERS:
**     Usual workflow attributes.
** Modifies: Action History
** Effects:  Actoin History is updated with No Action if the approval
**           notification is TimedOut.
*/

PROCEDURE Update_Action_History_TimeOut (itemtype     IN    VARCHAR2,
                                         itemkey      IN    VARCHAR2,
                                         actid        IN    NUMBER,
                                         funcmode     IN    VARCHAR2,
                                         resultout   OUT   NOCOPY VARCHAR2);

-- <BUG5383646 END>
--bug 5956252
procedure string_to_userTable(p_UserList  in VARCHAR2,
                               p_UserTable out NOCOPY WF_DIRECTORY.UserTable);


-- <Bug 6450446 Begin>
-- Created two new procedures to introduce supplier context in PO approval.

/**
 * Public Procedure: set_is_supplier_context_y
 * Requires:
 *   IN PARAMETERS:
 *     Usual workflow attributes.
 * Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y
 */
 procedure set_is_supplier_context_y(p_item_type        in varchar2,
                                     p_item_key         in varchar2,
                                     p_act_id           in number,
                                     p_func_mode        in varchar2,
                                     x_result_out       out NOCOPY varchar2);

/**
 * Public Procedure: set_is_supplier_context_n
 * Requires:
 *   IN PARAMETERS:
 *     Usual workflow attributes.
 * Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to N
 */
 procedure set_is_supplier_context_n(p_item_type        in varchar2,
                                     p_item_key         in varchar2,
                                     p_act_id           in number,
                                     p_func_mode        in varchar2,
                                     x_result_out       out NOCOPY varchar2);

-- <Bug 6450446 End>

 procedure Ins_actionhist_approve(itemtype        in varchar2,
                itemkey         in varchar2,
                   actid           in number,
                 funcmode        in varchar2,
                  resultout       out NOCOPY varchar2);

END  XX_PO_REQAPPROVAL_INIT1;
 
/


CREATE OR REPLACE PACKAGE BODY XX_PO_REQAPPROVAL_INIT1 AS
/* $Header: POXWPA1B.pls 115.206.11510.72 2009/05/04 11:06:20 rohbansa ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_document_subtype  PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;

--Bug#3497033
--g_currency_format_mask declared to pass in as the second parameter
--in FND_CURRENCY.GET_FORMAT_MASK
g_currency_format_mask NUMBER := 60;

 /*=======================================================================+
 | FILENAME
 |   POXWPA1B.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_REQAPPROVAL_INIT1
 |
 | NOTES        Ben Chihaoui Created 6/15/97
 | MODIFIED    (MM/DD/YY)
 | davidng      06/04/2002      Fix for bug 2401183. Used the Workflow Utility
 |                              Package wrapper function and procedure to get
 |                              and set attributes REL_NUM and REL_NUM_DASH
 |                              in procedure PO_REQAPPROVAL_INIT1.Initialise_Error
 *=======================================================================*/
--

TYPE g_refcur IS REF CURSOR;

-- Bug#3147435
-- Added contractor_requisition_flag and contractor_status to GetRecHdr_csr
Cursor GetRecHdr_csr(p_requisition_header_id NUMBER) RETURN ReqHdrRecord is
  select REQUISITION_HEADER_ID,DESCRIPTION,AUTHORIZATION_STATUS,
         TYPE_LOOKUP_CODE,PREPARER_ID,SEGMENT1,CLOSED_CODE,EMERGENCY_PO_NUM,
         NVL(CONTRACTOR_REQUISITION_FLAG, 'N'),
         NVL(CONTRACTOR_STATUS, 'NULL'), NOTE_TO_AUTHORIZER
  from po_requisition_headers_all
  where REQUISITION_HEADER_ID = p_requisition_header_id;

/*****************************************************************************
* The following are local/Private procedure that support the workflow APIs:  *
*****************************************************************************/


--
procedure SetReqHdrAttributes(itemtype in varchar2, itemkey in varchar2);

--
procedure SetReqAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status varchar2);
--
procedure SetPOAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status varchar2);
--
procedure SetRelAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status varchar2);
--
procedure UpdtReqItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id number);
--
procedure UpdtPOItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id number);
--
procedure UpdtRelItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id number);
--

procedure GetCanOwnerApprove(itemtype in varchar2,itemkey in varchar2,
                             CanOwnerApproveFlag OUT NOCOPY varchar2);

PROCEDURE InsertActionHistSubmit(itemtype varchar2, itemkey varchar2,
                                 p_doc_id number, p_doc_type varchar2,
                                 p_doc_subtype varchar2, p_employee_id number,
                                 p_action varchar2, p_note varchar2, p_path_id number);

 PROCEDURE InsertActionHistApprove(itemtype varchar2, itemkey varchar2,
 	                                     p_doc_id number, p_doc_type varchar2,
 	                                     p_doc_subtype varchar2, p_employee_id number,
 	                                     p_action varchar2,p_path_id number);

--
-- Bug 3845048 : Added update action history procedure as an autonomous transaction
PROCEDURE UpdateActionHistory(p_doc_id      IN number,
                              p_doc_type    IN varchar2,
                              p_doc_subtype IN varchar2,
                              p_action      IN varchar2
                              ) ;

-- <ENCUMBRANCE FPJ START>

FUNCTION EncumbOn_DocUnreserved(p_doc_type varchar2, p_doc_subtype varchar2,
                                p_doc_id number)
         RETURN varchar2;

-- <ENCUMBRANCE FPJ END>

PROCEDURE   PrintDocument(itemtype varchar2,itemkey varchar2);

-- DKC 10/10/99
PROCEDURE   FaxDocument(itemtype varchar2,itemkey varchar2);


FUNCTION Print_Requisition(p_doc_num varchar2, p_qty_precision varchar,
                           p_user_id varchar2) RETURN number ;

--Bug5194244 Added p_document_id ,document subtype,with terms ,document type parameters

FUNCTION Print_PO(p_doc_num varchar2, p_qty_precision varchar,
                  p_user_id varchar2,p_document_id number default NULL,
                  p_document_subtype varchar2 default NULL,p_withterms varchar2 default NULL) RETURN number ;


--DKC 10/10/99

--Bug5194244 Added p_document_id ,document subtype,with terms,document type parameters

FUNCTION Fax_PO(p_doc_num varchar2, p_qty_precision varchar,
                p_user_id varchar2, p_fax_enable varchar2,
		p_fax_num varchar2,p_document_id number default NULL,
		p_document_subtype varchar2 default NULL,p_withterms varchar2 default NULL) RETURN number ;

--Bug5194244 Added p_document_id ,document subtype,document type parameters

FUNCTION Print_Release(p_doc_num varchar2, p_qty_precision varchar,
             p_release_num varchar2, p_user_id varchar2,p_document_id number default NULL) RETURN number ;


-- DKC 10/10/99
--Bug5194244 Added p_document_id ,document subtype ,document type parameters

FUNCTION Fax_Release(p_doc_num varchar2, p_qty_precision varchar,
             	p_release_num varchar2, p_user_id varchar2,
		p_fax_enable varchar2, p_fax_num varchar2,p_document_id number default NULL) RETURN number ;


procedure CLOSE_OLD_NOTIF(itemtype in varchar2,
                          itemkey  in varchar2);

Procedure Update_Acc_Req_Flg(p_header_id in number,p_release_id in number);

Procedure Insert_Acc_Rejection_Row(itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in  number,
				   flag		   in  varchar2);

/************************************************************************************
* Added this procedure as part of Bug #: 2843760
* This procedure basically checks if archive_on_print option is selected, and if yes
* call procedure PO_ARCHIVE_PO_SV.ARCHIVE_PO to archive the PO
*************************************************************************************/
procedure archive_po(p_document_id in number,
					p_document_type in varchar2,
					p_document_subtype in varchar2);

/**************************************************************************************
* The following are the global APIs.						      *
**************************************************************************************/

/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >
  PROCEDURE NAME: get_diff_in_user_list

  DESCRIPTION   :
  Given a two lists of users, this procedure gives the difference of the two lists.
  The users must be present in the fnd_user table.

  Referenced by : locate_notifier
  parameters    :

    Input:
        p_super_set : A string having the list of user names
            Example string: 'GE1', 'GE2', 'GE22'
        p_subset : A list of string having the subset of user names present in the
        previous list.
    Output:
        x_name_list: A list users present in the super set but not in
            subset.
        x_users_count: The number of users in the above list.

  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/
PROCEDURE get_diff_in_user_list ( p_super_set in varchar2, p_subset in varchar2 ,
                                  x_name_list out nocopy varchar2,
                                  x_name_list_for_sql out nocopy varchar2,
                                  x_users_count out nocopy number )
IS
l_refcur g_refcur;
l_name_list varchar2(2000);
l_count number;
l_user_name FND_USER.USER_NAME%type;
l_progress varchar2(255);
BEGIN
   l_count := 0;
    open l_refcur for
    'select distinct fu.user_name
    from fnd_user fu
    where fu.user_name in ('|| p_super_set || ')
    and fu.user_name not in (' || p_subset || ')';



    -- Loop through the cursor and construct the
    -- user list.
    LOOP
      fetch l_refcur into l_user_name;
      if l_refcur%notfound then
         exit;
      end if;
      IF l_count = 0 THEN
        l_count := l_count+1;
	x_name_list_for_sql :=  '''' ||l_user_name ||'''';
	x_name_list :=  l_user_name;
       ELSE
        l_count := l_count+1;
	x_name_list_for_sql := x_name_list_for_sql || ', ' || '''' || l_user_name||'''';
	x_name_list := x_name_list || ' ' || l_user_name;
      END IF;
    END LOOP;

    -- If there are no users found simply
    -- send back null.
    if l_count = 0 then
        x_name_list := '  NULL  ';
    end if;
    x_users_count := l_count;

EXCEPTION
 WHEN OTHERS THEN
    x_name_list := null;
	l_progress :=  'PO_REQAPPROVAL_INIT1.get_diff_in_user_list : Failed to get the list of users';
	po_message_s.sql_error('In Exception of get_diff_in_user_list ()', l_progress, sqlcode);
END;
/*******************************************************************
  < Added this function as part of Bug #: 2810150 >
  PROCEDURE NAME: get_wf_role_for_users

  DESCRIPTION   :
  Given a list of users, the procedure looks through the wf_user_roles
  to get a role that has exactly same set of input list of users.

  Referenced by : locate_notifier
  parameters    :

    Input:
        p_list_of_users - String containing the list of users
            Example string: 'GE1', 'GE2', 'GE22'
        p_num_users - number of users in the above list
    Output:
        A string containg the role name ( or null , if such role
        does not exist ).

  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/

FUNCTION get_wf_role_for_users(p_list_of_users in varchar2, p_num_users in number) return varchar2 IS
l_refcur g_refcur;
l_role_name WF_USER_ROLES.ROLE_NAME%TYPE;
l_adhoc varchar2(10) :=''''||'ADHOC%'||'''';    -- fix for bug 4547779
l_progress varchar2(255);
BEGIN
      open l_refcur for
        'select role_name
         from wf_user_roles
         where
	     role_name in
         (
            select role_name
            from wf_user_roles
            where user_name in (' ||  p_list_of_users || ')
            and role_name like ' || l_adhoc || '            -- fix for bug 4547779
            and nvl(expiration_date,sysdate+1) > sysdate
            group by role_name
            having count(role_name) = :1
         )
        group by role_name
        having count(role_name) = :2 '
      using p_num_users, p_num_users;

      LOOP
        fetch l_refcur into l_role_name;
            if l_refcur%notfound then
                exit;
            end if;
            close l_refcur;
            exit;
      END LOOP;
      return l_role_name;
EXCEPTION
 WHEN OTHERS THEN
    l_role_name := null;
	l_progress :=  'PO_REQAPPROVAL_INIT1.get_wf_role_for_users: Failed to get the list of users';
	po_message_s.sql_error('In Exception of get_wf_role_for_users()', l_progress, sqlcode);
END;

/**
  < Added this function as part of Bug #: 2810150 >
    FUNCTION NAME: get_function_id
    Get the function id given the function name as in FND_FORM_FUNCTIONS table
    String p_function_name - Function name
    Return Number - The function id

    CHANGE History : Created 27-Feb-2003 JPASALA
*/
FUNCTION get_function_id (p_function_name IN VARCHAR2) RETURN NUMBER IS
   CURSOR l_cur IS
      SELECT function_id
	FROM fnd_form_functions
	WHERE function_name = p_function_name;
   l_function_id NUMBER:=0;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_function_id;
   CLOSE l_cur;
   if( l_function_id is null ) then
    l_function_id := -1;
   end if;
   RETURN l_function_id;

EXCEPTION
 WHEN OTHERS THEN
    l_function_id := -1;
    return l_function_id;
END get_function_id;

/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >
  PROCEDURE NAME: get_user_list_with_resp

  DESCRIPTION   :
  Given a set of users and and a set of responsibilities,
    this procedures returns a new set of users that are
    assigned atleast one of the responsibilities in the
    given set.

  Referenced by : locate_notifier
  parameters    :

    Input:
        p_function_id - function id
        p_namelist - String containing the list of users
            Example string: 'GE1', 'GE2', 'GE22'
    Output:
        x_new_list - list of users that have the given responsibility.
        x_count - number of users in the above list


  CHANGE History: Created      27-Feb-2003    jpasala
*******************************************************************/

PROCEDURE get_user_list_with_resp(
    p_function_id IN NUMBER,
    p_namelist IN VARCHAR2,
    x_new_list OUT NOCOPY VARCHAR2,
    x_new_list_for_sql  OUT NOCOPY VARCHAR2,
    x_count out nocopy number)
is
l_refcur g_refcur;
l_first boolean;
l_user_name varchar2(100);
l_count number;
l_progress varchar2(200);
l_f  varchar2 (10);
begin
    l_count := 0;
    l_f := '''' || 'F' || '''';
    open l_refcur for
    'select distinct fu.user_name
    from fnd_user fu, fnd_user_resp_groups furg
    where fu.user_id = furg.user_id
    and furg.responsibility_id in
    (
        SELECT
    	responsibility_id
	    FROM fnd_responsibility fr
    	WHERE menu_id in
	    ( SELECT fme.menu_id
    	  FROM fnd_menu_entries fme
	      START WITH fme.function_id ='|| p_function_id ||'
     	  CONNECT BY PRIOR menu_id = sub_menu_id
 	    )
        and (end_date is null or end_date > sysdate) '||
        ' and fr.responsibility_id not in (select responsibility_id from fnd_resp_functions
	                                         where action_id= '|| p_function_id ||
	                                         ' and rule_type=' || l_f || ' )' ||

   ' )
    and fu.user_name in (' || p_namelist || ')
    and (furg.end_date is null or furg.end_date > sysdate )' ;




    -- Loop through the cursor and construct the
    -- user list.
    LOOP
      fetch l_refcur into l_user_name;
      if l_refcur%notfound then
         exit;
      end if;
      IF l_count = 0 THEN
         l_count := l_count+1;
	 x_new_list_for_sql :=  '''' ||l_user_name ||'''';
	 x_new_list := l_user_name;
       ELSE
         l_count := l_count+1;
	 x_new_list_for_sql := x_new_list_for_sql || ', ' || '''' || l_user_name||'''';
	 x_new_list := x_new_list || ' ' || l_user_name;
      END IF;
    END LOOP;

    -- If there are no users found simply
    -- send back null.
    if l_count = 0 then
        x_new_list := '  NULL  ';
    end if;
    x_count := l_count;

EXCEPTION
 WHEN OTHERS THEN
    x_new_list := ' null ';
	l_progress :=  'PO_REQAPPROVAL_INIT1.get_user_list_with_resp: Failed to get the list of users';
	po_message_s.sql_error('In Exception of get_user_list_with_resp()', l_progress, sqlcode);
end get_user_list_with_resp;

-- Bug 5956252
-- String_To_UserTable (PRIVATE)
--   Converts a comma/space delimited string of users into a UserTable
-- IN
--   P_UserList  VARCHAR2
-- OUT
-- RETURN
--   P_UserTable WF_DIRECTORY.UserTable
--
procedure string_to_userTable(p_UserList  in VARCHAR2,
                               p_UserTable out NOCOPY WF_DIRECTORY.UserTable)
is

  c1          pls_integer;
  u1          pls_integer := 0;
  l_userList  varchar2(32000);
  l_username varchar2(100);
begin
  if (p_UserList is not NULL) then
    --
    -- Substring and insert users into UserTable
    --
    l_userList := ltrim(p_UserList);
    <<UserLoop>>
    loop
      c1 := instr(l_userList, ',');
      if (c1 = 0) then
          l_username := substr(l_userList,2,length(l_userList)-2);
          p_UserTable(u1) := l_username;
          exit;
      else
        l_username := substr(l_userList, 1, c1-1);
        l_username := substr(l_username,2,length(l_username)-2);
        p_UserTable(u1) := l_username;

      end if;

      u1 := u1 + 1;
      l_userList := ltrim(substr(l_userList, c1+1));
    end loop UserLoop;
  end if;
end string_to_userTable;
-------------------------------------------------------------------------------
--Start of Comments
--Name: start_wf_process
--Pre-reqs:
--  N/A
--Modifies:
--  N/A
--Locks:
--  None
--Function:
--  Starts a Document Approval workflow process.
--Parameters:
--IN:
--ItemType
--  Item Type of the workflow to be started; if NULL, we will use the default
--  Approval Workflow Item Type for the given DocumentType
--ItemKey
--  Item Key for starting the workflow; if NULL, we will construct a new key
--  from the sequence
--WorkflowProcess
--  Workflow process to be started; if NULL, we will use the default Approval
--  Workflow Process for the given DocumentType
--ActionOriginatedFrom
--  Indicates the caller of this procedure. If 'CANCEL', then the approval will
--  not insert into the action history.
--DocumentID
--  This value for this parameter depends on the DocumentType:
--    'REQUISITION': PO_REQUISITION_HEADERS_ALL.requisition_header_id
--    'PO' or 'PA':  PO_HEADERS_ALL.po_header_id
--    'RELEASE':     PO_RELEASES_ALL.po_release_id
--DocumentNumber
--  (Obsolete) This parameter is ignored. This procedure will derive the
--  document number from DocumentID and DocumentType. (Bug 3284628)
--PreparerID
--  Requester (for Requisitions) or buyer (for other document types)
--  whose approval authority should be used in the approval workflow
--DocumentType
--  'REQUISITION', 'PO', 'PA', 'RELEASE'
--DocumentSubType
--  The value for this parameter depends on the DocumentType:
--    'REQUISITION': PO_REQUISITION_HEADERS_ALL.type_lookup_code
--    'PO' or 'PA':  PO_HEADERS_ALL.type_lookup_code
--    'RELEASE':     PO_RELEASES_ALL.release_type
--SubmitterAction
--  (Unused) This parameter is not currently used.
--ForwardToID
--  Requester (for Requisitions) or buyer (for other document types)
--  that this document is being forwarded to
--ForwardFromID
--  Requester (for Requisitions) or buyer (for other document types)
--  that this document is being forwarded from.
--DefaultApprovalPathID
--  Approval hierarchy to use in the approval workflow
--Note
--  Note to be entered into Action History for this document
--PrintFlag
--  If 'Y', this document will be printed.
--FaxFlag
--  If 'Y', this document will be faxed.
--FaxNumber
--  Phone number that this document will be faxed to
--EmailFlag
--  If 'Y', this document will be emailed.
--EmailAddress
--  Email address that this document will be sent to
--CreateSourcingRule
--  Blankets only: If 'Y', the workflow will create new sourcing rules,
--  rule assignments, and ASL entries.
--ReleaseGenMethod
--  Blankets only: Release Generation Method to use when creating ASL entries
--UpdateSourcingRule
--  Blankets only: If 'Y', the workflow will update existing sourcing rules
--  and ASL entries.
--MassUpdateReleases
--  <RETROACTIVE FPI> Blankets / GAs only: If 'Y', we will update the price
--  on the releases of the blanket or standard POs of the GA with the
--  retroactive price change on the blanket/GA line.
--RetroactivePriceChange
--  <RETROACTIVE FPI> Releases / Standard POs only: If 'Y', indicates that
--  this release/PO has been updated with a retroactive price change.
--  This flag is used to differentiate between approval of releases from
--  the form and from the Mass Update Releases concurrent program.
--OrgAssignChange
--  <GA FPI> Global Agreements only: If 'Y', indicates that an Organization
--  Assignment change has been made to this GA.
--CommunicatePriceChange
--  <RETROACTIVE FPJ> Blankets only: If 'Y', we will communicate any releases
--  or POs that were retroactively priced to the Supplier.
--p_background_flag
--  <DROPSHIP FPJ> If 'Y', we will do the following:
--  1. No database commit
--  2. Change the authorization_status to 'IN PROCESS'.
--  3. Launch the approval workflow with background_flag set to 'Y', so that
--  it blocks immediately at a deferred activity.
--  As a result, the caller can choose to commit or rollback its changes.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Start_WF_Process ( ItemType          VARCHAR2,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ActionOriginatedFrom   VARCHAR2,
                             DocumentID             NUMBER,
                             DocumentNumber         VARCHAR2,
                             PreparerID             NUMBER,
                             DocumentTypeCode       VARCHAR2,
                             DocumentSubtype        VARCHAR2,
                             SubmitterAction        VARCHAR2,
                             forwardToID            NUMBER,
                             forwardFromID          NUMBER,
                             DefaultApprovalPathID  NUMBER,
                             Note                   VARCHAR2,
                             PrintFlag              VARCHAR2,
			     FaxFlag		    VARCHAR2,
			     FaxNumber		    VARCHAR2,
			     EmailFlag              VARCHAR2,
                             EmailAddress           VARCHAR2,
                             CreateSourcingRule     VARCHAR2,
                             ReleaseGenMethod       VARCHAR2,
                             UpdateSourcingRule     VARCHAR2,
			     MassUpdateReleases     VARCHAR2,
			     RetroactivePriceChange VARCHAR2,
                             OrgAssignChange        VARCHAR2,   -- GA FPI
                             CommunicatePriceChange VARCHAR2 default 'N', -- <FPJ Retroactive>
                             p_Background_Flag      VARCHAR2 default 'N') -- <DropShip FPJ>
IS
l_responsibility_id     number;
l_user_id               number;
l_application_id        number;

x_progress              varchar2(300);
x_wf_created		number;
x_orgid                 number;

EmailAddProfile   VARCHAR2(60);


x_acceptance_required_flag	varchar2(1) := null;
x_acceptance_due_date	date;
x_agent_id NUMBER;

x_buyer_username WF_USERS.name%TYPE; --Bug7562122
x_buyer_display_name WF_USERS.display_name%TYPE; --Bug7562122

l_userkey           varchar2(40);
l_doc_num_rel       varchar2(30);
l_doc_display_name  FND_NEW_MESSAGES.message_text%TYPE; -- Bug 3215186
l_release_num       PO_RELEASES.release_num%TYPE; -- Bug 3215186
l_revision_num      PO_HEADERS.revision_num%TYPE; -- Bug 3215186
l_ga_flag           varchar2(1) := null;  -- FPI GA

/* RETROACTIVE FPI START */
l_seq_for_item_key varchar2(25)  := null; /* Bug 8256074 */    -- 8435560
l_can_change_forward_from_flag
		po_document_types.can_change_forward_from_flag%type;
l_can_change_forward_to_flag po_document_types.can_change_forward_to_flag%type;
l_can_change_approval_path po_document_types.can_change_approval_path_flag%type;
l_can_preparer_approve_flag po_document_types.can_preparer_approve_flag%type;
l_default_approval_path_id po_document_types.default_approval_path_id%type;
l_can_approver_modify_flag po_document_types.can_approver_modify_doc_flag%type;
l_forwarding_mode_code po_document_types.forwarding_mode_code%type;
l_itemtype po_document_types.wf_approval_itemtype%type;
l_workflow_process po_document_types.wf_approval_process%type;
l_itemkey varchar2(60);
l_type_name po_document_types.type_name%type;

/* RETROACTIVE FPI END */

l_drop_ship_flag po_line_locations.drop_ship_flag%type; -- <DropShip FPJ>
l_conterms_exist_flag     PO_HEADERS_ALL.CONTERMS_EXIST_FLAG%TYPE; --<CONTERMS FPJ>
--bug##3682458 replaced legal entity name with operating unit
l_operating_unit  hr_all_organization_units_tl.name%TYPE; --<POC FPJ>

l_document_number PO_HEADERS_ALL.segment1%TYPE; -- Bug 3284628

l_consigned_flag PO_HEADERS_ALL.CONSIGNED_CONSUMPTION_FLAG%TYPE;
l_autoapprove_retro  varchar2(1);

l_okc_doc_type  varchar2(20);  -- <Word Integration 11.5.10+>
l_vendor po_vendors.vendor_name%type; --Bug 4115777
l_vendor_site_code po_vendor_sites_all.vendor_site_code%type; --Bug 4115777

x_display_name  VARCHAR2(60);
x_document_id  number;
x_tam  NUMBER;

BEGIN


/* DBMS_OUTPUT.enable(10000); */

  x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: at beginning of Start_WF_Process';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  --
  -- Start Process :
  --      - If a process is passed then it will be run
  --      - If a process is not passed then the selector function defined in
  --        item type will be determine which process to run
  --

  /* RETROACTIVE FPI START.
   * Get the itemtype and WorkflowProcess from po_document_types
   * if it is not set.
  */

  If ((ItemType is NULL) or (WorkflowProcess is NULL)) then

        po_approve_sv.get_document_types(
                p_document_type_code           => DocumentTypeCode,
                p_document_subtype             => DocumentSubtype,
                x_can_change_forward_from_flag =>l_can_change_forward_from_flag,
                x_can_change_forward_to_flag   => l_can_change_forward_to_flag,
                x_can_change_approval_path     => l_can_change_approval_path,
                x_default_approval_path_id     => l_default_approval_path_id,
                x_can_preparer_approve_flag    => l_can_preparer_approve_flag, -- Bug 2737257
                x_can_approver_modify_flag     => l_can_approver_modify_flag,
                x_forwarding_mode_code         => l_forwarding_mode_code,
                x_wf_approval_itemtype         => l_itemtype,
                x_wf_approval_process          => l_workflow_process,
                x_type_name                    => l_type_name);

  else
	l_itemtype := ItemType;
	l_workflow_process := WorkflowProcess;

  END IF;

  If (ItemKey is NULL) then

        select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
        into l_seq_for_item_key
        from sys.dual;

        l_itemkey := to_char(DocumentID) || '-' ||
                                         l_seq_for_item_key;
  else
	l_itemkey := ItemKey;

  END IF;

  /* RETROACTIVE FPI END */

  IF  ( l_itemtype is NOT NULL )   AND
      ( l_itemkey is NOT NULL)     AND
      ( DocumentID is NOT NULL ) THEN

	-- bug 852056: check to see if process has already been created
	-- if it has, don't create process again.
	begin
	  select count(*)
	  into   x_wf_created
	  from   wf_items
	  where  item_type = l_itemtype
	    and  item_key  = l_itemkey;
	exception
	  when others then
	    x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: check process existance';
	    po_message_s.sql_error('In Exception of Start_WF_Process()', x_progress, sqlcode);
	    raise;
	end;

       --<DropShip FPJ Start>
       --commit only when background flag is not N.
       --Default value is N which will commit to retain behavior of current callers.
       --background flag is passed as 'Y' when called from OM for Drop Ship FPJ, commit not done
       IF p_Background_Flag <> 'Y' THEN
         commit;
       END IF;
       --<DropShip FPJ End>

       if x_wf_created = 0 then
        wf_engine.CreateProcess( ItemType => l_itemtype,
                                 ItemKey  => l_itemkey,
                                 process  => l_workflow_process );
       end if;

        --
        -- Initialize workflow item attributes
        --
        /* get the profile option value for the second Email Address */
        FND_PROFILE.GET('PO_SECONDRY_EMAIL_ADD', EmailAddProfile);
               
        
        

	if NVL(ActionOriginatedFrom, 'Approval') = 'POS_DATE_CHG' then

        	wf_engine.SetItemAttrText (     itemtype   => l_itemtype,
                	                        itemkey    => l_itemkey,
                        	                aname      => 'WEB_SUPPLIER_REQUEST',
                                	        avalue     =>  'Y');
	end if;

        --< Bug 3631960 Start >
	/* bug 4574501 : passing ActionOriginatedFrom to INTERFACE_SOURCE_CODE,
	   instead of NULL in case of CANCEL, will use the same in the workflow
	   to skip the PO_APPROVED notification ,when wf is called from cancel.*/

	    x_progress := 'start wf process called interface source code:'||ActionOriginatedFrom;
	    PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);

        IF (ActionOriginatedFrom = 'CANCEL') THEN

            -- If approval workflow is being called from a Cancel action, then
            -- do not insert into action history.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INSERT_ACTION_HIST_FLAG'
                                          , avalue   => 'N'
                                          );
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INTERFACE_SOURCE_CODE'
                                          , avalue   => ActionOriginatedFrom
                                          );

            -- Bug 4299952 We should always bypass the approval hierarchy
            -- for a Cancel action, since the approval workflow is only being
            -- invoked for communication and archival purposes.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    =>
                                            'BYPASS_APPROVAL_HIERARCHY_FLAG'
                                          , avalue   => 'Y'
                                          );
        ELSE

            -- All other cases, we need to insert into action history.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INSERT_ACTION_HIST_FLAG'
                                          , avalue   => 'Y'
                                          );
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    => 'INTERFACE_SOURCE_CODE'
                                          , avalue   => ActionOriginatedFrom
                                          );

            -- Bug 4299952 We do not need to bypass the approval hierarchy
            -- for other actions.
            PO_WF_UTIL_PKG.SetItemAttrText( itemtype => l_itemtype
                                          , itemkey  => l_itemkey
                                          , aname    =>
                                            'BYPASS_APPROVAL_HIERARCHY_FLAG'
                                          , avalue   => 'N'
                                          );
        END IF;  --< if ActionOriginatedFrom ... >
        --< Bug 3631960 End >

        --
        wf_engine.SetItemAttrNumber (   itemtype   => l_itemtype,
                                        itemkey    => l_itemkey,
                                        aname      => 'DOCUMENT_ID',
                                        avalue     => DocumentID);
        --
        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'DOCUMENT_TYPE',
                                        avalue          =>  DocumentTypeCode);
        --

        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'DOCUMENT_SUBTYPE',
                                        avalue          =>  DocumentSubtype);
--<POC FPJ>
  g_document_subtype := DocumentSubtype;
        --
        
        
        -- AWAS Custom
        wf_engine.SetItemAttrNumber (   itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'PREPARER_ID',
                                        avalue          => PreparerID);
        --
        wf_engine.SetItemAttrNumber (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'FORWARD_TO_ID',
                                        avalue          =>  ForwardToID);
        --
        x_display_name := wf_engine.getitemattrtext(     itemtype   => l_itemtype,
                                                          itemkey    => l_itemkey,
                                                          aname      => 'DOCUMENT_DISPLAY_NAME');
                        
        x_document_id  := wf_engine.GetItemAttrNumber(     itemtype   => l_itemtype,
                                                          itemkey    => l_itemkey,
                                                          aname      => 'DOCUMENT_ID');
                                                          
        IF x_display_name = 'Standard PO' THEN
        
        SELECT sum(decode(c.segment1,'PARTS',1,0))
        into x_tam
        FROM po_lines_all l,
        mtl_categories_b c
        WHERE po_header_id = x_document_id
        and l.category_id = c.category_id;
                      
        IF x_tam = 0 then 
        FND_PROFILE.GET('PO_SECONDRY_EMAIL_ADD', EmailAddProfile);
        ELSE 
        EmailAddProfile := 'procurement@awas.com';
        END IF;
        
        END IF;
        
        -- End of AWAS Custom

/* Bug# 2308846: kagarwal
** Description: The forward from user was always set to the preparer
** in the Approval process. Hence if the forward from user was
** different from the preparer, the forward from was showing
** wrong information.
**
** Fix Details: Modified the procedure Start_WF_Process() and
** Set_Startup_Values() to set the forward from attributes
** correctly.
*/

        if (forwardFromID is not NULL) then
          wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  forwardFromID);

        else
          wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  forwardFromID);
        end if;

        --
        wf_engine.SetItemAttrNumber (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'APPROVAL_PATH_ID',
                                        avalue          =>  DefaultApprovalPathID);
        --
        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'NOTE',
                                        avalue          =>  Note);
        --
        wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'PRINT_DOCUMENT',
                                        avalue          =>  PrintFlag);

        PO_WF_UTIL_PKG.SetItemAttrText (itemtype        => l_itemtype,
                                        itemkey         => l_itemkey,
                                        aname           => 'JUSTIFICATION',
                                        avalue          =>  Note);

	-- DKC 10/13/99
  	IF DocumentTypeCode IN ('PO', 'PA', 'RELEASE') THEN


	   if DocumentTypeCode <> 'RELEASE' then

	   SELECT poh.acceptance_required_flag,
	          poh.acceptance_due_date,
	          poh.agent_id
	   into   x_acceptance_required_flag,
	          x_acceptance_due_date,
	          x_agent_id
	   from po_headers  poh
	   where poh.po_header_id = DocumentID;

	 ELSE

	   SELECT por.acceptance_required_flag,
	          por.acceptance_due_date, por.agent_id
	     into      x_acceptance_required_flag,
	             x_acceptance_due_date,
	             x_agent_id
		from po_releases por,
		     po_headers  poh
		where por.po_release_id = DocumentID
	             and   por.po_header_id = poh.po_header_id;


	END IF;

	wf_engine.SetItemAttrText ( itemtype => l_itemtype,
        			    itemkey  => l_itemkey,
        	        	    aname    => 'ACCEPTANCE_REQUIRED',
				    avalue   => x_acceptance_required_flag);

	wf_engine.SetItemAttrDate ( itemtype => l_itemtype,
        			    itemkey  => l_itemkey,
        	        	    aname    => 'ACCEPTANCE_DUE_DATE',
				    avalue   => x_acceptance_due_date);

	wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
        			      itemkey  => l_itemkey,
        	        	      aname    => 'BUYER_USER_ID',
				      avalue   => x_agent_id);


	if x_agent_id is not null then

		x_progress := '003';

		-- Get the buyer user name


	  	WF_DIRECTORY.GetUserName(  'PER',
	        	                   x_agent_id,
       		         	           x_buyer_username,
                	        	   x_buyer_display_name);
		x_progress := '004';

		wf_engine.SetItemAttrText (   	itemtype => l_itemtype,
        			      		itemkey  => l_itemkey,
                		      		aname    => 'BUYER_USER_NAME',
				      		avalue   => x_buyer_username);
	end if;


          --DKC 10/10/99
          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'FAX_DOCUMENT',
                                          avalue          =>  FaxFlag);
          --DKC 10/10/99
          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'FAX_NUMBER',
                                          avalue          =>  FaxNumber);


          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'EMAIL_DOCUMENT',
                                          avalue          =>  EmailFlag);

          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'EMAIL_ADDRESS',
                                          avalue          =>  EmailAddress);

           wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'EMAIL_ADD_FROM_PROFILE',
                                          avalue          =>  EmailAddProfile);


            wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'CREATE_SOURCING_RULE',
                                          avalue          =>  createsourcingrule);

           wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'UPDATE_SOURCING_RULE',
                                          avalue          =>  updatesourcingrule);

           wf_engine.SetItemAttrText (    itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'RELEASE_GENERATION_METHOD',
                                          avalue          =>  ReleaseGenMethod);

	    /* RETROACTIVE FPI START */
            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'MASSUPDATE_RELEASES',
                                          avalue       =>  MassUpdateReleases);

            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'CO_R_RETRO_CHANGE',
                                          avalue       =>  RetroactivePriceChange);
	    /* RETROACTIVE FPI  END */

            /* GA FPI start */
            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'GA_ORG_ASSIGN_CHANGE',
                                          avalue       =>  OrgAssignChange);
            /* GA FPI End */

            -- <FPJ Retroactive START>
            PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'CO_H_RETROACTIVE_SUPPLIER_COMM',
                                          avalue       =>  CommunicatePriceChange);
            -- <FPJ Retroactive END>

            --<DropShip FPJ Start>
            PO_WF_UTIL_PKG.SetItemAttrText(itemtype    => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'BACKGROUND_FLAG',
                                          avalue       =>  p_background_flag);

            -- l_drop_ship_flag indicates if current Release/PO has any DropShip Shipments
            BEGIN
              l_drop_ship_flag := 'N';

              IF DocumentTypeCode = 'RELEASE' THEN
                select 'Y'
                into l_drop_ship_flag
                from dual
                where exists
                 (select 'Release DropShip Shipment Exists'
                  from po_line_locations
                  where po_release_id = DocumentId
                  and drop_ship_flag = 'Y');

              ELSIF DocumentTypeCode = 'PO' THEN
                select 'Y'
                into l_drop_ship_flag
                from dual
                where exists
                 (select 'PO DropShip Shipment Exists'
                  from po_line_locations
                  where po_header_id = DocumentId
                  and drop_ship_flag = 'Y');
              END IF;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_drop_ship_flag := 'N';
            END;

            -- Workflow Attribute DROP_SHIP_FLAG added for any customizations to refer to it.
            -- Base Purchasing code does NOT refer to DROP_SHIP_FLAG attribute
            PO_WF_UTIL_PKG.SetItemAttrText(itemtype    => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'DROP_SHIP_FLAG',
                                          avalue       =>  l_drop_ship_flag);
            --<DropShip FPJ End>

            -- Bug 3318625 START
            -- Set the autoapprove attribute for retroactively priced consumption
            -- advices so that they are always routed through change order skipping
            -- the authority checks
            BEGIN
              l_consigned_flag := 'N';

             IF DocumentTypeCode = 'RELEASE' THEN
                select  NVL(consigned_consumption_flag, 'N') -- Bug 3318625
	        into    l_consigned_flag
	        from   po_releases_all
	        where  po_release_id = DocumentId;
              ELSIF DocumentTypeCode = 'PO' THEN
                select  NVL(consigned_consumption_flag, 'N')
	        into    l_consigned_flag
	        from   po_headers_all
	        where  po_header_id = DocumentId;
              END IF;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_consigned_flag := 'N';
            END;

            IF l_consigned_flag = 'Y' THEN
               l_autoapprove_retro := 'Y';

               PO_WF_UTIL_PKG.SetItemAttrText (    itemtype     => l_itemtype,
                                          itemkey      => l_itemkey,
                                          aname        => 'CO_H_RETROACTIVE_AUTOAPPROVAL',
                                          avalue       =>  l_autoapprove_retro);
            END IF;

            -- Bug 3318625 END

        /* Get the multi-org context and store it in item attribute ORG_ID. This will be
        ** By all other activities.
        */
        PO_REQAPPROVAL_INIT1.get_multiorg_context (DocumentTypeCode, DocumentID, x_orgid);

        IF x_orgid is NOT NULL THEN

          fnd_client_info.set_org_context(to_char(x_orgid));

          /* Set the Org_id item attribute. We will use it to get the context for every activity */
          wf_engine.SetItemAttrNumber (   itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'ORG_ID',
                                          avalue          => x_orgid);

        END IF;


	 -- DKC 02/06/01
	 wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'PO_EMAIL_HEADER',
					  avalue 	=> 'PLSQL:PO_EMAIL_GENERATE.GENERATE_HEADER/'|| to_char(DocumentID) || ':' || DocumentTypeCode);


	 -- DKC 02/06/01
	 wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'PO_EMAIL_BODY',
					  avalue  	 => 'PLSQLCLOB:PO_EMAIL_GENERATE.GENERATE_HTML/'|| to_char(DocumentID) || ':' || DocumentTypeCode);

          /* set the terms and conditions read from a file */
			--EMAILPO FPH--
			-- GENERATE_TERMS is changed to take itemtype and itemkey instead of DocumentID and DocumentTypeCode
			-- as itemtype and itemkey are necessary for retrieving the profile options
			-- Upgrade related issues are handled in PO_EMAIL_GENERATE.GENERATE_TERMS procedure
	  /* Bug 2687751. When we refactored start_wf_process, we defaulted
	   * item type and item key and changed all the occurences of
	   * itemkey to use local variable l_itemkey. This was left out in the
	   * SetItemAttrText for PO_TERMS_CONDITIONS. Changing this as part
	   * of bug 2687751.
	  */
          wf_engine.SetItemAttrText (     itemtype        => l_itemtype,
                                          itemkey         => l_itemkey,
                                          aname           => 'PO_TERMS_CONDITIONS',
					  avalue  	 => 'PLSQLCLOB:PO_EMAIL_GENERATE.GENERATE_TERMS/'|| l_itemtype || ':' || l_itemkey);

	END IF;


if (DocumentTypeCode in ('PO', 'PA','RELEASE','REQUISITION')) then
if (DocumentTypeCode in ('PO', 'PA')) then

        /* FPI GA Start */

        -- <GC FPJ>
        -- Pass ga flag to the wf for all PA documents (BLANKET and CONTRACT)

        -- IF DocumentTypeCode = 'PA' AND DocumentSubtype = 'BLANKET' THEN

         IF DocumentTypeCode = 'PA' THEN

           select global_agreement_flag
           into l_ga_flag
           from po_headers_all
           where po_header_id = DocumentID;

           PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype    => l_itemtype,
                                         itemkey     => l_itemkey,
                                         aname       => 'GLOBAL_AGREEMENT_FLAG',
                                         avalue      =>  l_ga_flag);
         END IF;
         /* FPI GA End */

       /* bug 2115200 */
       /* Added logic to derive the doc display name */
       --CONTERMS FPJ Extracting Contract Terms value in this Query as well
        select revision_num,
               DECODE(TYPE_LOOKUP_CODE,
                 'BLANKET',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_BLKT'),
                 'CONTRACT',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_CNTR'),
                 'STANDARD',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_STD'),
                 'PLANNED',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_PLND')),
               NVL(CONTERMS_EXIST_FLAG,'N'), --<CONTERMS FPJ>
               segment1 -- Bug 3284628
        into l_revision_num,
             l_doc_display_name,
	     l_conterms_exist_flag, --<CONTERMS FPJ>
             l_document_number -- Bug 3284628
	from po_headers
	where po_header_id = DocumentID;

      l_doc_num_rel := l_document_number;

      --<CONTERMS FPJ Start>
      PO_WF_UTIL_PKG.SetItemAttrText( itemtype    => l_itemtype,
                                      itemkey     => l_itemkey,
                                      aname       => 'CONTERMS_EXIST_FLAG',
                                      avalue      =>  l_conterms_exist_flag);
      --<CONTERMS FPJ END>

      /* FPI GA Start */
       if l_ga_flag = 'Y' then
         l_doc_display_name := FND_MESSAGE.GET_STRING('PO','PO_GA_TYPE');
       end if;
      /* FPI GA End */

     elsif (DocumentTypeCode = 'RELEASE') then

       -- Bug 3859714. Workflow attribute WITH_TERMS should be set to 'N' for
       -- a Release because a release will not have Terms.
       l_conterms_exist_flag := 'N';

       /* bug 2115200 */
        select POR.revision_num,
               POR.release_num,
               DECODE(POR.release_type,
                 'BLANKET', FND_MESSAGE.GET_STRING('POS','POS_POTYPE_BLKTR'),
                 'SCHEDULED',FND_MESSAGE.GET_STRING('POS','POS_POTYPE_PLNDR')),
               POH.segment1 -- Bug 3284628
        into l_revision_num,
             l_release_num,
             l_doc_display_name,
             l_document_number -- Bug 3284628
        from po_releases POR, po_headers POH
        where POR.po_release_id = DocumentID
        and   POR.po_header_id = POH.po_header_id; -- JOIN

        l_doc_num_rel := l_document_number || '-' || l_release_num;

     -- Bug 3284628 START
     ELSIF (DocumentTypeCode = 'REQUISITION') THEN

       SELECT PRH.segment1
       INTO l_document_number
       FROM po_requisition_headers PRH
       WHERE PRH.requisition_header_id = DocumentID;

       END IF; -- DocumentTypeCode

        -- Bug 3284628 START
      wf_engine.SetItemAttrText (   itemtype   => l_itemtype,
                                      itemkey    => l_itemkey,
                                      aname      => 'DOCUMENT_NUMBER',
                                      avalue     => l_document_number);
      -- Bug 3284628 END

      /* Bug# 2474660: kagarwal
** Desc: Setting the item user key for all documents.
** The item user key will be the document number for PO/PA/Requisitions
** and BPA Number - Release Num for releases.
*/


     if (DocumentTypeCode = 'RELEASE') then
        l_userkey := l_doc_num_rel;
     else
        l_userkey := l_document_number; -- Bug 3284628
     end if;

     BEGIN
        wf_engine.SetItemUserKey(itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 userkey         => l_userkey);

     EXCEPTION
       when others then
          null;
     END;

      END IF;
if (DocumentTypeCode in ('PO', 'PA','RELEASE')) then

   /* bug 2115200 */
      wf_engine.SetItemAttrText (itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 aname           => 'DOCUMENT_NUM_REL',
                                 avalue          =>  l_doc_num_rel);

      wf_engine.SetItemAttrText (itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 aname           => 'REVISION_NUMBER',
                                 avalue          =>  l_revision_num);

      wf_engine.SetItemAttrText (itemtype        => l_itemtype,
                                 itemkey         => l_itemkey,
                                 aname           => 'DOCUMENT_DISPLAY_NAME',
                                 avalue          =>  l_doc_display_name);
end if;




--<Bug 4115777 Start> Need to show supplier and operating unit in
-- PO Approval notifications

   BEGIN
      if DocumentTypeCode <> 'RELEASE' then
              select pov.vendor_name,
                     pvs.vendor_site_code
              into l_vendor,
                   l_vendor_site_code
              from po_vendors pov,po_headers poh,po_vendor_sites_all pvs
              where pov.vendor_id    = poh.vendor_id
              and poh.po_header_id   = DocumentId
              and poh.vendor_site_id = pvs.vendor_site_id;
      else
              select pov.vendor_name,
                     pvs.vendor_site_code
              into l_vendor,
                   l_vendor_site_code
              from po_releases por,po_headers poh,
                   po_vendors pov,po_vendor_sites_all pvs
              where por.po_release_id = DocumentId
              and por.po_header_id    = poh.po_header_id
              and poh.vendor_id       = pov.vendor_id
              and poh.vendor_site_id  = pvs.vendor_site_id;
      end if;
   EXCEPTION
      WHEN OTHERS THEN
         --In case of any exception, the supplier will show up as null
         null;
   END;

   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => l_vendor);

   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'SUPPLIER_SITE',
                                   avalue   => l_vendor_site_code);

   --Brought the following code out of POC FPJ block
   --Need to display the Legal Entity Name on the Notification Subject

   IF  x_orgid is not null  THEN
      --bug#3682458 replaced the sql that retrieves legal entity
      --name with sql that retrieves operating unit name
      BEGIN
         SELECT hou.name
         into   l_operating_unit
         FROM
                hr_organization_units hou
         WHERE
                hou.organization_id = x_orgid;
      EXCEPTION
         WHEN OTHERS THEN
            l_operating_unit:=null;
      END;
   END IF;

   --bug#3682458 replaced legal_entity_name with operating_unit_name
   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'OPERATING_UNIT_NAME',
                                  avalue=>l_operating_unit);
--<Bug 4115777 End>

--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T'  THEN

PO_WF_UTIL_PKG.SetItemAttrText (itemtype        => l_itemtype,
                                itemkey         => l_itemkey,
                                aname           => 'WITH_TERMS',
                                avalue          =>l_conterms_exist_flag);

PO_WF_UTIL_PKG.SetItemAttrText (itemtype        => l_itemtype,
                                itemkey         => l_itemkey,
                                aname           => 'LANGUAGE_CODE',
                                avalue          =>userenv('LANG'));

--bug#3682458
PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'EMAIL_TEXT_WITH_PDF',
                      avalue=>FND_MESSAGE.GET_STRING('PO','PO_PDF_EMAIL_TEXT'));

PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PO_PDF_ERROR',
                      avalue=>FND_MESSAGE.GET_STRING('PO','PO_PDF_ERROR'));

PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PDF_ATTACHMENT_BUYER',
                   avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.PDF_ATTACH_APP/'|| l_itemtype||':'||l_itemkey);

-- Bug 3851357. Replaced PDF_ATTACH_SUPP with PDF_ATTACH so that the procedure
-- PO_COMMUNICATION_PKG.PDF_ATTACH is consistently called for all Approval PDF
-- supplier notifications
PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PDF_ATTACHMENT_SUPP',
                   avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.PDF_ATTACH/'|| l_itemtype||':'||l_itemkey);

PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                           itemkey => l_itemkey,
                           aname => 'PDF_ATTACHMENT',
                   avalue => 'PLSQLBLOB:PO_COMMUNICATION_PVT.PDF_ATTACH/'||l_itemtype||':'||l_itemkey);

  -- <Start Word Integration 11.5.10+>
  -- <Set up okc doc attachment attribute, if necessary>
  IF (l_conterms_exist_flag = 'Y')
  THEN

    l_okc_doc_type := PO_CONTERMS_UTL_GRP.get_po_contract_doctype(DocumentSubtype);

    IF ( ('STRUCTURED' <> OKC_TERMS_UTIL_GRP.get_contract_source_code(p_document_type => l_okc_doc_type
                                                                    , p_document_id => DocumentID))
          AND
         ('N' = OKC_TERMS_UTIL_GRP.is_primary_terms_doc_mergeable(p_document_type => l_okc_doc_type
                                                                , p_document_id => DocumentID))
       )
    THEN

      PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                      itemkey => l_itemkey,
                                      aname => 'OKC_DOC_ATTACHMENT',
                                      avalue =>
                               'PLSQLBLOB:PO_COMMUNICATION_PVT.OKC_DOC_ATTACH/'||
                                    l_itemtype||':'||l_itemkey);

    END IF;  -- not structured and not mergeable


    -- <Start Contract Dev. Report 11.5.10+>: Set up attachments links region.
    PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'PO_OKC_ATTACHMENTS',
                                   avalue   =>
                         'FND:entity=OKC_CONTRACT_DOCS'
                         || '&' || 'pk1name=BusinessDocumentType'
                         || '&' || 'pk1value=' || DocumentTypeCode || '_' || DocumentSubtype
                         || '&' || 'pk2name=BusinessDocumentId'
                         || '&' || 'pk2value=' || DocumentID
                         || '&' || 'pk3name=BusinessDocumentVersion'
                         || '&' || 'pk3value=' || '-99'
                         || '&' || 'categories=OKC_REPO_CONTRACT,OKC_REPO_APP_ABSTRACT');
    -- <End Contract Dev. Report 11.5.10+>


  END IF; -- l_conterms_exist_flag = 'Y'
  -- <End Word Integration 11.5.10+>

END IF;
--<POC FPJ End>

        x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: Before call to FND_PROFILE';
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);
        END IF;

        /* Get the USER_ID and the RESPONSIBLITY_ID for the current forms session.
        ** This will be used in later calls to APPS_INITIALIZE(), before calling
        ** the Document Manager.
        */

       if (x_wf_created = 0) then

        -- Bug 5389914
        --FND_PROFILE.GET('USER_ID', l_user_id);
        --FND_PROFILE.GET('RESP_ID', l_responsibility_id);
        --FND_PROFILE.GET('RESP_APPL_ID', l_application_id);
        /*Bug8439136 If the PO approval is launched from create doc flow then
          set the user_id to the buyer_id on the PO rather than the current
          session user_id */

         BEGIN
           IF (ActionOriginatedFrom = 'CREATEDOC')  THEN
               select user_id
               into l_user_id
               from fnd_user
               where employee_id = PreparerID;
           ELSE
	       l_user_id := fnd_global.user_id;
           END IF;
        EXCEPTION
           WHEN OTHERS THEN
               l_user_id := fnd_global.user_id;
        END;
        /*Bug8439136 end */

        l_responsibility_id := fnd_global.resp_id;
        l_application_id := fnd_global.resp_appl_id;

        IF (l_user_id = -1) THEN
            l_user_id := NULL;
        END IF;

        IF (l_responsibility_id = -1) THEN
            l_responsibility_id := NULL;
        END IF;

        IF (l_application_id = -1) THEN
            l_application_id := NULL;
        END IF;

        /* l_application_id := 201; */
        --
        wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'USER_ID',
                                      avalue          =>  l_user_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'APPLICATION_ID',
                                      avalue          =>  l_application_id);
        --
        wf_engine.SetItemAttrNumber ( itemtype        => l_itemtype,
                                      itemkey         => l_itemkey,
                                      aname           => 'RESPONSIBILITY_ID',
                                      avalue          =>  l_responsibility_id);

        /* Set the context for the doc manager */
        fnd_global.APPS_INITIALIZE (l_user_id, l_responsibility_id, l_application_id);
		-- bug fix 2424044
		IF x_orgid is NOT NULL THEN
        	fnd_client_info.set_org_context(to_char(x_orgid));
		END IF;
       end if;


       --<DropShip FPJ Start>
       -- When background flag is 'Y' the approval workflow blocks at a background activity
       -- set authorization_status to IN PROCESS so that the header is 'locked'
       -- while the workflow process is waiting for background engine to pick it up

       IF p_background_flag = 'Y' THEN
           IF DocumentTypeCode = 'RELEASE' THEN
               update po_releases
               set AUTHORIZATION_STATUS = 'IN PROCESS',
               last_updated_by      = fnd_global.user_id,
               last_update_login    = fnd_global.login_id,
               last_update_date     = sysdate
               where po_release_id  = DocumentID;
           ELSE --PO or PA
               update po_headers
               set AUTHORIZATION_STATUS = 'IN PROCESS',
               last_updated_by         = fnd_global.user_id,
               last_update_login       = fnd_global.login_id,
               last_update_date        = sysdate
               where po_header_id      = DocumentID;
           END IF;
       END IF; -- END of IF p_background_flag = 'Y'

            --<DropShip FPJ End>

        x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: Before  call to wf_engine.StartProcess()' ||
                       ' parameter DefaultApprovalPathID= ' || to_char(DefaultApprovalPathID);
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,x_progress);
        END IF;

        --
        wf_engine.StartProcess(         itemtype        => l_itemtype,
                                        itemkey         => l_itemkey );

    END IF;

EXCEPTION
 WHEN OTHERS THEN

   x_progress :=  'PO_REQAPPROVAL_INIT1.Start_WF_Process: In Exception handler';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,l_itemkey,x_progress);
   END IF;

   po_message_s.sql_error('In Exception of Start_WF_Process()', x_progress, sqlcode);

   RAISE;

END Start_WF_Process;


-- SetStartupValues
--  Iinitialize/assigns startup values to workflow attributes.
--
-- IN
--   itemtype, itemkey, actid, funcmode
-- OUT
--   Resultout
--    - Completed   - Activity was completed without any errors.
--
procedure Set_Startup_Values(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_doc_subtype   varchar2(25);
l_document_id   number;

l_preparer_id number;
x_username    WF_USERS.name%TYPE; --Bug7562122
x_user_display_name WF_USERS.display_name%TYPE; --Bug7562122
x_ff_username   WF_USERS.name%TYPE; --Bug7562122
x_ff_user_display_name WF_USERS.display_name%TYPE; --Bug7562122
x_ft_username    WF_USERS.name%TYPE; --Bug7562122
x_ft_user_display_name WF_USERS.display_name%TYPE; --Bug7562122
l_forward_to_id     number;
l_forward_from_id   number;
l_authorization_status varchar2(25);
l_open_form         varchar2(200);
l_update_req_url    varchar2(1000);
l_open_req_url    varchar2(1000);
l_resubmit_req_url    varchar2(1000);    -- Bug 636924, lpo, 03/31/98
--Bug#3147435
--Variables for VIEW_REQ_DTLS_URL, EDIT_REQ_URL and RESUBMIT_REQ_URL
l_view_req_dtls_url varchar2(1000);
l_edit_req_url varchar2(1000);
l_resubmit_url varchar2(1000);
l_error_msg       varchar2(200);
x_orgid     number;

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
l_po_revision number;

l_interface_source      VARCHAR2(30);
l_can_modify_flag       VARCHAR2(1);

x_progress  varchar2(200);
--bug 4556437
l_printer   VARCHAR2(30);
-- 4956567
l_conc_copies number;
l_conc_save_output varchar2(1);
--Bug 6027642
l_external_url VARCHAR2(500);
l_header_attribute_10 VARCHAR2(240);
x_suggested_buyer_id NUMBER;
xx_project_id NUMBER;

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Set_Startup_Values: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2353153
  ** Setting application context
  */

  -- bug 4556437 : context setting no longer required here
  --PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

  -- Set the multi-org context

  x_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF x_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(x_orgid));

  END IF;

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
                                         
                                         
                                         
/* AWAS Custom to set default buyer  */

SELECT attribute10 
INTO l_header_attribute_10
from po_requisition_headers_all where requisition_header_id = l_document_id;


IF l_header_attribute_10 IS NOT NULL THEN

   xx_project_id := to_number(l_header_attribute_10);
   
-- Set suggested_buyer_id
SELECT person_id
into x_suggested_buyer_id
FROM pa_project_players
WHERE project_role_type = '1002'
AND project_id = xx_project_id;

UPDATE po_requisition_lines_all
set suggested_buyer_id = x_suggested_buyer_id
where requisition_header_id = l_document_id;


END IF;

/* End of AWAS Custom  

*/

  /* Since we are just starting the workflow assign the preparer_id to
  ** variable APPROVER_EMPID. This variable always holds the
  ** employee id of the approver i.e. activity VERIFY AUTHORITY will
  ** always use this employee id to verify authority against.
  ** If the preparer can not approve, then process FIND APPROVER will
  ** find an approver and put his/her employee_id in APPROVER_EMPID
  ** item attribute.
  */
  l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_preparer_id);

   /* Get the username and display_name of the preparer. This will
   ** be used as the FORWARD-FROM in the notifications.
   ** Initially the preparer is also considered as the approver, so
   ** set the approver_username also.
   */
   PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, x_username,
                                      x_user_display_name);

   -- Bug 711141 fix (setting process owner here)

   wf_engine.SetItemOwner (itemtype => itemtype,
                           itemkey  => itemkey,

/* { Bug 2148872:          owner    => 'PER:' || l_preparer_id);

     wf_engine.SetItemOwner needs 'owner' parameter to be passed as
     the internal user name of the owner in wf_users. To pass it as
     "PER:person_id" has been disallowed by WF.                    */

                           owner    => x_username);   -- Bug 2148872 }

   /*bug 4556437: added a new attribute to the wf to store the
    preparer's printer, will use the same while submitting
    print requests*/

   l_printer := fnd_profile.value('PRINTER');
   /* bug 4956567 : need to set the number of copies and value of save output also*/
   l_conc_copies := to_number(fnd_profile.value('CONC_COPIES'));
   l_conc_save_output := fnd_profile.value('CONC_SAVE_OUTPUT');

    /* changed the call from wf_engine.setiteattrtext to
       po_wf_util_pkg.setitemattrtext because the later handles
       attrbute not found exception. req change order wf also
       uses these procedures and does not have the preparer_printer
       attribute, hence this was required */


   po_wf_util_pkg.SetItemAttrText (itemtype => itemType,
   			      itemkey  => itemkey,
			      aname    => 'PREPARER_PRINTER',
			      avalue   => l_printer);

   po_wf_util_pkg.SetItemAttrNumber (itemtype => itemType,
   			      itemkey  => itemkey,
			      aname    => 'PREPARER_CONC_COPIES',
			      avalue   => l_conc_copies);

   po_wf_util_pkg.SetItemAttrText (itemtype  => itemType,
  				  itemkey   => itemkey,
				  aname     => 'PREPARER_CONC_SAVE_OUTPUT',
				  avalue    => l_conc_save_output);
    /* bug 4956567 : end of addition here*/

   /* bug 4556437 */


   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_USER_NAME' ,
                              avalue     => x_username);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => x_username);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

/* Bug# 2308846: kagarwal
** Description: The forward from user was always set to the preparer
** in the Approval process. Hence if the forward from user was
** different from the preparer, the forward from was showing
** wrong information.
**
** Fix Details: Modified the procedure Start_WF_Process() and
** Set_Startup_Values() to set the forward from attributes
** correctly.
*/


   l_forward_from_id :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_FROM_ID');

   IF (l_forward_from_id <> l_preparer_id) THEN

      PO_REQAPPROVAL_INIT1.get_user_name(l_forward_from_id, x_ff_username,
                                         x_ff_user_display_name);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_USER_NAME' ,
                                  avalue     => x_ff_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_DISP_NAME' ,
                                  avalue     => x_ff_user_display_name);

   ELSE

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_USER_NAME' ,
                                  avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'FORWARD_FROM_DISP_NAME' ,
                                  avalue     => x_user_display_name);

   END IF;


   /* Get the username (this is the name used to forward the notification to)
   ** from the FORWARD_TO_ID. We need to do this here!
   ** Also set the item attribute FORWARD_TO_USERNAME to that username.
   */
   l_forward_to_id :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');

   IF l_forward_to_id is NOT NULL THEN

/* kagarwal: Use a diff variable for username and display name
** for forward to as later we set the responder attributes to same
** as that of preparer using the var x_username and
** x_user_display_name
*/
      /* Get the forward-to display name */
      PO_REQAPPROVAL_INIT1.get_user_name(l_forward_to_id, x_ft_username,
                                      x_ft_user_display_name);

      /* Set the forward-to display name */
      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => x_ft_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => x_ft_user_display_name);

   END IF;

   /* Bug 1064651
   ** Init  RESPONDER to PREPARER if document is a requisition.
   */

   IF l_document_type = 'REQUISITION' THEN

      wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RESPONDER_ID',
                                   avalue   => l_preparer_id);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'RESPONDER_USER_NAME' ,
                                  avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'RESPONDER_DISPLAY_NAME' ,
                                  avalue     => x_user_display_name);

     /* Bug 3800933
      ** Need to set the preparer's language as worflow attribute for info template attachment of req approval
     */
     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                    itemkey     => itemkey,
                                    aname       => 'PREPARER_LANGUAGE',
                                    avalue      =>  userenv('LANG'));

  END IF;

  -- Set the Command for the button that opens the Enter PO/Releases form
  -- Note: the Open Form command for the requisition is hard-coded in the
  --       Requisition approval workflow.

  IF l_document_type IN ('PO', 'PA') THEN

     l_open_form := 'PO_POXPOEPO:PO_HEADER_ID="' || '&' || 'DOCUMENT_ID"' ||
                    ' ACCESS_LEVEL_CODE="MODIFY"' ||
                    ' POXPOEPO_CALLING_FORM="POXSTNOT"';

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'OPEN_FORM_COMMAND' ,
                              avalue     => l_open_form);

  ELSIF l_document_type = 'RELEASE' THEN

     l_open_form := 'PO_POXPOERL:PO_RELEASE_ID="' || '&' || 'DOCUMENT_ID"' ||
                    ' ACCESS_LEVEL_CODE="MODIFY"' ||
                    ' POXPOERL_CALLING_FORM="POXSTNOT"';

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'OPEN_FORM_COMMAND' ,
                              avalue     => l_open_form);
  END IF;

  /* WEB REQUISITIONS:
  **  Set the URL to  VIEW/UPDATE web requisitions
  */

  -- The support for icx 3.0 is removed.

  IF (fnd_profile.value('POR_SSP4_INSTALLED') = 'Y' AND
      fnd_profile.value('POR_SSP_VERSION') = '5' AND
      l_document_type = 'REQUISITION' and
      po_core_s.get_product_install_status('ICX') = 'I') THEN

     l_open_req_url := por_util_pkg.jumpIntoFunction(
             p_application_id        => 178,
             p_function_code         => 'POR_OPEN_REQ',
             p_parameter1            => to_char(l_document_id),
             p_parameter11           => to_char(x_orgid) );

     l_update_req_url := por_util_pkg.jumpIntoFunction(
                     p_application_id=> 178,
                     p_function_code => 'POR_UPDATE_REQ',
                     p_parameter1    => to_char(l_document_id),
                     p_parameter11   => to_char(x_orgid) );

     -- Bug 636924, lpo, 03/31/98
     -- Added resubmit link.

     l_resubmit_req_url := por_util_pkg.jumpIntoFunction(
                     p_application_id=> 178,
                     p_function_code => 'POR_RESUBMIT_URL',
                     p_parameter1    => to_char(l_document_id),
                     p_parameter11   => to_char(x_orgid) );

     -- End of fix. Bug 636924, lpo, 03/31/98

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_URL' ,
                                 avalue     => l_open_req_url);

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_UPDATE_URL' ,
                                 avalue     => l_update_req_url);

     -- Bug 636924, lpo, 03/31/98
     -- Added resubmit workflow attribute.

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_RESUBMIT_URL' ,
                                 avalue     => l_resubmit_req_url);

     -- End of fix. Bug 636924, lpo, 03/31/98

     --Bug#3147435
     --Set the values for workflow attribute
     --VIEW_REQ_DTLS_URL and EDIT_REQ_URL

     l_view_req_dtls_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' ||
                            'porMode=viewReq' || '&' ||
                            'porReqHeaderId=' || to_char(l_document_id) || '&' ||
                            '_OrgId=' || to_char(x_orgid) || '&' ||
                            'addBreadCrumb=Y';

     l_edit_req_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' ||
                       'porMode=approverCheckout' || '&' ||
                       'porReqHeaderId=' || to_char(l_document_id) || '&' ||
                       '_OrgId=' || to_char(x_orgid);

     l_resubmit_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' ||
                       'porMode=resubmitReq' || '&' ||
                       'porReqHeaderId=' || to_char(l_document_id) || '&' ||
                       '_OrgId=' || to_char(x_orgid);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'VIEW_REQ_DTLS_URL',
                                      avalue     => l_view_req_dtls_url);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'EDIT_REQ_URL',
                                      avalue     => l_edit_req_url);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'RESUBMIT_REQ_URL',
                                      avalue     => l_resubmit_url);

     l_interface_source := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

     l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     SELECT CAN_APPROVER_MODIFY_DOC_FLAG
       INTO l_can_modify_flag
       FROM po_document_types
      WHERE DOCUMENT_TYPE_CODE = l_document_type
        AND DOCUMENT_SUBTYPE = l_doc_subtype;

     -- Not showing the open form icon if this is an IP req and owner can't
     -- modify.

     if l_can_modify_flag = 'N' and l_interface_source = 'POR' then

        wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'OPEN_FORM_COMMAND' ,
                              avalue     => '');
     end if;

  END IF;

  /* Set the Subject of the Approval notification initially to
  ** "requires your approval". If the user enters an invalid forward-to
  ** then this messages gets nulled-out and the "Invalid Forward-to"
  ** message gets a value (see notification: Approve Requisition).
  */
  fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
  l_error_msg := fnd_message.get;

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'REQUIRES_APPROVAL_MSG' ,
                              avalue     => l_error_msg);

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'WRONG_FORWARD_TO_MSG' ,
                              avalue     => '');

  /* Get the orignial authorization status from the document
  ** This has to be done here as we set the document status to
  ** IN-PROCESS after this.
  */

  IF l_document_type='REQUISITION' THEN

     select AUTHORIZATION_STATUS
     into l_authorization_status
     from po_requisition_headers_all
     where REQUISITION_HEADER_ID = l_document_id;

/* Bug#1810322: kagarwal
** Desc: If the original authorization status is IN PROCESS or PRE-APPROVED
** for Reqs then we need to store INCOMPLETE as the original authorization
** status.
*/

     IF l_authorization_status IN ('IN PROCESS', 'PRE-APPROVED') THEN
	l_authorization_status := 'INCOMPLETE';
     END IF;

  ELSIF l_document_type IN ('PO','PA') THEN

     select AUTHORIZATION_STATUS, NVL(REVISION_NUM,0)
     into l_authorization_status, l_po_revision
     from po_headers_all
     where PO_HEADER_ID = l_document_id;

/* Bug#1810322: kagarwal
** Desc: If the original authorization status is IN PROCESS or PRE-APPROVED
** for PO/Releases then we need to store REQUIRES REAPPROVAL as the original
** authorization status if the revision number is greater than 0 else
** INCOMPLETE.
*/

     IF l_authorization_status IN ('IN PROCESS', 'PRE-APPROVED') THEN
	IF l_po_revision > 0 THEN
		l_authorization_status := 'REQUIRES REAPPROVAL';
        ELSE
		l_authorization_status := 'INCOMPLETE';
	END IF;
     END IF;

  ELSIF l_document_type = 'RELEASE' THEN

      select AUTHORIZATION_STATUS, NVL(REVISION_NUM,0)
      into l_authorization_status, l_po_revision
      from po_releases_all
      where  PO_RELEASE_ID = l_document_id;

      IF l_authorization_status IN ('IN PROCESS', 'PRE-APPROVED') THEN
        IF l_po_revision > 0 THEN
                l_authorization_status := 'REQUIRES REAPPROVAL';
        ELSE
                l_authorization_status := 'INCOMPLETE';
        END IF;
     END IF;

  END IF;

  /* Set the doc authorization_status into original_autorization_status */

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                             itemkey    => itemkey,
                             aname      => 'ORIG_AUTH_STATUS' ,
                             avalue     => l_authorization_status);


  /* Set PLSQL document attribute */

  if l_document_type='REQUISITION' then

/* bug 2480327 notification UI enhancement
   add  &#NID to PLSQL document attributes
 */

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_REQ_APPROVE_MSG',
                              avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_APPROVE_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PO_REQ_APPROVED_MSG',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_APPROVED_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PO_REQ_NO_APPROVER_MSG',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_NO_APPROVER_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'PO_REQ_REJECT_MSG',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_PO_REQ_REJECT_MSG/'||
                         itemtype||':'||
                         itemkey||':'||
                         '&'||'#NID');

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REQ_LINES_DETAILS',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_REQ_LINES_DETAILS/'||
                         itemtype||':'||
                         itemkey);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'ACTION_HISTORY',
                            avalue   =>
                         'PLSQL:PO_WF_REQ_NOTIFICATION.GET_ACTION_HISTORY/'||
                         itemtype||':'||
                         itemkey);

  elsif l_document_type IN ('PO', 'PA', 'RELEASE') then

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_APPROVE_MSG',
                              avalue   => 'PLSQL:PO_WF_PO_NOTIFICATION.GET_PO_APPROVE_MSG/' ||
                         			itemtype || ':' || itemkey);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'PO_LINES_DETAILS',
                              avalue   => 'PLSQLCLOB:PO_WF_PO_NOTIFICATION.GET_PO_LINES_DETAILS/'|| -- <BUG 6932794>
                         			itemtype||':'|| itemkey);

    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'ACTION_HISTORY',
                              avalue   => 'PLSQL:PO_WF_PO_NOTIFICATION.GET_ACTION_HISTORY/'||
                         			itemtype||':'|| itemkey);

  end if;
--Bug 6027642
  l_external_url := fnd_profile.value('POS_EXTERNAL_URL');

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
 	                                    itemkey  => itemkey,
 	                                    aname    => '#WFM_HTMLAGENT',
 	                                    avalue   => l_external_url);
--Bug 6027642

  --
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Set_Startup_Values: 03'||
                'Open Form Command= ' || l_open_form;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Set_Startup_Values',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_STARTUP_VALUES',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Set_Startup_Values;


--
-- Get_Req_Attributes
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure Get_Req_Attributes(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_requisition_header_id NUMBER;
l_authorization_status varchar2(25);
l_orgid                number;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Get_Req_Attributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2377333
  ** Setting application context
  */

  -- bug 4556437 : context setting no longer required here
  --PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);


  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  l_requisition_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  GetReqAttributes(l_requisition_header_id,itemtype,itemkey);

     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --
  x_progress := 'PO_REQAPPROVAL_INIT1.Get_Req_Attributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Get_Req_Attributes',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.GET_REQ_ATTRIBUTES',l_requisition_header_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Get_Req_Attributes;

-- set_doc_stat_preapproved
-- Added for WR4
procedure set_doc_stat_preapproved(itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out NOCOPY varchar2    ) is

-- Bug 3326847: Change l_requisition_header_id to l_doc__header_id
--              This is because the PO Approval WF will now call this as code as well.
l_doc_header_id         NUMBER;
l_po_header_id          NUMBER;
l_doc_type              VARCHAR2(14);
l_authorization_stat    VARCHAR2(25);
l_note                  VARCHAR2(4000);
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_preapproved: 01';
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  -- Bug 3326847: Change l_requisition_header_id to l_doc_header_id
  l_doc_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_authorization_stat := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AUTHORIZATION_STATUS');

  l_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     IF l_doc_type = 'REQUISITION' THEN

        -- Bug 3326847: Change l_requisition_header_id to l_doc_header_id
        SetReqAuthStat(l_doc_header_id, itemtype,itemkey,l_note, 'PRE-APPROVED');

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTHORIZATION_STATUS',
                                    avalue    =>  'PRE-APPROVED');


     ELSIF l_doc_type IN ('PO', 'PA') THEN

        -- Bug 3327847: Added code to set POs to 'PRE-APPROVED' status.

        SetPOAuthStat(l_doc_header_id, itemtype, itemkey, l_note, 'PRE-APPROVED');

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTHORIZATION_STATUS',
                                    avalue    =>  'PRE-APPROVED');

     ELSIF l_doc_type = 'RELEASE' THEN

        -- Bug 3327847: Added code to set Releases to 'PRE-APPROVED' status.

        SetRelAuthStat(l_doc_header_id, itemtype, itemkey, l_note, 'PRE-APPROVED');

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AUTHORIZATION_STATUS',
                                    avalue    =>  'PRE-APPROVED');

     END IF;
     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','set_doc_stat_preapproved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_DOC_STAT_PREAPPROVED',l_doc_header_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END set_doc_stat_preapproved;


-- set_doc_stat_inprocess
--  Set the Doc status to In process and update the Doc Header table with the Itemtype
--  and Itemkey indicating that this doc has been submitted to workflow.
--
procedure set_doc_stat_inprocess(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_id           NUMBER;
l_doc_type              VARCHAR2(14);
l_authorization_stat    VARCHAR2(25);
l_note                  VARCHAR2(4000);
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_authorization_stat := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AUTHORIZATION_STATUS');

  l_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  /* If the Doc is INCOMPLETE or REJECTED (not IN PROCESS or PRE-APPROVED), then
  ** we want to set it to IN PROCESS and update the ITEMTYPE/ITEMKEY columns.
  ** If this is an upgrade to R11, then we need to update the ITEMTYPE/ITEMKEY columns
  ** Note that we only pickup docs is IN PROCESS or PRE-APPROVED in the upgrade step.
  */
  IF   ( NVL(l_authorization_stat, 'INCOMPLETE') NOT IN ('IN PROCESS', 'PRE-APPROVED') )
     OR
       ( l_note = 'UPGRADE_TO_R11' )  THEN

     IF l_doc_type = 'REQUISITION' THEN

        SetReqAuthStat(l_document_id, itemtype,itemkey,l_note, 'IN PROCESS');

     ELSIF l_doc_type IN ('PO', 'PA') THEN

        SetPOAuthStat(l_document_id, itemtype,itemkey,l_note,  'IN PROCESS');

     ELSIF l_doc_type = 'RELEASE' THEN

        SetRelAuthStat(l_document_id, itemtype,itemkey,l_note,  'IN PROCESS');

     END IF;

     wf_engine.SetItemAttrText ( itemtype  => itemtype,
                              itemkey   => itemkey,
                              aname     => 'AUTHORIZATION_STATUS',
                              avalue    => 'IN PROCESS' );



  END IF;

     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_stat_inprocess: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','set_doc_stat_inprocess',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_DOC_STAT_INPROCESS',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END set_doc_stat_inprocess;

--
procedure set_doc_to_originalstat(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_orig_auth_stat        VARCHAR2(25);
l_auth_stat             VARCHAR2(25);
l_requisition_header_id NUMBER;
l_po_header_id          NUMBER;
l_doc_id                NUMBER;
l_doc_type              VARCHAR2(14);
l_doc_subtype           VARCHAR2(25);
l_orgid                 NUMBER;
x_progress              varchar2(200);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_to_originalstat: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  l_orig_auth_stat := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORIG_AUTH_STATUS');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText(itemtype => itemtype,
                                             itemkey => itemkey,
					     aname   => 'DOCUMENT_SUBTYPE');

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  /* If the doc is APPROVED then don't reset the status. We should
  ** not run into this case. But this is to prevent any problems
  */
  IF l_doc_type = 'REQUISITION' THEN

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = l_doc_id;

     IF l_auth_stat <> 'APPROVED' THEN
        SetReqAuthStat(l_doc_id, itemtype,itemkey,NULL, l_orig_auth_stat);
     END IF;

  ELSIF l_doc_type IN ('PO', 'PA') THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_HEADERS
      where po_header_id = l_doc_id;

      IF l_auth_stat <> 'APPROVED' THEN
         SetPOAuthStat(l_doc_id, itemtype,itemkey,NULL, l_orig_auth_stat );
      END IF;

  ELSIF l_doc_type = 'RELEASE' THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_RELEASES
      where po_release_id = l_doc_id;

      IF l_auth_stat <> 'APPROVED' THEN
         SetRelAuthStat(l_doc_id, itemtype,itemkey,NULL, l_orig_auth_stat );
      END IF;

  END IF;

  IF l_auth_stat <> 'APPROVED' THEN

    wf_engine.SetItemAttrText ( itemtype  => itemtype,
                              itemkey   => itemkey,
                              aname     => 'AUTHORIZATION_STATUS',
                              avalue    => l_orig_auth_stat);

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_to_originalstat: 02' ||
                ' Auth_status= ' || l_auth_stat || ', Orig_auth_stat= ' || l_orig_auth_stat;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


     -- Bug 3845048: Added the code to update the action history with 'no action'
     -- so that the action history code is completed properly when the document
     -- is returned to the submitter, in case of no approver found or time out

     x_progress := 'PO_REQAPPROVAL_INIT1.set_doc_to_originalstat: 03' || 'Update Action History'
                    || 'Action Code = No Action';
     IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;
     /* This was added for bug 3845048.
        As part of fix 5383646 moving this code to prior location in approval wf.
     UpdateActionHistory(p_doc_id      =>  l_doc_id,
                         p_doc_type    =>  l_doc_type,
                         p_doc_subtype =>  l_doc_subtype,
                         p_action      =>  'NO ACTION'
                        ) ;
     */
     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','set_doc_stat_inprocess',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.SET_DOC_STAT_INPROCESS',l_doc_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END set_doc_to_originalstat;

-- Register_doc_submitted
--
--   Update the DOC HEADER with the Workflow Itemtype and ItemKey
--
procedure Register_doc_submitted(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
l_doc_id                NUMBER;
l_doc_type              VARCHAR2(25);
l_authorization_stat    VARCHAR2(25);
l_orgid                 NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Register_doc_submitted: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

      fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  l_doc_id := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  IF l_doc_type = 'REQUISITION' THEN

      UpdtReqItemtype(itemtype,itemkey, l_doc_id);

  ELSIF l_doc_type IN ('PO', 'PA') THEN

      UpdtPOItemtype(itemtype,itemkey, l_doc_id );

  ELSIF l_doc_type = 'RELEASE' THEN

        UpdtRelItemtype(itemtype,itemkey, l_doc_id);

  END IF;


     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --

  x_progress := 'PO_REQAPPROVAL_INIT1.Register_doc_submitted: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Register_doc_submitted',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.REGISTER_DOC_SUBMITTED',l_doc_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Register_doc_submitted;

--
-- can_owner_approve
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure can_owner_approve(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_document_id   number;
l_orgid         number;
x_CanOwnerApproveFlag   VARCHAR2(1);
l_interface_source      VARCHAR2(30);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.can_owner_approve: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_interface_source := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

  /* For one time upgrade of notifications for the client, we want to
  ** follow a certain path in the workflow. We do not want to go through
  ** the VERIFY AUTHORITY path. Therefore, set the RESULT to N
  */
  IF NVL(l_interface_source,'X') = 'ONE_TIME_UPGRADE' THEN
    --
     resultout := wf_engine.eng_completed || ':' || 'N';
    --
  ELSE

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
    -- Set the multi-org context
    l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    IF l_orgid is NOT NULL THEN

      fnd_client_info.set_org_context(to_char(l_orgid));

    END IF;

    XX_PO_REQAPPROVAL_INIT1.GetCanOwnerApprove(itemtype, itemkey, x_CanOwnerApproveFlag);

    --
     resultout := wf_engine.eng_completed || ':' || x_CanOwnerApproveFlag ;
    --

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.can_owner_approve: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','can_owner_approve',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.CAN_OWNER_APPROVE',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END can_owner_approve;

--
-- Is_doc_preapproved
--   Is document status pre-approved
--
procedure Is_doc_preapproved(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_auth_stat varchar2(25);
l_doc_type  varchar2(25);
l_doc_id    number;
l_orgid     number;
x_progress              varchar2(200);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_doc_preapproved: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2353153
  ** Setting application context
  */

-- bug 4556437 : context setting no longer required here
  --PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  -- Bug 762194: Need to set multi-org context.

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;


  IF l_doc_type = 'REQUISITION' THEN

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = l_doc_id;

  ELSIF l_doc_type IN ('PO', 'PA') THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_HEADERS
      where po_header_id = l_doc_id;

  ELSIF l_doc_type = 'RELEASE' THEN

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_RELEASES
      where po_release_id = l_doc_id;

  END IF;


  IF l_auth_stat = 'PRE-APPROVED' THEN

  --
     resultout := wf_engine.eng_completed || ':' || 'Y' ;
  --

  ELSIF l_auth_stat = 'IN PROCESS' THEN
  --
     resultout := wf_engine.eng_completed || ':' || 'N' ;
  --

  ELSE
  -- The doc is either APPROVED, INCOMPLETE or REJECTED. This invalid, therefore
  -- we will exit the workflow with an INVALID ACTION status.
     resultout := wf_engine.eng_completed || ':' || 'INVALID_AUTH_STATUS' ;
  --

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_doc_preapproved: 02' ||
                ' Authorization_status= ' || l_auth_stat ;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_doc_preapproved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_DOC_PREAPPROVED',l_doc_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Is_doc_preapproved;


--
--
-- Ins_actionhist_submit
--   When we start the workflow, if the document status is NOT 'IN PROCESS' or
--   PRE-APPROVED, then insert a SUBMIT action row into PO_ACTION_HISTORY
--   to signal the submission of the document for approval.
--   Also, insert an additional row with a NULL ACTION_CODE (to simulate a
--   forward-to since the DOC status is IN PROCESS. The code in the DOC-MANAGER
--   looks for this row.
--
procedure Ins_actionhist_submit(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_note        PO_ACTION_HISTORY.note%TYPE;
l_employee_id number;
l_orgid       number;

x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

l_path_id number;

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Ins_actionhist_submit: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

/* Bug 1100247 Amitabh
** Desc:Initially the Workflow sets the preparer_id, approver_empid
**      as the value passed to it by the POXAPAPC.pld file. As it always
**      assumed that an Incomplete Requisition would get approved  by
**      preparer only. Then when it calls the GetReqAttributes()
**      it would reget the preparer_id from the po_requisition_headers_all
**      table hence if the preparer_id and approver_empid are different
**      then the action history would be wrongly updated.
**
**      Modifying the parameter l_employee_id to be passed to
**      InsertActionHistSubmit() from PREPARER_ID to
**      APPROVER_EMPID.
**
**      Also modified the SetReqHdrAttributes() to also set the
**      PREPARER_USER_NAME and PREPARER_DISPLAY_NAME.
**
*/

  l_employee_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');

  PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'SUBMITTER_ID',
                                    avalue   => l_employee_id);

  l_note := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  -- Set the multi-org context
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  l_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

  XX_PO_REQAPPROVAL_INIT1.InsertActionHistSubmit(itemtype,itemkey,l_doc_id, l_doc_type,
                                   l_doc_subtype, l_employee_id, 'SUBMIT', l_note, l_path_id);


  --
     resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
  --


  x_progress := 'PO_REQAPPROVAL_INIT1.Ins_actionhist_submit: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Ins_actionhist_submit',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.INS_ACTIONHIST_SUBMIT',l_doc_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Ins_actionhist_submit;

--
-- Set_End_VerifyDoc_Passed
--  Sets the value of the transition to PASSED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_End_VerifyDoc_Passed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

BEGIN


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  --
     resultout := wf_engine.eng_completed || ':' || 'PASSED_VERIFICATION' ;
  --

END Set_End_VerifyDoc_Passed;

--
-- Set_End_VerifyDoc_Passed
--  Sets the value of the transition to PASSED_VERIFICATION to match the
--  transition value for the VERIFY_REQUISITION Process
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Set_End_VerifyDoc_Failed(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  --
     resultout := wf_engine.eng_completed || ':' || 'FAILED_VERIFICATION' ;
  --

END Set_End_VerifyDoc_Failed;

--
-- Set_End_Valid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Valid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

x_progress  varchar2(100);
BEGIN

  --
     resultout := wf_engine.eng_completed || ':' || 'VALID_ACTION' ;
  --

  x_progress := 'PO_REQAPPROVAL_INIT1.Set_End_Valid_Action: RESULT=VALID_ACTION';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

END Set_End_Valid_Action;

--
-- Set_End_Invalid_Action
--  Sets the value of the transition to VALID_ACTION to match the
--  transition value for the APPROVE_REQUISITION, APPROVE_PO,
--  APPROVE_AND_FORWARD_REQUISITION and APPROVE_AND_FORWARD_PO Processes.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - VALID_ACTION
--
procedure Set_End_Invalid_Action(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

BEGIN

  --
     resultout := wf_engine.eng_completed || ':' || 'INVALID_ACTION' ;
  --

END Set_End_Invalid_Action;

--
-- Is_Interface_ReqImport
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   Is the calling module REQ IMPORT. If it is, then we need to RESERVE the doc.
--   Web Requisition come through REQ IMPORT.
procedure Is_Interface_ReqImport(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is

l_interface_source  varchar2(25);
BEGIN

  l_interface_source := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');

  IF l_interface_source <> 'PO_FORM' THEN

     --
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
     --
  ELSE
     --
        resultout := wf_engine.eng_completed || ':' || 'N' ;
     --
  END IF;

END Is_Interface_ReqImport;

--
-- Encumb_on_doc_unreserved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If Encumbrance is ON and Document is NOT reserved, then return Y.
--   We need to reserve the doc.

procedure Encumb_on_doc_unreserved(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2    ) is
l_document_type varchar2(25);
l_document_subtype varchar2(25) := NULL;
l_document_id   number;
l_orgid     number;

x_progress  varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
BEGIN


  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  -- <ENCUMBRANCE FPJ START>
  -- Get the subtype for doc type other than requisition

  if l_document_type <> 'REQUISITION' THEN

     l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');
  end if;

  -- <ENCUMBRANCE FPJ END>

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;


  IF ( EncumbOn_DocUnreserved(
               p_doc_type    => l_document_type,
               p_doc_subtype => l_document_subtype,
               p_doc_id      => l_document_id)
      = 'Y' ) THEN

     --
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved: 01';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  ELSE
     --
        resultout := wf_engine.eng_completed || ':' || 'N' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved: 02';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.ENCUMB_ON_DOC_UNRESERVED',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Encumb_on_doc_unreserved;

--
--
-- RESERVE_AT_COMPLETION_CHECK
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--   If the reserve at completion flag is checked, then return Y.

procedure RESERVE_AT_COMPLETION_CHECK(   itemtype        in varchar2,
                                         itemkey         in varchar2,
                                         actid           in number,
                                         funcmode        in varchar2,
                                         resultout       out NOCOPY varchar2    ) is

l_reserve_at_compl varchar2(1);
x_CanOwnerApproveFlag   varchar2(1);

x_progress  varchar2(100);
l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN

/* Bug# 2234341: kagarwal
** Desc: The preparer cannot reserve a requisiton at the start of the
** approval workflow, if the preparer cannot approve and also the reserve
** at completion is No.
** The logic that follows here is that the owner/preparer is also an
** approver, if the preparer can approve is allowed.
*/

   select nvl(fsp.reserve_at_completion_flag,'N') into l_reserve_at_compl
        from financials_system_parameters fsp;

  /* Bug 5249967
  ** This function that is called to verify if the requisition is
  ** to be reserved before approval, is now made independent of
  ** "Owner Can Approve" flag.
  */
  --PO_REQAPPROVAL_INIT1.GetCanOwnerApprove(itemtype, itemkey, x_CanOwnerApproveFlag);

  /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  IF (l_reserve_at_compl = 'N') THEN

     --
        resultout := wf_engine.eng_completed || ':' || 'N' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_commit: 01';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  ELSE
     --
        resultout := wf_engine.eng_completed || ':' || 'Y' ;
     --
     x_progress := 'PO_REQAPPROVAL_INIT1.Encumb_on_doc_commit: 02';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Encumb_on_doc_unreserved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.RESERVE_AT_COMPLETION_CHECK',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END RESERVE_AT_COMPLETION_CHECK;


-- Remove_reminder_notif
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Remove the reminder notifications since this doc is now approved.

procedure Remove_reminder_notif(   itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2 ) is

l_release_flag varchar2(1);
l_orgid        number;
l_document_type varchar2(25);
l_document_subtype varchar2(25);
l_document_id  number;
l_wf_item_key  varchar2(100);
x_progress     varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
/*Bug 6644393 */
x_act_status WF_ITEM_ACTIVITY_STATUSES.ACTIVITY_STATUS%TYPE;
 x_result     varchar2(30);
/*Bug 6644393 */
cursor po_cursor(p_header_id number) is
select wf_item_key
from po_headers
where po_header_id= p_header_id;

cursor req_cursor(p_header_id number) is
select wf_item_key
from po_requisition_headers
where requisition_header_id= p_header_id;

cursor rel_cursor(p_header_id number) is
select wf_item_key
from po_releases
where po_release_id= p_header_id;

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Remove_reminder_notif: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;
/* Bug #: 1384323 draising
   Forward fix of Bug # 1338325
   We need to set multi org context by getting it from the
   database rather rather than the org id attribute.
*/

/*
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;
*/
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

       PO_REQAPPROVAL_INIT1.get_multiorg_context(l_document_type,l_document_id,l_orgid);

   IF l_orgid is NOT NULL THEN
      fnd_client_info.set_org_context(to_char(l_orgid));
       wf_engine.SetItemAttrNumber (itemtype => itemtype ,
                                    itemkey  => itemkey ,
                                    aname    => 'ORG_ID' ,
                                    avalue  => l_orgid );
  END IF;

/* End of fix for Bug # 1384323 */
 IF l_document_type = 'RELEASE' THEN

    l_release_flag := 'Y';

 ELSE

   l_release_flag := 'N';

 END IF;

 /* Remove reminder notifications */
 PO_APPROVAL_REMINDER_SV. Cancel_Notif ( l_document_subtype,
                                         l_document_id,
                                         l_release_flag);

 /* If the document has been previously submitted to workflow, and did not
 ** complete because of some error or some action such as Document being rejected,
 ** then notifications may have been  issued to users.
 ** We need to remove those notifications once we submit the document to a
 ** new workflow run, so that the user is not confused.
 */

  IF l_document_type='REQUISITION' THEN

    open req_cursor(l_document_id);
    fetch req_cursor into l_wf_item_key;
    close req_cursor;

  ELSIF l_document_type IN ('PO','PA') THEN

    open po_cursor(l_document_id);
    fetch po_cursor into l_wf_item_key;
    close po_cursor;

  ELSIF l_document_type = 'RELEASE' THEN

    open rel_cursor(l_document_id);
    fetch rel_cursor into l_wf_item_key;
    close rel_cursor;

  END IF;

  IF l_wf_item_key is NOT NULL THEN

    Close_Old_Notif(itemtype, l_wf_item_key);

  END IF;

  resultout := wf_engine.eng_completed ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Remove_reminder_notif: 02.';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

/*Bug6644393 Duplicate PO acceptances are recorded from ISP when
 PDF is the communication method.The notifications are even
 sent for the previous revision PO approval process after this
 process completes.hence aborting the previous revision po approval
 workflow process */

  if((l_document_type IN ('PO','PA','RELEASE')) and
      (l_wf_item_key is NOT NULL and (l_wf_item_key <> itemkey)) )THEN
          BEGIN
	   wf_engine.itemstatus (itemtype   => itemtype,
                                 itemkey       => l_wf_item_key,
                                 status        => x_act_status,
                                 RESULT        => x_result
                                );
	   EXCEPTION
	   WHEN OTHERS THEN
	   x_act_status:= NULL;
	   END;

          if x_act_status not in ('COMPLETE', 'ERROR') then
	   WF_Engine.AbortProcess(itemtype,l_wf_item_key);
	  end if;

   end if;   --doc type
 /*Bug6644393	end*/
EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Remove_reminder_notif',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.REMOVE_REMINDER_NOTIF',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Remove_reminder_notif;


procedure Print_Doc_Yes_No(   itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_print_doc   varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */


BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_print_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PRINT_DOCUMENT');

   /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  /* the value of l_print_doc should be Y or N */
  IF (nvl(l_print_doc,'N') <> 'Y') THEN
	l_print_doc := 'N';
  END IF;

  --
        resultout := wf_engine.eng_completed || ':' || l_print_doc ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No: 02. Result= ' || l_print_doc;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Print_Doc_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.PRINT_DOC_YES_NO',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Print_Doc_Yes_No;




-- DKC 10/10/99
procedure Fax_Doc_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_fax_doc     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_fax_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FAX_DOCUMENT');

   /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  /* the value of l_fax_doc should be Y or N */
  IF (nvl(l_fax_doc,'N') <> 'Y') THEN
	l_fax_doc := 'N';
  END IF;

  --
        resultout := wf_engine.eng_completed || ':' || l_fax_doc ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No: 02. Result= ' || l_fax_doc;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Fax_Doc_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.FAX_DOC_YES_NO',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Fax_Doc_Yes_No;

--SR-ASL FPH --
procedure Create_SR_ASL_Yes_No( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_create_sr_asl     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
l_document_type PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

l_resp_id     number;
l_user_id     number;
l_appl_id     number;

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Create_SR_ASL_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');


  l_user_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'USER_ID');

  l_resp_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSIBILITY_ID');

  l_appl_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPLICATION_ID');

  /* Since the call may be started from background engine (new seesion),
   * need to ensure the fnd context is correct
   */

  /* bug 4556437 : context setting revamp : Not required anymore since
     selector/ notification callback fns take care of context settings
  if (l_user_id is not null and
      l_resp_id is not null and
      l_appl_id is not null )then
  --
  -- Bug 4125251,replaced apps init call with set doc mgr contxt
  --
  PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);
  */

	IF l_orgid is NOT NULL THEN
		fnd_client_info.set_org_context(to_char(l_orgid));
	END IF;

  --end if;



  l_create_sr_asl := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CREATE_SOURCING_RULE');
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_TYPE');
  l_document_subtype := wf_engine.GetItemAttrText (itemtype =>itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_SUBTYPE');

  /* the value of CREATE_SOURCING_RULE should be Y or N */
  IF (nvl(l_create_sr_asl,'N') <> 'Y') THEN
    l_create_sr_asl := 'N';
  ELSE
    if l_document_type = 'PA'  then
      if l_document_subtype = 'BLANKET' then
        l_create_sr_asl := 'Y';
      else
        l_create_sr_asl := 'N';
      end if;
    else
        l_create_sr_asl := 'N';
    end if;
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_create_sr_asl;

  x_progress := 'PO_REQAPPROVAL_INIT1.Create_SR_ASL_Yes_No: 02. Result= ' || l_create_sr_asl;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  l_create_sr_asl := 'N';
    resultout := wf_engine.eng_completed || ':' || l_create_sr_asl;
END Create_SR_ASL_Yes_No;






-- DKC 10/10/99
procedure Send_WS_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_send_notif     varchar2(2);
x_progress    varchar2(300);


l_document_type varchar2(25);
l_document_subtype po_document_types.document_subtype%type;
l_document_id  number;
l_notifier varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Send_Notification_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, l_notifier);


  if (l_notifier is not null) then
	l_send_notif := 'Y';
	--Bug#2843760: Call ARCHIVE_PO whenever notification is sent to supplier
	ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);

	wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_NOTIF_PERFORMER',
				   avalue   => l_notifier);
   else
	l_send_notif := 'N';
   end if;


   resultout := wf_engine.eng_completed || ':' || l_send_notif ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Send_Notification_Yes_No: 02. Result= ' || l_send_notif;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Send_Notification_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.FAX_DOC_YES_NO',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Send_WS_Notif_Yes_No;


/*
< Added this procedure as part of Bug #: 2810150 >
*/
procedure Send_WS_FYI_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_send_notif     varchar2(2);
x_progress    varchar2(300);


l_document_type varchar2(25);
l_document_subtype po_document_types.document_subtype%type;
l_document_id  number;
l_notifier varchar2(100);
l_notifier_resp varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122

-- BINDING FPJ
l_acceptance_flag   PO_HEADERS_ALL.acceptance_required_flag%TYPE;

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

-- BINDING FPJ START

    IF ((l_document_type <> 'RELEASE') AND
       l_document_subtype IN ('STANDARD','BLANKET','CONTRACT')) THEN
        SELECT acceptance_required_flag
		  INTO l_acceptance_flag
		  FROM po_headers_all
		 WHERE po_header_Id = l_document_id;

        IF l_acceptance_flag = 'S' THEN
            PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, 'Y', l_notifier, l_notifier_resp);
        ELSE
            PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, 'N', l_notifier, l_notifier_resp);
        END IF;
    ELSE
-- BINDING FPJ END
        PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_document_type, 'N', l_notifier, l_notifier_resp);
    END IF;


  if (l_notifier is not null) then
	l_send_notif := 'Y';
	--Bug#2843760: Call ARCHIVE_PO whenever notification is sent to supplier
	ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);

	wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_NOTIF_PERFORMER',
				   avalue   => l_notifier);
   else
	l_send_notif := 'N';
   end if;

	wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_ACK_NOTIF_PERFORMER',
				   avalue   => l_notifier_resp);

   resultout := wf_engine.eng_completed || ':' || l_send_notif ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No: 02. Result= ' || l_send_notif;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.Send_WS_FYI_Notif_Yes_No',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Send_WS_FYI_Notif_Yes_No;



/*
< Added this procedure as part of Bug #: 2810150 >
*/
procedure Send_WS_ACK_Notif_Yes_No(     itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_send_notif     varchar2(2);
x_progress    varchar2(300);


l_document_type varchar2(25);
l_document_subtype po_document_types.document_subtype%type;
l_document_id  number;
l_notifier varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_notifier:=wf_engine.GetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PO_WF_ACK_NOTIF_PERFORMER');

  if (l_notifier is not null) then
	--Bug#2843760: Call ARCHIVE_PO whenever notification is sent to supplier
	ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);
	l_send_notif := 'Y';
   else
	l_send_notif := 'N';
   end if;


   resultout := wf_engine.eng_completed || ':' || l_send_notif ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No: 02. Result= ' || l_send_notif;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.Send_WS_ACK_Notif_Yes_No',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Send_WS_ACK_Notif_Yes_No;


/*
  For the given document_id ( ie. po_header_id ), this procedure
  tries to find out the correct users that need to be sent the
  notifications.

  This procedure assumes that all the supplier users related to this
  document need to be sent the notification.

  Returns the role containing all the users in the "resultout" variable
*/
procedure  locate_notifier(document_id    in      varchar2,
                                 document_type   in     varchar2,
                                 resultout      in out NOCOPY  varchar2) IS
l_role_with_resp varchar2(1000);
l_notify_only_flag varchar2(10);
BEGIN
    l_notify_only_flag := 'Y';
    locate_notifier(document_id, document_type, l_notify_only_flag, resultout, l_role_with_resp);
END;


/*******************************************************************
  < Added this procedure as part of Bug #: 2810150 >
  PROCEDURE NAME: locate_notifier

  DESCRIPTION   :
  For the given document_id ( ie. po_header_id ), this procedure
  tries to find out the correct users that need to be sent the
  notifications.

  Referenced by : Workflow procedures
  parameters    :
   Input:
    document_id - the document id
    document_type - Document type
    p_notify_only_flag -
        The values can be 'Y' or 'N'
        'Y' means: The procedure will return all the users that are supplier users related to the document.
        Returns the role containing all the users in the "x_resultout" variable

        'N' means: we want users that need to be sent FYI and also the users with resp.
            x_resultout: will have the role for the users that need to be sent the FYI
            x_role_with_resp: will have the role for users having the fucntion "POS_ACK_ORDER" assigned to
            them.

   Output:
    x_resultout - Role for the users that need to be sent FYI
    x_role_with_resp - Role for the users who have the ability to acknowledge.

  CHANGE History: Created      27-Feb-2003    jpasala
                  modified     10-JUL-2003    sahegde
*******************************************************************/

procedure locate_notifier (p_document_id      in  varchar2,
                           p_document_type    in  varchar2,
                           p_notify_only_flag in  varchar2,
                           x_resultout        in  out NOCOPY  varchar2,
                           x_role_with_resp   in  out NOCOPY  VARCHAR2) IS
/*CONERMS FPJ START*/
-- declare local variables to hold output of get_supplier_userlist call
l_supplier_user_tbl    po_vendors_grp.external_user_tbl_type;
l_namelist             varchar2(31990):=null;
l_namelist_for_sql     varchar2(32000):=null;
l_num_users            number := 0;
l_vendor_id            NUMBER;
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER := 0;
l_msg_data             VARCHAR2(2000);
/*CONERMS FPJ END*/

-- local variables for role creation
l_role_name            WF_USER_ROLES.ROLE_NAME%TYPE;
l_role_display_name    varchar2(100):=null;
l_temp                 varchar2(100);
l_expiration_date      DATE;
l_count                number;
l_select               boolean;
l_refcur1              g_refcur;
l_users_with_resp      varchar2(32000);
l_step                 varchar2(32000) := '0';
l_diff_users_for_sql   varchar2(32000);
l_user_count_with_resp number:=0;
l_fyi_user_count       number:=0;
l_users                WF_DIRECTORY.UserTable;

BEGIN
l_num_users := 0;
l_step := '0';

/* CONTERMS FPJ START */
-- The code to create the user list has been sliced into another procedure
-- called po_vendors_grp.get_external_userlist. This procedure now makes a
-- call to it to retrieve, comma and space delimited userlist, and number
-- of users, supplier list in a table and vendor id.
/*po_doc_utl_pvt.get_supplier_userlist(p_document_id => p_document_id
,p_document_type             => p_document_type
,x_return_status             => l_return_status
,x_supplier_user_tbl         => l_supplier_user_tbl
,x_supplier_userlist         => l_namelist
,x_supplier_userlist_for_sql => l_namelist_for_sql
,x_num_users                 => l_num_users
,x_vendor_id                 => l_vendor_id);*/

--bug4028805 Start
--Change '1.0' to 1.0 as p_api_version should be a NUMBER.
--bug4028805 End
po_vendors_grp.get_external_userlist
(p_api_version               => 1.0            --bug4028805
,p_init_msg_list             => FND_API.G_FALSE
,p_document_id               => p_document_id
,p_document_type             => p_document_type
,x_return_status             => l_return_status
,x_msg_count                 => l_msg_count
,x_msg_data                  => l_msg_data
,x_external_user_tbl         => l_supplier_user_tbl
,x_supplier_userlist         => l_namelist
,x_supplier_userlist_for_sql => l_namelist_for_sql
,x_num_users                 => l_num_users
,x_vendor_id                 => l_vendor_id);

l_step := '0'||l_namelist;
-- proceed if return status is success
IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
  l_step := '4'|| l_namelist;
  if(l_namelist is null) then
    x_resultout := null;
  else
    if (p_document_type in ('PO', 'PA')) then
      select max(need_by_date)+180
      into l_expiration_date
      from po_line_locations
      where po_header_id = to_number(p_document_id)
      and cancel_flag = 'N';

      if l_expiration_date <= sysdate then
        l_expiration_date := sysdate + 180;
      end if;
    elsif (p_document_type = 'RELEASE') then
      select max(need_by_date)+180
      into l_expiration_date
      from po_line_locations
      where po_release_id = to_number(p_document_id)
      and cancel_flag = 'N';

      if l_expiration_date <= sysdate then
        l_expiration_date := sysdate + 180;
      end if;
    else
      l_expiration_date:=null;
    end if;
    begin
      select vendor_name
      into l_role_display_name
      from po_vendors
      where vendor_id=l_vendor_id;
    exception
    when others then
      l_role_display_name:=' ';
    end;

    IF p_notify_only_flag = 'Y' THEN
      l_role_name:= get_wf_role_for_users(l_namelist_for_sql, l_num_users ) ;
    ELSE
      -- get the list of users with the given resp from the current set of users
      l_step := '6';
      get_user_list_with_resp( get_function_id('POS_ACK_ORDER'),
                               l_namelist_for_sql,
			       l_namelist,
			       l_users_with_resp,
			       l_user_count_with_resp);

      IF ( l_user_count_with_resp > 0 ) then
        l_step := '7 : '|| l_user_count_with_resp;
        x_role_with_resp := get_wf_role_for_users(l_users_with_resp, l_user_count_with_resp ) ;
        if(x_role_with_resp is null ) then
          /*For Bug 5956252,l_namelist is the same as l_users_with_resp.l_namelist is delimited by spaces
          l_users_with_resp is delimited by commas */

          if (l_users_with_resp is NOT NULL) then
            string_to_userTable(l_users_with_resp, l_users);
          end if;
          x_role_with_resp:=substr('ADHOCR' || to_char(sysdate, 'JSSSSS')|| p_document_id || p_document_type, 1, 30);
          l_step := '17'|| x_role_with_resp ;
          WF_DIRECTORY.CreateAdHocRole2(x_role_with_resp,
	                                l_role_display_name ,
                                        null,
                                        null,
                                        null,
                                        'MAILHTML',
                                        l_users,
                                        null,
                                        null,
                                        'ACTIVE',
                                        l_expiration_date);
        end if;
      ELSE
        x_role_with_resp := null;
      END IF;

      l_fyi_user_count := l_num_users - l_user_count_with_resp;

      if ( l_fyi_user_count =0  ) then
        /*  x_resultout := x_role_with_resp; JAI */
        /* Bug 5087421 */
        x_resultout := null;
        return;
      end if;

      l_step := '10: ' ;
      if ( l_user_count_with_resp > 0 ) then
        get_diff_in_user_list ( l_namelist_for_sql,
	                        l_users_with_resp ,
                                l_namelist ,
				l_diff_users_for_sql,
				l_fyi_user_count);
      else
        l_diff_users_for_sql:= l_namelist_for_sql;
        l_fyi_user_count := l_num_users;
      end if;
      l_step := '11: count='||l_fyi_user_count ;
      l_role_name := get_wf_role_for_users(l_diff_users_for_sql, l_fyi_user_count ) ;
    END IF; -- End of notify flag check

    if (l_role_name is null ) then
      l_step := '17'|| l_role_name;
      /* Bug 2966804 START */
      /* We need to give a role name before creating an ADHOC role. */

      l_role_name := substr('ADHOC' || to_char(sysdate, 'JSSSSS')|| p_document_id || p_document_type, 1, 30);

      /* Bug 2966804 END */
      /* Bug 5956252,l_diff_users_for_sql is the same as l_namelist.l_namelist is delimited by spaces
         whereas l_diff_users_for_sql is delimited by commas*/
      -- Bug 7203740 - Start
      /* If l_diff_users_for_sql is null then a role was created with '0' users
         even though there are users. */
      if (l_diff_users_for_sql IS NULL) then
        l_diff_users_for_sql:= l_namelist_for_sql;
      end if;
      -- Bug 7203740 - End

      if (l_diff_users_for_sql is NOT NULL) then
        string_to_userTable(l_diff_users_for_sql, l_users);
      end if;
      WF_DIRECTORY.CreateAdHocRole2(l_role_name,
                                    l_role_display_name ,
                                    null,
                                    null,
                                    null,
                                    'MAILHTML',
                                    l_users,
                                    null,
                                    null,
                                    'ACTIVE',
                                    l_expiration_date);
      x_resultout:=l_role_name;
    else
      l_step := '11'|| l_role_name;
      x_resultout:= l_role_name;
    end if;
  end if;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1.locate_notifier failed at:',l_step);
    wf_core.context('PO_REQAPPROVAL_INIT1.locate_notifier',l_role_name||sqlerrm);
    --raise_application_error(-20001,'l_role_name ='||l_role_name ||' and l_step='||l_step ||' and l_list='||l_namelist_for_sql, true);
end locate_notifier;

-- DKC 02/06/01
procedure Email_Doc_Yes_No(   itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
l_orgid       number;
l_email_doc     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122

l_document_type varchar2(25);
l_document_subtype varchar2(25);
l_document_id 	number;
l_po_header_id 	number;
l_vendor_site_code varchar2(15);
l_vendor_site_id number;
--EMAILPO FPH START--
l_vendor_site_lang PO_VENDOR_SITES.LANGUAGE%TYPE;
l_adhocuser_lang WF_LANGUAGES.NLS_LANGUAGE%TYPE;
l_adhocuser_territory WF_LANGUAGES.NLS_TERRITORY%TYPE;
--EMAILPO FPH START--
     /* Bug 2989951 Increased the width of the following variables */
l_po_email_performer  WF_USERS.name%TYPE;
l_po_email_add        WF_USERS.EMAIL_ADDRESS%TYPE;
l_display_name	      WF_USERS.display_name%TYPE;
l_po_email_performer_prof WF_USERS.name%TYPE;
l_po_email_add_prof	  WF_USERS.EMAIL_ADDRESS%TYPE;
l_display_name_prof	  WF_USERS.display_name%TYPE;
l_performer_exists number;
l_notification_preference varchar2(20) := 'MAILHTM2'; -- Bug 3788367
l_when_to_archive varchar2(80);
l_archive_result varchar2(2);

/* Bug 6904194 */
l_note fnd_new_messages.message_text%TYPE;
/* End Bug 6904194 */

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug 2687751.
   * For blankets, the org context was not getting set and hence
   * sql query which selecs vendor_site_id below from po_vendor_sites
   * was throwing an exception. Hence setting the org context here.
  */
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  x_progress := '001';
  -- Create the attribute email document
  l_email_doc := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_DOCUMENT');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  -- the value of l_email_doc should be Y or N
  IF (nvl(l_email_doc,'N') <> 'Y') THEN
	l_email_doc := 'N';
  END IF;


  -- Here, we are creating an entry in wf_local_users and assigning that to the email performer
  IF (l_email_doc = 'Y') THEN


     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_po_email_add := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_ADDRESS');

     l_po_email_add_prof :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_ADD_FROM_PROFILE');


     if (l_document_type in ('PO', 'PA')) then
	l_po_header_id := l_document_id;

     elsif (l_document_type = 'RELEASE') then
	select po_header_id into l_po_header_id
	from po_releases
	where po_release_id = l_document_id;

     else
	null;
     end if;

     x_progress := '002';

	--EMAILPO FPH--
	--also retrieve language to set the adhocuser language to supplier site preferred language
	select poh.vendor_site_id, pvs.vendor_site_code, pvs.language
	into l_vendor_site_id, l_vendor_site_code, l_vendor_site_lang
	from po_headers poh, po_vendor_sites pvs
	where pvs.vendor_site_id = poh.vendor_site_id
	and poh.po_header_id = 	l_po_header_id;

     /* Bug 2989951
     l_po_email_performer := l_vendor_site_code || substr(l_vendor_site_id, 1, 15);
     l_display_name := l_vendor_site_code || substr(l_vendor_site_id, 1, 15); */

	--EMAILPO FPH START--
	IF l_vendor_site_lang is  NOT NULL then
		SELECT wfl.nls_language, wfl.nls_territory INTO l_adhocuser_lang, l_adhocuser_territory
		FROM wf_languages wfl, fnd_languages_vl flv
		WHERE wfl.code = flv.language_code AND flv.nls_language = l_vendor_site_lang;
	ELSE
		SELECT wfl.nls_language, wfl.nls_territory into l_adhocuser_lang, l_adhocuser_territory
		FROM wf_languages wfl, fnd_languages_vl flv
		WHERE wfl.code = flv.language_code AND flv.installed_flag = 'B';
	END IF;
	--EMAILPO FPH END--

    /* Bug 6904194 */
    /* The Message sent to Supplier should be in Supplier Language if
    Suppliers language is different from Buyers language */

	IF l_vendor_site_lang is  NOT NULL then
        BEGIN
        -- SQL What : Get the message in the Supliers language.
          SELECT message_text
           INTO l_note
           FROM fnd_new_messages fm,
                fnd_languages fl
           WHERE fm.message_name = 'PO_PDF_EMAIL_TEXT'
             AND fm.language_code = fl.language_code
             AND fl.nls_language = l_vendor_site_lang;
        EXCEPTION
           WHEN OTHERS THEN
              NULL;
        END;

        PO_WF_UTIL_PKG.SetItemAttrText(	itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname => 'EMAIL_TEXT_WITH_PDF',
                                        avalue => l_note);
    END IF;
    /* End Bug 6904194 */

    /* Bug 2989951. AdHocUser Name should be concatenation of the E-mail Address and the language */
          l_po_email_performer := l_po_email_add||'.'||l_adhocuser_lang;
          l_po_email_performer := upper(l_po_email_performer);
          l_display_name := l_po_email_performer;

     select count(*) into l_performer_exists
     from wf_users where name = l_po_email_performer;
     /* Bug 2864242 The wf_local_users table is obsolete after the patch 2350501. So used the
        wf_users view instead of wf_local_users table */


     x_progress := '003';

     if (l_performer_exists = 0) then
	--EMAILPO FPH--
	-- Pass in the correct adhocuser language and territory for CreateAdHocUser and SetAdhocUserAttr instead of null
	WF_DIRECTORY.CreateAdHocUser(l_po_email_performer, l_display_name, l_adhocuser_lang, l_adhocuser_territory, null, l_notification_preference, 	l_po_email_add, null, 'ACTIVE', null);

      else
	WF_DIRECTORY.SETADHOCUSERATTR(l_po_email_performer, l_display_name, l_notification_preference, l_adhocuser_lang, l_adhocuser_territory,	l_po_email_add, null);

      end if;

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'PO_WF_EMAIL_PERFORMER',
                                    avalue    =>  l_po_email_performer);

     /* set the  performer from thr profilr to send the second email */
     /* Bug 2989951. Secondary AdHocUser Name should be concatenation of the Secondary E-mail Address and the language

     l_po_email_performer_prof := 'PO_SECONDRY_EMAIL_ADD';
     l_display_name_prof := 'PO_SECONDRY_EMAIL_ADD'; */

     l_po_email_performer_prof := l_po_email_add_prof||'.'||l_adhocuser_lang;
     l_po_email_performer_prof := upper(l_po_email_performer_prof);
     l_display_name_prof := l_po_email_performer_prof;


     select count(*) into l_performer_exists
     from wf_users where name = l_po_email_performer_prof;
     /* Bug 2864242 The wf_local_users table is obsolete after the patch 2350501. So used the
        wf_users view instead of wf_local_users table */


	 --EMAILPO FPH START--
	 -- For second email also the language and territory settings should be same as for the first one above
	 x_progress := '004';
     if (l_performer_exists = 0) then

	WF_DIRECTORY.CreateAdHocUser(l_po_email_performer_prof, l_display_name_prof, l_adhocuser_lang, l_adhocuser_territory, null, l_notification_preference, 	l_po_email_add_prof, null, 'ACTIVE', null);

      else
	WF_DIRECTORY.SETADHOCUSERATTR(l_po_email_performer_prof, l_display_name_prof, l_notification_preference, l_adhocuser_lang, l_adhocuser_territory,	l_po_email_add_prof, null);

      end if;
	--EMAILPO FPH END--

        wf_engine.SetItemAttrText ( itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'PO_WF_EMAIL_PERFORMER2',
                                    avalue    =>  l_po_email_performer_prof);



    x_progress := '005';

     -- bug 4727400 : updates need to autonomous, PA needs to be take care of.
     update_print_count(l_document_id,l_document_type);

     -- Begin Bug 3992826
     /*if (l_document_type = 'RELEASE')  then
               update po_releases_all pr
               set pr.printed_date = sysdate,
                   pr.print_count = nvl(pr.print_count,0) + 1
               where pr.po_release_id = l_document_id ;
     elsif (l_document_type  in ('PO','PA')) then -- Bug 4727400
               update po_headers_all ph
               set ph.printed_date = sysdate,
                   ph.print_count = nvl(ph.print_count,0) + 1
               where ph.po_header_id = l_document_id ;
     else
           null;
     end if; */
    -- End Bug 3992826



    --Bug#2843760: Moved portion of code which does the PO archiving to internal procedure ARCHIVE_PO
	ARCHIVE_PO(l_document_id, l_document_type, l_document_subtype);


  END IF;


   resultout := wf_engine.eng_completed || ':' || l_email_doc ;

  x_progress := 'PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No: 02. Result= ' || l_email_doc;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- resultout := wf_engine.eng_completed || ':' || 'Y' ;


EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Email_Doc_Yes_No',x_progress||':'||sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.EMAIL_DOC_YES_NO',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Email_Doc_Yes_No;











-- Print_Document
--   Resultout
--     ACTIVITY_PERFORMED
--   Print Document.

procedure Print_Document(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_print_doc   varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Document: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Document: 02';

  PrintDocument(itemtype,itemkey);
  --
     resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Print_Document: 03';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Print_Document',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.PRINT_DOCUMENT',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Print_Document;




-- Procedure called by wf.
-- DKC 10/10/99
procedure Fax_Document(     itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_orgid       number;
l_fax_doc     varchar2(2);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Document: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Document: 02';

  FaxDocument(itemtype,itemkey);
  --
     resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.Fax_Document: 03';

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1.Fax_Document',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.FAX_DOCUMENT',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Fax_Document;






-- Is_document_Approved
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--
--   Is the document already approved. This may be the case if the document
--   was PRE-APPROVED before it goes through the reserve action. The RESERVE
--   would then approve the doc after it reserved the funds.

procedure Is_document_Approved(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_auth_stat   varchar2(25);
l_doc_type varchar2(25);
l_doc_id       number;
l_orgid       number;
x_resultout   varchar2(1);
x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Is_document_Approved: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2377333
  ** Setting application context
  */

-- bug 4556437 : context setting no longer required here
  --PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
  IF l_doc_type='REQUISITION' THEN

    x_progress := '002';

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = l_doc_id;


  ELSIF l_doc_type IN ('PO','PA') THEN

    x_progress := '003';

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_HEADERS
      where po_header_id = l_doc_id;

  ELSIF l_doc_type = 'RELEASE' THEN

      x_progress := '004';

      select NVL(authorization_status,'INCOMPLETE') into l_auth_stat
      from PO_RELEASES
      where po_release_id = l_doc_id;

   END IF;

  IF l_auth_stat = 'APPROVED' THEN

     resultout := wf_engine.eng_completed || ':' || 'Y' ;
     x_resultout := 'Y';
  ELSE
     resultout := wf_engine.eng_completed || ':' || 'N';
     x_resultout := 'N';
  END IF;

  x_progress := 'PO_REQAPPROVAL_INIT1.Is_document_Approved: 02. Result=' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_document_Approved',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_DOCUMENT_APPROVED',l_doc_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;


END Is_document_Approved;

-- Get_Create_PO_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed

procedure Get_Create_PO_Mode(itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       out NOCOPY varchar2    ) is
l_create_po_mode  VARCHAR2(1);
x_progress        varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN


   x_progress := 'PO_REQAPPROVAL_INIT1.Get_Create_PO_Mode: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_create_po_mode := wf_engine.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'SEND_CREATEPO_TO_BACKGROUND');

  /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  /* Bug 678291 by dkfchan
  ** if the approval mode is background, set the result to 'BACKGROUD'
  ** Removed the original method which set the WF_ENGINE.THRESHOLD to -1.
  ** This fix depends on the change poxwfrqa.wft and poxwfpoa.wft also.
  */

  IF NVL(l_create_po_mode,'N') = 'Y' THEN
    resultout := wf_engine.eng_completed || ':' ||  'BACKGROUND';
  ELSE
    resultout := wf_engine.eng_completed || ':' ||  'ONLINE';
  END IF;

  x_progress :=  'PO_REQAPPROVAL_INIT1.Get_Create_PO_Mode: ' ||
                 'Create PO Mode= ' || l_create_po_mode;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Get_Create_PO_Mode',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.GET_CREATE_PO_MODE',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Get_Create_PO_Mode;

-- Get_Workflow_Approval_Mode
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      On-line
--      Background

procedure Get_Workflow_Approval_Mode(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is
l_approval_mode   VARCHAR2(30);
x_progress              varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN

  /* get the profile PO_WORKFLOW_APPROVAL_MODE and return the value */

   x_progress := 'PO_REQAPPROVAL_INIT1.Get_Workflow_Approval_Mode: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  fnd_profile.get('PO_WORKFLOW_APPROVAL_MODE', l_approval_mode);

  /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  /* Bug 678291 by dkfchan
  ** if the approval mode is background, set the result to 'BACKGROUD'
  ** Removed the original method which set the WF_ENGINE.THRESHOLD to -1.
  ** This fix depends on the change poxwfrqa.wft and poxwfpoa.wft also.
  */

  IF l_approval_mode =  'BACKGROUND' or l_approval_mode is NULL THEN
    resultout := wf_engine.eng_completed || ':' ||  'BACKGROUND';
  ELSE
    resultout := wf_engine.eng_completed || ':' ||  'ONLINE';
  END IF;

  x_progress :=  'PO_REQAPPROVAL_INIT1.Get_Workflow_Approval_Mode: ' ||
                 'Approval Mode= ' || l_approval_mode;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Get_Workflow_Approval_Mode',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.GET_WORKFLOW_APPROVAL_MODE',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Get_Workflow_Approval_Mode;

-- Dummy
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--      Activity Performed
-- Dummy procedure that does nothing (NOOP). Used to set the
-- cost above the backgound engine threshold. This causes the
-- workflow to execute in the background.
procedure Dummy(   itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is

BEGIN

  /* Do nothing */
  NULL;

END Dummy;



/****************************************************************************
* The Following are the supporting APIs to the workflow functions.
* These API's are Private (Not declared in the Package specs).
****************************************************************************/

procedure GetReqAttributes(p_requisition_header_id in NUMBER,
                             itemtype        in varchar2,
                             itemkey         in varchar2) is

l_line_num varchar2(80);
x_progress varchar2(100) := '000';

counter NUMBER:=0;
BEGIN


  x_progress := 'PO_REQAPPROVAL_INIT1.GetReqAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Fetch the Req Header, then set the attributes.  */
  open GetRecHdr_csr(p_requisition_header_id);
  FETCH GetRecHdr_csr into ReqHdr_rec;
  close GetRecHdr_csr;

  x_progress := 'PO_REQAPPROVAL_INIT1.GetReqAttributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  SetReqHdrAttributes(itemtype, itemkey);

  x_progress := 'PO_REQAPPROVAL_INIT1.GetReqAttributes: 03';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','GetReqAttributes',x_progress);
        raise;

end GetReqAttributes;
--


--------------------------------------------------------------------------------
--Start of Comments
--Name: getReqAmountInfo
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  convert req total, req amount, req tax into approver preferred currency for display
--Parameters:
--IN:
--itemtype
--  workflow item type
--itemtype
--  workflow item key
--p_function_currency
--  functional currency
--p_total_amount_disp
--  req total including tax, in displayable format
--p_total_amount
--  req total including tax, number
--p_req_amount_disp
--  req total without including tax, in displayable format
--p_req_amount
--  req total without including tax, number
--p_tax_amount_disp
--  req tax, in displayable format
--p_tax_amount
--  req tax number
--OUT:
--p_amount_for_subject
--p_amount_for_header
--p_amount_for_tax
--End of Comments
-------------------------------------------------------------------------------
procedure getReqAmountInfo(itemtype        in varchar2,
                          itemkey         in varchar2,
                          p_function_currency in varchar2,
                          p_total_amount_disp in varchar2,
                          p_total_amount in number,
                          p_req_amount_disp in varchar2,
                          p_req_amount in number,
                          p_tax_amount_disp in varchar2,
                          p_tax_amount in number,
                          x_amount_for_subject out nocopy varchar2,
                          x_amount_for_header out nocopy varchar2,
                          x_amount_for_tax out nocopy varchar2) is

  l_rate_type po_system_parameters.default_rate_type%TYPE;
  l_rate number;
  l_denominator_rate number;
  l_numerator_rate number;
  l_approval_currency varchar2(30);
  l_amount_disp varchar2(60);
  l_amount_approval_currency number;
  l_approver_user_name fnd_user.user_name%TYPE;
  l_user_id fnd_user.user_id%TYPE;
  l_progress varchar2(200);
  l_no_rate_msg varchar2(200);

begin
  SELECT  default_rate_type
  INTO l_rate_type
  FROM po_system_parameters;

  l_progress := 'getReqAmountInfo:' || l_rate_type;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  l_approver_user_name := PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_USER_NAME');
  if (l_approver_user_name is not null) then
    SELECT user_id
    INTO l_user_id
    FROM fnd_user
    WHERE user_name = l_approver_user_name;

    l_progress := 'getReqAmountInfo:' || l_user_id;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    l_approval_currency := FND_PROFILE.VALUE_SPECIFIC('ICX_PREFERRED_CURRENCY', l_user_id);
  end if;

  if (l_approval_currency = p_function_currency or l_approver_user_name is null
      or l_rate_type is null or l_approval_currency is null) then
    x_amount_for_subject := p_total_amount_disp || ' ' || p_function_currency;
    x_amount_for_header := p_req_amount_disp || ' ' || p_function_currency;
    x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
    return;
  end if;

  l_progress := 'getReqAmountInfo:' || l_approval_currency;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  gl_currency_api.get_closest_triangulation_rate(
                  x_from_currency => p_function_currency,
                  x_to_currency => l_approval_currency,
                  x_conversion_date => sysdate,
                  x_conversion_type => l_rate_type,
                  x_max_roll_days  => 5,
                  x_denominator => l_denominator_rate,
                  x_numerator => l_numerator_rate,
                  x_rate => l_rate);


  l_progress := 'getReqAmountInfo:' || substrb(to_char(l_rate), 1, 30);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  /* setting amount for notification subject */
  l_amount_approval_currency := (p_total_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));
  x_amount_for_subject := l_amount_disp || ' ' || l_approval_currency;

  /* setting amount for header attribute */
  l_amount_approval_currency := (p_req_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));

  l_progress := 'getReqAmountInfo:' || l_amount_disp;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  x_amount_for_header := p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  x_amount_for_header || ' (' || l_amount_disp || ' ' || l_approval_currency || ')';

  l_amount_approval_currency := (p_tax_amount/l_denominator_rate) * l_numerator_rate;

  l_amount_disp := TO_CHAR(l_amount_approval_currency,
                            FND_CURRENCY.GET_FORMAT_MASK(l_approval_currency,g_currency_format_mask));

  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax :=  x_amount_for_tax || ' (' || l_amount_disp || ' ' || l_approval_currency || ')';

exception
when gl_currency_api.no_rate then
  l_progress := 'getReqAmountInfo: no rate';

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
  x_amount_for_subject := p_req_amount_disp || ' ' || p_function_currency;

  l_no_rate_msg := fnd_message.get_string('PO', 'PO_WF_NOTIF_NO_RATE');
  l_no_rate_msg := replace (l_no_rate_msg, '', l_approval_currency);

  x_amount_for_header :=  p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  x_amount_for_header || ' (' || l_no_rate_msg || ')';

  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax :=  x_amount_for_tax || ' (' || l_no_rate_msg || ')';

when others then

  l_progress := 'getReqAmountInfo:' || substrb(SQLERRM, 1,200);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
  x_amount_for_subject := p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_header :=  p_req_amount_disp || ' ' || p_function_currency;
  x_amount_for_tax := p_tax_amount_disp || ' ' || p_function_currency;

end;

procedure SetReqHdrAttributes(itemtype in varchar2, itemkey in varchar2) is

x_progress varchar2(200) := '000';

l_auth_stat  varchar2(80);
l_closed_code varchar2(80);
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_doc_type_disp varchar2(240); /* Bug# 2616355: kagarwal */
-- l_doc_subtype_disp varchar2(80);

l_req_amount        number;
l_req_amount_disp   varchar2(60);
l_tax_amount        number;
l_tax_amount_disp   varchar2(60);
l_total_amount      number;
l_total_amount_disp varchar2(60);

l_amount_for_subject varchar2(400);
l_amount_for_header varchar2(400);
l_amount_for_tax varchar2(400);

/* Bug# 1162252: Amitabh
** Desc: Changed the length of l_currency_code from 8 to 30
**       as the call to PO_CORE_S2.get_base_currency would
**       return varchar2(30).
*/

l_currency_code     varchar2(30);
l_doc_id            number;

/* Bug 1100247: Amitabh
*/
x_username   WF_USERS.name%TYPE; --Bug7562122
x_user_display_name  WF_USERS.display_name%TYPE; --Bug7562122
/* Bug 2830992
 */
l_num_attachments number;
 /*Start Bug#3406460 */
 l_precision        number;
 l_ext_precision    number;
 l_min_acct_unit    number;
 /*End Bug#3406460  */
cursor c1(p_auth_stat varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='AUTHORIZATION STATUS'
  and lookup_code = p_auth_stat;

cursor c2(p_closed_code varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='DOCUMENT STATE'
  and lookup_code = p_closed_code;

/* Bug# 2616355: kagarwal
** Desc: We will get the document type display value from
** po document types.
*/

cursor c3(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;

/*
cursor c4(p_doc_subtype varchar2) is
  select DISPLAYED_FIELD
  from po_lookup_codes
  where lookup_type='REQUISITION TYPE'
  and lookup_code = p_doc_subtype;
*/

/* Bug# 1470041: kagarwal
** Desc: Modified the cursor req_total_csr for calculating the Req Total
** in procedure SetReqHdrAttributes() to ignore the Req lines modified using
** the modify option in the autocreate form.
**
** Added condition:
**                 AND  NVL(modified_by_agent_flag, 'N') = 'N'
*/
/*Start Bug#3406460 - Added precision parameter to round the line amount*/
cursor req_total_csr(p_doc_id number,l_precision number) is
   SELECT nvl(SUM(round(decode(order_type_lookup_code,
                         'RATE', amount,
                         'FIXED PRICE', amount,
                         quantity * unit_price),l_precision)) ,0)
   FROM   po_requisition_lines
   WHERE  requisition_header_id = p_doc_id
     AND  NVL(cancel_flag,'N') = 'N'
     AND  NVL(modified_by_agent_flag, 'N') = 'N';
/*End Bug#3406460*/
/* Bug# 2483898: kagarwal
** Desc:  When calculating the Tax for Requisitons submitted for approval,
** the cancelled requisition lines should be ignored. Also the lines modified in
** the autocreate form using the modify option should also be ignored.
*/

cursor req_tax_csr(p_doc_id number) is
   SELECT nvl(sum(nonrecoverable_tax), 0)
   FROM   po_requisition_lines rl,
          po_req_distributions rd
   WHERE  rl.requisition_header_id = p_doc_id
     AND  rd.requisition_line_id = rl.requisition_line_id
     AND  NVL(rl.cancel_flag,'N') = 'N'
     AND  NVL(rl.modified_by_agent_flag, 'N') = 'N';

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.SetReqHdrAttributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'DOCUMENT_NUMBER',
                                   avalue     =>  ReqHdr_rec.segment1);
   --
   wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'DOCUMENT_ID',
                                   avalue     => ReqHdr_rec.requisition_header_id);
   --
   wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'PREPARER_ID',
                                   avalue     => ReqHdr_rec.preparer_id);
   --
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS',
                                   avalue     =>  ReqHdr_rec.authorization_status);
   --

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQ_DESCRIPTION',
                                   avalue      =>  ReqHdr_rec.description);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CLOSED_CODE',
                                   avalue      =>  ReqHdr_rec.closed_code);
   --

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'EMERGENCY_PO_NUMBER',
                                   avalue      =>  ReqHdr_rec.emergency_po_num);
   --

   -- Bug#3147435
   x_progress := 'PO_REQAPPROVAL_INIT1.SetReqHdrAttributes: 02 Start of Hdr Att for JRAD';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   -- Bug#3147435
   --Set the CONTRACTOR_REQUISITION_FLAG
   PO_WF_UTIL_PKG.SetItemAttrText (itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CONTRACTOR_REQUISITION_FLAG',
                                   avalue      =>  ReqHdr_rec.contractor_requisition_flag);
   --

   -- Bug#3147435
   --Set the CONTRACTOR_STATUS
   PO_WF_UTIL_PKG.SetItemAttrText (itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CONTRACTOR_STATUS',
                                   avalue      =>  ReqHdr_rec.contractor_status);
   --

   -- Bug#3147435
   x_progress := 'PO_REQAPPROVAL_INIT1.SetReqHdrAttributes: 03 End of Hdr Att for JRAD';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

/* Bug 1100247  Amitabh*/
   PO_REQAPPROVAL_INIT1.get_user_name(ReqHdr_rec.preparer_id, x_username,
                                      x_user_display_name);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_USER_NAME' ,
                              avalue     => x_username);

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

   /* Get the translated values for the DOC_TYPE, DOC_SUBTYPE, AUTH_STATUS and
   ** CLOSED_CODE. These will be displayed in the notifications.
   */
  l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

   OPEN C1(ReqHdr_rec.authorization_status);
   FETCH C1 into l_auth_stat;
   CLOSE C1;

   OPEN C2(ReqHdr_rec.closed_code);
   FETCH C2 into l_closed_code;
   CLOSE C2;

/* Bug# 2616355: kagarwal */

   OPEN C3(l_doc_type, l_doc_subtype);
   FETCH C3 into l_doc_type_disp;
   CLOSE C3;

/*
   OPEN C4(l_doc_subtype);
   FETCH C4 into l_doc_subtype_disp;
   CLOSE C4;
*/

   --
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS_DISP',
                                   avalue     =>  l_auth_stat);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'CLOSED_CODE_DISP',
                                   avalue      =>  l_closed_code);
   --
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_TYPE_DISP',
                                   avalue      =>  l_doc_type_disp);
   --
/* Bug# 2616355: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/
/*
   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'DOCUMENT_SUBTYPE_DISP',
                                   avalue      =>  l_doc_subtype_disp);
*/

   l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   l_currency_code := PO_CORE_S2.get_base_currency;
/*Start Bug#3406460 - call to fnd function to get precision */
   fnd_currency.get_info(l_currency_code,
                         l_precision,
                        l_ext_precision,
                         l_min_acct_unit);
/* End Bug#3406460*/

    OPEN req_total_csr(l_doc_id,l_precision); --Bug#3406460  added parameter X_precision
   FETCH req_total_csr into l_req_amount;
   CLOSE req_total_csr;

   /* For REQUISITIONS, since every line could have a different currency, then
   ** will show the total in the BASE/FUNCTIONAL currency.
   ** For POs, we will show it in the Document currency specified by the user.
   */

   l_req_amount_disp := TO_CHAR(l_req_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'FUNCTIONAL_CURRENCY',
                                   avalue      =>  l_currency_code);

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQ_AMOUNT_DSP',
                                   avalue      =>  l_req_amount_disp);

  OPEN req_tax_csr(l_doc_id);
  FETCH req_tax_csr into l_tax_amount;
  CLOSE req_tax_csr;

  l_tax_amount_disp := TO_CHAR(l_tax_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));

   wf_engine.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_DSP',
                                   avalue      =>  l_tax_amount_disp);

  l_total_amount := l_req_amount + l_tax_amount;

  l_total_amount_disp := TO_CHAR(l_total_amount,FND_CURRENCY.GET_FORMAT_MASK(
                                       l_currency_code, g_currency_format_mask));


  /* bug 3105327
     support approval currency in notification header and subject
     because TOTAL_AMOUNT_DSP is only used in notification,
     this bug fix changes the meaning of this attribute from total to
     total with currency;
     the workflow definition is modified such that
     currency atribute is removed from the subject.
   */
  getReqAmountInfo(itemtype => itemtype,
                          itemkey => itemkey,
                          p_function_currency => l_currency_code,
                          p_total_amount_disp => l_total_amount_disp,
                          p_total_amount => l_total_amount,
                          p_req_amount_disp => l_req_amount_disp,
                          p_req_amount => l_req_amount,
                          p_tax_amount_disp => l_tax_amount_disp,
                          p_tax_amount => l_tax_amount,
                          x_amount_for_subject => l_amount_for_subject,
                          x_amount_for_header => l_amount_for_header,
                          x_amount_for_tax => l_amount_for_tax);

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TOTAL_AMOUNT_DSP',
                                   avalue      =>  l_amount_for_subject);

  /* begin bug 2480327 notification UI enhancement */

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQ_AMOUNT_CURRENCY_DSP',
                                   avalue      =>  l_amount_for_header);

  PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'TAX_AMOUNT_CURRENCY_DSP',
                                   avalue      =>  l_amount_for_tax);


  /* Bug 2830992
   */
  begin
    select count(1)
    into l_num_attachments
    from fnd_attached_documents
    where pk1_value = to_char(ReqHdr_rec.requisition_header_id)
        and entity_name = 'REQ_HEADERS';
  exception
    when others then
      l_num_attachments := 0;
  end;

  if (l_num_attachments > 0 ) then
    PO_WF_UTIL_PKG.SetItemAttrDocument(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'ATTACHMENT',
                            documentid   =>
   'FND:entity=REQ_HEADERS' || '&' || 'pk1name=REQUISITION_HEADER_ID' ||
   '&' || 'pk1value='|| ReqHdr_rec.requisition_header_id);
   end if;


  /* end bug 2480327 notification UI enhancement */

  x_progress := 'SetReqHdrAttributes (end): : ' || l_auth_stat ||
                l_currency_code || l_req_amount_disp;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if (ReqHdr_rec.NOTE_TO_AUTHORIZER is not null) then
    PO_WF_UTIL_PKG.SetItemAttrText (     itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'JUSTIFICATION',
                                   avalue      =>  ReqHdr_rec.NOTE_TO_AUTHORIZER);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetReqHdrAttributes',x_progress);
        raise;


end SetReqHdrAttributes;

--
--  procedure SetReqAuthStat, SetPOAuthStat, SetRelAuthStat
--    This procedure sets the document status to IN PROCESS, if called at the beginning of the
--    Approval Workflow,
--    or to INCOMPLETE if doc failed STATE VERIFICATION or COMPLETENESS check at the
--    beginning of WF,
--    or to it's original status if No Approver was found or doc failed STATE VERIFICATION
--    or COMPLETENESS check before APPROVE, REJECT or FORWARD

procedure SetReqAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2,note varchar2,
                         p_auth_status in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

l_requisition_header_id number;
x_progress varchar2(3):= '000';

BEGIN

  l_requisition_header_id := p_document_id;

  /* If this is for the upgrade, then only put in the ITEMTYPE/ITEMKEY.
  ** We should not change the doc status to IN PROCESS (it could have been
  ** PRE-APPROVED).
  ** If normal processing then at this point the status is NOT 'IN PROCESS'
  ** or 'PRE-APPROVED', therefore we should update the status to IN PROCESS.
  */

/* Bug# 1894960: kagarwal
** Desc: Requisitons Upgraded from 10.7 fails to set the status of Requisiton
** to Pre-Approved.
**
** Reason being that when the procedure SetReqAuthStat() is called to set the
** Requisiton status to Pre-Approved, the conditon
** "IF (note = 'UPGRADE_TO_R11')" do not set the authorization status causes
** the Requisiton to remain in the existing status.
** Hence the Upgraded Requisitons can never be set to 'Pre-Approved' status and
** the approval process will always return the Req with Notification
** "No Approver Found".
**
** Whereas the reason for this condition was to not set the status of upgrade
** Reqs to IN PROCESS as it could have been PRE-APPROVED.
**
** Changed the procedure SetReqAuthStat().
**
** Modified the clause IF note = 'UPGRADE_TO_R11'
**
** TO:
**
** IF (note = 'UPGRADE_TO_R11' and p_auth_status = 'IN PROCESS') THEN
**
** Now when the approval process will  call the procedure SetReqAuthStat()
** to set the Requisiton to 'Pre-Approved' status then it will go to the
** else part and set its authorization status to 'Pre-Approved'.
*/

  IF (note = 'UPGRADE_TO_R11' and p_auth_status = 'IN PROCESS') THEN

    update po_requisition_headers set
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    active_shopping_cart_flag = NULL,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where requisition_header_id = l_requisition_header_id;

  ELSE

    update po_requisition_headers set
    AUTHORIZATION_STATUS = p_auth_status,
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    active_shopping_cart_flag = NULL,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where requisition_header_id = l_requisition_header_id;

  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetReqAuthStat',x_progress);
        raise;

END SetReqAuthStat;

--
procedure SetPOAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                        p_auth_status in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

l_po_header_id  NUMBER;
x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  l_po_header_id := p_document_id;

  /* If this is for the upgrade, then only put in the ITEMTYPE/ITEMKEY.
  ** We should not change the doc status to IN PROCESS (it could have been
  ** PRE-APPROVED).
  ** If normal processing then at this point the status is NOT 'IN PROCESS'
  ** or 'PRE-APPROVED', therefore we should update the status to IN PROCESS.
  */
  IF note = 'UPGRADE_TO_R11' THEN

    update po_headers set
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where po_header_id = l_po_header_id;

  ELSE
    --Bug 4065793: used to_date(null) to retain the time_stamp of submit_date
    update po_headers set
    AUTHORIZATION_STATUS = p_auth_status,
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    ,submit_date = decode(p_auth_status,
              'INCOMPLETE',to_date(null),submit_date)   --<DBI Req Fulfillment 11.5.10+>
    where po_header_id = l_po_header_id;
  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetPOAuthStat',x_progress);
        raise;

END SetPOAuthStat;

--
procedure SetRelAuthStat(p_document_id in number, itemtype in varchar2,itemkey in varchar2, note varchar2,
                         p_auth_status in varchar2) is
pragma AUTONOMOUS_TRANSACTION;

l_Release_header_id  NUMBER;
x_progress varchar2(3):= '000';

BEGIN

   x_progress := '001';

  l_Release_header_id := p_document_id;

  /* If this is for the upgrade, then only put in the ITEMTYPE/ITEMKEY.
  ** We should not change the doc status to IN PROCESS (it could have been
  ** PRE-APPROVED).
  ** If normal processing then at this point the status is NOT 'IN PROCESS'
  ** or 'PRE-APPROVED', therefore we should update the status to IN PROCESS.
  */
  IF note = 'UPGRADE_TO_R11' THEN

    update po_releases   set
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    where po_release_id = l_Release_header_id;

  ELSE

    --Bug 4065793: used to_date(null) to retain the time_stamp of submit_date
    update po_releases   set
    AUTHORIZATION_STATUS = p_auth_status,
    WF_ITEM_TYPE = itemtype,
    WF_ITEM_KEY  = itemkey,
    last_updated_by         = fnd_global.user_id,
    last_update_login       = fnd_global.login_id,
    last_update_date        = sysdate
    ,submit_date = decode(p_auth_status,
              'INCOMPLETE',to_date(null),submit_date) --<DBI Req Fulfillment 11.5.10+>
    where po_release_id = l_Release_header_id;
  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','SetRelAuthStat',x_progress);
        raise;

END SetRelAuthStat;
--
--
procedure UpdtReqItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id in number) is
pragma AUTONOMOUS_TRANSACTION;
x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  update po_requisition_headers   set
  WF_ITEM_TYPE = itemtype,
  WF_ITEM_KEY  = itemkey,
  last_updated_by         = fnd_global.user_id,
  last_update_login       = fnd_global.login_id,
  last_update_date        = sysdate
  where requisition_header_id = p_doc_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','UpdtReqItemtype',x_progress);
        raise;

END UpdtReqItemtype;

--
procedure UpdtPOItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id in number) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  update po_headers   set
  WF_ITEM_TYPE = itemtype,
  WF_ITEM_KEY  = itemkey,
  last_updated_by         = fnd_global.user_id,
  last_update_login       = fnd_global.login_id,
  last_update_date        = sysdate
  ,submit_date            = sysdate       --<DBI Req Fulfillment 11.5.10+>
  where po_header_id = p_doc_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','UpdtPOItemtype',x_progress);
        raise;

END UpdtPOItemtype;


--
procedure UpdtRelItemtype(itemtype in varchar2,itemkey in varchar2, p_doc_id in number) is
pragma AUTONOMOUS_TRANSACTION;

x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';

  update po_releases   set
  WF_ITEM_TYPE = itemtype,
  WF_ITEM_KEY  = itemkey,
  last_updated_by         = fnd_global.user_id,
  last_update_login       = fnd_global.login_id,
  last_update_date        = sysdate
  ,submit_date            = sysdate       --<DBI Req Fulfillment 11.5.10+>
  where po_release_id = p_doc_id;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','UpdtRelItemtype',x_progress);
        raise;

END UpdtRelItemtype;

--
procedure GetCanOwnerApprove(itemtype in varchar2,itemkey in varchar2,
                             CanOwnerApproveFlag out NOCOPY varchar2)
is

Cursor C1(p_document_type_code VARCHAR2, p_document_subtype VARCHAR2) is
 select NVL(can_preparer_approve_flag,'N')
 from po_document_types
 where document_type_code = p_document_type_code
 and   document_subtype = p_document_subtype;

l_document_type_code VARCHAR2(25);
l_document_subtype   VARCHAR2(25);
x_progress varchar2(3):= '000';

BEGIN

 x_progress := '001';
 l_document_type_code := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

 l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  open C1(l_document_type_code, l_document_subtype);
  Fetch C1 into CanOwnerApproveFlag;
  close C1;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','GetCanOwnerApprove',x_progress);
        raise;

END GetCanOwnerApprove;
--

/*****************************************************************************
*
*  Supporting APIs declared in the package spec.
*****************************************************************************/


PROCEDURE get_multiorg_context(document_type varchar2, document_id number,
                               x_orgid IN OUT NOCOPY number) is

cursor get_req_orgid is
  select org_id
  from po_requisition_headers_all
  where requisition_header_id = document_id;

cursor get_po_orgid is
  select org_id
  from po_headers_all
  where po_header_id = document_id;

cursor get_release_orgid is
  select org_id
  from po_releases_all
  where po_release_id = document_id;

x_progress varchar2(3):= '000';

BEGIN

  x_progress := '001';
  IF document_type = 'REQUISITION' THEN


     OPEN get_req_orgid;
     FETCH get_req_orgid into x_orgid;
     CLOSE get_req_orgid;

  ELSIF document_type IN ( 'PO','PA' ) THEN

     OPEN get_po_orgid;
     FETCH get_po_orgid into x_orgid;
     CLOSE get_po_orgid;

  ELSIF document_type = 'RELEASE' THEN

     OPEN get_release_orgid ;
     FETCH get_release_orgid into x_orgid;
     CLOSE get_release_orgid;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','get_multiorg_context',x_progress);
        raise;

END get_multiorg_context;


--
PROCEDURE get_employee_id(p_username IN varchar2, x_employee_id OUT NOCOPY number) is

-- DEBUG: Is this the best way to get the emp_id of the username
--        entered as a forward-to in the notification?????
--
  /* 1578061 add orig system condition to enhance performance. */

  cursor c_empid is
    select ORIG_SYSTEM_ID
    from   wf_users WF
    where  WF.name     = p_username
      and  ORIG_SYSTEM NOT IN ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

x_progress varchar2(3):= '000';

BEGIN

    open  c_empid;
    fetch c_empid into x_employee_id;

    /* DEBUG: get Vance and Kevin opinion on this:
    ** If no employee_id is found then return null. We will
    ** treat that as the user not supplying a forward-to username.
    */
    IF c_empid%NOTFOUND  THEN

       x_employee_id := NULL;

    END IF;

    close c_empid;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','get_employee_id',p_username);
        raise;


END get_employee_id;


--
PROCEDURE get_user_name(p_employee_id IN number, x_username OUT NOCOPY varchar2,
                        x_user_display_name OUT NOCOPY varchar2) is

p_orig_system  varchar2(20);

BEGIN

  p_orig_system:= 'PER';

  WF_DIRECTORY.GetUserName(p_orig_system,
                           p_employee_id,
                           x_username,
                           x_user_display_name);

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','get_user_name',to_char(p_employee_id));
        raise;

END get_user_name;


--
PROCEDURE InsertActionHistSubmit(itemtype varchar2, itemkey varchar2,
                                 p_doc_id number, p_doc_type varchar2,
                                 p_doc_subtype varchar2, p_employee_id number,
                                 p_action varchar2, p_note varchar2,
                                 p_path_id number) is

pragma AUTONOMOUS_TRANSACTION;

l_auth_stat varchar2(25);
l_action_code varchar2(25);
l_revision_num number := NULL;
l_hist_count   number := NULL;
l_sequence_num   number := NULL;
l_approval_path_id number;

CURSOR action_hist_cursor(doc_id number , doc_type varchar2) is
   select max(sequence_num)
   from po_action_history
   where object_id= doc_id and
   object_type_code = doc_type;

CURSOR action_hist_code_cursor (doc_id number , doc_type varchar2, seq_num number) is
   select action_code
   from po_action_history
   where object_id = doc_id and
   object_type_code = doc_type and
   sequence_num = seq_num;


x_progress varchar2(3):='000';

BEGIN

  /* Get the document authorization status.
  ** has been submitted before, i.e.
  ** First insert a row with  a SUBMIT action.
  ** Then insert a row with a NULL ACTION_CODE to simulate the forward-to
  ** since the doc status has been changed to IN PROCESS.
  */

  x_progress := '001';

  l_approval_path_id := p_path_id;

  IF p_doc_type='REQUISITION' THEN

    x_progress := '002';

      select NVL(authorization_status, 'INCOMPLETE') into l_auth_stat
      from PO_REQUISITION_HEADERS
      where requisition_header_id = p_doc_id;


  ELSIF p_doc_type IN ('PO','PA') THEN

    x_progress := '003';

      select NVL(authorization_status,'INCOMPLETE'),revision_num
             into l_auth_stat, l_revision_num
      from PO_HEADERS
      where po_header_id = p_doc_id;

  ELSIF p_doc_type = 'RELEASE' THEN

      x_progress := '004';

      select NVL(authorization_status,'INCOMPLETE'),revision_num
             into l_auth_stat, l_revision_num
      from PO_RELEASES
      where po_release_id = p_doc_id;

   END IF;

   x_progress := '005';

   /* Check if this document had been submitted to workflow at some point
   ** and somehow kicked out. If that's the case, the sequence number
   ** needs to be incremented by one. Otherwise start at zero.
   */
   OPEN action_hist_cursor(p_doc_id , p_doc_type );
   FETCH action_hist_cursor into l_sequence_num;
   CLOSE action_hist_cursor;
   IF l_sequence_num is NULL THEN
      l_sequence_num := 0;
   ELSE
      OPEN action_hist_code_cursor(p_doc_id , p_doc_type, l_sequence_num);
      FETCH action_hist_code_cursor into l_action_code;
      l_sequence_num := l_sequence_num +1;
   END IF;


   x_progress := '006';
   IF ((l_sequence_num = 0)
        OR
       (l_sequence_num > 0 and l_action_code is NOT NULL)) THEN
      INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              p_action,
              decode(p_action, '',to_date(null), sysdate),
              p_employee_id,
              p_note,
              l_revision_num,
              fnd_global.login_id,
              0,
              0,
              0,
              '',
              l_approval_path_id,
              '' );

    ELSE
        l_sequence_num := l_sequence_num - 1;
        UPDATE PO_ACTION_HISTORY
          set object_id = p_doc_id,
              object_type_code = p_doc_type,
              object_sub_type_code = p_doc_subtype,
              sequence_num = l_sequence_num,
              last_update_date = sysdate,
              last_updated_by = fnd_global.user_id,
              creation_date = sysdate,
              created_by = fnd_global.user_id,
              action_code = p_action,
              action_date = decode(p_action, '',to_date(null), sysdate),
              employee_id = p_employee_id,
              note = p_note,
              object_revision_num = l_revision_num,
              last_update_login = fnd_global.login_id,
              request_id = 0,
              program_application_id = 0,
              program_id = 0,
              program_update_date = '',
              approval_path_id = l_approval_path_id,
              offline_code = ''
        WHERE
              object_id= p_doc_id and
              object_type_code = p_doc_type and
              sequence_num = l_sequence_num;

    END IF;

    INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num + 1,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              NULL,              -- ACTION_CODE
              decode(p_action, '',to_date(null), sysdate),
              p_employee_id,
              NULL,
              l_revision_num,
              fnd_global.login_id,
              0,
              0,
              0,
              '',
              0,
              '' );

    x_progress := '007';

commit;
EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','InsertActionHistSubmit',x_progress);
        raise;

END InsertActionHistSubmit;


--

-- <ENCUMBRANCE FPJ START>
-- Rewriting the following procedure to use the encumbrance APIs

FUNCTION EncumbOn_DocUnreserved(
                 p_doc_type    varchar2,
                 p_doc_subtype varchar2,
                 p_doc_id      number)
RETURN varchar2
IS
PRAGMA AUTONOMOUS_TRANSACTION;
-- The autonomous_transaction is required due to the use of the global temp
-- table PO_ENCUMBRANCE_GT, as the call to do_reserve later in the workflow
-- process is in an autonomous transaction because it must commit.
-- Without this autonomous transaction, the following error is raised:
-- ORA-14450: attempt to access a transactional temp table already in use

p_return_status          varchar2(1);
p_reservable_flag        varchar2(1);
l_progress               varchar2(200);

l_unreserved_flag VARCHAR2(1) := 'N';
l_return_exc   EXCEPTION;

BEGIN

   l_progress := '000';

   -- If the document is contract then we do not encumber it

   IF p_doc_subtype = 'CONTRACT' THEN

      RAISE l_return_exc;

   END IF;

   -- Check if encumbrance is on

   IF NOT (PO_CORE_S.is_encumbrance_on(
                  p_doc_type     => p_doc_type,
                  p_org_id       => NULL))
   THEN
       l_progress := '010';
      RAISE l_return_exc;
   END IF;

   l_progress := '020';

    -- Check if there is any distribution that can be reserved

   PO_DOCUMENT_FUNDS_PVT.is_reservable(
   x_return_status    =>   p_return_status
,  p_doc_type         =>   p_doc_type
,  p_doc_subtype      =>   p_doc_subtype
,  p_doc_level        =>   PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
,  p_doc_level_id     =>   p_doc_id
,  x_reservable_flag  =>   p_reservable_flag);

  l_progress := '030';

  IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '040';

  IF (p_return_status = FND_API.G_RET_STS_SUCCESS) AND
     (p_reservable_flag = PO_DOCUMENT_FUNDS_PVT.g_parameter_YES) THEN

     l_progress := '050';

      l_unreserved_flag := 'Y';
  END IF;

  l_progress := '060';

   ROLLBACK;
   RETURN(l_unreserved_flag);

EXCEPTION

WHEN l_return_exc THEN
   ROLLBACK;
   RETURN(l_unreserved_flag);

WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','EncumbOn_DocUnreserved',
                         l_progress);

   ROLLBACK;
   RAISE;

END EncumbOn_DocUnreserved;

-- <ENCUMBRANCE FPJ END>

PROCEDURE   PrintDocument(itemtype varchar2,itemkey varchar2) is

l_document_type   VARCHAR2(25);
l_document_num   VARCHAR2(30);
l_release_num     NUMBER;
l_request_id      NUMBER := 0;
l_qty_precision   VARCHAR2(30);
l_user_id         VARCHAR2(30);

x_progress varchar2(200);
-- BUG 4556437
l_printer         VARCHAR2(30);
-- bug 4956567
l_conc_copies     NUMBER;
l_conc_save_output VARCHAR2(1);
l_conc_save_output_bool BOOLEAN;
l_spo_result      BOOLEAN;

  l_return_status   BOOLEAN;
  l_territory       VARCHAR2(40);
  l_numeric_characters  VARCHAR2(40);
  /*Bug5194244 start */
  l_document_id number;
  l_withterms  varchar2(1);
  l_document_subtype     po_headers.type_lookup_code%TYPE;
  /*Bug5194244 end */

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.PrintDocument: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

   -- Get the profile option report_quantity_precision

   fnd_profile.get('REPORT_QUANTITY_PRECISION', l_qty_precision);

   /* Bug 2012896: the profile option REPORT_QUANTITY_PRECISION could be
      NULL. Even at site level!  And in that case the printing of report
      results into the inappropriate printing of quantities.
      Fix: Now, if the profile option is NULL, we are setting the variable
      l_qty_precision to 2, so that the printing would not fail. Why 2 ?
      This is the default defined in the definition of the said profile
      option. */

   IF l_qty_precision IS NULL THEN
      l_qty_precision := '2';
   END IF;

   -- Get the user id for the current user.  This information
   -- is used when sending concurrent request.

   FND_PROFILE.GET('USER_ID', l_user_id);

   --bug4704679 Start: Set the Numeric characters option

    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_numeric_characters);

    l_return_status:= FND_REQUEST.SET_OPTIONS(
                        numeric_characters => l_numeric_characters
                        );
   --bug4704679 End


   -- Send the concurrent request to print document.

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_num := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_NUMBER');

  /*Bug5194244 Get the item attributes DOCUMENT_ID,DOCUMENT_SUBTYPE
   and WITH_TERMSand pass it to Print_PO and Print_Release procedures*/

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_SUBTYPE');

 /*Bug5690836 Donot set the item attribute with_terms for requisitions
  as this attribute doesnot exist in req approval workflow*/
  IF l_document_type <> 'REQUISITION' THEN
  l_withterms := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'WITH_TERMS');
   END IF;



  -- Bug 4871481
  -- The global variable 4871481 should be populated. This is used by
  -- the print/fax routines
  g_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'DOCUMENT_SUBTYPE');
  -- End Bug 4871481

-- bug 4556437
  /* changed the call from wf_engine.setiteattrtext to
       po_wf_util_pkg.setitemattrtext because the later handles
       attrbute not found exception. req change order wf also
       uses these procedures and does not have the preparer_printer
       attribute, hence this was required */

  l_printer := po_wf_util_pkg.GetItemAttrText (itemtype  => itemtype,
 					    itemkey   => itemkey,
					    aname     => 'PREPARER_PRINTER');
-- bug 4956567 : Need to get the no of copies, and save output values for the
-- preparer and pass it to the set_print_options procedure
  l_conc_copies := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
  						     itemkey  => itemkey,
						     aname    => 'PREPARER_CONC_COPIES');
  l_conc_save_output := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
  						    itemkey  => itemkey,
						    aname    => 'PREPARER_CONC_SAVE_OUTPUT');

  if l_conc_save_output = 'Y' then
     l_conc_save_output_bool := TRUE;
  else
     l_conc_save_output_bool :=  FALSE;
  end if;


-- <Debug start>
        x_progress := 'SPO : got printer as '||l_printer||
		      ' conc_copies '||l_conc_copies||
		      ' save o/p '||l_conc_save_output;

	 IF (g_po_wf_debug = 'Y') THEN
            PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   	 END IF;
-- <debug end>

  if (l_printer is not null) then
     l_spo_result := fnd_request.set_print_options(printer=> l_printer,
     					            copies=> l_conc_copies,
						    save_output => l_conc_save_output_bool);
-- bug 4956567 <end>
     if (l_spo_result) then
     -- <Debug start>
        x_progress := 'SPO:set print options successful';
	IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;
     -- <debug end>
     else
     -- <Debug start>
        x_progress := 'SPO:set print options not successful ';
	IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;
     -- <Debug end>
     end if;
  end if;

   IF l_document_type = 'REQUISITION' THEN

        l_request_id := Print_Requisition(l_document_num, l_qty_precision,
                                          l_user_id);

   ELSIF l_document_type = 'RELEASE' THEN

        l_release_num := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RELEASE_NUM');

        --Bug5194244 Pass document_id,documentsubtype parameters
        l_request_id := Print_Release(l_document_num, l_qty_precision,
                                      to_char(l_release_num), l_user_id, l_document_id);

   ELSE
      --Bug5194244 Pass document_id,subtype and with terms parameters
        l_request_id := Print_PO(l_document_num, l_qty_precision,
                                          l_user_id, l_document_id,l_document_subtype,l_withterms);
   END IF;

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CONCURRENT_REQUEST_ID',
                                avalue   => l_request_id);

  x_progress := 'PO_REQAPPROVAL_INIT1.PrintDocument: 02. request_id= ' || to_char(l_request_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','PrintDocument',x_progress);
        raise;

END PrintDocument;




-- DKC 10/10/99
PROCEDURE   FaxDocument(itemtype varchar2,itemkey varchar2) is

l_document_type   VARCHAR2(25);
l_document_num    VARCHAR2(30);
l_release_num     NUMBER;
l_request_id      NUMBER := 0;
l_qty_precision   VARCHAR2(30);
l_user_id         VARCHAR2(30);

l_fax_enable	  VARCHAR2(25);
l_fax_num	  VARCHAR2(25);

x_progress varchar2(200);
-- BUG 4556437
l_spo_result      BOOLEAN;
l_printer         VARCHAR2(30);
/*Bug5194244 start */
l_document_id number;
l_withterms  varchar2(1);
l_document_subtype     po_headers.type_lookup_code%TYPE;
/*Bug5194244 end */

BEGIN

  x_progress := 'PO_REQAPPROVAL_INIT1.FaxDocument: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

   -- Get the profile option report_quantity_precision

   fnd_profile.get('REPORT_QUANTITY_PRECISION', l_qty_precision);

   -- Get the user id for the current user.  This information
   -- is used when sending concurrent request.

   FND_PROFILE.GET('USER_ID', l_user_id);

   -- Send the concurrent request to fax document.

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_num := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_NUMBER');

  /*Bug5194244 Get the document_id ,document subtype and with terms
   item attribute and pass it to Fax_PO and Fax_Release procedures
   Donot rely on global variable.Instead get the document subtype
   and pass it as a paramter */

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOCUMENT_ID');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_SUBTYPE');

  l_withterms := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'WITH_TERMS');

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
  	                                        itemkey  => itemkey,
                                                aname    => 'DOCUMENT_TYPE');


  -- Bug 4871481
  -- The global variable 4871481 should be populated. This is used by
  -- the print/fax routines
  g_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'DOCUMENT_SUBTYPE');
  -- End Bug 4871481

-- bug 4556437 : setting the printer to that of the preparer, so that
-- irrespective of who submits the request, the printing should happen
-- on preparer's printer
  /* changed the call from wf_engine.setiteattrtext to
       po_wf_util_pkg.setitemattrtext because the later handles
       attrbute not found exception. req change order wf also
       uses these procedures and does not have the preparer_printer
       attribute, hence this was required */

  l_printer := po_wf_util_pkg.GetItemAttrText  (itemtype   => itemtype,
 					    itemkey   => itemkey,
					    aname     => 'PREPARER_PRINTER');

  if (l_printer is not null) then
     l_spo_result:= fnd_request.set_print_options(printer=> l_printer);
  end if;

   IF l_document_type IN ('PO', 'PA') THEN

	l_fax_enable := wf_engine.GetItemAttrText (itemtype => itemtype,
					itemkey	=> itemkey,
					aname	=> 'FAX_DOCUMENT');

	l_fax_num    := wf_engine.GetItemAttrText (itemtype => itemtype,
					itemkey	=> itemkey,
					aname	=> 'FAX_NUMBER');

        --Bug5194244 Pass document_id ,document subtype and with terms parameters

        l_request_id := Fax_PO(l_document_num, l_qty_precision,
                                        l_user_id, l_fax_enable, l_fax_num,l_document_id,l_document_subtype,l_withterms);


   ELSIF l_document_type = 'RELEASE' THEN

        l_release_num := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RELEASE_NUM');

	l_fax_enable := wf_engine.GetItemAttrText (itemtype => itemtype,
					itemkey	=> itemkey,
					aname	=> 'FAX_DOCUMENT');

	l_fax_num    := wf_engine.GetItemAttrText (itemtype => itemtype,
					itemkey	=> itemkey,
					aname	=> 'FAX_NUMBER');

         --Bug5194244 Pass document_id ,document subtype parameters

        l_request_id := Fax_Release(l_document_num, l_qty_precision,
                                      	to_char(l_release_num), l_user_id,
					l_fax_enable, l_fax_num,l_document_id);

   END IF;

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'CONCURRENT_REQUEST_ID',
                                avalue   => l_request_id);

  x_progress := 'PO_REQAPPROVAL_INIT1.FaxDocument: 02. request_id= ' || to_char(l_request_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','FaxDocument',x_progress);
        raise;

END FaxDocument;






FUNCTION Print_Requisition(p_doc_num varchar2, p_qty_precision varchar,
                           p_user_id varchar2) RETURN number is

l_request_id NUMBER;
x_progress varchar2(200);

BEGIN

     l_request_id := fnd_request.submit_request('PO',
                'PRINTREQ',
                null,
                null,
                false,
                'P_REQ_NUM_FROM=' || p_doc_num,
                'P_REQ_NUM_TO=' || p_doc_num,
                'P_QTY_PRECISION=' || p_qty_precision,
                fnd_global.local_chr(0),
                NULL,
                NULL,
                NULL,
                NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Print_Requisition',x_progress);
        raise;
END;

FUNCTION Print_PO(p_doc_num varchar2, p_qty_precision varchar,
                  p_user_id varchar2,p_document_id number default NULL,
                  p_document_subtype varchar2 default NULL,p_withterms varchar2 default NULL) RETURN number is

l_request_id number;
-- BUG 5674144
l_org_id NUMBER;
x_progress varchar2(200);

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
--Bug4670662 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null


IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T'  and
    g_document_subtype <>'PLANNED') THEN
--Launching the Dispatch Purchase Order Concurrent Program

    l_request_id := fnd_request.submit_request('PO',
        'POXPOPDF',
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
	 p_doc_num       ,--P_po_num_to
	 null           ,--P_relaese_num_from
         null           ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
	 null           ,--P_approved_flag
         'N'             ,--P_test_flag
	 null           ,--P_print_releases
         null           ,--P_sortby
	 p_user_id      ,--P_user_id
	 null           ,--P_fax_enable
	 null           ,--P_fax_number
	 'Y'            ,--P_BLANKET_LINES
	'Communicate'   ,--View_or_Communicate,
         p_withterms    ,--P_WITHTERMS Bug#5194244 instead of 'Y'
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
        p_document_id   ,--P_DOCUMENT_ID Bug#5194244
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
       p_document_subtype, --P_DOCUMENT_TYPE Bug#5194244
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL);
--<POC FPJ End>
ELSE
-- BUG 5674144
-- After the context fix we are submitting the print request
-- in the context of the approver. Though we are setting the org context
-- before submitting the request, CP code is going to reset the org
-- context corresponding to the current user context.This would result
-- in a wrong document getting printed if  the user approver responds to
-- approval notification from a different responsibility. Hence here, we
-- are passing the org_id to the POXPRPOP report and in the report using
-- the org id to set the context.
select org_id into l_org_id from po_headers_all
where po_header_id = p_document_id;

    l_request_id := fnd_request.submit_request('PO',
                'POXPPO',
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO='   || p_doc_num,
                'P_USER_ID=' || p_user_id,
                'P_QTY_PRECISION=' || p_qty_precision,
                'P_BLANKET_LINES=Y',
                'P_PRINT_RELEASES=N',
		'ORG_ID='||to_char(l_org_id),
                fnd_global.local_chr(0),
		NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);
END IF;

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Print_PO',x_progress);
        raise;

END Print_PO;





--DKC 10/10/99
FUNCTION Fax_PO(p_doc_num varchar2, p_qty_precision varchar,
                p_user_id varchar2, p_fax_enable varchar2,
		p_fax_num varchar2,p_document_id number default NULL,
		p_document_subtype varchar2,p_withterms varchar2) RETURN number is

l_request_id number;
x_progress varchar2(200);
-- bug 5674144
l_org_id NUMBER;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' and
    g_document_subtype <>'PLANNED') THEN

--Launching the Dispatch Purchase Order Concurrent Program
--Bug4670662 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null

l_request_id := fnd_request.submit_request('PO',
        'POXPOFAX'      ,-- Bug 6029616
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num       ,--P_po_num_to
         null           ,--P_relaese_num_from
         null           ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'             ,--P_test_flag
         null           ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         'Y'            ,--P_fax_enable
         p_fax_num      ,--P_fax_number
         'Y'            ,--P_BLANKET_LINES
         'Communicate'   ,--View_or_Communicate,
         p_withterms    ,--P_WITHTERMS  Bug#5194244 instead of 'Y'
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id  ,--P_DOCUMENT_ID Bug#5194244
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
         p_document_subtype,--P_DOCUMENT_TYPE Bug#5194244
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL);

--<POC FPJ End>

ELSE
-- BUG 5674144
-- After the context fix we are submitting the print request
-- in the context of the approver. Though we are setting the org context
-- before submitting the request, CP code is going to reset the org
-- context corresponding to the current user context.This would result
-- in a wrong document getting printed if  the user approver responds to
-- approval notification from a different responsibility. Hence here, we
-- are passing the org_id to the POXPRPOP report and in the report using
-- the org id to set the context.
select org_id into l_org_id from po_headers_all
where po_header_id = p_document_id;

    l_request_id := fnd_request.submit_request('PO',
                'POXFPO',       -- bug 6629675
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO='   || p_doc_num,
                'P_USER_ID=' || p_user_id,
                'P_QTY_PRECISION=' || p_qty_precision,
		'P_FAX_ENABLE=' || p_fax_enable,
		'P_FAX_NUM=' || p_fax_num,
                'P_BLANKET_LINES=Y',   -- Bug 3672088
                'P_PRINT_RELEASES=N',  -- Bug 3672088
		'ORG_ID='||to_char(l_org_id),
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL);
END IF;

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Fax_PO',x_progress);
        raise;

END Fax_PO;





FUNCTION Print_Release(p_doc_num varchar2, p_qty_precision varchar,
             p_release_num varchar2, p_user_id varchar2,p_document_id number default NULL) RETURN number is

l_request_id number;
x_progress varchar2(200);
-- bug 5674144
l_org_id NUMBER;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' and
    g_document_subtype = 'BLANKET') THEN
--Launching the Dispatch Purchase Order Concurrent Program
--Bug4670662 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null

l_request_id := fnd_request.submit_request('PO',
        'POXPOPDF',
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num      ,--P_po_num_to
         p_release_num  ,--P_release_num_from
         p_release_num  ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'            ,--P_test_flag
         'Y'            ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         null           ,--P_fax_enable
         null           ,--P_fax_number
         'Y'            ,--P_BLANKET_LINES
         'Communicate'   ,--View_or_Communicate,
         'N'            ,--P_WITHTERMS
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id  ,--P_DOCUMENT_ID Bug#5194244
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
         'RELEASE'      ,--P_DOCUMENT_TYPE  Bug#5194244
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL);
--<POC FPJ End >
ELSE
-- BUG 5674144
-- After the context fix we are submitting the print request
-- in the context of the approver. Though we are setting the org context
-- before submitting the request, CP code is going to reset the org
-- context corresponding to the current user context.This would result
-- in a wrong document getting printed if  the user approver responds to
-- approval notification from a different responsibility. Hence here, we
-- are passing the org_id to the POXPRPOP report and in the report using
-- the org id to set the context.
select org_id into l_org_id from po_releases_all
where po_release_id = p_document_id;

     -- FRKHAN 09/17/98. Change 'p_doc_num || p_release_num' from P_RELEASE_NUM_FROM and TO to just p_release_num
     l_request_id := fnd_request.submit_request('PO',
                'POXPPO',
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_USER_ID=' || p_user_id,
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO=' || p_doc_num,
                'P_RELEASE_NUM_FROM=' || p_release_num,
                'P_RELEASE_NUM_TO='   || p_release_num,
                'P_QTY_PRECISION=' || p_qty_precision,
                'P_BLANKET_LINES=N',
                'P_PRINT_RELEASES=Y',
		'ORG_ID='||to_char(l_org_id),
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

END IF;

    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Print_Release',x_progress);
        raise;

END Print_Release;




-- Auto Fax
-- DKC 10/10/99
FUNCTION Fax_Release(p_doc_num varchar2, p_qty_precision varchar,
             	p_release_num varchar2, p_user_id varchar2,
		p_fax_enable varchar2, p_fax_num varchar2,p_document_id number default NULL) RETURN number is

l_request_id number;
x_progress varchar2(200);
-- bug 5674144
l_org_id NUMBER;

BEGIN
--<POC FPJ Start>
--Bug#3528330 used the procedure po_communication_profile() to check for the
--PO output format option instead of checking for the installation of
--XDO product
IF (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T' and
    g_document_subtype = 'BLANKET') THEN
--Launching the Dispatch Purchase Order Concurrent Program
--Bug4670662 Pass the parameters P_PO_TEMPLATE_CODE and P_CONTRACT_TEMPLATE_CODE as null

l_request_id := fnd_request.submit_request('PO',
        'POXPOFAX',    --bug6629675
         null,
         null,
         false,
        'R',--P_report_type
         null           ,--P_agent_name
         p_doc_num      ,--P_po_num_from
         p_doc_num       ,--P_po_num_to
         p_release_num  ,--P_relaese_num_from
         p_release_num  ,--P_release_num_to
         null           ,--P_date_from
         null           ,--P_date_to
         null           ,--P_approved_flag
         'N'            ,--P_test_flag
         'Y'            ,--P_print_releases
         null           ,--P_sortby
         p_user_id      ,--P_user_id
         'Y'            ,--P_fax_enable
         p_fax_num      ,--P_fax_number
         'N'            ,--P_BLANKET_LINES
         'Communicate'   ,--View_or_Communicate,
         'N'            ,--P_WITHTERMS
         'N'            ,--P_storeFlag Bug#3528330 Changed to "N"
         'Y'            ,--P_PRINT_FLAG
         p_document_id  ,--P_DOCUMENT_ID Bug#5194244
         null           ,--P_REVISION_NUM
         null           ,--P_AUTHORIZATION_STATUS
        'RELEASE'       ,--P_DOCUMENT_TYPEBug#5194244
         null           ,--P_PO_TEMPLATE_CODE
         null           ,--P_CONTRACT_TEMPLATE_CODE
         fnd_global.local_chr(0),
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL, NULL);
--<POC FPJ End>

ELSE
-- BUG 5674144
-- After the context fix we are submitting the print request
-- in the context of the approver. Though we are setting the org context
-- before submitting the request, CP code is going to reset the org
-- context corresponding to the current user context.This would result
-- in a wrong document getting printed if  the user approver responds to
-- approval notification from a different responsibility. Hence here, we
-- are passing the org_id to the POXPRPOP report and in the report using
-- the org id to set the context.
select org_id into l_org_id from po_releases_all
where po_release_id = p_document_id;

     l_request_id := fnd_request.submit_request('PO',
                'POXFPO',  -- bug 6629675
                null,
                null,
                false,
                'P_REPORT_TYPE=R',
                'P_TEST_FLAG=N',
                'P_USER_ID=' || p_user_id,
                'P_PO_NUM_FROM=' || p_doc_num,
                'P_PO_NUM_TO=' || p_doc_num,
                'P_RELEASE_NUM_FROM=' || p_release_num,
                'P_RELEASE_NUM_TO='   || p_release_num,
                'P_QTY_PRECISION=' || p_qty_precision,
		'P_FAX_ENABLE=' || p_fax_enable,
		'P_FAX_NUM=' || p_fax_num,
                'P_BLANKET_LINES=N',   -- Bug 3672088
                'P_PRINT_RELEASES=Y',  -- Bug 3672088
		'ORG_ID='||to_char(l_org_id),
                fnd_global.local_chr(0),
                NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL);
END IF;


    return(l_request_id);

EXCEPTION

   WHEN OTHERS THEN
        wf_core.context('PO_REQAPPROVAL_INIT1','Fax_Release',x_progress);
        raise;

END Fax_Release;






--
-- Is apps source code POR ?
-- Determines if the requisition is created
-- through web requisition 4.0 or higher
--
procedure is_apps_source_POR(itemtype in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_document_id               NUMBER;
  l_apps_source_code          VARCHAR2(25)  :='';

  l_doc_string varchar2(200);
  l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122

BEGIN
   IF (funcmode='RUN') THEN
    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    IF l_document_id IS NOT NULL THEN

      select nvl(apps_source_code, 'PO')
      into   l_apps_source_code
      from   po_requisition_headers_all
      where  requisition_header_id=l_document_id;

    END IF;

    l_progress:='002-'||to_char(l_document_id);

    /* POR = Web Requisition 4.0 or higher */
    IF (l_apps_source_code='POR') THEN

     resultout:='COMPLETE:'||'Y';
     return;
    ELSE
     resultout:='COMPLETE:'||'N';
     return;

    END IF;

   END IF; -- run mode

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','is_apps_source_POR',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_APPS_SOURCE_POR',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    RAISE;

END is_apps_source_POR;

-- Bug#3147435
-- Is contractor status PENDING?
-- Determines if the requisition has contractor_status PENDING at header level
procedure is_contractor_status_pending(itemtype in varchar2,
                                       itemkey         in varchar2,
                                       actid           in number,
                                       funcmode        in varchar2,
                                       resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_contractor_status         VARCHAR2(25)  := '';

  l_doc_string varchar2(200);
  l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
  l_document_id number; /* 6874681 */

BEGIN
   l_progress:='001-'||funcmode;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF (funcmode='RUN') THEN
    l_contractor_status := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CONTRACTOR_STATUS');

    /* 6874681 */
    l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'DOCUMENT_ID');

    l_progress:='002-'||l_contractor_status;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (l_contractor_status = 'PENDING') THEN
     --Bug#3268971
     --Setting the item attribute value to Y, which will be used in
     --ReqLinesNOtificationsCO to determine whether to display the helptext
     --for contractor assignment
     PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONTRACTOR_ASSIGNMENT_REQD',
                                       avalue   => 'Y' );
     resultout:='COMPLETE:'||'Y';

     l_progress:='003-'||resultout;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     return;
    ELSE
     resultout:='COMPLETE:'||'N';

     l_progress:='004-'||resultout;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     return;
    END IF;

   END IF; -- run mode

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','is_contractor_status_pending',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.is_contractor_status_pending',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    RAISE;

END is_contractor_status_pending;

-- Bug 823167 kbenjami
--
-- Is the Submitter the last Approver?
-- Checks to see if submitter is also the current
-- approver of the doc.
-- Prevents two notifications from being sent to the
-- same person.
--
procedure Is_Submitter_Last_Approver(itemtype 	in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2    ) is

approver_id	number;
preparer_id	number;

x_username    varchar2(100);

x_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122
l_document_id number; /* 6874681 */

BEGIN
  x_progress := 'PO_REQAPPROVAL_INIT1.Is_Submitter_Last_Approver: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;

  preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					      itemkey => itemkey,
					      aname => 'PREPARER_ID');

  approver_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
					      itemkey => itemkey,
					      aname => 'FORWARD_FROM_ID');

  x_username := wf_engine.GetItemAttrText (itemtype => itemtype,
					      itemkey => itemkey,
					      aname => 'FORWARD_FROM_USER_NAME');

  /* 6874681 */
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');

  -- return Y if forward from user name is null.

  if (preparer_id = approver_id OR x_username is null) then
    resultout := wf_engine.eng_completed || ':' || 'Y';
    x_progress := 'PO_REQAPPROVAL_INIT1.Is_Submitter_Last_Approver: 02. Result = Yes';
  else
    resultout := wf_engine.eng_completed || ':' || 'N';
    x_progress := 'PO_REQAPPROVAL_INIT1.Is_Submitter_Last_Approver: 02. Result = No';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_INIT1','Is_Submitter_Last_Approver',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.IS_SUBMITTER_LAST_APPROVER',l_document_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

end Is_Submitter_Last_Approver;

--

function get_error_doc(itemtype in varchar2,
                       itemkey  in varchar2) return varchar2
IS
  l_doc_string varchar2(200);

  l_document_type varchar2(25);
  l_document_subtype varchar2(25);
  l_document_id number;
  l_org_id number;

BEGIN

  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  fnd_client_info.set_org_context(to_char(l_org_id));

  IF (l_document_type IN ('PO', 'PA')) THEN
    select st.DISPLAYED_FIELD || ' ' ||
           ty.DISPLAYED_FIELD || ' ' ||
           hd.SEGMENT1
      into l_doc_string
      from po_headers hd,
           po_lookup_codes ty,
           po_lookup_codes st
     where hd.po_header_id = l_document_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = l_document_type
       and st.lookup_type = 'DOCUMENT SUBTYPE'
       and st.lookup_code = hd.TYPE_LOOKUP_CODE;
  ELSIF (l_document_type = 'REQUISITION') THEN
    select st.DISPLAYED_FIELD || ' ' ||
           ty.DISPLAYED_FIELD || ' ' ||
           hd.SEGMENT1
      into l_doc_string
      from po_requisition_headers hd,
           po_lookup_codes ty,
           po_lookup_codes st
     where hd.requisition_header_id = l_document_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = l_document_type
       and st.lookup_type = 'REQUISITION TYPE'
       and st.lookup_code = hd.TYPE_LOOKUP_CODE;
  ELSIF (l_document_type = 'RELEASE') THEN
    select st.DISPLAYED_FIELD || ' ' ||
           ty.DISPLAYED_FIELD || ' ' ||
           hd.SEGMENT1 || '-' ||
           rl.RELEASE_NUM
      into l_doc_string
      from po_headers hd,
           po_releases rl,
           po_lookup_codes ty,
           po_lookup_codes st
     where rl.po_release_id = l_document_id
       and rl.po_header_id = hd.po_header_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = l_document_type
       and st.lookup_type = 'DOCUMENT SUBTYPE'
       and st.lookup_code = rl.RELEASE_TYPE;
  END IF;

  return(l_doc_string);

EXCEPTION
 WHEN OTHERS THEN
   RAISE;

END get_error_doc;

function get_preparer_user_name(itemtype in varchar2,
                                itemkey  in varchar2) return varchar2
IS

  l_name          WF_USERS.name%TYPE; --Bug7562122
  l_preparer_id   number;
  l_disp          WF_USERS.display_name%TYPE; --Bug7562122

BEGIN

  l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'PREPARER_ID');

  PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, l_name, l_disp);

  return(l_name);

END;

procedure send_error_notif(itemtype    in varchar2,
                           itemkey     in varchar2,
                           username    in varchar2,
                           doc         in varchar2,
                           msg         in varchar2,
                           loc         in varchar2,
			   document_id in number) is  /* 6874681 */

pragma AUTONOMOUS_TRANSACTION;

/* Bug# 2074072: kagarwal
** Desc: Calling wf process to send Error Notification
** instead of the wf API.
*/

  -- l_nid NUMBER;
  l_seq                varchar2(25);    -- 8435560
  Err_ItemKey          varchar2(240);
  Err_ItemType         varchar2(240):= 'POERROR';
  l_document_id	       number;
  x_progress           varchar2(300);

BEGIN

 -- To be used only for PO and Req Approval wf

   x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 10';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 20'
                  ||' username: '|| username
                  ||' doc: '|| doc
                  ||' location: '|| loc
                  ||' error msg: '|| msg;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;


   if username is not null and doc is not null then

    /*  l_nid  := wf_notification.Send(username,
                                     itemtype,
                                     'PLSQL_ERROR_OCCURS',
                                     null, null, null, null);

      wf_Notification.SetAttrText(l_nid, 'PLSQL_ERROR_DOC', doc);
      wf_Notification.SetAttrText(l_nid, 'PLSQL_ERROR_LOC', loc);
      wf_Notification.SetAttrText(l_nid, 'PLSQL_ERROR_MSG', msg);
    */

      -- Get Document Id for the Errored Item.

      IF (document_id IS NULL) THEN  /* 6874681 Only if the passed value is null then fetch the document_id */

	l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
						      itemkey  => itemkey,
						      aname    => 'DOCUMENT_ID');
      ELSE   /* 6874681 Else retain the passed value */

	l_document_id := document_id;

      END IF;  /* 6874681 */

      select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;
      Err_ItemKey := to_char(l_document_id) || '-' || l_seq;


      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 50'
                      ||' Parent Itemtype: '|| ItemType
                      ||' Parent Itemkey: '|| ItemKey
                      ||' Error Itemtype: '|| Err_ItemType
                      ||' Error Itemkey: '|| Err_ItemKey;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      wf_engine.CreateProcess( ItemType => Err_ItemType,
                              ItemKey  => Err_ItemKey,
                              process  => 'PLSQL_ERROR_NOTIF');

      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 70';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      -- Set the attributes
     wf_engine.SetItemAttrText ( itemtype   => Err_ItemType,
                                 itemkey    => Err_ItemKey,
                                 aname      => 'PLSQL_ERROR_DOC',
                                 avalue     =>  doc);

     --
     wf_engine.SetItemAttrText ( itemtype   => Err_ItemType,
                                 itemkey    => Err_ItemKey,
                                 aname      => 'PLSQL_ERROR_LOC',
                                 avalue     => loc);
     --
     wf_engine.SetItemAttrText ( itemtype        => Err_ItemType,
                                 itemkey         => Err_ItemKey,
                                 aname           => 'PLSQL_ERROR_MSG',
                                 avalue          =>  msg);
     --
     wf_engine.SetItemAttrText ( itemtype   => Err_ItemType,
                                 itemkey    => Err_ItemKey,
                                 aname      => 'PREPARER_USER_NAME' ,
                                 avalue     => username);
     --
      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: 100';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;


      wf_engine.StartProcess(itemtype        => Err_ItemType,
                             itemkey         => Err_ItemKey);

      x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif:  900';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      commit;

  end if;

EXCEPTION
 WHEN OTHERS THEN
   x_progress :=  'PO_REQAPPROVAL_INIT1.send_error_notif: '|| sqlerrm;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;
   RAISE;

END send_error_notif;

-- This procedure will close all the notification of all the
-- previous approval WF.

procedure CLOSE_OLD_NOTIF(itemtype in varchar2,
                          itemkey  in varchar2) is
pragma AUTONOMOUS_TRANSACTION;
begin

    update wf_notifications set status = 'CLOSED'
     where notification_id in (
           select ias.notification_id
             from wf_item_activity_statuses ias,
	          wf_notifications ntf
            where ias.item_type = itemtype
              and ias.item_key  = itemkey
              and ntf.notification_id  = ias.notification_id);

    commit;

end;

/* Bug# 1739194: kagarwal
** Desc: Added new procedure to check the document manager error.
*/
procedure Is_Document_Manager_Error_1_2(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_error_number   NUMBER;

BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'Is_Document_Manager_Error_1_2: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_error_number:=
   wf_engine.GetItemAttrNumber (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'DOC_MGR_ERROR_NUM');

   l_progress := 'Is_Document_Manager_Error_1_2: 002 - '||
                  to_char(l_error_number);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF (l_error_number = 1 or l_error_number = 2) THEN
     resultout:='COMPLETE:'||'Y';
     return;

   ELSE
     resultout:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Is_Document_Manager_Error_1_2',
                    itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';

END Is_Document_Manager_Error_1_2;



/**************************************************************************/
procedure PROFILE_VALUE_CHECK(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2    )  is
x_progress    varchar2(300);
l_po_email_add_prof	varchar2(60);
l_prof_value varchar2(2);
l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE; --Bug7562122

BEGIN
   x_progress := 'PO_REQAPPROVAL_INIT1.profile_value_check: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_po_email_add_prof := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'EMAIL_ADD_FROM_PROFILE');

  /* the value of l_po_email_add_prof has a value or it is null*/
  IF  l_po_email_add_prof is null THEN
	l_prof_value := 'N';
  ELSE
       l_prof_value := 'Y';
  END IF;

  --
        resultout := wf_engine.eng_completed || ':' || l_prof_value ;
  --
  x_progress := 'PO_REQAPPROVAL_INIT1.profile_value_check: 02. Result= ' || l_prof_value;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_INIT1', 'PROFILE_VALUE_CHECK' ,
                    itemtype, itemkey, x_progress);
    resultout:='COMPLETE:'||'N';

END;

procedure Check_Error_Count(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_count   NUMBER;
  l_error_count   NUMBER;
  l_item_type  varchar2(30);
  l_item_key  varchar2(30);

BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'CHECK_ERROR_COUNT: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_item_type :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_TYPE');
   l_item_key :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_KEY');
   l_count:= wf_engine.GetItemAttrNumber (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'RETRY_COUNT');


   Select count(*)
   into l_error_count
   from wf_items
   where parent_item_type=l_item_type
   and parent_item_key = l_item_key;


   IF (l_error_count <= l_count) then
     resultout:='COMPLETE:'||'Y'; -- retry
     return;

   ELSE
     resultout:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Check_Error_Count',
                    itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';
END Check_Error_Count;

procedure Initialise_Error(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_error_number number;
  l_name          WF_USERS.name%TYPE; --Bug7562122
  l_preparer_id   number;
  l_disp          WF_USERS.display_name%TYPE; --Bug7562122
  l_item_type  varchar2(30);
  l_item_key  varchar2(30);
  l_doc_err_num number;
  l_doc_type varchar2(25); /* Bug# 2655410 */
  l_doc_subtype varchar2(25);
 -- l_doc_subtype_disp varchar2(30);
  l_doc_type_disp    varchar2(240);
  l_orgid            number;
  l_ga_flag   varchar2(1) := null;  -- FPI GA

  l_doc_num          varchar2(30);
  l_sys_error_msg    varchar2(2000) :='';
  l_release_num_dash varchar2(30);
  l_release_num      number; --1942901

/* Bug# 2655410: kagarwal
** Desc: We will get the document type display value from
** po document types.
*/

cursor docDisp(p_doc_type varchar2, p_doc_subtype varchar2) is
select type_name
from po_document_types
where document_type_code = p_doc_type
and document_subtype = p_doc_subtype;


BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'Initialise_Error: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_item_type :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_TYPE');
   l_item_key :=wf_engine.GetItemAttrText (   itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'ERROR_ITEM_KEY');

/* Bug# 2708702 kagarwal
** Fix Details: Make all the Set and Get calls for parent item type to use the PO wrapper
** PO_WF_UTIL_PKG so that the missing attribute errors are ignored.
*/

   l_preparer_id := PO_WF_UTIL_PKG.GetItemAttrNumber (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'PREPARER_ID');

   PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, l_name, l_disp);

/* Bug# 2655410: kagarwal
** Desc: We will get the document type display value from
** po document types. Hence we need to get the doc type and subtype
** from the parent wf and then set the doc type display in the
** error wf.
**
** Also need to set the org context before calling the cursor
*/

   l_doc_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOCUMENT_SUBTYPE');

   l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOCUMENT_TYPE');

   IF l_doc_type = 'PA' AND l_doc_subtype = 'BLANKET' THEN

       l_ga_flag := PO_WF_UTIL_PKG.GetItemAttrText (itemtype    => l_item_type,
                                         itemkey  => l_item_key,
                                         aname    => 'GLOBAL_AGREEMENT_FLAG');
   END IF;

  /* If Global Agreement flag is 'Y' then no need to get the value from
  ** po document types as the message will be translated
  */

  if l_ga_flag = 'Y' then
     l_doc_type_disp := FND_MESSAGE.GET_STRING('PO','PO_GA_TYPE');
  else

      l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => l_item_type,
                                              itemkey  => l_item_key,
                                              aname    => 'ORG_ID');

      IF l_orgid is NOT NULL THEN

          fnd_client_info.set_org_context(to_char(l_orgid));

      END IF;

      OPEN docDisp(l_doc_type, l_doc_subtype);
      FETCH docDisp into l_doc_type_disp;
      CLOSE docDisp;

   end if; /* if l_ga_flag = 'Y' */

   l_doc_num := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOCUMENT_NUMBER');


   l_sys_error_msg := PO_WF_UTIL_PKG.GetItemAttrText (   itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'SYSADMIN_ERROR_MSG');

   l_release_num_dash := PO_WF_UTIL_PKG.GetItemAttrText (itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'RELEASE_NUM_DASH');

   l_release_num:= PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'RELEASE_NUM');

   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'PREPARER_USER_NAME' ,
                              avalue     => l_name);

/* Bug# 2655410: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/

/*   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'DOCUMENT_SUBTYPE_DISP' ,
                              avalue     => l_doc_subtype_disp);
*/
   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'DOCUMENT_TYPE_DISP' ,
                              avalue     => l_doc_type_disp);

   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'DOCUMENT_NUMBER' ,
                              avalue     => l_doc_num);

   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'RELEASE_NUM_DASH' ,
                              avalue     => l_release_num_dash);

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'RELEASE_NUM' ,
                              avalue     => l_release_num);


   l_error_number := PO_REQAPPROVAL_ACTION.doc_mgr_err_num;
   /* bug 1942091. Set the Error attributes */
   l_sys_error_msg := PO_REQAPPROVAL_ACTION.sysadmin_err_msg;

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'DOC_MGR_ERROR_NUM',
                                   avalue     => l_error_number);
   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'SYSADMIN_ERROR_MSG' ,
                              avalue     => l_sys_error_msg);
   /* Set the parents doc manager error number and sysadmin error mesg*/
   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => l_item_type,
                                   itemkey    => l_item_key,
                                   aname      => 'DOC_MGR_ERROR_NUM',
                                   avalue     => l_error_number);
   PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => l_item_type,
                              itemkey    => l_item_key,
                              aname      => 'SYSADMIN_ERROR_MSG' ,
                              avalue     => l_sys_error_msg);

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Initialise_Error',
                    itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';
END Initialise_Error;



procedure acceptance_required   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	l_acceptance_flag po_headers_all.acceptance_required_flag%TYPE;
	x_progress              varchar2(3) := '000';
	l_document_id number;
	l_document_type po_document_types.document_type_code%type;
	l_document_subtype po_document_types.document_subtype%type;
	l_when_to_archive po_document_types.archive_external_revision_code%type;
	l_archive_result varchar2(1);
begin
/*
1. Bug#2742276: To find out if acceptance is required, older version used to check workflow
attribute ACCEPTANCE_REQUIRED.
This may not be correct since acceptance_requried_flag may be updated in the DB.
Thus, we shall query acceptance_required_flag from po_headers/po_releases view.

*/
	x_progress := '001';

	l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

	l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

	 l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

	if(l_document_type <> 'RELEASE') then
		select acceptance_required_flag
		into l_acceptance_flag
		from po_headers_all --Bug 4411349
		where po_header_Id = l_document_id;
	else
		select acceptance_required_flag
		into l_acceptance_flag
		from po_releases_all --Bug 4411349
		where po_release_Id = l_document_id;
	end if;

/* BINDING FPJ  START*/
    IF nvl(l_acceptance_flag,'N') <> 'N' THEN
       result := 'COMPLETE:' || 'Y';
    ELSE
       result := 'COMPLETE:' || 'N';
    END IF;
/* BINDING FPJ  END*/

exception
  WHEN OTHERS THEN
    	wf_core.context('PO_REQAPPROVAL_INIT1','acceptance_required',x_progress);
    	raise;
end;

--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_acceptance_result	fnd_new_messages.message_text%type := null; -- Bug 2821341
	x_org_id		number;
	x_user_id		number;
        x_document_id           number;
        x_document_type_code    varchar2(30);
        x_vendor                po_vendors.vendor_name%type; /* Bug 6760338 Changing the size as equal to the column size of vendor_name */
        x_supp_user_name        WF_USERS.name%TYPE; --Bug7562122
        x_supplier_displayname  WF_USERS.display_name%TYPE; --Bug7562122
	-- x_accp_type		varchar2(100);
	l_nid                   number;
	l_ntf_role_name         WF_USERS.name%TYPE; --Bug7562122

begin

  -- set the org context
  x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	    itemkey  => itemkey,
                            	 	    aname    => 'ORG_ID');

  fnd_client_info.set_org_context(to_char(x_org_id));

  x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOCUMENT_ID');

  x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_TYPE');

   -- commented out the usage of accptance_type (FPI)
  /* x_accp_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               	itemkey  => itemkey,
                                               	aname    => 'ACCEPTANCE_TYPE'); */

  x_acceptance_result := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               		itemkey  => itemkey,
                                               		aname    => 'ACCEPTANCE_RESULT');

if x_document_type_code <> 'RELEASE' then
        select pov.vendor_name
        into x_vendor
        from po_vendors pov,po_headers poh
        where pov.vendor_id = poh.vendor_id
        and poh.po_header_id=x_document_id;
else
        select pov.vendor_name
        into x_vendor
        from po_releases por,po_headers poh,po_vendors pov
        where por.po_release_id = x_document_id
        and por.po_header_id    = poh.po_header_id
        and poh.vendor_id       = pov.vendor_id;
end if;



      if (x_document_type_code <> 'RELEASE') then

        --dbms_output.put_line('For std pos');
       begin
        select a.notification_id, a.recipient_role
        INTO   l_nid, l_ntf_role_name
        from   wf_notifications a,
               wf_item_activity_statuses wa
        where  itemkey=wa.item_key
        and    itemtype=wa.item_type
        and    a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
        and    a.notification_id=wa.notification_id and a.status = 'CLOSED';
       exception
        when others then l_nid := null;
       end;

       else
       begin
        --dbms_output.put_line('For Releases');
        select a.notification_id, a.recipient_role
        INTO  l_nid, l_ntf_role_name
        from  wf_notifications a,
              wf_item_activity_statuses wa
        where itemkey=wa.item_key
        and   itemtype=wa.item_type
        and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
        and   a.notification_id=wa.notification_id and a.status = 'CLOSED';
       exception
        when others then l_nid := null;
      end;
    end if;

    if (l_nid is null) then
      --we do not want to continue if the notification is not closed.
      return;
    else
     x_supp_user_name := wf_notification.responder(l_nid);
    end if;


   PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => x_vendor);

   -- commented out the usage of accptance_type (FPI)
  /* IF (x_accp_type is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  (	itemtype => itemtype,
                                   	itemkey  => itemkey,
                                   	aname    => 'ACCEPTANCE_TYPE',
                                   	avalue   => 'Accepted' );
   END IF; */


   IF (x_acceptance_result is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  ( itemtype => itemtype,
                              		itemkey  => itemkey,
                              		aname    => 'ACCEPTANCE_RESULT',
                              		avalue   => fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPTED') );
   END IF;


 if (substr(x_supp_user_name, 1, 6) = 'email:') then
     --Get the username and store that in the supplier_user_name.
      x_supp_user_name := PO_ChangeOrderWF_PVT.getEmailResponderUserName(x_supp_user_name, l_ntf_role_name);
 end if;


 PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SUPPLIER_USER_NAME',
                                 avalue   => x_supp_user_name);



  -- insert acceptance record.
  Insert_Acc_Rejection_Row(itemtype, itemkey, actid, 'Y');

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('PO_REQAPPROVAL_INIT1','Register_acceptance',x_progress);
    	raise;
end;

--

procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_acceptance_result	fnd_new_messages.message_text%type := null;  -- Bug 2821341
	x_org_id		number;
        x_document_id           number;
        x_document_type_code    varchar2(30);
        x_vendor                varchar2(80);
        x_supp_user_name        WF_USERS.name%TYPE; --Bug7562122
        x_supplier_displayname  WF_USERS.display_name%TYPE; --Bug7562122
	--x_accp_type		varchar2(100);
	l_revision_num number;
	l_is_hdr_rejected varchar2(1);
	l_return_status varchar2(1);
l_role_name WF_USERS.name%TYPE; --Bug7562122
l_role_display_name WF_USERS.display_name%TYPE; --Bug7562122
l_nid  number;
l_ntf_role_name  WF_USERS.name%TYPE; --Bug7562122

begin

  -- set the org context
  x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	    itemkey  => itemkey,
                            	 	    aname    => 'ORG_ID');

  fnd_client_info.set_org_context(to_char(x_org_id));

  x_progress := '001';
  x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOCUMENT_ID');

  x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_TYPE');


  -- commented out the usage of accptance_type (FPI)
  /* x_accp_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               	itemkey  => itemkey,
                                               	aname    => 'ACCEPTANCE_TYPE'); */

  x_acceptance_result := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               		itemkey  => itemkey,
                                               		aname    => 'ACCEPTANCE_RESULT');

if x_document_type_code <> 'RELEASE' then
        select
        	pov.vendor_name,
        	poh.revision_num
        into
        	x_vendor,
        	l_revision_num
        from po_vendors pov,po_headers poh
        where pov.vendor_id = poh.vendor_id
        and poh.po_header_id=x_document_id;

        x_progress := '002';
        PO_ChangeOrderWF_PVT.IsPOHeaderRejected(
							1.0,
							l_return_status,
							x_document_id,
							null,
							l_revision_num,
							l_is_hdr_rejected);
else
        select
        	pov.vendor_name,
        	por.revision_num
        into
        	x_vendor,
        	l_revision_num
        from po_releases por,po_headers poh,po_vendors pov
        where por.po_release_id = x_document_id
        and por.po_header_id    = poh.po_header_id
        and poh.vendor_id       = pov.vendor_id;

    	x_progress := '003';
        PO_ChangeOrderWF_PVT.IsPOHeaderRejected(
							1.0,
							l_return_status,
							null,
							x_document_id,
							l_revision_num,
							l_is_hdr_rejected);
end if;


   if (x_document_type_code <> 'RELEASE') then

           --dbms_output.put_line('For std pos');
          begin
           select a.notification_id, a.recipient_role
           INTO   l_nid, l_ntf_role_name
           from   wf_notifications a,
                  wf_item_activity_statuses wa
           where  itemkey=wa.item_key
           and    itemtype=wa.item_type
           and    a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
           and    a.notification_id=wa.notification_id and a.status = 'CLOSED';
          exception
           when others then l_nid := null;
          end;

          else
          begin
           --dbms_output.put_line('For Releases');
           select a.notification_id, a.recipient_role
           INTO  l_nid, l_ntf_role_name
           from  wf_notifications a,
                 wf_item_activity_statuses wa
           where itemkey=wa.item_key
           and   itemtype=wa.item_type
           and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
           and   a.notification_id=wa.notification_id and a.status = 'CLOSED';
          exception
           when others then l_nid := null;
         end;
       end if;

       if (l_nid is null) then
           --We do not want to continue if the notification is not closed.
           return;
       else
         x_supp_user_name := wf_notification.responder(l_nid);
       end if;


  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => x_vendor);

   -- commented out the usage of accptance_type (FPI)
   /* IF (x_accp_type is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  (	itemtype => itemtype,
                                   	itemkey  => itemkey,
                                   	aname    => 'ACCEPTANCE_TYPE',
                                   	avalue   => 'Rejected' );
   END IF; */


   IF (x_acceptance_result is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  (	itemtype => itemtype,
                              		itemkey  => itemkey,
                              		aname    => 'ACCEPTANCE_RESULT',
                              		avalue   => 'Rejected' );
   END IF;


  if (substr(x_supp_user_name, 1, 6) = 'email:') then
      --Get the username and store that in the supplier_user_name.
       x_supp_user_name := PO_ChangeOrderWF_PVT.getEmailResponderUserName(x_supp_user_name, l_ntf_role_name);
   end if;

  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER_USER_NAME',
                                   avalue   => x_supp_user_name);



  -- insert rejection record.
  if(l_is_hdr_rejected = 'Y') then
  	x_progress := '004';
	Insert_Acc_Rejection_Row(itemtype, itemkey, actid, 'N');
  else
  	x_progress := '005';
	wf_directory.createadhocrole(
		l_role_name ,
		l_role_display_name ,
		null,
		null,
		null,
		'MAILHTML',
		null,
		null,
		null,
		'ACTIVE',
		sysdate+1);
    PO_WF_UTIL_PKG.SetItemAttrText  (	itemtype => itemtype,
                              		itemkey  => itemkey,
                              		aname    => 'BUYER_USER_NAME',
                              		avalue   => l_role_name);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('PO_REQAPPROVAL_INIT1','Register_rejection',x_progress);
    	raise;
end;


Procedure Insert_Acc_Rejection_Row(itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in  number,
				   flag		   in  varchar2)
is

   x_row_id             varchar2(30);
  -- Bug 2850566
  -- x_Acceptance_id      number;
  -- x_Last_Update_Date   date           	:=  TRUNC(SYSDATE);
  -- x_Last_Updated_By    number         	:=  fnd_global.user_id;
  -- End of Bug 2850566

   x_Creation_Date      date           	:=  TRUNC(SYSDATE);
   x_Created_By         number         	:=  fnd_global.user_id;
   x_Po_Header_Id       number;
   x_Po_Release_Id      number;
   x_Action             varchar2(240)	:= 'NEW';
   x_Action_Date        date    	:=  TRUNC(SYSDATE);
   x_Employee_Id        number;
   x_Revision_Num       number;
   x_Accepted_Flag      varchar2(1)	:= flag;
  -- x_Acceptance_Lookup_Code varchar2(25);
   x_document_id	number;
   x_document_type_code varchar2(30);
   x_acceptance_note	PO_ACCEPTANCES.note%TYPE;	--bug 2178922

   --  Bug 2850566
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_Last_Update_Date   PO_ACCEPTANCES.last_update_date%TYPE;
   l_Last_Updated_By    PO_ACCEPTANCES.last_updated_by%TYPE;
   l_acc_po_header_id   PO_HEADERS_ALL.po_header_id%TYPE;
   l_acceptance_id      PO_ACCEPTANCES.acceptance_id%TYPE;
   --  End of Bug 2850566
   l_rspndr_usr_name    fnd_user.user_name%TYPE := '';
   l_accepting_party varchar2(1);
begin
    -- Bug 2850566
    -- Commented out the select statement as it is handled in the PO_ACCEPTANCES rowhandler
	-- SELECT po_acceptances_s.nextval into x_Acceptance_id FROM sys.dual;

         -- commented out the usage of accptance_type (FPI)
	/* x_Acceptance_Lookup_Code := wf_engine.GetItemAttrText( itemtype => itemtype,
                                   		       	       itemkey  => itemkey,
                            	 	               	       aname    => 'ACCEPTANCE_LOOKUP_CODE'); */

	x_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => itemtype,
                                   		       	itemkey  => itemkey,
                            	 	               	aname    => 'ACCEPTANCE_COMMENTS');

         -- commented out the usage of accptance_type (FPI)
	/* if (x_Acceptance_Lookup_Code is NULL) then
	   if flag = 'Y' then
		x_Acceptance_Lookup_Code := 'Accepted Terms';
	   else
		x_Acceptance_Lookup_Code := 'Unacceptable Changes';
	   end if;
        end if; */

	x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_ID');

	x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                   		       	      itemkey  => itemkey,
                            	 	               	      aname    => 'DOCUMENT_TYPE');

	-- abort any outstanding acceptance notifications for any previous revision of the document.

	if x_document_type_code <> 'RELEASE' then
		x_Po_Header_Id := x_document_id;

		select revision_num,agent_id
		into x_revision_num,x_employee_id
		from po_headers
		where po_header_id = x_document_id;
	else
		x_Po_Release_Id := x_document_id;

		select po_header_id, revision_num,agent_id
		into x_Po_Header_Id, x_revision_num,x_employee_id
		from po_releases
		where po_release_id = x_document_id;
	end if;

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   IF x_po_release_id IS NULL THEN
     l_acc_po_header_id := x_po_header_id;
   ELSE
     l_acc_po_header_id := NULL;
   END IF;

    l_rspndr_usr_name := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                   		       	      itemkey  => itemkey,
                            	 	               	      aname    => 'SUPPLIER_USER_NAME');

    begin
      select user_id into   l_Last_Updated_By
      from fnd_user
      where user_name = upper(l_rspndr_usr_name);
      l_accepting_party := 'S';
    exception when others then
      --in case of non-isp users there wont be any suppliers
      l_Last_Updated_By := x_created_by;
      l_accepting_party := 'S';  --ack is always by supplier.
    end;
    l_Last_Update_Login := l_Last_Updated_By;

    PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid                  =>  l_rowid,
			x_acceptance_id			 =>  l_acceptance_id,
            x_Last_Update_Date       =>  l_Last_Update_Date,
            x_Last_Updated_By        =>  l_Last_Updated_By,
            x_Last_Update_Login      =>  l_Last_Update_Login,
			p_creation_date			 =>  x_Creation_Date,
			p_created_by			 =>  l_Last_Updated_By,
			p_po_header_id			 =>  l_acc_po_header_id,
			p_po_release_id			 =>  x_Po_Release_Id,
			p_action			     =>  x_Action,
			p_action_date			 =>  x_Action_Date,
			p_employee_id			 =>  null,
			p_revision_num			 =>  x_Revision_Num,
			p_accepted_flag			 =>  x_Accepted_Flag,
			p_note                   =>  x_acceptance_note,
			p_accepting_party        =>  l_accepting_party
			);

   --  End of Bug 2850566 RBAIRRAJ


   -- Reset the Acceptance required Flag
 /*  if x_po_release_id is not null then
      update po_releases
      set acceptance_required_flag = 'N',
      acceptance_due_date = ''
      where po_release_id = x_po_release_id;
   else
      update po_headers
      set acceptance_required_flag = 'N',
      acceptance_due_date = ''
      where po_header_id = x_po_header_id;
   end if; */
   Update_Acc_Req_Flg(x_po_header_id,x_po_release_id);
exception
	when others then
	raise;
end;

/* Bug#2353153: kagarwal
** Added new PROCEDURE set_doc_mgr_context as a global procedure as this
** is being used by wf apis present in different packages.
**
** Calling Set_doc_mgr_context to set the application context in procedures
** Set_Startup_Values() and Is_doc_preapproved() procedures for PO Approval
** to succeed when SLS SUB LEDGER SECURITY (IGI) is being used
*/

PROCEDURE Set_doc_mgr_context (itemtype VARCHAR2,
                               itemkey VARCHAR2)  is

l_user_id            number;
l_responsibility_id  number;
l_application_id     number;
l_orgid	     number; --RETRO FPI

x_progress  varchar2(200);
-- Bug 4125251 Start
X_User_Id            NUMBER;
X_Responsibility_Id  NUMBER;
X_Application_Id     NUMBER;
-- Bug 4125251 End

BEGIN

   -- Bug 5389914
   -- Bug 4125251 Start
   --Fnd_Profile.Get('USER_ID',X_User_Id);
   --Fnd_Profile.Get('RESP_ID',X_Responsibility_Id);
   --Fnd_Profile.Get('RESP_APPL_ID',X_Application_Id);
   -- Bug 4125251 End
   X_User_Id := fnd_global.user_id;
   X_Responsibility_Id := fnd_global.resp_id;
   X_Application_Id := fnd_global.resp_appl_id;

	IF (X_User_Id = -1) THEN
	    X_User_Id := NULL;
	END IF;

	IF (X_Responsibility_Id = -1) THEN
	    X_Responsibility_Id := NULL;
	END IF;

	IF (X_Application_Id = -1) THEN
	    X_Application_Id := NULL;
	END IF;

   l_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey          => itemkey,
                                      aname            => 'USER_ID');


   l_application_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'APPLICATION_ID');

   l_responsibility_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'RESPONSIBILITY_ID');


-- bug 3543578
-- Returning a Req from AutoCreate was nulling out the FND context.
-- No particular context is required for sending the notification in
-- the NOTIFY_RETURN_REQ process, so only change the context if
-- a valid context has been explicitly set for the workflow process.

--
-- Bug 4125251 Start
--
-- Set the application context to the logged-in user
-- if not null
--
      IF (NVL(X_USER_ID,-1)           = -1 OR
          NVL(X_RESPONSIBILITY_ID,-1) = -1 OR
          NVL(X_APPLICATION_ID,-1)    = -1)THEN
        IF X_USER_ID IS NOT NULL THEN
           FND_GLOBAL.APPS_INITIALIZE (X_USER_ID, L_RESPONSIBILITY_ID, L_APPLICATION_ID);
        ELSE
        -- Start fix for Bug 3543578
          IF (     L_USER_ID           IS NOT NULL
             AND   L_RESPONSIBILITY_ID IS NOT NULL
             AND   L_APPLICATION_ID    IS NOT NULL) THEN
             FND_GLOBAL.APPS_INITIALIZE (L_USER_ID, L_RESPONSIBILITY_ID, L_APPLICATION_ID);
          END IF;
        -- End fix for Bug 3543578
        END IF;
      END IF;
-- Bug 4125251 End
--

  /* RETRO FPI START.
   *  If we had set the org context for a different operating unit, the above
   *  fnd_global.APPS_INITIALIZE resets it back to the operating unit of
   *  the responsibility. So set the org context explicitly again.
  */
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    fnd_client_info.set_org_context(to_char(l_orgid));

  END IF;

  /* RETRO FPI END. */

   x_progress := 'PO_REQAPPROVAL_ACTION.set_doc_mgr_context. USER_ID= '
                || to_char(l_user_id)
                || ' APPLICATION_ID= ' || to_char(l_application_id)
                || 'RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Bug 3571038
  igi_sls_context_pkg.set_sls_context;


EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','set_doc_mgr_context',x_progress);
        raise;

END Set_doc_mgr_context;

/* RETROACTIVE FPI START */
procedure MassUpdate_Releases_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    ) IS
l_orgid       number;
l_massupdate_releases     varchar2(2);
l_progress    varchar2(300);

l_doc_string varchar2(200);
l_preparer_user_name  WF_USERS.name%TYPE; --Bug7562122
l_document_type PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

l_resp_id     number;
l_user_id     number;
l_appl_id     number;

BEGIN

  l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Yes_No: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');


  l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'USER_ID');

  l_resp_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONSIBILITY_ID');

  l_appl_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPLICATION_ID');

  /* Since the call may be started from background engine (new seesion),
   * need to ensure the fnd context is correct
   */

/* bug 4556437 context setting revamp : discrete context setting no longer
   required
  if (l_user_id is not null and
      l_resp_id is not null and
      l_appl_id is not null )then

     --
     -- Bug 4125251,replaced apps init call with set doc mgr context call
     --
       PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);
*/
        IF l_orgid is NOT NULL THEN
                fnd_client_info.set_org_context(to_char(l_orgid));
        END IF;

 -- end if;



  l_massupdate_releases := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'MASSUPDATE_RELEASES');
  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_TYPE');
  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype =>itemtype,
                                                itemkey => itemkey,
                                                aname => 'DOCUMENT_SUBTYPE');

  /* the value of CREATE_SOURCING_RULE should be Y or N */
  IF (nvl(l_massupdate_releases,'N') <> 'Y') THEN
    l_massupdate_releases := 'N';
  ELSE
    if (l_document_type = 'PA' and l_document_subtype = 'BLANKET') then
	l_massupdate_releases := 'Y';
    else
	l_massupdate_releases := 'N';
    end if;
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_massupdate_releases;

  l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Yes_No: 02. Result= ' || l_massupdate_releases;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  l_massupdate_releases := 'N';
    resultout := wf_engine.eng_completed || ':' || l_massupdate_releases;
END MassUpdate_Releases_Yes_No;

procedure MassUpdate_Releases_Workflow( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
				     resultout       out NOCOPY varchar2    )  is
l_document_id po_headers_all.po_header_id%type;
l_vendor_id   po_headers_all.vendor_id%type;
l_vendor_site_id   po_headers_all.vendor_site_id%type;
l_progress varchar2(300);
l_update_releases varchar2(1) := 'Y';
l_return_status varchar2(1) ;
l_communicate_update varchar2(30); -- Bug 3574895. Length same as that on the form field PO_APPROVE.COMMUNICATE_UPDATES
l_category_struct_id  mtl_category_sets_b.structure_id%type; -- Bug 3592705
begin

        l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Workflow: 01';

        /* Bug# 2846210
        ** Desc: Setting application context as this wf api will be executed
        ** after the background engine is run.
        */

       -- bug 4556437 : context setting no longer required here
       --_Set_doc_mgr_context(itemtype, itemkey);

	l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
	select poh.vendor_id, poh.vendor_site_id
	into l_vendor_id, l_vendor_site_id
	from po_headers poh
	where poh.po_header_id = l_document_id;

	--<Bug 3592705 Start> Retrieved the default structure for
        --     Purchasing from the view mtl_default_sets_view.
        Begin
           SELECT structure_id
           INTO   l_category_struct_id
           FROM   mtl_default_sets_view
           WHERE  functional_area_id = 2 ;
        Exception
           when others then
              l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Workflow: Could not find Category Structure Id';
              IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
              END IF;
              raise;
        End;
        --<Bug 3592705 End>

        --Bug 3574895. Retroactively Repriced Releases/Std PO's are not getting
        --             communicated to supplier. Need to pick up the workflow
        --             attribute CO_H_RETROACTIVE_SUPPLIER_COMM here from the
        --             Blanket Approval Workflow and pass it in the procedure
        --             call below so that it may be set correctly for Release/
        --             Standard PO Approval as well.
        l_communicate_update := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CO_H_RETROACTIVE_SUPPLIER_COMM');

	PO_RETROACTIVE_PRICING_PVT. MassUpdate_Releases
	      ( p_api_version => 1.0,
		p_validation_level => 100,
		p_vendor_id => l_vendor_id,
		p_vendor_site_id => l_vendor_site_id ,
		p_po_header_id => l_document_id,
		p_category_struct_id => l_category_struct_id, -- Bug 3592705
		p_category_from => null,
		p_category_to => null,
		p_item_from => null,
		p_item_to => null,
		p_date => null,
                p_communicate_update => l_communicate_update, --Bug 3574895
		x_return_status => l_return_status);

	If (l_return_status <> 'S') then
		l_update_releases := 'N';
	End if;

	l_progress := ': 02. Result= ' || l_update_releases;
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
	END IF;
	resultout := wf_engine.eng_completed || ':' || l_update_releases;
EXCEPTION
  WHEN OTHERS THEN
	l_update_releases := 'N';
  	l_progress := 'PO_REQAPPROVAL_INIT1.MassUpdate_Releases_Workflow: 03.'||
			' Result= ' || l_update_releases;
	resultout := wf_engine.eng_completed || ':' || l_update_releases;
	IF (g_po_wf_debug = 'Y') THEN
   	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
	END IF;
END MassUpdate_Releases_Workflow;

procedure Send_Supplier_Comm_Yes_No( itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2    ) IS
l_retro_change varchar2(1);
l_supplier_comm varchar2(1) := 'Y'; --default has to be Y
l_progress varchar2(300);
l_document_type   PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype   PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;

BEGIN
  l_progress := 'PO_REQAPPROVAL_INIT1.Send_Supplier_Comm_Yes_No: 01';

  l_retro_change := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CO_R_RETRO_CHANGE');

  -- Bug 3694128 : get the document type and subtype
  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  -- Bug 3694128 : The communication depends on the WF attribute only
  -- for std PO's and blanket releases. For all other documents we
  -- always communicate.
  If (l_retro_change = 'Y') and
     ((l_document_type = 'RELEASE' AND l_document_subtype = 'BLANKET') OR
      (l_document_type = 'PO' AND l_document_subtype = 'STANDARD')) then
	l_supplier_comm := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'CO_H_RETROACTIVE_SUPPLIER_COMM');
  else
     l_supplier_comm := 'Y';
  end if;

  -- Bug 3325520
  IF (l_supplier_comm IS NULL) THEN
    l_supplier_comm := 'N';
  END IF; /*IF (l_supplier_comm IS NULL)*/

  resultout := wf_engine.eng_completed || ':' || l_supplier_comm;

  l_progress := 'PO_REQAPPROVAL_INIT1.Send_Supplier_Comm_Yes_No: 02. Result= ' || l_supplier_comm;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
  l_supplier_comm := 'Y';
    resultout := wf_engine.eng_completed || ':' || l_supplier_comm;
END Send_Supplier_Comm_Yes_No;

/* RETROACTIVE FPI END */

/************************************************************************************
* Added this procedure as part of Bug #: 2843760
* This procedure basically checks if archive_on_print option is selected, and if yes
* call procedure PO_ARCHIVE_PO_SV.ARCHIVE_PO to archive the PO
*************************************************************************************/
procedure archive_po(p_document_id in number,
		     p_document_type in varchar2,
		     p_document_subtype in varchar2)
IS
-- <FPJ Refactor Archiving API>
l_return_status varchar2(1) ;
l_msg_count NUMBER := 0;
l_msg_data VARCHAR2(2000);

BEGIN

  -- <FPJ Refactor Archiving API>
  PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(
    p_api_version => 1.0,
    p_document_id => p_document_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_process => 'PRINT',
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data);

END ARCHIVE_PO;


-- <FPJ Retroactive START>
/**
* Public Procedure: Retro_Invoice_Release_WF
* Requires:
*   IN PARAMETERS:
*     Usual workflow attributes.
* Modifies: PO_DISTRIBUTIONS_ALL.invoice_adjustment_flag
* Effects:  This procedure updates invoice adjustment flag, and calls Costing
*           and Inventory APIs.
*/
PROCEDURE Retro_Invoice_Release_WF( itemtype        IN VARCHAR2,
                                    itemkey         IN VARCHAR2,
                                    actid           IN NUMBER,
                                    funcmode        IN VARCHAR2,
                                    resultout       OUT NOCOPY VARCHAR2)
IS

l_retro_change 		VARCHAR2(1);
l_document_id		PO_HEADERS_ALL.po_header_id%TYPE;
l_document_type		PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_progress		VARCHAR2(2000);
l_update_releases	VARCHAR2(1) := 'Y';
l_return_status		VARCHAR2(1) ;
l_msg_count		NUMBER := 0;
l_msg_data		VARCHAR2(2000);
l_retroactive_update 	VARCHAR2(30) := 'NEVER';
l_reset_retro_update 	BOOLEAN := FALSE;

BEGIN

  l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 01';
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  resultout := wf_engine.eng_completed || ':' || l_update_releases;

  /* Bug# 2846210
  ** Desc: Setting application context as this wf api will be executed
  ** after the background engine is run.
  */

  -- bug 4556437 : context setting no longer required here
  --Set_doc_mgr_context(itemtype, itemkey);

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DOCUMENT_ID');
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'DOCUMENT_TYPE');

  l_retro_change := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CO_R_RETRO_CHANGE');

  l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 02. ' ||
                'l_document_id = ' || l_document_id ||
                'l_document_type = ' || l_document_type ||
                'l_retro_change = ' || l_retro_change ;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Only handle retroactive invoice change for PO or Release
  IF (l_document_type NOT IN ('PO', 'RELEASE')) THEN
    RETURN;
  END IF;

  -- Don't trust l_retro_change='N' because if user makes retro changes, instead
  -- of approving it immediately, he chooses to close the form and re-query
  -- the PO/Release, then approve it.
  -- In this case, d_globals.retroactive_change_flag is lost.
  -- Always trust l_retro_change='Y'
  IF (l_retro_change IS NULL OR l_retro_change = 'N') THEN

    l_retro_change := PO_RETROACTIVE_PRICING_PVT.Is_Retro_Update(
                        p_document_id   => l_document_id,
		        p_document_type => l_document_type);

    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 03' ||
                'l_retro_change = ' || l_retro_change ;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


  END IF; /*IF (l_retro_change IS NULL OR l_retro_change = 'N')*/

  IF (l_retro_change = 'Y') THEN
    l_retroactive_update := PO_RETROACTIVE_PRICING_PVT.Get_Retro_Mode;

    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 04' ||
                'l_retroactive_update = ' || l_retroactive_update;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    -- Need to reset retroactive_date afterwards
    l_reset_retro_update := TRUE;

    IF (l_retroactive_update = 'NEVER') THEN
      l_retro_change := 'N';
    END IF; /*IF (l_retroactive_update = 'NEVER')*/

  END IF; /*IF (l_retro_change = 'Y')*/

  l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 05' ||
                'l_retroactive_update = ' || l_retroactive_update ||
                'l_retro_change = ' || l_retro_change ;
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  -- Set 'CO_R_RETRO_CHANGE' attribute so that later Workflow process can
  -- use this attribute safely
  PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CO_R_RETRO_CHANGE',
                                  avalue   =>  l_retro_change);

  IF (l_retro_change = 'Y' AND l_retroactive_update = 'ALL_RELEASES') THEN
    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 06. Calling ' ||
                  'PO_RETROACTIVE_PRICING_PVT.Retro_Invoice_Release';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_RETROACTIVE_PRICING_PVT.Retro_Invoice_Release
      ( p_api_version   => 1.0,
    	p_document_id   => l_document_id,
    	p_document_type => l_document_type ,
    	x_return_status => l_return_status,
    	x_msg_count	=> l_msg_count,
    	x_msg_data 	=> l_msg_data);

    IF (l_return_status <> 'S') THEN
      l_update_releases := 'N';
    END IF;

    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 07. Result= ' ||
                  l_update_releases;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

  END IF; /*IF (l_retro_change = 'Y' AND l_retroactive_update = 'ALL_RELEASES')*/

  IF (l_reset_retro_update) THEN
    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 08. Reset_Retro_Update';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_RETROACTIVE_PRICING_PVT.Reset_Retro_Update(
        p_document_id   => l_document_id,
        p_document_type => l_document_type);
  END IF; /*IF (l_reset_retro_update)*/

  resultout := wf_engine.eng_completed || ':' || l_update_releases;

EXCEPTION
  WHEN OTHERS THEN
    l_update_releases := 'N';
    l_progress := 'PO_REQAPPROVAL_INIT1.Retro_Invoice_Release_WF: 09.'||
    	          ' Result= ' || l_update_releases;
    resultout := wf_engine.eng_completed || ':' || l_update_releases;
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

END Retro_Invoice_Release_WF;

-- <FPJ Retroactive END>

-------------------------------------------------------------------------------
--Start of Comments :  Bug 3845048
--Name: UpdateActionHistory
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Updates the action history for the given doc with an action
--Parameters:
--IN:
--p_doc_id
--  Document id
--p_doc_type
--  Document type
--p_doc_subtype
--  Document Sub type
--p_action
--  Action to be inserted into the action history
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-- <BUG5383646 START>
/*
  Update the Action History with a note ICX_POR_NOTIF_TIMEOUT in approvers
  language
*/

PROCEDURE UpdateActionHistory(p_doc_id      IN number,
                              p_doc_type    IN varchar2,
                              p_doc_subtype IN varchar2,
                              p_action      IN varchar2
                              ) is
pragma AUTONOMOUS_TRANSACTION;

l_emp_id          NUMBER;
l_rowid           ROWID;
l_name            wf_local_roles.NAME%TYPE;
l_display_name    wf_local_roles.display_name%TYPE;
l_email_address   wf_local_roles.email_address%TYPE;
l_notification_preference     wf_local_roles.notification_preference%TYPE;
l_language        wf_local_roles.LANGUAGE%TYPE;
l_territory       wf_local_roles.territory%TYPE;
l_note            fnd_new_messages.message_text%TYPE;

BEGIN
        -- SQL What : Get the employee_id corresponding to the last NULL action record.
        -- Sql Why  : To get hold the language of the employee.

   BEGIN
      SELECT pah.employee_id, pah.ROWID
        INTO l_emp_id,        l_rowid
        FROM po_action_history pah
       WHERE pah.object_id = p_doc_id
         AND pah.object_type_code = p_doc_type
         AND pah.object_sub_type_code = p_doc_subtype
         AND pah.sequence_num = (SELECT Max(sequence_num)
                                   FROM po_action_history pah1
                                  WHERE pah1.object_id = p_doc_id
                                    AND pah1.object_type_code = p_doc_type
                                    AND pah1.object_sub_type_code = p_doc_subtype)
         AND pah.action_code is NULL;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF l_emp_id IS NOT NULL THEN

      wf_directory.GetUserName ( p_orig_system        => 'PER',
                                 p_orig_system_id     => l_emp_id,
                                 p_name               => l_name,
                                 p_display_name       => l_display_name );

      IF l_name IS NOT NULL THEN

         WF_DIRECTORY.GETROLEINFO ( ROLE              => l_name,
                                    Display_Name      => l_display_name,
                                    Email_Address     => l_email_address,
                                    Notification_Preference => l_notification_preference,
                                    LANGUAGE          => l_language,
                                    Territory         => l_territory );

         IF l_language IS NOT NULL THEN
            BEGIN
               -- SQL What : Get the message in the approvers language.
               -- Sql Why  : To maintain the NO ACTION message in approver language.
               SELECT message_text
                 INTO l_note
                 FROM fnd_new_messages fm,
                      fnd_languages fl
                WHERE fm.message_name = 'ICX_POR_NOTIF_TIMEOUT'
                  AND fm.language_code = fl.language_code
                  AND fl.nls_language = l_language;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;
      END IF;
   END IF;

   IF l_note IS NULL THEN
      l_note := fnd_message.get_string('ICX', 'ICX_POR_NOTIF_TIMEOUT');
   END IF;

   IF l_rowid IS NOT NULL THEN
      -- SQL What : Update the No action in the action history.
      -- Sql Why  : To maintain the NO ACTION message in approver language.
      UPDATE po_action_history pah
         SET pah.action_code   = p_action,
	          pah.action_date   = SYSDATE,
             pah.Note = l_note,
             pah.last_updated_by   = fnd_global.user_id,
             pah.last_update_login = fnd_global.login_id,
             pah.last_update_date  = SYSDATE
      WHERE ROWID = l_rowid;
   END IF;
   COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    NULL;
END;

--BUG 5378701
PROCEDURE Update_Acc_Req_Flg(p_header_id number ,
                                          p_release_id number)
 IS
 PRAGMA AUTONOMOUS_TRANSACTION;
 l_api_name varchar2(50) :='Update_Acc_Req_Flg';
 Begin
--Bug 6665604 - Start
--Update the last update date when po_headers_all/po_releases_all tables are updated.
IF p_release_id is not null THEN
      update po_releases
      set acceptance_required_flag = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      acceptance_due_date = ''
      where po_release_id = p_release_id;
   ELSE
      update po_headers
      set acceptance_required_flag = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      acceptance_due_date = ''
      where po_header_id = p_header_id;
   END IF;
--Bug 6665604 - End
 commit;
 EXCEPTION
     WHEN OTHERS THEN
     NULL;
 End Update_Acc_Req_Flg;

-- bug 4727400 : added the following proc to update the print count
PROCEDURE update_print_count(p_doc_id NUMBER,
			     p_doc_type VARCHAR2)
is
pragma AUTONOMOUS_TRANSACTION;
begin
    if (p_doc_type = 'RELEASE')  then

               update po_releases_all pr
               set pr.printed_date = sysdate,
                   pr.print_count = nvl(pr.print_count,0) + 1
               where pr.po_release_id = p_doc_id ;

    elsif (p_doc_type  in ('PO','PA')) then

               update po_headers_all ph
               set ph.printed_date = sysdate,
                   ph.print_count = nvl(ph.print_count,0) + 1
               where ph.po_header_id = p_doc_id ;

    end if;
commit;
end;

-- <BUG5383646 START>
/*
** Public Procedure: Update_Action_History_TimeOut
** Requires:
**   IN PARAMETERS:
**     Usual workflow attributes.
** Modifies: Action History
** Effects:  Actoin History is updated with No Action if the approval
**           notification is TimedOut.
*/

PROCEDURE Update_Action_History_Timeout (Itemtype     IN    VARCHAR2,
                                         Itemkey      IN    VARCHAR2,
                                         Actid        IN    NUMBER,
                                         Funcmode     IN    VARCHAR2,
                                         Resultout    OUT   NOCOPY VARCHAR2) IS

L_Doc_Id                NUMBER;
L_Doc_Type              Po_Action_History.Object_Type_Code%TYPE;
L_Doc_Subtype           Po_Action_History.Object_Sub_Type_Code%TYPE;

BEGIN

  L_Doc_Type := Wf_Engine.Getitemattrtext (Itemtype => Itemtype,
                                           Itemkey  => Itemkey,
                                           Aname    => 'DOCUMENT_TYPE');

  L_Doc_Subtype := Wf_Engine.Getitemattrtext(Itemtype => Itemtype,
                                             Itemkey  => Itemkey,
  	                                     Aname    => 'DOCUMENT_SUBTYPE');

  L_Doc_Id := Wf_Engine.Getitemattrnumber (Itemtype => Itemtype,
                                           Itemkey  => Itemkey,
                                           Aname    => 'DOCUMENT_ID');

  UpdateActionHistory ( p_doc_id      =>  L_Doc_Id,
                        p_doc_type    =>  L_Doc_Type,
                        p_doc_subtype =>  L_Doc_Subtype,
                        p_action      =>  'NO ACTION'
                      );

END Update_Action_History_Timeout;
-- <BUG5383646 END>


/* Bug 5578063 added the procedure to update the approve action
in the action history when the reserve is not checked while
submission for approval */
procedure Ins_actionhist_approve(itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out NOCOPY varchar2) is

l_doc_id number;
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_employee_id number;
l_orgid       number;
x_progress    varchar2(100);
l_preparer_user_name varchar2(100);
l_path_id number;
l_doc_string varchar2(200);

BEGIN

x_progress := 'PO_REQAPPROVAL_INIT1.Ins_actionhist_approve: 01';


-- Do nothing in cancel or timeout mode
--
if (funcmode <> wf_engine.eng_run) then

  resultout := wf_engine.eng_null;
 return;

end if;

l_doc_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'DOCUMENT_ID');

l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'DOCUMENT_TYPE');

l_doc_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'DOCUMENT_SUBTYPE');

l_employee_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                     aname    => 'APPROVER_EMPID');

l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                     itemkey  => itemkey,
                                    aname    => 'ORG_ID');

IF l_orgid is NOT NULL THEN

fnd_client_info.set_org_context(to_char(l_orgid));

END IF;

l_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVAL_PATH_ID');

XX_PO_REQAPPROVAL_INIT1.InsertActionHistApprove(itemtype,itemkey,l_doc_id, l_doc_type,
                               l_doc_subtype, l_employee_id, 'APPROVE',l_path_id);


--
 resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED' ;
--


x_progress := 'PO_REQAPPROVAL_INIT1.Ins_actionhist_approve: 02';

EXCEPTION
WHEN OTHERS THEN
l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
wf_core.context('PO_REQAPPROVAL_INIT1','Ins_actionhist_approve',x_progress);
PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_INIT1.INS_ACTIONHIST_APPROVE');
raise;

END Ins_actionhist_approve;


/* Bug 5578063 added the procedure to update the approve action
in the action history when the reserve is not checked while
submission for approval */

PROCEDURE InsertActionHistApprove(itemtype varchar2, itemkey varchar2,
                             p_doc_id number, p_doc_type varchar2,
                             p_doc_subtype varchar2, p_employee_id number,
                             p_action varchar2,
                             p_path_id number) is

pragma AUTONOMOUS_TRANSACTION;

l_action_code varchar2(25);
l_hist_count   number := NULL;
l_sequence_num   number := NULL;
l_approval_path_id number;

CURSOR action_hist_cursor(doc_id number , doc_type varchar2) is
select max(sequence_num)
from po_action_history
where object_id= doc_id and
object_type_code = doc_type;

CURSOR action_hist_code_cursor (doc_id number , doc_type varchar2, seq_num number) is
select action_code
from po_action_history
where object_id = doc_id and
object_type_code = doc_type and
sequence_num = seq_num;


x_progress varchar2(3):='000';

BEGIN

x_progress := '001';

l_approval_path_id := p_path_id;


x_progress := '002';

OPEN action_hist_cursor(p_doc_id,p_doc_type);
FETCH action_hist_cursor into l_sequence_num;
CLOSE action_hist_cursor;

OPEN action_hist_code_cursor(p_doc_id , p_doc_type, l_sequence_num);
FETCH action_hist_code_cursor into l_action_code;


x_progress := '003';
IF  (l_action_code is NULL) THEN

UPDATE PO_ACTION_HISTORY
     set object_id = p_doc_id,
         object_type_code = p_doc_type,
         object_sub_type_code = p_doc_subtype,
         sequence_num = l_sequence_num,
         last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
         action_code = p_action,
         action_date = decode(p_action, '',to_date(NULL),sysdate),
         employee_id = p_employee_id,
         last_update_login = fnd_global.login_id,
         request_id = 0,
         program_application_id = 0,
         program_id = 0,
         program_update_date = '',
         approval_path_id = l_approval_path_id,
         offline_code = ''
    WHERE
        object_id= p_doc_id and
        object_type_code = p_doc_type and
        sequence_num = l_sequence_num;
End if;

x_progress := '004';
IF (g_po_wf_debug = 'Y') THEN
/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
END IF;

commit;
EXCEPTION

WHEN OTHERS THEN
   wf_core.context('PO_REQAPPROVAL_INIT1','InsertActionHistApprove',x_progress);
    raise;

END InsertActionHistApprove;


-- <Bug 6144768 Begin>
-- Created two new procedures to introduce supplier context in PO approval.

 /**
  * Public Procedure: set_is_supplier_context_y
  * Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y to let
  * the POREQ_SELECTOR know we should be in the supplier's context
  * and not reset to the buyer's context
  * Requires:
  *   IN PARAMETERS:
  *     Usual workflow attributes.
  * Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to Y
  */
  procedure set_is_supplier_context_y(p_item_type        in varchar2,
                                      p_item_key         in varchar2,
                                      p_act_id           in number,
                                      p_func_mode        in varchar2,
                                      x_result_out       out NOCOPY varchar2) is

  l_progress                  VARCHAR2(300);

  begin

  l_progress := 'PO_REQAPPROVAL_INIT1.set_is_supplier_context_y: ';

  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Begin');
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrText(itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'IS_SUPPLIER_CONTEXT',
                                 avalue   => 'Y');

  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'End');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Unexpected error');
    END IF;
    RAISE;
  END set_is_supplier_context_y;

  /**
   * Public Procedure: set_is_supplier_context_n
   * Sets the workflow attribute IS_SUPPLIER_CONTEXT to N to let
   * the POREQ_SELECTOR know we are no longer in the suppliers
   * context.
   * Requires:
   *   IN PARAMETERS:
   *     Usual workflow attributes.
   * Modifies: Sets the workflow attribute IS_SUPPLIER_CONTEXT to N
   */

   procedure set_is_supplier_context_n(p_item_type        in varchar2,
                                       p_item_key         in varchar2,
                                       p_act_id           in number,
                                       p_func_mode        in varchar2,
                                       x_result_out       out NOCOPY varchar2) is

   l_progress                  VARCHAR2(300);

   begin

   l_progress := 'PO_REQAPPROVAL_INIT1.set_is_supplier_context_n: ';

   IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Begin');
   END IF;

   -- Set the IS_SUPPLIER_CONTEXT value to 'N'
   PO_WF_UTIL_PKG.SetItemAttrText(itemtype => p_item_type,
                                  itemkey  => p_item_key,
                                  aname    => 'IS_SUPPLIER_CONTEXT',
                                  avalue   => 'N');

   IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'End');
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
   IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(p_item_type, p_item_key, l_progress || 'Unexpected error');
   END IF;
   RAISE;
   END set_is_supplier_context_n;
   -- <Bug 6144768 End>

END XX_PO_REQAPPROVAL_INIT1;
/
