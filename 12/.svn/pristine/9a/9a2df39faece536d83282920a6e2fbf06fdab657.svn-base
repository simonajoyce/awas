CREATE OR REPLACE PACKAGE XX_HSH_STMT_INTERFACE_PKG
IS

  -- Main procedure which will be run on the submission of the concurrent request

  PROCEDURE 	bank_statement_load ( errbuf        	OUT    VARCHAR2
            		            , retcode       	OUT    NUMBER
                                    , p_input_file  	IN     VARCHAR2
                                   -- , p_dir_path    	IN     VARCHAR2
                                    , p_debug       	IN     VARCHAR2
                                   -- , p_backup_dir  	IN     VARCHAR2
                                    , p_option	    	IN     VARCHAR2
                                    , p_Bank_Branch 	IN     VARCHAR2
                                    , p_Bank_Account	IN     VARCHAR2
                                    , p_stmt_from	IN     VARCHAR2
                                    , p_stmt_to	        IN     VARCHAR2
                                    , p_stmt_date_from	IN     VARCHAR2
                                    , p_stmt_date_to    IN     VARCHAR2
                                    , p_gl_date		IN     VARCHAR2
                                    , P_ar_activity     IN     VARCHAR2
                                    , p_payment_method  IN     VARCHAR2
                                    , p_nsf_handling    IN     VARCHAR2
                                    , p_display_debug 	IN     VARCHAR2
                                    , p_debug_path 	IN     VARCHAR2
                                    , p_debug_file	IN     VARCHAR2
                                   );

  --Procedure which will upload XX_DB Bank format file into Oracle Cash Management

  PROCEDURE    XX_HSH_bank_stmt_load( x_error_message  OUT   VARCHAR2
 				 , x_error_code	    OUT   NUMBER
 				 , p_input_file     IN    VARCHAR2
 				 , p_dir_path       IN    VARCHAR2
 				 );

  -- Procedure to validate the statement loaded into the staging table
  -- returns 0 if loaded successfully, >0 otherwise along with error message.

  PROCEDURE    validate_bank_stmt( x_error_message OUT VARCHAR2
				 , x_error_code    OUT NUMBER);


  -- Procedure to load data from staging table to Cash managment interface tables.
  -- returns 0 if loaded successfully, >0 otherwise along with error message.

  PROCEDURE	interface_XX_HSH_bank_stmt_std( x_error_message OUT VARCHAR2
 				           , x_error_code    OUT NUMBER
                                              );

   -- Procedure to write message in log file.
  PROCEDURE	write_log( p_message	IN VARCHAR2
 			 );

  -- Procedure to debug messages to log file
  PROCEDURE	write_debug( p_message	IN VARCHAR2
 			   );

  -- Procedure to write message on output file.
  PROCEDURE	write_out( p_message	IN VARCHAR2
 			 );

  -- Procedure to submit a request
  PROCEDURE submit_conc_request( p_application  IN   VARCHAR2
			       , p_program	IN   VARCHAR2
			       , p_sub_request  IN   BOOLEAN
			       , p_parameter1   IN   VARCHAR2
			       , p_parameter2	IN   VARCHAR2
			       , p_parameter3	IN   VARCHAR2
			       , p_parameter4	IN   VARCHAR2
			       , p_parameter5   IN   VARCHAR2
			       , p_parameter6	IN   VARCHAR2
			       , p_parameter7	IN   VARCHAR2
			       , p_parameter8	IN   VARCHAR2
			       , p_parameter9   IN   VARCHAR2
			       , p_parameter10	IN   VARCHAR2
			       , p_parameter11	IN   VARCHAR2
			       , P_PARAMETER12	IN   VARCHAR2
			       , p_parameter13  IN   VARCHAR2
             , p_parameter14	IN   VARCHAR2
			       , P_PARAMETER15	IN   VARCHAR2
             , p_parameter16	IN   VARCHAR2
			       , x_request_id   OUT  NUMBER
			       );

  -- Procedure to wait for a request to complete and find the code of its completion.
  PROCEDURE wait_conc_request ( p_request_id	IN 	NUMBER
	           	      , p_description	IN      VARCHAR2
			      , x_phase		OUT	VARCHAR2
			      , x_code		OUT	VARCHAR2
			      );


  -- procedure  to get bank name, branch name and currency for SQLLOADER call.
  PROCEDURE  get_bank_ac_details( p_sort_code 	       IN	VARCHAR2
                                , p_bank_account_num   IN	VARCHAR2
                                , x_bank_name	       OUT	VARCHAR2
                                , x_branch_name        OUT	VARCHAR2
                                , x_currency_code      OUT	VARCHAR2
                                );


  G_DEBUG_MODE	BOOLEAN      DEFAULT 	FALSE;
  G_USER_ID	NUMBER	     DEFAULT	FND_PROFILE.VALUE('USER_ID');
  G_ORG_ID	NUMBER	     DEFAULT	FND_PROFILE.VALUE('ORG_ID');
  G_CUR_CODE	VARCHAR2(30) DEFAULT    NULL;

  l_request_id	NUMBER	     DEFAULT 	0;
  l_phase	VARCHAR2(30);
  l_code	VARCHAR2(30);

  fileloc	VARCHAR2(100) := 'G:\11i\prdcomn\admin\out\PRD_dubvmpof01\Payments';

