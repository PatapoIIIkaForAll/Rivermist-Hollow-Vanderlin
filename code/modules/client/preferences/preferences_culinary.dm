// Favourite and hated food and drink: dish groups on food, drink types on consumable reagents.

/obj/item/reagent_containers/food/snacks
	/// Dish groups this food belongs to, DISH_* flags. Untagged food never counts as favourite or hated.
	var/dish_type = NONE

/datum/reagent/consumable
	/// Drink types this reagent belongs to, DRINKTYPE_* flags. Untagged reagents never count.
	var/drink_type = NONE
	/// Dish groups this reagent counts as when eaten, DISH_* flags; soups and stews.
	var/dish_type = NONE
	/// Fare of this reagent as a dish, for the favourite food threshold.
	var/dish_fare = FARE_NEUTRAL

/// Dish groups in the order the player sees them.
GLOBAL_LIST_INIT(culinary_dish_groups, list(
	"Meat" = DISH_MEAT,
	"Poultry" = DISH_POULTRY,
	"Fish & seafood" = DISH_SEAFOOD,
	"Eggs" = DISH_EGG,
	"Dairy & cheese" = DISH_DAIRY,
	"Vegetables & mushrooms" = DISH_VEGETABLE,
	"Fruit" = DISH_FRUIT,
	"Bread" = DISH_BREAD,
	"Pastry" = DISH_PASTRY,
	"Pies & tarts" = DISH_PIE,
	"Stew & soup" = DISH_SOUP,
	"Cakes & sweets" = DISH_SWEET,
))

/// Drink types in the order the player sees them.
GLOBAL_LIST_INIT(culinary_drink_groups, list(
	"Wine" = DRINKTYPE_WINE,
	"Ale & beer" = DRINKTYPE_ALE,
	"Spirits" = DRINKTYPE_SPIRIT,
	"Mead" = DRINKTYPE_MEAD,
	"Cider" = DRINKTYPE_CIDER,
	"Tea & coffee" = DRINKTYPE_TEA,
	"Milk" = DRINKTYPE_MILK,
))

/// A typical food per dish group, drawn next to the group in the character creator.
GLOBAL_LIST_INIT(culinary_dish_icons, list(
	"[DISH_MEAT]" = /obj/item/reagent_containers/food/snacks/cooked/frysteak,
	"[DISH_POULTRY]" = /obj/item/reagent_containers/food/snacks/cooked/roastchicken,
	"[DISH_SEAFOOD]" = /obj/item/reagent_containers/food/snacks/fryfish/carp,
	"[DISH_EGG]" = /obj/item/reagent_containers/food/snacks/cooked/egg,
	"[DISH_DAIRY]" = /obj/item/reagent_containers/food/snacks/cheddar,
	"[DISH_VEGETABLE]" = /obj/item/reagent_containers/food/snacks/produce/vegetable/cabbage,
	"[DISH_FRUIT]" = /obj/item/reagent_containers/food/snacks/produce/fruit/apple,
	"[DISH_BREAD]" = /obj/item/reagent_containers/food/snacks/bread,
	"[DISH_PASTRY]" = /obj/item/reagent_containers/food/snacks/pastry,
	"[DISH_PIE]" = /obj/item/reagent_containers/food/snacks/pie/cooked/apple,
	"[DISH_SWEET]" = /obj/item/reagent_containers/food/snacks/strawbycake_cooked,
	"[DISH_SOUP]" = /obj/item/reagent_containers/glass/bowl,
))

/// Name of a group flag in groups, or "None".
/proc/culinary_group_name(list/groups, flag)
	if(!flag)
		return "None"
	for(var/label in groups)
		if(groups[label] == flag)
			return label
	return "None"

/// TRUE for NONE or a flag that names one group in groups.
/proc/culinary_group_valid(list/groups, flag)
	if(flag == NONE)
		return TRUE
	if(!isnum(flag))
		return FALSE
	for(var/label in groups)
		if(groups[label] == flag)
			return TRUE
	return FALSE

/// The highest group flag set in flags, NONE when none is set.
/proc/culinary_primary_group(list/groups, flags)
	. = NONE
	if(!isnum(flags))
		return
	for(var/label in groups)
		var/flag = groups[label]
		if((flags & flag) && flag > .)
			. = flag

