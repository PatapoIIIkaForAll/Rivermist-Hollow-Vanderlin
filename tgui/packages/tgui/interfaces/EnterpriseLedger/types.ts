import type { BooleanLike } from 'tgui-core/react';

export type PrestigeGrade = {
  level: number;
  unlocked: BooleanLike;
  saved: BooleanLike;
  spent: BooleanLike;
};

export type PrestigeData = {
  level: number;
  max_level: number;
  earned: number;
  next: number | null;
  grades: PrestigeGrade[];
};

export type DebugData = {
  bank: number;
  owner_level: number;
  max_owner_level: number;
  max_room_level: number;
  patrons: number;
  patron_kinds: string[];
};

export type Data = {
  name: string;
  map: string | null;
  floors: FloorInfo[];
  rooms: RoomInfo[];

  pages: string[];
  can_manage: BooleanLike;
  is_staff: BooleanLike;
  shift_active: BooleanLike;
  viewed_z: number | null;
  book_balance: number;
  earned_round: number;
  earned_today: number;
  prestige: PrestigeData | null;
  debug: DebugData | null;
};

export type RoomKind = 'guest' | 'service' | 'common';

export type RoomInfo = {
  id: number;
  name: string;
  kind: RoomKind;
  z: number;
  tiles: number;
  purpose: string | null;
  level: number;
  tenant: string | null;
  beds: number;
  items: number;
};

export type FloorInfo = {
  z: number;
  basement: BooleanLike;
  tiles: number;
};

export type IconInfo = {
  name: string;
  icon: string | null;
  icon_state: string | null;
};

export type ContentLine = IconInfo & {
  id: string;
  value: number;
  count: number;
  missing: number;
};

export type UpgradeLine = {
  id: string;
  count: number;
  from: IconInfo;
  to: IconInfo;
};

export type TenantInfo = {
  name: string;
  patron: BooleanLike;
  time_left: number | null;
  rent: number;
  needs: string[];
};

export type RoomPage = 'info' | 'upgrade';

export type RoomData = {
  enterprise: string;
  name: string;
  kind: RoomKind;
  purpose: string | null;
  floor: number;
  tiles: number;
  beds: number;
  page: RoomPage;
  level: number;
  max_level: number;
  effect: string | null;
  next_effect: string | null;
  upgrade_cost: number;
  can_grade: BooleanLike;
  funds: number;
  rent: number;
  seatings: number;
  contents: ContentLine[];
  upgrades: UpgradeLine[];
  repair_cost: number;
  tenant: TenantInfo | null;
};

export type StockEntry = IconInfo & {
  id: string;
  amount: number;
  price: number;
  buyout: number;
};

export type StockData = {
  enterprise: string;
  level: number;
  cap: number;
  can_buy: BooleanLike;
  funds: number;
  entries: StockEntry[];
};

export type Locale = {
  windowTitle: string;
  enterpriseNames: Record<string, string>;
  pages: Record<string, string>;
  purposes: Record<string, string>;
  enterprisePurposes: Record<string, Record<string, string>>;
  purposeUnknown: string;
  levelNames: string[];
  labels: {
    yourRole: string;
    roleManager: string;
    roleStaff: string;
    roleOutsider: string;
    shift: string;
    shiftActive: string;
    shiftInactive: string;
    startShift: string;
    endShift: string;
    sectionInProgress: string;
    premises: string;
    premisesMissing: string;
    basement: string;
    guestRooms: string;
    guestRoomsNone: string;
    surveyAgain: string;
    resetView: string;
    legend: string;
    legendHint: string;
    legendEmpty: string;
    bookBalance: string;
    bookHint: string;
    earnedRound: string;
    earnedToday: string;
  };
  prestige: {
    title: string;
    level: string;
    earned: string;
    next: string;
    nextNone: string;
    roundNote: string;
    gradesTitle: string;
    gradesHint: string;
    gradeLocked: string;
    gradeEmpty: string;
    gradeReady: string;
    gradeSpent: string;
  };
  room: {
    info: string;
    upgrade: string;
    about: string;
    purpose: string;
    floor: string;
    size: string;
    beds: string;
    level: string;
    effect: string;
    effectNone: string;
    rent: string;
    rentNone: string;
    seatings: string;
    tenant: string;
    tenantNone: string;
    tenantName: string;
    tenantPatron: string;
    tenantStay: string;
    tenantStayForever: string;
    tenantRent: string;
    tenantNeeds: string;
    tenantNeedsNone: string;
    contents: string;
    contentsNone: string;
    effectNow: string;
    effectNext: string;
    upgradeItems: string;
    upgradeItemsNone: string;
    upgradeMaxLevel: string;
    upgradeNotForSale: string;
    upgradeFunds: string;
    prestigeGrade: string;
    prestigeGradeHint: string;
  };
  debug: {
    title: string;
    note: string;
    money: string;
    bank: string;
    ownerLevel: string;
    grant: string;
    reload: string;
    rooms: string;
    allRooms: string;
    patrons: string;
    patronsCount: string;
    summon: string;
    clearPatrons: string;
    time: string;
    newDay: string;
    tired: string;
  };
  stock: {
    title: string;
    hint: string;
    capacity: string;
    empty: string;
    price: string;
    buy: string;
    funds: string;
  };
  formatPremises: (floors: number, basements: number, tiles: number) => string;
  formatFloor: (number: number) => string;
  formatTiles: (tiles: number) => string;
  formatBeds: (beds: number) => string;
  formatRepair: (cost: number) => string;
  formatMissing: (missing: number) => string;
  formatLevel: (level: number, maxLevel: number) => string;
  formatLevelUp: (level: number, nextLevel: number) => string;
  formatStay: (hours: number, minutes: number) => string;
  formatUpgrade: (cost: number) => string;
  formatRent: (rent: number) => string;
  formatBuy: (cost: number) => string;
  formatCapacity: (cap: number) => string;
};

export type PageProps = {
  locale: Locale;
  pageId: string;
};
