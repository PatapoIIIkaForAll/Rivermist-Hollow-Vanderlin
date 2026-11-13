/datum/reagent/drug
	name = "Drug"
	metabolization_rate = 0.1
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M, efficiency)
	M.set_drugginess(30 SECONDS * efficiency)
	if(prob(5))
		if(M.gender == FEMALE)
			M.emote(pick("twitch_s","giggle"))
		else
			M.emote(pick("twitch_s","chuckle"))
	if(M.has_quirk(/datum/quirk/negative/addiction/smoker))
		M.sate_addiction(/datum/quirk/negative/addiction/smoker)
	..()

/datum/reagent/drug/space_drugs/on_mob_metabolize(mob/living/M)
	..()
	M.set_drugginess(30 SECONDS)
	M.apply_status_effect(/datum/status_effect/buff/weed)
	M.overlay_fullscreen("weedsm", /atom/movable/screen/fullscreen/weedsm)

/datum/reagent/drug/space_drugs/on_mob_end_metabolize(mob/living/M)
	M.set_drugginess(0)
	M.clear_fullscreen("weedsm")
	M.remove_status_effect(/datum/status_effect/buff/weed)

/atom/movable/screen/fullscreen/weedsm
	icon_state = "smok"
	plane = BLACKNESS_PLANE
	layer = AREA_LAYER
	blend_mode = 0
	alpha = 100
	show_when_dead = FALSE

/atom/movable/screen/fullscreen/weedsm/Initialize()
	. = ..()
//			if(L.has_status_effect(/datum/status_effect/buff/weed))
	filters += filter(type="angular_blur",x=5,y=5,size=1)

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	. = ..()
	to_chat(M, "<span class='danger'>I start tripping hard!</span>")

/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 999
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM


/datum/reagent/drug/nicotine/on_mob_end_metabolize(mob/living/M)
//	M.remove_stress(/datum/stress_event/pweed)
	..()

/datum/reagent/drug/nicotine/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stress_event/pweed)
	..()

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M, efficiency)
	if(M.has_quirk(/datum/quirk/negative/addiction/smoker))
		M.sate_addiction(/datum/quirk/negative/addiction/smoker)
	..()
	. = 1

/datum/reagent/drug/nicotine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()
	. = 1

/datum/reagent/drug/hallucinogen
	name = "Hallucinogen"
	description = "A stronghallucinogenic drug."
	color = "#E700E7" // rgb: 231, 0, 231
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "the clouds"
	overdose_threshold = 30

/datum/reagent/drug/hallucinogen/on_mob_life(mob/living/carbon/psychonaut, seconds_per_tick, metabolization_ratio)
	. = ..()
	psychonaut.slurring = max(psychonaut.slurring, 2.5 SECONDS * metabolization_ratio * seconds_per_tick)

	switch(current_cycle)
		if(2 to 6)
			if(SPT_PROB(5, seconds_per_tick))
				psychonaut.emote(pick("twitch","giggle"))
		if(6 to 11)
			psychonaut.set_jitter_if_lower(50 SECONDS * metabolization_ratio * seconds_per_tick)
			if(SPT_PROB(10, seconds_per_tick))
				psychonaut.emote(pick("twitch","giggle"))
		if (11 to INFINITY)
			psychonaut.set_jitter_if_lower(100 SECONDS * metabolization_ratio * seconds_per_tick)
			if(SPT_PROB(16, seconds_per_tick))
				psychonaut.emote(pick("twitch","giggle"))

/datum/reagent/drug/hallucinogen/on_mob_metabolize(mob/living/psychonaut)
	. = ..()

	if(!psychonaut.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	// Info for non-matrix plebs like me!

	// This doesn't change the RGB matrixes directly at all. Instead, it shifts all the colors' Hue by 33%,
	// Shifting them up the color wheel, turning R to G, G to B, B to R, making a psychedelic effect.
	// The second moves them two colors up instead, turning R to B, G to R, B to G.
	// The third does a full spin, or resets it back to normal.
	// Imagine a triangle on the color wheel with the points located at the color peaks, rotating by 90 degrees each time.
	// The value with decimals is the Hue. The rest are Saturation, Luminosity, and Alpha, though they're unused here.

	// The filters were initially named _green, _blue, _red, despite every filter changing all the colors. It caused me a 2-years-long headache.

	var/list/col_filter_identity = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.000,0,0,0)
	var/list/col_filter_shift_once = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.333,0,0,0)
	var/list/col_filter_shift_twice = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0.666,0,0,0)
	var/list/col_filter_reset = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 1.000,0,0,0) //visually this is identical to the identity

	game_plane_master_controller.add_filter("rainbow", 10, color_matrix_filter(col_filter_reset, FILTER_COLOR_HSL))

	for(var/filter in game_plane_master_controller.get_filters("rainbow"))
		animate(filter, color = col_filter_identity, time = 0 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = col_filter_shift_once, time = 4 SECONDS)
		animate(color = col_filter_shift_twice, time = 4 SECONDS)
		animate(color = col_filter_reset, time = 4 SECONDS)

	game_plane_master_controller.add_filter("psilocybin_wave", 1, list("type" = "wave", "size" = 2, "x" = 32, "y" = 32))

	for(var/filter in game_plane_master_controller.get_filters("psilocybin_wave"))
		animate(filter, time = 64 SECONDS, loop = -1, easing = LINEAR_EASING, offset = 32, flags = ANIMATION_PARALLEL)

