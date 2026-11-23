/**
 * Where every admin command lives in the Admin Menu.
 *
 * The server only says which verbs the admin holds. This file sorts them into categories and
 * folders, picks an icon, and marks the destructive ones. A verb nobody has sorted yet still
 * shows up: it falls back to its original stat panel category, or to "Other".
 */
import type { VerbEntry } from './types';

export type CategoryId =
  | 'players'
  | 'moderation'
  | 'movement'
  | 'objects'
  | 'events'
  | 'round'
  | 'debug'
  | 'prefs'
  | 'other';

export type Category = {
  id: CategoryId;
  name: string;
  icon: string;
  hint: string;
};

export const CATEGORIES: Category[] = [
  {
    id: 'players',
    name: 'Players',
    icon: 'users',
    hint: 'Player list, player panel and per-player actions',
  },
  {
    id: 'moderation',
    name: 'Moderation',
    icon: 'gavel',
    hint: 'Bans, notes, logs, staff chat, player quality',
  },
  {
    id: 'movement',
    name: 'Movement & Observation',
    icon: 'eye',
    hint: 'Ghosting, jumping, teleporting mobs, visibility',
  },
  {
    id: 'objects',
    name: 'Objects & Creatures',
    icon: 'cube',
    hint: 'Spawning, equipment, mob control, deleting, build mode',
  },
  {
    id: 'events',
    name: 'Events & Storytelling',
    icon: 'scroll',
    hint: 'Narration, divine intervention, fun, sound, world events',
  },
  {
    id: 'round',
    name: 'Round & Server',
    icon: 'server',
    hint: 'Round control, server settings, chat control, staff',
  },
  {
    id: 'debug',
    name: 'Debug',
    icon: 'bug',
    hint: 'View Variables, proc calls, controllers, mapping, profiling',
  },
  {
    id: 'prefs',
    name: 'Admin Preferences',
    icon: 'cog',
    hint: 'Your own admin toggles',
  },
  {
    id: 'other',
    name: 'Other',
    icon: 'ellipsis-h',
    hint: 'Commands that are not sorted into a category yet',
  },
];

type Place = [CategoryId, string];

/** Original stat panel category -> place in the menu. */
const BY_CATEGORY: Record<string, Place> = {
  Admin: ['movement', 'Jump & Teleport'],
  'Admin.Admin': ['moderation', 'General'],
  'Admin.Admin Preferences': ['prefs', 'Visibility & Verbs'],
  'Admin.Bans': ['moderation', 'Bans'],
  'Admin.Ghost': ['movement', 'Ghost'],
  'Admin.Jump': ['movement', 'Jump & Teleport'],
  'Admin.Logs': ['moderation', 'Logs & Investigation'],
  'Admin.Management': ['round', 'Staff & Permissions'],
  Debug: ['debug', 'General'],
  'Debug.Core': ['debug', 'Core Tools'],
  'Debug.Debug': ['debug', 'Diagnostics'],
  'Debug.Dungeon': ['debug', 'Dungeon'],
  'Debug.Mapping': ['debug', 'Mapping'],
  'Debug.Mapping Custom': ['debug', 'Map Templates'],
  'Debug.Profiler': ['debug', 'Profiler'],
  'Debug.Spawn': ['objects', 'Spawn'],
  Event: ['objects', 'Build Mode'],
  GameMaster: ['events', 'General'],
  'GameMaster.Antags': ['events', 'Antagonists'],
  'GameMaster.Codes': ['moderation', 'Whitelist Codes'],
  'GameMaster.Equipping': ['objects', 'Equipment & Bodies'],
  'GameMaster.Fun': ['events', 'Fun'],
  'GameMaster.Gods': ['events', 'Divine Intervention'],
  'GameMaster.Interactions': ['events', 'World Interactions'],
  'GameMaster.Narrate': ['events', 'Narration'],
  'GameMaster.Sound': ['events', 'Sound'],
  'GameMaster.Triumphs': ['moderation', 'Player Quality & Triumphs'],
  '-GameMaster-': ['events', 'Frontier'],
  'OOC.Admin': ['round', 'Chat Control'],
  'Preferences.Admin': ['prefs', 'Chat & Sound'],
  Server: ['round', 'Server'],
  'Server.Round Control': ['round', 'Round Control'],
};

