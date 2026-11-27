// -- Trader den ---------------------------------------------------------------

/// A peaceful mid-stretch merchant. Same menu skeleton as the shrine.
/obj/structure/dungeon_trader
	name = "wandering peddler's stall"
	desc = "A hunched figure behind a cloth-draped stall. How it got down here is not a polite question."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "streetvendor1"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/dungeon_run/owning_run

/obj/structure/dungeon_trader/Destroy()
	owning_run = null
	return ..()

/obj/structure/dungeon_trader/examine(mob/user)
	. = ..()
	if(owning_run)
		. += span_notice("It trades in motes - the party holds [owning_run.motes]. Touch it to barter.")

/obj/structure/dungeon_trader/attack_hand(mob/user, list/modifiers)
	. = ..()
	open_trader_menu(user)

/obj/structure/dungeon_trader/proc/open_trader_menu(mob/living/user)
	if(!istype(user) || !user.client || !owning_run || QDELETED(owning_run))
		return
	var/floor = owning_run.floor
	var/list/offers = list(
		list("id" = "heal", "label" = "Mend wounds", "cost" = 25),
		list("id" = "cache", "label" = "A cache of goods", "cost" = 60 + floor * 20),
		list("id" = "key", "label" = "A skeleton key (opens locked passages)", "cost" = 75),
		list("id" = "bank", "label" = "Bank motes as echoes now", "cost" = 0),
	)
	var/list/by_label = list()
	for(var/list/offer as anything in offers)
		by_label["[offer["label"]] ([offer["cost"]] motes)"] = offer
	var/picked = tgui_input_list(user, "The peddler's stock (you hold [owning_run.motes] motes):", "Wandering Peddler", by_label)
	var/list/chosen = by_label[picked]
	if(!chosen || QDELETED(src) || !owning_run || QDELETED(owning_run))
		return
	if(!owning_run.try_pay_offer(chosen["cost"]))
		to_chat(user, span_warning("Not enough motes."))
		return
	apply_offer(chosen["id"], user)

/obj/structure/dungeon_trader/proc/apply_offer(id, mob/living/user)
	switch(id)
		if("heal")
			user.adjustBruteLoss(-40)
			user.adjustFireLoss(-40)
			to_chat(user, span_nicegreen("The peddler daubs something foul-smelling on your wounds. It works."))
		if("cache")
			var/table_type = get_dungeon_loot_table_type_for_floor(owning_run.floor)
			var/datum/loot_table/table = new table_type
			table.spawn_loot(user, owning_run.floor, user.return_item_rarity())
			qdel(table)
			to_chat(user, span_nicegreen("The peddler slides a bundle across the stall."))
		if("key")
			var/obj/item/dungeon_key/key = new(get_turf(user))
			key.key_id = "default"
			to_chat(user, span_nicegreen("The peddler produces a worn key. \"Opens most things down here.\""))
		if("bank")
			owning_run.bank_motes_now(user)

/datum/pocket_dimension/dungeon/proc/spawn_trader_den()
	var/turf/spot = get_drop_turf(null)
	if(!spot)
		return
	var/obj/structure/dungeon_trader/trader = new(spot)
	trader.owning_run = owning_run
	track_native_movable(trader)

// -- Mystery events -----------------------------------------------------------

/// One-shot room dressers: each spawns a single curiosity into a mystery room.
/datum/dungeon_mystery_event
	abstract_type = /datum/dungeon_mystery_event

/datum/dungeon_mystery_event/proc/trigger(datum/pocket_dimension/dungeon/room)
	return

/datum/dungeon_mystery_event/proc/place(datum/pocket_dimension/dungeon/room, obj/structure/built)
	var/turf/spot = room.get_drop_turf(null)
	if(!spot)
		qdel(built)
		return null
	built.forceMove(spot)
	room.track_native_movable(built)
	return built

/datum/dungeon_mystery_event/fountain

/datum/dungeon_mystery_event/fountain/trigger(datum/pocket_dimension/dungeon/room)
	var/obj/structure/dungeon_mote_fountain/fountain = place(room, new /obj/structure/dungeon_mote_fountain)
	if(fountain)
		fountain.owning_run = room.owning_run

/datum/dungeon_mystery_event/gamble

/datum/dungeon_mystery_event/gamble/trigger(datum/pocket_dimension/dungeon/room)
	var/obj/structure/dungeon_gamble_altar/altar = place(room, new /obj/structure/dungeon_gamble_altar)
	if(altar)
		altar.owning_run = room.owning_run

/datum/dungeon_mystery_event/trapped_chest

/datum/dungeon_mystery_event/trapped_chest/trigger(datum/pocket_dimension/dungeon/room)
	var/obj/structure/dungeon_trapped_chest/chest = place(room, new /obj/structure/dungeon_trapped_chest)
	if(chest)
		chest.owning_room = room

/datum/dungeon_mystery_event/riddle

/datum/dungeon_mystery_event/riddle/trigger(datum/pocket_dimension/dungeon/room)
	var/obj/structure/dungeon_riddle_shrine/shrine = place(room, new /obj/structure/dungeon_riddle_shrine)
	if(shrine)
		shrine.owning_run = room.owning_run