END  XX_HSH_STMT_INTERFACE_PKG;
/


CREATE OR REPLACE PACKAGE BODY XX_HSH_STMT_INTERFACE_PKG
IS
--+==========================================================================+
--| Name:         XX_HSH_STMT_INTERFACE_PKGBODY			     |
--| Description:  XX_HSH_STMT_INTERFACE_PKGbody contains the  definition |
--|               of procedures/functions used in bank statement upload into |
--|		  Oracle Cash Management.			             |
--+==========================================================================+




--=============================================================================


  -- Main procedure which will be run on the submission of the concurrent request

  PROCEDURE 	bank_statement_load ( errbuf        	OUT    VARCHAR2
                                    , retcode       	OUT    NUMBER
                                    , p_input_file  	IN     VARCHAR2
                                    , p_debug       	IN     VARCHAR2
                                    , p_option	    	IN     VARCHAR2
                                    , p_Bank_Branch 	IN     VARCHAR2
                                    , p_Bank_Account	IN     VARCHAR2
                                    , p_stmt_from	IN     VARCHAR2
                                    , p_stmt_to	        IN     VARCHAR2
                                    , p_stmt_date_from	IN     VARCHAR2
                                    , p_stmt_date_to    IN     VARCHAR2
                                    , p_gl_date		IN     VARCHAR2
                                    , P_ar_activity     IN     VARCHAR2
                                    , p_payment_method  IN     VARCHAR2
                                    , p_nsf_handling    IN     VARCHAR2
                                    , p_display_debug 	IN     VARCHAR2
                                    , p_debug_path 	IN     VARCHAR2
                                    , p_debug_file	IN     VARCHAR2
                                    ) IS

  l_error_message		VARCHAR2(1000);
  l_error_code			NUMBER;
  l_org_name			HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
  l_bank_branch			AP_BANK_BRANCHES.BANK_BRANCH_ID%TYPE;
   X_bank_branch			AP_BANK_BRANCHES.BANK_BRANCH_ID%TYPE;

  l_file_ext			varchar2(50);
  l_records              number;

  e_bank_stmt_load_failed	EXCEPTION;
  e_backup			EXCEPTION;
  e_autorec_failed		EXCEPTION;

CURSOR C_BANK_ID is      SELECT ABB.BRANCH_party_ID BANK_BRANCH_ID
                           FROM   XX_HSH_STMT_LINES_INTERFACE ISL,
                                  CE_BANK_ACCOUNTS ABA,
                                  CE_BANK_BRANCHES_V abb
                           WHERE  ISL.BANK_ACCOUNT_NUM = ABA.BANK_ACCOUNT_NUM
                           AND    ABA.BANK_BRANCH_ID   	     = ABB.BRANCH_party_ID
                           AND    ISL.BANK_ACCOUNT_NUM           IS NOT NULL
                           GROUP BY                        ABB.BRANCH_PARTY_ID;


BEGIN

     fileloc :=  FND_PROFILE.VALUE('AWAS_CE_STMT_DIR');

  IF p_debug = 'Y' THEN
    G_DEBUG_MODE := TRUE;
  ELSE
    G_DEBUG_MODE := FALSE;
  END IF;


  -- Display concurrent Program Paramteres
  write_debug('**************************** Concurrent Program Parameters ****************************');
  write_debug('p_input_file -> '||p_input_file);
--  write_debug('p_dir_path   -> '||p_dir_path);
  write_debug('p_debug      -> '||p_debug);
