CREATE OR REPLACE PACKAGE XX_AP_FUNCTIONS_PKG AS 

  FUNCTION project_name(p_invoice_id IN NUMBER
      ,
      p_line_number IN NUMBER
          )
    RETURN varchar2; 
    
  FUNCTION gl_dist(p_invoice_id IN NUMBER
      ,
      p_line_number IN NUMBER
          )
    RETURN varchar2; 
    
  FUNCTION imscan_link(p_invoice_id IN NUMBER      
          )
    RETURN varchar2; 

END XX_AP_FUNCTIONS_PKG;
/


CREATE OR REPLACE PACKAGE BODY XX_AP_FUNCTIONS_PKG AS

  FUNCTION project_name(p_invoice_id IN NUMBER
      ,
      p_line_number IN NUMBER
          )
    RETURN varchar2 AS
    
    RETVAL PA_PROJECTS_ALL.NAME%TYPE;
    
  BEGIN
  RETVAL :=NULL;
  
    SELECT p.name
    into retval
    FROM PA_PROJECTS_ALL P, AP_INVOICE_LINES_ALL L
    WHERE P.PROJECT_ID = L.PROJECT_ID
    AND L.INVOICE_ID = P_INVOICE_ID
    and l.line_number = p_line_number;
    
      
    
    RETURN retval;
  END project_name;
  
  FUNCTION gl_dist(p_invoice_id IN NUMBER
      ,
      p_line_number IN NUMBER
          )
    RETURN VARCHAR2 AS
    
    RETVAL VARCHAR2(250);
    rec_count number;
    
    BEGIN
    rec_count := 0;
    SELECT COUNT(distinct dist_code_combination_id)
    into REC_COUNT
    FROM AP_INVOICE_DISTRIBUTIONS_ALL D
    WHERE D.INVOICE_ID = P_INVOICE_ID
    AND D.INVOICE_LINE_NUMBER = P_LINE_NUMBER;
    
    IF REC_COUNT > 1 THEN
    RETVAL := 'Multiple Gl Accounts';
    
    ELSE
    
    SELECT distinct C.SEGMENT1||'.'||C.SEGMENT2||'.'||C.SEGMENT3||'.'||C.SEGMENT4||'.'||C.SEGMENT5||'.'||C.SEGMENT6||'.'||C.SEGMENT7||chr(13)||GL_FLEXFIELDS_PKG.Get_Concat_Description(c.chart_of_accounts_id,c.code_combination_id)
    into retval
    FROM AP_INVOICE_DISTRIBUTIONS_ALL D,
         GL_CODE_COMBINATIONS C
    WHERE C.CODE_COMBINATION_ID = d.dist_CODE_COMBINATION_ID
    AND D.INVOICE_ID = P_INVOICE_ID
    and d.invoice_line_number = p_line_number;
    
    END IF;
    
    RETURN RETVAL;
    
    END GL_DIST;
    
    
    FUNCTION IMSCAN_LINK(P_INVOICE_ID IN NUMBER      )
    RETURN VARCHAR2 AS
    
    RETVAL VARCHAR2 (150);
    
    BEGIN
    RETVAL := NULL;
    
    SELECT '<a href="https://imscan.awas.com/AwasDocView/View/Doc?token=19-'||D_ID||'" target="_blank">View Invoice</a>'
    into retval
    FROM XX_IMSCAN_LINK@BASIN
    WHERE ORACLE_VOUCHER = (SELECT DOC_SEQUENCE_VALUE FROM AP_INVOICES_ALL WHERE INVOICE_ID = P_INVOICE_ID);
    
    
    RETURN RETVAL;
    
    end imscan_link;
    
  

END XX_AP_FUNCTIONS_PKG;
/
