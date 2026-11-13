/// Verbs of the Emotes.Wildtongue section.
GLOBAL_LIST_INIT(wildtongue_verbs, list(
	/mob/living/carbon/human/species/rakshari/verb/emote_meow,
	/mob/living/carbon/human/species/rakshari/verb/emote_purr,
	/mob/living/carbon/human/proc/wildtongue_mreow,
	/mob/living/carbon/human/proc/wildtongue_mrrp,
	/mob/living/carbon/human/proc/wildtongue_trill,
	/mob/living/carbon/human/proc/wildtongue_roar,
	/mob/living/carbon/human/proc/wildtongue_caw,
	/mob/living/carbon/human/proc/wildtongue_peep,
	/mob/living/carbon/human/proc/wildtongue_hoot,
	/mob/living/carbon/human/proc/wildtongue_squeak,
	/mob/living/carbon/human/proc/wildtongue_hiss,
	/mob/living/carbon/human/proc/wildtongue_phiss,
	/mob/living/carbon/human/proc/wildtongue_howl,
	/mob/living/carbon/human/proc/wildtongue_cackle,
	/mob/living/carbon/human/proc/wildtongue_whine,
	/mob/living/carbon/human/proc/wildtongue_fwhine,
	/mob/living/carbon/human/proc/wildtongue_psnort,
	/mob/living/carbon/human/proc/wildtongue_oink,
	/mob/living/carbon/human/proc/wildtongue_moo,
	/mob/living/carbon/human/proc/wildtongue_bark,
	/mob/living/carbon/human/proc/wildtongue_growl,
	/mob/living/carbon/human/proc/wildtongue_prbt,
	/mob/living/carbon/human/proc/wildtongue_bleat,
	/mob/living/carbon/human/proc/wildtongue_chitter,
	/mob/living/carbon/human/proc/wildtongue_flutter,
	/mob/living/carbon/human/proc/wildtongue_yip,
	/mob/living/carbon/human/proc/wildtongue_bellow,
	/mob/living/carbon/human/proc/wildtongue_lizhiss,
	/mob/living/carbon/human/proc/wildtongue_squeal,
	/mob/living/carbon/human/proc/wildtongue_thump,
))

/// Tongue that unlocks the Emotes.Wildtongue verbs for any species.
/obj/item/organ/tongue/wild_tongue
	name = "wild tongue"
	desc = "A rough, flexible tongue, shaped for the calls of beasts as much as for speech."

/obj/item/organ/tongue/wild_tongue/Initialize(mapload)
	. = ..()
	emote_verbs = GLOB.wildtongue_verbs

/datum/species
	/// Spawns with a wild tongue instead of the plain one. Opt-in only.
	var/wild_tongue = FALSE

/datum/species/New()
	if(wild_tongue && organs && organs[ORGAN_SLOT_TONGUE] == /obj/item/organ/tongue)
		organs = organs.Copy()
		organs[ORGAN_SLOT_TONGUE] = /obj/item/organ/tongue/wild_tongue
	return ..()

/datum/species/anthromorph
	wild_tongue = TRUE

/datum/species/anthromorphsmall
	wild_tongue = TRUE

/datum/species/half_anthromorphsmall
	wild_tongue = TRUE

/datum/species/demihuman
	wild_tongue = TRUE

/datum/species/taur_kin
	wild_tongue = TRUE

/datum/species/rakshari
	wild_tongue = TRUE

/datum/species/tabaxi
	wild_tongue = TRUE

/datum/species/harpy
	wild_tongue = TRUE

/datum/species/medicator
	wild_tongue = TRUE

/datum/species/kobold
	wild_tongue = TRUE

/datum/species/gnoll
	wild_tongue = TRUE

/datum/species/gnoll_champion
	wild_tongue = TRUE

/datum/species/werewolf
	wild_tongue = TRUE

/datum/species/minotaur
	wild_tongue = TRUE

/datum/species/white_stag
	wild_tongue = TRUE

/obj/item/organ/tongue
	/// Verbs granted to the owner while this tongue is inserted.
	var/list/emote_verbs

/obj/item/organ/tongue/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, new_zone = null)
	. = ..()
	if(!length(emote_verbs))
		return
	var/list/missing = emote_verbs - M.verbs
	if(length(missing))
		add_verb(M, missing)

/obj/item/organ/tongue/Remove(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!length(emote_verbs))
		return
	var/list/present = emote_verbs & M.verbs
	if(length(present))
		remove_verb(M, present)

