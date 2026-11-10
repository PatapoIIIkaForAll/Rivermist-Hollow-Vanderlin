import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  // ui_static_data
  name: string;
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
  // The lock id of the room's doors.
  id: string;
  name: string;
  z: number;
  tiles: number;
  beds: number;
};

export type FloorInfo = {
  z: number;
  basement: BooleanLike;
  tiles: number;
  // The id of the BYOND map control that shows this floor.
  map: string;
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
  };
  formatPremises: (floors: number, basements: number, tiles: number) => string;
  formatFloor: (number: number) => string;
};

export type PageProps = {
  locale: Locale;
  pageId: string;
};
