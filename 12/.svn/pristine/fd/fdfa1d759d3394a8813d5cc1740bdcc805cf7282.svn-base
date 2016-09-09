CREATE OR REPLACE PACKAGE        "XX_AP_SERENGETI_INVOICES_PKG" AS
/*******************************************************************************
PACKAGE NAME : XX_AP_SERENGETI_INVOICES_PKG
CREATED BY   : Simon Joyce
DATE CREATED : 13-May-2016
--
PURPOSE      : Load AP Invoices from Serengeti
--
MODIFICATION HISTORY
--------------------
--
DATE       WHO?       DETAILS                              DESCRIPTION
---------- ---------  -----------------------------------  ---------------------
13-05-2016 SJOYCE     Initial Version
*******************************************************************************/

     G_DEBUG_MODE BOOLEAN DEFAULT FALSE;
     G_USER_ID    NUMBER DEFAULT FND_PROFILE.VALUE ( 'USER_ID' ) ;
     G_ORG_ID     NUMBER DEFAULT FND_PROFILE.VALUE ( 'ORG_ID' ) ;
     G_CUR_CODE   VARCHAR2 ( 30 ) DEFAULT NULL;
     G_REQUEST_ID NUMBER;
     L_REQUEST_ID NUMBER DEFAULT 0;
     l_phase      VARCHAR2 ( 30 ) ;
     L_CODE       VARCHAR2 ( 30 ) ;
     fileloc      VARCHAR2 ( 150 ) ;
     
PROCEDURE INVOICE_LOAD
     (    x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER
         ) ;
         
          
end XX_AP_SERENGETI_INVOICES_PKG;
/


CREATE OR REPLACE PACKAGE BODY        "XX_AP_SERENGETI_INVOICES_PKG" AS

G_SFTP_REQUEST_ID  number;
function get_tax_details(P_INVOICE_DATE date, P_PC_RATE number, P_COUNTRY varchar2)
return varchar2;

CURSOR IF_BATCH(p_request_id NUMBER, p_file_name VARCHAR2)
IS
       (
               SELECT batch_id
                   , batch_date
                   , created_by_name
                   , status
                 FROM xx_ap_invoice_batch_if
                WHERE request_id = p_request_id
                 AND filename    = p_file_name
       )
;

CURSOR IF_HEADER(p_request_id NUMBER, p_batch_id VARCHAR2)
IS
       (
               SELECT vendor_name
                   , vendor_site_id
                   , invoice_number
                   , invoice_date
                   , invoice_currency
                   , invoice_amount
                   , invoice_id
                   , status
                 FROM xx_ap_invoice_header_if
                WHERE request_id = p_request_id
                 AND batch_id    = p_batch_id
       )
;

CURSOR IF_LINES(p_request_id NUMBER, p_invoice_id NUMBER)
IS
       (
               SELECT entity
                     ||'.'
                     ||account
                     ||'.'
                     ||cost_centre
                     ||'.'
                     ||msn
                     ||'.'
                     ||nvl(leasee,'000')
                     ||'.'
                     ||entity
                     ||'.0000' GL_STRING
                   , amount
                   , net_amount
                   , description
                   , status
                 FROM xx_ap_invoice_lines_if
                WHERE request_id = p_request_id
                 AND invoice_id  = p_invoice_id
       )
;
       


CURSOR DUPE_INV_CHECK
IS
       (
             select x.invoice_id, x.BATCH_ID, x.invoice_number
                 from xx_ap_invoice_header_if x,
                 ap_invoices_all aia
                 where x.request_id      = g_request_id
                 and x.INVOICE_NUMBER = aia.invoice_num
                 and x.vendor_site_id = aia.vendor_site_id
       )
;

CURSOR GL_LINES(p_file_name IN VARCHAR2, p_invoice_id NUMBER)
IS
       (
               SELECT l.invoice_id
                   , l.entity
                   , l.account
                   , l.cost_centre
                   , l.msn
                   , nvl(l.leasee,'000') leasee
                   , l.row_number
                 from  xx_ap_invoice_batch_if b
                   , xx_ap_invoice_header_if h
                   , xx_ap_invoice_lines_if l
                 where b.filename = p_file_name
                 and b.request_id = g_request_id
                 AND b.batch_id   = h.batch_id
                 and H.REQUEST_ID = b.request_id
                 and h.invoice_id = p_invoice_id
                 and l.invoice_id = h.invoice_id
                 and l.request_id = h.request_id
       )
;

CURSOR SFTP_FILES(p_request_id NUMBER)
IS
       (
               SELECT filename
                 FROM XX_AP_SERENGETI_FILES
                WHERE request_id = p_request_id
       )
;

PROCEDURE REPORT;

PROCEDURE POPULATE_INVOICES(p_input_file in varchar2);
      
PROCEDURE CALL_SQL_LOADER ( x_error_message OUT VARCHAR2,
                            x_error_code OUT NUMBER,
                            p_input_file IN VARCHAR2,
                            p_dir_path   IN VARCHAR2 );

PROCEDURE CALL_SFTP_PROCESS ( x_error_message OUT VARCHAR2,
                              x_error_code OUT NUMBER);
                              
PROCEDURE ARCHIVE_FILE      ( x_error_message OUT VARCHAR2,
                              x_error_code OUT NUMBER,
                              p_file_name IN VARCHAR2);

PROCEDURE DELETE_FILE      ( x_error_message OUT VARCHAR2,
                              x_error_code OUT NUMBER,
                              p_file_name IN VARCHAR2);
                            
