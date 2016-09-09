CREATE OR REPLACE PACKAGE XX_REQ_IMPORT_PKG AS 

procedure ProcessItems (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2) ;
 
  
PROCEDURE upload(
P_PROCESS_FLAG                  IN         VARCHAR2 DEFAULT NULL,   
P_LAST_UPDATED_BY               IN         NUMBER DEFAULT NULL,        
P_LAST_UPDATE_DATE              IN         DATE DEFAULT SYSDATE,          
P_LAST_UPDATE_LOGIN             IN         NUMBER DEFAULT NULL,        
P_CREATION_DATE                 IN         DATE DEFAULT SYSDATE,          
P_CREATED_BY                    IN         NUMBER DEFAULT NULL,        
P_INTERFACE_SOURCE_CODE         IN         VARCHAR2 DEFAULT NULL,  
P_SOURCE_TYPE_CODE              IN         VARCHAR2 DEFAULT NULL  ,
P_DESTINATION_TYPE_CODE         IN         VARCHAR2 DEFAULT NULL  ,
P_ITEM_DESCRIPTION              IN         VARCHAR2 DEFAULT NULL ,
P_QUANTITY                      IN         NUMBER DEFAULT NULL        ,
P_UNIT_PRICE                    IN         NUMBER DEFAULT NULL        ,
P_AUTHORIZATION_STATUS          IN         VARCHAR2 DEFAULT NULL  ,
P_NOTE_TO_APPROVER              IN         VARCHAR2 DEFAULT NULL ,
P_PREPARER_ID                   IN         NUMBER DEFAULT NULL     ,
P_HEADER_DESCRIPTION            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE_CATEGORY     IN         VARCHAR2 DEFAULT NULL  ,
P_HEADER_ATTRIBUTE1             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE2             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE3             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE4             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE5             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE6             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE7             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE8             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE9             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE10            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE11            IN         DATE DEFAULT NULL ,
P_HEADER_ATTRIBUTE12            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE13            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE14            IN         VARCHAR2 DEFAULT NULL ,
P_URGENT_FLAG                   IN         VARCHAR2 DEFAULT NULL   ,
P_HEADER_ATTRIBUTE15            IN         VARCHAR2 DEFAULT NULL ,
P_RFQ_REQUIRED_FLAG             IN         VARCHAR2 DEFAULT NULL   ,
P_JUSTIFICATION                 IN         VARCHAR2 DEFAULT NULL ,
P_NOTE_TO_BUYER                 IN         VARCHAR2 DEFAULT NULL ,
P_ITEM_SEGMENT1                 IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT1       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT2       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT3       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT4       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT5       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT6       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT7       IN         VARCHAR2 DEFAULT NULL  ,
P_CATEGORY_ID                   IN         NUMBER DEFAULT NULL        ,
P_CATEGORY_SEGMENT1             IN         VARCHAR2 DEFAULT NULL  ,
P_CATEGORY_SEGMENT2             IN         VARCHAR2 DEFAULT NULL  ,
P_UNIT_OF_MEASURE               IN         VARCHAR2 DEFAULT NULL  ,
P_LINE_TYPE_ID                  IN         NUMBER DEFAULT NULL        ,
P_PROJECT_NUM                   IN         VARCHAR2 DEFAULT NULL  ,
P_TASK_NUM                      IN         VARCHAR2 DEFAULT NULL  ,
P_EXPENDITURE_TYPE              IN         VARCHAR2 DEFAULT NULL  ,
P_DESTINATION_ORGANIZATION_ID   IN         NUMBER DEFAULT 85        ,
P_DELIVER_TO_LOCATION_ID        IN         NUMBER DEFAULT NULL        ,
P_DELIVER_TO_REQUESTOR_ID       IN         NUMBER DEFAULT NULL     ,
P_SUGGESTED_VENDOR_NAME         IN         VARCHAR2 DEFAULT NULL ,
P_SUGGESTED_VENDOR_ID           IN         NUMBER DEFAULT NULL        ,
P_SUGGESTED_VENDOR_SITE         IN         VARCHAR2 DEFAULT NULL  ,
P_SUGGESTED_VENDOR_SITE_ID      IN         NUMBER DEFAULT NULL        ,
P_SUGGESTED_VENDOR_ITEM_NUM     IN         VARCHAR2 DEFAULT NULL  ,
P_LINE_ATTRIBUTE_CATEGORY       IN         VARCHAR2 DEFAULT NULL  ,
P_LINE_ATTRIBUTE1               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE2               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE3               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE4               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE5               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE6               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE7               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE8               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE9               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE10              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE11              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE12              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE13              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE14              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE15              IN         VARCHAR2 DEFAULT NULL ,
P_NEED_BY_DATE                  IN         DATE DEFAULT SYSDATE          ,
P_PROJECT_ACCOUNTING_CONTEXT    IN         VARCHAR2 DEFAULT 'Y'  ,
P_EXPENDITURE_ORGANIZATION_ID   IN         NUMBER DEFAULT NULL        ,
P_PROJECT_ID                    IN         NUMBER DEFAULT NULL        ,
P_TASK_ID                       IN         NUMBER DEFAULT NULL        ,
P_EXPENDITURE_ITEM_DATE         IN         DATE DEFAULT SYSDATE          ,
P_ORG_ID                        IN         NUMBER DEFAULT NULL        
) ;
  