/** Proc name (last segment of the verb path) -> place, for verbs whose old tab said little. */
const BY_PROC: Record<string, Place> = {
  // Moderation
  show_player_panel: ['moderation', 'Players'],
  playerpanel: ['moderation', 'Players'],
  cmd_admin_check_player_exp: ['moderation', 'Players'],
  discord_id_manipulation: ['moderation', 'Players'],
  send_to_cryo: ['moderation', 'Players'],
  cmd_give_job_boost: ['moderation', 'Players'],
  cmd_view_job_boosts: ['moderation', 'Players'],
  cmd_admin_pm_panel: ['moderation', 'Communication'],
  cmd_admin_pm_context: ['moderation', 'Communication'],
  cmd_admin_say: ['moderation', 'Communication'],
  dsay: ['moderation', 'Communication'],
  investigate_show: ['moderation', 'Logs & Investigation'],
  // Movement
  Getkey: ['movement', 'Jump & Teleport'],
  Getmob: ['movement', 'Jump & Teleport'],
  cmd_get_mob: ['movement', 'Jump & Teleport'],
  sendmob: ['movement', 'Jump & Teleport'],
  jump_to_ruin: ['movement', 'Jump & Teleport'],
  returntolobby: ['movement', 'Ghost'],
  toggle_view_range: ['movement', 'Visibility'],
  invisimin: ['movement', 'Visibility'],
  stealth: ['movement', 'Visibility'],
  toggle_combo_hud: ['movement', 'Visibility'],
  adjust_personal_see_leylines: ['movement', 'Visibility'],
  // Objects & creatures
  cmd_admin_delete: ['objects', 'Delete'],
  cmd_debug_del_all: ['objects', 'Delete'],
  remove_liquid: ['objects', 'Delete'],
  togglebuildmodeself: ['objects', 'Build Mode'],
  cmd_assume_direct_control: ['objects', 'Mob Control'],
  cmd_give_control_to_player: ['objects', 'Mob Control'],
  possess: ['objects', 'Mob Control'],
  release: ['objects', 'Mob Control'],
  admin_heal: ['objects', 'Mob Control'],
  admin_sleep: ['objects', 'Mob Control'],
  prompt_subclass: ['objects', 'Mob Control'],
  respawn_character: ['objects', 'Mob Control'],
  cmd_admin_godmode: ['objects', 'Mob Control'],
  cmd_admin_rejuvenate: ['objects', 'Mob Control'],
  give_spell: ['objects', 'Mob Control'],
  remove_spell: ['objects', 'Mob Control'],
  manipulate_organs: ['objects', 'Mob Control'],
  cmd_admin_drop_everything: ['objects', 'Equipment & Bodies'],
  spawn_hunting_trail: ['objects', 'Spawn'],
  // Events
  manage_resurrection_runes: ['events', 'World Interactions'],
  open_scene_editor: ['events', 'Scenes'],
  show_tip: ['events', 'Narration'],
  open_wave_creator: ['events', 'Waves & Migrants'],
  wave_creation_tools: ['events', 'Waves & Migrants'],
  admin_force_next_migrant_wave: ['events', 'Waves & Migrants'],
  toggle_migrations: ['events', 'Waves & Migrants'],
  run_particle_weather: ['events', 'World & Weather'],
  set_tod_override: ['events', 'World & Weather'],
  toggle_random_events: ['events', 'World & Weather'],
  forceEvent: ['events', 'World & Weather'],
  pump_random_event: ['events', 'World & Weather'],
  cmd_admin_mod_antag_rep: ['events', 'Antagonists'],
  // Round & server
  game_panel: ['round', 'Round Control'],
  secrets: ['round', 'Round Control'],
  forceGamemode: ['round', 'Round Control'],
  start_vote: ['round', 'Round Control'],
  change_skill_exp_modifier: ['round', 'Round Control'],
  cmd_admin_list_open_jobs: ['round', 'Jobs'],
  toggle_jobs_for_persistent: ['round', 'Jobs'],
  select_job_pack_debug: ['round', 'Jobs'],
  poll_panel: ['round', 'Server'],
  reload_configuration: ['round', 'Server'],
  reestablish_db_connection: ['round', 'Server'],
  announce: ['round', 'Chat Control'],
  set_admin_notice: ['round', 'Chat Control'],
  // Debug
  mark_datum_mapview: ['debug', 'Core Tools'],
  vv_history_panel: ['debug', 'Core Tools'],
  cmd_controller_view_ui: ['debug', 'Controllers'],
  restart_controller: ['debug', 'Controllers'],
  create_or_modify_area: ['debug', 'Mapping'],
  fix_death_area: ['debug', 'Mapping'],
  toggle_debug_pathfinding: ['debug', 'Diagnostics'],
  view_armor_compare: ['debug', 'Diagnostics'],
  check_bomb_impacts: ['debug', 'Diagnostics'],
  tracy_next_round: ['debug', 'Profiler'],
  start_tracy: ['debug', 'Profiler'],
  // Preferences
  toggle_AI_interact: ['prefs', 'Visibility & Verbs'],
  toggle_admin_menu_mode: ['prefs', 'Visibility & Verbs'],
  toggle_admin_context_menu_mode: ['prefs', 'Visibility & Verbs'],
  toggle_admin_ghost_hands: ['prefs', 'Visibility & Verbs'],
  toggle_context_menu: ['prefs', 'Visibility & Verbs'],
};

