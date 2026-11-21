/mob/living/carbon/human/species/rakshari
	race = /datum/species/rakshari

/datum/attribute_holder/sheet/job/species/rakshari
	raw_attribute_list = list(
		STAT_STRENGTH = -2,
		STAT_PERCEPTION = 2,
		STAT_CONSTITUTION = -2,
		STAT_SPEED = 2,
	)

/datum/species/rakshari
	name = "Rakshari"
	id = SPEC_ID_RAKSHARI
	changesource_flags = WABBAJACK
	native_language = "Zakhara"

	desc = "Rakshari origins trace back to nomadic desert tribes, \
	whose survival in the harsh sands cultivated a culture steeped in resilience, cunning, and adaptability. \
	\n\n\
	Over centuries, the Rakshari united under the banners of powerful Zakhara merchant-kings and warlords,\
	transforming their scattered clans into a dominant slaver force across the region. \
	They would often raid weaker settlements and rival caravans, \
	capturing slaves to fuel their expanding cities and economies. \
	Practice of this was justified through religious doctrines, \
	venerating strength and dominance as divine virtues. \
	\n\n\
	As they further attached themselves to Zakharani, however, \
	their people would integrate more sophisticated forms of servitude, \
	such as indentured contracts and debt bondage. \
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. EXPECT A MORE DIFFICULT EXPERIENCE. PLAY AT YOUR OWN RISK."

	use_skintones = TRUE
	default_color = "FFFFFF"

	possible_ages = NORMAL_AGES_LIST

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP, TRAIT_KITTEN_MOM)

	statsheet_male = /datum/attribute_holder/sheet/job/species/rakshari

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/rakshari.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/rakshari.dmi'
	body_hair_materials = BODY_HAIR_MATERIALS_FURRED

	exotic_bloodtype = /datum/blood_type/human/rakshari

	order_num = 16

	offset_features_m = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,-1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,1),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,2),\
		OFFSET_ARMOR = list(0,1),\
		OFFSET_UNDIES = list(0,-1),\
	)
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/rakshari,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/rakshari,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory/rakshari,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/tail/rakshari,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
	)
	body_markings = list(
		/datum/body_marking/tonage,
		/datum/body_marking/womb_tattoo,
		/datum/body_marking/butterfly,
		/datum/body_marking/waist,
		/datum/body_marking/diagonal_eyes,
		/datum/body_marking/wide_eyes,
		/datum/body_marking/stripes,
		/datum/body_marking/plain,
		/datum/body_marking/spotted,
		/datum/body_marking/tiger,
		/datum/body_marking/tiger/dark,
		/datum/body_marking/sock,
		/datum/body_marking/sock/tertiary,
		/datum/body_marking/socklonger,
		/datum/body_marking/tips,
		/datum/body_marking/bellyscale,
		/datum/body_marking/kobold_scale,
		/datum/body_marking/bellyscaleslim,
		/datum/body_marking/bellyscalesmooth,
		/datum/body_marking/bellyscaleslimsmooth,
		/datum/body_marking/buttscale,
		/datum/body_marking/belly,
		/datum/body_marking/bellyslim,
		/datum/body_marking/tie,
		/datum/body_marking/butt,
		/datum/body_marking/tiesmall,
		/datum/body_marking/backspots,
		/datum/body_marking/front,
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
	)
	descriptor_choices = list(
		/datum/descriptor_choice/trait,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/fur,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one,
		/datum/descriptor_choice/prominent_two,
		/datum/descriptor_choice/prominent_three,
		/datum/descriptor_choice/prominent_four,
	)
	COOLDOWN_DECLARE(cat_meow_cooldown)

/datum/species/rakshari/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/zalad)
	add_verb(C, /mob/living/carbon/human/species/rakshari/verb/emote_meow)
	add_verb(C, /mob/living/carbon/human/species/rakshari/verb/emote_purr)
	var/datum/action/cooldown/keen_nose/sniff_action = new(C)
	sniff_action.Grant(C)
	to_chat(C, "<span class='info'>I can speak Zakhara with ,z before my speech.</span>")

/datum/species/rakshari/check_roundstart_eligible()
	return TRUE

/datum/species/rakshari/after_creation(mob/living/carbon/C)
	..()
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/zalad)

/datum/species/rakshari/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(prob(1) && !(H.rogue_sneaking))
		if(!COOLDOWN_FINISHED(src, cat_meow_cooldown))
			return
		var/emote = "meow"
		if(prob(15))
			emote = "purr"
		H.emote(emote, forced = TRUE)

		COOLDOWN_START(src, cat_meow_cooldown, 5 MINUTES)

/datum/species/rakshari/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	for(var/datum/action/cooldown/keen_nose/sniff_action in C.actions)
		if(sniff_action.target == C)
			qdel(sniff_action)