END XX_REQ_IMPORT_PKG;
 
/


CREATE OR REPLACE PACKAGE BODY XX_REQ_IMPORT_PKG AS

PROCEDURE WRITE_LOG   (P_MESSAGE IN VARCHAR2 );
PROCEDURE WRITE_OUTPUT(P_MESSAGE IN VARCHAR2);
PROCEDURE WRITE_DEBUG (P_COMMENTS       in varchar2,
                       P_PROCEDURE_NAME in varchar2,
                       P_PROGRESS       in varchar2);

G_DEBUG_MODE   BOOLEAN;
V_REQUEST_ID   NUMBER;



PROCEDURE upload(
P_PROCESS_FLAG                  IN         VARCHAR2 DEFAULT NULL,   
P_LAST_UPDATED_BY               IN         NUMBER DEFAULT NULL,        
P_LAST_UPDATE_DATE              IN         DATE DEFAULT SYSDATE,          
P_LAST_UPDATE_LOGIN             IN         NUMBER DEFAULT NULL,        
P_CREATION_DATE                 IN         DATE DEFAULT SYSDATE,          
P_CREATED_BY                    IN         NUMBER DEFAULT NULL,        
P_INTERFACE_SOURCE_CODE         IN         VARCHAR2 DEFAULT NULL,  
P_SOURCE_TYPE_CODE              IN         VARCHAR2 DEFAULT NULL  ,
P_DESTINATION_TYPE_CODE         IN         VARCHAR2 DEFAULT NULL  ,
P_ITEM_DESCRIPTION              IN         VARCHAR2 DEFAULT NULL ,
P_QUANTITY                      IN         NUMBER DEFAULT NULL        ,
P_UNIT_PRICE                    IN         NUMBER DEFAULT NULL        ,
P_AUTHORIZATION_STATUS          IN         VARCHAR2 DEFAULT NULL  ,
P_NOTE_TO_APPROVER              IN         VARCHAR2 DEFAULT NULL ,
P_PREPARER_ID                   IN         NUMBER DEFAULT NULL     ,
P_HEADER_DESCRIPTION            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE_CATEGORY     IN         VARCHAR2 DEFAULT NULL  ,
P_HEADER_ATTRIBUTE1             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE2             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE3             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE4             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE5             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE6             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE7             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE8             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE9             IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE10            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE11            IN         DATE DEFAULT NULL ,
P_HEADER_ATTRIBUTE12            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE13            IN         VARCHAR2 DEFAULT NULL ,
P_HEADER_ATTRIBUTE14            IN         VARCHAR2 DEFAULT NULL ,
P_URGENT_FLAG                   IN         VARCHAR2 DEFAULT NULL   ,
P_HEADER_ATTRIBUTE15            IN         VARCHAR2 DEFAULT NULL ,
P_RFQ_REQUIRED_FLAG             IN         VARCHAR2 DEFAULT NULL   ,
P_JUSTIFICATION                 IN         VARCHAR2 DEFAULT NULL ,
P_NOTE_TO_BUYER                 IN         VARCHAR2 DEFAULT NULL ,
P_ITEM_SEGMENT1                 IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT1       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT2       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT3       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT4       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT5       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT6       IN         VARCHAR2 DEFAULT NULL  ,
P_CHARGE_ACCOUNT_SEGMENT7       IN         VARCHAR2 DEFAULT NULL  ,
P_CATEGORY_ID                   IN         NUMBER DEFAULT NULL        ,
P_CATEGORY_SEGMENT1             IN         VARCHAR2 DEFAULT NULL  ,
P_CATEGORY_SEGMENT2             IN         VARCHAR2 DEFAULT NULL  ,
P_UNIT_OF_MEASURE               IN         VARCHAR2 DEFAULT NULL  ,
P_LINE_TYPE_ID                  IN         NUMBER DEFAULT NULL        ,
P_PROJECT_NUM                   IN         VARCHAR2 DEFAULT NULL  ,
P_TASK_NUM                      IN         VARCHAR2 DEFAULT NULL  ,
P_EXPENDITURE_TYPE              IN         VARCHAR2 DEFAULT NULL  ,
P_DESTINATION_ORGANIZATION_ID   IN         NUMBER DEFAULT 85        ,
P_DELIVER_TO_LOCATION_ID        IN         NUMBER DEFAULT NULL        ,
P_DELIVER_TO_REQUESTOR_ID       IN         NUMBER DEFAULT NULL     ,
P_SUGGESTED_VENDOR_NAME         IN         VARCHAR2 DEFAULT NULL ,
P_SUGGESTED_VENDOR_ID           IN         NUMBER DEFAULT NULL        ,
P_SUGGESTED_VENDOR_SITE         IN         VARCHAR2 DEFAULT NULL  ,
P_SUGGESTED_VENDOR_SITE_ID      IN         NUMBER DEFAULT NULL        ,
P_SUGGESTED_VENDOR_ITEM_NUM     IN         VARCHAR2 DEFAULT NULL  ,
P_LINE_ATTRIBUTE_CATEGORY       IN         VARCHAR2 DEFAULT NULL  ,
P_LINE_ATTRIBUTE1               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE2               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE3               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE4               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE5               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE6               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE7               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE8               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE9               IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE10              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE11              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE12              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE13              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE14              IN         VARCHAR2 DEFAULT NULL ,
P_LINE_ATTRIBUTE15              IN         VARCHAR2 DEFAULT NULL ,
P_NEED_BY_DATE                  IN         DATE DEFAULT SYSDATE          ,
P_PROJECT_ACCOUNTING_CONTEXT    IN         VARCHAR2 DEFAULT 'Y'  ,
P_EXPENDITURE_ORGANIZATION_ID   IN         NUMBER DEFAULT NULL        ,
P_PROJECT_ID                    IN         NUMBER DEFAULT NULL        ,
P_TASK_ID                       IN         NUMBER DEFAULT NULL        ,
P_EXPENDITURE_ITEM_DATE         IN         DATE DEFAULT SYSDATE          ,
P_ORG_ID                        IN         NUMBER DEFAULT NULL        
)  AS

