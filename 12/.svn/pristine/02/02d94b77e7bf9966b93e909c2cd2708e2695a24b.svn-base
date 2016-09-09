-- |  $Header: apxamex.ctl 120.4 2007/05/31 13:01:01 nram ship $|
-- +==================================================================+
-- |                Copyright (c) 1999 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +==================================================================+
-- |  Name:
-- |  apxamex.ctl (SQL*Loader Control file)
-- |
-- |  Description:
-- |  American Express Transaction Loader
-- |  This control file specifies the format of loading American
-- |  Express transaction records in KR-1025 format
-- |
-- |  Assumptions:
-- |  Valid transaction records begin with '1'
-- |  Record length = 1946
-- |
-- |  Valid mis_industry_codes:
-- |  'CA' = ATM
-- |  '05' = Restaurant
-- |  '04' = Car Rental
-- |  '03' = Hotel
-- |  '01' = Airline
-- |
-- |  Setup:
-- |  Please replace CARD_PROGRAM_ID with the valid card_program_id of the
-- |  Card Program you will be loading these transactions for.
-- |  Please replace ORG_ID with the valid org_id of the
-- |  Card Program you will be loading these transactions for.
-- |
-- |  History:
-- |  18-MAY-99  Ron Langi       Created
-- |
-- +==================================================================+
options (silent=(header,feedback,discards))
load data
infile *
append


-- ALL TRANSACTIONS
-- Exclude Corporate Travel Card 374398813841000 and 374398893731006 and 374398977292008 and 374398893732004 and  374398674191008
-- Also exclude US Cards beginning with 3782 and 3796

into table ap_credit_card_trxns_all
when (1) = '1' and (431:432) <> 'CA' and (431:432) <> '04' and (431:432) <> '03' and (431:432) <> '01' and (431:432) <> 'NF' and (431:432) <> '05' 
(
 trx_id				"ap_credit_card_trxns_s1.nextval",
 validate_code			constant 'N',
 payment_flag			constant 'N',
 card_program_id		"xx_get_card_program_id(:card_number)",   
 org_id         		constant  85,
 expensed_amount		constant 0,
 card_number boundfiller	position(114:132)	char,
 --card_id                    "ap_web_credit_card_pkg.get_card_id(:card_number, to_char(:card_program_id))",
 card_id                    "xx_get_card_id(:card_number)",
 reference_number		position(375:389)	char,
 --record_type
 --merchant_activity
 transaction_type		position(329:330)	char,
 financial_category		position(331:331)	char,
 transaction_amount		position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:transaction_amount/power(10,:posted_decimal)),
                :transaction_amount/power(10,:posted_decimal))",
 debit_flag			position(245:245)	char,
 billed_date			position(406:413)	date "YYYYMMDD"
	defaultif(billed_date=blanks),
 billed_amount			position(246:260)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:billed_amount/power(10,:billed_decimal)),
                :billed_amount/power(10,:billed_decimal))",
 billed_decimal			position(279:279)	integer external,
 billed_currency_code		position(276:278)	char,
 posted_date			position(398:405)	date "YYYYMMDD"
	defaultif(posted_date=blanks),
 posted_amount			position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:posted_amount/power(10,:posted_decimal)),
                :posted_amount/power(10,:posted_decimal))",
 posted_decimal			position(313:313)	integer external,
 posted_currency_code		position(310:312)	char,
 currency_conversion_exponent	position(279:279)	integer external,
 currency_conversion_rate	position(314:328)	decimal external
	":currency_conversion_rate/power(10,8)",
 mis_industry_code		position(431:432)	char,
 transaction_date		position(390:397)	date "YYYYMMDD"
                defaultif(transaction_date=blanks)
     "nvl(:transaction_date,
         decode(:mis_industry_code,'FE',:posted_date,'SP',:posted_date,'NG',:posted_date,'TC',:posted_date,'OA',:posted_date,:transaction_date))",
 sic_code			position(1104:1107)	integer external,
 --merchant_tax_id
 merchant_reference		position(234:244)	char,
 merchant_name1			position(840:879)	char,
 merchant_name2			position(880:919)	char,
 merchant_address1		position(920:959)	char,
 merchant_address2		position(960:999)	char,
 --merchant_address3
 --merchant_address4
 merchant_city			position(1000:1039)	char,
 merchant_province_state	position(1040:1045)	char,
 merchant_postal_code		position(1046:1060)	char,
 merchant_country		position(1061:1095)	char,
 total_tax			position(261:275)	decimal external,
 local_tax			position(295:309)	decimal external,
 --national_tax
 --other_tax
 --org_id
 --last_update_date
 --last_updated_by
 --last_update_login
 creation_date			sysdate
 --created_by
)


