CREATE OR REPLACE PACKAGE AP_WEB_CUS_ACCTG_PKG AUTHID CURRENT_USER AS
/* $Header: apwcaccs.pls 120.2.12010000.2 2008/08/06 07:45:54 rveliche ship $ */


FUNCTION GetIsCustomBuildOnly RETURN NUMBER;


FUNCTION BuildAccount(
        p_report_header_id              IN NUMBER,
        p_report_line_id                IN NUMBER,
        p_employee_id                   IN NUMBER,
        p_cost_center                   IN VARCHAR2,
        p_exp_type_parameter_id         IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_ccid                          IN NUMBER,
        p_build_mode                    IN VARCHAR2,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY NUMBER,
        p_return_error_message          OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


FUNCTION BuildDistProjectAccount(
        p_report_header_id              IN              NUMBER,
        p_report_line_id                IN              NUMBER,
        p_report_distribution_id        IN              NUMBER,
        p_exp_type_parameter_id         IN              NUMBER,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY      NUMBER,
        p_return_error_message          OUT NOCOPY      VARCHAR2,
        p_return_status                 OUT NOCOPY      VARCHAR2) RETURN BOOLEAN;

-- Bug: 7176464
FUNCTION CustomValidateProjectDist(
       p_report_line_id                 IN              NUMBER,
       p_web_parameter_id               IN              NUMBER,
       p_project_id                     IN              NUMBER,
       p_task_id                        IN              NUMBER,
       p_award_id                       IN              NUMBER,
       p_expenditure_org_id             IN              NUMBER,
       p_amount                         IN              NUMBER,
       p_return_error_message           OUT NOCOPY      VARCHAR2) RETURN BOOLEAN;

END AP_WEB_CUS_ACCTG_PKG;

/


CREATE OR REPLACE PACKAGE BODY AP_WEB_CUS_ACCTG_PKG AS
/* $Header: apwcaccb.pls 120.3.12010000.4 2013/04/23 10:47:10 rveliche ship $ */


---------------------------------------------
-- Some global types, constants and cursors
---------------------------------------------

---
--- Function/procedures
---

/*========================================================================
 | PUBLIC FUNCTION GetIsCustomBuildOnly
 |
 | DESCRIPTION
 |   This is called by Expenses Entry Allocations page
 |   when user presses Update/Next (only if Online Validation is disabled).
 |
 |   If you want to enable custom rebuilds in Expenses Entry Allocations page,
 |   when Online Validation is disabled, modify this function to:
 |
 |         return 1 - if you want to enable custom builds
 |         return 0 - if you do not want to enable custom builds
 |
 |   If Online Validation is enabled, custom rebuilds can be performed
 |   in BuildAccount (when p_build_mode = C_VALIDATE).
 |
 |   If Online Validation is disabled, custom rebuilds can be performed
 |   in BuildAccount, as follows:
 |      (1) in Expenses Entry Allocations page (when p_build_mode = C_CUSTOM_BUILD_ONLY)
 |      (2) in Expenses Workflow AP Server Side Validation (when p_build_mode = C_VALIDATE)
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-Aug-2005           R Langi           Created
 |
 *=======================================================================*/
FUNCTION GetIsCustomBuildOnly RETURN NUMBER
IS
BEGIN

    -- if you want to enable custom builds
    -- AWAS Uncommented out following line
    return 1;

    -- if you do not want to enable custom builds
    -- AWAS Commented out following line
    --return 0;

END;


/*========================================================================
 | PUBLIC FUNCTION BuildAccount
 |
 | DESCRIPTION
 |   This function provides a client extension to Internet Expenses
 |   for building account code combinations.
 |
 |   Internet Expenses builds account code combinations as follows:
 |
 |   If a CCID is provided then get the segments from the CCID else use the
 |   segments provided.  Overlay the segments using the expense type segments.
 |   If the expense type segments are empty then use the employee's default
 |   CCID segments (which is overlaid with the expense report header level
 |   cost center segment).  If Expense Type Cost Center segment is empty,
 |   then overlay using line level cost center or header level cost center.
 |
 |   This procedure returns the built segments and CCID (if validated).
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |   Always used for default employee accounting
 |   (1) Expenses Workflow AP Server Side Validation
 |
 |   PARAMETERS
 |      p_report_header_id              - NULL in this case
 |      p_report_line_id                - NULL in this case
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - NULL in this case
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE
 |      p_new_segments                  - returns the default employee segments
 |      p_new_ccid                      - returns the default employee code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |   When Expense Entry Allocations is enabled:
 |   (1) Initial render of Expense Allocations page:
 |          - creates new distributions
 |            or
 |          - rebuilds existing distributions when expense type changed
 |            or
 |          - rebuilds existing distributions when expense report header cost center changed
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Entry Allocations is enabled with Online Validation:
 |   (1) When user presses Update/Next on Expense Allocations page:
 |          - rebuilds/validates user modified distributions
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - NULL in this case
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Entry Allocations is enabled without Online Validation:
 |   (1) When user presses Update/Next on Expense Allocations page:
 |          - rebuilds user modified distributions
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - NULL in this case
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_CUSTOM_BUILD_ONLY
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |   (2) Expenses Workflow AP Server Side Validation
 |          - validates user modified distributions
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - contains the expense report line segments
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Entry Allocations is disabled:
 |   (1) Expenses Workflow AP Server Side Validation
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - NULL in this case
 |      p_ccid                          - NULL in this case
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |   When Expense Type is changed by Auditor:
 |   (1) Expenses Audit
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_segments                      - NULL in this case
 |      p_ccid                          - contains the expense report line code combination id
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_BUILD_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 |    When there is a need to validate the Default Expense Account
 |    (1) General Information Page, when next is clicked
 |    (2) Server Side Validation, from workflow when the report is submitted.
 |
 |
 |    PARAMETERS
 |      p_report_header_id              - NULL in this case
 |      p_report_line_id                - NULL in this case
 |      p_employee_id                   - contains the employee id
 |      p_cost_center                   - contains the expense report cost center
 |      p_exp_type_parameter_id         - NULL in this case
 |      p_segments                      - contains the segment values of the employee's default expense account.
 |      p_ccid                          - NULL In this case.
 |      p_build_mode                    - AP_WEB_ACCTG_PKG.C_DEFAULT_VALIDATE
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   True if BuildAccount was customized
 |   False if BuildAccount was NOT customized
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Aug-2005           R Langi           Created
 |
 *=======================================================================*/

FUNCTION BuildAccount(
        p_report_header_id              IN NUMBER,
        p_report_line_id                IN NUMBER,
        p_employee_id                   IN NUMBER,
        p_cost_center                   IN VARCHAR2,
        p_exp_type_parameter_id         IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_ccid                          IN NUMBER,
        p_build_mode                    IN VARCHAR2,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY NUMBER,
        p_return_error_message          OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS


-- AWAS Variables Start
l_employee_id varchar2(200);
l_segment3 varchar2(4);
l_chart_of_accounts_id NUMBER := 0;
l_flex_segment_delimiter VARCHAR2(2) := '';
l_concatenated_segments   varchar2(2000);
l_exp_line_acct_segs_array    FND_FLEX_EXT.SEGMENTARRAY;
l_default_emp_segments        FND_FLEX_EXT.SEGMENTARRAY;
l_FlexConcactenated           AP_EXPENSE_REPORT_PARAMS.FLEX_CONCACTENATED%TYPE;
l_exp_type_template_array     FND_FLEX_EXT.SEGMENTARRAY;
l_num_segments                NUMBER:=NULL;
l_default_emp_ccid            AP_WEB_DB_EXPRPT_PKG.expHdr_employeeCCID;
l_segment4 VARCHAR2(25) := NULL;
l_account VARCHAR2(6) := NULL;
l_cc VARCHAR2(4) := NULL;
lc_flex_conc varchar2(2000);



l_segment1 VARCHAR2(25) := NULL;

l_company_segment VARCHAR2(25) := NULL;



BEGIN

insert into xx_debug values (sysdate,'p_report_header_id:'||p_report_header_id,null,null,1);
insert into xx_debug values (sysdate,'p_report_line_id:'||p_report_line_id,null,null,1);
insert into xx_debug values (sysdate,'p_ccid:'||p_ccid,null,null,1);
insert into xx_debug values (sysdate,'p_employee_id:'||p_employee_id,null,null,1);
insert into xx_debug values (sysdate,'p_cost_center:'||p_cost_center,null,null,1);

if p_report_line_id is not null then

 p_new_segments := AP_OIE_KFF_SEGMENTS_T('');

 p_new_segments.extend(7);
   
  -- Get Employee default CCID

  IF (NOT AP_WEB_DB_EXPRPT_PKG.GetDefaultEmpCCID(

         p_employee_id          => p_employee_id,

         p_default_emp_ccid     => l_default_emp_ccid)) THEN

      NULL;

  END IF;



  IF (l_default_emp_ccid is null) THEN

    FND_MESSAGE.Set_Name('SQLAP', 'AP_WEB_EXP_MISSING_EMP_CCID');

    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;

  END IF;



  --Get Chart of Accounts Id

  IF (NOT AP_WEB_DB_EXPRPT_PKG.GetChartOfAccountsID(

         p_employee_id          => p_employee_id,

         p_chart_of_accounts_id => l_chart_of_accounts_id)) THEN

      NULL;

  END IF;



  --Get default employee segments

  IF (l_default_emp_ccid IS NOT NULL) THEN

    IF (NOT FND_FLEX_EXT.GET_SEGMENTS(

                                'SQLGL',

                                'GL#',

                                l_chart_of_accounts_id,

                                l_default_emp_ccid,

                                l_num_segments,

                                l_default_emp_segments)) THEN

     RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;

       NULL;

    END IF; /* GET_SEGMENTS */

  END IF;



  IF (l_chart_of_accounts_id is null) THEN

    FND_MESSAGE.Set_Name('SQLAP', 'OIE_MISS_CHART_OF_ACC_ID');

    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;

  END IF;



  -- Get segment delimiter

  l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(

                                        'SQLGL',

                                        'GL#',

                                        l_chart_of_accounts_id);





  IF (l_flex_segment_delimiter IS NULL) THEN

    FND_MSG_PUB.Add;

    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;

  END IF;



  
  if (p_ccid is not null) then



      IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL',

                                      'GL#',

                                      l_chart_of_accounts_id,

                                      p_ccid,

                                      l_num_segments,

                                      l_exp_line_acct_segs_array)) THEN

              Null;

      END IF;

  elsif (p_segments is not null and p_segments.count > 0) then



       IF (l_num_segments IS NULL) THEN

         l_num_segments := p_segments.count;

       END IF;



      FOR i IN 1..l_num_segments LOOP

            l_exp_line_acct_segs_array(i) := p_segments(i);

      END LOOP;



  end if /* p_ccid is not null or p_segments is not null */;



  -----------------------------------------------------------------------------

   if (p_exp_type_parameter_id is not null) then



    IF (AP_WEB_DB_EXPRPT_PKG.GetFlexConcactenated(

               p_parameter_id => p_exp_type_parameter_id,

               p_FlexConcactenated => l_FlexConcactenated)) THEN





  lc_flex_conc := TO_CHAR(l_FlexConcactenated);

       insert into xx_debug values (sysdate,'lc_flex_conc:'||lc_flex_conc,null,null,1);
       insert into xx_debug values (sysdate,'l_flex_segment_delimiter:'||l_flex_segment_delimiter,null,null,1);
       

  -- Getting Account segment from the concatenated expense report template accounting structure

   SELECT substr(lc_flex_conc,instr(lc_flex_conc,l_flex_segment_delimiter,1,1)+1,instr(lc_flex_conc,l_flex_segment_delimiter,1,2)-instr(lc_flex_conc,l_flex_segment_delimiter,1,1)-1)
   INTO   l_account
   FROM   DUAL;


   insert into xx_debug values (sysdate,'l_account:'||l_account,null,null,1);

   SELECT substr(lc_flex_conc,instr(lc_flex_conc,l_flex_segment_delimiter,1,2)+1,instr(lc_flex_conc,l_flex_segment_delimiter,1,3)-instr(lc_flex_conc,l_flex_segment_delimiter,1,2)-1)
   INTO   l_cc
   FROM   DUAL;

       insert into xx_debug values (sysdate,'l_cc:'||l_cc,null,null,1);
    END IF;
    
    
    if p_report_line_id is not null then
    
    select attribute1 
       into l_employee_id
       from AP.AP_EXPENSE_REPORT_LINES_ALL 
       where report_line_id = p_report_line_id;
       
    --   insert into xx_debug values (sysdate,'attribute1:'||l_employee_id,null,null,1);
       
       if l_employee_id is null then
       -- not populated so don't need custom workflow.
        
     --   insert into xx_debug values (sysdate,'employee id null',null,null,1);
        return FALSE;
       else
       
       
       SELECT g.segment3
        into l_segment3
          FROM per_all_assignments_f p
            , gl_code_combinations g
         WHERE p.default_code_comb_id = g.code_combination_id
          AND person_id               = l_employee_id; 
       
      -- insert into xx_debug values (sysdate,'l_segment3:'||l_segment3,null,null,1);
       --insert into xx_debug values (sysdate,'p_ccid:'||p_ccid,null,null,1);
       
       end if;          
       end if;

  end if; /* p_exp_type_parameter_id is not null */

  -----------------------------------------------------------------------------

     -- Overlay the incoming segment values with the segment values

     -- defined in expense type template IF the incoming segment value

     -- is NULL.

     
       
   
       if l_segment3 is null then 
              l_segment3:= l_default_emp_segments(3);       
       end if;
       
       if l_cc is not null then   -- update cost cetnre to expense type template cost centre if used
       L_segment3 := l_cc;
       end if;
       
       if l_account is null then
        l_account := l_Default_emp_segments(2);
        end if;




   p_new_segments(1) := l_default_emp_segments(1); 

   p_new_segments(2) := l_account; 

   p_new_segments(3) := l_segment3;

   p_new_segments(4) := l_default_emp_segments(4);

   p_new_segments(5) := l_default_emp_segments(5);

   p_new_segments(6) := l_default_emp_segments(6);

   p_new_segments(7) := l_default_emp_segments(7);





  l_concatenated_segments :=   p_new_segments(1)||l_flex_segment_delimiter||
                               p_new_segments(2)||l_flex_segment_delimiter||
                               p_new_segments(3)||l_flex_segment_delimiter||
                               p_new_segments(4)||l_flex_segment_delimiter||
                               p_new_segments(5)||l_flex_segment_delimiter||
                               p_new_segments(6)||l_flex_segment_delimiter||
                               p_new_segments(7);

       insert into xx_debug values (sysdate,'l_concatenated_segments:'||l_concatenated_segments,null,null,1);

  IF (FND_FLEX_KEYVAL.validate_segs('CREATE_COMBINATION',

                                        'SQLGL',

                                        'GL#',

                                        l_chart_of_accounts_id,

                                        l_concatenated_segments)) THEN 


        p_new_ccid := FND_FLEX_KEYVAL.combination_id;



      ELSE

        p_return_error_message := FND_FLEX_KEYVAL.error_message;

        FND_MESSAGE.set_encoded(FND_FLEX_KEYVAL.encoded_error_message);

        fnd_msg_pub.add();



      END IF;

  return TRUE;
 
 end if;
 
 return FALSE;