PROCEDURE VALIDATE_DATA (p_file_name IN VARCHAR2);

PROCEDURE write_log
     (
          p_message IN VARCHAR2 ) ;
     /*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 ) ;
     /*-- Procedure to write message on output file.*/
PROCEDURE write_out
     (
          p_message IN VARCHAR2 ) ;
     /*-- Procedure to submit a request*/
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
          x_request_id OUT NUMBER ) ;
     /*-- Procedure to wait for a request to complete and find the code of its completion.*/
PROCEDURE wait_conc_request
     (
          p_request_id  IN NUMBER,
          p_description IN VARCHAR2,
          x_phase OUT VARCHAR2,
          x_code OUT VARCHAR2 ) ;
          

PROCEDURE INVOICE_LOAD
     (    x_error_message OUT VARCHAR2,
          x_error_code OUT NUMBER
         )  AS
         
         l_duplicate number;
         l_file_count number;
  BEGIN
       g_request_id := fnd_global.conc_request_id;
       
       WRITE_OUT('AWAS Serengeti Invoice Load Program');
       WRITE_OUT('===================================');
       WRITE_OUT('');
       WRITE_OUT('Process Started at: '||sysdate);
       WRITE_OUT('');
       
       select count(*)
       into l_file_count
       from XX_AP_SERENGETI_FILES
       where request_id = G_SFTP_REQUEST_ID;
       
       WRITE_OUT('');
       
       
       CALL_SFTP_PROCESS(x_error_message,x_error_code);
       WRITE_LOG ( 'X_ERROR_CODE   : '||x_error_code ) ;
       WRITE_LOG ( 'X_ERROR_MESSAGE: '||x_error_message ) ;
       
       select count(*)
       into l_file_count
       from XX_AP_SERENGETI_FILES
       where request_id = G_SFTP_REQUEST_ID
       and filename <> '*';
       
       if l_file_count = 0 then
              WRITE_OUT('');
              WRITE_OUT('No files transferred from SFTP Server.');
              WRITE_OUT('');
              WRITE_OUT('Program Exiting.');
              
       else
       
              WRITE_OUT(l_file_count||' files transferred from SFTP Server.');
      
       
       IF x_error_code <> 2 then
       
        WRITE_LOG ( 'Checking xx_ap_serengeti_files table for files to import. Using Request Id: '||G_SFTP_REQUEST_ID ) ;
        
       for files in sftp_files(G_SFTP_REQUEST_ID) loop
       
              
                SELECT COUNT(*) 
                into l_duplicate
                 FROM xx_ap_serengeti_files
                WHERE filename  = files.filename
                 AND request_id <> G_SFTP_REQUEST_ID
                 and imported = 'Y';
       
             
              if l_duplicate = 0 then 
              WRITE_LOG ( files.filename||' has not been loaded before. Attempting to load.....' ) ;
              
              WRITE_OUT('');
              WRITE_OUT('Loading file:      '||files.filename);
              CALL_SQL_LOADER(x_error_message, x_error_code, files.filename,'/u01/app/oracle/apps/apps_st/appl/awcust/12.0.0/SERENGETI/NEW');
              
              
              ARCHIVE_FILE(x_error_message, x_error_code,files.filename);
              DELETE_FILE(x_error_message, x_error_code,files.filename);
              
              WRITE_LOG ( 'Calling VALIDATE_DATA.');
              VALIDATE_DATA(files.filename);
              WRITE_LOG ( 'Returned From VALIDATE_DATA.');
                                 
              WRITE_LOG ( 'Calling POPULATE_INVOICES.');                                 
              POPULATE_INVOICES(files.filename);
              WRITE_LOG ( 'Returned From POPULATE_INVOICES.');
              
              else
              WRITE_LOG ( files.filename||' is a duplicate file and has already been imported!' ) ;
              WRITE_OUT('');
              WRITE_OUT( files.filename||' is a duplicate file and has already been imported!');
              
              end if;
       
       end loop;
       
         
       
       end if;
       
       end if;
        REPORT;
       return;
       

  END INVOICE_LOAD;
  
PROCEDURE POPULATE_INVOICES(p_input_file in varchar2)
is
     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     l_gl_result     VARCHAR2 (100);
     e_return_error  EXCEPTION;
     x_error_message VARCHAR2(1000);
     x_error_code    NUMBER;
     l_batch_id      varchar2(100);
     
cursor ap_invoices (p_input_file varchar2) is
  ( SELECT vendor_name
                   , vendor_site_id
                   , invoice_number
                   , invoice_date
                   , invoice_currency
                   , invoice_amount
                   , invoice_id
                   , description
                   , description2
                   , h.batch_id
                   , h.total_tax_amt
                   , h.final_approver
                   , h.final_app_comments
                   , h.vendor_country
                 FROM xx_ap_invoice_header_if h,
                 xx_ap_invoice_batch_if b
                WHERE h.request_id = b.request_id
                 AND h.batch_id    = b.batch_id
                 and b.filename = p_input_file  
                 and b.request_id = g_request_id
                 and h.status = 'OK'
  );
  
  cursor ap_lines( p_invoice_id number) is
  (select l.invoice_id,
         gl_code_combination_id,
         l.amount,
         net_amount,
         l.description,
         entity||'.'||account||'.'||cost_centre||'.'||msn||'.'||nvl(leasee,'000')||'.'||entity||'.0000' AC_STRING,
         l.amount-l.net_amount tax_amount,
         round((l.amount/l.net_amount)-1,4)*100 PC,
         row_number
         from xx_ap_invoice_lines_if l,
         XX_AP_INVOICE_HEADER_IF h
         where h.INVOICE_ID = l.invoice_id
         and h.request_id = l.request_id
         and l.invoice_id= p_invoice_id
         and l.request_id = g_request_id
         );
  
  l_vendor_id number;
  l_line_num number;
  tax_details varchar2(200);
  L_invoice_count number;
  L_invoice_type_lookup_code varchar2(20);
  
