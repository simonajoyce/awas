package oracle.apps.awcust.awcustPerson.server;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
//  ---------------------------------------------------------------
//  ---    File generated by Oracle Business Components for Java.
//  ---------------------------------------------------------------

public class awcustCostCentreAMImpl extends OAApplicationModuleImpl 
{
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public awcustCostCentreAMImpl()
  {
  }

  /**
   * 
   * Container's getter for awcustCostCentreVO1
   */
  public awcustCostCentreVOImpl getawcustCostCentreVO1()
  {
    return (awcustCostCentreVOImpl)findViewObject("awcustCostCentreVO1");
  }

  /**
   * 
   * Sample main for debugging Business Components code using the tester.
   */
  public static void main(String[] args)
  {
    launchTester("oracle.apps.awcust.awcustPerson.server", "awcustCostCentreAMLocal");
  }
}