END BuildAccount;


/*========================================================================
 | PUBLIC FUNCTION BuildDistProjectAccount
 |
 | DESCRIPTION
 |   This function provides a client extension to Internet Expenses
 |   for getting account code combinations for projects related expense line.
 |
 |   Internet Expenses gets account code combinations for projects related
 |   expense line as follows:
 |
 |   (1) Calls AP_WEB_PROJECT_PKG.ValidatePATransaction
 |   (2) Calls pa_acc_gen_wf_pkg.ap_er_generate_account
 |
 |   This procedure returns the validated segments and CCID.
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |   Called from the following for projects related expense lines:
 |   (1) Expenses Workflow AP Server Side Validation
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_report_distribution_id        - contains the expense report distribution identifier
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |      p_return_status                 - returns either 'SUCCESS', 'ERROR', 'VALIDATION_ERROR', 'GENERATION_ERROR'
 |
 |
 |   When Expense Type is changed by Auditor:
 |   (1) Expenses Audit
 |
 |   PARAMETERS
 |      p_report_header_id              - contains report header id
 |      p_report_line_id                - contains report line id
 |      p_report_distribution_id        - contains the expense report distribution identifier
 |      p_exp_type_parameter_id         - contains the expense type parameter id
 |      p_new_segments                  - returns the new expense report line segments
 |      p_new_ccid                      - returns the new expense report line code combination id
 |      p_return_error_message          - returns any error message if an error occurred
 |      p_return_status                 - returns either 'SUCCESS', 'ERROR', 'VALIDATION_ERROR', 'GENERATION_ERROR'
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   True if BuildProjectAccount was customized
 |   False if BuildProjectAccount was NOT customized
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Aug-2005           R Langi           Created
 |
 *=======================================================================*/