--  write_debug('p_backup_dir -> '||p_backup_dir);
  write_debug('**************************** End of Concurrent program parameters **********************');


  write_debug('bank_statement_load -> Starting...');

  -- Get org Name
  BEGIN
  write_debug('bank_statement_load -> Fetch l_org_name');
    SELECT substr(name ,1,30)
    INTO   l_org_name
    FROM   hr_all_organization_units
    WHERE  organization_id = G_ORG_ID;
  write_debug('bank_statement_load ->  fetch of l_org_name successful. l_org_name:'||l_org_name);
  EXCEPTION

    WHEN OTHERS THEN
      write_log('Error in fetching the organization name');

  END;


  Write_out(l_org_name||'            HSH - Bank Statement Upload Execution Report             '||to_char(SYSDATE,'DD-MON-YYYY HH:MI:SS'));
  Write_out('-----------------------------------------------------------------------------------------------');
  write_out('');


  -- Initialize the sequenuce for line number with one
 BEGIN

  write_debug('bank_statement_load-> Recreating the sequences... ');
  EXECUTE IMMEDIATE 'DROP SEQUENCE    XX_HSH_stmt_lines_interface_s';
  EXECUTE IMMEDIATE 'CREATE SEQUENCE  XX_HSH_STMT_LINES_INTERFACE_S START WITH 1';
  write_debug('bank_statement_load->sequences created..');

 EXCEPTION
   WHEN OTHERS THEN
     retcode := 2;
     errbuf  := 'Error in rebuilding the sequence XX_HSH_STMT_LINES_INTERFACE_S. '||sqlerrm;
 END;

   -- Load the statements into cash management


 -- Seperate statments by Bank ie XX_WT for Deustch Bank
    	  l_file_ext := '\XX_HSH';

            --Fetching Bank Branch Name from the file



   write_debug('bank_statement_load -> calling XX_HSH_bank_stmt_load');

   XX_HSH_bank_stmt_load( l_error_message
                        , l_error_code
                        , p_input_file
                        , fileloc
                        );

 write_debug('bank_statement_load ->returned from XX_HSH_bank_stmt_load');



 IF l_error_code <> 0 THEN
     raise e_bank_stmt_load_failed;
 Else

     Write_out('Bank statement file transfer to Cash Management is Successful');
     Write_out('');

   /*
    -- utl file copy to move the file
      write_debug('p_dir_path-   '||fileloc || l_file_ext);
      write_debug('p_backup_dir- '||fileloc || '\BACKUP');
      write_debug('p_input_file- '||p_input_file);

     UTL_FILE.FCOPY(fileloc || l_file_ext, p_input_file, fileloc || '\BACKUP', p_input_file||'LOADED');
     write_debug('MID');
     UTL_FILE.FREMOVE(fileloc || l_file_ext, p_input_file);


     Write_out('Backup of the file is successful.');

     */
     IF p_option <> 'LOAD' THEN



     BEGIN
                SELECT count(*)
                into l_records
                FROM   XX_HSH_STMT_LINES_INTERFACE;
               EXCEPTION
               WHEN OTHERS THEN
                    Write_out ( 'WARNING! Unable to fetch Bank Branch Name. Could not submit Bank Statement Import and AutoReconciliation Program ' ) ;
                    l_error_message := 'Failed to submit request Bank Statement Import and AutoReconciliation Program ' ;
                    raise e_autorec_failed;
               END;


        if l_records = 0 then
        write_debug('bank_statement_load-> No records loaded')  ;
        Write_out ( 'WARNING! There were no records loaded from the statement file.' ) ;
        retcode :=1;
        errbuf:= 'No Statement lines to process';
        write_out('');
        Write_out('                                   ****End of Report****');

        else



        FOR r1 IN c_bank_id
        LOOP



        l_bank_branch := r1.bank_branch_id;


               submit_conc_request ( p_application => 'CE'
                                   , p_program => 'ARPLABIR'
                                   , p_sub_request => TRUE
                                   , p_parameter1 => p_option
                                   , p_parameter2 => l_bank_branch
                                   , p_parameter3 => p_Bank_Account
                                   , P_PARAMETER4 => P_STMT_FROM
                                   , P_PARAMETER5 => P_STMT_TO
                                   , P_PARAMETER6 => TO_CHAR ( TO_DATE ( SUBSTR ( P_STMT_DATE_FROM, 1, 10 ), 'RRRR/MM/DD' ), 'RRRR-MON-DD' )
                                   , P_PARAMETER7 => TO_CHAR ( TO_DATE ( SUBSTR ( P_STMT_DATE_TO, 1, 10 ), 'RRRR/MM/DD' ), 'RRRR-MON-DD' )
                                   , P_PARAMETER8 => TO_CHAR ( TO_DATE ( SUBSTR ( P_GL_DATE, 1, 10 ), 'RRRR/MM/DD' ), 'RRRR-MON-DD' )
                                   , P_PARAMETER9 => NULL
                                   , P_PARAMETER10 => NULL
                                   , P_PARAMETER11 => P_AR_ACTIVITY
                                   , P_PARAMETER12 => P_PAYMENT_METHOD
                                   , P_PARAMETER13 => P_NSF_HANDLING
                                   , P_PARAMETER14 => P_DISPLAY_DEBUG
                                   , P_PARAMETER15 => P_DEBUG_PATH
                                   , P_PARAMETER16 => P_DEBUG_FILE
                                   , x_request_id => l_request_id ) ;

      -- wait till the Standard Cash management auto reconcilation program is completed
        IF l_request_id <>0 THEN
        wait_conc_request( l_request_id
     		   , 'Wait for bank statement loader program to complete'
     		   , l_phase
     		   , l_code
                   );
        ELSE
          l_error_message:= 'Failed to submit request Bank Statement Import and AutoReconciliation Program ' ;
          raise e_autorec_failed;
        END IF;
     -----------------------------------------------------------------------------------------------------

          write_out('');
          write_out('Bank Statement Import and AutoReconciliation Program completed.');
          write_out('Check the output and/or logfile of the request:'|| l_request_id);



      end LOOP;



     END IF;



     write_out('');
     write_out('');
     Write_out('                                   ****End of Report****');

     end if;
     END IF;



