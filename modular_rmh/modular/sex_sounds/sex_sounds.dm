// Picked sounds for mouth work, slaps and rubbing: one rule per act for every action that does it.

/datum/sex_action
	/// Thrust counter for the throat actions, which gluck or gag every other thrust.
	var/mouth_thrusts = 0

// ---- Mouths ----

/// This mob's mouth at work; kinds: suck, slurp, gluck, gag, choke, kiss, lick. Returns the clip.
/mob/living/proc/make_mouth_noise(kind = "suck", vol = 25)
	if(rogue_sneaking || alpha <= 100)
		vol *= 0.5
	var/clip = get_mouth_noise(kind)
	playsound(get_sense_anchor(), clip, vol, TRUE, -2, ignore_walls = FALSE)
	return clip

/// One clip for [kind] in this mob's voice; voiced kinds split by gender, the old mouth pair stays the fallback.
/mob/living/proc/get_mouth_noise(kind)
	var/female = gender == FEMALE
	switch(kind)
		if("suck")
			if(female)
				return pick('modular_rmh/sound/erp/suck_f1.ogg', 'modular_rmh/sound/erp/suck_f2.ogg', 'modular_rmh/sound/erp/suck_f3.ogg')
			return pick('modular_rmh/sound/erp/suck_m1.ogg', 'modular_rmh/sound/erp/suck_m2.ogg', 'modular_rmh/sound/erp/suck_m3.ogg')
		if("slurp")
			return pick('modular_rmh/sound/erp/slurp1.ogg', 'modular_rmh/sound/erp/slurp2.ogg', 'modular_rmh/sound/erp/slurp3.ogg')
		if("gluck")
			if(female)
				return pick('modular_rmh/sound/erp/gluck_f1.ogg', 'modular_rmh/sound/erp/gluck_f2.ogg', 'modular_rmh/sound/erp/gluck_f3.ogg')
			return pick('modular_rmh/sound/erp/gluck_m1.ogg', 'modular_rmh/sound/erp/gluck_m2.ogg', 'modular_rmh/sound/erp/gluck_m3.ogg')
		if("gag")
			if(female)
				return pick('modular_rmh/sound/erp/gag_f1.ogg', 'modular_rmh/sound/erp/gag_f2.ogg')
			return pick('modular_rmh/sound/erp/gag_m1.ogg', 'modular_rmh/sound/erp/gag_m2.ogg')
		if("choke")
			return female ? 'modular_rmh/sound/erp/choke_f1.ogg' : 'modular_rmh/sound/erp/choke_m1.ogg'
		if("kiss")
			return pick('modular_rmh/sound/erp/kiss1.ogg', 'modular_rmh/sound/erp/kiss2.ogg', 'modular_rmh/sound/erp/kiss3.ogg')
		if("lick")
			return pick('modular_rmh/sound/erp/lick1.ogg', 'modular_rmh/sound/erp/lick2.ogg', 'modular_rmh/sound/erp/lick3.ogg')
	if(female)
		return pick('sound/misc/mat/girlmouth (1).ogg', 'sound/misc/mat/girlmouth (2).ogg')
	return pick('sound/misc/mat/guymouth (2).ogg', 'sound/misc/mat/guymouth (3).ogg', 'sound/misc/mat/guymouth (4).ogg', 'sound/misc/mat/guymouth (5).ogg')

/// Oral by force: a suck when gentle, a slurp at mid force, a gluck when the head is driven down.
/datum/sex_action/proc/get_oral_noise_kind()
	switch(force)
		if(SEX_FORCE_LOW)
			return "suck"
		if(SEX_FORCE_MID)
			return "slurp"
	return "gluck"

/// The wet slide of a cock into [target]'s throat, played when a throat action starts.
/datum/sex_action/proc/play_throat_entry(mob/living/target, vol)
	mouth_thrusts = 0
	playsound(target, pick('modular_rmh/sound/erp/throat_slide1.ogg', 'modular_rmh/sound/erp/throat_slide2.ogg'), vol, TRUE, -2, ignore_walls = FALSE)

/// Every other thrust [target] glucks, or gags at high force; returns the clip or null on the quiet thrusts.
/datum/sex_action/proc/play_throat_thrust(mob/living/target, vol)
	mouth_thrusts++
	if(mouth_thrusts % 2)
		return null
	return target.make_mouth_noise(force >= SEX_FORCE_HIGH ? "gag" : "gluck", vol)

// ---- Slaps ----

