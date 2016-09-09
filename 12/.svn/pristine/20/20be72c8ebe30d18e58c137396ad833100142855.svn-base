CREATE OR REPLACE PACKAGE XX_PA_BUDGET_WF
AS
       PROCEDURE PA_BUDGET_LINES(
                     p_budget_version_id IN NUMBER ,
                     display_type        IN VARCHAR2 DEFAULT 'text/html',
                     document            IN OUT NOCOPY VARCHAR2,
                     document_type       IN OUT nocopy VARCHAR2);
       
       PROCEDURE CREATE_ACCOUNTING(
                     itemtype IN VARCHAR2 ,
                     itemkey  IN VARCHAR2 ,
                     actid    IN NUMBER ,
                     FUNCMODE IN VARCHAR2 ,
                     RESULTOUT OUT NOCOPY VARCHAR2 );
       
       PROCEDURE PA_ACCOUNTING_LINES(
                     p_budget_version_id IN NUMBER ,
                     display_type        IN VARCHAR2 DEFAULT 'text/html',
                     document            IN OUT NOCOPY VARCHAR2,
                     DOCUMENT_TYPE       IN OUT NOCOPY VARCHAR2);
       
       PROCEDURE VERSION_NAME_CHK(
                     itemtype IN VARCHAR2 ,
                     itemkey  IN VARCHAR2 ,
                     actid    IN NUMBER ,
                     FUNCMODE IN VARCHAR2 ,
                     RESULTOUT OUT NOCOPY VARCHAR2 );
       
       PROCEDURE TAM_PROJECT(
                     itemtype IN VARCHAR2 ,
                     itemkey  IN VARCHAR2 ,
                     actid    IN NUMBER ,
                     FUNCMODE IN VARCHAR2 ,
                     RESULTOUT OUT NOCOPY VARCHAR2 );
       
       PROCEDURE VERSION_NAME_CHG(
                     itemtype IN VARCHAR2 ,
                     itemkey  IN VARCHAR2 ,
                     actid    IN NUMBER ,
                     FUNCMODE IN VARCHAR2 ,
                     RESULTOUT OUT NOCOPY VARCHAR2 );
       
       G_DEBUG_MODE BOOLEAN DEFAULT false;
       
       L_REQUEST_ID NUMBER DEFAULT 0;
       
END XX_PA_BUDGET_WF;
/


CREATE OR REPLACE PACKAGE BODY XX_PA_BUDGET_WF
AS
/********************************************************************************
  PACKAGE NAME  : XX_PA_BUDGET_WF
  CREATED BY    : Simon Joyce
  DATE CREATED  : 12-Jul-2013
  --
  PURPOSE       : PL/SQL Package to support custom PA Budget WF process
  --
  MODIFICATION HISTORY
  --------------------
  --
  DATE       WHO?       DETAILS                              DESCRIPTION
  ---------- ---------  -----------------------------------  -----------------------
  12-Jul-2013 SJOYCE    First Version
  ********************************************************************************/
       G_API_VERSION_NUMBER CONSTANT NUMBER := 1.0;
       
PROCEDURE submit_conc_request(
                     p_application IN VARCHAR2,
                     p_program     IN VARCHAR2,
                     p_sub_request IN BOOLEAN,
                     p_parameter1  IN VARCHAR2,
                     p_parameter2  IN VARCHAR2,
                     p_parameter3  IN VARCHAR2,
                     p_parameter4  IN VARCHAR2,
                     p_parameter5  IN VARCHAR2,
                     p_parameter6  IN VARCHAR2,
                     p_parameter7  IN VARCHAR2,
                     p_parameter8  IN VARCHAR2,
                     p_parameter9  IN VARCHAR2,
                     p_parameter10 IN VARCHAR2,
                     p_parameter11 IN VARCHAR2,
                     P_PARAMETER12 IN VARCHAR2,
                     P_PARAMETER13 IN VARCHAR2,
                     P_PARAMETER14 IN VARCHAR2,
                     P_PARAMETER15 IN VARCHAR2,
                     p_parameter16 IN VARCHAR2,
                     x_request_id OUT NUMBER ) ;
                     
/*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request(
                            p_request_id  IN NUMBER,
                            p_description IN VARCHAR2,
                            X_PHASE OUT VARCHAR2,
                            x_code OUT VARCHAR2 ) ;

/*-- Procedure to debug messages to log file*/
PROCEDURE write_debug(
                                   P_MESSAGE IN VARCHAR2 ) ;

TYPE BUDGET_LINES_RECORD
IS
       RECORD
       (
              grouping VARCHAR2(30),
              expenditure_type pa_resource_assignments.expenditure_type%type,
              OLD         NUMBER,
              NEW         NUMBER,
              VARIANCE    NUMBER,
              ACTUALS     NUMBER,
              COMMITMENTS NUMBER,
              total_costs NUMBER );

TYPE NON_TAM_LINES_RECORD
IS
       RECORD
       (
              task_name VARCHAR2(30),
              expenditure_type pa_resource_assignments.expenditure_type%type,
              OLD         NUMBER,
              NEW         NUMBER,
              VARIANCE    NUMBER,
              ACTUALS     NUMBER,
              COMMITMENTS NUMBER,
              total_costs NUMBER );

TYPE GL_LINES_RECORD
IS
       RECORD
       (
              DESCRIPTION VARCHAR2(150),
              SEGMENT1    VARCHAR2(30),
              SEGMENT2    VARCHAR2(30),
              SEGMENT3    VARCHAR2(30),
              SEGMENT4    VARCHAR2(30),
              SEGMENT5    VARCHAR2(30),
              SEGMENT6    VARCHAR2(30),
              SEGMENT7    VARCHAR2(30),
              DR          VARCHAR2(30),
              CR          VARCHAR2(30) );

TYPE SUM_RECORD
IS
       RECORD
       (
              EXPENDITURE_TYPE PA_RESOURCE_ASSIGNMENTS.EXPENDITURE_TYPE%type,
              PREVIOUS NUMBER,
              THIS     NUMBER );

PROCEDURE TAM_PROJECT(
              itemtype IN VARCHAR2 ,
              itemkey  IN VARCHAR2 ,
              actid    IN NUMBER ,
              FUNCMODE IN VARCHAR2 ,
              RESULTOUT OUT NOCOPY VARCHAR2 )
AS
       L_PROJECT_ID NUMBER;
       L_project_type pa_projects_all.project_type%type;
       L_CHK_RESULT VARCHAR2 (50);
BEGIN
       L_PROJECT_ID := WF_ENGINE.GETITEMATTRNUMBER( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'PROJECT_ID' ) ;
        SELECT project_type
          INTO L_project_type
          FROM PA_PROJECTS_ALL
         WHERE project_ID   = L_project_ID;
       IF L_Project_type    = 'IS PROJECT TYPE' THEN
              L_CHK_RESULT := wf_engine.eng_completed||':'||'F';
       ELSE
              L_CHK_RESULT := wf_engine.eng_completed||':'||'T';
       END IF;
       resultout := L_CHK_RESULT;
END TAM_PROJECT;
       
PROCEDURE VERSION_NAME_CHK(
              itemtype IN VARCHAR2 ,
              itemkey  IN VARCHAR2 ,
              actid    IN NUMBER ,
              FUNCMODE IN VARCHAR2 ,
              RESULTOUT OUT NOCOPY VARCHAR2 )
AS
       L_VERSION_NAME      VARCHAR2(60);
       L_BUDGET_VERSION_ID NUMBER;
       L_PERIOD            VARCHAR2(10);
       L_CHK_RESULT        VARCHAR2 (50);
BEGIN
       L_BUDGET_VERSION_ID := WF_ENGINE.GETITEMATTRNUMBER( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'DRAFT_VERSION_ID' )
       ;
        SELECT UPPER(VERSION_NAME)
          INTO L_VERSION_NAME
          FROM PA_BUDGET_VERSIONS
         WHERE BUDGET_VERSION_ID = L_BUDGET_VERSION_ID;
       BEGIN
               SELECT PERIOD_NAME
                 INTO L_PERIOD
                 FROM GL_PERIODS
                WHERE PERIOD_SET_NAME = 'AWAS'
                 AND period_name      = l_Version_name;
       EXCEPTION
       WHEN OTHERS THEN
              L_CHK_RESULT := wf_engine.eng_completed||':'||'F';
       END;
       IF L_PERIOD         IS NOT NULL THEN
              L_CHK_RESULT := wf_engine.eng_completed||':'||'T';
       END IF;
       resultout := L_CHK_RESULT;
END VERSION_NAME_CHK;

PROCEDURE VERSION_NAME_CHG(
              itemtype IN VARCHAR2 ,
              itemkey  IN VARCHAR2 ,
              actid    IN NUMBER ,
              FUNCMODE IN VARCHAR2 ,
              RESULTOUT OUT NOCOPY VARCHAR2 )
AS
       L_VERSION_NAME      VARCHAR2(6);
       L_BUDGET_VERSION_ID NUMBER;
BEGIN
       L_VERSION_NAME      := WF_ENGINE.GETITEMATTRTEXT( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'NEW_VERSION_NAME' ) ;
       L_BUDGET_VERSION_ID := WF_ENGINE.GETITEMATTRNUMBER( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'DRAFT_VERSION_ID' )
       ;
       dbms_output.put_line('L_VERSION_NAME:'||L_VERSION_NAME);
        UPDATE PA_BUDGET_VERSIONS
       SET VERSION_NAME          = UPPER(L_VERSION_NAME)
         WHERE BUDGET_VERSION_ID = L_BUDGET_VERSION_ID;
       DBMS_OUTPUT.PUT_LINE('L_BUDGET_VERSION_ID:'||L_BUDGET_VERSION_ID);
       DBMS_OUTPUT.PUT_LINE('Records updated'||sql%ROWCOUNT);
END VERSION_NAME_CHG;

PROCEDURE PA_BUDGET_LINES(
              p_budget_version_id IN NUMBER ,
              display_type        IN VARCHAR2 DEFAULT 'text/html',
              document            IN OUT NOCOPY VARCHAR2,
              document_type       IN OUT nocopy VARCHAR2)