begin
  l_invoice_count :=0;
   WRITE_LOG ( 'Starting to Populate Invoices in Open Interface...' ) ;
   
  for inv in ap_invoices(p_input_file) loop
  
  WRITE_LOG ( 'In Loop 1...' ) ;
  select vendor_id 
  into l_vendor_id
  from ap_supplier_sites_all
  where vendor_Site_id = inv.vendor_site_id;
  
  l_batch_id := inv.batch_id;
  
  if inv.invoice_amount > 0 then 
  L_invoice_type_lookup_code := 'STANDARD';
  else
  L_invoice_type_lookup_code := 'CREDIT';
  end if;
  
  insert into ap_invoices_interface 
       (invoice_id,
       attribute1,
       attribute2,
       attribute3,
       invoice_type_lookup_code,
       source,
       org_id,
       control_amount,
       add_tax_to_inv_amt_flag,
       calc_Tax_during_import_flag,
       group_id,
       vendor_id,
       vendor_site_id,
       invoice_num,
       invoice_date,
       invoice_currency_code,
       invoice_amount,
       description,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date)
       values
       (inv.invoice_id,
       'https://tracker.serengetilaw.com/tracker/InvoiceInfo?id='||inv.invoice_id,
       inv.final_approver,
       inv.final_app_comments,
       L_invoice_type_lookup_code,
       'SERENGETI',
       85,
       inv.total_tax_amt,
       'Y',
       'Y',
       inv.batch_id,
       l_vendor_id,
       inv.vendor_site_id,
       inv.invoice_number,
       inv.invoice_date,
       inv.invoice_currency,
       inv.invoice_amount,
       inv.description||','||inv.description2,
       FND_PROFILE.VALUE ( 'USER_ID' ),
       sysdate,
       FND_PROFILE.VALUE ( 'USER_ID' ),
       sysdate);
       
       l_invoice_count := l_invoice_count + sql%rowcount;
       
       WRITE_LOG ( 'Inserted Invoice Header count:'||sql%rowcount ) ;
       
       l_line_num := 1;
       
       for lines in ap_lines(inv.invoice_id) loop
       
       WRITE_LOG ( 'In Loop 2...' ) ;
       
       tax_details := 'No Tax Details';
       
       if lines.amount - lines.net_amount <> 0 then 
              
       WRITE_LOG ( 'Tax Invoice Line, getting tax details...' ) ;
       tax_details := get_tax_details(inv.iNVOICE_DATE, lines.PC, inv.vendor_COUNTRY);
       WRITE_LOG ( 'Tax Details:'||tax_details ) ;
       
       
       end if;
       
       if tax_details = 'No Tax Details'  then
       
       insert into AP_INVOICE_LINES_INTERFACE
       (         invoice_id,
                 invoice_line_id,
                 line_number,
                 line_group_number,
                 line_type_lookup_code,
                 amount,
                 description,
                 dist_code_combination_id,
                 last_updated_by,
                 last_update_date,
                 created_by,
                 creation_date,
                 org_id,
                 dist_code_concatenated
                 )
       values
       (      inv.invoice_id,
              ap_invoice_lines_interface_s.nextval,
              l_line_num,
              l_line_num,
              'ITEM',
              lines.amount,
              lines.description,
              lines.gl_code_combination_id,
              FND_PROFILE.VALUE ( 'USER_ID' ),
              sysdate,
              FND_PROFILE.VALUE ( 'USER_ID' ),
              sysdate,
              85,
              nvl2(lines.gl_code_combination_id,null,lines.ac_string)              
              );
       WRITE_LOG ( 'Inserted Invoice Lines count:'||sql%rowcount ) ;
       elsif 
       tax_details = 'Error'  then
       
       update xx_AP_INVOICE_LINES_IF
       set STATUS = 'Tax Calculation Error.'
       where invoice_id = inv.invoice_id
       and row_number = lines.row_number
       and request_id = g_request_id;
       
       update xx_ap_invoice_header_if
       set status = 'Tax Calculation Error.'
       where invoice_id = inv.invoice_id
       and request_id = g_request_id;
       
       update XX_AP_INVOICE_BATCH_IF
       set Status = 'Error - See Invoices'
       where request_id = g_request_id
       and batch_id = l_batch_id;
       
       delete ap_invoices_interface
       where invoice_id = inv.invoice_id;
       
       l_invoice_count := l_invoice_count - 1;
              
       delete AP_INVOICE_LINES_INTERFACE
       where invoice_id = inv.invoice_id;
       
       exit;
       
       else
       
       insert into AP_INVOICE_LINES_INTERFACE
       (         invoice_id,
                 invoice_line_id,
                 line_number,
                 line_group_number,
                 line_type_lookup_code,
                 amount,
                 description,
                 dist_code_combination_id,
                 last_updated_by,
                 last_update_date,
                 created_by,
                 creation_date,
                 org_id,
                 dist_code_concatenated,
                 tax_classification_code
                 )
       values
       (      inv.invoice_id,
              ap_invoice_lines_interface_s.nextval,
              l_line_num,
              l_line_num,
              'ITEM',
              lines.amount,
              lines.description,
              lines.gl_code_combination_id,
              FND_PROFILE.VALUE ( 'USER_ID' ),
              sysdate,
              FND_PROFILE.VALUE ( 'USER_ID' ),
              sysdate,
              85,
              nvl2(lines.gl_code_combination_id,null,lines.ac_string),
              substr(tax_details,instr(tax_details,'|',1,3)+1,instr(tax_details,'|',1,4)-instr(tax_details,'|',1,3)-1)
              );
              WRITE_LOG ( 'Inserted Invoice Lines count:'||sql%rowcount ) ;
       end if;
       l_line_num := l_line_num + 1;  
       
       end loop; --lines
       
  end loop;  --invoices
  
  commit;
  
  
  if l_invoice_count > 0 then 
  
  submit_conc_request ( p_application =>'SQLAP', p_program =>'APXIIMPT', p_sub_request => FALSE, p_parameter1 => null, p_parameter2 => 'SERENGETI', p_parameter3 => l_batch_id, p_parameter4 => null, 
                            p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => 'Y', p_parameter9 => 'N', p_parameter10 => 'N', p_parameter11 => 'N', p_parameter12 => '1000', p_parameter13 => '1622', p_parameter14 => NULL, p_parameter15 => 'N',p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     WRITE_LOG ( 'REQUEST_ID: '||l_request_id ) ;
     
     
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Wait for Open Interface Program to complete', l_phase, l_code ) ;
     ELSE
          x_error_message := 'Failed to submit Open Interface Program request' ;
          raise e_return_error;
     END IF;
     
     WRITE_LOG ( 'L_PHASE: '||l_phase ) ;
     WRITE_LOG ( 'L_CODE: '||l_code ) ;
     
     write_log ( 'XX_AP_SERENGETI_INVOICES_PKG -> after waiting for the Open Interface Program request' ) ;
            IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
                 
                 write_log ( 'Open Interface Program Completed with a status of '||l_code ) ;
                 
                           
                 IF l_error_code = 0 THEN
                      
                      
                      IF l_error_code <> 0 THEN
                           write_debug ( 'Failed Open Interface Program Process' ) ;
                           x_error_message := 'Failed Open Interface Program Process';
                           raise e_return_error;
                      ELSE
                           write_debug ( 'Open Interface Program completed successfully.' ) ;
                      END IF;
                 ELSE
                      x_error_message := 'Error: Open Interface Program Process failed. Action: Please Correct the errors and resubmit the request';
                      raise e_return_error;
                 END IF;
            ELSE
                 write_log ( 'Open Interface Program Process completed in error. Check the Log File for Concurrent Request: '||l_request_id||' for more information on the error' ) ;
                 x_error_message := 'Error: Open Interface Program Process failed. Action: Please look at the log file for Concurrent Request: '||l_request_id||' for errors';
                 raise e_return_error;
            END IF;
            x_error_code := 0;
     
     end if;
     
EXCEPTION
WHEN e_return_error THEN
     x_error_code := 2;
  
  
end populate_invoices;
  
PROCEDURE CALL_SFTP_PROCESS(  x_error_message OUT VARCHAR2,
                              x_error_code OUT NUMBER
                             )
          IS
     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     l_gl_result     VARCHAR2 (100);
     e_return_error  EXCEPTION;
BEGIN
     l_error_code := 0;
     WRITE_LOG ( 'XX_AP_SERENGETI_INVOICES_PKG -> Beginning of CALL_SFTP_PROCESS procedure' ) ;
     submit_conc_request ( p_application =>'AWCUST', p_program =>'XXSERENGETI_SFTP', p_sub_request => FALSE, p_parameter1 => fnd_profile.value('AWAS_SERENGETI_SFTP_USERNAME'), p_parameter2 => fnd_profile.value('AWAS_SERENGETI_SFTP_PASSWORD'), p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter15 => NULL,p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     WRITE_LOG ( 'REQUEST_ID: '||l_request_id ) ;
     G_SFTP_REQUEST_ID := l_request_id;
     
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Wait for SFTP Process to complete', l_phase, l_code ) ;
     ELSE
          x_error_message := 'Failed to submit request to SFTP Serengeti Invoices' ;
          raise e_return_error;
     END IF;
     
     WRITE_LOG ( 'L_PHASE: '||l_phase ) ;
     WRITE_LOG ( 'L_CODE: '||l_code ) ;
     
     write_log ( 'XX_AP_SERENGETI_INVOICES_PKG -> after waiting for the SFTP request' ) ;
     IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
          
          write_log ( 'Serengeti SFTP Completed with a status of '||l_code ) ;
          
                    
          IF l_error_code = 0 THEN
               
               
               IF l_error_code <> 0 THEN
                    write_debug ( 'Failed SFTP Process' ) ;
                    x_error_message := 'Failed SFTP Process';
                    raise e_return_error;
               ELSE
                    write_debug ( 'Serengeti SFTP completed successfully.' ) ;
               END IF;
          ELSE
               x_error_message := 'Error: Serengeti SFTP Process failed. Action: Please Correct the errors and resubmit the request';
               raise e_return_error;
          END IF;
     ELSE
          write_log ( 'SFTP Process completed in error. Check the Log File for Concurrent Request: '||l_request_id||' for more information on the error' ) ;
          x_error_message := 'Error: Serengeti SFTP Process failed. Action: Please look at the log file for Concurrent Request: '||l_request_id||' for errors';
          raise e_return_error;
     END IF;
     x_error_code := 0;
EXCEPTION
WHEN e_return_error THEN
     x_error_code := 2;

end CALL_SFTP_PROCESS;

PROCEDURE ARCHIVE_FILE(  x_error_message OUT VARCHAR2,
                              x_error_code OUT NUMBER,
                              p_file_name IN VARCHAR2
                             )
          IS
     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     l_gl_result     VARCHAR2 (100);
     e_return_error  EXCEPTION;
BEGIN
     l_error_code := 0;
     WRITE_LOG ( 'XX_AP_SERENGETI_INVOICES_PKG -> Beginning of ARCHIVE_FILE procedure' ) ;
     submit_conc_request ( p_application =>'AWCUST', p_program =>'XXSERENGETI_ARCHIVE', p_sub_request => FALSE, p_parameter1 => p_file_name, p_parameter2 => null, p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter15 => NULL,p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     WRITE_LOG ( 'REQUEST_ID: '||l_request_id ) ;
     
     
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Wait for File Archive to complete', l_phase, l_code ) ;
     ELSE
          x_error_message := 'Failed to submit request to Archive File' ;
          raise e_return_error;
     END IF;
     
     WRITE_LOG ( 'L_PHASE: '||l_phase ) ;
     WRITE_LOG ( 'L_CODE: '||l_code ) ;
     
     write_log ( 'XX_AP_SERENGETI_INVOICES_PKG -> after waiting for the File Archive request' ) ;
     IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
          
          write_log ( 'Serengeti File Archive Completed with a status of '||l_code ) ;
          
                    
          IF l_error_code = 0 THEN
               
               -- Update archived Status to Y as successful                                  
                     update xx_ap_serengeti_files
                     set archived = 'Y'
                     where request_id = g_sftp_request_id
                     and filename = p_file_name;
                     
                     
                     
                     write_debug ( 'Serengeti file Archived successfully. Filename: '||p_file_name ) ; 
               
                    
          ELSE
               x_error_message := 'Failed File Archive Process. Filename: '||p_file_name;              
               raise e_return_error;
          END IF;
     ELSE
          write_log ( 'File Archive Process completed in error. Check the Log File for Concurrent Request: '||l_request_id||' for more information on the error' ) ;
          x_error_message := 'Error: Serengeti File Archive Process failed. Action: Please look at the log file for Concurrent Request: '||l_request_id||' for errors';
          raise e_return_error;
     END IF;
     
     
     x_error_code := 0;
     
     
     
EXCEPTION
WHEN e_return_error THEN
     x_error_code := 2;

end ARCHIVE_FILE;

PROCEDURE DELETE_FILE(  x_error_message OUT VARCHAR2,
                              x_error_code OUT NUMBER,
                              p_file_name IN VARCHAR2
                             )
          IS
     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     l_gl_result     VARCHAR2 (100);
     e_return_error  EXCEPTION;
     l_file_name     varchar2 (240);
BEGIN
     l_error_code := 0;
     
     l_file_name := replace(p_file_name,'_',' ');
     
     WRITE_LOG ( 'XX_AP_SERENGETI_INVOICES_PKG -> Beginning of DELETE_FILE procedure' ) ;
     
     submit_conc_request ( p_application =>'AWCUST', p_program =>'XXSERENGETI_DELETE_FILE', p_sub_request => FALSE, p_parameter1 => fnd_profile.value('AWAS_SERENGETI_SFTP_USERNAME'), p_parameter2 => fnd_profile.value('AWAS_SERENGETI_SFTP_PASSWORD'), p_parameter3 => l_file_name, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter15 => NULL,p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     WRITE_LOG ( 'REQUEST_ID: '||l_request_id ) ;
     
     
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Wait for File Deletion to complete', l_phase, l_code ) ;
     ELSE
          x_error_message := 'Failed to submit request to Delete File' ;
          raise e_return_error;
     END IF;
     
     WRITE_LOG ( 'L_PHASE: '||l_phase ) ;
     WRITE_LOG ( 'L_CODE: '||l_code ) ;
     
     write_log ( 'XX_AP_SERENGETI_INVOICES_PKG -> after waiting for the File Deletion request' ) ;
     IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
          
          write_log ( 'Serengeti File Delete Completed with a status of '||l_code ) ;
          
                    
          IF l_error_code = 0 THEN
               
               -- Update archived Status to Y as successful                                  
                     update xx_ap_serengeti_files
                     set archived = 'Y'
                     where request_id = g_sftp_request_id
                     and filename = p_file_name;
                     
                     write_debug ( 'Serengeti file Deleted successfully. Filename: '||p_file_name ) ; 
               
                    
          ELSE
               x_error_message := 'Failed File Delete Process. Filename: '||p_file_name;              
               raise e_return_error;
          END IF;
     ELSE
          write_log ( 'File Delete Process completed in error. Check the Log File for Concurrent Request: '||l_request_id||' for more information on the error' ) ;
          x_error_message := 'Error: Serengeti File Delete Process failed. Action: Please look at the log file for Concurrent Request: '||l_request_id||' for errors';
          raise e_return_error;
     END IF;
     
     
     x_error_code := 0;
     
     
     
EXCEPTION
WHEN e_return_error THEN
     x_error_code := 2;

end DELETE_FILE;
  
  
PROCEDURE CALL_SQL_LOADER(  x_error_message OUT VARCHAR2,
                            x_error_code OUT NUMBER,
                            p_input_file IN VARCHAR2,
                            p_dir_path   IN VARCHAR2 )
          IS
     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     l_gl_result     VARCHAR2 (100);
     e_return_error  EXCEPTION;
BEGIN
     l_error_code := 0;
     WRITE_LOG ( 'XX_AP_SERENGETI_INVOICES_PKG -> Begining of CALL_SQL_LOADER procedure' ) ;
     submit_conc_request ( p_application =>'AWCUST', p_program =>'XXAPSERENGETILOAD', p_sub_request => FALSE, p_parameter1 => p_dir_path||'/'||p_input_file, p_parameter2 => NULL, p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter15 => NULL,p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Wait for SQL Loader program to complete', l_phase, l_code ) ;
     ELSE
          x_error_message := 'Failed to submit request to load Serengeti Invoices' ;
          raise e_return_error;
     END IF;
     write_log ( 'XX_AP_SERENGETI_INVOICES_PKG -> after waiting for the request' ) ;
     IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
          
          write_log ( 'Serengeti Batch File Uploaded into the staging tables completed with a status of '||l_code ) ;
          
          /*-- validate and load this data into the standard open interface tables.*/
          write_log ( 'Updating staging tables with request_id = '||g_request_id ) ;
          
                  UPDATE xx_AP_INVOICE_BATCH_IF
                     SET request_id       = g_request_id
                          , filename      = p_input_file
                          , created_by    = FND_PROFILE.VALUE ( 'USER_ID' )
                          , creation_date = sysdate
                       WHERE request_id  IS NULL;
                 
                 WRITE_LOG ( 'Number of Batches:  ' || SQL%ROWCOUNT ) ;
                 WRITE_OUT ( 'Number of Batches:  ' || SQL%ROWCOUNT ) ;
                 
                 
                  UPDATE xx_ap_invoice_header_if
                     SET request_id       = g_request_id
                          , created_by    = FND_PROFILE.VALUE ( 'USER_ID' )
                          , creation_date = sysdate
                       WHERE request_id  IS NULL;
                 
                 WRITE_LOG ( 'Number of Invoices: ' || SQL%ROWCOUNT ) ;
                 WRITE_OUT ( 'Number of Invoices: ' || SQL%ROWCOUNT ) ;
                  
                  
                  UPDATE xx_ap_invoice_lines_if
                     SET request_id       = g_request_id
                          , created_by    = FND_PROFILE.VALUE ( 'USER_ID' )
                          , creation_date = sysdate
                       WHERE request_id  IS NULL;
                 
                 WRITE_LOG ( 'Number of Lines:    ' || SQL%ROWCOUNT ) ;
                 WRITE_OUT ( 'Number of Lines:    ' || SQL%ROWCOUNT ) ;
                 
                 commit;
                 
                 
                 
                             
          
          IF l_error_code = 0 THEN
               
               write_debug ( 'Serengeti Data loaded into the standard interface tables successfully.' ) ;
              
          ELSE
               x_error_message := 'Error: Serengeti Data Load failed. Action: Please Correct the errors and resubmit the request';
               raise e_return_error;
          END IF;
     ELSE
          x_error_message := 'Error: Serengeti Data Load failed. Action: Please look at the log file for errors';
          raise e_return_error;
     END IF;
     x_error_code := 0;
EXCEPTION
WHEN e_return_error THEN
     x_error_code := 2;

end CALL_SQL_LOADER;

PROCEDURE REPORT
is

     l_error_message VARCHAR2 ( 1000 ) ;
     l_error_code    NUMBER;
     l_gl_result     VARCHAR2 (100);
     e_return_error  EXCEPTION;
     
begin

     l_error_code := 0;
     WRITE_LOG ( 'XX_AP_SERENGETI_INVOICES_PKG -> Beginning of REPORT procedure' ) ;
     submit_conc_request ( p_application =>'AWCUST', p_program =>'XXAP_SERENGETI_IF_REP', p_sub_request => FALSE, p_parameter1 => g_request_id, p_parameter2 => NULL, p_parameter3 => NULL, p_parameter4 => NULL, p_parameter5 => NULL, p_parameter6 => NULL, p_parameter7 => NULL, p_parameter8 => NULL, p_parameter9 => NULL, p_parameter10 => NULL, p_parameter11 => NULL, p_parameter12 => NULL, p_parameter13 => NULL, p_parameter14 => NULL, p_parameter15 => NULL,p_parameter16 => NULL,x_request_id =>l_request_id ) ;
     /*-- wait till the sqlloader program is completed*/
     IF l_request_id <> 0 THEN
          wait_conc_request ( l_request_id, 'Waiting for REPORT to complete', l_phase, l_code ) ;
     ELSE
          l_error_message := 'Failed to submit request: AWAS Serengeti Interface Report' ;
          raise e_return_error;
     END IF;
     write_log ( 'XX_AP_SERENGETI_INVOICES_PKG -> after waiting for the REPORT' ) ;
     IF ( ( l_phase = 'Completed' ) AND ( l_code IN ( 'Normal', 'Warning' ) ) ) THEN
          
          write_log ( 'Seregenti Interface Report completed with a status of '||l_code ) ;
          
                            
          
          IF l_error_code = 0 THEN
               
               write_debug ( 'Serengeti Interface Report completed successfully.' ) ;
              
          ELSE
               l_error_message := 'Error: Serengeti Interface Report failed. Action: Please Correct the errors and resubmit the request';
               raise e_return_error;
          END IF;
     ELSE
          l_error_message := 'Error: Serengeti Interface Report failed. Action: Please look at the log file for errors';
          raise e_return_error;
     END IF;
     l_error_code := 0;
EXCEPTION
WHEN e_return_error THEN
     l_error_code := 2;

end report;

PROCEDURE VALIDATE_DATA(
              p_file_name IN VARCHAR2)
IS
       l_error_code  NUMBER;
       l_gl_result   VARCHAR2 (100);
       l_error_count NUMBER;
       l_batch_id    varchar2 (100);
       L_header_error number;
       
       
       CURSOR SITE_CHECK(p_file_name IN VARCHAR2)
IS
       (
               SELECT x.VENDOR_NAME
                   , ss.vendor_site_id
                   , x.INVOICE_NUMBER
                   , x.INVOICE_DATE
                   , x.INVOICE_CURRENCY
                   , x.INVOICE_AMOUNT
                   , x.invoice_id
                   , X.BATCH_ID
                 FROM ap_supplier_sites_all ss
                   , xx_ap_invoice_header_if x
                   , xx_ap_invoice_batch_if b
                WHERE x.vendor_site_id = SS.VENDOR_SITE_ID (+)
                 AND x.request_id      = g_request_id
                 AND b.batch_id        = x.batch_id
                 AND b.request_id      = g_request_id
                 AND b.filename        = p_file_name
       )
;

CURSOR SITE_CUR(p_file_name IN VARCHAR2,p_vendor_site_id in number)
IS
       (
               SELECT x.VENDOR_NAME
                   , ss.vendor_site_id
                   , x.INVOICE_NUMBER
                   , x.INVOICE_DATE
                   , x.INVOICE_CURRENCY
                   , x.INVOICE_AMOUNT
                   , x.invoice_id
                   , X.BATCH_ID
                   , ss.invoice_currency_code
                 FROM ap_supplier_sites_all ss
                   , xx_ap_invoice_header_if x
                   , xx_ap_invoice_batch_if b
                WHERE x.vendor_site_id = p_VENDOR_SITE_ID
                 and x.vendor_site_id = ss.vendor_site_id (+)
                 AND x.request_id      = g_request_id
                 AND b.batch_id        = x.batch_id
                 AND b.request_id      = g_request_id
                 AND b.filename        = p_file_name
                 and x.invoice_currency = ss.invoice_currency_code (+)
       )
;

BEGIN
       write_log ( 'Validating Data...............') ;
       write_log ( 'In Filename: '||p_file_name) ;
       
       l_error_count := 0;
       -- Check Supplier Site Exists
       FOR c1 IN site_check(p_file_name)
              
       LOOP
       l_header_error := 0;
                     write_log ( '----------------------------------------') ;
                     write_log ( 'Vendor Name   :'||c1.vendor_name) ;
                     write_log ( 'Vendor Site ID:'||c1.vendor_site_id) ;
                     write_log ( 'Invoice number:'||c1.invoice_number) ;
                     
              IF c1.vendor_site_id IS NULL THEN
                     
                     l_error_count := l_error_count + 1;
                     l_header_error := l_header_error + 1;
                     write_log ( 'Vendor Site Not Mapped in Oracle Correctly. Please verify and retry') ;
                      UPDATE xx_ap_invoice_header_if
                      SET status         = STATUS||'ERROR - Vendor Mapping.'
                       WHERE invoice_id = c1.invoice_id
                        AND request_id  = g_request_id;
             
                     COMMIT;
            /*  ELSE
              
                     write_log ( 'Vendor Site Mapping OK') ;
              -- vendor Site Exists, check currency
              for c_chk in site_cur(p_file_name,c1.vendor_site_id)
              loop
                     IF c_chk.invoice_currency_code IS NULL THEN
                           
                            l_error_count := l_error_count + 1;
                            l_header_error := l_header_error + 1;
                       
                            
                            write_log ( 'Currency Incorrect') ;
                             
                             UPDATE xx_ap_invoice_header_if
                             SET status         = STATUS||'ERROR - Invalid Site Currency.'
                             WHERE invoice_id = c1.invoice_id
                             AND request_id  = g_request_id;
                             
                             COMMIT;
                     ELSE
                            write_log ( 'Invoice Currency matches Site Currency') ;
                     END IF;
              end loop;
          */    
              END IF;
              
              
              
              -- Validate GL Coding.
              write_log ( 'Validating GL Data...............') ;
              
              FOR c2 IN gl_lines(p_file_name, c1.invoice_id)
              LOOP
                     -- Getting GL Code.
                      SELECT xx_valid_gl_code(c2.entity,c2.account,c2.cost_centre,c2.msn,c2.leasee,c2.entity,'0000')
                        INTO l_gl_result
                        FROM dual;
                     write_log ('Validating GL String: '||c2.entity||'.'||c2.account ||'.'||c2.cost_centre||'.'||c2.msn||'.'||
                     c2.leasee||'.'||c2.entity||'.00000');
                     write_log ( 'l_gl_result='||l_gl_result) ;
              
                     
                     IF xx_isnumber(l_gl_result) = 1 THEN
                     write_log ( 'GL Code OK') ;
                             UPDATE xx_ap_invoice_lines_if
                            SET gl_code_combination_id = l_gl_result * 1
                                 , status              = 'OK'
                              WHERE invoice_id         = c1.invoice_id
                               AND row_number          = c2.row_number
                               AND entity              = c2.entity
                               AND account             = c2.account
                               AND cost_centre         = c2.cost_centre
                               AND msn                 = c2.msn
                               AND leasee              = c2.leasee
                               AND request_id          = g_request_id;
                            COMMIT;
                     ELSE
                      write_log ( 'GL Code NOT OK') ;
                            l_error_count := l_error_count + 1;
                            l_header_error := l_header_error + 1;
                             UPDATE xx_ap_invoice_lines_if
                             SET status = STATUS||'Error: '
                                   ||L_gl_result||'.'
                              WHERE invoice_id = c1.invoice_id
                               AND row_number  = c2.row_number
                               AND entity      = c2.entity
                               AND account     = c2.account
                               AND cost_centre = c2.cost_centre
                               AND msn           = c2.msn
                               AND NVL(leasee,'000')   = c2.leasee
                               AND request_id     = g_request_id;
                            COMMIT;
                            
                     END IF;
              END LOOP;
              l_batch_id := c1.batch_id;
              
              if l_header_error = 0 then
                     update xx_ap_invoice_header_if
                     set status = 'OK'
                     where request_id = g_request_id
                     and invoice_id = c1.invoice_id;
              end if;
              write_log ( '----------------------------------------') ;
       END LOOP;  -- Invoice HEader Loop
      
      
      
     -- Now check for duplicates 
      write_log ('VALIDATE_DATE.DUPLICATE_CHECKING Begin');
      For C2 in dupe_inv_check 
      loop
      write_log ('Duplicate Found. Invoice Number:'||c2.invoice_number||'  Invoice ID:'||c2.invoice_id);
      
      update xx_ap_invoice_header_if
       SET status         = 'WARNING - Duplicate invoice found'
                       WHERE invoice_id = c2.invoice_id
                        AND request_id  = g_request_id;
       
       update xx_ap_invoice_lines_if
       SET status = 'Warning: Duplicate Invoice detected'
       WHERE invoice_id = c2.invoice_id
       AND request_id   = g_request_id;
      
      end loop;   -- dupe check
      write_log ('VALIDATE_DATE.DUPLICATE_CHECKING End.');
      write_log ( '----------------------------------------') ;
      
       IF l_error_count = 0 THEN
              write_log ('Woohoo we have a succesful file!');
               UPDATE xx_ap_invoice_batch_if
                     SET status        = 'OK'
                       WHERE batch_id  = l_batch_id
                        AND request_id = g_request_id;
       ELSE
                     UPDATE xx_ap_invoice_batch_if
                     SET status        = 'Errors Found.'
                     WHERE batch_id  = l_batch_id
                     AND request_id = g_request_id;
                     
              write_log (l_error_count||' Errors Found.');
              write_log ('Correct Source Data and resubmit.');
       END IF;
       write_log ( '----------------------------------------') ;
       
END VALIDATE_DATA;


function get_tax_details(P_INVOICE_DATE date, P_PC_RATE number, P_COUNTRY varchar2)
return varchar2 as

retval varchar2(200);

begin
WRITE_LOG ( 'In Get_tax_details function' ) ;

 SELECT s.tax||'|'||s.tax_regime_code||'|'||s.tax_status_code||'|'||TAX_RATE_CODE||'|'||r.tax_rate_id
       into retval
   FROM ZX.ZX_STATUS_B s
     , ZX_rates_b r
     , ZX_REGIMES_B tr
     , FND_TERRITORIES_tl t
  WHERE p_invoice_date BETWEEN s.effective_from AND NVL(s.effective_to,sysdate+1)
   AND r.tax_status_Code = s.tax_status_code
   AND r.tax_regime_code = s.tax_regime_code
   AND p_invoice_date BETWEEN r.effective_from AND NVL(r.effective_to,sysdate+1)
   AND r.rate_type_code       = 'PERCENTAGE'
   AND r.percentage_rate      = p_PC_RATE
   AND t.territory_short_name = p_country
   AND t.TERRITORY_CODE       = tr.country_Code
   AND tr.tax_regime_code     = s.tax_regime_code;


  if retval is null then
  
  retval := 'No Tax Details';
  
  end if;
  
  return retval;

 exception when others then
  WRITE_LOG ( 'Exception raised in get_tax_details function.' ) ;
  retval := 'Error';
  return retval;
  
end get_tax_details;

/*--=============================================================================*/
/*-- Procedure to submit a request*/
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
END submit_conc_request;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to wait for a request to complete and find the code of its completion.*/
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
END wait_conc_request;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to write message in log file.*/
PROCEDURE write_log
     (
          p_message IN VARCHAR2 )
                    IS
     l_message VARCHAR2 ( 100 ) ;
BEGIN
     l_message := SUBSTR ( p_message, 1, 100 ) ;
     fnd_file.put_line ( fnd_file.log, l_message ) ;
END write_log;
/*--=============================================================================*/
/*--=============================================================================*/
/*-- Procedure to debug messages to log file*/
PROCEDURE write_debug
     (
          p_message IN VARCHAR2 )
                    IS
BEGIN
     IF G_debug_mode THEN
          fnd_file.put_line ( fnd_file.log, p_message ) ;
     END IF;
END write_debug;
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
END XX_AP_SERENGETI_INVOICES_PKG;
/
