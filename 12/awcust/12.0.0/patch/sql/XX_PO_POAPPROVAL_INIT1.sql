CREATE OR REPLACE PACKAGE xx_PO_POAPPROVAL_INIT1 AUTHID CURRENT_USER AS



 /*=======================================================================+
 | FILENAME
 |
 |
 | DESCRIPTION
 |  Custom AWAS APckage to populate PO attributes
 |
 | NOTES
 | MODIFIED    Simon Joyce 13-Aug-2012
 *=====================================================================*/


--
-- Get_PO_Attributes
--   Get the PO attributes. We get the header info and up to 5
--   PO lines.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Activity Performed   - Activity was completed without any errors.
--
procedure Get_PO_Attributes(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out NOCOPY varchar2	);

-- Is_this_new_doc
--   Is this a new document or a change order.
--
-- IN
--   itemtype  --   itemkey  --   actid   --   funcmode
-- OUT
--   Resultout
--    - Y/N
--
PROCEDURE attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	);

  PROCEDURE to_supplier_docs_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	);


  PROCEDURE get_attachments (document_id in varchar2, display_type in varchar2, document IN OUT BLOB, document_type IN OUT VARCHAR2);


END XX_PO_POAPPROVAL_INIT1;

/


CREATE OR REPLACE PACKAGE BODY XX_PO_POAPPROVAL_INIT1 AS
/* $Header: POXWPA2B.pls 115.22.11510.12 2009/03/13 06:25:35 lswamina ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on; --< Bug 3554754 >

g_pkg_name           CONSTANT VARCHAR2(30) := 'PO_POAPPROVAL_INIT1';
g_module_prefix      CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED	       CONSTANT NUMBER	     := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE	       CONSTANT NUMBER	     := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT	       CONSTANT NUMBER	     := FND_LOG.LEVEL_STATEMENT;

 /*=======================================================================+
 | FILENAME
 |
 |
 | DESCRIPTION
 |   PL/SQL body for package:  XX_PO_POAPPROVAL_INIT1
 |
 | NOTES        Simon Joyce Created 12-Aug-2012
 | MODIFIED    (MM/DD/YY)
 *=======================================================================*/
