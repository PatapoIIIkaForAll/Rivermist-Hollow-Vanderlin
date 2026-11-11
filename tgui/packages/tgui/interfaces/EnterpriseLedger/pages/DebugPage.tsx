import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { getPurposeLabel } from '../purposes';
import type { Data, Locale, PageProps, RoomInfo } from '../types';

const MONEY_STEPS = [-1000, -100, 100, 1000, 10000];

type MoneyRowProps = {
  label: string;
  value: number;
  field: string;
  onSet: (field: string, value: number) => void;
};

const MoneyRow = (props: MoneyRowProps) => {
  const { label, value, field, onSet } = props;

  return (
    <LabeledList.Item label={label}>
      <Stack align="center">
        <Stack.Item width="6em" bold>
          {value}
        </Stack.Item>
        {MONEY_STEPS.map((step) => (
          <Stack.Item key={step}>
            <Button onClick={() => onSet(field, Math.max(value + step, 0))}>
              {step > 0 ? `+${step}` : step}
            </Button>
          </Stack.Item>
        ))}
        <Stack.Item>
          <Button color="bad" onClick={() => onSet(field, 0)}>
            0
          </Button>
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};

type LevelButtonsProps = {
  max: number;
  current: number | null;
  onPick: (level: number) => void;
};

const LevelButtons = (props: LevelButtonsProps) => {
  const { max, current, onPick } = props;
  const levels = Array.from({ length: max + 1 }, (_, level) => level);

  return (
    <>
      {levels.map((level) => (
        <Button
          key={level}
          selected={level === current}
          onClick={() => onPick(level)}
        >
          {level}
        </Button>
      ))}
    </>
  );
};

type RoomRowProps = {
  locale: Locale;
  enterprise: string;
  room: RoomInfo;
  max: number;
  onLevel: (room: number, level: number) => void;
};

const RoomRow = (props: RoomRowProps) => {
  const { locale, enterprise, room, max, onLevel } = props;

  return (
    <Stack align="center" mb={0.5}>
      <Stack.Item grow>
        {room.name}
        <Box inline color="label" ml={1}>
          {getPurposeLabel(locale, enterprise, room.purpose)} ·{' '}
          {locale.levelNames[room.level] || room.level}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <LevelButtons
          max={max}
          current={room.level}
          onPick={(level) => onLevel(room.id, level)}
        />
      </Stack.Item>
    </Stack>
  );
};

export const DebugPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const debug = data.debug;

  if (!debug) {
    return (
      <Section fill title={locale.debug.title}>
        <NoticeBox>{locale.labels.sectionInProgress}</NoticeBox>
      </Section>
    );
  }

  const rooms = data.rooms || [];
  const setValue = (field: string, value: number) =>
    act('debug_set', { field, value });
  const setRoomLevel = (room: number, level: number) =>
    act('debug_room_level', { room, level });

  return (
    <Section fill scrollable title={locale.debug.title}>
      <NoticeBox info>{locale.debug.note}</NoticeBox>
      <Section title={locale.debug.money}>
        <LabeledList>
          <MoneyRow
            label={locale.labels.bookBalance}
            value={data.book_balance}
            field="book"
            onSet={setValue}
          />
          <MoneyRow
            label={locale.debug.bank}
            value={debug.bank}
            field="bank"
            onSet={setValue}
          />
          <MoneyRow
            label={locale.labels.earnedToday}
            value={data.earned_today}
            field="earned_today"
            onSet={setValue}
          />
          <MoneyRow
            label={locale.labels.earnedRound}
            value={data.earned_round}
            field="earned_round"
            onSet={setValue}
          />
        </LabeledList>
      </Section>
      <Section title={locale.debug.ownerLevel}>
        <LevelButtons
          max={debug.max_owner_level}
          current={debug.owner_level}
          onPick={(level) => setValue('owner_level', level)}
        />
        <Button ml={1} icon="door-open" onClick={() => act('debug_grant')}>
          {locale.debug.grant}
        </Button>
      </Section>
      <Section title={locale.debug.patrons}>
        <Box mb={1}>
          {locale.debug.patronsCount}: {debug.patrons}
        </Box>
        {debug.patron_kinds.map((name, index) => (
          <Button
            key={name}
            icon="user-plus"
            onClick={() => act('debug_patron', { kind: index + 1 })}
          >
            {locale.debug.summon}: {name}
          </Button>
        ))}
        <Button
          icon="user-xmark"
          color="bad"
          disabled={!debug.patrons}
          onClick={() => act('debug_clear_patrons')}
        >
          {locale.debug.clearPatrons}
        </Button>
      </Section>
      <Section title={locale.debug.time}>
        <Button icon="sun" onClick={() => act('debug_new_day')}>
          {locale.debug.newDay}
        </Button>
        <Button icon="moon" onClick={() => act('debug_evening')}>
          {locale.debug.evening}
        </Button>
        <Button icon="utensils" onClick={() => act('debug_orders')}>
          {locale.orders.debugMorning}
        </Button>
        <Button icon="bed" onClick={() => act('debug_tired')}>
          {locale.debug.tired}
        </Button>
      </Section>
      <Section title={locale.debug.rooms}>
        <Stack align="center" mb={1}>
          <Stack.Item grow bold>
            {locale.debug.allRooms}
          </Stack.Item>
          <Stack.Item>
            <LevelButtons
              max={debug.max_room_level}
              current={null}
              onPick={(level) => setRoomLevel(0, level)}
            />
          </Stack.Item>
        </Stack>
        {rooms.map((room) => (
          <RoomRow
            key={room.id}
            locale={locale}
            enterprise={data.name}
            room={room}
            max={debug.max_room_level}
            onLevel={setRoomLevel}
          />
        ))}
      </Section>
    </Section>
  );
};
