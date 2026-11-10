import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { Data, Locale, PageProps } from '../types';

const getRoleLabel = (locale: Locale, data: Data) => {
  if (data.can_manage) {
    return locale.labels.roleManager;
  }
  if (data.is_staff) {
    return locale.labels.roleStaff;
  }
  return locale.labels.roleOutsider;
};

export const OverviewPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const { name, is_staff, shift_active } = data;
  const premises = data.floors || [];
  const tiles = premises.reduce((total, floor) => total + floor.tiles, 0);
  const basements = premises.filter((floor) => floor.basement).length;
  const rooms = data.rooms || [];

  return (
    <Section
      fill
      title={locale.enterpriseNames[name] || name}
      buttons={
        <Button
          icon={shift_active ? 'stop' : 'play'}
          color={shift_active ? 'bad' : 'good'}
          disabled={!is_staff}
          onClick={() => act(shift_active ? 'end_shift' : 'start_shift')}
        >
          {shift_active ? locale.labels.endShift : locale.labels.startShift}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label={locale.labels.yourRole}>
          {getRoleLabel(locale, data)}
        </LabeledList.Item>
        <LabeledList.Item
          label={locale.labels.shift}
          color={shift_active ? 'good' : 'average'}
        >
          {shift_active
            ? locale.labels.shiftActive
            : locale.labels.shiftInactive}
        </LabeledList.Item>
        <LabeledList.Item
          label={locale.labels.premises}
          color={premises.length ? undefined : 'bad'}
        >
          {premises.length
            ? locale.formatPremises(
                premises.length - basements,
                basements,
                tiles,
              )
            : locale.labels.premisesMissing}
        </LabeledList.Item>
        <LabeledList.Item label={locale.labels.guestRooms}>
          {rooms.length
            ? `${rooms.length}: ${rooms.map((room) => room.name).join(', ')}`
            : locale.labels.guestRoomsNone}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