/** Proc name -> icon. Everything else gets an icon from its name, then from its folder. */
const ICON_BY_PROC: Record<string, string> = {
  debug_variables: 'search-plus',
  callproc: 'terminal',
  callproc_datum: 'terminal',
  SDQL2_query: 'database',
  view_runtimes: 'exclamation-triangle',
  game_panel: 'chess-board',
  secrets: 'user-secret',
  show_player_panel: 'id-card',
  playerpanel: 'address-book',
  check_antagonists: 'mask',
  show_traitor_panel: 'mask',
  ban_panel: 'gavel',
  unban_panel: 'unlock',
  role_ban_panel: 'user-slash',
  admin_ghost: 'ghost',
  toggle_aghost_invis: 'ghost',
  ghost_up: 'arrow-up',
  ghost_down: 'arrow-down',
  ghostears: 'assistive-listening-systems',
  ghostwhispers: 'comment-dots',
  ghosteyes: 'eye',
  invisimin: 'eye-slash',
  stealth: 'user-ninja',
  cmd_admin_say: 'comments',
  dsay: 'skull',
  cmd_admin_pm_panel: 'envelope',
  cmd_admin_pm_context: 'envelope',
  cmd_admin_subtle_message: 'comment-dots',
  cmd_admin_direct_narrate: 'feather',
  cmd_admin_world_narrate: 'globe',
  cmd_admin_local_narrate: 'bullhorn',
  cmd_admin_create_announcement: 'bullhorn',
  announce: 'bullhorn',
  admin_heal: 'heart',
  cmd_admin_rejuvenate: 'heartbeat',
  admin_sleep: 'bed',
  sleep_view: 'bed',
  wake_view: 'sun',
  admin_bless: 'pray',
  admin_curse: 'skull-crossbones',
  smite: 'bolt',
  heart_attack: 'heart-broken',
  cmd_admin_godmode: 'shield-alt',
  cmd_admin_gib: 'bomb',
  cmd_admin_gib_self: 'bomb',
  drop_bomb: 'bomb',
  drop_dynex_bomb: 'bomb',
  cmd_admin_explosion: 'bomb',
  cmd_admin_delete: 'trash',
  cmd_debug_del_all: 'trash-alt',
  spawn_atom: 'plus-square',
  podspawn_atom: 'parachute-box',
  beaker_panel: 'flask',
  cmd_admin_dress: 'tshirt',
  cmd_admin_check_contents: 'box-open',
  togglebuildmodeself: 'hammer',
  possess: 'hand-paper',
  release: 'hand-rock',
  cmd_assume_direct_control: 'gamepad',
  cmd_give_control_to_player: 'people-arrows',
  respawn_character: 'redo',
  give_spell: 'magic',
  open_scene_editor: 'theater-masks',
  remove_spell: 'magic',
  force_say: 'comment',
  object_say: 'comment',
  startnow: 'play',
  restart: 'power-off',
  end_round: 'flag-checkered',
  delay: 'pause',
  stop_restart: 'hand-paper',
  accelerate_or_delay_round_end: 'hourglass-half',
  start_vote: 'vote-yea',
  adminchangemap: 'map',
  forcerandomrotate: 'map-signs',
  panicbunker: 'shield-alt',
  edit_admin_permissions: 'user-shield',
  reload_admins: 'users-cog',
  getserverlogs: 'file-archive',
  getcurrentlogs: 'file-alt',
  investigate_show: 'search',
  check_pq: 'star-half-alt',
  adjust_pq: 'star',
  give_all_triumphs: 'trophy',
  end_triumph_season: 'trophy',
  manage_books: 'book',
  manage_paintings: 'palette',
  send_bird_letter: 'dove',
  ShowAllFamilies: 'sitemap',
  local_lightsout: 'lightbulb',
  run_particle_weather: 'cloud-rain',
  set_tod_override: 'clock',
  cmd_controller_view_ui: 'tachometer-alt',
  restart_controller: 'sync',
  hide_verbs: 'eye-slash',
  hide_most_verbs: 'low-vision',
  toggle_admin_menu_mode: 'columns',
  toggle_admin_context_menu_mode: 'mouse-pointer',
  toggle_admin_ghost_hands: 'hand-paper',
  enable_browser_debug: 'tools',
  vv_history_panel: 'history',
  map_export: 'file-export',
  map_template_load: 'file-import',
  map_template_upload: 'upload',
  search_important_items: 'gem',
  mark_datum_mapview: 'thumbtack',
  toggle_view_range: 'expand',
  set_ui_theme: 'adjust',
  set_ghost_sprite: 'ghost',
  discord_id_manipulation: 'link',
  open_wave_creator: 'users',
  wave_creation_tools: 'users-cog',
  admin_force_next_migrant_wave: 'walking',
  anoint_priest: 'church',
  forceGamemode: 'chess',
};

