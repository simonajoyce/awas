CREATE OR REPLACE PACKAGE XX_AP_SUPPLIER_WF AS 

PROCEDURE archive_site
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );

PROCEDURE archive_bank
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
PROCEDURE archive_bank2
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE validate_bank
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );
          
PROCEDURE get_site_approver
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );

PROCEDURE get_bank_account_approver
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );          
          

PROCEDURE set_site_attributes
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );
          
PROCEDURE name_change_init
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );
          
PROCEDURE intermediary_init
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE intermediary_approved
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE intermediary_rejected
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );


PROCEDURE disable_site
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );
          
PROCEDURE set_account_attributes
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );
          
PROCEDURE remove_Site_holds
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );

PROCEDURE enable_bank
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );
          
PROCEDURE enable_bank2
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 );
          
PROCEDURE noti_handler_new_site(itemtype IN VARCHAR2,
                        ITEMKEY IN VARCHAR2,
                        actid   IN NUMBER,
                        FUNCMODE IN VARCHAR2,
                        RESULTOUT  OUT NOCOPY VARCHAR2 );
                        
PROCEDURE noti_handler_new_bank(itemtype IN VARCHAR2,
                        ITEMKEY IN VARCHAR2,
                        actid   IN NUMBER,
                        FUNCMODE IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	);
  
PROCEDURE name_change_rej
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 );

PROCEDURE bank_attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   ACTID       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   RESULTOUT   IN OUT NOCOPY   VARCHAR2
	);
  
PROCEDURE tax_details_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	);

PROCEDURE GET_ATTACHMENTS (DOCUMENT_ID IN VARCHAR2, 
      DISPLAY_TYPE IN VARCHAR2, 
      DOCUMENT IN OUT BLOB, 
      DOCUMENT_TYPE IN OUT VARCHAR2);

PROCEDURE GET_INTERMED_DETAILS( p_ext_bank_account_id		IN NUMBER ,
                                display_type		IN VARCHAR2 DEFAULT 'text/html',
                                document		IN OUT	NOCOPY VARCHAR2,
                                document_type	IN OUT	NOCOPY VARCHAR2);

END XX_AP_SUPPLIER_WF;
/


CREATE OR REPLACE PACKAGE BODY XX_AP_SUPPLIER_WF AS

TYPE int_acc_detail_record IS RECORD
		(     
COUNTRY_CODE                      VARCHAR2(2),   
BANK_NAME                         VARCHAR2(360), 
CITY                              VARCHAR2(60)  ,
BANK_CODE                         VARCHAR2(30)  ,
BRANCH_NUMBER                     VARCHAR2(30)  ,
BIC                               VARCHAR2(30)  ,
ACCOUNT_NUMBER                    VARCHAR2(100) ,
IBAN                              VARCHAR2(50)  ,
COMMENTS                          VARCHAR2(240) 
		 );

PROCEDURE INSERT_APPROVAL_HISTORY(ITEMTYPE IN VARCHAR2,
                                ITEMKEY   IN  VARCHAR2,
                                P_APPROVER  IN VARCHAR2,
                                P_RESULT    IN VARCHAR2,
                                P_COMMENTS  IN VARCHAR2);

PROCEDURE tax_details_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	) as
  
  l_country  ap_supplier_sites_all.country%type;
  L_vat_registration_num  AP_SUPPLIER_SITES_ALL.VAT_REGISTRATION_NUM%type;
  
  begin
  --check if Vendor site is in Ireland if so check for Tax Registration
  select s.country, nvl(s.vat_registration_num,h.vat_registration_num)
  into l_country,
  L_vat_registration_num
  from ap_supplier_sites_all s,
  ap_suppliers h
  WHERE s.vendor_id = h.vendor_id
  and s.VENDOR_SITE_ID = TO_NUMBER(ITEMKEY);
  
  if l_country = 'IE' then
  
  if l_vat_registration_num is null then
  
  resultout := wf_engine.eng_completed || ':' ||  'F';
        
  WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','No Supplier Tax Details Entered.');
  else 
   resultout := wf_engine.eng_completed || ':' ||  'T';
   end if;
  else 
  --Supplier not in Ireland
   resultout := wf_engine.eng_completed || ':' ||  'T';
   
  end if;
  
  	EXCEPTION
	   WHEN OTHERS
	   THEN
      
	      wf_core.CONTEXT ('xx_ap_supplier_wf_pkg', 'tax_details_exist');
  
  end tax_details_exist;
  
PROCEDURE archive_site
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) AS
          
  L_VENDOR_ID NUMBER(15);
  L_VENDOR_EXISTS NUMBER(15);
  
  BEGIN
  
  

  INSERT INTO XX_AP_SUPPLIER_SITES_HIST 
  (SELECT X.*,  XX_AP_SUPPLIER_SITES_S.NEXTVAL
  FROM AP_SUPPLIER_SITES_ALL X
  WHERE VENDOR_SITE_ID = TO_NUMBER(ITEMKEY));

  WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VERSION_ID',XX_AP_SUPPLIER_SITES_S.CURRVAL);  
  
  SELECT VENDOR_ID
  INTO L_VENDOR_ID
  FROM AP_SUPPLIER_SITES_ALL
  WHERE VENDOR_SITE_ID = TO_NUMBER(ITEMKEY);
  
  SELECT COUNT(*)
  INTO L_VENDOR_EXISTS
  FROM XX_AP_SUPPLIERS_HIST
  WHERE VENDOR_ID = L_VENDOR_ID;
  
  IF L_VENDOR_EXISTS = 0 THEN
  
  INSERT INTO XX_AP_SUPPLIERS_HIST
  (SELECT X.*, XX_AP_SUPPLIER_S.NEXTVAL
  FROM AP_SUPPLIERS X
  WHERE VENDOR_ID = L_VENDOR_ID);
  
  END IF;
  
  WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','');
  

  END archive_site;
  
PROCEDURE archive_bank
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) AS

BEGIN

INSERT INTO XX_IBY_EXT_BANK_ACCOUNTS_HIST 
  (SELECT X.*,  XX_IBY_EXT_BANK_ACCOUNTS_S.NEXTVAL
  FROM IBY_EXT_BANK_ACCOUNTS X
  WHERE EXT_BANK_ACCOUNT_ID = TO_NUMBER(ITEMKEY));

  WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VERSION_ID',XX_IBY_EXT_BANK_ACCOUNTS_S.CURRVAL);  
  


END ARCHIVE_BANK;

PROCEDURE name_change_rej
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as

l_ext_bank_account_id iby_ext_bank_accounts.ext_bank_account_id%type;
l_OLD_BANK_ACCOUNT_NAME  varchar2(100);
begin

l_ext_bank_account_id   := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID');
l_OLD_BANK_ACCOUNT_NAME := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'OLD_BANK_ACCOUNT_NAME');

update iby_ext_bank_accounts
set bank_account_name = l_OLD_BANK_ACCOUNT_NAME,
    attribute15 = 'A'
where ext_bank_account_id = l_ext_bank_account_id;

      update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'N',
          HOLD_REASON            = null
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = L_EXT_BANK_ACCOUNT_ID);


end name_change_rej;

PROCEDURE archive_bank2
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) AS

L_EXT_BANK_ACCOUNT_ID iby_ext_bank_accounts.ext_bank_account_ID%type;

BEGIN

L_EXT_BANK_ACCOUNT_ID     := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID');

INSERT INTO XX_IBY_EXT_BANK_ACCOUNTS_HIST 
  (SELECT X.*,  substr(itemkey,instr(itemkey,'-')+1,length(itemkey)-instr(itemkey,'-')+1)
  FROM IBY_EXT_BANK_ACCOUNTS X
  WHERE EXT_BANK_ACCOUNT_ID = L_EXT_BANK_ACCOUNT_ID);

  WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VERSION_ID',substr(itemkey,instr(itemkey,'-')+1,length(itemkey)-instr(itemkey,'-')+1));  
  


END ARCHIVE_BANK2;
          

PROCEDURE remove_Site_holds
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY varchar2 ) as

L_REASON AP_SUPPLIER_SITES_ALL.HOLD_REASON%type;
L_SITE_APPROVER varchar2(50);


begin

select HOLD_REASON
into L_REASON
from AP_SUPPLIER_SITES_ALL
where VENDOR_SITE_ID = TO_CHAR(ITEMKEY);

l_Site_approver := WF_ENGINE.gETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'SITE_APPROVER');

if l_reason = 'Supplier Site Not Yet Approved '||l_site_approver then  -- only supplier site awaiting approval

UPDATE AP_SUPPLIER_SITES_ALL
SET ATTRIBUTE15 = 'A'  -- Approved
,   HOLD_REASON = NULL
,   HOLD_ALL_PAYMENTS_FLAG = 'N'
WHERE VENDOR_SITE_ID = to_char(ITEMKEY);

else

update AP_SUPPLIER_SITES_ALL
SET HOLD_REASON = trim(replace(hold_reason, 'Supplier Site Not Yet Approved '||l_site_approver,''))
where VENDOR_SITE_ID = TO_CHAR(ITEMKEY);

end if;


END REMOVE_SITE_HOLDS;  

PROCEDURE disable_site
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) as

begin

UPDATE AP_SUPPLIER_SITES_ALL
SET VENDOR_SITE_CODE_ALT = 'SITE REJECTED'
,   ATTRIBUTE15 = 'R'
,   HOLD_REASON = 'SITE APPROVAL REJECTED'
,   INACTIVE_DATE = sysdate
WHERE VENDOR_SITE_ID = to_char(ITEMKEY);


end disable_site;

PROCEDURE enable_bank
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) AS

L_APPROVER_NAME FND_USER.USER_NAME%type;
L_REASON  varchar2(240);

BEGIN

 L_APPROVER_NAME           := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_NAME');
 
 

begin
UPDATE IBY_EXT_BANK_ACCOUNTS 
set ATTRIBUTE15 = 'A'  -- Approved
,   START_DATE = to_date(nvl(attribute1,sysdate),'DD-MON-YYYY')
,   attribute1 = NULL
,   ATTRIBUTE14 =  sysdate  -- approval date
,   ATTRIBUTE13 = L_APPROVER_NAME  -- approver name
WHERE ext_bank_Account_ID = to_char(ITEMKEY);

EXCEPTION when OTHERS then

UPDATE IBY_EXT_BANK_ACCOUNTS 
SET ATTRIBUTE15 = 'A'  -- Approved
,   START_DATE = to_date(attribute1,'DD-MM-YYYY')
,   attribute1 = NULL
,   ATTRIBUTE14 =  sysdate  -- approval date
,   ATTRIBUTE13 = L_APPROVER_NAME  -- approver name
where EXT_BANK_ACCOUNT_ID = TO_CHAR(ITEMKEY);

