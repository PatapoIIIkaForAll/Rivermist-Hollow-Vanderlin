/datum/action/cooldown/spell/healing
	name = "Lesser Miracle"
	desc = "Call upon your patron to heal the wounds of yourself or others."
	button_icon_state = "lesserheal"
	sound = 'sound/magic/heal.ogg'
	charge_sound = 'sound/magic/holycharging.ogg'

	cast_range = 6
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/attribute/skill/magic/holy

	charge_required = FALSE
	cooldown_time = 10 SECONDS
	spell_cost = 10

	/// Base healing before adjustments
	var/base_healing = 25
	/// Wound healing modifier
	var/wound_modifier = 0.25
	/// Blood healing amount
	var/blood_restoration = 0
	/// Stuns undead
	var/stun_undead = FALSE
	/// Unholy, profane healing
	var/is_profane = FALSE
	/// Some prayers reject targets outside their aligned faith.
	var/patron_restrictive = FALSE

/datum/action/cooldown/spell/healing/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return isliving(cast_on)

/datum/action/cooldown/spell/healing/cast(mob/living/cast_on)
	. = ..()
	if(is_profane && patron_restrictive && !(cast_on.patron in ALL_PROFANE_PATRONS))
		cast_on.visible_message(
			span_warning("The Inhumen Four sear the flesh of [cast_on]! a non-believer and weakling!"),
			span_notice("The Inhumen Four lash out at me with a wave of pain!"),
		)
		cast_on.emote("scream")
		return

	var/datum/component/vampire_disguise/vampire_disguise = cast_on.GetComponent(/datum/component/vampire_disguise)
	if(!is_profane)
		if(HAS_TRAIT(cast_on, TRAIT_ASTRATA_CURSE))
			cast_on.visible_message(span_danger("[cast_on] recoils in pain!"), span_userdanger("Divine healing shuns me!"))
			cast_on.cursed_freak_out()
			return
		if(cast_on.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			if(!(cast_on.mind?.has_antag_datum(/datum/antagonist/vampire) && vampire_disguise?.disguised)) //vampire disguises are handled later
				if(cast_on.mind?.has_antag_datum(/datum/antagonist/vampire/lord))
					cast_on.visible_message(span_warning("[cast_on] overpowers being burned!"), span_greentext("I overpower being burned!"))
					return
				cast_on.visible_message(span_danger("[cast_on] is burned by holy light!"), span_userdanger("I'm burned by holy light!"))
				if(stun_undead)
					cast_on.Paralyze(5 SECONDS)
				cast_on.adjustFireLoss(base_healing)
				cast_on.adjust_divine_fire_stacks(1)
				cast_on.IgniteMob()
				return
		if(((cast_on.real_name in GLOB.excommunicated_players) || (cast_on.real_name in GLOB.heretical_players)) && !HAS_TRAIT(cast_on, TRAIT_FANATICAL))
			cast_on.visible_message(
				span_warning("The angry Ten sear the flesh of [cast_on]! a foolish blasphemer and heretic!"),
				span_notice("I am despised by the gods, rejected, and they remind me just how unlovable I am with a wave of pain!"),
			)
			cast_on.emote("scream")
			return

	var/conditional_buff = FALSE
	var/situational_bonus = 10
	var/situational_blood = 0
	//this if chain is stupid, replace with variables on /datum/patron when possible?
	if(isliving(owner))
		var/mob/living/living_owner = owner
		switch(living_owner.patron?.type)
			if(/datum/patron/psydon, /datum/patron/psydon/extremist)
				cast_on.visible_message(span_info("A strange stirring feeling pours from [cast_on]!"), span_notice("Sentimental thoughts drive away my pains!"))

			if(/datum/patron/divine/astrata)
				cast_on.visible_message(span_info("A wreath of gentle light passes over [cast_on]!"), span_notice("I'm bathed in holy light!"))
				// during the day, heal 10 more (basic as fuck)
				if(GLOB.tod == "day")
					conditional_buff = TRUE

			if(/datum/patron/divine/noc)
				cast_on.visible_message(span_info("A shroud of soft moonlight falls upon [cast_on]!"), span_notice("I'm shrouded in gentle moonlight!"))
				// during the night, heal 10 more (i wish this was more interesting but they're twins so whatever)
				if(GLOB.tod == "night")
					conditional_buff = TRUE

			if(/datum/patron/divine/dendor)
				cast_on.visible_message(span_info("A rush of primal energy spirals about [cast_on]!"), span_notice("I'm infused with primal energies!"))
				var/static/list/natural_stuff = typecacheof(list(/obj/structure/flora/grass, /obj/structure/chair/bench/ancientlog, /obj/structure/flora))
				situational_bonus = 0
				// the more natural stuff around US, the more we heal
				for(var/obj/O in oview(5, owner))
					if(is_type_in_typecache(O, natural_stuff))
						situational_bonus = min(situational_bonus + 0.5, 25)
				if(situational_bonus > 0)
					conditional_buff = TRUE

			if(/datum/patron/divine/abyssor)
				cast_on.visible_message(span_info("A mist of salt-scented vapour settles on [cast_on]!"), span_notice("I'm invigorated by healing vapours!"))
				// if our owner or cast_on is standing in water, heal a flat amount extra
				if(istype(get_turf(cast_on), /turf/open/water) || istype(get_turf(owner), /turf/open/water))
					conditional_buff = TRUE
					situational_bonus = 15
				situational_blood += BLOOD_VOLUME_SURVIVE/2

			if(/datum/patron/divine/ravox)
				cast_on.visible_message(span_info("An air of righteous defiance rises near [cast_on]!"), span_notice("I'm filled with an urge to fight on!"))
				situational_bonus = 0
				// the bloodier the area around our cast_on is, the more we heal
				for(var/obj/effect/decal/cleanable/blood/O in oview(5, cast_on))
					situational_bonus = min(situational_bonus + 1, 25)
				conditional_buff = TRUE

			if(/datum/patron/divine/necra)
				cast_on.visible_message(span_info("A sense of quiet respite radiates from [cast_on]!"), span_notice("I feel the Undermaiden's gaze turn from me for now!"))
				if(iscarbon(cast_on))
					var/mob/living/carbon/C = cast_on
					// if the cast_on is "close to death" (at or below 25% health)
					if(C.health <= (C.maxHealth * 0.25))
						conditional_buff = TRUE
						situational_bonus = 25

			if(/datum/patron/divine/xylix)
				cast_on.visible_message(span_info("A fugue seems to manifest briefly across [cast_on]!"), span_notice("My wounds vanish as if they had never been there! "))
				// half of the time, heal a little (or a lot) more - flip the coin
				if(prob(50))
					conditional_buff = TRUE
					situational_bonus = rand(1, 25)
			if(/datum/patron/divine/pestra)
				cast_on.visible_message(span_info("An aura of clinical care encompasses [cast_on]!"), span_notice("I'm sewn back together by sacred medicine!"))
				// pestra always heals a little more toxin damage and restores a bit more blood
				cast_on.adjustToxLoss(-situational_bonus)
				situational_blood += BLOOD_VOLUME_SURVIVE/2

			if(/datum/patron/divine/malum)
				cast_on.visible_message(span_info("A tempering heat is discharged out of [cast_on]!"), span_notice("I feel the heat of a forge soothing my pains!"))
				situational_bonus = 0
				for(var/obj/machinery/light/fueled/O in oview(5, owner))
					if(!O.on)
						continue
					situational_bonus = min(situational_bonus + 3, 25)
				if(situational_bonus > 0)
					conditional_buff = TRUE

			if(/datum/patron/divine/eora)
				cast_on.visible_message(span_info("An eminence of love blossoms around [cast_on]!"), span_notice("I'm filled with the restorative warmth of love!"))
				// if they're wearing an eoran bud (or are a pacifist), pretty much double the healing.
				situational_bonus = 0
				if (HAS_TRAIT(cast_on, TRAIT_PACIFISM))
					conditional_buff = TRUE
					situational_bonus = 25

			if(/datum/patron/inhumen/zizo)
				cast_on.visible_message(span_info("Vital energies are sapped towards [cast_on]!"), span_notice("The life around me pales as I am restored!"))
				// set up a ritual pile of bones (or just cast near a stack of bones whatever) around us for massive bonuses, cap at 50 for 75 healing total (wowie)
				situational_bonus = 0
				for(var/obj/item/alch/bone/O in oview(5, owner))
					situational_bonus = min(situational_bonus + 5, 50)
				if(situational_bonus > 0)
					conditional_buff = TRUE

			if(/datum/patron/inhumen/graggar)
				cast_on.visible_message(span_info("Foul fumes billow outward as [cast_on] is restored!"), span_notice("A noxious scent burns my nostrils, but I feel better!"))
				// if you've got lingering toxin damage, you get healed more, but your bonus healing doesn't affect toxin
				var/toxloss = cast_on.getToxLoss()
				if(toxloss >= 10)
					conditional_buff = TRUE
					situational_bonus = 25
					cast_on.adjustToxLoss(situational_bonus) // remember we do a global toxloss adjust down below so this is okay

			if(/datum/patron/inhumen/matthios)
				cast_on.visible_message(span_info("A shadowed hand passes [cast_on] a small, stolen vial... its contents glimmer faintly before sinking into their veins..."), span_notice("A quick swig and the ache fades..."))
				// COMRADES! WE MUST BAND TOGETHER! Or Outlaw.
				if(HAS_TRAIT(cast_on, TRAIT_BANDITCAMP) || (cast_on.real_name in GLOB.outlawed_players))
					conditional_buff = TRUE
					situational_bonus = 25

			if(/datum/patron/inhumen/baotha)
				cast_on.visible_message(span_info("A sweet, dizzying haze swirls around [cast_on], their eyes glimmering with bliss..."), span_notice("Mmm... the world softens... and I melt into it..."))
				//If the owner or cast_on are on drugs, they get a heal bonus.
				var/static/list/drugs_buffs = list(
					/datum/status_effect/buff/druqks,
					/datum/status_effect/buff/ozium,
					/datum/status_effect/buff/moondust,
					/datum/status_effect/buff/weed,
					/datum/status_effect/buff/moondust_purest,
				)

				for(var/datum/status_effect/path as anything in drugs_buffs)
					if(living_owner.has_status_effect(path) || cast_on.has_status_effect(path))
						conditional_buff = TRUE
						situational_bonus = 25
						break

			else
				if(istype(living_owner.patron, /datum/patron/godless))
					cast_on.visible_message(span_info("No Gods answer these prayers."), span_notice("No Gods answer these prayers."))
					return
				cast_on.visible_message(span_info("A choral sound comes from above and [cast_on] is healed!"), span_notice("I am bathed in healing choral hymns!"))
	var/amount_healed = base_healing

	if(conditional_buff)
		to_chat(owner, span_greentext("Channeling my patron's power is easier in these conditions!"))
		amount_healed += situational_bonus

	if(vampire_disguise?.disguised) //vamps can pretend to be normal for a little bit
		var/vitae_loss = amount_healed * (cast_on.mind?.has_antag_datum(/datum/antagonist/vampire/lord) ? 0.3 : 0.6)
		cast_on.adjust_bloodpool(-vitae_loss)
		if(cast_on.bloodpool)
			to_chat(cast_on, span_danger("My disguise holds at the cost of [round(vitae_loss)] vitae!"))
		else
			vampire_disguise.force_undisguise(cast_on)
		return

	SEND_SIGNAL(owner, COMSIG_LIVING_HEALED_OTHER, amount_healed)
	cast_on.adjustToxLoss(-amount_healed)
	cast_on.adjustOxyLoss(-amount_healed)
	cast_on.adjust_bloodvolume(blood_restoration + situational_blood, BLOOD_VOLUME_NORMAL)
	var/mob/living/healing_owner = owner
	cast_on.defeat_try_prepared_recovery(healing_owner, "healing miracle", src)
	if(!iscarbon(cast_on))
		cast_on.adjustBruteLoss(-amount_healed)
		cast_on.adjustFireLoss(-amount_healed)
		return

	var/mob/living/carbon/C = cast_on
	// Organ damage to the brain (a beaten dullahan head, poisons) mends with the rest.
	C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -amount_healed)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(owner.zone_selected))
	if(affecting)
		affecting.heal_damage(amount_healed, amount_healed)
		affecting.heal_wounds(amount_healed * wound_modifier)
		for(var/datum/injury/injury as anything in affecting.injuries)
			if(injury.damage_type == WOUND_DIVINE)
				continue
			injury.heal_damage(amount_healed)
		C.update_damage_overlays()

	for(var/obj/item/organ/possible_organ as anything in affecting.getorganlist(/obj/item/organ))
		if(ORGAN_SLOT_ARTERY in possible_organ.organ_efficiency)
			possible_organ.applyOrganDamage(-amount_healed * wound_modifier)
			continue
		if(possible_organ.scarred_below(40))
			continue
		if(possible_organ.organ_flags & ORGAN_DESTROYED)
			possible_organ.organ_flags &= ~ORGAN_DESTROYED //I am having pity on people here at this point I won't force you to get new organs unless they fully necrose.
			possible_organ.scar_organ(20, 40)
		if(possible_organ.damage > possible_organ.medium_threshold)
			possible_organ.applyOrganDamage(-amount_healed * wound_modifier)