--
-- Get_PO_Attributes
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure Get_PO_Attributes(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_po_header_id NUMBER;
l_document_type varchar2(50);
l_project_name PA_PROJECTS_ALL.NAME%TYPE;
l_req_justification po_requisition_headers_all.note_to_authorizer%type;
l_change_summary po_headers_all.change_summary%type;


l_authorization_status VARCHAR2(25);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name WF_USERS.name%TYPE;  --Bug7562122

x_display_name  VARCHAR2(60);
x_document_id  NUMBER;
x_tam  NUMBER;

BEGIN

  x_progress := 'XX_PO_POAPPROVAL_INIT1.Get_PO_Attributes: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


dbms_output.put_line('Here 0');
  l_po_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
   l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

dbms_output.put_line('document_type'||l_document_type);
dbms_output.put_line('l_po_header_id'||l_po_header_id);

IF l_document_type IS NULL THEN

SELECT type_lookup_code
INTO l_document_type
FROM po_headers_all
WHERE po_header_id = l_po_header_id;

end if;

  dbms_output.put_line('document_type'||l_document_type);

if l_document_type not in ('BLANKET','PA') then

SELECT xp.NAME, rh.note_to_authorizer
  INTO l_project_name,
  l_req_justification
    FROM po_distributions_all xpda,
    po_requisition_headers_all rh,
    po_requisition_lines_all rl,
    po_req_distributions_all rd,
      pa_projects_all xp,
      dual z
    WHERE xpda.project_id = xp.project_id (+)
    AND xpda.req_distribution_id = rd.distribution_id (+)
    AND rd.requisition_line_id = rl.requisition_line_id (+)
    and rl.requisition_header_id = rh.requisition_header_id (+)
    AND xpda.po_distribution_id =
    (SELECT MIN(po_distribution_id)
      FROM po_distributions_all xd
      WHERE nvl(xd.po_release_id,xd.po_header_id) = nvl(xpda.po_release_id,xpda.po_header_id))
    AND nvl(xpda.po_release_id,xpda.po_header_id) = l_po_header_id;

    dbms_output.put_line('Here 1');
    dbms_output.put_line('l_project_name'||l_project_name);
    dbms_output.put_line('l_req_justification'||l_req_justification);

  IF l_project_name IS NOT NULL THEN

    dbms_output.put_line('Here 2');
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'XX_PROJECT_NAME',
                                  avalue     =>  l_project_name);

    else

        dbms_output.put_line('line 133');

    SELECT attribute12
    INTO l_project_name
    FROM po_headers_all
    where po_header_id = l_po_header_id
    union
    select attribute12
    from po_releases_all
    where po_release_id = l_po_header_id;

   dbms_output.put_line('line 144');

   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'XX_PROJECT_NAME',
                                  avalue     =>  l_project_name);

    dbms_output.put_line('line 151');

    END IF;

    dbms_output.put_line('line 155');


  if l_document_type not in ('RELEASE') then
   select change_summary
   into l_change_summary
   from po_headers_all
   where po_header_id = l_po_header_id;

   dbms_output.put_line('line 156');
   end if;


   if l_change_summary is not null then
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'AWAS_CHANGE_SUMMARY',
                                  avalue     =>  l_change_summary);
    end if;



        dbms_output.put_line('Here 3');

   IF l_req_justification IS NOT NULL THEN

      dbms_output.put_line('Here 4');
   wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'XX_REQ_JUSTIFICATION',
                                  avalue     =>  l_req_justification);
    END IF;

    dbms_output.put_line('Here 5');
    END IF;

    dbms_output.put_line('Here 6');
     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --
  x_progress :=  'XX_PO_POAPPROVAL_INIT1.Get_PO_Attributes: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


-- Set the Copy PO to procurement@awas.com if orer is for items with a category beginning with PARTS

      x_display_name := wf_engine.getitemattrtext(     itemtype   => itemtype,
                                                          itemkey    => itemkey,
                                                          aname      => 'DOCUMENT_DISPLAY_NAME');

        x_document_id  := wf_engine.GetItemAttrNumber(     itemtype   => itemtype,
                                                          itemkey    => itemkey,
                                                          aname      => 'DOCUMENT_ID');

        IF x_display_name = 'Standard PO' THEN

        SELECT sum(decode(c.segment1,'PARTS',1,0))
        into x_tam
        FROM po_lines_all l,
        mtl_categories_b c
        WHERE po_header_id = x_document_id
        and l.category_id = c.category_id;

        IF x_tam > 0 then

                   wf_engine.SetItemAttrText (    itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'EMAIL_ADD_FROM_PROFILE',
                                          avalue          =>  'procurement@awas.com');


        END IF;

        END IF;





EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('XX_PO_POAPPROVAL_INIT1','Get_PO_Attributes',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_POAPPROVAL_INIT1.GET_PO_ATTRIBUTES',l_po_header_id); /* 6874681 Passing document id to avoid exceptions in the called procedure */
    raise;

END Get_PO_Attributes;

PROCEDURE to_supplier_docs_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	)

  -- This procedure just get TO_SUPPLIER documents
	IS
	   l_attachment_count   NUMBER                  := NULL;
	   l_file_name          VARCHAR2 (100)          := NULL;
	   l_file_id            fnd_lobs.file_id%TYPE   := NULL;
	   l_file_attached      VARCHAR2 (4000);
	   l_attrname           wf_engine.nametabtyp;

	   l_attrval            wf_engine.texttabtyp;
	   l_po_num             VARCHAR2 (50);   -- Ticket 70132

	   CURSOR c_file_table (p_po_header_id NUMBER)
	   IS
	      SELECT FL.FILE_ID, FL.FILE_NAME
	        FROM FND_ATTACHED_DOCUMENTS FAD, FND_DOCUMENTS FDT, FND_LOBS FL, FND_DOCUMENTS_TL fdt1
	       WHERE (   (ENTITY_NAME = 'PO_RELEASES' AND FAD.PK1_VALUE = p_PO_HEADER_ID)
	              OR (entity_name = 'PO_HEADERS' AND fad.pk1_value = p_po_header_id)
	              OR (entity_name = 'PO_HEADERS' AND fad.pk1_value = (SELECT po_header_id
	                                                                    FROM PO_RELEASES_ALL
	                                                                   WHERE po_release_id = p_po_header_id))
	              OR (entity_name = 'PO_LINES' AND pk1_value IN (SELECT po_line_id
	                                                               FROM PO_LINES_ALL
	                                                              WHERE po_header_id = p_po_header_id))
	              OR (entity_name = 'PO_LINES' AND pk1_value IN (SELECT po_line_id
	                                                               FROM po_lines_all
	                                                              WHERE po_header_id = (SELECT po_header_id
	                                                                                      FROM PO_RELEASES_ALL
	                                                                                     WHERE po_release_id = p_po_header_id)))
	              OR (entity_name = 'PO_SHIPMENTS' AND pk1_value IN (SELECT line_location_id
	                                                                   FROM PO_LINE_LOCATIONS_RELEASE_V
	                                                                  WHERE po_release_id = p_po_header_id))
                             )
	         AND FAD.DOCUMENT_ID = FDT.DOCUMENT_ID
           and fdt.document_id = fdt1.document_id(+)
	         AND fdt.media_id = fl.file_id
	         AND nvl(FDT1.DESCRIPTION,'a') <> 'POR:See Address Below'
           and fad.category_id = 33
	         AND (FL.EXPIRATION_DATE IS NULL OR FL.EXPIRATION_DATE > SYSDATE)
	         UNION
           SELECT FL.FILE_ID, FL.FILE_NAME
	         FROM fnd_attached_documents fad, fnd_documents fdt, fnd_lobs fl, fnd_documents_tl fdt1
           WHERE fad.document_id = fdt.document_id
           AND fdt.media_id = fl.file_id
           AND FAD.CATEGORY_ID = 33
           and fdt.document_id = fdt1.document_id(+)
	         AND (FL.EXPIRATION_DATE IS NULL OR FL.EXPIRATION_DATE > SYSDATE)
           and nvl(fdt1.description,'a') <> 'POR:See Address Below'
           AND ((entity_name = 'REQ_LINES' and pk2_value is null AND pk1_value in (SELECT distinct rl.requisition_line_id
                             FROM po_distributions_all pod,
                                  po_req_distributions_all rd,
                                  po_requisition_lines_all rl
                             WHERE pod.req_distribution_id = rd.distribution_id (+)
                             AND RD.REQUISITION_LINE_ID = RL.REQUISITION_LINE_ID (+)
                             AND po_header_id = p_po_header_id))
                             OR (entity_name = 'REQ_HEADERS' AND pk1_value in (SELECT distinct rl.requisition_header_id
                                                                   FROM po_distributions_all pod,
                                                                   po_req_distributions_all rd,
                                                                   po_requisition_lines_all rl
                                                                   WHERE pod.req_distribution_id = rd.distribution_id (+)
                                                                   AND RD.REQUISITION_LINE_ID = RL.REQUISITION_LINE_ID (+)
                                                                   AND po_header_id = p_po_header_id)));


	   TYPE file_tbl IS TABLE OF c_file_table%ROWTYPE
	      INDEX BY BINARY_INTEGER;

	   l_file_tbl           file_tbl;
	   l_run_query          VARCHAR2 (2000);
	   ln_po_header_id      NUMBER;
	BEGIN
	   IF (funcmode != wf_engine.eng_run)
	   THEN
	      --  Do nothing in cancel or timeout mode
	      resultout := wf_engine.eng_null;
	      RETURN;
	      END IF;

        dbms_output.put_line('Line 189');

	      ln_po_header_id := apps.wf_engine.getitemattrnumber (itemtype,
	                                                           itemkey,
	                                                           'DOCUMENT_ID'
	                                                          );
        dbms_output.put_line('DOCUMENT_ID='||ln_po_header_id);

	      -- Get the attachments into the PL/SQL table
	      OPEN c_file_table (ln_po_header_id);

	      FETCH c_file_table
	      BULK COLLECT INTO l_file_tbl;

	      CLOSE c_file_table;

	-------------------------------------------------------
	--Get the attachments
	--Assign to Document Attributes
	--------------------------------------------------------
	      IF l_file_tbl.COUNT > 0
	      THEN


	         FOR idx IN l_file_tbl.FIRST .. l_file_tbl.COUNT
	         LOOP
	            IF idx < 5   -- We are allowing a maximum of 5 attachments for a notification
	            THEN

                 l_attrname (idx) := 'XX_TO_SUPPLIER_ATTACHMENT' || idx;


	               l_attrval (idx) := 'PLSQLBLOB:xx_po_poapproval_init1.to_supplier_docs_exist/' || TO_CHAR (l_file_tbl (idx).file_id);


	            END IF;
	         END LOOP;


                wf_engine.setitemattrtextarray (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => l_attrname,
                                  avalue     => l_attrval);


	      END IF;


	   resultout := wf_engine.eng_completed;
	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xx_wf_attachments_pkg', 'to_supplier_docs_exist');
	      RAISE;
	END to_supplier_docs_exist;

