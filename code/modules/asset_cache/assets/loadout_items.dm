/datum/asset/spritesheet/loadout_items
	name = "loadout_items"

/datum/asset/spritesheet/loadout_items/create_spritesheets()
	for(var/datum/loadout_item/item as anything in GLOB.loadout_items)
		var/obj/item/item_type = item.item_path
		if(!item_type)
			continue

		var/icon_file = initial(item_type.icon)
		var/icon_state = initial(item_type.icon_state)
		if(!icon_file || !icon_state)
			continue

		Insert("[sanitize_css_class_name("loadout_item_[REF(item)]")]", icon_file, icon_state)