l_project_id NUMBER;
l_project_name VARCHAR2 (60);
l_preparer_id NUMBER;
l_task_id NUMBER;
l_vendor_id NUMBER;
t_vendor_id NUMBER;
x_uom varchar2(60);
l_CHARGE_ACCOUNT_SEGMENT1   VARCHAR2(4);
l_CHARGE_ACCOUNT_SEGMENT2   VARCHAR2(6);
l_CHARGE_ACCOUNT_SEGMENT3   VARCHAR2(4);
l_CHARGE_ACCOUNT_SEGMENT4   VARCHAR2(6);
l_CHARGE_ACCOUNT_SEGMENT5   VARCHAR2(3);
l_CHARGE_ACCOUNT_SEGMENT6   VARCHAR2(4);
l_CHARGE_ACCOUNT_SEGMENT7   VARCHAR2(4);
l_suggested_buyer_id NUMBER;
l_gl VARCHAR2(200);
x_note_to_buyer varchar2(480);
x_base_unit_price number;

no_description exception;
no_category exception;
no_vendor_part exception;
no_uom exception;
invalid_uom exception;
no_quantity exception;
minus_quantity exception;


  BEGIN


IF p_quantity IS NULL THEN
raise no_quantity;
end if;

IF p_quantity < 0 THEN
raise minus_quantity;
END IF;

    
-- validate information for parts ordered without part number.
IF p_item_segment1 IS NULL THEN

IF p_item_description IS NULL THEN
raise no_description;
END IF;

IF p_category_id IS NULL THEN 
raise no_category;
END IF;

IF P_SUGGESTED_VENDOR_ITEM_NUM IS NULL THEN
raise no_vendor_part;
END IF;

IF P_UNIT_OF_MEASURE IS NULL THEN
raise no_uom;
END IF;

ELSE 
IF P_UNIT_OF_MEASURE IS NOT NULL THEN

SELECT primary_unit_of_measure 
INTO x_UOM
FROM mtl_system_items_b WHERE segment1 = P_ITEM_SEGMENT1;

IF x_uom <> p_unit_of_measure THEN
raise invalid_uom;
END IF;
end if;


END IF;
  
  
    

--set project id and Charge Account
SELECT project_id,
       name,
       attribute2, -- entity
       attribute3,  -- natural account
       '0000', --cost centre
       attribute1,  -- MSN
       attribute4, -- Leasee
       attribute2, -- IC
       '0000' --Spare
INTO
l_project_id,
l_project_name,
l_CHARGE_ACCOUNT_SEGMENT1 ,
l_CHARGE_ACCOUNT_SEGMENT2 ,
l_CHARGE_ACCOUNT_SEGMENT3 ,
l_CHARGE_ACCOUNT_SEGMENT4 ,
l_CHARGE_ACCOUNT_SEGMENT5 ,
l_CHARGE_ACCOUNT_SEGMENT6 ,
l_CHARGE_ACCOUNT_SEGMENT7 
FROM pa_projects_all
WHERE segment1 = p_project_num;

-- create GL string if not done so already
select XX_VALID_GL_CODE (l_CHARGE_ACCOUNT_SEGMENT1
		  		   ,l_CHARGE_ACCOUNT_SEGMENT2
		  		   ,l_CHARGE_ACCOUNT_SEGMENT3
		  		   ,l_CHARGE_ACCOUNT_SEGMENT4
		  		   ,l_CHARGE_ACCOUNT_SEGMENT5
		  		   ,l_CHARGE_ACCOUNT_SEGMENT6
		  		   ,l_CHARGE_ACCOUNT_SEGMENT7)
             into l_gl