FUNCTION BuildDistProjectAccount(
        p_report_header_id              IN              NUMBER,
        p_report_line_id                IN              NUMBER,
        p_report_distribution_id        IN              NUMBER,
        p_exp_type_parameter_id         IN              NUMBER,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY      NUMBER,
        p_return_error_message          OUT NOCOPY      VARCHAR2,
        p_return_status                 OUT NOCOPY      VARCHAR2) RETURN BOOLEAN

IS


BEGIN

       

  /*
  --
  -- Insert logic to populate segments here
  --

  --
  -- Insert logic to validate segments here
  --

  --
  -- Insert logic to generate CCID here
  --

  return TRUE;
  */
  return FALSE;

END BuildDistProjectAccount;

/*========================================================================
 | PUBLIC FUNCTION CustomValidateProjectDist
 |
 | DESCRIPTION
 |   This function provides a client extension to Internet Expenses
 |   to validate Project Task and Award. Introduced for fix: 7176464
 |
 |
 |   PARAMETERS
 |      p_report_line_id                - contains report line id
 |      p_web_parameter_id	        - contains the expense type parameter id
 |      p_project_id		        - contains the Id of the Project entered in Allocations
 |      p_task_id	                - contains the Id of the Task entered in Allocations
 |      p_award_id                      - contains the Id of the Award entered in Allocations
 |      p_expenditure_org_id            - contains the Id of the Project Expenditure Organization entered in Allocations
 |      p_amount		        - contains the amount entered on the distribution
 |      p_return_error_message          - returns any error message if an error occurred
 |
 |
 | RETURNS
 |   True if CustomValidateProjectDist was customized
 |   False if CustomValidateProjectDist was NOT customized
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-JUL-2008           Rajesh Velicheti           Created
 |
 *=======================================================================*/

FUNCTION CustomValidateProjectDist(
       p_report_line_id			IN		NUMBER,
       p_web_parameter_id		IN		NUMBER,
       p_project_id			IN		NUMBER,
       p_task_id                        IN		NUMBER,
       p_award_id			IN		NUMBER,
       p_expenditure_org_id		IN		NUMBER,
       p_amount				IN		NUMBER,
       p_return_error_message		OUT NOCOPY	VARCHAR2) RETURN BOOLEAN
IS

BEGIN

  /*
  -- Insert logic to validate Project, Task and Award.
  -- Error messages if any should be populated in p_return_error_message

  return TRUE;
  */
  return FALSE;

END CustomValidateProjectDist;


END AP_WEB_CUS_ACCTG_PKG;
/
