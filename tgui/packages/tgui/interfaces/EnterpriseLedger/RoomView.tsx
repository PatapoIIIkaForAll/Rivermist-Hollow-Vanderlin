import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
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
  TenantInfo,
  UpgradeLine,
} from './types';

const ICON_SIZE = '32px';
const DECISECONDS_IN_HOUR = 36000;
const DECISECONDS_IN_MINUTE = 600;

type RoomPageProps = {
  locale: Locale;
};

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

const TenantDetails = (props: { locale: Locale; tenant: TenantInfo }) => {
  const { locale, tenant } = props;
  const hours = Math.floor(tenant.time_left / DECISECONDS_IN_HOUR);
  const minutes = Math.floor(
    (tenant.time_left % DECISECONDS_IN_HOUR) / DECISECONDS_IN_MINUTE,
  );
  const needs = tenant.needs || [];

  return (
    <LabeledList>
      <LabeledList.Item label={locale.room.tenantName}>
        {tenant.name}
      </LabeledList.Item>
      <LabeledList.Item label={locale.room.tenantStay}>
        {locale.formatStay(hours, minutes)}
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
            <LabeledList.Item label={locale.room.level}>
              {locale.formatLevel(data.level, data.max_level)}
            </LabeledList.Item>
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
            <LabeledList.Item label={locale.room.effectNow}>
              {data.effect || locale.room.effectNone}
            </LabeledList.Item>
            {canGoUp && (
              <LabeledList.Item label={locale.room.effectNext} color="good">
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
      <Stack.Item>
        <NoticeBox info>{locale.room.upgradeSoon}</NoticeBox>
        <Button fluid disabled icon="arrow-up" textAlign="center">
          {locale.room.upgrade}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const EnterpriseRoomView = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<RoomData>();
  const purpose = getPurposeLabel(locale, data.enterprise, data.purpose);
  const Page = data.page === 'upgrade' ? UpgradePage : InfoPage;

  return (
    <Window title={`${data.name} — ${purpose}`} width={520} height={640}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item grow>
                <Tabs>
                  <Tabs.Tab
                    icon="circle-info"
                    selected={data.page !== 'upgrade'}
                    onClick={() => act('set_page', { page: 'info' })}
                  >
                    {locale.room.info}
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon="arrow-up"
                    selected={data.page === 'upgrade'}
                    onClick={() => act('set_page', { page: 'upgrade' })}
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