/// Spawns one weighted mystery curiosity. forced_type pins the roll (tests).
/datum/pocket_dimension/dungeon/proc/spawn_mystery_event(forced_type)
	var/static/list/event_weights = list(
		/datum/dungeon_mystery_event/fountain = 30,
		/datum/dungeon_mystery_event/gamble = 25,
		/datum/dungeon_mystery_event/trapped_chest = 25,
		/datum/dungeon_mystery_event/riddle = 20,
	)
	var/event_type = forced_type || pickweight(event_weights.Copy())
	var/datum/dungeon_mystery_event/event = new event_type
	event.trigger(src)
	qdel(event)

// -- Mystery structures --------------------------------------------------------

/obj/structure/dungeon_mote_fountain
	name = "glimmering fountain"
	desc = "Light pools around a humming crystal spire. It looks drinkable, in the way dares are doable."
	icon = 'icons/roguetown/misc/mana_pylon.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/dungeon_run/owning_run
	/// REF text -> TRUE; one sip per delver
	var/list/drank_refs = list()

/obj/structure/dungeon_mote_fountain/Destroy()
	owning_run = null
	return ..()

/obj/structure/dungeon_mote_fountain/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!isliving(user) || !owning_run || QDELETED(owning_run))
		return
	var/key = "[REF(user)]"
	if(drank_refs[key])
		to_chat(user, span_warning("The light shies away from your hand. It has given you its share."))
		return
	drank_refs[key] = TRUE
	var/mob/living/drinker = user
	drinker.adjustBruteLoss(-25)
	drinker.adjustFireLoss(-25)
	owning_run.award_motes(8, src)
	to_chat(user, span_nicegreen("You cup the light and drink. Warmth spreads through you."))

/obj/structure/dungeon_gamble_altar
	name = "wager stone"
	desc = "A grinning stone gargoyle with an upturned palm. Something inside it enjoys a bet."
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "gargoyle"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/dungeon_run/owning_run

/obj/structure/dungeon_gamble_altar/Destroy()
	owning_run = null
	return ..()

/obj/structure/dungeon_gamble_altar/examine(mob/user)
	. = ..()
	. += span_notice("Stake 20 motes on the circle: double or nothing.")

/obj/structure/dungeon_gamble_altar/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!isliving(user) || !owning_run || QDELETED(owning_run))
		return
	if(!owning_run.spend_motes(20))
		to_chat(user, span_warning("The stone wants 20 motes staked. The party doesn't have them."))
		return
	if(prob(50))
		owning_run.award_motes(45, src)
		visible_message(span_nicegreen("The circle flares - the stake comes back heavier!"))
	else
		visible_message(span_warning("The circle swallows the stake and goes dark."))

/obj/structure/dungeon_trapped_chest
	name = "gilded chest"
	desc = "Unlocked, unguarded, gleaming. Absolutely nothing about this is suspicious."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "chestfancy_neu"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/pocket_dimension/dungeon/owning_room

/obj/structure/dungeon_trapped_chest/Destroy()
	owning_room = null
	return ..()

/obj/structure/dungeon_trapped_chest/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!isliving(user) || !owning_room || QDELETED(owning_room))
		return
	var/mob/living/opener = user
	opener.adjustBruteLoss(20)
	opener.Knockdown(2 SECONDS)
	opener.visible_message(
		span_warning("[opener] springs the chest's trap and is thrown back!"),
		span_userdanger("The lid bites! Pain lances up your arms!"),
	)
	owning_room.spawn_bonus_loot_cache(sealed = FALSE)
	qdel(src)

/obj/structure/dungeon_riddle_shrine
	name = "whispering shrine"
	desc = "A candle-crowned gargoyle that murmurs a question to anyone who comes close."
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "gargoyle_candles"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/dungeon_run/owning_run
	var/answered = FALSE
	var/list/riddle

/obj/structure/dungeon_riddle_shrine/Initialize()
	. = ..()
	riddle = pick(list(
		list("q" = "I have cities, but no houses; forests, but no trees; water, but no fish. What am I?", "a" = list("A map", "A dream", "A painting", "A grave"), "correct" = "A map"),
		list("q" = "The more of me you take, the more you leave behind. What am I?", "a" = list("Footsteps", "Time", "Breath", "Gold"), "correct" = "Footsteps"),
		list("q" = "What walks on four legs at dawn, two at noon, and three at dusk?", "a" = list("A man", "A wolf", "A spider", "A king"), "correct" = "A man"),
	))

/obj/structure/dungeon_riddle_shrine/Destroy()
	owning_run = null
	return ..()

/obj/structure/dungeon_riddle_shrine/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!isliving(user) || !user.client || !owning_run || QDELETED(owning_run))
		return
	if(answered)
		to_chat(user, span_warning("The shrine is silent. Its question has been answered."))
		return
	var/picked = tgui_input_list(user, riddle["q"], "The Whispering Shrine", riddle["a"])
	if(isnull(picked) || answered || QDELETED(src))
		return
	answered = TRUE
	if(picked == riddle["correct"])
		owning_run.award_motes(25, src)
		visible_message(span_nicegreen("The shrine sighs, satisfied, and light spills from its mouth."))
	else
		visible_message(span_warning("The shrine goes cold. Wrong."))