/datum/species/rakshari/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/rakshari/get_skin_list()
	return sortList(list(
		"Mountain Rakshari" = SKIN_TONE_WHITE3, // - (White 3)
		"City Rakshari" = SKIN_TONE_WHITE4, // - (White 4)
		"Desert Rakshari" = SKIN_TONE_MEDIT1, // - (Mediterranean 1)
		"Deep Desert Rakshari" = SKIN_TONE_LATIN, // - (Latin)
		"Oasis Rakshari" = SKIN_COLOR_HOMUNCULUS, // - (Grey-blue)
		"Oasis Shade Rakshari" = SKIN_COLOR_NIGHTSHADE, // - (Black-blue)
		"Quicksand Rakshari" = SKIN_COLOR_QUICKSAND, // Orange, apparently sphynx cats can be orange, who knew!
	))

/datum/species/rakshari/get_hairc_list()
	return sortList(list(
	"blond - pale" = "9d8d6e",
	"blond - dirty" = "88754f",
	"blond - drywheat" = "d5ba7b",
	"blond - strawberry" = "c69b71",

	"brown - mud" = "362e25",
	"brown - oats" = "584a3b",
	"brown - grain" = "58433b",
	"brown - soil" = "48322a",
	"brown - bark" = "2d1300",

	"black - oil" = "181a1d",
	"black - cave" = "201616",
	"black - rogue" = "2b201b",
	"black - midnight" = "1d1b2b",

	"orange - rust" = "bc5e35",
	"orange - flame" = "b24c2e",
	))

/// Keen nose: crowd bearing radius, per-mob line radius, crowd cell size, and distance wording bands.
#define KEEN_NOSE_RANGE 40
#define KEEN_NOSE_DETAIL_RANGE 20
#define KEEN_NOSE_CROWD_CELL_SIZE 8
#define KEEN_NOSE_CLOSE_DISTANCE 6
#define KEEN_NOSE_FAR_DISTANCE 12

/datum/action/cooldown/keen_nose
	name = "Sniff for scents"
	desc = "Smell the air to detect living beings at a distance."
	button_icon_state = "shieldsparkles"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 30 SECONDS

/datum/action/cooldown/keen_nose/proc/get_smell_message(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		var/mob/living/carbon/human/sniffer = owner
		var/datum/species/target_species = target_human.dna?.species
		var/datum/species/sniffer_species = sniffer?.dna?.species

		if(IS_WEREWOLF(target_human) && IS_WEREWOLF(sniffer))
			return "You smell [target_human.name], a fellow werewolf"
		var/datum/status_effect/werewolf_scent_mark/pack_mark = target_human.has_status_effect(/datum/status_effect/werewolf_scent_mark)
		if(pack_mark?.is_smelled_by(sniffer))
			return "You smell [target_human.name], heavy with the scent of the pack"
		if((target_human.mob_biotypes & MOB_UNDEAD) || target_human.stat == DEAD || target_human.hygiene <= HYGIENE_LEVEL_DIRTY)
			return "Eugh! You smell something rotten"
		if(!target_species || !sniffer_species)
			return "You smell someone unfamiliar"
		if(istype(target_species, /datum/species/rakshari) && istype(sniffer_species, /datum/species/rakshari))
			return "You smell [target_human.name], a fellow rakshari"

		var/static/list/animal_scent_species = list(
			SPEC_ID_BEASTKIN,
			SPEC_ID_BEASTKINSMALL,
			SPEC_ID_DRAGONBORN,
			SPEC_ID_FLUVIAN,
			SPEC_ID_GNOLL,
			SPEC_ID_GOBLIN,
			SPEC_ID_HALF_BEASTKINSMALL,
			SPEC_ID_HOLLOWKIN,
			SPEC_ID_HUMAN_SPACE,
			SPEC_ID_KOBOLD,
			SPEC_ID_KOBOLD_FORMIKRAG,
			SPEC_ID_LIZARDFOLK,
			SPEC_ID_ORC,
			SPEC_ID_RAKSHARI,
			SPEC_ID_ROUSMAN,
			SPEC_ID_TABAXI,
			SPEC_ID_TAUR_KIN,
			SPEC_ID_YUANTI,
		)
		if(target_species.id in animal_scent_species)
			return "You smell an animal"
		if(target_species.id in RACES_PLAYER_NONDISCRIMINATED)
			return "You smell someone humanlike"
		if(target_species.id in RACES_PLAYER_HERETICAL_RACE)
			return "Ugh! You smell something tainted"
		return "You smell someone unfamiliar"

	if(istype(target, /mob/living/simple_animal))
		return "You smell an animal"
	if((target.mob_biotypes & MOB_UNDEAD) || target.stat == DEAD)
		return "Eugh! You smell something rotten"
	return "You smell something"

/datum/action/cooldown/keen_nose/Activate(atom/target)
	. = ..()
	if(!owner)
		return

	var/list/smelled_targets = get_smelled_targets()
	owner.visible_message(span_notice("[owner] sniffs the air!"))
	playsound(owner, 'sound/items/sniff.ogg', 70, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'sound/items/sniff.ogg', 70, TRUE), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_sniff), smelled_targets), 1.5 SECONDS)

