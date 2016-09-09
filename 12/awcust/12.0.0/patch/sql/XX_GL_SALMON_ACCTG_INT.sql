CREATE OR REPLACE package XX_GL_SALMON_ACCTG_INT as
/*******************************************************************************
PACKAGE NAME : XX_GL_SALMON_ACCTG_INT
CREATED BY   : Simon Joyce
DATE CREATED : 21-Jan-2015
--
PURPOSE      : Imports Accoutning Transactions from Salmon
--
ARGUMENTS
    ERRBUF                Apps Standard Error Buffer
    RETCODE               Apps Standard Return Code
    P_ACCOUNTING_DATE     User Entered Account Date parameter
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
21-01-2015 SJOYCE     Initial Version
*******************************************************************************/

  PROCEDURE main
     (
          ERRBUF OUT varchar2,
          RETCODE OUT number,
          P_ACCOUNTING_DATE varchar2);

END XX_GL_SALMON_ACCTG_INT;
/


CREATE OR REPLACE PACKAGE BODY XX_GL_SALMON_ACCTG_INT AS
/*******************************************************************************
  PACKAGE NAME  : XX_GL_SALMON_ACCTG_INT
  CREATED BY    : Simon Joyce
  DATE CREATED  : 25-Jan-2015
  --
  PURPOSE       :
  --
  MODIFICATION HISTORY
  --------------------
  --
  DATE        WHO?       DETAILS                              DESCRIPTION
  ----------  ---------  -----------------------------------  ------------------
  25-Jan-2015 SJOYCE     First Version LB, CF and IS          Change 497
  24-Feb-2015 SJOYCE     Phase 2 BW, FF and DP                Change 531
  13-May-2015 SJOYCE     Phase 3, FT and LL                   Change 620
  04-Jun-2015 SJOYCE     Phase 4, SP and FW                   Change 638
  *****************************************************************************/

-- Global Variables
L_REQUEST_ID number;
G_DEBUG_MODE BOOLEAN;
X number;
V_USER_ID  number;


PROCEDURE submit_conc_request
     (
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
          X_REQUEST_ID OUT number ) ;

/*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          X_PHASE OUT varchar2,
          x_code OUT VARCHAR2 ) ;

/*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          P_MESSAGE in varchar2 ) ;
/*-- Procedure to write output file*/
PROCEDURE write_out
     (
          P_MESSAGE in varchar2 );

procedure LB_LOAD (P_ACCOUNTING_DATE varchar2);
procedure IS_LOAD (P_ACCOUNTING_DATE varchar2);
procedure CF_LOAD (P_ACCOUNTING_DATE varchar2);
procedure FF_LOAD (P_ACCOUNTING_DATE varchar2);
procedure LL_LOAD (P_ACCOUNTING_DATE varchar2);
procedure DP_LOAD (P_ACCOUNTING_DATE varchar2);
procedure BW_LOAD (P_ACCOUNTING_DATE varchar2);
procedure FT_LOAD (P_ACCOUNTING_DATE varchar2);
procedure SP_LOAD (P_ACCOUNTING_DATE varchar2);
procedure FW_LOAD (P_ACCOUNTING_DATE varchar2);



/* MAIN Procedure - imports transactions into Oracle then into the GL_INTERFACE
   and then submits Journal Import */

