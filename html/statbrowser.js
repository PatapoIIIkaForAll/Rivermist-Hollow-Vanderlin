// Polyfills and compatibility ------------------------------------------------
var decoder = decodeURIComponent || unescape;
if (!Array.prototype.includes) {
  Array.prototype.includes = function (thing) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] == thing) return true;
    }
    return false;
  };
}
if (!String.prototype.trim) {
  String.prototype.trim = function () {
    return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, "");
  };
}

// Status panel implementation ------------------------------------------------
//status_tab_parts expects a list to be returned, to which we'll send a list within a list
//with just "loading" to not appear broken.
var status_tab_parts = [["Loading..."]];
var current_tab = null;
//mc_tab_parts expects a list to be returned, to which we'll send a list within a list
//with just "loading" to not appear broken.
var mc_tab_parts = [["Loading..."]];
var href_token = null;
var spells = [];
var spell_tabs = [];
var verb_tabs = [];
var verbs = [["", ""]]; // list with a list inside
var tickets = [];
var sdql2 = [];
var permanent_tabs = []; // tabs that won't be cleared by wipes
var imageRetryDelay = 500;
var imageRetryLimit = 50;
var topbar = document.getElementById("topbar");
var menu = document.getElementById("menu");
var statcontentdiv = document.getElementById("statcontent");
var storedimages = [];
var split_admin_tabs = false;

// Any BYOND commands that could result in the client's focus changing go through this
// to ensure that when we relinquish our focus, we don't do it after the result of
// a command has already taken focus for itself.
function run_after_focus(callback) {
  setTimeout(callback, 0);
}

document.addEventListener("mouseup", restoreFocus);
document.addEventListener("keyup", restoreFocus);

window.onload = function () {
  Byond.sendMessage("Update-Verbs");
};

function buildTopButtons() {
  var names = {
    "Changelog" : "changelog",
    "Rules" : "rules",
    "Wiki" : "wiki",
    "GitHub" : "github",
    "Report Issue" : "report-issue",
  }

  for(var name in names) {
    createButton(name, names[name]);
  }
}

function createButton(name, command) {
  var button = document.createElement("DIV");

  button.id = command;
  button.textContent = name;
  button.className = "top-item";
  button.style.order = name.charCodeAt(0);

  button.onclick = function () {
    Byond.command(command);
  }

  topbar.appendChild(button);
}

function createStatusTab(name) {
  if (name.indexOf(".") != -1) {
    var splitName = name.split(".");
    if (split_admin_tabs && splitName[0] === "Admin") name = splitName[1];
    else name = splitName[0];
  }
  if (document.getElementById(name) || name.trim() == "") {
    return;
  }
  if (!verb_tabs.includes(name) && !permanent_tabs.includes(name)) {
    return;
  }
  var button = document.createElement("DIV");
  button.onclick = function () {
    tab_change(name);
    this.blur();
    statcontentdiv.focus();
  };
  button.id = name;
  button.textContent = name;
  button.className = "button";
  //ORDERING ALPHABETICALLY
  button.style.order = { Status: 1, MC: 2, Tickets: 3 }[name] || name.charCodeAt(0);
  //END ORDERING
  menu.appendChild(button);
  SendTabToByond(name);
}

function removeStatusTab(name) {
  if (!document.getElementById(name) || permanent_tabs.includes(name)) {
    return;
  }
  for (var i = verb_tabs.length - 1; i >= 0; --i) {
    if (verb_tabs[i] == name) {
      verb_tabs.splice(i, 1);
    }
  }
  menu.removeChild(document.getElementById(name));
  TakeTabFromByond(name);
}

function sortVerbs() {
  verbs.sort(function (a, b) {
    var selector = a[0] == b[0] ? 1 : 0;
    if (a[selector].toUpperCase() < b[selector].toUpperCase()) {
      return 1;
    } else if (a[selector].toUpperCase() > b[selector].toUpperCase()) {
      return -1;
    }
    return 0;
  });
}

function addPermanentTab(name) {
  if (!permanent_tabs.includes(name)) {
    permanent_tabs.push(name);
  }
  createStatusTab(name);
}

function removePermanentTab(name) {
  for (var i = permanent_tabs.length - 1; i >= 0; --i) {
    if (permanent_tabs[i] == name) {
      permanent_tabs.splice(i, 1);
    }
  }
  removeStatusTab(name);
}

function checkStatusTab() {
  for (var i = 0; i < menu.children.length; i++) {
    if (
      !verb_tabs.includes(menu.children[i].id) &&
      !permanent_tabs.includes(menu.children[i].id)
    ) {
      menu.removeChild(menu.children[i]);
    }
  }
}

function remove_verb(v) {
  var verb_to_remove = v; // to_remove = [verb:category, verb:name]
  for (var i = verbs.length - 1; i >= 0; i--) {
    var part_to_remove = verbs[i];
    if (part_to_remove[1] == verb_to_remove[1]) {
      verbs.splice(i, 1);
    }
  }
}