/// Every other living mob within the nose's range on the owner's z-level; one range() pass.
/datum/action/cooldown/keen_nose/proc/get_smelled_targets()
	. = list()
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf)
		return
	for(var/mob/living/smell_target in range(KEEN_NOSE_RANGE, owner_turf))
		if(smell_target != owner)
			. += smell_target

/datum/action/cooldown/keen_nose/proc/finish_sniff(list/smelled_targets)
	if(QDELETED(owner) || QDELETED(src))
		return

	playsound(owner, 'sound/items/sniff.ogg', 100, TRUE)
	var/mob/living/sniffer = owner
	if(istype(sniffer))
		sniffer.reveal_fluid_scent_trails()
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf)
		return
	var/reported = FALSE
	for(var/mob/living/smell_target as anything in smelled_targets)
		if(QDELETED(smell_target))
			continue
		var/turf/target_turf = get_turf(smell_target)
		if(!target_turf || target_turf.z != owner_turf.z)
			continue
		var/distance = get_dist(owner_turf, target_turf)
		// Past the detail range only a pack-marked scent stands out on its own.
		if(distance > KEEN_NOSE_DETAIL_RANGE && !smells_pack_mark(smell_target))
			continue
		var/distance_phrase
		if(smell_target.loc == owner.loc)
			distance_phrase = " right beside you"
		else
			distance_phrase = " [get_distance_phrase(distance, dir2text(get_dir(owner, smell_target)))]"

		var/message = get_smell_message(smell_target)
		if(message)
			to_chat(owner, span_notice("[message][get_fluid_scent_note(smell_target)][distance_phrase]!"))
			reported = TRUE

	var/crowd_line = get_crowd_bearing_line(smelled_targets)
	if(crowd_line)
		to_chat(owner, span_notice(crowd_line))
	else if(!reported)
		to_chat(owner, span_notice("You smell the air, but it is empty of every scent save your own."))

/datum/action/cooldown/keen_nose/proc/smells_pack_mark(mob/living/target)
	var/datum/status_effect/werewolf_scent_mark/pack_mark = target.has_status_effect(/datum/status_effect/werewolf_scent_mark)
	return pack_mark?.is_smelled_by(owner)

/datum/action/cooldown/keen_nose/proc/get_distance_phrase(distance, direction)
	if(distance <= KEEN_NOSE_CLOSE_DISTANCE)
		return "close to the [direction]"
	if(distance > KEEN_NOSE_FAR_DISTANCE)
		return "far to the [direction]"
	return "to the [direction]"

/// Bearing to the densest 8x8 cell of living, non-adjacent mobs; people with a mind count double.
/datum/action/cooldown/keen_nose/proc/get_crowd_bearing_line(list/smelled_targets)
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf)
		return null
	var/list/cell_weights = list()
	var/list/cell_x_totals = list()
	var/list/cell_y_totals = list()
	var/list/cell_counts = list()
	var/best_cell
	for(var/mob/living/smell_target as anything in smelled_targets)
		if(QDELETED(smell_target) || smell_target.stat == DEAD)
			continue
		var/turf/target_turf = get_turf(smell_target)
		if(!target_turf || target_turf.z != owner_turf.z || get_dist(owner_turf, target_turf) <= 1)
			continue
		var/cell = "[round(target_turf.x / KEEN_NOSE_CROWD_CELL_SIZE)]_[round(target_turf.y / KEEN_NOSE_CROWD_CELL_SIZE)]"
		cell_weights[cell] += ((ishuman(smell_target) && (smell_target.client || smell_target.mind)) ? 2 : 1)
		cell_x_totals[cell] += target_turf.x
		cell_y_totals[cell] += target_turf.y
		cell_counts[cell] += 1
		if(!best_cell || cell_weights[cell] > cell_weights[best_cell])
			best_cell = cell
	if(!best_cell)
		return null
	var/crowd_count = cell_counts[best_cell]
	var/turf/crowd_turf = locate(round(cell_x_totals[best_cell] / crowd_count), round(cell_y_totals[best_cell] / crowd_count), owner_turf.z)
	return "The thickest scent of people lies [get_crowd_bearing_text(owner_turf, crowd_turf)]."

/// Werewolves read the distance like their lair tracker; other noses use the per-mob wording.
/datum/action/cooldown/keen_nose/proc/get_crowd_bearing_text(turf/from_turf, turf/to_turf)
	var/direction = get_precise_direction_between(from_turf, to_turf)
	if(!direction)
		return "all around you"
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(owner)
	if(wolf)
		return "[wolf.get_werewolf_lair_distance_text(from_turf, to_turf)] to the [direction]"
	return get_distance_phrase(get_dist(from_turf, to_turf), direction)

#undef KEEN_NOSE_RANGE
#undef KEEN_NOSE_DETAIL_RANGE
#undef KEEN_NOSE_CROWD_CELL_SIZE
#undef KEEN_NOSE_CLOSE_DISTANCE
#undef KEEN_NOSE_FAR_DISTANCE

