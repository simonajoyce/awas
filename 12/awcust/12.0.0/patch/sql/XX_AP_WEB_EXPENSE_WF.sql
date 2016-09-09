CREATE OR REPLACE PACKAGE XX_AP_WEB_EXPENSE_WF AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
PROCEDURE SETATTRIBUTE(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       P_FUNMODE	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

END XX_AP_WEB_EXPENSE_WF;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AP_WEB_EXPENSE_WF AS

PROCEDURE SETATTRIBUTE(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       P_FUNMODE	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2) is

 L_PURPOSE		AP_EXPENSE_REPORT_HEADERS.DESCRIPTION%TYPE;
 L_REPORT_HEADER_ID	AP_EXPENSE_REPORT_HEADERS.REPORT_HEADER_ID%TYPE;
 L_DEBUG_INFO                  VARCHAR2(200);
 L_ITEM_TYPE      WF_ITEMS.ITEM_TYPE%TYPE;
 l_item_key       wf_items.item_key%type;
 
 BEGIN
 L_REPORT_HEADER_ID := TO_NUMBER(substr(P_ITEM_KEY,1,5));
 L_ITEM_TYPE := P_ITEM_TYPE;
 l_item_key := p_item_key;

  select aerh.description
  INTO   L_PURPOSE
  from   ap_expense_report_headers_all aerh
  WHERE  AERH.REPORT_HEADER_ID = L_REPORT_HEADER_ID;
  




      WF_ENGINE.SetItemAttrText(l_item_type,
                              l_item_key,
                              'PURPOSE',
                              l_purpose);

  p_result := 'COMPLETE';

  AP_WEB_UTILITIES_PKG.logProcedure('XX_AP_WEB_EXPENSE_WF', 'end setAttribute');

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('XX_AP_WEB_EXPENSE_WF', 'setAttribute',
                     P_ITEM_TYPE, P_ITEM_KEY, TO_CHAR(P_ACTID), L_DEBUG_INFO);
    raise;
    
  end;

END XX_AP_WEB_EXPENSE_WF;
/
