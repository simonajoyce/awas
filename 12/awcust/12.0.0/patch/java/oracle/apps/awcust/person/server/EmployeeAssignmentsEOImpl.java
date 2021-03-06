package oracle.apps.awcust.person.server;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.server.OAEntityDefImpl;
import oracle.apps.fnd.framework.server.OAEntityImpl;

import oracle.jbo.AttributeList;
import oracle.jbo.Key;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class EmployeeAssignmentsEOImpl extends OAEntityImpl {
    public static final int ASSIGNMENTID = 0;
    public static final int PERSONID = 1;
    public static final int STARTDATE = 2;
    public static final int ENDDATE = 3;
    public static final int OFFICE = 4;
    public static final int COSTCENTRE = 5;
    public static final int DEPARTMENT = 6;
    public static final int LINEMANAGER = 7;
    public static final int LINEMANAGERID = 8;
    public static final int JOBTITLE = 9;
    public static final int JOBLEVEL = 10;
    public static final int EMPLOYEETYPE = 11;
    public static final int MOBILENUMBER = 12;
    public static final int DESKNUMBER = 13;
    public static final int BUSINESSCARDS = 14;
    public static final int REMOTEACCESS = 15;
    public static final int PCTYPE = 16;
    public static final int MOBILEDEVICE = 17;
    public static final int DESKLOCATION = 18;
    public static final int OTHERCOMMENTS = 19;
    public static final int STATUS = 20;
    public static final int PERSONWITH = 21;
    public static final int MANAGERAPPROVER = 22;
    public static final int MANAGERRESPONSE = 23;
    public static final int MANAGERRESPONSEDATE = 24;
    public static final int ITAPPROVER = 25;
    public static final int ITRESPONSE = 26;
    public static final int ITRESPONSEDATE = 27;
    public static final int CSAPPROVER = 28;
    public static final int CSRESPONSE = 29;
    public static final int CSRESPONSEDATE = 30;
    public static final int APPROVALCOMMENTS = 31;
    public static final int LASTUPDATEDATE = 32;
    public static final int LASTUPDATELOGIN = 33;
    public static final int LASTUPDATEDBY = 34;
    public static final int CREATIONDATE = 35;
    public static final int CREATEDBY = 36;
    public static final int USERPROFILE = 37;
    public static final int RESTRICTFYI = 38;
    public static final int EMPLOYEENAME = 39;
    public static final int PORTAL = 40;


    private static OAEntityDefImpl mDefinitionObject;

    /**This is the default constructor (do not remove)
     */
    public EmployeeAssignmentsEOImpl() {
    }


    /**Retrieves the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        if (mDefinitionObject == null) {
            mDefinitionObject = 
                    (OAEntityDefImpl)EntityDefImpl.findDefObject("oracle.apps.awcust.person.server.EmployeeAssignmentsEO");
        }
        return mDefinitionObject;
    }

    /**Add attribute defaulting logic in this method.
     */
    public void create(AttributeList attributeList) {
        super.create(attributeList);
        
        // To Access database we need the class OADBTRANSACTION
        OADBTransaction txn = getOADBTransaction();
        
        //Assignment ID is obtained from the SEQUENCE called xx_employee_assignment_s
        // and then we set the assignmentId by calling the setter method
        Number assignmentId = txn.getSequenceValue("xx_employee_assignment_s");
        setAssignmentId(assignmentId);
        
        //set default start date to today
        //Date startDate = txn.getCurrentDBDate();
        //setStartDate(startDate);
        
       //set default status = new
        setStatus("New");
   }

    /**Add entity remove logic in this method.
     */
    public void remove() {
        super.remove();
    }

    /**Add Entity validation code in this method.
     */
    protected void validateEntity() {
        super.validateEntity();
    }

    /**Gets the attribute value for AssignmentId, using the alias name AssignmentId
     */
    public Number getAssignmentId() {
        return (Number)getAttributeInternal(ASSIGNMENTID);
    }

    /**Sets <code>value</code> as the attribute value for AssignmentId
     */
    public void setAssignmentId(Number value) {
        setAttributeInternal(ASSIGNMENTID, value);
    }

    /**Gets the attribute value for PersonId, using the alias name PersonId
     */
    public Number getPersonId() {
        return (Number)getAttributeInternal(PERSONID);
    }

    /**Sets <code>value</code> as the attribute value for PersonId
     */
    public void setPersonId(Number value) {
        setAttributeInternal(PERSONID, value);
    }

    /**Gets the attribute value for StartDate, using the alias name StartDate
     */
    public Date getStartDate() {
        return (Date)getAttributeInternal(STARTDATE);
    }

    /**Sets <code>value</code> as the attribute value for StartDate
     */
    public void setStartDate(Date value) {
    
        setAttributeInternal(STARTDATE, value);
            
    }

    /**Gets the attribute value for EndDate, using the alias name EndDate
     */
    public Date getEndDate() {
        return (Date)getAttributeInternal(ENDDATE);
    }

    /**Sets <code>value</code> as the attribute value for EndDate
     */
    public void setEndDate(Date value) {
        setAttributeInternal(ENDDATE, value);
    }

    /**Gets the attribute value for Office, using the alias name Office
     */
    public String getOffice() {
        return (String)getAttributeInternal(OFFICE);
    }

    /**Sets <code>value</code> as the attribute value for Office
     */
    public void setOffice(String value) {
        setAttributeInternal(OFFICE, value);
    }

    /**Gets the attribute value for CostCentre, using the alias name CostCentre
     */
    public Number getCostCentre() {
        return (Number)getAttributeInternal(COSTCENTRE);
    }

    /**Sets <code>value</code> as the attribute value for CostCentre
     */
    public void setCostCentre(Number value) {
        setAttributeInternal(COSTCENTRE, value);
    }

    /**Gets the attribute value for Department, using the alias name Department
     */
    public String getDepartment() {
        return (String)getAttributeInternal(DEPARTMENT);
    }

    /**Sets <code>value</code> as the attribute value for Department
     */
    public void setDepartment(String value) {
        setAttributeInternal(DEPARTMENT, value);
    }

    /**Gets the attribute value for LineManager, using the alias name LineManager
     */
    public String getLineManager() {
        return (String)getAttributeInternal(LINEMANAGER);
    }

    /**Sets <code>value</code> as the attribute value for LineManager
     */
    public void setLineManager(String value) {
        setAttributeInternal(LINEMANAGER, value);
    }

    /**Gets the attribute value for LineManagerId, using the alias name LineManagerId
     */
    public Number getLineManagerId() {
        return (Number)getAttributeInternal(LINEMANAGERID);
    }

    /**Sets <code>value</code> as the attribute value for LineManagerId
     */
    public void setLineManagerId(Number value) {
        setAttributeInternal(LINEMANAGERID, value);
    }

    /**Gets the attribute value for JobTitle, using the alias name JobTitle
     */
    public String getJobTitle() {
        return (String)getAttributeInternal(JOBTITLE);
    }

    /**Sets <code>value</code> as the attribute value for JobTitle
     */
    public void setJobTitle(String value) {
        setAttributeInternal(JOBTITLE, value);
    }

    /**Gets the attribute value for JobLevel, using the alias name JobLevel
     */
    public Number getJobLevel() {
        return (Number)getAttributeInternal(JOBLEVEL);
    }

    /**Sets <code>value</code> as the attribute value for JobLevel
     */
    public void setJobLevel(Number value) {
        setAttributeInternal(JOBLEVEL, value);
    }

    /**Gets the attribute value for EmployeeType, using the alias name EmployeeType
     */
    public String getEmployeeType() {
        return (String)getAttributeInternal(EMPLOYEETYPE);
    }

    /**Sets <code>value</code> as the attribute value for EmployeeType
     */
    public void setEmployeeType(String value) {
        setAttributeInternal(EMPLOYEETYPE, value);
    }

    /**Gets the attribute value for MobileNumber, using the alias name MobileNumber
     */
    public String getMobileNumber() {
        return (String)getAttributeInternal(MOBILENUMBER);
    }

    /**Sets <code>value</code> as the attribute value for MobileNumber
     */
    public void setMobileNumber(String value) {
        setAttributeInternal(MOBILENUMBER, value);
    }

    /**Gets the attribute value for DeskNumber, using the alias name DeskNumber
     */
    public String getDeskNumber() {
        return (String)getAttributeInternal(DESKNUMBER);
    }

    /**Sets <code>value</code> as the attribute value for DeskNumber
     */
    public void setDeskNumber(String value) {
        setAttributeInternal(DESKNUMBER, value);
    }

    /**Gets the attribute value for BusinessCards, using the alias name BusinessCards
     */
    public String getBusinessCards() {
        return (String)getAttributeInternal(BUSINESSCARDS);
    }

    /**Sets <code>value</code> as the attribute value for BusinessCards
     */
    public void setBusinessCards(String value) {
        setAttributeInternal(BUSINESSCARDS, value);
    }

    /**Gets the attribute value for RemoteAccess, using the alias name RemoteAccess
     */
    public String getRemoteAccess() {
        return (String)getAttributeInternal(REMOTEACCESS);
    }

    /**Sets <code>value</code> as the attribute value for RemoteAccess
     */
    public void setRemoteAccess(String value) {
        setAttributeInternal(REMOTEACCESS, value);
    }

    /**Gets the attribute value for PcType, using the alias name PcType
     */
    public String getPcType() {
        return (String)getAttributeInternal(PCTYPE);
    }

    /**Sets <code>value</code> as the attribute value for PcType
     */
    public void setPcType(String value) {
        setAttributeInternal(PCTYPE, value);
    }

    /**Gets the attribute value for MobileDevice, using the alias name MobileDevice
     */
    public String getMobileDevice() {
        return (String)getAttributeInternal(MOBILEDEVICE);
    }

    /**Sets <code>value</code> as the attribute value for MobileDevice
     */
    public void setMobileDevice(String value) {
        setAttributeInternal(MOBILEDEVICE, value);
    }

    /**Gets the attribute value for DeskLocation, using the alias name DeskLocation
     */
    public String getDeskLocation() {
        return (String)getAttributeInternal(DESKLOCATION);
    }

    /**Sets <code>value</code> as the attribute value for DeskLocation
     */
    public void setDeskLocation(String value) {
        setAttributeInternal(DESKLOCATION, value);
    }

    /**Gets the attribute value for OtherComments, using the alias name OtherComments
     */
    public String getOtherComments() {
        return (String)getAttributeInternal(OTHERCOMMENTS);
    }

    /**Sets <code>value</code> as the attribute value for OtherComments
     */
    public void setOtherComments(String value) {
        setAttributeInternal(OTHERCOMMENTS, value);
    }

    /**Gets the attribute value for Status, using the alias name Status
     */
    public String getStatus() {
        return (String)getAttributeInternal(STATUS);
    }

    /**Sets <code>value</code> as the attribute value for Status
     */
    public void setStatus(String value) {
        setAttributeInternal(STATUS, value);
    }

    /**Gets the attribute value for PersonWith, using the alias name PersonWith
     */
    public String getPersonWith() {
        return (String)getAttributeInternal(PERSONWITH);
    }

    /**Sets <code>value</code> as the attribute value for PersonWith
     */
    public void setPersonWith(String value) {
        setAttributeInternal(PERSONWITH, value);
    }

    /**Gets the attribute value for ManagerApprover, using the alias name ManagerApprover
     */
    public String getManagerApprover() {
        return (String)getAttributeInternal(MANAGERAPPROVER);
    }

    /**Sets <code>value</code> as the attribute value for ManagerApprover
     */
    public void setManagerApprover(String value) {
        setAttributeInternal(MANAGERAPPROVER, value);
    }

    /**Gets the attribute value for ManagerResponse, using the alias name ManagerResponse
     */
    public String getManagerResponse() {
        return (String)getAttributeInternal(MANAGERRESPONSE);
    }

    /**Sets <code>value</code> as the attribute value for ManagerResponse
     */
    public void setManagerResponse(String value) {
        setAttributeInternal(MANAGERRESPONSE, value);
    }

    /**Gets the attribute value for ManagerResponseDate, using the alias name ManagerResponseDate
     */
    public Date getManagerResponseDate() {
        return (Date)getAttributeInternal(MANAGERRESPONSEDATE);
    }

    /**Sets <code>value</code> as the attribute value for ManagerResponseDate
     */
    public void setManagerResponseDate(Date value) {
        setAttributeInternal(MANAGERRESPONSEDATE, value);
    }

    /**Gets the attribute value for ItApprover, using the alias name ItApprover
     */
    public String getItApprover() {
        return (String)getAttributeInternal(ITAPPROVER);
    }

    /**Sets <code>value</code> as the attribute value for ItApprover
     */
    public void setItApprover(String value) {
        setAttributeInternal(ITAPPROVER, value);
    }

    /**Gets the attribute value for ItResponse, using the alias name ItResponse
     */
    public String getItResponse() {
        return (String)getAttributeInternal(ITRESPONSE);
    }

    /**Sets <code>value</code> as the attribute value for ItResponse
     */
    public void setItResponse(String value) {
        setAttributeInternal(ITRESPONSE, value);
    }

    /**Gets the attribute value for ItResponseDate, using the alias name ItResponseDate
     */
    public Date getItResponseDate() {
        return (Date)getAttributeInternal(ITRESPONSEDATE);
    }

    /**Sets <code>value</code> as the attribute value for ItResponseDate
     */
    public void setItResponseDate(Date value) {
        setAttributeInternal(ITRESPONSEDATE, value);
    }

    /**Gets the attribute value for CsApprover, using the alias name CsApprover
     */
    public String getCsApprover() {
        return (String)getAttributeInternal(CSAPPROVER);
    }

    /**Sets <code>value</code> as the attribute value for CsApprover
     */
    public void setCsApprover(String value) {
        setAttributeInternal(CSAPPROVER, value);
    }

    /**Gets the attribute value for CsResponse, using the alias name CsResponse
     */
    public String getCsResponse() {
        return (String)getAttributeInternal(CSRESPONSE);
    }

    /**Sets <code>value</code> as the attribute value for CsResponse
     */
    public void setCsResponse(String value) {
        setAttributeInternal(CSRESPONSE, value);
    }

    /**Gets the attribute value for CsResponseDate, using the alias name CsResponseDate
     */
    public Date getCsResponseDate() {
        return (Date)getAttributeInternal(CSRESPONSEDATE);
    }

    /**Sets <code>value</code> as the attribute value for CsResponseDate
     */
    public void setCsResponseDate(Date value) {
        setAttributeInternal(CSRESPONSEDATE, value);
    }

    /**Gets the attribute value for ApprovalComments, using the alias name ApprovalComments
     */
    public String getApprovalComments() {
        return (String)getAttributeInternal(APPROVALCOMMENTS);
    }

    /**Sets <code>value</code> as the attribute value for ApprovalComments
     */
    public void setApprovalComments(String value) {
        setAttributeInternal(APPROVALCOMMENTS, value);
    }

    /**Gets the attribute value for LastUpdateDate, using the alias name LastUpdateDate
     */
    public Date getLastUpdateDate() {
        return (Date)getAttributeInternal(LASTUPDATEDATE);
    }

    /**Sets <code>value</code> as the attribute value for LastUpdateDate
     */
    public void setLastUpdateDate(Date value) {
        setAttributeInternal(LASTUPDATEDATE, value);
    }

    /**Gets the attribute value for LastUpdateLogin, using the alias name LastUpdateLogin
     */
    public Number getLastUpdateLogin() {
        return (Number)getAttributeInternal(LASTUPDATELOGIN);
    }

    /**Sets <code>value</code> as the attribute value for LastUpdateLogin
     */
    public void setLastUpdateLogin(Number value) {
        setAttributeInternal(LASTUPDATELOGIN, value);
    }

    /**Gets the attribute value for LastUpdatedBy, using the alias name LastUpdatedBy
     */
    public Number getLastUpdatedBy() {
        return (Number)getAttributeInternal(LASTUPDATEDBY);
    }

    /**Sets <code>value</code> as the attribute value for LastUpdatedBy
     */
    public void setLastUpdatedBy(Number value) {
        setAttributeInternal(LASTUPDATEDBY, value);
    }

    /**Gets the attribute value for CreationDate, using the alias name CreationDate
     */
    public Date getCreationDate() {
        return (Date)getAttributeInternal(CREATIONDATE);
    }

    /**Sets <code>value</code> as the attribute value for CreationDate
     */
    public void setCreationDate(Date value) {
        setAttributeInternal(CREATIONDATE, value);
    }

    /**Gets the attribute value for CreatedBy, using the alias name CreatedBy
     */
    public Number getCreatedBy() {
        return (Number)getAttributeInternal(CREATEDBY);
    }

    /**Sets <code>value</code> as the attribute value for CreatedBy
     */
    public void setCreatedBy(Number value) {
        setAttributeInternal(CREATEDBY, value);
    }

    /**getAttrInvokeAccessor: generated method. Do not modify.
     */
    protected Object getAttrInvokeAccessor(int index, 
                                           AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case ASSIGNMENTID:
            return getAssignmentId();
        case PERSONID:
            return getPersonId();
        case STARTDATE:
            return getStartDate();
        case ENDDATE:
            return getEndDate();
        case OFFICE:
            return getOffice();
        case COSTCENTRE:
            return getCostCentre();
        case DEPARTMENT:
            return getDepartment();
        case LINEMANAGER:
            return getLineManager();
        case LINEMANAGERID:
            return getLineManagerId();
        case JOBTITLE:
            return getJobTitle();
        case JOBLEVEL:
            return getJobLevel();
        case EMPLOYEETYPE:
            return getEmployeeType();
        case MOBILENUMBER:
            return getMobileNumber();
        case DESKNUMBER:
            return getDeskNumber();
        case BUSINESSCARDS:
            return getBusinessCards();
        case REMOTEACCESS:
            return getRemoteAccess();
        case PCTYPE:
            return getPcType();
        case MOBILEDEVICE:
            return getMobileDevice();
        case DESKLOCATION:
            return getDeskLocation();
        case OTHERCOMMENTS:
            return getOtherComments();
        case STATUS:
            return getStatus();
        case PERSONWITH:
            return getPersonWith();
        case MANAGERAPPROVER:
            return getManagerApprover();
        case MANAGERRESPONSE:
            return getManagerResponse();
        case MANAGERRESPONSEDATE:
            return getManagerResponseDate();
        case ITAPPROVER:
            return getItApprover();
        case ITRESPONSE:
            return getItResponse();
        case ITRESPONSEDATE:
            return getItResponseDate();
        case CSAPPROVER:
            return getCsApprover();
        case CSRESPONSE:
            return getCsResponse();
        case CSRESPONSEDATE:
            return getCsResponseDate();
        case APPROVALCOMMENTS:
            return getApprovalComments();
        case LASTUPDATEDATE:
            return getLastUpdateDate();
        case LASTUPDATELOGIN:
            return getLastUpdateLogin();
        case LASTUPDATEDBY:
            return getLastUpdatedBy();
        case CREATIONDATE:
            return getCreationDate();
        case CREATEDBY:
            return getCreatedBy();
        case USERPROFILE:
            return getUserProfile();
        case RESTRICTFYI:
            return getRestrictFyi();
        case EMPLOYEENAME:
            return getEmployeeName();
        case PORTAL:
            return getPortal();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }

    /**setAttrInvokeAccessor: generated method. Do not modify.
     */
    protected void setAttrInvokeAccessor(int index, Object value, 
                                         AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case ASSIGNMENTID:
            setAssignmentId((Number)value);
            return;
        case PERSONID:
            setPersonId((Number)value);
            return;
        case STARTDATE:
            setStartDate((Date)value);
            return;
        case ENDDATE:
            setEndDate((Date)value);
            return;
        case OFFICE:
            setOffice((String)value);
            return;
        case COSTCENTRE:
            setCostCentre((Number)value);
            return;
        case DEPARTMENT:
            setDepartment((String)value);
            return;
        case LINEMANAGER:
            setLineManager((String)value);
            return;
        case LINEMANAGERID:
            setLineManagerId((Number)value);
            return;
        case JOBTITLE:
            setJobTitle((String)value);
            return;
        case JOBLEVEL:
            setJobLevel((Number)value);
            return;
        case EMPLOYEETYPE:
            setEmployeeType((String)value);
            return;
        case MOBILENUMBER:
            setMobileNumber((String)value);
            return;
        case DESKNUMBER:
            setDeskNumber((String)value);
            return;
        case BUSINESSCARDS:
            setBusinessCards((String)value);
            return;
        case REMOTEACCESS:
            setRemoteAccess((String)value);
            return;
        case PCTYPE:
            setPcType((String)value);
            return;
        case MOBILEDEVICE:
            setMobileDevice((String)value);
            return;
        case DESKLOCATION:
            setDeskLocation((String)value);
            return;
        case OTHERCOMMENTS:
            setOtherComments((String)value);
            return;
        case STATUS:
            setStatus((String)value);
            return;
        case PERSONWITH:
            setPersonWith((String)value);
            return;
        case MANAGERAPPROVER:
            setManagerApprover((String)value);
            return;
        case MANAGERRESPONSE:
            setManagerResponse((String)value);
            return;
        case MANAGERRESPONSEDATE:
            setManagerResponseDate((Date)value);
            return;
        case ITAPPROVER:
            setItApprover((String)value);
            return;
        case ITRESPONSE:
            setItResponse((String)value);
            return;
        case ITRESPONSEDATE:
            setItResponseDate((Date)value);
            return;
        case CSAPPROVER:
            setCsApprover((String)value);
            return;
        case CSRESPONSE:
            setCsResponse((String)value);
            return;
        case CSRESPONSEDATE:
            setCsResponseDate((Date)value);
            return;
        case APPROVALCOMMENTS:
            setApprovalComments((String)value);
            return;
        case LASTUPDATEDATE:
            setLastUpdateDate((Date)value);
            return;
        case LASTUPDATELOGIN:
            setLastUpdateLogin((Number)value);
            return;
        case LASTUPDATEDBY:
            setLastUpdatedBy((Number)value);
            return;
        case CREATIONDATE:
            setCreationDate((Date)value);
            return;
        case CREATEDBY:
            setCreatedBy((Number)value);
            return;
        case USERPROFILE:
            setUserProfile((String)value);
            return;
        case RESTRICTFYI:
            setRestrictFyi((String)value);
            return;
        case EMPLOYEENAME:
            setEmployeeName((String)value);
            return;
        case PORTAL:
            setPortal((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }

    /**Gets the attribute value for UserProfile, using the alias name UserProfile
     */
    public String getUserProfile() {
        return (String)getAttributeInternal(USERPROFILE);
    }

    /**Sets <code>value</code> as the attribute value for UserProfile
     */
    public void setUserProfile(String value) {
        setAttributeInternal(USERPROFILE, value);
    }

    /**Gets the attribute value for RestrictFyi, using the alias name RestrictFyi
     */
    public String getRestrictFyi() {
        return (String)getAttributeInternal(RESTRICTFYI);
    }

    /**Sets <code>value</code> as the attribute value for RestrictFyi
     */
    public void setRestrictFyi(String value) {
        setAttributeInternal(RESTRICTFYI, value);
    }

    /**Gets the attribute value for EmployeeName, using the alias name EmployeeName
     */
    public String getEmployeeName() {
        return (String)getAttributeInternal(EMPLOYEENAME);
    }

    /**Sets <code>value</code> as the attribute value for EmployeeName
     */
    public void setEmployeeName(String value) {
        setAttributeInternal(EMPLOYEENAME, value);
    }

    /**Gets the attribute value for Portal, using the alias name Portal
     */
    public String getPortal() {
        return (String)getAttributeInternal(PORTAL);
    }

    /**Sets <code>value</code> as the attribute value for Portal
     */
    public void setPortal(String value) {
        setAttributeInternal(PORTAL, value);
    }

    /**Creates a Key object based on given key constituents
     */
    public static Key createPrimaryKey(Number assignmentId) {
        return new Key(new Object[]{assignmentId});
    }
}
