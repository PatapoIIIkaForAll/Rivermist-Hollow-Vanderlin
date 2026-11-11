import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { getPurposeLabel } from './purposes';
import type {
  ContentLine,
  IconInfo,
  Locale,
  RoomData,
  RoomPage,
  TenantInfo,
  UpgradeLine,
} from './types';
import { useIconRefs } from './useIconRefs';

const ICON_SIZE = '32px';
const DECISECONDS_IN_HOUR = 36000;
const DECISECONDS_IN_MINUTE = 600;
const COUNTDOWN_STEP = 15000;

type RoomPageProps = {
  locale: Locale;
};

const getLevelLabel = (locale: Locale, level: number) =>
  `${level} · ${locale.levelNames[level] || level}`;

const ItemIcon = (props: { item: IconInfo }) => {
  const { item } = props;
  const fallback = <Icon name="cube" size={1.5} />;

  return (
    <Box
      width={ICON_SIZE}
      height={ICON_SIZE}
      textAlign="center"
      style={{ lineHeight: ICON_SIZE }}
    >
      {item.icon ? (
        <DmIcon
          icon={item.icon}
          icon_state={item.icon_state || ''}
          width={ICON_SIZE}
          height={ICON_SIZE}
          fallback={fallback}
        />
      ) : (
        fallback
      )}
    </Box>
  );
};

const ContentRow = (props: { locale: Locale; line: ContentLine }) => {
  const { locale, line } = props;

  return (
    <Stack align="center" mb={0.5}>
      <Stack.Item>
        <ItemIcon item={line} />
      </Stack.Item>
      <Stack.Item grow>{line.name}</Stack.Item>
      {!!line.missing && (
        <Stack.Item color="bad">
          {locale.formatMissing(line.missing)}
        </Stack.Item>
      )}
      <Stack.Item color="label">×{line.count}</Stack.Item>
    </Stack>
  );
};

const UpgradeRow = (props: { line: UpgradeLine }) => {
  const { line } = props;

  return (
    <Stack align="center" mb={0.5}>
      <Stack.Item>
        <ItemIcon item={line.from} />
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {line.from.name}
        <Box inline color="label" ml={1}>
          ×{line.count}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Icon name="arrow-right" color="good" />
      </Stack.Item>
      <Stack.Item>
        <ItemIcon item={line.to} />
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {line.to.name}
      </Stack.Item>
    </Stack>
  );
};

const getStay = (locale: Locale, timeLeft: number | null) => {
  if (timeLeft === null || timeLeft === undefined) {
    return locale.room.tenantStayForever;
  }
  const hours = Math.floor(timeLeft / DECISECONDS_IN_HOUR);
  const minutes = Math.floor(
    (timeLeft % DECISECONDS_IN_HOUR) / DECISECONDS_IN_MINUTE,
  );
  return locale.formatStay(hours, minutes);
};

const StayLeft = (props: { locale: Locale; timeLeft: number | null }) => {
  const { locale, timeLeft } = props;
  const [since, setSince] = useState(Date.now());
  const [now, setNow] = useState(Date.now());

  useEffect(() => {
    setSince(Date.now());
    setNow(Date.now());
    if (timeLeft === null || timeLeft === undefined) {
      return;
    }
    const timer = setInterval(() => setNow(Date.now()), COUNTDOWN_STEP);
    return () => clearInterval(timer);
  }, [timeLeft]);

  if (timeLeft === null || timeLeft === undefined) {
    return <>{getStay(locale, null)}</>;
  }
  const passed = Math.floor((now - since) / 100);
  return <>{getStay(locale, Math.max(timeLeft - passed, 0))}</>;
};

