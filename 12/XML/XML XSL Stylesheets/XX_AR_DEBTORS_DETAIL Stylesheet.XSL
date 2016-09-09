<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:template match="/">
		<xsl:processing-instruction name="mso-application">
			<xsl:text>progid="Excel.Sheet"</xsl:text>
		</xsl:processing-instruction>
		<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
            xmlns:x="urn:schemas-microsoft-com:office:excel"
            xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
			<xsl:apply-templates/>
		</Workbook>
	</xsl:template>
	<xsl:template match="LIST_G_MAIN">
		<Worksheet ss:Name="PivotTable">
			<Table>
				<Row>
					<Cell>
						<Data ss:Type="String">Duty management report generated on: <!-- <<xsl:value-of select="//CURR_DATE"/> -->
						</Data>
					</Cell>
				</Row>
				<Row>
					<Cell>
						<Data ss:Type="String">Selection date from: <!-- <xsl:value-of select="//DATE_FROM"/> to: <xsl:value-of select="//DATE_TO"/> -->
						</Data>
					</Cell>
				</Row>
				<Row>
					<Cell>
						<Data ss:Type="String">Amounts displayed are in currency of: <!-- <xsl:value-of select="//CURRENCY_CODE"/> -->
						</Data>
					</Cell>
				</Row>
			</Table>   
			<PivotTable xmlns="urn:schemas-microsoft-com:office:excel">
				<Name>SimonsPivot</Name>
				<ImmediateItemsOnDrop/>
				<ShowPageMultipleItemLabel/>
				<CompactRowIndent>1</CompactRowIndent>
				<Location>R5C2:R12C4</Location>
				<VersionLastUpdate>3</VersionLastUpdate>
				<DefaultVersion>1</DefaultVersion>
				<PivotField>
					<Name>Customer Name</Name>
					<Orientation>Page</Orientation>
					<Position>1</Position>
					<PivotItem>
						<Name/>
					</PivotItem>
				</PivotField>
				<PivotField>
					<Name>Trx Date</Name>
				</PivotField>
				<PivotField>
					<Name>Trx Num</Name>
				</PivotField>
				<PivotField>
					<Name>Amount</Name>
					<DataType>Integer</DataType>
				</PivotField>
				<PivotField>
					<Name>TA</Name>
				</PivotField>
				<PivotField>
					<Name>Dispute Amount</Name>
					<DataType>Integer</DataType>
				</PivotField>
				<PivotField>
					<Name>Currency</Name>
				</PivotField>
				<PivotField>
					<Name>Trx Type</Name>
					<Orientation>Row</Orientation>
					<Position>1</Position>
					<Subtotal>None</Subtotal>
				</PivotField>
				<PivotField>
					<Name>MSN</Name>
				</PivotField>
				<PivotField>
					<Name>GL Date</Name>
				</PivotField>
				<PivotField>
					<Name>Period</Name>
					<Orientation>Column</Orientation>
					<Position>1</Position>
					<PivotItem>
						<Name/>
					</PivotItem>
				</PivotField>
				<PivotField>
					<Name>Total Amount</Name>
					<ParentField>Amount</ParentField>
					<DataType>Integer</DataType>
					<Orientation>Data</Orientation>
					<Function>Sum</Function>
					<Position>1</Position>
				</PivotField>
				   <PTLineItems>
					<PTLineItem>
					 <Item>0</Item>
					</PTLineItem>
					</PTLineItems>
				   <PTLineItems>
					<Orientation>Column</Orientation>
					<PTLineItem>
					 <Item>0</Item>
					</PTLineItem>
				   </PTLineItems>
				<PTSource>
					<RefreshOnFileOpen/>
					<ConsolidationReference>
						<FileName>[AWAS_AR_Debtors_Detail_Report.xml]Detail Data</FileName>
						<Reference>R1C1:R<xsl:value-of select="count(G_REPORT)+1"/>C11</Reference>
					</ConsolidationReference>
				</PTSource>
			</PivotTable>
		</Worksheet>
		<Worksheet ss:Name="Detail Data">
			<Table>
				<Row>
					<Cell>
						<Data ss:Type="String">Customer Name</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Trx Date</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Trx Num</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Amount</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">TA</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Dispute Amount</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Currency</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Trx Type</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">MSN</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">GL Date</Data>
					</Cell>
					<Cell>
						<Data ss:Type="String">Period</Data>
					</Cell>
				</Row>
				<xsl:apply-templates/>
			</Table>
			<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
			</WorksheetOptions>	      
		</Worksheet>  
	</xsl:template> 
	<xsl:template match="G_MAIN">
		<Row>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="CUSTOMER_NAME"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="TRX_DATE"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="INVOICE_NO"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="Number">
					<xsl:value-of select="AMOUNT"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="TA"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="Number">
					<xsl:value-of select="DISPUTE_AMOUNT"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="CURRENCY_CODE"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="TRANSACTION_TYPE"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="GL_MSN"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="GL_DATE"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="PERIOD"/>
				</Data>
			</Cell>
		</Row>
	</xsl:template>
	<xsl:template name="PivotTable">
	</xsl:template>
</xsl:stylesheet>