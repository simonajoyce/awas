--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_PA_JOURNAL_BALS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_PA_JOURNAL_BALS" 
(
  P_PROJECT_ID IN NUMBER
, P_SOURCE IN VARCHAR2
, P_PERIOD IN VARCHAR2
) RETURN NUMBER AS

/*******************************************************************************
FUNCITON NAME: XX_PA_JOURNAL_BALS
CREATED BY   : Simon Joyce
DATE CREATED : 20-Feb-2012
--
PURPOSE      : Funciton to return total value of journal for a particular
              Source for a specific project (Used in Discoverer)

--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
20-02-2013 SJOYCE     First Version
25-07-2013 SJOYCE     R12 Version
*******************************************************************************/




l_ccid number;
retval number;

BEGIN


IF P_PERIOD <> 'ALL' THEN

  if p_source = 'AR' then
              select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
              into retval
              from gl_je_lines l,
              gl_je_headers h
              WHERE L.JE_HEADER_ID = H.JE_HEADER_ID
              and h.ledger_id = 8
              and h.period_name = p_period
              and h.je_source = 'Receivables'
              and l.code_combination_id in (select code_combination_id
                from gl_code_combinations c,
                     pa_projects_all p
                where p.attribute1 = c.segment4 --MSN
                and p.attribute2 = c.segment1   -- ENTITY
                and p.attribute3 = c.segment2   -- Account
                and p.attribute4 = c.segment5  --OP
                --and p.attribute2 = c.segment6  -- IC
                and c.segment3 = '0000'
                and p.project_id = p_project_id)
              ;

    elsif p_source='AP' then
              select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
              into retval
              from gl_je_lines l,
              gl_je_headers h
              where l.je_header_id = h.je_header_id
              and h.ledger_id = 8
              and h.period_name = p_period
              and h.je_source = 'Payables'
              and l.code_combination_id in (select code_combination_id
                from gl_code_combinations c,
                     pa_projects_all p
                where p.attribute1 = c.segment4 --MSN
                and p.attribute2 = c.segment1   -- ENTITY
                and p.attribute3 = c.segment2   -- Account
                and p.attribute4 = c.segment5  --OP
                --and p.attribute2 = c.segment6  -- IC
                and c.segment3 = '0000'
                and p.project_id = p_project_id);

    elsif p_source='PO' then
              select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
              into retval
              from gl_je_lines l,
              gl_je_headers h
              where l.je_header_id = h.je_header_id
              and h.ledger_id = 8
              AND H.PERIOD_NAME = P_PERIOD
              and h.je_source = 'Purchasing'
              and l.code_combination_id in (select code_combination_id
                from gl_code_combinations c,
                     pa_projects_all p
                where p.attribute1 = c.segment4 --MSN
                and p.attribute2 = c.segment1   -- ENTITY
                and p.attribute3 = c.segment2   -- Account
                and p.attribute4 = c.segment5  --OP
                --and p.attribute2 = c.segment6  -- IC
                AND C.SEGMENT3 = '0000'
                and p.project_id = p_project_id);

       elsif p_source='GL' then
              select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
              into retval
              from gl_je_lines l,
              gl_je_headers h
              where l.je_header_id = h.je_header_id
              and h.ledger_id = 8
              AND H.PERIOD_NAME = P_PERIOD
              and h.je_source in ('Manual','Spreadsheet')
              and l.code_combination_id in (select code_combination_id
                from gl_code_combinations c,
                     pa_projects_all p
                where p.attribute1 = c.segment4 --MSN
                and p.attribute2 = c.segment1   -- ENTITY
                and p.attribute3 = c.segment2   -- Account
                and p.attribute4 = c.segment5  --OP
                --and p.attribute2 = c.segment6  -- IC
                AND C.SEGMENT3 = '0000'
                and p.project_id = p_project_id);



    end if;

    ELSE
    if p_source = 'AR' then
              select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
              into retval
              from gl_je_lines l,
              gl_je_headers h
              WHERE L.JE_HEADER_ID = H.JE_HEADER_ID
              AND H.ledger_id = 8
      --        and h.period_name = p_period
              and h.je_source = 'Receivables'
              and l.code_combination_id in (select code_combination_id
                from gl_code_combinations c,
                     pa_projects_all p
                where p.attribute1 = c.segment4 --MSN
                and p.attribute2 = c.segment1   -- ENTITY
                and p.attribute3 = c.segment2   -- Account
                and p.attribute4 = c.segment5  --OP
                --and p.attribute2 = c.segment6  -- IC
                and c.segment3 = '0000'
                AND P.PROJECT_ID = P_PROJECT_ID) ;

      ELSIF P_SOURCE = 'OR' then  -- operating Revenue
                    select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
              into retval
              from gl_je_lines l,
              gl_je_headers h
              WHERE L.JE_HEADER_ID = H.JE_HEADER_ID
              and h.ledger_id = 8
              and h.je_source in ('Manual','Spreadsheet')
              and l.code_combination_id in (select code_combination_id
                from gl_code_combinations c,
                     pa_projects_all p
                where p.attribute1 = c.segment4 --MSN
                AND P.ATTRIBUTE2 = C.SEGMENT1   -- ENTITY
                AND C.SEGMENT2 = '412025'
                and p.attribute4 = c.segment5  --OP
                AND P.ATTRIBUTE2 = C.SEGMENT6  -- IC
                and p.project_id = p_project_id);
      END IF;
      END IF;

  RETURN retval;



END XX_PA_JOURNAL_BALS;


/
