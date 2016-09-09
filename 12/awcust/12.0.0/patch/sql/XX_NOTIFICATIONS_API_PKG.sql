CREATE OR REPLACE PACKAGE xx_notifications_api_pkg  IS
/*****************************************************************
*** This package will be the core to the functionality of 	**
*** workflow API						**
**Anil Passi    16-SEP-2003	Created, Gave Life		**
**								**
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

PROCEDURE send_notification
(
 x_email_address                         IN VARCHAR2
,x_user_name                             IN VARCHAR2 DEFAULT NULL
,x_message_type                          IN VARCHAR2
,x_message_subject                       IN VARCHAR2
,x_process_short_code                    IN VARCHAR2
,x_message_text                          IN VARCHAR2 DEFAULT NULL
,x_intranet_accessible                   IN VARCHAR2 DEFAULT 'Y'
,X_RESPONSE_LOOKUP_TYPE			 IN VARCHAR2 DEFAULT NULL
,X_NOTIFICATION_API_ID                   OUT INTEGER
,X_RESPONSE_CALLBACK_SQL		 IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE get_response_type
   (
	itemtype in varchar2,
	itemkey in varchar2,
	actid in number,
	funcmode in varchar2,
	result in out varchar2
   ) ;

PROCEDURE add_query
(
 X_NOTIFICATION_API_ID                   IN INTEGER
,X_QUERY_TITLE_TEXT                      IN VARCHAR2
,X_FROM_CLAUSE                           IN VARCHAR2
,X_WHERE_CLAUSE                          IN VARCHAR2
,X_BIND_VALUES                           IN VARCHAR2 DEFAULT NULL
,x_column_title_1                        IN VARCHAR2 DEFAULT NULL
,x_column_width_1                        IN VARCHAR2 DEFAULT NULL
,x_column_name_1                         IN VARCHAR2 DEFAULT NULL
,x_column_title_2                        IN VARCHAR2 DEFAULT NULL
,x_column_width_2                        IN VARCHAR2 DEFAULT NULL
,x_column_name_2                         IN VARCHAR2 DEFAULT NULL
,x_column_title_3                        IN VARCHAR2 DEFAULT NULL
,x_column_width_3                        IN VARCHAR2 DEFAULT NULL
,x_column_name_3                         IN VARCHAR2 DEFAULT NULL
,x_column_title_4                        IN VARCHAR2 DEFAULT NULL
,x_column_width_4                        IN VARCHAR2 DEFAULT NULL
,x_column_name_4                         IN VARCHAR2 DEFAULT NULL
,x_column_title_5                        IN VARCHAR2 DEFAULT NULL
,x_column_width_5                        IN VARCHAR2 DEFAULT NULL
,x_column_name_5                         IN VARCHAR2 DEFAULT NULL
,x_column_title_6                        IN VARCHAR2 DEFAULT NULL
,x_column_width_6                        IN VARCHAR2 DEFAULT NULL
,x_column_name_6                         IN VARCHAR2 DEFAULT NULL
,x_column_title_7                        IN VARCHAR2 DEFAULT NULL
,x_column_width_7                        IN VARCHAR2 DEFAULT NULL
,x_column_name_7                         IN VARCHAR2 DEFAULT NULL
,x_column_title_8                        IN VARCHAR2 DEFAULT NULL
,x_column_width_8                        IN VARCHAR2 DEFAULT NULL
,x_column_name_8                         IN VARCHAR2 DEFAULT NULL
,x_column_title_9                        IN VARCHAR2 DEFAULT NULL
,x_column_width_9                        IN VARCHAR2 DEFAULT NULL
,x_column_name_9                         IN VARCHAR2 DEFAULT NULL
,x_column_title_10                       IN VARCHAR2 DEFAULT NULL
,x_column_width_10                       IN VARCHAR2 DEFAULT NULL
,x_column_name_10                        IN VARCHAR2 DEFAULT NULL
,x_column_title_11                       IN VARCHAR2 DEFAULT NULL
,x_column_width_11                       IN VARCHAR2 DEFAULT NULL
,x_column_name_11                        IN VARCHAR2 DEFAULT NULL
,x_column_title_12                       IN VARCHAR2 DEFAULT NULL
,x_column_width_12                       IN VARCHAR2 DEFAULT NULL
,x_column_name_12                        IN VARCHAR2 DEFAULT NULL
,x_column_title_13                       IN VARCHAR2 DEFAULT NULL
,x_column_width_13                       IN VARCHAR2 DEFAULT NULL
,x_column_name_13                        IN VARCHAR2 DEFAULT NULL
,x_column_title_14                       IN VARCHAR2 DEFAULT NULL
,x_column_width_14                       IN VARCHAR2 DEFAULT NULL
,x_column_name_14                        IN VARCHAR2 DEFAULT NULL
,x_column_title_15                       IN VARCHAR2 DEFAULT NULL
,x_column_width_15                       IN VARCHAR2 DEFAULT NULL
,x_column_name_15                        IN VARCHAR2 DEFAULT NULL
) ;

PROCEDURE START_WORKFLOW_API
(
 P_NOTIFICATION_API_ID IN INTEGER
,P_PROCESS_CODE IN VARCHAR2
) ;

PROCEDURE GET_NOTIFICATION_DOCUMENT
    (document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	CLOB,
    document_type	in out	varchar2) ;

PROCEDURE create_set_roles
   (
	itemtype in varchar2,
	itemkey in varchar2,
	actid in number,
	funcmode in varchar2,
	result in out varchar2
	) ;

PROCEDURE init_workflow_api_variables
   (
	itemtype in varchar2,
	itemkey in varchar2,
	actid in number,
	funcmode in varchar2,
	result in out varchar2
	) ;

PROCEDURE construct_sql_statement 
( 
 P_NOTIFICATION_QUERY_ID IN INTEGER 
,p_query_statement OUT VARCHAR2
) ;

PROCEDURE get_column_title_list 
	( 
	 P_NOTIFICATION_QUERY_ID IN INTEGER 
	,P_COLUMN_TITLE_LIST	OUT VARCHAR2
	) ;

FUNCTION email_to_role 
(
p_email IN VARCHAR2
) RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES ( email_to_role, WNDS ) ;

PROCEDURE set_callback_result
    (
	itemtype in varchar2,
	itemkey in varchar2,
	actid in number,
	funcmode in varchar2,
	result in out varchar2
	) ;

PROCEDURE execute_callback
	   (
	itemtype in varchar2,
	itemkey in varchar2,
	actid in number,
	funcmode in varchar2,
	result in out varchar2
	) ;

   FUNCTION get_role_for_user_email(
      p_user                     IN       VARCHAR2
     ,p_email                    IN       VARCHAR2 )
      RETURN VARCHAR2 ;
--PRAGMA RESTRICT_REFERENCES ( get_role_for_user_email, WNDS ) ;      
END xx_notifications_api_pkg  ;

 
/


CREATE OR REPLACE PACKAGE BODY xx_notifications_api_pkg IS
  /*****************************************************************
  *** This package will be the core to the functionality of   **
  *** workflow API                 **
  **Anil Passi    16-SEP-2003   Created, Gave Life      **
  **                      **
  **Anil Passi    17-SEP-2003   Replace the bulk fetch     **
  **             for ref cursor, bcos it gave  **
  **                error ORA-01001: invalid cursor **
  **                Now doing fetch one by on  **
  **Anil Passi    17-SEP-2003
                  Made a change so that imperial.ac.uk
                  is treated as ic.ac.uk
  Anil Passi      02 Feb 06. 
                  Remove expiration date from ad hoc 
                  role as 11.5.10 validates against this
  Anil Passi      Jun06 Implement CLOB for large sized notifications                
  Anil Passi      Jun06 Option to notify in realtime
  
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

  --Set the global variables
  --These will primarily be used to build the HTML table
  g_bold_text_begin     VARCHAR2(30) := '<p><strong>';
  g_bold_text_end       VARCHAR2(30) := '</strong></p>';
  g_table_begin         VARCHAR2(40) := '<table border="1">';
  g_table_end           VARCHAR2(30) := '</table>';
  g_record_begin        VARCHAR2(5) := '<tr>';
  g_record_end          VARCHAR2(5) := '</tr>';
  g_column_begin        VARCHAR2(5) := '<td>';
  g_column_begin_silver VARCHAR2(500) := '<td' ||
                                         ' style="BACKGROUND: silver;"' ||
                                         '><STRONG>';
  g_column_end          VARCHAR2(5) := '</td>';
  g_column_end_silver   VARCHAR2(500) := '</STRONG></td>';
  g_item_owner          VARCHAR2(30) := 'PASSIA';
  g_response_value      VARCHAR2(30) := 'ic_RESPONSE_VALUE';

  /*
  Create a ROLE
  and return the ROLE name
  */
  FUNCTION create_role_email
  (
    p_user  IN VARCHAR2
   ,p_email IN VARCHAR2
  ) RETURN VARCHAR2 IS
    v_role wf_roles.NAME%TYPE := email_to_role(p_email);
  BEGIN
    --anil passi 02 Feb 06. Remove expiration date from ad hoc 
    --role as 11.5.10 validates against this
    wf_directory.createadhocrole(role_name               => v_role
                                ,role_display_name       => v_role
                                ,role_description        => v_role
                                ,notification_preference => 'MAILHTML'
                                ,email_address           => p_email
                                ,status                  => 'ACTIVE'
                                ,expiration_date         => NULL);
    RETURN v_role;
  END create_role_email;
  /*
  This procedure will build the first record for HTML table
  Since we have one to many relation between Query and column list,
  We will loop for each column record and build the title record
  */

  PROCEDURE get_column_title_list
  (
    p_notification_query_id IN INTEGER
   ,p_column_title_list     OUT VARCHAR2
  ) IS
  BEGIN
    FOR p_rec IN (SELECT g_column_begin_silver || column_title ||
                         g_column_end_silver "HTML_COL_TITLE"
                  FROM   xx_notification_columns
                  WHERE  notification_query_id = p_notification_query_id
                  ORDER  BY notification_column_id)
    LOOP
      SELECT p_column_title_list || p_rec.html_col_title
      INTO   p_column_title_list
      FROM   dual;
    END LOOP;
  
    --Now add the record tags to begin and end record
    p_column_title_list := g_record_begin || p_column_title_list ||
                           g_record_end;
  END get_column_title_list;

  /*
  The output of all the columns will be
  concatenated.
  */
  PROCEDURE get_column_list
  (
    p_notification_query_id IN INTEGER
   ,p_column_list           OUT VARCHAR2
  ) IS
  BEGIN
    FOR p_rec IN (SELECT '''' || g_column_begin || '''' || '||' ||
                         column_name || '||' || '''' || g_column_end || '''' "HTML_COL"
                  FROM   xx_notification_columns
                  WHERE  notification_query_id = p_notification_query_id
                  ORDER  BY notification_column_id)
    LOOP
      SELECT p_column_list || decode(p_column_list, NULL, NULL, '||') ||
             p_rec.html_col
      INTO   p_column_list
      FROM   dual;
    END LOOP;
  END get_column_list;

  /*
  Please note, this procedure will append
  FROM and WHERE keywords to the respect clauses.
  Hence the parameters passed to this API
  should not use FROM and WHERE in the clauses, as
  the API appends these keywords.
  */
  PROCEDURE construct_sql_statement
  (
    p_notification_query_id IN INTEGER
   ,p_query_statement       OUT VARCHAR2
  ) IS
    v_column_list VARCHAR2(4000);
  
    CURSOR c_get_stmt(px_notification_query_id IN INTEGER, p_column_list IN VARCHAR2) IS
      SELECT ' SELECT ' || '''' || g_record_begin || '''' || '||' ||
             p_column_list || '||' || '''' || g_record_end || '''' || ' ' ||
             ' FROM ' || from_clause || ' WHERE ' || where_clause ||
             decode(bind_values, NULL, NULL, ' USING ' || bind_values) "SELECT_STMT"
      FROM   xx_notification_queries
      WHERE  notification_query_id = px_notification_query_id;
  BEGIN
    --Get the column list
    get_column_list(p_notification_query_id => p_notification_query_id
                   ,p_column_list           => v_column_list);
  
    --Now pass the column list
    OPEN c_get_stmt(px_notification_query_id => p_notification_query_id
                   ,p_column_list            => v_column_list);
    FETCH c_get_stmt
      INTO p_query_statement;
    CLOSE c_get_stmt;
  END construct_sql_statement;

  /*
  Not doing anything intelligent here.
  ing records in xx_notiFICATION_QUERIES
  and xx_notiFICATION_COLUMNS
  At the moment, max limit of columns for a query
  is 15, but this can be easily expanded.
  No changes will be required to the data model
  if u add further parameters for column names.
  
  Column width is for future use only.
  The developer using this API may ignore
  column width. The HTML table construct will
  take care of column sizing automatically
  */
  PROCEDURE add_query
  (
    x_notification_api_id IN INTEGER
   ,x_query_title_text    IN VARCHAR2
   ,x_from_clause         IN VARCHAR2
   ,x_where_clause        IN VARCHAR2
   ,x_bind_values         IN VARCHAR2 DEFAULT NULL
   ,x_column_title_1      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_1      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_1       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_2      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_2      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_2       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_3      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_3      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_3       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_4      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_4      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_4       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_5      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_5      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_5       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_6      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_6      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_6       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_7      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_7      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_7       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_8      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_8      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_8       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_9      IN VARCHAR2 DEFAULT NULL
   ,x_column_width_9      IN VARCHAR2 DEFAULT NULL
   ,x_column_name_9       IN VARCHAR2 DEFAULT NULL
   ,x_column_title_10     IN VARCHAR2 DEFAULT NULL
   ,x_column_width_10     IN VARCHAR2 DEFAULT NULL
   ,x_column_name_10      IN VARCHAR2 DEFAULT NULL
   ,x_column_title_11     IN VARCHAR2 DEFAULT NULL
   ,x_column_width_11     IN VARCHAR2 DEFAULT NULL
   ,x_column_name_11      IN VARCHAR2 DEFAULT NULL
   ,x_column_title_12     IN VARCHAR2 DEFAULT NULL
   ,x_column_width_12     IN VARCHAR2 DEFAULT NULL
   ,x_column_name_12      IN VARCHAR2 DEFAULT NULL
   ,x_column_title_13     IN VARCHAR2 DEFAULT NULL
   ,x_column_width_13     IN VARCHAR2 DEFAULT NULL
   ,x_column_name_13      IN VARCHAR2 DEFAULT NULL
   ,x_column_title_14     IN VARCHAR2 DEFAULT NULL
   ,x_column_width_14     IN VARCHAR2 DEFAULT NULL
   ,x_column_name_14      IN VARCHAR2 DEFAULT NULL
   ,x_column_title_15     IN VARCHAR2 DEFAULT NULL
   ,x_column_width_15     IN VARCHAR2 DEFAULT NULL
   ,x_column_name_15      IN VARCHAR2 DEFAULT NULL
  ) IS
    n_notification_query_id  INTEGER;
    n_notification_column_id INTEGER;
  BEGIN
    /*
    First create query record
    Next create the column records one by one
    */
  
    /*
    Note at the moment no validation done for column
    name, width and title be mutually inclusive
    */
  
    SELECT xx_notification_queries_s.NEXTVAL
    INTO   n_notification_query_id
    FROM   dual;
    /*
    Create the query record
    */
    xx_notifications_insert_pkg.xx_notification_queries(x_notification_query_id => n_notification_query_id
                                                       ,x_notification_api_id   => x_notification_api_id
                                                       ,x_query_title_text      => x_query_title_text
                                                       ,x_from_clause           => x_from_clause
                                                       ,x_where_clause          => x_where_clause
                                                       ,x_bind_values           => x_bind_values);
  
    /* Now create notification columns */
    IF x_column_name_1 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_1
                                                         ,x_column_width           => x_column_width_1
                                                         ,x_column_name            => x_column_name_1);
    END IF;
  
    IF x_column_name_2 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_2
                                                         ,x_column_width           => x_column_width_2
                                                         ,x_column_name            => x_column_name_2);
    END IF;
  
    IF x_column_name_3 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_3
                                                         ,x_column_width           => x_column_width_3
                                                         ,x_column_name            => x_column_name_3);
    END IF;
  
    IF x_column_name_4 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_4
                                                         ,x_column_width           => x_column_width_4
                                                         ,x_column_name            => x_column_name_4);
    END IF;
  
    IF x_column_name_5 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_5
                                                         ,x_column_width           => x_column_width_5
                                                         ,x_column_name            => x_column_name_5);
    END IF;
  
    IF x_column_name_6 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_6
                                                         ,x_column_width           => x_column_width_6
                                                         ,x_column_name            => x_column_name_6);
    END IF;
  
    IF x_column_name_7 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_7
                                                         ,x_column_width           => x_column_width_7
                                                         ,x_column_name            => x_column_name_7);
    END IF;
  
    IF x_column_name_8 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_8
                                                         ,x_column_width           => x_column_width_8
                                                         ,x_column_name            => x_column_name_8);
    END IF;
  
    IF x_column_name_9 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_9
                                                         ,x_column_width           => x_column_width_9
                                                         ,x_column_name            => x_column_name_9);
    END IF;
  
    IF x_column_name_10 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_10
                                                         ,x_column_width           => x_column_width_10
                                                         ,x_column_name            => x_column_name_10);
    END IF;
  
    IF x_column_name_12 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_12
                                                         ,x_column_width           => x_column_width_12
                                                         ,x_column_name            => x_column_name_12);
    END IF;
  
    IF x_column_name_13 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_13
                                                         ,x_column_width           => x_column_width_13
                                                         ,x_column_name            => x_column_name_13);
    END IF;
  
    IF x_column_name_14 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_14
                                                         ,x_column_width           => x_column_width_14
                                                         ,x_column_name            => x_column_name_14);
    END IF;
  
    IF x_column_name_15 IS NOT NULL
    THEN
      SELECT xx_notification_columns_s.NEXTVAL
      INTO   n_notification_column_id
      FROM   dual;
      xx_notifications_insert_pkg.xx_notification_columns(x_notification_query_id  => n_notification_query_id
                                                         ,x_notification_column_id => n_notification_column_id
                                                         ,x_column_title           => x_column_title_15
                                                         ,x_column_width           => x_column_width_15
                                                         ,x_column_name            => x_column_name_15);
    END IF;
  END add_query;

  PROCEDURE send_notification
  (
    x_email_address         IN VARCHAR2
   ,x_user_name             IN VARCHAR2 DEFAULT NULL
   ,x_message_type          IN VARCHAR2
   ,x_message_subject       IN VARCHAR2
   ,x_process_short_code    IN VARCHAR2
   ,x_message_text          IN VARCHAR2 DEFAULT NULL
   ,x_intranet_accessible   IN VARCHAR2 DEFAULT 'Y'
   ,x_response_lookup_type  IN VARCHAR2 DEFAULT NULL
   ,x_notification_api_id   OUT INTEGER
   ,x_response_callback_sql IN VARCHAR2 DEFAULT NULL
  ) IS
    n_notification_api_id INTEGER;
  BEGIN
  
    IF x_email_address IS NULL
       AND x_user_name IS NULL
    THEN
      raise_application_error(-20001
                             ,'xx_notifications_api_pkg.send_notification=> Both ' ||
                              'Email address and the UserName can not be NULL ');
    END IF;
    SELECT xx_notifications_api_s.NEXTVAL
    INTO   n_notification_api_id
    FROM   dual;
  
    x_notification_api_id := n_notification_api_id;
    xx_notifications_insert_pkg.xx_notifications_api(x_notification_api_id   => n_notification_api_id
                                                    ,x_email_address         => x_email_address
                                                    ,x_message_type          => x_message_type
                                                    ,x_message_subject       => x_message_subject
                                                    ,x_process_short_code    => x_process_short_code
                                                    ,x_user_name             => x_user_name
                                                    ,x_intranet_accessible   => x_intranet_accessible
                                                    ,x_message_text          => x_message_text
                                                    ,x_response_lookup_type  => x_response_lookup_type
                                                    ,x_response_callback_sql => x_response_callback_sql);
  END send_notification;

  PROCEDURE start_workflow_api
  (
    p_notification_api_id IN INTEGER
   ,p_process_code        IN VARCHAR2
  ) IS
    l_save_thr NUMBER;
    l_itemkey  VARCHAR2(100);
    l_itemtype VARCHAR2(100) := 'XXWFAPI';
  BEGIN
    IF NVL(fnd_profile.VALUE('xx_notiF_API_REALTIME'),'N') != 'Y'
    THEN
      l_save_thr := wf_engine.threshold; -- to allow run in trigger
      wf_engine.threshold := -1;
    END IF;
    l_itemkey := p_process_code || '-' || to_char(p_notification_api_id);
    wf_engine.createprocess(l_itemtype, l_itemkey, 'API_PROCESS');
    wf_engine.setitemuserkey(itemtype => l_itemtype
                            ,itemkey  => l_itemkey
                            ,userkey  => p_process_code || '-' ||
                                         to_char(p_notification_api_id));
    wf_engine.setitemowner(itemtype => l_itemtype
                          ,itemkey  => l_itemkey
                          ,owner    => g_item_owner);
    wf_engine.setitemattrnumber(itemtype => l_itemtype
                               ,itemkey  => l_itemkey
                               ,aname    => 'NOTIFICATION_API_ID'
                               ,avalue   => to_char(p_notification_api_id));
    wf_engine.startprocess(l_itemtype, l_itemkey);
    IF NVL(fnd_profile.VALUE('xx_notiF_API_REALTIME'),'N') != 'Y'
    THEN
        wf_engine.threshold := l_save_thr;
    END IF ;
  END start_workflow_api;

  /* COnvert the email to a role name
  This is done, bcos we must give a role name
  to each email */
  FUNCTION email_to_role(p_email IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN upper(REPLACE(REPLACE(REPLACE(p_email
                                        ,'ic.ac.uk'
                                        ,'imperial.ac.uk')
                                ,'.'
                                ,'_')
                        ,'@'
                        ,'_'));
  END email_to_role;

  /*
  Returns the ROLE for a given
  user and email address combination.
  Given that sometimes
  */
  FUNCTION get_role_for_user_email
  (
    p_user  IN VARCHAR2
   ,p_email IN VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR c_get_role IS
      SELECT *
      FROM   wf_roles
      WHERE  NAME = p_user
      AND    nvl(upper(REPLACE(email_address, 'ic.ac.uk', 'imperial.ac.uk'))
                ,'XX') =
             nvl(nvl(upper(REPLACE(p_email, 'ic.ac.uk', 'imperial.ac.uk'))
                     ,upper(REPLACE(email_address
                                   ,'ic.ac.uk'
                                   ,'imperial.ac.uk')))
                 ,'XX');
  
    CURSOR c_get_email IS
      SELECT *
      FROM   wf_local_roles
      WHERE  NAME = email_to_role(p_email)
      AND    email_address = p_email;
  
    p_get_role  c_get_role%ROWTYPE;
    p_get_email c_get_email%ROWTYPE;
  BEGIN
    OPEN c_get_role;
    FETCH c_get_role
      INTO p_get_role;
  
    IF c_get_role%FOUND
    THEN
      CLOSE c_get_role;
      RETURN p_get_role.NAME;
    END IF;
  
    CLOSE c_get_role;
    OPEN c_get_email;
    FETCH c_get_email
      INTO p_get_email;
  
    IF c_get_email%FOUND
    THEN
      CLOSE c_get_email;
      RETURN p_get_email.NAME;
    END IF;
  
    CLOSE c_get_email;
  
    RETURN create_role_email(p_user => p_user, p_email => p_email);
  
  END get_role_for_user_email;


  PROCEDURE create_set_roles
  (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT VARCHAR2
  ) IS
    v_email_address       xx_notifications_api.email_address%TYPE;
    v_user_name           xx_notifications_api.user_name%TYPE;
    v_role_name           wf_roles.NAME%TYPE;
    n_notification_api_id INTEGER;
  
    CURSOR c_get_email_and_user IS
      SELECT email_address
            ,user_name
      FROM   xx_notifications_api
      WHERE  notification_api_id = n_notification_api_id;
  
    l_error VARCHAR(100) := 'CREATE_SET_ROLES';
    e_user_exception EXCEPTION;
  BEGIN
    n_notification_api_id := wf_engine.getitemattrnumber(itemtype => itemtype
                                                        ,itemkey  => itemkey
                                                        ,aname    => 'NOTIFICATION_API_ID');
    OPEN c_get_email_and_user;
    FETCH c_get_email_and_user
      INTO v_email_address, v_user_name;
    CLOSE c_get_email_and_user;
  
    IF v_email_address IS NULL
       AND v_user_name IS NULL
    THEN
      l_error := 'Email and User name are null';
      RAISE e_user_exception;
    END IF;
  
    v_role_name := get_role_for_user_email(p_user  => v_user_name
                                          ,p_email => v_email_address);
  
    IF v_role_name IS NULL
    THEN
      --create role here
      v_role_name := create_role_email(p_user  => v_user_name
                                      ,p_email => v_email_address);
    END IF;
  
    IF v_role_name IS NULL
    THEN
      l_error := 'Unable to create role';
      RAISE e_user_exception;
    END IF;
  
    --Set the role here
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'SEND_TO_ROLE'
                             ,avalue   => v_role_name);
    RESULT := 'COMPLETE:Y';
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('xx_notiFICATIONS_API_PKG'
                     ,'CREATE_SET_ROLES'
                     ,itemkey
                     ,to_char(actid)
                     ,funcmode
                     ,l_error);
      RAISE;
  END create_set_roles;

  /* This will initialise the message body
  Will also initialize the message document procedure
  along with the parameters for genrating the doc*/
  PROCEDURE init_workflow_api_variables
  (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT VARCHAR2
  ) IS
    n_notification_api_id INTEGER;
    v_message_subject     xx_notifications_api.message_subject%TYPE;
  
    CURSOR c_get(p_notification_api_id IN INTEGER) IS
      SELECT message_subject
      FROM   xx_notifications_api
      WHERE  notification_api_id = p_notification_api_id;
  BEGIN
    --Get the notification API Id
    n_notification_api_id := wf_engine.getitemattrnumber(itemtype => itemtype
                                                        ,itemkey  => itemkey
                                                        ,aname    => 'NOTIFICATION_API_ID');
    /* get the message subject */
    OPEN c_get(p_notification_api_id => n_notification_api_id);
    FETCH c_get
      INTO v_message_subject;
    CLOSE c_get;
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'NOTIFICATION_SUBJECT'
                             ,avalue   => v_message_subject);
    --And then set the document attribute
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'NOTIFICATION_DOCUMENT'
                             ,avalue   => 'plsqlclob:xx_notiFICATIONS_API_PKG.GET_NOTIFICATION_DOCUMENT/' ||
                                          itemtype || ':' ||
                                          to_char(n_notification_api_id));
    RESULT := 'COMPLETE';
  END init_workflow_api_variables;

  /*
  This procedure will be the backbone of
  generating the message for this API workflow
  */
  PROCEDURE get_notification_document
  (
    document_id   IN VARCHAR2
   ,display_type  IN VARCHAR2
   ,document      IN OUT CLOB
   ,document_type IN OUT VARCHAR2
  ) IS
    l_item_type           wf_items.item_type%TYPE;
    l_item_key            wf_items.item_key%TYPE;
    l_notification_api_id INTEGER;
    v_long_variable       VARCHAR2(2800);
    v_sql_select          varchar2(4000);
    l_document            LONG;
    v_message_type        xx_notifications_api.message_type%TYPE;
    x integer;
  
    TYPE notification_ref_cursor IS REF CURSOR;
  
    notification_cursor notification_ref_cursor;
  
    /*
    For some reasons bulk fetch didnt work, hence commenting
    the pl/sql table rec_tab
    */
    --type   result_tab is table of varchar2(4000);
    --rec_tab result_tab ;
  
    CURSOR c_get_text_html(p_notification_api_id IN INTEGER) IS
      SELECT message_text
            ,message_type
      FROM   xx_notifications_api
      WHERE  notification_api_id = p_notification_api_id
      AND    message_type IN ('TEXT', 'HTML', 'TEXT_AND_QUERY');
  BEGIN
    l_item_type           := substr(document_id
                                   ,1
                                   ,instr(document_id, ':') - 1);
    l_notification_api_id := substr(document_id
                                   ,instr(document_id, ':') + 1);
    OPEN c_get_text_html(p_notification_api_id => l_notification_api_id);
    FETCH c_get_text_html
      INTO l_document, v_message_type;
    CLOSE c_get_text_html;
  
    /*
    The main message text has been captured as above
    Next we need to generate the dynamic SQL and display its
    contents in the table format of HTML
    */
  
  
    IF v_message_type NOT IN ('QUERY', 'TEXT_AND_QUERY')
    THEN
      wf_notification.writetoclob(document, l_document);
      RETURN;
    END IF;
  
    FOR p_rec IN (SELECT notification_query_id
                        ,query_title_text
                  FROM   xx_notification_queries
                  WHERE  notification_api_id = l_notification_api_id
                  ORDER  BY notification_query_id)
    LOOP
    
      v_long_variable := NULL;
      xx_notifications_api_pkg.construct_sql_statement(p_notification_query_id => p_rec.notification_query_id
                                                      ,p_query_statement       => v_sql_select);
      l_document := l_document || chr(10) || g_bold_text_begin ||
                    p_rec.query_title_text || g_bold_text_end || chr(10);
      l_document := l_document || chr(10) || g_table_begin || chr(10);
      /*
      Although bulk fetch might be more efficient, but
      it invokes invalid cursor in this case
      FETCH notification_cursor BULK COLLECT INTO rec_tab ;
      FOR i in 1..notification_cursor%rowcount
      LOOP
         document := document || rec_tab(i) ;
      END LOOP ;
      */
      /*
      I am reusing the v_long_variable variable for
      different purposes ,because i do not wish to
      define another 4000 byte variable to hold data
      */
      --dbms_output.put_line('cursor sql ='||v_sql_select);
      
      OPEN notification_cursor FOR v_sql_select;
      get_column_title_list(p_notification_query_id => p_rec.notification_query_id
                           ,p_column_title_list     => v_long_variable);
      --This will append the Column titles
      l_document := l_document || v_long_variable;
    
      --dbms_output.put_line('cursor open'); 
      x := 0;
      LOOP
      --dbms_output.put_line('In Loop'); 
        FETCH notification_cursor
          INTO v_long_variable;
          --dbms_output.put_line('Fetched'||x); 
          x := x+1;
      
        IF notification_cursor%NOTFOUND
        THEN
          EXIT;
        END IF;
      
        
        l_document := l_document || v_long_variable;
        IF lengthb(l_document) >= 28000
        THEN
        
        --dbms_output.put_line('write to clob'); 
          wf_notification.writetoclob(document, l_document);
          l_document := '';
        END IF;
      
      END LOOP;
      
      --dbms_output.put_line('left loop'); 
      l_document := l_document || chr(10) || g_table_end || chr(10);
      
    --  dbms_output.put_line('length'||lengthb(l_document)); 
      IF lengthb(l_document) >= 28000
      THEN
        wf_notification.writetoclob(document, l_document);
        l_document := '';
      END IF;
    
       END LOOP;
      
  --    dbms_output.put_line('about to writetclob');  
      
      wf_notification.writetoclob(document, l_document);
      
