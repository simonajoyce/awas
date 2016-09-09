CREATE OR REPLACE PACKAGE XX_PO_AUTOCREATE_DOC AUTHID CURRENT_USER AS

procedure should_req_be_autocreated(itemtype   IN   VARCHAR2,
                                    itemkey    IN   VARCHAR2,
                                    actid      IN   NUMBER,
                                    funcmode   IN   VARCHAR2,
                                    resultout  OUT NOCOPY  VARCHAR2 );
                                    
procedure verify_po_contacts(itemtype  IN   VARCHAR2,
                                     itemkey   IN   VARCHAR2,
                                     actid     IN   NUMBER,
                                     funcmode  IN   VARCHAR2,
                                     resultout OUT NOCOPY  VARCHAR2 );
                                     
                                     
END xx_PO_AUTOCREATE_DOC;
 
/


CREATE OR REPLACE PACKAGE BODY XX_PO_AUTOCREATE_DOC AS

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');


/***************************************************************************
 *
 *	Procedure:	should_req_be_autocreated
 *
 *	Description:	Decides whether automatic autocreation should
 *			take place or not.
 *
 **************************************************************************/
procedure should_req_be_autocreated(itemtype   IN   VARCHAR2,
                                    itemkey    IN   VARCHAR2,
                                    actid      IN   NUMBER,
                                    funcmode   IN   VARCHAR2,
                                    resultout  OUT NOCOPY  VARCHAR2 ) is

x_autocreate_doc   varchar2(1);
x_progress         VARCHAR2(300);
x_req_header_id  NUMBER;
x_tam_cat number;
BEGIN

x_req_header_id := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'REQ_HEADER_ID');

IF x_req_header_id IS NULL THEN

  SELECT substr(itemkey,1,instr(itemkey,'-')-1)*1 
  into x_req_header_id
  from dual;

end if;

  /*  For AWAS All PO except TAM related PO are autocreated. */
  
  SELECT sum(decode(c.segment1,'PARTS',1,0))
  into x_tam_cat
  FROM po_requisition_headers_all h,
       po_requisition_lines_all l,
       mtl_categories_b c
      WHERE  h.requisition_header_id = l.requisition_header_id
      AND l.category_id = c.category_id (+)
      and l.requisition_header_id = x_req_header_id;
  
  

   IF x_tam_cat > 0
   THEN 
   x_autocreate_doc := 'N';
   ELSE
   x_autocreate_doc := 'Y';
   END IF;
   
   /* This decision is made by simply looking at an item atrribute,
    * which has a default value. All the user needs to do is change
    * that attribute according to their needs.
    */

   --x_autocreate_doc := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
     --                                             itemkey  => itemkey,
       --                                           aname    => 'AUTOCREATE_DOC');

   if (x_autocreate_doc = 'Y') then
     resultout := wf_engine.eng_completed || ':' ||  'Y';

     x_progress:= '10: should_req_be_autocreated: result = Y';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   else
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '20: should_req_be_autocreated: result = N';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;
   END IF;
   
   po_wf_util_pkg.setItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AUTOCREATE_DOC',
                                                avalue   => x_autocreate_doc);
   

exception
  when others then
    wf_core.context('po_autocreate_doc','should_req_be_autocreated',x_progress);
    raise;
end should_req_be_autocreated;

  procedure verify_po_contacts(itemtype  IN   VARCHAR2,
                                     itemkey   IN   VARCHAR2,
                                     actid     IN   NUMBER,
                                     funcmode  IN   VARCHAR2,
                                     resultout OUT NOCOPY  VARCHAR2 ) AS
                                     
l_user_id NUMBER;
l_requisition_line_id number;
l_vendor_site_id NUMBER;
l_contact_name varchar2(20);
l_contact_number VARCHAR2(15);
l_email_address VARCHAR2(2000);

  BEGIN

-- Set local Variables
 l_user_id := 1622;  -- replace

 l_requisition_line_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'REQ_LINE_ID');
                                           
                                    
  SELECT vendor_site_id,
         substr(suggested_vendor_contact,1,20),
         substr(suggested_vendor_phone,1,15),
         suggested_vendor_contact_email
  INTO   l_vendor_site_id,
         l_contact_name,
         l_contact_number,
         l_email_address
  FROM po_requisition_lines_all 
  WHERE requisition_line_id = l_requisition_line_id;
  
-- next insert contact where it does not exist

 
if l_email_address is not null then 
 
INSERT INTO po_vendor_contacts 
(VENDOR_CONTACT_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,VENDOR_SITE_ID,CREATION_DATE,CREATED_BY,
LAST_NAME,PHONE,
EMAIL_ADDRESS) 
select po_vendor_contacts_s.nextval,
          SYSDATE,
          l_user_id,
          l_vendor_site_id,
          SYSDATE,
          l_user_id,
          l_contact_name,
          l_contact_number,
          l_email_address
          FROM po_requisition_lines_all l
          WHERE NOT EXISTS (SELECT 1 FROM po_vendor_contacts c WHERE upper(l_email_address) = upper(c.email_address)
                                                                 AND l_vendor_site_id = c.vendor_site_id)
          and requisition_line_id = l_requisition_line_id;

-- set contact id on requisition line.
UPDATE po_requisition_lines_all l 
SET vendor_contact_id = (SELECT vendor_contact_id FROM po_vendor_contacts c WHERE c.vendor_site_id = l_vendor_site_id
                                                                            AND upper(l_email_address) = upper(c.email_address))
where requisition_line_id = l_requisition_line_id;

-- Update communication details on Vendor Site
UPDATE po_vendor_sites_all
SET email_address = l_email_address,
    supplier_notif_method = 'EMAIL'
WHERE vendor_site_id = l_vendor_site_id;

end if;

-- set resultout
  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  END verify_po_contacts;

END XX_PO_AUTOCREATE_DOC;
/
