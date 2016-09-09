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
</xsl:stylesheet>