import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  // ui_static_data
  name: string;
  pages: string[];

  // ui_data
  can_manage: BooleanLike;
  is_staff: BooleanLike;
  shift_active: BooleanLike;
  premises: FloorRow[];
};

export type FloorRow = {
  z: number;
  tiles: number;
  basement: BooleanLike;
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
  };
  formatPremises: (floors: number, basements: number, tiles: number) => string;
};

export type PageProps = {
  locale: Locale;
  pageId: string;
};