AS
       L_LINE BUDGET_LINES_RECORD;
       L_nt_line NON_TAM_LINES_RECORD;
       L_sum_line sum_record;
       l_document          VARCHAR2(32000) := '';
       L_BUDGET_VERSION_ID NUMBER;
       l_version_name      VARCHAR2(100);
       l_project_id        NUMBER;
       l_project_type pa_projects_all.project_Type%type;
       NL            VARCHAR2(1) := fnd_global.newline;
       I             NUMBER      := 0;
       max_lines_dsp NUMBER      := 20;
       line_mesg     VARCHAR2(240);
       curr_len      NUMBER := 0;
       prior_len     NUMBER := 0;
       CURSOR non_tam_bud_lines (v_budget_Version_id NUMBER )
       IS
               SELECT x.task_name
                   ,x.EXPENDITURE_TYPE
                   , SUM(DECODE(VERS,'OLD',NVL(RAW_COST,0),0)) OLD
                   , SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) NEW
                   , SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM(DECODE(VERS,'OLD',NVL(RAW_COST,0),0)) VARIANCE
                   , SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) ACTUALS
                   , SUM(DECODE(VERS,'Commitments',NVL(RAW_COST,0),0)) COMMITMENTS
                   , SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) + SUM(DECODE(VERS,'Commitments',NVL(RAW_COST,0),0)) TOTAL_COST
                 FROM
                     (
                             SELECT 'NEW' vers
                                 , t.task_name
                                 , r.expenditure_type
                                 , l.raw_cost
                               FROM pa_budget_versions v
                                 , pa_resource_assignments r
                                 , PA_BUDGET_LINES L
                                 , pa_tasks t
                              WHERE V.BUDGET_VERSION_ID         = V_BUDGET_VERSION_ID
                               AND r.budget_version_id (+)      = v.budget_version_id
                               AND l.resource_assignment_id (+) = r.resource_assignment_id
                               AND r.task_id                    = t.task_id (+)
                   UNION ALL
                      SELECT 'OLD'
                          , t.task_name
                          , r.expenditure_type
                          , l.raw_cost
                        FROM pa_budget_versions v
                          , pa_resource_assignments r
                          , pa_budget_lines l
                          , pa_tasks t
                       WHERE V.BUDGET_VERSION_ID =
                            (
                                    SELECT MAX(Y.BUDGET_VERSION_ID)
                                      FROM PA_BUDGET_VERSIONS Y
                                        , PA_BUDGET_VERSIONS Z
                                     WHERE Z.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                                      AND y.project_id         = z.project_id
                                      AND y.fin_plan_type_id   = z.fin_plan_type_id
                                      AND y.budget_status_Code = 'B'
                            )
                        AND r.budget_version_id (+)      = v.budget_version_id
                        AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                        AND r.task_id                    = t.task_id (+)
                   UNION ALL
                      SELECT 'Actuals'
                          , t.task_name
                          , EI.EXPENDITURE_TYPE EXPENDITURE_TYPE
                          , ROUND(SUM(EI.RAW_COST),2) AMOUNT
                        FROM PA_EXPENDITURE_ITEMS_ALL EI
                          , PA_BUDGET_VERSIONS V
                          , pa_tasks t
                       WHERE V.PROJECT_ID       = EI.PROJECT_ID
                        AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                        AND ei.task_id          = t.task_id (+)
                    GROUP BY v.PROJECT_ID
                          , t.task_name
                          ,EI.EXPENDITURE_TYPE
                   UNION ALL
                      SELECT 'Commitments'
                          , t.task_name
                          , C.EXPENDITURE_TYPE CMT_EXP_TYPE
                          , ROUND(SUM(C.TOT_CMT_RAW_COST),2) CMT_RAW_COST
                        FROM PA_COMMITMENT_TXNS C
                          , PA_BUDGET_VERSIONS V
                          , pa_tasks t
                       WHERE V.PROJECT_ID       = C.PROJECT_ID
                        AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                        AND c.task_id           = t.task_id (+)
                    GROUP BY v.PROJECT_ID
                          ,t.task_name
                          , EXPENDITURE_TYPE
                     )
                     X
             GROUP BY x.task_name
                   , X.EXPENDITURE_TYPE
             ORDER BY x.task_name
                   , x.expenditure_type;
              CURSOR budget_line_cur (v_budget_version_id NUMBER)
              IS
                      SELECT y.grouping
                          , x.EXPENDITURE_TYPE
                          , SUM(DECODE(VERS,'OLD',NVL(RAW_COST,0),0)) OLD
                          , SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) NEW
                          , SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM(DECODE(VERS,'OLD',NVL(RAW_COST,0),0)) VARIANCE
                          , SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) ACTUALS
                          , SUM(DECODE(VERS,'Commitments',NVL(RAW_COST,0),0)) COMMITMENTS
                          , SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) + SUM(DECODE(VERS,'Commitments',NVL(RAW_COST,0),0) )
                            TOTAL_COST
                        FROM
                            (
                                    SELECT 'NEW' vers
                                        , r.expenditure_type
                                        , l.raw_cost
                                      FROM pa_budget_versions v
                                        , pa_resource_assignments r
                                        , PA_BUDGET_LINES L
                                     WHERE V.BUDGET_VERSION_ID         = V_BUDGET_VERSION_ID
                                      AND r.budget_version_id (+)      = v.budget_version_id
                                      AND l.resource_assignment_id (+) = r.resource_assignment_id
                          UNION ALL
                             SELECT 'OLD'
                                 , r.expenditure_type
                                 , l.raw_cost
                               FROM pa_budget_versions v
                                 , pa_resource_assignments r
                                 , pa_budget_lines l
                              WHERE V.BUDGET_VERSION_ID =
                                   (
                                           SELECT MAX(Y.BUDGET_VERSION_ID)
                                             FROM PA_BUDGET_VERSIONS Y
                                               , PA_BUDGET_VERSIONS Z
                                            WHERE Z.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                                             AND y.project_id         = z.project_id
                                             AND y.fin_plan_type_id   = z.fin_plan_type_id
                                             AND y.budget_status_Code = 'B'
                                   )
                               AND r.budget_version_id (+)      = v.budget_version_id
                               AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                          UNION ALL
                             SELECT 'Actuals'
                                 ,EI.EXPENDITURE_TYPE EXPENDITURE_TYPE
                                 , ROUND(SUM(EI.RAW_COST),2) AMOUNT
                               FROM PA_EXPENDITURE_ITEMS_ALL EI
                                 , PA_BUDGET_VERSIONS V
                              WHERE V.PROJECT_ID       = EI.PROJECT_ID
                               AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                           GROUP BY v.PROJECT_ID
                                 , EI.EXPENDITURE_TYPE
                          UNION ALL
                             SELECT 'Commitments'
                                 , C.EXPENDITURE_TYPE CMT_EXP_TYPE
                                 , ROUND(SUM(C.TOT_CMT_RAW_COST),2) CMT_RAW_COST
                               FROM PA_COMMITMENT_TXNS C
                                 , PA_BUDGET_VERSIONS V
                              WHERE V.PROJECT_ID       = C.PROJECT_ID
                               AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                           GROUP BY v.PROJECT_ID
                                 , EXPENDITURE_TYPE
                            )
                            X
                          , (
                                    SELECT segment_value_lookup exp_type
                                        , DECODE(segment_value,'000000','Accrual','Non Accrual') grouping
                                      FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                     WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                            )
                            Y
                       WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                        AND expenditure_type   <> 'Security Deposits/Credits'
                    GROUP BY Y.grouping
                          ,X.EXPENDITURE_TYPE
                     HAVING Y.grouping = 'Accrual'
                    ORDER BY y.grouping
                          , x.expenditure_type ;
                     CURSOR BUDGET_LINE_CUR2 (V_BUDGET_VERSION_ID NUMBER)
                     IS
                             SELECT Y.grouping
                                 , DECODE(X.EXPENDITURE_TYPE,'Security Deposits/Credits','Less Security Deposits/Credits',
                                   X.EXPENDITURE_TYPE) EXPENDITURE_TYPE
                                 , SUM(DECODE(VERS,'OLD',NVL(RAW_COST,0),0)) *-1 OLD
                                 , SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) *-1 NEW
                                 , (SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))*-1)-(SUM(DECODE(VERS,'OLD',NVL(RAW_COST,0),0)) *-1)
                                   VARIANCE
                                 , SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) ACTUALS
                                 , SUM(DECODE(VERS,'Commitments',NVL(RAW_COST,0),0)) COMMITMENTS
                                 , SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) + SUM(DECODE(VERS,'Commitments',NVL( RAW_COST,0),0
                                   )) TOTAL_COST
                               FROM
                                   (
                                           SELECT 'NEW' vers
                                               , r.expenditure_type
                                               , l.raw_cost
                                             FROM pa_budget_versions v
                                               , pa_resource_assignments r
                                               , PA_BUDGET_LINES L
                                            WHERE V.BUDGET_VERSION_ID         = V_BUDGET_VERSION_ID
                                             AND r.budget_version_id (+)      = v.budget_version_id
                                             AND l.resource_assignment_id (+) = r.resource_assignment_id
                                 UNION ALL
                                    SELECT 'OLD'
                                        , r.expenditure_type
                                        , l.raw_cost
                                      FROM pa_budget_versions v
                                        , pa_resource_assignments r
                                        , pa_budget_lines l
                                     WHERE V.BUDGET_VERSION_ID =
                                          (
                                                  SELECT MAX(Y.BUDGET_VERSION_ID)
                                                    FROM PA_BUDGET_VERSIONS Y
                                                      , PA_BUDGET_VERSIONS Z
                                                   WHERE Z.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                                                    AND y.project_id         = z.project_id
                                                    AND y.fin_plan_type_id   = z.fin_plan_type_id
                                                    AND y.budget_status_Code = 'B'
                                          )
                                      AND r.budget_version_id (+)      = v.budget_version_id
                                      AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                                 UNION ALL
                                    SELECT 'Actuals'
                                        ,EI.EXPENDITURE_TYPE EXPENDITURE_TYPE
                                        , ROUND(SUM(EI.RAW_COST),2) AMOUNT
                                      FROM PA_EXPENDITURE_ITEMS_ALL EI
                                        , PA_BUDGET_VERSIONS V
                                     WHERE V.PROJECT_ID       = EI.PROJECT_ID
                                      AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                                  GROUP BY v.PROJECT_ID
                                        , EI.EXPENDITURE_TYPE
                                 UNION ALL
                                    SELECT 'Commitments'
                                        , C.EXPENDITURE_TYPE CMT_EXP_TYPE
                                        , ROUND(SUM(C.TOT_CMT_RAW_COST),2) CMT_RAW_COST
                                      FROM PA_COMMITMENT_TXNS C
                                        , PA_BUDGET_VERSIONS V
                                     WHERE V.PROJECT_ID       = C.PROJECT_ID
                                      AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                                  GROUP BY v.PROJECT_ID
                                        , EXPENDITURE_TYPE
                                   )
                                   X
                                 , (
                                           SELECT segment_value_lookup exp_type
                                               , DECODE(segment_value,'000000','Accrual','Non Accrual') grouping
                                             FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                            WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                                   )
                                   Y
                              WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                               AND EXPENDITURE_TYPE   IN ('Security Deposits/Credits','TAM Operational Revenue')
                           GROUP BY Y.grouping
                                 ,X.EXPENDITURE_TYPE
                           ORDER BY y.grouping
                                 , x.expenditure_type;
                            CURSOR SUMMARY1 (V_BUDGET_VERSION_ID NUMBER)
                            IS
                                    SELECT expenditure_Type
                                        , SUM(DECODE(period_name,version_name,0,raw_cost)) previous
                                        , SUM(DECODE(period_name,version_name,raw_cost,0)) This
                                      FROM
                                          (
                                                  SELECT r.expenditure_type
                                                      , l.raw_cost
                                                      , upper(L.PERIOD_NAME)period_name
                                                      , upper(v.version_name) version_name
                                                    FROM pa_budget_versions v
                                                      , pa_resource_assignments r
                                                      , PA_BUDGET_LINES L
                                                   WHERE V.BUDGET_VERSION_ID         = V_BUDGET_VERSION_ID
                                                    AND R.BUDGET_VERSION_ID (+)      = V.BUDGET_VERSION_ID
                                                    AND l.resource_assignment_id (+) = r.resource_assignment_id
                                          )
                           GROUP BY EXPENDITURE_TYPE
                           ORDER BY 1;
                            old_total         NUMBER;
                            new_total         NUMBER;
                            VARIANCE_TOTAL    NUMBER;
                            COST_TOTAL        NUMBER;
                            COMMITMENT_TOTAL  NUMBER;
                            total_total       NUMBER;
                            OLD_TOTAL2        NUMBER;
                            NEW_TOTAL2        NUMBER;
                            VARIANCE_TOTAL2   NUMBER;
                            COST_TOTAL2       NUMBER;
                            COMMITMENT_TOTAL2 NUMBER;
                            TOTAL_TOTAL2      NUMBER;
                            l_period_name pa_budget_versions.version_name%type;
                            AS_ACC_REQ NUMBER;
                            AS_SEC_DEP NUMBER;
                            AS_OP_REV  NUMBER;
                     BEGIN
                            L_BUDGET_VERSION_ID := P_BUDGET_VERSION_ID;
                             SELECT VERSION_NAME
                                 , PROJECT_ID
                               INTO L_VERSION_NAME
                                 , L_PROJECT_ID
                               FROM PA_BUDGET_VERSIONS V
                              WHERE V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID;
                             SELECT project_type
                               INTO L_project_type
                               FROM PA_PROJECTS_ALL
                              WHERE project_ID = L_project_ID;
                            max_lines_dsp     := 50;
                            old_total         :=0;
                            new_total         :=0;
                            VARIANCE_TOTAL    :=0;
                            COST_TOTAL        :=0;
                            COMMITMENT_TOTAL  :=0;
                            total_total       :=0;
                            OLD_TOTAL2        :=0;
                            NEW_TOTAL2        :=0;
                            VARIANCE_TOTAL2   :=0;
                            COST_TOTAL2       :=0;
                            COMMITMENT_TOTAL2 :=0;
                            TOTAL_TOTAL2      :=0;
                            SELECT DISTINCT V.VERSION_NAME
                               INTO l_period_name
                               FROM PA_BUDGET_VERSIONS V
                              WHERE V.BUDGET_VERSION_ID = l_BUDGET_VERSION_ID;
                            IF (display_type            = 'text/html') THEN
                                   IF l_project_type    = 'IS PROJECT TYPE' THEN
                                          L_DOCUMENT   := L_DOCUMENT || NL || NL || '<div class="container">';
                                          L_DOCUMENT   := L_DOCUMENT || '<h2>Budget Lines for '||l_version_name||'</h2>';
                                          L_DOCUMENT   := L_DOCUMENT ||
                                          '<table style="width: 75%" class="table table-bordered cell-border" cellspacing="10">' ||
                                          NL;
                                          L_DOCUMENT := L_DOCUMENT || '<thead>'||NL;
                                          l_document := l_document || '<TR>' || nl;
                                          l_document := l_document || '<TH  id="TASK_NAME">' ||'Task'|| '</TH>' || nl;
                                          l_document := l_document || '<TH  id="EXPENDITURE_TYPE">' ||'Expenditure Type'|| '</TH>'
                                          || nl;
                                          l_document := l_document || '<TH  id="OLD">' || 'Old Amount' || '</TH>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="NEW">' || 'New Amount' || '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="VARIANCE">' || 'New Accrual Amount'|| '</TH>' || NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="ACTUALS">' || 'Actuals'|| '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="COMMITMENTS">' || 'Commitments'|| '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="TOTAL_COSTS">' || 'Total Costs'|| '</TH>' || NL;
                                          l_document := l_document || '<TH  id="VARIANCE2">' || 'Variance'|| '</TH>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</thead>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '<tbody>'||NL;
                                          curr_len   := lengthb(l_document);
                                          prior_len  := curr_len;
                                          OPEN non_tam_bud_lines(l_budget_version_id);
                                          LOOP
                                                 FETCH non_tam_bud_lines
                                                    INTO l_nt_line;
                                                 i := i + 1;
                                                 EXIT
                                          WHEN non_tam_bud_lines%NOTFOUND;
                                                 /* Exit the cursor if the current document length and 2 times the
                                                 ** length added in prior line exceeds 32000 char */
                                                 IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                                                        EXIT;
                                                 END IF;
                                                 prior_len  := curr_len;
                                                 l_document := l_document || '<TR>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="200" headers="TASK_NAME">' || NVL(
                                                 l_nt_line.TASK_NAME, '&'||'nbsp') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE">' || NVL(
                                                 l_nt_line.expenditure_type, '&'||'nbsp') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="OLD">' || TO_CHAR
                                                 (NVL(l_nt_line.Old,0),'999,999,999.90') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="NEW">' || TO_CHAR
                                                 (NVL(l_nt_line.new,0),'999,999,999.90') || '</TD>' || nl;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE">' ||
                                                 TO_CHAR(NVL(L_nt_LINE.VARIANCE,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS">' ||
                                                 TO_CHAR(NVL(l_nt_line.Actuals,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="COMMITMENTS">' ||
                                                 TO_CHAR(NVL(l_nt_line.commitments,0),'999,999,999.90') || '</TD>' || nl;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="TOTAL_COSTS">' ||
                                                 TO_CHAR(NVL(l_nt_line.total_costs,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE2">' ||
                                                 TO_CHAR(NVL(l_nt_line.new,0)-NVL(L_nt_LINE.TOTAL_COSTS,0), '999,999,999.90') ||
                                                 '</TD>' || NL;
                                                 l_document       := l_document || '</TR>' || NL;
                                                 old_total        := old_total       +NVL(l_nt_line.old,0);
                                                 new_total        := new_total       +NVL(l_nt_line.new,0);
                                                 VARIANCE_TOTAL   := VARIANCE_TOTAL  +NVL(L_nt_LINE.VARIANCE,0);
                                                 COST_TOTAL       := COST_TOTAL      +NVL(L_nt_LINE.ACTUALS,0);
                                                 COMMITMENT_TOTAL := COMMITMENT_TOTAL+NVL(L_nt_LINE.COMMITMENTS,0);
                                                 TOTAL_TOTAL      := TOTAL_TOTAL     +NVL(L_nt_LINE.TOTAL_COSTS,0);
                                                 EXIT
                                          WHEN i           = max_lines_dsp;
                                                 curr_len := LENGTHB(l_document);
                                          END LOOP;
                                          -- Put in Total Line
                                          l_document := l_document || '<TR>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="200" headers="TASK_NAME"><B>' || 'Totals' ||
                                          '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE"><B>' || '&' ||
                                          'nbsp' || '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="OLD"><B>' || TO_CHAR(
                                          old_total,'9,999,999.90') || '</B></TD>' || nl;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="NEW"><B>' || TO_CHAR(
                                          new_total,'9,999,999.90')|| '</B></TD>' || nl;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE"><B>' ||
                                          TO_CHAR(variance_total,'9,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS"><B>' || TO_CHAR
                                          (COST_TOTAL,'9,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="COMMITMENTS"><B>' ||
                                          TO_CHAR(commitment_total,'9,999,999.90')|| '</B></TD>' || nl;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="TOTAL_COSTS"><B>' ||
                                          TO_CHAR(total_total,'9,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE2"><B>' ||
                                          TO_CHAR(new_total-TOTAL_TOTAL,'9,999,999.90') || '</B></TD>' || NL;
                                          l_document := l_document || '</TR>' || nl;
                                          AS_ACC_REQ := variance_total;
                                          L_DOCUMENT := L_DOCUMENT || '</tbody>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '</table></P>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</div>'||NL;
                                          CLOSE non_tam_bud_lines;
                                   ELSE
                                          L_DOCUMENT := L_DOCUMENT || NL || NL || '<div class="container">';
                                          L_DOCUMENT := L_DOCUMENT || '<h2>Budget Lines for '||l_version_name||'</h2>';
                                          L_DOCUMENT := L_DOCUMENT || '<table style="width: 75%" class="table table-bordered">'||NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<thead>'||NL;
                                          -- Column Headings
                                          l_document := l_document || '<TR>' || nl;
                                          l_document := l_document || '<TH  id="EXPENDITURE_TYPE">' ||'Expenditure Type'|| '</TH>'
                                          || nl;
                                          l_document := l_document || '<TH  id="OLD">' || 'Old Amount' || '</TH>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="NEW">' || 'New Amount' || '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="VARIANCE">' || 'New Accrual Amount'|| '</TH>' || NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="ACTUALS">' || 'Actuals'|| '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="COMMITMENTS">' || 'Commitments'|| '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="TOTAL_COSTS">' || 'Total Costs'|| '</TH>' || NL;
                                          l_document := l_document || '<TH  id="VARIANCE2">' || 'Variance'|| '</TH>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</thead>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '<tbody>'||NL;
                                          curr_len   := lengthb(l_document);
                                          prior_len  := curr_len;
                                          OPEN budget_line_cur(l_budget_version_id);
                                          LOOP
                                                 FETCH budget_line_cur
                                                    INTO l_line;
                                                 i := i + 1;
                                                 EXIT
                                          WHEN budget_line_cur%NOTFOUND;
                                                 /* Exit the cursor if the current document length and 2 times the
                                                 ** length added in prior line exceeds 32000 char */
                                                 IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                                                        EXIT;
                                                 END IF;
                                                 prior_len  := curr_len;
                                                 l_document := l_document || '<TR>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE">' || NVL(
                                                 l_line.expenditure_type, '&'||'nbsp') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="OLD">' || TO_CHAR
                                                 (NVL(l_line.Old,0),'999,999,999.90') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="NEW">' || TO_CHAR
                                                 (NVL(l_line.new,0),'999,999,999.90') || '</TD>' || nl;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE">' ||
                                                 TO_CHAR(NVL(L_LINE.VARIANCE,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS">' ||
                                                 TO_CHAR(NVL(l_line.Actuals,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="COMMITMENTS">' ||
                                                 TO_CHAR(NVL(l_line.commitments,0),'999,999,999.90') || '</TD>' || nl;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="TOTAL_COSTS">' ||
                                                 TO_CHAR(NVL(l_line.total_costs,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE2">' ||
                                                 TO_CHAR(NVL(l_line.new,0)-NVL(L_LINE.TOTAL_COSTS,0),'999,999,999.90') || '</TD>'
                                                 || NL;
                                                 l_document       := l_document || '</TR>' || NL;
                                                 old_total        := old_total       +NVL(l_line.old,0);
                                                 new_total        := new_total       +NVL(l_line.new,0);
                                                 VARIANCE_TOTAL   := VARIANCE_TOTAL  +NVL(L_LINE.VARIANCE,0);
                                                 COST_TOTAL       := COST_TOTAL      +NVL(L_LINE.ACTUALS,0);
                                                 COMMITMENT_TOTAL := COMMITMENT_TOTAL+NVL(L_LINE.COMMITMENTS,0);
                                                 TOTAL_TOTAL      := TOTAL_TOTAL     +NVL(L_LINE.TOTAL_COSTS,0);
                                                 EXIT
                                          WHEN i           = max_lines_dsp;
                                                 curr_len := LENGTHB(l_document);
                                          END LOOP;
                                          -- Put in Total Line
                                          l_document := l_document || '<TR>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE"><B>' || 'Totals'
                                          || '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="OLD"><B>' || TO_CHAR(
                                          old_total,'9,999,999.90') || '</B></TD>' || nl;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="NEW"><B>' || TO_CHAR(
                                          new_total,'9,999,999.90')|| '</B></TD>' || nl;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE"><B>' ||
                                          TO_CHAR(variance_total,'9,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS"><B>' || TO_CHAR
                                          (COST_TOTAL,'9,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="COMMITMENTS"><B>' ||
                                          TO_CHAR(commitment_total,'9,999,999.90')|| '</B></TD>' || nl;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="TOTAL_COSTS"><B>' ||
                                          TO_CHAR(total_total,'9,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE2"><B>' ||
                                          TO_CHAR(new_total-TOTAL_TOTAL,'9,999,999.90') || '</B></TD>' || NL;
                                          l_document := l_document || '</TR>' || nl;
                                          AS_ACC_REQ := variance_total;
                                          L_DOCUMENT := L_DOCUMENT || '</tbody>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '</table></P>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</div>'||NL;
                                          CLOSE budget_line_cur;
                                          L_DOCUMENT := L_DOCUMENT ||NL || NL || '<div class="container">';
                                          L_DOCUMENT := L_DOCUMENT || '<h2>Security Deposit Details</h2>';
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<table style="width: 75%" class="table table-bordered table-condensed table-striped">'
                                          ||NL;
                                          L_DOCUMENT := L_DOCUMENT || '<thead>'||NL;
                                          -- Now get Security deposit amounts.
                                          -- Column Headings
                                          l_document := l_document || '<TR>' || nl;
                                          l_document := l_document || '<TH  id="EXPENDITURE_TYPE">' ||'Expenditure Type'|| '</TH>'
                                          || nl;
                                          l_document := l_document || '<TH  id="OLD">' || 'Old Amount' || '</TH>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="NEW">' || 'New Amount' || '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="VARIANCE">' || 'New Accrual Amount'|| '</TH>' || NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="ACTUALS">' || 'Security Deposits Received'||
                                          '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH  id="BAL">' || 'Unapplied Security Deposits'|| '</TH>'
                                          || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</thead>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '<tbody>'||NL;
                                          --reverse totals
                                          OLD_TOTAL := OLD_TOTAL*-1;
                                          NEW_TOTAL := NEW_TOTAL*-1;
                                          OPEN budget_line_cur2(l_budget_version_id);
                                          LOOP
                                                 FETCH budget_line_cur2
                                                    INTO l_line;
                                                 I := I + 1;
                                                 EXIT
                                          WHEN budget_line_cur2%NOTFOUND;
                                                 /* Exit the cursor if the current document length and 2 times the
                                                 ** length added in prior line exceeds 32000 char */
                                                 IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                                                        EXIT;
                                                 END IF;
                                                 prior_len                 := curr_len;
                                                 IF L_LINE.EXPENDITURE_TYPE = 'Less Security Deposits/Credits' THEN
                                                        AS_SEC_DEP         := L_LINE.VARIANCE*-1;
                                                 ELSE
                                                        AS_OP_REV := L_LINE.VARIANCE;
                                                 END IF;
                                                 l_document := l_document || '<TR>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE">' || NVL(
                                                 l_line.expenditure_type, '&'||'nbsp') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="OLD">' || TO_CHAR
                                                 (NVL(l_line.Old,0),'999,999,999.90') || '</TD>' || NL;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="NEW">' || TO_CHAR
                                                 (NVL(l_line.new,0),'999,999,999.90') || '</TD>' || nl;
                                                 l_document := l_document ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE">' ||
                                                 TO_CHAR(NVL(L_LINE.VARIANCE,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS">' ||
                                                 TO_CHAR(NVL(l_line.Actuals,0)*-1,'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="BAL">' || TO_CHAR
                                                 ((NVL(L_LINE.ACTUALS,0)*-1)-NVL(L_LINE.new,0),'999,999,999.90') || '</TD>' || NL;
                                                 l_document        := l_document || '</TR>' || NL;
                                                 old_total         := old_total        +NVL(l_line.old,0);
                                                 new_total         := new_total        +NVL(l_line.new,0);
                                                 VARIANCE_TOTAL    := VARIANCE_TOTAL   +NVL(L_LINE.VARIANCE,0);
                                                 COST_TOTAL        := COST_TOTAL       +NVL(L_LINE.ACTUALS,0);
                                                 COMMITMENT_TOTAL  := COMMITMENT_TOTAL +NVL(L_LINE.COMMITMENTS,0);
                                                 TOTAL_TOTAL       := TOTAL_TOTAL      +NVL(L_LINE.TOTAL_COSTS,0);
                                                 OLD_TOTAL2        := OLD_TOTAL2       +NVL(L_LINE.old,0);
                                                 NEW_TOTAL2        := NEW_TOTAL2       +NVL(L_LINE.new,0);
                                                 VARIANCE_TOTAL2   := VARIANCE_TOTAL2  +NVL(L_LINE.VARIANCE,0);
                                                 COST_TOTAL2       := COST_TOTAL2      +NVL(L_LINE.ACTUALS,0);
                                                 COMMITMENT_TOTAL2 := COMMITMENT_TOTAL2+NVL(L_LINE.COMMITMENTS,0);
                                                 TOTAL_TOTAL2      := TOTAL_TOTAL2     +NVL(L_LINE.TOTAL_COSTS,0);
                                                 EXIT
                                          WHEN i           = max_lines_dsp;
                                                 curr_len := LENGTHB(l_document);
                                          END LOOP;
                                          -- put in security deposits sub total
                                          l_document := l_document || '<TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE"><B>' ||
                                          'Total Security/Op Rev' || '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="OLD"><B>' || TO_CHAR(
                                          OLD_TOTAL2,'999,999,999.90') || '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="NEW"><B>' || TO_CHAR(
                                          new_total2,'999,999,999.90')|| '</B></TD>' || nl;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE"><B>' ||
                                          TO_CHAR(variance_total2,'999,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS"><B>' || TO_CHAR
                                          (COST_TOTAL2    *-1,'999,999,999.90') || '</B></TD>' || NL;
                                          IF (COST_TOTAL2 +NEW_TOTAL2)*-1 < 0 THEN
                                                 --color red
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="BAL"><font color="red"><B>'
                                                 || TO_CHAR((COST_TOTAL2+new_total2)*-1,'999,999,999.90') ||
                                                 '<font color="black"></B></TD>' || NL;
                                          ELSE
                                                 -- color black
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="BAL"><B>' ||
                                                 TO_CHAR((COST_TOTAL2+NEW_TOTAL2)*-1,'999,999,999.90') || '</B></TD>' || NL;
                                          END IF;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          -- Put grand Total Line
                                          L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
                                          --convert back for report
                                          OLD_TOTAL  := OLD_TOTAL*-1;
                                          new_total  := new_total*-1;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="150" headers="EXPENDITURE_TYPE"><B>' ||
                                          'Total After Sec Dep/Credits' || '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="OLD"><B>' || TO_CHAR(
                                          old_total,'999,999,999.90') || '</B></TD>' || nl;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="NEW"><B>' || TO_CHAR(
                                          new_total,'999,999,999.90')|| '</B></TD>' || nl;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="VARIANCE"><B>' ||
                                          TO_CHAR(AS_ACC_REQ+ AS_SEC_DEP + AS_OP_REV+0,'999,999,999.90') || '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="ACTUALS"><B>' || ' ' ||
                                          '</B></TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="BAL"><B>' || ' ' ||
                                          '</B></TD>' || NL;
                                          l_document := l_document || '</TR>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '</tbody>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '</table></P>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</div>'||NL;
                                          CLOSE budget_line_cur2;
                                          OLD_TOTAL := 0;
                                          new_total := 0;
                                          -- Period Summary lines
                                          L_DOCUMENT := L_DOCUMENT ||NL || NL || '<div class="container">';
                                          L_DOCUMENT := L_DOCUMENT || '<h2>Period Summary</h2>';
                                          L_DOCUMENT := L_DOCUMENT || '<table style="width: 75%" class="table table-bordered">'||NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<thead>'||NL;
                                          -- Column Headings
                                          l_document := l_document || '<TR>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '<TH id="EXPENDITURE_TYPE">' ||'Expenditure Type'|| '</TH>'
                                          || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH id="PREVIOUS">' || 'Previous Periods' || '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TH id="THIS">' || L_PERIOD_NAME || '</TH>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</thead>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '<tbody>'||NL;
                                          OPEN summary1(l_budget_version_id);
                                          LOOP
                                                 FETCH summary1
                                                    INTO l_sum_line;
                                                 I := I + 1;
                                                 EXIT
                                          WHEN summary1%NOTFOUND;
                                                 /* Exit the cursor if the current document length and 2 times the
                                                 ** length added in prior line exceeds 32000 char */
                                                 IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                                                        EXIT;
                                                 END IF;
                                                 prior_len  := curr_len;
                                                 l_document := l_document || '<TR>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE">' || NVL(
                                                 l_sum_line.expenditure_type, '&'||'nbsp') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="PREVIOUS">' ||
                                                 TO_CHAR(NVL(l_sum_line.Previous,0),'999,999,999.90') || '</TD>' || NL;
                                                 L_DOCUMENT := L_DOCUMENT ||
                                                 '<TD style="white-space:nowrap" width="100" align=right headers="THIS">' ||
                                                 TO_CHAR(NVL(l_sum_line.This,0),'999,999,999.90') || '</TD>' || nl;
                                                 l_document := l_document || '</TR>' || NL;
                                                 OLD_TOTAL  := OLD_TOTAL+NVL(L_SUM_LINE.PREVIOUS,0);
                                                 new_total  := new_total+NVL(l_sum_line.this,0);
                                                 EXIT
                                          WHEN i           = max_lines_dsp;
                                                 curr_len := LENGTHB(l_document);
                                          END LOOP;
                                          -- put in security deposits sub total
                                          l_document := l_document || '<TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD style="white-space:nowrap" width="180" headers="EXPENDITURE_TYPE"><B>' || 'Total' ||
                                          '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="PREVIOUS"><B>' ||
                                          TO_CHAR(OLD_TOTAL,'999,999,999.90') || '</B></TD>' || NL;
                                          l_document := l_document ||
                                          '<TD style="white-space:nowrap" width="100" align=right headers="THIS"><B>' || TO_CHAR(
                                          new_total,'999,999,999.90')|| '</B></TD>' || nl;
                                          l_document := l_document || '</TR>' || nl;
                                          L_DOCUMENT := L_DOCUMENT || '</tbody>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '</table></P>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</div>'||NL;
                                          CLOSE summary1;
                                          L_DOCUMENT := L_DOCUMENT ||NL || NL || '<div class="container">';
                                          L_DOCUMENT := L_DOCUMENT || '<h2>Accrual Summary</h2>';
                                          L_DOCUMENT := L_DOCUMENT || '<table style="width: 75%" class="table table-bordered">'||NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<tbody>'||NL;
                                          --- Accrual Summary region
                                          -- Column Headings
                                          L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD "white-space:nowrap" width="150" align=light><B>New Accrual Requirement:</TD>' || NL
                                          ;
                                          L_DOCUMENT := L_DOCUMENT || '<TD "white-space:nowrap" width="100" align=right>'|| TO_CHAR
                                          (NVL(AS_ACC_REQ,0),'999,999,999.90')||'</TD>' || NL;
                                          l_document := l_document || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD "white-space:nowrap" width="150" align=left><B>Less Security Deposits:</TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TD "white-space:nowrap" width="100" align=right>'|| TO_CHAR
                                          (NVL(AS_SEC_DEP,0),'999,999,999.90')||'</TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD "white-space:nowrap" width="150" align=left><B>Charge to P&L:</TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TD "white-space:nowrap" width="100" align=right>'|| TO_CHAR
                                          (NVL(AS_SEC_DEP,0)+NVL(AS_ACC_REQ,0),'999,999,999.90')||'</TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT ||
                                          '<TD "white-space:nowrap" width="150" align=left><B>Release to Op Rev:</TD>' || NL ;
                                          L_DOCUMENT := L_DOCUMENT || '<TD "white-space:nowrap" width="100" align=right>'|| TO_CHAR
                                          (NVL(AS_OP_REV,0),'999,999,999.90')||'</TD>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          l_document := l_document || '</TABLE></P>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</tbody>'||NL;
                                          L_DOCUMENT := L_DOCUMENT || '</table></P>' || NL;
                                          L_DOCUMENT := L_DOCUMENT || '</div>'||NL;
                                   END IF;
                            END IF;
                            document:= l_document;
                     END PA_BUDGET_LINES;

PROCEDURE CREATE_ACCOUNTING(
              itemtype IN VARCHAR2 ,
              itemkey  IN VARCHAR2 ,
              actid    IN NUMBER ,
              funcmode IN VARCHAR2 ,
              resultout OUT NOCOPY VARCHAR2 )
AS
       -- Check for Operational Revenue Amounts
       CURSOR GL_AMOUNT_OR(L_BUDGET_VERSION_ID NUMBER)
       IS
               SELECT 1
                 FROM
                     (
                             SELECT P.ATTRIBUTE2 ENT
                                 , P.ATTRIBUTE3 ACC
                                 , '0000' CC
                                 , P.ATTRIBUTE1 MSN
                                 , P.ATTRIBUTE4 LE
                                 , P.ATTRIBUTE2 IC
                                 , '0000' SP
                                 , 1 DR
                                 , 0 CR
                                 , P.name
                                   ||' Release to Op Revenue' description
                               FROM PA_PROJECTS_ALL P
                                 , GL_CODE_COMBINATIONS G
                                 , pa_budget_versions v
                              WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                               AND G.SEGMENT2 (+)      = P.ATTRIBUTE3
                               AND G.SEGMENT3 (+)      = '0000'
                               AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                               AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                               AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                               AND G.SEGMENT7 (+)      = '0000'
                               AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                               AND p.project_id        = v.project_id
                     )
              Z
            , (
                      SELECT (SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM(DECODE(VERS,'OLD',NVL( RAW_COST,0),0))) AMOUNT
                        FROM
                            (
                                    SELECT 'NEW' vers
                                        , r.expenditure_type
                                        , l.raw_cost
                                      FROM pa_budget_versions v
                                        , pa_resource_assignments r
                                        , PA_BUDGET_LINES L
                                     WHERE V.BUDGET_VERSION_ID         = L_BUDGET_VERSION_ID
                                      AND r.budget_version_id (+)      = v.budget_version_id
                                      AND l.resource_assignment_id (+) = r.resource_assignment_id
                                 UNION ALL
                                    SELECT 'OLD'
                                        , r.expenditure_type
                                        , l.raw_cost
                                      FROM pa_budget_versions v
                                        , pa_resource_assignments r
                                        , PA_BUDGET_LINES L
                                     WHERE V.BUDGET_VERSION_ID =
                                          (
                                                  SELECT MAX(Y.BUDGET_VERSION_ID)
                                                    FROM PA_BUDGET_VERSIONS Y
                                                      , PA_BUDGET_VERSIONS Z
                                                   WHERE Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                    AND y.project_id         = z.project_id
                                                    AND y.fin_plan_type_id   = z.fin_plan_type_id
                                                    AND y.budget_status_Code = 'B'
                                          )
                                      AND r.budget_version_id (+)      = v.budget_version_id
                                      AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                            )
                            X
                          , (
                                    SELECT segment_value_lookup exp_type
                                        , DECODE(segment_value,'000000','Accrual','Non Accrual') grouping
                                      FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                     WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                            )
                            Y
                       WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                        AND EXPENDITURE_TYPE    = 'TAM Operational Revenue'
                    GROUP BY Y.grouping
              )
              Y
         WHERE 1        = 1
          AND Y.AMOUNT <> 0;
       -- Check for normal P&L Amounts
       CURSOR GL_AMOUNT(V_BUDGET_VERSION_ID NUMBER)
       IS
               SELECT SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM(DECODE(VERS,'OLD',NVL( RAW_COST,0) ,0)) AMOUNT
                 FROM
                     (
                             SELECT 'NEW' vers
                                 , r.expenditure_type
                                 , l.raw_cost
                               FROM PA_BUDGET_VERSIONS V
                                 , pa_resource_assignments r
                                 , PA_BUDGET_LINES L
                              WHERE V.BUDGET_VERSION_ID         = V_BUDGET_VERSION_ID
                               AND r.budget_version_id (+)      = v.budget_version_id
                               AND l.resource_assignment_id (+) = r.resource_assignment_id
                   UNION ALL
                      SELECT 'OLD'
                          , r.expenditure_type
                          , l.raw_cost
                        FROM PA_BUDGET_VERSIONS V
                          , pa_resource_assignments r
                          , pa_budget_lines l
                       WHERE V.BUDGET_VERSION_ID =
                            (
                                    SELECT MAX(Y.BUDGET_VERSION_ID)
                                      FROM PA_BUDGET_VERSIONS Y
                                        , PA_BUDGET_VERSIONS Z
                                     WHERE Z.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
                                      AND y.budget_version_id  < Z.BUDGET_VERSION_ID
                                      AND y.project_id         = z.project_id
                                      AND y.fin_plan_type_id   = z.fin_plan_type_id
                                      AND y.budget_status_Code = 'B'
                            )
                        AND r.budget_version_id (+)      = v.budget_version_id
                        AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                     )
                     X
                   , (
                             SELECT segment_value_lookup exp_type
                                 , DECODE(segment_value,'000000','Accrual','Non Accrual') grouping
                               FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                              WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                              UNION
                             SELECT 'X'
                                 , 'Accrual'
                               FROM DUAL
                     )
                     Y
                WHERE NVL(X.EXPENDITURE_TYPE,'X') = Y.EXP_TYPE (+)
             GROUP BY Y.grouping
              HAVING Y.grouping = 'Accrual';
              -- Build Op Revenue Line Details
              CURSOR GL_LINES_OR (L_BUDGET_VERSION_ID NUMBER)
              IS
                      SELECT name
                          , description
                          , ent
                          , acc
                          , CC
                          , MSN
                          , le
                          , IC
                          , SP
                          , DECODE(DR,1,AMOUNT*-1,NULL) DR
                          , DECODE(cr,1,amount*-1,NULL) CR
                        FROM
                            (
                                    SELECT P.name
                                        , P.ATTRIBUTE2 ENT
                                        , P.ATTRIBUTE3 ACC
                                        , '0000' CC
                                        , P.ATTRIBUTE1 MSN
                                        , P.ATTRIBUTE4 LE
                                        , P.ATTRIBUTE2 IC
                                        , '0000' SP
                                        , 1 DR
                                        , 0 CR
                                        , P.name
                                          ||' Release to Op Revenue' description
                                      FROM PA_PROJECTS_ALL P
                                        , GL_CODE_COMBINATIONS G
                                        , pa_budget_versions v
                                     WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                                      AND G.SEGMENT2 (+)      = P.ATTRIBUTE3
                                      AND G.SEGMENT3 (+)      = '0000'
                                      AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                                      AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                                      AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                                      AND G.SEGMENT7 (+)      = '0000'
                                      AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                      AND p.project_id        = v.project_id
                          UNION ALL
                             SELECT P.name
                                 , P.ATTRIBUTE2 ENT
                                 , '412025' ACC
                                 , '1100' CC
                                 , P.ATTRIBUTE1 MSN
                                 , P.ATTRIBUTE4 LE
                                 , P.ATTRIBUTE2 IC
                                 , '0000' SP
                                 , 0 DR
                                 , 1 CR
                                 , P.name
                                   ||' Release to Op Revenue' description
                               FROM PA_PROJECTS_ALL P
                                 , GL_CODE_COMBINATIONS G
                                 , pa_budget_versions v
                              WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                               AND G.SEGMENT2 (+)      = '412025'
                               AND G.SEGMENT3 (+)      = '1100'
                               AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                               AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                               AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                               AND G.SEGMENT7 (+)      = '0000'
                               AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                               AND P.PROJECT_ID        = V.PROJECT_ID
                           ORDER BY 1
                                 , CR
                            )
                            Z
                          , (
                                    SELECT (SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM(DECODE(VERS, 'OLD',NVL( RAW_COST,0),0)))
                                          AMOUNT
                                      FROM
                                          (
                                                  SELECT 'NEW' vers
                                                      , r.expenditure_type
                                                      , l.raw_cost
                                                    FROM pa_budget_versions v
                                                      , pa_resource_assignments r
                                                      , PA_BUDGET_LINES L
                                                   WHERE V.BUDGET_VERSION_ID         = L_BUDGET_VERSION_ID
                                                    AND r.budget_version_id (+)      = v.budget_version_id
                                                    AND l.resource_assignment_id (+) = r.resource_assignment_id
                                               UNION ALL
                                                  SELECT 'OLD'
                                                      , r.expenditure_type
                                                      , l.raw_cost
                                                    FROM pa_budget_versions v
                                                      , pa_resource_assignments r
                                                      , PA_BUDGET_LINES L
                                                   WHERE V.BUDGET_VERSION_ID =
                                                        (
                                                                SELECT MAX(Y.BUDGET_VERSION_ID)
                                                                  FROM PA_BUDGET_VERSIONS Y
                                                                    , PA_BUDGET_VERSIONS Z
                                                                 WHERE Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                                  AND y.project_id         = z.project_id
                                                                  AND y.fin_plan_type_id   = z.fin_plan_type_id
                                                                  AND y.budget_status_Code = 'B'
                                                        )
                                                    AND r.budget_version_id (+)      = v.budget_version_id
                                                    AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                                          )
                                          X
                                        , (
                                                  SELECT segment_value_lookup exp_type
                                                      , DECODE(segment_value,'000000','Accrual', 'Non Accrual') grouping
                                                    FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                                   WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                                          )
                                          Y
                                     WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                                      AND EXPENDITURE_TYPE    = 'TAM Operational Revenue'
                                  GROUP BY Y.grouping
                            )
                            Y
                       WHERE 1        = 1
                        AND y.amount <> 0;
                     -- Build Standard P%L GL Line Details
                     CURSOR GL_LINES (L_PROJECT_ID NUMBER)
                     IS
                             SELECT P.name
                                 , G.CODE_COMBINATION_ID
                                 , P.ATTRIBUTE2 ENT
                                 , P.ATTRIBUTE3 ACC
                                 , '0000' CC
                                 , P.ATTRIBUTE1 MSN
                                 , P.ATTRIBUTE4 LE
                                 , P.ATTRIBUTE2 IC
                                 , '0000' SP
                                 , 0 DR
                                 , 1 CR
                                 , p.name
                                   ||' Provision Accrual' description
                               FROM PA_PROJECTS_ALL P
                                 , GL_CODE_COMBINATIONS G
                              WHERE G.SEGMENT1 (+) = P.ATTRIBUTE2
                               AND G.SEGMENT2 (+)  = P.ATTRIBUTE3
                               AND G.SEGMENT3 (+)  = '0000'
                               AND G.SEGMENT4 (+)  = P.ATTRIBUTE1
                               AND G.SEGMENT5 (+)  = P.ATTRIBUTE4
                               AND G.SEGMENT6 (+)  = P.ATTRIBUTE2
                               AND G.SEGMENT7 (+)  = '0000'
                               AND P.PROJECT_ID    = L_PROJECT_ID
                   UNION ALL
                      SELECT P.name
                          , G.CODE_COMBINATION_ID
                          , P.ATTRIBUTE2 ENT
                          , DECODE(P.ATTRIBUTE3,'262105','577105','262205','577205','000000') ACC
                          , '1100' CC
                          , P.ATTRIBUTE1 MSN
                          , P.ATTRIBUTE4 LE
                          , P.ATTRIBUTE2 IC
                          , '0000' SP
                          , 1 DR
                          , 0 CR
                          , p.name
                            ||' P and L Charge' description
                        FROM PA_PROJECTS_ALL P
                          , GL_CODE_COMBINATIONS G
                       WHERE G.SEGMENT1 (+) = P.ATTRIBUTE2
                        AND G.SEGMENT2 (+)  = DECODE(P.ATTRIBUTE3,'262105','577105','262205','577205', '000000')
                        AND G.SEGMENT3 (+)  = '1100'
                        AND G.SEGMENT4 (+)  = P.ATTRIBUTE1
                        AND G.SEGMENT5 (+)  = P.ATTRIBUTE4
                        AND G.SEGMENT6 (+)  = P.ATTRIBUTE2
                        AND G.SEGMENT7 (+)  = '0000'
                        AND p.project_id    = l_project_id
                    ORDER BY 1
                          , CR;
                     -- Declare variables
                     V_BUDGET_DESCRIPTION VARCHAR2(250);
                     V_BUDGET_NOTE        VARCHAR2(2000);
                     v_BUDGET_VERSION     VARCHAR2(100);
                     V_USER_ID            NUMBER;
                     V_ACCOUNTING_DATE    DATE;
                     V_PROJECT_ID         NUMBER;
                     V_BUDGET_VERSION_ID  NUMBER;
              BEGIN
                     IF (funcmode <> wf_engine.eng_run) THEN
                            --
                            resultout := wf_engine.eng_null;
                            RETURN;
                            --
                     END IF;
                     V_BUDGET_DESCRIPTION := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME =>
                     'BUDGET_DESCRIPTION' ) ;
                     V_BUDGET_NOTE := WF_ENGINE.GETITEMATTRTEXT ( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'NOTE' ) ;
                     V_PROJECT_ID  := WF_ENGINE.GETITEMATTRNUMBER( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME => 'PROJECT_ID'
                     ) ;
                     V_BUDGET_VERSION_ID := WF_ENGINE.GETITEMATTRNUMBER( ITEMTYPE => ITEMTYPE, ITEMKEY => ITEMKEY, ANAME =>
                     'DRAFT_VERSION_ID' ) ;
                     V_user_id := FND_GLOBAL.USER_ID;
                      SELECT REPLACE(UPPER(VERSION_NAME),' ','')
                        INTO V_BUDGET_VERSION
                        FROM PA_BUDGET_VERSIONS
                       WHERE budget_version_id = V_BUDGET_VERSION_ID;
                     DBMS_OUTPUT.PUT_LINE('V_BUDGET_VERSION='||V_BUDGET_VERSION);
                     dbms_output.put_line('V_BUDGET_VERSION_ID='||V_BUDGET_VERSION_ID);
                     BEGIN
                             SELECT END_DATE
                               INTO v_accounting_date
                               FROM GL_PERIODS
                              WHERE PERIOD_SET_NAME = 'AWAS'
                               AND PERIOD_NAME      = V_BUDGET_VERSION;
                     EXCEPTION
                     WHEN OTHERS THEN
                            DBMS_OUTPUT.PUT_LINE('In Exception');
                            BEGIN
                                    SELECT END_DATE
                                      INTO v_accounting_date
                                      FROM GL_PERIODS
                                     WHERE PERIOD_SET_NAME            = 'AWAS'
                                      AND REPLACE(PERIOD_NAME,'-','') = V_BUDGET_VERSION;
                            EXCEPTION
                            WHEN OTHERS THEN
                                   V_ACCOUNTING_DATE := sysdate;
                            END;
                     END;
                     dbms_output.put_line('V_ACCOUNTING_DATE='||V_ACCOUNTING_DATE);
                     FOR tot IN GL_AMOUNT (V_BUDGET_VERSION_ID)
                     LOOP
                            FOR LINE IN GL_LINES(V_PROJECT_ID)
                            LOOP
                                   IF TOT.AMOUNT <> 0 THEN
                                          DBMS_OUTPUT.PUT_LINE('inserting line'||V_ACCOUNTING_DATE);
                                          dbms_output.put_line('amount='||TOT.AMOUNT);
                                           INSERT
                                             INTO gl_interface
                                                 (
                                                        STATUS
                                                      , LEDGER_ID
                                                      , ACCOUNTING_DATE
                                                      , CURRENCY_CODE
                                                      , DATE_CREATED
                                                      , CREATED_BY
                                                      , ACTUAL_FLAG
                                                      , USER_JE_SOURCE_NAME
                                                      , USER_JE_CATEGORY_NAME
                                                      , SEGMENT1
                                                      , SEGMENT2
                                                      , SEGMENT3
                                                      , SEGMENT4
                                                      , SEGMENT5
                                                      , SEGMENT6
                                                      , SEGMENT7
                                                      , ENTERED_DR
                                                      , ENTERED_CR
                                                      , REFERENCE4
                                                      , REFERENCE5
                                                      , reference10
                                                 )
                                                 VALUES
                                                 (
                                                        'NEW'
                                                      , 8
                                                      , v_accounting_date
                                                      , 'USD'
                                                      , sysdate
                                                      , V_USER_ID
                                                      , 'A'
                                                      , 'AWAS Project Accruals'
                                                      , 'Adjustment'
                                                      , LINE.ENT
                                                      , LINE.ACC
                                                      , LINE.CC
                                                      , LINE.MSN
                                                      , LINE.LE
                                                      , LINE.IC
                                                      , LINE.SP
                                                      , DECODE(LINE.DR,1,TOT.AMOUNT,NULL)
                                                      , DECODE(LINE.CR,1,TOT.AMOUNT,NULL)
                                                      , LINE.name
                                                        ||' Accrual '
                                                        ||v_budget_version
                                                      , LINE.name
                                                        ||' '
                                                        ||V_BUDGET_DESCRIPTION
                                                      , LINE.description
                                                 );
                                          dbms_output.put_line('Lines inserted:'||sql%rowcount);
                                   END IF;
                            END LOOP;
                     END LOOP;
                     dbms_output.put_line('Checking for Op Rev');
                     FOR OPREV IN GL_AMOUNT_OR
                     (
                            V_BUDGET_VERSION_ID
                     )
                     LOOP
                            dbms_output.put_line
                            (
                                   'Found Op Rev transactions'
                            )
                            ;
                            FOR LINE_OR IN GL_LINES_OR
                            (
                                   V_BUDGET_VERSION_ID
                            )
                            LOOP
                                   DBMS_OUTPUT.PUT_LINE
                                   (
                                          'Found Op Rev lines'
                                   )
                                   ;
                                   DBMS_OUTPUT.PUT_LINE('dr amount='||LINE_OR.DR);
                                   dbms_output.put_line('cr amount='||LINE_OR.CR);
                                   IF (LINE_OR.DR <> 0 OR LINE_OR.CR <> 0) THEN
                                          DBMS_OUTPUT.PUT_LINE('inserting OR line '||V_ACCOUNTING_DATE) ;
                                          DBMS_OUTPUT.PUT_LINE('dr amount='||LINE_OR.DR);
                                          dbms_output.put_line('cr amount='||LINE_OR.CR);
                                           INSERT
                                             INTO GL_INTERFACE
                                                 (
                                                        STATUS
                                                      , LEDGER_ID
                                                      , ACCOUNTING_DATE
                                                      , CURRENCY_CODE
                                                      , DATE_CREATED
                                                      , CREATED_BY
                                                      , ACTUAL_FLAG
                                                      , USER_JE_SOURCE_NAME
                                                      , USER_JE_CATEGORY_NAME
                                                      , SEGMENT1
                                                      , SEGMENT2
                                                      , SEGMENT3
                                                      , SEGMENT4
                                                      , SEGMENT5
                                                      , SEGMENT6
                                                      , SEGMENT7
                                                      , ENTERED_DR
                                                      , ENTERED_CR
                                                      , REFERENCE4
                                                      , REFERENCE5
                                                      , reference10
                                                 )
                                                 VALUES
                                                 (
                                                        'NEW'
                                                      , 8
                                                      , v_accounting_date
                                                      , 'USD'
                                                      , sysdate
                                                      , V_USER_ID
                                                      , 'A'
                                                      , 'AWAS Project Accruals'
                                                      , 'Adjustment'
                                                      , LINE_OR.ENT
                                                      , LINE_OR.ACC
                                                      , LINE_OR.CC
                                                      , LINE_OR.MSN
                                                      , LINE_OR.LE
                                                      , LINE_OR.IC
                                                      , LINE_OR.SP
                                                      , LINE_OR.DR
                                                      , LINE_OR.CR
                                                      , LINE_OR.name
                                                        ||' Op Revenue '
                                                        ||V_BUDGET_VERSION
                                                      , LINE_OR.name
                                                        ||' '
                                                        ||V_BUDGET_DESCRIPTION
                                                      , LINE_OR.description
                                                 );
                                          dbms_output.put_line('Lines inserted as OR:'||sql%rowcount);
                                   END IF;
                            END LOOP;
                     END LOOP; --OPREV
                     submit_conc_request ( p_application => 'SQLGL' , p_program => 'GLLEZLSRS' , p_sub_request => TRUE ,
                     p_parameter1 => 1007 , p_parameter2 => 61 , p_parameter3 => 8 , P_PARAMETER4 => NULL , P_PARAMETER5 => 'N' ,
                     P_PARAMETER6 => 'N' , P_PARAMETER7 => 'N' , P_PARAMETER8 => NULL , P_PARAMETER9 => NULL , P_PARAMETER10 =>
                     NULL , P_PARAMETER11 => NULL , P_PARAMETER12 => NULL , P_PARAMETER13 => NULL , P_PARAMETER14 => NULL ,
                     P_PARAMETER15 => NULL , P_PARAMETER16 => NULL , x_request_id => l_request_id ) ;
              EXCEPTION
              WHEN FND_API.G_EXC_ERROR THEN
                     WF_CORE.CONTEXT('XX_PA_BUDGET_WF','CREATE_ACCOUNTING',itemtype, itemkey, TO_CHAR( actid), funcmode);
                     RAISE;
              WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                     WF_CORE.CONTEXT('XX_PA_BUDGET_WF','CREATE_ACCOUNTING',itemtype, itemkey, TO_CHAR( actid), funcmode);
                     RAISE;
              WHEN OTHERS THEN
                     WF_CORE.context('XX_PA_BUDGET_WF','CREATE_ACCOUNTING',ITEMTYPE, ITEMKEY, TO_CHAR( ACTID), FUNCMODE);
                     RAISE;
END CREATE_ACCOUNTING;

PROCEDURE PA_ACCOUNTING_LINES(
              p_budget_version_id IN NUMBER ,
              display_type        IN VARCHAR2 DEFAULT 'text/html',
              document            IN OUT NOCOPY VARCHAR2,
              document_type       IN OUT nocopy VARCHAR2 )
AS
       L_LINE GL_LINES_RECORD;
       l_document          VARCHAR2(32000) := '';
       l_budget_version_id NUMBER;
       NL                  VARCHAR2(1) := fnd_global.newline;
       I                   NUMBER      := 0;
       MAX_LINES_DSP       NUMBER      := 20;
       line_mesg           VARCHAR2(2400);
       curr_len            NUMBER := 0;
       prior_len           NUMBER := 0;
       l_period_name pa_budget_versions.version_name%type;
       CURSOR GL_OP_REV(L_BUDGET_VERSION_ID NUMBER)
       IS
               SELECT description
                   , ent
                   , acc
                   , CC
                   , MSN
                   , le
                   , IC
                   , SP
                   , DECODE(DR,1,AMOUNT*-1,NULL) DR
                   , DECODE(cr,1,amount*-1,NULL) CR
                 FROM
                     (
                             SELECT P.ATTRIBUTE2 ENT
                                 , P.ATTRIBUTE3 ACC
                                 , '0000' CC
                                 , P.ATTRIBUTE1 MSN
                                 , P.ATTRIBUTE4 LE
                                 , P.ATTRIBUTE2 IC
                                 , '0000' SP
                                 , 1 DR
                                 , 0 CR
                                 , P.name
                                   ||' Release to Op Revenue' description
                               FROM PA_PROJECTS_ALL P
                                 , GL_CODE_COMBINATIONS G
                                 , pa_budget_versions v
                              WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                               AND G.SEGMENT2 (+)      = P.ATTRIBUTE3
                               AND G.SEGMENT3 (+)      = '0000'
                               AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                               AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                               AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                               AND G.SEGMENT7 (+)      = '0000'
                               AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                               AND p.project_id        = v.project_id
                   UNION ALL
                      SELECT P.ATTRIBUTE2 ENT
                          , '412025' ACC
                          , '1100' CC
                          , P.ATTRIBUTE1 MSN
                          , P.ATTRIBUTE4 LE
                          , P.ATTRIBUTE2 IC
                          , '0000' SP
                          , 0 DR
                          , 1 CR
                          , P.name
                            ||' Release to Op Revenue' description
                        FROM PA_PROJECTS_ALL P
                          , GL_CODE_COMBINATIONS G
                          , pa_budget_versions v
                       WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                        AND G.SEGMENT2 (+)      = '412025'
                        AND G.SEGMENT3 (+)      = '1100'
                        AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                        AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                        AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                        AND G.SEGMENT7 (+)      = '0000'
                        AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                        AND P.PROJECT_ID        = V.PROJECT_ID
                    ORDER BY 1
                          , CR
                     )
                     Z
                   , (
                             SELECT (SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM( DECODE(VERS,'OLD',NVL( RAW_COST,0),0))) AMOUNT
                               FROM
                                   (
                                           SELECT 'NEW' vers
                                               , r.expenditure_type
                                               , l.raw_cost
                                             FROM pa_budget_versions v
                                               , pa_resource_assignments r
                                               , PA_BUDGET_LINES L
                                            WHERE V.BUDGET_VERSION_ID         = L_BUDGET_VERSION_ID
                                             AND r.budget_version_id (+)      = v.budget_version_id
                                             AND l.resource_assignment_id (+) = r.resource_assignment_id
                                        UNION ALL
                                           SELECT 'OLD'
                                               , r.expenditure_type
                                               , l.raw_cost
                                             FROM pa_budget_versions v
                                               , pa_resource_assignments r
                                               , pa_budget_lines l
                                            WHERE V.BUDGET_VERSION_ID =
                                                 (
                                                         SELECT MAX(Y.BUDGET_VERSION_ID)
                                                           FROM PA_BUDGET_VERSIONS Y
                                                             , PA_BUDGET_VERSIONS Z
                                                          WHERE Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                           AND y.project_id         = z.project_id
                                                           AND y.fin_plan_type_id   = z.fin_plan_type_id
                                                           AND y.budget_status_Code = 'B'
                                                 )
                                             AND r.budget_version_id (+)      = v.budget_version_id
                                             AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                                   )
                                   X
                                 , (
                                           SELECT segment_value_lookup exp_type
                                               , DECODE(segment_value,'000000','Accrual', 'Non Accrual') grouping
                                             FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                            WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                                   )
                                   Y
                              WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                               AND EXPENDITURE_TYPE    = 'TAM Operational Revenue'
                           GROUP BY Y.grouping
                     )
                     Y
                WHERE 1        = 1
                 AND y.amount <> 0;
              CURSOR gl_line_cur (l_budget_version_id NUMBER)
              IS
                      SELECT description
                          , ent
                          , acc
                          , CC
                          , MSN
                          , le
                          , IC
                          , SP
                          , DECODE(DR,1,AMOUNT,NULL) DR
                          , DECODE(cr,1,amount,NULL) CR
                        FROM
                            (
                                    SELECT P.ATTRIBUTE2 ENT
                                        , P.ATTRIBUTE3 ACC
                                        , '0000' CC
                                        , P.ATTRIBUTE1 MSN
                                        , P.ATTRIBUTE4 LE
                                        , P.ATTRIBUTE2 IC
                                        , '0000' SP
                                        , 0 DR
                                        , 1 CR
                                        , p.name
                                          ||' Provision Accrual' description
                                      FROM PA_PROJECTS_ALL P
                                        , GL_CODE_COMBINATIONS G
                                        , pa_budget_versions v
                                     WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                                      AND G.SEGMENT2 (+)      = P.ATTRIBUTE3
                                      AND G.SEGMENT3 (+)      = '0000'
                                      AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                                      AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                                      AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                                      AND G.SEGMENT7 (+)      = '0000'
                                      AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                      AND p.project_id        = v.project_id
                          UNION ALL
                             SELECT P.ATTRIBUTE2 ENT
                                 , DECODE(P.ATTRIBUTE3,'262105','577105','262205', '577205','000000') ACC
                                 , '1100' CC
                                 , P.ATTRIBUTE1 MSN
                                 , P.ATTRIBUTE4 LE
                                 , P.ATTRIBUTE2 IC
                                 , '0000' SP
                                 , 1 DR
                                 , 0 CR
                                 , p.name
                                   ||' P and L Charge' description
                               FROM PA_PROJECTS_ALL P
                                 , GL_CODE_COMBINATIONS G
                                 , pa_budget_versions v
                              WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                               AND G.SEGMENT2 (+)      = DECODE(P.ATTRIBUTE3,'262105', '577105','262205', '577205','000000')
                               AND G.SEGMENT3 (+)      = '1100'
                               AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                               AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                               AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                               AND G.SEGMENT7 (+)      = '0000'
                               AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                               AND P.PROJECT_ID        = V.PROJECT_ID
                               AND p.project_id NOT   IN (25603,25604)
                           ORDER BY 1
                                 , CR
                            )
                            Z
                          , (
                                    SELECT SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM (DECODE(VERS,'OLD',NVL( RAW_COST,0),0))
                                          AMOUNT
                                      FROM
                                          (
                                                  SELECT 'NEW' vers
                                                      , r.expenditure_type
                                                      , l.raw_cost
                                                    FROM PA_BUDGET_VERSIONS V
                                                      , pa_resource_assignments r
                                                      , PA_BUDGET_LINES L
                                                   WHERE V.BUDGET_VERSION_ID         = L_BUDGET_VERSION_ID
                                                    AND r.budget_version_id (+)      = v.budget_version_id
                                                    AND l.resource_assignment_id (+) = r.resource_assignment_id
                                               UNION ALL
                                                  SELECT 'OLD'
                                                      , r.expenditure_type
                                                      , l.raw_cost
                                                    FROM PA_BUDGET_VERSIONS V
                                                      , pa_resource_assignments r
                                                      , pa_budget_lines l
                                                   WHERE V.BUDGET_VERSION_ID =
                                                        (
                                                                SELECT MAX( Y.BUDGET_VERSION_ID )
                                                                  FROM PA_BUDGET_VERSIONS Y
                                                                    , PA_BUDGET_VERSIONS Z
                                                                 WHERE Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                                  AND Y.PROJECT_ID         = Z.PROJECT_ID
                                                                  AND y.budget_version_id  < z.budget_version_id
                                                                  AND y.fin_plan_type_id   = z.fin_plan_type_id
                                                                  AND y.budget_status_Code = 'B'
                                                        )
                                                    AND r.budget_version_id (+)      = v.budget_version_id
                                                    AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                                          )
                                          X
                                        , (
                                                  SELECT segment_value_lookup exp_type
                                                      , DECODE(segment_value,'000000', 'Accrual','Non Accrual') grouping
                                                    FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                                   WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                                          )
                                          Y
                                     WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                                  GROUP BY Y.grouping
                                   HAVING Y.grouping = 'Accrual'
                            )
                            Y
                       WHERE 1        = 1
                        AND Y.AMOUNT <> 0
                       UNION
                      SELECT description
                          , ent
                          , acc
                          , CC
                          , MSN
                          , le
                          , IC
                          , SP
                          , DECODE(DR,1,AMOUNT,NULL) DR
                          , DECODE(cr,1,amount,NULL) CR
                        FROM
                            (
                                    SELECT P.ATTRIBUTE2 ENT
                                        , P.ATTRIBUTE3 ACC
                                        , '0000' CC
                                        , P.ATTRIBUTE1 MSN
                                        , P.ATTRIBUTE4 LE
                                        , P.ATTRIBUTE2 IC
                                        , '0000' SP
                                        , 0 DR
                                        , 1 CR
                                        , p.name
                                          ||' Provision Accrual' description
                                      FROM PA_PROJECTS_ALL P
                                        , GL_CODE_COMBINATIONS G
                                        , pa_budget_versions v
                                     WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                                      AND G.SEGMENT2 (+)      = P.ATTRIBUTE3
                                      AND G.SEGMENT3 (+)      = '0000'
                                      AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                                      AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                                      AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                                      AND G.SEGMENT7 (+)      = '0000'
                                      AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                      AND p.project_id        = v.project_id
                                 UNION ALL
                                    SELECT P.ATTRIBUTE2 ENT
                                        , DECODE(P.ATTRIBUTE3,'262105','577105','262205', '577205','000000') ACC
                                        , '1100' CC
                                        , P.ATTRIBUTE1 MSN
                                        , P.ATTRIBUTE4 LE
                                        , P.ATTRIBUTE2 IC
                                        , '0000' SP
                                        , 1 DR
                                        , 0 CR
                                        , p.name
                                          ||' P and L Charge' description
                                      FROM PA_PROJECTS_ALL P
                                        , GL_CODE_COMBINATIONS G
                                        , pa_budget_versions v
                                     WHERE G.SEGMENT1 (+)     = P.ATTRIBUTE2
                                      AND G.SEGMENT2 (+)      = DECODE(P.ATTRIBUTE3,'262105', '577105','262205', '577205','000000')
                                      AND G.SEGMENT3 (+)      = '1100'
                                      AND G.SEGMENT4 (+)      = P.ATTRIBUTE1
                                      AND G.SEGMENT5 (+)      = P.ATTRIBUTE4
                                      AND G.SEGMENT6 (+)      = P.ATTRIBUTE2
                                      AND G.SEGMENT7 (+)      = '0000'
                                      AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                      AND P.PROJECT_ID        = V.PROJECT_ID
                                      AND p.project_id       IN (25603,25604)
                                  ORDER BY 1
                                        , CR
                            )
                            Z
                          , (
                                    SELECT SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0))- SUM (DECODE(VERS,'OLD',NVL( RAW_COST,0),0))
                                          AMOUNT
                                      FROM
                                          (
                                                  SELECT 'NEW' vers
                                                      , r.expenditure_type
                                                      , l.raw_cost
                                                    FROM PA_BUDGET_VERSIONS V
                                                      , pa_resource_assignments r
                                                      , PA_BUDGET_LINES L
                                                   WHERE V.BUDGET_VERSION_ID         = L_BUDGET_VERSION_ID
                                                    AND r.budget_version_id (+)      = v.budget_version_id
                                                    AND l.resource_assignment_id (+) = r.resource_assignment_id
                                               UNION ALL
                                                  SELECT 'OLD'
                                                      , r.expenditure_type
                                                      , l.raw_cost
                                                    FROM PA_BUDGET_VERSIONS V
                                                      , pa_resource_assignments r
                                                      , pa_budget_lines l
                                                   WHERE V.BUDGET_VERSION_ID =
                                                        (
                                                                SELECT MAX( Y.BUDGET_VERSION_ID )
                                                                  FROM PA_BUDGET_VERSIONS Y
                                                                    , PA_BUDGET_VERSIONS Z
                                                                 WHERE Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                                  AND Y.PROJECT_ID         = Z.PROJECT_ID
                                                                  AND y.budget_version_id  < z.budget_version_id
                                                                  AND y.fin_plan_type_id   = z.fin_plan_type_id
                                                                  AND y.budget_status_Code = 'B'
                                                        )
                                                    AND r.budget_version_id (+)      = v.budget_version_id
                                                    AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
                                          )
                                          X
                                        , (
                                                  SELECT segment_value_lookup exp_type
                                                      , DECODE(segment_value,'000000', 'Accrual','Non Accrual') grouping
                                                    FROM PA_SEGMENT_VALUE_LOOKUPS SVL
                                                   WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1
                                          )
                                          Y
                                     WHERE X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
                                  GROUP BY Y.grouping
                            )
                            Y
                       WHERE 1        = 1
                        AND y.amount <> 0;
              BEGIN
                     l_budget_version_id := p_budget_version_id;
                     max_lines_dsp       := 30;
                     SELECT DISTINCT V.VERSION_NAME
                        INTO l_period_name
                        FROM PA_BUDGET_VERSIONS V
                       WHERE V.BUDGET_VERSION_ID = l_BUDGET_VERSION_ID;
                     IF (display_type            = 'text/html') THEN
                            DBMS_OUTPUT.PUT_LINE('1');
                            L_DOCUMENT := L_DOCUMENT || NL || NL || '<div class="container">';
                            L_DOCUMENT := L_DOCUMENT || '<h2>Proposed Journal Lines</h2>' ;
                            L_DOCUMENT := L_DOCUMENT || '<table style="width: 75%" class="table table-bordered">'||NL ;
                            L_DOCUMENT := L_DOCUMENT || '<thead>'||NL;
                            -- Column Headings
                            L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="DESCRIPTION">' || 'Description'|| '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT1">' || 'Entity' || '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT2">' || 'Account' || '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT3">' || 'Cost Centre'|| '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT4">' || 'MSN'|| '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT5">' || 'Leasee' || '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT6">' || 'IC'|| '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="SEGMENT7">' || 'Spare' || '</TH>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '<TH  id="DR">' || 'Debit Amt'|| '</TH>' || NL;
                            l_document := l_document || '<TH  id="CR">' || 'Credit Amt'|| '</TH>' || nl;
                            l_document := l_document || '</TR>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '</thead>'||NL;
                            L_DOCUMENT := L_DOCUMENT || '<tbody>'||NL;
                            DBMS_OUTPUT.PUT_LINE('2');
                            curr_len  := lengthb(l_document);
                            prior_len := curr_len;
                            DBMS_OUTPUT.PUT_LINE('curr_len'||curr_len);
                            OPEN gl_line_cur(l_budget_version_id);
                            LOOP
                                   FETCH gl_line_cur
                                      INTO l_line;
                                   i := i + 1;
                                   EXIT
                            WHEN gl_line_cur%NOTFOUND;
                                   /* Exit the cursor if the current document length and
                                   2 times the
                                   ** length added in prior line exceeds 32000 char */
                                   IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                                          EXIT;
                                   END IF;
                                   PRIOR_LEN := CURR_LEN;
                                   DBMS_OUTPUT.PUT_LINE('curr_len'||curr_len);
                                   l_document := l_document || '<TR>' || NL;
                                   L_DOCUMENT := L_DOCUMENT || '<TD style="white-space:nowrap" width="180" headers="DESCRIPTION">'
                                   || NVL(l_line.description, '&'||'nbsp') || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT1">' || l_line.SEGMENT1
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="SEGMENT2">' || l_line.SEGMENT2||
                                   '</TD>' || nl;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT3">' || l_line.SEGMENT3
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="SEGMENT4">' || l_line.SEGMENT4
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="30" align=right headers="SEGMENT5">' || L_LINE.SEGMENT5
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT6">' || L_LINE.SEGMENT6
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT7">' || l_line.SEGMENT7
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="DR">' || TO_CHAR(NVL(L_LINE.DR,0
                                   ),'999,999,999.90')|| '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="CR">' || TO_CHAR(NVL(L_LINE.CR,0
                                   ),'999,999,999.90')|| '</TD>' || NL;
                                   l_document := l_document || '</TR>' || NL;
                                   EXIT
                            WHEN i           = max_lines_dsp;
                                   CURR_LEN := LENGTHB(L_DOCUMENT);
                                   DBMS_OUTPUT.PUT_LINE('curr_len'||curr_len);
                            END LOOP;
                            CLOSE gl_line_cur;
                            OPEN gl_op_rev(l_budget_version_id);
                            LOOP
                                   FETCH gl_op_rev
                                      INTO l_line;
                                   I := I + 1;
                                   EXIT
                            WHEN GL_op_rev%NOTFOUND;
                                   /* Exit the cursor if the current document length and
                                   2 times the
                                   ** length added in prior line exceeds 32000 char */
                                   IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                                          EXIT;
                                   END IF;
                                   PRIOR_LEN := CURR_LEN;
                                   DBMS_OUTPUT.PUT_LINE('curr_len'||curr_len);
                                   l_document := l_document || '<TR>' || NL;
                                   L_DOCUMENT := L_DOCUMENT || '<TD style="white-space:nowrap" width="180" headers="DESCRIPTION">'
                                   || NVL(l_line.description, '&'||'nbsp') || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="400" align=right headers="SEGMENT1">' || l_line.SEGMENT1
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="SEGMENT2">' || l_line.SEGMENT2||
                                   '</TD>' || nl;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT3">' || l_line.SEGMENT3
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="SEGMENT4">' || l_line.SEGMENT4
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="30" align=right headers="SEGMENT5">' || L_LINE.SEGMENT5
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT6">' || L_LINE.SEGMENT6
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="40" align=right headers="SEGMENT7">' || l_line.SEGMENT7
                                   || '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="DR">' || TO_CHAR(NVL(L_LINE.DR,0
                                   ),'999,999,999.90')|| '</TD>' || NL;
                                   L_DOCUMENT := L_DOCUMENT ||
                                   '<TD style="white-space:nowrap" width="60" align=right headers="CR">' || TO_CHAR(NVL(L_LINE.CR,0
                                   ),'999,999,999.90')|| '</TD>' || NL;
                                   l_document := l_document || '</TR>' || NL;
                                   EXIT
                            WHEN i           = max_lines_dsp;
                                   CURR_LEN := LENGTHB(L_DOCUMENT);
                                   DBMS_OUTPUT.PUT_LINE('curr_len'||curr_len);
                            END LOOP;
                            CLOSE gl_op_rev;
                            L_DOCUMENT := L_DOCUMENT || '</tbody>'||NL;
                            L_DOCUMENT := L_DOCUMENT || '</table></P>' || NL;
                            L_DOCUMENT := L_DOCUMENT || '</div>'||NL;
                     END IF;
                     document:= L_DOCUMENT;
END PA_ACCOUNTING_LINES;
/*=============================================================================*/
/* Procedure to submit a request*/
/*=============================================================================*/
PROCEDURE submit_conc_request(
              p_application IN VARCHAR2,
              p_program     IN VARCHAR2,
              p_sub_request IN BOOLEAN,
              p_parameter1  IN VARCHAR2,
              p_parameter2  IN VARCHAR2,
              p_parameter3  IN VARCHAR2,
              p_parameter4  IN VARCHAR2,
              p_parameter5  IN VARCHAR2,
              p_parameter6  IN VARCHAR2,
              p_parameter7  IN VARCHAR2,
              p_parameter8  IN VARCHAR2,
              p_parameter9  IN VARCHAR2,
              p_parameter10 IN VARCHAR2,
              p_parameter11 IN VARCHAR2,
              P_PARAMETER12 IN VARCHAR2,
              p_parameter13 IN VARCHAR2,
              P_PARAMETER14 IN VARCHAR2,
              P_PARAMETER15 IN VARCHAR2,
              P_PARAMETER16 IN VARCHAR2,
              x_request_id OUT NUMBER )
IS
BEGIN
       WRITE_DEBUG ( 'submit_conc_request -> begining' ) ;
       X_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST ( APPLICATION=> P_APPLICATION , PROGRAM =>P_PROGRAM , SUB_REQUEST=>FALSE ,
       ARGUMENT1 =>P_PARAMETER1 , ARGUMENT2 =>P_PARAMETER2 , ARGUMENT3 =>P_PARAMETER3 , ARGUMENT4 =>P_PARAMETER4 , ARGUMENT5 =>
       P_PARAMETER5 , ARGUMENT6 => P_PARAMETER6 , ARGUMENT7 =>P_PARAMETER7 , ARGUMENT8 =>P_PARAMETER8 , ARGUMENT9 =>P_PARAMETER9 ,
       ARGUMENT10 =>P_PARAMETER10 , ARGUMENT11 =>P_PARAMETER11 , ARGUMENT12 =>P_PARAMETER12 , ARGUMENT13 => P_PARAMETER13 ,
       ARGUMENT14 =>P_PARAMETER14 , ARGUMENT15 => P_PARAMETER15 , argument16 =>p_parameter16 ) ;
       IF x_request_id = 0 THEN
              ROLLBACK;
       ELSE
              COMMIT;
       END IF;
       write_Debug ( 'submit_conc_request -> request_id :'|| x_request_id ) ;
       write_Debug ( 'submit_conc_request -> end' ) ;
END submit_conc_request;
/*=============================================================================*/
/*Procedure to wait for a request to complete and find the code of its completion.*/
/*=============================================================================*/
PROCEDURE wait_conc_request(
              p_request_id  IN NUMBER,
              p_description IN VARCHAR2,
              x_phase OUT VARCHAR2,
              x_code OUT VARCHAR2 )
IS
       l_request_code BOOLEAN DEFAULT FALSE;
       l_dev_phase    VARCHAR2 ( 30 ) ;
       l_dev_code     VARCHAR2 ( 30 ) ;
       l_sleep_time   NUMBER DEFAULT 15;
       l_message      VARCHAR2 ( 100 ) ;
BEGIN
       write_debug ( 'wait_conc_request -> begining' ) ;
       write_debug ( 'Waiting for ' || p_description || ' request to complete.' ) ;
       l_request_code := FND_CONCURRENT.WAIT_FOR_REQUEST ( p_request_id, l_Sleep_Time, 0, x_Phase, x_code, l_dev_phase, l_dev_code,
       l_Message ) ;
       write_Debug ( 'Completion code details are :- ' ) ;
       write_Debug ( 'Phase      -> '||x_Phase ) ;
       write_Debug ( 'code       -> '||x_code ) ;
       write_Debug ( 'Dev Phase  -> '||l_dev_phase ) ;
       write_Debug ( 'Dev code   -> '||l_dev_code ) ;
       write_Debug ( 'Message    -> '||l_Message ) ;
       write_debug ( 'wait_conc_request -> End' ) ;
END WAIT_CONC_REQUEST;
/*--=============================================================================*/
/*-- Procedure to debug messages to log file*/
/*--=============================================================================*/
PROCEDURE write_debug(
              p_message IN VARCHAR2 )
IS
BEGIN
       IF G_debug_mode THEN
              fnd_file.put_line ( fnd_file.log, p_message ) ;
       END IF;
END WRITE_DEBUG;
/*--=============================================================================*/
END XX_PA_BUDGET_WF;
/
