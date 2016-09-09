--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure XX_GET_BANK_ACCOUNT_NUMBER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "APPS"."XX_GET_BANK_ACCOUNT_NUMBER" (itemtype  IN VARCHAR2
                                                      ,itemkey   IN VARCHAR2
                                                      ,actid     IN NUMBER
                                                      ,funcmode  IN VARCHAR2
                                                      ,resultout OUT NOCOPY VARCHAR2) IS
  bank_event_document   CLOB;
  event                 wf_event_t;
  xmldoc                xmldom.domdocument;
  parser                xmlparser.parser;
  v_bank_account_number VARCHAR2(500);
  v_bank_account_number_old VARCHAR2(500);
  v_bank_account_name VARCHAR2(500);
  v_bank_account_name_old VARCHAR2(500);
  v_bank_Asset_Acct VARCHAR2(500);
  v_bank_Asset_Acct_old VARCHAR2(500);
  v_ui VARCHAR2(500);
  v_updated_by varchar2(60);
  v_temp number;
  v_temp2 number;
  v_temp3 number;
  v_temp4 number;
  v_bank VARCHAR2(500);
  v_branch VARCHAR2(500);
  v_address VARCHAR2(500);
  v_swift VARCHAR2(500);
  v_aba VARCHAR2(500);
  v_currency  VARCHAR2(500);
  v_currency_old  VARCHAR2(500);
  v_description  VARCHAR2(500);
  v_description_old  VARCHAR2(500);
  v_date date;
  v_inactive date;
  v_old_inactive date;
  
BEGIN
  IF (funcmode = 'RUN')
  THEN
    --
    event                 := wf_engine.getitemattrevent(itemtype => itemtype
                                                       ,itemkey  => itemkey
                                                       ,NAME     => 'BANK_ACC_CHANGED_PAYLOAD');
    bank_event_document   := event.geteventdata();
    v_bank_account_number := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/bank_account_number');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_NUMBER'
                             ,avalue   => v_bank_account_number);
                                                 
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BANK_ACCT_NUMBER_FROM_PAYLOAD'
                             ,avalue   => v_bank_account_number);
                             
    v_bank_account_number_old := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/old_bank_account_number');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_OLD_NUMBER'
                             ,avalue   => v_bank_account_number_old);
                             
     v_bank_account_name := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/bank_account_name');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_NAME'
                             ,avalue   => v_bank_account_name);
                                                 
                                
    v_bank_account_name_old := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/old_bank_account_name');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_OLD_NAME'
                             ,avalue   => v_bank_account_name_old);
                        
    v_temp := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/asset_code_combination_id');
    select segment1||'.'||segment2||'.'||segment3||'.'||segment4||'.'||segment5||'.'||segment6||'.'||segment7
    into v_bank_Asset_Acct
    from gl_code_combinations
    where code_combination_id = v_temp;
                              
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_ASSET_ACCT'
                             ,avalue   => v_bank_Asset_acct);
                                                 
                                
    v_temp2 := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/old_asset_code_combination_id');
    if v_temp2 is not null then
    select segment1||'.'||segment2||'.'||segment3||'.'||segment4||'.'||segment5||'.'||segment6||'.'||segment7
    into v_bank_Asset_Acct_old
    from gl_code_combinations
    where code_combination_id = v_temp2;
    else
    v_bank_Asset_Acct_old := null;
    end if;
    
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_OLD_ASSET_ACCT'
                             ,avalue   => v_bank_Asset_Acct_old);
                             
     v_currency := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/currency_code');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_CURRENCY'
                             ,avalue   => v_currency);
                                                 
                                
    v_currency_old := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/old_currency_code');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_OLD_CURRENCY'
                             ,avalue   => v_currency_old);
     
     v_description := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/description');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_DESCRIPTION'
                             ,avalue   => v_description);
                                                 
                                
    v_description_old := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/old_description');
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BA_OLD_DESCRIPTION'
                             ,avalue   => v_description_old);                        
                             
     
     
     v_ui := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/record_type');
    
    
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'UPDATE_INSERT'
                             ,avalue   => v_ui);
                             
    v_temp3 := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/changed_by_user_id');
    
    select description
    into v_updated_by
    from fnd_user
    where user_id = v_temp3;
    
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'UPDATED_BY'
                             ,avalue   => v_updated_by);
                             
     
      v_temp4 := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/bank_branch_id');
     select bank_name, 
       bank_branch_name, 
       nvl2(address_line1,address_line1||',',address_line1)
       ||nvl2(address_line2,address_line2||',',address_line2)
       ||nvl2(address_line3,address_line3||',',address_line3)
       ||nvl2(address_line4,address_line4||',',address_line4)
       ||nvl2(city,city||',',city)
       ||nvl2(state,state||',',state)
       ||nvl2(zip,zip||',',zip)
       ||nvl2(country,country,country) address,
       bank_num,
       bank_number
     into v_bank,
          v_branch,
          v_address,
          v_swift,
          v_aba
     from ap_bank_branches b
     where bank_branch_id = v_temp4;
     
       wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BANK_NAME'
                             ,avalue   => v_bank);
      
      wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BRANCH_NAME'
                             ,avalue   => v_branch);
                             
     wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'BANK_ADDRESS'
                             ,avalue   => v_address);
     
     wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'SWIFT_CODE'
                             ,avalue   => v_swift);
                             
     wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'ABA_NUMBER'
                             ,avalue   => v_aba);
                             
                             
                             
     v_date := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/record_date');
    
    
    wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'UPDATE_DATE'
                             ,avalue   => v_date);
                             
                             
     v_inactive := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/inactive_date');
                                                 
     wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'INACTIVE_DATE'
                             ,avalue   => v_inactive);
                             
     v_old_inactive := irc_xml_util.valueof(bank_event_document
                                                 ,'/ap_bank_accounts/old_inactive_date');
                                                 
     wf_engine.setitemattrtext(itemtype => itemtype
                             ,itemkey  => itemkey
                             ,aname    => 'OLD_INACTIVE_DATE'
                             ,avalue   => v_old_inactive);
  END IF;
  
END xx_get_bank_account_number;

 

/
