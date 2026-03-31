GLOBAL_LIST_EMPTY(preferences_datums)

GLOBAL_LIST_EMPTY(chosen_names)

GLOBAL_LIST_INIT(name_adjustments, list())

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 20

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	/// color of the players text in OOC messages
	var/ooccolor = null
	/// color of admin's asay messages
	var/asaycolor = "#ff4500"			//This won't change the color for current admins, only incoming ones.
	/// pronouns that will be shown when hovering over the users name in OOC messages
	var/oocpronouns = ""
	/// the ghost icon this admin ghost will get when becoming an aghost.
	var/admin_ghost_icon = null
	var/ui_theme = UI_PREFERENCE_LIGHT_MODE
	var/triumphs = 0
	var/enable_tips = TRUE
	var/tip_delay = 500 //tip delay in milliseconds

	//Antag preferences
	var/list/be_special = list()		//Special role selection
	var/tmp/old_be_special = 0			//Bitflag version of be_special, used to update old savefiles and nothing more
										//If it's 0, that's good, if it's anything but 0, the owner of this prefs file's antag choices were,
										//autocorrected this round, not that you'd need to check that.

	var/UI_style = null
	var/buttons_locked = TRUE
	var/hotkeys = TRUE

	var/showrolls = TRUE
	var/max_chat_length = CHAT_MESSAGE_MAX_LENGTH
	var/see_chat_non_mob = TRUE

	// Custom Keybindings
	var/list/key_bindings = list()

	var/tgui_fancy = TRUE
	var/tgui_lock = TRUE
	var/windowflashing = TRUE
	var/db_flags
	var/toggles = TOGGLES_DEFAULT
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/toggles_maptext = NONE
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/ghost_hud = 1
	var/inquisitive_ghost = 1
	var/allow_midround_antag = 1
	var/preferred_map = null

	var/uses_glasses_colour = 0

	//character preferences
	/// Keeps track of round-to-round randomization of the character slot, prevents overwriting.
	var/slot_randomized

	/// The character's real name.
	var/real_name

	/// Gender of character (used for masculine or feminine model selection).
	var/gender = MALE

	/// Character's pronouns.
	var/pronouns = HE_HIM

	/// The type of voice soundpack the mob should use.
	var/voice_type = VOICE_TYPE_MASC

	/// The type of moans the mob should use.
	var/moan_selection = MOANPACK_TYPE_DEF	//RMH EDIT: choose moanpack

	/// Age of character.
	var/age = AGE_ADULT

	/// Character's origin.
	var/origin = "Default"

	/// Underwear type.
	//var/underwear = "Nude"

	/// Underwear color.
	//var/underwear_color = null

	/// Undershirt type.
	//var/undershirt = "Nude"

	/// Accessory type.
	var/accessory = "Nothing"

	/// Detail type.
	var/detail = "Nothing"

	/// Socks type.
	var/socks = "Nude"

	/// Skin color.
	var/skin_tone = "caucasian1"

	/// Eye color.
	var/eye_color = "000"

	/// Voice color.
	var/voice_color = "a0a0a0"

	/// Detail color.
	var/detail_color = "000"

	/// link to a page containing your headshot image
	var/headshot_link
	var/nsfw_headshot_link //Twilight Axis edit далее TA

	/// link to a page containing your ooc extra image
	var/ooc_extra_link
	var/ooc_extra
	var/song_link
	var/song_artist
	var/song_title

	/// text of your flavor
	var/flavortext
	var/flavortext_display

	var/nsfwflavortext

	var/erpprefs_flavor

	var/list/img_gallery = list()

	var/list/nsfw_img_gallery = list()

	var/ooc_notes
	var/ooc_notes_display

	var/rumour

	var/noble_gossip

	/// The species this character is.
	var/datum/species/pref_species = new /datum/species/human/northern() //Mutant race
	/// The patron/god/diety this character worships
	var/datum/patron/selected_patron
	/// The default patron to use if none is selected
	var/static/datum/patron/default_patron = /datum/patron/faerun/good_gods/Selune
	var/list/features = MANDATORY_FEATURE_LIST
	var/list/randomise = list(
		(RANDOM_BODY) = FALSE,
		(RANDOM_BODY_ANTAG) = FALSE,
		//(RANDOM_UNDERWEAR) = FALSE,
		//(RANDOM_UNDERWEAR_COLOR) = FALSE,
		//(RANDOM_UNDERSHIRT) = FALSE,
		(RANDOM_SKIN_TONE) = FALSE,
		(RANDOM_EYE_COLOR) = FALSE
	)

	var/phobia = "spiders"

	var/list/custom_names = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

		// Want randomjob if preferences already filled - Donkie
	var/joblessrole = RETURNTOLOBBY  //defaults to 1 for fewer assistants

	/// 0 = character settings, 1 = game preferences
	var/current_tab = 0

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = 100//0 is sync

	var/parallax

	var/ambientocclusion = TRUE
	///Should we automatically fit the viewport?
	var/auto_fit_viewport = FALSE
	///Should we be in the widescreen mode set by the config?
	var/widescreenpref = TRUE
	///What size should pixels be displayed as? 0 is strech to fit
	var/pixel_size = 0
	///What scaling method should we use?
	var/scaling_method = "normal"

	var/musicvol = 50
	var/mastervol = 50

	var/static/default_cmusic_type = /datum/combat_music/default
	var/datum/combat_music/combat_music
	var/combat_music_helptext_shown = FALSE

	var/anonymize = TRUE

	var/lastclass

	var/list/exp = list()
	var/list/menuoptions

	var/datum/migrant_pref/migrant
	var/next_special_trait = null

	var/action_buttons_screen_locs = list()

	var/domhand = 2
	var/alignment = ALIGNMENT_TN
	var/list/quirks = list()
	var/list/quirk_customizations = list() // Maps quirk_type -> customization_value

	/// Family system
	var/family = FAMILY_NONE
	var/setspouse = ""
	var/gender_choice = ANY_GENDER

	var/crt = FALSE

	var/list/customizer_entries = list()
	var/list/list/body_markings = list()
	var/update_mutant_colors = TRUE

	var/list/descriptor_entries = list()
	var/list/custom_descriptors = list()

	var/datum/loadout_menu/loadout_menu


	var/datum/loadout_item/loadout1
	var/datum/loadout_item/loadout2
	var/datum/loadout_item/loadout3
	var/datum/loadout_item/loadout4
	var/datum/loadout_item/loadout5
	var/datum/loadout_item/loadout6
	var/datum/loadout_item/loadout7
	var/datum/loadout_item/loadout8
	var/datum/loadout_item/loadout9
	var/datum/loadout_item/loadout10

	var/loadout_1_hex
	var/loadout_2_hex
	var/loadout_3_hex
	var/loadout_4_hex
	var/loadout_5_hex
	var/loadout_6_hex
	var/loadout_7_hex
	var/loadout_8_hex
	var/loadout_9_hex
	var/loadout_10_hex

	// Custom names for loadout items
	var/loadout_1_name
	var/loadout_2_name
	var/loadout_3_name
	var/loadout_4_name
	var/loadout_5_name
	var/loadout_6_name
	var/loadout_7_name
	var/loadout_8_name
	var/loadout_9_name
	var/loadout_10_name

	// Custom descriptions for loadout items
	var/loadout_1_desc
	var/loadout_2_desc
	var/loadout_3_desc
	var/loadout_4_desc
	var/loadout_5_desc
	var/loadout_6_desc
	var/loadout_7_desc
	var/loadout_8_desc
	var/loadout_9_desc
	var/loadout_10_desc

	// Loadout preset storage - 3 slots for saving/loading character customization
	var/list/loadout_preset_1
	var/list/loadout_preset_2
	var/list/loadout_preset_3
	// Temporary storage for loadout item selection (per-user to prevent race conditions)
	var/list/temp_loadout_selection

	// History tracking for character customization undo
	var/list/customization_history = list()
	var/current_loadout_slot = 1

	var/taur_type = null
	var/taur_color = "F2F2F2"
	var/taur_markings = "F2F2F2"
	var/taur_tertiary = "F2F2F2"
	var/selected_title = "None"

	var/list/preference_message_list = list()

	/// Tracker to whether the person has ever spawned into the round, for purposes of applying the respawn ban
	var/has_spawned = FALSE
	///our selected accent
	var/selected_accent = ACCENT_DEFAULT
	/// If our owner has patreon access
	var/patreon = TRUE
	/// If our owner is from a race that has more than one accent
	var/change_accent = FALSE

	var/datum/job/advclass/preview_subclass
	var/tmp/preview_image_revision = 0
	var/tmp/preview_update_generation = 0
	var/tmp/preview_resource_token
	/// Custom UI scale
	var/ui_scale
	///this is our character slot
	var/tmp/current_slot = 1
	/// List storing ERP preference values
	var/list/erp_preferences
	/// List storing undie preference values
	var/list/smallclothes_preferences = list()
	/// Assoc list of culinary preferences, where the key is the type of the culinary preference, and value is food/drink typepath
	var/list/culinary_preferences = list()

	/// Whether multi-character readying is enabled
	var/multi_char_ready = FALSE
	/// List of character slot indices selected for multi-ready (in priority order)
	var/list/multi_ready_slots = list()

	var/datum/multi_ready_ui/multi_ready_panel

	var/char_theme = "grimshart"
	var/static/list/char_themes = list(
		"dusty",
		"grimshart",
		"paper",
		"parchment",
	)

	// I beg for datumised prefs
	/// culture datum type
	var/datum/culture/culture = /datum/culture/universal/ambiguous

/datum/preferences/New(client/C)
	parent = C

	migrant  = new /datum/migrant_pref(src)

	flavortext = null
	headshot_link = null

	// C/parent can be a client_interface
	//if(isclient(parent))
	//	patreon = parent?.patreon?.has_access(ACCESS_ASSISTANT_RANK)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

	UI_style = GLOB.available_ui_styles[1]

	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots += 5
		max_save_slots += 30
		//if(patreon)
		//	max_save_slots += 30
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			if(check_nameban(C.ckey))
				real_name = pref_species.random_name(gender,1)
			return
	//we couldn't load character data so just randomize the character appearance + name
	randomise_appearance_prefs()
	customizer_entries = list()
	validate_customizer_entries()
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()
	genderize_customizer_entries()		//let's create a random character then - rather than a fat, bald and naked man.
	if(!selected_patron)
		selected_patron = GLOB.patron_list[default_patron]
	if(!combat_music)
		combat_music = GLOB.cmode_tracks_by_type[default_cmusic_type]
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds and update their movement keys
	if(isclient(C))
		C.update_movement_keys()
	real_name = pref_species.random_name(gender,1)
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()

/datum/preferences/Destroy()
	parent = null
	selected_patron = null
	combat_music = null
	preview_subclass = null

	QDEL_NULL(migrant)
	QDEL_NULL(pref_species)
	QDEL_NULL(multi_ready_panel)
	QDEL_LIST(customizer_entries)
	QDEL_LIST(descriptor_entries)
	QDEL_LIST(custom_descriptors)

	for(var/i in 1 to 10)
		QDEL_NULL(vars["loadout[i]"])

	if(customization_history)
		for(var/list/snapshot as anything in customization_history)
			for(var/i in 1 to 10)
				var/datum/loadout_item/loadout_item = snapshot["loadout[i]"]
				if(loadout_item)
					qdel(loadout_item)
		customization_history.Cut()

	return ..()

/datum/preferences/Topic(href, href_list, hsrc)			//yeah, gotta do this I guess..
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='14%'>"
#define MAX_MUTANT_ROWS 4

/datum/preferences/proc/show_choices(mob/user, tabchoice)
	if(!user || !user.client)
		return
	if(slot_randomized)
		load_character(default_slot)
		slot_randomized = FALSE

	send_character_ui_resources(user)
	build_and_show_menu(user)