/// Animal noises that need a wild tongue.
/datum/emote/living/wildtongue
	vary = TRUE
	show_runechat = FALSE
	message_muffled = "makes a muffled sound!"

/datum/emote/living/wildtongue/can_run_emote(mob/user, status_check = TRUE, intentional)
	. = ..()
	if(!.)
		return
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/carbon_user = user
	return istype(carbon_user.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/wild_tongue)

/datum/emote/living/wildtongue/get_sound(mob/living/user)
	if(!can_voice_beast_noise(user))
		return null
	return ..()

/datum/emote/living/carbon/human/rakshari/get_sound(mob/living/user)
	if(!can_voice_beast_noise(user))
		return null
	return ..()

/datum/emote/living/carbon/human/rakshari/purr
	message_muffled = "makes a muffled sound!"

/// Gagged, bagged, mute or with a hand over the mouth: the text turns muffled, the call itself is not heard.
/datum/emote/proc/can_voice_beast_noise(mob/living/user)
	if(!message_muffled || !iscarbon(user))
		return TRUE
	var/mob/living/carbon/carbon_user = user
	return carbon_user.can_speak_vocal()

/datum/emote/living/wildtongue/mreow
	key = "mreow"
	key_third_person = "mreows"
	message = "mreows!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/cat/cat_meow4.ogg'

/mob/living/carbon/human/proc/wildtongue_mreow()
	set name = "Mreow"
	set category = "Emotes.Wildtongue"
	emote("mreow", intentional = TRUE)

/datum/emote/living/wildtongue/mrrp
	key = "mrrp"
	key_third_person = "mrrps"
	message = "mrrps!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/cat/mrrp.ogg'

/mob/living/carbon/human/proc/wildtongue_mrrp()
	set name = "Mrrp"
	set category = "Emotes.Wildtongue"
	emote("mrrp", intentional = TRUE)

/datum/emote/living/wildtongue/trill
	key = "trill"
	key_third_person = "trills"
	message = "trills!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/cat/trill.ogg'

/mob/living/carbon/human/proc/wildtongue_trill()
	set name = "Trill"
	set category = "Emotes.Wildtongue"
	emote("trill", intentional = TRUE)

/datum/emote/living/wildtongue/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/mobs/cat/roar1.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/cat/roar2.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/cat/roar3.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/cat/roar4.ogg')

/mob/living/carbon/human/proc/wildtongue_roar()
	set name = "Roar"
	set category = "Emotes.Wildtongue"
	emote("roar", intentional = TRUE)

/datum/emote/living/wildtongue/caw
	key = "caw"
	key_third_person = "caws"
	message = "caws!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('sound/vo/mobs/bird/CROW_01.ogg', 'sound/vo/mobs/bird/CROW_03.ogg')

/mob/living/carbon/human/proc/wildtongue_caw()
	set name = "Caw"
	set category = "Emotes.Wildtongue"
	emote("caw", intentional = TRUE)

/datum/emote/living/wildtongue/peep
	key = "peep"
	key_third_person = "peeps"
	message = "peeps!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/bird/peep.ogg'

/mob/living/carbon/human/proc/wildtongue_peep()
	set name = "Peep"
	set category = "Emotes.Wildtongue"
	emote("peep", intentional = TRUE)

/datum/emote/living/wildtongue/hoot
	key = "hoot"
	key_third_person = "hoots"
	message = "hoots!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/bird/hoot.ogg'

/mob/living/carbon/human/proc/wildtongue_hoot()
	set name = "Hoot"
	set category = "Emotes.Wildtongue"
	emote("hoot", intentional = TRUE)

/datum/emote/living/wildtongue/squeak
	key = "squeak"
	key_third_person = "squeaks"
	message = "squeaks!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/mouse/squeak.ogg'

/mob/living/carbon/human/proc/wildtongue_squeak()
	set name = "Squeak"
	set category = "Emotes.Wildtongue"
	emote("squeak", intentional = TRUE)

/datum/emote/living/wildtongue/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/snake/hiss.ogg'

/mob/living/carbon/human/proc/wildtongue_hiss()
	set name = "Hiss"
	set category = "Emotes.Wildtongue"
	emote("hiss", intentional = TRUE)

/datum/emote/living/wildtongue/phiss
	key = "phiss"
	key_third_person = "phisses"
	message = "hisses!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/possum/phiss.ogg'

/mob/living/carbon/human/proc/wildtongue_phiss()
	set name = "PHiss"
	set category = "Emotes.Wildtongue"
	emote("phiss", intentional = TRUE)

