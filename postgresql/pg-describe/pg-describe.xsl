<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
Copyright (C) 2023, 2024 Ildar Shaimordanov
MIT License
-->

<xsl:output method="html" encoding="utf-8" indent="yes" />

<xsl:template match="/">
<html>
<head>
<title>rbsdb</title>
<style type="text/css">
body {
	margin: 0;
}
table {
	border-collapse: collapse;
	font-family: "Calibri Light", sans-serif;
	font-size: 12px;
}
.global_header {
	background-color: #999;
	position: sticky;
	top: 0;
}
.local_header_1 {
	background-color: #ccc;
	position: sticky;
	top: 1.5em;
}
.local_header_2 {
	background-color: #eee;
	position: sticky;
	top: 3em;
}
th {
	border: 1px solid #ccc;
	padding: 2px 5px;
	text-align: left;
}
td {
	border: 1px solid #ccc;
	padding: 2px 5px;
}
.number {
	text-align: right;
}
</style>
</head>
<body>
<table>
<thead>
<tr class="global_header">
<th>Schema</th>
<th>Table</th>
<th>#</th>
<th>Column</th>
<th>Type</th>
<th>Nullable</th>
<th>Default</th>
<th>Comment</th>
</tr>
</thead>
<tbody>
<xsl:apply-templates select="//DATA_RECORD" />
</tbody>
</table>
</body>
</html>
</xsl:template>

<xsl:template match="//DATA_RECORD[table_name = '' and n = '']">
<tr class="local_header_1">
<th><xsl:value-of select="table_schema" /></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th><xsl:value-of select="comment" /></th>
</tr>
</xsl:template>

<xsl:template match="//DATA_RECORD[table_name != '' and n = '']">
<tr class="local_header_2">
<th><xsl:value-of select="table_schema" /></th>
<th><xsl:value-of select="table_name" /></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th></th>
<th><xsl:value-of select="comment" /></th>
</tr>
</xsl:template>

<xsl:template match="//DATA_RECORD" priority="0">
<tr>
<td><xsl:value-of select="table_schema" /></td>
<td><xsl:value-of select="table_name" /></td>
<td class="number"><xsl:value-of select="n" /></td>
<td><xsl:value-of select="column_name" /></td>
<td><xsl:value-of select="column_type" /></td>
<td><xsl:value-of select="nullable" /></td>
<td><xsl:value-of select="default" /></td>
<td><xsl:value-of select="comment" /></td>
</tr>
</xsl:template>

</xsl:stylesheet>