EXCEPTION

 WHEN e_bank_stmt_load_failed THEN
      write_debug('bank_statement_load-> When e_bank_stmt_load_failed exception raised');
      write_out('Bank statement load failed.');
      retcode :=2;
      errbuf:= l_error_message;
      write_out('');
      Write_out('                                   ****End of Report****');
WHEN  e_autorec_failed THEN
      write_debug('bank_statement_load-> When e_bank_stmt_load_failed exception raised');
      write_out('Bank statement load failed.');
      retcode :=2;
      errbuf:= l_error_message;
      write_out('');
      Write_out('                                   ****End of Report****');

 WHEN OTHERS THEN
     write_debug('bank_statement_load-> When Others exception raised')  ;
     write_log(Sqlerrm);
     retcode :=2;
     errbuf:= l_error_message;
     write_out('');
     Write_out('                                   ****End of Report****');



END bank_statement_load;
--=============================================================================


--=============================================================================

--Procedure which will upload XX_DB Bank format file into Oracle Cash Management

 PROCEDURE    XX_HSH_bank_stmt_load( x_error_message   OUT   VARCHAR2
                                  , x_error_code	    OUT   NUMBER
                                  , p_input_file      IN    VARCHAR2
                                  , p_dir_path        IN    VARCHAR2
                                  )
 IS

   l_error_message	VARCHAR2(1000);
   l_error_code		NUMBER;

   e_return_error	EXCEPTION;

 BEGIN

  write_debug('XX_HSH_bank_stmt_load -> Begining of procedure');


   submit_conc_request( p_application         =>'CE'
                      , p_program             =>'CESLRPROHSH'
                      , P_SUB_REQUEST         => FALSE
                      , p_parameter1  	    => p_dir_path||'/'||p_input_file
                      , p_parameter2	    => NULL
                      , p_parameter3	    => NULL
                      , p_parameter4	    => NULL
                      , p_parameter5	    => NULL
                      , p_parameter6	    => NULL
                      , p_parameter7	    => NULL
                      , p_parameter8	    => NULL
                      , p_parameter9	    => NULL
                      , p_parameter10	    => NULL
                      , p_parameter11	    => NULL
                      , p_parameter12	    => NULL
                      , p_parameter13	    => NULL
                      , P_PARAMETER14	    => NULL
                      , p_parameter15	    => NULL
                      , p_parameter16	    => NULL
                      , x_request_id	    =>l_request_id
               	      );

   -- wait till the sqlloader program is completed
   IF l_request_id <>0 THEN

   wait_conc_request( l_request_id
                    , 'Wait for bank statement loader program to complete'
                    , l_phase
                    , l_code
                    );
   ELSE
     x_error_message:= 'Failed to submit request to load XX_HSH Bank Statement' ;
     raise e_return_error;
   END IF;


   write_log('XX_HSH_bank_stmt_load -> after waiting for the request');

   IF ((l_phase ='Completed') AND (l_code in ('Normal','Warning'))) THEN
     write_log('Bank statement Uploaded into the staging tables completed with a status of '||l_code);


     -- validate and load this data into the standard open interface tables.
     validate_bank_stmt( l_error_message
                       , l_error_code );

     write_debug('Bank statement Validated with error code:(0-no errors)'|| l_error_code);

     IF l_error_code = 0 THEN

         interface_XX_HSH_bank_stmt_std( l_error_message
                                      , l_error_code);


         IF l_error_code <> 0 THEN
            write_debug('Failed trasferring data to standard tables');
            x_error_message := 'Failed trasferring data to standard tables';
            raise e_return_error;
         ELSE
            write_debug('XX_HSH Bank Statement loaded into the standard interface tables successfully.');

         END IF;
     ELSE
       x_error_message	:= 'Error: Bank statement validation failed. Action: Please Correct the errors and resubmit the request';
       raise e_return_error;

     END IF;


  ELSE
    x_error_message	:= 'Error: Bank Statement Load failed. Action: Please look at the log file for errors';
    raise e_return_error;

  END IF;
  x_error_code :=0;

 EXCEPTION

  WHEN e_return_error THEN
      x_error_code	:= 2;

 END XX_HSH_bank_stmt_load;
 --=============================================================================





  -- Procedure to validate  bank statement
  --=============================================================================
  PROCEDURE    validate_bank_stmt(x_error_message OUT VARCHAR2,
                                  x_error_code  OUT NUMBER)
  IS

    CURSOR bank_stmt_headers_cur IS
   	SELECT BANK_ACCOUNT_NUM, ASCII(BANK_ACCOUNT_NUM)
    FROM  XX_HSH_STMT_LINES_INTERFACE ISH
    WHERE  BANK_ACCOUNT_NUM IS NOT NULL
    AND    NOT EXISTS (SELECT 1
		   	   FROM   CE_BANK_ACCOUNTS ABA,
                  CE_BANK_BRANCHES_V     ABB
			   WHERE  ABA.BANK_BRANCH_ID   = ABB.BRANCH_PARTY_ID
         AND	ABA.BANK_ACCOUNT_NUM = ISH.BANK_ACCOUNT_NUM );


    CURSOR  trx_code_valid_cur IS
    SELECT  DISTINCT TRX_CODE, BANK_ACCOUNT_NUM
    FROM    XX_HSH_STMT_LINES_INTERFACE ISL
    WHERE   BANK_ACCOUNT_NUM IS NOT NULL
    AND     NOT EXISTS 	   (SELECT 1 	    FROM   CE_TRANSACTION_CODES CTC
                                               , CE_BANK_ACCOUNTS AAA
                            WHERE  CTC.BANK_ACCOUNT_ID  =  AAA.BANK_ACCOUNT_ID
                            AND    AAA.BANK_ACCOUNT_NUM =  ISL.BANK_ACCOUNT_NUM
                            AND    TRX_CODE  	      =  ISL.TRX_CODE)
    ORDER BY 2;

    CURSOR NULL_AMOUNTS_CUR  IS
    SELECT COUNT(1)
    FROM  XX_HSH_STMT_LINES_INTERFACE
    WHERE  AMOUNT IS NULL
    AND    BANK_ACCOUNT_NUM IS NOT NULL;



    L_HEADER 		  BANK_STMT_HEADERS_CUR%ROWTYPE;
    L_TRX_CODE_VALID 	  TRX_CODE_VALID_CUR%ROWTYPE;
    L_ZERO_AMOUNTS	  NUMBER DEFAULT 0;
    L_ERROR_COUNT	  NUMBER DEFAULT 0;


  BEGIN


    delete XX_HSH_STMT_LINES_INTERFACE where trx_code is null;


           update XX_HSH_STMT_LINES_INTERFACE
           set trx_code = (case when amount >= 0 then trx_code||'DR' else trx_code||'CR' end );


           update XX_HSH_STMT_LINES_INTERFACE
           set trx_text = attribute3||attribute4||attribute5||attribute6
           where trx_text = 'NONREF';

           commit;

    write_debug('validate_bank_stmt -> Start of procedure');
    x_error_code       := 0;
    l_error_count      := 0;

    -- validating the bank account number

    write_debug('validate_bank_stmt -> Start validating the bank account number');
    OPEN   bank_stmt_headers_cur;

    FETCH  bank_stmt_headers_cur INTO l_header;
    write_debug('validate_bank_stmt -> after fetch records from bank_stmt_headers_cur');

    IF  bank_stmt_headers_cur%NOTFOUND THEN

      write_debug('validate_bank_stmt -> Correct Bank account Numbers');

    ELSE
      write_out('');
      write_out('The following Bank account number(s) does not exist');
      LOOP

      write_out(l_header.bank_account_num);
      FETCH  bank_stmt_headers_cur INTO l_header;

      EXIT WHEN bank_stmt_headers_cur%NOTFOUND;

    END LOOP;


      x_error_message := x_error_message||'Bank Account not defined in Oracle Accounts Payable.';
      l_error_count   := l_error_count+1;
      write_log('validate_bank_stmt -> Incorrect Bank account numbers exists');

    END IF;

    CLOSE bank_stmt_headers_cur;

    write_debug('validate_bank_stmt -> End validating bank account number');


    -- validating the trx_code from

    OPEN trx_code_valid_cur;

    FETCH trx_code_valid_cur into l_trx_code_valid;

    IF  trx_code_valid_cur%NOTFOUND THEN

      write_debug('validate_bank_stmt ->  Correct transaction codes');

    ELSE
    write_out('');
    write_out('The following bank transaction codes do not exist');

    LOOP

      write_out('Bank Account->'||l_trx_code_valid.bank_account_num||'  Transaction Code -> '||l_trx_code_valid.trx_code);
      FETCH trx_code_valid_cur into l_trx_code_valid;
      EXIT WHEN trx_code_valid_cur%notfound;

    END LOOP;

      x_error_message := x_error_message||' Incorrect transaction codes';
      l_error_count   := l_error_count+1;
      write_debug('validate_bank_stmt -> Incorrect transaction codes.');
        write_out('Error: Bank statement contains invalid transaction codes');

    END IF;

    CLOSE trx_code_valid_cur;
    write_debug('validate_bank_stmt -> End of validation of Trx_code');


    -- Validate if the amount for any of the columns is Zero
    write_debug('validate_bank_stmt -> Start of procedure');
    OPEN null_amounts_cur;

    FETCH null_amounts_cur  INTO l_zero_amounts;

    IF  l_zero_amounts = 0 THEN

      write_debug('No Bank statement lines with Null Amounts');

    ELSE

      write_out('Error: Bank statement contains lines with NULL amounts');

      x_error_message := x_error_message||' Banks statement lines exists with NULL values.';
      l_error_count   := l_error_count+1;
      write_debug('Error: Amount Cannot be null in the bank statement lines ');

    END IF;

    CLOSE null_amounts_cur;

    write_debug('validate_bank_stmt -> l_error_count:'||l_error_count);




    IF  l_error_count <> 0 THEN

      x_error_code := 2;

    ELSE

      x_error_code  :=0;

    END IF;

    write_debug('validate_bank_stmt -> exit procedure');