/datum/reagent/drug/hallucinogen/on_mob_end_metabolize(mob/living/psychonaut)
	. = ..()
	if(!psychonaut.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("rainbow")
	game_plane_master_controller.remove_filter("psilocybin_wave")

/datum/reagent/drug/hallucinogen/overdose_process(mob/living/psychonaut, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(SPT_PROB(10, seconds_per_tick))
		psychonaut.emote(pick("twitch","drool","moan"))

/datum/reagent/drug/hallucinogen_concetrate
	name = "Raw Hallucinogen Extract"
	description = "A crude concentration of psychoactive compounds. Unstable and incompletely processed."
	color = "#b000b0"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM
	taste_description = " something deeply wrong"

/datum/reagent/drug/hallucinogen_concetrate/on_mob_life(mob/living/carbon/psychonaut, seconds_per_tick, metabolization_ratio)
	. = ..()
	// weaker version of base hallucinogen — slurring only, mild jitter at high cycle
	psychonaut.slurring = max(psychonaut.slurring, 1 SECONDS * metabolization_ratio * seconds_per_tick)
	if(current_cycle >= 8)
		psychonaut.set_jitter_if_lower(20 SECONDS * metabolization_ratio * seconds_per_tick)

/datum/reagent/drug/skum
	name = "Moonlily"
	description = "A moon-pale refinement of ozium and pure moondust. It grants blissful endurance and freedom from pain at a steep cost."
	color = "#878178"
	taste_description = "cold bliss"
	overdose_threshold = 10
	addiction_threshold = 6
	metabolization_rate = 0.2

/datum/reagent/drug/skum/on_mob_life(mob/living/carbon/M, efficiency)
	SEND_SIGNAL(M, COMSIG_DRUG_INDULGE)
	if(M.has_quirk(/datum/quirk/negative/addiction/junkie))
		M.sate_addiction(/datum/quirk/negative/addiction/junkie)
	M.set_drugginess(90 SECONDS * efficiency)
	if(prob(5))
		if(M.gender == FEMALE)
			M.emote(pick("giggle", "twitch_s"))
		else
			M.emote(pick("chuckle", "twitch_s"))
	. = ..()

/datum/reagent/drug/skum/on_mob_metabolize(mob/living/M)
	. = ..()
	M.set_drugginess(90 SECONDS)
	M.apply_status_effect(/datum/status_effect/buff/skum)
	M.overlay_fullscreen("weedsm", /atom/movable/screen/fullscreen/weedsm)

/datum/reagent/drug/skum/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M.clear_fullscreen("weedsm")
	M.remove_status_effect(/datum/status_effect/buff/skum)

/datum/reagent/drug/skum/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.25 * REM, 0)
	. = ..()

/datum/reagent/drug/skum/overdose_start(mob/living/M)
	. = ..()
	M.playsound_local(get_turf(M), 'sound/misc/heroin_rush.ogg', 100, FALSE)
	M.visible_message(span_warning("Blood runs from [M]'s nose."))

/datum/reagent/drug/bimb
	name = "Blush"
	description = "A treacherously sweet pink draught that smothers reason and leaves the drinker profoundly foolish."
	color = "#f594ef"
	taste_description = "cloying rose and bitter nightshade"
	overdose_threshold = 25
	metabolization_rate = 0.1

/datum/reagent/drug/bimb/on_mob_life(mob/living/carbon/M, efficiency)
	SEND_SIGNAL(M, COMSIG_DRUG_INDULGE)
	if(M.has_quirk(/datum/quirk/negative/addiction/junkie))
		M.sate_addiction(/datum/quirk/negative/addiction/junkie)
	if(prob(10 * efficiency))
		M.adjust_confusion(2 SECONDS * efficiency)
	if(prob(5 * efficiency))
		M.emote(pick("giggle", "twitch_s"))
	. = ..()

/datum/reagent/drug/bimb/on_mob_metabolize(mob/living/M)
	. = ..()
	M.apply_status_effect(/datum/status_effect/debuff/dumb)

/datum/reagent/drug/bimb/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M.remove_status_effect(/datum/status_effect/debuff/dumb)

/datum/reagent/drug/bimb/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM, 0)
	M.adjust_drowsiness(4 SECONDS)
	M.adjust_confusion(3 SECONDS)
	. = ..()

/datum/reagent/drug/madness
	name = "Grave Dream"
	description = "A wine-dark corpse-cap draught whose visions drag waking minds through terror and delirium."
	color = "#9a1e54"
	taste_description = "mushrooms and old graves"
	metabolization_rate = 0.5
	overdose_threshold = 15
	var/hallucination_prob = 25
	var/next_hallucination = 0
	var/atom/movable/screen/fullscreen/maniac/hallucinations

/datum/reagent/drug/madness/on_mob_metabolize(mob/living/M)
	. = ..()
	hallucinations = M.overlay_fullscreen("maniac", /atom/movable/screen/fullscreen/maniac)

/datum/reagent/drug/madness/on_mob_life(mob/living/carbon/M, efficiency)
	SEND_SIGNAL(M, COMSIG_DRUG_INDULGE)
	if(M.has_quirk(/datum/quirk/negative/addiction/junkie))
		M.sate_addiction(/datum/quirk/negative/addiction/junkie)
	M.set_drugginess(60 SECONDS * efficiency)
	M.set_dizzy(8 SECONDS * efficiency)
	if(world.time >= next_hallucination && prob(hallucination_prob * efficiency))
		hallucinations?.jumpscare(M)
		next_hallucination = world.time + rand(8 SECONDS, 15 SECONDS)
	. = ..()

/datum/reagent/drug/madness/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M.clear_fullscreen("maniac")
	hallucinations = null
	next_hallucination = 0

/datum/reagent/drug/madness/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * REM, 0)
	M.adjust_confusion(4 SECONDS)
	if(prob(10))
		hallucinations?.jumpscare(M, fade_in = 0.1 SECONDS, duration = 1 SECONDS)
	. = ..()

