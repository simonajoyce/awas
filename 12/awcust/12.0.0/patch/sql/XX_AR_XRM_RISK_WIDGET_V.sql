--------------------------------------------------------
--  File created - Wednesday-June-22-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View XX_AR_XRM_RISK_WIDGET_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "APPS"."XX_AR_XRM_RISK_WIDGET_V" ("CUSTOMER_NAME", "CUSTOMER_NUMBER", "REPORT_TYPE", "CS_NOTES", "CS_ENTERED_DATE", "CS_CREATED_BY", "NS_NOTES", "NS_ENTERED_DATE", "NS_CREATED_BY", "STRATEGY", "RCP_ID", "STATEMENT_AVAIL_YN", "MONITORING_YN") AS 
  SELECT DISTINCT NVL(risk_counterparty, customer_name) customer_name
            , MAX(oracle_customer_id) customer_number
            , MAX(report_type) report_type
            , cs_notes
            , cs_entered_date
            , cs_Created_by
            , ns_notes
            , ns_entered_date
            , ns_created_by
            , strategy
            , rcp_id
            , STATEMENT_AVAIL_YN
            , MONITORING_YN
          FROM
              (
SELECT c.customer_name
                          , c.customer_number
                          , p.account_status_meaning REPORT_TYPE
                          , nvl2(p.account_status_meaning,cs.notes,case when cs.entered_date > sysdate - 7 then cs.notes else null end) cs_notes
                          , nvl2(p.account_status_meaning,cs.entered_date,case when cs.entered_date > sysdate - 7 then cs.entered_date else null end) cs_entered_date
                          , nvl2(p.account_status_meaning,cs.created_by_name,case when cs.entered_date > sysdate - 7 then cs.created_by_name else null end) cs_created_by
                          , nvl2(p.account_status_meaning,ns.notes,case when ns.entered_date > sysdate - 7 then ns.notes else null end) ns_notes
                          , nvl2(p.account_status_meaning,ns.entered_date,case when ns.entered_date > sysdate - 7 then ns.entered_date else null end) ns_entered_date
                          , nvl2(p.account_status_meaning,ns.created_by_name,case when ns.entered_date > sysdate - 7 then ns.created_by_name else null end) ns_created_by
                          , NULL STRATEGY
                          , NVL(xrm.rcp_id,xrm.lessee_id) rcp_id
                          , NVL(xrm.risk_counterparty,xrm.lessee) risk_counterparty
                          , xrm.oracle_customer_id
                          , decode(count(d.status),0,'N','Y') STATEMENT_AVAIL_YN
                          , decode(p.account_status_meaning,'Watchlist','Y','Key Debtor','Y',null,decode(SUM(DECODE(d.status,'CURRENT',0,NULL,0,1)),0,'N','Y'),'N') MONITORING_YN 
                        FROM ar_customers c
                          , AR_CUSTOMER_PROFILEs_v p
                          , iex_delinquencies_all d
                          , (
                                   SELECT DISTINCT n.source_object_id
                                        , notes
                                        , entered_date
                                        , created_by_name
                                      FROM AST_NOTES_DETAILS_vl n
                                     WHERE n.source_object_code = 'IEX_ACCOUNT'
                                      AND n.NOTE_TYPE           = 'AWAS_CUST2'
                                      AND jtf_note_id          IN
                                          (
                                                  SELECT MAX(jtf_note_id)
                                                    FROM AST_NOTES_DETAILS_vl v
                                                   WHERE v.source_object_code = 'IEX_ACCOUNT'
                                                    AND v.NOTE_TYPE           = 'AWAS_CUST2'
                                                GROUP BY source_object_id
                                          )
                            )
                            cs
                          , (
                                   SELECT DISTINCT n.source_object_id
                                        , notes
                                        , entered_date
                                        , created_by_name
                                      FROM AST_NOTES_DETAILS_vl n
                                     WHERE n.source_object_code = 'IEX_ACCOUNT'
                                      AND n.NOTE_TYPE           = 'AWAS_CUST3'
                                      AND jtf_note_id          IN
                                          (
                                                  SELECT MAX(jtf_note_id)
                                                    FROM AST_NOTES_DETAILS_vl v
                                                   WHERE v.source_object_code = 'IEX_ACCOUNT'
                                                    AND v.NOTE_TYPE           = 'AWAS_CUST3'
                                                GROUP BY source_object_id
                                          )
                            )
                            ns
                          ,(
                                    SELECT CMH.contract_id
                                          ||'-'
                                          ||map1.ora_fin_code contract_id
                                        , cmh.contract_id lease_number
                                        , map1.ora_fin_code oracle_customer_id
                                        , fngetmsn@basin(CMH.aircraft_no) AS MSN
                                        , ORG1.ORG_NAME                   AS LESSEE
                                        , ORG3.ORG_NAME                   AS RISK_COUNTERPARTY
                                        , org3.org_id RCP_ID
                                        , org1.org_id LESSEE_ID
                                      FROM tblCMCOntractHeader@basin CMH
                                   LEFT OUTER JOIN tblCMLEase@basin CML
                                        ON cmh.contract_id = cml.contract_id
                                   LEFT OUTER JOIN tblCMRisk@basin CMR
                                        ON cmh.contract_id = cmr.contract_id
                                   LEFT OUTER JOIN TBLORGANISATION@basin ORG1
                                        ON CML.LESSEE_ORG_ID = ORG1.ORG_ID
                                   LEFT OUTER JOIN tblOraFinGLMapping@basin map1
                                        ON org1.org_id = map1.als_code
                                   LEFT OUTER JOIN TBLORGANISATION@basin ORG2
                                        ON cmr.guarantor_org_id = ORG2.ORG_ID
                                   LEFT OUTER JOIN TBLORGANISATION@basin ORG3
                                        ON cmr.risk_counterparty_org_id               = ORG3.ORG_ID
                                     WHERE NVL(map1.MAP_TYPE_DESC,'AWAS_GL_CUSTOMER') = 'AWAS_GL_CUSTOMER'
                            )
                            xrm
                       WHERE c.customer_id    = ns.source_object_id (+)
                        AND c.customer_id     = cs.source_object_id (+)
                        AND c.customer_id     = p.customer_id
                        AND p.site_use_id    IS NULL
                        AND c.customer_id     = D.CUST_ACCOUNT_ID (+)
                        AND c.customer_number = xrm.oracle_customer_id (+)
                            --HAVING SUM(DECODE(d.status,'CURRENT',0,NULL,0,1)) > 0
                    GROUP BY c.customer_name
                          , c.customer_number
                          , p.account_status_meaning
                          , nvl2(p.account_status_meaning,cs.notes,case when cs.entered_date > sysdate - 7 then cs.notes else null end)
                          , nvl2(p.account_status_meaning,cs.entered_date,case when cs.entered_date > sysdate - 7 then cs.entered_date else null end)
                          , nvl2(p.account_status_meaning,cs.created_by_name,case when cs.entered_date > sysdate - 7 then cs.created_by_name else null end)
                          , nvl2(p.account_status_meaning,ns.notes,case when ns.entered_date > sysdate - 7 then ns.notes else null end) 
                          , nvl2(p.account_status_meaning,ns.entered_date,case when ns.entered_date > sysdate - 7 then ns.entered_date else null end) 
                          , nvl2(p.account_status_meaning,ns.created_by_name,case when ns.entered_date > sysdate - 7 then ns.created_by_name else null end) 
                          , NVL(xrm.rcp_id,xrm.lessee_id)
                          , NVL(xrm.risk_counterparty,xrm.lessee)
                          , xrm.oracle_customer_id
                       UNION
                      SELECT c.customer_name
                          , c.customer_number
                          , p.account_status_meaning REPORT_TYPE
                          , nvl2(p.account_status_meaning,cs.notes,case when cs.entered_date > sysdate - 7 then cs.notes else null end) cs_notes
                          , nvl2(p.account_status_meaning,cs.entered_date,case when cs.entered_date > sysdate - 7 then cs.entered_date else null end) cs_entered_date
                          , nvl2(p.account_status_meaning,cs.created_by_name,case when cs.entered_date > sysdate - 7 then cs.created_by_name else null end) cs_created_by
                          , nvl2(p.account_status_meaning,ns.notes,case when ns.entered_date > sysdate - 7 then ns.notes else null end) ns_notes
                          , nvl2(p.account_status_meaning,ns.entered_date,case when ns.entered_date > sysdate - 7 then ns.entered_date else null end) ns_entered_date
                          , nvl2(p.account_status_meaning,ns.created_by_name,case when ns.entered_date > sysdate - 7 then ns.created_by_name else null end) ns_created_by
                          , NULL STRATEGY
                          , NVL(xrm.rcp_id,xrm.lessee_id) rcp_id
                          , NVL(xrm.risk_counterparty,xrm.lessee) risk_counterparty
                          , xrm.oracle_customer_id
                          , decode(count(d.status),0,'N','Y') STATEMENT_AVAIL_YN
                          , decode(p.account_status_meaning,'Watchlist','Y','Key Debtor','Y',null,decode(SUM(DECODE(d.status,'CURRENT',0,NULL,0,1)),0,'N','Y'),'N') MONITORING_YN 
                        FROM ar_customers c
                          , AR_CUSTOMER_PROFILEs_v p
                          , iex_delinquencies_all d
                          , (
                                   SELECT DISTINCT n.source_object_id
                                        , notes
                                        , entered_date
                                        , created_by_name
                                      FROM AST_NOTES_DETAILS_vl n
                                     WHERE n.source_object_code = 'IEX_ACCOUNT'
                                      AND n.NOTE_TYPE           = 'AWAS_CUST2'
                                      AND jtf_note_id          IN
                                          (
                                                  SELECT MAX(jtf_note_id)
                                                    FROM AST_NOTES_DETAILS_vl v
                                                   WHERE v.source_object_code = 'IEX_ACCOUNT'
                                                    AND v.NOTE_TYPE           = 'AWAS_CUST2'
                                                GROUP BY source_object_id
                                          )
                            )
                            cs
                          , (
                                   SELECT DISTINCT n.source_object_id
                                        , notes
                                        , entered_date
                                        , created_by_name
                                      FROM AST_NOTES_DETAILS_vl n
                                     WHERE n.source_object_code = 'IEX_ACCOUNT'
                                      AND n.NOTE_TYPE           = 'AWAS_CUST3'
                                      AND jtf_note_id          IN
                                          (
                                                  SELECT MAX(jtf_note_id)
                                                    FROM AST_NOTES_DETAILS_vl v
                                                   WHERE v.source_object_code = 'IEX_ACCOUNT'
                                                    AND v.NOTE_TYPE           = 'AWAS_CUST3'
                                                GROUP BY source_object_id
                                          )
                            )
                            ns
                          ,(
                                    SELECT CMH.contract_id
                                          ||'-'
                                          ||map1.ora_fin_code contract_id
                                        , cmh.contract_id lease_number
                                        , map1.ora_fin_code oracle_customer_id
                                        , fngetmsn@basin(CMH.aircraft_no) AS MSN
                                        , ORG1.ORG_NAME                   AS LESSEE
                                        , ORG3.ORG_NAME                   AS RISK_COUNTERPARTY
                                        , org3.org_id RCP_ID
                                        , org1.org_id LESSEE_ID
                                      FROM tblCMCOntractHeader@basin CMH
                                   LEFT OUTER JOIN tblCMLEase@basin CML
                                        ON cmh.contract_id = cml.contract_id
                                   LEFT OUTER JOIN tblCMRisk@basin CMR
                                        ON cmh.contract_id = cmr.contract_id
                                   LEFT OUTER JOIN TBLORGANISATION@basin ORG1
                                        ON CML.LESSEE_ORG_ID = ORG1.ORG_ID
                                   LEFT OUTER JOIN tblOraFinGLMapping@basin map1
                                        ON org1.org_id = map1.als_code
                                   LEFT OUTER JOIN TBLORGANISATION@basin ORG2
                                        ON cmr.guarantor_org_id = ORG2.ORG_ID
                                   LEFT OUTER JOIN TBLORGANISATION@basin ORG3
                                        ON cmr.risk_counterparty_org_id               = ORG3.ORG_ID
                                     WHERE NVL(map1.MAP_TYPE_DESC,'AWAS_GL_CUSTOMER') = 'AWAS_GL_CUSTOMER'
                            )
                            xrm
                       WHERE c.customer_id            = ns.source_object_id (+)
                        AND c.customer_id             = cs.source_object_id (+)
                        AND c.customer_id             = p.customer_id
                        AND p.site_use_id            IS NULL
                        AND c.customer_id             = D.CUST_ACCOUNT_ID (+)
                        AND p.account_status_meaning IN ('Watchlist','Key Debtor')
                        AND c.customer_number         = xrm.oracle_customer_id (+)
                        group by c.customer_name
                          , c.customer_number
                          , p.account_status_meaning
                          , nvl2(p.account_status_meaning,cs.notes,case when cs.entered_date > sysdate - 7 then cs.notes else null end)
                          , nvl2(p.account_status_meaning,cs.entered_date,case when cs.entered_date > sysdate - 7 then cs.entered_date else null end)
                          , nvl2(p.account_status_meaning,cs.created_by_name,case when cs.entered_date > sysdate - 7 then cs.created_by_name else null end)
                          , nvl2(p.account_status_meaning,ns.notes,case when ns.entered_date > sysdate - 7 then ns.notes else null end) 
                          , nvl2(p.account_status_meaning,ns.entered_date,case when ns.entered_date > sysdate - 7 then ns.entered_date else null end) 
                          , nvl2(p.account_status_meaning,ns.created_by_name,case when ns.entered_date > sysdate - 7 then ns.created_by_name else null end)                           , NVL(xrm.rcp_id,xrm.lessee_id)
                          , NVL(xrm.risk_counterparty,xrm.lessee)
                          , xrm.oracle_customer_id
                          )
      GROUP BY NVL(risk_counterparty, customer_name)
            , cs_notes
            , cs_entered_date
            , cs_Created_by
            , ns_notes
            , ns_entered_date
            , ns_created_by
            , strategy
            , rcp_id
            , STATEMENT_AVAIL_YN
            , MONITORING_YN;
