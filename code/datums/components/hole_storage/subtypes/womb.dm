/// One chamber past the vagina for eggs and embryos; it has no opening of its own.
/datum/component/body_storage/womb
	available_layers = list(
		STORAGE_LAYER_OUTER = FALSE,
		STORAGE_LAYER_INNER = FALSE,
		STORAGE_LAYER_DEEP = TRUE,
	)
	def_bulk_deep = 15

/// The womb is reached through the vagina, so anything worn that blocks the vagina blocks it too.
/datum/component/body_storage/womb/has_equipped_insertion_blocker()
	if(!owner)
		return FALSE
	for(var/obj/item/equipped_item as anything in owner.get_equipped_items())
		if(equipped_item.blocks_body_storage_slot(ORGAN_SLOT_VAGINA))
			return TRUE
	return FALSE
