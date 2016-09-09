/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.awcust.person.webui;

import com.sun.java.util.collections.HashMap;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;

/**
 * Controller for ...
 */
public class EmployeeAssignmentsCO extends OAControllerImpl
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
    OAApplicationModule am = (OAApplicationModule)pageContext.getApplicationModule(webBean);
    OAViewObject vo = (OAViewObject)am.findViewObject("EmployeeDetailsVO1");
    if(vo != null) {
                vo.executeQuery();
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
    // get the action in the employee region
    String actionInEmpRegion = pageContext.getParameter(EVENT_PARAM);
    
    //perform logic for clicking the addAssignment image
    if(actionInEmpRegion.equals("addAssignment")){
    
     //get the personId of the employee we clicked the create assignment icon for
    String actionPersonId = pageContext.getParameter("paramMasterPersonId");
    //display the action and personId in a message on the screen
   //  throw new OAException("Action triggered is " + actionInEmpRegion +
   // " and the personId captured is " + actionPersonId, OAException.CONFIRMATION);
    
    //handle the submit button press actions
    HashMap map = new HashMap();
    map.put("mapParam1", actionPersonId);
    
    // we are calling the create assignment page and we are going to pass parameters through the URL
    // and also through the HashMap to pass the personid
    pageContext.setForwardURL("OA.jsp?page=/oracle/apps/awcust/person/webui/CreateAssignmentPG&urlParam=Create",
                            null, // string functionname
                            OAWebBeanConstants.KEEP_MENU_CONTEXT,
                            null, // string menuName
                            map, //HashMap parameters
                            true, //Retain AM
                            OAWebBeanConstants.ADD_BREAD_CRUMB_SAVE, //string addBreadcrumb
                            OAWebBeanConstants.IGNORE_MESSAGES // byte messaging level
                            );
    
    }
  }

}
