// Panel icon groups and short tooltips for sex actions; the icons are /datum/asset/simple/sex_panel_icons.

/datum/sex_action
	/// Icon group shown before the name in the ERP panel.
	var/menu_category = "body"
	/// Ten words or fewer for the panel tooltip; null shows the name alone.
	var/menu_tip

/datum/asset/simple/sex_panel_icons
	assets = list(
		"sexcat_body.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_body.png',
		"sexcat_breasts.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_breasts.png',
		"sexcat_custom.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_custom.png',
		"sexcat_devices.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_devices.png',
		"sexcat_feet.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_feet.png',
		"sexcat_fluids.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_fluids.png',
		"sexcat_grind.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_grind.png',
		"sexcat_hands.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_hands.png',
		"sexcat_impact.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_impact.png',
		"sexcat_mouth.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_mouth.png',
		"sexcat_portal.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_portal.png',
		"sexcat_sex.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_sex.png',
		"sexcat_tail.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_tail.png',
		"sexcat_toys.png" = 'modular_rmh/modular/sex_panel/icons/sexcat_toys.png',
	)

/datum/sex_scene_controller/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/sex_panel_icons))

// ---- Groups by family ----

/datum/sex_action/custom
	menu_category = "custom"

/datum/sex_action/chastity
	menu_category = "devices"

/datum/sex_action/nipple_clamps
	menu_category = "devices"

/datum/sex_action/portal_base
	menu_category = "portal"

/datum/sex_action/beads
	menu_category = "toys"

/datum/sex_action/object_fuck
	menu_category = "toys"

/datum/sex_action/hole_storage
	menu_category = "toys"

/datum/sex_action/hole_storage/expel_foreign_fluids
	menu_category = "fluids"

/datum/sex_action/garment_pleasure
	menu_category = "toys"

/datum/sex_action/toy_grind
	menu_category = "toys"

/datum/sex_action/toy_lift_off
	menu_category = "toys"

/datum/sex_action/toy_seat_plug
	menu_category = "toys"

/datum/sex_action/toy_suck
	menu_category = "toys"

/datum/sex_action/lube_up
	menu_category = "fluids"

/datum/sex_action/collect_fluid
	menu_category = "fluids"

/datum/sex_action/milk_breasts
	menu_category = "fluids"

/datum/sex_action/spray_milk
	menu_category = "fluids"

/datum/sex_action/attach_fluid_pump
	menu_category = "fluids"

/datum/sex_action/remove_fluid_pump
	menu_category = "fluids"

/datum/sex_action/masturbate
	menu_category = "hands"

/datum/sex_action/rub_body
	menu_category = "hands"

/datum/sex_action/masturbate/slap_balls
	menu_category = "impact"

/datum/sex_action/masturbate/slap_breasts
	menu_category = "impact"

/datum/sex_action/masturbate/slap_pussy
	menu_category = "impact"

/datum/sex_action/masturbate/other/slap_balls
	menu_category = "impact"

/datum/sex_action/masturbate/other/slap_breasts
	menu_category = "impact"

/datum/sex_action/masturbate/other/slap_pussy
	menu_category = "impact"

/datum/sex_action/spanking
	menu_category = "impact"

/datum/sex_action/impact_play
	menu_category = "impact"

/datum/sex_action/wax_play
	menu_category = "impact"

/datum/sex_action/feather_tickling
	menu_category = "impact"

/datum/sex_action/tear_stockings
	menu_category = "impact"

/datum/sex_action/masturbate/heft_breasts
	menu_category = "breasts"

/datum/sex_action/masturbate/squeeze_together
	menu_category = "breasts"

/datum/sex_action/bounce_breasts
	menu_category = "breasts"

/datum/sex_action/breast_press
	menu_category = "breasts"

/datum/sex_action/cleavage_smother
	menu_category = "breasts"

/datum/sex_action/sex/other/boobjob
	menu_category = "breasts"

/datum/sex_action/sex
	menu_category = "sex"

/datum/sex_action/held_mob_fuck
	menu_category = "sex"

/datum/sex_action/bellyriding/anal
	menu_category = "sex"

/datum/sex_action/bellyriding/vaginal
	menu_category = "sex"

/datum/sex_action/frotting
	menu_category = "grind"

/datum/sex_action/scissoring
	menu_category = "grind"

/datum/sex_action/grind
	menu_category = "grind"

/datum/sex_action/bellyriding/frot
	menu_category = "grind"

