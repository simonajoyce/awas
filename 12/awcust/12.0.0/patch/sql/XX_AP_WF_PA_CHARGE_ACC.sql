CREATE OR REPLACE PACKAGE XX_AP_WF_PA_CHARGE_ACC AS
       
PROCEDURE Get_PA_Exp_Account (itemtype        IN  VARCHAR2
  					,itemkey         IN  VARCHAR2
					  ,actid           IN  NUMBER
					  ,funcmode        IN  VARCHAR2
					  ,result          OUT VARCHAR2);
            
           
PROCEDURE debug_test (itemtype        IN  VARCHAR2
  					  ,itemkey         IN  VARCHAR2
					  ,actid           IN  NUMBER
					  ,funcmode        IN  VARCHAR2
					  ,result          OUT VARCHAR2) ;

PROCEDURE WriteLog (p_comments IN VARCHAR2
				   ,p_procedure_name IN VARCHAR2
				   ,p_progress IN VARCHAR2);

END XX_AP_WF_PA_CHARGE_ACC;
 
/


CREATE OR REPLACE PACKAGE BODY XX_AP_WF_PA_CHARGE_ACC AS
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
 /**********************************************************************
 DESCRIPTION
 PL/SQL body for package:  XX_PO_WF_PO_CHARGE_ACC.

 NOTES
 MODIFIED    S. Joyce (17-Feb-2012) - Created.
 ***********************************************************************/
            
 
 PROCEDURE debug_test (itemtype        IN  VARCHAR2
  					  ,itemkey         IN  VARCHAR2
					  ,actid           IN  NUMBER
					  ,funcmode        IN  VARCHAR2
					  ,result          OUT VARCHAR2) IS
 gl_code number;
 BEGIN
 PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'DEBUG STEP NOW');
 
  gl_code := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	         itemkey  => itemkey,
                            	 	         aname    => 'CODE_COMBINATION_ID');
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'Current CODE_COMBINATION_ID='||gl_code);
     
 end debug_test;
 
 
PROCEDURE Get_pa_exp_Account (itemtype        IN  VARCHAR2
  					  ,itemkey         IN  VARCHAR2
					  ,actid           IN  NUMBER
					  ,funcmode        IN  VARCHAR2
					  ,result          OUT VARCHAR2) IS

  CURSOR c_get_segments (b_fnd_flex_num NUMBER) IS
  SELECT application_column_name
  ,	   	 segment_name
  FROM   fnd_id_flex_segments--_vl
  WHERE  id_flex_num = b_fnd_flex_num;

  v_progress					VARCHAR2(100) := '000';
  v_fnd_flex_num 				number;
  v_segment1 				   	VARCHAR2(30);
  v_segment2 				   	VARCHAR2(30);
  v_segment3 				   	VARCHAR2(30);
  v_segment4 				   	VARCHAR2(30);
  v_segment5 				   	VARCHAR2(30);
  v_segment6 				   	VARCHAR2(30);
  v_segment7 				   	VARCHAR2(30);
  v_segment1_value				VARCHAR2(30);
  v_segment2_value				VARCHAR2(30);
  v_segment3_value				VARCHAR2(30);
  v_segment4_value				VARCHAR2(30);
  v_segment5_value				VARCHAR2(30);
  v_segment6_value				VARCHAR2(30);
  v_segment7_value				VARCHAR2(30);
  v_org_id						NUMBER;
  v_error						VARCHAR2(2000);
  l_project_id       number;
  l_expenditure_type varchar2(200);
  L_temp_id          NUMBER;
  x_progress	VARCHAR2(100);
	success		varchar2(2);

BEGIN
 x_progress := 'XX_PA_WF_PA_CHARGE_ACC.expense: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  IF (funcmode <> wf_engine.eng_run) THEN
  
  

    result := wf_engine.eng_null;
    RETURN;

  END IF;

  -- Get the Org ID.
  SELECT to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),
  		 ' ', null,substrb(userenv('CLIENT_INFO'),1,10)))
  INTO   v_org_id
  FROM   dual;

   IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'v_org_id ='||v_org_id);
  END IF;

  -- Get the CHART_OF_ACCOUNTS_ID item attribute, which is the ID for the Charge Account Flexfield.
  --v_fnd_flex_num := wf_engine.GetItemAttrNumber (itemtype => itemtype
   --     	                                  ,itemkey  => itemkey
    --            	            	          ,aname    => 'CHART_OF_ACCOUNTS_ID');
                                                                            
    v_fnd_flex_num := 50230;
    
    
 -- Get Project ID then return flexfield Attribute1 from Project to get MSN for segment 4
 -- Entity and Natural Account
  l_project_id := wf_engine.GetItemAttrNumber(itemtype => itemtype
        	                             ,itemkey  => itemkey
                        	          	 ,aname    => 'PROJECT_ID');
      
      l_expenditure_type := wf_engine.GetItemAttrText(itemtype => itemtype
        	                             ,itemkey  => itemkey
                        	          	 ,aname    => 'EXPENDITURE_TYPE');
                                       
    
  
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  po_wf_debug_pkg.insert_debug(itemtype,itemkey,'Project_id ='||l_project_id);
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'Expenditure_type ='||l_expenditure_type);
  END IF;
  
  select segment_value
  into v_segment2_value
from pa_segment_value_lookups
where segment_value_lookup = l_expenditure_type
and segment_value_lookup_Set_id = 1; 

