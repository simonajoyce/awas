--------------------------------------------------------
--  File created - Monday-July-04-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AR_GET_CONTACTS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AR_GET_CONTACTS" 
(
  P_CONTACT_TYPE IN VARCHAR2 
, P_PRIMARY_YN IN VARCHAR2 
, P_CUST_ACCOUNT_ID IN VARCHAR2 
) RETURN VARCHAR2 AS 

/*Parameters
  P_CONTACT_TYPE,  DUN or STMTS for Dunning and Statements
  P_PRIMARY_YN   use Y to return Primary Contacts only
  P_CUST_ACCOUNT_ID  Customer_account_id

*/


EMAIL  VARCHAR2(2000);



CURSOR C1 is 
       SELECT        hrr.RESPONSIBILITY_TYPE
                   , hrr.PRIMARY_FLAG
                   , hpsub.PARTY_NAME
                   , hprel.EMAIL_ADDRESS
                 FROM HZ_CUST_ACCOUNT_ROLES hcar
                   , HZ_PARTIES hpsub
                   , HZ_PARTIES hprel
                   , HZ_PARTIES hpobj
                   , HZ_ORG_CONTACTS hoc
                   , HZ_RELATIONSHIPS hr
                   , HZ_PARTY_SITES hps
                   , FND_TERRITORIES_VL ftv
                   , fnd_lookup_values_vl lookups
                   , hz_cust_accounts act
                   , HZ_ROLE_RESPONSIBILITY hrr
                WHERE hcar.CUST_ACCOUNT_ID                     = P_CUST_ACCOUNT_ID
                 AND hcar.ROLE_TYPE                            = 'CONTACT'
                 AND hcar.PARTY_ID                             = hr.PARTY_ID
                 AND hr.PARTY_ID                               = hprel.PARTY_ID
                 AND hr.SUBJECT_ID                             = hpsub.PARTY_ID
                 AND hr.OBJECT_ID                              = hpobj.PARTY_ID
                 AND hoc.PARTY_RELATIONSHIP_ID                 = hr.RELATIONSHIP_ID
                 AND hcar.cust_account_id                      = act.cust_account_id
                 AND act.party_id                              = hr.object_id
                 AND hps.PARTY_ID(+)                           = hprel.PARTY_ID
                 AND NVL(hps.IDENTIFYING_ADDRESS_FLAG(+), 'Y') = 'Y'
                 AND NVL(hps.STATUS(+), 'A')                   = 'A'
                 AND hprel.COUNTRY                             = ftv.TERRITORY_CODE(+)
                 AND lookups.LOOKUP_TYPE (+)                   = 'RESPONSIBILITY'
                 AND lookups.LOOKUP_CODE(+)                    = hoc.JOB_TITLE_CODE
                 and hcar.STATUS                               = 'A'
                 AND hr.STATUS                                 = 'A'
                 and hrr.CUST_ACCOUNT_ROLE_ID                  = hcar.CUST_ACCOUNT_ROLE_ID
                 and hrr.primary_flag                          = P_PRIMARY_YN
                 and hrr.RESPONSIBILITY_TYPE                   = P_CONTACT_TYPE;


BEGIN
  
  for r1 in c1 loop
  
  EMAIL := EMAIL||';'||R1.email_Address;
  
  end loop;
  
  EMAIL := ltrim(EMAIL,';');
  
  
  RETURN EMAIL;
  

END XX_AR_GET_CONTACTS;

/
