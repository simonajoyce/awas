/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.awcust.person.webui;

import com.sun.java.util.collections.HashMap;

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
import oracle.jbo.domain.Number;


/**
 * Controller for ...
 */
public class CreateEmpCO extends OAControllerImpl
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
    am.invokeMethod("createNewEmployee");
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
    
    // capturing the event when the apply button is clicked
    if (pageContext.getParameter("Apply") != null){
    
        // create instance of the view object
        OAViewObject vo = (OAViewObject)am.findViewObject("EmpDetailsCreateVO1");
        
        // get the value of the attributes we need
        Number personIdTmp  = (Number)vo.getCurrentRow().getAttribute("PersonId");
        
       
        
        String firstName = (String)vo.getCurrentRow().getAttribute("FirstName");
        String lastName  = (String)vo.getCurrentRow().getAttribute("LastName");
        
        String employeeName = firstName + " " + lastName;
        
        
        // convert personIdTmp to string
        String personId  = personIdTmp.stringValue();
                
        //build hash map for parameters
        HashMap map = new HashMap();
        map.put("mapParam1", personId);
        map.put("mapParam2", employeeName);
    
        //call a method to commit the transaction and display a message
        am.invokeMethod("commitTransaction");
        
        //set the message tokens
        MessageToken[] tokens = {new MessageToken("FIRST_NAME",firstName),
                                 new MessageToken("LAST_NAME",lastName)
        };
        
        // call a confirmation message

        OAException confirmMessage = new OAException("AWCUST",
                                                 "AWAS_NEW_EMP_CREATED_CONFIRM",
                                                 tokens,
                                                 
                                                 OAException.CONFIRMATION,
                                                 null);

        pageContext.putDialogMessage(confirmMessage);

        // Navigate to CreateAssignments page
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
    else if (pageContext.getParameter("Cancel") != null){
        am.invokeMethod("rollbackEmployeeCreate");
        TransactionUnitHelper.endTransactionUnit(pageContext, "EmployeeCreateTxn");
        
        //Navigate back to EmpSearchPG
        pageContext.setForwardURL("OA.jsp?page=/oracle/apps/awcust/person/webui/EmpSearchPage",
                                        null,
                                        OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                        null,
                                        null,
                                        true,
                                        OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                        OAWebBeanConstants.IGNORE_MESSAGES);
                                        
    }
  }

}
