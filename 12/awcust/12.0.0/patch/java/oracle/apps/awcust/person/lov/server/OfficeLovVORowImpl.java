package oracle.apps.awcust.person.lov.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;

import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class OfficeLovVORowImpl extends OAViewRowImpl {
    public static final int OFFICE = 0;

    /**This is the default constructor (do not remove)
     */
    public OfficeLovVORowImpl() {
    }

    /**Gets the attribute value for the calculated attribute Office
     */
    public String getOffice() {
        return (String) getAttributeInternal(OFFICE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Office
     */
    public void setOffice(String value) {
        setAttributeInternal(OFFICE, value);
    }

    /**getAttrInvokeAccessor: generated method. Do not modify.
     */
    protected Object getAttrInvokeAccessor(int index, 
                                           AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case OFFICE:
            return getOffice();
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
