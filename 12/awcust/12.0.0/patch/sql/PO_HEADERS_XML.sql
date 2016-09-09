CREATE OR REPLACE FORCE VIEW "APPS"."PO_HEADERS_XML" ("TYPE_LOOKUP_CODE", "SEGMENT1", "REVISION_NUM", "PRINT_COUNT",
       "CREATION_DATE", "PRINTED_DATE", "REVISED_DATE", "START_DATE", "END_DATE", "NOTE_TO_VENDOR", "DOCUMENT_BUYER_FIRST_NAME",
       "DOCUMENT_BUYER_LAST_NAME", "DOCUMENT_BUYER_TITLE", "DOCUMENT_BUYER_AGENT_ID", "ARCHIVE_BUYER_AGENT_ID",
       "ARCHIVE_BUYER_FIRST_NAME", "ARCHIVE_BUYER_LAST_NAME", "ARCHIVE_BUYER_TITLE", "AMOUNT_AGREED", "CANCEL_FLAG",
       "CONFIRMING_ORDER_FLAG", "ACCEPTANCE_REQUIRED_FLAG", "ACCEPTANCE_DUE_DATE", "CURRENCY_CODE", "CURRENCY_NAME", "RATE",
       "SHIP_VIA", "FOB", "FREIGHT_TERMS", "PAYMENT_TERMS", "CUSTOMER_NUM", "VENDOR_NUM", "VENDOR_NAME", "VENDOR_ADDRESS_LINE1",
       "VENDOR_ADDRESS_LINE2", "VENDOR_ADDRESS_LINE3", "VENDOR_CITY", "VENDOR_STATE", "VENDOR_POSTAL_CODE", "VENDOR_COUNTRY",
       "VENDOR_PHONE", "VENDOR_CONTACT_FIRST_NAME", "VENDOR_CONTACT_LAST_NAME", "VENDOR_CONTACT_TITLE", "VENDOR_CONTACT_PHONE",
       "SHIP_TO_LOCATION_ID", "SHIP_TO_LOCATION_NAME", "SHIP_TO_ADDRESS_LINE1", "SHIP_TO_ADDRESS_LINE2", "SHIP_TO_ADDRESS_LINE3",
       "SHIP_TO_ADDRESS_LINE4", "SHIP_TO_ADDRESS_INFO", "SHIP_TO_COUNTRY", "BILL_TO_LOCATION_ID", "BILL_TO_LOCATION_NAME",
       "BILL_TO_ADDRESS_LINE1", "BILL_TO_ADDRESS_LINE2", "BILL_TO_ADDRESS_LINE3", "BILL_TO_ADDRESS_LINE4", "BILL_TO_ADDRESS_INFO",
       "BILL_TO_COUNTRY", "ATTRIBUTE1", "ATTRIBUTE2", "ATTRIBUTE3", "ATTRIBUTE4", "ATTRIBUTE5", "ATTRIBUTE6", "ATTRIBUTE7",
       "ATTRIBUTE8", "ATTRIBUTE9", "ATTRIBUTE10", "ATTRIBUTE11", "ATTRIBUTE12", "ATTRIBUTE13", "ATTRIBUTE14", "ATTRIBUTE15",
       "VENDOR_SITE_ID", "PO_HEADER_ID", "APPROVED_FLAG", "LANGUAGE", "VENDOR_ID", "CLOSED_CODE", "USSGL_TRANSACTION_CODE",
       "GOVERNMENT_CONTEXT", "REQUEST_ID", "PROGRAM_APPLICATION_ID", "PROGRAM_ID", "PROGRAM_UPDATE_DATE", "ORG_ID", "COMMENTS",
       "REPLY_DATE", "REPLY_METHOD_LOOKUP_CODE", "RFQ_CLOSE_DATE", "QUOTE_TYPE_LOOKUP_CODE", "QUOTATION_CLASS_CODE",
       "QUOTE_WARNING_DELAY_UNIT", "QUOTE_WARNING_DELAY", "QUOTE_VENDOR_QUOTE_NUMBER", "CLOSED_DATE", "USER_HOLD_FLAG",
       "APPROVAL_REQUIRED_FLAG", "FIRM_STATUS_LOOKUP_CODE", "FIRM_DATE", "FROZEN_FLAG", "EDI_PROCESSED_FLAG",
       "EDI_PROCESSED_STATUS", "ATTRIBUTE_CATEGORY", "CREATED_BY", "VENDOR_CONTACT_ID", "TERMS_ID", "FOB_LOOKUP_CODE",
       "FREIGHT_TERMS_LOOKUP_CODE", "STATUS_LOOKUP_CODE", "RATE_TYPE", "RATE_DATE", "FROM_HEADER_ID", "FROM_TYPE_LOOKUP_CODE",
       "AUTHORIZATION_STATUS", "APPROVED_DATE", "AMOUNT_LIMIT", "MIN_RELEASE_AMOUNT", "NOTE_TO_AUTHORIZER", "NOTE_TO_RECEIVER",
       "VENDOR_ORDER_NUM", "LAST_UPDATE_DATE", "LAST_UPDATED_BY", "SUMMARY_FLAG", "ENABLED_FLAG", "SEGMENT2", "SEGMENT3",
       "SEGMENT4", "SEGMENT5", "START_DATE_ACTIVE", "END_DATE_ACTIVE", "LAST_UPDATE_LOGIN", "SUPPLY_AGREEMENT_FLAG",
       "GLOBAL_ATTRIBUTE_CATEGORY", "GLOBAL_ATTRIBUTE1", "GLOBAL_ATTRIBUTE2", "GLOBAL_ATTRIBUTE3", "GLOBAL_ATTRIBUTE4",
       "GLOBAL_ATTRIBUTE5", "GLOBAL_ATTRIBUTE6", "GLOBAL_ATTRIBUTE7", "GLOBAL_ATTRIBUTE8", "GLOBAL_ATTRIBUTE9",
       "GLOBAL_ATTRIBUTE10", "GLOBAL_ATTRIBUTE11", "GLOBAL_ATTRIBUTE12", "GLOBAL_ATTRIBUTE13", "GLOBAL_ATTRIBUTE14",
       "GLOBAL_ATTRIBUTE15", "GLOBAL_ATTRIBUTE16", "GLOBAL_ATTRIBUTE17", "GLOBAL_ATTRIBUTE18", "GLOBAL_ATTRIBUTE19",
       "GLOBAL_ATTRIBUTE20", "INTERFACE_SOURCE_CODE", "REFERENCE_NUM", "WF_ITEM_TYPE", "WF_ITEM_KEY", "PCARD_ID",
       "PRICE_UPDATE_TOLERANCE", "MRC_RATE_TYPE", "MRC_RATE_DATE", "MRC_RATE", "PAY_ON_CODE", "XML_FLAG", "XML_SEND_DATE",
       "XML_CHANGE_SEND_DATE", "GLOBAL_AGREEMENT_FLAG", "CONSIGNED_CONSUMPTION_FLAG", "CBC_ACCOUNTING_DATE",
       "CONSUME_REQ_DEMAND_FLAG", "CHANGE_REQUESTED_BY", "SHIPPING_CONTROL", "CONTERMS_EXIST_FLAG", "CONTERMS_ARTICLES_UPD_DATE",
       "CONTERMS_DELIV_UPD_DATE", "PENDING_SIGNATURE_FLAG", "OU_NAME", "OU_ADDR1", "OU_ADDR2", "OU_ADDR3", "OU_TOWN_CITY",
       "OU_REGION2", "OU_POSTALCODE", "OU_COUNTRY", "BUYER_LOCATION_ID", "BUYER_ADDRESS_LINE1", "BUYER_ADDRESS_LINE2",
       "BUYER_ADDRESS_LINE3", "BUYER_ADDRESS_LINE4", "BUYER_CITY_STATE_ZIP", "BUYER_CONTACT_PHONE", "BUYER_CONTACT_EMAIL",
       "BUYER_CONTACT_FAX", "VENDOR_FAX", "SUPPLIER_NOTIF_METHOD", "VENDOR_EMAIL", "TOTAL_AMOUNT", "BUYER_COUNTRY",
       "VENDOR_ADDRESS_LINE4", "VENDOR_AREA_CODE", "VENDOR_CONTACT_AREA_CODE", "LE_NAME", "LE_ADDR1", "LE_ADDR2", "LE_ADDR3",
       "LE_TOWN_CITY", "LE_STAE_PROVINCE", "LE_POSTALCODE", "LE_COUNTRY", "CANCEL_DATE", "CHANGE_SUMMARY",
       "DOCUMENT_CREATION_METHOD", "ENCUMBRANCE_REQUIRED_FLAG", "STYLE_DISPLAY_NAME", "VENDOR_FAX_AREA_CODE")
