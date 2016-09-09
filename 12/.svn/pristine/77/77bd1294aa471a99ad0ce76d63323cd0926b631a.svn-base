--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_CE_BANK_CONTACTS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_CE_BANK_CONTACTS" 
(
  P_BANK_ID IN NUMBER  
, P_BANK_BRANCH_ID IN NUMBER  
, P_BANK_ACCOUNT_ID IN NUMBER  
, P_TYPE IN VARCHAR
) RETURN VARCHAR2 AS 

  TYPE ADDRESS_RECORD IS RECORD
  (IDENTIFYING_ADDRESS_FLAG VARCHAR2(1),
   ADDRESS                  VARCHAR2(400),
   STATUS                   HZ_PARTY_SITES.STATUS%TYPE);
 
   TYPE CONTACT_RECORD IS RECORD
   (JOB_TITLE     HZ_ORG_CONTACTS_CPUI_V.JOB_TITLE%TYPE,
    DEPARTMENT    HZ_ORG_CONTACTS_CPUI_V.DEPARTMENT%TYPE,
    PARTY_NAME    HZ_PARTIES.PARTY_NAME%TYPE,
    PHONE         VARCHAR2(30),
    EMAIL         HZ_PARTIES.EMAIL_ADDRESS%TYPE,
    ADDRESS       VARCHAR2(400));

  L_DOCUMENT			VARCHAR2(32000) := '';
  NL	 	          VARCHAR2(1) := FND_GLOBAL.NEWLINE;
  L_LINE          ADDRESS_RECORD;
  L_CONTACT       CONTACT_RECORD;
  I				        NUMBER := 0;
  MAX_LINES_DSP		NUMBER := 20;
  CURR_LEN			  NUMBER := 0;
  PRIOR_LEN			  NUMBER := 0;
  

 

cursor C_address (L_PARTY_ID number) is SELECT 
    HZPUIPARTYSITEEO.IDENTIFYING_ADDRESS_FLAG,
    LOC.ADDRESS1||','||LOC.ADDRESS3||','||LOC.ADDRESS4||','||LOC.CITY||'.'||loc.state||'.'||loc.province||'.'||loc.county||'.'||loc.postal_Code||','||TERR.TERRITORY_SHORT_NAME ADDRESS,
    HZPUIPARTYSITEEO.STATUS    
  FROM hz_party_sites HzPuiPartySiteEO,
    hz_parties p,
    hz_locations loc,
    FND_TERRITORIES_VL TERR
  WHERE  p.party_id                = L_PARTY_ID
  AND p.party_id                   = HzPuiPartySiteEO.party_id
  AND HzPuiPartySiteEO.location_id = loc.location_id
  AND HzPuiPartySiteEO.status      = 'A'
  AND TERR.TERRITORY_CODE          = LOC.COUNTRY
  ORDER BY identifying_address_flag DESC;

