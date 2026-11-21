/obj/machinery/anvil
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "anvil"
	icon_state = "anvil"
	var/hott = 0
	var/obj/item/ingot/hingot
	max_integrity = 2000
	density = TRUE
	damage_deflection = 25
	climbable = TRUE
	var/previous_material_quality = 0
	var/cool_time = 30 SECONDS
	var/smithing = FALSE // Is a minigame currently active?
	var/obj/item/working_material // Reference to the material being worked
	var/always_perfect = FALSE // Debug/admin flag

/obj/machinery/anvil/crafted
	icon_state = "caveanvil"

/obj/machinery/anvil/examine(mob/user)
	. = ..()
	if(hingot)
		. += hingot.examine()
		if(hott)
			. += "<span class='warning'>[hingot] is too hot to touch.</span>"

/obj/machinery/anvil/attack_hand_secondary(mob/user, list/modifiers)
	if(hingot && !smithing)
		return hingot.attack_hand_secondary(user, modifiers)
	return ..()

/obj/machinery/anvil/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/weapon/tongs))
		var/obj/item/weapon/tongs/T = tool
		if(smithing)
			to_chat(user, "<span class='warning'>[src] is currently being worked on!</span>")
			return ITEM_INTERACT_BLOCKING
		if(hingot)
			if(T.held_item && istype(T.held_item, /obj/item/ingot))
				if(hingot.currecipe && hingot.currecipe.needed_item && istype(T.held_item, hingot.currecipe.needed_item))
					hingot.currecipe.item_added(user)
					qdel(T.held_item)
					T.set_held_item(null)
					update_appearance(UPDATE_OVERLAYS)
					return ITEM_INTERACT_SUCCESS
				return ITEM_INTERACT_BLOCKING
			else
				T.set_held_item(hingot)
				T.hott = hott
				hingot = null
				update_appearance(UPDATE_OVERLAYS)
				return ITEM_INTERACT_SUCCESS
		else
			if(T.held_item && istype(T.held_item, /obj/item/ingot))
				var/obj/item/repair_target
				for(var/obj/item/I in src.loc)
					if(I.anvilrepair && I.max_integrity)
						repair_target = I
						break

				if(repair_target && T.hott)
					var/obj/item/ingot/used_ingot = T.held_item

					var/skill_value = GET_MOB_SKILL_VALUE(user, repair_target.anvilrepair)
					if(skill_value <= 0)
						to_chat(user, span_warning("You don't know enough about this craft to restore [repair_target]."))
						return ITEM_INTERACT_BLOCKING

					var/expected_ingot_type
					if(repair_target.melting_material)
						var/datum/material/mat = GET_ATTRIBUTE_DATUM(repair_target.melting_material)
						expected_ingot_type = mat?.ingot_type
					else if(repair_target.smeltresult)
						if(istype(repair_target.smeltresult, /obj/item/ingot))
							expected_ingot_type = repair_target.smeltresult

					if(!expected_ingot_type || !istype(used_ingot, expected_ingot_type))
						to_chat(user, span_warning("This isn't the right material to restore [repair_target]."))
						return ITEM_INTERACT_BLOCKING

					var/restores_done = repair_target.integrity_restores
					var/base_restore = (skill_value / SKILL_MASTER) * 0.20
					var/diminish_factor = max(0.1, 1.0 - (restores_done * 0.30))
					var/restore_amount = round(repair_target.max_integrity * base_restore * diminish_factor)
					if(restore_amount <= 0)
						to_chat(user, span_warning("[repair_target] has been restored too many times. The metal no longer accepts new material."))
						return ITEM_INTERACT_BLOCKING

					var/restore_cap = repair_target.max_integrity * (0.15 * diminish_factor)
					restore_amount = min(restore_amount, restore_cap)
					repair_target.max_integrity += restore_amount
					repair_target.integrity_restores++

					qdel(T.held_item)
					T.set_held_item(null)
					update_appearance(UPDATE_OVERLAYS)

					var/datum/mind/smith_mind = user.mind
					var/amt2raise = floor(GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) * 0.25)
					smith_mind?.add_sleep_experience(repair_target.anvilrepair, amt2raise)

					playsound(src, 'sound/items/bsmith3.ogg', 100, FALSE)
					user.visible_message(span_info("[user] works new material into [repair_target], restoring some of its integrity."))
					if(restores_done >= 2)
						to_chat(user, span_warning("The metal is taking the new material less readily now. Further restorations will be less effective."))
					return ITEM_INTERACT_SUCCESS

				var/obj/item/ingot/placed_ingot = T.held_item
				T.set_held_item(null)
				placed_ingot.forceMove(src)
				hingot = placed_ingot
				hott = T.hott
				if(hott)
					START_PROCESSING(SSmachines, src)
				update_appearance(UPDATE_OVERLAYS)
				return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/ingot))
		if(!hingot)
			tool.forceMove(src)
			hingot = tool
			hott = 0
			update_appearance(UPDATE_OVERLAYS)
			return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/weapon/hammer))
		var/obj/item/weapon/hammer/hammer = tool
		user.changeNext_move(CLICK_CD_MELEE)
		if(!hingot)
			return NONE
		if(!hott)
			to_chat(user, "<span class='warning'>The bar has gone too cold to continue working on it.</span>")
			return ITEM_INTERACT_BLOCKING
		if(smithing)
			to_chat(user, "<span class='warning'>Already working on this!</span>")
			return ITEM_INTERACT_BLOCKING
		if(!hingot.currecipe)
			if(!choose_recipe(user))
				return ITEM_INTERACT_BLOCKING
		if(has_world_trait(/datum/world_trait/delver))
			if(!has_recipe_unlocked(user.key, hingot.currecipe.type))
				return ITEM_INTERACT_BLOCKING

		start_minigame(user, hammer)
		return ITEM_INTERACT_SUCCESS

	if(hingot && hingot.currecipe && hingot.currecipe.needed_item && istype(tool, hingot.currecipe.needed_item))
		hingot.currecipe.item_added(user)
		if(istype(tool, /obj/item/ingot))
			var/obj/item/ingot/I = tool
			hingot.currecipe.material_quality += I.recipe_quality
			previous_material_quality = I.recipe_quality
		else
			hingot.currecipe.material_quality += previous_material_quality
		hingot.currecipe.num_of_materials += 1
		qdel(tool)
		return ITEM_INTERACT_SUCCESS

	if(tool.anvilrepair && !user.cmode)
		user.visible_message("<span class='info'>[user] places \a [tool] on the anvil.</span>")
		tool.forceMove(loc)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/anvil/proc/start_minigame(mob/living/user, obj/item/weapon/hammer/hammer)
	if(!hingot || !hingot.currecipe)
		return

	smithing = TRUE
	working_material = hingot

	var/difficulty_modifier = hingot.currecipe.craftdiff

	var/datum/anvil_challenge/challenge = new(src, hingot.currecipe, user, difficulty_modifier)
	if(!challenge)
		smithing = FALSE
		working_material = null
		return