end;




update IBY_PMT_INSTR_USES_ALL
set start_date = sysdate
where instrument_type = 'BANKACCOUNT'
and payment_function = 'PAYABLES_DISB'
and instrument_id = to_number(itemkey);



          select distinct HOLD_REASON
          into L_REASON
          from AP_SUPPLIER_SITES_ALL
          where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and SUP.PARTY_ID = AO.ACCOUNT_OWNER_PARTY_ID
                          and BA.EXT_BANK_ACCOUNT_ID = TO_CHAR(ITEMKEY));


if L_REASON like '%Supplier Site Not Yet Approved%' then  -- site not yet approved

update AP_SUPPLIER_SITES_ALL
      set HOLD_REASON  = substr(hold_reason,1,instr(hold_reason,'Pending'))
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and SUP.PARTY_ID = AO.ACCOUNT_OWNER_PARTY_ID
                          and BA.EXT_BANK_ACCOUNT_ID = TO_CHAR(ITEMKEY));
else

update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'N',
          HOLD_REASON            = null
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and SUP.PARTY_ID = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = TO_CHAR(ITEMKEY));

end if;



END ENABLE_BANK;  


PROCEDURE enable_bank2
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) AS
-- Enable Bank Account after approved Name Change
L_APPROVER_NAME fnd_user.user_name%Type;
L_EXT_BANK_ACCOUNT_ID iby_ext_bank_accounts.ext_bank_account_ID%type;

BEGIN

 L_APPROVER_NAME           := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_NAME');
 L_EXT_BANK_ACCOUNT_ID     := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID');
 
UPDATE IBY_EXT_BANK_ACCOUNTS 
SET ATTRIBUTE15 = 'A'  -- Approved
,   ATTRIBUTE14 =  sysdate  -- approval date
,   ATTRIBUTE13 = L_APPROVER_NAME  -- approver name
WHERE ext_bank_Account_ID = L_ext_BANK_ACCOUNT_ID;

update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'N',
          HOLD_REASON            = null
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = L_EXT_BANK_ACCOUNT_ID);


END ENABLE_BANK2;  

PROCEDURE get_site_approver
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 )
IS
L_SITE_APPROVER  VARCHAR2(50);
L_VENDOR_TYPE  VARCHAR2(50);

BEGIN

SELECT VENDOR_TYPE_LOOKUP_CODE
INTO L_VENDOR_TYPE
FROM AP_SUPPLIERS S,
AP_SUPPLIER_SITES_ALL A
WHERE A.VENDOR_ID = S.VENDOR_ID
AND A.VENDOR_SITE_ID = TO_NUMBER(ITEMKEY);

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_TYPE',L_VENDOR_TYPE);

SELECT ATTRIBUTE1
into L_SITE_APPROVER
FROM FND_LOOKUP_VALUES
WHERE LOOKUP_TYPE = 'VENDOR TYPE'
AND LANGUAGE = 'US'
and lookup_code = l_VENDOR_TYPE;

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'SITE_APPROVER',L_SITE_APPROVER);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'ORIGINAL_APPROVER',L_SITE_APPROVER);

update AP_SUPPLIER_SITES_ALL
set HOLD_REASON = replace(replace(HOLD_REASON,'Supplier Site Not Yet Approved',''),L_SITE_APPROVER,'')||'Supplier Site Not Yet Approved '||L_SITE_APPROVER
where VENDOR_SITE_ID = TO_NUMBER(ITEMKEY);

end get_site_approver;

PROCEDURE validate_bank
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 )
          
AS
BEGIN

update IBY_PMT_INSTR_USES_ALL
set start_date = '31-Dec-4712'
where instrument_type = 'BANKACCOUNT'
and payment_function = 'PAYABLES_DISB'
and instrument_id = to_number(itemkey);




END VALIDATE_BANK;


PROCEDURE get_bank_account_approver
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 )
IS
L_ACCOUNT_APPROVER  VARCHAR2(50);
l_ext_bank_account_id number;

begin

 L_EXT_BANK_ACCOUNT_ID     := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID');
 
 DBMS_OUTPUT.PUT_LINE('L_EXT_BANK_ACCOUNT_ID='||L_EXT_BANK_ACCOUNT_ID);
 
 if L_ext_bank_account_id is null then
 L_EXT_BANK_ACCOUNT_ID := ITEMKEY;
 DBMS_OUTPUT.PUT_LINE('L_EXT_BANK_ACCOUNT_ID='||L_EXT_BANK_ACCOUNT_ID);
 end if;

SELECT * 
INTO L_ACCOUNT_APPROVER
from (                           
SELECT user_name 
FROM WF_LOCAL_USER_ROLES 
WHERE ROLE_NAME = 'FND_RESP|AWCUST|AWAS_EXTERNAL_BANK_APPROVER|STANDARD'
AND USER_END_DATE IS NULL
AND ROLE_END_DATE IS NULL
and user_name not in (select nvl(flv.ATTRIBUTE1,'X')
from  iby_ext_bank_accounts b, 
IBY_PMT_INSTR_USES_ALL u,
iby_external_payees_all ep,
ap_suppliers pov,
FND_LOOKUP_VALUES flv
where U.INSTRUMENT_ID = B.EXT_BANK_ACCOUNT_ID
and U.EXT_PMT_PARTY_ID = ep.ext_payee_id
and EP.PAYEE_PARTY_ID = POV.PARTY_ID
and nvl(FLV.LOOKUP_TYPE,'VENDOR TYPE') = 'VENDOR TYPE'
and nvl(FLV.LANGUAGE,'US') = 'US'
and FLV.LOOKUP_CODE (+) = POV.VENDOR_TYPE_LOOKUP_CODE
and B.EXT_BANK_ACCOUNT_ID = to_number(L_EXT_BANK_ACCOUNT_ID))
AND SYSDATE BETWEEN START_DATE AND nvl(expiration_DATE,sysdate+1)
ORDER BY DBMS_RANDOM.VALUE)
where rownum = 1;

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_NAME',L_ACCOUNT_APPROVER);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'ORIGINAL_APPROVER',L_ACCOUNT_APPROVER);

UPDATE IBY_EXT_BANK_ACCOUNTS 
SET   ATTRIBUTE13 = L_ACCOUNT_APPROVER, -- approver name
      ATTRIBUTE15 = 'P'
WHERE ext_bank_Account_ID = l_ext_bank_account_id;

update AP_SUPPLIER_SITES_ALL
      set HOLD_REASON  = hold_reason||' Pending Bank Account Approval with '||L_ACCOUNT_APPROVER,
          HOLD_ALL_PAYMENTS_FLAG = 'Y'
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = l_ext_bank_account_id);

end get_bank_account_approver; 
  

PROCEDURE set_site_attributes
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) AS
          
L_VENDOR_NAME       AP_SUPPLIERS.VENDOR_NAME%TYPE;
L_VENDOR_NUMBER     AP_SUPPLIERS.SEGMENT1%TYPE;
L_VENDOR_TYPE       AP_SUPPLIERS.VENDOR_TYPE_LOOKUP_CODE%TYPE;
L_VENDOR_ID         AP_SUPPLIERS.VENDOR_ID%TYPE;
L_VENDOR_SITE_CODE  AP_SUPPLIER_SITES_ALL.VENDOR_SITE_CODE%TYPE;
L_VENDOR_SITE_ID    AP_SUPPLIER_SITES_ALL.VENDOR_SITE_ID%TYPE;
L_CHANGED_BY        FND_USER.USER_NAME%TYPE;
L_PO_SITE_FLAG      AP_SUPPLIER_SITES_ALL.PURCHASING_SITE_FLAG%TYPE;
L_PAY_SITE_FLAG     AP_SUPPLIER_SITES_ALL.PAY_SITE_FLAG%TYPE;
L_ADDRESS           VARCHAR2(2000);
L_PHONE             VARCHAR2(50);
L_PAYMENT_TERMS     AP_TERMS.NAME%TYPE;
L_CURRENCY          AP_SUPPLIER_SITES_ALL.INVOICE_CURRENCY_CODE%TYPE;
L_VAT_REGISTRATION_CODE AP_SUPPLIER_SITES_ALL.VAT_REGISTRATION_NUM%TYPE;


  BEGIN
  
  SELECT X.VENDOR_NAME,
       X.SEGMENT1 VENDOR_NUMBER,
       X.VENDOR_TYPE_LOOKUP_CODE,
       x.vendor_id,
       S.VENDOR_SITE_CODE,
       S.VENDOR_SITE_ID,
       U.USER_NAME,
       S.PURCHASING_SITE_FLAG PO_SITE_FLAG,
       S.PAY_SITE_FLAG,
       S.ADDRESS_LINE1||DECODE(S.ADDRESS_LINE2,NULL,NULL,CHR(12))||
       S.ADDRESS_LINE2||DECODE(S.ADDRESS_LINE3,NULL,NULL,CHR(12))||
       S.ADDRESS_LINE3||DECODE(S.ADDRESS_LINE4,NULL,NULL,CHR(12))||
       S.ADDRESS_LINE4||DECODE(S.CITY,NULL,NULL,CHR(12))||
       S.CITY||DECODE(S.STATE,NULL,NULL,CHR(12))||
       S.STATE||DECODE(S.COUNTY,NULL,NULL,CHR(12))||
       S.COUNTY||DECODE(S.PROVINCE,NULL,NULL,CHR(12))||
       S.PROVINCE||DECODE(S.ZIP,NULL,NULL,CHR(12))||
       S.ZIP||DECODE(S.COUNTRY,NULL,NULL,CHR(12))||
       S.COUNTRY ADDRESS,
       S.AREA_CODE||'-'||S.PHONE PHONE,
       T.NAME PAYMENT_TERMS,
       S.INVOICE_CURRENCY_CODE,
       x.VAT_REGISTRATION_NUM       
    INTO
      L_VENDOR_NAME,   
      L_VENDOR_NUMBER     ,
      L_VENDOR_TYPE       ,
      L_VENDOR_ID         ,
      L_VENDOR_SITE_CODE  ,
      L_VENDOR_SITE_ID    ,
      L_CHANGED_BY        ,
      L_PO_SITE_FLAG      ,
      L_PAY_SITE_FLAG     ,
      L_ADDRESS           ,
      L_PHONE             ,
      L_PAYMENT_TERMS     ,
      L_CURRENCY          ,
      L_VAT_REGISTRATION_CODE 
    FROM  AP_SUPPLIER_SITES_ALL S,
          AP_SUPPLIERS x,
          FND_USER U,
          ap_terms t
    WHERE U.USER_ID = S.CREATED_BY
    AND S.VENDOR_ID = X.VENDOR_ID
    AND T.TERM_ID (+) = S.TERMS_ID
    AND VENDOR_SITE_ID = ITEMKEY;
    
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_NAME',L_VENDOR_NAME);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_NUMBER',L_VENDOR_NUMBER);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_TYPE',L_VENDOR_TYPE);
    WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VENDOR_ID',L_VENDOR_ID);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_SITE_CODE',L_VENDOR_SITE_CODE);
    WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VENDOR_SITE_ID',L_VENDOR_SITE_ID);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'CHANGED_BY',L_CHANGED_BY);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'PO_SITE_FLAG',L_PO_SITE_FLAG);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'PAY_SITE_FLAG',L_PAY_SITE_FLAG);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'ADDRESS',L_ADDRESS);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'PHONE',L_PHONE);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'PAYMENT_TERMS',L_PAYMENT_TERMS);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'CURRENCY',L_CURRENCY);
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VAT_REGISTRATION_CODE',L_VAT_REGISTRATION_CODE);
    
    WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','');
  
  END set_site_attributes;

