var/global/list/colorlist = list(
	"Custom" = "CUSTOM_RGB",
	"Swan White"="#ffffff",
	"Chalk White" = "#f4ecde",
	"Cream" = "#fffdd0",
	"Light Grey" = "#999999",
	"Dunked in Water" = "#bbbbbb",
	"Mage Grey" = "#6c6c6c",
	"Sow's skin"="#CE929F",
	"Knight's Red"="#933030",
	"Royal Red"="#8b2323",
	"Red Ochre" = "#913831",
	"Maroon" = "#550000",
	"Scarlet" = "#bb0a1e",
	"Royal Orange" = "#df8405",
	"Madroot Red"="#AD4545",
	"Marigold Orange"="#E2A844",
	"Chestnut" = "#613613",
	"Dirt" = "#7c6d5c",
	"Peasant Brown" = "#685542",
	"Russet" = "#7f461b",
	"Yellow Weld" = "#f4c430",
	"Yarrow" = "#f0cb76",
	"Yellow Ochre" = "#cb9d06",
	"Mage Yellow" = "#c1b144",
	"Astrata's Yellow"="#FFFD8D",
	"Olive" = "#98bf64",
	"Royal Green" = "#264d26",
	"Forest Green" = "#428138",
	"Mage Green" = "#759259",
	"Bog Green"="#375B48",
	"Seafoam Green"="#49938B",
	"Royal Teal" = "#249589",
	"Cornflower Blue"="#749EE8",
	"Royal Blue" = "#173266",
	"Woad Blue"="#395480",
	"Mage Blue" = "#4756d8",
	"Periwinkle Blue" = "#8f99fb",
	"Lavender"="#865c9c",
	"Royal Purple"="#5E4687",
	"Orchil" = "#66023C",
	"Wine Rouge"="#752B55",
	"Royal Magenta" = "#962e5c",
	"Blacksteel Grey"="#404040",
	"Dark Grey" = "#505050",
	"Darkest Night" = "#414143",
	"Purple"="#8747b1",
	"Black"="#2b292e",
	"Brown"="#61462c",
	"Yellow"="#ffcd43",
	"Azure"="#007fff",
	"Baby Puke" = "#b5b004",
    "Gold" = "#f9a602",
    "Mage Red" = "#b8252c",
    "Orange" = "#bd6606",
	"Red" = "#a32121",
	)

/*	.................   Luxury dye bin   ................... */
/obj/structure/dye_bin
	name = "dye bin"
	desc = "A wooden barrel with various dyes, used to stain clothes into new colors."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "dye_bin"
	density = TRUE
	anchored = FALSE
	max_integrity = 80
	attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg','sound/combat/hits/onwood/woodimpact (2).ogg')
	var/final/atom/movable/inserted = null
	var/final/active_color = null
	/// Allow holder'd mobs
	var/allow_mobs = TRUE

	/// Packs that this bin will initialize with
	var/list/initial_packs = list(/obj/item/dye_pack/cheap)
	/// List of all colors currently usable in this bin.
	var/final/list/selectable_colors = list(
		// This is to let you bleach out colors.
		"Bleach Out" = "#FFFFFF",
		"CUSTOM" = "CUSTOM_RGB",
	)

/obj/structure/dye_bin/luxury
	icon_state = "dye_bin_luxury"
	initial_packs = list(
		/obj/item/dye_pack/luxury,
		/obj/item/dye_pack/royal,
		/obj/item/dye_pack/mage,
	)

/obj/structure/dye_bin/deconstruct(disassembled)
	visible_message( \
		span_warning("[src] falls over, spilling out [p_their()] contents!"), \
		null, \
		span_warning("Something was knocked over!")
	)
	new /obj/effect/decal/cleanable/dyes(get_turf(src))
	var/obj/item/bin/I = new(loc)
	I.kover = TRUE
	return ..()

/obj/structure/dye_bin/Initialize(mapload, obj/item/dye_pack/inserted_pack)
	. = ..()
	if(mapload || !inserted_pack)
		for(var/pack_path in initial_packs)
			var/obj/item/dye_pack/new_pack = new pack_path()
			add_dye_pack(new_pack)
	else
		add_dye_pack(inserted_pack)

	active_color = pick_assoc(selectable_colors)

