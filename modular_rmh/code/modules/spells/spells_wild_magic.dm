/datum/action/cooldown/spell
	var/disable_wild_magic = FALSE

/datum/action/cooldown/spell/after_cast(atom/cast_on)
	. = ..()

	if(disable_wild_magic)
		return
	handle_wild_magic(cast_on)

/datum/action/cooldown/spell/proc/restore_frog_form(mob/living/frog)
	if(!frog || QDELETED(frog))
		return

	var/datum/status_effect/shapechange_mob/from_spell/shape = frog.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)

	if(!shape)
		return

	frog.visible_message(
		span_notice("[frog] shimmers and reforms into their original shape!"))
	shape.restore_caster()


/datum/action/cooldown/spell/proc/restore_mist_form(mob/living/mist)
	if(!mist || QDELETED(mist))
		return

	var/datum/status_effect/shapechange_mob/from_spell/shape = mist.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)

	if(!shape)
		return

	mist.visible_message(
		span_notice("The mist condenses, reforming into a solid body!"))
	shape.restore_caster()

/datum/action/cooldown/spell/proc/restore_cat_form(mob/living/cat)
    if(!cat || QDELETED(cat))
        return
    var/datum/status_effect/shapechange_mob/from_spell/shape = cat.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)
    if(!shape)
        return
    cat.visible_message(span_notice("[cat] shimmers and reforms into their original shape!"))
    shape.restore_caster()

/datum/action/cooldown/spell/proc/restore_crow_form(mob/living/crow)
    if(!crow || QDELETED(crow))
        return
    var/datum/status_effect/shapechange_mob/from_spell/shape = crow.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)
    if(!shape)
        return
    crow.visible_message(span_notice("The crow reforms into [owner]'s original body!"))
    shape.restore_caster()
/datum/action/cooldown/spell/proc/restore_mute(mob/living/owner)
	if(!owner || QDELETED(owner))
		return
	if(!HAS_TRAIT(owner, TRAIT_MUTE))
		return
	REMOVE_TRAIT(owner, TRAIT_MUTE, "wild_magic")
	owner.visible_message(span_danger("Pink bubbles stop coming out of [owner]'s mouth."))