const TenantDetails = (props: { locale: Locale; tenant: TenantInfo }) => {
  const { locale, tenant } = props;
  const needs = tenant.needs || [];

  return (
    <LabeledList>
      <LabeledList.Item label={locale.room.tenantName}>
        {tenant.name}
        {!!tenant.patron && (
          <Box inline color="label" ml={1}>
            ({locale.room.tenantPatron})
          </Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label={locale.room.tenantStay}>
        <StayLeft locale={locale} timeLeft={tenant.time_left} />
      </LabeledList.Item>
      <LabeledList.Item label={locale.room.tenantRent}>
        {tenant.rent}
      </LabeledList.Item>
      <LabeledList.Item label={locale.room.tenantNeeds}>
        {needs.length ? needs.join(', ') : locale.room.tenantNeedsNone}
      </LabeledList.Item>
    </LabeledList>
  );
};

const InfoPage = (props: RoomPageProps) => {
  const { locale } = props;
  const { data } = useBackend<RoomData>();
  const contents = data.contents || [];

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title={locale.room.about}>
          <LabeledList>
            <LabeledList.Item label={locale.room.purpose}>
              {getPurposeLabel(locale, data.enterprise, data.purpose)}
            </LabeledList.Item>
            <LabeledList.Item label={locale.room.floor}>
              {data.floor
                ? locale.formatFloor(data.floor)
                : locale.labels.basement}
            </LabeledList.Item>
            <LabeledList.Item label={locale.room.size}>
              {locale.formatTiles(data.tiles)}
            </LabeledList.Item>
            {!!data.beds && (
              <LabeledList.Item label={locale.room.beds}>
                {data.beds}
              </LabeledList.Item>
            )}
            {!!data.seatings && (
              <LabeledList.Item label={locale.room.seatings}>
                {data.seatings}
              </LabeledList.Item>
            )}
            <LabeledList.Item label={locale.room.level}>
              {getLevelLabel(locale, data.level)}
            </LabeledList.Item>
            {data.kind === 'guest' && (
              <LabeledList.Item label={locale.room.rent}>
                {data.rent || locale.room.rentNone}
              </LabeledList.Item>
            )}
            <LabeledList.Item label={locale.room.effect}>
              {data.effect || locale.room.effectNone}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={locale.room.tenant}>
          {data.tenant ? (
            <TenantDetails locale={locale} tenant={data.tenant} />
          ) : (
            <Box color="label">{locale.room.tenantNone}</Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={locale.room.contents}>
          {!contents.length && (
            <Box color="label">{locale.room.contentsNone}</Box>
          )}
          {contents.map((line) => (
            <ContentRow key={line.id} locale={locale} line={line} />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const UpgradeButtons = (props: RoomPageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<RoomData>();

  return (
    <Stack vertical>
      {!data.upgrade_cost && !data.can_grade && (
        <Stack.Item color="label">{locale.room.upgradeNotForSale}</Stack.Item>
      )}
      {!!data.upgrade_cost && (
        <Stack.Item>
          <Button
            fluid
            icon="arrow-up"
            textAlign="center"
            color="good"
            disabled={data.funds < data.upgrade_cost}
            onClick={() => act('upgrade')}
          >
            {locale.formatUpgrade(data.upgrade_cost)}
          </Button>
          <Box color="label" mt={0.5}>
            {locale.room.upgradeFunds}: {data.funds}
          </Box>
        </Stack.Item>
      )}
      {!!data.can_grade && (
        <Stack.Item>
          <Button
            fluid
            icon="crown"
            textAlign="center"
            tooltip={locale.room.prestigeGradeHint}
            onClick={() => act('prestige_grade')}
          >
            {locale.room.prestigeGrade}
          </Button>
        </Stack.Item>
      )}
    </Stack>
  );
};

const UpgradePage = (props: RoomPageProps) => {
  const { locale } = props;
  const { data } = useBackend<RoomData>();
  const upgrades = data.upgrades || [];
  const canGoUp = data.level < data.max_level;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section
          title={
            canGoUp
              ? locale.formatLevelUp(data.level, data.level + 1)
              : locale.formatLevel(data.level, data.max_level)
          }
        >
          <LabeledList>
            <LabeledList.Item
              label={`${locale.room.effectNow} (${locale.levelNames[data.level]})`}
            >
              {data.effect || locale.room.effectNone}
            </LabeledList.Item>
            {canGoUp && (
              <LabeledList.Item
                label={`${locale.room.effectNext} (${locale.levelNames[data.level + 1]})`}
                color="good"
              >
                {data.next_effect || locale.room.effectNone}
              </LabeledList.Item>
            )}
          </LabeledList>
          {!canGoUp && (
            <Box color="label" mt={1}>
              {locale.room.upgradeMaxLevel}
            </Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={locale.room.upgradeItems}>
          {!upgrades.length && (
            <Box color="label">{locale.room.upgradeItemsNone}</Box>
          )}
          {upgrades.map((line) => (
            <UpgradeRow key={line.id} line={line} />
          ))}
        </Section>
      </Stack.Item>
      {canGoUp && (
        <Stack.Item>
          <UpgradeButtons locale={locale} />
        </Stack.Item>
      )}
    </Stack>
  );
};

export const EnterpriseRoomView = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<RoomData>();
  const [chosen, setChosen] = useState({
    room: data.name,
    page: data.page,
    seq: data.page_seq,
  });
  useIconRefs();
  const purpose = getPurposeLabel(locale, data.enterprise, data.purpose);
  const ownChoice = chosen.room === data.name && chosen.seq === data.page_seq;
  const page = ownChoice ? chosen.page : data.page;
  const Page = page === 'upgrade' ? UpgradePage : InfoPage;
  const choose = (next: RoomPage) => {
    setChosen({ room: data.name, page: next, seq: data.page_seq });
    act('set_page', { page: next });
  };

  return (
    <Window title={`${data.name} — ${purpose}`} width={540} height={660}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Tabs>
                  <Tabs.Tab
                    icon="circle-info"
                    selected={page !== 'upgrade'}
                    onClick={() => choose('info')}
                  >
                    {locale.room.info}
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="arrow-up"
                    selected={page === 'upgrade'}
                    onClick={() => choose('upgrade')}
                  >
                    {locale.room.upgrade}
                  </Tabs.Tab>
                </Tabs>
              </Stack.Item>
              {!!data.repair_cost && (
                <Stack.Item>
                  <Button
                    icon="hammer"
                    color="average"
                    onClick={() => act('repair')}
                  >
                    {locale.formatRepair(data.repair_cost)}
                  </Button>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Page locale={locale} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