PROCEDURE main
     (
          ERRBUF OUT varchar2,
          RETCODE OUT number,
          P_ACCOUNTING_DATE varchar2) AS


  L_ACCOUNTING_DATE date;
  L_IF_CHK number;
  X_PHASE varchar2(240);
  x_code VARCHAR2 (240);

  cursor if_failed is select reference4 Salmon_ref, reference10 Line_desc, Status_Description, 
                     segment1||'.'||segment2||'.'||segment3||'.'||segment4||'.'||segment5||'.'||segment6||'.'||segment7 GL_STRING, 
                     round(entered_dr-entered_cr,2) amt, Currency_Code
                     from gl_interface
                     where user_je_source_name = 'Salmon - Auto'
                     and status not like 'P%';


  BEGIN

  select to_Date(p_ACCOUNTING_DATE, 'YYYY/MM/DD HH24:MI:SS') into l_accounting_date from dual;

  WRITE_OUT ( '            Salmon Account Interface Program             '||TO_CHAR ( sysdate, 'DD-MON-YYYY HH:MI:SS' ) ) ;
  WRITE_OUT ( '-----------------------------------------------------------------------------------------------' ) ;
  WRITE_OUT ( '' ) ;
  WRITE_OUT ( 'Parameters:' ) ;
  WRITE_OUT ( 'Accounting Date:'||P_ACCOUNTING_DATE ) ;
  WRITE_OUT ( 'Tieback previous transactions' ) ;


        update XX_SALMON_ACC_INT X
        set x.JE_HEADER_ID = ( select max(l.je_header_id) from GL_JE_LINES L, GL_JE_HEADERS H
                            where H.JE_HEADER_ID = L.JE_HEADER_ID
                            and H.JE_SOURCE = '81'
                            and H.DESCRIPTION = X."PaymentUniqueID"
                            and L.REFERENCE_1 = X.rowid),
              X.JE_LINE_NUM = ( select max(L.JE_LINE_NUM) from GL_JE_LINES L, GL_JE_HEADERS H
                            where H.JE_HEADER_ID = L.JE_HEADER_ID
                            and H.JE_SOURCE = '81'
                            and H.DESCRIPTION = X."PaymentUniqueID"
                            and L.REFERENCE_1 = X.rowid)
        where JE_HEADER_ID = -1;


        WRITE_OUT ( 'Number of Records Tied back: '||sql%ROWCOUNT);

        commit;


  WRITE_OUT ( '' ) ;
  WRITE_OUT ( 'Insert new transactions in the XX_SALMON_ACC_INT table where accounting date');
  WRITE_OUT ( 'less than or equal to '||P_ACCOUNTING_DATE ) ;
  WRITE_OUT ( 'Only LB,SF,IS,FF,BW,DP,LL, SP, FW and FTs being loaded at this time' ) ;
  WRITE_OUT ( '' ) ;


  --Load table in Oracle with Salmon Transactions
INSERT
INTO
  XX_SALMON_ACC_INT
SELECT
  "PaymentUniqueID",
  "TransactionType" ,
  "Payee" ,
  "TicketNumber" ,
  "TransactionDate" ,
  "ActualDate" ,
  "Currency" ,
  "FXRate" ,
  "EnteredDR" ,
  "EnteredCR" ,
  "AccountedDR" ,
  "AccountedCR" ,
  "Entity" ,
  "GLAccount" ,
  "CostCentre" ,
  "MSN" ,
  "Lessee" ,
  "InterCo" ,
  "Spare" ,
  "PaymentReference" ,
  "TicketStub" ,
  NULL,
  NULL,
  TO_DATE("TransactionDate",'DD/MM/YYYY'),
  TO_DATE("ActualDate",'DD/MM/YYYY'),
  "Cash/Memo"
from
  VSALMONACCOUNTINGINTERFACE@BASIN
where
  "TicketStub"                              in ('LB','SF','IS','FF','BW','DP','LL','FT','SP', 'FW')