/datum/action/cooldown/spell/healing/profane
	name = "Corrupt Lesser Miracle"
	antimagic_flags = MAGIC_RESISTANCE_UNHOLY
	required_items = null
	is_profane = TRUE

/datum/action/cooldown/spell/healing/greater
	name = "Miracle"
	button_icon_state = "astrata"

	charge_required = TRUE
	charge_time = 1 SECONDS
	cooldown_time = 20 SECONDS
	spell_cost = 45

	base_healing = 50
	wound_modifier = 0.5
	blood_restoration = BLOOD_VOLUME_SURVIVE
	stun_undead = TRUE
	patron_restrictive = TRUE

/datum/action/cooldown/spell/healing/greater/profane
	name = "Corrupt Miracle"
	antimagic_flags = MAGIC_RESISTANCE_UNHOLY
	required_items = null
	stun_undead = FALSE
	is_profane = TRUE

/datum/action/cooldown/spell/defeat_absolution
	name = "Bear Their Burden"
	desc = "Spend devotion to lift one ordinary defeat trauma from another person beside you. Light, moderate and severe trauma cost you 10, 20 or 30 bodily damage and two minutes of Sacrificial Exhaustion. Does not cure Convalescence, heal wounds or wake the defeated."
	button_icon_state = "lesserheal"
	sound = 'sound/magic/heal.ogg'
	charge_sound = 'sound/magic/holycharging.ogg'
	cast_range = 1
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/attribute/skill/magic/holy
	// The treatment channels after diagnosis, so cancelling the choice never spends anything.
	charge_required = FALSE
	cooldown_time = 2 MINUTES
	spell_cost = 100
	self_cast_possible = FALSE
	var/datum/weakref/selected_trauma_ref
	var/treating = FALSE

