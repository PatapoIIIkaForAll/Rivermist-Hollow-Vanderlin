// Layer shift: draw a mob slightly above or below others on its tile.

#define LAYER_SHIFT_STEP 0.01
#define LAYER_SHIFT_MAX_STEPS 5

/mob/living
	/// Layer steps above (positive) or below (negative) the base layer.
	var/layer_shift_steps = 0
	/// Layer before shifting started; null while not shifted.
	var/layer_shift_base

/// Layer the mob should have for its current base and steps.
/mob/living/proc/layer_shift_layer()
	return layer_shift_base + layer_shift_steps * LAYER_SHIFT_STEP

/// Shifts the layer by the given steps, clamped, and shows the result in chat.
/mob/living/proc/shift_layer(steps)
	if(isnull(layer_shift_base))
		layer_shift_base = layer
		layer_shift_steps = 0
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_layer_shift_moved))
		RegisterSignal(src, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_layer_shift_body_position))
	else if(layer != layer_shift_layer())
		// Something else set the layer since the last shift: start over from it.
		layer_shift_base = layer
		layer_shift_steps = 0

	layer_shift_steps = clamp(layer_shift_steps + steps, -LAYER_SHIFT_MAX_STEPS, LAYER_SHIFT_MAX_STEPS)
	layer = layer_shift_layer()

	var/step_text = layer_shift_steps > 0 ? "+[layer_shift_steps]" : "[layer_shift_steps]"
	if(abs(layer_shift_steps) == LAYER_SHIFT_MAX_STEPS)
		step_text += layer_shift_steps > 0 ? " (highest)" : " (lowest)"
	to_chat(src, span_info("Layer: [step_text]"))

	if(!layer_shift_steps)
		clear_layer_shift()

/// Puts the mob back on its base layer, unless something else has set the layer since.
/mob/living/proc/reset_layer_shift()
	if(isnull(layer_shift_base) || layer != layer_shift_layer())
		return
	layer = layer_shift_base
	clear_layer_shift()

/mob/living/proc/clear_layer_shift()
	layer_shift_base = null
	layer_shift_steps = 0
	UnregisterSignal(src, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))

/mob/living/proc/on_layer_shift_moved(datum/source, atom/old_loc)
	SIGNAL_HANDLER
	if(loc != old_loc)
		reset_layer_shift()

/// Runs before the lying and standing layer changes, so they see the base layer.
/mob/living/proc/on_layer_shift_body_position(datum/source)
	SIGNAL_HANDLER
	reset_layer_shift()

#undef LAYER_SHIFT_STEP
#undef LAYER_SHIFT_MAX_STEPS