and TO_DATE("TransactionDate",'DD/MM/YYYY') <= L_ACCOUNTING_DATE
and "PaymentUniqueID" not in (select "PaymentUniqueID" from XX_SALMON_ACC_INT);


  WRITE_OUT ('Number of Records Inserted: '||sql%ROWCOUNT) ;

  --Create Journal in GL


  V_USER_ID              := FND_GLOBAL.USER_ID;

  WRITE_OUT ('') ;
  WRITE_OUT ('Deleting any previously stuck lines') ;
       
       delete gl_interface
       where user_je_source_name = 'Salmon - Auto';
       
       WRITE_OUT ('Number of Records Deleted: '||sql%ROWCOUNT) ;
  
  WRITE_OUT ('Now loading records into GL_INTERFACE..') ;

  WRITE_OUT ('Loading LBs') ;

  LB_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded LBs') ;

  WRITE_OUT ('Loading CFs') ;

  CF_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded CFs') ;

  WRITE_OUT ('Loading ISs') ;

  IS_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded ISs') ;

  WRITE_OUT ('Loading FFs') ;

  FF_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded FFs') ;

  WRITE_OUT ('Loading LLs') ;

  LL_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded LLs') ;

  WRITE_OUT ('Loading DPs') ;

  DP_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded DPs') ;

  WRITE_OUT ('Loading BWs') ;

  BW_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded BWs') ;

  WRITE_OUT ('Loading FTs') ;

  FT_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded FTs') ;

  WRITE_OUT ('Loading SPs') ;

  SP_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded SPs') ;

  WRITE_OUT ('Loading FWs') ;

  FW_LOAD(L_ACCOUNTING_DATE);

  WRITE_OUT ('Loaded FWs') ;
  
  



          -- Submit GL Interface Import Program
           WRITE_OUT ('') ;
           WRITE_OUT ('Now Submitting Program - Import Journals') ;



begin

          submit_conc_request ( p_application => 'SQLGL'
                                   , p_program => 'GLLEZLSRS'
                                   , p_sub_request => TRUE
                                   , P_PARAMETER1 => 1007
                                   , p_parameter2 => 81
                                   , p_parameter3 => 8
                                   , P_PARAMETER4 => NULL
                                   , P_PARAMETER5 => 'N'
                                   , P_PARAMETER6 => 'N'
                                   , P_PARAMETER7 => 'Y'
                                   , P_PARAMETER8 => NULL
                                   , P_PARAMETER9 => NULL
                                   , P_PARAMETER10 => NULL
                                   , P_PARAMETER11 => NULL
                                   , P_PARAMETER12 => NULL
                                   , P_PARAMETER13 => NULL
                                   , P_PARAMETER14 => NULL
                                   , P_PARAMETER15 => NULL
                                   , P_PARAMETER16 => null
                                   , x_request_id => l_request_id ) ;


          WRITE_OUT ('Request id:'||L_REQUEST_ID);

       wait_conc_request
     ( l_request_id ,'Journal Import',
          x_phase,
          x_code  );

end;

          WRITE_OUT ('');
          /*
          select count(*)
          into l_if_chk
          from gl_interface
          where user_je_source_name = 'Salmon - Auto'
          and status <> 'P';
          
           WRITE_OUT ('Number of records with errors: '||l_if_chk);
           
          if l_if_chk > 0 then
          WRITE_OUT ('Number of records with errors: '||l_if_chk);
          WRITE_OUT('Not all records were imported correctly, please review the following transaction(s)');
          WRITE_OUT ('');
          for LINE in if_failed LOOP
          
          WRITE_OUT('Salmon Ref   : '||line.salmon_ref||'  Line Description: '||line.line_desc);
          WRITE_OUT('Error message: '||line.status_description);
          WRITE_OUT('GL String    : '||line.gl_string);
          WRITE_OUT('Amount       : '||line.amt||' '||line.currency_code);
          
          WRITE_OUT ('');
          
          end loop;
          WRITE_OUT('No records can be imported until the above error(s) are resolved.');
          retcode :=2;
          errbuf  := 'Invalid transactions in file, must be fixed in Salmon and retried.';
          
          else
          retcode := 0;
          end if;
          */
          WRITE_OUT ('Process Completed, please verify Journals');


  END main;

procedure FT_LOAD(P_ACCOUNTING_DATE varchar2) as

