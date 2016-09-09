/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package oracle.apps.awcust.pa.webui;

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
public class gvsDocCO extends OAControllerImpl
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
      pageContext.writeDiagnostics(this,"GVS - Version 2.0",3);
      String strProjectId = pageContext.getParameter("ProjectId");
      pageContext.writeDiagnostics(this,"GVS - strProjectId: " + strProjectId,3);
      //
      OAApplicationModule oaAM = pageContext.getApplicationModule(webBean);
      //
      pageContext.putParameter("p_DataSource",DocumentHelper.DATA_SOURCE_TYPE_BLOB);
      pageContext.putParameter("p_DataSourceCode","SJTESTXML");
      pageContext.putParameter("p_DataSourceAppsShortName","AWCUST");
      pageContext.putParameter("p_TemplateCode","SJTESTXML");
      pageContext.putParameter("p_TemplateAppsShortName","AWCUST");
      pageContext.putParameter("p_Locale","Default");
      //pageContext.putParameter("p_Locale","English:United States");
      pageContext.putParameter("p_OutputType","PDF");
      pageContext.putParameter("p_XDORegionHeight","200%");
      Serializable[] oaParams = {strProjectId};
      BlobDomain result = (BlobDomain)oaAM.invokeMethod("getGVSData",oaParams);
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
