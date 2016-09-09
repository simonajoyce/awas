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
 <xsl:template match="LIST_G_REPORT">
 <!--<Worksheet ss:Name="Value Summary">
   <PivotTable xmlns="urn:schemas-microsoft-com:office:excel">
   <Name>PivotTableValue</Name>
   <ImmediateItemsOnDrop/>
   <ShowPageMultipleItemLabel/>
   <CompactRowIndent>1</CompactRowIndent>
   <Location>R6C3:R16C8</Location>
   <VersionLastUpdate>3</VersionLastUpdate>
   <DefaultVersion>1</DefaultVersion>
   <PivotField>
    <Name>PO Number</Name>
   </PivotField>
   <PivotField>
    <Name>Line Num</Name>
   </PivotField>
   <PivotField>
    <Name>Type Lookup Code</Name>
    <Orientation>Page</Orientation>
    <Position>1</Position>
    <PivotItem>
     <Name>STANDARD</Name>
    </PivotItem>
   </PivotField>
   <PivotField>
    <Name>Vendor Number</Name>
   </PivotField>
   <PivotField>
    <Name>Vendor Name</Name>
   </PivotField>
   <PivotField>
    <Name>Item Number</Name>
   </PivotField>
   <PivotField>
    <Name>Item Category</Name>
   </PivotField>
   <PivotField>
    <Name>Item Description</Name>
   </PivotField>
   <PivotField>
    <Name>UOM</Name>
   </PivotField>
   <PivotField>
    <Name>Currency</Name>
    <Orientation>Column</Orientation>
    <Position>1</Position>
    <PivotItem>
     <Name>EUR</Name>
    </PivotItem>
    <PivotItem>
     <Name>SGD</Name>
    </PivotItem>
    <PivotItem>
     <Name>USD</Name>
    </PivotItem>
   </PivotField>
   <PivotField>
    <Name>Unit Price</Name>
    <DataType>Number</DataType>
   </PivotField>
   <PivotField>
    <Name>Qty Ordered</Name>
    <DataType>Integer</DataType>
   </PivotField>
   <PivotField>
    <Name>Extended Cost</Name>
    <DataType>Number</DataType>
   </PivotField>
   <PivotField>
    <Name>Qty Received</Name>
    <DataType>Number</DataType>
   </PivotField>
   <PivotField>
    <Name>Qty Invoiced</Name>
    <DataType>Integer</DataType>
   </PivotField>
   <PivotField>
    <Name>Qty Cancelled</Name>
    <DataType>Number</DataType>
   </PivotField>
   <PivotField>
    <Name>Age</Name>
    <Orientation>Row</Orientation>
    <Position>1</Position>
    <PivotItem>
     <Name>0-3 Months</Name>
    </PivotItem>
    <PivotItem>
     <Name>3-6 Months</Name>
    </PivotItem>
    <PivotItem>
     <Name>6-9 Months</Name>
    </PivotItem>
    <PivotItem>
     <Name>9-12 Months</Name>
    </PivotItem>
    <PivotItem>
     <Name>Over 12 Months</Name>
    </PivotItem>
   </PivotField>
   <PivotField>
    <DataField/>
    <Name>Data</Name>
    <Orientation>Row</Orientation>
    <Position>-1</Position>
   </PivotField>
   <PivotField>
    <Name>Sum of Extended Cost</Name>
    <ParentField>Extended Cost</ParentField>
    <Orientation>Data</Orientation>
    <Position>1</Position>
   </PivotField>
   <PTLineItems>
    <PTLineItem>
     <Item>0</Item>
    </PTLineItem>
    <PTLineItem>
     <Item>1</Item>
    </PTLineItem>
    <PTLineItem>
     <Item>2</Item>
    </PTLineItem>
    <PTLineItem>
     <Item>3</Item>
    </PTLineItem>
    <PTLineItem>
     <Item>4</Item>
    </PTLineItem>
    <PTLineItem>
     <ItemType>Grand</ItemType>
     <Item>0</Item>
    </PTLineItem>
   </PTLineItems>
   <PTLineItems>
    <Orientation>Column</Orientation>
    <PTLineItem>
     <Item>0</Item>
    </PTLineItem>
    <PTLineItem>
     <Item>1</Item>
    </PTLineItem>
    <PTLineItem>
     <Item>2</Item>
    </PTLineItem>
    <PTLineItem>
     <ItemType>Grand</ItemType>
     <Item>0</Item>
    </PTLineItem>
   </PTLineItems>
   <PTSource>
    <RefreshOnFileOpen/>
    <ConsolidationReference>
     <FileName>[AWAS_Open_PO_Report_180314.xml]PO Data</FileName>
     <Reference>R1C1:R<xsl:value-of select="count(G_REPORT)+1"/>C41</Reference>
    </ConsolidationReference>
   </PTSource>
  </PivotTable>
 </Worksheet> -->
 <Worksheet ss:Name="PO Data">
  <Table>
	<Row>
		<Cell><Data ss:Type="String">PO Number</Data></Cell>
		<Cell><Data ss:Type="String">Line Num</Data></Cell>
		<Cell><Data ss:Type="String">Type Lookup_Code</Data></Cell>
		<Cell><Data ss:Type="String">Vendor Num</Data></Cell>
		<Cell><Data ss:Type="String">Vendor Name</Data></Cell>
		<Cell><Data ss:Type="String">Item Number</Data></Cell>
		<Cell><Data ss:Type="String">Category</Data></Cell>
		<Cell><Data ss:Type="String">Item Description</Data></Cell>
		<Cell><Data ss:Type="String">Unit Meas_Lookup_Code</Data></Cell>
		<Cell><Data ss:Type="String">Tax Name</Data></Cell>
		<Cell><Data ss:Type="String">Po Dist_Creation_Date</Data></Cell>
		<Cell><Data ss:Type="String">Unit Price</Data></Cell>
		<Cell><Data ss:Type="String">Currency Code</Data></Cell>
		<Cell><Data ss:Type="String">Qty Ord</Data></Cell>
		<Cell><Data ss:Type="String">Extended Cost</Data></Cell>
		<Cell><Data ss:Type="String">Qty Rec</Data></Cell>
		<Cell><Data ss:Type="String">Qty Inv</Data></Cell>
		<Cell><Data ss:Type="String">Qty Can</Data></Cell>
		<Cell><Data ss:Type="String">GL Account</Data></Cell>
		<Cell><Data ss:Type="String">GL Ent</Data></Cell>
		<Cell><Data ss:Type="String">GL Account</Data></Cell>
		<Cell><Data ss:Type="String">GL CC</Data></Cell>
		<Cell><Data ss:Type="String">GL MSN</Data></Cell>
		<Cell><Data ss:Type="String">Deliver To Person</Data></Cell>
		<Cell><Data ss:Type="String">Requisition Number</Data></Cell>
		<Cell><Data ss:Type="String">Req Line Number</Data></Cell>
		<Cell><Data ss:Type="String">Closed Code</Data></Cell>
		<Cell><Data ss:Type="String">Vendor Type_Lookup_Code</Data></Cell>
		<Cell><Data ss:Type="String">Project Number</Data></Cell>
		<Cell><Data ss:Type="String">Project Name</Data></Cell>
		<Cell><Data ss:Type="String">Project MSN</Data></Cell>
		<Cell><Data ss:Type="String">Need By Date</Data></Cell>
		<Cell><Data ss:Type="String">Promised Date</Data></Cell>
		<Cell><Data ss:Type="String">Closed For Receiving_Date</Data></Cell>
		<Cell><Data ss:Type="String">Closed For Invoice_Date</Data></Cell>
		<Cell><Data ss:Type="String">PO Creation Date</Data></Cell>
		<Cell><Data ss:Type="String">Age Creation</Data></Cell>
		<Cell><Data ss:Type="String">Receipt Creation</Data></Cell>
		<Cell><Data ss:Type="String">Age Creation Months</Data></Cell>
		<Cell><Data ss:Type="String">Receipt Creation Months</Data></Cell>
		<Cell><Data ss:Type="String">Age Creation Bucket</Data></Cell>
	 </Row>
    <xsl:apply-templates/>
   </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
  </WorksheetOptions>	      
  </Worksheet>  
 </xsl:template>
 <xsl:template match="G_REPORT">
  <Row>
		<Cell><Data ss:Type="String"><xsl:value-of select="PO_NUMBER"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="LINE_NUM"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="TYPE_LOOKUP_CODE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="VENDOR_NUM"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="VENDOR_NAME"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="ITEM_NUMBER"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="CATEGORY"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="ITEM_DESCRIPTION"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="UNIT_MEAS_LOOKUP_CODE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="TAX_NAME"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="PO_DIST_CREATION_DATE"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="UNIT_PRICE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="CURRENCY_CODE"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="QTY_ORD"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="EXTENDED_COST"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="QTY_REC"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="QTY_INV"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="QTY_CAN"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="GL_ACCOUNT"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="GL_ENT"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="GL_ACC"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="GL_CC"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="GL_MSN"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="DELIVER_TO_PERSON"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="REQUISITION_NUMBER"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="REQ_LINE_NUMBER"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="CLOSED_CODE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="VENDOR_TYPE_LOOKUP_CODE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="PROJECT_NUMBER"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="PROJECT_NAME"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="PROJECT_MSN"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="NEED_BY_DATE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="PROMISED_DATE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="CLOSED_FOR_RECEIVING_DATE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="CLOSED_FOR_INVOICE_DATE"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="PO_CREATION_DATE"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="AGE_CREATION"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="RECEIPT_CREATION"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="AGE_CREATION_MONTHS"/></Data></Cell>
		<Cell><Data ss:Type="Number"><xsl:value-of select="RECEIPT_CREATION_MONTHS"/></Data></Cell>
		<Cell><Data ss:Type="String"><xsl:value-of select="AGE_CREATION_BUCKET"/></Data></Cell>
   </Row>
 </xsl:template>
</xsl:stylesheet>