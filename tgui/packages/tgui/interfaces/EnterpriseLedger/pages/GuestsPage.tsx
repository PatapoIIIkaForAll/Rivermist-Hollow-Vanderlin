import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  TimeDisplay,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { Data, GuestInfo, GuestsData, Locale, PageProps } from '../types';

const getOrderDoing = (locale: Locale, guest: GuestInfo) => {
  const text = locale.orders;
  const order = guest.order;
  const staying = guest.stage === 'stay';
  if (!order) {
    return staying ? locale.guests.tableStay : locale.guests.tableWalk;
  }
  const morning = order.morning ? `, ${text.morning}` : '';
  if (order.state === 'note') {
    return text.note + morning;
  }
  if (order.state === 'meal') {
    return text.meal + morning;
  }
  if (!staying || order.time_left === null) {
    return (staying ? text.wait : text.walk) + morning;
  }
  return (
    <>
      {text.wait} (
      <TimeDisplay
        auto="down"
        value={order.time_left}
        format={(value) => locale.formatOrderLeft(Math.ceil(value / 600))}
      />
      ){morning}
    </>
  );
};

const getDoing = (locale: Locale, guest: GuestInfo) => {
  const text = locale.guests;
  const staying = guest.stage === 'stay';
  switch (guest.goal) {
    case 'leave':
      return text.leaving;
    case 'bar':
      return staying ? text.barStay : text.barWalk;
    case 'table':
      return staying ? text.tableStay : text.tableWalk;
    case 'order':
      return getOrderDoing(locale, guest);
    case 'room':
      return staying ? text.roomStay : text.roomWalk;
    default:
      return text.idle;
  }
};

const getMood = (locale: Locale, guest: GuestInfo) => {
  if (guest.displeasure >= guest.max_displeasure) {
    return { text: locale.guests.moodFedUp, color: 'bad' };
  }
  if (guest.displeasure > 0) {
    return {
      text: locale.formatGrumbling(guest.displeasure, guest.max_displeasure),
      color: 'average',
    };
  }
  return { text: locale.guests.moodGood, color: 'good' };
};

const getCallBlock = (locale: Locale, guests: GuestsData) => {
  if (!guests.can_call) {
    return locale.guests.callStaff;
  }
  if (guests.calls_left <= 0) {
    return locale.guests.callNone;
  }
  if (!guests.open) {
    return locale.guests.callLocked;
  }
  return null;
};

const getMorning = (locale: Locale, guests: GuestsData) => {
  if (guests.morning_kind) {
    const kind = locale.guestKinds[guests.morning_kind] || guests.morning_kind;
    return guests.morning_locked
      ? `${kind}: ${locale.guests.morningLocked}`
      : locale.formatMorningCame(kind);
  }
  return guests.morning_due
    ? locale.guests.morningDue
    : locale.guests.morningNext;
};

type GuestRowProps = {
  locale: Locale;
  guest: GuestInfo;
};

const GuestRow = (props: GuestRowProps) => {
  const { locale, guest } = props;
  const doing = getDoing(locale, guest);
  const mood = getMood(locale, guest);
  const place = guest.goal !== 'leave' && guest.place;

  return (
    <Table.Row className="candystripe">
      <Table.Cell py={0.5}>
        {locale.guestKinds[guest.kind] || guest.name}
      </Table.Cell>
      <Table.Cell py={0.5}>
        {doing}
        {place && (
          <Box inline color="label" ml={1}>
            {place}
          </Box>
        )}
      </Table.Cell>
      <Table.Cell py={0.5} color={mood.color}>
        {mood.text}
      </Table.Cell>
    </Table.Row>
  );
};

export const GuestsPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const guests = data.guests;
  const text = locale.guests;

  if (!guests) {
    return (
      <Section fill title={text.title}>
        <NoticeBox>{locale.labels.sectionInProgress}</NoticeBox>
      </Section>
    );
  }

  const callBlock = getCallBlock(locale, guests);
  const present = guests.present || [];

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section
          title={text.title}
          buttons={
            <Button
              icon="bell"
              disabled={!!callBlock}
              tooltip={callBlock}
              onClick={() => act('call_guest')}
            >
              {text.call}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label={text.morning}>
              {getMorning(locale, guests)}
            </LabeledList.Item>
            <LabeledList.Item
              label={text.calls}
              color={guests.calls_left > 0 ? undefined : 'average'}
            >
              {locale.formatCalls(guests.calls_left, guests.calls_max)}
            </LabeledList.Item>
            <LabeledList.Item
              label={text.entrance}
              color={guests.open ? 'good' : 'bad'}
            >
              {guests.open ? text.entranceOpen : text.entranceClosed}
            </LabeledList.Item>
          </LabeledList>
          <Box color="label" mt={1}>
            {text.hint}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={text.present}>
          {present.length ? (
            <Table>
              <Table.Row header>
                <Table.Cell>{text.who}</Table.Cell>
                <Table.Cell>{text.doing}</Table.Cell>
                <Table.Cell>{text.mood}</Table.Cell>
              </Table.Row>
              {present.map((guest) => (
                <GuestRow key={guest.id} locale={locale} guest={guest} />
              ))}
            </Table>
          ) : (
            <NoticeBox>{text.presentNone}</NoticeBox>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
