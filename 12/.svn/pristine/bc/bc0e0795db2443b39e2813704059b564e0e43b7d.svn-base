# Script to run ldt loader files
# simply add the FNDLOAD Upload Statement to end of list
# =========================================================
# Will simply prompt for APPS Password
 
echo "Enter APPS Password"
 stty -echo                  #Turns echo off
 read appspwd
 stty echo                   #Turns echo on

cd $AWCUST_TOP/patch/import

FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/affrmcus.lct APXIISIM_FP.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/fndfold.lct ALL_FORM_FOLDERs.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpreqg.lct ALL_REPORTS_AP_RG.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct BOM_CREATE_ACCOUNTING_CR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct PAYABLES_ACCOUNTING_PROCESS_CR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd O Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct AWAS_DOWNLOAD_AMEX.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct PAYABLES_TRANSFER_TO_GL_CR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct AP_TRIAL_BALANCE_CR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/aflvmlu.lct PAYMENT_TEMPLATE_TYPE_LKP.ldt UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct AWAS_BANK_ACCOUNTS_VS.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct XX_CE_GL_PERIOD_VS.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct AWAS_CEXRECRE_CP.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpreqg.lct ALL_REPORTS_CE_RG.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcprset.lct AWAS_CREATE_JOURNAL_ENTRIES_RS.ldt CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct AWASARXAGER12_CP.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $XDO_TOP/patch/115/import/xdotmpl.lct AWASARXAGER12EXCEL_DD.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $XDO_TOP/patch/115/import/xdotmpl.lct AWASARXAGER12PDF_DD.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct AX_NAV_SUPERVISOR_AR.ldt 
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpreqg.lct RECEIVABLES_ALL_RG.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct AR_CREATE_ACCOUNTING_CR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_HZ_CUSTOMER_PROFILES_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_AR_CUSTOMER_PROFILE_AMOUNT_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_HZ_CUST_ACCOUNTS_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_AR_CUSTOMER_PROFILE_CLASSES_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_HZ_CUSTOMER_PROFILE_CLASSES_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_HZ_CUST_ACCT_SITES_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct JG_HZ_CUST_PROFILE_AMTS_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct HZ_PARTIES_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct AR_CUSTOMER_PROFILES_HZ_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct AR_CUSTOMER_PROFILE_AMOUNTS_HZ_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct AR_CUST_PROF_CLASS_AMOUNTS_HZ_FLEX.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $BNE_TOP/patch/115/import/bnelay.lct AWASFOREIGNACTUALSSINGLE.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct GL_SUPERUSER_MENU.ldt 
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct GL_SUPERVISOR_MENU.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct BNE_AWAS_FUNCTIONAL_JOURNAL_FUNC.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct BNE_S_FOREIGN_CURRENCY_JOURNAL.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct BNE_AWAS_MULTIPLE_JOURNALS_USD.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct BNE_SALMON_LOANS.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct FA_CREATE_ACCOUNTING_CR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afscursp.lct Purchasing_Buyer_Resp.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $BNE_TOP/patch/115/import/bnelay.lct AWASFUNCTIONALACTUALSSINGLE.ldt 
FNDLOAD apps/$appspwd 0 Y UPLOAD $BNE_TOP/patch/115/import/bnelay.lct AWASFUNCTIONALACTUALSMULTIPLE.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $BNE_TOP/patch/115/import/bnelay.lct SALMON.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $BNE_TOP/patch/115/import/bnemap.lct SALMON_ADI_MAP.ldt
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afscursp.lct treasury_resp.ldt UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct XX_BNP_CESQLLDR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct XX_BOI_CESQLLDR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct XXCITICESQLLDR.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct AWAS_DB_BAI_STMT_LOAD.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct AWAS_Internal_Bank_Account_VS.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
FNDLOAD apps/$appspwd 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct CE_BANK_ACCOUNTS_DFF.ldt