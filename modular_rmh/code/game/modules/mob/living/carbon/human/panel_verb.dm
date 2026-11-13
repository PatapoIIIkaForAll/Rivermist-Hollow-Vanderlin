/mob/living/carbon/human/verb/open_interact_panel()
	set name = "Open ERP Panel"
	set category = "IC"

	var/list/possible_mobs = get_sex_panel_candidates()
	if(LAZYLEN(possible_mobs))
		var/mob/living/choice = browser_input_list(src, "Who do you wish to interact with?", "Sex Scene", possible_mobs, null)
		if(choice)
			if(!open_sex_scene(choice))
				to_chat(src, span_warning(get_sex_scene_refusal(choice)))