/datum/preferences/proc/build_and_show_menu(mob/user)
	var/list/dat = list()
	var/datum/faith/selected_faith = GLOB.faith_list[selected_patron.associated_faith]
	var/datum/job/high_job
	for(var/job_type in job_preferences)
		if(job_preferences[job_type] != JP_HIGH)
			continue
		high_job = job_type
		break

	user?.client.acquire_dpi()
	var/list/preview_data = get_character_preview_data(user)

	dat += {"
<html lang="en">
<head>
	<style>
		html {
			height: 100%;
			width: 100%;
			overflow: hidden;
		}
		body {
			background-color: #1a1a1a;
			height: 100%;
			width: 100%;
			margin: 0;
			overflow: hidden;
			image-rendering: pixelated;
			position: relative;
		}
		.ui-container {
			position: absolute;
			width: 272px;
			height: 315px;
			background-image: url('Charsheet_BG.1.png');
			background-size: cover;
			transform-origin: top left;
		}
		.sprite { position: absolute; background-repeat: no-repeat; cursor: pointer; }

		.header-bg   { top: 5px;   left: 6px;   width: 260px; height: 52px; background-image: url('0_header_bg.png'); }
		.preview-bg  { top: 50px;  left: 8px;   width: 99px;  height: 83px; background-image: url('charpreview_bg.png'); }
		.body-bg     { top: 58px;  left: 110px; width: 118px; height: 75px; background-image: url('0_body_bg.png'); }
		.voice-bg    { top: 137px; left: 2px;   width: 107px; height: 41px; background-image: url('0_voice_bg.png'); }
		.family-bg   { top: 137px; left: 114px; width: 86px;  height: 74px; background-image: url('0_family_bg.png'); }
		.flavour-bg  { top: 137px; left: 201px; width: 65px;  height: 95px; background-image: url('0_flavour_bg.png'); }
		.loadout-bg  { top: 181px; left: 3px;   width: 64px;  height: 74px; background-image: url('0_loadout_bg.png'); }
		.triumphs-bg { top: 182px; left: 74px;  width: 37px;  height: 34px; background-image: url('0_triumphs_bg.png'); }
		.headshot-bg { top: 213px; left: 119px; width: 76px;  height: 76px; background-image: url('headshot_bg.png'); }
		.ooc-bg      { top: 236px; left: 201px; width: 54px;  height: 48px; background-image: url('0_ooc_bg.png'); }

		.features-bg { top: 60px; left: 231px; width: 36px; height: 48px; background-image: url('0_features_bg.png'); }
		#silhouette  { top: 3px;  left: 10px;  width: 15px; height: 28px; background-image: url('features_bodytype_f.png'); }
		.f-btn       { top: 95px; left: 232px; width: 34px; height: 10px; background-image: url('features_button.png'); z-index: 3; }
		.f-btn:hover { background-image: url('features_button_hover.png'); }
		.f-random    { top: 110px; left: 232px; width: 34px; height: 25px; background-image: url('features_random.png'); }
		.f-random:hover { background-image: url('features_random_hover.png'); }

		.flav-desc { top: 174px; left: 207px; width: 49px; height: 10px; background-image: url('flavour_descriptors.png'); }
		.flav-desc:hover { background-image: url('flavour_descriptors_hover.png'); }
		.flav-text { top: 192px; left: 207px; width: 53px; height: 10px; background-image: url('flavour_text.png'); }
		.flav-text:hover { background-image: url('flavour_text_hover.png'); }
		.flav-misc { top: 210px; left: 207px; width: 50px; height: 10px; background-image: url('flavour_misc.png'); }
		.flav-misc:hover { background-image: url('flavour_misc_hover.png'); }
		.flav-prev { top: 226px; left: 215px; width: 34px; height: 10px; background-image: url('flavour_preview.png'); }
		.flav-prev:hover { background-image: url('flavour_preview_hover.png'); }

		.ooc-notes { top: 252px; left: 207px; width: 41px; height: 10px; background-image: url('ooc_notes.png'); }
		.ooc-notes:hover { background-image: url('ooc_notes_hover.png'); }
		.ooc-extra { top: 270px; left: 207px; width: 40px; height: 10px; background-image: url('ooc_extra.png'); }
		.ooc-extra:hover { background-image: url('ooc_extra_hover.png'); }
		.btn-roles { top: 284px; left: 200px; width: 55px; height: 30px; background-image: url('ooc_specialroles.png'); }
		.btn-roles:hover { background-image: url('ooc_specialroles_hover.png'); }

		.tri-shop { top: 202px; left: 75px; width: 34px; height: 26px; background-image: url('triumphs_shop.png'); }
		.tri-shop:hover { background-image: url('triumphs_shop_hover.png'); }

		.clickable-text {
			font-weight: bold;
			position: absolute;
			background: transparent;
			border: none;
			outline: none;
			font-size: 8px;
			color: #161418;
			text-align: left;
			cursor: pointer;
			display: flex;
			align-items: center;
			justify-content: flex-start;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
			padding: 0 2px;
		}

		.clickable-text:hover {
			text-decoration: underline;
		}

		.auto-shrink {
			font-size: 8px;
		}

		@media (max-width: 100px) {
			.auto-shrink { font-size: 7px; }
		}

		#bespecial   { top: 230px; left: 76px; width: 34px; height: 23px; background-image: url('bespecial_no.png'); }
		#bespecial:hover {background-image: url('bespecial_no_hover.png');}
		#bespecial.yes:hover {background-image: url('bespecial_yes_hover.png');}
		#bespecial.yes { background-image: url('bespecial_yes.png'); }

		.menu-ready  { top: 258px; left: 4px;   width: 88px; height: 10px; background-image: url('ready_order.png'); }
		.menu-ready:hover { background-image: url('ready_order_hover.png'); }
		.menu-change { top: 269px; left: 4px;   width: 69px; height: 10px; background-image: url('change_character.png'); }
		.menu-change:hover { background-image: url('change_character_hover.png'); }
		.menu-save   { top: 280px; left: 4px;   width: 21px; height: 10px; background-image: url('save.png'); }
		.menu-save:hover { background-image: url('save_hover.png'); }
		.menu-undo   { top: 280px; left: 26px;  width: 21px; height: 10px; background-image: url('undo.png'); }
		.menu-undo:hover { background-image: url('undo_hover.png'); }
		.menu-done   { top: 280px; left: 48px;  width: 20px; height: 10px; background-image: url('done.png'); }
		.menu-done:hover { background-image: url('done_hover.png'); }

		.v-color-box { top: 136px; left: 34px; width: 48px; height: 15px; background-image: url('voice_colour.png'); }
		.v-blob      { top: 4px;   left: 35px; width: 8px;  height: 7px;
					   background-image: url('voice_colour_blob.png');
					   background-blend-mode: multiply; }

		.menu-keybinds {
			top: 280px;
			left: 78px;
			width: 39px;
			height: 10px;
			background-image: url('keybinds.png');
		}
		.menu-keybinds:hover {
			background-image: url('keybinds_hover.png');
		}

		.menu-toggles {
			top: 269px;
			left: 83px;
			width: 34px;
			height: 10px;
			background-image: url('toggles.png');
		}
		.menu-toggles:hover {
			background-image: url('toggles_hover.png');
		}

		.preview-grid {
			position: absolute;
			top: 52px;
			left: 10px;
			width: 94px;
			height: 79px;
			background-color: #000;
			display: flex;
			flex-wrap: wrap;
			overflow: hidden;
		}

		.preview-slot {
			display: flex;
			align-items: center;
			justify-content: center;
			width: 47px;
			height: 39px;
			overflow: visible;
		}

		.preview-slot img {
			width: 32px;
			height: 32px;
			transform-origin: center center;
			image-rendering: pixelated;
			pointer-events: none;
		}
	</style>
	<script>
		function getViewportWidth() {
			return window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth || 816;
		}

		function getViewportHeight() {
			return window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 950;
		}

		function decodeOutputValue(value) {
			try {
				return decodeURIComponent(value);
			} catch (error) {
				return value;
			}
		}

		function applyLayoutScale() {
			var container = document.getElementById('ui-container');
			if(!container) {
				return;
			}

			var viewportWidth = getViewportWidth();
			var viewportHeight = getViewportHeight();
			var scale = Math.min(3, (viewportWidth - 8) / 272, (viewportHeight - 8) / 315);

			if(!isFinite(scale) || scale <= 0) {
				scale = 1;
			}

			container.style.transform = 'scale(' + scale + ')';
			container.style.left = Math.max(0, Math.floor((viewportWidth - (272 * scale)) / 2)) + 'px';
			container.style.top = Math.max(0, Math.floor((viewportHeight - (315 * scale)) / 2)) + 'px';
		}

		function shrinkText(element) {
			// Reset to default size first
			element.style.fontSize = '8px';

			// Force a reflow to ensure scrollWidth is accurate
			element.offsetHeight;

			const maxWidth = element.offsetWidth - 4;
			let fontSize = 8;

			// Only shrink if text is actually overflowing
			while (element.scrollWidth > maxWidth && fontSize > 5) {
				fontSize -= 0.5;
				element.style.fontSize = fontSize + 'px';
				// Force reflow after each change
				element.offsetHeight;
			}
		}

		function updateField(fieldId, value) {
			var elem = document.getElementById(fieldId);
			if(elem) {
				elem.textContent = value;
				if(elem.classList.contains('auto-shrink')) {
					shrinkText(elem);
				}
			}
		}

		function updateHeadshot(url) {
			var img = document.getElementById('headshot-img');
			if(img) {
				img.src = url || '';
				img.style.display = url ? 'block' : 'none';
			}
		}

		function updateBeSpecial(isActive) {
			var elem = document.getElementById('bespecial');
			if(elem) {
				if(isActive) {
					elem.classList.add('yes');
				} else {
					elem.classList.remove('yes');
				}
			}
		}

		function tryApplyPreviewImage(elem, value, loadToken, attempt) {
			if(!elem || elem.previewLoadToken !== loadToken) {
				return;
			}

			var preloader = new Image();
			preloader.onload = function() {
				if(!elem || elem.previewLoadToken !== loadToken) {
					return;
				}
				elem.src = value;
			};
			preloader.onerror = function() {
				if(!elem || elem.previewLoadToken !== loadToken) {
					return;
				}
				if(attempt >= 5) {
					return;
				}
				setTimeout(function() {
					tryApplyPreviewImage(elem, value, loadToken, attempt + 1);
				}, 50 * (attempt + 1));
			};
			preloader.src = value;
		}

		function updatePreviewImage(fieldId, value) {
			var elem = document.getElementById(fieldId);
			if(elem && value) {
				var loadToken = String(Date.now()) + Math.random();
				elem.previewLoadToken = loadToken;
				tryApplyPreviewImage(elem, value, loadToken, 0);
			}
		}

		function updateCharacterData() {
			// BYOND's list2params() with output() sends arguments in pairs
			// Arguments come as: arg0, arg1, arg2, arg3... where each pair is key=value so we can't just do update(data)
			var data = {};

			// Process all arguments - they come as strings like "key=value"
			for(var i = 0; i < arguments.length; i++) {
				var arg = arguments\[i\];
				if(typeof arg === 'string' && arg.indexOf('=') !== -1) {
					var parts = arg.split('=');
					var key = parts\[0\];
					var value = decodeOutputValue(parts.slice(1).join('=')); // In case value contains '='
					data\[key\] = value;
				}
			}

			// Update fields only if they exist in data
			if('name' in data) updateField('char-name', data.name || '');
			if('job' in data) updateField('char-job', data.job || 'None');
			if('faith' in data) updateField('char-faith', data.faith || '');
			if('species' in data) updateField('char-species', data.species || '');
			if('patron' in data) updateField('char-patron', data.patron || '');
			if('pq' in data) updateField('char-pq', data.pq || '');
			if('age' in data) updateField('char-age', data.age || '');
			if('domhand' in data) updateField('char-domhand', data.domhand || '');
			if('pronouns' in data) updateField('char-pronouns', data.pronouns || '');
			if('family' in data) updateField('char-family', data.family || 'None');
			if('genderpref' in data) updateField('char-genderpref', data.genderpref || 'Any');
			if('spouse' in data) updateField('char-spouse', data.spouse || 'None');
			if('voicetype' in data) updateField('char-voicetype', data.voicetype || '');
			if('accent' in data) updateField('char-accent', data.accent || '');
			if('moan' in data) updateField('char-moan', data.moan || '');
			if('triumphs' in data) updateField('char-triumphs', data.triumphs || '0');
			if('culture' in data) updateField('char-culture', data.culture || 'None');

			if('headshot' in data) updateHeadshot(data.headshot);
			if('bespecial' in data) updateBeSpecial(data.bespecial === '1');
			if('preview_north' in data) updatePreviewImage('preview-north', data.preview_north);
			if('preview_south' in data) updatePreviewImage('preview-south', data.preview_south);
			if('preview_east' in data) updatePreviewImage('preview-east', data.preview_east);
			if('preview_west' in data) updatePreviewImage('preview-west', data.preview_west);


			if('gender' in data) {
				updateField('char-gender', data.gender || '');
				var silhouette = document.getElementById('silhouette');
				silhouette.style.backgroundImage = "url('features_bodytype_" + data.gender + ".png')";
				if (data.gender === "F") silhouette.style.width = "15px";
				if (data.gender === "M") silhouette.style.width = "18px";
			}

			// Update voice color blob
			if('voice_color' in data) {
				var blob = document.getElementById('voice-blob');
				if(blob && data.voice_color) {
					blob.style.backgroundColor = data.voice_color;
				}
			}
		}

		window.addEventListener('load', function() {
			applyLayoutScale();
			document.querySelectorAll('.auto-shrink').forEach(shrinkText);
		});
		window.addEventListener('resize', applyLayoutScale);
	</script>
</head>
<body>
<div id="ui-container" class="ui-container">
	<div class="sprite header-bg"></div>
	<div class="sprite preview-bg"></div>
	<div class="preview-grid">
		<div class="preview-slot"><img id="preview-north" src="[preview_data["preview_north"] || ""]"></div>
		<div class="preview-slot"><img id="preview-south" src="[preview_data["preview_south"] || ""]"></div>
		<div class="preview-slot"><img id="preview-east" src="[preview_data["preview_east"] || ""]"></div>
		<div class="preview-slot"><img id="preview-west" src="[preview_data["preview_west"] || ""]"></div>
	</div>
	<div class="sprite body-bg"></div>
	<div class="sprite voice-bg"></div>
	<div class="sprite family-bg"></div>
	<div class="sprite flavour-bg"></div>
	<div class="sprite loadout-bg"></div>
	<div class="sprite triumphs-bg"></div>
	<div class="sprite headshot-bg" style="padding: 3px; box-sizing: border-box;">
		<a href='?_src_=prefs;preference=headshot;task=input' style="display: block; width: 100%; height: 100%;">
			<img id="headshot-img" src="[headshot_link || ""]"
				 style="width: 100%; height: 100%; object-fit: cover; cursor: pointer; image-rendering: auto;"
				 onerror="this.style.display='none';">
		</a>
	</div>
	<div class="sprite ooc-bg"></div>

	<div class="sprite" style="top:26px; left:23px; width:92px; height:9px; background-image: url('header_charname.png');">
		<a href='?_src_=prefs;preference=name;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-name" class="clickable-text auto-shrink" style="width:92px; height:9px;">[real_name]</div>
		</a>
	</div>
	<div class="sprite" style="top:11px; left:122px; width:46px; height:9px; background-image: url('header_class.png');">
		<a href='?_src_=prefs;preference=job;task=menu' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-job" class="clickable-text auto-shrink" style="width:46px; height:9px;">[high_job || "None"]</div>
		</a>
	</div>
	<div class="sprite" style="top:11px; left:172px; width:42px; height:9px; background-image: url('header_faith.png');">
		<a href='?_src_=prefs;preference=faith;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-faith" class="clickable-text auto-shrink" style="width:42px; height:9px;">[selected_faith?.name || ""]</div>
		</a>
	</div>
	<div class="sprite" style="top:11px; left:220px; width:31px; height:9px; background-image: url('header_playerckey.png');">
		<div id="char-ckey" class="clickable-text" style="width:31px; height:9px; cursor: default;">[user.ckey]</div>
	</div>
	<div class="sprite" style="top:30px; left:122px; width:46px; height:9px; background-image: url('header_species.png');">
		<a href='?_src_=prefs;preference=species;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-species" class="clickable-text auto-shrink" style="width:46px; height:9px;">[pref_species.name]</div>
		</a>
	</div>
	<div class="sprite" style="top:30px; left:172px; width:42px; height:9px; background-image: url('header_patron.png');">
		<a href='?_src_=prefs;preference=patron;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-patron" class="clickable-text auto-shrink" style="width:42px; height:9px;">[selected_patron.name]</div>
		</a>
	</div>
	<div class="sprite" style="top:30px; left:220px; width:31px; height:9px; background-image: url('header_pq.png');">
		<a href='?_src_=prefs;preference=playerquality;task=menu' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-pq" class="clickable-text auto-shrink" style="width:31px; height:9px;">[get_playerquality(user.ckey, text = TRUE)]</div>
		</a>
	</div>

	<div class="sprite" style="top:70px; left:118px; width:46px; height:9px; background-image: url('body_age.png');">
		<a href='?_src_=prefs;preference=age;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-age" class="clickable-text auto-shrink" style="width:46px; height:9px;">[age]</div>
		</a>
	</div>
	<div class="sprite" style="top:70px; left:168px; width:53px; height:9px; background-image: url('body_flaw.png');">
		<a href='?_src_=prefs;preference=select_quirks' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div class="clickable-text auto-shrink" style="width:53px; height:9px;">Select Quirks</div>
		</a>
	</div>
	<div class="sprite" style="top:89px; left:119px; width:46px; height:9px; background-image: url('body_dominanthand.png');">
		<a href='?_src_=prefs;preference=domhand' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-domhand" class="clickable-text auto-shrink" style="width:46px; height:9px;">[domhand == 1 ? "Left" : "Right"]</div>
		</a>
	</div>
	<div class="sprite" style="top:89px; left:168px; width:53px; height:9px; background-image: url('body_ancestry.png');">
		<a href='?_src_=prefs;preference=s_tone;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div class="clickable-text auto-shrink" style="width:53px; height:9px;">Change</div>
		</a>
	</div>
	<div class="sprite" style="top:108px; left:119px; width:46px; height:9px; background-image: url('body_pronouns.png');">
		<a href='?_src_=prefs;preference=pronouns;task=input' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-pronouns" class="clickable-text auto-shrink" style="width:46px; height:9px;">[pronouns]</div>
		</a>
	</div>
	<a href='?_src_=prefs;preference=gender'><div class="sprite" style="top:108px; left:169px; width:53px; height:9px; background-image: url('body_bodytype.png');">
		<div id="char-gender" class="clickable-text auto-shrink" style="width:53px; height:9px;">[gender == MALE ? "M" : "F"]</div>
	</div></a>

	<a href='?_src_=prefs;preference=family'><div class="sprite" style="top:150px; left:120px; width:73px; height:9px; background-image: url('family_type.png');">
		<div id="char-family" class="clickable-text auto-shrink" style="width:73px; height:9px;">[family ? family : "None"]</div>
	</div></a>
	<a href='?_src_=prefs;preference=gender_choice'><div class="sprite" style="top:169px; left:120px; width:73px; height:9px; background-image: url('gender_pref.png');">
		<div id="char-genderpref" class="clickable-text auto-shrink" style="width:73px; height:9px;">[gender_choice ? gender_choice : "Any"]</div>
	</div></a>
	<a href='?_src_=prefs;preference=setspouse'><div class="sprite" style="top:188px; left:120px; width:73px; height:9px; background-image: url('spouse_pref.png');">
		<div id="char-spouse" class="clickable-text auto-shrink" style="width:73px; height:9px;">[setspouse ? setspouse : "None"]</div>
	</div></a>

	<a href='?_src_=prefs;preference=culture;task=input'><div class="sprite" style="top:150px; left:207px; width:51px; height:9px; background-image: url('flavour_culture.png');">
		<div id="char-culture" class="clickable-text auto-shrink" style="width:51px; height:9px;">[culture ? culture::name : "None"]</div>
	</div></a>

	<a href='?_src_=prefs;preference=voicetype;task=input'><div class="sprite" style="top:154px; left:10px; width:46px; height:9px; background-image: url('voice_type.png');">
		<div id="char-voicetype" class="clickable-text auto-shrink" style="width:46px; height:9px;">[voice_type]</div>
	</div></a>
	<a href='?_src_=prefs;preference=moanselection;task=input'><div class="sprite" style="top:154px; left:60px; width:42px; height:9px; background-image: url('voice_accent.png');">
		<div id="char-moan" class="clickable-text auto-shrink" style="width:42px; height:9px;">[moan_selection]</div>
	</div></a>

	<a href='?_src_=prefs;preference=loadout_item;task=input'><div class="sprite" style="top:194px; left:10px; width:51px; height:9px; background-image: url('loadout_item1.png');">
		<div id="char-loadout1" class="clickable-text auto-shrink" style="width:51px; height:9px;">Open Loadout Menu</div>
	</div></a>

	<div class="sprite" style="top:195px; left:82px; width:22px; height:7px; background-image: url('triumphs_display.png');">
		<a href='?_src_=prefs;preference=triumphs;task=menu' style="text-decoration: none; display: block; width: 100%; height: 100%;">
			<div id="char-triumphs" class="clickable-text" style="width:22px; height:7px; font-size: 5px;">[user.get_triumphs() ? "\Roman [user.get_triumphs()]" : "0"]</div>
		</a>
	</div>

	<a href='?_src_=prefs;preference=triumph_buy_menu'><div class="sprite tri-shop"></div></a>
	<a href='?_src_=prefs;preference=descriptors;task=menu'><div class="sprite flav-desc"></div></a>
	<a href='?_src_=prefs;preference=flavortext;task=input'><div class="sprite flav-text"></div></a>
	<a href='?_src_=prefs;preference=misc;task=menu'><div class="sprite flav-misc"></div></a>
	<a href='?_src_=prefs;preference=ooc_preview;task=input'><div class="sprite flav-prev"></div></a>
	<a href='?_src_=prefs;preference=ooc_notes;task=input'><div class="sprite ooc-notes"></div></a>
	<a href='?_src_=prefs;preference=ooc_extra;task=input'><div class="sprite ooc-extra"></div></a>
	<a href='?_src_=prefs;preference=antag;task=menu'><div class="sprite btn-roles"></div></a>
	<a href='?_src_=prefs;preference=customizers;task=menu'><div class="sprite f-btn"></div></a>
	<a href='?_src_=prefs;preference=randomiseappearanceprefs;'><div class="sprite f-random"></div></a>

	<div class="sprite features-bg"><div id="silhouette" class="sprite" style="background-image: url('features_bodytype_[gender == MALE ? "m" : "f"].png');"></div></div>

	<div class="sprite v-color-box">
		<a href='?_src_=prefs;preference=voice;task=input' style="display: block; width: 100%; height: 100%;">
			<div id="voice-blob" class="sprite v-blob" style="background-color: [voice_color];"></div>
		</a>
	</div>
	<a href='?_src_=prefs;preference=bespecial'><div id="bespecial" class="sprite [next_special_trait ? "yes" : ""]"></div></a>
	<a href='?_src_=prefs;preference=multi;task=menu'><div class="sprite menu-ready"></div></a>
	<a href='?_src_=prefs;preference=changeslot;'><div class="sprite menu-change"></div></a>
	<a href='?_src_=prefs;preference=keybinds;task=menu'><div class="sprite menu-keybinds"></div></a>
	<a href='?_src_=prefs;preference=toggles'><div class="sprite menu-toggles"></div></a>
	<a href='?_src_=prefs;preference=save'><div class="sprite menu-save"></div></a>
	<a href='?_src_=prefs;preference=load'><div class="sprite menu-undo"></div></a>
	<a href='?_src_=prefs;preference=finished'><div class="sprite menu-done"></div></a>
</div>
</body>
</html>
"}

	winshow(user, "stonekeep_prefwin", TRUE)
	user.client?.clear_character_previews()
	winshow(user, "stonekeep_prefwin.character_preview_map", FALSE)
	// This should really be a browser datum
	user << browse(dat.Join(), "window=preferences_browser;size=816x950")
	addtimer(CALLBACK(src, PROC_REF(update_preview_icon)), 1)
	onclose(user, "stonekeep_prefwin", src)

/datum/preferences/proc/update_menu_data(mob/user, list/fields_to_update)
	if(!winexists(user, "preferences_browser"))
		return

	var/datum/faith/selected_faith = GLOB.faith_list[selected_patron.associated_faith]
	var/datum/job/high_job
	for(var/job_type in job_preferences)
		if(job_preferences[job_type] != JP_HIGH)
			continue
		high_job = job_type
		break

	var/list/params = list()

	// If no specific fields specified, update all
	var/update_all = !fields_to_update || !length(fields_to_update)

	if(update_all || ("name" in fields_to_update))
		params["name"] = real_name
	if(update_all || ("job" in fields_to_update))
		params["job"] = high_job || "None"
	if(update_all || ("faith" in fields_to_update))
		params["faith"] = selected_faith?.name || ""
	if(update_all || ("species" in fields_to_update))
		params["species"] = pref_species.name
	if(update_all || ("patron" in fields_to_update))
		params["patron"] = selected_patron.name
	if(update_all || ("pq" in fields_to_update))
		params["pq"] = "[get_playerquality(user.ckey, text = TRUE)]"
	if(update_all || ("age" in fields_to_update))
		params["age"] = age
	if(update_all || ("domhand" in fields_to_update))
		params["domhand"] = domhand == 1 ? "Left" : "Right"
	if(update_all || ("pronouns" in fields_to_update))
		params["pronouns"] = pronouns
	if(update_all || ("gender" in fields_to_update))
		params["gender"] = gender == MALE ? "M" : "F"
	if(update_all || ("family" in fields_to_update))
		params["family"] = family ? family : "None"
	if(update_all || ("genderpref" in fields_to_update))
		params["genderpref"] = gender_choice ? gender_choice : "Any"
	if(update_all || ("spouse" in fields_to_update))
		params["spouse"] = setspouse ? setspouse : "None"
	if(update_all || ("voicetype" in fields_to_update))
		params["voicetype"] = voice_type
	if(update_all || ("accent" in fields_to_update))
		params["accent"] = selected_accent
	if(update_all || ("moan" in fields_to_update))
		params["moan"] = moan_selection
	if(update_all || ("loadout1" in fields_to_update))
		params["loadout1"] = loadout1 ? loadout1.name : "None"
	if(update_all || ("loadout2" in fields_to_update))
		params["loadout2"] = loadout2 ? loadout2.name : "None"
	if(update_all || ("loadout3" in fields_to_update))
		params["loadout3"] = loadout3 ? loadout3.name : "None"
	if(update_all || ("triumphs" in fields_to_update))
		params["triumphs"] = user.get_triumphs() ? "\Roman [user.get_triumphs()]" : "0"
	if(update_all || ("headshot" in fields_to_update))
		params["headshot"] = headshot_link || ""
	if(update_all || ("voice_color" in fields_to_update))
		params["voice_color"] = voice_color
	if(update_all || ("bespecial" in fields_to_update))
		params["bespecial"] = next_special_trait ? "1" : "0"
	if(update_all || ("culture" in fields_to_update))
		params["culture"] = culture::name

	// Use list2params as BYOND expects for browser output
	user << output(list2params(params), "preferences_browser:updateCharacterData")
	update_preview_icon()


/datum/preferences/proc/set_ui_theme(new_theme)
	if(new_theme in list("dusty", "grimshart", "paper", "parchment"))
		char_theme = new_theme
		return TRUE
	return FALSE

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/set_choices(mob/user, limit = 15, list/splitJobs = list("Captain", "Priest", "Merchant", "Butler", "Village Elder"), widthPerColumn = 400, height = 620)
	if(!SSjob)
		return

	var/HTML = "<center>"
	if(!length(SSjob.joinable_occupations))
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>"
	else
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>"
		if(joblessrole != RETURNTOLOBBY && joblessrole != BERANDOMJOB)
			joblessrole = RETURNTOLOBBY

		HTML += "<b>If Role Unavailable:</b><font color='purple'><a href='?_src_=prefs;preference=job;task=nojob'>[joblessrole]</a></font><BR>"

		var/datum/job/highest_pref
		for(var/job in job_preferences)
			if(job_preferences[job] > highest_pref)
				highest_pref = SSjob.GetJob(job)
		if(isnull(highest_pref))
			preview_subclass = null
		HTML += "<div style='text-align: center'><br><b>Subclass Preview:</b><br> <a href='?_src_=prefs;preference=subclassoutfit;task=input'>[preview_subclass ? "[preview_subclass.title]" : "Change"]</a></div>"

		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += {"
			<script type='text/javascript'>
				function update_job_preference() {
					var data = {};
					for(var i = 0; i < arguments.length; i++) {
						var arg = arguments\[i\];
						if(typeof arg === 'string' && arg.indexOf('=') !== -1) {
							var parts = arg.split('=');
							var key = parts\[0\];
							var value = decodeURIComponent(parts.slice(1).join('='));
							data\[key\] = value;
						}
					}

					if(!data.jobTitle || data.prefLevel === undefined) return;

					var jobId = data.jobTitle.replace(/ /g, '_');
					var prefLink = document.getElementById('job-pref-' + jobId);

					if(prefLink) {
						var level = parseInt(data.prefLevel);
						// level values: 1=High, 2=Medium, 3=Low, 4=NEVER
						var config = {
							1: { label: 'High', color: 'slateblue', upper: 4, lower: 2 },
							2: { label: 'Medium', color: 'green', upper: 1, lower: 3 },
							3: { label: 'Low', color: 'orange', upper: 2, lower: 4 },
							4: { label: 'NEVER', color: 'red', upper: 3, lower: 1 }
						};

						if(config\[level\]) {
							var cfg = config\[level\];
							var jobTitle = data.jobTitle;

							prefLink.innerHTML = '<font color=' + cfg.color + '>' + cfg.label + '</font>';
							prefLink.href = '?_src_=prefs;preference=job;task=setJobLevel;level=' + cfg.upper + ';text=' + jobTitle;
							prefLink.setAttribute('oncontextmenu', 'javascript:return setJobPrefRedirect(' + cfg.lower + ', "' + jobTitle + '");');
						}
					}
				}


				function toggleCategory(categoryName) {
					var fieldset = document.getElementById('fieldset-' + categoryName);
					var content = document.getElementById('content-' + categoryName);
					if(content.style.display === 'none') {
						content.style.display = 'block';
						fieldset.setAttribute('data-collapsed', 'false');
					} else {
						content.style.display = 'none';
						fieldset.setAttribute('data-collapsed', 'true');
					}
				}
			</script>
			<style>
				.two-column-container {
					display: flex;
					justify-content: center;
					gap: 20px;
					max-width: 1000px;
					margin: 0 auto;
				}

				.column {
					display: flex;
					flex-direction: column;
					gap: 10px;
					width: 450px;
				}

				.job-category-box {
					width: 100%;
					border: 2px solid;
					margin: 0;
					box-sizing: border-box;
				}

				.job-category-box table {
					width: 100%;
				}

				fieldset\[data-collapsed="true"\] legend::after {
					content: " (Expand)";
				}
				fieldset\[data-collapsed="false"\] legend::after {
					content: " (Collapse)";
				}

				.tutorialhover {
					position: relative;
					display: inline-block;
				}
				.tutorialhover .tutorial {
					visibility: hidden;
					width: 280px;
					background-color: black;
					color: #e3c06f;
					text-align: center;
					border-radius: 6px;
					padding: 5px;
					position: absolute;
					z-index: 1000;
					left: 50%;
					transform: translateX(-50%);
					bottom: 100%;
					margin-bottom: 5px;
				}
				.tutorialhover:hover .tutorial {
					visibility: visible;
				}
			</style>
		"}

		var/race_ban = FALSE
		if(is_race_banned(user.ckey, user.client.prefs.pref_species.id))
			HTML += "<div style='color: red; text-align: center; padding: 10px;'>YOU ARE BANNED FROM PLAYING THE SPECIES: [user.client.prefs.pref_species.id]</div>"
			race_ban = TRUE

		if(!race_ban)
			var/left_column_html = ""
			var/right_column_html = ""

			var/list/omegalist = list(
				GLOB.lords_positions,
				GLOB.townhall_positions,
				GLOB.townwatch_positions,
				GLOB.chapel_positions,
				GLOB.scholars_positions,
				GLOB.traders_positions,
				GLOB.tavern_positions,
				GLOB.town_positions,
				GLOB.outsiders_positions,
				GLOB.adventurers_positions,
			)
			var/category_index = 0
			for(var/list/category in omegalist)
				if(!SSjob.name_occupations[category[1]])
					continue

				var/list/available_jobs = list()
				for(var/job in category)
					var/datum/job/job_datum = SSjob.name_occupations[job]
					if(!job_datum)
						continue
					if(!job_datum.total_positions && !job_datum.spawn_positions)
						continue
					if(!job_datum.enabled)
						continue
					if(job_datum.spawn_positions <= 0)
						continue
					available_jobs += job_datum

				if(!length(available_jobs))
					continue

				var/datum/job/first_job = SSjob.name_occupations[category[1]]
				var/cat_color = first_job.selection_color
				var/cat_name = ""
				switch(first_job.department_flag)
					if(LORDS)
						cat_name = "Lords"
					if(KEEP)
						cat_name = "The Keep"
					if(TOWNHALL)
						cat_name = "Town Hall"
					if(TOWNWATCH)
						cat_name = "Town Watch"
					if(CHAPEL)
						cat_name = "Chapel"
					if(SCHOLARS)
						cat_name = "Scholars"
					if(TRADERS)
						cat_name = "Traders"
					if(TAVERN)
						cat_name = "Tavern"
					if(TOWN)
						cat_name = "Towners"
					if(ADVENTURERS)
						cat_name = "Adventurers"
					if(VILLAINS)
						cat_name = "Villains"
					if(OUTSIDERS)
						cat_name = "Outsiders"

				var/category_html = ""
				category_html += "<fieldset class='job-category-box' style='border-color: [cat_color];' id='fieldset-[cat_name]' data-collapsed='true'>"
				category_html += "<legend align='center' style='font-weight: bold; color: [cat_color]; cursor: pointer;' onclick='toggleCategory(\"[cat_name]\")'>[cat_name]</legend>"
				category_html += "<div id='content-[cat_name]' style='display: none;'>"
				category_html += "<table cellpadding='1' cellspacing='0'>"

				for(var/datum/job/job in available_jobs)
					var/rank = job.title
					var/used_name = (pronouns == SHE_HER && job.f_title) ? job.f_title : job.title
					var/job_id = replacetext(rank, " ", "_")

					category_html += "<tr bgcolor='#000000'><td width='60%' align='right'>"

					if(is_role_banned(user.ckey, job.title))
						category_html += "[used_name]</td><td><a href='?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
						continue
					if(!job.player_old_enough(user.client))
						var/available_in_days = job.available_in_days(user.client)
						category_html += "[used_name]</td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
						continue
					if(CONFIG_GET(flag/usewhitelist))
						if(job.whitelist_req && (!user.client.whitelisted()))
							category_html += "<font color=#6183a5>[used_name]</font></td><td> </td></tr>"
							continue
					var/lock_html = get_job_lock_html(job, user, used_name)
					if(lock_html)
						category_html += lock_html
						continue
					var/job_display = used_name


					category_html += "<div class='tutorialhover'> [job.class_setup_examine ? "<a href='?src=[REF(job)];explainjob=1'><font>[job_display]</font></a>" : "<font>[job_display]</font>"]</span>\
						<span class='tutorial'>[job.tutorial]<br>\
						Slots: [job.get_total_positions()]</span>\
						</div>"


					category_html += "</td><td width='40%'>"

					var/prefLevelLabel = "ERROR"
					var/prefLevelColor = "pink"
					var/prefUpperLevel = -1 // level to assign on left click
					var/prefLowerLevel = -1 // level to assign on right click

					switch(job_preferences[job.title])
						if(JP_HIGH)
							prefLevelLabel = "High"
							prefLevelColor = "slateblue"
							prefUpperLevel = 4
							prefLowerLevel = 2
						if(JP_MEDIUM)
							prefLevelLabel = "Medium"
							prefLevelColor = "green"
							prefUpperLevel = 1
							prefLowerLevel = 3
						if(JP_LOW)
							prefLevelLabel = "Low"
							prefLevelColor = "orange"
							prefUpperLevel = 2
							prefLowerLevel = 4
						else
							prefLevelLabel = "NEVER"
							prefLevelColor = "red"
							prefUpperLevel = 3
							prefLowerLevel = 1

					category_html += "<a class='white' id='job-pref-[job_id]' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"
					category_html += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
					category_html += "</a></td></tr>"

				category_html += "</table></div></fieldset>"

				if(category_index % 2 == 0)
					left_column_html += category_html
				else
					right_column_html += category_html
				category_index++

			HTML += "<div class='two-column-container'>"
			HTML += "<div class='column'>[left_column_html]</div>"
			HTML += "<div class='column'>[right_column_html]</div>"
			HTML += "</div>"

		if(user.client.prefs.lastclass)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=triumphthing'>PLAY AS [user.client.prefs.lastclass] AGAIN</a></center>"
		else
			HTML += "<br>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset</a></center>"

	HTML += "</center>"

	var/datum/browser/noclose/popup = new(user, "mob_occupation", "<div align='center'>Class Selection</div>", 1000, 700)
	popup.set_window_options(can_close = FALSE)
	popup.set_content(HTML)
	popup.open(FALSE)

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if(!job)
		return FALSE
	if(level == JP_HIGH)
		for(var/j in job_preferences)
			if(job_preferences[j] == JP_HIGH)
				job_preferences[j] = JP_MEDIUM
	job_preferences[job.title] = level
	return TRUE


/datum/preferences/proc/update_job_preference(mob/user, role, desiredLvl)
	if(!SSjob || !length(SSjob.joinable_occupations))
		return
	var/datum/job/job = SSjob.GetJob(role)
	if(!job || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		user << browse(null, "window=mob_occupation")
		update_menu_data(user, list("job"))
		return
	if(!isnum(desiredLvl))
		to_chat(user, "<span class='danger'>update_job_preference - desired level was not a number. Please notify coders!</span>")
		CRASH("update_job_preference called with desiredLvl value of [isnull(desiredLvl) ? "null" : desiredLvl]")

	var/jpval = null
	// desiredLvl comes from the links: 1=High, 2=Medium, 3=Low, 4=NEVER
	// JP constants: JP_LOW=1, JP_MEDIUM=2, JP_HIGH=3
	switch(desiredLvl)
		if(1)
			jpval = JP_HIGH  // 3
		if(2)
			jpval = JP_MEDIUM  // 2
		if(3)
			jpval = JP_LOW  // 1
		if(4)
			jpval = null  // NEVER

	var/was_high = (jpval == JP_HIGH)
	var/previous_high_job = null

	if(was_high)
		for(var/job_title in job_preferences)
			if(job_preferences[job_title] == JP_HIGH)
				previous_high_job = job_title
				break

	set_job_preference_level(job, jpval)

	// Send back the desiredLvl value directly since that's what JavaScript expects
	update_job_display(user, role, desiredLvl)

	if(was_high && previous_high_job && previous_high_job != role)
		update_job_display(user, previous_high_job, 2)  // Medium

	update_menu_data(user, list("job"))
	return 1

/datum/preferences/proc/reset_jobs(mob/user, silent = FALSE)
	job_preferences = list()
	preview_subclass = null
	if(!silent)
		to_chat(user, "<font color='red'>Classes reset.</font>")
	if(winget(user, "mob_occupation", "is-visible"))
		set_choices(user)


/datum/preferences/proc/update_job_display(mob/user, job_title, pref_level)
	if(!winexists(user, "mob_occupation"))
		return

	var/list/params = list()
	params["jobTitle"] = job_title
	params["prefLevel"] = pref_level

	user << output(list2params(params), "mob_occupation.browser:update_job_preference")

/datum/preferences/proc/capture_keybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybinds;task=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/noclose/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)

/datum/preferences/proc/reset_patron(mob/user, silent = FALSE)
	selected_patron = default_patron
	if(!silent)
		to_chat(user, "<font color='red'>Patron reset.</font>")

/datum/preferences/proc/reset_culture(mob/user, silent = FALSE)
	var/datum/culture/selected = GLOB.culture_singletons[culture]
	if(selected.is_selectable(src))
		return
	culture = src::culture
	if(!silent)
		to_chat(user, "<font color='red'>Culture reset.</font>")

/datum/preferences/proc/reset_last_class(mob/user)
	if(user.client?.prefs)
		if(!user.client.prefs.lastclass)
			return
	if(browser_alert(user, "Use 2 TRIUMPHS to play as this class again?", "OUROBOROS", DEFAULT_INPUT_CONFIRMATIONS) != CHOICE_CONFIRM)
		return
	if(user.client?.prefs)
		if(user.client.prefs.lastclass)
			if(user.get_triumphs() < 2)
				to_chat(user, "<span class='warning'>I haven't TRIUMPHED enough.</span>")
				return
			user.adjust_triumphs(-2)
			user.client.prefs.lastclass = null
			user.client.prefs.save_preferences()

/datum/preferences/proc/set_keybinds(mob/user)
	var/list/dat = list()
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for (var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		kb_categories[kb.category] += list(kb)

	dat += "<style>label { display: inline-block; width: 200px; }</style><body>"

	dat += "<center><a href='?_src_=prefs;preference=keybinds;task=close'>Done</a></center><br>"
	for (var/category in kb_categories)
		for (var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]))
				dat += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name];old_key=["Unbound"]'>Unbound</a>"
			//	var/list/default_keys = hotkeys ? kb.hotkey_keys : kb.classic_keys
			//	if(LAZYLEN(default_keys))
			//		dat += "| Default: [default_keys.Join(", ")]"
				dat += "<br>"
			else
				var/bound_key = user_binds[kb.name][1]
				dat += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					dat += " | <a href ='?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					dat += "| <a href ='?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
				dat += "<br>"

	dat += "<br><br>"
	dat += "<a href ='?_src_=prefs;preference=keybinds;task=keybindings_reset'>\[Reset to default\]</a>"
	dat += "</body>"

	var/datum/browser/noclose/popup = new(user, "keybind_setup", "<div align='center'>Keybinds</div>", 600, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options(can_close = FALSE)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/set_antag(mob/user)
	var/list/dat = list()
	dat += "<style>label { display: inline-block; width: 200px; }</style><body>"
	dat += "<center><a href='?_src_=prefs;preference=antag;task=close' style='display:block;margin-bottom:2px'>Done</a></center>"
	dat += "<h2 style='margin:5;padding:5;line-height:1.2'>Villains</h2>"
	if(is_total_antag_banned(user.ckey))
		dat += "<font color=red><b>I am banned from antagonist roles.</b></font><br>"
		src.be_special = list()
	for (var/i in GLOB.special_roles_rogue)
		if(is_antag_banned(user.ckey, i))
			dat += "<b>[capitalize(i)]:</b> <a href='?_src_=prefs;bancheck=[i]'>BANNED</a><br>"
		else
			var/days_remaining = null
			if(ispath(GLOB.special_roles_rogue[i]) && CONFIG_GET(flag/use_age_restriction_for_jobs))
				days_remaining = get_remaining_days(user.client)
			if(days_remaining)
				dat += "<b>[capitalize(i)]:</b> <font color=red> \[IN [days_remaining] DAYS__~~\]~~__</font><br>"
			else
				dat += "<b>[capitalize(i)]:</b> <a href='?_src_=prefs;preference=antag;task=be_special;be_special_type=[i]'>[(i in be_special) ? "Enabled" : "Disabled"]</a><br>"

	var/list/vessel_ids = GLOB.vessel_ids
	var/list/available_vessel_ids = list()
	for(var/id in vessel_ids)
		if(user.client.is_whitelisted(id))
			available_vessel_ids += id

	if(length(available_vessel_ids))
		dat += "<h2 style='margin:5;padding:5;line-height:1.2'>Vessels</h2>"
		for(var/id in available_vessel_ids)
			var/enabled = (id in be_special)
			dat += "<b>[id]:</b> <a href='?_src_=prefs;preference=antag;task=be_special;be_special_type=[id]'>[enabled ? "Enabled" : "Disabled"]</a><br>"

	dat += "</body>"
	var/datum/browser/noclose/popup = new(user, "antag_setup", "<div align='center'>Special Roles</div>", 265, 340)
	popup.set_window_options(can_close = FALSE)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/lore_popup(mob/user)
	if(!user || !user.client)
		return
	var/list/dat = list()
	var/datum/browser/noclose/popup  = new(user, "lore_primer", "<div align='center'>Lore Primer</div>", 650, 900)
	dat += GLOB.roleplay_readme
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/process_link(mob/user, list/href_list)

	if(href_list["bancheck"])
		var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, href_list["bancheck"])
		var/admin = FALSE
		if(GLOB.admin_datums[user.ckey] || GLOB.deadmins[user.ckey])
			admin = TRUE
		for(var/i in ban_details)
			if(admin && !text2num(i["applies_to_admins"]))
				continue
			ban_details = i
			break //we only want to get the most recent ban's details
		if(ban_details && ban_details.len)
			var/expires = "This is a permanent ban."
			if(ban_details["expiration_time"])
				expires = " The ban is for [DisplayTimeText(text2num(ban_details["duration"]) MINUTES)] and expires on [ban_details["expiration_time"]] (server time)."
			to_chat(user, "<span class='danger'>You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [href_list["bancheck"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]</span>")
			return
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				show_choices(user,4)
			if("reset")
				reset_jobs(user, TRUE)

			if("triumphthing")
				reset_last_class(user)
			if("nojob")
				switch(joblessrole)
					if(RETURNTOLOBBY)
						joblessrole = BERANDOMJOB
					if(BERANDOMJOB)
						joblessrole = RETURNTOLOBBY
				set_choices(user)
			if("tutorial")
				if(href_list["tut"])
					to_chat(user, "<span class='info'>* ----------------------- *</span>")
					to_chat(user, href_list["tut"])
					to_chat(user, "<span class='info'>* ----------------------- *</span>")
			if("random")
				joblessrole = BERANDOMJOB
				set_choices(user)
			if("setJobLevel")
				if(SSticker.job_change_locked)
					return 1
				var/datum/job/highest_pref
				for(var/job in job_preferences)
					if(job_preferences[job] > highest_pref)
						highest_pref = SSjob.GetJob(job)
				if(isnull(highest_pref))
					preview_subclass = null
				update_job_preference(user, href_list["text"], text2num(href_list["level"]))
			else
				set_choices(user)
		return 1
	else if(href_list["preference"] == "multi")
		if(isnewplayer(user))
			var/mob/dead/new_player/player = user
			player.cache_multi_ready_characters()
		open_multi_ready()
		return 1


	else if(href_list["preference"] == "antag")
		to_chat(user, span_info("Antags are disabled for now."))
		return
		/*switch(href_list["task"])
			if("close")
				user << browse(null, "window=antag_setup")
				update_menu_data(user)
			if("be_special")
				var/be_special_type = href_list["be_special_type"]
				if(be_special_type in be_special)
					be_special -= be_special_type
				else
					be_special += be_special_type
				set_antag(user)
			if("update")
				set_antag(user)
			else
				SetAntag(user)*/

	else if(href_list["preference"] == "misc")
		show_misc_pref_ui(user)
		return

	else if(href_list["preference"] == "triumphs")
		user.show_triumphs_list()

	else if(href_list["preference"] == "playerquality")
		check_pq_menu(user.ckey)

	else if(href_list["preference"] == "culinary")
		show_culinary_ui(user)
		return

	else if(href_list["preference"] == "markings")
		ShowMarkings(user)
		return
	else if(href_list["preference"] == "underwear")
		show_smallclothes_ui(user)
		return
	else if(href_list["preference"] == "descriptors")
		show_descriptors_ui(user)
		return

	else if(href_list["preference"] == "customizers")
		ShowCustomizers(user)
		return

	else if(href_list["preference"] == "erp")
		show_erp_preferences(user)
		return

	else if(href_list["preference"] == "triumph_buy_menu")
		SStriumphs.startup_triumphs_menu(user.client)

	else if(href_list["preference"] == "keybinds")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=keybind_setup")
				update_menu_data(user)
			if("update")
				set_keybinds(user)
			if("keybindings_capture")
				var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
				var/old_key = href_list["old_key"]
				capture_keybinding(user, kb, old_key)
				return

			if("keybindings_set")
				var/kb_name = href_list["keybinding"]
				if(!kb_name)
					user << browse(null, "window=capturekeypress")
					set_keybinds(user)
					return

				var/clear_key = text2num(href_list["clear_key"])
				var/old_key = href_list["old_key"]
				if(clear_key)
					if(key_bindings[old_key])
						key_bindings[old_key] -= kb_name
						if(!length(key_bindings[old_key]))
							key_bindings -= old_key
					user << browse(null, "window=capturekeypress")
					save_preferences()
					set_keybinds(user)
					return

				var/new_key = uppertext(href_list["key"])
				var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
				var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
				var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
				var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""
				// var/key_code = text2num(href_list["key_code"])

				if(GLOB._kbMap[new_key])
					new_key = GLOB._kbMap[new_key]

				var/full_key
				switch(new_key)
					if("Alt")
						full_key = "[new_key][CtrlMod][ShiftMod]"
					if("Ctrl")
						full_key = "[AltMod][new_key][ShiftMod]"
					if("Shift")
						full_key = "[AltMod][CtrlMod][new_key]"
					else
						full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
				if(key_bindings[old_key])
					key_bindings[old_key] -= kb_name
					if(!length(key_bindings[old_key]))
						key_bindings -= old_key
				key_bindings[full_key] += list(kb_name)
				key_bindings[full_key] = sortList(key_bindings[full_key])
				var/datum/keybinding/client/say/kb = GLOB.keybindings_by_name[kb_name]
				if(istype(kb))
					user.client.set_macros()
				DIRECT_OUTPUT(user, browse(null, "window=capturekeypress"))
				user.client.update_movement_keys()
				save_preferences()
				set_keybinds(user)

			if("keybindings_reset")
				var/choice = browser_alert(user, "Do you really want to reset your keybindings?", "Setup keybindings", DEFAULT_INPUT_CONFIRMATIONS)
				if(choice != CHOICE_CONFIRM)
					return
				hotkeys = TRUE
				key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
				user.client.update_movement_keys()
				set_keybinds(user)
			else
				set_keybinds(user)
		return TRUE

	else if(href_list["preference"] == "toggles")
		var/list/toggles_list = list(
			"Default Toggles" = list("toggles_default", toggles),
			"Maptext Toggles" = list("toggles_maptext", toggles_maptext)
		)
		var/toggle_type = tgui_input_list(user, message = "", title = "Toggle Select", items = toggles_list)
		if(!toggle_type)
			return
		var/list/toggles_data = toggles_list[toggle_type]
		var/bitfield = toggles_data[1]
		var/prefs_variable = toggles_data[2]
		var/new_toggles = input_bitfield(user, toggle_type, bitfield, prefs_variable, nheight = 500)
		if(!isnull(new_toggles))
			if(toggle_type == "Default Toggles")
				// Reset all fields we touch to 0 first because we don't use a full set to do toggles = X
				// And don't want to override them
				for(var/field in GLOB.bitfields[bitfield])
					toggles &= ~GLOB.bitfields[bitfield][field]
				toggles ^= new_toggles
				if((prefs_variable & SOUND_LOBBY) && user.client && isnewplayer(user))
					user.client.playtitlemusic()
				else
					user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if((prefs_variable & SOUND_SHIP_AMBIENCE) && user.client && !isnewplayer(user))
					user.refresh_looping_ambience()
				else
					user.cancel_looping_ambience()

				if((prefs_variable & AMBIENTOCCLUSION) && user.client)
					ambientocclusion = toggles & AMBIENTOCCLUSION
					update_occlusion(user.client)
				else
					ambientocclusion = toggles & AMBIENTOCCLUSION
					update_occlusion(user.client)

				user.client?.update_ambience_pref()

			else if(toggle_type == "Maptext Toggles")
				toggles_maptext = new_toggles

	switch(href_list["task"])
		if("erp_pref")
			handle_erp_pref_topic(user, href_list)
			show_choices(user)
			show_erp_preferences(user)
			return
		if("change_customizer")
			handle_customizer_topic(user, href_list)
			update_menu_data(user)
			ShowCustomizers(user)
			return
		if("change_marking")
			handle_body_markings_topic(user, href_list)
			update_menu_data(user)
			ShowMarkings(user)
			return
		if("change_smallclothes_preferences")
			handle_undies_topic(user, href_list)
			show_smallclothes_ui(user)
			return
		if("change_loadout_preferences")
			handle_loadout_topic(user, href_list)
			open_loadout_menu_selection(user)
			return
		if("change_descriptor")
			handle_descriptors_topic(user, href_list)
			show_descriptors_ui(user)
			return
		if("change_culinary_preferences")
			handle_culinary_topic(user, href_list)
			show_culinary_ui(user)
			return
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = pref_species.random_name(gender,1)
				if("age")
					age = pick(pref_species.possible_ages)
				if("eyes")
					eye_color = random_eye_color()
				if("s_tone")
					var/list/skins = pref_species.get_skin_list()
					skin_tone = skins[pick(skins)]
				if("species")
					user << browse(null, "window=misc_customization")
					random_species()
				if("all")
					apply_character_randomization_prefs()

		if("input")

			if(href_list["preference"] in GLOB.preferences_custom_names)
				ask_for_custom_name(user,href_list["preference"])

			switch(href_list["preference"])
				if("name")
					var/new_name = tgui_input_text(user, "DECIDE YOUR HERO'S IDENTITY", "THE SELF", real_name, MAX_NAME_LEN, encode = FALSE)
					if(new_name)
						new_name = reject_bad_name(new_name)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
					GLOB.name_adjustments |= "[parent] changed their characters name to [new_name]."
					log_character("[parent] changed their characters name to [new_name].")

				if("subclassoutfit")
					var/list/choices = list("None")
					var/datum/job/highest_pref
					for(var/job in job_preferences)
						if(job_preferences[job] > highest_pref)
							highest_pref = SSjob.GetJob(job)
					if(isnull(highest_pref))
						to_chat(user, "<b>I don't have a Class set to High!</b>")
						return
					if(length(highest_pref.job_subclasses))
						for(var/adv in highest_pref.job_subclasses)
							var/datum/job/advclass/advpath = adv
							var/datum/job/advclass/advref = SSrole_class_handler.get_advclass_by_name(initial(advpath.title))
							choices[advref.title] = advref
					else
						to_chat(user, "<b>This role does not have any subclasses!</b>")
						return
					if(length(choices))
						var/new_choice = tgui_input_list(user, "Choose an outfit preview:", "Outfit Preview", choices)
						if(new_choice && new_choice != "None")
							preview_subclass = choices[new_choice]
							update_preview_icon()
						else
							preview_subclass = null
							update_preview_icon()
						update_menu_data(user, list("job"))
				if("age")
					var/new_age = tgui_input_list(user, "SELECT YOUR HERO'S AGE", "YILS DEAD", pref_species.possible_ages, age)
					if(new_age)
						age = new_age
						reset_jobs(user)
				if ("pronouns")
					var/list/allowed_pronouns = pref_species.allowed_pronouns
					if(!allowed_pronouns || !length(allowed_pronouns))
						// fallback to the default pronouns list
						allowed_pronouns = PRONOUNS_LIST

					if(length(allowed_pronouns) == 1)
						pronouns = allowed_pronouns[1]
						to_chat(user, span_warning("This species can only use [pronouns]."))
						return

					var/pronouns_input = tgui_input_list(user, "CHOOSE HOW MORTALS REFER TO YOUR HERO", "DISOBEY SOCIAL NORMS", allowed_pronouns)
					if(pronouns_input)
						pronouns = pronouns_input
						to_chat(user, span_warning("Your character's pronouns are now [pronouns]."))
				if ("voicetype")
					var/list/allowed_voices
					if(gender == MALE)
						allowed_voices = pref_species.allowed_voicetypes_m
					else if(gender == FEMALE)
						allowed_voices = pref_species.allowed_voicetypes_f
					else
						allowed_voices = VOICE_TYPES_LIST
					if(!allowed_voices || !length(allowed_voices))
						allowed_voices = VOICE_TYPES_LIST
					if(length(allowed_voices) == 1)
						voice_type = allowed_voices[1]
						to_chat(user, span_warning("This species can only use the [voice_type] voice type."))
						return

					var/voicetype_input = tgui_input_list(user, "CHOOSE YOUR HERO'S VOICE TYPE", "DISCARD SOCIETY'S EXPECTATIONS", allowed_voices)
					if(voicetype_input)
						voice_type = voicetype_input
						if(voicetype_input == VOICE_TYPE_ANDRO)
							to_chat(user, span_warning("This will use the feminine voicepack pitched down a bit to achieve a more androgynous sound."))
						to_chat(user, span_warning("Your character will now vocalize with a [lowertext(voice_type)] affect."))
				if ("moanselection")
					to_chat(user, "<font color='yellow'>This option allws you to customize your character's moanpack, dependant on the voice type. Leave it on 'default' or click 'cancel' to automatically use your voice type and species' moanpack.</font>")
					/*var moanpack_type_input = input(user, "Choose your character's moanpack type", "Moanpack Type") as null|anything in list(MOANPACK_TYPE_DEF, "Custom")
					generate_selectable_moanpacks()
					if(moanpack_type_input)
						if(moanpack_type_input == MOANPACK_TYPE_DEF)
							moan_selection = MOANPACK_TYPE_DEF
							to_chat(user, "<font color='red'>You will use your default species' moanpack.</font>")
						else if(moanpack_type_input == "Custom")*/
					if (user.client.prefs.voice_type == VOICE_TYPE_MASC)
						generate_selectable_moanpacks()
						var/moanpack_sel_input = tgui_input_list(user, "Choose your character's moanpack", "Moanpack", GLOB.selectable_moanpacks_male)
						if(moanpack_sel_input)
							moan_selection = moanpack_sel_input
							to_chat(user, "<font color='red'>Your character will now use the '[lowertext(moanpack_sel_input)]' moanpack.</font>")
						else
							moan_selection = MOANPACK_TYPE_DEF
					else
						generate_selectable_moanpacks()
						var/moanpack_sel_input = tgui_input_list(user, "Choose your character's moanpack", "Moanpack", GLOB.selectable_moanpacks_female)
						if(moanpack_sel_input)
							moan_selection = moanpack_sel_input
							to_chat(user, "<font color='red'>Your character will now use the '[lowertext(moanpack_sel_input)]' moanpack.</font>")
						else
							moan_selection = MOANPACK_TYPE_DEF
				if("faith")
					var/list/faiths_named = list()
					for(var/datum/faith/faith as anything in GLOB.faith_list)
						faith = GLOB.faith_list[faith]
						if(!faith.preference_accessible(src))
							continue
						faiths_named["\The [faith.name]"] = faith
					var/faith_input = tgui_input_list(user, "SELECT YOUR HERO'S BELIEF", "PUPPETS ON STRINGS", faiths_named, "\The [selected_patron.associated_faith::name]")
					if(faith_input)
						var/datum/faith/faith = faiths_named[faith_input]
						to_chat(user, "<font color='purple'>Pantheon: [faith.name]</font>")
						to_chat(user, "<font color='purple'>Background: [faith.desc]</font>")
						selected_patron = GLOB.patron_list[faith.godhead] || GLOB.patron_list[pick(GLOB.patrons_by_faith[faith.type])]

				if("patron")
					var/list/patrons_named = list()
					for(var/datum/patron/patron_type as anything in GLOB.patrons_by_faith[selected_patron.associated_faith || initial(default_patron.associated_faith)])
						var/datum/patron/patron = GLOB.patron_list[patron_type.type]
						if(!patron.preference_accessible(src))
							continue
						var/pref_name = patron.display_name ? patron.display_name : patron.name
						patrons_named[pref_name] = patron

					if(length(patrons_named))
						var/datum/faith/current_faith = GLOB.faith_list[selected_patron.associated_faith] || GLOB.faith_list[initial(default_patron.associated_faith)]
						var/patron_default = selected_patron?.display_name ? selected_patron.display_name : selected_patron?.name
						var/god_input = tgui_input_list(user, "SELECT YOUR HERO'S PATRON GOD", uppertext("\The [current_faith.name]"), patrons_named, patron_default)
						if(god_input)
							selected_patron = patrons_named[god_input]

					to_chat(user, "<font color='purple'>Patron: [selected_patron]</font>")
					to_chat(user, "<font color='purple'>Domain: [selected_patron.domain]</font>")
					to_chat(user, "<font color='purple'>Background: [selected_patron.desc]</font>")
					to_chat(user, "<font color='purple'>Flawed aspects: [selected_patron.flaws]</font>")
					to_chat(user, "<font color='purple'>Likely Worshippers: [selected_patron.worshippers]</font>")
					to_chat(user, "<font color='red'>Considers these to be Sins: [selected_patron.sins]</font>")
					to_chat(user, "<font color='white'>Blessed with boon(s): [selected_patron.boons]</font>")

				if("combat_music") // if u change shit here look at /client/verb/combat_music() too
					if(!combat_music_helptext_shown)
						to_chat(user, span_notice("<span class='bold'>Combat Music Override</span>\n") + \
						"Options other than \"Default\" override whatever the game dynamically sets for you, \
						which is influenced by your job class, villain status, or certain events.\n\
						You can change this later through \"Combat Mode Music\" in the Options tab.\"</span>")
						combat_music_helptext_shown = TRUE
					var/track_select = tgui_input_list(user, "Set a track to be your combat music.", "Combat Music", GLOB.cmode_tracks_by_name, combat_music?.name)
					if(track_select)
						combat_music = GLOB.cmode_tracks_by_name[track_select]
						to_chat(user, span_notice("Selected track: <b>[track_select]</b>."))
						if(combat_music.desc)
							to_chat(user, "<i>[combat_music.desc]</i>")
						if(combat_music.credits)
							to_chat(user, span_info("Song name: <b>[combat_music.credits]</b>"))
					show_misc_pref_ui(user)

				if("voice")
					var/new_voice = tgui_color_picker(user, "SELECT YOUR HERO'S VOICE COLOR", "THE THROAT", "#[voice_color]")
					if(new_voice)
						if(color_hex2num(new_voice) < 230)
							to_chat(user, "<font color='red'>This voice color is too dark for mortals.</font>")
							return
						voice_color = sanitize_hexcolor(new_voice)

				if("headshot")
					to_chat(user, "<span class='notice'>Please use an image of the head and shoulder area to maintain immersion level. Lastly, ["<span class='bold'>do not use a real life photo or use any image that is less than serious.</span>"]</span>")
					to_chat(user, "<span class='notice'>If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser.</span>")
					to_chat(user, "<span class='notice'>Keep in mind that the photo will be downsized to 325x325 pixels, so the more square the photo, the better it will look.</span>")
					var/new_headshot_link = tgui_input_text(user, "Input the headshot link (https, hosts: gyazo, lensdump, imgbox, catbox):", "Headshot", headshot_link, encode = FALSE)
					if(new_headshot_link == null)
						return
					if(new_headshot_link == "")
						headshot_link = null
						show_choices(user)
						return
					var/is_valid_link = is_valid_headshot_link(user, new_headshot_link, FALSE)
					if(!is_valid_link)
						to_chat(user, span_notice("Failed to update headshot"))
						return
					headshot_link = new_headshot_link
					to_chat(user, span_notice("Successfully updated headshot picture"))
					log_game("[user] has set their Headshot image to '[headshot_link]'.")
				if("formathelp")
					var/list/dat = list()
					dat +="You can use backslash (\\) to escape special characters.<br>"
					dat += "<br>"
					dat += "# text : Defines a header.<br>"
					dat += "|text| : Centers the text.<br>"
					dat += "**text** : Makes the text <b>bold</b>.<br>"
					dat += "*text* : Makes the text <i>italic</i>.<br>"
					dat += "^text^ : Increases the <font size = \"4\">size</font> of the text.<br>"
					dat += "((text)) : Decreases the <font size = \"1\">size</font> of the text.<br>"
					dat += "* item : An unordered list item.<br>"
					dat += "--- : Adds a horizontal rule.<br>"
					dat += "-=FFFFFFtext=- : Adds a specific <font color = '#FFFFFF'>colour</font> to text.<br><br>"
					dat += "Minimum Flavortext: <b>[MINIMUM_FLAVOR_TEXT]</b> characters.<br>"
					dat += "Minimum OOC Notes: <b>[MINIMUM_OOC_NOTES]</b> characters."
					var/datum/browser/popup = new(user, "Formatting Help", width = 400, height = 350)
					popup.set_content(dat.Join())
					popup.open(FALSE)
				if("skin_color_ref_list")
					var/list/dat = list()
					dat +="<br><center><h2>Skin color codes reference list</h2></center><br>"
					dat += "<br>"
					var/list/s_list = pref_species.get_skin_list()
					for(var/tone in s_list)
						var/hex_color = "#" + s_list[tone]
						dat += "- <b>[tone]</b>  |  <span style='border: 1px solid #161616; background-color: [hex_color ? hex_color : "#000000"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>"
						dat += "<br>"
					var/datum/browser/popup = new(user, "skin_color_ref", "<div align='center'>Skin colors</div>", width = 400, height = 450)
					popup.set_content(dat.Join())
					popup.open(FALSE)
				if("loadout1hex")
					var/choice = tgui_input_list(user, "Choose a color.", "Loadout Item One Colour", colorlist)
					if (choice && colorlist[choice])
						loadout_1_hex = colorlist[choice]
						if (loadout1)
							to_chat(user, "The colour for your [loadout1::name] has been set to <b>[choice]</b>.")
					else
						loadout_1_hex = null
						to_chat(user, "The colour for your <b>first</b> loadout item has been cleared.")
				if("loadout2hex")
					var/choice = tgui_input_list(user, "Choose a color.", "Loadout Item Two Colour", colorlist)
					if (choice && colorlist[choice])
						loadout_2_hex = colorlist[choice]
						if (loadout2)
							to_chat(user, "The colour for your [loadout2::name] has been set to <b>[choice]</b>.")
					else
						loadout_2_hex = null
						to_chat(user, "The colour for your <b>second</b> loadout item has been cleared.")
				if("loadout3hex")
					var/choice = tgui_input_list(user, "Choose a color.", "Loadout Item Three Colour", colorlist)
					if (choice && colorlist[choice])
						loadout_3_hex = colorlist[choice]
						if (loadout3)
							to_chat(user, "The colour for your [loadout3::name] has been set to <b>[choice]</b>.")
					else
						loadout_3_hex = null
						to_chat(user, "The colour for your <b>third</b> loadout item has been cleared.")
				if("loadout_item")
					open_loadout_menu(user)

				if("species")
					selected_accent = ACCENT_DEFAULT

					var/list/selectable = list()
					for(var/species_id in GLOB.roundstart_species)
						var/species_type = GLOB.species_list[species_id]

						var/datum/species/species = new species_type()
						if(!species.preference_accessible(src))
							continue

						selectable[species.name] = species.type

					var/result = tgui_input_list(user, "SELECT YOUR HERO'S PEOPLE:", "PEOPLE OF FAERUN", selectable, pref_species?.name)

					if(result)
						user << browse(null, "window=misc_customization")
						var/species_type = selectable[result]

						pref_species = new species_type()

						to_chat(user, "<em>[pref_species.name]</em>")
						if(pref_species.desc)
							to_chat(user, "[pref_species.desc]")

						if(!length(pref_species.allowed_pronouns))
							to_chat(user, span_warning("This species does not have any allowed pronouns. Please contact a coder to add them."))
						else if (length(pref_species.allowed_pronouns) == 1)
							pronouns = pref_species.allowed_pronouns[1]
						else if(!(pronouns in pref_species.allowed_pronouns))
							pronouns = pref_species.allowed_pronouns[1]

						if(pref_species.forced_taur && pref_species.allowed_taur_types.len)
							taur_type = pick(pref_species.allowed_taur_types)
						else
							taur_type = null


						selected_title = "None"
						//Now that we changed our species, we must verify that the mutant colour is still allowed.
						real_name = pref_species.random_name(gender,1)
						reset_jobs(user)
						reset_patron(user)
						reset_culture(user)
						randomise_appearance_prefs(~(RANDOMIZE_SPECIES))
						features = pref_species.get_random_features()
						sanitize_species_mutant_colors()
						customizer_entries = list()
						validate_customizer_entries()
						reset_all_customizer_accessory_colors()
						randomize_all_customizer_accessories()
						accessory = "Nothing"

				if("taur_type")
					var/list/species_taur_list = pref_species.get_taur_list()
					if(!LAZYLEN(species_taur_list))
						taur_type = null
						to_chat(user, span_bad("There are no available taur bodies for this species."))
						return

					var/list/taur_selection
					if(pref_species.forced_taur)
						taur_selection = list()
					else
						taur_selection = list("None")

					for(var/obj/item/bodypart/taur/tt as anything in pref_species.get_taur_list())
						taur_selection[tt::name] = tt

					var/new_taur_type = tgui_input_list(user, "Choose your character's taur body", "TAUR BODY", taur_selection)
					if(!new_taur_type)
						return

					if(new_taur_type == "None")
						taur_type = null
					else
						taur_type = taur_selection[new_taur_type]

					var/obj/item/bodypart/taur/tt = taur_type
					to_chat(user, span_red("Your character now has [tt ? tt::name : "no taurtype."]."))
					show_misc_pref_ui(user)

				if("taur_color")
					var/new_taur_color = pick_common_color_from_palette(user, "CHOOSE YOUR HERO'S TAUR COLOR", "TAUR COLOR", taur_color)
					if(new_taur_color)
						taur_color = new_taur_color
					show_misc_pref_ui(user)

				if("taur_markings")
					var/new_taur_markings = tgui_color_picker(user, "Choose your character's taur markings color:", "Character Preference", "#[taur_markings]")
					if(new_taur_markings)
						taur_markings = sanitize_hexcolor(new_taur_markings)
					show_misc_pref_ui(user)

				if("taur_tertiary")
					var/new_taur_tertiary = tgui_color_picker(user, "Choose your character's taur tertiary markings color:", "Character Preference", "#[taur_tertiary]")
					if(new_taur_tertiary)
						taur_tertiary = sanitize_hexcolor(new_taur_tertiary)
					show_misc_pref_ui(user)

				if("mutant_color")
					pick_mutant_color_from_palette(user, 1)
					show_misc_pref_ui(user)

				if("mutant_color2")
					pick_mutant_color_from_palette(user, 2)
					show_misc_pref_ui(user)

				if("mutant_color3")
					pick_mutant_color_from_palette(user, 3)
					show_misc_pref_ui(user)

				if("skin_choice_pick")
					pick_mutant_color_from_palette(user, 1)
					show_misc_pref_ui(user)
				if("race_title")
					var/list/titles = pref_species.race_titles
					var/list/choices = list("None", "Custom")
					for(var/A in titles)
						choices += list(A)
					if(user?.client)
						var/result = tgui_input_list(user, "What do they call your kind?", "RACE TITLE", choices)

						if(result == "Custom")
							result = tgui_input_text(user, "Name of your people:", "RACE TITLE", "None",  encode = FALSE)
						if(result)
							if(result == "None")
								selected_title = "None"
							else
								selected_title = result
					show_misc_pref_ui(user)

				if("flavortext")
					to_chat(user, span_notice("["<span class='bold'>Flavortext should not include nonphysical nonsensory attributes such as backstory or the character's internal thoughts. NSFW descriptions are prohibited.</span>"]"))
					// Keep this raw while editing; we encode it later for the rendered preview.
					var/new_flavortext = tgui_input_text(user, "Input your character description", "DESCRIBE YOURSELF", flavortext, multiline = TRUE, encode = FALSE)
					if(new_flavortext == null)
						return
					if(new_flavortext == "")
						flavortext = null
						flavortext_display = null
						update_menu_data(user)
						return
					flavortext = new_flavortext
					var/ft = flavortext
					ft = html_encode(ft)
					ft = replacetext(parsemarkdown_basic(ft), "\n", "<BR>")
					flavortext_display = ft
					to_chat(user, span_notice("Successfully updated flavortext"))
					log_game("[user] has set their flavortext'.")
				if("nsfw_headshot")
					to_chat(user, "<span class='notice'>Finally a place to show it all.</span>")
					var/new_nsfw_headshot_link = tgui_input_text(user, "Input the nsfw headshot link (https, hosts: gyazo, lensdump, imgbox, catbox):", "NSFW Headshot", nsfw_headshot_link, encode = FALSE)
					if(new_nsfw_headshot_link == null)
						return
					if(new_nsfw_headshot_link == "")
						nsfw_headshot_link = null
						update_menu_data(user)
						return
					if(!is_valid_nsfw_headshot_link(user, new_nsfw_headshot_link))
						nsfw_headshot_link = null
						update_menu_data(user)
						return
					nsfw_headshot_link = new_nsfw_headshot_link
					to_chat(user, "<span class='notice'>Successfully updated NSFW Headshot picture</span>")
					log_game("[user] has set their NSFW Headshot image to '[nsfw_headshot_link]'.") //TA edit end

				if("ooc_notes")
					to_chat(user, span_notice("["<span class='bold'>Do not put anything NSFW here. This feature is for stuff that wouldn't fit in the flavortext.</span>"]"))
					var/new_ooc_notes = tgui_input_text(user, "Input your OOC preferences:", "OOC notes", ooc_notes, multiline = TRUE, encode = FALSE)
					if(new_ooc_notes == null)
						return
					if(new_ooc_notes == "")
						ooc_notes = null
						ooc_notes_display = null
						update_menu_data(user)
						return
					ooc_notes = new_ooc_notes

					var/ooc = ooc_notes
					ooc = html_encode(ooc)
					ooc = replacetext(parsemarkdown_basic(ooc), "\n", "<BR>")
					ooc_notes_display = ooc
					to_chat(user, span_notice("Successfully updated OOC notes."))
					log_game("[user] has set their OOC notes'.")

				if("change_artist")
					var/new_artist = tgui_input_text(user, "Input your song's artist:", "Song Artist", song_artist,  encode = FALSE)
					if(new_artist == null)
						return
					if(new_artist == "")
						update_menu_data(user)
						return
					song_artist = new_artist
					to_chat(user, "<span class='notice'>Successfully updated song artist.</span>")
					log_game("[user] has set their song artist.")

				if("change_title")
					var/new_title = tgui_input_text(user, "Input your song's title:", "Song title", song_title,  encode = FALSE)
					if(new_title== null)
						return
					if(new_title == "")
						update_menu_data(user)
						return
					song_title = new_title
					to_chat(user, "<span class='notice'>Successfully updated song title.</span>")
					log_game("[user] has set their song title.")

				if("gossip")
					to_chat(user, span_notice("Gossip is rumours spread around, and known only in Noble circles, only other well-born individuals are aware of it. Gossip, similarly to standard rumours does not need to be precise or true, but remember that it can provide hints and avenues for other Nobles to interact with, and judge your Character.\n<b>Avoid explicit bodily descriptions, though rumors like \"sleeps around a lot\" are fine.</b>"))
					var/new_gossip = tgui_input_text(user, "Input noble gossip about your character:", "Noble Gossip", noble_gossip, multiline = TRUE, encode = FALSE)
					if(new_gossip == null)
						return
					if(new_gossip == "")
						noble_gossip = null
						update_menu_data(user)
						return
					noble_gossip = new_gossip
					to_chat(user, span_notice("Successfully updated Noble Gossip"))
					log_game("[user] has set their noble gossip'.")

				if("rumour")
					to_chat(user, span_notice("Rumours are things others might know, or think they know about you, they don't necessarily have to be precise, or even true. But remember that they can provide a hint to another player on how to interact with, or even think about your character.\n<b>Avoid explicit bodily descriptions, though rumors like \"sleeps around a lot\" are fine.</b>"))
					var/new_rumour = tgui_input_text(user, "Input rumours about your character:", "Rumours", rumour, multiline = TRUE, encode = FALSE)
					if(new_rumour == null)
						return
					if(new_rumour == "")
						rumour = null
						update_menu_data(user)
						return
					rumour = new_rumour
					to_chat(user, span_notice("Successfully updated Rumours"))
					log_game("[user] has set their rumour'.")

				if("rumour_preview")
					var/msg = ""
					if(rumour && length(rumour))
						var/rumour_display = rumour
						rumour_display = html_encode(rumour_display)
						rumour_display = parsemarkdown_basic(rumour_display, hyperlink = TRUE)
						msg += "<b>You recall what you heard around Town about [real_name]...</b><br>[rumour_display]"
					if(length(noble_gossip))
						if(msg)
							msg += "<br><br>"
						var/gossip_display = noble_gossip
						gossip_display = html_encode(gossip_display)
						gossip_display = parsemarkdown_basic(gossip_display, hyperlink = TRUE)
						msg += "<b>You recall what the other Blue-bloods hushed about [real_name]...</b><br>[gossip_display]"
					if(msg)
						to_chat(user, "<span class='info'>[msg]</span>")

				if("nsfwflavortext")
					to_chat(user, "<span class='notice'>["<span class='bold'>NSFW Flavortext can be used for setting things like body descriptions and other physical details that may be conisdered explicit.</span>"]</span>")
					to_chat(user, "<font color = '#d6d6d6'>Leave blank to clear.</font>")
					var/new_nsfwflavortext = tgui_input_text(user, "Input your character description:", "NSFW Flavortext", nsfwflavortext, multiline = TRUE, encode = FALSE)
					if(new_nsfwflavortext == null)
						return
					if(new_nsfwflavortext == "")
						new_nsfwflavortext = null
						nsfwflavortext = null
						to_chat(user, "<span class='notice'>Successfully deleted NSFW Flavor Text.</span>")
						update_menu_data(user)
						return
					nsfwflavortext = new_nsfwflavortext
					to_chat(user, "<span class='notice'>Successfully updated NSFW flavortext</span>")
					log_game("[user] has set their NSFW flavortext'.")
				if("song_link")
					to_chat(user, "<span class='notice'>Add a link from a suitable host (catbox, etc) to an mp3 to embed in your flavor text.</span>")
					to_chat(user, "<span class='notice'>If the song doesn't  play properly, ensure that it's a direct link that opens properly in a browser.</span>")
					to_chat(user, "<font color = '#d6d6d6'>Leave blank to clear your current song.</font>")
					to_chat(user, "<font color ='red'>Abuse of this will get you banned.</font>")
					var/new_song_link = tgui_input_text(user, "Input the accessory link (https, hosts: catbox):", "Song URL", song_link, encode = FALSE)
					if(new_song_link == null)
						return
					if(new_song_link == "")
						new_song_link = null
						song_link = null
						to_chat(user, "<span class='notice'>Successfully deleted OOC Extra.</span>")
						update_menu_data(user)
						return
					var/static/list/valid_extensions = list("mp3")
					if(!is_valid_headshot_link(user, new_song_link, FALSE, valid_extensions))
						new_song_link = null
						update_menu_data(user)
						return

					var/list/value_split = splittext(new_song_link, ".")

					// extension will always be the last entry
					var/extension = value_split[length(value_split)]
					if((extension in valid_extensions))
						song_link = new_song_link
						to_chat(user, "<span class='notice'>Successfully updated Song URL.</span>")
						log_game("[user] has set their Song URL to '[song_link]'.")

				if("img_gallery")

					if(img_gallery.len >= 3)
						to_chat(user, "You already have three images in your gallery!")
						return

					to_chat(user, "<span class='notice'>Please use an image ["<span class='bold'>of your character</span>"] to maintain immersion level. Lastly, ["<span class='bold'>do not use a real life photo or use any image that is less than serious.</span>"]</span>")
					to_chat(user, "<span class='notice'>If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser.</span>")
					to_chat(user, "<span class='notice'>Keep in mind that all three images are displayed next to eachother and justified to fill a horizontal rectangle. As such, vertical images work best.</span>")
					to_chat(user, "<span class='notice'>You can only have a maximum of ["<span class='bold'>THREE IMAGES</span>"] in your gallery at a time.</span>")

					var/new_galleryimg = tgui_input_text(user, "Input the image link (https, hosts: gyazo, lensdump, imgbox, catbox):", "Gallery Image",  encode = FALSE)

					if(new_galleryimg == null)
						return
					if(new_galleryimg == "")
						new_galleryimg = null
						update_menu_data(user)
						return
					if(!is_valid_headshot_link(user, new_galleryimg))
						to_chat(user, "<span class='notice'>Invalid image link. Make sure it's a direct link from a valid host (gyazo, lensdump, imgbox, catbox).</span>")
						new_galleryimg = null
						update_menu_data(user)
						return
					img_gallery += new_galleryimg
					to_chat(user, "<span class='notice'>Successfully added image to gallery.</span>")
					log_game("[user] has added an image to their gallery: '[new_galleryimg]'.")

				if("nsfw_img_gallery")

					if(nsfw_img_gallery.len >= 3)
						to_chat(user, "You already have three images in your gallery!")
						return

					to_chat(user, "<span class='notice'>Please use an image ["<span class='bold'>of your character</span>"] to maintain immersion level. Lastly, ["<span class='bold'>do not use a real life photo or use any image that is less than serious.</span>"]</span>")
					to_chat(user, "<span class='notice'>If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser.</span>")
					to_chat(user, "<span class='notice'>Keep in mind that all three images are displayed next to eachother and justified to fill a horizontal rectangle. As such, vertical images work best.</span>")
					to_chat(user, "<span class='notice'>You can only have a maximum of ["<span class='bold'>THREE IMAGES</span>"] in your gallery at a time.</span>")

					var/new_galleryimg = tgui_input_text(user, "Input the image link (https, hosts: gyazo, lensdump, imgbox, catbox):", "Gallery Image",  encode = FALSE)

					if(new_galleryimg == null)
						return
					if(new_galleryimg == "")
						new_galleryimg = null
						update_menu_data(user)
						return
					if(!is_valid_headshot_link(user, new_galleryimg))
						to_chat(user, "<span class='notice'>Invalid image link. Make sure it's a direct link from a valid host (gyazo, lensdump, imgbox, catbox).</span>")
						new_galleryimg = null
						update_menu_data(user)
						return
					nsfw_img_gallery += new_galleryimg
					to_chat(user, "<span class='notice'>Successfully added image to nsfw gallery.</span>")
					log_game("[user] has added an image to their nsfw gallery: '[new_galleryimg]'.")

				if("clear_gallery")
					if(!img_gallery.len)
						to_chat(user, "You don't have any images in your gallery to clear!")
						return
					var/dachoice = tgui_alert(user, "Do you really want to clear your image gallery?", "Clear Gallery", list("Yae", "Nae"))
					if(dachoice == "Nae")
						update_menu_data(user)
						return
					img_gallery = list()
					to_chat(user, "<span class='notice'>Successfully cleared image gallery.</span>")
					log_game("[user] has cleared their image gallery.")

				if("clear_nsfw_gallery")
					if(!nsfw_img_gallery.len)
						to_chat(user, "You don't have any images in your nsfw gallery to clear!")
						return
					var/dachoice = tgui_alert(user, "Do you really want to clear your nsfw image gallery?", "Clear nsfw Gallery", list("Yae", "Nae"))
					if(dachoice == "Nae")
						update_menu_data(user)
						return
					nsfw_img_gallery = list()
					to_chat(user, "<span class='notice'>Successfully cleared their nsfw image gallery.</span>")
					log_game("[user] has cleared their nsfw image gallery.")

				if("ooc_preview")
					var/datum/examine_panel/preview_examine_panel = new(user)
					preview_examine_panel.pref = src
					preview_examine_panel.holder = user
					preview_examine_panel.viewing = user
					preview_examine_panel.ui_interact(user)
					/*var/list/dat = list()
					if(is_valid_headshot_link(null, headshot_link, TRUE))
						dat += ("<div align='center'><img src='[headshot_link]' width='350px' height='350px'></div>")
					if(flavortext && flavortext_display)
						dat += "<div align='left' style='line-height: 1.2;'>[flavortext_display]</div>"
					if(ooc_notes && ooc_notes_display)
						dat += "<br>"
						dat += "<div align='center'><b>OOC notes</b></div>"
						dat += "<div align='left' style='line-height: 1.2;'>[ooc_notes_display]</div>"
					if(is_valid_nsfw_headshot_link(null, nsfw_headshot_link, TRUE))
						dat += "<br><div align='center'><b>NSFW</b></div>"
						dat += ("<br><div align='center'><img src='[nsfw_headshot_link]' width='350px' height='350px'></div>")
					if(ooc_extra)
						dat += "[ooc_extra]"
					var/datum/browser/popup = new(user, "[real_name]", "<center>[real_name]</center>", width = 480, height = 700)
					popup.set_content(dat.Join())
					popup.open(FALSE)*/
				if("ooc_extra")
					to_chat(user, "<span class='notice'>["<span class='bold'>Erotic Roleplay preferences. If you put 'anything goes' or 'no limits' here, do not be surprised if people take you up on it.</span>"]</span>")
					to_chat(user, "<font color = '#d6d6d6'>Leave blank to clear.</font>")
					var/new_erpprefs = tgui_input_text(user, "Input your preferences:", "ERP Preferences", erpprefs_flavor, multiline = TRUE, encode = FALSE)
					if(new_erpprefs == null)
						return
					if(new_erpprefs == "")
						new_erpprefs = null
						erpprefs_flavor = null
						to_chat(user, "<span class='notice'>Successfully deleted ERP preferences.</span>")
						update_menu_data(user)
						return
					erpprefs_flavor = new_erpprefs
					to_chat(user, "<span class='notice'>Successfully updated ERP Preferences.</span>")
					log_game("[user] has set their ERP preferences'.")
					/*to_chat(user, span_notice("Add a link from a suitable host (catbox, etc) to an mp3, mp4, or jpg / png file to have it embed at the bottom of your OOC notes."))
					to_chat(user, span_notice("If the link doesn't show up properly in-game, ensure that it's a direct link that opens properly in a browser."))
					to_chat(user, span_notice("Videos will be shrunk to a ~300x300 square. Keep this in mind."))
					to_chat(user, "<font color = '#d6d6d6'>Leave a single space to delete it from your OOC notes.</font>")
					to_chat(user, "<font color ='red'>Abuse of this will get you banned.</font>")
					var/new_extra_link = input(user, "Input the accessory link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "OOC Extra", ooc_extra_link) as text|null
					if(new_extra_link == null)
						return
					if(new_extra_link == "")
						new_extra_link = null
						update_menu_data(user)
						return
					if(new_extra_link == " ")	//Single space to delete
						ooc_extra_link = null
						ooc_extra = null
						to_chat(user, span_notice("Successfully deleted OOC Extra."))
					var/static/list/valid_extensions = list("jpg", "png", "jpeg", "gif", "mp4", "mp3")
					if(!is_valid_headshot_link(user, new_extra_link, FALSE, valid_extensions))
						new_extra_link = null
						update_menu_data(user)
						return

					var/list/value_split = splittext(new_extra_link, ".")

					// extension will always be the last entry
					var/extension = value_split[length(value_split)]
					var/info
					if(extension in valid_extensions)
						ooc_extra_link = new_extra_link
						ooc_extra = null
						ooc_extra = "<div align ='center'><center>"
						if(extension == "jpg" || extension == "png" || extension == "jpeg" || extension == "gif")
							ooc_extra += "<br>"
							ooc_extra += "<img src='[ooc_extra_link]'/>"
							info = "an embedded image."
						else
							switch(extension)
								if("mp4")
									ooc_extra = "<br>"
									ooc_extra += "<video width=["288"] height=["288"] controls=["true"]>"
									ooc_extra += "<source src='[ooc_extra_link]' type=["video/mp4"]>"
									ooc_extra += "</video>"
									info = "a video."
								if("mp3")
									ooc_extra = "<br>"
									ooc_extra += "<audio controls>"
									ooc_extra += "<source src='[ooc_extra_link]' type=["audio/mp3"]>"
									ooc_extra += "Your browser does not support the audio element."
									ooc_extra += "</audio>"
									info = "embedded audio."
						ooc_extra += "</center></div>"
						to_chat(user, span_notice("Successfully updated OOC Extra with [info]"))
						log_game("[user] has set their OOC Extra to '[ooc_extra_link]'.")*/
				if("s_tone")
					var/list/listy = pref_species.get_skin_list()
					var/new_s_tone = tgui_input_list(user, "CHOOSE YOUR HERO'S [uppertext(pref_species.skin_tone_wording)]", "THE SUN", listy)
					if(new_s_tone)
						skin_tone = listy[new_s_tone]
						features["mcolor"] = listy[new_s_tone]
						sanitize_species_mutant_colors()

				if("selected_accent")
					if(length(pref_species.multiple_accents))
						change_accent = TRUE
					else
						change_accent = FALSE
					if(!change_accent)
						to_chat(user, "Sorry, this option is unavailable to your race.")
						selected_accent = ACCENT_DEFAULT
						return
					var/accent
					accent = tgui_input_list(user, "CHOOSE YOUR HERO'S ACCENT", "VOICE OF THE WORLD", GLOB.accent_list, selected_accent)
					if(accent)
						selected_accent = accent
					else if(change_accent)
						var/accent_default
						for(var/accent_name in pref_species.multiple_accents)
							if(pref_species.multiple_accents[accent_name] == selected_accent)
								accent_default = accent_name
								break
						accent = tgui_input_list(user, "CHOOSE YOUR HERO'S ACCENT", "VOICE OF THE WORLD", pref_species.multiple_accents, accent_default)
						if(accent)
							selected_accent = pref_species.multiple_accents[accent]
				if("ooccolor")
					var/new_ooccolor = tgui_color_picker(user, "Choose your OOC colour:", "Game Preference", ooccolor)
					if(new_ooccolor)
						ooccolor = sanitize_ooccolor(new_ooccolor)

				if("asaycolor")
					var/new_asaycolor = tgui_color_picker(user, "Choose your ASAY color:", "Game Preference", asaycolor)
					if(new_asaycolor)
						asaycolor = sanitize_ooccolor(new_asaycolor)
				if ("clientfps")
					var/desiredfps = tgui_input_number(user, "Choose your desired fps. (0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps, 500, 0)
					if (!isnull(desiredfps))
						clientfps = desiredfps
						parent.fps = desiredfps

				if("ui")
					var/pickedui = tgui_input_list(user, "Choose your UI style.", "Character Preference", sortList(GLOB.available_ui_styles), UI_style)
					if(pickedui)
						UI_style = "Rogue"
						if (parent && parent.mob && parent.mob.hud_used)
							parent.mob.hud_used.update_ui_style(ui_style2icon(UI_style))

				if("culture")
					var/list/cultures = list()
					for(var/culture_type in GLOB.culture_singletons)
						var/datum/culture/culture = GLOB.culture_singletons[culture_type]
						if(!culture.is_selectable(src))
							continue
						cultures[culture.name] += culture.type
					var/choice = browser_input_list(user, "CHOOSE YOUR HERO'S CULTURE", "CULTURE", cultures)
					if(!choice)
						return
					culture = cultures[choice]
					to_chat(user, span_notice("[culture::name]"))
					to_chat(user, span_notice("[culture::description]"))
		else
			switch(href_list["preference"])
				if ("max_chat_length")
					var/desiredlength = tgui_input_number(user, "Choose the max character length of shown Runechat messages. Valid range is 1 to [CHAT_MESSAGE_MAX_LENGTH] (default: [initial(max_chat_length)]))", "Character Preference", max_chat_length, CHAT_MESSAGE_MAX_LENGTH, 1)
					if (!isnull(desiredlength))
						max_chat_length = clamp(desiredlength, 1, CHAT_MESSAGE_MAX_LENGTH)
				if("gender")
					var/pickedGender = MALE
					if(gender == MALE)
						pickedGender = FEMALE
					if(pickedGender && pickedGender != gender)
						gender = pickedGender
						real_name = real_name = pref_species.random_name(gender,1)
						reset_jobs(user)
						randomise_appearance_prefs(RANDOMIZE_UNDERWEAR | RANDOMIZE_HAIRSTYLE)
						accessory = "Nothing"
						detail = "Nothing"
						genderize_customizer_entries()
				if("domhand")
					if(domhand == 1)
						domhand = 2
					else
						domhand = 1
				if("bespecial")
					if(next_special_trait)
						print_special_text(user, next_special_trait)
						return
					to_chat(user, span_boldwarning("You will become special for one round, this could be something negative, positive or neutral and could have a high impact on your character and your experience. You cannot back out from or reroll this, and it will not carry over to other rounds."))
					to_chat(user, span_boldwarning("THIS COSTS 1 TRIUMPH"))
					if(user.get_triumphs() < 1)
						to_chat(user, span_bignotice("YOU DON'T HAVE ENOUGH TRIUMPHS."))
						return
					var/result = alert(user, "You'll receive a unique trait for one round\n You cannot back out from or reroll this\nDo you really want to spend 1 triumph for it?", "Be Special", "Yes", "No")
					if(result != "Yes")
						return
					user.adjust_triumphs(-1)
					if(next_special_trait)
						return
					next_special_trait = roll_random_special(user.client)
					if(next_special_trait)
						log_game("SPECIALS: Rolled [next_special_trait] for ckey: [user.ckey]")
						print_special_text(user, next_special_trait)
						user.playsound_local(user, 'sound/misc/alert.ogg', 100)
						to_chat(user, span_warning("This will be applied on your next game join."))
						to_chat(user, span_warning("You may switch your character and choose any role, if you don't meet the requirements (if any are specified) it won't be applied"))

				if("family")
					var/list/famtree_options_list = list(FAMILY_NONE, FAMILY_PARTIAL, FAMILY_NEWLYWED, FAMILY_FULL, "EXPLAIN THIS TO ME")
					var/new_family = tgui_input_list(user, "SELECT YOUR HERO'S BOND", "BLOOD IS THICKER THAN WATER", famtree_options_list, family)
					if(new_family == "EXPLAIN THIS TO ME")
						to_chat(user, span_purple("\
						--[FAMILY_NONE] will disable this feature.<br>\
						--[FAMILY_PARTIAL] will assign you as a progeny of a local house based on your species. This feature will instead assign you as a aunt or uncle to a local family if your older than ADULT.<br>\
						--[FAMILY_NEWLYWED] assigns you a spouse without adding you to a family. Setspouse will prioritize pairing you with another newlywed with the same name as your setspouse.<br>\
						--[FAMILY_FULL] will attempt to assign you as matriarch or patriarch of one of the local houses of the kingdom/town. Setspouse will will prevent \
						players with the setspouse = None from matching with you unless their name equals your setspouse."))

					else if(new_family)
						family = new_family
				//Setspouse is part of the family subsystem. It will check existing families for this character and attempt to place you in this family.
				if("setspouse")
					var/newspouse = tgui_input_text(user, "INPUT THE IDENTITY OF ANOTHER HERO", "TIL DEATH DO US PART", max_length = MAX_MESSAGE_LEN)
					if(newspouse)
						setspouse = newspouse
					else
						setspouse = null
				//Gender_choice is part of the family subsytem. It will check existing families members with the same preference of this character and attempt to place you in this family.
				if("select_quirks")
					open_quirk_menu(user)

				if("gender_choice")
					// If pronouns are neutral, lock to ANY_GENDER
					if(pronouns == THEY_THEM || pronouns == IT_ITS)
						to_chat(user, span_warning("With neutral pronouns, you may only choose [ANY_GENDER]."))
						gender_choice = ANY_GENDER
					else
						var/list/gender_choice_option_list = list(ANY_GENDER, SAME_GENDER, DIFFERENT_GENDER)
						var/new_gender_choice  = tgui_input_list(user, "SELECT YOUR HERO'S PREFERENCE", "TO LOVE AND TO CHERISH", gender_choice_option_list, gender_choice)
						if(new_gender_choice)
							gender_choice = new_gender_choice
					genderize_customizer_entries()
				if("alignment")
					var/new_alignment = tgui_input_list(user, "SELECT YOUR HERO'S MORALITY", "CUT FROM THE SAME CLOTH", ALL_ALIGNMENTS_LIST, alignment)
					if(new_alignment)
						alignment = new_alignment
				if("hotkeys")
					hotkeys = !hotkeys
					if(hotkeys)
						winset(user, null, "input.focus=true command=activeInput input.background-color=[COLOR_INPUT_ENABLED]  input.text-color = #EEEEEE")
					else
						winset(user, null, "input.focus=true command=activeInput input.background-color=[COLOR_INPUT_DISABLED]  input.text-color = #ad9eb4")

				if("see_chat_non_mob")
					see_chat_non_mob = !see_chat_non_mob
				if("action_buttons")
					buttons_locked = !buttons_locked
				if("tgui_fancy")
					tgui_fancy = !tgui_fancy
				if("tgui_lock")
					tgui_lock = !tgui_lock
				if("winflash")
					windowflashing = !windowflashing

				//here lies the badmins
				if("hear_adminhelps")
					user.client.toggleadminhelpsound()
				if("hear_prayers")
					user.client.toggle_prayer_sound()
				if("announce_login")
					user.client.toggleannouncelogin()
				if("combohud_lighting")
					toggles ^= COMBOHUD_LIGHTING
				if("toggle_dead_chat")
					user.client.deadchat()
				if("toggle_radio_chatter")
					user.client.toggle_hear_radio()
				if("toggle_prayers")
					user.client.toggleprayers()
				if("toggle_deadmin_always")
					toggles ^= DEADMIN_ALWAYS
				if("toggle_deadmin_antag")
					toggles ^= DEADMIN_ANTAGONIST
				if("toggle_deadmin_head")
					toggles ^= DEADMIN_POSITION_HEAD
				if("toggle_deadmin_security")
					toggles ^= DEADMIN_POSITION_SECURITY
				if("toggle_deadmin_silicon")
					toggles ^= DEADMIN_POSITION_SILICON


				if("be_special")
					to_chat(user, span_info("Antags are disabled for now."))
					return
					/*var/be_special_type = href_list["be_special_type"]
					if(be_special_type in be_special)
						be_special -= be_special_type
					else
						be_special += be_special_type*/

				if("toggle_random")
					var/random_type = href_list["random_type"]
					if(randomise[random_type])
						randomise -= random_type
					else
						randomise[random_type] = TRUE

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if((toggles & SOUND_LOBBY) && user.client && isnewplayer(user))
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					if(user.client?.holder)
						chat_toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					if(user.client?.holder)
						chat_toggles ^= CHAT_GHOSTSIGHT

				if("ghost_whispers")
					if(user.client?.holder)
						chat_toggles ^= CHAT_GHOSTWHISPER

				if("ghost_radio")
					chat_toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					chat_toggles ^= CHAT_GHOSTPDA

				if("income_pings")
					chat_toggles ^= CHAT_BANKCARD

				if("pull_requests")
					chat_toggles ^= CHAT_PULLR

				if("allow_midround_antag")
					toggles ^= MIDROUND_ANTAG

				if("ambientocclusion")
					toggles ^= AMBIENTOCCLUSION
					ambientocclusion = toggles & AMBIENTOCCLUSION
					update_occlusion(parent)

				if("auto_fit_viewport")
					auto_fit_viewport = !auto_fit_viewport
					if(auto_fit_viewport && parent)
						parent.fit_viewport()

				if("widescreenpref")
					widescreenpref = !widescreenpref
					var/datum/view_data/view = user.client.view_size
					view.setDefault(view.getScreenSize(widescreenpref))

				if("pixel_size")
					switch(pixel_size)
						if(PIXEL_SCALING_AUTO)
							pixel_size = PIXEL_SCALING_1X
						if(PIXEL_SCALING_1X)
							pixel_size = PIXEL_SCALING_1_2X
						if(PIXEL_SCALING_1_2X)
							pixel_size = PIXEL_SCALING_2X
						if(PIXEL_SCALING_2X)
							pixel_size = PIXEL_SCALING_3X
						if(PIXEL_SCALING_3X)
							pixel_size = PIXEL_SCALING_AUTO
					user.client.view_size.apply() //Let's winset() it so it actually works

				if("scaling_method")
					switch(scaling_method)
						if(SCALING_METHOD_NORMAL)
							scaling_method = SCALING_METHOD_DISTORT
						if(SCALING_METHOD_DISTORT)
							scaling_method = SCALING_METHOD_BLUR
						if(SCALING_METHOD_BLUR)
							scaling_method = SCALING_METHOD_NORMAL
					user.client.view_size.setZoomMode()

				if("schizo_voice")
					toggles ^= SCHIZO_VOICE
					if(toggles & SCHIZO_VOICE)
						to_chat(user, "<span class='warning'>You are now a voice.\n\
										As a voice, you will receive meditations from players asking about game mechanics!\n\
										Good voices could be rewarded with PQ by staff for answering meditations, while bad ones are punished.</span>")
					else
						to_chat(user, span_warning("You are no longer a voice."))

				if("loreprimer")
					lore_popup(user)

				if("finished")
					var/client/C = usr.client
					if(C)
						C.clear_character_previews()
					user << browse(null, "window=latechoices") //closes late choices window
					user << browse(null, "window=playersetup") //closes the player setup window
					user << browse(null, "window=preferences") //closes job selection
					user << browse(null, "window=mob_occupation")
					user << browse(null, "window=latechoices") //closes late job selection
					user << browse(null, "window=migration") // Closes migrant menu

					SStriumphs.remove_triumph_buy_menu(user.client)
					winshow(user, "stonekeep_prefwin", FALSE)
					user << browse(null, "window=preferences_browser")
					user << browse(null, "window=lobby_window")
					return

				if("save")
					save_preferences()
					save_character()
					if(isnewplayer(user))
						var/mob/dead/new_player/player = user
						player.cache_multi_ready_characters()

				if("load")
					load_preferences()
					load_character()
					if(isnewplayer(user))
						var/mob/dead/new_player/player = user
						player.cache_multi_ready_characters()

				if("changeslot")
					selected_accent = ACCENT_DEFAULT
					var/list/choices = list()
					if(path)
						var/savefile/S = new /savefile(path)
						if(S)
							for(var/i=1, i<=max_save_slots, i++)
								var/name
								S.cd = "/character[i]"
								S["real_name"] >> name
								if(!name)
									name = "Slot[i]"
								choices[name] = i
					var/choice = tgui_input_list(user, "WHO IS YOUR HERO?", "NECRA AWAITS", choices, real_name)
					if(choice)
						choice = choices[choice]
						if(!load_character(choice))
							randomise_appearance_prefs()
							customizer_entries = list()
							validate_customizer_entries()
							reset_all_customizer_accessory_colors()
							randomize_all_customizer_accessories()
							genderize_customizer_entries()
							save_character()

				if("randomiseappearanceprefs")
					user << browse(null, "window=misc_customization")
					randomise_appearance_prefs()
					customizer_entries = list()
					validate_customizer_entries()
					reset_all_customizer_accessory_colors()
					randomize_all_customizer_accessories()
					reset_jobs(user)
					genderize_customizer_entries()
					clear_flavor()

				if("tab")
					if (href_list["tab"])
						current_tab = text2num(href_list["tab"])

	update_menu_data(user)
	return 1


/datum/preferences/proc/show_misc_pref_ui(mob/user)
	var/list/dat = list()
	dat += {"
	<html lang="en">
	<head>
		<style>
			body {
				background-color: #1a1a1a;
				display: flex;
				justify-content: center;
				align-items: center;
				height: 100vh;
				margin: 0;
				image-rendering: pixelated;
			}
			.ui-container {
				position: relative;
				width: 272px;
				height: 293px;
				background-image: url('Charsheet_BG.1.png');
				background-size: cover;
				transform: scale(3);
				zoom: [100 / user.client?.window_scaling]%;
			}
		</style>
	</head>"}

	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	// Encapsulating table
	dat += "<table width = '100%'>"
	// Only one Row
	dat += "<tr>"
	// Leftmost Column, 40% width
	dat += "<td width=45% valign='top'>"

	//-----------START OF IDENT TABLE-----------//
	dat += "<h2 style='padding-left: 4px'>Identity</h2>"
	dat += "<table width='100%'><tr><td width='75%' valign='top'>"
	dat += "<br>"
	dat += "<b>Food Preferences:</b> <a href='?_src_=prefs;preference=culinary;task=menu'>Change</a><BR>"
	var/musicname = (combat_music.shortname ? combat_music.shortname : combat_music.name)
	dat += "<b>Combat Music:</b> <a href='?_src_=prefs;preference=combat_music;task=input'>[musicname || "FUCK!"]</a><BR>"
	dat += "<br><b>NSFW Flavortext:</b><a href='?_src_=prefs;preference=formathelp;task=input'>(?)</a><a href='?_src_=prefs;preference=nsfwflavortext;task=input'>Change</a>"
	dat += "<br><b>ERP:</b> <a href='?_src_=prefs;preference=erp;task=menu'>Change</a>"
	dat += "<br><b>NSFW Headshot:</b> <a href='?_src_=prefs;preference=nsfw_headshot;task=input'>Change</a>"
	if(nsfw_headshot_link != null)
		dat += "<br><img src='[nsfw_headshot_link]' width='125px' height='175px'>"
	dat += "<br><b>Song:</b> <a href='?_src_=prefs;preference=song_link;task=input'>Change URL</a>"
	dat += "<a href='?_src_=prefs;preference=change_title;task=input'>Change Title</a>"
	dat += "<a href='?_src_=prefs;preference=change_artist;task=input'>Change Artist</a>"
	dat += "<br><B>Image Gallery:</b> <a href='?_src_=prefs;preference=img_gallery;task=input'>Add</a>"
	dat+= "<a href='?_src_=prefs;preference=clear_gallery;task=input'>Clear Gallery</a>"
	dat += "<br><B>Nsfw Image Gallery:</b> <a href='?_src_=prefs;preference=nsfw_img_gallery;task=input'>Add</a>"
	dat+= "<a href='?_src_=prefs;preference=clear_nsfw_gallery;task=input'>Clear Nsfw Gallery</a>"
	dat += "</tr></table>"
	//-----------END OF IDENT TABLE-----------//


	// Middle dummy Column, 20% width
	dat += "</td>"
	dat += "<td width=10% valign='top'>"
	// Rightmost column, 40% width
	dat += "<td width=45% valign='top'>"
	dat += "<h2 style='padding-left: 4px'>Body</h2>"

	//-----------START OF BODY TABLE-----------
	dat += "<table width='100%'><tr><td width='1%' valign='top'>"

	// Rumours / Gossip
	dat += "<br><b>Rumours & Noble Gossip:</b><a href='?_src_=prefs;preference=formathelp;task=input'>(?)</a><br><a href='?_src_=prefs;preference=rumour;task=input'>Set Rumours</a><a href='?_src_=prefs;preference=gossip;task=input'>Set Gossip</a><a href='?_src_=prefs;preference=rumour_preview;task=input'><i>Preview</i></a><br>"

	var/use_skintones = pref_species.use_skintones
	if(use_skintones)

		//dat += APPEARANCE_CATEGORY_COLUMN
		var/skin_tone_wording = pref_species.skin_tone_wording // Both the skintone names and the word swap here is useless fluff

		dat += "<b>[skin_tone_wording]: </b><a href='?_src_=prefs;preference=s_tone;task=input'>Change </a> | <a href='?_src_=prefs;preference=skin_color_ref_list;task=input'>Reference</a>"
		//dat += "<a href='?_src_=prefs;preference=toggle_random;random_type=[RANDOM_SKIN_TONE]'>[(randomise[RANDOM_SKIN_TONE]) ? "Lock" : "Unlock"]</A>"

	dat += "<br>"
	if(pref_species.use_titles)
		var/display_title = selected_title ? selected_title : "None"
		dat += "<b>Race Title:</b> <a href='?_src_=prefs;preference=race_title;task=input'>[display_title]</a><BR>"
	dat += "<br><b>Markings:</b> <a href='?_src_=prefs;preference=markings;task=menu'>Change</a>"
	dat += "<br><b>Smallclothes:</b> <a href='?_src_=prefs;preference=underwear;task=menu'>Change</a>"

	if((MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))

		dat += "<br><b>Mutant Color #1:</b> <span style='border: 1px solid #161616; background-color: #[features["mcolor"]];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color;task=input'>Change</a><BR>"
		dat += "<b>Mutant Color #2:</b> <span style='border: 1px solid #161616; background-color: #[features["mcolor2"]];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color2;task=input'>Change</a><BR>"
		dat += "<b>Mutant Color #3:</b> <span style='border: 1px solid #161616; background-color: #[features["mcolor3"]];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color3;task=input'>Change</a><BR>"

	if(LAZYLEN(pref_species.allowed_taur_types))
		var/obj/item/bodypart/taur/T = taur_type
		var/name = ispath(T) ? T::name : "None"
		dat += "<br><b>Taur Body Type:</b> <a href='?_src_=prefs;preference=taur_type;task=input'>[name]</a><BR>"
		dat += "<b>Taur Color:</b> <span style='border: 1px solid #161616; background-color: #[taur_color];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=taur_color;task=input'>Change</a><BR>"
		dat += "<b>Taur Markings:</b> <span style='border: 1px solid #161616; background-color: #[taur_markings];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=taur_markings;task=input'>Change</a><BR>"
		dat += "<b>Taur Tertiary:</b> <span style='border: 1px solid #161616; background-color: #[taur_tertiary];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=taur_tertiary;task=input'>Change</a><BR>"

	dat += "<br></td>"

	dat += "</tr></table>"
	//-----------END OF BODY TABLE-----------//
	dat += "</td>"
	dat += "</tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "misc_customization", "<div align='center'>Miscellaneous Preferences</div>", 480, 500)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/// Sanitization checks to be performed before using these preferences.
/datum/preferences/proc/sanitize_chosen_prefs()
	/*if(!pref_species || !pref_species.preference_accessible(src))
		pref_species = new /datum/species/human/northern
		customizer_entries = list()
		validate_customizer_entries()
		save_character()*/

	sanitize_species_mutant_colors()

	if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == SPEC_ID_HUMEN))
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(GLOB.last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(GLOB.last_names)]"

/// Applies the randomization prefs, sanitizes the result and then applies the preference to the human mob.
/// This is good if you are applying prefs to a mob as if they were joining the round.
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	sanitize_chosen_prefs()
	apply_prefs_to(character, icon_updates)

/// Applies the given preferences to a human mob. Calling this directly will skip sanitisation.
/// This is good if you are applying prefs to a mob as if you were cloning them.
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, character_setup = FALSE)
	if(QDELETED(character) || !ishuman(character))
		return
	character.age = age
	character.gender = gender
	character.dna.features = features.Copy()
	character.dna.real_name = character.real_name
	character.dna.body_markings = deepCopyList(body_markings)
	character.set_species(pref_species.type, icon_update = FALSE, pref_load = src)
	/*if(real_name in GLOB.chosen_names)
		character.real_name = pref_species.random_name(gender)
	else
		character.real_name = real_name*/
	character.real_name = real_name
	character.name = character.real_name

	var/obj/item/organ/eyes/organ_eyes = character.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		organ_eyes.eye_color = eye_color
		organ_eyes.old_eye_color = eye_color

	character.skin_tone = skin_tone
	character.culture = GLOB.culture_singletons[culture]
	character.detail = detail
	//character.socks = socks

	/* V: */

	// Rumours / Noble gossip
	character.rumour = rumour
	character.noble_gossip = noble_gossip

	character.nsfwflavortext = nsfwflavortext

	character.erpprefs_flavor = erpprefs_flavor

	character.img_gallery = img_gallery

	character.nsfw_img_gallery = nsfw_img_gallery

	character.headshot_link = headshot_link

	character.nsfw_headshot_link = nsfw_headshot_link

	character.flavortext = flavortext
	character.flavortext_display = flavortext_display
	character.ooc_notes = ooc_notes
	character.ooc_notes_display = ooc_notes_display
	character.ooc_extra_link = ooc_extra_link
	character.ooc_extra = ooc_extra
	character.pronouns = pronouns
	character.voice_type = voice_type

	if(taur_type)
		character.Taurize(taur_type, "#[taur_color]", "#[taur_markings]", "#[taur_tertiary]")
	else if(character_setup)
		// This should only ever ~do~ anything for previews
		character.ensure_not_taur()


	if((selected_title != "None" && pref_species.use_titles) && selected_title != null)
		character.dna.species.name = selected_title

	character.domhand = domhand
	character.set_patron(selected_patron)
	character.familytree_pref = family
	character.gender_choice_pref = gender_choice

	if(smallclothes_preferences)
		apply_smallclothes_preferences(character)

	if(!character_setup)
		//RMH Edit
		generate_selectable_moanpacks()
		if(moan_selection == MOANPACK_TYPE_DEF)
			if(voice_type == VOICE_TYPE_MASC)
				character.moan_selection = GLOB.selectable_moanpacks["MALE DEFAULT"]
			else
				character.moan_selection = GLOB.selectable_moanpacks["FEMALE DEFAULT"]
		else
			character.moan_selection = GLOB.selectable_moanpacks[moan_selection]

		character.cmode_music_override = combat_music.musicpath
		character.cmode_music_override_name = combat_music.name
		character.voice_color = voice_color
		character.setspouse = setspouse
		if(length(quirks))
			// ???
			apply_quirks_to_character(character)

		if(culinary_preferences)
			apply_culinary_preferences(character)


		if(parent)
			var/datum/role_bans/bans = get_role_bans_for_ckey(parent.ckey)
			for(var/datum/role_ban_instance/ban as anything in bans.bans)
				if(!ban.curses)
					continue
				for(var/curse_name as anything in ban.curses)
					var/datum/curse/curse = GLOB.curse_names[curse_name]
					character.add_curse(curse.type)

			apply_trait_bans(character, parent.ckey)

			if(is_misc_banned(parent.ckey, BAN_MISC_LEPROSY))
				ADD_TRAIT(character, TRAIT_LEPROSY, TRAIT_BAN_PUNISHMENT)
			if(is_misc_banned(parent.ckey, BAN_MISC_PUNISHMENT_CURSE))
				ADD_TRAIT(character, TRAIT_PUNISHMENT_CURSE, TRAIT_BAN_PUNISHMENT)

		if(pref_species.multiple_accents && length(pref_species.multiple_accents))
			change_accent = TRUE
		else
			change_accent = FALSE

		character.accent = selected_accent

		/* :V */
		apply_character_kinks(character)

	if(icon_updates)
		character.update_body()
		character.update_body_parts(redraw = TRUE)

/datum/preferences/proc/get_default_name(name_id)
	// you can use name_id to add more here
	return random_unique_name()

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = tgui_input_text(user, "Choose your character's [namedata["qdesc"]]:", "Character Preference", max_length = MAX_NAME_LEN, encode = FALSE)
	if(!raw_name)
		if(namedata["allow_null"])
			custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' and .</font>")
			return
		else
			custom_names[name_id] = sanitized_name

/datum/preferences/proc/try_update_mutant_colors()
	if(update_mutant_colors)
		reset_body_marking_colors()
		reset_all_customizer_accessory_colors()

/datum/preferences/proc/has_mutant_color_preferences()
	return pref_species && ((MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))

/datum/preferences/proc/get_mutant_color_feature_key(color_slot)
	switch(color_slot)
		if(1)
			return "mcolor"
		if(2)
			return "mcolor2"
		if(3)
			return "mcolor3"
	return null

/datum/preferences/proc/get_mutant_palette_choice(list/palette, color_value)
	if(!length(palette) || !length(color_value))
		return null

	var/normalized_color = lowertext("[color_value]")
	for(var/palette_name in palette)
		if(lowertext("[palette[palette_name]]") == normalized_color)
			return palette_name

	return null

/datum/preferences/proc/is_mutant_color_in_palette(color_value, list/palette)
	return !isnull(get_mutant_palette_choice(palette, color_value))

/datum/preferences/proc/get_first_mutant_palette_color(list/palette)
	for(var/palette_name in palette)
		return palette[palette_name]
	return null

/datum/preferences/proc/sanitize_species_mutant_colors()
	if(!has_mutant_color_preferences())
		return

	for(var/color_slot in 1 to 3)
		var/list/palette = pref_species.get_mutant_color_list(color_slot)
		if(!length(palette))
			continue

		var/feature_key = get_mutant_color_feature_key(color_slot)
		if(!feature_key)
			continue

		if(color_slot == 1 && pref_species.use_skintones)
			var/feature_valid = is_mutant_color_in_palette(features[feature_key], palette)
			var/skin_valid = is_mutant_color_in_palette(skin_tone, palette)

			if(feature_valid)
				skin_tone = features[feature_key]
			else if(skin_valid)
				features[feature_key] = skin_tone
			/*else
				var/default_color = get_first_mutant_palette_color(palette)
				features[feature_key] = default_color
				skin_tone = default_color*/
			continue

		if(!is_mutant_color_in_palette(features[feature_key], palette))
			features[feature_key] = get_first_mutant_palette_color(palette)

/datum/preferences/proc/pick_mutant_color_from_palette(mob/user, color_slot)
	if(!has_mutant_color_preferences())
		return

	var/feature_key = get_mutant_color_feature_key(color_slot)
	if(!feature_key)
		return

	var/list/palette = pref_species.get_mutant_color_list(color_slot)
	if(!length(palette))
		to_chat(user, span_warning("This species does not have a preset palette for color #[color_slot] yet."))
		return

	var/current_choice = get_mutant_palette_choice(palette, features[feature_key])
	if(color_slot == 1 && pref_species.use_skintones && !current_choice)
		current_choice = get_mutant_palette_choice(palette, skin_tone)

	var/selection = tgui_input_list(user, "CHOOSE YOUR HERO'S COLOR #[color_slot]", "BODY COLOR #[color_slot]", palette, current_choice)
	if(!selection)
		return

	features[feature_key] = palette[selection]
	if(color_slot == 1 && pref_species.use_skintones)
		skin_tone = features[feature_key]

	try_update_mutant_colors()

/datum/preferences/proc/pick_common_color_from_palette(mob/user, prompt, title, current_color)
	var/list/palette = pref_species.get_common_mutant_color_palette()
	var/current_choice = get_mutant_palette_choice(palette, current_color)
	var/selection = tgui_input_list(user, prompt, title, palette, current_choice)
	if(!selection)
		return null
	return palette[selection]
/datum/preferences/proc/is_active_migrant()
	if(!migrant)
		return FALSE
	if(!migrant.active)
		return FALSE
	return TRUE

/datum/preferences/proc/allowed_respawn()
	if(!has_spawned)
		return TRUE
	if(is_misc_banned(parent.ckey, BAN_MISC_RESPAWN))
		return FALSE
	return TRUE

/datum/preferences/proc/get_ui_theme_stylesheet()
	switch(ui_theme)

		if(UI_PREFERENCE_LIGHT_MODE)

			. = {"
			<html>
			<head>
			  <style>
				body {
				  background-color: #ffffff;
				  color: #000000;
				}

				a {
				  color: #1a0dab;
				}

				a:visited {
				  color: #660099;
				}

				hr {
				  border-top: 1px solid #ccc;
				}
			  </style>
			</head>
			</html>
			"}

		if(UI_PREFERENCE_DARK_MODE)

			. = {"
			<html>
			<head>
			  <style>
				body {
				  background-color: #121212;
				  color: #e0e0e0;
				}
				a {
				  color: #90caf9;
				}
				a:visited {
				  color: #ce93d8;
				}
				hr {
				  border-top: 1px solid #444;
				}
			  </style>
			</head>
			</html>
			"}

/datum/preferences/proc/is_valid_headshot_link(mob/user, value, silent = FALSE, list/valid_extensions = list("jpg", "png", "jpeg", "gif"))
	var/static/list/allowed_hosts = list("i.gyazo.com", "a.l3n.co", "b.l3n.co", "c.l3n.co", "images2.imgbox.com", "thumbs2.imgbox.com", "files.catbox.moe")

	if(!length(value))
		return FALSE

	// Ensure link starts with "https://"
	if(findtext(value, "https://") != 1)
		if(!silent)
			to_chat(user, "<span class='warning'>Your link must be https!</span>")
		return FALSE

	// Extract domain from the URL
	var/start_index = length("https://") + 1
	var/end_index = findtext(value, "/", start_index)
	var/domain = (end_index ? copytext(value, start_index, end_index) : copytext(value, start_index))

	// Check if domain is in the allowed list
	if(!(domain in allowed_hosts))
		if(!silent)
			to_chat(user, "<span class='warning'>The image must be hosted on an approved site.</span>")
		return FALSE

	// Extract the filename and extension
	var/list/path_split = splittext(value, "/")
	var/filename = path_split[length(path_split)]
	var/list/file_parts = splittext(filename, ".")

	if(length(file_parts) < 2)
		return FALSE

	var/extension = file_parts[length(file_parts)]

	// Validate extension
	if(!(extension in valid_extensions))
		if(!silent)
			to_chat(user, "<span class='warning'>The image must be one of the following extensions: '[english_list(valid_extensions)]'</span>")
		return FALSE

	return TRUE

/proc/is_valid_nsfw_headshot_link(mob/user, value, silent = FALSE) //TA edit
	var/static/link_regex = regex("i.gyazo.com|a.l3n.co|b.l3n.co|c.l3n.co|images2.imgbox.com|thumbs2.imgbox.com|files.catbox.moe") //gyazo, discord, lensdump, imgbox, catbox
	var/static/list/valid_extensions = list("jpg", "png", "jpeg") // Regex works fine, if you know how it works

	if(!length(value))
		return FALSE

	var/find_index = findtext(value, "https://")
	if(find_index != 1)
		if(!silent)
			to_chat(user, "<span class='warning'>Your link must be https!</span>")
		return FALSE

	if(!findtext(value, "."))
		if(!silent)
			to_chat(user, "<span class='warning'>Invalid link!</span>")
		return FALSE
	var/list/value_split = splittext(value, ".")

	// extension will always be the last entry
	var/extension = value_split[length(value_split)]
	if(!(extension in valid_extensions))
		if(!silent)
			to_chat(usr, "<span class='warning'>The image must be one of the following extensions: '[english_list(valid_extensions)]'</span>")
		return FALSE

	find_index = findtext(value, link_regex)
	if(find_index != 9)
		if(!silent)
			to_chat(usr, "<span class='warning'>The image must be hosted on one of the following sites: 'Gyazo, Lensdump, Imgbox, Catbox'</span>")
		return FALSE
	return TRUE //TA edit end


/datum/preferences/proc/resolve_loadout_to_color(item_path)
	if (loadout1 && (item_path == loadout1.item_path) && loadout_1_hex)
		return loadout_1_hex
	if (loadout2 && (item_path == loadout2.item_path) && loadout_2_hex)
		return loadout_2_hex
	if (loadout3 && (item_path == loadout3.item_path) && loadout_3_hex)
		return loadout_3_hex

	return FALSE

/datum/preferences/proc/get_job_lock_html(datum/job/job, mob/user, used_name)
	var/player_species = user.client.prefs.pref_species.id_override || user.client.prefs.pref_species.id
	var/fails_allowed = length(job.allowed_races) && !(player_species in job.allowed_races)
	var/fails_blacklist = length(job.blacklisted_species) && (player_species in job.blacklisted_species)
	if(job.required_playtime_remaining(user.client))
		var/list/lines = list()
		for(var/t in job.exp_requirements)
			var/needed = job.exp_requirements[t]
			var/have = user.client.calc_exp_type(t)
			lines += "[t]: [get_exp_format(have)] / [get_exp_format(needed)]"
		var/text = jointext(lines, "<br>")

		return make_lock_row(
			used_name,
			"\[TIME LOCK\]",
			"<b>Requirements:</b><br>[text]"
		)
	if(fails_allowed || fails_blacklist)
		if(!user.client.has_triumph_buy(TRIUMPH_BUY_RACE_ALL))
			var/list/allowed_races = job.allowed_races.Copy()
			for(var/blacklist in job.blacklisted_species)
				allowed_races -= blacklist
			var/races_text = jointext(allowed_races, ", ")
			return make_lock_row(
				used_name,
				"\[SPECIES LOCK\]",
				"<b>Species Needed:</b><br>[races_text]"
			)
	if(length(job.allowed_ages) && !(user.client.prefs.age in job.allowed_ages))
		var/ages_text = jointext(job.allowed_ages, ", ")
		return make_lock_row(
			used_name,
			"\[AGE LOCK\]",
			"<b>Ages Needed:</b><br>[ages_text]"
		)
	if(length(job.allowed_sexes) && !(user.client.prefs.gender in job.allowed_sexes))
		var/sexes_text = jointext(job.allowed_sexes, ", ")
		return make_lock_row(
			used_name,
			"\[SEX LOCK\]",
			"<b>Sexes Needed:</b><br>[sexes_text]"
		)
	if(length(job.allowed_patrons) && !(user.client.prefs.selected_patron.type in job.allowed_patrons))
		var/list/patron_list = list()
		for(var/mult_patron in job.allowed_patrons)
			var/datum/patron/P = new mult_patron
			patron_list += (P.display_name ? P.display_name : P.name)
			qdel(P)
		var/patron_text = jointext(patron_list, ", ")

		return make_lock_row(
			used_name,
			"\[PATRON LOCK\]",
			"<b>Patron Needed:</b><br>[patron_text]"
		)
	// No lock
	return FALSE

/datum/preferences/proc/make_lock_row(used_name, lock_text, body_text)
	return {"
		[used_name]
	</td>
	<td>
		<div class='tutorialhover'>
			<font color=#a36c63>[lock_text]</font>
			<span class='tutorial'>[body_text]</span>
		</div>
	</td>
	</tr>
	"}

/proc/update_occlusion(client/parent_cl)
	if(parent_cl && parent_cl.screen && parent_cl.screen.len)
		var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in parent_cl.screen
		PM.backdrop(parent_cl.mob)
		PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in parent_cl.screen
		PM.backdrop(parent_cl.mob)
		PM = locate(/atom/movable/screen/plane_master/game_world_above) in parent_cl.screen
		PM.backdrop(parent_cl.mob)
		PM = locate(/atom/movable/screen/plane_master/game_world_below) in parent_cl.screen
		PM.backdrop(parent_cl.mob)
		PM = locate(/atom/movable/screen/plane_master/massive_obj) in parent_cl.screen
		PM.backdrop(parent_cl.mob)
		PM = locate(/atom/movable/screen/plane_master/game_world_walls) in parent_cl.screen
		PM.backdrop(parent_cl.mob)

/datum/preferences/proc/resolve_loadout_to_name(item_path)
	if (loadout1 && (item_path == loadout1.item_path) && loadout_1_name)
		return loadout_1_name
	if (loadout2 && (item_path == loadout2.item_path) && loadout_2_name)
		return loadout_2_name
	if (loadout3 && (item_path == loadout3.item_path) && loadout_3_name)
		return loadout_3_name
	if (loadout4 && (item_path == loadout4.item_path) && loadout_4_name)
		return loadout_4_name
	if (loadout5 && (item_path == loadout5.item_path) && loadout_5_name)
		return loadout_5_name
	if (loadout6 && (item_path == loadout6.item_path) && loadout_6_name)
		return loadout_6_name
	if (loadout7 && (item_path == loadout7.item_path) && loadout_7_name)
		return loadout_7_name
	if (loadout8 && (item_path == loadout8.item_path) && loadout_8_name)
		return loadout_8_name
	if (loadout9 && (item_path == loadout9.item_path) && loadout_9_name)
		return loadout_9_name
	if (loadout10 && (item_path == loadout10.item_path) && loadout_10_name)
		return loadout_10_name

	return FALSE

/datum/preferences/proc/resolve_loadout_to_desc(item_path)
	if (loadout1 && (item_path == loadout1.item_path) && loadout_1_desc)
		return loadout_1_desc
	if (loadout2 && (item_path == loadout2.item_path) && loadout_2_desc)
		return loadout_2_desc
	if (loadout3 && (item_path == loadout3.item_path) && loadout_3_desc)
		return loadout_3_desc
	if (loadout4 && (item_path == loadout4.item_path) && loadout_4_desc)
		return loadout_4_desc
	if (loadout5 && (item_path == loadout5.item_path) && loadout_5_desc)
		return loadout_5_desc
	if (loadout6 && (item_path == loadout6.item_path) && loadout_6_desc)
		return loadout_6_desc
	if (loadout7 && (item_path == loadout7.item_path) && loadout_7_desc)
		return loadout_7_desc
	if (loadout8 && (item_path == loadout8.item_path) && loadout_8_desc)
		return loadout_8_desc
	if (loadout9 && (item_path == loadout9.item_path) && loadout_9_desc)
		return loadout_9_desc
	if (loadout10 && (item_path == loadout10.item_path) && loadout_10_desc)
		return loadout_10_desc

	return FALSE