/obj/machinery/anvil/proc/process_minigame_result(quality_score, mob/living/user, total_fail)
	if(!hingot || !hingot.currecipe)
		return

	var/datum/anvil_recipe/recipe = hingot.currecipe
	var/breakthrough = quality_score >= 80
	if(total_fail)
		quality_score = 0
	var/success = recipe.advance(user, breakthrough, quality_score)

	if(!success)
		shake_camera(user, 1, 1)
		playsound(src, 'sound/items/bsmithfail.ogg', 100, FALSE)

	if(success)
		var/skill_boost = 0
		if(quality_score >= 80)
			skill_boost = quality_score * 2
			recipe.numberofbreakthroughs++
		else if(quality_score >= 60)
			skill_boost = quality_score * 1.5
		else if(quality_score >= 40)
			skill_boost = quality_score
		else if(quality_score >= 20)
			skill_boost = quality_score * 0.5

		recipe.skill_quality += skill_boost

	if(recipe.progress >= 100 && !length(recipe.additional_items) && !recipe.needed_item)
		complete_recipe(user, quality_score)

	working_material = null

/obj/machinery/anvil/proc/complete_recipe(mob/living/user, quality_score)
	if(!hingot || !hingot.currecipe)
		return

	var/datum/anvil_recipe/recipe = hingot.currecipe
	var/obj/item/I = new recipe.created_item(loc)

	I.OnCrafted(user.dir, user)

	var/skill_level = 0
	if(user)
		skill_level = GET_MOB_SKILL_VALUE_OLD(user, recipe.appro_skill)

	recipe.handle_creation(I, quality_score, skill_level)
	SEND_SIGNAL(user, COMSIG_ITEM_FORGED)

	record_featured_stat(FEATURED_STATS_SMITHS, user)
	record_featured_object_stat(FEATURED_STATS_FORGED_ITEMS, I.name)

	for(var/i in 1 to recipe.createditem_extra)
		var/obj/item/extra = new recipe.created_item(loc)
		extra.OnCrafted(user.dir, user)
		recipe.handle_creation(extra, quality_score, skill_level)

	user?.visible_message(span_info("[user] finishes crafting [I]!"))

	qdel(hingot)
	hingot = null
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/anvil/proc/choose_recipe(mob/living/user)
	if(!hingot || !hott)
		return

	var/list/valid_types = list()
	for(var/datum/anvil_recipe/R as anything in GLOB.anvil_recipes)
		if(IS_ABSTRACT(R))
			continue

		if(has_world_trait(/datum/world_trait/delver))
			if(!has_recipe_unlocked(user.key, R))
				continue

		if(istype(hingot, R.req_bar))
			if(!(R.i_type in valid_types))
				valid_types += R.i_type

	if(!length(valid_types))
		return

	var/i_type_choice
	if(length(valid_types) == 1)
		i_type_choice = valid_types[1]
	else
		i_type_choice = browser_input_list(user, "Choose a category", "Anvil", valid_types)
	if(!i_type_choice)
		return

	var/list/appro_recipe = list()
	for(var/datum/anvil_recipe/R as anything in GLOB.anvil_recipes)
		if(!IS_ABSTRACT(R))
			if(R.i_type == i_type_choice && istype(hingot, R::req_bar) && !isnull(R.name))
				appro_recipe[R.name] = R

	for(var/r_name in appro_recipe)
		var/datum/anvil_recipe/R = appro_recipe[r_name]
		if(!R::req_bar)
			appro_recipe -= r_name
		if(!istype(hingot, R::req_bar))
			appro_recipe -= r_name

	if(length(appro_recipe))
		var/chosen_recipe_name = browser_input_list(user, "Choose what to start working on:", "Anvil", sortList(appro_recipe.Copy()), null)
		if(!chosen_recipe_name)
			return FALSE
		var/datum/chosen_recipe = appro_recipe[chosen_recipe_name]
		if(!hingot.currecipe && chosen_recipe)
			hingot.currecipe = new chosen_recipe.type(hingot)
			hingot.currecipe.material_quality += hingot.recipe_quality
			previous_material_quality = hingot.recipe_quality
			return TRUE

	return FALSE

