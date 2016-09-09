  CREATE OR REPLACE FORCE VIEW "APPS"."AWAS_AR_ADDRESSES_V" ("CUSTOMER_NAME", "LOCATION_ID", "CUSTOMER_NUMBER", "SITE_USE_ID", "LOCATION", "CONCAT_ADDRESS", "ADDRESS1", "ADDRESS2", "ADDRESS3", "ADDRESS4", "CITY", "STATE", "POSTAL_CODE", "COUNTRY", "REVENUE_ACC", "RECEIVABLE_ACC", "LATITUDE", "LONGITUDE", "CUSTOM_COORDINATE", "ADDRESS_WARNING") AS 
--------------------------------------------------------
--  DDL for View AWAS_AR_ADDRESSES_V
-- Created by Simon Joyce, Version 1, 2008
--------------------------------------------------------
  SELECT P.PARTY_NAME CUSTOMER_NAME, 
       L.LOCATION_ID,
       c.account_number customer_number,
       s.site_use_id,
       S.LOCATION, 
       NVL2(L.ADDRESS1,l.ADDRESS1||',',l.ADDRESS1)
       ||NVL2(L.ADDRESS2,L.ADDRESS2||',',l.ADDRESS2)
       ||NVL2(L.ADDRESS3,l.ADDRESS3||',',L.ADDRESS3)
       ||NVL2(L.ADDRESS4,l.ADDRESS4||',',l.ADDRESS4)
       ||NVL2(L.CITY,l.CITY||',',L.CITY)
       ||NVL2(L.STATE,L.STATE||',',L.STATE)
       ||NVL2(L.POSTAL_CODE,L.POSTAL_CODE||',',l.POSTAL_CODE)
       ||nvl2(l.country,l.country,l.country) concat_address,
       L.ADDRESS1,
       l.ADDRESS2,
       L.ADDRESS3,
       L.ADDRESS4,
       L.CITY,
       L.STATE,
       L.POSTAL_CODE,
       l.country,
       g.segment1||'.'||g.segment2||'.'||g.segment3||'.'||g.segment4||'.'||g.segment5||'.'||g.segment6||'.'||g.segment7 REVENUE_ACC,
       r.segment1||'.'||r.segment2||'.'||r.segment3||'.'||r.segment4||'.'||r.segment5||'.'||r.segment6||'.'||r.segment7 RECEIVABLE_ACC,
       a.attribute2 Latitude,
       a.attribute3 Longitude,
       a.attribute4 Custom_Coordinate, 
       a.attribute5 Address_warning
from hz_cust_site_uses_all s,
     hz_cust_acct_sites_all a,
     HZ_CUST_ACCOUNTS C,
     HZ_PARTIES P,
     gl_code_combinations g,
     gl_code_combinations r,
     HZ_LOCATIONS L,
     hz_party_sites ps
where s.org_id = 85
and a.org_id = 85
and s.site_use_code = 'BILL_TO'
and s.gl_id_rev = g.code_combination_id
and s.gl_id_rec = r.code_combination_id
and a.cust_acct_site_id = s.cust_acct_site_id
AND C.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
AND C.PARTY_ID = P.PARTY_ID
AND PS.LOCATION_ID = L.LOCATION_ID
AND PS.PARTY_SITE_ID = A.PARTY_SITE_ID
order by 3 desc
 ;
/