PROCEDURE set_account_attributes
     (    itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULTOUT OUT NOCOPY VARCHAR2 ) 
AS

L_VENDOR_NAME       AP_SUPPLIERS.VENDOR_NAME%TYPE;
L_VENDOR_NUMBER     AP_SUPPLIERS.SEGMENT1%TYPE;
L_VENDOR_TYPE       AP_SUPPLIERS.VENDOR_TYPE_LOOKUP_CODE%TYPE;
L_VENDOR_ID         AP_SUPPLIERS.VENDOR_ID%TYPE;
L_VENDOR_SITE_CODE  AP_SUPPLIER_SITES_ALL.VENDOR_SITE_CODE%TYPE;
L_VENDOR_SITE_ID    AP_SUPPLIER_SITES_ALL.VENDOR_SITE_ID%TYPE;
L_CHANGED_BY        FND_USER.USER_NAME%TYPE;
L_BANK_ACCOUNT_NAME IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE;
L_IBAN              IBY_EXT_BANK_ACCOUNTS.IBAN%TYPE;
L_BANK_ACCOUNT_NUM  IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE;
L_ACCOUNT_CURRENCY  IBY_EXT_BANK_ACCOUNTS.CURRENCY_CODE%TYPE;
L_OP                IBY_PMT_INSTR_USES_ALL.ORDER_OF_PREFERENCE%TYPE;
L_ACCT_START_DATE   DATE;
L_BANK_NAME         HZ_PARTIES.PARTY_NAME%TYPE;
L_BRANCH_NAME       CE_BANK_BRANCHES_V.BANK_BRANCH_NAME%TYPE;
L_BRANCH_NUMBER     CE_BANK_BRANCHES_V.BRANCH_NUMBER%TYPE;
L_SWIFT_CODE        CE_BANK_BRANCHES_V.EFT_SWIFT_CODE%TYPE;
L_VAT_REGISTRATION_CODE AP_SUPPLIERS.VAT_REGISTRATION_NUM%TYPE;

BEGIN


begin

 SELECT          distinct
                  u.user_name,
                 accts.bank_account_name,
                 ACCTS.IBAN IBAN,
                 accts.bank_account_num,
                 accts.currency_code,
                 uses.order_of_preference,
                 AWAS_TO_DATE(ACCTS.ATTRIBUTE1),
                 bank.party_name bank_name,
                 branch.bank_branch_name,
                 branch.branch_number,
                 BRANCH.EFT_SWIFT_CODE,
                 PV.VENDOR_NAME,
                 PV.SEGMENT1,
                 PV.VENDOR_TYPE_LOOKUP_CODE,
                 pv.vendor_id,
                 pv.vat_registration_num
INTO L_CHANGED_BY,
     L_BANK_ACCOUNT_NAME,
     L_IBAN,
     L_BANK_ACCOUNT_NUM,
      L_ACCOUNT_CURRENCY,     
      L_OP,
      L_ACCT_START_DATE,
      L_BANK_NAME,
      L_BRANCH_NAME,
      L_BRANCH_NUMBER,
      L_SWIFT_CODE,
      L_VENDOR_NAME,
L_VENDOR_NUMBER,
L_VENDOR_TYPE ,
L_VENDOR_ID,
L_VAT_REGISTRATION_CODE
FROM     FND_USER U,
                 APPS.IBY_PMT_INSTR_USES_ALL USES,
                 apps.IBY_EXTERNAL_PAYEES_ALL payee,
                 apps.IBY_EXT_BANK_ACCOUNTS accts,
                 apps.HZ_PARTIES bank,
                 apps.HZ_ORGANIZATION_PROFILES bankProfile,
                 APPS.CE_BANK_BRANCHES_V BRANCH,
                 APPS.AP_SUPPLIERS PV,
                 APPS.AP_SUPPLIER_SITES_ALL SITES                 
WHERE uses.instrument_type = 'BANKACCOUNT'
AND PAYEE.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
and u.user_id = accts.created_by
AND PAYEE.PAYEE_PARTY_ID = PV.PARTY_ID
AND PAYEE.PAYMENT_FUNCTION = 'PAYABLES_DISB'                 
AND USES.INSTRUMENT_ID = ACCTS.EXT_BANK_ACCOUNT_ID
and sysdate between TRUNC(BANKPROFILE.EFFECTIVE_START_DATE(+))  and NVL(TRUNC(BANKPROFILE.EFFECTIVE_END_DATE(+)),sysdate + 1)
--AND SYSDATE BETWEEN NVL (uses.start_date, SYSDATE) AND NVL (USES.END_DATE, SYSDATE)                                 
AND accts.bank_id = bank.party_id(+)
AND ACCTS.BANK_ID = BANKPROFILE.PARTY_ID(+)
AND ACCTS.BRANCH_ID = BRANCH.BRANCH_PARTY_ID(+)  
AND PV.VENDOR_ID = SITES.VENDOR_ID
AND ACCTS.EXT_BANK_ACCOUNT_ID = TO_NUMBER(ITEMKEY);

exception when others then

SELECT          distinct
                  u.user_name,
                 accts.bank_account_name,
                 ACCTS.IBAN IBAN,
                 accts.bank_account_num,
                 accts.currency_code,
                 USES.ORDER_OF_PREFERENCE,
                 AWAS_TO_DATE(ACCTS.ATTRIBUTE1),
                 bank.party_name bank_name,
                 branch.bank_branch_name,
                 branch.branch_number,
                 BRANCH.EFT_SWIFT_CODE,
                 PV.VENDOR_NAME,
                 PV.SEGMENT1,
                 PV.VENDOR_TYPE_LOOKUP_CODE,
                 pv.vendor_id,
                 pv.vat_registration_num
INTO L_CHANGED_BY,
     L_BANK_ACCOUNT_NAME,
     L_IBAN,
     L_BANK_ACCOUNT_NUM,
      L_ACCOUNT_CURRENCY,     
      L_OP,
      L_ACCT_START_DATE,
      L_BANK_NAME,
      L_BRANCH_NAME,
      L_BRANCH_NUMBER,
      L_SWIFT_CODE,
      L_VENDOR_NAME,
L_VENDOR_NUMBER,
L_VENDOR_TYPE ,
L_VENDOR_ID,
L_VAT_REGISTRATION_CODE
FROM     FND_USER U,
                 APPS.IBY_PMT_INSTR_USES_ALL USES,
                 apps.IBY_EXTERNAL_PAYEES_ALL payee,
                 apps.IBY_EXT_BANK_ACCOUNTS accts,
                 apps.HZ_PARTIES bank,
                 apps.HZ_ORGANIZATION_PROFILES bankProfile,
                 APPS.CE_BANK_BRANCHES_V BRANCH,
                 APPS.AP_SUPPLIERS PV,
                 APPS.AP_SUPPLIER_SITES_ALL SITES                 
WHERE uses.instrument_type = 'BANKACCOUNT'
AND PAYEE.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
and u.user_id = accts.created_by
AND PAYEE.PAYEE_PARTY_ID = PV.PARTY_ID
AND PAYEE.PAYMENT_FUNCTION = 'PAYABLES_DISB'                 
AND USES.INSTRUMENT_ID = ACCTS.EXT_BANK_ACCOUNT_ID
and sysdate between TRUNC(BANKPROFILE.EFFECTIVE_START_DATE(+))  and NVL(TRUNC(BANKPROFILE.EFFECTIVE_END_DATE(+)),sysdate + 1)
AND SYSDATE BETWEEN NVL (uses.start_date, SYSDATE) AND NVL (USES.END_DATE, SYSDATE)                                 
AND accts.bank_id = bank.party_id(+)
AND ACCTS.BANK_ID = BANKPROFILE.PARTY_ID(+)
AND ACCTS.BRANCH_ID = BRANCH.BRANCH_PARTY_ID(+)  
AND PV.VENDOR_ID = SITES.VENDOR_ID
AND ACCTS.EXT_BANK_ACCOUNT_ID = TO_NUMBER(ITEMKEY);

end;

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'CHANGED_BY',L_CHANGED_BY);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_ACCOUNT_NAME',L_BANK_ACCOUNT_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'IBAN',L_IBAN);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_ACCOUNT_NUM',L_BANK_ACCOUNT_NUM);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_ACCOUNT_CURRENCY',L_ACCOUNT_CURRENCY);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'ORDER_OF_PREF',L_OP);
WF_ENGINE.SETITEMATTRDATE(ITEMTYPE,ITEMKEY,'ACCOUNT_START_DATE',L_ACCT_START_DATE);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_NAME',L_BANK_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_BRANCH_NAME',L_BRANCH_NAME);

if l_swift_code is null then
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BRANCH_NUMBER',L_BRANCH_NUMBER);
else
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BRANCH_NUMBER',null);
end if;

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'EFT_SWIFT_CODE',L_SWIFT_CODE);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_NAME',L_VENDOR_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_NUMBER',L_VENDOR_NUMBER);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_TYPE',L_VENDOR_TYPE);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VENDOR_ID',L_VENDOR_ID);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID',to_number(ITEMKEY));
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VAT_REGISTRATION_CODE',L_VAT_REGISTRATION_CODE);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_ACC_DETAILS', avalue =>'PLSQL: XX_AP_SUPPLIER_WF.GET_INTERMED_DETAILS /'||to_number(ITEMKEY));
    

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','');




END SET_ACCOUNT_ATTRIBUTES;

