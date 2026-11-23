/// A run-scoped buff. Applied to every roster member while the run lives,
/// stripped on run end. Stat-based boons use named stat modifiers so they
/// never leak outside the dungeon.
/datum/dungeon_boon
	abstract_type = /datum/dungeon_boon
	var/name = "Boon"
	var/desc = "A blessing of the deep."
	/// Higher = more common in the pick-three offer
	var/weight = 10
	/// Domain tags matching /datum/dungeon_god_profile domains
	var/list/domains = list("fate")
	/// DUNGEON_BOON_* rarity this instance rolled (display + magnitude)
	var/rarity = DUNGEON_BOON_COMMON
	/// Effect multiplier set from rarity when the card is built
	var/magnitude = 1
	/// Synergy prerequisite boon types; synergies only appear via the dedicated
	/// offer slot once every prerequisite is held by the run
	var/list/requires
	/// Watching-god name branded onto this offered card (display only)
	var/god_brand
	/// TRUE = never appears in normal offers; sold only at dark bargain altars
	var/dark_bargain_only = FALSE
	/// Price datums may stack when a party accepts the same cost repeatedly.
	var/allow_duplicates = FALSE

/datum/dungeon_boon/proc/get_mod_id(datum/dungeon_run/run)
	return "dungeon_boon_[type]_[REF(run)]"

/// Branded, rarity-tagged label for chat lines and legacy list menus.
/datum/dungeon_boon/proc/get_display_name()
	var/rarity_tag = (rarity == DUNGEON_BOON_COMMON) ? "" : " ([capitalize(rarity)])"
	var/synergy_tag = length(requires) ? " (Synergy)" : ""
	return "[god_brand ? "[god_brand] " : ""][name][rarity_tag][synergy_tag]"

/datum/dungeon_boon/proc/apply(datum/dungeon_run/run, mob/living/target)
	return

/datum/dungeon_boon/proc/remove(datum/dungeon_run/run, mob/living/target)
	return

/// Run-global effects belong to boon acquisition, never to carrier count.
/datum/dungeon_boon/proc/acquire(datum/dungeon_run/run)
	return

/datum/dungeon_boon/proc/release(datum/dungeon_run/run)
	return

/// Optional per-room hook, called for every active boon when a combat room clears.
/datum/dungeon_boon/proc/on_room_cleared(datum/dungeon_run/run, datum/pocket_dimension/dungeon/room)
	return

// -- Life --

/datum/dungeon_boon/vigor
	name = "Vigor of the Deep"
	desc = "Your flesh hardens against the dark. (+max health)"
	domains = list("life", "war")
	var/applied_amount = 25

/datum/dungeon_boon/vigor/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	applied_amount = round(25 * magnitude)
	target.maxHealth += applied_amount
	target.health = min(target.health + applied_amount, target.maxHealth)

/datum/dungeon_boon/vigor/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.maxHealth = max(1, target.maxHealth - applied_amount)
	target.health = min(target.health, target.maxHealth)

/datum/dungeon_boon/second_wind
	name = "Second Wind"
	desc = "Every victory knits your wounds. (heal on room clear)"
	domains = list("life")

/datum/dungeon_boon/second_wind/on_room_cleared(datum/dungeon_run/run, datum/pocket_dimension/dungeon/room)
	var/heal = round(20 * magnitude)
	for(var/mob/living/member as anything in run.get_members_in_room(room))
		// Silent healing reads as a dead boon - only speak up when there was
		// something to mend, so the player can tell it fired.
		var/hurt = (member.getBruteLoss() + member.getFireLoss()) > 0
		member.adjustBruteLoss(-heal)
		member.adjustFireLoss(-heal)
		if(hurt && member.client)
			to_chat(member, span_nicegreen("Second Wind: the victory knits your wounds."))

/datum/dungeon_boon/stubborn_heart
	name = "Stubborn Heart"
	desc = "You refuse to stay down. (faster self-recovery when defeated)"
	domains = list("life")

