CREATE OR REPLACE package XX_PA_PROJECT_WF authid current_user as
/* $Header: XXPAWFPRVS.pls 120.1 2014/10/14 17:07:55 sjoyce noship $ */

PROCEDURE Closing_project
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 );

PROCEDURE Check_for_commitments
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,FUNCMODE                      in      varchar2
  ,RESULTOUT                     OUT     NOCOPY varchar2 );
  
PROCEDURE Check_variance
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,FUNCMODE                      in      varchar2
  ,resultout                     OUT     NOCOPY VARCHAR2 );
  
PROCEDURE Check_errors
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,FUNCMODE                      in      varchar2
  ,RESULTOUT                     OUT     NOCOPY varchar2 );

PROCEDURE Check_SecDep
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,ACTID                         in      number
  ,FUNCMODE                      in      varchar2
  ,RESULTOUT                     OUT     NOCOPY varchar2 );
  
  procedure COMMITMENT_LINES
          ( p_project_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			in OUT	NOCOPY varchar2,
           DOCUMENT_TYPE	in OUT	NOCOPY varchar2);
  
  procedure SECDEP_LINES
          ( p_project_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			in OUT	NOCOPY varchar2,
           DOCUMENT_TYPE	in OUT	NOCOPY varchar2);
           
  procedure forecast_LINES
          ( p_project_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			in OUT	NOCOPY varchar2,
           DOCUMENT_TYPE	in OUT	NOCOPY varchar2);
           

end XX_PA_PROJECT_WF;
/


CREATE OR REPLACE PACKAGE BODY XX_PA_PROJECT_WF AS

type COMMITMENT_LINE_RECORD is RECORD
		( COMMITMENT_NUM PO_HEADERS_ALL.SEGMENT1%type,
      DESCRIPTION    VARCHAR2(240),
      EXP_DATE       date,
      REQUESTOR_NAME varchar2(50),
      EXPENDITURE_TYPE PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_TYPE%type,
      cost            number
		 );
     
type FORECAST_LINE_RECORD is RECORD
		( EXPENDITURE_TYPE PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_TYPE%type,
      FORECAST            number,
      ACTUALS           number,
      VARIANCE          number
		 );
     
type SECDEP_LINE_RECORD is RECORD
		( EXPENDITURE_TYPE PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_TYPE%type,
      USED              number,
      AVAILABLE         number
		 );
 
 

  PROCEDURE Closing_project
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) AS
  
  L_STATUS varchar2(50);
    
  BEGIN
    
     IF (funcmode <> wf_engine.eng_run) THEN
        --
            resultout := wf_engine.eng_null;
            RETURN;
        --
    END IF;
     
    L_STATUS := WF_ENGINE.GETITEMATTRTEXT(ITEMTYPE  => ITEMTYPE,ITEMKEY   => ITEMKEY,ANAME => 'PROJECT_STATUS_CODE' );
    
    DBMS_OUTPUT.PUT_LINE('L_STATUS='||L_STATUS);
    
    
   if L_STATUS = 'PENDING_CLOSE' then
   
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'T';
       
    ELSE
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
    
    end if;
    
   
EXCEPTION

WHEN FND_API.G_EXC_ERROR
    then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CLOSING_PROJECT',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CLOSING_PROJECT',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
   then
    WF_CORE.context('XX_PA_PROJECT_WF','CLOSING_PROJECT',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
    RAISE; 
    
  end CLOSING_PROJECT;
  
 PROCEDURE Check_for_commitments
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) AS
  
  L_PROJECT_ID number;
  L_COMMITMENTS number;
  L_ERROR_MESSAGE varchar2(250);
  
      
  BEGIN
    
     IF (funcmode <> wf_engine.eng_run) THEN
        --
            resultout := wf_engine.eng_null;
            RETURN;
        --
    END IF;
     
    
    l_project_id := wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            ANAME       => 'PROJECT_ID' );

   begin
   
       select ROUND(SUM(C.TOT_CMT_RAW_COST),2) CMT_RAW_COST
       into L_COMMITMENTS
       from PA_COMMITMENT_TXNS C
       where C.PROJECT_ID = L_PROJECT_ID;
   
   EXCEPTION when OTHERS then
       L_COMMITMENTS := 0;
   end;
   
   if L_COMMITMENTS > 0 then
  
      l_error_message := wf_engine.GetItemAttrText(itemtype    => itemtype,
                            ITEMKEY     => ITEMKEY,
                            ANAME       => 'ERROR_MESSAGE' );
 
      L_ERROR_MESSAGE := L_ERROR_MESSAGE ||' There are open commitments for this project. Please use the table below to identify them and resolve them.';
      
      wf_engine.SetItemAttrText
                    (itemtype => itemtype,
                     ITEMKEY  => ITEMKEY,
                     ANAME    => 'ERROR_MESSAGE',
                     avalue   => l_error_message );
   
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'T';
       
    ELSE
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
    
    end if;
    
   
