CREATE OR REPLACE PACKAGE XX_CE_MAIL_AP AS

  PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 ) ;

END XX_CE_MAIL_AP;

 
/


CREATE OR REPLACE PACKAGE BODY XX_CE_MAIL_AP AS

  PROCEDURE MAIN
     (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2 )  AS
          
         n_not_id INTEGER;
BEGIN
  xx_notifications_api_pkg.send_notification(
     x_email_address       => 'accountspayable@awas.com' 
   ,x_user_name           => null  
    ,x_notification_api_id => n_not_id
    ,x_message_type        => 'TEXT_AND_QUERY'
    ,x_process_short_code  => 'ALERT-'
    ,x_message_subject     => 'Cash Management Statement Lines in Error'
    ,x_message_text        => 'Transactions Assigned to AP as at ' ||to_char(SYSDATE,'DD-Mon-RRRR HH24:MI'));
   
  xx_notifications_api_pkg.add_query(
     x_notification_api_id => n_not_id
    ,x_query_title_text    => 'List of Statement Lines assigned to AP requiring your attention'
    ,x_from_clause         => 'xx_CE_stmt_line_errors_v'
    ,x_where_clause        => 'dept = ''AP'''
    ,x_bind_values         =>  NULL
    ,x_column_title_1      => 'Account Num'
    ,x_column_name_1       => 'BANK_ACCOUNT_NUMBER'
    ,x_column_title_2      => 'Stmt Num'
    ,x_column_name_2       => 'STATEMENT_NUMBER'
    ,x_column_title_3      => 'Line'
    ,x_column_name_3       => 'LINE_NUMBER'
    ,x_column_title_4      => 'Trx Date'
    ,x_column_name_4       => 'TRX_DATE'
    ,x_column_title_5      => 'Trx Type'
    ,x_column_name_5       => 'TRX_TYPE'
    ,x_column_title_6      => 'Amount'
    ,x_column_name_6       => 'AMOUNT'
    ,x_column_title_7      => 'Comments'
    ,x_column_name_7       => 'COMMENTS'
    ,x_column_title_8      => 'Trx Text'
    ,x_column_name_8       => 'TRX_TEXT');
    
 
  xx_notifications_api_pkg.add_query(
     x_notification_api_id => n_not_id
    ,x_query_title_text    => 'AP Payments not reconciled after 10 days'
    ,x_from_clause         => 'ap_checks_all c, ap_bank_accounts_all b'
    ,x_where_clause        => 'b.bank_account_id = c.bank_account_id and c.status_lookup_code = ''NEGOTIABLE'' and c.org_id = 85 and c.checK_date < sysdate - 10 order by c.check_date asc'
    ,x_bind_values         => NULL
    ,x_column_title_1      => 'Account Num'
    ,x_column_name_1       => 'b.bank_account_num'
    ,x_column_title_2      => 'Account Name'
    ,x_column_name_2       => 'c.bank_account_name'
    ,x_column_title_3      => 'Trx Date'
    ,x_column_name_3       => 'c.check_date'
    ,x_column_title_4      => 'Vendor'
    ,x_column_name_4       => 'c.vendor_name'
    ,x_column_title_5      => 'Curr'
    ,x_column_name_5       => 'c.currency_code'
    ,x_column_title_6      => 'Amount'
    ,x_column_name_6       => 'decode(c.currency_code,b.currency_code,c.amount, c.base_amount)');    
  dbms_output.put_line('AP Notification Id: ' || n_not_id);
COMMIT ;


  xx_notifications_api_pkg.send_notification(
     x_email_address       => 'accountreceivables@awas.com'
    ,x_user_name           => null
    ,x_notification_api_id => n_not_id
    ,x_message_type        => 'TEXT_AND_QUERY'
    ,x_process_short_code  => 'ALERT-'
    ,x_message_subject     => 'Cash Management Statement Lines in Error'
    ,x_message_text        => 'Transactions Assigned to AR as at ' ||to_char(SYSDATE,'DD-Mon-RRRR HH24:MI'));
   
  xx_notifications_api_pkg.add_query(
     x_notification_api_id => n_not_id
    ,x_query_title_text    => 'List of Statement Lines assigned to AR requiring your attention'
    ,x_from_clause         => 'xx_CE_stmt_line_errors_v'
    ,x_where_clause        => 'dept = ''AR'''
    ,x_bind_values         =>  NULL
    ,x_column_title_1      => 'Account Num'
    ,x_column_name_1       => 'BANK_ACCOUNT_NUMBER'
    ,x_column_title_2      => 'Stmt Num'
    ,x_column_name_2       => 'STATEMENT_NUMBER'
    ,x_column_title_3      => 'Line'
    ,x_column_name_3       => 'LINE_NUMBER'
    ,x_column_title_4      => 'Trx Date'
    ,x_column_name_4       => 'TRX_DATE'
    ,x_column_title_5      => 'Trx Type'
    ,x_column_name_5       => 'TRX_TYPE'
    ,x_column_title_6      => 'Amount'
    ,x_column_name_6       => 'AMOUNT'
    ,x_column_title_7      => 'Comments'
    ,x_column_name_7       => 'COMMENTS'
    ,x_column_title_8      => 'Trx Text'
    ,x_column_name_8       => 'TRX_TEXT');
    
  dbms_output.put_line('AR Notification Id: ' || n_not_id);
  
  commit;
  
  xx_notifications_api_pkg.send_notification(
     x_email_address       =>  'cmt@awas.com'
    ,x_user_name           => null 
    ,x_notification_api_id => n_not_id
    ,x_message_type        => 'TEXT_AND_QUERY'
    ,x_process_short_code  => 'ALERT-'
    ,x_message_subject     => 'Cash Management Statement Lines in Error'
    ,x_message_text        => 'Transactions Assigned to GL as at ' ||to_char(SYSDATE,'DD-Mon-RRRR HH24:MI'));
   
  xx_notifications_api_pkg.add_query(
     x_notification_api_id => n_not_id
    ,x_query_title_text    => 'List of Statement Lines assigned to GL requiring your attention'
    ,x_from_clause         => 'xx_CE_stmt_line_errors_v'
    ,x_where_clause        => 'dept = ''GL'''
    ,x_bind_values         =>  NULL
    ,x_column_title_1      => 'Account Num'
    ,x_column_name_1       => 'BANK_ACCOUNT_NUMBER'
    ,x_column_title_2      => 'Stmt Num'
    ,x_column_name_2       => 'STATEMENT_NUMBER'
    ,x_column_title_3      => 'Line'
    ,x_column_name_3       => 'LINE_NUMBER'
    ,x_column_title_4      => 'Trx Date'
    ,x_column_name_4       => 'TRX_DATE'
    ,x_column_title_5      => 'Trx Type'
    ,x_column_name_5       => 'TRX_TYPE'
    ,x_column_title_6      => 'Amount'
    ,x_column_name_6       => 'AMOUNT'
    ,x_column_title_7      => 'Comments'
    ,x_column_name_7       => 'COMMENTS'
    ,x_column_title_8      => 'Trx Text'
    ,x_column_name_8       => 'TRX_TEXT');
  
  dbms_output.put_line('GL Notification Id: ' || n_not_id);
  
  commit;
    
  END MAIN;

END XX_CE_MAIL_AP;

/