/datum/action/cooldown/spell/proc/handle_wild_magic(atom/cast_on)
	if(!owner)
		return
	if(!HAS_TRAIT(owner, TRAIT_WILDMAGIC))
		return
	if(prob(30))
		return
	var/list/targets = list()
	var/mob/living/wild_target = null

	for(var/mob/living/L in view(7, owner))
		if(L.stat != DEAD && L != owner)
			targets += L
	if(length(targets))
		wild_target = pick(targets)
	var/wild_magic_switch = rand(1,50)
	owner.visible_message(span_notice("[owner] causes unpredictable magical effects."))
	switch(wild_magic_switch)
		if(1)
			/*var/datum/action/cooldown/spell/enchantment/green_flame/G = new
			G.owner = owner
			G.cast(owner)
			owner.visible_message(span_danger("[owner] infuses their weapon!"))*/
			ADD_TRAIT(owner, TRAIT_MUTE, "wild_magic")
			owner.visible_message(span_danger("Pink bubbles start flying out of [owner]'s mouth when he tries to speak."))
			addtimer(CALLBACK(src, PROC_REF(restore_mute), owner), 60 SECONDS)
		if(2)
			var/obj/projectile/magic/flashpowder/P = new
			P.fire(owner, wild_target ? wild_target : target)
			owner.visible_message(span_danger("[owner] casts flashpowder!"))
		if(3)
			var/datum/action/cooldown/spell/undirected/teleport/radius_turf/T = new
			T.owner = owner
			T.inner_tele_radius = 1
			T.outer_tele_radius = 5
			T.cast(owner)
			owner.visible_message(span_danger("[owner] vanishes in a violent magical distortion!"))
		if(4)
			var/datum/action/cooldown/spell/projectile/fireball/F = new
			F.owner = owner
			owner.visible_message(span_danger("[owner]'s unstable magic erupts into a FIREBALL!"))
			F.cast(wild_target ? wild_target : cast_on)
		if(5)
			var/datum/action/cooldown/spell/aoe/on_turf/ensnare/E = new
			E.owner = owner
			var/turf/center
			if(isturf(cast_on))
				center = cast_on
			else
				center = get_turf(cast_on)
			if(center)
				owner.visible_message(span_danger("Arcane tendrils erupt from the ground around [owner]!"))
				E.cast(center)
		if(6)
			var/datum/action/cooldown/spell/undirected/touch/entangler/H = new
			H.owner = owner
			owner.visible_message(span_nicegreen("Living vines spiral around [owner]'s hand as Silvanus answers the chaos!"))
			H.cast(owner)
		if(7)
			/*var/datum/action/cooldown/spell/undirected/shapeshift/frog/F = new
			F.owner = owner
			owner.visible_message(span_danger("[owner]'s body twists and collapses into a small, croaking shape!"))
			var/mob/living/frog = F.do_shapeshift(owner)
			if(!frog)
				return
			addtimer(
				CALLBACK(src, PROC_REF(restore_frog_form), frog), 10 SECONDS)*/
			var/datum/action/cooldown/spell/healing/greater/Hm= new
			Hm.owner = owner
			owner.visible_message(span_nicegreen("The [wild_target ? wild_target : owner]`s wounds instantly begin to heal."))
			Hm.cast(wild_target ? wild_target : owner)
		if(8)
			var/datum/action/cooldown/spell/undirected/shapeshift/mist/M = new
			M.owner = owner
			owner.visible_message(span_danger("[owner]'s body dissolves into drifting mist!"))
			var/mob/living/mist = M.do_shapeshift(owner)
			if(!mist)
				return
			addtimer(CALLBACK(src, PROC_REF(restore_mist_form), mist), 10 SECONDS)
			/*wild_magic_proc = TRUE
			owner.visible_message(span_danger("Unstable energy pulses rhythmically from [owner], each heartbeat threatening another chaotic eruption."))
			for(var/count = 0, count <= 10, count++)
				addtimer(CALLBACK(src, PROC_REF(wild_magic_cast), cast_on), 6 SECONDS)		Я не ебу как это доделать, так что делать это не буду, но код оставлю
			wild_magic_proc = FALSE*/
		if(9)
			var/datum/action/cooldown/spell/undirected/jaunt/ethereal_jaunt/J = new
			J.owner = owner
			owner.visible_message(span_danger("[owner] flickers and slips partially out of reality!"))
			J.cast(owner)
		if(10)
			var/datum/action/cooldown/spell/undirected/conjure_item/smoke_bomb/S = new
			S.owner = owner
			owner.visible_message(span_notice("[owner] coughs as a cloud of smoke erupts from thin air!"))
			S.cast(owner)
		if(11)
			var/datum/action/cooldown/spell/undirected/conjure_item/poison_bomb/P = new
			P.owner = owner
			owner.visible_message(span_danger("[owner]'s magic curdles into a sickly green vapor!"))
			P.cast(owner)
		if(12)
			var/datum/action/cooldown/spell/undirected/conjure_item/light/L = new
			L.owner = owner
			owner.visible_message(span_notice("A brilliant orb of condensed light bursts into existence near [owner]!"))
			L.cast(owner)
		if(13)
			var/datum/action/cooldown/spell/undirected/conjure_item/brick/B = new
			B.owner = owner
			owner.visible_message(span_warning("Reality hardens in [owner]'s hand with a dull, ominous *thunk*!"))
			B.cast(owner)
		if(14)
			var/datum/action/cooldown/spell/status/guidance/G = new
			G.owner = owner
			owner.visible_message(span_notice("[owner] mutters a small incantation; a faint orange glow surrounds them briefly!"))
			G.cast(owner)
		if(15)
			var/datum/action/cooldown/spell/status/haste/H = new
			H.owner = owner
			owner.visible_message(span_notice("[owner] whispers a quick spell; their movements shimmer and quicken!"))
			H.cast(owner)
		if(16)
			var/datum/action/cooldown/spell/undirected/giant_shape/G = new
			G.owner = owner
			owner.visible_message(span_notice("[owner] channels the power of a giant; their body begins to grow and tremble!"))
			G.cast(owner)
		if(17)
			var/datum/action/cooldown/spell/undirected/shadow_step/Ss = new
			Ss.owner = owner
			owner.visible_message(span_warning("[owner] melts into the shadows!"))
			Ss.cast(owner)
		if(18)
			var/datum/action/cooldown/spell/undirected/secondsight/SSs = new
			SSs.owner = owner
			owner.visible_message(span_notice("[owner]'s vision sharpens, revealing hidden truths!"))
			SSs.cast(owner)
		if(19)
			var/datum/action/cooldown/spell/undirected/blade_ward/Bw = new
			Bw.owner = owner
			owner.visible_message(span_notice("[owner] traces a warding sigil in the air!"))
			Bw.cast(owner)
		if(20)
			var/datum/action/cooldown/spell/undirected/longstrider/Ls = new
			Ls.owner = owner
			owner.visible_message(span_notice("[owner] mutters an incantation and a dim pulse of light radiates out from them!"))
			Ls.cast(owner)
		if(21)
			var/datum/action/cooldown/spell/undirected/feather_falling/Ff = new
			Ff.owner = owner
			owner.visible_message(span_notice("[owner] whispers the incantation and a soft aura surrounds them!"))
			Ff.cast(owner)
		if(22)
			var/datum/action/cooldown/spell/undirected/forcewall/Fw = new
			Fw.owner = owner
			owner.visible_message(span_notice("[owner] conjures a shimmering wall of force!"))
			Fw.cast(owner)
		if(23)
			var/datum/action/cooldown/spell/projectile/lightning/BOl = new
			BOl.owner = owner
			owner.visible_message(span_warning("[owner] yells 'THUNDER STRIKE!!!' and lightning crackles around them!"))
			BOl.cast(wild_target ? wild_target : cast_on)
		if(24)
			var/datum/action/cooldown/spell/projectile/frost_bolt/Fb = new
			Fb.owner = owner
			owner.visible_message(span_notice("[owner] hurls a beam of frost forward!"))
			Fb.cast(wild_target ? wild_target : cast_on)
		if(25)
			var/datum/action/cooldown/spell/projectile/arcyne_bolt/Ab = new
			Ab.owner = owner
			owner.visible_message(span_notice("[owner] fires rapid bolts of arcyne power!"))
			Ab.cast(wild_target ? wild_target : cast_on)
		if(26)
			var/datum/action/cooldown/spell/projectile/acid_splash/AS = new
			AS.owner = owner
			owner.visible_message(span_warning("[owner] hurls a glob of caustic acid!"))
			AS.cast(wild_target ? wild_target : cast_on)
		if(27)
			var/datum/action/cooldown/spell/conjure/kneestingers/KNi = new
			KNi.owner = owner
			owner.visible_message(span_notice("[owner] whispers 'Treefather light the way.' and kneestingers sprout!"))
			KNi.cast(owner)
		if(28)
			var/datum/action/cooldown/spell/conjure/phantom_ear/Pe = new
			Pe.owner = owner
			owner.visible_message(span_notice("[owner] whispers 'Lend me thine ear.' and a phantom ear appears."))
			Pe.cast(owner)
		if(29)
			var/datum/action/cooldown/spell/conjure/rous/Ro = new
			Ro.owner = owner
			owner.visible_message(span_notice("[owner] calls for their brethren!"))
			Ro.cast(owner)
		if(30)
			var/datum/action/cooldown/spell/conjure/bonfire/Bo = new
			Bo.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'Bonfire!' and a magical flame appears."))
			Bo.cast(owner)
		if(31)
			var/datum/action/cooldown/spell/conjure/raise_lesser_undead/Ul = new
			Ul.owner = owner
			owner.visible_message(span_warning("[owner] shouts 'SERVE ME!' and a skeleton rises."))
			Ul.cast(owner)
		if(32)
			var/datum/action/cooldown/spell/conjure/web/Wb = new
			Wb.owner = owner
			owner.visible_message(span_notice("[owner] whispers 'Strands that bind!' and webs appear around you."))
			Wb.cast(owner)
		if(33)
			var/datum/action/cooldown/spell/conjure/familiar/Fm = new
			Fm.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'B'ST FR'ND!' and a spectral wolf familiar appears."))
			Fm.cast(owner)
		if(34)
			var/datum/action/cooldown/spell/beam/beam_of_frost/BOf = new
			BOf.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'Chill!' and a frost beam emerges."))
			BOf.cast(wild_target ? wild_target : cast_on)
		if(35)
			var/datum/action/cooldown/spell/aoe/on_turf/snap_freeze/Sf = new
			Sf.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'Air be still!' and frost envelops the area."))
			Sf.cast(wild_target ? wild_target : cast_on)
		if(36)
			var/datum/action/cooldown/spell/aoe/on_turf/meteor_storm/Ms = new
			Ms.owner = owner
			owner.visible_message(span_boldwarning("[owner] shouts 'METEOR STORM!!!' and meteors rain from the sky!"))
			Ms.cast(owner)
		if(37)
			var/datum/action/cooldown/spell/aoe/on_turf/arcyne_storm/As = new
			As.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'BE TORN APART!!!' and arcyne energy swirls."))
			As.cast(wild_target ? wild_target : cast_on)
		if(38)
			var/datum/action/cooldown/spell/aoe/repulse/Rp = new
			Rp.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'GITTAH WEIGH' and throws everything around away!"))
			Rp.cast(owner)
		if(39)
			var/datum/action/cooldown/spell/aoe/repulse/dragon/Ts = new
			Ts.owner = owner
			owner.visible_message(span_notice("[owner] sweeps their tail with force!"))
			Ts.cast(owner)
		if(40)
			var/datum/action/cooldown/spell/aoe/churn_undead/Cu = new
			Cu.owner = owner
			owner.visible_message(span_notice("[owner] shouts 'The Undermaiden rebukes!' and churns the undead."))
			Cu.cast(owner)
		if(41)
			var/datum/action/cooldown/spell/undirected/shapeshift/cat/C = new
			C.owner = owner
			owner.visible_message(span_danger("[owner]'s body shifts and shrinks into a nimble cat!"))
			var/mob/living/cat = C.do_shapeshift(owner)
			if(!cat)
				return
			addtimer(CALLBACK(src, PROC_REF(restore_cat_form), cat), 10 SECONDS)
		if(42)
			var/datum/action/cooldown/spell/undirected/shapeshift/crow/C = new
			C.owner = owner
			owner.visible_message(span_danger("[owner]'s body twists and feathers sprout as they become a crow!"))
			var/mob/living/crow = C.do_shapeshift(owner)
			if(!crow)
				return
			addtimer(CALLBACK(src, PROC_REF(restore_crow_form), crow), 10 SECONDS)
		if(43)
			var/datum/action/cooldown/spell/gravity/G = new
			G.owner = owner
			owner.visible_message(span_danger("[owner] crushes the space around [wild_target ? wild_target : cast_on]!"))
			G.cast(wild_target ? wild_target : cast_on)
		if(44)
			var/datum/action/cooldown/spell/find_flaw/Ff = new
			Ff.owner = owner
			owner.visible_message(span_notice("[owner] peers into [wild_target ? wild_target : cast_on] and detects hidden flaws!"))
			Ff.cast(cast_on)
		if(45)
			var/datum/action/cooldown/spell/chill_touch/Ct = new
			Ct.owner = owner
			owner.visible_message(span_danger("[owner] reaches out with a skeletal hand!"))
			Ct.cast(wild_target ? wild_target : cast_on)
		if(46)
			var/datum/action/cooldown/spell/blade_burst/Bb = new
			Bb.owner = owner
			owner.visible_message(span_danger("[owner] summons a storm of blades!"))
			Bb.cast(wild_target ? wild_target : cast_on)
		if(47)
			var/datum/action/cooldown/spell/beast_tame/Bt = new
			Bt.owner = owner
			owner.visible_message(span_notice("[owner] whispers to tame the wild beast!"))
			Bt.cast(cast_on)
		if(48)
			var/datum/action/cooldown/spell/blindness/Bl = new
			Bl.owner = owner
			owner.visible_message(span_danger("[owner] shrouds [wild_target ? wild_target : cast_on]'s eyes in darkness!"))
			Bl.cast(wild_target ? wild_target : cast_on)
		if(49)
			var/datum/action/cooldown/spell/essence/silence/SIl = new
			SIl.owner = owner
			owner.visible_message(span_notice("[owner] creates a zone of absolute silence!"))
			SIl.cast(wild_target ? wild_target : cast_on)
		if(50)
			var/datum/action/cooldown/spell/essence/toxic_cleanse/Tc = new
			Tc.owner = owner
			owner.visible_message(span_notice("[owner] cleanses all toxins from the area!"))
			Tc.cast(wild_target)