/** First matching rule wins. Tested against the verb's display name. */
const ICON_BY_NAME: [RegExp, string][] = [
  [/frontier/i, 'mountain'],
  [/jump|teleport/i, 'location-arrow'],
  [/\bget\b|\bsend\b/i, 'people-arrows'],
  [/sound|music|ambien/i, 'music'],
  [/ooc/i, 'comments'],
  [/toggle|show\/hide|hear\/silence|do\/don't/i, 'toggle-on'],
  [/spawn|create|generate/i, 'plus-square'],
  [/delete|del-|remove|clear/i, 'trash'],
  [/ban\b|mute/i, 'gavel'],
  [/log|runtime|census|report/i, 'file-alt'],
  [/profil|tracy/i, 'stopwatch'],
  [/reload|restart|regenerate|reestablish|refresh/i, 'sync'],
  [/debug|test/i, 'bug'],
  [/color|colour|theme|icon/i, 'palette'],
  [/narrate|announce|say|message|tip/i, 'comment'],
  [/job|subclass|migra|wave/i, 'briefcase'],
  [/triumph|pq|quality|commend/i, 'star'],
  [/code|whitelist/i, 'key'],
  [/map|area|z-level|ruin|dungeon|pocket/i, 'map'],
  [/explosi|bomb|dynex/i, 'bomb'],
  [/liquid|pollution|weather/i, 'tint'],
  [/hud|view|check|display|list|count|show/i, 'eye'],
  [/set |change|modify|adjust|edit/i, 'sliders-h'],
  [/event|trigger|force|pump/i, 'dice'],
  [/config|server|hub|cdn|fps/i, 'server'],
  [/priest|bless|curse|god/i, 'pray'],
  [/vote|poll/i, 'vote-yea'],
];

/** Destructive or far-reaching commands: the menu asks for a second click before running them. */
const DANGEROUS = new Set<string>([
  'restart',
  'end_round',
  'startnow',
  'cmd_debug_del_all',
  'cmd_admin_delete',
  'everyone_random',
  'drop_bomb',
  'drop_dynex_bomb',
  'cmd_admin_explosion',
  'cmd_admin_gib',
  'cmd_admin_gib_self',
  'heart_attack',
  'smite',
  'end_triumph_season',
  'give_all_triumphs',
  'adminchangemap',
  'forcerandomrotate',
  'restart_controller',
  'reload_admins',
  'hide_verbs',
  'sleep_view',
  'local_lightsout',
  'panicbunker',
  'toggle_hub',
  'returntolobby',
  'map_template_load',
]);

/** Shown first on the Commands home page when the admin has them. */
export const QUICK_ACCESS: string[] = [
  'debug_variables',
  'admin_ghost',
  'game_panel',
  'open_scene_editor',
  'check_antagonists',
  'cmd_admin_pm_panel',
  'jumptomob',
  'jumptokey',
  'Getmob',
  'spawn_atom',
  'togglebuildmodeself',
  'ban_panel',
  'investigate_show',
];

export type MenuVerb = VerbEntry & {
  proc: string;
  categoryId: CategoryId;
  folder: string;
  icon: string;
  dangerous: boolean;
  /** Lower-cased text the search runs against. */
  haystack: string;
};

const FOLDER_ICONS: Record<string, string> = {
  Bans: 'gavel',
  Ghost: 'ghost',
  'Jump & Teleport': 'location-arrow',
  Spawn: 'plus-square',
  Delete: 'trash',
  Sound: 'music',
  Narration: 'feather',
  'Round Control': 'flag-checkered',
  Server: 'server',
  'Core Tools': 'tools',
  Mapping: 'map',
  Profiler: 'stopwatch',
  'Mob Control': 'gamepad',
  'Build Mode': 'hammer',
  Frontier: 'mountain',
  Communication: 'comments',
  Players: 'users',
};

export function folderIcon(folder: string): string {
  return FOLDER_ICONS[folder] || 'folder';
}

function procName(path: string): string {
  const cut = path.lastIndexOf('/');
  return cut === -1 ? path : path.slice(cut + 1);
}

function pickIcon(proc: string, name: string, folder: string): string {
  const exact = ICON_BY_PROC[proc];
  if (exact) {
    return exact;
  }
  for (const [pattern, icon] of ICON_BY_NAME) {
    if (pattern.test(name)) {
      return icon;
    }
  }
  return FOLDER_ICONS[folder] || 'chevron-circle-right';
}

function place(verb: VerbEntry, proc: string): Place {
  const byProc = BY_PROC[proc];
  if (byProc) {
    return byProc;
  }
  const byCategory = BY_CATEGORY[verb.category];
  if (byCategory) {
    return byCategory;
  }
  if (!verb.category) {
    return ['other', 'Right-click Commands'];
  }
  // Unknown tab: keep its own name as the folder so nothing gets lost.
  const top = verb.category.split('.')[0];
  if (top === 'Debug') {
    return ['debug', verb.category.replace(/^Debug\.?/, '') || 'General'];
  }
  if (top === 'GameMaster') {
    return ['events', verb.category.replace(/^GameMaster\.?/, '') || 'General'];
  }
  if (top === 'Server') {
    return ['round', verb.category.replace(/^Server\.?/, '') || 'Server'];
  }
  return ['other', verb.category];
}

export function buildCatalog(verbs: VerbEntry[]): MenuVerb[] {
  const catalog = verbs.map((verb): MenuVerb => {
    const proc = procName(verb.path);
    const [categoryId, folder] = place(verb, proc);
    const category = CATEGORIES.find((entry) => entry.id === categoryId);
    return {
      ...verb,
      proc,
      categoryId,
      folder,
      icon: pickIcon(proc, verb.name, folder),
      dangerous: DANGEROUS.has(proc),
      haystack: [
        verb.name,
        verb.desc || '',
        folder,
        category?.name || '',
        verb.category,
        proc,
      ]
        .join(' ')
        .toLowerCase(),
    };
  });
  catalog.sort((a, b) => a.name.localeCompare(b.name));
  return catalog;
}

/** Folders of one category, alphabetical, with "General" first. */
export function groupByFolder(verbs: MenuVerb[]): [string, MenuVerb[]][] {
  const folders = new Map<string, MenuVerb[]>();
  for (const verb of verbs) {
    const list = folders.get(verb.folder);
    if (list) {
      list.push(verb);
    } else {
      folders.set(verb.folder, [verb]);
    }
  }
  return [...folders.entries()].sort(([a], [b]) => {
    if (a === 'General') {
      return -1;
    }
    if (b === 'General') {
      return 1;
    }
    return a.localeCompare(b);
  });
}