/obj/machinery/anvil/attack_hand(mob/living/user, list/modifiers)
	if(smithing)
		to_chat(user, span_warning("[src] is currently being worked on!"))
		return TRUE
	if(hingot)
		// The ingot cannot see the anvil's heat, so this guard has to stay here.
		if(hott)
			to_chat(user, span_warning("It's too hot to handle with your hands."))
			return TRUE
		// Clear our reference and move it out before handing off, or the anvil keeps a phantom ingot.
		var/obj/item/ingot/taken = hingot
		hingot = null
		taken.forceMove(user.loc)
		. = taken.attack_hand(user, modifiers)
		update_appearance(UPDATE_OVERLAYS)
		return .
	return ..()

/obj/machinery/anvil/process()
	if(hott)
		if(world.time > hott + cool_time)
			hott = 0
			STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSmachines, src)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/anvil/update_overlays()
	. = ..()
	if(!hingot)
		return
	var/obj/item/I = hingot
	I.pixel_x = I.base_pixel_x
	I.pixel_y = I.base_pixel_y
	var/mutable_appearance/M = new /mutable_appearance(I)
	if(hott)
		M.filters += filter(type="color", color = list(3,0,0,1, 0,2.7,0,0.4, 0,0,1,0, 0,0,0,1))
	M.transform *= 0.5
	M.pixel_y = 5
	M.pixel_x = 3
	. += M