/// Dish groups that have at least one food good enough to count as a favourite.
/proc/culinary_favourite_dish_options()
	var/static/list/options
	if(!options)
		var/reachable = NONE
		for(var/obj/item/reagent_containers/food/snacks/food_type as anything in subtypesof(/obj/item/reagent_containers/food/snacks))
			if(initial(food_type.faretype) >= FAVOURITE_FOOD_MINFARE)
				reachable |= initial(food_type.dish_type)
		for(var/datum/reagent/consumable/dish as anything in subtypesof(/datum/reagent/consumable))
			if(initial(dish.dish_fare) >= FAVOURITE_FOOD_MINFARE)
				reachable |= initial(dish.dish_type)
		options = list()
		for(var/label in GLOB.culinary_dish_groups)
			if(reachable & GLOB.culinary_dish_groups[label])
				options[label] = GLOB.culinary_dish_groups[label]
	return options

/// Drink types that have at least one drink good enough to count as a favourite.
/proc/culinary_favourite_drink_options()
	var/static/list/options
	if(!options)
		var/reachable = FAVOURITE_DRINK_ANY_QUALITY
		for(var/datum/reagent/consumable/drink as anything in subtypesof(/datum/reagent/consumable))
			if(initial(drink.quality) >= FAVOURITE_DRINK_MINQUALITY)
				reachable |= initial(drink.drink_type)
		options = list()
		for(var/label in GLOB.culinary_drink_groups)
			if(reachable & GLOB.culinary_drink_groups[label])
				options[label] = GLOB.culinary_drink_groups[label]
	return options

