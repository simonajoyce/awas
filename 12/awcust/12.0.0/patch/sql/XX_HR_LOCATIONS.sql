--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_HR_LOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_HR_LOCATIONS" ("LOCATION_CODE", "ADDRESS", "LOCATION_ID") AS 
  (SELECT location_code ,
    nvl2(address_line_1,address_line_1
    ||','
    ||chr(13),'')
    ||nvl2(address_line_2,address_line_2
    ||','
    ||chr(13),'')
    ||nvl2(address_line_3,address_line_3
    ||','
    ||chr(13),'')
    ||nvl2(town_or_city,town_or_city
    ||','
    ||chr(13),'')
    ||nvl2(country,country
    ||','
    ||chr(13),'')
    ||nvl2(postal_Code,postal_code
    ||','
    ||chr(13),'') ADDRESS,
    location_id
  FROM hr_locations
  WHERE SYSDATE < NVL(inactive_Date,SYSDATE+1)
  )
 ;
