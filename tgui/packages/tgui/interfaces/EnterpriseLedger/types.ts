import type { BooleanLike } from 'tgui-core/react';

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
};

export type RoomKind = 'guest' | 'service' | 'common';

export type RoomInfo = {
  id: number;
  name: string;
  kind: RoomKind;
  z: number;
  tiles: number;
  purpose: string | null;
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
  time_left: number;
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
  contents: ContentLine[];
  upgrades: UpgradeLine[];
  repair_cost: number;
  tenant: TenantInfo | null;
};

export type Locale = {
  windowTitle: string;
  enterpriseNames: Record<string, string>;
  pages: Record<string, string>;
  purposes: Record<string, string>;
  enterprisePurposes: Record<string, Record<string, string>>;
  purposeUnknown: string;
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
    tenant: string;
    tenantNone: string;
    tenantName: string;
    tenantStay: string;
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
    upgradeSoon: string;
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
};

export type PageProps = {
  locale: Locale;
  pageId: string;
};