from dual;
             

-- Set P_TASK_ID
SELECT task_id
   INTO l_task_id
   FROM pa_tasks 
   WHERE chargeable_flag = 'Y'
   AND task_name = 'Default'
   AND project_id = l_project_id;
   

Begin   
-- Set suggested_buyer_id
SELECT person_id
into l_suggested_buyer_id
FROM pa_project_players
WHERE project_role_type = '1001'
AND project_id = l_project_id;

exception
WHEN OThers THEN 
l_suggested_buyer_id := 2527;  -- AWAS Default

END;

-- Get Preparer_id
SELECT employee_id
into l_preparer_id
FROM fnd_user 
where user_id = TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));


IF p_suggested_vendor_site IS NOT NULL
THEN

SELECT vendor_id
INTO l_vendor_id
FROM po_vendor_sites_all
WHERE vendor_site_id = (p_suggested_vendor_site)*1;

end if;

IF P_HEADER_ATTRIBUTE14 IS NOT NULL
THEN

SELECT vendor_id
INTO t_vendor_id
FROM po_vendor_sites_all
WHERE vendor_site_id = (P_HEADER_ATTRIBUTE14)*1;

end if;


-- concatenate supplier contact and inco terms into note to buyer
x_note_to_buyer := P_note_to_buyer;

IF P_LINE_ATTRIBUTE13 IS NOT NULL THEN 
x_note_to_buyer := x_note_to_buyer||' '||'Supplier Contact:'||P_LINE_ATTRIBUTE13;
END IF;
IF P_LINE_ATTRIBUTE14 IS NOT NULL THEN
x_note_to_buyer := x_note_to_buyer||' '||'Inco Terms:'||P_LINE_ATTRIBUTE14;
END IF;

if p_line_attribute15 <> 'USD'
then
select xx_get_exchange_rate(p_line_attribute15)*p_unit_price
into x_base_unit_price
from dual;
else
x_base_unit_price := p_unit_price;
end if;