/// One saved food preference as a dish group: numbers are checked, an old dish typepath maps through its tag.
/proc/culinary_clean_food_value(value, list/allowed)
	if(istext(value))
		value = text2path(value)
	if(ispath(value, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/food_type = value
		value = culinary_primary_group(allowed, initial(food_type.dish_type))
	return culinary_group_valid(allowed, value) ? value : NONE

/// One saved drink preference as a drink type: numbers are checked, an old drink typepath maps through its tag.
/proc/culinary_clean_drink_value(value, list/allowed)
	if(istext(value))
		value = text2path(value)
	if(ispath(value, /datum/reagent/consumable))
		var/datum/reagent/consumable/drink = value
		value = culinary_primary_group(allowed, initial(drink.drink_type))
	return culinary_group_valid(allowed, value) ? value : NONE

/// Favourite and hated food reactions for eating food of dish_flags at the given fare.
/mob/living/carbon/human/proc/culinary_react_to_food(dish_flags, fare)
	if(!dish_flags || !length(culinary_preferences))
		return
	var/favourite = culinary_preferences[CULINARY_FAVOURITE_FOOD]
	if(isnum(favourite) && (dish_flags & favourite) && fare >= FAVOURITE_FOOD_MINFARE)
		if(add_stress(/datum/stress_event/favourite_food))
			culinary_set_stress_duration(/datum/stress_event/favourite_food, max(fare, 1))
			culinary_random_triumph(FAVOURITE_FOOD_TRIUMPH)
			to_chat(src, span_green("Yum! My favourite kind of food!"))
	var/hated = culinary_preferences[CULINARY_HATED_FOOD]
	if(isnum(hated) && (dish_flags & hated))
		if(add_stress(/datum/stress_event/hated_food))
			to_chat(src, span_red("Yuck! The kind of food I hate!"))

/// Favourite and hated drink reactions for drinking a reagent of drink_flags at the given quality.
/mob/living/carbon/human/proc/culinary_react_to_drink(drink_flags, quality)
	if(!drink_flags || !length(culinary_preferences))
		return
	var/favourite = culinary_preferences[CULINARY_FAVOURITE_DRINK]
	if(isnum(favourite) && (drink_flags & favourite) && (quality >= FAVOURITE_DRINK_MINQUALITY || (favourite & FAVOURITE_DRINK_ANY_QUALITY)))
		if(add_stress(/datum/stress_event/favourite_drink))
			culinary_set_stress_duration(/datum/stress_event/favourite_drink, max(1 + quality, 1))
			culinary_random_triumph(FAVOURITE_DRINK_TRIUMPH)
			to_chat(src, span_green("Yum! My favourite kind of drink!"))
	var/hated = culinary_preferences[CULINARY_HATED_DRINK]
	if(isnum(hated) && (drink_flags & hated))
		if(add_stress(/datum/stress_event/hated_drink))
			to_chat(src, span_red("Yuck! The kind of drink I hate!"))

/// Stretches a just-added stress event to its base duration times multiplier.
/mob/living/carbon/human/proc/culinary_set_stress_duration(event_type, multiplier)
	var/datum/stress_event/event = has_stress_type(event_type)
	if(!event)
		return
	var/base_duration = initial(event.timer)
	if(base_duration > 0)
		event.timer = world.time + base_duration * multiplier

/// One triumph per category the first time a random favourite is enjoyed.
/mob/living/carbon/human/proc/culinary_random_triumph(reward_key)
	if(!culinary_preferences[CULINARY_RANDOM_PREFERENCES] || culinary_preferences[reward_key])
		return
	culinary_preferences[reward_key] = TRUE
	adjust_triumphs(1)

/// Dish groups a favourite food may be; filled by get_global_selectable_foods().
GLOBAL_LIST_EMPTY(selectable_foods)
/// Drink types a favourite drink may be; filled by get_global_selectable_drinks().
GLOBAL_LIST_EMPTY(selectable_drinks)

/// Preference keys of the four culinary picks.
#define CULINARY_PICK_KEYS list(CULINARY_FAVOURITE_FOOD, CULINARY_FAVOURITE_DRINK, CULINARY_HATED_FOOD, CULINARY_HATED_DRINK)

/proc/get_global_selectable_foods()
	var/list/flags = list()
	var/list/options = culinary_favourite_dish_options()
	for(var/label in options)
		flags += options[label]
	return flags

/proc/get_global_selectable_drinks()
	var/list/flags = list()
	var/list/options = culinary_favourite_drink_options()
	for(var/label in options)
		flags += options[label]
	return flags

/// The groups a culinary pick key may hold: favourites only offer groups with good enough fare.
/proc/culinary_options_for_key(key)
	switch(key)
		if(CULINARY_FAVOURITE_FOOD)
			return culinary_favourite_dish_options()
		if(CULINARY_FAVOURITE_DRINK)
			return culinary_favourite_drink_options()
		if(CULINARY_HATED_FOOD)
			return GLOB.culinary_dish_groups
		if(CULINARY_HATED_DRINK)
			return GLOB.culinary_drink_groups

/// Random favourite and hated groups for one round; the hated group never equals the favourite.
/proc/roll_random_culinary_groups()
	var/list/rolled = list()
	var/list/food_options = culinary_favourite_dish_options()
	var/list/drink_options = culinary_favourite_drink_options()
	rolled[CULINARY_FAVOURITE_FOOD] = length(food_options) ? food_options[pick(food_options)] : NONE
	rolled[CULINARY_FAVOURITE_DRINK] = length(drink_options) ? drink_options[pick(drink_options)] : NONE
	rolled[CULINARY_HATED_FOOD] = culinary_pick_other(GLOB.culinary_dish_groups, rolled[CULINARY_FAVOURITE_FOOD])
	rolled[CULINARY_HATED_DRINK] = culinary_pick_other(GLOB.culinary_drink_groups, rolled[CULINARY_FAVOURITE_DRINK])
	return rolled

/// A random group flag from groups other than excluded, NONE when nothing is left.
/proc/culinary_pick_other(list/groups, excluded)
	var/list/flags = list()
	for(var/label in groups)
		if(groups[label] != excluded)
			flags += groups[label]
	return length(flags) ? pick(flags) : NONE

/// Converts old dish typepaths to groups, drops unknown values and keeps favourite and hated apart.
/datum/preferences/proc/validate_culinary_preferences()
	if(!length(GLOB.selectable_foods))
		GLOB.selectable_foods = get_global_selectable_foods()
	if(!length(GLOB.selectable_drinks))
		GLOB.selectable_drinks = get_global_selectable_drinks()
	var/list/culinary = read_preference(/datum/preference/list_type/culinary_preferences)
	if(!islist(culinary))
		culinary = list()
	var/list/cleaned = list(CULINARY_RANDOM_PREFERENCES = culinary[CULINARY_RANDOM_PREFERENCES] ? TRUE : FALSE)
	cleaned[CULINARY_FAVOURITE_FOOD] = culinary_clean_food_value(culinary[CULINARY_FAVOURITE_FOOD], culinary_favourite_dish_options())
	cleaned[CULINARY_FAVOURITE_DRINK] = culinary_clean_drink_value(culinary[CULINARY_FAVOURITE_DRINK], culinary_favourite_drink_options())
	cleaned[CULINARY_HATED_FOOD] = culinary_clean_food_value(culinary[CULINARY_HATED_FOOD], GLOB.culinary_dish_groups)
	cleaned[CULINARY_HATED_DRINK] = culinary_clean_drink_value(culinary[CULINARY_HATED_DRINK], GLOB.culinary_drink_groups)
	if(cleaned[CULINARY_FAVOURITE_FOOD] && cleaned[CULINARY_FAVOURITE_FOOD] == cleaned[CULINARY_HATED_FOOD])
		cleaned[CULINARY_HATED_FOOD] = NONE
	if(cleaned[CULINARY_FAVOURITE_DRINK] && cleaned[CULINARY_FAVOURITE_DRINK] == cleaned[CULINARY_HATED_DRINK])
		cleaned[CULINARY_HATED_DRINK] = NONE
	write_preference(/datum/preference/list_type/culinary_preferences, cleaned)

/// Sets one culinary pick to a group flag or NONE. Returns FALSE for an unknown key or group.
/datum/preferences/proc/set_culinary_group(key, flag)
	if(!(key in CULINARY_PICK_KEYS))
		return FALSE
	flag = text2num("[flag]")
	if(!culinary_group_valid(culinary_options_for_key(key), flag))
		return FALSE
	validate_culinary_preferences()
	var/list/culinary = read_preference(/datum/preference/list_type/culinary_preferences)
	culinary = culinary.Copy()
	culinary[key] = flag
	// Picking the group already on the other side clears that side.
	var/static/list/opposite_keys = list(
		CULINARY_FAVOURITE_FOOD = CULINARY_HATED_FOOD,
		CULINARY_HATED_FOOD = CULINARY_FAVOURITE_FOOD,
		CULINARY_FAVOURITE_DRINK = CULINARY_HATED_DRINK,
		CULINARY_HATED_DRINK = CULINARY_FAVOURITE_DRINK,
	)
	var/opposite = opposite_keys[key]
	if(flag && culinary[opposite] == flag)
		culinary[opposite] = NONE
	write_preference(/datum/preference/list_type/culinary_preferences, culinary)
	return TRUE

/// Flips random culinary picks; returns the new state.
/datum/preferences/proc/toggle_random_culinary()
	validate_culinary_preferences()
	var/list/culinary = read_preference(/datum/preference/list_type/culinary_preferences)
	culinary = culinary.Copy()
	culinary[CULINARY_RANDOM_PREFERENCES] = !culinary[CULINARY_RANDOM_PREFERENCES]
	write_preference(/datum/preference/list_type/culinary_preferences, culinary)
	return culinary[CULINARY_RANDOM_PREFERENCES]

/// Group lists for the character creator food pickers.
/proc/culinary_creator_options()
	var/static/list/data
	if(data)
		return data
	var/list/favourite_dishes = culinary_favourite_dish_options()
	var/list/dishes = list()
	for(var/label in GLOB.culinary_dish_groups)
		var/flag = GLOB.culinary_dish_groups[label]
		var/obj/item/icon_type = GLOB.culinary_dish_icons["[flag]"]
		dishes += list(list(
			"value" = flag,
			"name" = label,
			"icon" = icon_type ? "[initial(icon_type.icon)]" : null,
			"icon_state" = icon_type ? initial(icon_type.icon_state) : null,
			"favourite" = (label in favourite_dishes),
		))
	var/list/favourite_drinks = culinary_favourite_drink_options()
	var/list/drinks = list()
	for(var/label in GLOB.culinary_drink_groups)
		drinks += list(list(
			"value" = GLOB.culinary_drink_groups[label],
			"name" = label,
			"favourite" = (label in favourite_drinks),
		))
	var/obj/item/cup_type = /obj/item/reagent_containers/glass/cup
	data = list(
		"dishes" = dishes,
		"drinks" = drinks,
		"cup" = list("icon" = "[initial(cup_type.icon)]", "icon_state" = initial(cup_type.icon_state)),
	)
	return data

/// The current culinary picks for the character creator.
/datum/preferences/proc/culinary_creator_data()
	var/list/culinary = read_preference(/datum/preference/list_type/culinary_preferences)
	if(!islist(culinary))
		culinary = list()
	return list(
		"random" = culinary[CULINARY_RANDOM_PREFERENCES] ? TRUE : FALSE,
		"favourite_food" = isnum(culinary[CULINARY_FAVOURITE_FOOD]) ? culinary[CULINARY_FAVOURITE_FOOD] : NONE,
		"favourite_drink" = isnum(culinary[CULINARY_FAVOURITE_DRINK]) ? culinary[CULINARY_FAVOURITE_DRINK] : NONE,
		"hated_food" = isnum(culinary[CULINARY_HATED_FOOD]) ? culinary[CULINARY_HATED_FOOD] : NONE,
		"hated_drink" = isnum(culinary[CULINARY_HATED_DRINK]) ? culinary[CULINARY_HATED_DRINK] : NONE,
	)

/datum/preferences/proc/handle_culinary_topic(mob/user, href_list)
	switch(href_list["preference"])
		if("toggle_random_culinary")
			if(toggle_random_culinary())
				to_chat(user, span_notice("Random culinary preferences enabled."))
			else
				to_chat(user, span_notice("Random culinary preferences disabled."))
		if("set_culinary")
			set_culinary_group(href_list["culinary_key"], href_list["culinary_value"])

/datum/preferences/proc/print_culinary_page(mob/user)
	var/list/culinary = read_preference(/datum/preference/list_type/culinary_preferences)
	var/random_preferences = culinary[CULINARY_RANDOM_PREFERENCES]
	var/list/dat = list()
	dat += "<style>.culinary-pick { margin: 6px 0; } .culinary-pick a { margin-right: 4px; } .culinary-pick .linkOn { font-weight: bold; }</style>"
	dat += "<div><b>Random each round:</b> <a href='byond://?_src_=prefs;preference=toggle_random_culinary;task=change_culinary_preferences'>[random_preferences ? "On" : "Off"]</a></div>"
	dat += "<div>When on, random groups are picked each round. Enjoying a random favourite gives a triumph once per category.</div>"
	if(random_preferences)
		return dat
	for(var/key in CULINARY_PICK_KEYS)
		var/list/options = culinary_options_for_key(key)
		var/current = culinary[key]
		dat += "<div class='culinary-pick'><b>[key]:</b><br>"
		dat += "<a class='[!current ? "linkOn" : ""]' href='byond://?_src_=prefs;preference=set_culinary;culinary_key=[url_encode(key)];culinary_value=0;task=change_culinary_preferences'>None</a>"
		for(var/label in options)
			var/flag = options[label]
			dat += "<a class='[current == flag ? "linkOn" : ""]' href='byond://?_src_=prefs;preference=set_culinary;culinary_key=[url_encode(key)];culinary_value=[flag];task=change_culinary_preferences'>[html_encode(label)]</a>"
		dat += "</div>"
	return dat

/datum/preferences/proc/show_culinary_ui(mob/user)
	validate_culinary_preferences()
	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += print_culinary_page(user)
	var/datum/browser/popup = new(user, "culinary_customization", "<div align='center'>Food Preferences</div>", 420, 460)
	popup.set_content(dat.Join())
	popup.open(FALSE)

#undef CULINARY_PICK_KEYS

/proc/encode_special_chars(text)
	. = text
	. = replacetext(., "ü", "&uuml;")
	. = replacetext(., "Ü", "&Uuml;")
	. = replacetext(., "ö", "&ouml;")
	. = replacetext(., "Ö", "&Ouml;")
	. = replacetext(., "ä", "&auml;")
	. = replacetext(., "Ä", "&Auml;")
	. = replacetext(., "ß", "&szlig;")
	return .
