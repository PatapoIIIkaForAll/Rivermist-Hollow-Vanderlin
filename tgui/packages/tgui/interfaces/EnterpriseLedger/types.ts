import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  // ui_static_data
  name: string;
  // The id of the BYOND map control the floors are drawn on.
  map: string | null;
  floors: FloorInfo[];
  rooms: RoomInfo[];

  // ui_data
  pages: string[];
  can_manage: BooleanLike;
  is_staff: BooleanLike;
  shift_active: BooleanLike;
  // The floor the server is showing this viewer; null until the premises page asks for one.
  viewed_z: number | null;
};

export type RoomInfo = {
  name: string;
  kind: 'guest' | 'service' | 'common';
  z: number;
  tiles: number;
  beds: number;
  // How many furnishings the survey listed in the room.
  items: number;
};

export type FloorInfo = {
  z: number;
  basement: BooleanLike;
  tiles: number;
};

export type Locale = {
  windowTitle: string;
  enterpriseNames: Record<string, string>;
  pages: Record<string, string>;
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
  };
  formatPremises: (floors: number, basements: number, tiles: number) => string;
  formatFloor: (number: number) => string;
};

export type PageProps = {
  locale: Locale;
  pageId: string;
};