PROCEDURE noti_handler_new_site(itemtype IN VARCHAR2,
                        ITEMKEY IN VARCHAR2,
                        actid   IN NUMBER,
                        FUNCMODE IN VARCHAR2,
                        RESULTOUT  OUT NOCOPY VARCHAR2 )
is  
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
L_LOGIN_ID      NUMBER(15);
v_approver_comment      VARCHAR2(400);
l_approver_name varchar2(240);

BEGIN
      --get the Notification id
      l_nid := WF_ENGINE.context_nid;
    
    --get the result code
     Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid
     And na.Name = 'RESULT';

     v_approver_comment := wf_notification.getattrtext(l_nid,'APPROVER_COMMENT');

      IF l_activity_result_code = 'REJECTED' AND  v_approver_comment IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
  
     --get current approver
     L_APPROVER_NAME           := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'SITE_APPROVER');

    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
    IF l_forward_to_person_id is not NULL then
               l_orig_system := 'PER';
               l_orig_sys_id := l_forward_to_person_id;
    ELSE
               l_orig_system := 'FND_USR';
               l_orig_sys_id := l_forward_to_user_id;
    END IF;
                WF_DIRECTORY.GetRoleName(l_orig_system,
                                l_orig_sys_id,
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,
                                l_orig_sys_id,
                                l_name,
                                l_display_name);

                WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'SITE_APPROVER',
                        l_role);
       
       INSERT_APPROVAL_HISTORY(ITEMTYPE,ITEMKEY,L_APPROVER_NAME,'DELEGATED','Delegated to:'||l_role);
       

       resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;

       return;
       End if;

	IF (funcmode = 'RESPOND') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'APPROVAL_RESULT',l_result);


            If (l_result='APPROVED') then

            l_result:='WFAPPROVED';
            End IF;

            l_user_id := FND_GLOBAL.USER_ID;

            
          select user_name
            into l_approver_name
            from fnd_user
            where user_id = l_user_id;

          
                        

--check Approver and get from notification if Sysadimn or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  L_APPROVER_NAME := WF_NOTIFICATION.RESPONDER(L_NID);

end if;

--Check Again and use the used signed in if still showing as Sysadmin or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  
   select USER_NAME
   into L_APPROVER_NAME
   from FND_USER 
   where user_id = FND_GLOBAL.USER_ID;

end if;                        
                        
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'SITE_APPROVER',
                        l_approver_name);              
                        
                        
    INSERT_APPROVAL_HISTORY(ITEMTYPE,ITEMKEY,L_APPROVER_NAME,L_RESULT,V_APPROVER_COMMENT);

            RESULTOUT := WF_ENGINE.ENG_COMPLETED || ':' || WF_ENGINE.ENG_NULL;
            
            return;

        End if;

	if (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'APPROVAL_RESULT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          select user_name
            into l_approver_name
            from fnd_user
            where user_id = l_user_id;

           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'SITE_APPROVER',
                        L_APPROVER_NAME);
          
          --check Approver and get from notification if Sysadimn or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  L_APPROVER_NAME := WF_NOTIFICATION.RESPONDER(L_NID);

end if;

--Check Again and use the used signed in if still showing as Sysadmin or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  
   select USER_NAME
   into L_APPROVER_NAME
   from FND_USER 
   where user_id = FND_GLOBAL.USER_ID;

end if;   
          
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'SITE_APPROVER',
                        L_APPROVER_NAME);
          
          
          
          INSERT_APPROVAL_HISTORY(ITEMTYPE,ITEMKEY,L_APPROVER_NAME,L_RESULT,V_APPROVER_COMMENT);

           RESULTOUT := WF_ENGINE.ENG_COMPLETED || ':' || WF_ENGINE.ENG_NULL;
           
            return;
        End if;

  -- Don't allow transfer

      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

return;
EXCEPTION

WHEN OTHERS
   then
        WF_CORE.CONTEXT('AWCUST',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
        RAISE;
                        
                        
                        
  end noti_handler_new_site;
  
PROCEDURE noti_handler_new_bank(itemtype IN VARCHAR2,
                        ITEMKEY IN VARCHAR2,
                        actid   IN NUMBER,
                        FUNCMODE IN VARCHAR2,
                        RESULTOUT  OUT NOCOPY VARCHAR2 )
is  
l_status	VARCHAR2(50);
l_response      VARCHAR2(50);
l_nid           number;
l_forward_to_person_id number;
l_result        varchar2(100);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_activity_result_code VARCHAR2(200);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_forward_to_user_id WF_ROLES.ORIG_SYSTEM_ID%TYPE;
l_esc_approver  AME_UTIL.approverRecord;
l_rec_role      VARCHAR2(50);
l_comments      VARCHAR2(240);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_user_id       NUMBER(15);
L_LOGIN_ID      NUMBER(15);
v_approver_comment      VARCHAR2(400);
L_APPROVER_NAME varchar2(240);
l_responder    varchar2(100);
l_check   varchar2(240);

BEGIN
      --get the Notification id
      L_NID := WF_ENGINE.CONTEXT_NID;
      l_responder := WF_NOTIFICATION.responder(L_nid);
      
      DBMS_OUTPUT.PUT_LINE('l_responder'||L_RESPONDER);
      
    --get the result code
     Select text_value
     Into l_activity_result_code
     From wf_notification_attributes na
     Where na.notification_id = wf_engine.context_nid
     And na.Name = 'RESULT';

     v_approver_comment := wf_notification.getattrtext(l_nid,'APPROVER_COMMENT');

      IF l_activity_result_code = 'REJECTED' AND  v_approver_comment IS NULL
      THEN
        RESULTout := 'ERROR: You must enter a reason if rejecting, in the Approver Comments field.';
        RETURN;
      END IF;
  
     --get current approver
     L_APPROVER_NAME           := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_NAME');

    
    -- If Notification Forwarded
    IF (funcmode ='FORWARD') then
            l_rec_role :=WF_ENGINE.context_text;
            l_status:='DELEGATED';

     

     BEGIN
            SELECT user_id,employee_id
            INTO   l_forward_to_user_id,l_forward_to_person_id
            FROM   FND_USER
            WHERE  USER_NAME=l_rec_role;
          EXCEPTION
          WHEN OTHERS THEN
          NULL;
     END;
     
                IF l_forward_to_person_id is not NULL then
                           l_orig_system := 'PER';
                           l_orig_sys_id := l_forward_to_person_id;
                ELSE
                           l_orig_system := 'FND_USR';
                           l_orig_sys_id := l_forward_to_user_id;
                END IF;
                            WF_DIRECTORY.GetRoleName(l_orig_system,
                                            l_orig_sys_id,
                                            l_role,
                                            l_role_display);
            
                            WF_DIRECTORY.GetUserName(l_orig_system,
                                            l_orig_sys_id,
                                            l_name,
                                            l_display_name);
            
                            WF_ENGINE.SetItemAttrText(itemtype,
                                    ITEMKEY,
                                    'APPROVER_NAME',
                                    l_role);
                   
                   INSERT_APPROVAL_HISTORY(ITEMTYPE,ITEMKEY,L_APPROVER_NAME,'DELEGATED','Delegated to:'||l_role);
                   
            
                   resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
            
                   return;
       End if;

  -- If Notificaiton responded to 
	IF (funcmode = 'RESPOND') then
  
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'APPROVAL_RESULT',l_result);

            l_user_id := FND_GLOBAL.USER_ID;

            
          select user_name
            into l_approver_name
            from fnd_user
            where user_id = l_user_id;
            
                        --check Approver and get from notification if Sysadimn or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  L_APPROVER_NAME := WF_NOTIFICATION.RESPONDER(L_NID);

end if;
  
--Check Again and use the used signed in if still showing as Sysadmin or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  
   select USER_NAME
   into L_APPROVER_NAME
   from FND_USER 
   where user_id = FND_GLOBAL.USER_ID;

end if;   
 
 if L_approver_name is null then
 
 select recipient_role
 into L_approver_name
 from wf_notifications
 where notification_id = l_nid;
 
 end if;

           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'APPROVER_NAME',
                        l_approver_name);
                        
           
            
            If (l_result='APPROVED') then

            l_result:='WFAPPROVED';
            
            
            begin
            
            UPDATE IBY_EXT_BANK_ACCOUNTS 
            set ATTRIBUTE15 = 'A'  -- Approved
            ,   START_DATE = to_date(attribute1,'DD-MM-YYYY')
            ,   attribute1 = NULL
            ,   ATTRIBUTE14 =  sysdate  -- approval date
            ,   ATTRIBUTE13 = L_APPROVER_NAME  -- approver name
            WHERE ext_bank_Account_ID = to_char(ITEMKEY);
  
            EXCEPTION when OTHERS then
            
            UPDATE IBY_EXT_BANK_ACCOUNTS 
            set ATTRIBUTE15 = 'A'  -- Approved
            ,   START_DATE = to_date(nvl(attribute1,sysdate),'DD-MON-YYYY')
            ,   attribute1 = NULL
            ,   ATTRIBUTE14 =  sysdate  -- approval date
            ,   ATTRIBUTE13 = L_APPROVER_NAME  -- approver name
            WHERE ext_bank_Account_ID = to_char(ITEMKEY);
            
            
            end;
            
            elsif (l_result='REJECTED') then
            
            UPDATE IBY_EXT_BANK_ACCOUNTS 
            SET ATTRIBUTE15 = 'R'  -- Approved
            ,   ATTRIBUTE14 =  sysdate  -- approval date
            ,   ATTRIBUTE13 = L_APPROVER_NAME  -- approver name
            WHERE ext_bank_Account_ID = to_char(ITEMKEY);
  
            
            update AP_SUPPLIER_SITES_ALL
            set HOLD_REASON  = replace(hold_reason,' Pending Bank Account Approval with '||L_APPROVER_NAME,'')
            where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = to_char(ITEMKEY));
                          
            select distinct replace(hold_reason,' ','')
            into l_check
            from ap_supplier_sites_all 
            where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = to_char(ITEMKEY));
                          
            if l_check is null then
            
            update AP_SUPPLIER_SITES_ALL
            set               HOLD_ALL_PAYMENTS_FLAG = 'N'
            where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = to_char(ITEMKEY));
            
            end if;
                          
            
            
            
            End IF;
            

 
            
            INSERT_APPROVAL_HISTORY(ITEMTYPE,ITEMKEY,L_APPROVER_NAME,L_RESULT,V_APPROVER_COMMENT);

            RESULTOUT := WF_ENGINE.ENG_COMPLETED || ':' || WF_ENGINE.ENG_NULL;
            
            return;

        End if;

	-- If notification reponded to and delegated
  if (funcmode = 'RESPOND' and l_response='DELEGATED') then
            l_result := wf_notification.GetAttrText(l_nid, 'RESULT');

            WF_ENGINE.SetItemAttrText(itemtype,itemkey,'APPROVAL_RESULT',l_result);

            If (l_result='APPROVED') then
            l_result:='WFAPPROVED';
            End IF;

          select user_name
            into l_approver_name
            from fnd_user
            where user_id = l_user_id;

          
                        
          --check Approver and get from notification if Sysadimn or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  L_APPROVER_NAME := WF_NOTIFICATION.RESPONDER(L_NID);