if (g_po_wf_debug = 'Y') then
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'v_segment2 ='||v_segment2_value);
  end if;
  
                                       
  SELECT attribute1,
         attribute2,
         decode(v_segment2_value,'000000',attribute3,v_segment2_value),
         attribute4
  INTO v_segment4_value,
       v_segment1_value,
       v_segment2_value,
       v_segment5_value
  FROM pa_projects_all
  where project_id = l_project_id;
  
  IF v_segment2_value = '000000' THEN
       v_segment3_value := NULL;
       v_segment2_value := NULL; 
    end if;
    
      if v_segment2_value BETWEEN '000001' AND '399999'
      then v_segment3_value := '0000';
      ELSE 
          v_segment3_value := '1100';
      END IF;
  
  -- set cost centre to 2006 if P&L account
  IF v_segment2_value between '400000' and '599999' THEN
       
       v_segment3_value := '2006';
  END IF;
  
  if v_segment2_value = '159005' then
  v_segment5_value :='000';
  end if;
  

  
  v_segment7_value := '0000';
  
 
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'v_segment1_value= '||v_segment1_value);
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'v_segment2_value= '||v_segment2_value);
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'v_segment3_value= '||v_segment3_value);
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'v_segment4_value= '||v_segment4_value);
  END IF;  
  

  -- Get the names of the Segments that need to be changed.
  -- Do this instead of defaulting the values in Workflow builder, as they could change in the future.
  FOR i IN c_get_segments (v_fnd_flex_num) LOOP

    IF i.application_column_name = 'SEGMENT1' THEN
	  -- The value of v_segment1 = ENT.
	  v_segment1 := i.segment_name;
	ELSIF i.application_column_name = 'SEGMENT2' THEN
	  -- The value of v_segment2 = ACC.
	  v_segment2 := i.segment_name;
	ELSIF i.application_column_name = 'SEGMENT3' THEN
	  -- The value of v_segment3 = CC.
	  v_segment3 := i.segment_name;
	ELSIF i.application_column_name = 'SEGMENT4' THEN
		  -- The value of v_segment4 = MSN/ESN.
	  v_segment4 := i.segment_name;
	ELSIF i.application_column_name = 'SEGMENT5' THEN
	  -- The value of v_segment5 = LE.
	  v_segment5 := i.segment_name;
  ELSIF i.application_column_name = 'SEGMENT6' THEN
	  -- The value of v_segment5 = IC.
	  v_segment6 := i.segment_name;
  ELSIF i.application_column_name = 'SEGMENT7' THEN
	  -- The value of v_segment5 = SP.
	  v_segment7 := i.segment_name;
	
	
	ELSE
	  NULL;
	END IF;

  END LOOP;
 
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'xx_ap_wf_pa_charge_account line 198');
     
  END IF;  

  -- Set the Workflow item attribute TEMP_ACCOUNT_ID to the Employee's
  -- default expense account (Employee is derived from PREPARER_ID item attribute) .
  
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT1'
							,avalue	  => v_segment1 );

  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT2'
							,avalue	  => v_segment2 );


  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT3'
							,avalue	  => v_segment3 );

  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT4'
							,avalue	  => v_segment4 );


  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT5'
							,avalue	  => v_segment5 );
  
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT6'
							,avalue	  => v_segment6 );
              
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT7'
							,avalue	  => v_segment7 );

  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT1_VALUE'
							,avalue	  => v_segment1_value );

if v_segment2_value is not null then
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT2_VALUE'
							,avalue	  => v_segment2_value );
end if;

if v_segment3_value is not null then
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT3_VALUE'
							,avalue	  => v_segment3_value );
END IF;


  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT4_VALUE'
							,avalue	  => v_segment4_value );

  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT5_VALUE'
							,avalue	  => v_segment5_value );
              
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT6_VALUE'
							,avalue	  => v_segment1_value ); --  set IC same as Ent
  
  wf_engine.SetItemAttrText (itemtype => itemtype
  							,itemkey  => itemkey
							,aname	  => 'SEGMENT7_VALUE'
							,avalue	  => v_segment7_value ); 

IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'xx_ap_wf_pa_charge_account line 277');
     
  END IF;  



  result := 'COMPLETE:S';
  
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'xx_ap_wf_pa_charge_account result='||result);
     
  END IF;  
  RETURN;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
	    success := 'N';
      
  WHEN OTHERS THEN
  v_error := sqlerrm;
  
   IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
             'AP_WF_PA_CHARGE_ACC.expense sqlerror='|| v_error);
    END IF;

  writelog(v_error, 'XX_AP_WF_PA_CHARGE_ACC.Get_PA_EXP_Account', v_progress);
	wf_core.context('XX_AP_WF_PA_CHARGE_ACC','Get_PA_EXP_Account',v_progress);
  RAISE;

END Get_PA_Exp_Account;


PROCEDURE WriteLog (p_comments IN VARCHAR2
				   ,p_procedure_name IN VARCHAR2
				   ,p_progress IN VARCHAR2) IS

PRAGMA autonomous_transaction;

BEGIN
  INSERT INTO xx_debug (create_date, comments, procedure_name, progress) VALUES
  		 	  			  (SYSDATE, p_comments, p_procedure_name, p_progress);
  COMMIT;
END WriteLog;

END XX_AP_WF_PA_CHARGE_ACC;
/
