/datum/antagonist/mothbug
	name = "Mothbug"
	job_rank = ROLE_MOTHBUG
	roundend_category = "Mothbug Colony"
	antagpanel_category = "Mothbug"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	increase_votepwr = FALSE
	replace_banned = FALSE
	var/datum/team/mothbug_colony/colony

/proc/find_mothbug_colony(create = FALSE)
	for(var/datum/team/mothbug_colony/existing_colony in GLOB.antagonist_teams)
		return existing_colony
	if(create)
		return new /datum/team/mothbug_colony

/datum/antagonist/mothbug/create_team(datum/team/mothbug_colony/new_team)
	colony = istype(new_team) ? new_team : find_mothbug_colony(TRUE)

/datum/antagonist/mothbug/get_team()
	return colony

/datum/antagonist/mothbug/can_be_owned(datum/mind/new_owner)
	return ..() && istype(new_owner.current, /mob/living/simple_animal/mothbug)

/datum/antagonist/mothbug/on_gain()
	owner.special_role = ROLE_MOTHBUG
	if(colony)
		objectives |= colony.objectives
	. = ..()
	colony?.update_peak_size()
	owner.announce_objectives()

/datum/antagonist/mothbug/greet()
	to_chat(owner.current, span_boldannounce("I am a mothbug, one of a hungry colony hidden in the town's dark corners."))
	to_chat(owner.current, span_notice("Click fabric to eat it: clothes, cloth, silk, fur and bedsheets, even inside chests and wardrobes. Eating gives silk, which pays for my abilities and heals me."))
	to_chat(owner.current, span_notice("I cannot hurt anyone. A person who is bound, lying down, asleep or knocked out is fair game: pick a body area on my doll and click them to nibble away their clothes there, underwear too. Bare skin gets tickled instead."))
	to_chat(owner.current, span_notice("Hide in darkness or under tables and beds. Stay unseen; the town will hunt a colony it notices."))

/datum/antagonist/mothbug/hatchling
	name = "Mothling"

/datum/antagonist/mothbug/hatchling/greet()
	to_chat(owner.current, span_boldannounce("I am a mothling, a newly hatched grub of the mothbug colony."))
	to_chat(owner.current, span_notice("I cannot fly or lay eggs. I must eat fabric and hide. Fabric feeds me better than it feeds the adults."))
	to_chat(owner.current, span_notice("Click fabric to eat it. Hide in darkness or under tables and beds. People can pick me up, so keep away from them."))

/datum/team/mothbug_colony
	name = "Mothbug Colony"
	member_name = "mothbug"
	var/fabric_eaten = 0
	var/peak_size = 0
	var/eggs_laid = 0
	var/omen_given = FALSE
	var/list/obj/item/mothbug_egg/eggs = list()
	/// Mothbug eggs growing inside hosts; they count toward the cap until born.
	var/list/obj/item/oviposition_egg/host_eggs = list()

/datum/team/mothbug_colony/New(starting_members)
	. = ..()
	for(var/objective_type in list(/datum/objective/mothbug_feast, /datum/objective/mothbug_brood, /datum/objective/mothbug_survive))
		add_objective(new objective_type)

/datum/team/mothbug_colony/Destroy(force, ...)
	for(var/obj/item/mothbug_egg/egg as anything in eggs)
		egg.colony = null
	eggs = null
	for(var/obj/item/oviposition_egg/host_egg as anything in host_eggs)
		UnregisterSignal(host_egg, COMSIG_PARENT_QDELETING)
	host_eggs = null
	return ..()

/// Living mothbugs plus eggs still waiting to hatch, in the open or inside hosts.
/datum/team/mothbug_colony/proc/get_colony_size()
	return length(get_living_members()) + length(eggs) + length(host_eggs)

/datum/team/mothbug_colony/proc/track_host_egg(obj/item/oviposition_egg/host_egg)
	host_eggs += host_egg
	RegisterSignal(host_egg, COMSIG_PARENT_QDELETING, PROC_REF(on_host_egg_deleted))

/datum/team/mothbug_colony/proc/on_host_egg_deleted(obj/item/oviposition_egg/source)
	SIGNAL_HANDLER
	host_eggs -= source

/datum/team/mothbug_colony/proc/get_colony_cap()
	var/players = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	return clamp(MOTHBUG_COLONY_BASE_CAP + round(players / MOTHBUG_COLONY_PLAYERS_PER_SLOT), MOTHBUG_COLONY_BASE_CAP, MOTHBUG_COLONY_MAX_CAP)

/datum/team/mothbug_colony/proc/has_room()
	return get_colony_size() < get_colony_cap()

/datum/team/mothbug_colony/proc/record_fabric(amount)
	fabric_eaten += amount
	if(!omen_given && fabric_eaten >= MOTHBUG_OMEN_THRESHOLD)
		give_omen()

/// One quiet hint to whoever stands near the colony once it has eaten its fill.
/datum/team/mothbug_colony/proc/give_omen()
	omen_given = TRUE
	var/list/hearers = list()
	for(var/mob/living/simple_animal/mothbug/moth as anything in get_living_members())
		for(var/mob/living/carbon/human/listener in hearers(10, moth))
			hearers |= listener
	for(var/mob/living/carbon/human/listener as anything in hearers)
		to_chat(listener, span_notice("Something flutters softly in the dark nearby, and a faint smell of old wardrobes hangs in the air."))
	message_admins("The mothbug colony has eaten [round(fabric_eaten)] silk of fabric; [length(hearers)] nearby townsfolk got a hint.")

/datum/team/mothbug_colony/proc/get_living_members()
	. = list()
	for(var/datum/mind/member as anything in members)
		var/mob/living/body = member.current
		if(istype(body, /mob/living/simple_animal/mothbug) && body.stat != DEAD)
			. += body

/datum/team/mothbug_colony/proc/update_peak_size()
	peak_size = max(peak_size, length(get_living_members()))

/datum/team/mothbug_colony/roundend_report()
	var/report = ..()
	var/living = length(get_living_members())
	return "[report]The colony ate [round(fabric_eaten)] silk worth of fabric, laid [eggs_laid] egg\s and grew to [peak_size] at its largest. [living ? "[living] mothbug\s still hide in the dark." : "The colony was wiped out."]<br>"

/datum/objective/mothbug_feast
	name = "mothbug feast"
	target_amount = MOTHBUG_FEAST_GOAL

/datum/objective/mothbug_feast/New()
	. = ..()
	explanation_text = "As a colony, eat [target_amount] silk worth of the town's fabric."

/datum/objective/mothbug_feast/check_completion()
	var/datum/team/mothbug_colony/colony = team
	return istype(colony) && colony.fabric_eaten >= target_amount

/datum/objective/mothbug_brood
	name = "mothbug brood"
	target_amount = MOTHBUG_BROOD_GOAL

/datum/objective/mothbug_brood/New()
	. = ..()
	explanation_text = "Grow the colony to [target_amount] living mothbugs at once."

/datum/objective/mothbug_brood/check_completion()
	var/datum/team/mothbug_colony/colony = team
	return istype(colony) && colony.peak_size >= target_amount

/datum/objective/mothbug_survive
	name = "mothbug survival"
	explanation_text = "Keep at least one mothbug alive to the end of the round."

/datum/objective/mothbug_survive/check_completion()
	var/datum/team/mothbug_colony/colony = team
	return istype(colony) && length(colony.get_living_members()) > 0