/datum/dungeon_boon/stubborn_heart/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.defeat_struggle_delay_mult = 1 / (1 + magnitude)

/datum/dungeon_boon/stubborn_heart/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.defeat_struggle_delay_mult = 1

// -- Luck --

/datum/dungeon_boon/fortune
	name = "Fortune's Favor"
	desc = "Luck clings to you; the dungeon yields more. (+fortune)"
	domains = list("luck")

/datum/dungeon_boon/fortune/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.set_stat_modifier(get_mod_id(run), STAT_FORTUNE, round(10 * magnitude))

/datum/dungeon_boon/fortune/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.remove_stat_modifier(get_mod_id(run))

/datum/dungeon_boon/greed
	name = "Hunger for Motes"
	desc = "Slain guardians spill more light. (+mote drops)"
	domains = list("luck", "shadow")

/datum/dungeon_boon/greed/acquire(datum/dungeon_run/run)
	run.mote_multiplier = 1 + 0.5 * magnitude

/datum/dungeon_boon/greed/release(datum/dungeon_run/run)
	run.mote_multiplier = 1

// -- War --

/datum/dungeon_boon/edge
	name = "Battle Edge"
	desc = "Your blows land harder. (+strength)"
	domains = list("war")

/datum/dungeon_boon/edge/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.set_stat_modifier(get_mod_id(run), STAT_STRENGTH, max(1, round(2 * magnitude)))

/datum/dungeon_boon/edge/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.remove_stat_modifier(get_mod_id(run))

/datum/dungeon_boon/warding
	name = "Warding"
	desc = "You endure what should fell you. (+endurance)"
	domains = list("war", "craft")

/datum/dungeon_boon/warding/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.set_stat_modifier(get_mod_id(run), STAT_ENDURANCE, max(1, round(2 * magnitude)))

/datum/dungeon_boon/warding/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.remove_stat_modifier(get_mod_id(run))

// -- Nature --

/datum/dungeon_boon/fleetfoot
	name = "Fleetfoot"
	desc = "The dungeon's paths seem shorter. (+dexterity)"
	domains = list("nature", "shadow")

/datum/dungeon_boon/fleetfoot/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.set_stat_modifier(get_mod_id(run), STAT_SPEED, max(1, round(1 * magnitude)))

/datum/dungeon_boon/fleetfoot/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.remove_stat_modifier(get_mod_id(run))

// -- Shadow --

/datum/dungeon_boon/mote_magnet
	name = "Mote Magnet"
	desc = "Cleared rooms bleed extra light. (bonus motes on clear)"
	domains = list("shadow", "luck")

/datum/dungeon_boon/mote_magnet/on_room_cleared(datum/dungeon_run/run, datum/pocket_dimension/dungeon/room)
	run.award_motes(round(5 * magnitude), null)

// -- Fate --

/datum/dungeon_boon/echo_affinity
	name = "Echo Affinity"
	desc = "Your deeds crystallize more readily. (+echo conversion)"
	domains = list("fate")

/datum/dungeon_boon/echo_affinity/acquire(datum/dungeon_run/run)
	run.echo_conversion_bonus = 0.1 * magnitude

/datum/dungeon_boon/echo_affinity/release(datum/dungeon_run/run)
	run.echo_conversion_bonus = 0

// -- Synergies (guaranteed card once prerequisites are held) --

/datum/dungeon_boon/battle_luck
	name = "Battle Luck"
	desc = "Fortune rides your blade - strength and luck entwined."
	domains = list("war", "luck")
	requires = list(/datum/dungeon_boon/edge, /datum/dungeon_boon/fortune)

/datum/dungeon_boon/battle_luck/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.set_stat_modifier(get_mod_id(run), list(STAT_STRENGTH = max(1, round(1 * magnitude)), STAT_FORTUNE = round(5 * magnitude)))

/datum/dungeon_boon/battle_luck/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.remove_stat_modifier(get_mod_id(run))

/datum/dungeon_boon/martyrs_resolve
	name = "Martyr's Resolve"
	desc = "Suffering endured becomes strength shared."
	domains = list("life", "war")
	requires = list(/datum/dungeon_boon/vigor, /datum/dungeon_boon/second_wind)
	var/applied_amount = 15