function check_verbs() {
  for (var v = verb_tabs.length - 1; v >= 0; v--) {
    verbs_cat_check(verb_tabs[v]);
  }
}

function verbs_cat_check(cat) {
  var tabCat = cat;
  if (cat.indexOf(".") != -1) {
    var splitName = cat.split(".");
    if (split_admin_tabs && splitName[0] === "Admin") tabCat = splitName[1];
    else tabCat = splitName[0];
  }
  var verbs_in_cat = 0;
  var verbcat = "";
  if (!verb_tabs.includes(tabCat)) {
    removeStatusTab(tabCat);
    return;
  }
  for (var v = 0; v < verbs.length; v++) {
    var part = verbs[v];
    verbcat = part[0];
    if (verbcat.indexOf(".") != -1) {
      var splitName = verbcat.split(".");
      if (split_admin_tabs && splitName[0] === "Admin") verbcat = splitName[1];
      else verbcat = splitName[0];
    }
    if (verbcat != tabCat || verbcat.trim() == "") {
      continue;
    } else {
      verbs_in_cat = 1;
      break; // we only need one
    }
  }
  if (verbs_in_cat != 1) {
    removeStatusTab(tabCat);
    if (current_tab == tabCat) tab_change("Status");
  }
}

function findVerbindex(name, verblist) {
  for (var i = 0; i < verblist.length; i++) {
    var part = verblist[i];
    if (part[1] == name) return i;
  }
}
function wipe_verbs() {
  verbs = [["", ""]];
  verb_tabs = [];
  checkStatusTab(); // remove all empty verb tabs
}

function update_verbs() {
  wipe_verbs();
  Byond.sendMessage("Update-Verbs");
}

function SendTabsToByond() {
  var tabstosend = [];
  tabstosend = tabstosend.concat(permanent_tabs, verb_tabs);
  for (var i = 0; i < tabstosend.length; i++) {
    SendTabToByond(tabstosend[i]);
  }
}

function SendTabToByond(tab) {
  Byond.sendMessage("Send-Tabs", { tab: tab });
}

//Byond can't have this tab anymore since we're removing it
function TakeTabFromByond(tab) {
  Byond.sendMessage("Remove-Tabs", { tab: tab });
}

function spell_cat_check(cat) {
  var spells_in_cat = 0;
  var spellcat = "";
  for (var s = 0; s < spells.length; s++) {
    var spell = spells[s];
    spellcat = spell[0];
    if (spellcat == cat) {
      spells_in_cat++;
    }
  }
  if (spells_in_cat < 1) {
    removeStatusTab(cat);
  }
}

function tab_change(tab) {
  if (tab == current_tab) return;
  if (document.getElementById(current_tab))
    document.getElementById(current_tab).className = "button"; // disable active on last button
  current_tab = tab;
  set_byond_tab(tab);
  if (document.getElementById(tab))
    document.getElementById(tab).className = "button active"; // make current button active
  var spell_tabs_thingy = spell_tabs.includes(tab);
  var verb_tabs_thingy = is_verb_tab(tab);
  statcontentdiv.className = "statcontent";
  if (tab == "Status") {
    draw_status();
  } else if (tab == "MC") {
    draw_mc();
  } else if (spell_tabs_thingy) {
    draw_spells(tab);
  } else if (verb_tabs_thingy) {
    draw_verbs(tab);
  } else if (tab == "Debug Stat Panel") {
    draw_debug();
  } else if (tab == "Tickets") {
    draw_tickets();
  } else if (tab == "SDQL2") {
    draw_sdql2();
  } else {
    statcontentdiv.textContext = "Loading...";
  }
  Byond.winset(Byond.windowId, {
    "is-visible": true,
  });
}

function set_byond_tab(tab) {
  Byond.sendMessage("Set-Tab", { tab: tab });
}

