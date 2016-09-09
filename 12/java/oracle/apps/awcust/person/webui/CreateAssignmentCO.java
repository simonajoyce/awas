/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.awcust.person.webui;

import java.io.Serializable;


import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.TransactionUnitHelper;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;

/**
 * Controller for ...
 */
public class CreateAssignmentCO extends OAControllerImpl
{
  public static final String RCS_ID="$Header$";
  public static final boolean RCS_ID_RECORDED =
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

  /**
   * Layout and page setup logic for a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processRequest(pageContext, webBean);
    
    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    
    //capture the parameter passed in the url
    String paramUrlAction = pageContext.getParameter("urlParam");
    // If the URL parameter was from the Add Employee Apply Page call our create method
    
    if (paramUrlAction.equals("Create")){
    
        //Capture the parameter passed in the hash
        String paramPersonId = pageContext.getParameter("mapParam1");
        String paramEmployeeName = pageContext.getParameter("mapParam2");
        //add parameter list that we can use to pass parameters
        Serializable[] params = {paramPersonId,paramEmployeeName};
        am.invokeMethod("createNewAssignment", params);
    } 
    else if (paramUrlAction.equals("Update")){
        
        //capture the parameters passed in the hash
        String paramAssignmentId  = pageContext.getParameter("mapParam1");
        String paramPersonId      = pageContext.getParameter("mapParam2");
        String paramOffice        = pageContext.getParameter("mapParam3");
        String paramCostCentre    = pageContext.getParameter("mapParam4");
        String paramDepartment    = pageContext.getParameter("mapParam5");
        String paramLineManager   = pageContext.getParameter("mapParam6");
        String paramJobTitle      = pageContext.getParameter("mapParam7");
        String paramJobLevel      = pageContext.getParameter("mapParam8");
        String paramEmployeeType  = pageContext.getParameter("mapParam9");
        String paramUserProfile   = pageContext.getParameter("mapParam10");
        String paramEmployeeName  = pageContext.getParameter("mapParam11");
        
         //add parameter list that we can use to pass parameters
         Serializable[] params = {  paramPersonId,
                                    paramAssignmentId,
                                    paramOffice,
                                    paramCostCentre,
                                    paramDepartment,
                                    paramLineManager,
                                    paramJobTitle,
                                    paramJobLevel,
                                    paramEmployeeType,
                                    paramUserProfile,
                                    paramEmployeeName};
                                    
         am.invokeMethod("updateAssignment", params);
    }
    
    
  }

  /**
   * Procedure to handle form submissions for form elements in
   * a region.
   * @param pageContext the current OA page context
   * @param webBean the web bean corresponding to the region
   */
  public void processFormRequest(OAPageContext pageContext, OAWebBean webBean)
  {
    super.processFormRequest(pageContext, webBean);
    OAApplicationModule am = pageContext.getApplicationModule(webBean);
    
    String actionInAssignmentRegion = pageContext.getParameter(EVENT_PARAM);
    
    if (!pageContext.isFormSubmission()){
                
        //capture the parameters passed in the URl
        String paramUrlAction = pageContext.getParameter("urlParam");
        // If the URL parameter was from the Add Assignment Button call our create Method
        if (paramUrlAction.equals("Create")){
            //Capture the parameter passed in the hash
            String paramPersonId = pageContext.getParameter("mapParam1");
            Serializable[] params = {paramPersonId};
            am.invokeMethod("createNewAssignment", params);
            
        }
		// If the URL PArameter was from the Update Assignments Button call our updateMethod
        else if (paramUrlAction.equals("Update")) {
            // capture the parameters passed in the hash
            String paramAssignmentId = pageContext.getParameter("mapParam1");
            String paramPersonId     = pageContext.getParameter("mapParam2");
            //String paramOffice      = pageContext.getParameter("mapParam3");
            //String paramCostCentre     = pageContext.getParameter("mapParam4");
            //String paramDepartment     = pageContext.getParameter("mapParam5");
            //String paramLineManager     = pageContext.getParameter("mapParam6"); 
            //String paramJobTitle     = pageContext.getParameter("mapParam7");
            //String paramJobLevel     = pageContext.getParameter("mapParam8");
            //String paramEmployeeType     = pageContext.getParameter("mapParam9");
            //String paramUserProfile     = pageContext.getParameter("mapParam10");      
     
            
            Serializable[] params = {paramAssignmentId,
                                     paramPersonId
                                     //paramOffice,
                                     //paramCostCentre,
                                     //paramDepartment,
                                     //paramLineManager,
                                     //paramJobTitle,
                                     //paramJobLevel,
                                     //paramEmployeeType,
                                     //paramUserProfile
                                     };
            am.invokeMethod("updateAssignment", params);
            
        }
    }
    
    
    
    
    // Capturing the event when the Apply button is clicked
    
      if (actionInAssignmentRegion.equals("Apply"))          {
                // create instance of the view object
                OAViewObject vo = (OAViewObject)am.findViewObject("EmpAssignmentsCreateVO1");
                // get the value of the assignment id
                Number assignmentIdtmp = (Number)vo.getCurrentRow().getAttribute("AssignmentId");
                String assignmentId = assignmentIdtmp.stringValue();
                
                if (vo.getCurrentRow().getAttribute("StartDate") != null) {
                    
                
                Date   endDateTmp   = (Date)vo.getCurrentRow().getAttribute("StartDate");                
                String endDate      = endDateTmp.stringValue();

                
                Serializable[] params = {assignmentId,
                                         endDate};
                //commit the transaction
                am.invokeMethod("commitTransaction");
                
                am.invokeMethod("endAssignment",params);
                }        
           
        else if (vo.getCurrentRow().getAttribute("StartDate") == null) {
           throw new OAException("The start date must not be null.");
        }
             //set the message tokens
            MessageToken[] tokens = {new MessageToken("ASSIGNMENT_ID",assignmentId)};
                // call a confirmation message

            OAException confirmMessage = new OAException("AWCUST",
                                                         "AWAS_ASSIGNMENT_CREATE_CONFIRM",
                                                         tokens,
                                                         OAException.CONFIRMATION,
                                                         null);

            pageContext.putDialogMessage(confirmMessage);
                
                // Navigate back to the CreateEmployee page
                pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/awcust/person/webui/CreateEmpPG",
                                            null,
                                            OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                            null,
                                            null,
                                            true,  // retain AM
                                            OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
                                
    }
    //Capture the Cancel Button
     else if (actionInAssignmentRegion.equals("Cancel"))          {
	
        
        am.invokeMethod("rollBackAssignment");
        TransactionUnitHelper.endTransactionUnit(pageContext,"assignmentCreateTxn");
                           
         pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/awcust/person/webui/EmpSearchPage",
                                         null,
                                         OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                         null,
                                         null,
                                         true,
                                         OAWebBeanConstants.ADD_BREAD_CRUMB_NO);
                                         
    
    }
       
  }

}