insert into po_requisitions_interface_all
(PROCESS_FLAG                  ,   
LAST_UPDATED_BY               ,        
LAST_UPDATE_DATE              ,          
LAST_UPDATE_LOGIN             ,        
CREATION_DATE                 ,          
CREATED_BY                    ,        
INTERFACE_SOURCE_CODE         ,  
SOURCE_TYPE_CODE                ,
DESTINATION_TYPE_CODE           ,
ITEM_DESCRIPTION               ,
QUANTITY                              ,
UNIT_PRICE                            ,
AUTHORIZATION_STATUS            ,
NOTE_TO_APPROVER               ,
PREPARER_ID                    ,
HEADER_DESCRIPTION             ,
HEADER_ATTRIBUTE_CATEGORY       ,
HEADER_ATTRIBUTE1              ,
HEADER_ATTRIBUTE2              ,
HEADER_ATTRIBUTE3              ,
HEADER_ATTRIBUTE4              ,
HEADER_ATTRIBUTE5              ,
HEADER_ATTRIBUTE6              ,
HEADER_ATTRIBUTE7              ,
HEADER_ATTRIBUTE8              ,
HEADER_ATTRIBUTE9              ,
HEADER_ATTRIBUTE10             ,
HEADER_ATTRIBUTE11             ,
HEADER_ATTRIBUTE12             ,
HEADER_ATTRIBUTE13             ,
HEADER_ATTRIBUTE14             ,
URGENT_FLAG                      ,
HEADER_ATTRIBUTE15             ,
RFQ_REQUIRED_FLAG                ,
JUSTIFICATION                  ,
NOTE_TO_BUYER                  ,
ITEM_SEGMENT1                   ,
CHARGE_ACCOUNT_SEGMENT1         ,
CHARGE_ACCOUNT_SEGMENT2         ,
CHARGE_ACCOUNT_SEGMENT3         ,
CHARGE_ACCOUNT_SEGMENT4         ,
CHARGE_ACCOUNT_SEGMENT5         ,
CHARGE_ACCOUNT_SEGMENT6         ,
CHARGE_ACCOUNT_SEGMENT7         ,
CATEGORY_ID                     ,
CATEGORY_SEGMENT1               ,
CATEGORY_SEGMENT2               ,
UNIT_OF_MEASURE                 ,
LINE_TYPE_ID                    ,
PROJECT_NUM                     ,
TASK_NUM                        ,
EXPENDITURE_TYPE                ,
DESTINATION_ORGANIZATION_ID           ,
DELIVER_TO_LOCATION_ID                ,
DELIVER_TO_REQUESTOR_ID            ,
SUGGESTED_VENDOR_NAME          ,
SUGGESTED_VENDOR_ID                   ,
SUGGESTED_VENDOR_SITE           ,
SUGGESTED_VENDOR_SITE_ID              ,
SUGGESTED_VENDOR_ITEM_NUM       ,
LINE_ATTRIBUTE_CATEGORY         ,
LINE_ATTRIBUTE1                ,
LINE_ATTRIBUTE2                ,
LINE_ATTRIBUTE3                ,
LINE_ATTRIBUTE4                ,
LINE_ATTRIBUTE5                ,
LINE_ATTRIBUTE6                ,
LINE_ATTRIBUTE7                ,
LINE_ATTRIBUTE8                ,
LINE_ATTRIBUTE9                ,
LINE_ATTRIBUTE10               ,
LINE_ATTRIBUTE11               ,
LINE_ATTRIBUTE12               ,
LINE_ATTRIBUTE13               ,
LINE_ATTRIBUTE14               ,
LINE_ATTRIBUTE15               ,
NEED_BY_DATE                            ,
PROJECT_ACCOUNTING_CONTEXT      ,
EXPENDITURE_ORGANIZATION_ID           ,
PROJECT_ID                            ,
TASK_ID                               ,
EXPENDITURE_ITEM_DATE                   ,
ORG_ID                             ,
DELETE_ENABLED_FLAG,
UPDATE_ENABLED_FLAG,
SUGGESTED_BUYER_ID,
CURRENCY_CODE,
RATE_TYPE,
rate_date,
currency_unit_price
)
VALUES
(p_process_flag                  ,   
TO_NUMBER(FND_PROFILE.VALUE('USER_ID')), -- P_LAST_UPDATED_BY               ,        
SYSDATE,                                 -- P_LAST_UPDATE_DATE              ,          
P_LAST_UPDATE_LOGIN             ,        
sysdate,                                 -- P_CREATION_DATE                 ,          
TO_NUMBER(FND_PROFILE.VALUE('USER_ID')), -- P_CREATED_BY                    ,        
'AWAS ADI',                              -- P_INTERFACE_SOURCE_CODE         ,  
'VENDOR'  ,                               -- P_SOURCE_TYPE_CODE                ,
'EXPENSE',                                -- P_DESTINATION_TYPE_CODE           ,
P_ITEM_DESCRIPTION               ,
p_quantity                              ,
x_base_unit_price,
'INCOMPLETE',                             -- P_AUTHORIZATION_STATUS            ,
P_NOTE_TO_APPROVER               ,
l_PREPARER_ID                    ,
l_project_name||' '||P_HEADER_DESCRIPTION             ,
'TAM', --P_HEADER_ATTRIBUTE_CATEGORY       ,
P_HEADER_ATTRIBUTE1              ,
P_HEADER_ATTRIBUTE2              ,
P_HEADER_ATTRIBUTE3              ,
P_HEADER_ATTRIBUTE4              ,
P_HEADER_ATTRIBUTE5              ,
P_HEADER_ATTRIBUTE6              ,
P_HEADER_ATTRIBUTE7              ,
P_HEADER_ATTRIBUTE8              ,
P_HEADER_ATTRIBUTE9              ,
l_project_id  , --P_HEADER_ATTRIBUTE10             ,
P_HEADER_ATTRIBUTE11             ,
P_HEADER_ATTRIBUTE12             ,
P_HEADER_ATTRIBUTE13             ,
P_HEADER_ATTRIBUTE14             ,
P_URGENT_FLAG                      ,
P_HEADER_ATTRIBUTE15             ,
P_RFQ_REQUIRED_FLAG                ,
P_JUSTIFICATION                  ,
X_NOTE_TO_BUYER                  ,
P_ITEM_SEGMENT1                   ,
l_CHARGE_ACCOUNT_SEGMENT1         ,
l_CHARGE_ACCOUNT_SEGMENT2         ,
l_CHARGE_ACCOUNT_SEGMENT3         ,
l_CHARGE_ACCOUNT_SEGMENT4         ,
l_CHARGE_ACCOUNT_SEGMENT5         ,
l_CHARGE_ACCOUNT_SEGMENT6         ,
l_charge_account_segment7         ,
nvl2(p_item_segment1,null,p_category_id)                     ,
nvl2(p_item_segment1,null,p_category_segment1)               ,
nvl2(p_item_segment1,null,P_CATEGORY_SEGMENT2)               ,
P_UNIT_OF_MEASURE                 ,
1,                                    --P_LINE_TYPE_ID                          ,
P_PROJECT_NUM                     ,
P_TASK_NUM                        ,
nvl(P_EXPENDITURE_TYPE,P_HEADER_ATTRIBUTE12) ,
85, --P_DESTINATION_ORGANIZATION_ID          ,
P_DELIVER_TO_LOCATION_ID                ,
l_preparer_id, --P_DELIVER_TO_REQUESTOR_ID            ,
NVL(P_SUGGESTED_VENDOR_NAME,P_HEADER_ATTRIBUTE13)          ,
nvl(l_vendor_id,t_vendor_id)                   ,
null, --NVL(P_SUGGESTED_VENDOR_SITE,P_HEADER_ATTRIBUTE14)           ,
NVL(P_SUGGESTED_VENDOR_SITE,P_HEADER_ATTRIBUTE14)           ,
P_SUGGESTED_VENDOR_ITEM_NUM       ,
P_LINE_ATTRIBUTE_CATEGORY         ,
P_LINE_ATTRIBUTE1                ,
P_LINE_ATTRIBUTE2                ,
P_LINE_ATTRIBUTE3                ,
P_LINE_ATTRIBUTE4                ,
P_LINE_ATTRIBUTE5                ,
P_LINE_ATTRIBUTE6                ,
P_LINE_ATTRIBUTE7                ,
P_LINE_ATTRIBUTE8                ,
P_LINE_ATTRIBUTE9                ,
P_LINE_ATTRIBUTE10               ,
P_LINE_ATTRIBUTE11               ,
P_LINE_ATTRIBUTE12               ,
P_LINE_ATTRIBUTE13               ,
P_LINE_ATTRIBUTE14               ,
P_LINE_ATTRIBUTE15               ,
nvl(P_NEED_BY_DATE,P_HEADER_ATTRIBUTE11), --P_NEED_BY_DATE                            ,
'Y', --P_PROJECT_ACCOUNTING_CONTEXT      ,
85, --P_EXPENDITURE_ORGANIZATION_ID           ,
l_PROJECT_ID                            ,
l_TASK_ID                               ,
nvl(P_NEED_BY_DATE,P_HEADER_ATTRIBUTE11), -- P_EXPENDITURE_ITEM_DATE  -- setting the same
85,                                --P_ORG_ID 
 'Y',
'Y',
l_suggested_buyer_id,
P_LINE_ATTRIBUTE15,
DECODE(P_LINE_ATTRIBUTE15,'USD',NULL,NULL,NULL,'Corporate'),
decode(p_line_attribute15,'USD',null,null,null,sysdate),
decode(p_line_attribute15,'USD',null,null,null,nvl(p_unit_price,0))
                            );

    
  exception
  WHEN no_quantity THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'You must enter a quantity');
  
  WHEN minus_quantity THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'Quantity must be positive');
  
  WHEN no_description THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'You must enter a part description when part number is blank'); 
  
  
  WHEN no_category THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'You must enter a category when part number is blank'); 
  
  
  WHEN no_vendor_part THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'You must enter a Suggested Vendor Part Number when part number is blank'); 
  
  WHEN no_uom THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'You must enter a UOM when part number is blank');
  
  WHEN invalid_uom THEN
  FND_MESSAGE.SET_NAME('BNE','WEBADI_ERROR'); 
  FND_MESSAGE.SET_TOKEN('MSG', 'The UOM you entered against this part does not match the Master Part Number UOM. Contact Purchasing');
  
  WHEN others THEN
  fnd_message.set_name('BNE','WEBADI_ERROR'); 
  --fnd_message.set_token('MSG', 'Undefined error message'); 
  fnd_message.set_token('MSG', sqlerrm); 
  
  --insert into xx_debug values(sysdate,sqlerrm,'xx_req_import_pkg',null,null);

    
  END upload;
  
