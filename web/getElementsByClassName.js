// My vision of document.getElementsByClassName.
// I developed it to implement the absent functionality in MSIE and MSHTA.

document.getElementsByClassName =
document.getElementsByClassName || (function() {
	function getArrangedClassName(className) {
		return className
		.replace(/^\s+|\s+$/g, '')
		.toLowerCase()
		.split(/\s+/)
		.sort();
	}

	function contains(a, b) {
		var found = 0;

		for (var i = 0; i < a.length; i++) {
			for (var j = 0; j < b.length; j++) {
				if ( a[i] == b[j] ) {
					found++;
				}
			}
		}

		return found == b.length;
	}

	return function getElementsByClassName(className, parent) {
		var result = [];

		var cn = getArrangedClassName(String(className));
		var els = ( parent || document ).getElementsByTagName('*');
		for (var i = 0; i < els.length; i++) {
			var cni = getArrangedClassName(els[i].className);
			if ( contains(cni, cn) ) {
				result.push(els[i]);
			}
		}

		return result;
	};
})();