cursor GL_LINES is
     select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              '172061' ACC,
              '0000' CC,
              '000000' MSN,
              '000' LE ,
              X."InterCo" IC,
              '0000' SP,
              to_date(X."ActualDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber"||' - '||x."PaymentReference" DESCRIPTION,
              rowid
from XX_SALMON_ACC_INT X
where "TicketStub" = 'FT'
and upper("TransactionType") = upper('Funds out')
and "GLAccount" is null
and "EnteredDR" <> 0
and JE_HEADER_ID is null
union all
select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              to_char(x."GLAccount") ACC,
              to_char(decode(x."CostCentre",'0','0000',x."CostCentre")) CC,
              to_char(nvl(x."MSN",'000000')) MSN,
              x."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."ActualDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber"||' - '||x."PaymentReference" DESCRIPTION,
              rowid
 from XX_SALMON_ACC_INT X
where "TicketStub" = 'FT'
and "GLAccount" is not null
and JE_HEADER_ID is null
and ((upper(nvl("TransactionType",'x')) = upper('Funds out') and "EnteredCR" <> 0)
    or
    (nvl("TransactionType",'x') = 'Funds In' and "EnteredDR" <> 0)
    or
    (nvl("TransactionType",'x') = 'x'))
;


begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          USER_CURRENCY_CONVERSION_TYPE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          'Corporate',
          DECODE(LINE.CURRENCY, 'USD',null,null),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          decode(LINE.CURRENCY,'USD',LINE.ACCT_DR,null),
          decode(LINE.CURRENCY,'USD',LINE.ACCT_CR,null),
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

       WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);



          end LOOP;
          WRITE_OUT('');
           WRITE_OUT ('number of FT records loaded into GL_INTERFACE: '||x) ;

end FT_LOAD;

procedure LB_LOAD(P_ACCOUNTING_DATE varchar2) as

cursor GL_LINES is
     select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              X."GLAccount" ACC,
              X."CostCentre" CC,
              X."MSN" MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" in ('Borrowing repayment','Interest payment')
    and "TicketStub" = 'LB'
    and JE_HEADER_ID is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

       WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);



          end LOOP;
          WRITE_OUT('');
           WRITE_OUT ('number of LB records loaded into GL_INTERFACE: '||x) ;

end LB_LOAD;

procedure IS_LOAD(P_ACCOUNTING_DATE varchar2) as

  cursor GL_LINES is
     select     X."PaymentUniqueID" name,
              X."Entity" ENT,
              nvl(X."GLAccount",'544010') ACC,
              X."CostCentre" CC,
              X."MSN" MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" in ('Interest payment','Interest receipt')
    and "TicketStub" = 'IS'
    and je_header_id is null;

begin
 X := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);

          end LOOP;

          WRITE_OUT('');
          WRITE_OUT ('number of IS records loaded into GL_INTERFACE: '||x) ;

end IS_LOAD;

procedure CF_LOAD(P_ACCOUNTING_DATE varchar2) as

  cursor GL_LINES is
     select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              nvl(X."GLAccount",'172040') ACC,
              X."CostCentre" CC,
              X."MSN" MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              ROUND(X."EnteredDR",2) ENT_DR,
              ROUND(X."EnteredCR",2) ENT_CR,
              ROUND(X."AccountedDR",2) ACCT_DR,
              ROUND(X."AccountedCR",2) ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" in ('Premium paid')
    and "TicketStub" = 'CF'
    and je_header_id is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

                WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);


          end LOOP;

          WRITE_OUT('');
           WRITE_OUT ('number of CF records loaded into GL_INTERFACE: '||x) ;

end CF_LOAD;

