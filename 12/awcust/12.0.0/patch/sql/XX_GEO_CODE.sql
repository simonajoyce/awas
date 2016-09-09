SET DEFINE OFF;
--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GEO_CODE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GEO_CODE" 
          ( Concat_Location IN VARCHAR2 )
          RETURN VARCHAR2 /*--  Latitude,Logitude,Warning*/
          
     /*------------------------------------------------------------------
     | xx_geo_code FUNCTION WRITTEN AND DEVELOPED BY Simon Joyce        |
     | 29th Oct 2009. this function returns the Latitude, Logitude and  |
     | any warning messages from Yahoo maps api when supplied with a    |
     | concatenated address                                             |
     ------------------------------------------------------------------*/
     AS
          l_pieces UTL_HTTP.HTML_PIECES;
          l_two_pages VARCHAR2 ( 4000 ) ;
          l_start_lon NUMBER;
          l_end_lon   NUMBER;
          l_start_war NUMBER;
          l_end_war   NUMBER;
          l_start_lat NUMBER;
          l_end_lat   NUMBER;
          l_start_add NUMBER;
          l_end_add   NUMBER;
          l_start_city NUMBER;
          l_end_city   NUMBER;
          l_start_state NUMBER;
          l_end_state   NUMBER;
          l_start_zip NUMBER;
          l_end_zip   NUMBER;
          l_start_country NUMBER;
          l_end_country   NUMBER;
          l_lon       VARCHAR2 ( 50 ) ;
          l_war       VARCHAR2 ( 200 ) ;
          l_lat       VARCHAR2 ( 50 ) ;
          l_address   VARCHAR2 (1000);
          l_city      VARCHAR2 (300);
          l_state     VARCHAR2 (100);
          l_zip       VARCHAR2 (20);
          l_country   VARCHAR2 (50);
          l_geocode   VARCHAR2 ( 1800 ) ;
          l_location  VARCHAR2 ( 300 ) ;
          url         VARCHAR2 ( 800 ) ;
     BEGIN
           SELECT REPLACE ( concat_location, ' ', '+' ) INTO l_location FROM dual;
           SELECT REPLACE ( l_location, '#', '' ) INTO l_location FROM dual;
          
          url      := 'http://local.yahooapis.com/MapsService/V1/geocode?appid=YD-9G7bey8_JXxQP6rxl.fBFGgCdNjoDMACQA--&location='|| l_location;
          l_pieces := UTL_HTTP.REQUEST_PIECES ( url, 32 ) ;
          FOR i    IN 1 .. l_pieces.COUNT
          LOOP
               l_two_pages := l_two_pages || l_pieces ( i ) ;
                SELECT INSTR ( l_two_pages, '<Latitude>', 1, 1 ) INTO l_start_lat FROM dual;
                l_start_lat := l_start_lat + 10;
                SELECT INSTR ( l_two_pages, '</Latitude>', 1, 1 ) INTO l_end_lat FROM dual;
                
                SELECT INSTR ( l_two_pages, '<Longitude>', 1, 1 ) INTO l_start_lon FROM dual;
                l_start_lon := l_start_lon + 11;
                SELECT INSTR ( l_two_pages, '</Longitude>', 1, 1 ) INTO l_end_lon FROM dual;
                
                SELECT INSTR ( l_two_pages, '<Address>', 1, 1 ) INTO l_start_add FROM dual;
                l_start_add := l_start_add + 9;
                SELECT INSTR ( l_two_pages, '</Address>', 1, 1 ) INTO l_end_add FROM dual;
                
                SELECT INSTR ( l_two_pages, '<City>', 1, 1 ) INTO l_start_city FROM dual;
                l_start_city := l_start_city + 6;
                SELECT INSTR ( l_two_pages, '</City>', 1, 1 ) INTO l_end_city FROM dual;
                
                SELECT INSTR ( l_two_pages, '<State>', 1, 1 ) INTO l_start_state FROM dual;
                l_start_state := l_start_state + 7;
                SELECT INSTR ( l_two_pages, '</State>', 1, 1 ) INTO l_end_state FROM dual;
                
                SELECT INSTR ( l_two_pages, '<Zip>', 1, 1 ) INTO l_start_zip FROM dual;
                l_start_zip := l_start_zip + 5;
                SELECT INSTR ( l_two_pages, '</Zip>', 1, 1 ) INTO l_end_zip FROM dual;
                
                SELECT INSTR ( l_two_pages, '<Country>', 1, 1 ) INTO l_start_country FROM dual;
                l_start_country := l_start_country + 9;
                SELECT INSTR ( l_two_pages, '</Country>', 1, 1 ) INTO l_end_country FROM dual;
                
                SELECT INSTR ( l_two_pages, 'warning="', 1, 1 ) INTO l_start_war FROM dual;
               IF l_start_war   <> 0 THEN
                    l_start_war := l_start_war + 9;
                     SELECT INSTR ( l_two_pages, '">', l_start_war, 1 ) INTO l_end_war FROM dual;
               ELSE
                    l_end_war := 0;
               END IF;
                SELECT
                         SUBSTR ( l_two_pages, l_start_lat, l_end_lat - l_start_lat ),
                         SUBSTR ( l_two_pages, l_start_lon, l_end_lon - l_start_lon ),
                         SUBSTR ( l_two_pages, l_start_war, l_end_war - l_start_war ),
                         SUBSTR ( l_two_pages, l_start_add, l_end_add - l_start_add ),
                         SUBSTR ( l_two_pages, l_start_city, l_end_city - l_start_city ),
                         SUBSTR ( l_two_pages, l_start_state, l_end_state - l_start_state ),
                         SUBSTR ( l_two_pages, l_start_zip, l_end_zip - l_start_zip),
                         SUBSTR ( l_two_pages, l_start_country, l_end_country - l_start_country)
                       INTO
                         l_lat,
                         l_lon,
                         l_war,
                         l_address,
                         l_city,
                         l_state,
                         l_zip,
                         l_country
                       FROM
                         dual;
               
               l_geocode   := l_lat||'|'||l_lon||'|'||l_war||'|'||l_address||'|'||l_city||'|'||l_state||'|'||l_zip||'|'||l_country;
               l_two_pages := l_pieces ( i ) ;
          END LOOP;
          RETURN l_geocode;
     END xx_geo_code;
 

/