end if;

--Check Again and use the used signed in if still showing as Sysadmin or Guest
if L_APPROVER_NAME = 'SYSADMIN' or L_APPROVER_NAME = 'GUEST' then
  
   select USER_NAME
   into L_APPROVER_NAME
   from FND_USER 
   where user_id = FND_GLOBAL.USER_ID;

end if;   

 if L_approver_name is null then
 
 select recipient_role
 into L_approver_name
 from wf_notifications
 where notification_id = l_nid;
 
 end if;
           WF_ENGINE.SetItemAttrText(itemtype,
                        ITEMKEY,
                        'APPROVER_NAME',
                        L_APPROVER_NAME);
                        
          INSERT_APPROVAL_HISTORY(ITEMTYPE,ITEMKEY,L_APPROVER_NAME,L_RESULT,V_APPROVER_COMMENT);

           RESULTOUT := WF_ENGINE.ENG_COMPLETED || ':' || WF_ENGINE.ENG_NULL;
           
            return;
  End if;

  -- Don't allow transfer
      if ( funcmode = 'TRANSFER' ) then
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
      end if;

  
  return;
  
EXCEPTION

WHEN OTHERS
   then
        WF_CORE.CONTEXT('AWCUST',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
        RAISE;
                        
end noti_handler_new_bank;
  
PROCEDURE INSERT_APPROVAL_HISTORY(ITEMTYPE IN VARCHAR2,
                                ITEMKEY   IN  VARCHAR2,
                                P_APPROVER  IN VARCHAR2,
                                P_RESULT    IN VARCHAR2,
                                P_COMMENTS  IN VARCHAR2) 
          IS
                                

L_VENDOR_ID           NUMBER(15);
L_VENDOR_SITE_ID      NUMBER(15);
L_EXT_BANK_ACCOUNT_ID NUMBER(15);
L_VERSION_ID          number(15);


begin                                
 
L_VENDOR_ID           := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VENDOR_ID');
L_VENDOR_SITE_ID      := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VENDOR_SITE_ID');
L_EXT_BANK_ACCOUNT_ID := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID');
L_VERSION_ID          := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VERSION_ID');

 INSERT INTO XX_AP_SUPPLIER_APRVL (VENDOR_ID 
        , VENDOR_SITE_ID
        , EXT_BANK_ACCOUNT_ID 
        , APPROVER
        , RESPONSE_DATE
        , RESPONSE
        , COMMENTS
        , VERSION_ID
        ,APPROVAL_SEQ)
  VALUES (L_VENDOR_ID 
        , L_VENDOR_SITE_ID
        , L_EXT_BANK_ACCOUNT_ID 
        , P_APPROVER
        , SYSDATE
        , P_RESULT
        , P_COMMENTS
        , L_VERSION_ID
        , XX_AP_SUPPLIER_APRVL_S.NEXTVAL);
        
        --CLEAR COMMENTS        
        WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT',NULL);
        
        
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('AWCUST',ITEMTYPE, ITEMKEY, null, 'RUN');
        RAISE;

end insert_approval_history;

PROCEDURE attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	)
	IS
	   l_attachment_count   NUMBER                  := NULL;
	   l_file_name          VARCHAR2 (100)          := NULL;
	   l_file_id            fnd_lobs.file_id%TYPE   := NULL;
	   l_file_attached      VARCHAR2 (4000);
	   l_attrname           wf_engine.nametabtyp;
     L_ATTRVAL            WF_ENGINE.TEXTTABTYP;
     
     L_VENDOR_ID         AP_SUPPLIERS.VENDOR_ID%TYPE;


	   CURSOR c_file_table (p_vendor_id NUMBER)
	   IS
	      select fl.file_id, fl.file_name, entity_name, pk1_value, tl.user_name category
	        from fnd_attached_documents fad, fnd_documents fdt, fnd_lobs fl, fnd_document_categories_tl tl
	       WHERE  ENTITY_NAME = 'PO_VENDORS' 
         and fad.pk1_value = p_vendor_id
           and fad.document_id = fdt.document_id
	         AND fdt.media_id = fl.file_id
	         AND (FL.EXPIRATION_DATE IS NULL OR FL.EXPIRATION_DATE > SYSDATE)
	         and tl.category_id = fad.category_id
           ;

	   TYPE file_tbl IS TABLE OF c_file_table%ROWTYPE
	      INDEX BY BINARY_INTEGER;

	   l_file_tbl           file_tbl;
	   l_run_query          VARCHAR2 (2000);
	   

  BEGIN
	   IF (funcmode != wf_engine.eng_run)
	   THEN
	      --  Do nothing in cancel or timeout mode
	      resultout := wf_engine.eng_null;
	      RETURN;
	      END IF;


  l_vendor_id := apps.wf_engine.getitemattrnumber (itemtype,itemkey,'VENDOR_ID');
       

	      -- Get the attachments into the PL/SQL table
	      OPEN c_file_table (l_vendor_id);

	      FETCH c_file_table
	      BULK COLLECT INTO l_file_tbl;

	      CLOSE c_file_table;

	-------------------------------------------------------
	--Get the attachments
	--Assign to Document Attributes
	--------------------------------------------------------
	      IF l_file_tbl.COUNT > 0
	      THEN

          resultout := wf_engine.eng_completed || ':' ||  'T';

	         FOR idx IN l_file_tbl.FIRST .. l_file_tbl.COUNT
	         LOOP
	            IF idx < 10   -- We are allowing a maximum of 10 attachments for a notification
	            THEN

                 l_attrname (idx) := 'XX_APPROVAL_ATTACHMENT' || idx;


	               l_attrval (idx) := 'PLSQLBLOB:xx_ap_supplier_wf.Get_Attachments/' || TO_CHAR (l_file_tbl (idx).file_id);


	            END IF;
	         END LOOP;


                wf_engine.setitemattrtextarray (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => l_attrname,
                                  avalue     => l_attrval);
          
        ELSE
        --no attachment exists set status to error
        resultout := wf_engine.eng_completed || ':' ||  'F';
        
        WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','No Supplier Attachments found.');
        

	      END IF;


	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xx_ap_supplier_wf', 'attachment_exist');
	      RAISE;
	END ATTACHMENT_EXIST;

PROCEDURE bank_attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	)
	IS
	   l_attachment_count   NUMBER                  := NULL;
	   l_file_name          VARCHAR2 (100)          := NULL;
	   l_file_id            fnd_lobs.file_id%TYPE   := NULL;
	   l_file_attached      VARCHAR2 (4000);
	   l_attrname           wf_engine.nametabtyp;
     L_ATTRVAL            WF_ENGINE.TEXTTABTYP;
     l_changed_by         fnd_user.user_name%type;
     L_EXT_BANK_ACCOUNT_ID  number;
     
     L_VENDOR_ID         AP_SUPPLIERS.VENDOR_ID%TYPE;
     
     L_vendor_type       ap_suppliers.vendor_type_lookup_code%TYPE;


	   CURSOR c_file_table 
	   IS
	     select fl.file_id, fl.file_name, entity_name, pk1_value, tl.user_name category
	        FROM FND_ATTACHED_DOCUMENTS FAD, FND_DOCUMENTS FDT, FND_LOBS FL, FND_DOCUMENT_CATEGORIES_TL TL
	       WHERE  ENTITY_NAME = 'IBY_EXT_BANK_ACCOUNTS' 
           and fad.pk1_value = l_ext_bank_account_id
           and fad.document_id = fdt.document_id
	         AND fdt.media_id = fl.file_id
	         AND (FL.EXPIRATION_DATE IS NULL OR FL.EXPIRATION_DATE > SYSDATE)
	         and tl.category_id = fad.category_id;
           

	   TYPE file_tbl IS TABLE OF c_file_table%ROWTYPE
	      INDEX BY BINARY_INTEGER;

	   l_file_tbl           file_tbl;
	   l_run_query          VARCHAR2 (2000);
	  

  BEGIN
  
  L_EXT_BANK_ACCOUNT_ID := WF_ENGINE.GETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID');
  L_VENDOR_TYPE := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_TYPE');
  
  
	   IF (funcmode != wf_engine.eng_run)
	   THEN
	      --  Do nothing in cancel or timeout mode
	      resultout := wf_engine.eng_null;
	      RETURN;
	      END IF;


      
      if L_VENDOR_TYPE = 'VENDOR' then  -- Vendor should be changed to something else
      
        resultout := wf_engine.eng_completed || ':' ||  'F';
        
        WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','Please Change Vendor Type.');
        RETURN;
      
      ELSE

	      -- Get the attachments into the PL/SQL table
	      OPEN c_file_table;

	      FETCH c_file_table
	      BULK COLLECT INTO l_file_tbl;

	      CLOSE c_file_table;

	-------------------------------------------------------
	--Get the attachments
	--Assign to Document Attributes
	--------------------------------------------------------
	      IF l_file_tbl.COUNT > 0
	      THEN

        resultout := wf_engine.eng_completed || ':' ||  'T';

	         FOR idx IN l_file_tbl.FIRST .. l_file_tbl.COUNT
	         LOOP
	            IF idx < 10   -- We are allowing a maximum of 10 attachments for a notification
	            THEN

                 l_attrname (idx) := 'XX_APPROVAL_ATTACHMENT' || idx;


	               l_attrval (idx) := 'PLSQLBLOB:xx_ap_supplier_wf.Get_Attachments/' || TO_CHAR (l_file_tbl (idx).file_id);


	            END IF;
	         END LOOP;


           wf_engine.setitemattrtextarray (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => l_attrname,
                                  avalue     => l_attrval);
                                  
          L_CHANGED_BY           := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_NAME');
                                  
           update iby_ext_bank_accounts
           set attribute13 = L_CHANGED_BY
           where ext_bank_account_id = L_EXT_BANK_ACCOUNT_ID;                       

        ELSE
        --no attachment exists set status to error
        resultout := wf_engine.eng_completed || ':' ||  'F';
        
        WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_COMMENT','No Bank Account Evidence Attached');
               
         L_CHANGED_BY           := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'CHANGED_BY');
         
        update iby_ext_bank_accounts
        set attribute13 = L_CHANGED_BY
        where ext_bank_account_id = L_EXT_BANK_ACCOUNT_ID
        ;
        
	      END IF;

        end IF;
	   
     
	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xx_ap_supplier_wf', 'bank_attachment_exist');
	      RAISE;
	end bank_attachment_exist;


