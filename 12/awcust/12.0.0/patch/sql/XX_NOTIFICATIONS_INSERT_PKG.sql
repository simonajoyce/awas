CREATE OR REPLACE PACKAGE xx_notifications_insert_pkg IS
/*****************************************************************
** This package provides us with API's to insert records in     **
**             xx_notiFICATIONS_API                            **
**             xx_notiFICATION_QUERIES                         **
**             xx_notiFICATION_COLUMNS                         **
**								**
** Anil Passi    15-SEP-2003	Created, Gave Life		**
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
*****************************************************************/

PROCEDURE xx_notiFICATIONS_API
(
 x_notification_api_id                   IN NUMBER
,x_email_address                         IN VARCHAR2
,x_message_type                          IN VARCHAR2
,x_message_subject                       IN VARCHAR2
,x_process_short_code                    IN VARCHAR2
,x_user_name                             IN VARCHAR2 DEFAULT NULL
,x_intranet_accessible                   IN VARCHAR2 DEFAULT 'Y'
,X_RESPONSE_LOOKUP_TYPE			 IN VARCHAR2 DEFAULT NULL
,x_message_text                          IN VARCHAR2 DEFAULT NULL
,X_RESPONSE_CALLBACK_SQL		 IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE xx_notiFICATION_QUERIES
(
 x_notification_query_id                 IN NUMBER
,x_notification_api_id                   IN NUMBER
,x_query_title_text                      IN VARCHAR2
,x_from_clause                           IN VARCHAR2
,x_where_clause                          IN VARCHAR2
,x_bind_values                           IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE xx_notiFICATION_COLUMNS
(
 x_notification_query_id                 IN NUMBER
,x_notification_column_id                IN NUMBER
,x_column_title                          IN VARCHAR2
,x_column_width                          IN NUMBER
,x_column_name                           IN VARCHAR2
) ;

END xx_notifications_insert_pkg ;
 
/


CREATE OR REPLACE PACKAGE BODY xx_notifications_insert_pkg
IS
/*****************************************************************
** This package provides us with API's to insert records in     **
**             xx_notiFICATIONS_API                            **
**             xx_notiFICATION_QUERIES                         **
**             xx_notiFICATION_COLUMNS                         **
**								**
** Anil Passi    15-SEP-2003	Created, Gave Life		**
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
**                                                              **
*****************************************************************/

g_user_id INTEGER := FND_GLOBAL.USER_ID ;
g_login_id INTEGER := FND_GLOBAL.LOGIN_ID ;

PROCEDURE xx_notiFICATIONS_API
(
 x_notification_api_id                   IN NUMBER
,x_email_address                         IN VARCHAR2
,x_message_type                          IN VARCHAR2
,x_message_subject                       IN VARCHAR2
,x_process_short_code                    IN VARCHAR2
,x_user_name                             IN VARCHAR2 DEFAULT NULL
,x_intranet_accessible                   IN VARCHAR2 DEFAULT 'Y'
,X_RESPONSE_LOOKUP_TYPE			 IN VARCHAR2 DEFAULT NULL
,x_message_text                          IN VARCHAR2 DEFAULT NULL
,X_RESPONSE_CALLBACK_SQL		 IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
    INSERT INTO xx_notifications_api
    (
    notification_api_id
    ,email_address
    ,message_type
    ,message_subject
    ,process_short_code                    
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,creation_date
    ,created_by
    ,user_name
    ,intranet_accessible
    ,message_text
    ,RESPONSE_LOOKUP_TYPE			 
    ,RESPONSE_CALLBACK_SQL		 
    )
    VALUES
    (
     x_notification_api_id
    ,x_email_address
    ,x_message_type
    ,x_message_subject
    ,x_process_short_code                    
    ,SYSDATE    --x_last_update_date
    ,g_user_id  --x_last_updated_by
    ,g_login_id --x_last_update_login
    ,SYSDATE    --x_creation_date
    ,g_user_id  --x_created_by
    ,x_user_name
    ,x_intranet_accessible
    ,x_message_text
    ,X_RESPONSE_LOOKUP_TYPE			 
    ,X_RESPONSE_CALLBACK_SQL		 
    ) ;
END xx_notiFICATIONS_API ;

PROCEDURE xx_notiFICATION_QUERIES
(
 x_notification_query_id                 IN NUMBER
,x_notification_api_id                   IN NUMBER
,x_query_title_text                      IN VARCHAR2
,x_from_clause                           IN VARCHAR2
,x_where_clause                          IN VARCHAR2
,x_bind_values                           IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
INSERT INTO xx_notification_queries
(
notification_query_id
,notification_api_id
,query_title_text
,from_clause
,where_clause
,bind_values
,last_update_date
,last_updated_by
,last_update_login
,creation_date
,created_by
)
VALUES
(
x_notification_query_id
,x_notification_api_id
,x_query_title_text
,x_from_clause
,x_where_clause
,x_bind_values
,SYSDATE    --x_last_update_date
,g_user_id  --x_last_updated_by
,g_login_id --x_last_update_login
,SYSDATE    --x_creation_date
,g_user_id  --x_created_by
) ;
END xx_notiFICATION_QUERIES ;

PROCEDURE xx_notiFICATION_COLUMNS
(
 x_notification_query_id                 IN NUMBER
,x_notification_column_id                IN NUMBER
,x_column_title                          IN VARCHAR2
,x_column_width                          IN NUMBER
,x_column_name                           IN VARCHAR2
) IS
BEGIN
INSERT INTO xx_notification_columns
(
notification_query_id
,notification_column_id
,column_title
,column_width
,column_name
,last_update_date
,last_updated_by
,last_update_login
,creation_date
,created_by
)
VALUES
(
x_notification_query_id
,x_notification_column_id
,x_column_title
,x_column_width
,x_column_name
,SYSDATE    --x_last_update_date
,g_user_id  --x_last_updated_by
,g_login_id --x_last_update_login
,SYSDATE    --x_creation_date
,g_user_id  --x_created_by
) ;
END xx_notiFICATION_COLUMNS ;


END xx_notifications_insert_pkg ;
/