function draw_debug() {
  statcontentdiv.textContent = "";
  var wipeverbstabs = document.createElement("div");
  var link = document.createElement("a");
  link.onclick = function () {
    wipe_verbs();
  };
  link.textContent = "Wipe All Verbs";
  wipeverbstabs.appendChild(link);
  document.getElementById("statcontent").appendChild(wipeverbstabs);
  var wipeUpdateVerbsTabs = document.createElement("div");
  var updateLink = document.createElement("a");
  updateLink.onclick = function () {
    update_verbs();
  };
  updateLink.textContent = "Wipe and Update All Verbs";
  wipeUpdateVerbsTabs.appendChild(updateLink);
  document.getElementById("statcontent").appendChild(wipeUpdateVerbsTabs);
  var text = document.createElement("div");
  text.textContent = "Verb Tabs:";
  document.getElementById("statcontent").appendChild(text);
  var table1 = document.createElement("table");
  for (var i = 0; i < verb_tabs.length; i++) {
    var part = verb_tabs[i];
    // Hide subgroups except admin subgroups if they are split
    if (verb_tabs[i].lastIndexOf(".") != -1) {
      var splitName = verb_tabs[i].split(".");
      if (split_admin_tabs && splitName[0] === "Admin") part = splitName[1];
      else continue;
    }
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part;
    var a = document.createElement("a");
    a.onclick = (function (part) {
      return function () {
        removeStatusTab(part);
      };
    })(part);
    a.textContent = " Delete Tab " + part;
    td1.appendChild(a);
    tr.appendChild(td1);
    table1.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table1);
  var header2 = document.createElement("div");
  header2.textContent = "Verbs:";
  document.getElementById("statcontent").appendChild(header2);
  var table2 = document.createElement("table");
  for (var v = 0; v < verbs.length; v++) {
    var part2 = verbs[v];
    var trr = document.createElement("tr");
    var tdd1 = document.createElement("td");
    tdd1.textContent = part2[0];
    var tdd2 = document.createElement("td");
    tdd2.textContent = part2[1];
    trr.appendChild(tdd1);
    trr.appendChild(tdd2);
    table2.appendChild(trr);
  }
  document.getElementById("statcontent").appendChild(table2);
  var text3 = document.createElement("div");
  text3.textContent = "Permanent Tabs:";
  document.getElementById("statcontent").appendChild(text3);
  var table3 = document.createElement("table");
  for (var i = 0; i < permanent_tabs.length; i++) {
    var part3 = permanent_tabs[i];
    var trrr = document.createElement("tr");
    var tddd1 = document.createElement("td");
    tddd1.textContent = part3;
    trrr.appendChild(tddd1);
    table3.appendChild(trrr);
  }
  document.getElementById("statcontent").appendChild(table3);
}

var statusNodes = [];
var statusTable = null;
var lastStatusUpdateTime = 0;
var STATUS_UPDATE_INTERVAL = 1000;

function statusRowSignature(part) {
	if (!Array.isArray(part)) {
		return part.trim() == "" ? "break" : "text";
	}

	var partType = part[0] == null ? "" : String(part[0]).trim();
	if (partType == "") {
		return "break";
	}
	if (partType == "same_line") {
		return "same_line";
	}
	if (partType == "tod") {
		return "tod";
	}
	if (partType == "load") {
		return part[3] !== undefined ? "load_with_span" : "load";
	}
	return part[2] ? "default_link" : "default";
}

function createTextStatusRow() {
	var node = document.createElement("div");

	return {
		node: node,
		update: function (part) {
			node.textContent = part;
		},
	};
}

function createBreakStatusRow() {
	return {
		node: document.createElement("br"),
		update: function () {},
	};
}

function createTodStatusRow() {
	var node = document.createElement("div");
	var before = document.createTextNode("");
	var span = document.createElement("span");
	var after = document.createTextNode("");

	node.appendChild(before);
	node.appendChild(span);
	node.appendChild(after);

	return {
		node: node,
		update: function (part) {
			var todName = part[1] || "";
			var todWord = todName.charAt(0).toUpperCase() + todName.slice(1);
			var todText = part[2] || "";
			var todIdx = todText.indexOf(todWord);

			span.className = "tod-" + todName;
			if (todIdx === -1) {
				before.textContent = todText;
				span.textContent = "";
				after.textContent = "";
				return;
			}

			before.textContent = todText.slice(0, todIdx);
			span.textContent = todWord;
			after.textContent = todText.slice(todIdx + todWord.length);
		},
	};
}

function createLoadStatusRow(hasSpan) {
	var node = document.createElement("div");

	if (hasSpan) {
		var text = document.createTextNode("");
		var span = document.createElement("span");

		node.appendChild(text);
		node.appendChild(span);

		return {
			node: node,
			update: function (part) {
				text.textContent = part[2] || "";
				span.className = "load-" + part[1];
				span.textContent = part[3] || "";
			},
		};
	}

	return {
		node: node,
		update: function (part) {
			node.className = "load-" + part[1];
			node.textContent = part[2] || "";
		},
	};
}

function createSameLineStatusRow() {
	var node = document.createElement("div");
	var a = document.createElement("a");

	node.appendChild(a);

	return {
		node: node,
		update: function (part) {
			a.href = "byond://?" + part[2];
			a.textContent = part[1] || "";
		},
	};
}

function createDefaultStatusRow(hasLink) {
	var node = document.createElement("div");

	if (hasLink) {
		var text = document.createTextNode("");
		var a = document.createElement("a");

		node.appendChild(text);
		node.appendChild(a);

		return {
			node: node,
			update: function (part) {
				text.textContent = part[0] || "";
				a.href = "byond://?" + part[2];
				a.textContent = part[1] || "";
			},
		};
	}

	return {
		node: node,
		update: function (part) {
			node.textContent = part[0] || "";
		},
	};
}

function createStatusRow(part) {
	var signature = statusRowSignature(part);
	var row;

	if (signature == "text") {
		row = createTextStatusRow();
	} else if (signature == "break") {
		row = createBreakStatusRow();
	} else if (signature == "tod") {
		row = createTodStatusRow();
	} else if (signature == "load_with_span") {
		row = createLoadStatusRow(true);
	} else if (signature == "load") {
		row = createLoadStatusRow(false);
	} else if (signature == "same_line") {
		row = createSameLineStatusRow();
	} else {
		row = createDefaultStatusRow(signature == "default_link");
	}

	row.signature = signature;
	return row;
}