AS;

        SELECT PH.TYPE_LOOKUP_CODE
            , PH.SEGMENT1
            , PH.REVISION_NUM
            , PH.PRINT_COUNT
            , TO_CHAR(PH.CREATION_DATE,'DD-MON-YYYY HH24:MI:SS') CREATION_DATE
            , PH.PRINTED_DATE
            , TO_CHAR(PH.REVISED_DATE,'DD-MON-YYYY HH24:MI:SS') REVISED_DATE
            , TO_CHAR(PH.START_DATE,'DD-MON-YYYY HH24:MI:SS') START_DATE
            , TO_CHAR(PH.END_DATE,'DD-MON-YYYY HH24:MI:SS') END_DATE
            , PH.NOTE_TO_VENDOR
            /*AWAS HRE.FIRST_NAME DOCUMENT_BUYER_FIRST_NAME, */
			/*AWAS*/
            ,  NULL DOCUMENT_BUYER_FIRST_NAME
            , HRE.LAST_NAME DOCUMENT_BUYER_LAST_NAME
			/*AWAS HRL.MEANING DOCUMENT_BUYER_TITLE,         */
			/*AWAS*/
            ,	NULL DOCUMENT_BUYER_TITLE
            , PH.AGENT_ID DOCUMENT_BUYER_AGENT_ID
            , DECODE(NVL(PH.REVISION_NUM, 0),0, NULL, PO_COMMUNICATION_PVT.GETARCBUYERAGENTID(PH.PO_HEADER_ID))
              ARCHIVE_BUYER_AGENT_ID
            , DECODE(NVL(PH.REVISION_NUM, 0),0, NULL, PO_COMMUNICATION_PVT.GETARCBUYERFNAME()) ARCHIVE_BUYER_FIRST_NAME
            , DECODE(NVL(PH.REVISION_NUM, 0),0, NULL, PO_COMMUNICATION_PVT.GETARCBUYERLNAME()) ARCHIVE_BUYER_LAST_NAME
            , DECODE(NVL(PH.REVISION_NUM, 0),0, NULL, PO_COMMUNICATION_PVT.GETARCBUYERTITLE()) ARCHIVE_BUYER_TITLE
            , TO_CHAR(NVL(PH.BLANKET_TOTAL_AMOUNT, ''),PO_COMMUNICATION_PVT.GETFORMATMASK) AMOUNT_AGREED
            , NVL(PH.CANCEL_FLAG,'N')
            , PH.CONFIRMING_ORDER_FLAG
            , NVL(PH.ACCEPTANCE_REQUIRED_FLAG,'N')
            , TO_CHAR(PH.ACCEPTANCE_DUE_DATE,'DD-MON-YYYY HH24:MI:SS') ACCEPTANCE_DUE_DATE
            , FCC.CURRENCY_CODE
            , FCC.NAME CURRENCY_NAME
            , TO_CHAR(PH.RATE, PO_COMMUNICATION_PVT.GETFORMATMASK) RATE
            , NVL(OFC.FREIGHT_CODE_TL, PH.SHIP_VIA_LOOKUP_CODE) SHIP_VIA
            , PLC1.MEANING FOB
            , PLC2.MEANING FREIGHT_TERMS
            , T.NAME PAYMENT_TERMS
            , NVL(PVS.CUSTOMER_NUM, VN.CUSTOMER_NUM) CUSTOMER_NUM
            , VN.SEGMENT1 VENDOR_NUM
            , VN.VENDOR_NAME
            , HL.ADDRESS1 VENDOR_ADDRESS_LINE1
            , HL.ADDRESS2 VENDOR_ADDRESS_LINE2
            , HL.ADDRESS3 VENDOR_ADDRESS_LINE3
            , HL.CITY VENDOR_CITY
            , DECODE(HL.STATE, NULL, DECODE(HL.PROVINCE, NULL, HL.COUNTY, HL.PROVINCE), HL.STATE) VENDOR_STATE
            , SUBSTR(HL.POSTAL_CODE, 1, 20) VENDOR_POSTAL_CODE
            , FTE3.TERRITORY_SHORT_NAME VENDOR_COUNTRY
            , PVS.PHONE VENDOR_PHONE
            , PVC.FIRST_NAME VENDOR_CONTACT_FIRST_NAME
            , PVC.LAST_NAME VENDOR_CONTACT_LAST_NAME
            , PLC4.MEANING VENDOR_CONTACT_TITLE
            , PVC.PHONE VENDOR_CONTACT_PHONE
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETLOCATIONINFO(PH.SHIP_TO_LOCATION_ID))
              SHIP_TO_LOCATION_ID
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETLOCATIONNAME()) SHIP_TO_LOCATION_NAME
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE1()) SHIP_TO_ADDRESS_LINE1
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE2()) SHIP_TO_ADDRESS_LINE2
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE3()) SHIP_TO_ADDRESS_LINE3
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE4()) SHIP_TO_ADDRESS_LINE4
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSINFO()) SHIP_TO_ADDRESS_INFO
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETTERRITORYSHORTNAME() )SHIP_TO_COUNTRY
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETLOCATIONINFO(PH.BILL_TO_LOCATION_ID))
              BILL_TO_LOCATION_ID
            , DECODE(NVL(PH.SHIP_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETLOCATIONNAME()) BILL_TO_LOCATION_NAME
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE1() ) BILL_TO_ADDRESS_LINE1
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE2() ) BILL_TO_ADDRESS_LINE2
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE3() ) BILL_TO_ADDRESS_LINE3
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSLINE4() ) BILL_TO_ADDRESS_LINE4
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETADDRESSINFO()) BILL_TO_ADDRESS_INFO
            , DECODE(NVL(PH.BILL_TO_LOCATION_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETTERRITORYSHORTNAME()) BILL_TO_COUNTRY
            , PH.ATTRIBUTE1
            , PH.ATTRIBUTE2
            , PH.ATTRIBUTE3
            , PH.ATTRIBUTE4
            , PH.ATTRIBUTE5
            , PH.ATTRIBUTE6
            , PH.ATTRIBUTE7
            , PH.ATTRIBUTE8
            , PH.ATTRIBUTE9
            , PH.ATTRIBUTE10
            , PH.ATTRIBUTE11
            , PH.ATTRIBUTE12
            , PH.ATTRIBUTE13
            , PH.ATTRIBUTE14
			/*AWAS PH.ATTRIBUTE15, */
			/*AWAS*/
	     ,		NVL(
			(SELECT xp.LONG_NAME
			FROM po_distributions_all xpda,
				pa_projects_all xp
			WHERE xpda.project_id       = xp.project_id (+)
			AND xpda.po_distribution_id =
				(SELECT MIN(po_distribution_id)
				FROM po_distributions_all xd
				WHERE xd.po_header_id = xpda.po_header_id
				)

			AND XPDA.PO_HEADER_ID = PH.PO_HEADER_ID
			) , ph.attribute12) ATTRIBUTE15
            , PH.VENDOR_SITE_ID
            , PH.PO_HEADER_ID
            , DECODE(PH.APPROVED_FLAG,'Y','Y','N') APPROVED_FLAG
            , PVS.LANGUAGE
            , PH.VENDOR_ID
            , PH.CLOSED_CODE
            , PH.USSGL_TRANSACTION_CODE
            , PH.GOVERNMENT_CONTEXT
            , PH.REQUEST_ID
            , PH.PROGRAM_APPLICATION_ID
            , PH.PROGRAM_ID
            , PH.PROGRAM_UPDATE_DATE
            , PH.ORG_ID
            , PH.COMMENTS
            , TO_CHAR(PH.REPLY_DATE,'DD-MON-YYYY HH24:MI:SS') REPLY_DATE
            , PH.REPLY_METHOD_LOOKUP_CODE
            , TO_CHAR(PH.RFQ_CLOSE_DATE,'DD-MON-YYYY HH24:MI:SS') RFQ_CLOSE_DATE
            , PH.QUOTE_TYPE_LOOKUP_CODE
            , PH.QUOTATION_CLASS_CODE
            , PH.QUOTE_WARNING_DELAY_UNIT
            , PH.QUOTE_WARNING_DELAY
            , PH.QUOTE_VENDOR_QUOTE_NUMBER
            , TO_CHAR(PH.CLOSED_DATE,'DD-MON-YYYY HH24:MI:SS') CLOSED_DATE
            , PH.USER_HOLD_FLAG
            , PH.APPROVAL_REQUIRED_FLAG
            , PH.FIRM_STATUS_LOOKUP_CODE
            , TO_CHAR(PH.FIRM_DATE,'DD-MON-YYYY HH24:MI:SS') FIRM_DATE
            , PH.FROZEN_FLAG
            , PH.EDI_PROCESSED_FLAG
            , PH.EDI_PROCESSED_STATUS
            , PH.ATTRIBUTE_CATEGORY
            , PH.CREATED_BY
            , PH.VENDOR_CONTACT_ID
            , PH.TERMS_ID
            , PH.FOB_LOOKUP_CODE
            , PH.FREIGHT_TERMS_LOOKUP_CODE
            , PH.STATUS_LOOKUP_CODE
            , PH.RATE_TYPE
            , TO_CHAR(PH.RATE_DATE,'DD-MON-YYYY HH24:MI:SS') RATE_DATE
            , PH.FROM_HEADER_ID
            , PH.FROM_TYPE_LOOKUP_CODE
            , NVL(PH.AUTHORIZATION_STATUS, 'N') AUTHORIZATION_STATUS
            , TO_CHAR(PH.APPROVED_DATE,'DD-MON-YYYY HH24:MI:SS') APPROVED_DATE
            , TO_CHAR(PH.AMOUNT_LIMIT, PO_COMMUNICATION_PVT.GETFORMATMASK) AMOUNT_LIMIT
            , TO_CHAR(PH.MIN_RELEASE_AMOUNT, PO_COMMUNICATION_PVT.GETFORMATMASK) MIN_RELEASE_AMOUNT
            , PH.NOTE_TO_AUTHORIZER
            , PH.NOTE_TO_RECEIVER
            , PH.VENDOR_ORDER_NUM
            , TO_CHAR(PH.LAST_UPDATE_DATE,'DD-MON-YYYY HH24:MI:SS') LAST_UPDATE_DATE
            , PH.LAST_UPDATED_BY
            , PH.SUMMARY_FLAG
            , PH.ENABLED_FLAG
            , PH.SEGMENT2
            , PH.SEGMENT3
            , PH.SEGMENT4
            , PH.SEGMENT5
            , TO_CHAR(PH.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS') START_DATE_ACTIVE
            , TO_CHAR(PH.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS') END_DATE_ACTIVE
            , PH.LAST_UPDATE_LOGIN
            , PH.SUPPLY_AGREEMENT_FLAG
            , PH.GLOBAL_ATTRIBUTE_CATEGORY
			/*AWAS PH.GLOBAL_ATTRIBUTE1, */
			/*AWAS*/
            , 'FAO: '
			||buyer.fao GLOBAL_ATTRIBUTE1
            , PH.GLOBAL_ATTRIBUTE2
            , PH.GLOBAL_ATTRIBUTE3
            , PH.GLOBAL_ATTRIBUTE4
            , PH.GLOBAL_ATTRIBUTE5
            , PH.GLOBAL_ATTRIBUTE6
            , PH.GLOBAL_ATTRIBUTE7
            , PH.GLOBAL_ATTRIBUTE8
            , PH.GLOBAL_ATTRIBUTE9
            , PH.GLOBAL_ATTRIBUTE10
            , PH.GLOBAL_ATTRIBUTE11
            , PH.GLOBAL_ATTRIBUTE12
            , PH.GLOBAL_ATTRIBUTE13
            , PH.GLOBAL_ATTRIBUTE14
            , PH.GLOBAL_ATTRIBUTE15
            , PH.GLOBAL_ATTRIBUTE16
            , PH.GLOBAL_ATTRIBUTE17
            , PH.GLOBAL_ATTRIBUTE18
            , PH.GLOBAL_ATTRIBUTE19
            , PH.GLOBAL_ATTRIBUTE20
            , PH.INTERFACE_SOURCE_CODE
            , PH.REFERENCE_NUM
            , PH.WF_ITEM_TYPE
            , PH.WF_ITEM_KEY
            , PH.PCARD_ID
            , PH.PRICE_UPDATE_TOLERANCE
            , PH.MRC_RATE_TYPE
            , PH.MRC_RATE_DATE
            , PH.MRC_RATE
            , PH.PAY_ON_CODE
            , PH.XML_FLAG
            , TO_CHAR(PH.XML_SEND_DATE,'DD-MON-YYYY HH24:MI:SS') XML_SEND_DATE
            , TO_CHAR(PH.XML_CHANGE_SEND_DATE,'DD-MON-YYYY HH24:MI:SS') XML_CHANGE_SEND_DATE
            , PH.GLOBAL_AGREEMENT_FLAG
            , PH.CONSIGNED_CONSUMPTION_FLAG
            , TO_CHAR(PH.CBC_ACCOUNTING_DATE,'DD-MON-YYYY HH24:MI:SS') CBC_ACCOUNTING_DATE
            , PH.CONSUME_REQ_DEMAND_FLAG
            , PH.CHANGE_REQUESTED_BY
            , PLC3.MEANING SHIPPING_CONTROL
            , PH.CONTERMS_EXIST_FLAG
            , TO_CHAR(PH.CONTERMS_ARTICLES_UPD_DATE,'DD-MON-YYYY HH24:MI:SS') CONTERMS_ARTICLES_UPD_DATE
            , TO_CHAR(PH.CONTERMS_DELIV_UPD_DATE,'DD-MON-YYYY HH24:MI:SS') CONTERMS_DELIV_UPD_DATE
            , NVL(PH.PENDING_SIGNATURE_FLAG,'N')
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOPERATIONINFO(PH.ORG_ID)) OU_NAME
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOUADDRESSLINE1()) OU_ADDR1
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOUADDRESSLINE2()) OU_ADDR2
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOUADDRESSLINE3()) OU_ADDR3
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOUTOWNCITY()) OU_TOWN_CITY
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOUREGION2()) OU_REGION2
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.GETOUPOSTALCODE()) OU_POSTALCODE
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getOUCountry()) OU_COUNTRY
            /*AWAS PO_COMMUNICATION_PVT.GETLOCATIONINFO(PA.LOCATION_ID) BUYER_LOCATION_ID, */
			/*AWAS*/
            , PO_COMMUNICATION_PVT.GETLOCATIONINFO(buyer.buyer_LOCATION_ID) BUYER_LOCATION_ID
            , PO_COMMUNICATION_PVT.GETADDRESSLINE1() BUYER_ADDRESS_LINE1
            , PO_COMMUNICATION_PVT.GETADDRESSLINE2() BUYER_ADDRESS_LINE2
            , PO_COMMUNICATION_PVT.GETADDRESSLINE3() BUYER_ADDRESS_LINE3
            , PO_COMMUNICATION_PVT.GETADDRESSLINE4() BUYER_ADDRESS_LINE4
            , PO_COMMUNICATION_PVT.GETADDRESSINFO() BUYER_CITY_STATE_ZIP
            , PO_COMMUNICATION_PVT.GETPHONE(PA.AGENT_ID) BUYER_CONTACT_PHONE
            , PO_COMMUNICATION_PVT.GETEMAIL() BUYER_CONTACT_EMAIL
            , PO_COMMUNICATION_PVT.GETFAX() BUYER_CONTACT_FAX
            , PVS.FAX VENDOR_FAX
            , PVS.SUPPLIER_NOTIF_METHOD SUPPLIER_NOTIF_METHOD
            , PVS.EMAIL_ADDRESS VENDOR_EMAIL
            , TO_CHAR(DECODE(PH.TYPE_LOOKUP_CODE,'STANDARD',PO_CORE_S.GET_TOTAL('H',PH.PO_HEADER_ID), NULL),
              PO_COMMUNICATION_PVT.GETFORMATMASK) TOTAL_AMOUNT
            , PO_COMMUNICATION_PVT.GETTERRITORYSHORTNAME() BUYER_COUNTRY
            , HL.ADDRESS4 VENDOR_ADDRESS_LINE4
            , PVS.AREA_CODE VENDOR_AREA_CODE
            , PVC.AREA_CODE VENDOR_CONTACT_AREA_CODE
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLegalEntityDetails(PH.ORG_ID)) LE_NAME
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLEAddressLine1()) LE_ADDR1
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLEAddressLine2()) LE_ADDR2
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLEAddressLine3()) LE_ADDR3
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLETownOrCity()) LE_TOWN_CITY
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLEStateOrProvince()) LE_STAE_PROVINCE
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLEPostalCode()) LE_POSTALCODE
            , DECODE(NVL(PH.ORG_ID,-1),-1, NULL, PO_COMMUNICATION_PVT.getLECountry()) LE_COUNTRY
            , DECODE(PH.CANCEL_FLAG, 'Y' , PO_COMMUNICATION_PVT.getPOCancelDate(PH.PO_HEADER_ID), NULL) CANCEL_DATE
            , PH.CHANGE_SUMMARY
            , PH.DOCUMENT_CREATION_METHOD
            , PH.ENCUMBRANCE_REQUIRED_FLAG
            , PSL.DISPLAY_NAME STYLE_DISPLAY_NAME
            , PVS.FAX_AREA_CODE VENDOR_FAX_AREA_CODE
          FROM FND_LOOKUP_VALUES PLC1
            , FND_LOOKUP_VALUES PLC2
            , FND_CURRENCIES_TL FCC
            , AP_SUPPLIERS VN
            , AP_SUPPLIER_SITES_ALL PVS
            , HZ_LOCATIONS HL
            , PO_VENDOR_CONTACTS PVC
            , PER_ALL_PEOPLE_F HRE
            , AP_TERMS T
            , PO_HEADERS_ALL PH
            , FND_TERRITORIES_TL FTE3
            , ORG_FREIGHT_TL OFC
            , PO_AGENTS PA
            , FND_LOOKUP_VALUES PLC3
            , PO_DOC_STYLE_LINES_TL PSL
            , FND_LOOKUP_VALUES PLC4
            , HR_LOOKUPS HRL
	     ,		(SELECT DISTINCT d.po_header_id,
			  DECODE(d.po_release_id,NULL,(NVL(p.last_name, p2.last_name)), p2.last_name) BUYER_LAST_NAME,
			  DECODE(d.po_release_id,NULL,(NVL(a.location_id, a2.location_id)), a2.location_id) buyer_location_id,
			  DECODE(d.po_release_id,NULL,(NVL(p.person_id, p2.person_id)), p2.person_id) buyer_agent_id,
			  h.attribute14 FAO
			FROM po_distributions_all d,
			  po_req_distributions_all r,
			  po_requisition_lines_all l,
			  po_lines_all pol,
			  po_requisition_headers_all h,
			  po_headers_all poh,
			  per_all_people_f p,
			  per_all_assignments_f a,
			  per_all_people_f p2,
			  per_all_assignments_f a2
			WHERE d.req_distribution_id = r.distribution_id (+)
			AND r.requisition_line_id   = l.requisition_line_id (+)
			AND l.requisition_header_id = h.requisition_header_id (+)
			AND pol.po_line_id          = d.po_line_id
			AND pol.line_num            = 1
			AND h.preparer_id           = p.person_id (+)
			AND d.po_release_id        IS NULL
			AND p.EMPLOYEE_NUMBER      IS NOT NULL
			AND p.person_id             = A.person_id
			AND p2.person_id            = a2.person_id
			AND TRUNC(SYSDATE) BETWEEN p.EFFECTIVE_START_DATE AND p.EFFECTIVE_END_DATE
			AND poh.po_header_id    = d.po_header_id
			AND poh.agent_id        = p2.person_id
			AND p2.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN P2.EFFECTIVE_START_DATE AND P2.EFFECTIVE_END_DATE
			UNION ALL
			SELECT poh.po_header_id,
			  p2.last_name,
			  a2.location_id,
			  p2.person_id,
			  NULL
			FROM po_headers_all poh,
			  per_all_people_f p2,
			  per_all_assignments_f a2
			WHERE poh.agent_id      = p2.person_id
			AND p2.EMPLOYEE_NUMBER IS NOT NULL
			AND TRUNC(SYSDATE) BETWEEN p2.EFFECTIVE_START_DATE AND p2.EFFECTIVE_END_DATE
			AND poh.TYPE_LOOKUP_CODE = 'BLANKET'
			AND p2.person_id         = a2.person_id
			) buyer
         WHERE HRL.LOOKUP_CODE(+)   = HRE.TITLE
          AND HRL.LOOKUP_TYPE(+)    ='TITLE'
          AND VN.VENDOR_ID(+)       = PH.VENDOR_ID
          AND PVS.VENDOR_SITE_ID(+) = PH.VENDOR_SITE_ID
          AND PVS.LOCATION_ID       = HL.LOCATION_ID(+)
          AND PH.VENDOR_CONTACT_ID  = PVC.VENDOR_CONTACT_ID(+)
          AND (PH.VENDOR_CONTACT_ID IS NULL
          OR PH.VENDOR_SITE_ID     =PVC.VENDOR_SITE_ID)
          AND HRE.PERSON_ID = PH.AGENT_ID
          AND TRUNC(SYSDATE) BETWEEN HRE.EFFECTIVE_START_DATE AND HRE.EFFECTIVE_END_DATE
          AND PH.TERMS_ID                                               = T.TERM_ID (+)
          AND PH.TYPE_LOOKUP_CODE                                      IN ('STANDARD','BLANKET','CONTRACT')
          AND FCC.CURRENCY_CODE                                         = PH.CURRENCY_CODE
          AND PLC1.LOOKUP_CODE (+)                                      = PH.FOB_LOOKUP_CODE
          AND PLC1.LOOKUP_TYPE (+)                                      = 'FOB'
          AND PLC1.LANGUAGE(+)                                          = USERENV('LANG')
          AND PLC1.VIEW_APPLICATION_ID(+)                               = 201
          AND DECODE(PLC1.LOOKUP_CODE, NULL, 1, PLC1.SECURITY_GROUP_ID) = DECODE(PLC1.LOOKUP_CODE, NULL, 1,
              FND_GLOBAL.LOOKUP_SECURITY_GROUP(PLC1.LOOKUP_TYPE, PLC1.VIEW_APPLICATION_ID) )
          AND PLC2.LOOKUP_CODE (+)                                     = PH.FREIGHT_TERMS_LOOKUP_CODE
          AND PLC2.LOOKUP_TYPE (+)                                     = 'FREIGHT TERMS'
          AND PLC2.LANGUAGE(+)                                         = USERENV('LANG')
          AND PLC2.VIEW_APPLICATION_ID(+)                              = 201
          AND DECODE(PLC2.LOOKUP_CODE, NULL, 1,PLC2.SECURITY_GROUP_ID) = DECODE(PLC2.LOOKUP_CODE, NULL, 1,
              FND_GLOBAL.LOOKUP_SECURITY_GROUP(PLC2.LOOKUP_TYPE, PLC2.VIEW_APPLICATION_ID))
          AND SUBSTR(HL.COUNTRY, 1, 25)                                 = FTE3.TERRITORY_CODE (+)
          AND DECODE(FTE3.TERRITORY_CODE, NULL, '1', FTE3.LANGUAGE)     = DECODE(FTE3.TERRITORY_CODE, NULL, '1', USERENV('LANG'))
          AND OFC.FREIGHT_CODE (+)                                      = PH.SHIP_VIA_LOOKUP_CODE
          AND OFC.ORGANIZATION_ID (+)                                   = PH.ORG_ID
          AND PA.AGENT_ID                                               = PH.AGENT_ID
          AND PLC3.LOOKUP_CODE (+)                                      = PH.SHIPPING_CONTROL
          AND PLC3.LOOKUP_TYPE (+)                                      = 'SHIPPING CONTROL'
          AND PLC3.LANGUAGE(+)                                          = USERENV('LANG')
          AND PLC3.VIEW_APPLICATION_ID(+)                               = 201
          AND DECODE(PLC3.LOOKUP_CODE, NULL, 1, PLC3.SECURITY_GROUP_ID) = DECODE(PLC3.LOOKUP_CODE, NULL, 1,
              FND_GLOBAL.LOOKUP_SECURITY_GROUP(PLC3.LOOKUP_TYPE, PLC3.VIEW_APPLICATION_ID))
          AND FCC.LANGUAGE                                              = USERENV('LANG')
          AND OFC.LANGUAGE(+)                                           = USERENV('LANG')
          AND PH.STYLE_ID                                               = PSL.STYLE_ID(+)
          AND PSL.LANGUAGE(+)                                           = USERENV('LANG')
          AND PSL.DOCUMENT_SUBTYPE(+)                                   = PH.TYPE_LOOKUP_CODE
          AND PLC4.LOOKUP_CODE (+)                                      = PVC.PREFIX
          AND PLC4.LOOKUP_TYPE (+)                                      = 'CONTACT_TITLE'
          AND PLC4.LANGUAGE(+)                                          = USERENV('LANG')
          AND PLC4.VIEW_APPLICATION_ID(+)                               = 222
          AND DECODE(PLC4.LOOKUP_CODE, NULL, 1, PLC4.SECURITY_GROUP_ID) = DECODE(PLC4.LOOKUP_CODE, NULL, 1,
              FND_GLOBAL.LOOKUP_SECURITY_GROUP(PLC4.LOOKUP_TYPE, PLC4.VIEW_APPLICATION_ID))
		  AND buyer.po_header_id (+)                                    = ph.po_header_id;