/datum/emote/living/wildtongue/howl
	key = "howl"
	key_third_person = "howls"
	message = "howls!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/mobs/wwolf/ehowl1.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/wwolf/ehowl2.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/wwolf/ehowl3.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/wwolf/ehowl4.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/wwolf/ehowl5.ogg')

/mob/living/carbon/human/proc/wildtongue_howl()
	set name = "Howl"
	set category = "Emotes.Wildtongue"
	emote("howl", intentional = TRUE)

/datum/emote/living/wildtongue/cackle
	key = "cackle"
	key_third_person = "cackles"
	message = "cackles!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/hyena/cackle.ogg'

/mob/living/carbon/human/proc/wildtongue_cackle()
	set name = "Cackle"
	set category = "Emotes.Wildtongue"
	emote("cackle", intentional = TRUE)

/datum/emote/living/wildtongue/whine
	key = "whine"
	key_third_person = "whines"
	message = "whines."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/vw/whine.ogg'

/mob/living/carbon/human/proc/wildtongue_whine()
	set name = "Whine"
	set category = "Emotes.Wildtongue"
	emote("whine", intentional = TRUE)

/datum/emote/living/wildtongue/fwhine
	key = "fwhine"
	key_third_person = "fwhines"
	message = "whines like a Venard."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/mobs/venard/fox1.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox2.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox3.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox4.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox5.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox6.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox7.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox8.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox9.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox10.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox11.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox12.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/venard/fox13.ogg')

/mob/living/carbon/human/proc/wildtongue_fwhine()
	set name = "Whine (Venard)"
	set category = "Emotes.Wildtongue"
	emote("fwhine", intentional = TRUE)

/datum/emote/living/wildtongue/psnort
	key = "psnort"
	key_third_person = "psnorts"
	message = "lets out an elongated snort."
	emote_type = EMOTE_AUDIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/dog/pugsnort.ogg'

/mob/living/carbon/human/proc/wildtongue_psnort()
	set name = "Snort (Animal)"
	set category = "Emotes.Wildtongue"
	emote("psnort", intentional = TRUE)

/datum/emote/living/wildtongue/oink
	key = "oink"
	key_third_person = "oinks"
	message = "oinks."
	emote_type = EMOTE_AUDIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/mobs/pig/pig1.ogg', 'modular_rmh/modular/wildtongue/sound/mobs/pig/pig2.ogg')

/mob/living/carbon/human/proc/wildtongue_oink()
	set name = "Oink"
	set category = "Emotes.Wildtongue"
	emote("oink", intentional = TRUE)

/datum/emote/living/wildtongue/moo
	key = "moo"
	key_third_person = "moos"
	message = "moos!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('sound/vo/mobs/minotaur/minoidle.ogg', 'sound/vo/mobs/minotaur/minoidle2.ogg', 'sound/vo/mobs/minotaur/minoidle3.ogg')

/mob/living/carbon/human/proc/wildtongue_moo()
	set name = "Moo"
	set category = "Emotes.Wildtongue"
	emote("moo", intentional = TRUE)

/datum/emote/living/wildtongue/bark
	key = "bark"
	key_third_person = "barks"
	message = "barks!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('sound/vo/mobs/vw/bark (1).ogg', 'sound/vo/mobs/vw/bark (2).ogg', 'sound/vo/mobs/vw/bark (3).ogg', 'sound/vo/mobs/vw/bark (4).ogg', 'sound/vo/mobs/vw/bark (5).ogg', 'sound/vo/mobs/vw/bark (6).ogg', 'sound/vo/mobs/vw/bark (7).ogg')

/mob/living/carbon/human/proc/wildtongue_bark()
	set name = "Bark"
	set category = "Emotes.Wildtongue"
	emote("bark", intentional = TRUE)

/datum/emote/living/wildtongue/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('sound/vo/mobs/vw/idle (1).ogg', 'sound/vo/mobs/vw/idle (2).ogg', 'sound/vo/mobs/vw/idle (3).ogg', 'sound/vo/mobs/vw/idle (4).ogg')

/mob/living/carbon/human/proc/wildtongue_growl()
	set name = "Growl"
	set category = "Emotes.Wildtongue"
	emote("growl", intentional = TRUE)

/datum/emote/living/wildtongue/prbt
	key = "prbt"
	key_third_person = "prbts"
	message = "prbts!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/mobs/shark/prbt.ogg'