/datum/dungeon_boon/martyrs_resolve/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	applied_amount = round(15 * magnitude)
	target.maxHealth += applied_amount
	target.health = min(target.health + applied_amount, target.maxHealth)

/datum/dungeon_boon/martyrs_resolve/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.maxHealth = max(1, target.maxHealth - applied_amount)
	target.health = min(target.health, target.maxHealth)

// -- Dark bargains: altar-exclusive boons, always sold at epic ----------------

/datum/dungeon_boon/dark
	abstract_type = /datum/dungeon_boon/dark
	dark_bargain_only = TRUE
	domains = list("shadow")

/datum/dungeon_boon/dark/umbral_edge
	name = "Umbral Edge"
	desc = "Night itself sharpens your arm and your stride. (+strength, +dexterity)"
	domains = list("shadow", "war")

/datum/dungeon_boon/dark/umbral_edge/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.set_stat_modifier(get_mod_id(run), list(STAT_STRENGTH = max(1, round(2 * magnitude)), STAT_SPEED = max(1, round(1 * magnitude))))

/datum/dungeon_boon/dark/umbral_edge/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.remove_stat_modifier(get_mod_id(run))

/datum/dungeon_boon/dark/gloamskin
	name = "Gloamskin"
	desc = "Shadow knits itself into your hide. (+endurance, +max health)"
	domains = list("shadow", "life")
	var/applied_amount = 20

/datum/dungeon_boon/dark/gloamskin/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	applied_amount = round(20 * magnitude)
	target.maxHealth += applied_amount
	target.health = min(target.health + applied_amount, target.maxHealth)
	target.set_stat_modifier(get_mod_id(run), STAT_ENDURANCE, max(1, round(2 * magnitude)))

/datum/dungeon_boon/dark/gloamskin/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	target.maxHealth = max(1, target.maxHealth - applied_amount)
	target.health = min(target.health, target.maxHealth)
	target.remove_stat_modifier(get_mod_id(run))

/datum/dungeon_boon/dark/debt_of_blood
	name = "Debt of Blood"
	desc = "Every cleared room pays tribute in blood and light. (heal + motes on clear)"
	domains = list("shadow", "luck")

/datum/dungeon_boon/dark/debt_of_blood/on_room_cleared(datum/dungeon_run/run, datum/pocket_dimension/dungeon/room)
	for(var/mob/living/member as anything in run.get_members_in_room(room))
		member.adjustBruteLoss(-round(15 * magnitude))
		member.adjustFireLoss(-round(15 * magnitude))
	run.award_motes(round(10 * magnitude), null)

// -- Bargain prices: hidden run-scoped anti-boons -----------------------------

/datum/dungeon_boon/dark_price
	abstract_type = /datum/dungeon_boon/dark_price
	dark_bargain_only = TRUE
	weight = 0
	allow_duplicates = TRUE

/// The Price of Flesh: every roster member loses a cut of max health for the
/// rest of the run. Rides the carrier registry like any boon, so it applies to
/// late joiners and strips cleanly at run end.
/datum/dungeon_boon/dark_price/flesh
	name = "Price of Flesh"
	desc = "The bargain's cost, written in everyone's vitality."
	/// REF text -> amount taken (per-target, so restore is exact)
	var/list/cuts = list()