EXCEPTION

WHEN OTHERS THEN

   x_error_code :=2;
   x_error_message:= 'Error:'||SQLERRM;
   write_debug('validate_bank_stmt -> When Others exception');

END validate_bank_stmt;


--=============================================================================


--=============================================================================

PROCEDURE	interface_XX_HSH_bank_stmt_std( x_error_message OUT VARCHAR2
                                       , x_error_code    OUT NUMBER
                                       )
IS



    CURSOR C_STMT_HEADER is
       select distinct bank_account_num,
                                          to_char(posting_date,'RRRR')||'-'||lpad(statement_number, 3,'0') statement_number,
                                          posting_date statement_date,
                                          control_begin_balance,
                                          control_end_balance,
                                          control_total_dr,
                                          control_total_cr,
                                          control_line_count,
                                          original_currency currency_code,
                                          85 org_id
                                          from XX_HSH_STMT_LINES_INTERFACE where line_number = 1;

      cursor C_STMT_HEADER_REAL IS
                       SELECT            X.bank_account_num,
                                         X.statement_number,
                                         X.statement_date,
                                         X.control_begin_balance,
                                         X.control_end_balance,
                                         X.control_total_dr,
                                         X.control_total_cr,
                                         X.CONTROL_LINE_COUNT,
                                         85,
                                         ABB.BANK_NAME,
                                         ABB.BANK_BRANCH_NAME,
                                         ABA.CURRENCY_CODE,
                                         ABA.BANK_ACCOUNT_ID
                      FROM XX_HSH_STMT_HEADER_IF_ALL X,
                           CE_BANK_ACCOUNTS ABA,
                           CE_BANK_BRANCHES_V ABB
                      WHERE  X.BANK_ACCOUNT_NUM = ABA.BANK_ACCOUNT_NUM
                      and aba.account_owner_org_id = 85
                      AND    ABA.BANK_BRANCH_ID   = ABB.BRANCH_PARTY_ID
                           ;





  L_STATEMENT_HEADER	C_STMT_HEADER%ROWTYPE;
  L_STMT_HEADER_REAL	C_STMT_HEADER_REAL%ROWTYPE;
  L_STATMENT_EXISTS	CHAR(1) DEFAULT 'N';
  l_STMT_NUM		NUMBER;