/datum/sex_action/bellyriding/groin_rub
	menu_category = "grind"

/datum/sex_action/sex/other/footjob
	menu_category = "feet"

/datum/sex_action/sex/other/thighjob
	menu_category = "feet"

/datum/sex_action/footjob_intimate
	menu_category = "feet"

/datum/sex_action/foot_grind_vagina
	menu_category = "feet"

/datum/sex_action/use_their_feet
	menu_category = "feet"

/datum/sex_action/thigh_head
	menu_category = "feet"

/datum/sex_action/tailjob
	menu_category = "tail"

/datum/sex_action/tentacle_jerk
	menu_category = "tail"

/datum/sex_action/maneater_vine_caress
	menu_category = "tail"

/datum/sex_action/blowjob
	menu_category = "mouth"

/datum/sex_action/cunnilingus
	menu_category = "mouth"

/datum/sex_action/rimming
	menu_category = "mouth"

/datum/sex_action/suck_balls
	menu_category = "mouth"

/datum/sex_action/suck_nipples
	menu_category = "mouth"

/datum/sex_action/suck_own_nipple
	menu_category = "mouth"

/datum/sex_action/penis_head_worship
	menu_category = "mouth"

/datum/sex_action/kissing
	menu_category = "mouth"

/datum/sex_action/foot_lick
	menu_category = "mouth"

/datum/sex_action/armpit_nuzzle
	menu_category = "mouth"

/datum/sex_action/crotch_nuzzle
	menu_category = "mouth"

/datum/sex_action/tonguebath
	menu_category = "mouth"

/datum/sex_action/lick_coat
	menu_category = "mouth"

/datum/sex_action/lick_soaked_clothes
	menu_category = "mouth"

/datum/sex_action/facesitting
	menu_category = "mouth"

/datum/sex_action/held_head_oral
	menu_category = "mouth"

// ---- Tooltips for names that do not say enough ----

/datum/sex_action/attach_fluid_pump
	menu_tip = "Fit the held pump over a matching organ."

/datum/sex_action/remove_fluid_pump
	menu_tip = "Pop a fitted pump off, reservoir and all."

/datum/sex_action/beads/bear_down/anus
	menu_tip = "Push the beads out of your ass, no hands."

/datum/sex_action/beads/bear_down/vagina
	menu_tip = "Push the beads out of your pussy, no hands."

/datum/sex_action/beads/draw
	menu_tip = "Pull the beads out one pop at a time."

/datum/sex_action/beads/feed
	menu_tip = "Push the bead string in, one bead at a time."

/datum/sex_action/beads/tug
	menu_tip = "Tug the ring so the beads shift inside."

/datum/sex_action/beads/work
	menu_tip = "Pop the outer bead out and back in, repeatedly."

/datum/sex_action/beads/yank
	menu_tip = "Rip the whole bead string out at once."

/datum/sex_action/bounce_breasts
	menu_tip = "Make your breasts bounce for onlookers."

/datum/sex_action/breast_press
	menu_tip = "Rub your breasts against theirs."

/datum/sex_action/bury_face
	menu_tip = "Press your face between their breasts."

/datum/sex_action/chastity/cage_to_belt
	menu_tip = "Grind your caged cock against their belt plate."

/datum/sex_action/chastity/cage_to_cage
	menu_tip = "Grind your caged cock against their cage."

/datum/sex_action/chastity/force_belt
	menu_tip = "Hold their mouth against the front of your belt."

/datum/sex_action/chastity/force_cage
	menu_tip = "Push their mouth over the bars of your cage."

/datum/sex_action/chastity/force_rim
	menu_tip = "Hold their mouth against your rear shield."

/datum/sex_action/chastity/frot_device
	menu_tip = "Slide your cock along their locked cage."

/datum/sex_action/chastity/frot_on_cage
	menu_tip = "Work their cock along the bars of your cage."

/datum/sex_action/chastity/grind_cage_pussy
	menu_tip = "Roll your cage's bars along their bare pussy."

/datum/sex_action/chastity/grind_cage_slit
	menu_tip = "Roll your cage's bars along their genital slit."

/datum/sex_action/chastity/hands/fondle
	menu_tip = "Squeeze and roll their chastity device in your palm."

/datum/sex_action/chastity/hands/rub_pussy
	menu_tip = "Work your fingers along the front of their belt."

/datum/sex_action/chastity/hands/self_cock
	menu_tip = "Stroke your own caged cock through the bars."

