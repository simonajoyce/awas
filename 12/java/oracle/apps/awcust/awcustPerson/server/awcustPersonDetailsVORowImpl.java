package oracle.apps.awcust.awcustPerson.server;
import oracle.apps.fnd.framework.server.OAViewRowImpl;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.RowID;
//  ---------------------------------------------------------------
//  ---    File generated by Oracle Business Components for Java.
//  ---------------------------------------------------------------

public class awcustPersonDetailsVORowImpl extends OAViewRowImpl implements oracle.apps.awcust.awcustPerson.awcustPersonDetailsVORow 
{
  protected static final int PERSONID = 0;
  protected static final int FIRSTNAME = 1;
  protected static final int LASTNAME = 2;
  protected static final int EMAIL = 3;
  protected static final int STARTDATE = 4;
  protected static final int ENDDATE = 5;
  protected static final int OFFICE = 6;
  protected static final int COSTCENTRE = 7;
  protected static final int LINEMANAGER = 8;
  protected static final int EXPENSESAPPROVER = 9;
  protected static final int JOBTITLE = 10;
  protected static final int EMPLOYEETYPE = 11;
  protected static final int PCTYPE = 12;
  protected static final int MOBILEDEVICE = 13;
  protected static final int DESKLOCATION = 14;
  protected static final int OTHERCOMMENTS = 15;
  protected static final int LASTUPDATEDATE = 16;
  protected static final int LASTUPDATELOGIN = 17;
  protected static final int LASTUPDATEDBY = 18;
  protected static final int CREATIONDATE = 19;
  protected static final int CREATEDBY = 20;
  protected static final int ROWID = 21;
  protected static final int STATUS = 22;
  protected static final int PERSONWITH = 23;
  protected static final int BUSINESSCARDS = 24;
  protected static final int APPROVALCOMMENTS = 25;
  protected static final int DEPARTMENT = 26;
  /**
   * 
   * This is the default constructor (do not remove)
   */
  public awcustPersonDetailsVORowImpl()
  {
  }

  /**
   * 
   * Gets awcustPersonDetailsEO entity object.
   */
  public oracle.apps.awcust.awcustPerson.schema.server.awcustPersonDetailsEOImpl getawcustPersonDetailsEO()
  {
    return (oracle.apps.awcust.awcustPerson.schema.server.awcustPersonDetailsEOImpl)getEntity(0);
  }

