package oracle.apps.awcust.pa.reports.server;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OADBTransactionImpl;

import oracle.jbo.domain.BlobDomain;
import oracle.apps.xdo.oa.util.DataTemplate;
import java.sql.SQLException;
import oracle.apps.xdo.XDOException;
import com.sun.java.util.collections.Hashtable;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ReportPubAMImpl extends OAApplicationModuleImpl {
    /**This is the default constructor (do not remove)
     */
    public ReportPubAMImpl() {
    }

    /**Sample main for debugging Business Components code using the tester.
     */
    public static void main(String[] args) {
               launchTester("oracle.apps.awcust.pa.reports.server", /* package name */
      "ReportPubAMLocal" /* Configuration Name */);
    }
    public BlobDomain getXMLData (String strProjectId)
    {
    BlobDomain blobDomain = new BlobDomain();
    try
    {
    DataTemplate datatemplate = new DataTemplate(((OADBTransactionImpl)getOADBTransaction()).getAppsContext(), "AWCUST", "SJTESTXML");
    Hashtable parameters = new Hashtable();
    parameters.put("P_PROJECT_ID",strProjectId);
    datatemplate.setParameters(parameters);
    datatemplate.setOutput(blobDomain.getBinaryOutputStream());
    datatemplate.processData();
    }
    catch(SQLException e)
    {
    throw new OAException("SQL Error=" + e.getMessage(),OAException.ERROR);
    }
    catch (XDOException e)
    {
    throw new OAException("XDOException" + e.getMessage(),OAException.ERROR);
    }
    catch(Exception e)
    {
    throw new OAException("Exception" + e.getMessage(),OAException.ERROR);
    }
    return blobDomain;
    }
}
