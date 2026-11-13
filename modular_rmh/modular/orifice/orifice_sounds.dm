// Sounds and feel words for things passing an opening, chosen by lube, stretch and soreness.

/// TRUE when the hole drags whatever the lube: raw or overused tissue sounds and feels dry.
/datum/orifice/proc/sounds_dry()
	if(get_soreness_state() >= ORIFICE_STATE_RAW)
		return TRUE
	return get_lube_id() == "dry"

/// TRUE when nothing resists: a gaping or stretched-wide hole.
/datum/orifice/proc/gives_no_resistance()
	var/stretch = get_stretch_id()
	return stretch == "gaping" || stretch == "wide"

/// One clip for [kind] through this opening, or null for silence; kinds: insert, withdraw, slip, settle, pass, gush, contraction.
/datum/orifice/proc/get_passage_sound(kind)
	var/dry = sounds_dry()
	var/slick = !dry && get_lube_id() == "slick"
	var/stretch = get_stretch_id()
	var/open = gives_no_resistance()
	var/tight = stretch == "tight" || stretch == "snug"
	switch(kind)
		if("insert")
			if(dry)
				return pick('modular_rmh/sound/erp/rub_dry1.ogg', 'modular_rmh/sound/erp/rub_dry2.ogg')
			if(slick)
				return pick('modular_rmh/sound/erp/insert_wet1.ogg', 'modular_rmh/sound/erp/insert_wet2.ogg', 'modular_rmh/sound/erp/insert_wet3.ogg')
			return pick('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg')
		if("withdraw")
			if(open)
				return pick('modular_rmh/sound/erp/withdraw_gape1.ogg', 'modular_rmh/sound/erp/withdraw_gape2.ogg')
			if(dry)
				return pick('modular_rmh/sound/erp/rub_dry1.ogg', 'modular_rmh/sound/erp/rub_dry2.ogg')
			if(tight && slick)
				return pick('modular_rmh/sound/erp/pop_wet1.ogg', 'modular_rmh/sound/erp/pop_wet2.ogg')
			return pick('modular_rmh/sound/erp/withdraw_wet1.ogg', 'modular_rmh/sound/erp/withdraw_wet2.ogg', 'modular_rmh/sound/erp/withdraw_wet3.ogg')
		if("slip")
			if(dry)
				return 'sound/misc/mat/pop.ogg'
			if(slick)
				return pick('modular_rmh/sound/erp/slip_squelch1.ogg', 'modular_rmh/sound/erp/slip_squelch2.ogg')
			return pick('modular_rmh/sound/erp/slip_squish1.ogg', 'modular_rmh/sound/erp/slip_squish2.ogg')
		if("settle")
			if(dry)
				return 'sound/misc/mat/endin.ogg'
			return pick('modular_rmh/sound/erp/settle_deep1.ogg', 'modular_rmh/sound/erp/settle_deep2.ogg')
		if("pass")
			if(open)
				return pick('modular_rmh/sound/erp/withdraw_gape1.ogg', 'modular_rmh/sound/erp/withdraw_gape2.ogg')
			if(dry)
				return pick('modular_rmh/sound/erp/rub_dry1.ogg', 'modular_rmh/sound/erp/rub_dry2.ogg')
			return pick('modular_rmh/sound/erp/pass_big1.ogg', 'modular_rmh/sound/erp/pass_big2.ogg', 'modular_rmh/sound/erp/pass_big3.ogg')
		if("gush")
			if(slick)
				return pick('modular_rmh/sound/erp/gush1.ogg', 'modular_rmh/sound/erp/gush2.ogg')
			return pick('modular_rmh/sound/erp/gush_small1.ogg', 'modular_rmh/sound/erp/gush_small2.ogg')
		if("contraction")
			if(dry)
				return null
			return pick('modular_rmh/sound/erp/settle_deep1.ogg', 'modular_rmh/sound/erp/settle_deep2.ogg')
	return null

/// Plays the clip for [kind] at the owner, or [at]; a dry pass adds the rough drag. Returns the clip or null.
/datum/orifice/proc/play_passage_sound(kind, vol = 40, atom/at)
	var/clip = get_passage_sound(kind)
	if(!clip)
		return null
	var/atom/source = at || organ?.owner || organ
	if(!source)
		return clip
	playsound(source, clip, vol, TRUE, -2, ignore_walls = FALSE)
	if(kind == "pass" && sounds_dry() && !gives_no_resistance())
		playsound(source, 'modular_rmh/sound/erp/rub_rough1.ogg', vol, TRUE, -2, ignore_walls = FALSE)
	return clip

/// Bare clause on how [kind] feels now, or "" when nothing stands out; callers add the comma.
/datum/orifice/proc/get_passage_feel(kind)
	var/list/parts = list()
	if(gives_no_resistance())
		parts += "with no resistance at all"
	else if(get_stretch_id() == "tight")
		parts += (kind == "withdraw" || kind == "pass") ? "slow to work free" : "slow and with effort"
	if(get_lube_id() == "dry")
		parts += "dry and dragging"
	switch(get_soreness_id())
		if("sore")
			parts += "stinging on the way"
		if("raw", "overused")
			parts += "burning the whole way"
	if(!length(parts))
		return ""
	if(length(parts) == 1)
		return parts[1]
	var/last = parts[length(parts)]
	parts.Cut(length(parts))
	return "[jointext(parts, ", ")] and [last]"

/// Plays the wear-aware clip for [kind] on the owner, or [fallback] when this organ has no opening.
/obj/item/organ/genitals/filling_organ/proc/play_hole_sound(kind, vol = 40, fallback)
	if(!owner)
		return
	var/datum/orifice/opening = get_orifice(FALSE)
	if(opening && opening.play_passage_sound(kind, vol))
		return
	if(fallback)
		playsound(owner, fallback, vol, TRUE, -2, ignore_walls = FALSE)

/// The feel clause for [kind] with its leading comma, or "" for an organ with no opening.
/obj/item/organ/genitals/filling_organ/proc/get_hole_feel(kind)
	var/datum/orifice/opening = get_orifice(FALSE)
	var/feel = opening?.get_passage_feel(kind)
	return feel ? ", [feel]" : ""
