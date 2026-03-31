///basically subtypes of these process kinda like a machine but don't
///need the entire machine
/obj/structure/fake_machine
	destroy_sound = 'sound/foley/breaksound.ogg'
	break_sound = 'sound/foley/machinebreak.ogg'
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/fake_machine/proc/budget2change(budget, mob/user, specify)
	var/turf/T
	if(!user || (!ismob(user)))
		T = get_turf(src)
	else
		T = get_turf(user)
	if(!budget || budget <=0)
		return
	budget = floor(budget)
	var/type_to_put
	var/zenars_to_put
	if(specify)
		switch(specify)
			if("ROLDON")
				zenars_to_put = budget/1000
				type_to_put = /obj/item/coin/platinum
			if("DANTER")
				zenars_to_put = budget/100
				type_to_put = /obj/item/coin/gold
			if("CENTAUR")
				zenars_to_put = budget/50
				type_to_put = /obj/item/coin/electrum
			if("TARAN")
				zenars_to_put = budget/10
				type_to_put = /obj/item/coin/silver
			if("FANDAR")
				zenars_to_put = budget
				type_to_put = /obj/item/coin/copper
			if("MARQUE")
				zenars_to_put = budget
				type_to_put = /obj/item/coin/inqcoin
	else
		var coincounter
		var counter = budget

		if(floor(counter/1000) > 0)
			coincounter += floor(counter/1000)
			counter -= coincounter * 1000
			new /obj/item/coin/platinum(T, coincounter)
			coincounter = 0
		if(floor(counter/100) > 0)
			coincounter += floor(counter/100)
			counter -= coincounter * 100
			new /obj/item/coin/gold(T, coincounter)
			coincounter = 0
		if(floor(counter/50) > 0)
			coincounter += floor(counter/50)
			counter -= coincounter * 50
			new /obj/item/coin/electrum(T, coincounter)
			coincounter = 0
		if(floor(counter/10) > 0)
			coincounter += floor(counter/10)
			counter -= coincounter * 10
			new /obj/item/coin/silver(T, coincounter)
			coincounter = 0
		if(counter > 0)
			coincounter += counter
			new /obj/item/coin/copper(T, coincounter)
			coincounter = 0

	if(!type_to_put || zenars_to_put < 1)
		return

	var/stacks = CEILING(zenars_to_put / 20, 1)
	for(var/i in 1 to stacks)
		var/zenar_value = min(floor(zenars_to_put), 20)
		var/obj/item/coin/G = new type_to_put(T, zenar_value)
		zenars_to_put -= zenar_value
		G.pixel_y = G.base_pixel_y + rand(-4, 4)
		G.pixel_x = G.base_pixel_x + rand(-4, 4)
		if(user)
			user.put_in_hands(G)

	playsound(T, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
