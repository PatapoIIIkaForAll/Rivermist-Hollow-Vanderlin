import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  // ui_static_data
  name: string;
  pages: string[];
  plan: FloorPlan[];

  // ui_data
  can_manage: BooleanLike;
  is_staff: BooleanLike;
  shift_active: BooleanLike;
};

export type FloorPlan = {
  z: number;
  basement: BooleanLike;
  width: number;
  height: number;
  tiles: number;
  // One string per row, south row first, one character per turf; see CELL_KINDS in PremisesPage.
  rows: string[];
  objects: PlanObject[];
};

export type PlanObject = {
  // Column and row inside the floor, counted from its south-west corner.
  x: number;
  y: number;
  name: string;
};

export type CellKind =
  | 'wall'
  | 'floor'
  | 'furnished'
  | 'openSpace'
  | 'door'
  | 'stairs'
  | 'ledger';

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
    refresh: string;
  };
  cellKinds: Record<CellKind, string>;
  formatPremises: (floors: number, basements: number, tiles: number) => string;
  formatFloor: (number: number) => string;
};

export type PageProps = {
  locale: Locale;
  pageId: string;
};