--      dbms_output.put_line('finished writetclob');  
      
      
  EXCEPTION
    WHEN OTHERS THEN
    --dbms_output.put_line('EXCEPTION:'||SQLERRM);
    fnd_log.STRING(log_level => fnd_log.level_statement
                  ,module    => 'xxxx_notif_api.plsql.xx_notifications_api_pkg.get_notification_document'
                  ,message   => 'l_notification_api_id=>' || l_notification_api_id || ' ' || SQLERRM );
  END get_notification_document;

  PROCEDURE get_response_type
  (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT VARCHAR2
  ) IS
    n_notification_api_id INTEGER;
    v_response_type       xx_notifications_api.response_lookup_type%TYPE;
  
    CURSOR c_get(p_notification_api_id IN INTEGER) IS
      SELECT response_lookup_type
      FROM   xx_notifications_api
      WHERE  notification_api_id = p_notification_api_id;
  BEGIN
    --Get the notification API Id
    n_notification_api_id := wf_engine.getitemattrnumber(itemtype => itemtype
                                                        ,itemkey  => itemkey
                                                        ,aname    => 'NOTIFICATION_API_ID');
    /* get the response type */
    OPEN c_get(p_notification_api_id => n_notification_api_id);
    FETCH c_get
      INTO v_response_type;
    CLOSE c_get;
    RESULT := nvl(v_response_type, 'NONE');
  END get_response_type;

  PROCEDURE set_callback_result
  (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT VARCHAR2
  ) IS
    l_nid                  NUMBER;
    l_activity_result_code VARCHAR2(200);
    n_notification_api_id  INTEGER;
  BEGIN
    IF (funcmode IN ('RESPOND'))
    THEN
      SELECT notification_id
            ,activity_result_code
      INTO   l_nid
            ,l_activity_result_code
      FROM   wf_item_activity_statuses
      WHERE  item_type = itemtype
      AND    item_key = itemkey
      AND    process_activity = actid;
      n_notification_api_id := wf_notification.getattrnumber(l_nid
                                                            ,'NOTIFICATION_API_ID');
    
      UPDATE xx_notifications_api
      SET    response_lookup_result = l_activity_result_code
      WHERE  notification_api_id = n_notification_api_id;
    ELSIF (funcmode = 'TIMEOUT')
    THEN
      NULL;
    END IF;
  
    RESULT := 'COMPLETE:APPROVED';
  EXCEPTION
    WHEN OTHERS THEN
      RESULT := SQLERRM;
  END set_callback_result;

  PROCEDURE execute_callback
  (
    itemtype IN VARCHAR2
   ,itemkey  IN VARCHAR2
   ,actid    IN NUMBER
   ,funcmode IN VARCHAR2
   ,RESULT   IN OUT VARCHAR2
  ) IS
    n_notification_api_id    INTEGER;
    v_response_lookup_result xx_notifications_api.response_lookup_result%TYPE;
    v_response_callback_sql  xx_notifications_api.response_callback_sql%TYPE;
  
    CURSOR c_get(p_notification_api_id IN INTEGER) IS
      SELECT response_lookup_result
            ,response_callback_sql
      FROM   xx_notifications_api
      WHERE  notification_api_id = p_notification_api_id;
  BEGIN
    --Get the notification API Id
    n_notification_api_id := wf_engine.getitemattrnumber(itemtype => itemtype
                                                        ,itemkey  => itemkey
                                                        ,aname    => 'NOTIFICATION_API_ID');
    /* get the response type */
    OPEN c_get(p_notification_api_id => n_notification_api_id);
    FETCH c_get
      INTO v_response_lookup_result, v_response_callback_sql;
    CLOSE c_get;
  
    IF v_response_callback_sql IS NULL
    THEN
      RESULT := 'COMPLETE:Y';
      RETURN;
    ELSE
      SELECT REPLACE(v_response_callback_sql
                    ,g_response_value
                    ,v_response_lookup_result)
      INTO   v_response_callback_sql
      FROM   dual;
    END IF;
  
    EXECUTE IMMEDIATE v_response_callback_sql;
    RESULT := 'COMPLETE:Y';
  EXCEPTION
    WHEN OTHERS THEN
      --need to write proper code when we
      --implement prototype
      RESULT := 'COMPLETE:Y';
  END execute_callback;
END xx_notifications_api_pkg;
/