PROCEDURE ProcessItems (
          errorbuf OUT VARCHAR2,
          retcode OUT VARCHAR2) 
AS
        l_api_version    NUMBER      := 1.0;
        l_init_msg_list  VARCHAR2(2) := FND_API.G_TRUE;
        l_commit         VARCHAR2(2) := FND_API.G_FALSE;
        l_item_tbl       EGO_ITEM_PUB.ITEM_TBL_TYPE;
        l_role_grant_tbl EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE := EGO_ITEM_PUB.G_MISS_ROLE_GRANT_TBL;
        x_item_tbl       EGO_ITEM_PUB.ITEM_TBL_TYPE;
        x_message_list   Error_Handler.Error_Tbl_Type;
        x_return_status  VARCHAR2(2);
        x_msg_count      NUMBER := 0;
        y_return_status  VARCHAR2(2);
        y_errorcode      NUMBER;
        y_msg_count      NUMBER :=0;
        y_msg_data       VARCHAR2(2000);
        r_return_status  VARCHAR2(2);
        r_errorcode      NUMBER;
        r_msg_count      NUMBER :=0;
        r_msg_data       VARCHAR2(2000);
        l_user_id        NUMBER;
        l_resp_id        NUMBER := 50962;
        l_application_id NUMBER := 178;
        l_rowcnt         NUMBER := 1;
        

             /*  FROM INTERFACE
        CURSOR csr_org_items IS
           SELECT DISTINCT org_id, 
              trim(UPPER(suggested_vendor_item_num)) suggested_vendor_item_num ,
              item_description,
              category_id,
              c.uom_code
              FROM po_requisitions_interface_all i,
              mtl_units_of_measure c
              WHERE i.suggested_vendor_item_num IS NOT NULL
              and c.unit_of_measure = i.unit_of_measure;
        */
        
        
        CURSOR csr_org_items IS
        SELECT DISTINCT i.org_id, 
              trim(UPPER(i.suggested_vendor_product_code)) suggested_vendor_item_num ,
              item_description,
              category_id,
              c.uom_code
              FROM po_requisition_lines_all i,
              po_requisition_headers_all h,
              mtl_units_of_measure c
              WHERE i.suggested_vendor_product_code IS NOT NULL
              AND item_id IS NULL
              and h.requisition_header_id = i.requisition_header_id
              AND c.unit_of_measure = i.unit_meas_lookup_code
              AND modified_by_agent_flag IS NULL
              AND line_location_id IS NULL
              AND nvl(i.cancel_flag,'N')= 'N'
              AND h.authorization_status = 'APPROVED';
              
              
              ITEM_COUNT number;
              
                          