procedure SP_LOAD(P_ACCOUNTING_DATE varchar2) as

  cursor GL_LINES is
          select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              X."GLAccount" ACC,
              decode(X."CostCentre",'0','0000',X."CostCentre") CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              -- Change 733 - removed exchange rate from Salmon to use calculated exchange rate
              -- X."FXRate"  EXCHANGE_RATE,  
              ROUND((ROUND(X."AccountedDR",2)+ROUND(X."AccountedCR",2))/(ROUND(X."EnteredDR",2)+ROUND(X."EnteredCR",2)),8) EXCHANGE_RATE,
              ROUND(X."EnteredDR",2) ENT_DR,
              ROUND(X."EnteredCR",2) ENT_CR,
              ROUND(X."AccountedDR",2) ACCT_DR,
              ROUND(X."AccountedCR",2) ACCT_CR,
              nvl(X."TransactionType",'Intercompany ')||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT x
where "TicketStub" = 'SP'
and je_header_id is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          USER_CURRENCY_CONVERSION_TYPE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          'User',
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          decode(LINE.CURRENCY,'USD',LINE.ACCT_DR,null),
          decode(LINE.CURRENCY,'USD',LINE.ACCT_CR,null),
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

                WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);


          end LOOP;

          WRITE_OUT('');
           WRITE_OUT ('number of SP records loaded into GL_INTERFACE: '||x) ;

end SP_LOAD;

procedure FW_LOAD(P_ACCOUNTING_DATE varchar2) as

  cursor GL_LINES is
          select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              X."GLAccount" ACC,
              decode(X."CostCentre",'0','0000',X."CostCentre") CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              ROUND(X."EnteredDR",2) ENT_DR,
              ROUND(X."EnteredCR",2) ENT_CR,
              ROUND(X."AccountedDR",2) ACCT_DR,
              ROUND(X."AccountedCR",2) ACCT_CR,
              nvl(X."TransactionType",'Intercompany ')||'-'||X."TicketNumber" DESCRIPTION
              ,
              rowid
    from XX_SALMON_ACC_INT x
where "TicketStub" = 'FW'
and je_header_id is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          USER_CURRENCY_CONVERSION_TYPE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          'Corporate',
          DECODE(LINE.CURRENCY, 'USD',null,null),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          decode(LINE.CURRENCY,'USD',LINE.ACCT_DR,null),
          decode(LINE.CURRENCY,'USD',LINE.ACCT_CR,null),
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

                WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);


          end LOOP;

          WRITE_OUT('');
           WRITE_OUT ('number of FW records loaded into GL_INTERFACE: '||x) ;

end FW_LOAD;


procedure FF_LOAD(P_ACCOUNTING_DATE varchar2) as

cursor GL_LINES is
     select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              nvl(X."GLAccount",'172050') ACC,
              X."CostCentre" CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" = 'Commitment fee paid'
    and "TicketStub" = 'FF'
    and JE_HEADER_ID is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

       WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);



          end LOOP;
          WRITE_OUT('');
           WRITE_OUT ('number of FF records loaded into GL_INTERFACE: '||x) ;

end FF_LOAD;


procedure LL_LOAD(P_ACCOUNTING_DATE varchar2) as

cursor GL_LINES is
     select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              NVL(X."GLAccount",DECODE("TransactionType",'Interest receipt','441005','113205')) ACC,
              nvl(X."CostCentre",'1100') CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" in ('Capital funding','Capital repayment','Interest receipt')
    and "TicketStub" = 'LL'
    and JE_HEADER_ID is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

       WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);



          end LOOP;
          WRITE_OUT('');
           WRITE_OUT ('number of LL records loaded into GL_INTERFACE: '||x) ;

end LL_LOAD;


procedure DP_LOAD(P_ACCOUNTING_DATE varchar2) as

