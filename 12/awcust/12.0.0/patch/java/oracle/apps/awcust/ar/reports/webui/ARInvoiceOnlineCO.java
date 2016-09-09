/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.awcust.ar.reports.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.xdo.oa.common.DocumentHelper;

import oracle.jbo.domain.BlobDomain;

/**
 * Controller for ...
 */
public class ARInvoiceOnlineCO extends OAControllerImpl
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
       pageContext.writeDiagnostics(this,"AWCUST - Version 2.0",3);
       String strInvoiceNumber = pageContext.getParameter("InvoiceNumber");
       pageContext.writeDiagnostics(this,"Parameter - strInvoiceNumber: " + strInvoiceNumber,3);
       //
       OAApplicationModule oaAM = pageContext.getApplicationModule(webBean);
       //
       pageContext.putParameter("p_DataSource",DocumentHelper.DATA_SOURCE_TYPE_BLOB);
       pageContext.putParameter("p_DataSourceCode","XX_AR_ONLINE_INVOICE");
       pageContext.putParameter("p_DataSourceAppsShortName","AWCUST");
       pageContext.putParameter("p_TemplateCode","XX_AR_ONLINE_INVOICE");
       pageContext.putParameter("p_TemplateAppsShortName","AWCUST");
       pageContext.putParameter("p_Locale","Default");
       
       
       pageContext.putParameter("p_XDORegionHeight","200%");
       Serializable[] oaParams = {strInvoiceNumber};
       BlobDomain result = (BlobDomain)oaAM.invokeMethod("getXMLData",oaParams);
       pageContext.putSessionValueDirect("XML_DATA_BLOB", result);
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
   }

}