EXCEPTION

WHEN FND_API.G_EXC_ERROR
    then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CLOSING_PROJECT',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CLOSING_PROJECT',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
   then
    WF_CORE.context('XX_PA_PROJECT_WF','CLOSING_PROJECT',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
    RAISE; 
    
  END Check_for_commitments;
  
  procedure COMMITMENT_LINES
          ( p_project_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			in OUT	NOCOPY varchar2,
           DOCUMENT_TYPE	in OUT	NOCOPY varchar2) AS
           
  L_PROJECT_ID    number;
  L_TOTAL         number;
  L_LINE		      COMMITMENT_LINE_RECORD;
  L_DOCUMENT			varchar2(32000) := '';
    
  NL				      varchar2(1) := FND_GLOBAL.NEWLINE;
  I				        number := 0;
  MAX_LINES_DSP		number := 20;
  LINE_MESG			  varchar2(240);
  CURR_LEN			  number := 0;
  PRIOR_LEN			  number := 0;
  
  cursor CMT_LINES_CUR(V_PROJECT_ID number) is
    select  C.CMT_NUMBER COMMITMENT_NUM,
            C.DESCRIPTION, 
            C.EXPENDITURE_ITEM_DATE EXP_DATE,
            C.CMT_REQUESTOR_NAME REQUESTOR_NAME,
            C.EXPENDITURE_TYPE,
            C.TOT_CMT_RAW_COST cost
    from PA_COMMITMENT_TXNS C
    where C.PROJECT_ID = v_project_id;
    
      
  BEGIN
    
    L_TOTAL := 0;
           
    l_project_id := p_project_id;
        
        
        
    if (display_type = 'text/html') then

      L_DOCUMENT := NL || NL || '<!-- COMMITMENT LINES -->'|| NL || NL || '<P><B>';
    	l_document := l_document || 'Commitment Lines';
    	l_document := l_document || '</B>';

      l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_PO_TO_APPROVE_SUM') || '"> '|| nl;

      -- Column Headings
      L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="COMMITMENT_NUM">' ||'Commitment Num'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="DESCRIPTION">' || 'Description' || '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="EXP_DATE">' || 'Exp Date' || '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="REQUESTOR_NAME">' || 'Requestor Name'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="EXPENDITURE_TYPE">' || 'Expenditure Type'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="COST">' || 'USD Amount'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
      
        CURR_LEN  := LENGTHB(L_DOCUMENT);
        PRIOR_LEN := CURR_LEN;
        

      open CMT_LINES_CUR(L_PROJECT_ID);
      
      loop
  	  FETCH CMT_LINES_CUR INTO l_line;
          i := i + 1;
          EXIT WHEN CMT_LINES_CUR%NOTFOUND;

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                prior_len := curr_len;

            l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="COMMITMENT_NUM">'
                  || NVL(L_LINE.COMMITMENT_NUM, '&'||'nbsp') || '</TD>' || NL;
                  
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="DESCRIPTION">'
                  || nvl(l_line.description,'&'||'nbsp') || '</TD>' || NL;

           l_document := l_document || '<TD nowrap align=right headers="EXP_DATE">'
                  || l_line.exp_date|| '</TD>' || nl;

           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="REQUESTOR_NAME">'
                  || NVL(L_LINE.REQUESTOR_NAME,'&'||'nbsp') || '</TD>' || NL;

          L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="EXPENDITURE_TYPE">'
                  || l_line.expenditure_type || '</TD>' || NL;

           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="COST">'
                  || to_char(nvl(l_line.cost,0),'999,999,999.90') || '</TD>' || nl;

           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
          l_total := l_total+nvl(l_line.cost,0);
          
           EXIT WHEN i = max_lines_dsp;

                CURR_LEN  := LENGTHB(L_DOCUMENT);
    	END LOOP;
      
       l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="COMMITMENT_NUM"><B>'
                              || 'Total' || '</B></TD>' || NL;
                              
             L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="DESCRIPTION">'
                  || '&'||'nbsp' || '</TD>' || NL;

           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="EXP_DATE">'
                  || '&'||'nbsp'|| '</TD>' || nl;

           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="REQUESTOR_NAME">'
                  || '&'||'nbsp'|| '</TD>' || NL;

          L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="EXPENDITURE_TYPE">'
                  || '&'||'nbsp'|| '</TD>' || NL;

            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="COST"><B>'
                  ||TO_CHAR(L_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
                  
           
           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
      L_DOCUMENT := L_DOCUMENT || '</TABLE></P>' || NL;

    	CLOSE CMT_LINES_CUR;

	END IF;

	document:= L_DOCUMENT;
    
  END commitment_lines;
  
  PROCEDURE CHECK_VARIANCE
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) AS
  
  L_PROJECT_ID        number;
  L_BUDGET_VERSION_ID number;
  
  L_VARIANCES         number;
  
  L_ERROR_MESSAGE varchar2(500);
      
  BEGIN
    
     IF (funcmode <> wf_engine.eng_run) THEN
        --
            resultout := wf_engine.eng_null;
            RETURN;
        --
    END IF;
     
    
    l_project_id := wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            ANAME       => 'PROJECT_ID' );
                            
    begin 
    select BUDGET_VERSION_ID 
      into  L_BUDGET_VERSION_ID
      from  PA_BUDGET_VERSIONS V,
            PA_PROJ_FP_OPTIONS PFO
      where V.BUDGET_STATUS_CODE = 'B'
      and V.CURRENT_FLAG = 'Y'
      and V.PROJECT_ID = PFO.PROJECT_ID
      and PFO.FIN_PLAN_TYPE_ID              =V.FIN_PLAN_TYPE_ID (+)
      and PFO.PRIMARY_COST_FORECAST_FLAG = 'Y'
      and PFO.FIN_PLAN_OPTION_LEVEL_CODE    ='PLAN_TYPE'
      and V.PROJECT_ID = L_PROJECT_ID;

   EXCEPTION when OTHERS then
    RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
            RETURN;
   end;
   
   begin
