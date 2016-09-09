CREATE OR REPLACE PACKAGE XX_AP_PAYMENT_EVENT_WF_PKG AUTHID CURRENT_USER
AS
     /* $Header: appewfps.pls 115.5 2003/02/20 19:45:44 syidner noship $ */
PROCEDURE get_check_info
     (
          p_item_type IN VARCHAR2,
          p_item_key  IN VARCHAR2,
          p_actid     IN NUMBER,
          p_funmode   IN VARCHAR2,
          p_result OUT NOCOPY VARCHAR2 ) ;
     FUNCTION rule_function
          (
               p_subscription IN RAW,
               p_event        IN OUT NOCOPY WF_EVENT_T )
          RETURN VARCHAR2;
     PROCEDURE get_remit_email_address
          (
               p_check_id IN NUMBER,
               p_email_address OUT NOCOPY VARCHAR2 ) ;
     PROCEDURE Get_Paid_Invoices
          (
               document_id   IN VARCHAR2,
               display_type  IN VARCHAR2,
               document      IN OUT NOCOPY CLOB,
               document_type IN OUT NOCOPY VARCHAR2 ) ;
     END XX_AP_PAYMENT_EVENT_WF_PKG;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AP_PAYMENT_EVENT_WF_PKG as
/* $Header: appewfpb.pls 115.13 2006/07/05 05:16:49 sguddeti noship $ */

