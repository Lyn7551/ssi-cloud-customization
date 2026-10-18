/* SSI Cloud "Spaces" page — data loading (public APIs only: WebDAV nc:mount-type + OCS files_sharing) */
/* global OC, OCP */

(function () {
	'use strict';

	var deptsEl = document.getElementById('ssispace-depts');
	var sharesEl = document.getElementById('ssispace-shares');
	if (!deptsEl || !sharesEl) {
		return;
	}

	var uid = (OC.getCurrentUser && OC.getCurrentUser().uid)
		|| document.head.getAttribute('data-user')
		|| document.body.getAttribute('data-user');
	var davBase = OC.linkToRemote('dav') + '/files/' + encodeURIComponent(uid);
	/* canonical pretty-URL base generated server-side (no hand-rolled index.php paths) */
	var filesAppBase = document.getElementById('ssispace').getAttribute('data-files-base');

	var PROPFIND_BODY = '<?xml version="1.0"?>'
		+ '<d:propfind xmlns:d="DAV:" xmlns:nc="http://nextcloud.org/ns">'
		+ '<d:prop><d:displayname/><nc:mount-type/><d:resourcetype/></d:prop></d:propfind>';

	function propfind(path) {
		return fetch(davBase + encodeURI(path), {
			method: 'PROPFIND',
			credentials: 'same-origin',
			headers: { 'Content-Type': 'application/xml', Depth: '1', requesttoken: OC.requestToken },
			body: PROPFIND_BODY
		}).then(function (res) {
			if (!res.ok) {
				throw new Error('PROPFIND ' + res.status);
			}
			return res.text();
		}).then(function (text) {
			return parsePropfind(text, path);
		});
	}

	function parsePropfind(text, selfPath) {
		var doc = new DOMParser().parseFromString(text, 'application/xml');
		var responses = doc.getElementsByTagNameNS('DAV:', 'response');
		var out = [];
		for (var i = 0; i < responses.length; i++) {
			var r = responses[i];
			var hrefEl = r.getElementsByTagNameNS('DAV:', 'href')[0];
			if (!hrefEl) {
				continue;
			}
			var href = decodeURIComponent(hrefEl.textContent);
			var rel = href.replace(/^.*\/files\/[^/]+/, '').replace(/\/$/, '');
			if (rel === selfPath.replace(/\/$/, '') || rel === '') {
				continue; // self
			}
			var isCollection = r.getElementsByTagNameNS('DAV:', 'collection').length > 0;
			var mtEl = r.getElementsByTagNameNS('http://nextcloud.org/ns', 'mount-type')[0];
			var nameEl = r.getElementsByTagNameNS('DAV:', 'displayname')[0];
			out.push({
				path: rel,
				name: nameEl ? nameEl.textContent : rel.split('/').pop(),
				isCollection: isCollection,
				mountType: mtEl ? mtEl.textContent : ''
			});
		}
		return out;
	}

	function el(tag, cls, text) {
		var e = document.createElement(tag);
		if (cls) {
			e.className = cls;
		}
		if (text !== undefined) {
			e.textContent = text;
		}
		return e;
	}

	function filesLink(path) {
		return filesAppBase + '?dir=' + encodeURIComponent(path);
	}

	function clearSkeletons(container) {
		var skels = container.querySelectorAll('.ssispace-skel');
		for (var i = 0; i < skels.length; i++) {
			skels[i].remove();
		}
	}

	function deptCard(dept) {
		var card = el('div', 'ssispace-card ssispace-card--dept');
		card.style.cursor = 'default';

		var icon = el('span', 'ssispace-card-icon');
		icon.setAttribute('aria-hidden', 'true');
		icon.innerHTML = '<svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor">'
			+ '<path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5s-3 1.34-3 3 1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>';
		card.appendChild(icon);

		var body = el('span', 'ssispace-card-body');
		var name = el('a', 'ssispace-card-name', dept.name);
		name.href = filesLink(dept.path);
		body.appendChild(name);

		var meta = el('span', 'ssispace-card-meta', dept.path);
		body.appendChild(meta);

		if (dept.subs.length > 0) {
			var tags = el('span', 'ssispace-tags');
			dept.subs.forEach(function (sub) {
				var tag = el('a', 'ssispace-tag', sub.name);
				tag.href = filesLink(sub.path);
				tags.appendChild(tag);
			});
			body.appendChild(tags);
		}
		card.appendChild(body);
		return card;
	}

	function shareCard(share) {
		var isFolder = share.item_type === 'folder';
		var href = isFolder
			? filesLink(share.path)
			: filesLink(share.path.replace(/\/[^/]*$/, '') || '/') + '&openfile=' + encodeURIComponent(share.file_source);

		var card = el('a', 'ssispace-card');
		card.href = href;

		var icon = el('span', 'ssispace-card-icon');
		icon.setAttribute('aria-hidden', 'true');
		icon.innerHTML = '<svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor">'
			+ '<path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z"/></svg>';
		card.appendChild(icon);

		var body = el('span', 'ssispace-card-body');
		body.appendChild(el('span', 'ssispace-card-name', share.path.split('/').pop() || share.path));
		var owner = share.displayname_owner || share.uid_owner || '';
		if (owner) {
			body.appendChild(el('span', 'ssispace-card-meta', owner));
		}
		card.appendChild(body);
		return card;
	}

	function showState(id) {
		var e = document.getElementById(id);
		if (e) {
			e.hidden = false;
		}
	}

	/* Department spaces: root group folders + one level of nested group folders as sub-team tags */
	propfind('/')
		.then(function (entries) {
			var depts = entries.filter(function (e) {
				return e.isCollection && e.mountType === 'group';
			});
			if (depts.length === 0) {
				clearSkeletons(deptsEl);
				showState('ssispace-depts-empty');
				return;
			}
			return Promise.all(depts.map(function (d) {
				return propfind(d.path).then(function (subs) {
					d.subs = subs.filter(function (s) {
						return s.isCollection && s.mountType === 'group';
					});
					return d;
				}).catch(function () {
					d.subs = [];
					return d;
				});
			})).then(function (list) {
				clearSkeletons(deptsEl);
				list.forEach(function (d) {
					deptsEl.appendChild(deptCard(d));
				});
			});
		})
		.catch(function () {
			clearSkeletons(deptsEl);
			showState('ssispace-depts-error');
		});

	/* Shared with me (OCS files_sharing public API) */
	fetch(OC.getRootPath() + '/ocs/v2.php/apps/files_sharing/api/v1/shares?shared_with_me=true&format=json', {
		credentials: 'same-origin',
		headers: { 'OCS-APIRequest': 'true', Accept: 'application/json', requesttoken: OC.requestToken }
	})
		.then(function (res) { return res.json(); })
		.then(function (data) {
			clearSkeletons(sharesEl);
			var shares = (data && data.ocs && data.ocs.data) || [];
			if (shares.length === 0) {
				showState('ssispace-shares-empty');
				return;
			}
			shares.forEach(function (s) {
				sharesEl.appendChild(shareCard(s));
			});
		})
		.catch(function () {
			clearSkeletons(sharesEl);
			showState('ssispace-shares-empty');
		});

	var page = document.getElementById('ssispace');
	if (page) {
		page.setAttribute('aria-busy', 'false');
	}
})();