PROCEDURE get_attachments (document_id in varchar2, display_type in varchar2, document IN OUT BLOB, document_type IN OUT VARCHAR2)
	IS
	   l_attachment          BLOB;
	   l_amount              NUMBER;
	   l_file_name           VARCHAR2 (240)                    := NULL;
	   l_file_content_type   fnd_lobs.file_content_type%TYPE   := NULL;
	BEGIN
	   l_file_content_type := NULL;

	   SELECT fl.file_data, fl.file_name, fl.file_content_type
	     INTO l_attachment, l_file_name, l_file_content_type
	     FROM fnd_lobs fl
	    WHERE fl.file_id = TO_NUMBER (document_id);

	-------------------------------------------
	--Now copy the content to document
	------------------------------------------
	   l_amount := DBMS_LOB.getlength (l_attachment);
	   DBMS_LOB.COPY (document,
	                  l_attachment,
	                  l_amount,
	                  1,
	                  1
	                 );
	---------------------------------------------------------
	-- Set the MIME type as a part of the document_type.
	---------------------------------------------------------
	   document_type := l_file_content_type || '; name=' || l_file_name;
	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xx_ap_supplier_wf_pkg',
	                       'Get_Attachments',
	                       document_id,
	                       display_type
	                      );
	END GET_ATTACHMENTS;
  
 PROCEDURE name_change_init
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as
          
          
     bank_event_document CLOB;
     event wf_event_t;
     xmldoc xmldom.domdocument;
     parser xmlparser.parser;
     
     v_bank_account_id  number;
     l_bank_account_name varchar2(100);
     l_old_bank_account_name varchar2(100);
     l_bank_account_num  iby_ext_bank_accounts.bank_account_num%TYPE;
     L_updated_by fnd_user.user_name%type;
     
          
    begin
    
    if ( funcmode = 'RUN' ) then

          event                 := wf_engine.getitemattrevent ( itemtype => itemtype, itemkey => itemkey, name => 'XXEVENTMSG' ) ;
          bank_event_document   := event.geteventdata ( ) ;

          v_bank_account_id := irc_xml_util.valueof ( bank_event_document, '/iby_ext_bank_accounts/ext_bank_account_id' ) ;
          wf_engine.setitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'EXT_BANK_ACCOUNT_ID', avalue => v_bank_account_id) ;
          
          dbms_output.put_line('v_bank_account_id'||v_bank_account_id);     
    
          l_bank_account_name := irc_xml_util.valueof ( bank_event_document, '/iby_ext_bank_accounts/new_bank_account_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BANK_ACCOUNT_NAME', avalue => l_bank_account_name) ;
          dbms_output.put_line('l_bank_account_name'||l_bank_account_name);     
          
          l_old_bank_account_name := irc_xml_util.valueof ( bank_event_document, '/iby_ext_bank_accounts/old_bank_account_name' ) ;
          wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'OLD_BANK_ACCOUNT_NAME', avalue => l_old_bank_account_name) ;
          dbms_output.put_line('l_old_bank_account_name'||l_old_bank_account_name);     
    
     update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'Y',
          HOLD_REASON            = hold_reason||' Awaiting Bank Account Name Change Approval'
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = v_BANK_ACCOUNT_ID);
                    
                    dbms_output.put_line('v_bank_account_id'||v_bank_account_id);     
                    
        select bank_account_num, u.user_name
        into l_bank_account_num,
        l_updated_by
        from IBY_EXT_BANK_ACCOUNTS    a,
        fnd_user u
        where a.ext_bank_account_id = v_bank_account_id
        and a.last_updated_by = u.user_id;
        
        wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'BANK_ACCOUNT_NUM', avalue => l_bank_account_num) ;
        wf_engine.setitemattrtext ( itemtype => itemtype, itemkey => itemkey, aname => 'CHANGED_BY', avalue => l_updated_by) ;
                          
                          
    
    end if;
    
end name_change_init;

PROCEDURE intermediary_init
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as

L_BANK_ACCOUNT_ID     iby_intermediary_accts.bank_acct_id%type;
L_INT_CREATION_DATE   date;
L_BA_CREATION_DATE    date;
L_CREATED_BY          fnd_user.user_name%type;
L_ACCOUNT_APPROVER  VARCHAR2(50);

L_VENDOR_NAME       AP_SUPPLIERS.VENDOR_NAME%TYPE;
L_VENDOR_NUMBER     AP_SUPPLIERS.SEGMENT1%TYPE;
L_VENDOR_TYPE       AP_SUPPLIERS.VENDOR_TYPE_LOOKUP_CODE%TYPE;
L_VENDOR_ID         AP_SUPPLIERS.VENDOR_ID%TYPE;
L_VENDOR_SITE_CODE  AP_SUPPLIER_SITES_ALL.VENDOR_SITE_CODE%TYPE;
L_VENDOR_SITE_ID    AP_SUPPLIER_SITES_ALL.VENDOR_SITE_ID%TYPE;
L_CHANGED_BY        FND_USER.USER_NAME%TYPE;
L_BANK_ACCOUNT_NAME IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE;
L_IBAN              IBY_EXT_BANK_ACCOUNTS.IBAN%TYPE;
L_BANK_ACCOUNT_NUM  IBY_EXT_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE;
L_ACCOUNT_CURRENCY  IBY_EXT_BANK_ACCOUNTS.CURRENCY_CODE%TYPE;
L_OP                IBY_PMT_INSTR_USES_ALL.ORDER_OF_PREFERENCE%TYPE;
L_ACCT_START_DATE   DATE;
L_BANK_NAME         HZ_PARTIES.PARTY_NAME%TYPE;
L_BRANCH_NAME       CE_BANK_BRANCHES_V.BANK_BRANCH_NAME%TYPE;
L_BRANCH_NUMBER     CE_BANK_BRANCHES_V.BRANCH_NUMBER%TYPE;
L_SWIFT_CODE        CE_BANK_BRANCHES_V.EFT_SWIFT_CODE%TYPE;
L_VAT_REGISTRATION_CODE AP_SUPPLIERS.VAT_REGISTRATION_NUM%TYPE;

    bank_event_document CLOB;
     event wf_event_t;
     xmldoc xmldom.domdocument;
     parser xmlparser.parser;
     
V_INT_ACCOUNT_ID    number;
v_INT_COUNTRY_OLD varchar2(50);
v_INT_COUNTRY varchar2(50);
v_INT_BANK_NAME_OLD varchar2(50);
v_INT_BANK_NAME varchar2(50);
v_INT_CITY_OLD varchar2(50);
v_INT_CITY varchar2(50);
v_INT_BANK_CODE_OLD varchar2(50);
v_INT_BANK_CODE varchar2(50);
v_INT_BRANCH_NUM_OLD varchar2(50);
v_INT_BRANCH_NUM varchar2(50);
v_INT_BIC_OLD varchar2(50);
v_INT_BIC varchar2(50);
v_INT_ACCOUNT_NUM_OLD varchar2(50);
v_INT_ACCOUNT_NUM varchar2(50);
v_INT_IBAN_OLD varchar2(50);
v_INT_IBAN varchar2(50);    
V_INT_COMMENTS_OLD varchar2(250);    
v_INT_COMMENTS varchar2(250);

change_check number;

l_attrname           wf_engine.nametabtyp;
     L_ATTRVAL            WF_ENGINE.TEXTTABTYP;

	   CURSOR c_file_table 
	   IS
	     select fl.file_id, fl.file_name, entity_name, pk1_value, tl.user_name category
	        FROM FND_ATTACHED_DOCUMENTS FAD, FND_DOCUMENTS FDT, FND_LOBS FL, FND_DOCUMENT_CATEGORIES_TL TL
	       WHERE  ENTITY_NAME = 'IBY_EXT_BANK_ACCOUNTS' 
           and fad.pk1_value = l_bank_account_id
           and fad.document_id = fdt.document_id
	         AND fdt.media_id = fl.file_id
	         AND (FL.EXPIRATION_DATE IS NULL OR FL.EXPIRATION_DATE > SYSDATE)
	         and tl.category_id = fad.category_id;
           

	   TYPE file_tbl IS TABLE OF c_file_table%ROWTYPE
	      INDEX BY BINARY_INTEGER;

	   l_file_tbl           file_tbl;
	   l_run_query          VARCHAR2 (2000);

begin

change_check := 0;

begin 

select a.bank_acct_id,
       a.last_update_date,
       b.creation_date,
       u.user_name
into  L_BANK_ACCOUNT_ID,
      L_INT_CREATION_DATE,
      L_BA_CREATION_DATE,
      L_CREATED_BY
from IBY_INTERMEDIARY_ACCTS a,
IBY_EXT_BANK_ACCOUNTS b,
      FND_USER U
where (a.INTERMEDIARY_ACCT_ID = substr(itemkey,5,instr(itemkey,':',5)-5) or a.INTERMEDIARY_ACCT_ID = substr(itemkey,5))
and a.last_updated_by = u.user_id
and b.ext_bank_account_id = a.bank_acct_id;

exception when others then

L_INT_CREATION_DATE := sysdate;
L_BA_CREATION_DATE := sysdate;


end;

DBMS_OUTPUT.PUT_LINE('L_CREATED_BY='||L_CREATED_BY);
dbms_output.put_line('L_BANK_ACCOUNT_ID='||L_BANK_ACCOUNT_ID);

if l_INT_CREATION_DATE > L_BA_CREATION_DATE + ((1/(24*60))*15)  -- 5 minutes
then
-- created over 5 minutes later, requires separate approval
resultout := wf_engine.eng_completed || ':' ||  'F';

-- Set approver

SELECT * 
INTO L_ACCOUNT_APPROVER
from (                           
SELECT user_name 
FROM WF_LOCAL_USER_ROLES 
WHERE ROLE_NAME = 'FND_RESP|AWCUST|AWAS_EXTERNAL_BANK_APPROVER|STANDARD'
AND USER_END_DATE IS NULL
AND ROLE_END_DATE IS NULL
and user_name not in (select flv.ATTRIBUTE1
from  iby_ext_bank_accounts b, 
IBY_PMT_INSTR_USES_ALL u,
iby_external_payees_all ep,
ap_suppliers pov,
FND_LOOKUP_VALUES flv
where U.INSTRUMENT_ID = B.EXT_BANK_ACCOUNT_ID
and U.EXT_PMT_PARTY_ID = ep.ext_payee_id
and ep.payee_party_id = pov.party_id
and flv.LOOKUP_TYPE = 'VENDOR TYPE'
AND flv.LANGUAGE = 'US'
and flv.lookup_code = pov.vendor_type_lookup_code
and b.ext_bank_Account_ID = l_bank_account_id)
AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
ORDER BY DBMS_RANDOM.VALUE)
where rownum = 1;