BEGIN

  write_debug('interface_XX_HSH_bank_stmt_std-> Begining of the procedure');

  delete xx_hsh_stmt_header_if_all;
  commit;

  OPEN  C_STMT_header;

  LOOP
    FETCH C_STMT_HEADER INTO L_STATEMENT_HEADER;

    EXIT WHEN C_STMT_HEADER%NOTFOUND;


  insert into xx_hsh_stmt_header_if_all (bank_account_num,
                                         statement_number,
                                         statement_date,
                                         control_begin_balance,
                                         control_end_balance,
                                         control_total_dr,
                                         control_total_cr,
                                         control_line_count,
                                         currency_code,
                                         org_id)
                                         values
                                         (L_STATEMENT_HEADER.bank_account_num,
                                          L_STATEMENT_HEADER.statement_number,
                                          L_STATEMENT_HEADER.STATEMENT_DATE,
                                          L_STATEMENT_HEADER.control_begin_balance,
                                          L_STATEMENT_HEADER.control_end_balance,
                                          L_STATEMENT_HEADER.control_total_dr,
                                          L_STATEMENT_HEADER.control_total_cr,
                                          L_STATEMENT_HEADER.control_line_count,
                                          L_STATEMENT_HEADER.currency_CODE,
                                          L_STATEMENT_HEADER.ORG_ID
                                          );



    END LOOP;
  close  C_STMT_header;


            update XX_HSH_STMT_LINES_INTERFACE
            set statement_number = to_char(posting_date,'RRRR')||'-'||lpad(statement_number, 3,'0');


  commit;


  OPEN  C_STMT_HEADER_REAL;

  LOOP
    FETCH C_STMT_HEADER_REAL INTO L_STMT_HEADER_REAL;

    EXIT WHEN C_STMT_HEADER_REAL%NOTFOUND;

     -- GENERATE STATEMENT NUMBER

      INSERT INTO
        --CE_STATEMENT_HEADERS_INT_ALL  --R11
        CE_STATEMENT_HEADERS_INT  --R12
        	  ( STATEMENT_NUMBER
        	  , BANK_ACCOUNT_NUM
        	  , BANK_NAME
        	  , BANK_BRANCH_NAME
        	  , STATEMENT_DATE
                  , CURRENCY_CODE
                  , ORG_ID
                  , CONTROL_TOTAL_DR
                  , CONTROL_TOTAL_CR
                  , control_begin_balance
                  , control_end_balance
                  , CONTROL_LINE_COUNT
                  , RECORD_STATUS_FLAG
                  , CREATED_BY
                  , CREATION_DATE
                  , LAST_UPDATED_BY
                  , LAST_UPDATE_DATE
                  )
         VALUES   (L_STMT_HEADER_REAL.STATEMENT_NUMBER
         	  ,L_STMT_HEADER_REAL.BANK_ACCOUNT_NUM
         	  ,L_STMT_HEADER_REAL.BANK_NAME
         	  ,L_STMT_HEADER_REAL.BANK_BRANCH_NAME
         	  ,L_STMT_HEADER_REAL.STATEMENT_DATE
         	  ,L_STMT_HEADER_REAL.CURRENCY_CODE
         	  ,G_ORG_ID
         	  ,L_STMT_HEADER_REAL.CONTROL_TOTAL_DR
         	  ,L_STMT_HEADER_REAL.CONTROL_TOTAL_CR
            ,L_STMT_HEADER_REAL.CONTROL_BEGIN_BALANCE
            ,L_STMT_HEADER_REAL.CONTROL_END_BALANCE
            ,L_STMT_HEADER_REAL.CONTROL_LINE_COUNT
         	  ,'N'
         	  ,G_USER_ID
         	  ,SYSDATE
         	  ,G_USER_ID
         	  ,SYSDATE
         	  );


  INSERT INTO CE_STATEMENT_LINES_INTERFACE
  	   		( BANK_ACCOUNT_NUM
  			, STATEMENT_NUMBER
  			, LINE_NUMBER
  			, CURRENCY_CODE
  			, AMOUNT
  			, BANK_TRX_NUMBER
  			, TRX_DATE
  			, TRX_CODE
  			, TRX_TEXT
  			, CREATED_BY
  			, CREATION_DATE
  			, LAST_UPDATED_BY
  			, LAST_UPDATE_DATE
        , CUSTOMER_TEXT
  			)
  SELECT  L.BANK_ACCOUNT_NUM
  			, L.STATEMENT_NUMBER
  			, L.LINE_NUMBER
  			, L.CURRENCY_CODE
  			, ABS(L.AMOUNT)
  		  , L.BANK_TRX_NUMBER
  			, L.TRX_DATE
  			, L.TRX_CODE
  			, trx_text
  			, G_USER_ID
  			, SYSDATE
  			, G_USER_ID
  			, SYSDATE
        , L.CUSTOMER_TEXT
  FROM 		XX_HSH_STMT_LINES_INTERFACE  L
  WHERE		L.BANK_ACCOUNT_NUM    = L_STMT_HEADER_REAL.BANK_ACCOUNT_NUM
  and     L.STATEMENT_NUMBER = L_STMT_HEADER_REAL.STATEMENT_NUMBER;

 WRITE_LOG('No of statement lines for the Bank account: '||L_STMT_HEADER_REAL.BANK_ACCOUNT_NUM||' '||sql%rowcount);

  END LOOP;
  close  C_STMT_HEADER_REAL;

  write_debug('interface_XX_HSH_bank_stmt_std->  End of procedure');

  EXCEPTION
    WHEN OTHERS THEN
      write_log('Error in inserting into Standard interface tables');
      write_out('Sql Error: '||sqlerrm);

      ROLLBACK;
      x_error_code := 2;
      x_error_message:= 'Error in inserting records into Cash Management tables';
      close  C_STMT_HEADER_REAL;

