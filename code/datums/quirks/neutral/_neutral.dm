
/datum/quirk/neutral
	abstract_type = /datum/quirk/neutral
	quirk_category = QUIRK_NEUTRAL
	point_value = 0

/datum/quirk/neutral/large_sized
	name = "Large Build"
	desc = "You're taller and broader than most. This makes you more imposing but also harder to miss."

/datum/quirk/neutral/large_sized/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(1.15, 1.15)
	H.update_transform()

/datum/quirk/neutral/large_sized/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(0.87, 0.87)
	H.update_transform()

/datum/quirk/neutral/small_sized
	name = "Small Build"
	desc = "You're smaller and more compact than most. This makes you less imposing but potentially harder to hit."

/datum/quirk/neutral/small_sized/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(0.9, 0.9)
	H.update_transform()

/datum/quirk/neutral/small_sized/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(1.11, 1.11)
	H.update_transform()

/datum/quirk/neutral/generous_figure
	name = "Generous Figure"
	desc = "I can select the largest breast, butt, and belly sizes in the body feature customizer."
	random_exempt = TRUE
	preview_render = FALSE

/datum/quirk/neutral/witless_pixie
	name = "Witless Pixie"
	desc = "By some cruel twist of fate, you have been born a dainty-minded, dim-witted klutz. Yours is a life of constant misdirection, confusion and general incompetence. It is no small blessing your dazzling looks make up for this, sometimes."

/datum/quirk/neutral/witless_pixie/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, list(STAT_INTELLIGENCE = rand(-2, -5)))

	REMOVE_TRAIT(H, TRAIT_BEAUTIFUL, QUIRK_TRAIT)
	REMOVE_TRAIT(H, TRAIT_UGLY, QUIRK_TRAIT)
	REMOVE_TRAIT(H, TRAIT_FISHFACE, QUIRK_TRAIT)

	if(prob(50))
		ADD_TRAIT(H, TRAIT_BEAUTIFUL, QUIRK_TRAIT)
	else if(prob(30))
		ADD_TRAIT(H, TRAIT_UGLY, QUIRK_TRAIT)

/datum/quirk/neutral/witless_pixie/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	// Remove stat penalty (inverse of what was applied)
	// This is approximate since we randomized on spawn
	H.adjust_stat_modifier(STATMOD_QUIRK, list(STAT_INTELLIGENCE = 3))

/datum/quirk/neutral/ugly
	name = "Ugly"
	desc = "Your appearance turns heads... in all the wrong ways. With features ranging from unsightly to grotesque, you likely have yet to find anyone impressed with your looks."

/datum/quirk/neutral/ugly/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner

	REMOVE_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
	REMOVE_TRAIT(H, TRAIT_FISHFACE, TRAIT_GENERIC)

	ADD_TRAIT(H, TRAIT_UGLY, TRAIT_GENERIC)

/datum/quirk/neutral/ugly/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	REMOVE_TRAIT(H, TRAIT_UGLY, TRAIT_GENERIC)

/datum/quirk/neutral/virgin
	name = "Virgin"
	desc = "I am a virgin, whether truly, by magic or plot holes. Vampires and cultists are likely to lust for my blood."
	traits_to_add = list(TRAIT_VIRGIN)

/datum/quirk/neutral/selfawaregeni
	name = "Sensitiveness"
	desc = "I can tell more about my private bits."
	desc_hint = "May be spammy, exact liquid information and alerts e.t.c."
	point_value = 0

/datum/quirk/neutral/free_flowing
	name = "Free-Flowing"
	desc = "My fluids pool into proper puddles on the ground instead of scattering as stray drops."
	desc_hint = "Genital fluids form liquid puddles directly, bypassing the drip decals."
	point_value = 0
