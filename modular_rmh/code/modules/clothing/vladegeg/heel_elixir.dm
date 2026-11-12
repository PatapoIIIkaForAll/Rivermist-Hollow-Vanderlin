/obj/item/heel_elixir
	name = "heel elixir"
	desc = "Turns a pair of shoes into heeled shoes. Use it on the shoes."
	icon = 'icons/roguetown/items/glass_reagent_container.dmi'
	icon_state = "vial_bottlecork"
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 0.8
	sellprice = 20

/obj/item/heel_elixir/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use it on shoes to give them heels. One use, and it cannot be undone.")
	. += span_info("Heeled shoes lower Speed by 1 and can trip you when you run. The Heel Walker quirk removes both.")

/obj/item/heel_elixir/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/clothing/shoes))
		return NONE
	var/obj/item/clothing/shoes/target = interacting_with
	if(!target.set_heeled(TRUE))
		to_chat(user, span_warning("\The [target] already have heels."))
		return ITEM_INTERACT_BLOCKING
	target.name = "[target.name] (heeled)"
	user.visible_message(span_notice("[user] pours [src] over [target], and heels grow on them."), span_notice("I pour [src] over [target], and heels grow on them."))
	playsound(target, 'sound/foley/waterwash (1).ogg', 30, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/datum/loadout_item/heel_elixir
	name = "Heel Elixir"
	item_path = /obj/item/heel_elixir

/datum/supply_pack/luxury/heel_elixir
	name = "Heel Elixir"
	cost = 40
	contains = /obj/item/heel_elixir

/datum/repeatable_crafting_recipe/alchemy/heel_elixir
	name = "heel elixir"
	output = /obj/item/heel_elixir
	requirements = list(
		/obj/item/reagent_containers/glass/bottle = 1,
		/obj/item/alch/runedust = 1,
	)
	starting_atom = /obj/item/alch/runedust
	attacked_atom = /obj/item/reagent_containers/glass/bottle
	craft_time = 3 SECONDS