/datum/action/cooldown/spell/defeat_absolution/Destroy()
	selected_trauma_ref = null
	return ..()

/datum/action/cooldown/spell/defeat_absolution/check_cost(cost_override, feedback = TRUE)
	// Miracle affordability is disabled in the shared spell code. Enforce this spell's own price.
	var/mob/living/carbon/human/caster = owner
	if(!istype(caster) || !caster.cleric?.check_devotion(get_adjusted_cost(cost_override)))
		if(feedback)
			to_chat(owner, span_warning("I need enough devotion to bear another's burden."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/defeat_absolution/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/caster = owner
	if(caster.has_status_effect(/datum/status_effect/sacrificial_exhaustion))
		if(feedback)
			to_chat(caster, span_warning("I must recover from my last sacrifice first."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/defeat_absolution/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on) || cast_on == owner || !owner?.Adjacent(cast_on))
		return FALSE
	var/mob/living/patient = cast_on
	if(patient.stat == DEAD)
		return FALSE
	for(var/datum/status_effect/debuff/defeat/trauma in patient.status_effects)
		if(DEFEAT_TRAUMA_PROVIDER_UNIVERSAL in trauma.accepted_provider_tags)
			return TRUE
	return FALSE

/datum/action/cooldown/spell/defeat_absolution/before_cast(atom/cast_on)
	. = ..()
	if((. & SPELL_CANCEL_CAST) || treating || !is_valid_target(cast_on))
		return . | SPELL_CANCEL_CAST
	treating = TRUE
	selected_trauma_ref = null
	var/mob/living/caster = owner
	var/mob/living/patient = cast_on
	var/datum/defeat_trauma_provider/universal/provider = new
	provider.requires_adjacent = TRUE
	var/list/choices = list()
	for(var/datum/status_effect/debuff/defeat/condition as anything in provider.diagnose(patient))
		choices["[condition.trauma_label] ([defeat_severity_label(condition.severity)])"] = condition
	var/choice = input(caster, "Choose the trauma to bear.", name) as null|anything in choices
	var/datum/status_effect/debuff/defeat/trauma = choices[choice]
	if(!QDELETED(src) && owner == caster && provider.validate(patient, caster, trauma) && can_cast_spell(TRUE))
		var/damage_cost = defeat_severity_rank(trauma.severity) * DEFEAT_BURDEN_DAMAGE_PER_SEVERITY
		var/confirmation = alert(caster, "Lift [patient]'s [trauma.trauma_label] in six seconds? Success costs [get_adjusted_cost()] devotion, [damage_cost] bodily damage and two minutes of Sacrificial Exhaustion.", name, "Bear the burden", "Cancel")
		if(confirmation == "Bear the burden" && !QDELETED(src) && owner == caster && provider.validate(patient, caster, trauma) && can_cast_spell(TRUE))
			if(do_after(caster, 6 SECONDS, target = patient, extra_checks = CALLBACK(provider, TYPE_PROC_REF(/datum/defeat_trauma_provider, validate), patient, caster, trauma)))
				if(!QDELETED(src) && owner == caster && provider.validate(patient, caster, trauma) && can_cast_spell(TRUE))
					selected_trauma_ref = WEAKREF(trauma)
	qdel(provider)
	treating = FALSE
	if(!selected_trauma_ref)
		return . | SPELL_CANCEL_CAST
	// The base cast chain ignores cast()'s return value. Commit costs only after the cure succeeds.
	return . | SPELL_NO_IMMEDIATE_COST | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/defeat_absolution/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/caster = owner
	var/datum/status_effect/debuff/defeat/trauma = selected_trauma_ref?.resolve()
	selected_trauma_ref = null
	if(QDELETED(trauma) || trauma.owner != cast_on || !is_valid_target(cast_on) || !can_cast_spell(TRUE))
		return FALSE
	var/damage_cost = defeat_severity_rank(trauma.severity) * DEFEAT_BURDEN_DAMAGE_PER_SEVERITY
	if(!cast_on.defeat_treat_trauma(caster, DEFEAT_TREATMENT_UNIVERSAL, trauma))
		return FALSE
	var/spent_cost = invoke_cost()
	if(spent_cost)
		handle_exp(spent_cost)
	StartCooldown()
	caster.apply_status_effect(/datum/status_effect/sacrificial_exhaustion)
	caster.adjustBruteLoss(damage_cost)
	caster.visible_message(span_notice("[caster] shudders as [cast_on]'s burden passes into them."), span_warning("I lift one trauma, taking [damage_cost] bodily damage in return."))
	to_chat(cast_on, span_notice("A lingering defeat trauma loosens its hold on you."))
	return TRUE
