import type { Locale } from './types';

const locale: Locale = {
  windowTitle: 'Enterprise Ledger',
  enterpriseNames: {
    enterprise: 'Enterprise',
    tavern: 'Tavern',
  },
  pages: {
    overview: 'Overview',
    menu: 'Menu',
    staff: 'Workers',
    zones: 'Zones & Upgrades',
    commissions: 'Commissions',
  },
  labels: {
    yourRole: 'Your role',
    roleManager: 'Manager',
    roleStaff: 'Staff',
    roleOutsider: 'Outsider',
    shift: 'Shift',
    shiftActive: 'In progress',
    shiftInactive: 'Not started',
    startShift: 'Start shift',
    endShift: 'End shift',
    sectionInProgress: 'This section of the ledger is still blank.',
    premises: 'Premises',
    premisesMissing: 'Not found: the ledger stands outside the premises.',
  },
  formatPremises: (floors, basements, tiles) =>
    `Floors: ${floors}, basement levels: ${basements}, tiles: ${tiles}`,
};

export default locale;