select SUM(DECODE(VARIANCE,0,0,1)) 
into L_VARIANCES
from (
   select  X.EXPENDITURE_TYPE,
              SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) FORECAST,
              SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) ACTUALS,
              SUM(DECODE(VERS,'NEW',nvl(RAW_COST,0),0))-  SUM(DECODE(VERS,'Actuals',nvl(RAW_COST,0),0)) VARIANCE
      from
(select 'NEW' vers, r.expenditure_type, l.raw_cost
from pa_budget_versions v,
pa_resource_assignments r,
PA_BUDGET_LINES L
where V.BUDGET_VERSION_ID = l_BUDGET_VERSION_ID
and r.budget_version_id (+) = v.budget_version_id
and l.resource_assignment_id (+) = r.resource_assignment_id
union all
SELECT 'Actuals' ,EI.EXPENDITURE_TYPE EXPENDITURE_TYPE, ROUND(SUM(EI.RAW_COST),2) AMOUNT
from PA_EXPENDITURE_ITEMS_ALL EI, PA_BUDGET_VERSIONS V
WHERE V.PROJECT_ID = EI.PROJECT_ID AND V.BUDGET_VERSION_ID = l_BUDGET_VERSION_ID
GROUP BY v.PROJECT_ID, EI.EXPENDITURE_TYPE
) X,
(SELECT segment_value_lookup exp_type, decode(segment_value,'000000','Accrual','Non Accrual') grouping
FROM PA_SEGMENT_VALUE_LOOKUPS SVL
WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1) Y
where X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
and expenditure_type <> 'Security Deposits/Credits'
group by Y.grouping,X.EXPENDITURE_TYPE
having Y.grouping = 'Accrual'
order by Y.grouping, X.EXPENDITURE_TYPE);
      
   
   EXCEPTION when OTHERS then
       L_VARIANCES := 0;
   end;
   
   if L_VARIANCES is null then
      L_VARIANCES := 0;
   end if;
   
   if L_VARIANCES > 0 then
   
   l_error_message := wf_engine.GetItemAttrText(itemtype    => itemtype,
                            ITEMKEY     => ITEMKEY,
                            ANAME       => 'ERROR_MESSAGE' );
 
      L_ERROR_MESSAGE := L_ERROR_MESSAGE ||' Accrual Forecast amounts do not match actual cost amounts. Please adjust the forecast before attempting to close.';
      
      wf_engine.SetItemAttrText
                    (itemtype => itemtype,
                     ITEMKEY  => ITEMKEY,
                     ANAME    => 'ERROR_MESSAGE',
                     avalue   => l_error_message );
   
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'T';
       
    else
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
    
    end if;
    
   