PROCEDURE get_check_info (p_item_type          IN VARCHAR2,
                          p_item_key           IN VARCHAR2,
                          p_actid              IN NUMBER,
                          p_funmode            IN VARCHAR2,
                          p_result             OUT NOCOPY VARCHAR2) IS

 l_check_id         ap_checks_all.check_id%type;
 l_org_id           ap_checks_all.org_id%type;
 l_check_number     ap_checks_all.check_number%type;
 l_check_date       varchar2(20);
 l_currency_code    ap_checks_all.currency_code%type;
 l_payment_amount   ap_checks_all.amount%type;
 l_email_address    po_vendor_sites_all.remittance_email%type;
 l_document_id      VARCHAR2(1000);
 l_vendor_num       po_vendors.segment1%type;

 l_role               varchar2(100);
 l_display_role_name  varchar2(100);

 BEGIN

     /* Get the check_id stored in the attribute check_id */

     l_check_id := wf_engine.getitemattrnumber(p_item_type,
                                               p_item_key,
                                               'CHECK_ID');

      /* Get the org_id stored in the attribute check_id */

     l_org_id   := wf_engine.getitemattrnumber(p_item_type,
                                               p_item_key,
                                               'ORG_ID');

     /* Set the Org ID context */

      if l_org_id is not null
      then

         fnd_client_info.set_org_context(l_org_id);

      end if;

     /* Get Basic Check Info */

     SELECT check_number,
            fnd_date.date_to_chardate(check_date),
            currency_code,
            amount
     INTO   l_check_number,
            l_check_date,
            l_currency_code,
            l_payment_amount
     FROM   ap_checks
     WHERE  check_id = l_check_id;
     
     /* AWAS Custom -- Get Vendor Number for email */
     
     select v.segment1
     into l_vendor_num
     from ap_checks a, po_vendors v
     where a.vendor_id = v.vendor_id
     and check_id = l_check_id;

    /* Get Supplier's Remittance Email Address */
    get_remit_email_address(l_check_id,l_email_address);

    l_role := null;

    --Bug 4918015     l_display_role_name := null;

    l_display_role_name := l_email_address ;  --Bug4918015


    -- Bug 4070337 changed from MAILHTML to MAILHTM2
    WF_DIRECTORY.createAdhocRole(role_name => l_role,
                                 role_display_name => l_display_role_name,
                                 email_address => l_email_address,
                                 notification_preference => 'MAILHTM2');

    /* AWAS - Set Vendor Number to WorkFlow Attribute */
    wf_engine.setitemattrtext(P_item_type,
                                p_item_key,
                               'VENDOR_NUM',
                                l_vendor_num);

    
    /* Set Check Number to WorkFlow Attribute */
    wf_engine.setitemattrnumber(P_item_type,
                                p_item_key,
                               'CHECK_NUMBER',
                                l_check_number);

    /* Set Check Date to the WorkFlow Attribute */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                             'CHECK_DATE',
                              l_check_date);

    /* Set Payment Currency Code to Workflow Attribute */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                             'PAYMENT_CURRENCY',
                              l_currency_code);

    /* Set Check Amount to the Workflow Attribute */
    wf_engine.setitemattrnumber(p_item_type,
                                p_item_key,
                               'CHECK_AMOUNT',
                                l_payment_amount);

    /* Set Email Address to Workflow Adhoc Role */
    wf_engine.setitemattrtext(p_item_type,
                              p_item_key,
                              'EMAIL_ADDRESS',
                              l_role);



    -- Set document_id for document  attribute

    l_document_id := 'PLSQLCLOB:XX_AP_PAYMENT_EVENT_WF_PKG.GET_PAID_INVOICES/'||l_check_id;

    wf_engine.setItemAttrText( itemtype => p_item_type,
                               itemkey => p_item_key,
                               aname    => 'INVOICES_LIST1',
                               avalue   => l_document_id);

 END get_check_info;

 -------------------------------------------------------------------------------
 ------- Procedure get_remit_email_address returns the Remittance Email Address
 ------- of the Supplier. This procedure is called by get_check_info and rule_function
 ------- procedures
 -------------------------------------------------------------------------------

  PROCEDURE get_remit_email_address (p_check_id      in  NUMBER,
                                     p_email_address out NOCOPY VARCHAR2) is

  l_vendor_id         po_vendor_sites_all.vendor_id%type;
  l_vendor_site_id    po_vendor_sites_all.vendor_site_id%type;

  BEGIN

    SELECT vendor_id,
           vendor_site_id
    INTO   l_vendor_id,
           l_vendor_site_id
    FROM   ap_checks
    WHERE  check_id = p_check_id;

    SELECT remittance_email
    INTO   p_email_address
    FROM   po_vendor_sites
    WHERE  vendor_id = l_vendor_id
    AND    vendor_site_id = l_vendor_site_id;

  END get_remit_email_address;

 -------------------------------------------------------------------------------
 ------- Procedure get_remit_email_address returns the Remittance Email Address
 ------- of the Supplier. This procedure is called by get_check_info and rule_function
 ------- procedures
 -------------------------------------------------------------------------------------------

  PROCEDURE get_check_status  (p_check_id     in NUMBER,
                               p_check_status out NOCOPY VARCHAR2) is


  BEGIN

    SELECT status_lookup_code
    INTO   p_check_status
    FROM   ap_checks
    WHERE  check_id = p_check_id;

  END get_check_status;

 ------ Procedure rule_function is called by the Subscription program. Rule Function determines
 ------ whether WorkFlow Program should be called.
 ------ Rule Defined is that to call the Workflow program only if the Remittance Email Address
 ------ is available for the Supplier.
 -------------------------------------------------------------------------------------------

  FUNCTION rule_function (p_subscription in RAW,
                          p_event        in out NOCOPY WF_EVENT_T) return varchar2 is


 l_rule                  VARCHAR2(20);
 l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
 l_parameter_t           wf_parameter_t:= wf_parameter_t(null, null);
 i_parameter_name        l_parameter_t.name%type;
 i_parameter_value       l_parameter_t.value%type;
 i                       pls_integer;

 l_check_id              l_parameter_t.value%type;
 l_org_id                l_parameter_t.value%type;
 l_email_address         po_vendor_sites_all.remittance_email%type;
 l_check_status          ap_checks_all.status_lookup_code%type;

 BEGIN

    l_parameter_list := p_event.getParameterList();
        if l_parameter_list is not null
        then
                i := l_parameter_list.FIRST;
                while ( i <= l_parameter_list.LAST )
                loop
                        i_parameter_name := null;
                        i_parameter_value := null;

                        i_parameter_name := l_parameter_list(i).getName();
                        i_parameter_value := l_parameter_list(i).getValue();

                        if i_parameter_name is not null
                        then
                                if    i_parameter_name = 'CHECK_ID'
                                then
                                        l_check_id := i_parameter_value;
                                elsif i_parameter_name = 'ORG_ID'
                                then
                                        l_org_id   := i_parameter_value;
                                end if;
                        end if;
                        i := l_parameter_list.NEXT(i);
                end loop;

          end if;


    /* Set the Org_id Context */

      if l_org_id is not null
      then

         fnd_client_info.set_org_context(l_org_id);

      end if;


    /* Convert check_id into number as function get_value returns
       it as a varchar2 */

       get_remit_email_address(to_number(l_check_id),l_email_address);

    /* Get the status of the Check */

       get_check_status(to_number(l_check_id),l_check_status);


    /* if email address is missing, then do not execute WF program */

    if l_email_address is not null
    then

      /* if check is voided, then do not execute WF program */

      if l_check_status <> 'VOIDED'
      then

         l_rule :=  wf_rule.default_rule(p_subscription,p_event);

      end if;

    end if;

   return ('SUCCESS');

 END rule_function;

  --
  --  This procedure is called from the Document type attribute in the
  --  WF to return the CLOB with all the formatting for the email
  --
  PROCEDURE Get_Paid_Invoices (
                document_id                     IN      VARCHAR2,
                display_type                    IN      VARCHAR2,
                document                        IN OUT NOCOPY  CLOB,
                document_type                   IN OUT NOCOPY  VARCHAR2) IS

  -- Local Variables
  l_debug_loc               VARCHAR2(1000);
  l_check_id                ap_checks_all.check_id%TYPE;
  l_message_line            VARCHAR2(200);
  l_buffer                  VARCHAR2(32767) := NULL;
  l_buffer_size             NUMBER := 32767;

  l_message_title           VARCHAR2(4000);
  l_msg_payment_number      VARCHAR2(4000);
  l_msg_payment_date        VARCHAR2(4000);
  l_msg_payment_currency    VARCHAR2(4000);
  l_msg_payment_amount      VARCHAR2(4000);

  l_msg_lines_inv_number    VARCHAR2(4000);
  l_msg_lines_inv_date      VARCHAR2(4000);
  l_msg_lines_disc_taken    VARCHAR2(4000);
  l_msg_lines_amount_paid   VARCHAR2(4000);

  CURSOR c_message_lines IS
        SELECT  '<TR><TD>'||invoice_num||
                '</TD><TD>'||fnd_date.date_to_chardate(ai.invoice_date)||
                --'</TD><TD ALIGN="RIGHT">'||
                --to_char(aip.discount_taken, fnd_currency.get_format_mask(ai.payment_currency_code,30))||
                '</TD><TD ALIGN="RIGHT">'||
                to_char(nvl(aip.amount, 0), fnd_currency.get_format_mask(ai.payment_currency_code,30))||
                '</TD></TR>'
        FROM    ap_invoice_payments_all aip, ap_invoices_all ai
        WHERE   aip.check_id = l_check_id
        AND     ai.invoice_id = aip.invoice_id
        ORDER BY invoice_num;

  BEGIN

    l_debug_loc := 'Inside XX_AP_PAYMENT_EVENT_WF_PKG.Get_Paid_Invoices'||'01';

    l_check_id := to_number(SUBSTR(document_id, INSTR(document_id,'/')+1,
                                   LENGTH(document_id)));

    l_debug_loc := 'Inside XX_AP_PAYMENT_EVENT_WF_PKG.Get_Paid_Invoice'||'02';

    -- Validate if check_id is passed from WF.
    IF l_check_id IS NULL THEN
      l_debug_loc := 'Inside XX_AP_PAYMENT_EVENT_WF_PKG.Get_Paid_Invoice'||'03';

      wf_core.token('CHECK_ID','NULL');
      wf_core.raise('WFSQL_ARGS');

    END IF;

    l_debug_loc := 'Inside XX_AP_PAYMENT_EVENT_WF_PKG.Get_Paid_Invoice'||'04';

    --
    --  Format the header information for the message
    --

    --  Get message text
    l_message_title := fnd_message.get_string('SQLAP', 'AP_APPEWF_HEADER_TITLE');
    l_msg_payment_number := fnd_message.get_string('SQLAP', 'AP_APPEWF_PAYMENT_NUMBER');
    l_msg_payment_date := fnd_message.get_string('SQLAP', 'AP_APPEWF_PAYMENT_DATE');
    l_msg_payment_currency := fnd_message.get_string('SQLAP', 'AP_APPEWF_PAYMENT_CURRENCY');
    l_msg_payment_amount := fnd_message.get_string('SQLAP', 'AP_APPEWF_PAYMENT_AMOUNT');
    l_msg_lines_inv_number := fnd_message.get_string('SQLAP', 'AP_APPEWF_LINES_INVOICE_NUMBER');
    l_msg_lines_inv_date := fnd_message.get_string('SQLAP', 'AP_APPEWF_LINES_INVOICE_DATE');
    --l_msg_lines_disc_taken := fnd_message.get_string('SQLAP', 'AP_APPEWF_LINES_DISCOUNT_TAKEN');
    l_msg_lines_amount_paid := fnd_message.get_string('SQLAP', 'AP_APPEWF_LINES_AMOUNT_PAID');


    --  Get payment info including formatting.  This is the header section of
    --  body of the email.  It is included in the l_buffer variable

    SELECT '<BR>'||l_message_title||
           '<BR><BR><BR><TABLE><TR><TD WIDTH=160><B>'||
           l_msg_payment_number||
           '</B></TD><TD>'||
           to_char(ac.check_number)||
           '</TD></TR><TR><TD><B>'||
           l_msg_payment_date||
           '</B></TD><TD>'||
           fnd_date.date_to_chardate(ac.check_date)||
           '</TD></TR><TR><TD><B>'||
           l_msg_payment_currency||
           '</B></TD><TD>'||
           ac.currency_code||
           '</TD></TR><TR><TD><B>'||
           l_msg_payment_amount||
           '</B></TD><TD>'||
           to_char(nvl(ac.amount, 0), fnd_currency.get_format_mask(ac.currency_code, 30))||
           '</TD></TR></TABLE><BR><BR>'
      INTO l_buffer
      FROM ap_checks_all ac
     WHERE check_id = l_check_id;


    --
    --  To include the headers for the list of invoices
    --

    l_buffer := l_buffer ||'<CENTER><TABLE ALIGN=CENTER><TR><TD WIDTH=155><U>'||
                           l_msg_lines_inv_number||'</U></TD><TD WIDTH=120><U>'||
                           l_msg_lines_inv_date||'</U></TD><TD ALIGN=RIGHT WIDTH=140><U>'||
                           --l_msg_lines_disc_taken||'</U></TD><TD ALIGN=RIGHT WIDTH=140><U>'||
                           l_msg_lines_amount_paid||'</U></TD></TR>' ;


    --
    --  Open the cursor that select the list of invoices formated
    --  There is no need to create the temporary CLOB.  WF does it.
    --  Populating the l_buffer variable minimize the times the
    --  WF_NOTIFICATION.WriteToCLob API is called for performance.
    --

    OPEN c_message_lines;

    LOOP
       FETCH c_message_lines INTO l_message_line;
       EXIT WHEN c_message_lines%NOTFOUND;

       IF length(l_buffer||l_message_line) <= l_buffer_size THEN
          l_buffer := l_buffer || l_message_line;

       ELSE
          WF_NOTIFICATION.WriteToClob(document, l_buffer);
          l_buffer := l_message_line;  -- bug 3958432

       END IF;

    END LOOP;

    if (l_buffer is not null) then
        l_buffer := l_buffer || '</TABLE></CENTER><BR><BR>';
        WF_NOTIFICATION.WriteToClob(document, l_buffer);

    else
        WF_NOTIFICATION.WriteToClob(document, '</TABLE></CENTER><BR><BR>');

    end if;

    l_debug_loc := 'Inside AP_PAYMENT_EVENT_WF_PKG.Get_Paid_Invoice'||'05';

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      wf_core.token('ORA_ERROR',
                    l_debug_loc||to_char(SQLCODE)||substr(SQLERRM,1,500));
      wf_core.raise('WF_ORA');
    WHEN OTHERS THEN
      wf_core.token('ORA_ERROR',
                    l_debug_loc||to_char(SQLCODE)||substr(SQLERRM,1,500));
      wf_core.raise('WF_ORA');

  END Get_Paid_Invoices;

END XX_AP_PAYMENT_EVENT_WF_PKG;

/
