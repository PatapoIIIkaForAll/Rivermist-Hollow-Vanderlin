/datum/action/cooldown/spell/status/seelie_dust
	name = "Seelie Dust"
	desc = "Douse a target in glittering dust that leaves them dazed and euphoric."
	button_icon_state = "createlight"
	cooldown_time = 150 SECONDS
	cast_range = 7
	charge_required = FALSE
	invocation_type = INVOCATION_NONE
	sound = 'sound/magic/churn.ogg'
	status_effect = /datum/status_effect/drugginess
	duration = 20 SECONDS
	has_visual_effects = FALSE

/datum/action/cooldown/spell/seelie_call_beast
	name = "Call Beast"
	desc = "Summon a rat to scamper to your aid."
	button_icon_state = "tamebeast"
	cooldown_time = 2 MINUTES
	cast_range = 7
	charge_required = FALSE
	invocation_type = INVOCATION_NONE
	sound = 'sound/magic/churn.ogg'
	has_visual_effects = FALSE

/datum/action/cooldown/spell/seelie_call_beast/is_valid_target(atom/cast_on)
	return isturf(cast_on) || isliving(cast_on)

/datum/action/cooldown/spell/seelie_call_beast/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = isturf(cast_on) ? cast_on : get_turf(cast_on)
	if(!target_turf)
		return

	if(prob(1))
		new /mob/living/simple_animal/hostile/retaliate/bigrat(target_turf)
	else
		new /obj/item/reagent_containers/food/snacks/smallrat(target_turf)

/datum/action/cooldown/spell/seelie_strip
	name = "Strip Clothes"
	desc = "Tug loose a random worn item."
	button_icon_state = "bcry"
	cooldown_time = 6 MINUTES
	cast_range = 1
	charge_required = FALSE
	invocation_type = INVOCATION_NONE
	sound = 'sound/magic/churn.ogg'
	has_visual_effects = FALSE

/datum/action/cooldown/spell/seelie_strip/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/seelie_strip/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on))
		return

	var/list/slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_SHOES, ITEM_SLOT_HEAD)
	var/chosen_slot = pick(slots)
	var/obj/item/choice = cast_on.get_item_by_slot(chosen_slot)
	if(choice && !istype(choice, /obj/item/clothing/head/helmet))
		cast_on.dropItemToGround(choice)
		to_chat(cast_on, span_warning("My clothes are yanked loose!"))

/datum/action/cooldown/spell/seelie_drain
	name = "Drain"
	desc = "Borrow stamina from a nearby target."
	button_icon_state = "bloodsteal"
	cooldown_time = 3 MINUTES
	cast_range = 1
	charge_required = FALSE
	invocation_type = INVOCATION_NONE
	sound = 'sound/magic/churn.ogg'
	spell_type = SPELL_STAMINA
	has_visual_effects = FALSE

/datum/action/cooldown/spell/seelie_drain/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/seelie_drain/cast(mob/living/cast_on)
	. = ..()
	if(!isliving(owner) || !istype(cast_on))
		return

	var/mob/living/target = cast_on
	var/mob/living/caster = owner
	var/drain_amount = 100
	var/gain_amount = 60

	if(target.stamina <= 0)
		to_chat(caster, span_warning("[target] is too exhausted to drain from!"))
		return

	if(caster.stamina >= caster.maximum_stamina - gain_amount)
		to_chat(caster, span_warning("I don't feel any more invigorated than I did..."))
		target.adjust_stamina(drain_amount)
		return

	target.adjust_stamina(drain_amount)
	caster.adjust_stamina(-gain_amount)
	to_chat(target, span_warning("I suddenly feel burdened and fatigued!"))
	to_chat(caster, span_notice("I reinvigorate myself with [target]'s energy!"))

/datum/action/cooldown/spell/seelie_replenish
	name = "Replenish Nature"
	desc = "Encourage a harvested herb patch to grow back."
	button_icon_state = "blesscrop"
	cooldown_time = 3 MINUTES
	cast_range = 1
	charge_required = FALSE
	invocation_type = INVOCATION_NONE
	sound = 'sound/magic/churn.ogg'
	has_visual_effects = FALSE

/datum/action/cooldown/spell/seelie_replenish/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/structure/flora/grass/herb)

/datum/action/cooldown/spell/seelie_replenish/cast(obj/structure/flora/grass/herb/cast_on)
	. = ..()
	if(!istype(cast_on))
		return

	if(!cast_on.harvested && length(cast_on.looty))
		to_chat(owner, span_warning("The herb patch is already thriving."))
		return

	cast_on.looty = list()
	cast_on.loot_replenish()
	to_chat(owner, span_notice("The herb patch swells with new growth."))

/datum/action/cooldown/spell/seelie_kiss
	name = "Fae Kiss"
	desc = "A gentle blessing that eases wounds and slows bleeding."
	button_icon_state = "bless"
	cooldown_time = 40 SECONDS
	cast_range = 1
	charge_required = FALSE
	invocation_type = INVOCATION_NONE
	sound = 'sound/magic/heal.ogg'
	has_visual_effects = FALSE

/datum/action/cooldown/spell/seelie_kiss/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/seelie_kiss/cast(mob/living/cast_on)
	. = ..()
	if(!istype(cast_on))
		return

	to_chat(cast_on, span_notice("A soft fae touch settles on my skin, easing my pain."))
	cast_on.visible_message(
		span_notice("[owner] gives [cast_on] a gentle, glowing kiss."),
		span_notice("I give [cast_on] a gentle, glowing kiss.")
	)
	cast_on.adjustBruteLoss(-8)
	cast_on.adjustFireLoss(-4)
	cast_on.bleed_rate = max(cast_on.bleed_rate - 2, 0)
	cast_on.suppress_bloodloss(50)
	addtimer(CALLBACK(cast_on, /mob/living/proc/adjustBruteLoss, -6), 5 SECONDS)
	addtimer(CALLBACK(cast_on, /mob/living/proc/adjustFireLoss, -2), 5 SECONDS)

/datum/action/cooldown/spell/projectile/water_bolt
	name = "Water Bolt"
	desc = "Launch a small bolt of water that splashes on impact, dousing flames and soaking targets."
	button_icon_state = "frostbolt"
	sound = 'sound/magic/churn.ogg'
	projectile_type = /obj/projectile/magic/waterbolt

	point_cost = 1
	charge_time = 1.5 SECONDS
	charge_drain = 1
	cooldown_time = 15 SECONDS
	spell_cost = 20
	spell_flags = SPELL_RITUOS

/datum/action/cooldown/spell/projectile/water_bolt/cast(atom/cast_on)
	. = ..()
	owner.visible_message(
		span_notice("[owner] flicks a splash of water toward [cast_on]!"),
		span_notice("I flick a splash of water toward [cast_on]!")
	)

/datum/action/cooldown/spell/projectile/water_bolt/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	to_fire.damage *= attuned_strength

/obj/projectile/magic/waterbolt
	name = "water bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "arcane_barrage"
	damage = 10
	damage_type = BRUTE
	range = 10
	speed = 1
	nodamage = FALSE

/obj/projectile/magic/waterbolt/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		var/datum/reagents/splash_reagents = new
		splash_reagents.add_reagent(/datum/reagent/water, 20)
		chem_splash(target_turf, 1, list(splash_reagents))
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.ExtinguishMob(TRUE)
	return .
