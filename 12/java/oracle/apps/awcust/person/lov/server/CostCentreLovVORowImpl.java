package oracle.apps.awcust.person.lov.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;

import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CostCentreLovVORowImpl extends OAViewRowImpl {
    public static final int COSTCENTRE = 0;
    public static final int DESCRIPTION = 1;

    /**This is the default constructor (do not remove)
     */
    public CostCentreLovVORowImpl() {
    }

    /**Gets the attribute value for the calculated attribute CostCentre
     */
    public String getCostCentre() {
        return (String) getAttributeInternal(COSTCENTRE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute CostCentre
     */
    public void setCostCentre(String value) {
        setAttributeInternal(COSTCENTRE, value);
    }

    /**Gets the attribute value for the calculated attribute Description
     */
    public String getDescription() {
        return (String) getAttributeInternal(DESCRIPTION);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Description
     */
    public void setDescription(String value) {
        setAttributeInternal(DESCRIPTION, value);
    }

    /**getAttrInvokeAccessor: generated method. Do not modify.
     */
    protected Object getAttrInvokeAccessor(int index, 
                                           AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case COSTCENTRE:
            return getCostCentre();
        case DESCRIPTION:
            return getDescription();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }

    /**setAttrInvokeAccessor: generated method. Do not modify.
     */
    protected void setAttrInvokeAccessor(int index, Object value, 
                                         AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }
}
