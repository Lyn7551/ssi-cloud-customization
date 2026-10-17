/* SSI Cloud "Spaces" — header entry (app menu is hidden by theming CSS, so we inject our own).
   The NC header is Vue-mounted after DOMContentLoaded, so wait for .header-right to appear. */
/* global OC */

(function () {
	'use strict';

	var LABELS = { zh: '空间', en: 'Spaces' };

	function inject() {
		var headerRight = document.querySelector('#header .header-end');
		if (!headerRight || document.getElementById('ssispace-header-entry')) {
			return false;
		}
		var lang = (OC.getLanguage() || 'en').slice(0, 2).toLowerCase();
		var label = LABELS[lang] || LABELS.en;

		var a = document.createElement('a');
		a.id = 'ssispace-header-entry';
		a.className = 'header-menu__trigger';
		a.href = OC.getRootPath() + '/index.php/apps/ssispace/';
		a.title = label;
		a.setAttribute('aria-label', label);
		a.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
			+ '<path d="M4 4h7v7H4V4zm9 0h7v7h-7V4zM4 13h7v7H4v-7zm9 0h7v7h-7v-7z"/></svg>';

		headerRight.insertBefore(a, headerRight.firstChild);
		return true;
	}

	function start() {
		if (inject()) {
			return;
		}
		var header = document.getElementById('header');
		if (!header) {
			return;
		}
		var observer = new MutationObserver(function () {
			if (inject()) {
				observer.disconnect();
			}
		});
		observer.observe(header, { childList: true, subtree: true });
		// safety stop after 15s
		setTimeout(function () { observer.disconnect(); }, 15000);
	}

	if (document.readyState !== 'loading') {
		start();
	} else {
		document.addEventListener('DOMContentLoaded', start);
	}
})();
