/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.awcust.person.webui;

import com.sun.java.util.collections.HashMap;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.jbo.domain.Number;

import oracle.apps.fnd.framework.webui.beans.OARawTextBean;


/**
 * Controller for ...
 */
public class EmpSearchPageCO extends OAControllerImpl
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
    
      OARawTextBean trialRawTextBean = (OARawTextBean)webBean.findChildRecursive("xxTrialRawTextBean");
      
      String theHTMLCode = "<html><body><p style=\"font-family:Arial,Helvetica,geneva,sans-serif;font-size:10pt;color:blue\">This is Just an example999999"+"</p></body></html>";
      
      trialRawTextBean.setText(theHTMLCode);
            
    
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
    
    // code for Create New Employee Button
    if (pageContext.getParameter("CreateNewEmployee") != null){
        
        pageContext.forwardImmediately("OA.jsp?page=/oracle/apps/awcust/person/webui/CreateEmpPG",
                                        null,
                                        OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                        null,
                                        null,
                                        true, //retain AM
                                        OAWebBeanConstants.ADD_BREAD_CRUMB_YES);
    }
    else if (pageContext.getParameter("event") != null && 
    
        pageContext.getParameter("event").equals("updateAssignmentAction")){
            String actionAssignmentId = pageContext.getParameter("updateAssignmentId");
            String actionPersonId     = pageContext.getParameter("updatePersonId");
            String actionOffice       = pageContext.getParameter("updateOffice");
            String actionCostCentre   = pageContext.getParameter("updateCostCentre");
            String actionDepartment   = pageContext.getParameter("updateDepartment");
            String actionLineManager  = pageContext.getParameter("updateLineManager");
            String actionJobTitle     = pageContext.getParameter("updateJobTitle");
            String actionJobLevel     = pageContext.getParameter("updateJobLevel");
            String actionEmployeeType = pageContext.getParameter("updateEmployeeType");
            String actionUserProfile  = pageContext.getParameter("updateUserProfile");
            String actionEmployeeName = pageContext.getParameter("updateEmployeeName");
            
            //handle the update assignment button press action
            
            HashMap map = new HashMap();
            map.put("mapParam1",actionAssignmentId);
            map.put("mapParam2",actionPersonId);
            map.put("mapParam3",actionOffice);
            map.put("mapParam4",actionCostCentre);
            map.put("mapParam5",actionDepartment);
            map.put("mapParam6",actionLineManager);
            map.put("mapParam7",actionJobTitle);
            map.put("mapParam8",actionJobLevel);
            map.put("mapParam9",actionEmployeeType);
            map.put("mapParam10",actionUserProfile);
            map.put("mapParam11",actionEmployeeName);
            
            //now call the create assignment page
            pageContext.setForwardURL("OA.jsp?page=/oracle/apps/awcust/person/webui/CreateAssignmentPG&urlParam=Update",
                                     null,
                                     OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                     null,
                                     map,
                                     true,
                                     OAWebBeanConstants.ADD_BREAD_CRUMB_SAVE,
                                     OAWebBeanConstants.IGNORE_MESSAGES
                                     );
        }
	else if (pageContext.getParameter("event") != null &&
	
		pageContext.getParameter("event").equals("updateEmployeeNameAction")){
		
		//String actionPersonId     = pageContext.getParameter("updatePersonId");
                
            OAViewObject vo = (OAViewObject)am.findViewObject("EmployeeDetailsVO1");
		           
	         // get the value of the attributes we need
	          Number personIdTmp  = (Number)vo.getCurrentRow().getAttribute("PersonId");
	          String PersonId  = personIdTmp.stringValue();
                
                
                
		HashMap map = new HashMap();
		 map.put("mapParam1",PersonId);
		 
		 //now call the create assignment page
            pageContext.setForwardURL("OA.jsp?page=/oracle/apps/awcust/person/webui/UpdateEmployeeNamePG&urlParam=Update",
                                     null,
                                     OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                     null,
                                     map,
                                     true,
                                     OAWebBeanConstants.ADD_BREAD_CRUMB_SAVE,
                                     OAWebBeanConstants.IGNORE_MESSAGES
                                     );
		}
  

	}
}