/obj/structure/dye_bin/proc/add_dye_pack(obj/item/dye_pack/new_pack)
	new_pack.forceMove(src) //GIVE ME THAT
	selectable_colors |= new_pack.selectable_colors
	qdel(new_pack)

/obj/structure/dye_bin/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(istype(I, /obj/item/dye_pack))
		. = TRUE
		var/obj/item/dye_pack/pack = I
		user.visible_message( \
			span_notice("[user] begins to add [pack] to [src]..."), \
			span_notice("I begin to add [pack] to [src]...") \
		)
		if(do_after(user, 3 SECONDS, src))
			add_dye_pack(pack)

		return


	if(!(I.sewrepair || I.dyeable)) // ????
		if(I.force < 8) // ?????????
			to_chat(user, span_warning("I do not think \the [I] can be dyed this way."))
		return ..()

	/* ---------- */
	. = TRUE

	if(ismobholder(I))
		if(!allow_mobs)
			to_chat(user, span_warning("I could not fit [I] into [src]."))
			return
		var/obj/item/mob_holder/fellow = I
		fellow.release() //is this not a bug?

	if(inserted)
		to_chat(user, span_warning("There is already something inside the dye bin."))
		return
	if(!user.transferItemToLoc(I, src))
		to_chat(user, span_warning("I can not let go of [I]!"))
		return

	user.visible_message( \
		span_notice("[user] inserts [I] into [src]."), \
		span_notice("I insert [I] into [src].") \
	)
	inserted = I
	icon_state = "dye_bin_full"
	updateUsrDialog()

/obj/structure/dye_bin/interact(mob/living/user)
	var/list/dat = list("<STYLE> * {text-align: center;} </STYLE>")
	if(!inserted)
		dat += "No item inserted."
	else
		var/ref = REF(src)
		dat += "Item inserted: \the [inserted]<BR>"
		dat += "<A href='byond://?src=[ref];action=eject'>Remove item.</A>"
		dat += "<HR>"

		dat += "Color: <span style='color:[active_color];'>■</span>"
		dat += "<BR>"
		dat += "<A href='byond://?src=[ref];action=select'>Select new color.</A>"
		dat += "<BR>"

		dat += "<A href='byond://?src=[ref];action=paint;type=base'>Taint with dye.</A>"
		if(isitem(inserted))
			var/obj/item/I = inserted
			if(I.get_detail_tag())
				dat += " | <A href='byond://?src=[ref];action=paint;type=detail'>Apply dye to accent.</A>"

	var/datum/browser/menu = new(user, "colormate","<CENTER>[src]</CENTER>", 400, 400, src)
	menu.set_content(dat.Join())
	menu.open()

/obj/structure/dye_bin/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["close"]) //the window will refuse to close if we don't do this ourselves
		usr << browse(null, "window=colormate")
		return

	var/mob/living/user = usr
	if(!istype(user))
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	switch(href_list["action"])
		if("select")
			var/choice = browser_input_list(user,"Choose your dye:", "Dyes", selectable_colors)
			if(!choice)
				return
			if(selectable_colors[choice] == "CUSTOM_RGB")
				var/current_color = active_color||"#FFFFFF"
				var/new_color = input(user, "Select custom RGB color:", "Custom Color", color) as color|null
				if(new_color)
					active_color = sanitize_hexcolor(new_color, include_crunch=1)
				else
					active_color = current_color
			else
				active_color = selectable_colors[choice]

			user << browse(null, "window=colormate")
			interact(user)
			//return

		if("paint")
			if(!inserted)
				return
			if(!active_color)
				return

			playsound(src, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 50, FALSE)
			user.visible_message( \
				null, \
				null, \
				span_hear("I hear something moving in water.") \
			)
			if(do_after(user, 1 SECONDS, src))
				if(href_list["type"] == "detail" && isitem(inserted))
					var/obj/item/I = inserted
					I.detail_color = active_color
					I.update_appearance(UPDATE_OVERLAYS)
				else
					inserted.add_atom_colour(active_color, FIXED_COLOUR_PRIORITY)

				user.visible_message( \
					span_notice("[user] dyes [inserted] in [src]."), \
					span_notice("I dye [inserted] in [src]."), \
				)
			inserted.forceMove(get_turf(src))
			inserted = null
			icon_state = initial(icon_state)

		if("eject")
			if(!inserted)
				return

			user.put_in_hands(inserted)
			user.visible_message( \
				span_notice("[user] removes [inserted] from [src]."), \
				span_notice("I remove [inserted] from [src].") \
			)
			inserted = null

			icon_state = initial(icon_state)

	updateUsrDialog()