END interface_XX_HSH_bank_stmt_std;

--=============================================================================




--=============================================================================


-- Procedure to write message in log file.

PROCEDURE	write_log( p_message	IN VARCHAR2
 			 )
IS

  l_message 	VARCHAR2(100);

BEGIN

  l_message  := SUBSTR(p_message,1,100);
  fnd_file.put_line( fnd_file.log, l_message );

END  write_log;
--=============================================================================


--=============================================================================


 -- Procedure to debug messages to log file
 PROCEDURE	write_debug( p_message	IN VARCHAR2
 			 )
IS
BEGIN

 IF G_debug_mode THEN

    fnd_file.put_line( fnd_file.log, p_message );

 END IF;

END write_debug;

--=============================================================================


--=============================================================================

-- Procedure to write message on output file.

 PROCEDURE	write_out( p_message	IN VARCHAR2
  			 )
IS

  l_message 	VARCHAR2(100);

BEGIN

  l_message  := SUBSTR(p_message,1,100);

  fnd_file.put_line( fnd_file.output, l_message );

END write_out;
--=============================================================================

--=============================================================================


 PROCEDURE  get_bank_ac_details( p_sort_code 	     IN	 	VARCHAR2
                               , p_bank_account_num  IN	 	VARCHAR2
                               , x_bank_name	     OUT	VARCHAR2
                               , x_branch_name       OUT	VARCHAR2
                               , x_currency_code     OUT	VARCHAR2)
 IS
 BEGIN

   write_debug('get_bank_ac_details -> Start');
   write_debug('get_bank_ac_details -> sort_code:'||p_sort_code);
   write_debug('get_bank_ac_details -> bank_account_number:'||p_bank_account_num);

   SELECT    abaa.currency_code
    	   , abb.bank_name
    	   , abb.bank_branch_name
   INTO      x_currency_code
           , x_bank_name
           , x_branch_name
   FROM      CE_BANK_ACCOUNTS  ABAA,
             CE_BANK_BRANCHES_V      ABB
   WHERE     abaa.BANK_BRANCH_ID   = abb.branch_party_id
   AND       ABAA.BANK_ACCOUNT_NUM = P_BANK_ACCOUNT_NUM
   AND       abb.branch_number          = p_sort_code;

   write_debug('get_bank_ac_details -> x_bank_name:'||x_bank_name);
   write_debug('get_bank_ac_details -> x_branch_name:'||x_branch_name );
   write_debug('get_bank_ac_details -> x_currency_code: '||x_currency_code);

   write_debug('get_bank_ac_details -> end');