PROCEDURE attachment_exist (
	   itemtype    IN              VARCHAR2,
	   itemkey     IN              VARCHAR2,
	   actid       IN              VARCHAR2,
	   funcmode    IN              VARCHAR2,
	   resultout   IN OUT NOCOPY   VARCHAR2
	)
	IS
	   l_attachment_count   NUMBER                  := NULL;
	   l_file_name          VARCHAR2 (100)          := NULL;
	   l_file_id            fnd_lobs.file_id%TYPE   := NULL;
	   l_file_attached      VARCHAR2 (4000);
	   l_attrname           wf_engine.nametabtyp;

	   l_attrval            wf_engine.texttabtyp;
	   l_po_num             VARCHAR2 (50);   -- Ticket 70132

	   CURSOR c_file_table (p_po_header_id NUMBER)
	   IS
      SELECT MAX(file_id) file_id
     , file_name
   FROM
       (
               SELECT FL.FILE_ID
                   , FL.FILE_NAME
                 FROM FND_ATTACHED_DOCUMENTS FAD
                   , FND_DOCUMENTS FDT
                   , FND_LOBS FL
                   , FND_DOCUMENTS_TL fdt1
                WHERE
                     (
                            (
                                   ENTITY_NAME   = 'PO_RELEASES'
                               AND FAD.PK1_VALUE = p_po_HEADER_ID
                            )
                         OR
                            (
                                   entity_name   = 'PO_HEADERS'
                               AND fad.pk1_value = p_po_header_id
                            )
                         OR
                            (
                                   entity_name   = 'PO_HEADERS'
                               AND fad.pk1_value =
                                   (
                                           SELECT po_header_id
                                             FROM PO_RELEASES_ALL
                                            WHERE po_release_id = p_po_header_id
                                   )
                            )
                         OR
                            (
                                   entity_name = 'PO_LINES'
                               AND pk1_value  IN
                                   (
                                           SELECT po_line_id
                                             FROM PO_LINES_ALL
                                            WHERE po_header_id = p_po_header_id
                                   )
                            )
                         OR
                            (
                                   entity_name = 'PO_LINES'
                               AND pk1_value  IN
                                   (
                                           SELECT po_line_id
                                             FROM po_lines_all
                                            WHERE po_header_id =
                                                 (
                                                         SELECT po_header_id
                                                           FROM PO_RELEASES_ALL
                                                          WHERE po_release_id = p_po_header_id
                                                 )
                                   )
                            )
                         OR
                            (
                                   entity_name = 'PO_SHIPMENTS'
                               AND pk1_value  IN
                                   (
                                           SELECT line_location_id
                                             FROM PO_LINE_LOCATIONS_RELEASE_V
                                            WHERE po_release_id = p_po_header_id
                                   )
                            )
                     )
                 AND FAD.DOCUMENT_ID            = FDT.DOCUMENT_ID
                 AND fdt.file_name              = fl.file_name
                 AND fdt.document_id            = fdt1.document_id(+)
                 AND fdt.media_id               = fl.file_id
                 AND NVL(FDT1.DESCRIPTION,'a') <> 'POR:See Address Below'
                 AND
                     (
                            FL.EXPIRATION_DATE IS NULL
                         OR FL.EXPIRATION_DATE  > SYSDATE
                     )
                UNION
               SELECT FL.FILE_ID
                   , FL.FILE_NAME
                 FROM fnd_attached_documents fad
                   , fnd_documents fdt
                   , fnd_lobs fl
                   , fnd_documents_tl fdt1
                WHERE fad.document_id = fdt.document_id
                 AND fdt.media_id     = fl.file_id
                 AND fdt.document_id  = fdt1.document_id(+)
                 AND fdt.file_name    = fl.file_name
                 AND
                     (
                            FL.EXPIRATION_DATE IS NULL
                         OR FL.EXPIRATION_DATE  > SYSDATE
                     )
                 AND NVL(fdt1.description,'a') <> 'POR:See Address Below'
                 AND
                     (
                            (
                                   entity_name = 'REQ_LINES'
                               AND pk2_value  IS NULL
                               AND pk1_value  IN
                                   (
                                          SELECT DISTINCT rl.requisition_line_id
                                             FROM po_distributions_all pod
                                               , po_req_distributions_all rd
                                               , po_requisition_lines_all rl
                                            WHERE pod.req_distribution_id = rd.distribution_id (+)
                                             AND RD.REQUISITION_LINE_ID   = RL.REQUISITION_LINE_ID (+)
                                             AND po_header_id             = p_po_header_id
                                   )
                            )
                         OR
                            (
                                   entity_name = 'REQ_HEADERS'
                               AND pk1_value  IN
                                   (
                                          SELECT DISTINCT rl.requisition_header_id
                                             FROM po_distributions_all pod
                                               , po_req_distributions_all rd
                                               , po_requisition_lines_all rl
                                            WHERE pod.req_distribution_id = rd.distribution_id (+)
                                             AND RD.REQUISITION_LINE_ID   = RL.REQUISITION_LINE_ID (+)
                                             AND po_header_id             = p_po_header_id
                                   )
                            )
                     )
       )