/// A slap for [kind] by force: spanks soft to hard, belt-punish smacks at high force and up, flat claps for breasts and pussy, the ball slap; old foley otherwise.
/datum/sex_action/proc/get_slap_sound(kind = "spank")
	switch(kind)
		if("spank")
			if(force >= SEX_FORCE_HIGH)
				return pick('modular_rmh/sound/effects/slap1.ogg', 'modular_rmh/sound/effects/slap2.ogg')
			if(force >= SEX_FORCE_MID)
				return pick('modular_rmh/sound/erp/spank_hard1.ogg', 'modular_rmh/sound/erp/spank_hard3.ogg')
			return pick('modular_rmh/sound/erp/spank_soft1.ogg', 'modular_rmh/sound/erp/spank_soft2.ogg', 'modular_rmh/sound/erp/spank_soft3.ogg')
		if("clap")
			if(force >= SEX_FORCE_EXTREME)
				return pick('modular_rmh/sound/erp/crack1.ogg', 'modular_rmh/sound/erp/crack2.ogg')
			if(force >= SEX_FORCE_HIGH)
				return pick('modular_rmh/sound/erp/clap1.ogg', 'modular_rmh/sound/erp/clap2.ogg')
			return pick('modular_rmh/sound/erp/spank_soft1.ogg', 'modular_rmh/sound/erp/spank_soft2.ogg', 'modular_rmh/sound/erp/spank_soft3.ogg')
		if("balls")
			return pick('modular_rmh/sound/erp/ball_slap1.ogg', 'modular_rmh/sound/erp/ball_slap2.ogg')
	return pick('sound/foley/slap.ogg', 'sound/foley/smackspecial.ogg')

// ---- Rubbing ----

/// Rubbing at [at]; kinds finger, handjob, fap, skin, grind, boob; [hole_slot] names the hole whose lube decides wet or dry.
/datum/sex_action/proc/play_rub_sound(kind, mob/living/at, vol = 30, hole_slot)
	var/clip = get_rub_sound(kind, at, hole_slot)
	playsound(at, clip, vol, TRUE, -2, ignore_walls = FALSE)
	return clip

/// One clip for [kind]: a slick hole or a coated cock sounds wet, force picks the stroke; the old fingering clip otherwise.
/datum/sex_action/proc/get_rub_sound(kind, mob/living/at, hole_slot)
	switch(kind)
		if("finger")
			if(hole_slot && is_hole_slick(at, hole_slot))
				return pick('modular_rmh/sound/erp/finger_wet1.ogg', 'modular_rmh/sound/erp/finger_wet2.ogg', 'modular_rmh/sound/erp/finger_wet3.ogg')
			return pick('modular_rmh/sound/erp/finger_dry1.ogg', 'modular_rmh/sound/erp/finger_dry2.ogg', 'modular_rmh/sound/erp/finger_dry3.ogg')
		if("handjob")
			return pick('modular_rmh/sound/erp/handjob1.ogg', 'modular_rmh/sound/erp/handjob2.ogg', 'modular_rmh/sound/erp/handjob3.ogg')
		if("fap")
			if(force >= SEX_FORCE_HIGH || groin_is_coated(at))
				return pick('modular_rmh/sound/erp/handjob1.ogg', 'modular_rmh/sound/erp/handjob2.ogg', 'modular_rmh/sound/erp/handjob3.ogg')
			return pick('modular_rmh/sound/erp/fap_dry1.ogg', 'modular_rmh/sound/erp/fap_dry2.ogg')
		if("skin")
			return pick('modular_rmh/sound/erp/skin_rub1.ogg', 'modular_rmh/sound/erp/skin_rub2.ogg', 'modular_rmh/sound/erp/skin_rub3.ogg')
		if("grind")
			return pick('modular_rmh/sound/erp/grind1.ogg', 'modular_rmh/sound/erp/grind2.ogg')
		if("boob")
			if(groin_is_coated(at))
				return pick('modular_rmh/sound/erp/boob_wet1.ogg', 'modular_rmh/sound/erp/boob_wet2.ogg')
			return pick('modular_rmh/sound/erp/boob_dry1.ogg', 'modular_rmh/sound/erp/boob_dry2.ogg')
	return 'sound/misc/mat/fingering.ogg'

/// TRUE when [owner]'s hole in [slot] reads slick.
/proc/is_hole_slick(mob/living/owner, slot)
	var/obj/item/organ/genitals/filling_organ/hole = owner?.getorganslot(slot)
	if(!istype(hole))
		return FALSE
	var/datum/orifice/opening = hole.get_orifice(FALSE)
	return opening?.get_lube_id() == "slick"

/// TRUE when [owner]'s groin carries any fluid coat: saliva, cum or lube.
/proc/groin_is_coated(mob/living/owner)
	var/datum/component/fluid_coated/coated = owner?.GetComponent(/datum/component/fluid_coated)
	if(!coated)
		return FALSE
	var/datum/fluid_coat/coat = coated.coats[FLUID_COAT_GROIN]
	return (coat?.fluids?.total_volume || 0) > 0