EXCEPTION

WHEN FND_API.G_EXC_ERROR
    then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CHECK_VARIANCE',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

when FND_API.G_EXC_UNEXPECTED_ERROR
   then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CHECK_VARIANCE',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
   then
    WF_CORE.context('XX_PA_PROJECT_WF','CHECK_VARIANCE',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
    RAISE; 
    
  end CHECK_VARIANCE;
  
  procedure forecast_LINES
          ( p_project_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			in OUT	NOCOPY varchar2,
           DOCUMENT_TYPE	in OUT	NOCOPY varchar2) AS
  
  L_BUDGET_VERSION_ID number;
    
  L_PROJECT_ID    number;
  L_TOTAL         number;
  L_F_TOTAL         number;
  L_A_TOTAL         number;
  L_LINE		      FORECAST_LINE_RECORD;
  L_DOCUMENT			varchar2(32000) := '';
    
  NL				      varchar2(1) := FND_GLOBAL.NEWLINE;
  I				        number := 0;
  MAX_LINES_DSP		number := 20;
  LINE_MESG			  varchar2(240);
  CURR_LEN			  number := 0;
  PRIOR_LEN			  number := 0;
  
 cursor budget_lines_cur (v_budget_version_id number) is
 select  X.EXPENDITURE_TYPE,
              SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) FORECAST,
              SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) ACTUALS,
              SUM(DECODE(VERS,'NEW',nvl(RAW_COST,0),0))-  SUM(DECODE(VERS,'Actuals',nvl(RAW_COST,0),0)) VARIANCE
      from
(select 'NEW' vers, r.expenditure_type, l.raw_cost
from pa_budget_versions v,
pa_resource_assignments r,
PA_BUDGET_LINES L
where V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
and r.budget_version_id (+) = v.budget_version_id
and l.resource_assignment_id (+) = r.resource_assignment_id
union all
SELECT 'Actuals' ,EI.EXPENDITURE_TYPE EXPENDITURE_TYPE, ROUND(SUM(EI.RAW_COST),2) AMOUNT
from PA_EXPENDITURE_ITEMS_ALL EI, PA_BUDGET_VERSIONS V
WHERE V.PROJECT_ID = EI.PROJECT_ID AND V.BUDGET_VERSION_ID = V_BUDGET_VERSION_ID
GROUP BY v.PROJECT_ID, EI.EXPENDITURE_TYPE
) X,
(SELECT segment_value_lookup exp_type, decode(segment_value,'000000','Accrual','Non Accrual') grouping
FROM PA_SEGMENT_VALUE_LOOKUPS SVL
WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1) Y
where X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
and expenditure_type <> 'Security Deposits/Credits'
group by Y.grouping,X.EXPENDITURE_TYPE
having Y.grouping = 'Accrual'
order by Y.grouping, X.EXPENDITURE_TYPE;


L_ERROR number;