/datum/sex_action/chastity/hands/self_pussy
	menu_tip = "Rub at the front plate of your own belt."

/datum/sex_action/chastity/hands/self_rear
	menu_tip = "Press at the rear plate of your own device."

/datum/sex_action/chastity/hands/stroke_cock
	menu_tip = "Stroke their caged cock through the bars."

/datum/sex_action/chastity/hands/tease_rear
	menu_tip = "Press along the seam of their rear shield."

/datum/sex_action/chastity/hands/work_insert
	menu_tip = "Rock their belt so the plug inside moves."

/datum/sex_action/chastity/lick_belt
	menu_tip = "Tongue through the front slits of their belt."

/datum/sex_action/chastity/nuzzle_cage
	menu_tip = "Hold their face against your caged cock."

/datum/sex_action/chastity/ride_cage
	menu_tip = "Grind your pussy down on their caged cock."

/datum/sex_action/chastity/ride_cage_slit
	menu_tip = "Grind your slit down on their caged cock."

/datum/sex_action/chastity/rim_shield
	menu_tip = "Lick along the edges of their rear shield."

/datum/sex_action/chastity/scissor_belt
	menu_tip = "Grind your pussy against their belt's plate."

/datum/sex_action/chastity/scissor_belts
	menu_tip = "Grind your belt plate against theirs."

/datum/sex_action/chastity/scissor_locked
	menu_tip = "Grind your belt plate against their bare pussy."

/datum/sex_action/chastity/tail/cage
	menu_tip = "Tease their caged cock with your tail tip."

/datum/sex_action/chastity/tail/shield
	menu_tip = "Work your tail tip along their rear shield."

/datum/sex_action/cleavage_smother
	menu_tip = "Hold their face between your breasts; hard force chokes."

/datum/sex_action/collect_fluid/other
	menu_tip = "Milk their release into the container you hold."

/datum/sex_action/collect_fluid/self
	menu_tip = "Pleasure yourself into the container you hold."

/datum/sex_action/feather_tickling
	menu_tip = "Tickle the doll-selected spot with a held feather."

/datum/sex_action/foot_grind_vagina
	menu_tip = "Grind your foot against their pussy."

/datum/sex_action/footjob_intimate/penis
	menu_tip = "Rub their cock with your foot."

/datum/sex_action/footjob_intimate/vagina
	menu_tip = "Rub their pussy with your foot."

/datum/sex_action/frotting
	menu_tip = "Rub your cock against theirs."

/datum/sex_action/garment_pleasure/other
	menu_tip = "Rub a held garment on them; it soaks their climax."

/datum/sex_action/garment_pleasure/self
	menu_tip = "Rub a held garment on yourself; it soaks your climax."

/datum/sex_action/grind/partner
	menu_tip = "Grind your crotch on them; height decides what you reach."

/datum/sex_action/grind/pillow
	menu_tip = "Straddle or clamp the pillows on your tile."

/datum/sex_action/grind/seat
	menu_tip = "Rock your hips quietly against the seat you sit on."

/datum/sex_action/grind/thing
	menu_tip = "Grind your crotch against a thing next to you."

/datum/sex_action/held_head_oral/penis
	menu_tip = "Use the severed head you hold on a cock."

/datum/sex_action/held_head_oral/vagina
	menu_tip = "Use the severed head you hold on a pussy."

/datum/sex_action/held_mob_fuck/anal
	menu_tip = "Fuck the ass of the small person you hold."

/datum/sex_action/held_mob_fuck/vaginal
	menu_tip = "Fuck the pussy of the small person you hold."

/datum/sex_action/held_mob_squirm
	menu_tip = "Thrash to throw off whoever holds and uses you."

/datum/sex_action/hole_storage/anus_remove
	menu_tip = "Take items out of the ass by hand."

/datum/sex_action/hole_storage/anus_remove_deep
	menu_tip = "Push out items lodged deep in your ass."

/datum/sex_action/hole_storage/anus_store
	menu_tip = "Push the held item into the ass."

/datum/sex_action/hole_storage/boobs_remove
	menu_tip = "Take out items tucked between the breasts."

/datum/sex_action/hole_storage/boobs_store
	menu_tip = "Tuck the held item between the breasts."

/datum/sex_action/hole_storage/expel_foreign_fluids/anal
	menu_tip = "Push fluids from the ass; a held container catches them."

/datum/sex_action/hole_storage/expel_foreign_fluids/vaginal
	menu_tip = "Push fluids from the pussy; a held container catches them."