GROUP BY file_name;

	   TYPE file_tbl IS TABLE OF c_file_table%ROWTYPE
	      INDEX BY BINARY_INTEGER;

	   l_file_tbl           file_tbl;
	   l_run_query          VARCHAR2 (2000);
	   ln_po_header_id      NUMBER;
	  l_buyer  VARCHAR2(240);
    l_buyer_details  VARCHAR2(240);
    l_buyer_email  varchar2(240);

  BEGIN
	   IF (funcmode != wf_engine.eng_run)
	   THEN
	      --  Do nothing in cancel or timeout mode
	      resultout := wf_engine.eng_null;
	      RETURN;
	      END IF;



  -- first set buyer email

     l_buyer := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'BUYER_USER_NAME');


      IF l_buyer <> 'AWASBUYER' THEN

      SELECT email_address
      into l_buyer_email
      FROM fnd_user
      WHERE user_name = l_buyer;

      l_buyer_details := 'For any questions or queries relating to this order please email '||l_buyer_email;

      wf_engine.SetItemAttrText (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'XX_BUYER_DETAILS',
                                  avalue     =>  l_buyer_details);

      end if;



        dbms_output.put_line('Line 189');

	      ln_po_header_id := apps.wf_engine.getitemattrnumber (itemtype,
	                                                           itemkey,
	                                                           'DOCUMENT_ID'
	                                                          );
        dbms_output.put_line('DOCUMENT_ID='||ln_po_header_id);


          --set notification region data
  	      po_wf_util_pkg.setitemattrtext
                     (ITEMTYPE => ITEMTYPE
                     ,itemkey  => itemkey
                     ,ANAME    => 'NOTIFICATION_REGION'
                     ,avalue   => 'JSP:/OA_HTML/OA.jsp?OAFunc=PO_APPRV_NOTIF&poHeaderId=' || ln_po_header_id);

	      -- Get the attachments into the PL/SQL table
	      OPEN c_file_table (ln_po_header_id);

	      FETCH c_file_table
	      BULK COLLECT INTO l_file_tbl;

	      CLOSE c_file_table;

	-------------------------------------------------------
	--Get the attachments
	--Assign to Document Attributes
	--------------------------------------------------------
	      IF l_file_tbl.COUNT > 0
	      THEN


	         FOR idx IN l_file_tbl.FIRST .. l_file_tbl.COUNT
	         LOOP
	            IF idx < 10   -- We are allowing a maximum of 2 attachments for a notification
	            THEN

                 l_attrname (idx) := 'XX_APPROVAL_ATTACHMENT' || idx;

                         dbms_output.put_line('PLSQLBLOB:xx_po_poapproval_init1.Get_Attachments/' || TO_CHAR (l_file_tbl (idx).file_id));
	               l_attrval (idx) := 'PLSQLBLOB:xx_po_poapproval_init1.Get_Attachments/' || TO_CHAR (l_file_tbl (idx).file_id);


	            END IF;
	         END LOOP;


                wf_engine.setitemattrtextarray (     itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => l_attrname,
                                  avalue     => l_attrval);


	      END IF;


	   resultout := wf_engine.eng_completed;
	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xx_wf_attachments_pkg', 'attachment_exist');
	      RAISE;
	END attachment_exist;