-- ATM

into table ap_credit_card_trxns_all
when (1) = '1' and (431:432) = 'CA'

(
 trx_id				"ap_credit_card_trxns_s1.nextval",
 validate_code			constant 'N',
 payment_flag			constant 'N',
 card_program_id		"xx_get_card_program_id(:card_number)",   
 org_id         		constant  85,
 expensed_amount		constant 0,
 card_number boundfiller	position(114:132)	char,
-- card_id                    "ap_web_credit_card_pkg.get_card_id(:card_number, to_char(:card_program_id))",
 card_id                    "xx_get_card_id(:card_number)",
 reference_number		position(375:389)	char,
 --record_type
 --merchant_activity
 transaction_type		position(329:330)	char,
 financial_category		position(331:331)	char,
 mis_industry_code		position(431:432)	char,
 transaction_date		position(390:397)	date "YYYYMMDD"
                defaultif(transaction_date=blanks)
     "nvl(:transaction_date,
         decode(:mis_industry_code,'FE',:posted_date,'SP',:posted_date,'NG',:posted_date,'TC',:posted_date,'OA',:posted_date,:transaction_date))",
 transaction_amount		position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:transaction_amount/power(10,:posted_decimal)),
                :transaction_amount/power(10,:posted_decimal))",
 debit_flag			position(245:245)	char,
 billed_date			position(406:413)	date "YYYYMMDD"
	defaultif(billed_date=blanks),
 billed_amount			position(246:260)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:billed_amount/power(10,:billed_decimal)),
                :billed_amount/power(10,:billed_decimal))",
 billed_decimal			position(279:279)	integer external,
 billed_currency_code		position(276:278)	char,
 posted_date			position(398:405)	date "YYYYMMDD"
	defaultif(posted_date=blanks),
 posted_amount			position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:posted_amount/power(10,:posted_decimal)),
                :posted_amount/power(10,:posted_decimal))",
 posted_decimal			position(313:313)	integer external,
 posted_currency_code		position(310:312)	char,
 currency_conversion_exponent	position(279:279)	integer external,
 currency_conversion_rate	position(314:328)	decimal external
	":currency_conversion_rate/power(10,8)",
 sic_code			position(1104:1107)	integer external,
 --merchant_tax_id
 merchant_reference		position(234:244)	char,
 merchant_name1			position(840:879)	char,
 merchant_name2			position(880:919)	char,
 merchant_address1		position(920:959)	char,
 merchant_address2		position(960:999)	char,
 --merchant_address3
 --merchant_address4
 merchant_city			position(1000:1039)	char,
 merchant_province_state	position(1040:1045)	char,
 merchant_postal_code		position(1046:1060)	char,
 merchant_country		position(1061:1095)	char,
 total_tax			position(261:275)	decimal external,
 local_tax			position(295:309)	decimal external,
 --national_tax
 --other_tax
 --org_id
 --last_update_date
 --last_updated_by
 --last_update_login
 creation_date			sysdate,
 --created_by
 folio_type			constant 'ATM',
 --atm_cash_advance
 atm_transaction_date		position(1242:1249)	date "YYYYMMDD"
	defaultif(atm_transaction_date=blanks),
 --atm_fee_amount
 --atm_type
 atm_id				position(1266:1305)	char,
 atm_network_id			position(1258:1265)	char
)