/obj/structure/dye_bin/onkick(mob/living/user)
	if(!istype(user))
		return

	playsound(src, 'sound/combat/hits/onwood/woodimpact (1).ogg', 100)
	user.visible_message( \
		span_warning("[user] kicks [src]!"), \
		span_warning("I kick [src]!"), \
		span_warning("I hear a loud bang!") \
	)

	if(prob(user.STASTR * 8))
		deconstruct(FALSE)

/*	.................   Dyes   ................... */

/obj/item/dye_pack //abstract
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "bait" //placeholder
	gender = PLURAL
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 0.7
	var/list/selectable_colors = list()

/obj/item/dye_pack/examine(mob/user)
	. = ..()
	. += span_info("Putting these into a wooden bin will turn it into a dye bin.")
	. += span_info("Putting these into an existing dye bin will add the colors into it.")
	var/colors_ref = "byond://?src=[REF(src)];action=colors"
	. += span_info(span_notice("I could look at the selection of <a href=[colors_ref]>colors</a>...")) //ew

/obj/item/dye_pack/Topic(href, href_list)
	. = ..()
	switch(href_list["action"])
		if("colors")
			if(!length(selectable_colors))
				to_chat(usr, span_warning("I am looking at [src], but there are no colors?"))
				to_chat(usr, span_ooc("<i>This is a bug. Please report this on the GitHub.</i>"))
				return

			var/list/message_parts = list(span_info("I can discern these colors..."))
			for(var/key in selectable_colors)
				var/value = selectable_colors[key]

				var/entry = span_info("- <font color='[value]'>[key]</font>")
				message_parts += entry

			to_chat(usr, message_parts.Join("\n"))

/obj/item/dye_pack/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	new /obj/effect/decal/cleanable/dyes(get_turf(src))
	. = ..()
	qdel(src)

/obj/item/dye_pack/cheap
	name = "cheap dyes"
	desc = "A handful of muted dyes made from natural elements."
	icon_state = "cheap_dyes"
	sellprice = 3

/obj/item/dye_pack/cheap/Initialize()
	selectable_colors = GLOB.peasant_dyes.Copy()
	. = ..()

/obj/item/dye_pack/luxury
	name = "luxury dyes"
	desc = "An assortment of rich, colorful dyes, hailing from all across Faerun. This would certainly cost a pretty zenny." // RMH
	icon_state = "luxury_dyes"
	sellprice = 30

/obj/item/dye_pack/luxury/Initialize()
	selectable_colors = GLOB.noble_dyes.Copy()
	. = ..()

/obj/item/dye_pack/royal
	name = "royal dyes"
	desc = "Dyes with powders hailing from all across Faerun, from Neverwinter to Baldur's Gate. \
		Vibrant and pleasing to the eyes, only the highest in the social hierarchy are seen with these colors." // RMH
	icon_state = "luxury_dyes"
	sellprice = 70

/obj/item/dye_pack/royal/Initialize()
	selectable_colors = GLOB.royal_dyes.Copy()
	. = ..()

// No clue where to sort these so...
/obj/item/dye_pack/mage
	name = "magician dyes"
	desc = "The pigmentation in these colors are bright and rich. Unusual."
	selectable_colors = list(
		"Mage Green" = CLOTHING_MAGE_GREEN,
		"Mage Yellow" = CLOTHING_MAGE_YELLOW,
		"Mage Orange" = CLOTHING_MAGE_ORANGE,
		"Mage Blue" = CLOTHING_MAGE_BLUE,
	)
