--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AR_GET_EMAIL
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AR_GET_EMAIL" (CUST_NUM varchar2,INVOICE_TYPE VARCHAR2) RETURN VARCHAR2 AS 

cursor c1 (p_type varchar2) is 
            select hcp.email_address email
            from hz_contact_points hcp,
                hz_cust_accounts hca
            where hca.party_id = hcp.owner_table_id (+)
            and hcp.owner_table_name = 'HZ_PARTIES'
            and hca.account_number = CUST_NUM
            and hcp.attribute1 = p_type
            and hcp.status = 'A'
            union 
            select hcp.email_address email
            from hz_contact_points hcp,
                hz_cust_accounts hca
            where hca.party_id = hcp.owner_table_id (+)
            and hcp.owner_table_name = 'HZ_PARTIES'
            and hca.account_number = CUST_NUM
            and hcp.attribute1 = 'BOTH'
            and hcp.status = 'A'
            ;
  
  R_EMAIL VARCHAR2 (2000);
  v_type varchar2 (60);
BEGIN

-- check for rental or maintenance

if invoice_type in ('Maintenance Invoice','Maint. Credit Memo') 
then v_type := 'MAINTENANCE';
else v_type := 'RENT';
end if;

for r1 in c1(v_type) loop
-- concatenate email addresses together
   r_email := r_email||r1.email||',';
   
   end loop;
-- remove trailing comma

   r_email := substr(r_email,1,length(r_email)-1);

  RETURN r_email;
  
END XX_AR_GET_EMAIL;
 

/