/datum/sex_action/hole_storage/vagina_remove
	menu_tip = "Take items out of the pussy by hand."

/datum/sex_action/hole_storage/vagina_remove_deep
	menu_tip = "Push out items lodged deep in your pussy."

/datum/sex_action/hole_storage/vagina_store
	menu_tip = "Push the held item into the pussy."

/datum/sex_action/impact_play
	menu_tip = "Strike the doll-selected spot with a held crop or paddle."

/datum/sex_action/lay_eggs_floor
	menu_tip = "Squat and lay your clutch on the ground."

/datum/sex_action/lay_womb_eggs
	menu_tip = "Bear down and push a ripe egg from your womb."

/datum/sex_action/lick_coat
	menu_tip = "Lick the fluid off their bare skin."

/datum/sex_action/lick_soaked_clothes/chest
	menu_tip = "Suck fluid from the soaked clothes over their chest."

/datum/sex_action/lick_soaked_clothes/crotch
	menu_tip = "Suck fluid from the soaked clothes over their crotch."

/datum/sex_action/lube_up/anus
	menu_tip = "Slick the ass with a held balm, oil, or spit."

/datum/sex_action/lube_up/vagina
	menu_tip = "Slick the pussy with a held balm, oil, or spit."

/datum/sex_action/lube_up/toy
	menu_tip = "Slick the held toy with balm, oil, or spit."

/datum/sex_action/lube_up/standing_toy
	menu_tip = "Slick a nearby standing toy with balm, oil, or spit."

/datum/sex_action/maneater_vine_caress
	menu_tip = "Stroke and squeeze their body with sap-slick tendrils."

/datum/sex_action/masturbate/heft_breasts
	menu_tip = "Lift your breasts and let them drop with a bounce."

/datum/sex_action/masturbate/labia
	menu_tip = "Play with and tug at your labia."

/datum/sex_action/masturbate/other/labia
	menu_tip = "Play with and tug at their labia."

/datum/sex_action/masturbate/other/squeeze_breasts
	menu_tip = "Knead their breasts with both hands."

/datum/sex_action/masturbate/penis_over
	menu_tip = "Jerk your cock over them, to finish on them."

/datum/sex_action/masturbate/squeeze_together
	menu_tip = "Press your breasts together for onlookers."

/datum/sex_action/milk_breasts/other
	menu_tip = "Milk their breasts into the open container you hold."

/datum/sex_action/milk_breasts/self
	menu_tip = "Milk your breasts into the open container you hold."

/datum/sex_action/nipple_clamps/take_off
	menu_tip = "Take off their nipple clamps."

/datum/sex_action/nipple_clamps/tug
	menu_tip = "Pull the chain between their nipple clamps."

/datum/sex_action/object_fuck/object_anal
	menu_tip = "Fuck your own ass with the held toy."

/datum/sex_action/object_fuck/object_anal_other
	menu_tip = "Fuck their ass with the held toy."

/datum/sex_action/object_fuck/object_vaginal
	menu_tip = "Fuck your own pussy with the held toy."

/datum/sex_action/object_fuck/object_vaginal_other
	menu_tip = "Fuck their pussy with the held toy."

/datum/sex_action/object_fuck/ride/anus
	menu_tip = "Sink your ass onto a toy standing on your tile."

/datum/sex_action/object_fuck/ride/both
	menu_tip = "Sink onto two standing toys, one in each hole."

/datum/sex_action/object_fuck/ride/forced/anus
	menu_tip = "Push their ass down onto a standing toy beside them."

/datum/sex_action/object_fuck/ride/forced/vagina
	menu_tip = "Push their pussy down onto a standing toy beside them."

/datum/sex_action/object_fuck/ride/vagina
	menu_tip = "Sink your pussy onto a toy standing on your tile."

/datum/sex_action/penis_head_worship
	menu_tip = "Kiss and lick the head of their cock."

/datum/sex_action/portal_base/portal_hand
	menu_tip = "Finger the pussy of whoever wears the linked panties."

/datum/sex_action/portal_base/portal_hand_anal
	menu_tip = "Finger the ass of whoever wears the linked panties."

/datum/sex_action/portal_base/portal_oral
	menu_tip = "Lick the pussy of whoever wears the linked panties."

/datum/sex_action/portal_base/portal_oral_anal
	menu_tip = "Rim the ass of whoever wears the linked panties."

/datum/sex_action/portal_base/portal_penis_anal
	menu_tip = "Fuck the ass of whoever wears the linked panties."