begin


      G_DEBUG_MODE := true;
      V_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      
WRITE_OUTPUT('AWAS Dynamic Part Import process started..');
WRITE_OUTPUT('');

  SELECT TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
  INTO l_user_id
  FROM dual;

	FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_application_id);  -- MGRPLM / Development Manager / EGO
	dbms_output.put_line('Initialized applications context: '|| l_user_id || ' '|| l_resp_id ||' '|| l_application_id );

-- First get Part Number assigned in Notes column
              UPDATE PO_REQUISITION_LINES_ALL
              SET suggested_vendor_product_code = upper(trim(xx_get_part(requisition_line_id)))
              WHERE suggested_vendor_product_code IS NULL
              AND item_id IS NULL
              AND modified_by_agent_flag IS NULL
              AND line_location_id IS NULL
              AND NVL(CANCEL_FLAG,'N')= 'N';
              
              DBMS_OUTPUT.PUT_LINE('Part numbers Updated '||SQL%ROWCOUNT);
              
             
-- Now check if already exists and update as appropriate.
             UPDATE po_requisition_lines_all  x
             SET item_id = (SELECT inventory_item_id FROM mtl_system_items_b WHERE segment1 = xx_rectify_non_ascii(suggested_vendor_product_code))
                          WHERE suggested_vendor_product_code IS NOT NULL
              AND item_id IS NULL
              AND modified_by_agent_flag IS NULL
              AND LINE_LOCATION_ID IS NULL
              AND NVL(CANCEL_FLAG,'N')= 'N';
              
               DBMS_OUTPUT.PUT_LINE('Sum of Part number already existing '||SQL%ROWCOUNT);

              select COUNT(distinct TRIM(UPPER(I.SUGGESTED_VENDOR_PRODUCT_CODE)))
              into item_count
              FROM po_requisition_lines_all i,
              po_requisition_headers_all h,
              mtl_units_of_measure c
              WHERE i.suggested_vendor_product_code IS NOT NULL
              AND item_id IS NULL
              and h.requisition_header_id = i.requisition_header_id
              AND c.unit_of_measure = i.unit_meas_lookup_code
              AND modified_by_agent_flag IS NULL
              AND line_location_id IS NULL
              and NVL(I.CANCEL_FLAG,'N')= 'N'
              and H.AUTHORIZATION_STATUS = 'APPROVED';
              
               DBMS_OUTPUT.PUT_LINE('Part numbers to be created '||item_count);

if ITEM_COUNT = 1000 then

    WRITE_OUTPUT('');
    WRITE_OUTPUT('No Items need creating. Ending program.');
    
else
       WRITE_OUTPUT('There are '||ITEM_COUNT||' item to be created.');
       WRITE_OUTPUT('==============================================');
       WRITE_OUTPUT('Calling API to create Items');        
       WRITE_OUTPUT('');
       
        -- Load l_item_tbl with the data
        FOR itm IN csr_org_items LOOP
             l_item_tbl(l_rowcnt).Transaction_Type            := 'CREATE'; 
             l_item_tbl(l_rowcnt).Segment1                    := XX_RECTIFY_NON_ASCII(itm.suggested_vendor_item_num);
             l_item_tbl(l_rowcnt).Description                 := XX_RECTIFY_NON_ASCII(itm.item_description);
             l_item_tbl(l_rowcnt).Organization_Id             := itm.org_id;
             l_item_tbl(l_rowcnt).Template_Name               := 'AWAS Parts';
             l_item_tbl(l_rowcnt).Inventory_Item_Status_Code  := 'Active';
             l_item_tbl(l_rowcnt).Primary_Uom_Code            := itm.uom_code;
       
       WRITE_OUTPUT('Part number: '||XX_RECTIFY_NON_ASCII(itm.suggested_vendor_item_num)|| ' Description: '||XX_RECTIFY_NON_ASCII(itm.item_description));
                          
        -- call API to load Items
       EGO_ITEM_PUB.PROCESS_ITEMS( 
                                 p_api_version            => l_api_version
                                 ,p_init_msg_list         => l_init_msg_list
                                 ,p_commit                => l_commit
                                 ,p_item_tbl              => l_item_tbl
                                 ,p_role_grant_tbl        => l_role_grant_tbl
                                 ,x_item_tbl              => x_item_tbl
                                 ,x_return_status         => x_return_status
                                 ,x_msg_count             => x_msg_count);
                                  
       WRITE_OUTPUT('Return Status: '||x_return_status);

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          FOR i IN 1..x_item_tbl.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE('Inventory Item Id :'||to_char(x_item_tbl(i).inventory_item_id));
             DBMS_OUTPUT.PUT_LINE('Organization Id   :'||to_char(x_item_tbl(i).organization_id));
      
             
       WRITE_OUTPUT('Calling API to assign Category'); 
       
      inv_item_category_pub.update_category_assignment
