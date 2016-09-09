--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure XX_PROCESSITEMS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "APPS"."XX_PROCESSITEMS" 
AS
        l_api_version		    NUMBER := 1.0; 
        l_init_msg_list		  VARCHAR2(2) := FND_API.G_TRUE; 
        l_commit		        VARCHAR2(2) := FND_API.G_FALSE; 
        l_item_tbl		      EGO_ITEM_PUB.ITEM_TBL_TYPE; 
        l_role_grant_tbl	  EGO_ITEM_PUB.ROLE_GRANT_TBL_TYPE := EGO_ITEM_PUB.G_MISS_ROLE_GRANT_TBL; 
        x_item_tbl		      EGO_ITEM_PUB.ITEM_TBL_TYPE;     
        x_message_list      Error_Handler.Error_Tbl_Type;
        x_return_status		  VARCHAR2(2);
        x_msg_count		      NUMBER := 0;
        y_return_status     VARCHAR2(2);
        y_errorcode         NUMBER;
        y_msg_count         NUMBER :=0;
        y_msg_data          VARCHAR2(2000);
        r_return_status     VARCHAR2(2);
        r_errorcode         NUMBER;
        r_msg_count         NUMBER :=0;
        r_msg_data          VARCHAR2(2000);
        
    
        l_user_id		NUMBER := 1622;   --TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
        l_resp_id		NUMBER := 50962;  
        l_application_id	NUMBER := 178;
        l_rowcnt		NUMBER := 1;
        

             /*
        CURSOR csr_org_items IS
           SELECT DISTINCT org_id, 
              trim(UPPER(suggested_vendor_item_num)) suggested_vendor_item_num ,
              item_description,
              category_id,
              c.uom_code
              FROM po_requisitions_interface_all i,
              mtl_units_of_measure c
              WHERE i.suggested_vendor_item_num IS NOT NULL
              AND c.unit_of_measure = i.unit_of_measure;
              */
              
              
              CURSOR csr_org_items IS        
           SELECT DISTINCT i.org_id, 
              XX_RECTIFY_NON_ASCII(trim(UPPER(i.suggested_vendor_product_code))) suggested_vendor_item_num,
              i.item_description,
              i.category_id,
              c.uom_code
              FROM po_requisition_lines_all i,
              po_req_distributions_all d,
              mtl_units_of_measure c,
              po_distributions_all pod,
              mtl_system_items_b x
              WHERE i.suggested_vendor_product_code IS NOT NULL
              AND i.item_id IS NULL
              AND XX_RECTIFY_NON_ASCII(trim(UPPER(i.suggested_vendor_product_code))) = x.segment1 (+)
              and x.segment1 is null
              and d.requisition_line_id = i.requisition_line_id
              AND c.unit_of_measure = i.UNIT_MEAS_LOOKUP_CODE
              AND d.distribution_id = pod.req_distribution_id (+)
              and pod.req_distribution_id is null;
        
        
        
BEGIN

	FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_application_id);  -- MGRPLM / Development Manager / EGO
	dbms_output.put_line('Initialized applications context: '|| l_user_id || ' '|| l_resp_id ||' '|| l_application_id );

        -- Load l_item_tbl with the data
        FOR itm IN csr_org_items LOOP
             l_item_tbl(l_rowcnt).Transaction_Type            := 'CREATE'; 
             l_item_tbl(l_rowcnt).Segment1                    := itm.suggested_vendor_item_num;
             l_item_tbl(l_rowcnt).Description                 := itm.item_description;
             l_item_tbl(l_rowcnt).Organization_Id             := itm.org_id;
             l_item_tbl(l_rowcnt).Template_Name               := 'AWAS Parts';
             l_item_tbl(l_rowcnt).Inventory_Item_Status_Code  := 'Active';
             l_item_tbl(l_rowcnt).Primary_Uom_Code            := itm.uom_code;
                          
             l_rowcnt := l_rowcnt + 1;             
        
        
        -- call API to load Items
       DBMS_OUTPUT.PUT_LINE('=====================================');
       DBMS_OUTPUT.PUT_LINE('Calling EGO_ITEM_PUB.Process_Items API');        
       EGO_ITEM_PUB.PROCESS_ITEMS( 
                                 p_api_version            => l_api_version
                                 ,p_init_msg_list         => l_init_msg_list
                                 ,p_commit                => l_commit
                                 ,p_item_tbl              => l_item_tbl
                                 ,p_role_grant_tbl        => l_role_grant_tbl
                                 ,x_item_tbl              => x_item_tbl
                                 ,x_return_status         => x_return_status
                                 ,x_msg_count             => x_msg_count);
                                  
       DBMS_OUTPUT.PUT_LINE('=====================================');
       DBMS_OUTPUT.PUT_LINE('Return Status: '||x_return_status);




       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          
          FOR i IN 1..x_item_tbl.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE('Inventory Item Id :'||to_char(x_item_tbl(i).inventory_item_id));
             DBMS_OUTPUT.PUT_LINE('Organization Id   :'||to_char(x_item_tbl(i).organization_id));
             DBMS_OUTPUT.PUT_LINE('=====================================');
             DBMS_OUTPUT.PUT_LINE('Calling inv_item_category_pub.update_category_assignment API'); 
          
          
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
      
             
          IF (r_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          DBMS_OUTPUT.PUT_LINE('Category Updated');
          
          ELSE
          DBMS_OUTPUT.PUT_LINE('Error Updating Category-Messages :');
             DBMS_OUTPUT.PUT_LINE('msg'||r_msg_data);
                         
          END IF; 
             
             
             /*UPDATE po_requisitions_interface_all
             SET item_id = x_item_tbl(i).inventory_item_id,
             suggested_vendor_item_num = NULL
             where trim(upper(suggested_vendor_item_num)) = itm.suggested_vendor_item_num;
             */
             
           UPDATE po_requisition_lines_all
             SET item_id = x_item_tbl(i).inventory_item_id,
             suggested_vendor_product_code = NULL
             where XX_RECTIFY_NON_ASCII(trim(UPPER(suggested_vendor_product_code))) = x_item_tbl(i).Segment1;
             
          END LOOP;
       ELSE
          DBMS_OUTPUT.PUT_LINE('Error Creating Item-Messages :');
          Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
          FOR i IN 1..x_message_list.COUNT LOOP
             DBMS_OUTPUT.PUT_LINE(x_message_list(i).message_text);
          END LOOP;
       END IF;
       
       END LOOP;
       
       DBMS_OUTPUT.PUT_LINE('=====================================');       
        
EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Exception Occured :');
          DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM);
          DBMS_OUTPUT.PUT_LINE('=====================================');
END xx_processitems;
 

/