begin 
  
  L_PROJECT_ID := P_PROJECT_ID;
  L_ERROR      := 0;
    
    begin
  
          select BUDGET_VERSION_ID 
          into  L_BUDGET_VERSION_ID
          from  PA_BUDGET_VERSIONS V,
                PA_PROJ_FP_OPTIONS PFO
          where V.BUDGET_STATUS_CODE = 'B'
          and V.CURRENT_FLAG = 'Y'
          and V.PROJECT_ID = PFO.PROJECT_ID
          and PFO.FIN_PLAN_TYPE_ID              =V.FIN_PLAN_TYPE_ID (+)
          and PFO.PRIMARY_COST_FORECAST_FLAG = 'Y'
          and PFO.FIN_PLAN_OPTION_LEVEL_CODE    ='PLAN_TYPE'
          and V.PROJECT_ID = L_PROJECT_ID;
    
    EXCEPTION when OTHERS then
      L_DOCUMENT := NL || NL || '<!-- FORECAST LINES -->'|| NL || NL || '<P><B>';
    	l_document := l_document || 'No Forecast Entered';
    	L_DOCUMENT := L_DOCUMENT || '</B>';

      L_ERROR := L_ERROR + 1;
      
    end;
        
  
  IF L_ERROR = 0 then
    
    L_TOTAL := 0;
    L_F_TOTAL := 0;
    L_A_TOTAL := 0;
           
    l_project_id := p_project_id;
        
        
        
    if (display_type = 'text/html') then

      L_DOCUMENT := NL || NL || '<!-- FORECAST LINES -->'|| NL || NL || '<P><B>';
    	l_document := l_document || 'Accrual Forecast Lines';
    	l_document := l_document || '</B>';

      l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_PO_TO_APPROVE_SUM') || '"> '|| nl;

      -- Column Headings
      L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="EXPENDITURE_TYPE">' || 'Expenditure Type'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="FORECAST">' || 'Forecast Amt'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="ACTUAL">' || 'Actual Amount'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="VARIANCE">' || 'Variance'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
      
        CURR_LEN  := LENGTHB(L_DOCUMENT);
        PRIOR_LEN := CURR_LEN;
        

      open budget_LINES_CUR(L_BUDGET_VERSION_ID);
      
      LOOP
  	  FETCH budget_LINES_CUR INTO l_line;
          I := I + 1;
          EXIT WHEN budget_LINES_CUR%NOTFOUND;

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                prior_len := curr_len;

            l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EXPENDITURE_TYPE">'
                  || NVL(L_LINE.EXPENDITURE_TYPE, '&'||'nbsp') || '</TD>' || NL;
                  
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="FORECAST">'
                  || TO_CHAR(NVL(L_LINE.FORECAST,0),'999,999,999.90') || '</TD>' || NL;

           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="ACTUALS">'
                  || TO_CHAR(NVL(L_LINE.actuals,0),'999,999,999.90') || '</TD>' || NL;
                  
           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="VARIANCE">'
                   || to_char(nvl(l_line.variance,0),'999,999,999.90') || '</TD>' || nl;

           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
          L_TOTAL := L_TOTAL+NVL(L_LINE.VARIANCE,0);
          L_F_TOTAL := L_F_TOTAL+NVL(L_LINE.FORECAST,0);
          l_A_total := l_A_total+nvl(l_line.ACTUALS,0);
          
           EXIT WHEN i = max_lines_dsp;

                CURR_LEN  := LENGTHB(L_DOCUMENT);
    	END LOOP;
      
       l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EXPENDITURE_TYPE"><B>'
                              || 'Total' || '</B></TD>' || NL;
                              
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="FORECAST"><B>'
                  ||TO_CHAR(L_F_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
                  
           L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="ACTUALS"><B>'
                  ||TO_CHAR(L_A_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
            
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="VARIANCE"><B>'
                  ||TO_CHAR(L_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
            
           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
      L_DOCUMENT := L_DOCUMENT || '</TABLE></P>' || NL;

    	CLOSE budget_LINES_CUR;

	END IF;
  
  END IF;

	document:= L_DOCUMENT;
  
  
  
  end forecast_lines;
  
  PROCEDURE Check_errors
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) AS
  
  L_ERROR_MESSAGE varchar2(250);
  
      
  BEGIN
    
     IF (funcmode <> wf_engine.eng_run) THEN
        --
            resultout := wf_engine.eng_null;
            RETURN;
        --
    END IF;
  
      l_error_message := wf_engine.GetItemAttrText(itemtype    => itemtype,
                            ITEMKEY     => ITEMKEY,
                            ANAME       => 'ERROR_MESSAGE' );
 
    if l_error_message is not null then
    
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'T';
       
    ELSE
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
    
    end if;
    
   
EXCEPTION

WHEN FND_API.G_EXC_ERROR
    then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CHECK_ERRORS',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CHECK_ERRORS',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
   then
    WF_CORE.context('XX_PA_PROJECT_WF','CHECK_ERRORS',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
    RAISE; 
    
  END Check_errors;
  
  PROCEDURE CHECK_SECDEP
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ) AS
  
  L_PROJECT_ID        number;
  L_BUDGET_VERSION_ID number;
  
  L_VARIANCES         number;
  
  L_ERROR_MESSAGE varchar2(500);
      
  BEGIN
    
     IF (funcmode <> wf_engine.eng_run) THEN
        --
            resultout := wf_engine.eng_null;
            RETURN;
        --
    END IF;
     
    
    l_project_id := wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            ANAME       => 'PROJECT_ID' );
                            
    begin 
    select BUDGET_VERSION_ID 
      into  L_BUDGET_VERSION_ID
      from  PA_BUDGET_VERSIONS V,
            PA_PROJ_FP_OPTIONS PFO
      where V.BUDGET_STATUS_CODE = 'B'
      and V.CURRENT_FLAG = 'Y'
      and V.PROJECT_ID = PFO.PROJECT_ID
      and PFO.FIN_PLAN_TYPE_ID              =V.FIN_PLAN_TYPE_ID (+)
      and PFO.PRIMARY_COST_FORECAST_FLAG = 'Y'
      and PFO.FIN_PLAN_OPTION_LEVEL_CODE    ='PLAN_TYPE'
      and V.PROJECT_ID = L_PROJECT_ID;

   EXCEPTION when OTHERS then
    RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
            RETURN;
   end;
   
   begin
select  SUM(ACTUALS)-SUM(new)
into L_VARIANCES
from (
SELECT y.grouping, x.EXPENDITURE_TYPE,
              SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) NEW,
              SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0)) ACTUALS