PROCEDURE get_attachments (document_id in varchar2, display_type in varchar2, document IN OUT BLOB, document_type IN OUT VARCHAR2)
	IS
	   l_attachment          BLOB;
	   l_amount              NUMBER;
	   l_file_name           VARCHAR2 (240)                    := NULL;
	   l_file_content_type   fnd_lobs.file_content_type%TYPE   := NULL;
	BEGIN
	   l_file_content_type := NULL;

	   SELECT fl.file_data, fl.file_name, fl.file_content_type
	     INTO l_attachment, l_file_name, l_file_content_type
	     FROM fnd_lobs fl
	    WHERE fl.file_id = TO_NUMBER (document_id);

	-------------------------------------------
	--Now copy the content to document
	------------------------------------------
	   l_amount := DBMS_LOB.getlength (l_attachment);
	   DBMS_LOB.COPY (document,
	                  l_attachment,
	                  l_amount,
	                  1,
	                  1
	                 );
	---------------------------------------------------------
	-- Set the MIME type as a part of the document_type.
	---------------------------------------------------------
	   document_type := l_file_content_type || '; name=' || l_file_name;
	EXCEPTION
	   WHEN OTHERS
	   THEN
	      wf_core.CONTEXT ('xxpo_wf_attachments_pkg',
	                       'Get_Attachments',
	                       document_id,
	                       display_type
	                      );
	END get_attachments;


--
END XX_PO_POAPPROVAL_INIT1;
/