(p_api_version => l_api_version
-- ,p_init_msg_list
-- ,p_commit
,p_category_id => itm.category_id
,p_old_category_id => 82
,p_category_set_id => 1
,p_inventory_item_id => x_item_tbl(i).inventory_item_id
,p_organization_id => x_item_tbl(i).organization_id
,x_return_status => r_return_status
,x_errorcode => r_errorcode
,x_msg_count => r_msg_count
,x_msg_data => r_msg_data);
      
             
          if (R_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS) then
          WRITE_OUTPUT('Category Updated');
          
          else
          WRITE_OUTPUT('Error Updating Category-Messages :');
          WRITE_OUTPUT('msg'||r_msg_data);
                         
          END IF; 
             
             /*  Interface
             UPDATE po_requisitions_interface_all
             SET item_id = x_item_tbl(i).inventory_item_id,
             suggested_vendor_item_num = NULL
             where trim(upper(suggested_vendor_item_num)) = itm.suggested_vendor_item_num;
             */
             
            UPDATE po_requisition_lines_all
             SET item_id = x_item_tbl(i).inventory_item_id,
             suggested_vendor_product_code = NULL
             where trim(upper(suggested_vendor_product_code)) = itm.suggested_vendor_item_num;
             
          end LOOP;
          
       else
          WRITE_OUTPUT('Error Creating Item-Messages :');
          Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
          for I in 1..X_MESSAGE_LIST.COUNT LOOP
             WRITE_OUTPUT(x_message_list(i).message_text);
          END LOOP;
       END IF;
       
       END LOOP;
       
             UPDATE po_requisition_lines_all  x
             SET item_id = (SELECT inventory_item_id FROM mtl_system_items_b WHERE segment1 = xx_rectify_non_ascii(suggested_vendor_product_code)),
             suggested_vendor_product_code = null
             WHERE suggested_vendor_product_code IS NOT NULL
              AND item_id IS NULL
              AND modified_by_agent_flag IS NULL
              AND line_location_id IS NULL
              AND nvl(cancel_flag,'N')= 'N'
              ;
       DBMS_OUTPUT.PUT_LINE('=====================================');       
end if;

        
EXCEPTION
        when OTHERS then
          WRITE_OUTPUT('Exception Occured :');
          WRITE_OUTPUT(SQLCODE ||':'||SQLERRM);
          WRITE_OUTPUT('=====================================');
END processitems;

/*---------------------------------------------------------------------------*/
/*-- Procedure to Write to Log file                                          */
/*---------------------------------------------------------------------------*/
PROCEDURE WRITE_LOG
     (
          P_MESSAGE IN VARCHAR2
     )
IS
BEGIN
     
          DBMS_OUTPUT.PUT_LINE
          (
               P_MESSAGE
          )
          ;

END WRITE_LOG;
/*---------------------------------------------------------------------------*/
/*-- Procedure to Write to Output File                                       */
/*---------------------------------------------------------------------------*/
PROCEDURE WRITE_OUTPUT
     (
          P_MESSAGE IN VARCHAR2
     )
IS
BEGIN
     FND_FILE.PUT_LINE
     (
          FND_FILE.OUTPUT, P_MESSAGE
     )
     ;
END WRITE_OUTPUT;

/*---------------------------------------------------------------------------*/
/*-- Procedure to write Debug to xx_debug table                              */
/*---------------------------------------------------------------------------*/
PROCEDURE Write_DEBUG
     (
          p_comments       IN VARCHAR2,
          p_procedure_name IN VARCHAR2,
          p_progress       IN VARCHAR2
     )
IS
     PRAGMA autonomous_transaction;
BEGIN

IF G_DEBUG_MODE THEN
      INSERT
             INTO
               xx_debug
               (
                    create_date   ,
                    comments      ,
                    procedure_name,
                    progress      ,
                    request_id
               )
               VALUES
               (
                    SYSDATE         ,
                    p_comments      ,
                    p_procedure_name,
                    p_progress      ,
                    v_request_id
               ) ;
     COMMIT;
END IF;

END WRITE_DEBUG;
 

END XX_REQ_IMPORT_PKG;
/