from
(select 'NEW' vers, r.expenditure_type, l.raw_cost
from pa_budget_versions v,
pa_resource_assignments r,
PA_BUDGET_LINES L
where V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
and r.budget_version_id (+) = v.budget_version_id
and l.resource_assignment_id (+) = r.resource_assignment_id
union all
select 'OLD', r.expenditure_type, l.raw_cost
from pa_budget_versions v,
pa_resource_assignments r,
pa_budget_lines l
where V.BUDGET_VERSION_ID = (select max(Y.BUDGET_VERSION_ID) from PA_BUDGET_VERSIONS Y, PA_BUDGET_VERSIONS Z
                              where Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                      and y.project_id = z.project_id
                              and y.fin_plan_type_id = z.fin_plan_type_id
                              and y.budget_status_Code = 'B')
and r.budget_version_id (+) = v.budget_version_id
AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
union all
SELECT 'Actuals' ,EI.EXPENDITURE_TYPE EXPENDITURE_TYPE, ROUND(SUM(EI.RAW_COST),2) AMOUNT
from PA_EXPENDITURE_ITEMS_ALL EI, PA_BUDGET_VERSIONS V
WHERE V.PROJECT_ID = EI.PROJECT_ID AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
GROUP BY v.PROJECT_ID, EI.EXPENDITURE_TYPE
UNION ALL
SELECT 'Commitments', C.EXPENDITURE_TYPE CMT_EXP_TYPE, ROUND(SUM(C.TOT_CMT_RAW_COST),2) CMT_RAW_COST
from PA_COMMITMENT_TXNS C, PA_BUDGET_VERSIONS V
WHERE V.PROJECT_ID = C.PROJECT_ID AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
GROUP BY v.PROJECT_ID, EXPENDITURE_TYPE) X,
(SELECT segment_value_lookup exp_type, decode(segment_value,'000000','Accrual','Non Accrual') grouping
FROM PA_SEGMENT_VALUE_LOOKUPS SVL
WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1) Y
where X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
and EXPENDITURE_TYPE in ('Security Deposits/Credits','TAM Operational Revenue')
group by Y.grouping,X.EXPENDITURE_TYPE
order by y.grouping, x.expenditure_type);
      
   
   EXCEPTION when OTHERS then
       L_VARIANCES := 0;
   end;
   
   if L_VARIANCES is null then
      L_VARIANCES := 0;
   end if;
   
   if L_VARIANCES > 0 then
   
   l_error_message := wf_engine.GetItemAttrText(itemtype    => itemtype,
                            ITEMKEY     => ITEMKEY,
                            ANAME       => 'ERROR_MESSAGE' );
 
      L_ERROR_MESSAGE := L_ERROR_MESSAGE ||' The full Security Deposit amount has not been utilised.';
      
      wf_engine.SetItemAttrText
                    (itemtype => itemtype,
                     ITEMKEY  => ITEMKEY,
                     ANAME    => 'ERROR_MESSAGE',
                     avalue   => l_error_message );
   
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'T';
       
    else
       RESULTOUT := WF_ENGINE.ENG_COMPLETED||':'||'F';
    
    end if;
    
   
EXCEPTION

WHEN FND_API.G_EXC_ERROR
    then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CHECK_SECDEP',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

