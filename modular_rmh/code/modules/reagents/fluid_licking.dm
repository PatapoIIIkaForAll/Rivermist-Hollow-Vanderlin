// Lick/drink spilled fluids off the floor: turf liquid puddles and sex-fluid decals.
// Requires the "bite" quick-intent and an empty active hand. Left-click = one lick; right-click = continuous drinking.

/// Units transferred by a single lick.
#define FLUID_LICK_VOLUME 2
/// Units transferred per sip while drinking.
#define FLUID_DRINK_SIP_VOLUME 4
/// Time each lick/sip takes.
#define FLUID_LICK_TIME (1 SECONDS)

/// TRUE if `user` is set up to lick fluids: bite quick-intent, empty active hand, and a usable mouth.
/proc/can_lick_fluids(mob/user)
	if(!iscarbon(user))
		return FALSE
	if(!istype(user.mmb_intent, /datum/intent/bite))
		return FALSE
	if(user.get_active_held_item())
		return FALSE
	var/mob/living/carbon/licker = user
	if(!licker.mouth_is_free(licker, cloth_blocks = TRUE))
		return FALSE
	return TRUE

/// Licks (one-shot) or drinks (continuous, until dry or interrupted) from `holder`, ingesting into `user`.
/// `anchor` is watched by do_after; `fluid_name` is used for messages. Returns TRUE if any fluid was consumed.
/proc/handle_fluid_lick(mob/living/user, datum/reagents/holder, atom/anchor, fluid_name = "the fluid", drinking = FALSE)
	if(!isliving(user) || !holder || !anchor)
		return FALSE
	if(holder.total_volume <= 0)
		return FALSE

	var/sip = drinking ? FLUID_DRINK_SIP_VOLUME : FLUID_LICK_VOLUME
	user.visible_message(span_warning("[user] lowers [user.p_their()] head and [drinking ? "starts lapping at" : "licks"] [fluid_name]..."), \
		span_notice("I [drinking ? "start lapping up" : "lick up"] [fluid_name]."))

	var/consumed_any = FALSE
	while(TRUE)
		if(!do_after(user, FLUID_LICK_TIME, anchor))
			break
		if(QDELETED(anchor) || !holder || holder.total_volume <= 0)
			break
		if(!can_lick_fluids(user))
			break
		holder.trans_to(user, min(sip, holder.total_volume), transfered_by = user, method = INGEST)
		playsound(user, 'sound/items/drink_bottle (1).ogg', 20, TRUE, -3)
		consumed_any = TRUE
		if(!drinking) //a single lick is one-and-done
			break
	return consumed_any

#undef FLUID_LICK_VOLUME
#undef FLUID_DRINK_SIP_VOLUME
#undef FLUID_LICK_TIME