/mob/living/carbon/human/proc/wildtongue_prbt()
	set name = "Prbt"
	set category = "Emotes.Wildtongue"
	emote("prbt", intentional = TRUE)

/datum/emote/living/wildtongue/bleat
	key = "bleat"
	key_third_person = "bleats"
	message = "bleats!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = list('sound/vo/mobs/goat/idle (1).ogg', 'sound/vo/mobs/goat/idle (2).ogg', 'sound/vo/mobs/goat/idle (3).ogg')

/mob/living/carbon/human/proc/wildtongue_bleat()
	set name = "Bleat"
	set category = "Emotes.Wildtongue"
	emote("bleat", intentional = TRUE)

/datum/emote/living/wildtongue/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/moth/mothchitter.ogg'

/mob/living/carbon/human/proc/wildtongue_chitter()
	set name = "Chitter"
	set category = "Emotes.Wildtongue"
	emote("chitter", intentional = TRUE)

/datum/emote/living/wildtongue/flutter
	key = "flutter"
	key_third_person = "flutters"
	message = "flutters!"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	message_muffled = null

/mob/living/carbon/human/proc/wildtongue_flutter()
	set name = "Flutter"
	set category = "Emotes.Wildtongue"
	emote("flutter", intentional = TRUE)

/datum/emote/living/wildtongue/yip
	key = "yip"
	key_third_person = "yips"
	message = "yips!"
	emote_type = EMOTE_AUDIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/yip.ogg', 'modular_rmh/modular/wildtongue/sound/yip2.ogg', 'modular_rmh/modular/wildtongue/sound/yip3.ogg')

/mob/living/carbon/human/proc/wildtongue_yip()
	set name = "Yip"
	set category = "Emotes.Wildtongue"
	emote("yip", intentional = TRUE)

/datum/emote/living/wildtongue/bellow
	key = "bellow"
	key_third_person = "bellows"
	message = "bellows!"
	emote_type = EMOTE_AUDIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/LizardBellow.ogg'

/mob/living/carbon/human/proc/wildtongue_bellow()
	set name = "LizBellow"
	set category = "Emotes.Wildtongue"
	emote("bellow", intentional = TRUE)

/datum/emote/living/wildtongue/lizhiss
	key = "lizhiss"
	key_third_person = "lizhisses"
	message = "hisses!"
	emote_type = EMOTE_AUDIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/LizardHiss.ogg'

/mob/living/carbon/human/proc/wildtongue_lizhiss()
	set name = "LizHiss"
	set category = "Emotes.Wildtongue"
	emote("lizhiss", intentional = TRUE)

/datum/emote/living/wildtongue/squeal
	key = "squeal"
	key_third_person = "squeals"
	message = "squeals!"
	emote_type = EMOTE_AUDIBLE
	sound = 'modular_rmh/modular/wildtongue/sound/LizardSqueal.ogg'

/mob/living/carbon/human/proc/wildtongue_squeal()
	set name = "LizSqueal"
	set category = "Emotes.Wildtongue"
	emote("squeal", intentional = TRUE)

/datum/emote/living/wildtongue/thump
	key = "thump"
	key_third_person = "thumps"
	message = "thumps!"
	emote_type = EMOTE_VISIBLE
	message_muffled = null
	sound = 'modular_rmh/modular/wildtongue/sound/LizardThump.ogg'

/mob/living/carbon/human/proc/wildtongue_thump()
	set name = "LizThump"
	set category = "Emotes.Wildtongue"
	emote("thump", intentional = TRUE)

// Plain human noises
/datum/emote/living/gulp
	key = "gulp"
	key_third_person = "gulps"
	message = "gulps."
	emote_type = EMOTE_AUDIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/gulp.ogg', 'modular_rmh/modular/wildtongue/sound/gulp2.ogg')

/mob/living/carbon/human/verb/emote_gulp()
	set name = "Gulp"
	set category = "Emotes.Noises"
	emote("gulp", intentional = TRUE)

/datum/emote/living/facepalm
	key = "facepalm"
	key_third_person = "facepalms"
	message = "facepalms."
	emote_type = EMOTE_AUDIBLE
	sound = list('modular_rmh/modular/wildtongue/sound/facepalm1.ogg', 'modular_rmh/modular/wildtongue/sound/facepalm2.ogg')

/mob/living/carbon/human/verb/emote_facepalm()
	set name = "Facepalm"
	set category = "Emotes.Noises"
	emote("facepalm", intentional = TRUE)