dbms_output.put_line('L_ACCOUNT_APPROVER='||L_ACCOUNT_APPROVER);

WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'APPROVER_NAME',L_ACCOUNT_APPROVER);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'CHANGED_BY',L_CREATED_BY);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID',L_BANK_ACCOUNT_ID);


SELECT          distinct
                  u.user_name,
                 accts.bank_account_name,
                 ACCTS.IBAN IBAN,
                 accts.bank_account_num,
                 accts.currency_code,
                 uses.order_of_preference,
                 accts.attribute1,
                 bank.party_name bank_name,
                 branch.bank_branch_name,
                 branch.branch_number,
                 BRANCH.EFT_SWIFT_CODE,
                 PV.VENDOR_NAME,
                 PV.SEGMENT1,
                 PV.VENDOR_TYPE_LOOKUP_CODE,
                 pv.vendor_id,
                 pv.vat_registration_num
INTO L_CHANGED_BY,
     L_BANK_ACCOUNT_NAME,
     L_IBAN,
     L_BANK_ACCOUNT_NUM,
      L_ACCOUNT_CURRENCY,     
      L_OP,
      L_ACCT_START_DATE,
      L_BANK_NAME,
      L_BRANCH_NAME,
      L_BRANCH_NUMBER,
      L_SWIFT_CODE,
      L_VENDOR_NAME,
L_VENDOR_NUMBER,
L_VENDOR_TYPE ,
L_VENDOR_ID,
L_VAT_REGISTRATION_CODE
FROM     FND_USER U,
                 APPS.IBY_PMT_INSTR_USES_ALL USES,
                 apps.IBY_EXTERNAL_PAYEES_ALL payee,
                 apps.IBY_EXT_BANK_ACCOUNTS accts,
                 apps.HZ_PARTIES bank,
                 apps.HZ_ORGANIZATION_PROFILES bankProfile,
                 APPS.CE_BANK_BRANCHES_V BRANCH,
                 APPS.AP_SUPPLIERS PV,
                 APPS.AP_SUPPLIER_SITES_ALL SITES                 
WHERE uses.instrument_type = 'BANKACCOUNT'
AND PAYEE.EXT_PAYEE_ID = USES.EXT_PMT_PARTY_ID
and u.user_id = accts.created_by
AND PAYEE.PAYEE_PARTY_ID = PV.PARTY_ID
AND PAYEE.PAYMENT_FUNCTION = 'PAYABLES_DISB'                 
AND USES.INSTRUMENT_ID = ACCTS.EXT_BANK_ACCOUNT_ID
AND SYSDATE BETWEEN TRUNC(BANKPROFILE.EFFECTIVE_START_DATE(+))  AND NVL(TRUNC(BANKPROFILE.EFFECTIVE_END_DATE(+)),SYSDATE + 1)
--AND SYSDATE BETWEEN NVL (uses.start_date, SYSDATE) AND NVL (USES.END_DATE, SYSDATE)                                 
AND accts.bank_id = bank.party_id(+)
AND ACCTS.BANK_ID = BANKPROFILE.PARTY_ID(+)
AND ACCTS.BRANCH_ID = BRANCH.BRANCH_PARTY_ID(+)  
AND PV.VENDOR_ID = SITES.VENDOR_ID
and ACCTS.EXT_BANK_ACCOUNT_ID = L_BANK_ACCOUNT_ID
and rownum = 1;



--WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'CHANGED_BY',L_CHANGED_BY);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_ACCOUNT_NAME',L_BANK_ACCOUNT_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'IBAN',L_IBAN);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_ACCOUNT_NUM',L_BANK_ACCOUNT_NUM);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_ACCOUNT_CURRENCY',L_ACCOUNT_CURRENCY);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'ORDER_OF_PREF',L_OP);
WF_ENGINE.SETITEMATTRDATE(ITEMTYPE,ITEMKEY,'ACCOUNT_START_DATE',L_ACCT_START_DATE);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_NAME',L_BANK_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BANK_BRANCH_NAME',L_BRANCH_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'BRANCH_NUMBER',L_BRANCH_NUMBER);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'EFT_SWIFT_CODE',L_SWIFT_CODE);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_NAME',L_VENDOR_NAME);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_NUMBER',L_VENDOR_NUMBER);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VENDOR_TYPE',L_VENDOR_TYPE);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'VENDOR_ID',L_VENDOR_ID);
WF_ENGINE.SETITEMATTRNUMBER(ITEMTYPE,ITEMKEY,'EXT_BANK_ACCOUNT_ID',L_BANK_ACCOUNT_ID);
WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE,ITEMKEY,'VAT_REGISTRATION_CODE',L_VAT_REGISTRATION_CODE);



-- Get Event Attributes

event  := wf_engine.getitemattrevent ( itemtype => itemtype, itemkey => itemkey, name => 'XXEVENTMSG' ) ;
bank_event_document   := event.geteventdata ( ) ;

v_INT_ACCOUNT_ID := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/intermediary_account_id' ) ;
wf_engine.setitemattrnumber ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_ACCOUNT_ID', avalue => v_INT_ACCOUNT_ID) ;

v_INT_COUNTRY_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_country_code' ) ;
      
v_INT_COUNTRY := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_country_code' ) ;

v_INT_BANK_NAME_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_bank_name' ) ;      

v_INT_BANK_NAME := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_bank_name' ) ;      
      
v_INT_CITY_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_city' ) ;	  
      
v_INT_CITY := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_city' ) ;

v_INT_BANK_CODE_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_bank_code' ) ;

v_INT_BANK_CODE := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_bank_code' ) ;      
      
v_INT_BRANCH_NUM_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_branch_number' ) ;

v_INT_BRANCH_NUM := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_branch_number' ) ;      

v_INT_BIC_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_bic' ) ;      
      
v_INT_BIC := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_bic' ) ;
       
v_INT_ACCOUNT_NUM_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_account_number' ) ;

v_INT_ACCOUNT_NUM := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_account_number' ) ;          

v_INT_IBAN_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_iban' ) ;      

v_INT_IBAN := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_iban' ) ;
      
v_INT_COMMENTS_OLD := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/old_comments' ) ;
      
v_INT_COMMENTS := irc_xml_util.valueof ( bank_event_document, 'iby_intermediary_accts/new_comments' ) ;

wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_COUNTRY_OLD', avalue =>v_INT_COUNTRY_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_COUNTRY', avalue =>v_INT_COUNTRY);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BANK_NAME_OLD', avalue =>v_INT_BANK_NAME_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BANK_NAME', avalue =>v_INT_BANK_NAME);      
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_CITY_OLD', avalue =>v_INT_CITY_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_CITY', avalue =>v_INT_CITY);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BANK_CODE_OLD', avalue =>v_INT_BANK_CODE_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BANK_CODE', avalue =>v_INT_BANK_CODE);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BRANCH_NUM_OLD', avalue =>v_INT_BRANCH_NUM_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BRANCH_NUM', avalue =>v_INT_BRANCH_NUM);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BIC_OLD', avalue =>v_INT_BIC_OLD);     
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_BIC', avalue =>v_INT_BIC);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_ACCOUNT_NUM_OLD', avalue =>v_INT_ACCOUNT_NUM_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_ACCOUNT_NUM', avalue =>v_INT_ACCOUNT_NUM);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_IBAN_OLD', avalue =>v_INT_IBAN_OLD);
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_IBAN', avalue =>v_INT_IBAN);     
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_COMMENTS_OLD', avalue =>v_INT_COMMENTS_OLD);     
wf_engine.setitemattrTEXT ( itemtype => itemtype, itemkey => itemkey, aname => 'INT_COMMENTS', avalue =>v_INT_COMMENTS);


--if nvl(v_INT_COUNTRY_OLD,'x') <> nvl(v_INT_COUNTRY,'x') then change_check := change_check +1; end if;
if v_INT_BANK_NAME_OLD <> v_INT_BANK_NAME then change_check := change_check +1; end if;
if v_INT_CITY_OLD <> v_INT_CITY then change_check := change_check +1; end if;
if v_INT_BANK_CODE_OLD <> v_INT_BANK_CODE then change_check := change_check +1; end if;
if v_INT_BRANCH_NUM_OLD <> v_INT_BRANCH_NUM then change_check := change_check +1; end if;
if v_INT_BIC_OLD <> v_INT_BIC then change_check := change_check +1; end if;
if v_INT_ACCOUNT_NUM_OLD <> v_INT_ACCOUNT_NUM then change_check := change_check +1; end if;
if v_INT_IBAN_OLD <> v_INT_IBAN then change_check := change_check +1; end if;
if v_INT_COMMENTS_OLD <> v_INT_COMMENTS then change_check := change_check +1; end if;

dbms_output.put_line('Change_check'||change_check);
if change_check = 0 then 
resultout := wf_engine.eng_completed || ':' ||  'T';
end if;

-- check if any details populated at all.
select length(v_INT_COUNTRY_OLD||
v_INT_COUNTRY||
v_INT_BANK_NAME_OLD||
v_INT_BANK_NAME||
v_INT_CITY_OLD||
v_INT_CITY||
v_INT_BANK_CODE_OLD||
v_INT_BANK_CODE||
v_INT_BRANCH_NUM_OLD||
v_INT_BRANCH_NUM||
v_INT_BIC_OLD||
v_INT_BIC||
v_INT_ACCOUNT_NUM_OLD||
v_INT_ACCOUNT_NUM||
v_INT_IBAN_OLD||
v_INT_IBAN||    
V_INT_COMMENTS_OLD||    
v_INT_COMMENTS)
into change_check
from dual;

dbms_output.put_line('Change_check'||change_check);

