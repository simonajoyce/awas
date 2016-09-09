<?xml version="1.0" encoding="UTF-8"?>
<!-- +======================================================================+ -->
<!-- |    Copyright (c) 2005, 2013 Oracle and/or its affiliates.           | -->
<!-- |                         All rights reserved.                         | -->
<!-- |                           Version 12.0.0                             | -->
<!-- +======================================================================+ -->
<!--  $Header: IBY_ISO_CT_CORE_V3_STD.xsl 120.0.12010000.3 2013/11/21 05:26:28 sgogula noship $   -->
<!--  dbdrv: exec java oracle/apps/xdo/oa/util XDOLoader.class java &phase=dat checkfile:~PROD:patch/115/publisher/templates:IBY_ISO_CT_CORE_V3_STD.xsl UPLOAD -DB_USERNAME &un_apps -DB_PASSWORD &pw_apps -JDBC_CONNECTION &jdbc_db_addr -LOB_TYPE TEMPLATE -APPS_SHORT_NAME IBY -LOB_CODE IBY_ISO_CT_001.001.03_STRD -LANGUAGE en -XDO_FILE_TYPE XSL-XML -FILE_NAME &fullpath:~PROD:patch/115/publisher/templates:IBY_ISO_CT_CORE_V3_STD.xsl -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:output omit-xml-declaration="no" />
   <xsl:output method="xml" />
   <xsl:key name="contacts-by-LogicalGroupReference" match="OutboundPayment" use="PaymentNumber/LogicalGroupReference" />
   <xsl:template match="OutboundPaymentInstruction">
      <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'" />
      <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
      <xsl:variable name="instrid" select="PaymentInstructionInfo/InstructionReferenceNumber" />
      <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
         <CstmrCdtTrfInitn>
            <GrpHdr>
               <MsgId>
                  <xsl:value-of select="$instrid" />
               </MsgId>
               <CreDtTm>
                  <xsl:value-of select="PaymentInstructionInfo/InstructionCreationDate" />
               </CreDtTm>
               <NbOfTxs>
                  <xsl:value-of select="InstructionTotals/PaymentCount" />
               </NbOfTxs>
               <CtrlSum>
                  <xsl:value-of select="format-number(sum(OutboundPayment/PaymentAmount/Value), '##0.00')" />
               </CtrlSum>
               <InitgPty>
                  <Nm>
                     <xsl:choose>
                        <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_NAME'])=0) and not(translate(PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_NAME']/Value,$lower,$upper) = 'NA') ">
                           <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_NAME']/Value" />
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="InstructionGrouping/Payer/LegalEntityName" />
                        </xsl:otherwise>
                     </xsl:choose>
                  </Nm>
                  <Id>
                     <OrgId>
                        <xsl:choose>
                           <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_BICorBEI'])=0) and  not(translate(PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_BICorBEI']/Value,$lower,$upper) = 'NA') ">
                              <BICOrBEI>
                                 <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_BICorBEI']/Value" />
                              </BICOrBEI>
                           </xsl:when>
                           <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_OTHRID'])=0) and  not(translate(PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_OTHRID']/Value,$lower,$upper) = 'NA') ">
                              <Othr>
                                 <Id>
                                    <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='CGI_INITIATING_PARTY_OTHRID']/Value" />
                                 </Id>
                              </Othr>
                           </xsl:when>
                           <xsl:otherwise>
                              <Othr>
                                 <Id>
                                    <xsl:value-of select="InstructionGrouping/Payer/LegalEntityRegistrationNumber" />
                                 </Id>
                              </Othr>
                           </xsl:otherwise>
                        </xsl:choose>
                     </OrgId>
                  </Id>
               </InitgPty>
            </GrpHdr>
            <xsl:for-each select="OutboundPayment[count(. | key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)[1]) = 1]">
               <xsl:sort select="PaymentNumber/LogicalGroupReference" />
               <PmtInf>
                  <PmtInfId>
                     <xsl:value-of select="PaymentNumber/LogicalGroupReference" />
                  </PmtInfId>
                  <PmtMtd>
                     <xsl:value-of select="PaymentMethod/PaymentMethodFormatValue" />
                  </PmtMtd>
                  <BtchBookg>
                     <xsl:choose>
                        <xsl:when test="contains(/OutboundPaymentInstruction/PaymentProcessProfile/BatchBookingFlag,'N')">
                           <xsl:text>false</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:text>true</xsl:text>
                        </xsl:otherwise>
                     </xsl:choose>
                  </BtchBookg>
                  <NbOfTxs>
                     <xsl:value-of select="count(key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference))" />
                  </NbOfTxs>
                  <CtrlSum>
                     <xsl:value-of select="format-number(sum(key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)/PaymentAmount/Value),'#.00')" />
                  </CtrlSum>
                  <PmtTpInf>
                     <xsl:choose>
                        <xsl:when test="not(count(SettlementPriority/Code)=0) and      (SettlementPriority/Code = 'EXPRESS') ">
                           <InstrPrty>HIGH</InstrPrty>
                        </xsl:when>
                        <xsl:otherwise>
                           <InstrPrty>NORM</InstrPrty>
                        </xsl:otherwise>
                     </xsl:choose>
                     <xsl:if test="not(PaymentMethod/PaymentMethodFormatValue='CHK')">
                        <SvcLvl>
						<!-- Following lines removed until patching for Service level Complete -->
                          <!-- <xsl:if test="not(ServiceLevel/Code='')">
                              <Cd>
                                 <xsl:value-of select="ServiceLevel/Code" />
                              </Cd>
                           </xsl:if>
                           <xsl:if test="(ServiceLevel/Code='')">
                              <Cd>URGP</Cd>
                           </xsl:if> -->
						      <Cd>
								<xsl:choose>
									<xsl:when test="BankAccount/BankAccountCurrency/Code='EUR'">
										<xsl:text>SEPA</xsl:text>
									</xsl:when>
									<xsl:otherwise>URGP</xsl:otherwise>
								</xsl:choose>
							  </Cd>
                        </SvcLvl>
                     </xsl:if>
                     <LclInstrm>
                        <Cd>
                           <xsl:value-of select="DeliveryChannel/Code" />
                        </Cd>
                     </LclInstrm>
                  </PmtTpInf>
                  <ReqdExctnDt>
                     <!--<xsl:value-of select="PaymentDate" />-->
					 <xsl:value-of select="substring(/OutboundPaymentInstruction/PaymentInstructionInfo/InstructionCreationDate,1,10)" />
				  </ReqdExctnDt>
                  <Dbtr>
                     <Nm>
                        <xsl:choose>
                           <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME'])=0) and not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value,$lower,$upper) = 'NA') ">
                              <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value" />
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="Payer/Name" />
                           </xsl:otherwise>
                        </xsl:choose>
                     </Nm>
                     <PstlAdr>
                        <StrtNm>
                           <xsl:value-of select="Payer/Address/AddressLine1" />
                        </StrtNm>
                        <PstCd>
                           <xsl:value-of select="Payer/Address/PostalCode" />
                        </PstCd>
                        <TwnNm>
                           <xsl:value-of select="Payer/Address/City" />
                        </TwnNm>
                        <xsl:if test="not(Payer/Address/County='') or not(Payer/Address/State='') or not(Payer/Address/Province='')">
                           <CtrySubDvsn>
                              <xsl:value-of select="Payer/Address/County" />
                              <xsl:value-of select="Payer/Address/State" />
                              <xsl:value-of select="Payer/Address/Province" />
                           </CtrySubDvsn>
                        </xsl:if>
                        <xsl:if test="not(Payer/Address/Country='')">
                           <Ctry>
                              <xsl:value-of select="Payer/Address/Country" />
                           </Ctry>
                        </xsl:if>
                     </PstlAdr>
                     <Id>
                        <OrgId>
                           <xsl:choose>
                              <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_BICORBEI'])=0) and  not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_BICORBEI']/Value,$lower,$upper) = 'NA')">
                                 <BICOrBEI>
                                    <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_BICORBEI']/Value" />
                                 </BICOrBEI>
                              </xsl:when>
                              <xsl:otherwise>
                                 <Othr>
                                    <xsl:choose>
                                       <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_OTHRID'])=0) and  not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_OTHRID']/Value,$lower,$upper) = 'NA')">
                                          <Id>
                                             <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_OTHRID']/Value" />
                                          </Id>
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <Id>
                                             <xsl:choose>
                                                <xsl:when test="not(Payer/TaxRegistrationNumber='')">
                                                   <xsl:value-of select="Payer/TaxRegistrationNumber" />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                   <xsl:value-of select="Payer/LegalEntityRegistrationNumber" />
                                                </xsl:otherwise>
                                             </xsl:choose>
                                          </Id>
                                       </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                       <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_ID_SCHME_NM'])=0) and  not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_ID_SCHME_NM']/Value,$lower,$upper) = 'NA')">
                                          <SchmeNm>
                                             <Cd>
                                                <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_ID_SCHME_NM']/Value" />
                                             </Cd>
                                          </SchmeNm>
                                       </xsl:when>
                                    </xsl:choose>
                                 </Othr>
                              </xsl:otherwise>
                           </xsl:choose>
                        </OrgId>
                     </Id>
                  </Dbtr>
                  <DbtrAcct>
                     <Id>
                        <!--<xsl:if test="not(BankAccount/IBANNumber='')">
                           <IBAN>
                              <xsl:value-of select="BankAccount/IBANNumber" />
                           </IBAN>
                        </xsl:if> -->
                        <!-- if no IBAN, use bank account number-->
                        <!--<xsl:if test="(BankAccount/IBANNumber='')"> -->
                           <Othr>
                              <Id>
                                 <xsl:value-of select="BankAccount/BankAccountNumber" />
                              </Id>
                           </Othr>
                        <!--</xsl:if>-->
                     </Id>
                     <xsl:if test="not(BankAccount/BankAccountType/Code='')">
                        <Tp>
                           <Cd>
                              <xsl:value-of select="BankAccount/BankAccountType/Code" />
                           </Cd>
                        </Tp>
                     </xsl:if>
                     <Ccy>
                        <xsl:value-of select="BankAccount/BankAccountCurrency/Code" />
                     </Ccy>
                  </DbtrAcct>
                  <DbtrAgt>
                     <FinInstnId>
                        <xsl:if test="not(BankAccount/SwiftCode='')">
                           <BIC>
                              <xsl:value-of select="BankAccount/SwiftCode" />
                           </BIC>
                        </xsl:if>
                        <xsl:if test="(BankAccount/SwiftCode='')">
                           <xsl:if test="not(BankAccount/BranchNumber='')">
                              <ClrSysMmbId>
                                 <MmbId>
                                    <xsl:value-of select="BankAccount/BranchNumber" />
                                 </MmbId>
                              </ClrSysMmbId>
                           </xsl:if>
                        </xsl:if>
                        <xsl:if test="not(BankAccount/BankAddress/Country='')">
                           <PstlAdr>
                              <Ctry>
                                 <xsl:value-of select="BankAccount/BankAddress/Country" />
                              </Ctry>
                           </PstlAdr>
                        </xsl:if>
                     </FinInstnId>
                     <!--<xsl:if test="(BankAccount/SwiftCode='')">
								<xsl:if test="not(BankAccount/BranchNumber='')">
									<BrnchId>
										<Id>
											<xsl:value-of select="BankAccount/BranchNumber"/>
										</Id>
									</BrnchId>
								</xsl:if>
							</xsl:if>  -->
                  </DbtrAgt>
                  <UltmtDbtr>
                     <Nm>
                        <xsl:choose>
                           <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_NAME'])=0) and not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_NAME']/Value,$lower,$upper) = 'NA') ">
                              <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_NAME']/Value" />
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="DocumentPayable/DocumentPayerLegalEntityName" />
                           </xsl:otherwise>
                        </xsl:choose>
                     </Nm>
                     <Id>
                        <OrgId>
                           <xsl:choose>
                              <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_BICorBEI'])=0) and  not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_BICorBEI']/Value,$lower,$upper) = 'NA')">
                                 <BICOrBEI>
                                    <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_BICorBEI']/Value" />
                                 </BICOrBEI>
                              </xsl:when>
                              <xsl:otherwise>
                                 <Othr>
                                    <xsl:choose>
                                       <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_OTHR_ID'])=0) and  not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_OTHR_ID']/Value,$lower,$upper) = 'NA')">
                                          <Id>
                                             <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='ULTIMATE_DEBTOR_OTHR_ID']/Value" />
                                          </Id>
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <xsl:if test="not(Payer/TaxRegistrationNumber='')">
                                             <Id>
                                                <xsl:value-of select="Payer/TaxRegistrationNumber" />
                                             </Id>
                                          </xsl:if>
                                          <xsl:if test="(Payer/TaxRegistrationNumber='')">
                                             <Id>
                                                <xsl:value-of select="Payer/LegalEntityRegistrationNumber" />
                                             </Id>
                                          </xsl:if>
                                       </xsl:otherwise>
                                    </xsl:choose>
                                 </Othr>
                              </xsl:otherwise>
                           </xsl:choose>
                        </OrgId>
                     </Id>
                  </UltmtDbtr>
                  <xsl:if test="not(PaymentMethod/PaymentMethodFormatValue='CHK')">
                     <!--<xsl:if test="not(BankCharges/BankChargeBearer/Code='')">-->
				  <ChrgBr>
				  <!-- If Payer Currency matches Payee currency use bank charge bearer from supplier otherwise use SHAR -->
					<xsl:choose>
						<!--<xsl:when test="PaymentAmount/Currency/Code=BankAccount/BankAccountCurrency/Code">-->
						<xsl:when test="not(BankAccount/SwiftCode='CITIUS33')">
                           <xsl:choose>
                              <xsl:when test="(BankCharges/BankChargeBearer/Code='BEN') or (BankCharges/BankChargeBearer/Code='PAYEE_PAYS_EXPRESS')">
                                 <xsl:text>CRED</xsl:text>
                              </xsl:when>
                              <xsl:when test="(BankCharges/BankChargeBearer/Code='OUR')">
                                 <xsl:text>DEBT</xsl:text>
                              </xsl:when>
                              <xsl:when test="(BankCharges/BankChargeBearer/Code='SHA')">
                                 <xsl:text>SHAR</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>DEBT</xsl:otherwise>
                           </xsl:choose>
						</xsl:when>
						<xsl:when test="PaymentAmount/Currency/Code=BankAccount/BankAccountCurrency/Code">
						    <xsl:choose>
                              <xsl:when test="(BankCharges/BankChargeBearer/Code='BEN') or (BankCharges/BankChargeBearer/Code='PAYEE_PAYS_EXPRESS')">
                                 <xsl:text>CRED</xsl:text>
                              </xsl:when>
                              <xsl:when test="(BankCharges/BankChargeBearer/Code='OUR')">
                                 <xsl:text>DEBT</xsl:text>
                              </xsl:when>
                              <xsl:when test="(BankCharges/BankChargeBearer/Code='SHA')">
                                 <xsl:text>SHAR</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>DEBT</xsl:otherwise>
                           </xsl:choose>
						</xsl:when>
						<xsl:otherwise>	
							<xsl:text>SHAR</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
                  </ChrgBr>
                     <!--</xsl:if>-->
                  </xsl:if>
                  <xsl:for-each select="key('contacts-by-LogicalGroupReference', PaymentNumber/LogicalGroupReference)">
                  <CdtTrfTxInf>
                        <xsl:variable name="paymentdetails" select="PaymentDetails" />
                        <PmtId>
                           <InstrId>
							  
							  <!-- HelpMe Change 430 next line added -->
                              <xsl:value-of select="concat('AWAS-',PaymentNumber/PaymentReferenceNumber)" />
							  <!-- HelpMe Change 430 above line added -->
                           </InstrId>
                           <EndToEndId>
						   <!-- HelpMe Change 430 <xsl:value-of select="PaymentNumber/PaymentReferenceNumber" /> -->
							<!-- HelpMe Change 430 next line added -->  
							<xsl:value-of select="concat('AWAS:',PaymentNumber/PaymentReferenceNumber)" />
							  <!-- HelpMe Change 430 above line added -->
                           </EndToEndId>
                        </PmtId>
                        <Amt>
                           <InstdAmt>
                              <xsl:attribute name="Ccy">
                                 <xsl:value-of select="PaymentAmount/Currency/Code" />
                              </xsl:attribute>
                              <xsl:value-of select="format-number(PaymentAmount/Value,'#.00')" />
                           </InstdAmt>
                        </Amt>
                        <xsl:if test="not(PaymentMethod/PaymentMethodFormatValue='CHK')">
                           <xsl:if test="not(BankCharges/BankChargeBearer/Code='')">
                        <ChrgBr>
                                 <xsl:choose>
                                    <xsl:when test="(BankCharges/BankChargeBearer/Code='BEN') or (BankCharges/BankChargeBearer/Code='PAYEE_PAYS_EXPRESS')">
                                       <xsl:text>CRED</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="(BankCharges/BankChargeBearer/Code='OUR')">
                                       <xsl:text>DEBT</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="(BankCharges/BankChargeBearer/Code='SHA')">
                                       <xsl:text>SHAR</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>SLEV</xsl:otherwise>
                                 </xsl:choose>
                        </ChrgBr>
                           </xsl:if>
                        </xsl:if>
                        <!-- AWAS Cheque Additions  -->
                        <xsl:if test="(PaymentMethod/PaymentMethodFormatValue='CHK')">
                        <ChqInstr>
                              <ChqTp>BCHQ</ChqTp>
                              <ChqNb>
                                 <xsl:value-of select="PaymentNumber/PaymentReferenceNumber" />
                              </ChqNb>
                              <ChqFr>
                                 <Nm>
                                    <xsl:choose>
                                       <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME'])=0) and not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value,$lower,$upper) = 'NA') ">
                                          <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value" />
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <xsl:value-of select="Payer/Name" />
                                       </xsl:otherwise>
                                    </xsl:choose>
                                 </Nm>
                                 <Adr>
                                    <AdrTp>ADDR</AdrTp>
                                    <StrtNm>
                                       <xsl:value-of select="Payer/Address/AddressLine1" />
                                    </StrtNm>
                                    <PstCd>
                                       <xsl:value-of select="Payer/Address/PostalCode" />
                                    </PstCd>
                                    <TwnNm>
                                       <xsl:value-of select="Payer/Address/City" />
                                    </TwnNm>
                                    <xsl:if test="not(Payer/Address/County='') or not(Payer/Address/State='') or not(Payer/Address/Province='')">
                                    <CtrySubDvsn>
                                          <xsl:value-of select="Payer/Address/County" />
                                          <xsl:value-of select="Payer/Address/State" />
                                          <xsl:value-of select="Payer/Address/Province" />
                                    </CtrySubDvsn>
                                    </xsl:if>
                                    <xsl:if test="not(Payer/Address/Country='')">
                                    <Ctry>
                                          <xsl:value-of select="Payer/Address/Country" />
                                    </Ctry>
                                    </xsl:if>
                                 </Adr>
                              </ChqFr>
                              <DlvryMtd>
                                 <Cd>MLDB</Cd>
                              </DlvryMtd>
                              <DlvrTo>
                                 <Nm>
                                    <xsl:choose>
                                       <xsl:when test="not(count(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME'])=0) and not(translate(/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value,$lower,$upper) = 'NA') ">
                                          <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/PaymentSystemAccount/AccountSettings[Name='DEBTOR_NAME']/Value" />
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <xsl:value-of select="Payer/Name" />
                                       </xsl:otherwise>
                                    </xsl:choose>
                                 </Nm>
                                 <Adr>
                                    <AdrTp>ADDR</AdrTp>
                                    <StrtNm>
                                       <xsl:value-of select="Payer/Address/AddressLine1" />
                                    </StrtNm>
                                    <PstCd>
                                       <xsl:value-of select="Payer/Address/PostalCode" />
                                    </PstCd>
                                    <TwnNm>
                                       <xsl:value-of select="Payer/Address/City" />
                                    </TwnNm>
                                    <xsl:if test="not(Payer/Address/County='') or not(Payer/Address/State='') or not(Payer/Address/Province='')">
                                       <CtrySubDvsn>
                                          <xsl:value-of select="Payer/Address/County" />
                                          <xsl:value-of select="Payer/Address/State" />
                                          <xsl:value-of select="Payer/Address/Province" />
                                       </CtrySubDvsn>
                                    </xsl:if>
                                    <xsl:if test="not(Payer/Address/Country='')">
                                       <Ctry>
                                          <xsl:value-of select="Payer/Address/Country" />
                                       </Ctry>
                                    </xsl:if>
                                 </Adr>
                              </DlvrTo>
                              <InstrPrty>NORM</InstrPrty>
                        </ChqInstr>
                        </xsl:if>
                        <!-- End of AWAS Cheque Additions  -->
                        <!-- AWAS Custom Add IntermediaryAgent1 -->
                        <xsl:if test="(PayeeBankAccount/IntermediaryBankAccount1/IntermediaryAccountID)">
                           <xsl:if test="not(concat(PayeeBankAccount/IntermediaryBankAccount1/SwiftCode,PayeeBankAccount/IntermediaryBankAccount1/BranchNumber)='')">
                              <IntrmyAgt1>
                                 <FinInstnId>
                                    <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount1/SwiftCode='')">
                                       <BIC>
                                          <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount1/SwiftCode" />
                                       </BIC>
                                    </xsl:if>
                                    <xsl:if test="(PayeeBankAccount/IntermediaryBankAccount1/SwiftCode='')">
                                       <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount1/BranchNumber='')">
                                          <ClrSysMmbId>
                                             <MmbId>
                                                <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount1/BranchNumber" />
                                             </MmbId>
                                          </ClrSysMmbId>
                                       </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount1/BankName='')">
                                       <Nm>
                                          <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount1/BankName" />
                                       </Nm>
                                    </xsl:if>
                                    <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount1/Country='')">
                                       <PstlAdr>
                                          <Ctry>
                                             <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount1/Country" />
                                          </Ctry>
                                       </PstlAdr>
                                    </xsl:if>
                                 </FinInstnId>
                                 <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount1/BranchNumber='')">
                                    <BrnchId>
                                       <Id>
                                          <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount1/BranchNumber" />
                                       </Id>
                                    </BrnchId>
                                 </xsl:if>
                              </IntrmyAgt1>
                           </xsl:if>
                        </xsl:if>
                        <!-- End Of AWAS IntermediaryAgent1 -->
                        <!-- AWAS Custom Add IntermediaryAgent2 -->
                        <xsl:if test="(PayeeBankAccount/IntermediaryBankAccount2/IntermediaryAccountID)">
                           <xsl:if test="not(concat(PayeeBankAccount/IntermediaryBankAccount2/SwiftCode,PayeeBankAccount/IntermediaryBankAccount2/BranchNumber)='')">
                              <IntrmyAgt2>
                                 <FinInstnId>
                                    <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount2/SwiftCode='')">
                                       <BIC>
                                          <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount2/SwiftCode" />
                                       </BIC>
                                    </xsl:if>
                                    <xsl:if test="(PayeeBankAccount/IntermediaryBankAccount2/SwiftCode='')">
                                       <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount2/BranchNumber='')">
                                          <ClrSysMmbId>
                                             <MmbId>
                                                <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount2/BranchNumber" />
                                             </MmbId>
                                          </ClrSysMmbId>
                                       </xsl:if>
                                    </xsl:if>
                                    <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount2/BankName='')">
                                       <Nm>
                                          <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount2/BankName" />
                                       </Nm>
                                    </xsl:if>
                                    <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount2/Country='')">
                                       <PstlAdr>
                                          <Ctry>
                                             <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount2/Country" />
                                          </Ctry>
                                       </PstlAdr>
                                    </xsl:if>
                                 </FinInstnId>
                                 <xsl:if test="not(PayeeBankAccount/IntermediaryBankAccount2/BranchNumber='')">
                                    <BrnchId>
                                       <Id>
                                          <xsl:value-of select="PayeeBankAccount/IntermediaryBankAccount2/BranchNumber" />
                                       </Id>
                                    </BrnchId>
                                 </xsl:if>
                              </IntrmyAgt2>
                           </xsl:if>
                        </xsl:if>
                        <!-- End Of AWAS IntermediaryAgent2 -->
						<!-- Add in CdtrAgt details if non cheque -->
						<xsl:if test="not(PaymentMethod/PaymentMethodFormatValue='CHK')">
                        <CdtrAgt>
                           <FinInstnId>
                              <xsl:if test="not(PayeeBankAccount/SwiftCode='')">
                                 <BIC>
                                    <xsl:value-of select="PayeeBankAccount/SwiftCode" />
                                 </BIC>
                              </xsl:if>
                              <xsl:if test="(PayeeBankAccount/SwiftCode='')">
                                 <xsl:if test="not(PayeeBankAccount/BranchNumber='')">
                                    <ClrSysMmbId>
                                       <MmbId>
                                          <xsl:value-of select="PayeeBankAccount/BranchNumber" />
                                       </MmbId>
                                    </ClrSysMmbId>
                                 </xsl:if>
                              </xsl:if>
                              <xsl:if test="not(PayeeBankAccount/BankName='')">
                                 <Nm>
                                    <xsl:value-of select="PayeeBankAccount/BankName" />
                                 </Nm>
                              </xsl:if>
                              <xsl:if test="not(PayeeBankAccount/BankAddress/Country='')">
                                 <PstlAdr>
                                    <Ctry>
                                       <xsl:value-of select="PayeeBankAccount/BankAddress/Country" />
                                    </Ctry>
                                 </PstlAdr>
                              </xsl:if>
                           </FinInstnId>
                           <!--<xsl:if test="not(PayeeBankAccount/BranchNumber='')">
										<BrnchId>
											<Id>
												<xsl:value-of select="PayeeBankAccount/BranchNumber"
												/>
											</Id>
										</BrnchId>
									</xsl:if> -->
                        </CdtrAgt>
						</xsl:if>
                        <Cdtr>
                           <Nm>
                              <xsl:value-of select="substring(translate(Payee/Name,'&amp;;#*=$![~`]{\}%@' ,''),1,35)" />
                           </Nm>
                           <PstlAdr>
                              <StrtNm>
                                 <!-- AWAS Added Translate to remove special characters -->
                                 <xsl:value-of select="translate(Payee/Address/AddressLine1,'&amp;;#*=$![~`]{\}%@' ,'')" />
                              </StrtNm>
                              <PstCd>
                                 <xsl:value-of select="Payee/Address/PostalCode" />
                              </PstCd>
                              <TwnNm>
                                 <xsl:value-of select="Payee/Address/City" />
                              </TwnNm>
                              <xsl:if test="not(Payee/Address/County='') or not(Payee/Address/State='') or not(Payee/Address/Province='')">
                                 <CtrySubDvsn>
                                    <xsl:value-of select="Payee/Address/County" />
                                    <xsl:value-of select="Payee/Address/State" />
                                    <xsl:value-of select="Payee/Address/Province" />
                                 </CtrySubDvsn>
                              </xsl:if>
                              <Ctry>
                                 <xsl:value-of select="Payee/Address/Country" />
                              </Ctry>
                           </PstlAdr>
                           <Id>
                              <OrgId>
                                 <xsl:if test="not(Payee/TaxRegistrationNumber='')">
                                    <Othr>
                                       <Id>
                                          <xsl:value-of select="Payee/TaxRegistrationNumber" />
                                       </Id>
                                    </Othr>
                                 </xsl:if>
                                 <xsl:if test="(Payee/TaxRegistrationNumber='')">
                                    <xsl:if test="not(Payee/LegalEntityRegistrationNumber='')">
                                       <Othr>
                                          <Id>
                                             <xsl:value-of select="Payee/LegalEntityRegistrationNumber" />
                                          </Id>
                                       </Othr>
                                    </xsl:if>
                                    <xsl:if test="(Payee/LegalEntityRegistrationNumber='')">
                                       <xsl:if test="not(Payee/SupplierNumber='')">
                                          <Othr>
                                             <Id>
                                                <xsl:value-of select="Payee/SupplierNumber" />
                                             </Id>
                                          </Othr>
                                       </xsl:if>
                                       <xsl:if test="(Payee/SupplierNumber='')">
                                          <xsl:if test="not(Payee/PartyNumber='')">
                                             <Othr>
                                                <Id>
                                                   <xsl:value-of select="Payee/PartyNumber" />
                                                </Id>
                                             </Othr>
                                          </xsl:if>
                                          <xsl:if test="(Payee/PartyNumber='')">
                                             <Othr>
                                                <Id>
                                                   <xsl:value-of select="Payee/FirstPartyReference" />
                                                </Id>
                                             </Othr>
                                          </xsl:if>
                                       </xsl:if>
                                    </xsl:if>
                                 </xsl:if>
                              </OrgId>
                           </Id>
                        </Cdtr>
						<xsl:if test="not(PaymentMethod/PaymentMethodFormatValue='CHK')">
                        <CdtrAcct>
                           <Id>
                              <xsl:if test="not(PayeeBankAccount/IBANNumber='')">
                                 <IBAN>
                                    <xsl:value-of select="PayeeBankAccount/IBANNumber" />
                                 </IBAN>
                              </xsl:if>
                              <!-- if no IBAN, use bank account number-->
                              <xsl:if test="(PayeeBankAccount/IBANNumber='')">
                                 <Othr>
                                    <Id>
                                       <xsl:value-of select="PayeeBankAccount/UserEnteredBankAccountNumber" />
                                    </Id>
                                 </Othr>
                              </xsl:if>
                           </Id>
                           <xsl:if test="not(PayeeBankAccount/BankAccountName='')">
                              <Nm>
                                 <xsl:value-of select="translate(PayeeBankAccount/BankAccountName,'&amp;;#*=$![~`]{\}%@' ,'')" />
                              </Nm>
                           </xsl:if>
                        </CdtrAcct>
						</xsl:if>
                        <xsl:if test="(Payee/PartyInternalID!= TradingPartner/PartyInternalID)">
                           <UltmtCdtr>
                              <Nm>
                                 <xsl:value-of select="TradingPartner/Name" />
                              </Nm>
                              <Id>
                                 <OrgId>
                                    <xsl:if test="not(TradingPartner/TaxRegistrationNumber='')">
                                       <Othr>
                                          <Id>
                                             <xsl:value-of select="TradingPartner/TaxRegistrationNumber" />
                                          </Id>
                                       </Othr>
                                    </xsl:if>
                                    <xsl:if test="(TradingPartner/TaxRegistrationNumber='')">
                                       <xsl:if test="not(TradingPartner/LegalEntityRegistrationNumber='')">
                                          <Othr>
                                             <Id>
                                                <xsl:value-of select="TradingPartner/LegalEntityRegistrationNumber" />
                                             </Id>
                                          </Othr>
                                       </xsl:if>
                                       <xsl:if test="(TradingPartner/LegalEntityRegistrationNumber='')">
                                          <xsl:if test="not(TradingPartner/SupplierNumber='')">
                                             <Othr>
                                                <Id>
                                                   <xsl:value-of select="TradingPartner/SupplierNumber" />
                                                </Id>
                                             </Othr>
                                          </xsl:if>
                                          <xsl:if test="(TradingPartner/SupplierNumber='')">
                                             <xsl:if test="not(TradingPartner/PartyNumber='')">
                                                <Othr>
                                                   <Id>
                                                      <xsl:value-of select="TradingPartner/PartyNumber" />
                                                   </Id>
                                                </Othr>
                                             </xsl:if>
                                             <xsl:if test="(TradingPartner/PartyNumber='')">
                                                <Othr>
                                                   <Id>
                                                      <xsl:value-of select="translate(TradingPartner/FirstPartyReference,'&amp;;#*=$![~`]{\}%@' ,'')" />
                                                   </Id>
                                                </Othr>
                                             </xsl:if>
                                          </xsl:if>
                                       </xsl:if>
                                    </xsl:if>
                                 </OrgId>
                              </Id>
                           </UltmtCdtr>
                        </xsl:if>
                        <xsl:if test="(PaymentMethod/PaymentMethodFormatValue='TRF') and (not(/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstruction[2]/Meaning='') or not(/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstructionDetails=''))">
                           <InstrForCdtrAgt>
                              <xsl:if test="not(/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstruction[2]/Meaning='')">
                                 <Cd>
                                    <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstruction[2]/Meaning" />
                                 </Cd>
                              </xsl:if>
                              <xsl:if test="not(/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstructionDetails='')">
                                 <InstrInf>
                                    <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstructionDetails" />
                                 </InstrInf>
                              </xsl:if>
                           </InstrForCdtrAgt>
                        </xsl:if>
                        <xsl:if test="(PaymentMethod/PaymentMethodFormatValue='TRF') and not(/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstruction[1]/Meaning='')">
                           <InstrForDbtrAgt>
                              <xsl:value-of select="/OutboundPaymentInstruction/PaymentInstructionInfo/BankInstruction[1]/Meaning" />
                           </InstrForDbtrAgt>
                        </xsl:if>
                        <xsl:if test="not(PaymentReason/Code = '')">
                           <Purp>
                              <Cd>
                                 <xsl:value-of select="PaymentReason/Code" />
                              </Cd>
                           </Purp>
                        </xsl:if>
                        <xsl:if test="not(Payee/TaxRegistrationNumber='') or not(Payer/TaxRegistrationNumber='')">
                           <Tax>
                              <xsl:if test="not(Payee/TaxRegistrationNumber='')">
                                 <Cdtr>
                                    <TaxId>
                                       <xsl:value-of select="Payee/TaxRegistrationNumber" />
                                    </TaxId>
                                 </Cdtr>
                              </xsl:if>
                              <xsl:if test="not(Payer/TaxRegistrationNumber='')">
                                 <Dbtr>
                                    <TaxId>
                                       <xsl:value-of select="Payer/TaxRegistrationNumber" />
                                    </TaxId>
                                 </Dbtr>
                              </xsl:if>
                           </Tax>
                        </xsl:if>
                        <RmtInf>
                           <xsl:variable name="IssurName" select="Payee/Name" />
                           <xsl:for-each select="DocumentPayable">
								<Ustrd>
									<!-- Removed next line ref Help Me Change 392
									<xsl:value-of select="DocumentNumber/ReferenceNumber" /> 
									-->
									<!-- Added next line ref Help Me Change 392 -->
									<xsl:value-of select="translate(DocumentNumber/ReferenceNumber,'&amp;;#*=$![~`]{\}%@_/' ,'')" />
								</Ustrd>
                           </xsl:for-each>
                        </RmtInf>
                  </CdtTrfTxInf>
                  </xsl:for-each>
               </PmtInf>
            </xsl:for-each>
         </CstmrCdtTrfInitn>
      </Document>
   </xsl:template>
</xsl:stylesheet>