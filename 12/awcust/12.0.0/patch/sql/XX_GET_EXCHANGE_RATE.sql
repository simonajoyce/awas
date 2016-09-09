--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_GET_EXCHANGE_RATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_GET_EXCHANGE_RATE" 
(
  CURRENCY_CODE IN VARCHAR2  
) return number as 

l_rate number;

BEGIN

select conversion_rate
into l_rate
from gl_daily_rates 
where to_date(conversion_date,'dd/mm/yy') = to_date(sysdate,'dd/mm/yy')
and conversion_type = 'Corporate'
and to_currency = 'USD'
and from_currency = currency_code;

  return l_rate;
  
END XX_GET_EXCHANGE_RATE;
 

/