/datum/dungeon_boon/dark_price/flesh/apply(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	var/key = "[REF(target)]"
	if(cuts[key])
		return
	var/cut = max(1, round(target.maxHealth * DUNGEON_BARGAIN_FLESH_CUT))
	cut = min(cut, target.maxHealth - 1)
	if(cut <= 0)
		return
	cuts[key] = cut
	target.maxHealth -= cut
	target.health = min(target.health, target.maxHealth)

/datum/dungeon_boon/dark_price/flesh/remove(datum/dungeon_run/run, mob/living/target)
	if(!istype(target))
		return
	var/key = "[REF(target)]"
	var/cut = cuts[key]
	if(!cut)
		return
	cuts -= key
	target.maxHealth += cut

// -- Offer construction ------------------------------------------------------

/// Builds a weighted pool of non-synergy boon instances not already active.
/proc/get_dungeon_boon_choices(datum/dungeon_run/run, count = 3)
	var/list/pool = list()
	var/list/active_types = list()
	for(var/datum/dungeon_boon/active as anything in run.active_boons)
		active_types[active.type] = TRUE
	for(var/datum/dungeon_boon/boon_type as anything in subtypesof(/datum/dungeon_boon))
		if(IS_ABSTRACT(boon_type))
			continue
		if(active_types[boon_type])
			continue
		if(initial(boon_type.dark_bargain_only)) // altar-exclusive
			continue
		// initial() cannot read list vars (returns null), so the synergy check
		// must happen on a live instance or synergies leak into normal offers.
		var/datum/dungeon_boon/candidate = new boon_type
		if(length(candidate.requires)) // synergies never roll normally
			qdel(candidate)
			continue
		pool[candidate] = max(1, candidate.weight)
	var/list/chosen = list()
	while(length(pool) && length(chosen) < count)
		var/datum/dungeon_boon/picked = pickweight(pool)
		pool -= picked
		chosen += picked
	for(var/datum/dungeon_boon/leftover as anything in pool)
		qdel(leftover)
	return chosen

/// Returns an available synergy boon type whose prerequisites the run holds.
/proc/get_available_synergy(datum/dungeon_run/run)
	var/list/active_types = list()
	for(var/datum/dungeon_boon/active as anything in run.active_boons)
		active_types[active.type] = TRUE
	for(var/datum/dungeon_boon/boon_type as anything in subtypesof(/datum/dungeon_boon))
		if(IS_ABSTRACT(boon_type) || active_types[boon_type])
			continue
		// Live instance: initial() returns null for list vars like requires.
		var/datum/dungeon_boon/candidate = new boon_type
		var/list/needs = candidate.requires?.Copy()
		qdel(candidate)
		if(!length(needs))
			continue
		var/satisfied = TRUE
		for(var/required_type in needs)
			if(!active_types[required_type])
				satisfied = FALSE
				break
		if(satisfied)
			return boon_type
	return null

/// Builds the full offer: branded, rarity-rolled cards from the watching gods.
/// Returns a list of ready boon instances; caller owns them (qdel the unpicked).
/proc/build_boon_offer(datum/dungeon_run/run, count = 3)
	var/list/datum/dungeon_boon/cards = get_dungeon_boon_choices(run, count)
	var/list/profiles = list()
	for(var/god_type in run.watching_god_types)
		for(var/datum/dungeon_god_profile/profile as anything in get_dungeon_god_profiles())
			if(profile.patron_type == god_type)
				profiles += profile
				break

	for(var/datum/dungeon_boon/card as anything in cards)
		var/datum/dungeon_god_profile/god
		if(length(profiles))
			// Prefer a watching god whose domains match this boon.
			var/list/matching = list()
			for(var/datum/dungeon_god_profile/profile as anything in profiles)
				for(var/domain in profile.domains)
					if(domain in card.domains)
						matching += profile
						break
			god = length(matching) ? pick(matching) : pick(profiles)
		card.rarity = run.roll_boon_rarity()
		card.magnitude = run.get_rarity_magnitude(card.rarity)
		if(god)
			card.god_brand = god.get_boon_prefix()

	// A satisfied synergy claims the last card slot, Hades duo-boon style.
	var/synergy_type = get_available_synergy(run)
	if(synergy_type && length(cards))
		var/datum/dungeon_boon/replaced = cards[length(cards)]
		cards -= replaced
		qdel(replaced)
		var/datum/dungeon_boon/synergy = new synergy_type
		synergy.rarity = DUNGEON_BOON_RARE
		synergy.magnitude = run.get_rarity_magnitude(DUNGEON_BOON_RARE)
		cards += synergy

	return cards

/datum/dungeon_run/proc/can_add_boon(datum/dungeon_boon/candidate)
	if(!istype(candidate) || ending)
		return FALSE
	var/list/active_types = list()
	for(var/datum/dungeon_boon/active as anything in active_boons)
		active_types[active.type] = TRUE
	if(active_types[candidate.type] && !candidate.allow_duplicates)
		return FALSE
	for(var/required_type in candidate.requires)
		if(!active_types[required_type])
			return FALSE
	return TRUE

// -- Offer session: one open pick-three window ------------------------------

/// A pending boon choice. Owns its unpicked cards; dies with the run.
/datum/dungeon_boon_offer
	var/datum/dungeon_run/run
	var/mob/living/chooser
	var/list/datum/dungeon_boon/cards

/datum/dungeon_boon_offer/New(datum/dungeon_run/owning_run, mob/living/choosing, list/offer_cards)
	..()
	run = owning_run
	chooser = choosing
	cards = offer_cards

/datum/dungeon_boon_offer/Destroy(force)
	SStgui.close_uis(src)
	QDEL_LIST(cards)
	if(run && !QDELETED(run))
		run.open_boon_offers -= src
	run = null
	chooser = null
	return ..()

/datum/dungeon_boon_offer/ui_state(mob/user)
	return GLOB.always_state

/datum/dungeon_boon_offer/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(run) || user != chooser)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/dungeon_boon_offer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DungeonBoonPicker")
		ui.open()

