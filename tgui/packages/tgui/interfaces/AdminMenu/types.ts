export type VerbEntry = {
  /** DM verb path, the id used to run it. */
  path: string;
  name: string;
  desc?: string | null;
  /** The verb's original stat panel category, e.g. "Admin.Jump". */
  category: string;
  hidden: boolean;
  /** Rights flags that grant the verb, empty when any admin gets it. */
  rights: string;
};

export type PlayerEntry = {
  ref: string;
  ckey: string;
  key: string;
  name: string;
  real_name: string;
  job: string;
  kind: 'living' | 'ghost' | 'lobby' | 'other';
  antag: boolean;
  connected: boolean;
  admin: boolean;
  dead: boolean;
  old_names: string;
};

export type LanguageEntry = { type: string; name: string; known: boolean };
export type QuirkEntry = { type: string; name: string; points: number };
export type QuirkOption = QuirkEntry & { group: string };

export type PlayerDetail = {
  ref: string;
  ckey: string;
  key: string;
  name: string;
  real_name: string;
  type: string;
  job: string;
  connected: boolean;
  is_new_player: boolean;
  is_living: boolean;
  is_human: boolean;
  has_mind: boolean;
  antag: boolean;
  ip?: string | null;
  log_src: string;
  has_attributes: boolean;
  location: string;
  health?: number;
  max_health?: number;
  stat?: string;
  godmode?: boolean;
  patron?: string | null;
  curses?: string;
  job_title?: string | null;
  quirks?: QuirkEntry[];
  languages: LanguageEntry[];
  rank?: string;
  is_admin?: boolean;
  playtime?: string;
  first_seen?: string;
  account_date?: string;
  byond_version?: string;
  pq?: string;
  pq_num?: number;
  muted?: number;
  centcom?: boolean;
};

export type ControllerRow = {
  flag: string;
  name: string;
  value: string;
  ref?: string | null;
};

export type AdminLogEntry = {
  id: number;
  time: string;
  cat: string;
  ckey?: string | null;
  text: string;
  x?: number | null;
  y?: number | null;
  z?: number | null;
};

export type AdminLog = {
  entries: AdminLogEntry[];
  matches: number;
  total: number;
  page: number;
  pages: number;
  categories: { id: string; name: string; count: number }[];
  selected_categories: string[];
  player?: string | null;
  search: string;
};

export type MuteType = { name: string; flag: number };

export type AdminMenuData = {
  // static
  verbs: VerbEntry[];
  mute_types: MuteType[];
  /** Every quirk that can be added; the same all round, so sent once. */
  quirk_options?: QuirkOption[];
  // dynamic
  ckey: string;
  rank: string;
  rights: string;
  can_varedit: boolean;
  new_menu: boolean;
  page: 'commands' | 'players' | 'mc' | 'log';
  /** Bumped when the server opens a page (F6): the window jumps to data.page. */
  page_request: number;
  notice?: string | null;
  notice_type: 'info' | 'good' | 'bad';
  notice_id: number;
  recent: string[];
  favorites: string[];
  log?: AdminLog;
  /** Sent only when a new player appears in the Round Log. */
  log_actors?: string[];
  active_tickets: number;
  round_time: string;
  player_count: number;
  marked?: string | null;
  players?: PlayerEntry[];
  selected?: PlayerDetail | null;
  mc?: { rows: ControllerRow[]; sdql2: number };
};