cursor GL_LINES is
     select   X."PaymentUniqueID" name,
              X."Entity" ENT,
              NVL(X."GLAccount",DECODE("AccountedDR",0,'441005','112205')) ACC,
              nvl(X."CostCentre",'1100') CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber"||'-'||x."Payee" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" = 'Interest'
    and "TicketStub" = 'DP'
    and JE_HEADER_ID is null
    union all
    select   X."PaymentUniqueID" name,
              X."Entity" ENT,
              NVL(X."GLAccount",'112205') ACC,
              X."CostCentre" CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber"||'-'||x."Payee" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" in ('Maturity','Placement')
    and "Cash/Memo" <> 'Memo'
    and "TicketStub" = 'DP'
    and JE_HEADER_ID is null;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

       WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);



          end LOOP;
          WRITE_OUT('');
           WRITE_OUT ('number of DP records loaded into GL_INTERFACE: '||x) ;

end DP_LOAD;

procedure BW_LOAD(P_ACCOUNTING_DATE varchar2) as

cursor GL_LINES is
     select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              NVL(X."GLAccount",decode("TransactionType","Cash/Memo",'Memo',decode("AccountedDR",0,'231025','141015'))) ACC,
              X."CostCentre" CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" = 'Interest'
    and "TicketStub" = 'BW'
    and JE_HEADER_ID is null
    union all
    select    X."PaymentUniqueID" name,
              X."Entity" ENT,
              NVL(X."GLAccount",'231025') ACC,
              X."CostCentre" CC,
              nvl(X."MSN",'000000') MSN,
              X."Lessee" LE ,
              X."InterCo" IC,
              X."Spare" SP,
              to_date(X."TransactionDate",'DD/MM/YYYY') ACCOUNTING_DATE,
              X."Currency" CURRENCY,
              X."FXRate"  EXCHANGE_RATE,
              X."EnteredDR" ENT_DR,
              X."EnteredCR" ENT_CR,
              X."AccountedDR" ACCT_DR,
              X."AccountedCR" ACCT_CR,
              X."TransactionType"||'-'||X."TicketNumber" DESCRIPTION,
              rowid
    from XX_SALMON_ACC_INT X
    where "TransactionType" = 'Repayment'
    and "TicketStub" = 'BW'
    and "Cash/Memo" <> 'Memo'
    and JE_HEADER_ID is null
    ;

begin
 x := 0;

  for LINE in GL_LINES LOOP

  insert into gl_interface
          (STATUS,
          LEDGER_ID,
          ACCOUNTING_DATE,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          DATE_CREATED,
          CREATED_BY,
          ACTUAL_FLAG,
          USER_JE_SOURCE_NAME,
          USER_JE_CATEGORY_NAME,
          SEGMENT1,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          SEGMENT6,
          SEGMENT7,
          ENTERED_DR,
          ENTERED_CR,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          REFERENCE4,
          REFERENCE5,
          REFERENCE10,
          reference21
          )
          values
          ('NEW',
          8,
          LINE.ACCOUNTING_DATE,
          LINE.CURRENCY,
          DECODE(LINE.CURRENCY, 'USD',null,LINE.ACCOUNTING_DATE),
          DECODE(LINE.CURRENCY, 'USD',null,LINE.EXCHANGE_RATE),
          sysdate,
          V_USER_ID,
          'A',
          'Salmon - Auto',
          'Adjustment',
          LINE.ENT,
          LINE.ACC,
          LINE.CC,
          LINE.MSN,
          LINE.LE,
          LINE.IC,
          LINE.SP,
          LINE.ENT_DR,
          LINE.ENT_CR,
          LINE.ACCT_DR,
          LINE.ACCT_CR,
          LINE.name,
          LINE.name,
          LINE.DESCRIPTION,
          LINE.rowid
          );

     x := x + sql%ROWCOUNT;

        update XX_SALMON_ACC_INT
        set JE_HEADER_ID = -1
        where rowid = LINE.rowid;
        DBMS_OUTPUT.PUT_LINE('Lines :'||sql%ROWCOUNT);
        commit;

       WRITE_OUT(LINE.name||','||LINE.ENT||'.'||LINE.ACC||'.'||LINE.CC||'.'||LINE.MSN||'.'||LINE.LE||'.'||LINE.IC||'.'||LINE.SP||','||
                LINE.ENT_DR||','||LINE.ENT_CR||','||LINE.ACCT_DR||','||LINE.ACCT_CR);



          end LOOP;
          WRITE_OUT('');
           WRITE_OUT ('number of BW records loaded into GL_INTERFACE: '||x) ;