-- RESTAURANT
into table ap_credit_card_trxns_all
when (1) = '1' and (431:432) = '05'
(
 trx_id				"ap_credit_card_trxns_s1.nextval",
 validate_code			constant 'N',
 payment_flag			constant 'N',
 card_program_id		"xx_get_card_program_id(:card_number)",   
 org_id         		constant  85,
 expensed_amount		constant 0,
 card_number boundfiller	position(114:132)	char,
-- card_id                    "ap_web_credit_card_pkg.get_card_id(:card_number, to_char(:card_program_id))",
 card_id                    "xx_get_card_id(:card_number)",
 reference_number		position(375:389)	char,
 --record_type
 --merchant_activity
 transaction_type		position(329:330)	char,
 financial_category		position(331:331)	char,
 mis_industry_code		position(431:432)	char,
 transaction_date		position(390:397)	date "YYYYMMDD"
                defaultif(transaction_date=blanks)
     "nvl(:transaction_date,
         decode(:mis_industry_code,'FE',:posted_date,'SP',:posted_date,'NG',:posted_date,'TC',:posted_date,'OA',:posted_date,:transaction_date))",
 transaction_amount		position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:transaction_amount/power(10,:posted_decimal)),
                :transaction_amount/power(10,:posted_decimal))",
 debit_flag			position(245:245)	char,
 billed_date			position(406:413)	date "YYYYMMDD"
	defaultif(billed_date=blanks),
 billed_amount			position(246:260)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:billed_amount/power(10,:billed_decimal)),
                :billed_amount/power(10,:billed_decimal))",
 billed_decimal			position(279:279)	integer external,
 billed_currency_code		position(276:278)	char,
 posted_date			position(398:405)	date "YYYYMMDD"
	defaultif(posted_date=blanks),
 posted_amount			position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:posted_amount/power(10,:posted_decimal)),
                :posted_amount/power(10,:posted_decimal))",
 posted_decimal			position(313:313)	integer external,
 posted_currency_code		position(310:312)	char,
 currency_conversion_exponent	position(279:279)	integer external,
 currency_conversion_rate	position(314:328)	decimal external
	":currency_conversion_rate/power(10,8)",
 sic_code			position(1104:1107)	integer external,
 --merchant_tax_id
 merchant_reference		position(234:244)	char,
 merchant_name1			position(840:879)	char,
 merchant_name2			position(880:919)	char,
 merchant_address1		position(920:959)	char,
 merchant_address2		position(960:999)	char,
 --merchant_address3
 --merchant_address4
 merchant_city			position(1000:1039)	char,
 merchant_province_state	position(1040:1045)	char,
 merchant_postal_code		position(1046:1060)	char,
 merchant_country		position(1061:1095)	char,
 total_tax			position(261:275)	decimal external,
 local_tax			position(295:309)	decimal external,
 --national_tax
 --other_tax
 --org_id
 --last_update_date
 --last_updated_by
 --last_update_login
 creation_date			sysdate,
 --created_by
 folio_type			constant 'RESTAURANT'
)

-- CAR RENTAL

into table ap_credit_card_trxns_all
when (1) = '1' and (431:432) = '04'

(
 trx_id				"ap_credit_card_trxns_s1.nextval",
 validate_code			constant 'N',
 payment_flag			constant 'N',
 card_program_id		"xx_get_card_program_id(:card_number)",   
 org_id         		constant  85,
 expensed_amount		constant 0,
 card_number	boundfiller	position(114:132)	char,
-- card_id                    "ap_web_credit_card_pkg.get_card_id(:card_number, to_char(:card_program_id))",
 card_id                    "xx_get_card_id(:card_number)",
 reference_number		position(375:389)	char,
 --record_type
 --merchant_activity
 transaction_type		position(329:330)	char,
 financial_category		position(331:331)	char,
 mis_industry_code		position(431:432)	char,
 transaction_date		position(390:397)	date "YYYYMMDD"
                defaultif(transaction_date=blanks)
     "nvl(:transaction_date,
         decode(:mis_industry_code,'FE',:posted_date,'SP',:posted_date,'NG',:posted_date,'TC',:posted_date,'OA',:posted_date,:transaction_date))",
 transaction_amount		position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:transaction_amount/power(10,:posted_decimal)),
                :transaction_amount/power(10,:posted_decimal))",
 debit_flag			position(245:245)	char,
 billed_date			position(406:413)	date "YYYYMMDD"
	defaultif(billed_date=blanks),
 billed_amount			position(246:260)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:billed_amount/power(10,:billed_decimal)),
                :billed_amount/power(10,:billed_decimal))",
 billed_decimal			position(279:279)	integer external,
 billed_currency_code		position(276:278)	char,
 posted_date			position(398:405)	date "YYYYMMDD"
	defaultif(posted_date=blanks),
 posted_amount			position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:posted_amount/power(10,:posted_decimal)),
                :posted_amount/power(10,:posted_decimal))",
 posted_decimal			position(313:313)	integer external,
 posted_currency_code		position(310:312)	char,
 currency_conversion_exponent	position(279:279)	integer external,
 currency_conversion_rate	position(314:328)	decimal external
	":currency_conversion_rate/power(10,8)",
 sic_code			position(1104:1107)	integer external,
 --merchant_tax_id
 merchant_reference		position(234:244)	char,
 merchant_name1			position(840:879)	char,
 merchant_name2			position(880:919)	char,
 merchant_address1		position(920:959)	char,
 merchant_address2		position(960:999)	char,
 --merchant_address3
 --merchant_address4
 merchant_city			position(1000:1039)	char,
 merchant_province_state	position(1040:1045)	char,
 merchant_postal_code		position(1046:1060)	char,
 merchant_country		position(1061:1095)	char,
 total_tax			position(261:275)	decimal external,
 local_tax			position(295:309)	decimal external,
 --national_tax
 --other_tax
 --org_id
 --last_update_date
 --last_updated_by
 --last_update_login
 creation_date			sysdate,
 --created_by
 folio_type			constant 'CAR RENTAL',
 --car_rental_date		position(614:621)	date "YYYYMMDD"	defaultif (car_rental_date=blanks),
 --car_return_date		position(652:659)	date "YYYYMMDD"	defaultif (car_return_date=blanks),
 car_rental_location		position(622:651)	char,
 --car_rental_state
 car_return_location		position(660:689)	char,
 --car_return_state
 car_renter_name		position(690:724)	char,
 car_rental_days		position(725:727)	char,
 car_rental_agreement_number	position(728:740)	char
 --car_class
 --car_total_mileage
 --car_gas_amount
 --car_insurance_amount
 --car_mileage_amount
 --car_daily_rate
)