when FND_API.G_EXC_UNEXPECTED_ERROR
   then
    WF_CORE.CONTEXT('XX_PA_PROJECT_WF','CHECK_SECDEP',itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

WHEN OTHERS
   then
    WF_CORE.context('XX_PA_PROJECT_WF','CHECK_SECDEP',ITEMTYPE, ITEMKEY, TO_CHAR(ACTID), FUNCMODE);
    RAISE; 
    
  end CHECK_SECDEP;
  
procedure secdep_LINES
          ( p_project_id		IN NUMBER ,
				   display_type		IN VARCHAR2 DEFAULT 'text/html',
				   document			in OUT	NOCOPY varchar2,
           DOCUMENT_TYPE	in OUT	NOCOPY varchar2) AS
  
  L_BUDGET_VERSION_ID number;
    
  L_PROJECT_ID    number;
  L_USED_TOTAL         number;
  L_AVAILABLE_TOTAL         number;
  
  L_LINE		      SECDEP_LINE_RECORD;
  L_DOCUMENT			varchar2(32000) := '';
    
  NL				      varchar2(1) := FND_GLOBAL.NEWLINE;
  I				        number := 0;
  MAX_LINES_DSP		number := 20;
  LINE_MESG			  varchar2(240);
  CURR_LEN			  number := 0;
  PRIOR_LEN			  number := 0;
  L_ERROR         number := 0;
  
 cursor secdep_lines_cur (v_budget_version_id number) is
 select  X.EXPENDITURE_TYPE,
              SUM(DECODE(VERS,'NEW',NVL(RAW_COST,0),0)) USED,
              SUM(DECODE(VERS,'Actuals',NVL(RAW_COST,0),0))AVAILABLE
from
(select 'NEW' vers, r.expenditure_type, l.raw_cost
from pa_budget_versions v,
pa_resource_assignments r,
PA_BUDGET_LINES L
where V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
and r.budget_version_id (+) = v.budget_version_id
and l.resource_assignment_id (+) = r.resource_assignment_id
union all
select 'OLD', r.expenditure_type, l.raw_cost
from pa_budget_versions v,
pa_resource_assignments r,
pa_budget_lines l
where V.BUDGET_VERSION_ID = (select max(Y.BUDGET_VERSION_ID) from PA_BUDGET_VERSIONS Y, PA_BUDGET_VERSIONS Z
                              where Z.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
                                                      and y.project_id = z.project_id
                              and y.fin_plan_type_id = z.fin_plan_type_id
                              and y.budget_status_Code = 'B')
and r.budget_version_id (+) = v.budget_version_id
AND L.RESOURCE_ASSIGNMENT_ID (+) = R.RESOURCE_ASSIGNMENT_ID
union all
SELECT 'Actuals' ,EI.EXPENDITURE_TYPE EXPENDITURE_TYPE, ROUND(SUM(EI.RAW_COST),2) AMOUNT
from PA_EXPENDITURE_ITEMS_ALL EI, PA_BUDGET_VERSIONS V
WHERE V.PROJECT_ID = EI.PROJECT_ID AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
GROUP BY v.PROJECT_ID, EI.EXPENDITURE_TYPE
UNION ALL
SELECT 'Commitments', C.EXPENDITURE_TYPE CMT_EXP_TYPE, ROUND(SUM(C.TOT_CMT_RAW_COST),2) CMT_RAW_COST
from PA_COMMITMENT_TXNS C, PA_BUDGET_VERSIONS V
WHERE V.PROJECT_ID = C.PROJECT_ID AND V.BUDGET_VERSION_ID = L_BUDGET_VERSION_ID
GROUP BY v.PROJECT_ID, EXPENDITURE_TYPE) X,
(SELECT segment_value_lookup exp_type, decode(segment_value,'000000','Accrual','Non Accrual') grouping
FROM PA_SEGMENT_VALUE_LOOKUPS SVL
WHERE SVL.SEGMENT_VALUE_LOOKUP_SET_ID = 1) Y
where X.EXPENDITURE_TYPE = Y.EXP_TYPE (+)
and EXPENDITURE_TYPE in ('Security Deposits/Credits','TAM Operational Revenue')
group by Y.grouping,X.EXPENDITURE_TYPE
order by y.grouping, x.expenditure_type;

  
begin 
  
  L_PROJECT_ID := P_PROJECT_ID;
  
  Begin
        select BUDGET_VERSION_ID 
        into  L_BUDGET_VERSION_ID
        from  PA_BUDGET_VERSIONS V,
              PA_PROJ_FP_OPTIONS PFO
        where V.BUDGET_STATUS_CODE = 'B'
        and V.CURRENT_FLAG = 'Y'
        and V.PROJECT_ID = PFO.PROJECT_ID
        and PFO.FIN_PLAN_TYPE_ID              =V.FIN_PLAN_TYPE_ID (+)
        and PFO.PRIMARY_COST_FORECAST_FLAG = 'Y'
        and PFO.FIN_PLAN_OPTION_LEVEL_CODE    ='PLAN_TYPE'
        and V.PROJECT_ID = L_PROJECT_ID;
  
  exception when others then
  
   L_DOCUMENT := NL || NL || '<!-- SECDEP LINES -->'|| NL || NL || '<P><B>';
    	l_document := l_document || 'There are no Security Deposits entered';
    	l_document := l_document || '</B>';
      
  end;
  
  
  
if L_ERROR = 0 then

    L_USED_TOTAL := 0;
    L_AVAILABLE_TOTAL := 0;
    
           
    l_project_id := p_project_id;
        
        
        
    if (display_type = 'text/html') then

      L_DOCUMENT := NL || NL || '<!-- SECDEP LINES -->'|| NL || NL || '<P><B>';
    	l_document := l_document || 'Security Deposit Lines';
    	l_document := l_document || '</B>';

      l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_PO_TO_APPROVE_SUM') || '"> '|| nl;

      -- Column Headings
      L_DOCUMENT := L_DOCUMENT || '<TR>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="EXPENDITURE_TYPE">' || 'Type'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '<TH  id="USED">' || 'Used'|| '</TH>' || NL;
      L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
      
        CURR_LEN  := LENGTHB(L_DOCUMENT);
        PRIOR_LEN := CURR_LEN;
        

      open secdep_LINES_CUR(L_PROJECT_ID);
      
      LOOP
  	  FETCH secdep_LINES_CUR INTO l_line;
          I := I + 1;
          EXIT WHEN secdep_LINES_CUR%NOTFOUND;

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */

                IF (curr_len + (2 * (curr_len - prior_len))) >= 32000 THEN
                   EXIT;
                END IF;

                prior_len := curr_len;

            l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="TYPE">'
                  || NVL(L_LINE.EXPENDITURE_TYPE, '&'||'nbsp') || '</TD>' || NL;
                  
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="USED">'
                  || TO_CHAR(NVL(L_LINE.USED,0),'999,999,999.90') || '</TD>' || NL;

           
           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
          L_USED_TOTAL := L_USED_TOTAL+NVL(L_LINE.USED,0);
          L_AVAILABLE_TOTAL := L_AVAILABLE_TOTAL+NVL(L_LINE.AVAILABLE,0);
          
          
           EXIT WHEN i = max_lines_dsp;

                CURR_LEN  := LENGTHB(L_DOCUMENT);
    	END LOOP;
      
       l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EXPENDITURE_TYPE"><B>'
                              || 'Total Used' || '</B></TD>' || NL;
                              
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="USED"><B>'
                  ||TO_CHAR(L_USED_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
                  
           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
            
      l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EXPENDITURE_TYPE"><B>'
                              || 'Total Available' || '</B></TD>' || NL;
                              
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="USED"><B>'
                  ||TO_CHAR(L_AVAILABLE_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
                  
           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
        l_document := l_document || '<TR>' || NL;


            L_DOCUMENT := L_DOCUMENT || '<TD nowrap headers="EXPENDITURE_TYPE"><B>'
                              || 'Remaining Balance' || '</B></TD>' || NL;
                              
            L_DOCUMENT := L_DOCUMENT || '<TD nowrap align=right headers="USED"><B>'
                  ||TO_CHAR(L_AVAILABLE_TOTAL-L_USED_TOTAL,'999,999,999.90')|| '</B></TD>' || NL;
                  
           L_DOCUMENT := L_DOCUMENT || '</TR>' || NL;
           
      L_DOCUMENT := L_DOCUMENT || '</TABLE></P>' || NL;

    	close SECDEP_LINES_CUR;
      
	END IF;
  
  end if;

	document:= L_DOCUMENT;
  
  
  
  end secdep_lines;

END XX_PA_PROJECT_WF;
/
