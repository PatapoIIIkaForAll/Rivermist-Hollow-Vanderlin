/obj/structure/fake_machine/vendor/inn_rmh
	lockids = list(ACCESS_INN)
	density = FALSE

/obj/structure/fake_machine/vendor/inn_rmh/Initialize()
	. = ..()

	// small rooms
	for (var/X in list(/obj/item/key/roomiv, /obj/item/key/roomv, /obj/item/key/roomvi, /obj/item/key/roomvii))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 50

	// medium rooms
	for (var/Y in list(/obj/item/storage/keyring/tavern_room1, /obj/item/storage/keyring/tavern_room2, /obj/item/storage/keyring/tavern_room3, /obj/item/storage/keyring/tavern_room8))
		var/obj/Q = new Y(src)
		held_items[Q] = list()
		held_items[Q]["NAME"] = Q.name
		held_items[Q]["PRICE"] = 90

	// big room
	for (var/Z in list(/obj/item/storage/keyring/tavern_room9))
		var/obj/F = new Z(src)
		held_items[F] = list()
		held_items[F]["NAME"] = F.name
		held_items[F]["PRICE"] = 150

	update_icon()