function needsStatusDomRebuild() {
	if (!statusTable || statusTable.parentNode !== statcontentdiv || statusNodes.length !== status_tab_parts.length) {
		return true;
	}

	for (var i = 0; i < status_tab_parts.length; i++) {
		if (statusNodes[i].signature != statusRowSignature(status_tab_parts[i])) {
			return true;
		}
	}

	return false;
}

function createStatusDom() {
	statusNodes = [];
	statusTable = document.createElement("table");

	for (var i = 0; i < status_tab_parts.length; i++) {
		var row = createStatusRow(status_tab_parts[i]);

		statusNodes.push(row);
		statusTable.appendChild(row.node);
	}

	statcontentdiv.textContent = "";
	statcontentdiv.appendChild(statusTable);
}

function updateStatusDom(force) {
	var now = Date.now();

	if (!force && now - lastStatusUpdateTime < STATUS_UPDATE_INTERVAL) {
		return;
	}

	lastStatusUpdateTime = now;
	for (var i = 0; i < status_tab_parts.length; i++) {
		statusNodes[i].update(status_tab_parts[i]);
	}
}

function draw_status() {
	if (!document.getElementById("Status")) {
		createStatusTab("Status");
		current_tab = "Status";
	}

	if (needsStatusDomRebuild()) {
		createStatusDom();
		updateStatusDom(true);
	} else {
		updateStatusDom(false);
	}

	if (verb_tabs.length == 0 || !verbs) {
		update_verbs()
	}
}

