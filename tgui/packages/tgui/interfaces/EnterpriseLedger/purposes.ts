import type { Locale } from './types';

export const PURPOSE_ICONS: Record<string, string> = {
  storage: 'box',
  drink_storage: 'wine-bottle',
  guest_room: 'bed',
  service_hall: 'beer-mug-empty',
  staff_quarters: 'users',
  kitchen: 'utensils',
};

export const getPurposeIcon = (purpose: string | null) =>
  (purpose && PURPOSE_ICONS[purpose]) || 'door-open';

export const getPurposeLabel = (
  locale: Locale,
  enterprise: string,
  purpose: string | null,
) => {
  if (!purpose) {
    return locale.purposeUnknown;
  }
  return (
    locale.enterprisePurposes[enterprise]?.[purpose] ||
    locale.purposes[purpose] ||
    purpose
  );
};