CURSOR C_BRANCH_CONTACTS IS 
 SELECT distinct HzPuiOrgContactsCpuiEO.job_title,
    HzPuiOrgContactsCpuiEO.department,
    OBJPARTY.PARTY_NAME,
    '+'||relparty.primary_phone_country_code||' '||relparty.primary_phone_area_code||' '||relparty.primary_phone_number Phone,
    RELPARTY.EMAIL_ADDRESS EMAIL,
    LOC.ADDRESS1||','||LOC.ADDRESS3||','||LOC.ADDRESS4||','||LOC.CITY||'.'||loc.state||'.'||loc.province||'.'||loc.county||'.'||loc.postal_Code||','||TERR.TERRITORY_SHORT_NAME ADDRESS
  FROM hz_org_contacts_cpui_v HzPuiOrgContactsCpuiEO,
    hz_org_contact_roles HzPuiOrgContactRolesEO,
    hz_relationships rel,
    hz_relationship_groupings_v reltype,
    HZ_PARTIES OBJPARTY,
    FND_TERRITORIES_VL TERR,
    hz_parties relparty,
    hz_party_sites ps,
    hz_locations loc,
    fnd_lookup_values departmentlu,
    FND_LOOKUP_VALUES JOBTITLELU,
    CE_CONTACT_ASSIGNMENTS cca
  WHERE HzPuiOrgContactsCpuiEO.relationship_type   = reltype.relationship_type
  AND HzPuiOrgContactsCpuiEO.relationship_code     = reltype.backward_rel_code
  AND (HzPuiOrgContactsCpuiEO.end_date            IS NULL
  OR HzPuiOrgContactsCpuiEO.end_date              >= sysdate)
  AND HzPuiOrgContactsCpuiEO.STATUS                = 'A'
  AND HzPuiOrgContactsCpuiEO.object_id            <> HzPuiOrgContactsCpuiEO.subject_id
  AND HzPuiOrgContactsCpuiEO.org_contact_id        = HzPuiOrgContactRolesEO.org_contact_id(+)
  AND HzPuiOrgContactRolesEO.status(+)             = 'A'
  AND HzPuiOrgContactsCpuiEO.party_relationship_id = rel.relationship_id
  AND HzPuiOrgContactsCpuiEO.directional_flag      = rel.directional_flag
  AND objparty.party_id                            = HzPuiOrgContactsCpuiEO.object_id
  AND relparty.party_id                            = HzPuiOrgContactsCpuiEO.relationship_party_id
  AND ps.party_id(+)                               = relparty.party_id
  AND ps.identifying_address_flag(+)               = 'Y'
  AND PS.LOCATION_ID                               = LOC.LOCATION_ID (+)
  AND TERR.TERRITORY_CODE             (+)          = LOC.COUNTRY
  AND departmentlu.view_application_id(+)          = 222
  AND departmentlu.lookup_type(+)                  = 'DEPARTMENT_TYPE'
  AND departmentlu.language(+)                     = userenv('LANG')
  AND departmentlu.lookup_code(+)                  = HzPuiOrgContactsCpuiEO.department_code
  AND jobtitlelu.view_application_id(+)            = 222
  AND jobtitlelu.lookup_type(+)                    = 'RESPONSIBILITY'
  AND jobtitlelu.language(+)                       = userenv('LANG')
  AND JOBTITLELU.LOOKUP_CODE(+)                    = HZPUIORGCONTACTSCPUIEO.JOB_TITLE_CODE
  AND RELTYPE.REL_GROUP_CODE     = 'PARTY_REL_GRP_CONTACTS'
  and objparty.party_type = 'PERSON'
  AND CCA.RELATIONSHIP_ID = HZPUIORGCONTACTSCPUIEO.PARTY_RELATIONSHIP_ID
  AND CCA.BANK_PARTY_ID = P_BANK_ID
  AND CCA.BRANCH_PARTY_ID = P_BANK_BRANCH_ID
  and cca.bank_account_id is null;
  
  CURSOR C_ACCOUNT_CONTACTS IS 
 SELECT distinct HzPuiOrgContactsCpuiEO.job_title,
    HzPuiOrgContactsCpuiEO.department,
    OBJPARTY.PARTY_NAME,
    '+'||relparty.primary_phone_country_code||' '||relparty.primary_phone_area_code||' '||relparty.primary_phone_number Phone,
    RELPARTY.EMAIL_ADDRESS EMAIL,
    LOC.ADDRESS1||','||LOC.ADDRESS3||','||LOC.ADDRESS4||','||LOC.CITY||'.'||loc.state||'.'||loc.province||'.'||loc.county||'.'||loc.postal_Code||','||TERR.TERRITORY_SHORT_NAME ADDRESS
  FROM hz_org_contacts_cpui_v HzPuiOrgContactsCpuiEO,
    hz_org_contact_roles HzPuiOrgContactRolesEO,
    hz_relationships rel,
    hz_relationship_groupings_v reltype,
    HZ_PARTIES OBJPARTY,
    FND_TERRITORIES_VL TERR,
    hz_parties relparty,
    hz_party_sites ps,
    hz_locations loc,
    fnd_lookup_values departmentlu,
    FND_LOOKUP_VALUES JOBTITLELU,
    CE_CONTACT_ASSIGNMENTS cca
  WHERE HzPuiOrgContactsCpuiEO.relationship_type   = reltype.relationship_type
  AND HzPuiOrgContactsCpuiEO.relationship_code     = reltype.backward_rel_code
  AND (HzPuiOrgContactsCpuiEO.end_date            IS NULL
  OR HzPuiOrgContactsCpuiEO.end_date              >= sysdate)
  AND HzPuiOrgContactsCpuiEO.STATUS                = 'A'
  AND HzPuiOrgContactsCpuiEO.object_id            <> HzPuiOrgContactsCpuiEO.subject_id
  AND HzPuiOrgContactsCpuiEO.org_contact_id        = HzPuiOrgContactRolesEO.org_contact_id(+)
  AND HzPuiOrgContactRolesEO.status(+)             = 'A'
  AND HzPuiOrgContactsCpuiEO.party_relationship_id = rel.relationship_id
  AND HzPuiOrgContactsCpuiEO.directional_flag      = rel.directional_flag
  AND objparty.party_id                            = HzPuiOrgContactsCpuiEO.object_id
  AND relparty.party_id                            = HzPuiOrgContactsCpuiEO.relationship_party_id
  AND ps.party_id(+)                               = relparty.party_id
  AND ps.identifying_address_flag(+)               = 'Y'
  AND PS.LOCATION_ID                               = LOC.LOCATION_ID (+)
  AND TERR.TERRITORY_CODE             (+)          = LOC.COUNTRY
  AND departmentlu.view_application_id(+)          = 222
  AND departmentlu.lookup_type(+)                  = 'DEPARTMENT_TYPE'
  AND departmentlu.language(+)                     = userenv('LANG')
  AND departmentlu.lookup_code(+)                  = HzPuiOrgContactsCpuiEO.department_code
  AND jobtitlelu.view_application_id(+)            = 222
  AND jobtitlelu.lookup_type(+)                    = 'RESPONSIBILITY'
  AND jobtitlelu.language(+)                       = userenv('LANG')
  AND JOBTITLELU.LOOKUP_CODE(+)                    = HZPUIORGCONTACTSCPUIEO.JOB_TITLE_CODE
  AND RELTYPE.REL_GROUP_CODE     = 'PARTY_REL_GRP_CONTACTS'
  and objparty.party_type = 'PERSON'
  AND CCA.RELATIONSHIP_ID = HZPUIORGCONTACTSCPUIEO.PARTY_RELATIONSHIP_ID
  AND CCA.BANK_PARTY_ID = P_BANK_ID
  and cca.bank_account_id = P_BANK_ACCOUNT_ID;
  