-- HOTEL

into table ap_credit_card_trxns_all
when (1) = '1' and (431:432) = '03'
(
 trx_id				"ap_credit_card_trxns_s1.nextval",
 validate_code			constant 'N',
 payment_flag			constant 'N',
 card_program_id		"xx_get_card_program_id(:card_number)",   
 org_id         		constant  85,
 expensed_amount		constant 0,
 card_number	boundfiller	position(114:132)	char,
-- card_id                    "ap_web_credit_card_pkg.get_card_id(:card_number, to_char(:card_program_id))",
 card_id                    "xx_get_card_id(:card_number)",
 reference_number		position(375:389)	char,
 --record_type
 --merchant_activity
 transaction_type		position(329:330)	char,
 financial_category		position(331:331)	char,
 mis_industry_code		position(431:432)	char,
 transaction_date		position(390:397)	date "YYYYMMDD"
                defaultif(transaction_date=blanks)
     "nvl(:transaction_date,
         decode(:mis_industry_code,'FE',:posted_date,'SP',:posted_date,'NG',:posted_date,'TC',:posted_date,'OA',:posted_date,:transaction_date))",
 transaction_amount		position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:transaction_amount/power(10,:posted_decimal)),
                :transaction_amount/power(10,:posted_decimal))",
 debit_flag			position(245:245)	char,
 billed_date			position(406:413)	date "YYYYMMDD"
	defaultif(billed_date=blanks),
 billed_amount			position(246:260)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:billed_amount/power(10,:billed_decimal)),
                :billed_amount/power(10,:billed_decimal))",
 billed_decimal			position(279:279)	integer external,
 billed_currency_code		position(276:278)	char,
 posted_date			position(398:405)	date "YYYYMMDD"
	defaultif(posted_date=blanks),
 posted_amount			position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:posted_amount/power(10,:posted_decimal)),
                :posted_amount/power(10,:posted_decimal))",
 posted_decimal			position(313:313)	integer external,
 posted_currency_code		position(310:312)	char,
 currency_conversion_exponent	position(279:279)	integer external,
 currency_conversion_rate	position(314:328)	decimal external
	":currency_conversion_rate/power(10,8)",
 sic_code			position(1104:1107)	integer external,
 --merchant_tax_id
 merchant_reference		position(234:244)	char,
 merchant_name1			position(840:879)	char,
 merchant_name2			position(880:919)	char,
 merchant_address1		position(920:959)	char,
 merchant_address2		position(960:999)	char,
 --merchant_address3
 --merchant_address4
 merchant_city			position(1000:1039)	char,
 merchant_province_state	position(1040:1045)	char,
 merchant_postal_code		position(1046:1060)	char,
 merchant_country		position(1061:1095)	char,
 total_tax			position(261:275)	decimal external,
 local_tax			position(295:309)	decimal external,
 --national_tax
 --other_tax
 --org_id
 --last_update_date
 --last_updated_by
 --last_update_login
 creation_date			sysdate,
 --created_by
 folio_type			constant 'HOTEL',
 --hotel_arrival_date		position(672:679)	date "YYYYMMDD"	defaultif (hotel_arrival_date=blanks),
 --hotel_depart_date		position(680:687)	date "YYYYMMDD"	defaultif (hotel_depart_date=blanks),
 hotel_charge_desc		position(614:636)	char,
 hotel_guest_name		position(637:671)	char,
 hotel_stay_duration		position(688:690)	integer external,
 hotel_room_rate		position(691:705)	char
	"replace(:hotel_room_rate, '$')",
 --hotel_no_show_flag
 --hotel_room_amount
 --hotel_telephone_amount
 --hotel_room_tax
 --hotel_bar_amount
 --hotel_movie_amount
 --hotel_gift_shop_amount
 --hotel_laundry_amount
 --hotel_health_amount
 --hotel_restaurant_amount
 --hotel_business_amount
 --hotel_parking_amount
 --hotel_room_service_amount
 --hotel_tip_amount
 --hotel_misc_amount
 hotel_city			position(706:735)	char,
 hotel_state			position(736:741)	char
 --hotel_folio_number
 --hotel_room_type
)


