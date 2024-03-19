// Copyright (C) 2023, 2024 Ildar Shaimordanov
// MIT License
var XML = require('xml');

var xml_root_name = '__SQL__';

var xml_file = ARGV[0];

var base = __filename.replace(/[.][^.]+$/, '');

var xsd_main_file = base + '.xsd';
var xsl_main_file = base + '.xsl';

var xml = XML.validate((function() {
	var xml = XML.load(xml_file, {
		async: false,
		validateOnParse: false,
		resolveExternals: true,
		schemas: XML.loadSchemaCache('', xsd_main_file)
	}, {
		ProhibitDTD: false
	});

	var node = xml.createElement(xml_root_name);
	var root = xml.documentElement;
	while ( root.hasChildNodes() ) {
		node.appendChild(root.removeChild(root.firstChild));
	}
	xml.documentElement = node;

	return xml;
})());

var html = xml.transformNode(XML.load(xsl_main_file));

console.log(html);
