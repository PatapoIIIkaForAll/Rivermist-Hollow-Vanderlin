// Recipes for clothing ported from Azure Peak.

/datum/anvil_recipe/armor/ported
	abstract_type = /datum/anvil_recipe/armor/ported

/datum/anvil_recipe/valuables/ported
	abstract_type = /datum/anvil_recipe/valuables/ported

/datum/anvil_recipe/weapons/ported
	abstract_type = /datum/anvil_recipe/weapons/ported

/datum/repeatable_crafting_recipe/sewing/ported
	abstract_type = /datum/repeatable_crafting_recipe/sewing/ported

/datum/repeatable_crafting_recipe/sewing/weaving/ported
	abstract_type = /datum/repeatable_crafting_recipe/sewing/weaving/ported

/datum/repeatable_crafting_recipe/leather/ported
	abstract_type = /datum/repeatable_crafting_recipe/leather/ported

/datum/repeatable_crafting_recipe/survival/ported
	abstract_type = /datum/repeatable_crafting_recipe/survival/ported

/datum/repeatable_crafting_recipe/crafting/ported
	abstract_type = /datum/repeatable_crafting_recipe/crafting/ported

/datum/anvil_recipe/armor/ported/blacksteel_bracers
	name = "Ancient Blacksteel Bracers"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/wrists/bracers/blacksteel
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_bucket
	name = "Ancient Blacksteel Bucket Helmet (+1 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/head/helmet/blacksteel_ap
	additional_items = list(/obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_halfplatechest
	name = "Ancient Blacksteel Half Plate Armor (+2 Blacksteel, +1 Cured Hide)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/armor/plate/blacksteel
	additional_items = list(/obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel, /obj/item/natural/hide/cured)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_armet
	name = "Armet, Blacksteel (+1 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/head/helmet/blacksteel_ap/modern
	additional_items = list(/obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_bracers
	name = "Bracers, Blacksteel"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/wrists/bracers/blacksteel/modern
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_halfplatechest
	name = "Half-Plate, Blacksteel (+2 Blacksteel, +1 Cured Hide)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/armor/plate/blacksteel/modern
	additional_items = list(/obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel, /obj/item/natural/hide/cured)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_neckguard
	name = "Neckguard, Blacksteel"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/neck/bevor/blacksteel/modern
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_platechest
	name = "Full-Plate, Blacksteel (+3 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/armor/plate/full/blacksteel/modern
	additional_items = list(/obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_platelegs
	name = "Plate Chausses, Blacksteel (+1 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/pants/platelegs/blacksteel/modern
	additional_items = list(/obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_modern_sugarloaf
	name = "Sugarloaf Helmet, Blacksteel (+1 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/head/helmet/heavy/bucket/crusader/blacksteel
	additional_items = list(/obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_neckguard
	name = "Ancient Blacksteel Neckguard"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/neck/bevor/blacksteel
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_plateboots
	name = "Ancient Blacksteel Plate Boots"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/shoes/boots/armor/blacksteel
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_platechest
	name = "Ancient Blacksteel Plate Armor (+3 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/armor/plate/full/blacksteel
	additional_items = list(/obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_plategloves
	name = "Ancient Blacksteel Plate Gauntlets"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/gloves/plate/blacksteel
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blacksteel_platelegs
	name = "Ancient Blacksteel Plate Chausses (+1 Blacksteel)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/pants/platelegs/blacksteel
	additional_items = list(/obj/item/ingot/blacksteel)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blessedsilver_greatplumearmetpsy
	name = "Aonic Greatplumed Armet"
	req_bar = /obj/item/ingot/silverblessed/bullion
	created_item = /obj/item/clothing/head/helmet/heavy/knight/psy/greatplume
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blessedsilver_greatplumearmetpsy_inq
	name = "Aonic Greatplumed Armet"
	req_bar = /obj/item/ingot/silverblessed/bullion
	created_item = /obj/item/clothing/head/helmet/heavy/knight/psy/greatplume
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blessedsilver_helmvolfpsy
	name = "Aonic Volfskulle Bascinet"
	req_bar = /obj/item/ingot/silverblessed
	created_item = /obj/item/clothing/head/helmet/heavy/volfplate/psydonic
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blessedsilver_helmvolfpsy_inq
	name = "Aonic Volfskulle Bascinet"
	req_bar = /obj/item/ingot/silverblessed/bullion
	created_item = /obj/item/clothing/head/helmet/heavy/volfplate/psydonic
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blessedsilver_psyfullplate
	name = "Aonic Full-Plate (+ Aonic Half-Plate, +1 Blessed Silver, +2 Cured Leather)"
	req_bar = /obj/item/ingot/silverblessed
	created_item = /obj/item/clothing/armor/plate/full/fluted/ornate
	additional_items = list(/obj/item/clothing/armor/plate/fluted/ornate, /obj/item/ingot/silverblessed, /obj/item/natural/hide/cured, /obj/item/natural/hide/cured)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/blessedsilver_psyfullplate_inq
	name = "Aonic Full-Plate (+ Aonic Half-Plate, +1 Blessed Silver, +2 Cured Leather)"
	req_bar = /obj/item/ingot/silverblessed/bullion
	created_item = /obj/item/clothing/armor/plate/full/fluted/ornate
	additional_items = list(/obj/item/clothing/armor/plate/fluted/ornate, /obj/item/ingot/silverblessed/bullion, /obj/item/natural/hide/cured, /obj/item/natural/hide/cured)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/bronze_barbute
	name = "Barbute, Bronze (+1 Bronze, +1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/head/helmet/heavy/bronze
	additional_items = list(/obj/item/ingot/bronze, /obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_bevor
	name = "Bevor, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/bevor/bronze
	additional_items = list(/obj/item/natural/hide/cured)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/bronze_bracers
	name = "Bracers, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/wrists/bracers/bronze
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_chainmail
	name = "Haubergeon, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/chainmail/bronze

/datum/anvil_recipe/armor/ported/bronze_cuirass
	name = "Cuirass, Bronze (+1 Bronze, +1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/plate/bronze
	additional_items = list(/obj/item/ingot/bronze, /obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_duelist
	name = "Duelist's Goggles, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/face/spectacles/duelist/bronze
	createditem_extra = 1

/datum/anvil_recipe/armor/ported/bronze_fullplate
	name = "Panoply Assembly, Full, Bronze (+3 Bronze, +1 Cured Leather, +1 Fur)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/plate/full/bronze
	additional_items = list(/obj/item/ingot/bronze, /obj/item/ingot/bronze, /obj/item/ingot/bronze, /obj/item/natural/hide/cured, /obj/item/natural/fur)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/bronze_goggles
	name = "Bronze Goggles (+1 Glass)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/face/spectacles/bronze
	additional_items = list(/obj/item/natural/glass)
	createditem_extra = 1

/datum/anvil_recipe/armor/ported/bronze_gorget
	name = "Neckguard, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/gorget/bronze
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_greaves
	name = "Greaves, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/shoes/boots/armor/bronze
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_halfplate
	name = "Panoply Assembly, Halved, Bronze (+3 Bronze, +1 Cured Leather, +1 Fur)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/plate/full/bronze/alt
	additional_items = list(/obj/item/ingot/bronze, /obj/item/ingot/bronze, /obj/item/ingot/bronze, /obj/item/natural/hide/cured, /obj/item/natural/fur)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/bronze_hauberk
	name = "Hauberk, Bronze (+1 Bronze)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/chainmail/hauberk/bronze
	additional_items = list(/obj/item/ingot/bronze)

/datum/anvil_recipe/armor/ported/bronze_illyria
	name = "Bascinet, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/head/helmet/bronze
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_lightchainmail
	name = "Haubyrine, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/chainmail/light/bronze

/datum/anvil_recipe/armor/ported/bronze_mailleboots
	name = "Maille Boots, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/shoes/boots/maille/bronze

/datum/anvil_recipe/armor/ported/bronze_maillebracers
	name = "Chainsleeves, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/wrists/bracers/bronze/chain

/datum/anvil_recipe/armor/ported/bronze_maillecoif
	name = "Chain Coif, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/chaincoif/bronze

/datum/anvil_recipe/armor/ported/bronze_maillegloves
	name = "Chain Gauntlets, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/gloves/chain/bronze

/datum/anvil_recipe/armor/ported/bronze_mailleskirt
	name = "Chainmaille Skirt, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/pants/chainlegs/kilt/bronze

/datum/anvil_recipe/armor/ported/bronze_mask
	name = "Mask, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/face/facemask/bronze
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_maskclassic
	name = "Mask, Ornate, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/face/facemask/bronze/classic
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_murmillo
	name = "Murmillo-Style Helmet, Bronze (+1 Bronze, +1 Fur)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/head/helmet/bronzegladiator
	additional_items = list(/obj/item/ingot/bronze, /obj/item/natural/fur)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/bronze_protector
	name = "Heart Protector, Bronze (+1 Bronze, +1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/plate/bronze/light
	additional_items = list(/obj/item/ingot/bronze, /obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_scalemail
	name = "Lamellar, Bronze (+1 Bronze, +1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/armor/medium/scale/bronze
	additional_items = list(/obj/item/ingot/bronze, /obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/bronze_skirt
	name = "Chainskirt, Bronze (+1 Cured Leather)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/pants/heavy_leather_pants/bronzeskirt
	additional_items = list(/obj/item/natural/hide/cured)

/datum/anvil_recipe/armor/ported/copper_boots
	name = "Lamellar Boots, Copper"
	req_bar = /obj/item/ingot/copper
	created_item = /obj/item/clothing/shoes/boots/maille/copper

/datum/anvil_recipe/armor/ported/copper_chest
	name = "Heart Protector, Copper"
	req_bar = /obj/item/ingot/copper
	created_item = /obj/item/clothing/armor/cuirass/copper

/datum/anvil_recipe/armor/ported/copper_scalemail
	name = "Lamellar, Copper (+1 Copper)"
	req_bar = /obj/item/ingot/copper
	created_item = /obj/item/clothing/armor/medium/scale/copper
	additional_items = list(/obj/item/ingot/copper)

/datum/anvil_recipe/armor/ported/decorated_gilded_cuirass
	name = "Cuirass, Decorated (+1 Steel Cuirass, +1 Steel)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/cuirass/ornate/decorated
	additional_items = list(/obj/item/clothing/armor/cuirass, /obj/item/ingot/steel)
	craftdiff = 4

/datum/anvil_recipe/armor/ported/decorated_gilded_fullplate
	name = "Plate Armor, Decorated (+1 Steel Plate Armor, +1 Steel)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/plate/full/fluted/decorated
	additional_items = list(/obj/item/clothing/armor/plate/full, /obj/item/ingot/steel)
	craftdiff = 4

/datum/anvil_recipe/armor/ported/decorated_gilded_fullplatefluted
	name = "Fluted Plate Armor, Decorated (+1 Fluted Plate Armor)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/plate/full/fluted/decorated
	additional_items = list(/obj/item/clothing/armor/plate/full/fluted)
	craftdiff = 4

/datum/anvil_recipe/armor/ported/decorated_gilded_halfplate
	name = "Halfplate, Decorated (+1 Steel Halfplate, +1 Steel)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/plate/fluted/decorated
	additional_items = list(/obj/item/clothing/armor/plate, /obj/item/ingot/steel)
	craftdiff = 4

/datum/anvil_recipe/armor/ported/decorated_gilded_halfplatefluted
	name = "Fluted Halfplate, Decorated (+1 Fluted Halfplate)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/plate/fluted/decorated
	additional_items = list(/obj/item/clothing/armor/plate/fluted)
	craftdiff = 4

/datum/anvil_recipe/armor/ported/decorated_helmetbucalt
	name = "Sugarloaf Helmet, Decorated (+1 Sugarloaf Helm)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/head/helmet/heavy/bucket/crusader/gold
	additional_items = list(/obj/item/clothing/head/helmet/heavy/bucket/crusader)
	craftdiff = 4

/datum/anvil_recipe/armor/ported/decorated_maskc
	name = "Crestless Mask, Gold"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/face/facemask/goldmaskc
	craftdiff = 4

/datum/anvil_recipe/armor/ported/gold_armet
	name = "Golden Knight's Armet (+1 Gold, +2 Silk)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/head/helmet/heavy/knight/gold
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_armetcrown
	name = "Golden Knight's Armet, Royal (+1 Gold, +2 Silk, +1 Dorpel)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/head/helmet/heavy/knight/gold/king
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk, /obj/item/gem/diamond)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_bracers
	name = "Golden Bracers (+1 Gold, +2 Silk)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/wrists/bracers/gold
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_cuirass
	name = "Golden Cuirass (+2 Gold, +2 Silk)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/cuirass/ornate/gold
	additional_items = list(/obj/item/ingot/gold, /obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_cuirasshero
	name = "Golden Cuirass, Heroic (+2 Gold, +2 Silk, +1 Tallow)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/armor/cuirass/ornate/gold/heroic
	additional_items = list(/obj/item/ingot/gold, /obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk, /obj/item/reagent_containers/food/snacks/tallow)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_gorget
	name = "Golden Gorget (+1 Gold, +2 Silk)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/gorget/gold
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_greaves
	name = "Golden Greaves (+1 Gold, +2 Silk)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/shoes/boots/armor/gold
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_helmet
	name = "Golden Barbute (+1 Gold, +2 Silk)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/head/helmet/heavy/sheriff/gold
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/gold_helmetcrown
	name = "Golden Barbute, Royal (+1 Gold, +2 Silk, +1 Dorpel)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/head/helmet/heavy/sheriff/gold/king
	additional_items = list(/obj/item/ingot/gold, /obj/item/natural/silk, /obj/item/natural/silk, /obj/item/gem/diamond)
	craftdiff = 6

/datum/anvil_recipe/armor/ported/holysteel_ravoxhelm
	name = "Tempuran Helmet (+1 Holy Steel, +1 Cured Leather, +1 Amulet of Tempus)"
	req_bar = /obj/item/ingot/steelholy
	created_item = /obj/item/clothing/head/helmet/heavy/ravoxhelm_ap
	additional_items = list(/obj/item/ingot/steelholy, /obj/item/natural/hide/cured, /obj/item/clothing/neck/psycross/ravox)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/holysteel_undividedtemplar_bucket
	name = "Undivided Templar's Bucket Helmet (+1 Holy Steel, +1 Cured Leather, +1 Amulet of Ten)"
	req_bar = /obj/item/ingot/steelholy
	created_item = /obj/item/clothing/head/helmet/heavy/undivided_alt
	additional_items = list(/obj/item/ingot/steelholy, /obj/item/natural/hide/cured, /obj/item/clothing/neck/psycross/undivided)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/holysteel_undividedtemplar_sallet
	name = "Undivided Templar's Sallet (+1 Holy Steel, +1 Cured Leather, +1 Amulet of Ten)"
	req_bar = /obj/item/ingot/steelholy
	created_item = /obj/item/clothing/head/helmet/heavy/undivided
	additional_items = list(/obj/item/ingot/steelholy, /obj/item/natural/hide/cured, /obj/item/clothing/neck/psycross/undivided)
	craftdiff = 5

/datum/anvil_recipe/armor/ported/iron_aventail
	name = "Aventail, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/neck/gorget/aventail/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_aventailbascinet
	name = "Bascinet, Aventailed, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/iron/aventail
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_bandedgauntlets
	name = "Banded Gauntlets, Iron (+2 Fur, + 1 Leather Gloves)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/gloves/plate/iron/banded
	additional_items = list(/obj/item/natural/fur, /obj/item/natural/fur, /obj/item/clothing/gloves/leather)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_barredhelm
	name = "Barred Helmet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/sheriff/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_bascinet
	name = "Bascinet, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_beakhelm
	name = "Beak Helmet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/beakhelm/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_bogman
	name = "Bogman Helmet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/guard/bogman/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_breastplate_legacy
	name = "Luskanian Breastplate, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/armor/cuirass/iron/legacy
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_bucket
	name = "Iron Bucket Helmet (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/bucket/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_chainhose
	name = "Chain Hoses, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/pants/chainlegs/iron/hose
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_chainleg_kilt
	name = "Chain Kilt, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/pants/chainlegs/iron/kilt
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_chainsleeves
	name = "Chainsleeves, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/wrists/bracers/iron/chain
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_coatofplates
	name = "Coat of Plates, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/armor/brigandine/heavy/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_cursed_collar
	name = "Cursed Collar"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/neck/gorget/cursed_collar
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_duelist
	name = "Duelist Goggles, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/face/spectacles/duelist
	craftdiff = 2
	createditem_extra = 1

/datum/anvil_recipe/armor/ported/iron_etruscanbascinet
	name = "Bascinet, Klappvisier, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/etruscan/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_fullchaincoif
	name = "Full Chain Coif, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/neck/chaincoif/iron/full
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_fullplate_legacy
	name = "Luskanian Full-Plate, Iron (+3 Iron, +1 Cured Leather)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/armor/plate/full/iron/legacy
	additional_items = list(/obj/item/ingot/iron, /obj/item/ingot/iron, /obj/item/ingot/iron, /obj/item/natural/hide/cured)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_goggles
	name = "Goggles, Iron (+1 Glass)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/face/spectacles/iron
	additional_items = list(/obj/item/natural/glass)
	craftdiff = 2
	createditem_extra = 1

/datum/anvil_recipe/armor/ported/iron_halfplate_legacy
	name = "Luskanian Half-Plate, Iron (+2 Iron, +1 Cured Leather)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/armor/plate/iron/legacy
	additional_items = list(/obj/item/ingot/iron, /obj/item/ingot/iron, /obj/item/natural/hide/cured)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_heavyaventailbascinet
	name = "Visored Bascinet, Aventailed, Iron (+2 Iron, +1 Cured Leather)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/aventail/iron
	additional_items = list(/obj/item/ingot/iron, /obj/item/ingot/iron, /obj/item/natural/hide/cured)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetarmet
	name = "Armet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/visored/royalknight/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetarmet_snouted
	name = "Armet, Snouted, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/visored/royalknight/iron/snouted
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetbarbute
	name = "Barbute, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/barbute/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetbarbutevisor
	name = "Barbute, Visored, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/barbute/visor/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetbuc
	name = "Bucket Helmet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/bucket/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetbucclassic
	name = "Iron Bucket Helmet, Sugarloafed (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/bucket/iron/classic
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmethounskull
	name = "Bascinet, Hounskull, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/hounskull/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetnasal
	name = "Nasal Helmet, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/nasal/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetpig
	name = "Bascinet, Pigface, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetroundface
	name = "Bascinet, Roundface, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/roundface/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetroundface_snouted
	name = "Bascinet, Roundface, Snouted, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/roundface/iron/snouted
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_helmetwinged
	name = "Winged Helmet, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/winged/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_kettle_legacy
	name = "Luskanian Kettle Helmet, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/kettle/iron/legacy
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_knightarmet
	name = "Knight's Armet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/knight/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_knightarmetgreatplume
	name = "Helmet, Greatplumed Armet, Knight, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/knight/iron/greatplume
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_knighthelmet
	name = "Knight's Helmet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/knight/old/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_lightchainmail
	name = "Haubyrine, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/armor/chainmail/light/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_mailleboot
	name = "Maille Boots, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/shoes/boots/maille/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_maskmaille
	name = "Maille Mask, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/face/facemask/maille
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_maskmaillefluted
	name = "Fluted Maille Mask, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/face/facemask/maille/fluted
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_plateboot
	name = "Plated Boots, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/shoes/boots/armor/iron
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_sallet_visor
	name = "Sallet, Visored, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/sallet/visored/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_sallet_visor_legacy
	name = "Luskanian Sallet, Visored, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/sallet/visored/iron/legacy
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_sallet_visor_snouted
	name = "Sallet, Visored, Snouted, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/sallet/visored/iron/snouted
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_sallet_legacy
	name = "Luskanian Sallet, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/sallet/iron/legacy
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_savoyard
	name = "Savoyard Helmet, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/guard/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_scalemail
	name = "Lamellar, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/armor/medium/scale/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_slittedkettle
	name = "Slitted Kettle, Iron (+1 Iron)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/head/helmet/heavy/knight/skettle/iron
	additional_items = list(/obj/item/ingot/iron)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_splintarms
	name = "Splinted Bracers (+1 leather bracers)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/wrists/bracers/splint
	additional_items = list(/obj/item/clothing/wrists/bracers/leather)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_splintlegs
	name = "Splinted Chausses (+1 leather pants)"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/pants/splintlegs
	additional_items = list(/obj/item/clothing/pants/trou/leather)
	craftdiff = 2

/datum/anvil_recipe/armor/ported/iron_wildguard
	name = "Wild Guard, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/face/wildguard
	craftdiff = 2

/datum/anvil_recipe/armor/ported/steel_aventailbascinet
	name = "Bascinet, Aventailed, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/bascinet/aventail
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_barredhelm
	name = "Barred Helmet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/sheriff
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_beakhelm
	name = "Beak Helmet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/beakhelm
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_bogman
	name = "Bogman Helmet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/guard/bogman
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_brayette
	name = "Brayette, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/pants/brayette
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_chainhose
	name = "Chain Hoses, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/pants/chainlegs/hose
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_chainmantle
	name = "Chain Mantle, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/neck/chaincoif/chainmantle
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_chainsleeves
	name = "Chainsleeves, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/wrists/bracers/chain
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_coatplates
	name = "Coat Of Plates, Steel (+1 Steel, +1 Leather, +1 Cloth)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/brigandine/heavy
	additional_items = list(/obj/item/ingot/steel, /obj/item/natural/hide/cured, /obj/item/natural/cloth)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_cuirass_legacy
	name = "Luskanian Cuirass, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/cuirass/legacy
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_duelist
	name = "Duelist Goggles, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/face/spectacles/duelist/steel
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/armor/ported/steel_etruscanbascinet
	name = "Bascinet, Klappvisier, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/bascinet/etruscan
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_frogmouth
	name = "Froggemund Helmet, Steel (+2 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/frogmouth
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_frogmouthgreatplume
	name = "Froggemund Helmet With Greatplume, Steel (+2 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/frogmouth/greatplume
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_fullchaincoif
	name = "Full Chain Coif, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/neck/chaincoif/full
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_fullplate_fluted_legacy
	name = "Luskanian Fluted Full-Plate, Steel (+4 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/plate/full/fluted/legacy
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_fullplate_fluted
	name = "Fluted Full-Plate, Steel (+4 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/plate/full/fluted
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_fullplate_legacy
	name = "Luskanian Full-Plate, Steel (+3 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/plate/full/legacy
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_goggles
	name = "Goggles, Steel (+1 Glass)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/face/spectacles/steel
	additional_items = list(/obj/item/natural/glass)
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/armor/ported/steel_halfplate_legacy
	name = "Luskanian Half-Plate, Steel (+2 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/plate/legacy
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_heavyaventailbascinet
	name = "Visored Bascinet, Aventailed, Steel (+2 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/aventail
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetarmet_snouted
	name = "Armet, Snouted, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/visored/royalknight/snouted
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetbarbute
	name = "Barbute, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/barbute
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetbarbutedunk
	name = "Barbute, Great, Steel (+1 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/barbute/great
	additional_items = list(/obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetbarbutedunk_snouted
	name = "Burgonet, Snouted, Steel (+1 Steel, +1 Cured Leather)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/burgonet
	additional_items = list(/obj/item/ingot/steel, /obj/item/natural/hide/cured)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetbarbutevisor
	name = "Barbute, Visored, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/barbute/visor
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetbucalt
	name = "Sugarloaf Helmet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/bucket/crusader
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmethounskull
	name = "Bascinet, Hounskull, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/hounskull
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetkettle_legacy
	name = "Luskanian Kettle Helmet, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/kettle/legacy
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetknight
	name = "Knight's Helmet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/knight/old
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetknightarmetgreatplume
	name = "Knight's Greatplumed Armet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/knight/greatplume
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetless_visor
	name = "Helmetless Visor, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/face/facemask/steel/visor
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetpig
	name = "Bascinet, Pigface, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetroundface
	name = "Bascinet, Roundface, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/roundface
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetroundface_snouted
	name = "Bascinet, Roundface, Snouted, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/bascinet/pigface/roundface/snouted
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetsall_legacy
	name = "Luskanian Sallet, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/sallet/legacy
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetsallv
	name = "Sallet, Visored, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/sallet/visored
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetsallv_legacy
	name = "Luskanian Sallet, Visored, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/sallet/visored/legacy
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_helmetsallv_snouted
	name = "Sallet, Visored, Snouted, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/sallet/visored/snouted
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_lightchainmail
	name = "Haubyrine, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/armor/chainmail/light
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_mailleboot
	name = "Maille Boots, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/shoes/boots/maille
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_maillemask
	name = "Maille Mask, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/face/facemask/steel/maille

/datum/anvil_recipe/armor/ported/steel_saventail
	name = "Aventail, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/neck/gorget/aventail
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_savoyard
	name = "Savoyard Helmet, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/guard
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_sgorget
	name = "Gorget, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/neck/gorget/steel
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_skullcaps
	name = "Skullcap, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/skullcap/steel
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_slittedkettle
	name = "Slitted Kettle, Steel (+1 Steel)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/heavy/knight/skettle
	additional_items = list(/obj/item/ingot/steel)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_splintarms
	name = "Brigandine Bracers (+1 Leather Bracers)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/wrists/bracers/brigandine
	additional_items = list(/obj/item/clothing/wrists/bracers/leather)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_splintlegs
	name = "Brigandine Chausses (+1 leather pants)"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/pants/brigandinelegs
	additional_items = list(/obj/item/clothing/pants/trou/leather)
	craftdiff = 3

/datum/anvil_recipe/armor/ported/steel_widehelmetkettle
	name = "Wide Kettle Helmet, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/head/helmet/kettle/wide
	craftdiff = 3

/datum/anvil_recipe/valuables/ported/astcrossbronze
	name = "Amulet of Order, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/astrata/bronze
	craftdiff = 2

/datum/anvil_recipe/valuables/ported/baotha
	name = "Amulets of Blissara (x2)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/inhumen/baotha
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/diamondg
	name = "Dorpel Ring, Gold (+1 Dorpel)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/diamond
	additional_items = list(/obj/item/gem/diamond)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/diamonds
	name = "Dorpel Ring, Silver (+1 Dorpel)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/diamonds
	additional_items = list(/obj/item/gem/diamond)
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/dragon
	name = "Dragonstone Ring (Secret!)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/ring/dragon_ring_ap
	additional_items = list(/obj/item/ingot/gold, /obj/item/gem/blue, /obj/item/gem/violet, /obj/item/clothing/neck/psycross/silver)
	craftdiff = 6

/datum/anvil_recipe/valuables/ported/duelring
	name = "Duelist's Rings (x2) (+1 Rosestone Ring)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/ring/duelist
	additional_items = list(/obj/item/clothing/ring/rose)
	craftdiff = 5
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/emeringg
	name = "Gemerald Ring, Gold (+1 Gemerald)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/emerald
	additional_items = list(/obj/item/gem/green)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/emerings
	name = "Gemerald Ring, Silver (+1 Gemerald)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/emeralds
	additional_items = list(/obj/item/gem/green)
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/gold_cross_abyssor
	name = "Golden Amulet of Umberlee (+1 Umberlant Amulet)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/abyssor/g
	additional_items = list(/obj/item/clothing/neck/psycross/abyssor)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_cross_baotha
	name = "Golden Amulet of Blissara"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/inhumen/baotha/g
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_cross_malum
	name = "Golden Amulet of Moradin (+1 Moradinite Amulet)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/malum/g
	additional_items = list(/obj/item/clothing/neck/psycross/malum)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_cross_matthios
	name = "Golden Amulet of Mask"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/inhumen/matthios/g
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_cross_pestra
	name = "Golden Amulet of Ilmater (+1 Ilmatari Amulet)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/pestra/g
	additional_items = list(/obj/item/clothing/neck/psycross/pestra)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_cross_ravox
	name = "Golden Amulet of Tempus (+1 Tempuran Amulet)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/ravox/g
	additional_items = list(/obj/item/clothing/neck/psycross/ravox)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_cross_xylix
	name = "Golden Amulet of Tymora (+1 Tymoran Amulet)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/xylix/g
	additional_items = list(/obj/item/clothing/neck/psycross/xylix)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_reformcross
	name = "Golden Reformist Holy symbol (+1 Reformist Cross)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/reform/g
	additional_items = list(/obj/item/clothing/neck/psycross/reform)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_undivided_cross
	name = "Golden Amulet of Ten"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/undivided/g
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/gold_zcross
	name = "Golden Inverted Holy symbol (+1 Inverted Holy symbol)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/inhumen/g
	additional_items = list(/obj/item/clothing/neck/psycross/inhumen)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldamber
	name = "Amber Amulet, Gold (+1 Amber)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldamber
	additional_items = list(/obj/item/gem/amber)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldcoral
	name = "Heartstone Amulet, Gold (+1 Heartstone)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldcoral
	additional_items = list(/obj/item/gem/coral)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldjade
	name = "Jade Amulet, Gold (+1 Jade)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldjade
	additional_items = list(/obj/item/gem/jade)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldonyxa
	name = "Onyxa Amulet, Gold (+1 Onyxa)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldonyxa
	additional_items = list(/obj/item/gem/onyxa)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldopal
	name = "Opal Amulet, Gold (+1 Opal)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldopal
	additional_items = list(/obj/item/gem/opal)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldrose
	name = "Rosestone Amulet, Gold (+1 Rosestone)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldrose
	additional_items = list(/obj/item/carvedgem/rose/rawrose)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldshell
	name = "Shell Amulet, Gold (+1 Clam Shell)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldshell
	additional_items = list(/obj/item/carvedgem/shell/rawshell)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/goldturq
	name = "Cerulite Amulet, Gold (+1 Cerulite)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/carved/goldturq
	additional_items = list(/obj/item/gem/turq)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/graggarbronze
	name = "Amulet of Violence, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/inhumen/graggar/bronze
	craftdiff = 2

/datum/anvil_recipe/valuables/ported/hope
	name = "Ring Of Omnipotence (Secret!)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/statdorpel
	additional_items = list(/obj/item/clothing/ring/statgemerald, /obj/item/clothing/ring/statonyx, /obj/item/clothing/ring/statamythortz, /obj/item/clothing/ring/statrontz)
	craftdiff = 6

/datum/anvil_recipe/valuables/ported/malumcrossbronze
	name = "Amulet of Creation, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/malum/bronze
	craftdiff = 2

/datum/anvil_recipe/valuables/ported/matthios
	name = "Amulets of Mask (x2)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/inhumen/matthios
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/noccrossbronze
	name = "Amulet of Knowledge, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/noc/bronze
	craftdiff = 2

/datum/anvil_recipe/valuables/ported/ornateamulet
	name = "Ornate Amulet"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/ornateamulet
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/psicrossbronze
	name = "Amulet of Faerun, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/bronze
	craftdiff = 2

/datum/anvil_recipe/valuables/ported/quartzg
	name = "Blortz Ring, Gold (+1 Blortz)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/quartz
	additional_items = list(/obj/item/gem/blue)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/quartzs
	name = "Blortz Ring, Silver (+1 Blortz)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/quartzs
	additional_items = list(/obj/item/gem/blue)
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/ravoxbronze
	name = "Amulet of Justice, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/ravox/bronze
	craftdiff = 2

/datum/anvil_recipe/valuables/ported/ringb
	name = "Rings, Bronze (x2)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/ring/bronze
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/ringbs
	name = "Rings, Blacksteel (x3)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/ring/blacksteel
	craftdiff = 3
	createditem_extra = 2

/datum/anvil_recipe/valuables/ported/sapphireg
	name = "Saffira Ring, Gold (+1 Saffira)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/sapphire
	additional_items = list(/obj/item/gem/violet)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/sapphires
	name = "Saffira Ring, Silver (+1 Saffira)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/sapphires
	additional_items = list(/obj/item/gem/violet)
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/signet_psy
	name = "Aonic Signet Ring, Blessed Silver"
	req_bar = /obj/item/ingot/silverblessed
	created_item = /obj/item/clothing/ring/signet/psy
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/signet_psy_gold
	name = "Aonic Signet Ring, Gold"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/signet/psy/g
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/signet_psy_inq
	name = "Aonic Signet Ring, Blessed Silver"
	req_bar = /obj/item/ingot/silverblessed/bullion
	created_item = /obj/item/clothing/ring/signet/psy
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/silver_amulet_ten
	name = "Silver Amulet of Ten (+1 Any Pantheonic Amulet)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/psycross/silver/undivided
	additional_items = list(/obj/item/clothing/neck/psycross)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silveramber
	name = "Amber Amulet, Silver (+1 Amber)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silveramber
	additional_items = list(/obj/item/gem/amber)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silvercoral
	name = "Heartstone Amulet, Silver (+1 Heartstone)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silvercoral
	additional_items = list(/obj/item/gem/coral)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silverjade
	name = "Jade Amulet, Silver (+1 Jade)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silverjade
	additional_items = list(/obj/item/gem/jade)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silveronyxa
	name = "Onyxa Amulet, Silver (+1 Onyxa)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silveronyxa
	additional_items = list(/obj/item/gem/onyxa)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silveropal
	name = "Opal Amulet, Silver (+1 Opal)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silveropal
	additional_items = list(/obj/item/gem/opal)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silverrose
	name = "Rosestone Amulet, Silver (+1 Rosestone)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silverrose
	additional_items = list(/obj/item/carvedgem/rose/rawrose)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silvershell
	name = "Shell Amulet, Silver (+1 Clam Shell)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silvershell
	additional_items = list(/obj/item/carvedgem/shell/rawshell)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/silverturq
	name = "Cerulite Amulet, Silver (+1 Cerulite)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/neck/carved/silverturq
	additional_items = list(/obj/item/gem/turq)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/skullamulet
	name = "Skull Amulet"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/skullamulet
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/topazg
	name = "Toper Ring, Gold (+1 Toper)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/topaz
	additional_items = list(/obj/item/gem/yellow)
	craftdiff = 4

/datum/anvil_recipe/valuables/ported/topazs
	name = "Toper Ring, Silver (+1 Toper)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/topazs
	additional_items = list(/obj/item/gem/yellow)
	craftdiff = 5

/datum/anvil_recipe/valuables/ported/undivided_cross
	name = "Amulets of Ten (x2)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/neck/psycross/undivided
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/weddingringb
	name = "Weddingbands, Bronze (x2)"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/ring/band/bronze
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/weddingringg
	name = "Weddingbands, Gold (x2)"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/clothing/ring/band/gold
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/weddingrings
	name = "Weddingbands, Silver (x2)"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/clothing/ring/band
	craftdiff = 3
	createditem_extra = 1

/datum/anvil_recipe/valuables/ported/zcross_iron
	name = "Inverted Holy symbol"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/neck/psycross/inhumen/iron
	craftdiff = 1

/datum/anvil_recipe/valuables/ported/zcrossbronze
	name = "Amulet of Ascension, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/neck/psycross/inhumen/bronze
	craftdiff = 2

/datum/anvil_recipe/weapons/ported/blacksteel_knuckles
	name = "Blacksteel Knuckles (+1 Silk)"
	req_bar = /obj/item/ingot/blacksteel
	created_item = /obj/item/clothing/gloves/knuckles/blacksteel
	additional_items = list(/obj/item/natural/silk)
	craftdiff = 5

/datum/anvil_recipe/weapons/ported/bronze_bronzeknuckle
	name = "Knuckledusters, Bronze"
	req_bar = /obj/item/ingot/bronze
	created_item = /obj/item/clothing/gloves/knuckles/bronze
	craftdiff = 1

/datum/anvil_recipe/weapons/ported/iron_iknuckles
	name = "Knuckles, Iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/clothing/gloves/knuckles/iron
	craftdiff = 2

/datum/anvil_recipe/weapons/ported/psy_knuckles_inq
	name = "Aonic Knuckledusters"
	req_bar = /obj/item/ingot/silverblessed/bullion
	created_item = /obj/item/clothing/gloves/knuckles/psydon
	craftdiff = 5

/datum/anvil_recipe/weapons/ported/steel_steelknuckle
	name = "Knuckles, Steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/clothing/gloves/knuckles
	craftdiff = 3

/datum/repeatable_crafting_recipe/crafting/ported/amber_amulet
	name = "amber amulet"
	output = /obj/item/clothing/neck/carved/amberamulet
	requirements = list(/obj/item/gem/amber = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/amber
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/ported/amber_mask
	name = "amber mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/ambermask
	requirements = list(/obj/item/gem/amber = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/amber
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/coral_amulet
	name = "heartstone amulet"
	output = /obj/item/clothing/neck/carved/coralamulet
	requirements = list(/obj/item/gem/coral = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/coral
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/ported/coral_mask
	name = "heartstone mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/coralmask
	requirements = list(/obj/item/gem/coral = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/coral
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/jade_mask
	name = "jade mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/jademask
	requirements = list(/obj/item/gem/jade = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/jade
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/jadeamulet
	name = "jade amulet"
	output = /obj/item/clothing/neck/carved/jadeamulet
	requirements = list(/obj/item/gem/jade = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/jade
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/ported/onyxa_mask
	name = "onyxa mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/onyxamask
	requirements = list(/obj/item/gem/onyxa = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/onyxa
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/opal_amulet
	name = "opal amulet"
	output = /obj/item/clothing/neck/carved/opalamulet
	requirements = list(/obj/item/gem/opal = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/opal
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/ported/opal_mask
	name = "opal mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/opalmask
	requirements = list(/obj/item/gem/opal = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/opal
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/rose_amulet
	name = "rosestone amulet"
	output = /obj/item/clothing/neck/carved/roseamulet
	requirements = list(/obj/item/carvedgem/rose/rawrose = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/carvedgem/rose/rawrose
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/ported/rose_mask
	name = "rosestone mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/rosemask
	requirements = list(/obj/item/carvedgem/rose/rawrose = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/carvedgem/rose/rawrose
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/shell_mask
	name = "shell mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/shellmask
	requirements = list(/obj/item/carvedgem/shell/rawshell = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/carvedgem/shell/rawshell
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/crafting/ported/turq_amulet
	name = "cerulite amulet"
	output = /obj/item/clothing/neck/carved/turqamulet
	requirements = list(/obj/item/gem/turq = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/turq
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/ported/turq_mask
	name = "cerulite mask"
	output = /obj/item/clothing/face/facemask/steel/ancient/turqmask
	requirements = list(/obj/item/gem/turq = 1)
	starting_atom = /obj/item/weapon/knife/hunting
	attacked_atom = /obj/item/gem/turq
	tool_usage = list(/obj/item/weapon/knife/hunting = list("starts to work", "start to work"))
	subtypes_allowed = TRUE
	category = "Mask"
	craftdiff = 4

/datum/repeatable_crafting_recipe/leather/ported/apron_blacksmith
	name = "leather apron"
	output = /obj/item/clothing/cloak/apron/blacksmith
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Cloak"

/datum/repeatable_crafting_recipe/leather/ported/armor_cuirass
	name = "leather cuirass"
	output = /obj/item/clothing/armor/leather/cuirass
	requirements = list(/obj/item/natural/hide/cured = 2)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Armor"

/datum/repeatable_crafting_recipe/leather/ported/armor_freivest
	name = "fencing jacket"
	output = /obj/item/clothing/armor/leather/heavy/freifechter
	requirements = list(/obj/item/natural/hide/cured = 4, /obj/item/reagent_containers/food/snacks/tallow = 2, /obj/item/natural/fibers = 4)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Armor"
	craftdiff = 4

/datum/repeatable_crafting_recipe/leather/ported/armor_furheadband
	name = "Fur Headband"
	output = /obj/item/clothing/head/headband/fur
	requirements = list(/obj/item/natural/hide/cured = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Hat"

/datum/repeatable_crafting_recipe/leather/ported/armor_heavy_leather_armor_coat
	name = "hardened leather coat"
	output = /obj/item/clothing/armor/leather/heavy/coat
	requirements = list(/obj/item/natural/hide/cured = 3, /obj/item/reagent_containers/food/snacks/tallow = 1, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Armor"
	craftdiff = 4

/datum/repeatable_crafting_recipe/leather/ported/armor_heavy_leather_pants
	name = "hardened leather pants"
	output = /obj/item/clothing/pants/heavy_leather_pants
	requirements = list(/obj/item/natural/hide/cured = 3, /obj/item/reagent_containers/food/snacks/tallow = 1, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Pants"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/armor_heavybracers
	name = "hardened leather bracers"
	output = /obj/item/clothing/wrists/bracers/leather/heavy
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Wrists"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/armor_lgorget
	name = "hardened leather gorget"
	output = /obj/item/clothing/neck/leather
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Neck"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/bandana
	name = "leather bandana"
	output = /obj/item/clothing/head/helmet/bandana
	requirements = list(/obj/item/natural/hide/cured = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/leather/ported/bearcloak
	name = "direbear cloak"
	output = /obj/item/clothing/cloak/darkcloak/bear
	requirements = list(/obj/item/natural/fur/direbear = 1, /obj/item/natural/hide/cured = 4)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/belt_alt
	name = "pouched suspenders"
	output = /obj/item/clothing/cloak/suspenders
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/cloth = 2, /obj/item/storage/belt/pouch = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/container_bandolier
	name = "bandolier"
	output = /obj/item/clothing/cloak/bandolier
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/rope = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Cloak"

/datum/repeatable_crafting_recipe/leather/ported/darkcloak
	name = "dark cloak"
	output = /obj/item/clothing/cloak/darkcloak
	requirements = list(/obj/item/natural/fur = 2, /obj/item/natural/hide/cured = 4)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Cloak"
	craftdiff = 5

/datum/repeatable_crafting_recipe/leather/ported/fingerless_leather_gloves
	name = "fingerless leather gloves"
	output = /obj/item/clothing/gloves/fingerless_leather
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/reagent_containers/food/snacks/tallow = 1, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Gloves"

/datum/repeatable_crafting_recipe/leather/ported/footwear_boots_noble
	name = "noble boots"
	output = /obj/item/clothing/shoes/boots/nobleboot
	requirements = list(/obj/item/natural/hide/cured = 3, /obj/item/natural/fur = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Shoes"

/datum/repeatable_crafting_recipe/leather/ported/footwear_boots_heavy
	name = "hardened leather boots"
	output = /obj/item/clothing/shoes/boots/leather/reinforced
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fur = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Shoes"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/footwear_boots_heavy_b
	name = "dress boots"
	output = /obj/item/clothing/shoes/boots/leather/reinforced/short
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fur = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Shoes"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/footwear_boots_heavy_footwrap
	name = "hardened leather footwraps"
	output = /obj/item/clothing/shoes/footwraps/hleather
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fur = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Shoes"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/leathermask
	name = "leather mask"
	output = /obj/item/clothing/face/facemask/leather
	requirements = list(/obj/item/natural/hide/cured = 2)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Mask"
	craftdiff = 1

/datum/repeatable_crafting_recipe/leather/ported/lightbearcloak
	name = "light direbear cloak"
	output = /obj/item/clothing/cloak/darkcloak/bear/light
	requirements = list(/obj/item/natural/fur/direbear = 1, /obj/item/natural/hide/cured = 4)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/ported/reinforcement_studded_forester
	name = "forester's brigandine"
	output = /obj/item/clothing/armor/leather/studded/warden/upgraded
	requirements = list(/obj/item/clothing/armor/leather/studded/warden = 1, /obj/item/natural/cured/essence = 1, /obj/item/reagent_containers/food/snacks/fat = 1)
	attacked_atom = /obj/item/clothing/armor/leather/studded/warden
	category = "Armor"
	craftdiff = 4

/datum/repeatable_crafting_recipe/leather/ported/reinforcement_studded_hood
	name = "studded leather hood"
	output = /obj/item/clothing/head/roguehood/studded
	requirements = list(/obj/item/clothing/head/roguehood = 1, /obj/item/ingot/iron = 1, /obj/item/reagent_containers/food/snacks/fat = 1)
	attacked_atom = /obj/item/clothing/head/roguehood
	category = "Hat"

/datum/repeatable_crafting_recipe/leather/ported/rosacoat
	name = "regal coat"
	output = /obj/item/clothing/shirt/tunic/rosacoat
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/natural/silk = 2, /obj/item/alch/herb/rosa = 1)
	attacked_atom = /obj/item/natural/silk
	category = "Shirt"
	craftdiff = 5

/datum/repeatable_crafting_recipe/leather/ported/rosagloves
	name = "ivory gloves"
	output = /obj/item/clothing/gloves/rosa
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/silk = 2)
	attacked_atom = /obj/item/natural/silk
	category = "Gloves"
	craftdiff = 5

/datum/repeatable_crafting_recipe/leather/ported/rosashoes
	name = "ivory shoes"
	output = /obj/item/clothing/shoes/rosa
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/silk = 2)
	attacked_atom = /obj/item/natural/silk
	category = "Shoes"
	craftdiff = 5

/datum/repeatable_crafting_recipe/leather/ported/tricorn
	name = "leather tricorn"
	output = /obj/item/clothing/head/helmet/tricorn
	requirements = list(/obj/item/natural/hide/cured = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Hat"

/datum/repeatable_crafting_recipe/leather/ported/unique_baggyleatherpants
	name = "pontifex's chaqchur"
	output = /obj/item/clothing/pants/trou/leather/pontifex
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1, /obj/item/natural/hide/cured = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 5

/datum/repeatable_crafting_recipe/leather/ported/unique_fencingbreeches
	name = "fencing breeches"
	output = /obj/item/clothing/pants/heavy_leather_pants/otavan/generic
	requirements = list(/obj/item/natural/fibers = 1, /obj/item/natural/hide/cured = 2, /obj/item/natural/cloth = 4)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 6

/datum/repeatable_crafting_recipe/leather/ported/unique_monkleather
	name = "pontifex's kaftan"
	output = /obj/item/clothing/armor/gambeson/heavy/pontifex
	requirements = list(/obj/item/natural/hide/cured = 4, /obj/item/natural/cloth = 1, /obj/item/reagent_containers/food/snacks/tallow = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 5

/datum/repeatable_crafting_recipe/leather/ported/unique_monkrobes
	name = "holy monk vestments"
	output = /obj/item/clothing/shirt/undershirt/priest/holy
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/reagent_containers/food/snacks/tallow = 1, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Shirt"
	craftdiff = 6

/datum/repeatable_crafting_recipe/leather/ported/unique_otavanleatherpants
	name = "Amnian leather trousers"
	output = /obj/item/clothing/pants/heavy_leather_pants/otavan
	requirements = list(/obj/item/reagent_containers/food/snacks/tallow = 1, /obj/item/natural/fibers = 1, /obj/item/natural/hide/cured = 2, /obj/item/natural/fur = 1)
	attacked_atom = /obj/item/natural/hide/cured
	category = "Pants"
	craftdiff = 6

/datum/repeatable_crafting_recipe/sewing/ported/abyssortemplar
	name = "tabard, Umberlant templar"
	output = /obj/item/clothing/cloak/tabard/abyssorite
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/allwrappings
	name = "cloth wrappings"
	output = /obj/item/clothing/wrists/allwrappings
	requirements = list(/obj/item/natural/cloth = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Wrists"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/apron_blacksmith
	name = "leather apron"
	output = /obj/item/clothing/cloak/apron/blacksmith
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/hide/cured = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/archer
	name = "archer cap"
	output = /obj/item/clothing/head/archercap
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/armingcap
	name = "arming cap"
	output = /obj/item/clothing/head/armingcap_ap
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 3)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/armingjacket
	name = "arming jacket"
	output = /obj/item/clothing/armor/gambeson/lord
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 3)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/astratacleric
	name = "cloak, Lathanderite templar"
	output = /obj/item/clothing/cloak/templar/astratancleric
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/bluedress
	name = "light blue dress"
	output = /obj/item/clothing/shirt/dress/blue
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/bucklehat
	name = "folded hat"
	output = /obj/item/clothing/head/bucklehat
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/buttonedlongcoat
	name = "plague coat"
	output = /obj/item/clothing/shirt/robe/physician_ap
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 5

/datum/repeatable_crafting_recipe/sewing/ported/cape_goldenorder
	name = "cape, golden order"
	output = /obj/item/clothing/cloak/cape/inquisitorgold
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/cape_silverorder
	name = "cape, silver order"
	output = /obj/item/clothing/cloak/cape/inquisitorsilver
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/chaperon_noble
	name = "noble's chaperon"
	output = /obj/item/clothing/head/chaperon/noble
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/clothblindfold
	name = "blindfold"
	output = /obj/item/clothing/face/blindfold_ap
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Mask"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/clothhosen
	name = "cloth hosen"
	output = /obj/item/clothing/pants/tights/hose
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/clothpaddedfootwraps
	name = "padded footwraps"
	output = /obj/item/clothing/shoes/footwraps/padded
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shoes"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/clothpaddedgloves
	name = "padded gloves"
	output = /obj/item/clothing/gloves/cloth
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Gloves"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/cotehardie
	name = "fitted coat"
	output = /obj/item/clothing/cloak/cotehardie
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/hide/cured = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/desert_skirt
	name = "desert skirt"
	output = /obj/item/clothing/pants/skirt/desert
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/dhoti
	name = "dhoti"
	output = /obj/item/clothing/pants/tights/dhoti
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/duelist
	name = "duelist hat"
	output = /obj/item/clothing/head/duelhat
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/duelmask
	name = "duelist's mask"
	output = /obj/item/clothing/face/duelmask
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Mask"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/dupatta
	name = "dupatta sash"
	output = /obj/item/clothing/cloak/sash/dupatta
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/durag
	name = "durag"
	output = /obj/item/clothing/head/durag
	requirements = list(/obj/item/natural/cloth = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/faceveil
	name = "face veil"
	output = /obj/item/clothing/face/faceveil
	requirements = list(/obj/item/natural/cloth = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Mask"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/footwrap
	name = "bandages, ankles"
	output = /obj/item/clothing/shoes/footwraps
	requirements = list(/obj/item/natural/cloth = 3)
	attacked_atom = /obj/item/natural/cloth
	category = "Shoes"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/formalbreeches
	name = "formal breeches"
	output = /obj/item/clothing/pants/tights/puritan
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 2, /obj/item/natural/silk = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 5

/datum/repeatable_crafting_recipe/sewing/ported/gambesonskirt
	name = "gambesoned kilt"
	output = /obj/item/clothing/pants/skirt/gambeson
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/greendress
	name = "light green dress"
	output = /obj/item/clothing/shirt/dress/green
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/grenzelblack
	name = "Darkholdian hat with blacksteel armet"
	output = /obj/item/clothing/head/helmet/blacksteel_ap/modern/grenzelhoft
	requirements = list(/obj/item/clothing/head/grenzelhofthat = 1, /obj/item/clothing/head/helmet/blacksteel_ap/modern = 1)
	attacked_atom = /obj/item/clothing/head/grenzelhofthat
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/grenzelhelm
	name = "Darkholdian hat with steel sallet"
	output = /obj/item/clothing/head/helmet/sallet/grenzelhoft
	requirements = list(/obj/item/clothing/head/grenzelhofthat = 1, /obj/item/clothing/head/helmet/sallet = 1)
	attacked_atom = /obj/item/clothing/head/grenzelhofthat
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/grenzelhelm_off
	name = "take hat off steel sallet"
	output = /obj/item/clothing/head/grenzelhofthat
	output_amount = 2
	requirements = list(/obj/item/clothing/head/helmet/sallet/grenzelhoft = 1)
	attacked_atom = /obj/item/clothing/head/helmet/sallet/grenzelhoft
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/grenzelklapper
	name = "Darkholdian hat with klappvisier"
	output = /obj/item/clothing/head/helmet/bascinet/etruscan/grenzelhoft
	requirements = list(/obj/item/clothing/head/grenzelhofthat = 1, /obj/item/clothing/head/helmet/bascinet/etruscan = 1)
	attacked_atom = /obj/item/clothing/head/grenzelhofthat
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/grenzelklapper_off
	name = "take hat off Sembian bascinet"
	output = /obj/item/clothing/head/grenzelhofthat
	output_amount = 2
	requirements = list(/obj/item/clothing/head/helmet/bascinet/etruscan/grenzelhoft = 1)
	attacked_atom = /obj/item/clothing/head/helmet/bascinet/etruscan/grenzelhoft
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/grenzelsalletvis
	name = "Darkholdian hat with visored sallet"
	output = /obj/item/clothing/head/helmet/sallet/visored/grenzelhoft
	requirements = list(/obj/item/clothing/head/grenzelhofthat = 1, /obj/item/clothing/head/helmet/sallet/visored = 1)
	attacked_atom = /obj/item/clothing/head/grenzelhofthat
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/grenzelsalletvis_off
	name = "take hat off visored sallet"
	output = /obj/item/clothing/head/grenzelhofthat
	output_amount = 2
	requirements = list(/obj/item/clothing/head/helmet/sallet/visored/grenzelhoft = 1)
	attacked_atom = /obj/item/clothing/head/helmet/sallet/visored/grenzelhoft
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/harmingjacket
	name = "padded arming jacket"
	output = /obj/item/clothing/armor/gambeson/lord/heavy
	requirements = list(/obj/item/natural/cloth = 5, /obj/item/natural/fibers = 5)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/heavyhood
	name = "heavy hood"
	output = /obj/item/clothing/head/roguehood/shalal/heavyhood
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/heavypadded
	name = "heavy padded coif"
	output = /obj/item/clothing/neck/coif/heavypadding
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Neck"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/hgambeson_fencer
	name = "fencing shirt"
	output = /obj/item/clothing/shirt/freifechter
	requirements = list(/obj/item/natural/cloth = 5, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/hgambesonskirt
	name = "padded gambesoned kilt"
	output = /obj/item/clothing/pants/skirt/gambeson/heavy
	requirements = list(/obj/item/natural/cloth = 6, /obj/item/natural/fibers = 4)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/hijab
	name = "hijab"
	output = /obj/item/clothing/head/roguehood/shalal/hijab
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/hoodwhite
	name = "robed tabard's hood"
	output = /obj/item/clothing/head/roguehood/shroudwhite
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/jupon
	name = "jupon"
	output = /obj/item/clothing/cloak/stabard/surcoat
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/jupon_short
	name = "short jupon"
	output = /obj/item/clothing/cloak/stabard/surcoat/short
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/keffiyeh
	name = "keffiyeh"
	output = /obj/item/clothing/head/roguehood/shalal
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/larmingjacket
	name = "light arming jacket"
	output = /obj/item/clothing/armor/gambeson/lord/light
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/leopardrobe
	name = "leopard robe"
	output = /obj/item/clothing/shirt/robe/leopard
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/lgambesonskirt
	name = "light gambesoned kilt"
	output = /obj/item/clothing/pants/skirt/gambeson/light
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/longcoat
	name = "longcoat"
	output = /obj/item/clothing/armor/longcoat
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/longveil
	name = "long veil"
	output = /obj/item/clothing/head/longveil
	requirements = list(/obj/item/natural/cloth = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/lunarrobe
	name = "moonlit robe"
	output = /obj/item/clothing/shirt/robe/lunar
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/maidhead
	name = "maid headband"
	output = /obj/item/clothing/head/maidhead
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/monkwraps
	name = "padded arm wrappings"
	output = /obj/item/clothing/wrists/bracers/cloth/monk
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 4)
	attacked_atom = /obj/item/natural/cloth
	category = "Wrists"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/necracleric
	name = "cloak, Jergalite templar"
	output = /obj/item/clothing/cloak/templar/necrancleric
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/necramask
	name = "death mask, reassembled"
	output = /obj/item/clothing/head/necramask
	requirements = list(/obj/item/clothing/head/necrahood = 1, /obj/item/alch/bone = 1)
	attacked_atom = /obj/item/clothing/head/necrahood
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/noble
	name = "noble's pinafore"
	output = /obj/item/clothing/shirt/dress/nobledress
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/paddedcap
	name = "padded arming cap"
	output = /obj/item/clothing/head/armingcap_ap/padded
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 5)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/paddedchausses
	name = "padded chausses"
	output = /obj/item/clothing/pants/tights/clothlegs
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/paddedchaussesalt
	name = "padded chausses, alternate"
	output = /obj/item/clothing/pants/tights/clothlegs
	requirements = list(/obj/item/clothing/pants/tights/hose = 1, /obj/item/clothing/pants/trou/leather = 1, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/fibers
	category = "Pants"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/paddedcoif
	name = "padded coif"
	output = /obj/item/clothing/neck/coif/padded
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Neck"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/paddedmask
	name = "padded mask"
	output = /obj/item/clothing/face/facemask/padded
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Mask"
	craftdiff = 1

/datum/repeatable_crafting_recipe/sewing/ported/peasantcap
	name = "cap"
	output = /obj/item/clothing/head/cap
	requirements = list(/obj/item/natural/cloth = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/psydon
	name = "tabard, Aonic"
	output = /obj/item/clothing/cloak/tabard/psydontabard/black
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/psydonhood
	name = "hood, Aonic"
	output = /obj/item/clothing/head/roguehood/psydon_ap/black
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/psydonhoodinq
	name = "hood, Aonic orthodoxist"
	output = /obj/item/clothing/head/roguehood/psydon_ap
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/psydoninq
	name = "tabard, Aonic orthodoxist"
	output = /obj/item/clothing/cloak/tabard/psydontabard
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/ragmask
	name = "rag mask"
	output = /obj/item/clothing/face/ragmask
	requirements = list(/obj/item/natural/cloth = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Mask"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/ravoxcleric
	name = "cloak, Tempuran templar"
	output = /obj/item/clothing/cloak/templar/ravoxcleric
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/ravoxgorget
	name = "gorget, Tempuran templar"
	output = /obj/item/clothing/head/roguehood/ravoxgorget
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/ravoxtemplar
	name = "tabard, Tempuran templar"
	output = /obj/item/clothing/cloak/templar/ravox
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/saree
	name = "saree"
	output = /obj/item/clothing/shirt/dress/saree
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/shalwar
	name = "shalwar pants"
	output = /obj/item/clothing/pants/tights/shalwar
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/shawlhood
	name = "shawl (hijab)"
	output = /obj/item/clothing/head/roguehood/shawlhood
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/skirt_short
	name = "short skirt"
	output = /obj/item/clothing/pants/skirt/short
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/sleevelessrobewhite
	name = "robed tabard"
	output = /obj/item/clothing/shirt/robe/tabardwhite
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/slitdress
	name = "slitted dress"
	output = /obj/item/clothing/shirt/dress/slit
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/stabardheavy
	name = "surcoat, overvestments"
	output = /obj/item/clothing/cloak/stabard/crusader/heavy
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/strapless_dress
	name = "strapless dress"
	output = /obj/item/clothing/shirt/dress/gen/strapless
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/strapless_dress_alt
	name = "strapless dress alt"
	output = /obj/item/clothing/shirt/dress/gen/strapless/alt
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/surcoatblacksteel
	name = "surcoat of the blacksteel order"
	output = /obj/item/clothing/cloak/stabard/crusader/bsteel
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/surcoatgoldast
	name = "surcoat of the golden order, Lathanderite"
	output = /obj/item/clothing/cloak/stabard/crusader/astrata
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/surcoatgolduni
	name = "surcoat of the golden order, undivided"
	output = /obj/item/clothing/cloak/stabard/crusader/undivided
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/surcoatsilverast
	name = "surcoat of the silver order, Lathanderite"
	output = /obj/item/clothing/cloak/stabard/crusader/t/astrata
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/surcoatsilveruni
	name = "surcoat of the silver order, undivided"
	output = /obj/item/clothing/cloak/stabard/crusader/t/undivided
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/tailor_desertgown
	name = "hierophant's kandys"
	output = /obj/item/clothing/shirt/robe/hierophant
	requirements = list(/obj/item/natural/cloth = 6, /obj/item/natural/fibers = 4)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/tailor_grenzelhat
	name = "Darkholdian hat"
	output = /obj/item/clothing/head/grenzelhofthat
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1, /obj/item/natural/silk = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 5

/datum/repeatable_crafting_recipe/sewing/ported/tailor_grenzelpants
	name = "Darkholdian paumpers"
	output = /obj/item/clothing/pants/heavy_leather_pants/grenzelpants
	requirements = list(/obj/item/natural/cloth = 4, /obj/item/natural/fibers = 2, /obj/item/natural/hide/cured = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Pants"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/tailor_grenzelshirt
	name = "Darkholdian hip-shirt"
	output = /obj/item/clothing/armor/gambeson/heavy/grenzelhoft
	requirements = list(/obj/item/natural/cloth = 6, /obj/item/natural/fibers = 4, /obj/item/natural/silk = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 5

/datum/repeatable_crafting_recipe/sewing/ported/tailor_halfrobe
	name = "hierophant's shawl"
	output = /obj/item/clothing/armor/gambeson/heavy/hierophant
	requirements = list(/obj/item/natural/cloth = 6, /obj/item/natural/fibers = 5)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/tailor_monkrobe
	name = "pontifex's qaba"
	output = /obj/item/clothing/shirt/robe/pointfex
	requirements = list(/obj/item/natural/cloth = 6, /obj/item/natural/fibers = 5)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/tailor_naledisash
	name = "hierophant's sash"
	output = /obj/item/clothing/cloak/hierophant
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/tailor_otavangambeson
	name = "Amnian gambeson"
	output = /obj/item/clothing/armor/gambeson/heavy/otavan_ap
	requirements = list(/obj/item/natural/cloth = 6, /obj/item/natural/fibers = 5)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 6

/datum/repeatable_crafting_recipe/sewing/ported/taverndress
	name = "tavern dress"
	output = /obj/item/clothing/shirt/dress/tavern
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/tiyon
	name = "tiyon"
	output = /obj/item/clothing/head/tiyon
	requirements = list(/obj/item/natural/cloth = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/toga_dress
	name = "toga, dress"
	output = /obj/item/clothing/shirt/toga/dress
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/ported/torsosash
	name = "sash"
	output = /obj/item/clothing/cloak/sash
	requirements = list(/obj/item/natural/cloth = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/traditionpsydon
	name = "traditional tabard, Aonic"
	output = /obj/item/clothing/cloak/tabard/psydontabard/white
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/undividedclericcloak
	name = "cloak, undivided devotee"
	output = /obj/item/clothing/cloak/undividedcleric
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/undividedclerictabard
	name = "tabard, undivided devotee"
	output = /obj/item/clothing/cloak/templar/undividedcleric
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Cloak"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/velvetdress
	name = "velvet dress"
	output = /obj/item/clothing/shirt/dress/velvetdress
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Shirt"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/ported/witchhat
	name = "witch hat"
	output = /obj/item/clothing/head/witchhat
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/ported/woolencollar
	name = "wool collar"
	output = /obj/item/clothing/neck/collar/woolen
	requirements = list(/obj/item/natural/cloth = 1)
	attacked_atom = /obj/item/natural/cloth
	category = "Neck"
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/ported/workervest
	name = "striped tunic"
	output = /obj/item/clothing/armor/workervest
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 2)
	attacked_atom = /obj/item/natural/cloth
	category = "Armor"
	craftdiff = 1

/datum/repeatable_crafting_recipe/survival/ported/autumnwoadarmor
	name = "autumnwoad elven plate, imbuement"
	output = /obj/item/clothing/armor/rare/elfplate/welfplate/autumn
	requirements = list(/obj/item/natural/fibers = 3, /obj/item/grown/log/tree/stick = 3, /obj/item/clothing/armor/rare/elfplate/welfplate/autumn/light = 1, /obj/item/grown/log/tree/small = 1, /obj/item/natural/cured/essence = 1)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Armor"
	craftdiff = 1

/datum/repeatable_crafting_recipe/survival/ported/autumnwoadhelmet
	name = "autumnwoad elven helm, imbuement"
	output = /obj/item/clothing/head/rare/elfplate/welfplate/autumn
	requirements = list(/obj/item/natural/fibers = 3, /obj/item/grown/log/tree/stick = 3, /obj/item/clothing/head/rare/elfplate/welfplate/autumn/light = 1, /obj/item/grown/log/tree/small = 1, /obj/item/natural/cured/essence = 1)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Hat"
	craftdiff = 1

/datum/repeatable_crafting_recipe/survival/ported/collar
	name = "collar"
	output = /obj/item/clothing/neck/collar
	requirements = list(/obj/item/natural/hide/cured = 1)
	starting_atom = /obj/item/natural/hide/cured
	attacked_atom = /obj/item/natural/hide/cured
	subtypes_allowed = TRUE
	category = "Neck"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/decoratedmailledhauberk
	name = "layer a decorated cuirass atop hauberk"
	output = /obj/item/clothing/armor/chainmail/hauberk/heavy/decorated
	requirements = list(/obj/item/clothing/armor/cuirass/ornate/decorated = 1, /obj/item/clothing/armor/chainmail/hauberk = 1)
	starting_atom = /obj/item/clothing/armor/cuirass/ornate/decorated
	attacked_atom = /obj/item/clothing/armor/chainmail/hauberk
	subtypes_allowed = TRUE
	category = "Armor"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/flowercrown_rosa_gray
	name = "gray flower crown"
	output = /obj/item/clothing/head/flowercrown/rosa/dyecrown
	requirements = list(/obj/item/natural/fibers = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/natural/fibers
	subtypes_allowed = TRUE
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/flowercrown_rosa_thorns
	name = "rosa crown with thorns"
	output = /obj/item/clothing/head/flowercrown/rosa/thorns
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/natural/thorn = 2, /obj/item/alch/herb/rosa = 3)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/natural/thorn
	subtypes_allowed = TRUE
	category = "Hat"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/gothicironmailledhauberk
	name = "layer a gothic iron cuirass atop hauberk"
	output = /obj/item/clothing/armor/chainmail/hauberk/iron/heavy/donator_gothic
	requirements = list(/obj/item/clothing/armor/cuirass/iron/donator_gothic = 1, /obj/item/clothing/armor/chainmail/hauberk/iron = 1)
	starting_atom = /obj/item/clothing/armor/cuirass/iron/donator_gothic
	attacked_atom = /obj/item/clothing/armor/chainmail/hauberk/iron
	subtypes_allowed = TRUE
	category = "Armor"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/gothicmailledhauberk
	name = "layer a gothic cuirass atop hauberk"
	output = /obj/item/clothing/armor/chainmail/hauberk/heavy/donator_gothic
	requirements = list(/obj/item/clothing/armor/cuirass/donator_gothic = 1, /obj/item/clothing/armor/chainmail/hauberk = 1)
	starting_atom = /obj/item/clothing/armor/cuirass/donator_gothic
	attacked_atom = /obj/item/clothing/armor/chainmail/hauberk
	subtypes_allowed = TRUE
	category = "Armor"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/ironandclothhose
	name = "layer a cloth hose atop iron chain hosen"
	output = /obj/item/clothing/pants/chainlegs/iron/hose/dyeable
	requirements = list(/obj/item/clothing/pants/tights/hose = 1, /obj/item/clothing/pants/chainlegs/iron = 1)
	starting_atom = /obj/item/clothing/pants/tights/hose
	attacked_atom = /obj/item/clothing/pants/chainlegs/iron
	subtypes_allowed = TRUE
	category = "Pants"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/ironmailledhauberk
	name = "layer a iron cuirass atop hauberk"
	output = /obj/item/clothing/armor/chainmail/hauberk/iron/heavy
	requirements = list(/obj/item/clothing/armor/cuirass/iron = 1, /obj/item/clothing/armor/chainmail/hauberk/iron = 1)
	starting_atom = /obj/item/clothing/armor/cuirass/iron
	attacked_atom = /obj/item/clothing/armor/chainmail/hauberk/iron
	subtypes_allowed = TRUE
	category = "Armor"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/mailledhauberk
	name = "layer a steel cuirass atop hauberk"
	output = /obj/item/clothing/armor/chainmail/hauberk/heavy
	requirements = list(/obj/item/clothing/armor/cuirass = 1, /obj/item/clothing/armor/chainmail/hauberk = 1)
	starting_atom = /obj/item/clothing/armor/cuirass
	attacked_atom = /obj/item/clothing/armor/chainmail/hauberk
	subtypes_allowed = TRUE
	category = "Armor"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/steelandclothhose
	name = "layer a cloth hose atop steel chain hosen"
	output = /obj/item/clothing/pants/chainlegs/hose/dyeable
	requirements = list(/obj/item/clothing/pants/tights/hose = 1, /obj/item/clothing/pants/chainlegs/hose = 1)
	starting_atom = /obj/item/clothing/pants/tights/hose
	attacked_atom = /obj/item/clothing/pants/chainlegs/hose
	subtypes_allowed = TRUE
	category = "Pants"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/ported/woodabyssorcross
	name = "wooden amulet of Umberlee"
	output = /obj/item/clothing/neck/psycross/abyssor/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodastratacross
	name = "wooden amulet of Lathander"
	output = /obj/item/clothing/neck/psycross/astrata/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodbaothacross
	name = "wooden amulet of Blissara"
	output = /obj/item/clothing/neck/psycross/inhumen/baotha/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodcross
	name = "wooden holy symbol"
	output = /obj/item/clothing/neck/psycross/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/wooddendorcross
	name = "wooden amulet of Silvanus"
	output = /obj/item/clothing/neck/psycross/dendor/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodeoracross
	name = "wooden amulet of Sune"
	output = /obj/item/clothing/neck/psycross/eora/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodgraggarcross
	name = "wooden amulet of Gruumsh"
	output = /obj/item/clothing/neck/psycross/inhumen/graggar/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodmalumcross
	name = "wooden amulet of Moradin"
	output = /obj/item/clothing/neck/psycross/malum/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodmatthioscross
	name = "wooden amulet of Mask"
	output = /obj/item/clothing/neck/psycross/inhumen/matthios/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodnecracross
	name = "wooden amulet of Jergal"
	output = /obj/item/clothing/neck/psycross/necra/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodnoccross
	name = "wooden amulet of Mystra"
	output = /obj/item/clothing/neck/psycross/noc/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodpestracross
	name = "wooden amulet of Ilmater"
	output = /obj/item/clothing/neck/psycross/pestra/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodravoxcross
	name = "wooden amulet of Tempus"
	output = /obj/item/clothing/neck/psycross/ravox/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodreformcross
	name = "wooden reformist holy symbol"
	output = /obj/item/clothing/neck/psycross/reform/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodtencross
	name = "wooden amulet of Ten"
	output = /obj/item/clothing/neck/psycross/undivided/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodxylixcross
	name = "wooden amulet of Tymora"
	output = /obj/item/clothing/neck/psycross/xylix/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/survival/ported/woodzcross
	name = "wooden inverted holy symbol"
	output = /obj/item/clothing/neck/psycross/inhumen/wood
	requirements = list(/obj/item/natural/fibers = 2, /obj/item/grown/log/tree/stick = 2)
	starting_atom = /obj/item/natural/fibers
	attacked_atom = /obj/item/grown/log/tree/stick
	subtypes_allowed = TRUE
	category = "Neck"

/datum/repeatable_crafting_recipe/sewing/weaving/ported/abyssorhood
	name = "Umberlee hood"
	output = /obj/item/clothing/head/roguehood/abyssor
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/eorahood
	name = "Sunite hood"
	output = /obj/item/clothing/head/roguehood/eorahood
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/eoramask
	name = "Sune mask"
	output = /obj/item/clothing/head/eoramask
	requirements = list(/obj/item/ingot/silver = 1, /obj/item/natural/silk = 4)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/necrahood
	name = "Jergal hood"
	output = /obj/item/clothing/head/necrahood
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/ravoxhood
	name = "Tempus hood"
	output = /obj/item/clothing/head/roguehood/ravox
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/ravoxrobe
	name = "Tempus robes"
	output = /obj/item/clothing/shirt/robe/ravox
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/weaving/ported/rosa
	name = "ivory dress"
	output = /obj/item/clothing/shirt/tunic/rosa
	requirements = list(/obj/item/natural/silk = 3, /obj/item/natural/cloth = 2, /obj/item/alch/herb/rosa = 1)
	attacked_atom = /obj/machinery/loom
	category = "Shirt"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/weaving/ported/rosacloak
	name = "regal cloak"
	output = /obj/item/clothing/cloak/rosa
	requirements = list(/obj/item/natural/silk = 2, /obj/item/natural/cloth = 1, /obj/item/alch/herb/rosa = 1)
	attacked_atom = /obj/machinery/loom
	category = "Cloak"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/weaving/ported/rosahat
	name = "scarlet hat"
	output = /obj/item/clothing/head/rosa
	requirements = list(/obj/item/natural/silk = 2, /obj/item/natural/cloth = 1, /obj/item/alch/herb/rosa = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/weaving/ported/undividedclerichood
	name = "undivided devotee hood"
	output = /obj/item/clothing/head/roguehood/undividedcleric
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/undividedclericrobe
	name = "undivided devotee robes"
	output = /obj/item/clothing/shirt/robe/undividedcleric
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Shirt"
	craftdiff = 3

/datum/repeatable_crafting_recipe/sewing/weaving/ported/undividedhood
	name = "undivided hood"
	output = /obj/item/clothing/head/roguehood/undivided
	requirements = list(/obj/item/natural/cloth = 2, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Hat"
	craftdiff = 4

/datum/repeatable_crafting_recipe/sewing/weaving/ported/undividedrobe
	name = "undivided robes"
	output = /obj/item/clothing/shirt/robe/undivided
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/silk = 1)
	attacked_atom = /obj/machinery/loom
	category = "Shirt"
	craftdiff = 4