/datum/dungeon_boon_offer/ui_data(mob/user)
	var/list/data = list()
	var/list/card_data = list()
	for(var/datum/dungeon_boon/card as anything in cards)
		card_data += list(list(
			"name" = card.name,
			"god" = card.god_brand,
			"rarity" = card.rarity,
			"desc" = card.desc,
			"domains" = card.domains,
			"synergy" = !!length(card.requires),
		))
	data["cards"] = card_data
	return data

/datum/dungeon_boon_offer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "pick")
		resolve_pick(text2num(params["index"]))
		return TRUE

/// Applies the chosen card to the run and retires the session. Index is
/// 1-based into cards; anything invalid is ignored (window stays open).
/datum/dungeon_boon_offer/proc/resolve_pick(index)
	if(QDELETED(src) || QDELETED(run) || !isnum(index) || index < 1 || index > length(cards))
		return FALSE
	var/datum/dungeon_boon/chosen = cards[index]
	if(!run.can_add_boon(chosen))
		to_chat(chooser, span_warning("That blessing has already been claimed or its bond has broken. The gods redraw their hands."))
		QDEL_LIST(cards)
		cards = build_boon_offer(run, 3)
		if(!length(cards))
			qdel(src)
			return FALSE
		SStgui.update_uis(src)
		return FALSE
	cards -= chosen // Destroy() must not qdel the applied boon
	if(!run.add_boon(chosen))
		qdel(chosen)
		return FALSE
	if(chooser && !QDELETED(chooser))
		to_chat(chooser, span_nicegreen("The run is blessed: [chosen.get_display_name()]."))
	qdel(src)
	return TRUE

/// Offers a boon choice to a player; the chosen boon applies to the whole run.
/// Async: opens a card window and returns. The session survives until picked
/// or the run ends. Multiple concurrent sessions are fine (independent windows).
/datum/dungeon_run/proc/offer_boon(mob/living/chooser)
	if(!istype(chooser) || !chooser.client || ending)
		return
	var/list/datum/dungeon_boon/cards = build_boon_offer(src, 3)
	if(!length(cards))
		return
	var/datum/dungeon_boon_offer/offer = new(src, chooser, cards)
	open_boon_offers += offer
	to_chat(chooser, span_boldnotice("The watching gods extend their hands. Choose."))
	INVOKE_ASYNC(offer, TYPE_PROC_REF(/datum, ui_interact), chooser)

/// Break rooms and shrines route through the same offer.
/datum/dungeon_run/proc/offer_break_room_boon(mob/living/chooser)
	offer_boon(chooser)
