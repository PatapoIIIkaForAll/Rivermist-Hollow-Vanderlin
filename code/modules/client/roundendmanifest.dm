/client/proc/view_rogue_manifest()
	var/dat
	dat += "<h1>Round ID: [GLOB.rogue_round_id]</h1>"
	dat += "<h4>- Inhabitants of [SSmapping.config.map_name] -</h4>"
	for(var/X in GLOB.character_list)
		dat += "[GLOB.character_list[X]]"

	src << browse(dat, "window=manifest;size=387x420;can_close=1")

/client/proc/view_actors_manifest()
	var/list/rows = list()
	for(var/mobid in GLOB.actors_list)
		var/list/actor = GLOB.actors_list[mobid]
		rows += "<tr><td>[actor["name"]]</td><td>[actor["species"]]</td><td>[actor["title"]]</td><td>[actor_status(actor["ckey"])]</td></tr>"

	var/dat = "<table class='actors'><tr><th>Name</th><th>Race</th><th>Occupation</th><th>Status</th></tr>"
	dat += length(rows) ? jointext(rows, "") : "<tr><td colspan='4' class='empty'>Nobody yet.</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(src, "actors", "<center>The people of [SSmapping.config.map_name]</center>", 560, 480)
	popup.set_head_content({"<style>
		table.actors {width: 100%; border-collapse: collapse;}
		table.actors th {text-align: left; border-bottom: 2px solid #8b7355; padding: 3px 6px;}
		table.actors td {border-bottom: 1px solid rgba(139, 115, 85, 0.35); padding: 3px 6px;}
		table.actors td.empty {text-align: center; font-style: italic;}
		.status-online {color: #6fbf73;}
		.status-afk {color: #d9b44a;}
		.status-offline {color: #9a9a9a;}
	</style>"})
	popup.set_content(dat)
	popup.open(FALSE)

/// Live connection label for an actor's ckey; never reveals whether the character is alive.
/proc/actor_status(ckey)
	var/client/player = GLOB.directory[ckey]
	if(!player)
		return "<span class='status-offline'>Disconnected</span>"
	if(player.manual_afk)
		return "<span class='status-afk'>Away</span>"
	var/idle = player.is_afk()
	if(idle)
		return "<span class='status-afk'>AFK ([round(idle / (1 MINUTES))]m)</span>"
	return "<span class='status-online'>Online</span>"
