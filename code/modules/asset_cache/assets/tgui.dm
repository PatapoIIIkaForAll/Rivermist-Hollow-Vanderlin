#ifdef TGS
/datum/asset/simple/tgui
	keep_local_name = FALSE
	assets = list(
		"tgui.bundle.js" = "tgui/public/tgui.bundle.js",
		"tgui.bundle.css" = "tgui/public/tgui.bundle.css",
	)

/datum/asset/simple/tgui_panel
	keep_local_name = FALSE
	assets = list(
		"tgui-panel.bundle.js" = "tgui/public/tgui-panel.bundle.js",
		"tgui-panel.bundle.css" = "tgui/public/tgui-panel.bundle.css",
	)
#else
/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = file("tgui/public/tgui-panel.bundle.js"),
		"tgui-panel.bundle.css" = file("tgui/public/tgui-panel.bundle.css"),
	)
#endif

/datum/asset/group/tgui_window_shared
	children = list(
		/datum/asset/simple/namespaced/fontawesome,
		/datum/asset/simple/namespaced/tgfont,
		/datum/asset/simple/namespaced/fonts,
		/datum/asset/json/icon_ref_map,
	)

/datum/asset/group/tgui_preload
	children = list(
		/datum/asset/simple/tgui,
		/datum/asset/simple/tgui_panel,
		/datum/asset/group/tgui_window_shared,
	)