function draw_mc() {
  statcontentdiv.textContent = "";
  statcontentdiv.className = "mcstatcontent";
  var table = document.createElement("table");
  for (var i = 0; i < mc_tab_parts.length; i++) {
    var part = mc_tab_parts[i];
    var tr = document.createElement("tr");
    var td0 = document.createElement("td");
    td0.className = "monospace";
    td0.textContent = part[0];
    var td1 = document.createElement("td");
    td1.textContent = part[1];
    var td2 = document.createElement("td");
    if (part[3]) {
      var a = document.createElement("a");
      a.href =
        "byond://?_src_=vars;admin_token=" + href_token + ";Vars=" + part[3];
      a.textContent = part[2];
      td2.appendChild(a);
    } else {
      td2.textContent = part[2];
    }
    tr.appendChild(td0);
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function remove_tickets() {
  if (tickets) {
    tickets = [];
    removePermanentTab("Tickets");
    if (current_tab == "Tickets") tab_change("Status");
  }
  checkStatusTab();
}

function remove_sdql2() {
  if (sdql2) {
    sdql2 = [];
    removePermanentTab("SDQL2");
    if (current_tab == "SDQL2") tab_change("Status");
  }
  checkStatusTab();
}

function remove_mc() {
  removePermanentTab("MC");
  if (current_tab == "MC") {
    tab_change("Status");
  }
}

function draw_sdql2() {
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  for (var i = 0; i < sdql2.length; i++) {
    var part = sdql2[i];
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part[0];
    var td2 = document.createElement("td");
    if (part[2]) {
      var a = document.createElement("a");
      a.href = "byond://?src=" + part[2] + ";statpanel_item_click=left";
      a.textContent = part[1];
      td2.appendChild(a);
    } else {
      td2.textContent = part[1];
    }
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function draw_tickets() {
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  if (!tickets) {
    return;
  }
  for (var i = 0; i < tickets.length; i++) {
    var part = tickets[i];
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part[0];
    var td2 = document.createElement("td");
    if (part[2]) {
      var a = document.createElement("a");
      a.href =
        "byond://?_src_=holder;admin_token=" +
        href_token +
        ";ahelp=" +
        part[2] +
        ";ahelp_action=ticket;statpanel_item_click=left;action=ticket";
      a.textContent = part[1];
      td2.appendChild(a);
    } else if (part[3]) {
      var a = document.createElement("a");
      a.href = "byond://?src=" + part[3] + ";statpanel_item_click=left";
      a.textContent = part[1];
      td2.appendChild(a);
    } else {
      td2.textContent = part[1];
    }
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function draw_spells(cat) {
  statcontentdiv.textContent = "";
  var table = document.createElement("table");
  for (var i = 0; i < spells.length; i++) {
    var part = spells[i];
    if (part[0] != cat) continue;
    var tr = document.createElement("tr");
    var td1 = document.createElement("td");
    td1.textContent = part[1];
    var td2 = document.createElement("td");
    if (part[3]) {
      var a = document.createElement("a");
      a.href = "byond://?src=" + part[3] + ";statpanel_item_click=left";
      a.textContent = part[2];
      td2.appendChild(a);
    } else {
      td2.textContent = part[2];
    }
    tr.appendChild(td1);
    tr.appendChild(td2);
    table.appendChild(tr);
  }
  document.getElementById("statcontent").appendChild(table);
}

function make_verb_onclick(command) {
  return function () {
    run_after_focus(function () {
      Byond.command(command);
    });
  };
}

// MC/Tickets/SDQL2 get pushed into verb_tabs by their update handlers, but they
// have their own renderers — never draw them as a verb grid.
var NON_VERB_TABS = ["Status", "MC", "Tickets", "SDQL2", "Debug Stat Panel"];

function is_verb_tab(tab) {
  return verb_tabs.includes(tab) && !NON_VERB_TABS.includes(tab);
}

// Verb search: only real verb tabs get it
var verb_search = "";
var last_verb_cat = null;
var verb_search_input = null;
var verb_search_groups = []; // [{ header, container, items }]

function apply_verb_filter() {
  var query = verb_search.toLowerCase();
  for (var g = 0; g < verb_search_groups.length; g++) {
    var group = verb_search_groups[g];
    var visible = 0;
    for (var i = 0; i < group.items.length; i++) {
      var item = group.items[i];
      var match =
        !query ||
        item.getAttribute("data-label").toLowerCase().indexOf(query) != -1;
      item.style.display = match ? "" : "none";
      if (match) visible++;
    }
    // Hide a sub-category heading when nothing under it matches
    if (group.header) group.header.style.display = visible ? "" : "none";
    group.container.style.display = visible ? "" : "none";
  }
}

function create_verb_search() {
  var input = document.createElement("input");
  input.type = "text";
  input.className = "verb-search";
  input.placeholder = "Search verbs...";
  input.value = verb_search;
  input.setAttribute("spellcheck", "false");
  input.setAttribute("autocomplete", "off");
  var onchange = function () {
    if (verb_search === this.value) return;
    verb_search = this.value;
    apply_verb_filter();
  };
  input.oninput = onchange;
  input.onkeyup = onchange;
  return input;
}

// Verb lists arrive in bursts (login, species change, organ swap): redraw once per burst
var verb_redraw_pending = false;

function schedule_draw_verbs() {
  if (verb_redraw_pending) return;
  verb_redraw_pending = true;
  setTimeout(function () {
    verb_redraw_pending = false;
    if (is_verb_tab(current_tab)) draw_verbs(current_tab);
  }, 50);
}

function draw_verbs(cat) {
  // New tab -> fresh query
  if (cat !== last_verb_cat) {
    verb_search = "";
    last_verb_cat = cat;
  }
  // add_verb_list() can redraw mid-typing — keep focus and caret
  var was_focused =
    verb_search_input && document.activeElement === verb_search_input;
  var caret = was_focused ? verb_search_input.selectionStart : null;

  statcontentdiv.textContent = "";
  verb_search_groups = [];
  verb_search_input = create_verb_search();
  if (cat === EMOTE_TAB) {
    draw_emote_panel(cat);
  } else {
    statcontentdiv.appendChild(verb_search_input);
    draw_verb_grid(cat);
  }

  apply_verb_filter();

  if (was_focused) {
    verb_search_input.focus();
    if (caret !== null) verb_search_input.setSelectionRange(caret, caret);
  }
}

function draw_verb_grid(cat) {
  var table = document.createElement("div");
  var additions = {}; // additional sub-categories to be rendered
  table.className = "grid-container";
  var main_group = { header: null, container: table, items: [] };
  verb_search_groups.push(main_group);
  sortVerbs();
  if (split_admin_tabs && cat.lastIndexOf(".") != -1) {
    var splitName = cat.split(".");
    if (splitName[0] === "Admin") cat = splitName[1];
  }
  verbs.reverse(); // sort verbs backwards before we draw
  for (var i = 0; i < verbs.length; ++i) {
    var part = verbs[i];
    var name = part[0];
    if (split_admin_tabs && name.lastIndexOf(".") != -1) {
      var splitName = name.split(".");
      if (splitName[0] === "Admin") name = splitName[1];
    }
    var command = part[1];

    if (
      command &&
      name.lastIndexOf(cat, 0) != -1 &&
      (name.length == cat.length || name.charAt(cat.length) == ".")
    ) {
      var subCat = name.lastIndexOf(".") != -1 ? name.split(".")[1] : null;
      if (subCat && !additions[subCat]) {
        var newTable = document.createElement("div");
        newTable.className = "grid-container";
        newTable.search_items = [];
        additions[subCat] = newTable;
      }

      var a = document.createElement("a");
      a.href = "#";
      a.onclick = make_verb_onclick(command.replace(/\s/g, "-"));
      a.className = "grid-item";
      a.setAttribute("data-label", command);
      var t = document.createElement("span");
      t.textContent = command;
      t.className = "grid-item-text";
      a.appendChild(t);
      (subCat ? additions[subCat] : table).appendChild(a);
      (subCat ? additions[subCat].search_items : main_group.items).push(a);
    }
  }

  // Append base table to view
  var content = document.getElementById("statcontent");
  content.appendChild(table);

  // Append additional sub-categories if relevant
  for (var subcat in additions) {
    if (additions.hasOwnProperty(subcat)) {
      // do addition here
      var header = document.createElement("h3");
      header.textContent = subcat;
      content.appendChild(header);
      content.appendChild(additions[subcat]);
      verb_search_groups.push({
        header: header,
        container: additions[subcat],
        items: additions[subcat].search_items,
      });
    }
  }
}

// Emotes tab: All / Favourite pages, starred emotes and player-made custom emotes.
// Favourites and customs are stored in the player's prefs on the server.
var EMOTE_TAB = "Emotes";
var emote_page = "all";
var emote_favourites = [];
var emote_customs = []; // [{ id, name }]
// Emote groups drawn after the alphabetical ones, in this order
var EMOTE_TRAILING_GROUPS = ["Rolling"];
var STAR_SVG =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2.8l2.75 5.82 6.37.74-4.73 4.36 1.27 6.3L12 16.9l-5.66 3.12 1.27-6.3-4.73-4.36 6.37-.74z"/></svg>';
var EDIT_SVG =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 20h4L19 9l-4-4L4 16z M13.5 6.5l4 4"/></svg>';

function collect_tab_verbs(cat) {
  // [{ command, sub }] in display order, sub is null for verbs without a sub-category
  var result = [];
  sortVerbs();
  for (var i = verbs.length - 1; i >= 0; i--) {
    var name = verbs[i][0];
    var command = verbs[i][1];
    if (
      !command ||
      name.lastIndexOf(cat, 0) == -1 ||
      (name.length != cat.length && name.charAt(cat.length) != ".")
    )
      continue;
    result.push({
      command: command,
      sub: name.lastIndexOf(".") != -1 ? name.split(".")[1] : null,
    });
  }
  return result;
}

function create_emote_cell(label, on_run, side_button) {
  var cell = document.createElement("div");
  cell.className = "emote-cell";
  cell.setAttribute("data-label", label);
  var item = document.createElement("div");
  item.className = "emote-item";
  var run = document.createElement("a");
  run.href = "#";
  run.className = "emote-item-name";
  run.textContent = label;
  run.title = label;
  run.onclick = function (e) {
    if (e) e.preventDefault();
    on_run();
  };
  item.appendChild(run);
  item.appendChild(side_button);
  cell.appendChild(item);
  return cell;
}

function create_emote_side_button(class_name, svg, title, on_click) {
  var button = document.createElement("a");
  button.href = "#";
  button.className = "emote-item-side " + class_name;
  button.title = title;
  button.innerHTML = svg;
  button.onclick = function (e) {
    if (e) e.preventDefault();
    on_click(button);
  };
  return button;
}

function toggle_emote_favourite(command, star) {
  var index = emote_favourites.indexOf(command);
  if (index == -1) emote_favourites.push(command);
  else emote_favourites.splice(index, 1);
  // Optimistic, the server answers with emote_panel_data
  star.className = "emote-item-side emote-star" + (index == -1 ? " active" : "");
  Byond.sendMessage("Emote-Favourite", { name: command });
  if (emote_page === "favourite") draw_verbs(current_tab);
}

function add_emote_group(content, title, cells) {
  if (!cells.length) return;
  var header = null;
  if (title) {
    header = document.createElement("h3");
    header.textContent = title;
    content.appendChild(header);
  }
  var container = document.createElement("div");
  container.className = "emote-grid";
  for (var i = 0; i < cells.length; i++) container.appendChild(cells[i]);
  content.appendChild(container);
  verb_search_groups.push({ header: header, container: container, items: cells });
}

function create_emote_page_toggle(cat) {
  var toggle = document.createElement("div");
  toggle.className = "emote-page-toggle";
  var pages = [
    ["all", "All"],
    ["favourite", "Favourite"],
  ];
  for (var i = 0; i < pages.length; i++) {
    (function (page, label) {
      var button = document.createElement("div");
      button.className = "emote-page-btn" + (emote_page === page ? " active" : "");
      button.textContent = label;
      button.onclick = function () {
        if (emote_page === page) return;
        emote_page = page;
        draw_verbs(cat);
      };
      toggle.appendChild(button);
    })(pages[i][0], pages[i][1]);
  }
  return toggle;
}

function draw_emote_panel(cat) {
  var toolbar = document.createElement("div");
  toolbar.className = "emote-toolbar";
  toolbar.appendChild(verb_search_input);
  toolbar.appendChild(create_emote_page_toggle(cat));
  statcontentdiv.appendChild(toolbar);

  var favourite_page = emote_page === "favourite";
  if (favourite_page) {
    var add = document.createElement("div");
    add.className = "emote-custom-add";
    add.textContent = "+ Custom";
    add.title = "Add your own emote";
    add.onclick = function () {
      Byond.sendMessage("Emote-Custom-Add");
    };
    statcontentdiv.appendChild(add);

    var custom_cells = [];
    for (var c = 0; c < emote_customs.length; c++) {
      (function (custom) {
        custom_cells.push(
          create_emote_cell(
            custom.name,
            function () {
              run_after_focus(function () {
                Byond.sendMessage("Emote-Custom-Run", { id: custom.id });
              });
            },
            create_emote_side_button("emote-edit", EDIT_SVG, "Edit", function () {
              Byond.sendMessage("Emote-Custom-Edit", { id: custom.id });
            }),
          ),
        );
      })(emote_customs[c]);
    }
    add_emote_group(statcontentdiv, "Custom", custom_cells);
  }

  var tab_verbs = collect_tab_verbs(cat);
  var groups = {};
  var order = [];
  for (var i = 0; i < tab_verbs.length; i++) {
    var entry = tab_verbs[i];
    var is_favourite = emote_favourites.indexOf(entry.command) != -1;
    if (favourite_page && !is_favourite) continue;
    var key = entry.sub || "";
    if (!groups[key]) {
      groups[key] = [];
      order.push(key);
    }
    (function (command, favourite) {
      var star = create_emote_side_button(
        "emote-star" + (favourite ? " active" : ""),
        STAR_SVG,
        "Favourite",
        function (button) {
          toggle_emote_favourite(command, button);
        },
      );
      groups[key].push(
        create_emote_cell(command, make_verb_onclick(command.replace(/\s/g, "-")), star),
      );
    })(entry.command, is_favourite);
  }
  // Verbs without a sub-category go first, without a heading; trailing groups go last
  order.sort(function (a, b) {
    if (a === "") return -1;
    if (b === "") return 1;
    var a_last = EMOTE_TRAILING_GROUPS.indexOf(a);
    var b_last = EMOTE_TRAILING_GROUPS.indexOf(b);
    if (a_last != b_last) return a_last - b_last;
    return a < b ? -1 : a > b ? 1 : 0;
  });
  for (var g = 0; g < order.length; g++) {
    add_emote_group(statcontentdiv, order[g] || null, groups[order[g]]);
  }

  if (favourite_page && !emote_customs.length && !order.length) {
    var hint = document.createElement("div");
    hint.className = "emote-empty";
    hint.textContent = "Star an emote on the All page to keep it here.";
    statcontentdiv.appendChild(hint);
  }
}

function set_theme(which) {
  if (which == "light") {
    document.body.className = "";
    document.documentElement.className = "light";
  } else if (which == "dark") {
    document.body.className = "dark";
    document.documentElement.className = "dark";
  }
}

function set_font_size(size) {
  document.body.style.setProperty("font-size", size);
}

function set_tabs_style(style) {
  if (style == "default") {
    menu.classList.add("menu-wrap");
    menu.classList.remove("tabs-classic");
  } else if (style == "classic") {
    menu.classList.add("menu-wrap");
    menu.classList.add("tabs-classic");
  } else if (style == "scrollable") {
    menu.classList.remove("menu-wrap");
    menu.classList.remove("tabs-classic");
  }
}

function restoreFocus() {
  // Don't yank focus to the map while typing in the verb search
  if (document.activeElement && document.activeElement.tagName === "INPUT") {
    return;
  }
  run_after_focus(function () {
    Byond.winset("map", {
      focus: true,
    });
  });
}

function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(";");
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == " ") c = c.substring(1);
    if (c.indexOf(name) === 0) {
      return decoder(c.substring(name.length, c.length));
    }
  }
  return "";
}

function add_verb_list(payload) {
  var to_add = payload; // list of a list with category and verb inside it
  to_add.sort(); // sort what we're adding
  for (var i = 0; i < to_add.length; i++) {
    var part = to_add[i];
    if (!part[0]) continue;
    var category = part[0];
    if (category.indexOf(".") != -1) {
      var splitName = category.split(".");
      if (split_admin_tabs && splitName[0] === "Admin") category = splitName[1];
      else category = splitName[0];
    }
    if (findVerbindex(part[1], verbs) !== undefined) continue;
    if (verb_tabs.includes(category)) {
      verbs.push(part);
      if (current_tab == category && is_verb_tab(category)) {
        schedule_draw_verbs(); // redraw if we added a verb to the tab we're currently in
      }
    } else if (category) {
      verb_tabs.push(category);
      verbs.push(part);
      createStatusTab(category);
    }
  }
}

function init_spells() {
  var cat = "";
  for (var i = 0; i < spell_tabs.length; i++) {
    cat = spell_tabs[i];
    if (cat.length > 0) {
      verb_tabs.push(cat);
      createStatusTab(cat);
    }
  }
}

if (!current_tab) {
  addPermanentTab("Status");
  tab_change("Status");
}

Byond.subscribeTo("update_spells", function (payload) {
  spell_tabs = payload.spell_tabs;
  var do_update = false;
  if (spell_tabs.includes(current_tab)) {
    do_update = true;
  }
  init_spells();
  if (payload.actions) {
    spells = payload.actions;
    if (do_update) {
      draw_spells(current_tab);
    }
  } else {
    remove_spells();
  }
});

Byond.subscribeTo("remove_verb_list", function (v) {
  var to_remove = v;
  for (var i = 0; i < to_remove.length; i++) {
    remove_verb(to_remove[i]);
  }
  check_verbs();
  sortVerbs();
  if (is_verb_tab(current_tab)) schedule_draw_verbs();
});

// passes a 2D list of (verbcategory, verbname) creates tabs and adds verbs to respective list
// example (IC, Say)
Byond.subscribeTo("init_verbs", function (payload) {
  wipe_verbs(); // remove all verb categories so we can replace them
  checkStatusTab(); // remove all status tabs
  verb_tabs = payload.panel_tabs;
  verb_tabs.sort(); // sort it
  var do_update = false;
  var cat = "";
  for (var i = 0; i < verb_tabs.length; i++) {
    cat = verb_tabs[i];
    createStatusTab(cat); // create a category if the verb doesn't exist yet
  }
  if (is_verb_tab(current_tab)) {
    do_update = true;
  }
  if (payload.verblist) {
    add_verb_list(payload.verblist);
    sortVerbs(); // sort them
    if (do_update) {
      schedule_draw_verbs();
    }
  }
  SendTabsToByond();
});

Byond.subscribeTo("update_stat", function (payload) {
  status_tab_parts = [payload.ping_str];

  var parsed = payload.global_data;

  for (var i = 0; i < parsed.length; i++)
    if (parsed[i] != null) status_tab_parts.push(parsed[i]);

  parsed = payload.other_str;

  for (var i = 0; i < parsed.length; i++)
    if (parsed[i] != null) status_tab_parts.push(parsed[i]);

  if (current_tab == "Status") {
    draw_status();
  } else if (current_tab == "Debug Stat Panel") {
    draw_debug();
  }
});

Byond.subscribeTo("update_mc", function (payload) {
  mc_tab_parts = payload.mc_data;
  mc_tab_parts.splice(0, 0, ["", "Location:", payload.coord_entry]);

  if (!verb_tabs.includes("MC")) {
    verb_tabs.push("MC");
  }

  createStatusTab("MC");

  if (current_tab == "MC") {
    draw_mc();
  }
});

Byond.subscribeTo("remove_spells", function () {
  for (var s = 0; s < spell_tabs.length; s++) {
    removeStatusTab(spell_tabs[s]);
  }
});

Byond.subscribeTo("init_spells", function () {
  var cat = "";
  for (var i = 0; i < spell_tabs.length; i++) {
    cat = spell_tabs[i];
    if (cat.length > 0) {
      verb_tabs.push(cat);
      createStatusTab(cat);
    }
  }
});

Byond.subscribeTo("check_spells", function () {
  for (var v = 0; v < spell_tabs.length; v++) {
    spell_cat_check(spell_tabs[v]);
  }
});

Byond.subscribeTo("create_debug", function () {
  if (!document.getElementById("Debug Stat Panel")) {
    addPermanentTab("Debug Stat Panel");
  } else {
    removePermanentTab("Debug Stat Panel");
  }
});

Byond.subscribeTo("remove_admin_tabs", function () {
  href_token = null;
  remove_mc();
  remove_tickets();
  remove_sdql2();
});

Byond.subscribeTo("update_split_admin_tabs", function (status) {
  status = status == true;

  if (split_admin_tabs !== status) {
    if (split_admin_tabs === true) {
      removeStatusTab("Events");
      removeStatusTab("Fun");
      removeStatusTab("Game");
    }
    update_verbs();
  }
  split_admin_tabs = status;
});

Byond.subscribeTo("add_admin_tabs", function (ht) {
  href_token = ht;
  addPermanentTab("MC");
  addPermanentTab("Tickets");
});

Byond.subscribeTo("update_sdql2", function (S) {
  sdql2 = S;
  if (sdql2.length > 0 && !verb_tabs.includes("SDQL2")) {
    verb_tabs.push("SDQL2");
    addPermanentTab("SDQL2");
  }
  if (current_tab == "SDQL2") {
    draw_sdql2();
  }
});

Byond.subscribeTo("update_tickets", function (T) {
  tickets = T;
  if (!verb_tabs.includes("Tickets")) {
    verb_tabs.push("Tickets");
    addPermanentTab("Tickets");
  }
  if (current_tab == "Tickets") {
    draw_tickets();
  }
});

Byond.subscribeTo("build_topbar", buildTopButtons);

Byond.subscribeTo("unread_changelog", () => {
  const changelog = document.getElementById("changelog");
  if(changelog) {
    changelog.className = "top-item unread";
  }
})

Byond.subscribeTo("read_changelog", () => {
  const changelog = document.getElementById("changelog");
  if(changelog) {
    changelog.className = "top-item";
  }
})

Byond.subscribeTo("remove_sdql2", remove_sdql2);

Byond.subscribeTo("remove_mc", remove_mc);

Byond.subscribeTo("add_verb_list", add_verb_list);

Byond.subscribeTo("emote_panel_data", function (payload) {
  // The server echoes every star click back; skip the redraw when it matches what we show
  var favourites = payload.favourites || [];
  var customs = payload.customs || [];
  var changed =
    JSON.stringify(favourites) !== JSON.stringify(emote_favourites) ||
    JSON.stringify(customs) !== JSON.stringify(emote_customs);
  emote_favourites = favourites.slice();
  emote_customs = customs;
  if (changed && current_tab === EMOTE_TAB) schedule_draw_verbs();
});
