// Buildmode item browser. The window is built once; the server pushes new pages with output().
var buildmode = {
	ref: null,
	seq: 0,
	searchTimer: null,
	sentSearch: '',
	selectedPath: null
};

function buildmodeTopic(params) {
	var query = 'byond://?src=' + encodeURIComponent(buildmode.ref);
	for (var key in params) {
		if (Object.prototype.hasOwnProperty.call(params, key)) {
			query += '&' + key + '=' + encodeURIComponent(params[key]);
		}
	}
	window.location.href = query;
}

// Requests that change the listing carry a number so replies to older requests are skipped.
function buildmodeRequest(params) {
	buildmode.seq += 1;
	params.seq = buildmode.seq;
	buildmodeTopic(params);
}

function buildmodeInit(ref, state) {
	buildmode.ref = ref;
	buildmode.seq = state.seq || 0;

	var tabs = document.querySelectorAll('#bm-tabs .tab');
	for (var i = 0; i < tabs.length; i++) {
		tabs[i].onclick = buildmodeOnTabClick;
	}

	var input = document.getElementById('bm-search');
	input.value = state.search || '';
	buildmode.sentSearch = input.value;
	input.oninput = buildmodeOnSearchInput;
	input.onkeydown = function (event) {
		if (event.keyCode === 13) {
			buildmodeFlushSearch();
		}
	};

	document.getElementById('bm-clear').onclick = function () {
		buildmodeTopic({ clear: 1 });
		return false;
	};
	document.getElementById('bm-grid').onclick = buildmodeOnGridClick;

	buildmodeRender(state);
}

function buildmodeOnTabClick() {
	buildmodeRequest({ category: this.getAttribute('data-category') });
	return false;
}

function buildmodeOnSearchInput() {
	if (buildmode.searchTimer) {
		clearTimeout(buildmode.searchTimer);
	}
	buildmode.searchTimer = setTimeout(buildmodeFlushSearch, 300);
}

function buildmodeFlushSearch() {
	if (buildmode.searchTimer) {
		clearTimeout(buildmode.searchTimer);
		buildmode.searchTimer = null;
	}
	var value = document.getElementById('bm-search').value || '';
	if (value === buildmode.sentSearch) {
		return;
	}
	buildmode.sentSearch = value;
	buildmodeRequest({ search: value });
}

function buildmodeOnGridClick(event) {
	var target = event.target || event.srcElement;
	while (target && target !== this) {
		if (target.getAttribute && target.getAttribute('data-path')) {
			buildmodeTopic({ item: target.getAttribute('data-path') });
			return false;
		}
		target = target.parentNode;
	}
	return false;
}

// Called by the server with a JSON page.
function buildmodeUpdate(json) {
	buildmodeRender(JSON.parse(json));
}

// Called by the server with the current selection only.
function buildmodeSelect(json) {
	buildmodeRenderSelection(JSON.parse(json).selected);
}

function buildmodeRender(state) {
	if (state.seq < buildmode.seq) {
		return;
	}

	var tabs = document.querySelectorAll('#bm-tabs .tab');
	for (var i = 0; i < tabs.length; i++) {
		var active = Number(tabs[i].getAttribute('data-category')) === state.category;
		tabs[i].className = active ? 'tab active' : 'tab';
	}

	buildmodeRenderPages('bm-pages-top', state);
	buildmodeRenderPages('bm-pages-bottom', state);

	var grid = document.getElementById('bm-grid');
	var fragment = document.createDocumentFragment();
	if (!state.items.length) {
		var empty = document.createElement('div');
		empty.className = 'more';
		empty.textContent = 'No entries.';
		fragment.appendChild(empty);
	}
	for (var j = 0; j < state.items.length; j++) {
		fragment.appendChild(buildmodeItemCell(state.items[j]));
	}
	grid.innerHTML = '';
	grid.appendChild(fragment);
	grid.scrollTop = 0;

	buildmodeRenderSelection(state.selected);
}

// item: [type path, name, icon resource ref, icon state, dir]
function buildmodeItemCell(item) {
	var cell = document.createElement('div');
	cell.className = 'item';
	cell.setAttribute('data-path', item[0]);
	cell.title = item[0];

	var iconBox = document.createElement('div');
	iconBox.className = 'item-icon';
	var img = document.createElement('img');
	img.src = item[2] + '?state=' + encodeURIComponent(item[3]) + '&dir=' + item[4];
	iconBox.appendChild(img);

	var label = document.createElement('div');
	label.className = 'item-name';
	label.textContent = item[1] || item[0];

	cell.appendChild(iconBox);
	cell.appendChild(label);
	return cell;
}

function buildmodeRenderPages(id, state) {
	var box = document.getElementById(id);
	box.innerHTML = '';

	var prev = document.createElement('a');
	prev.className = state.page > 1 ? 'button' : 'button disabled';
	prev.href = '#';
	prev.textContent = 'Previous';
	prev.onclick = function () {
		if (state.page > 1) {
			buildmodeRequest({ page: state.page - 1 });
		}
		return false;
	};

	var status = document.createElement('span');
	status.className = 'page-status';
	status.textContent = 'Page ' + state.page + ' of ' + state.pages + ' (' + state.total + ' entries)';

	var next = document.createElement('a');
	next.className = state.page < state.pages ? 'button' : 'button disabled';
	next.href = '#';
	next.textContent = 'Next';
	next.onclick = function () {
		if (state.page < state.pages) {
			buildmodeRequest({ page: state.page + 1 });
		}
		return false;
	};

	box.appendChild(prev);
	box.appendChild(status);
	box.appendChild(next);
}

function buildmodeRenderSelection(selected) {
	buildmode.selectedPath = selected ? selected.path : null;
	var label = document.getElementById('bm-selected');
	label.textContent = selected ? 'Selected: ' + selected.name + ' (' + selected.path + ')' : 'Nothing selected. Click an entry to select it.';
	document.getElementById('bm-clear').style.display = selected ? '' : 'none';

	var cells = document.querySelectorAll('#bm-grid .item');
	for (var i = 0; i < cells.length; i++) {
		var isSelected = cells[i].getAttribute('data-path') === buildmode.selectedPath;
		cells[i].className = isSelected ? 'item item-selected' : 'item';
	}
}