end BW_LOAD;

/*--=============================================================================*/
/*-- Procedure to submit a request*/
/*--=============================================================================*/
PROCEDURE submit_conc_request
     (
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

     X_REQUEST_ID   := FND_REQUEST.SUBMIT_REQUEST ( APPLICATION=>P_APPLICATION
                                                    , PROGRAM =>P_PROGRAM
                                                    , SUB_REQUEST=>FALSE
                                                    , ARGUMENT1 =>P_PARAMETER1
                                                    , ARGUMENT2 =>P_PARAMETER2
                                                    , ARGUMENT3 =>P_PARAMETER3
                                                    , ARGUMENT4 =>P_PARAMETER4
                                                    , ARGUMENT5 =>P_PARAMETER5
                                                    , ARGUMENT6 =>P_PARAMETER6
                                                    , ARGUMENT7 =>P_PARAMETER7
                                                    , ARGUMENT8 =>P_PARAMETER8
                                                    , ARGUMENT9 =>P_PARAMETER9
                                                    , ARGUMENT10 =>P_PARAMETER10
                                                    , ARGUMENT11 =>P_PARAMETER11
                                                    , ARGUMENT12 =>P_PARAMETER12
                                                    , ARGUMENT13 =>P_PARAMETER13
                                                    , ARGUMENT14 =>P_PARAMETER14
                                                    , ARGUMENT15 =>P_PARAMETER15
                                                    , argument16 =>p_parameter16 ) ;
     IF x_request_id = 0 THEN
          ROLLBACK;
     ELSE
          COMMIT;
     END IF;

     write_Debug ( 'submit_conc_request -> request_id :'|| x_request_id ) ;
     write_Debug ( 'submit_conc_request -> end' ) ;
end SUBMIT_CONC_REQUEST;

/*--=============================================================================*/
/*-- Procedure to wait for a request to complete and find the code of its completion.*/
/*--=============================================================================*/
PROCEDURE wait_conc_request
     (
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
     l_request_code := FND_CONCURRENT.WAIT_FOR_REQUEST ( p_request_id, l_Sleep_Time, 0, x_Phase, x_code, l_dev_phase, l_dev_code, l_Message ) ;
     write_Debug ( 'Completion code details are :- ' ) ;
     write_Debug ( 'Phase      -> '||x_Phase ) ;
     write_Debug ( 'code       -> '||x_code ) ;
     write_Debug ( 'Dev Phase  -> '||l_dev_phase ) ;
     write_Debug ( 'Dev code   -> '||l_dev_code ) ;
     write_Debug ( 'Message    -> '||l_Message ) ;
     write_debug ( 'wait_conc_request -> End' ) ;
end WAIT_CONC_REQUEST;
/*--=============================================================================*/
/*-- Procedure to debug messages to log file*/
/*--=============================================================================*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 )
                    IS
BEGIN

          FND_FILE.PUT_LINE ( FND_FILE.log, P_MESSAGE ) ;
          DBMS_OUTPUT.PUT_LINE( P_MESSAGE ) ;

end WRITE_DEBUG;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to write message on output file.*/
PROCEDURE write_out
     (
          p_message IN VARCHAR2 )
                    IS
     l_message VARCHAR2 ( 100 ) ;
BEGIN
     l_message := SUBSTR ( p_message, 1, 100 ) ;
     fnd_file.put_line ( fnd_file.output, l_message ) ;
END write_out;
/*--=============================================================================*/
/*--=============================================================================*/
END XX_GL_SALMON_ACCTG_INT;
/
