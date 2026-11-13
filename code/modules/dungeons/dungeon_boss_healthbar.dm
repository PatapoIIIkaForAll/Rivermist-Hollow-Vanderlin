/// A floating boss healthbar everyone in the room sees. Adds a maptext overlay
/// above the parent mob, refreshed on health change, removed on death/qdel.
/datum/component/dungeon_boss_healthbar
	var/image/bar
	var/boss_title = "Boss"

/datum/component/dungeon_boss_healthbar/Initialize(boss_title = "Boss")
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.boss_title = boss_title

/datum/component/dungeon_boss_healthbar/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(refresh))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	// A slow refresh also catches changes that arrive without a health update signal.
	START_PROCESSING(SSprocessing, src)
	build_bar()

/datum/component/dungeon_boss_healthbar/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_HEALTH_UPDATE, COMSIG_LIVING_DEATH))
	STOP_PROCESSING(SSprocessing, src)
	clear_bar()

/datum/component/dungeon_boss_healthbar/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	clear_bar()
	return ..()

/datum/component/dungeon_boss_healthbar/process(seconds_per_tick)
	refresh()

/datum/component/dungeon_boss_healthbar/proc/build_bar()
	var/atom/movable/owner = parent
	bar = image(null, owner)
	// In-world overlay: keep it on the game plane at a high layer. HUD planes
	// are for screen objects and misrender when inherited by world overlays.
	bar.layer = ABOVE_ALL_MOB_LAYER
	bar.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	bar.pixel_y = ICON_SIZE_Y
	bar.maptext_width = 96
	bar.maptext_x = -32
	owner.add_overlay(bar)
	refresh()

/datum/component/dungeon_boss_healthbar/proc/refresh()
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	if(QDELETED(owner) || !bar)
		return
	owner.cut_overlay(bar)
	var/ratio = owner.maxHealth > 0 ? clamp(owner.health / owner.maxHealth, 0, 1) : 0
	// Humanoid bosses fall when their defeat pool fills, and stand back up from knockouts.
	var/beaten_stat = UNCONSCIOUS
	if(iscarbon(owner))
		ratio = 1 - clamp(owner.get_defeat_damage_pool() / owner.get_effective_defeat_threshold(), 0, 1)
		beaten_stat = HARD_CRIT
	if(owner.stat >= beaten_stat)
		ratio = 0
	var/filled = round(ratio * 10)
	var/bar_str = ""
	for(var/i in 1 to 10)
		bar_str += (i <= filled) ? "█" : "░"
	var/color = ratio > 0.5 ? "#5fbf5f" : (ratio > 0.25 ? "#d8b84a" : "#c0392b")
	bar.maptext = "<span style='font-size:6pt;color:#e7d8be'>[boss_title]<br><span style='color:[color]'>[bar_str]</span></span>"
	owner.add_overlay(bar)

/datum/component/dungeon_boss_healthbar/proc/on_death()
	SIGNAL_HANDLER
	clear_bar()

/datum/component/dungeon_boss_healthbar/proc/clear_bar()
	var/atom/movable/owner = parent
	if(owner && bar)
		owner.cut_overlay(bar)
	bar = null