  /**
   * 
   * Gets the attribute value for PERSON_ID using the alias name PersonId
   */
  public Number getPersonId()
  {
    return (Number)getAttributeInternal(PERSONID);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for PERSON_ID using the alias name PersonId
   */
  public void setPersonId(Number value)
  {
    setAttributeInternal(PERSONID, value);
  }

  /**
   * 
   * Gets the attribute value for FIRST_NAME using the alias name FirstName
   */
  public String getFirstName()
  {
    return (String)getAttributeInternal(FIRSTNAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for FIRST_NAME using the alias name FirstName
   */
  public void setFirstName(String value)
  {
    setAttributeInternal(FIRSTNAME, value);
  }

  /**
   * 
   * Gets the attribute value for LAST_NAME using the alias name LastName
   */
  public String getLastName()
  {
    return (String)getAttributeInternal(LASTNAME);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LAST_NAME using the alias name LastName
   */
  public void setLastName(String value)
  {
    setAttributeInternal(LASTNAME, value);
  }

  /**
   * 
   * Gets the attribute value for EMAIL using the alias name Email
   */
  public String getEmail()
  {
    return (String)getAttributeInternal(EMAIL);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for EMAIL using the alias name Email
   */
  public void setEmail(String value)
  {
    setAttributeInternal(EMAIL, value);
  }

  /**
   * 
   * Gets the attribute value for START_DATE using the alias name StartDate
   */
  public Date getStartDate()
  {
    return (Date)getAttributeInternal(STARTDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for START_DATE using the alias name StartDate
   */
  public void setStartDate(Date value)
  {
    setAttributeInternal(STARTDATE, value);
  }

  /**
   * 
   * Gets the attribute value for END_DATE using the alias name EndDate
   */
  public Date getEndDate()
  {
    return (Date)getAttributeInternal(ENDDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for END_DATE using the alias name EndDate
   */
  public void setEndDate(Date value)
  {
    setAttributeInternal(ENDDATE, value);
  }

  /**
   * 
   * Gets the attribute value for OFFICE using the alias name Office
   */
  public String getOffice()
  {
    return (String)getAttributeInternal(OFFICE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for OFFICE using the alias name Office
   */
  public void setOffice(String value)
  {
    setAttributeInternal(OFFICE, value);
  }

  /**
   * 
   * Gets the attribute value for COST_CENTRE using the alias name CostCentre
   */
  public Number getCostCentre()
  {
    return (Number)getAttributeInternal(COSTCENTRE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for COST_CENTRE using the alias name CostCentre
   */
  public void setCostCentre(Number value)
  {
    setAttributeInternal(COSTCENTRE, value);
  }

  /**
   * 
   * Gets the attribute value for LINE_MANAGER using the alias name LineManager
   */
  public String getLineManager()
  {
    return (String)getAttributeInternal(LINEMANAGER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LINE_MANAGER using the alias name LineManager
   */
  public void setLineManager(String value)
  {
    setAttributeInternal(LINEMANAGER, value);
  }

  /**
   * 
   * Gets the attribute value for EXPENSES_APPROVER using the alias name ExpensesApprover
   */
  public String getExpensesApprover()
  {
    return (String)getAttributeInternal(EXPENSESAPPROVER);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for EXPENSES_APPROVER using the alias name ExpensesApprover
   */
  public void setExpensesApprover(String value)
  {
    setAttributeInternal(EXPENSESAPPROVER, value);
  }

  /**
   * 
   * Gets the attribute value for JOB_TITLE using the alias name JobTitle
   */
  public String getJobTitle()
  {
    return (String)getAttributeInternal(JOBTITLE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for JOB_TITLE using the alias name JobTitle
   */
  public void setJobTitle(String value)
  {
    setAttributeInternal(JOBTITLE, value);
  }

  /**
   * 
   * Gets the attribute value for EMPLOYEE_TYPE using the alias name EmployeeType
   */
  public String getEmployeeType()
  {
    return (String)getAttributeInternal(EMPLOYEETYPE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for EMPLOYEE_TYPE using the alias name EmployeeType
   */
  public void setEmployeeType(String value)
  {
    setAttributeInternal(EMPLOYEETYPE, value);
  }

  /**
   * 
   * Gets the attribute value for PC_TYPE using the alias name PcType
   */
  public String getPcType()
  {
    return (String)getAttributeInternal(PCTYPE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for PC_TYPE using the alias name PcType
   */
  public void setPcType(String value)
  {
    setAttributeInternal(PCTYPE, value);
  }

  /**
   * 
   * Gets the attribute value for MOBILE_DEVICE using the alias name MobileDevice
   */
  public String getMobileDevice()
  {
    return (String)getAttributeInternal(MOBILEDEVICE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for MOBILE_DEVICE using the alias name MobileDevice
   */
  public void setMobileDevice(String value)
  {
    setAttributeInternal(MOBILEDEVICE, value);
  }

  /**
   * 
   * Gets the attribute value for DESK_LOCATION using the alias name DeskLocation
   */
  public String getDeskLocation()
  {
    return (String)getAttributeInternal(DESKLOCATION);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for DESK_LOCATION using the alias name DeskLocation
   */
  public void setDeskLocation(String value)
  {
    setAttributeInternal(DESKLOCATION, value);
  }

  /**
   * 
   * Gets the attribute value for OTHER_COMMENTS using the alias name OtherComments
   */
  public String getOtherComments()
  {
    return (String)getAttributeInternal(OTHERCOMMENTS);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for OTHER_COMMENTS using the alias name OtherComments
   */
  public void setOtherComments(String value)
  {
    setAttributeInternal(OTHERCOMMENTS, value);
  }

  /**
   * 
   * Gets the attribute value for LAST_UPDATE_DATE using the alias name LastUpdateDate
   */
  public Date getLastUpdateDate()
  {
    return (Date)getAttributeInternal(LASTUPDATEDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LAST_UPDATE_DATE using the alias name LastUpdateDate
   */
  public void setLastUpdateDate(Date value)
  {
    setAttributeInternal(LASTUPDATEDATE, value);
  }

  /**
   * 
   * Gets the attribute value for LAST_UPDATE_LOGIN using the alias name LastUpdateLogin
   */
  public Number getLastUpdateLogin()
  {
    return (Number)getAttributeInternal(LASTUPDATELOGIN);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LAST_UPDATE_LOGIN using the alias name LastUpdateLogin
   */
  public void setLastUpdateLogin(Number value)
  {
    setAttributeInternal(LASTUPDATELOGIN, value);
  }

  /**
   * 
   * Gets the attribute value for LAST_UPDATED_BY using the alias name LastUpdatedBy
   */
  public Number getLastUpdatedBy()
  {
    return (Number)getAttributeInternal(LASTUPDATEDBY);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for LAST_UPDATED_BY using the alias name LastUpdatedBy
   */
  public void setLastUpdatedBy(Number value)
  {
    setAttributeInternal(LASTUPDATEDBY, value);
  }

  /**
   * 
   * Gets the attribute value for CREATION_DATE using the alias name CreationDate
   */
  public Date getCreationDate()
  {
    return (Date)getAttributeInternal(CREATIONDATE);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CREATION_DATE using the alias name CreationDate
   */
  public void setCreationDate(Date value)
  {
    setAttributeInternal(CREATIONDATE, value);
  }

  /**
   * 
   * Gets the attribute value for CREATED_BY using the alias name CreatedBy
   */
  public Number getCreatedBy()
  {
    return (Number)getAttributeInternal(CREATEDBY);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for CREATED_BY using the alias name CreatedBy
   */
  public void setCreatedBy(Number value)
  {
    setAttributeInternal(CREATEDBY, value);
  }

  /**
   * 
   * Gets the attribute value for ROWID using the alias name RowID
   */
  public RowID getRowID()
  {
    return (RowID)getAttributeInternal(ROWID);
  }
  //  Generated method. Do not modify.

  protected Object getAttrInvokeAccessor(int index, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case PERSONID:
        return getPersonId();
      case FIRSTNAME:
        return getFirstName();
      case LASTNAME:
        return getLastName();
      case EMAIL:
        return getEmail();
      case STARTDATE:
        return getStartDate();
      case ENDDATE:
        return getEndDate();
      case OFFICE:
        return getOffice();
      case COSTCENTRE:
        return getCostCentre();
      case LINEMANAGER:
        return getLineManager();
      case EXPENSESAPPROVER:
        return getExpensesApprover();
      case JOBTITLE:
        return getJobTitle();
      case EMPLOYEETYPE:
        return getEmployeeType();
      case PCTYPE:
        return getPcType();
      case MOBILEDEVICE:
        return getMobileDevice();
      case DESKLOCATION:
        return getDeskLocation();
      case OTHERCOMMENTS:
        return getOtherComments();
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
      case ROWID:
        return getRowID();
      case STATUS:
        return getStatus();
      case PERSONWITH:
        return getPersonWith();
      case BUSINESSCARDS:
        return getBusinessCards();
      case APPROVALCOMMENTS:
        return getApprovalComments();
      case DEPARTMENT:
        return getDepartment();
      default:
        return super.getAttrInvokeAccessor(index, attrDef);
      }
  }
  //  Generated method. Do not modify.

  protected void setAttrInvokeAccessor(int index, Object value, AttributeDefImpl attrDef) throws Exception
  {
    switch (index)
      {
      case PERSONID:
        setPersonId((Number)value);
        return;
      case FIRSTNAME:
        setFirstName((String)value);
        return;
      case LASTNAME:
        setLastName((String)value);
        return;
      case EMAIL:
        setEmail((String)value);
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
      case LINEMANAGER:
        setLineManager((String)value);
        return;
      case EXPENSESAPPROVER:
        setExpensesApprover((String)value);
        return;
      case JOBTITLE:
        setJobTitle((String)value);
        return;
      case EMPLOYEETYPE:
        setEmployeeType((String)value);
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
      case STATUS:
        setStatus((String)value);
        return;
      case PERSONWITH:
        setPersonWith((String)value);
        return;
      case BUSINESSCARDS:
        setBusinessCards((String)value);
        return;
      case APPROVALCOMMENTS:
        setApprovalComments((String)value);
        return;
      case DEPARTMENT:
        setDepartment((String)value);
        return;
      default:
        super.setAttrInvokeAccessor(index, value, attrDef);
        return;
      }
  }

  /**
   * 
   * Gets the attribute value for STATUS using the alias name Status
   */
  public String getStatus()
  {
    return (String)getAttributeInternal(STATUS);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for STATUS using the alias name Status
   */
  public void setStatus(String value)
  {
    setAttributeInternal(STATUS, value);
  }

  /**
   * 
   * Gets the attribute value for PERSON_WITH using the alias name PersonWith
   */
  public String getPersonWith()
  {
    return (String)getAttributeInternal(PERSONWITH);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for PERSON_WITH using the alias name PersonWith
   */
  public void setPersonWith(String value)
  {
    setAttributeInternal(PERSONWITH, value);
  }

  public int getSTATUS()
  {
    return STATUS;
  }

  /**
   * 
   * Gets the attribute value for BUSINESS_CARDS using the alias name BusinessCards
   */
  public String getBusinessCards()
  {
    return (String)getAttributeInternal(BUSINESSCARDS);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for BUSINESS_CARDS using the alias name BusinessCards
   */
  public void setBusinessCards(String value)
  {
    setAttributeInternal(BUSINESSCARDS, value);
  }

  /**
   * 
   * Gets the attribute value for APPROVAL_COMMENTS using the alias name ApprovalComments
   */
  public String getApprovalComments()
  {
    return (String)getAttributeInternal(APPROVALCOMMENTS);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for APPROVAL_COMMENTS using the alias name ApprovalComments
   */
  public void setApprovalComments(String value)
  {
    setAttributeInternal(APPROVALCOMMENTS, value);
  }

  /**
   * 
   * Gets the attribute value for DEPARTMENT using the alias name Department
   */
  public String getDepartment()
  {
    return (String)getAttributeInternal(DEPARTMENT);
  }

  /**
   * 
   * Sets <code>value</code> as attribute value for DEPARTMENT using the alias name Department
   */
  public void setDepartment(String value)
  {
    setAttributeInternal(DEPARTMENT, value);
  }


}