BEGIN
max_lines_dsp := 20;

IF P_TYPE = 'A' -- PARTY ADDRESS
THEN 
IF P_BANK_BRANCH_ID IS NULL  --Bank Address
THEN

          l_document := NL || NL || '<!-- Bank Address -->'|| NL || NL || '<P><B>';
    	   	L_DOCUMENT := L_DOCUMENT || '</B>';
          L_DOCUMENT := L_DOCUMENT || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="Bank Addresses"> '|| NL;
    	    L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
          --Column Headings
          L_DOCUMENT := L_DOCUMENT || '<TH  id="ADDRESS">' ||'Address'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
          
          CURR_LEN  := LENGTHB(L_DOCUMENT);
          prior_len := curr_len;
          
          OPEN C_ADDRESS (P_BANK_ID);
          
          LOOP
          FETCH C_ADDRESS INTO l_line;
          I := I + 1;
      		EXIT WHEN C_ADDRESS%NOTFOUND;
          
           /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                PRIOR_LEN := CURR_LEN;
      		l_document := l_document || '<TR>' || NL;
          
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="ADDRESS">'
				         || NVL(L_LINE.ADDRESS, '&'||'nbsp') || '</TD>' || NL;
                 
                 l_document := l_document || '</TR>' || NL;

                EXIT WHEN i = max_lines_dsp;

                curr_len  := LENGTHB(l_document);
    	END LOOP;
	l_document := l_document || '</TABLE></P>' || NL;

    	CLOSE C_ADDRESS;