-- AIR

into table ap_credit_card_trxns_all
when (1) = '1' and (431:432) = '01'
(
 trx_id				"ap_credit_card_trxns_s1.nextval",
 validate_code			constant 'N',
 payment_flag			constant 'N',
 --card_program_id		"xx_get_card_program_id(:card_number)",   
 org_id         		constant  85,
 expensed_amount		constant 0,
 card_number boundfiller	position(114:132)	char,
 card_program_id		"xx_get_card_program_id(:card_number)",   
-- card_id                    "ap_web_credit_card_pkg.get_card_id(:card_number, to_char(:card_program_id))",
 card_id                    "xx_get_card_id(:card_number)",
 reference_number		position(375:389)	char,
 --record_type
 --merchant_activity
 transaction_type		position(329:330)	char,
 financial_category		position(331:331)	char,
 mis_industry_code		position(431:432)	char,
 transaction_date		position(390:397)	date "YYYYMMDD"
                defaultif(transaction_date=blanks)
     "nvl(:transaction_date,
         decode(:mis_industry_code,'FE',:posted_date,'SP',:posted_date,'NG',:posted_date,'TC',:posted_date,'OA',:posted_date,:transaction_date))",
 transaction_amount		position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:transaction_amount/power(10,:posted_decimal)),
                :transaction_amount/power(10,:posted_decimal))",
 debit_flag			position(245:245)	char,
 billed_date			position(406:413)	date "YYYYMMDD"
	defaultif(billed_date=blanks),
 billed_amount			position(246:260)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:billed_amount/power(10,:billed_decimal)),
                :billed_amount/power(10,:billed_decimal))",
 billed_decimal			position(279:279)	integer external,
 billed_currency_code		position(276:278)	char,
 posted_date			position(398:405)	date "YYYYMMDD"
	defaultif(posted_date=blanks),
 posted_amount			position(280:294)	decimal external
	"decode(:debit_flag, 
                '-', -1*abs(:posted_amount/power(10,:posted_decimal)),
                :posted_amount/power(10,:posted_decimal))",
 posted_decimal			position(313:313)	integer external,
 posted_currency_code		position(310:312)	char,
 currency_conversion_exponent	position(279:279)	integer external,
 currency_conversion_rate	position(314:328)	decimal external
	":currency_conversion_rate/power(10,8)",
 sic_code			position(1104:1107)	integer external,
 --merchant_tax_id
 merchant_reference		position(234:244)	char,
 merchant_name1			position(840:879)	char,
 merchant_name2			position(880:919)	char,
 merchant_address1		position(920:959)	char,
 merchant_address2		position(960:999)	char,
 --merchant_address3
 --merchant_address4
 merchant_city			position(1000:1039)	char,
 merchant_province_state	position(1040:1045)	char,
 merchant_postal_code		position(1046:1060)	char,
 merchant_country		position(1061:1095)	char,
 total_tax			position(261:275)	decimal external,
 local_tax			position(295:309)	decimal external,
 --national_tax
 --other_tax
 --org_id
 --last_update_date
 --last_updated_by
 --last_update_login
 creation_date			sysdate,
 --created_by
 folio_type			constant 'AIR',
 --air_departure_date		position(614:621)	date "YYYYMMDD"
	--defaultif(air_departure_date=blanks),
 --air_departure_city
 air_routing			position(622:648)	char,
 --air_arrival_city
 --air_stopover_flag
 --air_base_fare_amount
 --air_fare_basis_code
 air_service_class		position(649:656)	char,
 --air_carrier_abbreviation
 air_carrier_code		position(657:672)	char,
 air_ticket_issuer		position(673:709)	char,
 air_issuer_city		position(710:739)	char,
 air_passenger_name		position(746:780)	char,
 --air_refund_ticket_number
 --air_exchanged_ticket_number
 air_agency_number		position(781:788)	char,
 air_ticket_number		position(789:801)	char
)

