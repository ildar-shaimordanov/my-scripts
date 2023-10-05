// My vision of document.getElementsByClassName.
// I developed it to implement the absent functionality in MSIE and MSHTA.

document.getElementsByClassName =
document.getElementsByClassName || (function() {
	function getArrangedClassName(className) {
		return className
		.replace(/^\s+|\s+$/g, '')
		.toLowerCase()
		.split(/\s+/)
		.sort()
		.join(' ');
	}

	return function getElementsByClassName(className, parent) {
		var result = [];

		var cn = getArrangedClassName(className);
		var els = ( parent || document ).getElementsByTagName('*');
		for (var i = 0; i < els.length; i++) {
			var cni = getArrangedClassName(els[i].className);
			if ( cni.indexOf(cn) > -1 ) {
				result.push(els[i]);
			}
		}

		return result;
	};
})();