ELSIF P_BANK_BRANCH_ID IS NOT NULL -- Branch Address
THEN
          l_document := NL || NL || '<!-- Branch Address -->'|| NL || NL || '<P><B>';
    	   	L_DOCUMENT := L_DOCUMENT || '</B>';
          L_DOCUMENT := L_DOCUMENT || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="Branch Addresses"> '|| NL;
    	    L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
          --Column Headings
          L_DOCUMENT := L_DOCUMENT || '<TH  id="ADDRESS">' ||'Address'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
          
          CURR_LEN  := LENGTHB(L_DOCUMENT);
          prior_len := curr_len;
          
          OPEN C_ADDRESS (P_BANK_BRANCH_ID);
          
          LOOP
          FETCH C_ADDRESS INTO l_line;
          I := I + 1;
      		EXIT WHEN C_ADDRESS%NOTFOUND;
          
           /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                PRIOR_LEN := CURR_LEN;
      		l_document := l_document || '<TR>' || NL;
          
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="ADDRESS">'
				         || NVL(L_LINE.ADDRESS, '&'||'nbsp') || '</TD>' || NL;
                 
                 l_document := l_document || '</TR>' || NL;

                EXIT WHEN i = max_lines_dsp;

                curr_len  := LENGTHB(l_document);
    	END LOOP;
	l_document := l_document || '</TABLE></P>' || NL;

    	CLOSE C_ADDRESS;
 
 END if;  --Address Type

	ELSIF P_TYPE = 'C'  --Contacts
  THEN
  
  IF P_BANK_BRANCH_ID IS NOT NULL   --Branch Contacts
  THEN
  
          l_document := NL || NL || '<!-- Branch Contacts -->'|| NL || NL || '<P><B>';
    	   	L_DOCUMENT := L_DOCUMENT || '</B>';
          L_DOCUMENT := L_DOCUMENT || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="Branch Contacts"> '|| NL;
    	    L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
          --Column Headings
          L_DOCUMENT := L_DOCUMENT || '<TH  id="PARTY_NAME">' ||'Contact Name'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="JOB_TITLE">' ||'Job Title'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="DEPARTMENT">' ||'Department'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="PHONE">' ||'Phone Number'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="EMAIL">' ||'Email'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="ADDRESS">' ||'Address'|| '</TH>' || NL;    
          
          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
          
          CURR_LEN  := LENGTHB(L_DOCUMENT);
          prior_len := curr_len;
          
          OPEN C_BRANCH_CONTACTS;
          
          LOOP
          FETCH C_BRANCH_CONTACTS INTO l_CONTACT;
          I := I + 1;
      		EXIT WHEN C_BRANCH_CONTACTS%NOTFOUND;
          
           /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                PRIOR_LEN := CURR_LEN;
      		l_document := l_document || '<TR>' || NL;
          
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="PARTY_NAME">'
				         || NVL(L_CONTACT.PARTY_NAME, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="JOB_TITLE">'
				         || NVL(L_CONTACT.JOB_TITLE, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="DEPARTMENT">'
				         || NVL(L_CONTACT.DEPARTMENT, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="PHONE">'
				         || NVL(L_CONTACT.PHONE, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EMAIL">'
				         || NVL(L_CONTACT.EMAIL, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="ADDRESS">'
				         || NVL(L_CONTACT.ADDRESS, '&'||'nbsp') || '</TD>' || NL;
                 
                 l_document := l_document || '</TR>' || NL;

                EXIT WHEN i = max_lines_dsp;

                curr_len  := LENGTHB(l_document);
    	END LOOP;
	l_document := l_document || '</TABLE></P>' || NL;

    	CLOSE C_BRANCH_CONTACTS;
  
  ELSIF P_BANK_BRANCH_ID IS NULL    --Account Contacts
  THEN
  
          l_document := NL || NL || '<!-- Account Contacts -->'|| NL || NL || '<P><B>';
    	   	L_DOCUMENT := L_DOCUMENT || '</B>';
          L_DOCUMENT := L_DOCUMENT || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="Account Contacts"> '|| NL;
    	    L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
          --Column Headings
          L_DOCUMENT := L_DOCUMENT || '<TH  id="PARTY_NAME">' ||'Contact Name'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="JOB_TITLE">' ||'Job Title'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="DEPARTMENT">' ||'Department'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="PHONE">' ||'Phone Number'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="EMAIL">' ||'Email'|| '</TH>' || NL;    
          L_DOCUMENT := L_DOCUMENT || '<TH  id="ADDRESS">' ||'Address'|| '</TH>' || NL;    
          
          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
          
          CURR_LEN  := LENGTHB(L_DOCUMENT);
          prior_len := curr_len;
          
          OPEN C_ACCOUNT_CONTACTS;
          
          LOOP
          FETCH C_ACCOUNT_CONTACTS INTO l_CONTACT;
          I := I + 1;
      		EXIT WHEN C_ACCOUNT_CONTACTS%NOTFOUND;
          
           /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                PRIOR_LEN := CURR_LEN;
      		l_document := l_document || '<TR>' || NL;
          
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="PARTY_NAME">'
				         || NVL(L_CONTACT.PARTY_NAME, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="JOB_TITLE">'
				         || NVL(L_CONTACT.JOB_TITLE, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="DEPARTMENT">'
				         || NVL(L_CONTACT.DEPARTMENT, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="PHONE">'
				         || NVL(L_CONTACT.PHONE, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EMAIL">'
				         || NVL(L_CONTACT.EMAIL, '&'||'nbsp') || '</TD>' || NL;
          L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="ADDRESS">'
				         || NVL(L_CONTACT.ADDRESS, '&'||'nbsp') || '</TD>' || NL;
                 
                 l_document := l_document || '</TR>' || NL;

                EXIT WHEN i = max_lines_dsp;

                curr_len  := LENGTHB(l_document);
    	END LOOP;
	l_document := l_document || '</TABLE></P>' || NL;

    	CLOSE C_ACCOUNT_CONTACTS;
  
  DBMS_OUTPUT.PUT_LINE('in here');
  dbms_output.put_line(l_document);
  
  END IF; --Contact Types
  
  END IF;   --P_TYPE
  

  RETURN L_DOCUMENT;
  
END XX_CE_BANK_CONTACTS;

/
