CREATE OR REPLACE PACKAGE XX_AR_ADDRESS_GEOCODE_PKG
AS
        /*------------------------------------------------------------------
          | xx_ar_address_geocode_pkg WRITTEN AND DEVELOPED BY Simon Joyce   |
          | 29th Oct 2009. this package calls the XX_GEO_CODE function and   |
          | populates the AR Customer sites table with the data              |
          | Revised by Simon Joyce. V1. 23-Jul-13 for R12 compatibility      |
          ------------------------------------------------------------------*/

PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 ) ;


          PROCEDURE MAIN_country
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 ) ;
END XX_AR_ADDRESS_GEOCODE_PKG;

/


CREATE OR REPLACE PACKAGE BODY XX_AR_ADDRESS_GEOCODE_PKG AS

  PROCEDURE MAIN
     (    errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2
         )  AS

  -- This procedure will populate the flexfieLd attributes, 2,3 and 5 on the
   -- hz_cust_acct_sites_all table

   l_temp varchar2(1800);

   CURSOR C1 is SELECT A.CUST_ACCT_SITE_ID,
               NVL2(l.ADDRESS1,l.ADDRESS1||',',l.ADDRESS1)
       ||NVL2(L.ADDRESS2,L.ADDRESS2||',',L.ADDRESS2)
       ||NVL2(l.ADDRESS3,l.ADDRESS3||',',l.ADDRESS3)
       ||NVL2(l.ADDRESS4,l.ADDRESS4||',',l.ADDRESS4)
       ||NVL2(l.CITY,l.CITY||',',l.CITY)
       ||NVL2(l.STATE,l.STATE||',',l.STATE)
       ||NVL2(l.POSTAL_CODE,l.POSTAL_CODE||',',l.POSTAL_CODE)
       ||nvl2(l.country,l.country,l.country) concat_location
                  FROM hz_cust_acct_sites_all a,
                  hz_locations l,
                  hz_cust_site_uses_all c,
                  HZ_PARTY_SITES P,
                  HZ_CUST_ACCOUNTS r,
                  HZ_PARTIES z
             WHERE NVL(a.ATTRIBUTE4,'N') = 'N'
             and p.location_id = l.location_id
             and c.cust_acct_site_id = a.cust_acct_site_id
             and c.site_use_code = 'BILL_TO'
             AND A.ATTRIBUTE2 IS NULL
             and r.PARTY_ID = z.PARTY_ID
             and r.party_id = p.party_id
             and c.status = 'A'
             AND A.ORG_ID = 85
             and p.party_site_id = a.party_site_id;




  BEGIN

     fnd_FILE.put_line(FND_FILE.output, 'AWAS AR populate location geocodes program');
     fnd_FILE.put_line(FND_FILE.output, '');
     fnd_FILE.put_line(FND_FILE.output, 'Program Starting');

    FOR i IN C1
     LOOP

          select xx_geo_code(i.concat_location)
          into l_temp
          from dual;

          update hz_cust_acct_sites_all
          set attribute2 = substr(substr(l_temp,1                       ,instr(l_temp,'|',1,1)-1),1,150),
              attribute3 = substr(substr(l_temp,instr(l_temp,'|',1,1)+1 ,instr(l_temp,'|',1,2)-instr(l_temp,'|',1,1)-1),1,150),
              attribute5 = substr(substr(l_temp,instr(l_temp,'|',1,2)+1 ,instr(l_temp,'|',1,3)-instr(l_temp,'|',1,2)-1),1,150),
              attribute6 = substr(substr(l_temp,instr(l_temp,'|',1,3)+1 ,instr(l_temp,'|',1,4)-instr(l_temp,'|',1,3)-1),1,150),
              attribute7 = substr(substr(l_temp,instr(l_temp,'|',1,4)+1 ,instr(l_temp,'|',1,5)-instr(l_temp,'|',1,4)-1),1,150),
              attribute8 = substr(substr(l_temp,instr(l_temp,'|',1,5)+1 ,instr(l_temp,'|',1,6)-instr(l_temp,'|',1,5)-1),1,150),
              attribute9 = substr(substr(l_temp,instr(l_temp,'|',1,6)+1 ,instr(l_temp,'|',1,7)-instr(l_temp,'|',1,6)-1),1,150),
              attribute10 = substr(substr(l_temp,instr(l_temp,'|',1,7)+1 ,length(l_temp)),1,150)
          where cust_acct_site_id = i.cust_acct_site_id;

          fnd_FILE.put_line(FND_FILE.output,'cas_ID:'||I.CUST_ACCT_SITE_ID||' Warning: '||substr(l_temp,instr(l_temp,',',1,2)+1,length(l_temp)));

     END LOOP ;

      fnd_FILE.put_line(FND_FILE.output, '');
      fnd_FILE.put_line(FND_FILE.output, 'Program Complete');


  END MAIN;


  PROCEDURE MAIN_COUNTRY
     (    errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2
         )  AS

  -- This procedure will populate the flexfieLd attributes, 2,3 and 5 on the
   -- hz_cust_acct_sites_all table

   l_temp varchar2(300);

   CURSOR C1 is SELECT cust_acct_site_id,
               nvl2(country,country,country) concat_location
             FROM hz_cust_acct_sites_all a,
                  hz_locations l,
                  hz_party_sites p
             WHERE p.location_id = l.location_id
             and a.org_id = 85
             and p.party_site_id = a.party_site_id

             ;




  BEGIN

     fnd_FILE.put_line(FND_FILE.output, 'AWAS AR populate location geocodes program');
     fnd_FILE.put_line(FND_FILE.output, '');
     fnd_FILE.put_line(FND_FILE.output, 'Program Starting');


 delete xx_ar_country_geo;

    FOR i IN C1
     LOOP

          select xx_geo_code(i.concat_location)
          into l_temp
          from dual;

          insert into xx_ar_country_geo values (i.cust_acct_site_id,
                                      substr(l_temp,1,instr(l_temp,',',1,1)-1)*1,
                                      substr(l_temp,instr(l_temp,',',1,1)+1 ,instr(l_temp,',',1,2)-instr(l_temp,',',1,1)-1)*1);
/*
          update hz_cust_acct_sites_all
          set attribute2 = substr(l_temp,1                       ,instr(l_temp,',',1,1)-1),
              attribute3 = substr(l_temp,instr(l_temp,',',1,1)+1 ,instr(l_temp,',',1,2)-instr(l_temp,',',1,1)-1),
              attribute5 = substr(l_temp,instr(l_temp,',',1,2)+1 ,length(l_temp))
          where cust_acct_site_id = i.cust_acct_site_id;
  */



          fnd_FILE.put_line(FND_FILE.output,'cas_ID:'||I.CUST_ACCT_SITE_ID||' Warning: '||substr(l_temp,instr(l_temp,',',1,2)+1,length(l_temp)));

     END LOOP ;

      fnd_FILE.put_line(FND_FILE.output, '');
      fnd_FILE.put_line(FND_FILE.output, 'Program Complete');


  END MAIN_COUNTRY;

END XX_AR_ADDRESS_GEOCODE_PKG;
/