EXCEPTION

 WHEN OTHERS THEN
    x_bank_name   	:= NULL;
    x_branch_name 	:= NULL;
    x_currency_code	:= NULL;
    write_debug('Error in fetching the Bank Details'||sqlerrm);

 END;

  --=============================================================================


-- Procedure to submit a request
  PROCEDURE submit_conc_request( p_application  IN   VARCHAR2
			       , p_program	IN   VARCHAR2
			       , p_sub_request  IN   BOOLEAN
			       , p_parameter1   IN   VARCHAR2
			       , p_parameter2	IN   VARCHAR2
			       , p_parameter3	IN   VARCHAR2
			       , p_parameter4	IN   VARCHAR2
			       , p_parameter5   IN   VARCHAR2
			       , p_parameter6	IN   VARCHAR2
			       , p_parameter7	IN   VARCHAR2
			       , p_parameter8	IN   VARCHAR2
			       , p_parameter9   IN   VARCHAR2
			       , p_parameter10	IN   VARCHAR2
			       , p_parameter11	IN   VARCHAR2
			       , p_parameter12	IN   VARCHAR2
			       , p_parameter13  IN   VARCHAR2
			       , P_PARAMETER14	IN   VARCHAR2
             , P_PARAMETER15	IN   VARCHAR2
             , p_parameter16	IN   VARCHAR2
			       , x_request_id   OUT  NUMBER
			       )
IS
BEGIN

  write_Debug('submit_conc_request -> begining');

  x_request_id := FND_REQUEST.SUBMIT_REQUEST
             (  application=>p_application
              , program    =>p_program
              , sub_request=>FALSE
              , argument1  =>p_parameter1
              , argument2  =>p_parameter2
              , argument3  =>p_parameter3
              , argument4  =>p_parameter4
              , argument5  =>p_parameter5
	      , argument6  =>p_parameter6
	      , argument7  =>p_parameter7
	      , argument8  =>p_parameter8
              , argument9  =>p_parameter9
	      , argument10  =>p_parameter10
	      , argument11  =>p_parameter11
	      , argument12  =>p_parameter12
              , argument13  =>p_parameter13
	      , argument14  =>p_parameter14
        , ARGUMENT15  =>P_PARAMETER15
        , argument16  =>p_parameter16
	      );

  IF x_request_id = 0 THEN
     ROLLBACK;
  ELSE
     COMMIT;
  END IF;
  write_Debug('submit_conc_request -> request_id :'|| x_request_id);
  write_Debug('submit_conc_request -> end');

END submit_conc_request;



--=============================================================================


--=============================================================================

-- Procedure to wait for a request to complete and find the code of its completion.

PROCEDURE wait_conc_request ( p_request_id		IN 	NUMBER
			    , p_description	IN      VARCHAR2
			 , x_phase		OUT	VARCHAR2
			 , x_code		OUT	VARCHAR2
			 )
IS
  l_request_code             BOOLEAN	DEFAULT FALSE;
  l_dev_phase				   VARCHAR2(30);
  l_dev_code				   VARCHAR2(30);
  l_sleep_time				   NUMBER DEFAULT 15;
  l_message				   VARCHAR2(100) ;

BEGIN
 write_debug('wait_conc_request -> begining');
 write_debug('Waiting for ' || p_description || ' request to complete.');
 l_request_code := FND_CONCURRENT.WAIT_FOR_REQUEST(p_request_id
                                                  ,l_Sleep_Time
                                                  ,0
                                                  ,x_Phase
                                                  ,x_code
                                                  ,l_dev_phase
                                                  ,l_dev_code
                                                  ,l_Message);
      write_Debug ('Completion code details are :- ');
	  write_Debug ('Phase      -> '||x_Phase );
	  write_Debug ('code       -> '||x_code );
	  write_Debug ('Dev Phase  -> '||l_dev_phase);
	  write_Debug ('Dev code   -> '||l_dev_code);
	  write_Debug ('Message    -> '||l_Message);

 write_debug('wait_conc_request -> End');

END wait_conc_request;


--=============================================================================


 END XX_HSH_STMT_INTERFACE_PKG;
/