if change_check > 0 then 
resultout := wf_engine.eng_completed || ':' ||  'F';
end if;




 IF (funcmode != wf_engine.eng_run)
	   THEN
	      --  Do nothing in cancel or timeout mode
	      resultout := wf_engine.eng_null;
	      RETURN;
	      END IF;

      -- Get the attachments into the PL/SQL table
	      OPEN c_file_table;

	      FETCH c_file_table
	      BULK COLLECT INTO l_file_tbl;

	      CLOSE c_file_table;

	-------------------------------------------------------
	--Get the attachments
	--Assign to Document Attributes
	--------------------------------------------------------
	      IF l_file_tbl.COUNT > 0
	      THEN

          FOR idx IN l_file_tbl.FIRST .. l_file_tbl.COUNT
	         LOOP
	            IF idx < 10   -- We are allowing a maximum of 10 attachments for a notification
	            THEN

                 l_attrname (idx) := 'XX_APPROVAL_ATTACHMENT' || idx;


	               l_attrval (idx) := 'PLSQLBLOB:xx_ap_supplier_wf.Get_Attachments/' || TO_CHAR (l_file_tbl (idx).file_id);


	            END IF;
	         END LOOP;


                wf_engine.setitemattrtextarray (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => l_attrname,
                                  avalue     => l_attrval);
                                  
       
	      END IF;


	   
     
	

else
-- Created within 5 minutes
resultout := wf_engine.eng_completed || ':' ||  'T';
end if;

-- Place Supplier Site on Hold
if 
resultout = wf_engine.eng_completed || ':' ||  'F'

then
update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'Y',
          HOLD_REASON            = hold_reason||' '||'Awaiting change to Intermediay Account to be approved with '||L_ACCOUNT_APPROVER
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = L_BANK_ACCOUNT_ID);
                          
end if;

end intermediary_init;

PROCEDURE intermediary_approved
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as

L_EXT_BANK_ACCOUNT_ID number;

begin

L_EXT_BANK_ACCOUNT_ID := wf_engine.getitemattrnumber ( itemtype, itemkey,'EXT_BANK_ACCOUNT_ID');

update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'N',
          HOLD_REASON            = null
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = L_EXT_BANK_ACCOUNT_ID);

end intermediary_approved;

PROCEDURE intermediary_rejected
     (
          itemtype IN VARCHAR2,
          itemkey  IN VARCHAR2,
          actid    IN NUMBER,
          funcmode IN VARCHAR2,
          resultout OUT NOCOPY VARCHAR2 ) as

V_INT_ACCOUNT_ID    number;
v_INT_COUNTRY_OLD varchar2(50);
v_INT_BANK_NAME_OLD varchar2(50);
v_INT_CITY_OLD varchar2(50);
v_INT_BANK_CODE_OLD varchar2(50);
v_INT_BRANCH_NUM_OLD varchar2(50);
v_INT_BIC_OLD varchar2(50);
v_INT_ACCOUNT_NUM_OLD varchar2(50);
v_INT_IBAN_OLD varchar2(50);   
V_INT_COMMENTS_OLD varchar2(250);    
L_EXT_BANK_ACCOUNT_ID number;


begin

select  substr(itemkey,5,instr(itemkey,':',5)-5)
into v_int_account_id   
from dual;


v_INT_COUNTRY_OLD   := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_COUNTRY_OLD');
v_INT_BANK_NAME_OLD := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_BANK_NAME_OLD');    
v_INT_CITY_OLD      := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_CITY_OLD');
v_INT_BANK_CODE_OLD := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_BANK_CODE_OLD');
v_INT_BRANCH_NUM_OLD:= wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_BRANCH_NUM_OLD');
v_INT_BIC_OLD       := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_BIC_OLD');     
v_INT_ACCOUNT_NUM_OLD := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_ACCOUNT_NUM_OLD');
v_INT_IBAN_OLD      := wf_engine.getitemattrTEXT ( itemtype, itemkey, 'INT_IBAN_OLD');
v_INT_COMMENTS_OLD  := wf_engine.getitemattrTEXT ( itemtype, itemkey,'INT_COMMENTS_OLD');
L_EXT_BANK_ACCOUNT_ID := wf_engine.getitemattrnumber ( itemtype, itemkey,'EXT_BANK_ACCOUNT_ID');

update iby_intermediary_accts
set country_code = nvl(v_int_Country_old,''),
    bank_name = nvl(v_int_bank_name_old,''),
    city = nvl(v_int_city_old,''),
    bank_code = nvl(v_int_bank_code_old,''),
    branch_number = nvl(v_int_branch_num_old,''),
    bic = nvl(v_int_bic_old,''),
    account_number = nvl(v_int_account_num_old,''),
    iban = nvl(v_int_iban_old,''),
    comments = nvl(v_int_comments_old,'')
where intermediary_acct_id = v_int_account_id;
    
update AP_SUPPLIER_SITES_ALL
      set HOLD_ALL_PAYMENTS_FLAG = 'N',
          HOLD_REASON            = null
      where vendor_id in (
                          select sup.vendor_id
                          from IBY.IBY_EXT_BANK_ACCOUNTS ba,
                          IBY.IBY_ACCOUNT_OWNERS ao,
                          ap_suppliers sup
                          where AO.EXT_BANK_ACCOUNT_ID = BA.EXT_BANK_ACCOUNT_ID
                          and sup.party_id = AO.ACCOUNT_OWNER_PARTY_ID
                          and ba.EXT_BANK_ACCOUNT_ID = L_EXT_BANK_ACCOUNT_ID);

end intermediary_rejected;

PROCEDURE GET_INTERMED_DETAILS( p_ext_bank_account_id		IN NUMBER ,
                                display_type		IN VARCHAR2 DEFAULT 'text/html',
                                document		IN OUT	NOCOPY VARCHAR2,
                                document_type	IN OUT	NOCOPY VARCHAR2
) IS


  l_item_type    		wf_items.item_type%TYPE;
  l_item_key     		wf_items.item_key%TYPE;
  l_ext_bank_account_id 			iby_ext_bank_Accounts.ext_bank_account_id%TYPE;
  
  

  
  l_line			int_acc_detail_record;
  l_document	VARCHAR2(32000) := '';

  NL				VARCHAR2(1) := fnd_global.newline;
  i				NUMBER := 0;
  max_lines_dsp			NUMBER := 3;
  line_mesg			VARCHAR2(240);
  curr_len			NUMBER := 0;
  prior_len			NUMBER := 0;

 cursor lines_cur ( v_ext_bank_account_id number) is
   select
COUNTRY_CODE,   
BANK_NAME   , 
CITY        ,
BANK_CODE   ,
BRANCH_NUMBER,
BIC         ,
ACCOUNT_NUMBER,
IBAN           ,
COMMENTS      
from IBY_INTERMEDIARY_ACCTS
where BANK_ACCT_ID = v_ext_bank_account_id
and length(COUNTRY_CODE||   
BANK_NAME || 
CITY      ||
BANK_CODE ||
BRANCH_NUMBER||
BIC        ||
ACCOUNT_NUMBER||
IBAN          ||
COMMENTS      ) > 0
order by INTERMEDIARY_ACCT_ID;


BEGIN

  document_type :=   'text/html';

  l_ext_bank_account_id := p_ext_bank_account_id;
  max_lines_dsp := 2;

  IF (display_type = 'text/html') THEN

    	l_document := NL || NL || '<!-- INTERMEDIARY_DETAILS -->'|| NL || NL || '<P><B>';
    	l_document := l_document || 'Intermediary Bank Details';
    	l_document := l_document || '</B>';

      l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1> '|| NL;
    	l_document := l_document || '<TR>' || NL;
    	
      l_document := l_document || '<TH  id="COUNTRY_CODE">' ||'Country'|| '</TH>' || NL;
      l_document := l_document || '<TH  id="CITY">' || 'City' || '</TH>' || NL;
      l_document := l_document || '<TH  id="BANK_NAME">' || 'Bank Name' || '</TH>' || NL;
      l_document := l_document || '<TH  id="BANK_CODE">' || 'Bank Code'|| '</TH>' || NL;
      l_document := l_document || '<TH  id="BRANCH_NUMBER">' ||'Branch Number'|| '</TH>' || NL;
      l_document := l_document || '<TH  id="BIC">' ||'BIC' || '</TH>' || NL;
      l_document := l_document || '<TH  id="ACCOUNT_NUMBER">' ||'Account Number' || '</TH>' || NL;
      l_document := l_document || '<TH  id="IBAN">' ||'IBAN' || '</TH>' || NL;
      l_document := l_document || '<TH  id="COMMENTS">' ||'Comments' || '</TH>' || NL;
      l_document := l_document || '</TR>' || NL;

        curr_len  := LENGTHB(l_document);
        prior_len := curr_len;


    	OPEN lines_cur(l_ext_bank_account_id);

    	LOOP
  	  FETCH lines_cur INTO l_line;
      i := i + 1;
      		EXIT WHEN lines_cur%NOTFOUND;

                 --Exit the cursor if the current document length and 2 times the
                 -- length added in prior line exceeds 32000 char 

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                prior_len := curr_len;
      		l_document := l_document || '<TR>' || NL;
      		
      		l_document := l_document || '<TD nowrap headers="COUNTRY_CODE">'
				         || NVL(l_line.country_code, '&'||'nbsp') || '</TD>' || NL;

          l_document := l_document || '<TD nowrap align=left headers="CITY">'
					 || NVL(l_line.city,'&'||'nbsp') || '</TD>' || NL;

           l_document := l_document || '<TD nowrap align=left headers="BANK_NAME">'
					 || NVL(l_line.bank_name,'&'||'nbsp') || '</TD>' || NL;

      		l_document := l_document || '<TD nowrap headers="BANK_CODE">'
				         || NVL(l_line.bank_code, '&'||'nbsp') || '</TD>' || NL;

      		l_document := l_document || '<TD nowrap headers="BRANCH_NUMBER">'
					 || NVL(l_line.branch_number, '&'||'nbsp') || '</TD>' || NL;

      		l_document := l_document || '<TD nowrap headers="BIC">'
					 || NVL(l_line.bic, '&'||'nbsp') || '</TD>' || NL;

     		l_document := l_document || '<TD nowrap align=right headers="ACCOUNT_NUMBER">'
					 || NVL(l_line.account_number,'&'||'nbsp') || '</TD>' || NL;

		l_document := l_document || '<TD nowrap align=right headers="IBAN">'
					 || NVL(l_line.iban,'&'||'nbsp') || '</TD>' || NL;

		l_document := l_document || '<TD nowrap align=right headers="COMMENTS">'
					 || NVL(l_line.comments,'&'||'nbsp') || '</TD>' || NL;

		l_document := l_document || '</TR>' || NL;

                EXIT WHEN i = max_lines_dsp;

                curr_len  := LENGTHB(l_document);
    	END LOOP;
	l_document := l_document || '</TABLE></P>' || NL;

    	CLOSE lines_cur;


	END IF;

	document:= l_document;
  
  exception when others then
wf_core.context('xx_ap_supplier_wf', 'get_intermed_details', document);
raise;
  
END GET_INTERMED_DETAILS;

END XX_AP_SUPPLIER_WF;
/