/datum/sex_action/portal_base/portal_penis_vaginal
	menu_tip = "Fuck the pussy of whoever wears the linked panties."

/datum/sex_action/portal_base/portal_remove_anal
	menu_tip = "Take items out of the linked wearer's ass."

/datum/sex_action/portal_base/portal_remove_vaginal
	menu_tip = "Take items out of the linked wearer's pussy."

/datum/sex_action/portal_base/portal_store_anal
	menu_tip = "Push the held item into the linked wearer's ass."

/datum/sex_action/portal_base/portal_store_vaginal
	menu_tip = "Push the held item into the linked wearer's pussy."

/datum/sex_action/portal_base/portal_vagina_anal
	menu_tip = "Grind your pussy on the linked wearer's ass."

/datum/sex_action/portal_base/portal_vagina_vaginal
	menu_tip = "Grind your pussy on the linked wearer's pussy."

/datum/sex_action/rub_body
	menu_tip = "Run your hands over their body."

/datum/sex_action/scissoring
	menu_tip = "Rub your pussy against theirs."

/datum/sex_action/sex/boobjob
	menu_tip = "Fuck the cleavage between their breasts."

/datum/sex_action/sex/lay_eggs/anal
	menu_tip = "Lay your eggs in their ass, one at a time."

/datum/sex_action/sex/lay_eggs/throat
	menu_tip = "Lay your eggs down their throat, one at a time."

/datum/sex_action/sex/lay_eggs/vaginal
	menu_tip = "Lay your eggs in their pussy, one at a time."

/datum/sex_action/sex/other/anal
	menu_tip = "Ride their cock with your ass."

/datum/sex_action/sex/other/boobjob
	menu_tip = "Work their cock between your breasts with your hands."

/datum/sex_action/sex/other/boobjob/hands_free
	menu_tip = "Work their cock between your breasts, no hands."

/datum/sex_action/sex/other/thighjob
	menu_tip = "Work their cock between your thighs."

/datum/sex_action/sex/other/vagina
	menu_tip = "Ride their cock with your pussy."

/datum/sex_action/sex/thighjob
	menu_tip = "Fuck the gap between their thighs."

/datum/sex_action/spray_milk
	menu_tip = "Squeeze a stream of milk over them."

/datum/sex_action/suck_nipples/own_head
	menu_tip = "Hold your severed head to your own breast."

/datum/sex_action/suck_own_nipple
	menu_tip = "Lift your own breast to your mouth and suckle."

/datum/sex_action/blowjob/own_head
	menu_tip = "Bring your severed head down onto your own cock."

/datum/sex_action/cunnilingus/own_head
	menu_tip = "Bring your severed head down onto your own pussy."

/datum/sex_action/rimming/own_head
	menu_tip = "Bring your severed head around to your own ass."

/datum/sex_action/tailjob/penis
	menu_tip = "Tease their cock with your tail."

/datum/sex_action/tailjob/vagina
	menu_tip = "Tease their pussy with your tail."

/datum/sex_action/tear_stockings
	menu_tip = "Rip the stockings into ragged ladders."

/datum/sex_action/tentacle_jerk
	menu_tip = "Coil a small tentacle around their cock."

/datum/sex_action/tentacle_jerk/maneater
	menu_tip = "Coil a flowering tendril around their cock."

/datum/sex_action/thigh_head
	menu_tip = "Hold their severed head snug between your thighs."

/datum/sex_action/tonguebath
	menu_tip = "Lick their body all over."

/datum/sex_action/toy_grind
	menu_tip = "Rub along a standing toy without taking it in."

/datum/sex_action/toy_lift_off
	menu_tip = "Haul someone stuck on a standing toy up off it."

/datum/sex_action/toy_seat_plug/anus
	menu_tip = "Take a standing plug into your ass and keep it."

/datum/sex_action/toy_seat_plug/vagina
	menu_tip = "Take a standing plug into your pussy and keep it."

/datum/sex_action/toy_suck
	menu_tip = "Kneel and suck a standing toy until it shines."

/datum/sex_action/toy_suck/forced
	menu_tip = "Push their mouth onto a standing toy."

/datum/sex_action/use_their_feet/penis
	menu_tip = "Fuck the soles of their feet."

/datum/sex_action/use_their_feet/vagina
	menu_tip = "Grind your pussy on their feet."

/datum/sex_action/wax_play
	menu_tip = "Drip a held candle's wax on the doll-selected spot."
