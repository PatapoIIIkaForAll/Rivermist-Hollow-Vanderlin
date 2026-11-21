/// An organ counts as overfilled at this share of capacity held as its own fluid.
#define RELIEF_NEEDED_FULL_RATIO 0.95
/// The ache ends only once every organ drops below this share.
#define RELIEF_NEEDED_RELIEVED_RATIO 0.8
/// Arousal added each time the ache flares.
#define RELIEF_NEEDED_AROUSAL 5
/// Random wait between ache reminders in chat; the ache itself flares more often, silently.
#define RELIEF_NEEDED_MESSAGE_MIN (6 MINUTES)
#define RELIEF_NEEDED_MESSAGE_MAX (10 MINUTES)

/datum/quirk/neutral/extra_productive
	name = "Productive Glands"
	desc = "My body makes milk, seed and nectar faster than most."
	desc_hint = "All fluid-producing organs produce 50% faster."

/datum/quirk/neutral/extra_productive/on_spawn()
	. = ..()
	owner?.add_fluid_modifier(/datum/fluid_modifier/extra_productive, "[type]")

/datum/quirk/neutral/extra_productive/on_remove()
	if(!QDELETED(owner))
		owner.remove_fluid_modifier(/datum/fluid_modifier/extra_productive, "[type]")
	return ..()

/datum/quirk/neutral/swelling_glands
	name = "Swelling Glands"
	desc = "My breasts and balls visibly swell as they fill, and shrink back once emptied."
	desc_hint = "Breasts grow one size once three quarters full of milk; balls grow up to three sizes when full and stop where their sprites end."
	traits_to_add = list(TRAIT_FLUID_ENGORGEMENT)

/datum/quirk/neutral/relief_needed
	name = "Relief Needed"
	desc = "When my breasts or balls are full, I ache for release."
	desc_hint = "A full fluid organ raises arousal, lowers mood and reminds you until it is emptied."
	/// TRUE while an organ is overfilled, until every organ is relieved.
	var/aching = FALSE
	COOLDOWN_DECLARE(next_ache)
	/// Not reset by relief, so a quick refill cannot repeat the reminder.
	COOLDOWN_DECLARE(next_ache_message)

/datum/quirk/neutral/relief_needed/on_life(mob/living/user)
	var/obj/item/organ/genitals/filling_organ/full_organ = get_filled_organ(user, RELIEF_NEEDED_FULL_RATIO)
	if(full_organ)
		if(!COOLDOWN_FINISHED(src, next_ache))
			return
		COOLDOWN_START(src, next_ache, rand(90, 150) SECONDS)
		aching = TRUE
		ache(user, full_organ)
		return
	if(!aching || get_filled_organ(user, RELIEF_NEEDED_RELIEVED_RATIO))
		return
	aching = FALSE
	COOLDOWN_RESET(src, next_ache)
	user.remove_stress(/datum/stress_event/overfilled)
	to_chat(user, span_notice("Ahh... the pressure is finally gone."))

/datum/quirk/neutral/relief_needed/proc/ache(mob/living/user, obj/item/organ/genitals/filling_organ/full_organ)
	SEND_SIGNAL(user, COMSIG_SEX_ADJUST_AROUSAL, RELIEF_NEEDED_AROUSAL)
	user.add_stress(/datum/stress_event/overfilled)
	if(!COOLDOWN_FINISHED(src, next_ache_message))
		return
	COOLDOWN_START(src, next_ache_message, rand(RELIEF_NEEDED_MESSAGE_MIN, RELIEF_NEEDED_MESSAGE_MAX))
	var/datum/reagent/fluid = full_organ.get_produced_reagent()
	var/organ_name = pick(full_organ.altnames)
	to_chat(user, span_love(pick(
		"My [organ_name] feel painfully overfilled. I need relief.",
		"My overfilled [organ_name] throb, heavy with [initial(fluid.name)].",
		"I can't stop thinking about my swollen [organ_name]. They need emptying.",
	)))

/// First producing organ whose own fluid fills at least the given share of its capacity.
/datum/quirk/neutral/relief_needed/proc/get_filled_organ(mob/living/user, ratio)
	for(var/slot in list(ORGAN_SLOT_BREASTS, ORGAN_SLOT_TESTICLES, ORGAN_SLOT_VAGINA))
		var/obj/item/organ/genitals/filling_organ/organ = user.getorganslot(slot)
		if(!istype(organ) || !organ.reagents?.maximum_volume || !organ.is_producing())
			continue
		if(organ.get_own_fluid_amount() >= organ.reagents.maximum_volume * ratio)
			return organ
	return null

/// One flat stack; each ache only refreshes the timer.
/datum/stress_event/overfilled
	stress_change = 2
	desc = span_red("I'm overfilled and aching for relief.")
	timer = 3 MINUTES

/datum/stress_event/pent_up_release
	stress_change = -2
	desc = span_green("That pent-up release felt incredible.")
	timer = 5 MINUTES

#undef RELIEF_NEEDED_FULL_RATIO
#undef RELIEF_NEEDED_RELIEVED_RATIO
#undef RELIEF_NEEDED_AROUSAL
#undef RELIEF_NEEDED_MESSAGE_MIN
#undef RELIEF_NEEDED_MESSAGE_MAX
