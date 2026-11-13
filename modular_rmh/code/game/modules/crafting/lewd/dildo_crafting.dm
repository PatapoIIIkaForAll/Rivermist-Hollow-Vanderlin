// Whittled from a small log with a knife.
/datum/repeatable_crafting_recipe/crafting/wood_dildo
	name = "wooden dildo"
	requirements = list(
		/obj/item/grown/log/tree/small = 1
	)
	tool_usage = list(
		/obj/item/weapon/knife = list(span_notice("starts to whittle"), span_notice("start to whittle"), 'sound/items/wood_sharpen.ogg'),
	)
	starting_atom = /obj/item/weapon/knife
	attacked_atom = /obj/item/grown/log/tree/small
	allow_inverse_start = FALSE
	output = /obj/item/dildo/wood
	category = "Lewd"

/datum/anvil_recipe/iron_dildo
	name = "Dildo, Iron (x3)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/dildo/iron
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/steel_dildo
	name = "Dildo, Steel (x3)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/dildo/steel
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/silver_dildo
	name = "Dildo, Silver (x3)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/dildo/silver
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/gold_dildo
	name = "Dildo, Gold (x3)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/dildo/gold
	createditem_extra = 3
	i_type = "Lewd"

//plugs

// Whittled from a small log with a knife.
/datum/repeatable_crafting_recipe/crafting/wood_plug
	name = "wooden plug"
	output = /obj/item/dildo/plug/wood
	requirements = list(/obj/item/grown/log/tree/small = 1)
	tool_usage = list(
		/obj/item/weapon/knife = list(span_notice("starts to whittle"), span_notice("start to whittle"), 'sound/items/wood_sharpen.ogg'),
	)
	starting_atom = /obj/item/weapon/knife
	attacked_atom = /obj/item/grown/log/tree/small
	allow_inverse_start = FALSE
	category = "Lewd"

// Knife on stone, like the stone mortar; a chisel on stone already cuts blocks.
/datum/repeatable_crafting_recipe/crafting/stone_plug
	name = "stone plug"
	output = /obj/item/dildo/plug/stone
	requirements = list(/obj/item/natural/stone = 1)
	starting_atom = /obj/item/weapon/knife
	attacked_atom = /obj/item/natural/stone
	allow_inverse_start = FALSE
	category = "Lewd"

/datum/anvil_recipe/iron_plug
	name = "Iron plug 3x"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/dildo/plug/iron
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/copper_plug
	name = "Copper plug 3x"
	req_bar = /obj/item/ingot/copper
	created_item = /obj/item/dildo/plug/copper
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/steel_plug
	name = "Steel plug 3x"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/dildo/plug/steel
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/silver_plug
	name = "Silver plug 3x"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/dildo/plug/silver
	createditem_extra = 3
	i_type = "Lewd"

/datum/anvil_recipe/gold_plug
	name = "Golden plug 3x"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/dildo/plug/gold
	createditem_extra = 3
	i_type = "Lewd"

// Same bench as the glass beads: an iron mould and a pane of glass.
/datum/anvil_recipe/glass_plug
	name = "Glass plug"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/natural/glass)
	created_item = /obj/item/dildo/plug/glass
	i_type = "Lewd"

// Fur bound to a steel plug; fur on a wooden plug makes the tail plug instead.
/datum/repeatable_crafting_recipe/crafting/bunny_plug
	name = "bunny plug"
	output = /obj/item/dildo/plug/bunny
	requirements = list(/obj/item/dildo/plug/steel = 1, /obj/item/natural/fur = 1)
	starting_atom = /obj/item/natural/fur
	attacked_atom = /obj/item/dildo/plug/steel
	allow_inverse_start = FALSE
	category = "Lewd"
